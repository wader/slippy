// Copyright (c) 2013 <mattias.wadman@gmail.com>
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// TODO: ivar needed for gdb
@interface SlippyLevel : NSObject {
  NSString *id_;
  NSString *author;
  NSString *authorHash;
  NSString *email;
  NSString *name;
  NSDate *added;
  float rating;
  int ratings;
  int width;
  int height;
  NSString *data;
  BOOL locked;
  BOOL uploaded;
  BOOL new_;
  NSDate *firstDownloaded;
  int userRating;
  
  int order;
  NSString *source;
  BOOL completed;
  BOOL completedAfterEdit;
}

@property(nonatomic, retain) NSString *id_;
@property(nonatomic, retain) NSString *author;
@property(nonatomic, retain) NSString *authorHash;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSDate *added;
@property(nonatomic, assign) float rating;
@property(nonatomic, assign) int ratings;
@property(nonatomic, assign) int width;
@property(nonatomic, assign) int height;
@property(nonatomic, retain) NSString *data;
@property(nonatomic, assign) BOOL locked;
@property(nonatomic, assign) BOOL uploaded;
@property(nonatomic, assign) BOOL new_;
@property(nonatomic, retain) NSDate *firstDownloaded;
@property(nonatomic, assign) int userRating;

@property(nonatomic, assign) int order;
@property(nonatomic, retain) NSString *source;
@property(nonatomic, assign) BOOL completed;
@property(nonatomic, assign) BOOL completedAfterEdit;

- (NSDictionary *)savePlist;

@end
