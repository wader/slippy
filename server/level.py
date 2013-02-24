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

from google.appengine.ext import db

class LevelStatistics(db.Model):
  levelid = db.StringProperty(required=True)
  udid = db.StringProperty(required=True)
  added = db.DateTimeProperty(auto_now_add=True)
  new = db.BooleanProperty(default=False)
  rating = db.IntegerProperty(required=True)
  solvetime = db.IntegerProperty(required=True)
  pushes = db.IntegerProperty(required=True)
  moves = db.IntegerProperty(required=True)

class Level(db.Model):
  id = db.StringProperty(required=True)
  udid = db.StringProperty(required=True)
  author = db.StringProperty(default="")
  email = db.StringProperty(default="")
  name = db.StringProperty(default="")
  added = db.DateTimeProperty(auto_now_add=True)
  width = db.IntegerProperty(required=True, default=16)
  height = db.IntegerProperty(required=True, default=9)
  data = db.StringProperty(required=True)
  ratings = db.IntegerProperty(default=0)
  ratingsum = db.IntegerProperty(default=0)
  rating = db.FloatProperty(default=0.0)
  rated = db.BooleanProperty(default=False)

  # public level dict
  def dict(self):
    return {
      "id": self.id,
      "authorhash": self.udid,
      "author": self.author,
      "email": self.email,
      "name": self.name,
      "added": self.added,
      "width": self.width,
      "height": self.height,
      "data": self.data,
      "ratings": self.ratings,
      "rating": self.rating
    }

