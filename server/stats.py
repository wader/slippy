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

class Player:
  def __init__(self):
    self.uploaded = []
    self.ratings = []

class Stats(webapp.RequestHandler):
  def w(self, s):
    self.response.out.write(s)

  def get(self):
    players = {}
    levels = {}
    fetch = Level.all().fetch(100000)
    for l in fetch:
      levels[l.id] = l
      if not players.has_key(l.udid):
	players[l.udid] = Player()
      players[l.udid].uploaded.append(l)

    ratings = {}
    fetch = LevelStatistics.all().fetch(100000)
    for r in fetch:
      if not players.has_key(r.udid):
	players[r.udid] = Player()
      players[r.udid].ratings.append(r)

    self.w("players: %d<br>" % len(players))
    self.w("<table border=1>")
    for udid, p in players.items():
      self.w("<tr>")
      self.w("<td valign=top>%s</td>" % udid)
      self.w("<td valign=top>")
      for u in p.uploaded:
	self.response.out.write("%s" % u.name)
      self.w("</td>")
      self.w("<td valign=top>")
      for r in p.ratings:
	if levels.has_key(r.levelid):
	  self.response.out.write("%s" % levels[r.levelid].name)
	else:
	  self.response.out.write("<deleted>")
      self.w("</td>")
      self.w("</tr>")
    self.w("</table>")


def main():
  application = webapp.WSGIApplication([("/stats", Stats)],
                                       debug=True)
  run_wsgi_app(application)

if __name__ == '__main__':
  main()
