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
from google.appengine.api import memcache
from level import Level, LevelStatistics

import datastore_cache
datastore_cache.DatastoreCachingShim.Install()

class ResetCache(webapp.RequestHandler):
  def get(self):
    memcache.flush_all()

class ResetRatings(webapp.RequestHandler):
  def get(self):
    while True:
      old = db.get(LevelStatistics.all(keys_only=True).filter("new =", False).fetch(1000))
      if len(old) == 0:
	break

      updated = []
      for o in old:
	o.new = True
	updated.append(o)
      db.put(updated)

    updated = []
    for l in db.get(Level.all(keys_only=True).fetch(1000)):
      l.ratings = 0
      l.ratingsum = 0
      updated.append(l)
    db.put(updated)
    logging.debug("reset ratings")

class Ratings(webapp.RequestHandler):
  def get(self):

    while True:
      new = db.get(LevelStatistics.all(keys_only=True).filter("new =", True).fetch(1000))
      if len(new) == 0:
        break

      levels = {}
      for id in set([n.levelid for n in new]):
	l = Level.gql("WHERE id = :1", id).get()
	if l is None:
	  continue
	levels[id] = l

      updated = []
      for n in new:
        n.new = False
	updated.append(n)
	try:
	  l = levels[n.levelid]
	  l.ratings += 1
	  l.ratingsum += n.rating
	  l.rated = True
	except KeyError:
	  continue

      for l in levels.values():
	l.rating = float(l.ratingsum) / float(l.ratings)
	updated.append(l)
	logging.debug("%s: %f sum=%d ratings=%d" % (l.name, l.rating, l.ratingsum, l.ratings))

      db.put(updated)
	
def main():
  application = webapp.WSGIApplication([("/tasks/ratings", Ratings),
                                        ("/tasks/resetratings", ResetRatings),
                                        ("/tasks/resetcache", ResetCache)],
                                       debug=True)
  run_wsgi_app(application)

if __name__ == '__main__':
  main()
