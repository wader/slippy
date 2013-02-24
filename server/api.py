# Copyright (c) 2013 <mattias.wadman@gmail.com>
#
# MIT License:
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import logging
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db
import plistlib
from random import choice
import string
from django.utils import simplejson
import datetime

import PyRSS2Gen
from level import Level, LevelStatistics

import datastore_cache
datastore_cache.DatastoreCachingShim.Install()

def randomstring(length=8, chars=string.letters + string.digits):
  return "".join([choice(chars) for i in range(length)])

class DateTimeJSONEncoder(simplejson.JSONEncoder):
  def default(self, obj):
    if isinstance(obj, datetime.datetime):
      return obj.strftime('%Y-%m-%dT%H:%M:%S')
    else:
      return simplejson.JSONEncoder.default(self, obj)

class APIHandler(webapp.RequestHandler):
  accepted_formats = ["json", "jsonp", "plist"]
  format = "json"
  required_args = []
  value = None
  raw = False

  def set_error(self, message):
    self.response.set_status(400)
    self.value = {"error": message}

  def verify(self):
    for arg in self.required_args:
      if arg not in self.request.arguments():
        return self.set_error("%s argument is missing" % arg)

      if self.request.get(arg).strip() == "":
        return self.set_error("%s argument is empty" % arg)

  def result(self):
    if self.raw:
      self.response.out.write(self.value)
      return

    if self.format not in self.accepted_formats:
      self.set_error("Format %s not accepted" % self.format)
      self.format = "json"

    if self.value is None:
      self.value = True

    if self.format is None or self.format == "json" or self.format == "jsonp":
      json = DateTimeJSONEncoder().encode(self.value)
      if self.format == "jsonp":
        json = self.request.get("cb", "cb") + "(" + json + ");"
        self.response.headers["Content-Type"] = "application/javascript"
      else:
        self.response.headers["Content-Type"] = "application/json"
      self.response.out.write(json)
    elif self.format == "plist":
      self.response.headers["Content-Type"] = "application/xml"
      self.response.out.write(plistlib.writePlistToString(self.value))
    else:
      self.response.out.write("unknown format %s" % self.format)

  def _do(self, *args, **kw):
    self.verify()

    # if last group is an extension (eg: .plist) set it as format and remove group
    if args[-1] is not None and len(args[-1]) > 0 and args[-1][0] == ".":
      self.format = args[-1][1:]
    args = args[0:-1]

    if self.value is None:
      self.do(*args, **kw)
    self.result()

  def get(self, *args, **kw):
    self._do(*args, **kw)

  def post(self, *args, **kw):
    self._do(*args, **kw)

class Levels(APIHandler):
  accepted_formats = APIHandler.accepted_formats + ["rss"]

  def do(self, limit):
    levels_query = Level.all(keys_only=True)

    if limit == "rated":
      levels_query.filter("rated =", True)
    elif limit == "new":
      one_month_ago = datetime.datetime.now() - datetime.timedelta(days=31)
      levels_query.filter("rated =", True)
      levels_query.filter("added >", one_month_ago)
    elif limit == "top":
      levels_query.filter("rated =", True)
      levels_query.order("-rating")

    levelkeys = levels_query.fetch(1000)
    levels = db.get(levelkeys)

    if self.format == "rss":
      last = datetime.datetime.now()
      if len(levels) > 0:
        last = levels[0].added

      def name(l):
	if l.author == "":
	  return l.name
	return l.name + " by " + l.author

      self.raw = True
      self.response.headers["Content-Type"] = "application/rss+xml"
      self.value = PyRSS2Gen.RSS2(
              title="Slippy recent levels",
              link="http://www.inwader.com/slippy/",
              description="Recently uploaded levels for Slippy the puzzel game",
              lastBuildDate=last,
              items=[
              PyRSS2Gen.RSSItem(
                      title=name(l),
                      link="http://www.inwader.com/slippy/",
                      description="",
                      guid=PyRSS2Gen.Guid(l.id, isPermaLink=False),
                      pubDate=l.added)
              for l in levels
              ]).to_xml(encoding="utf-8")
    else:
      self.value = {
        "version": 0,
        "levels": [l.dict() for l in levels]
      }

class UploadLevel(APIHandler):
  required_args = ["udid", "data"]

  def do(self):
    datalen = 16 * 9
    data = self.request.get("data")
    if len(data) != datalen:
      return self.set_error("Data argument has invalid length (%d != %d)" %\
                            (len(data), datalen))

    id = "community" + randomstring(16)
    Level(id=id,
	  udid=self.request.get("udid"),
	  author=self.request.get("author"),
	  email=self.request.get("email"),
	  name=self.request.get("name"),
	  data=self.request.get("data"),
	  rated=False).put()
    self.value = id

class UploadStatistics(APIHandler):
  required_args = ["levelid", "udid", "rating", "solvetime", "pushes", "moves"]

  def do(self):
    levelid = self.request.get("levelid")
    l = Level.gql("WHERE id = :1", levelid).get()
    if l is None:
      return self.set_error("Level %s does not exist." % levelid)

    udid = self.request.get("udid")
    if l.udid == udid:
      return self.set_error("Sorry, you can't rate your own levels.")

    levelstat = LevelStatistics.gql("WHERE levelid = :1 AND udid = :2",
				    levelid, udid).get()
    if levelstat is not None:
      return self.set_error("Sorry, this level has already been rated from this device.")

    rating = self.request.get_range("rating", 0, 5)

    s = LevelStatistics(levelid=levelid,
			udid=udid,
			rating=rating,
			solvetime=self.request.get_range("solvetime", 0, 1000000),
			pushes=self.request.get_range("pushes", 0, 1000000),
			moves=self.request.get_range("moves", 0, 1000000),
			new=True)

    # make it appear as rated immediately 
    if not l.rated:
      s.new = False
      l.ratings = 1
      l.ratingsum = rating
      l.rating = float(rating)
      l.rated = True
      l.put()

    s.put()

    self.value = "ok"

def main():
  application = webapp.WSGIApplication([("/api/1/levels/(all|rated|new|top)(\..+)?", Levels),
                                        ("/api/1/uploadlevel(\..+)?", UploadLevel),
                                        ("/api/1/uploadstatistics(\..+)?", UploadStatistics)],
                                       debug=True)
  run_wsgi_app(application)

if __name__ == '__main__':
  main()
