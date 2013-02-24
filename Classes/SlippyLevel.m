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

#import "SlippyLevel.h"
#import "LevelDatabase.h"

@implementation SlippyLevel

@synthesize id_;
@synthesize author;
@synthesize authorHash;
@synthesize email;
@synthesize name;
@synthesize added;
@synthesize rating;
@synthesize ratings;
@synthesize width;
@synthesize height;
@synthesize data;
@synthesize locked;
@synthesize uploaded;
@synthesize new_;
@synthesize firstDownloaded;
@synthesize userRating;

@synthesize order;
@synthesize source;
@synthesize completed;
@synthesize completedAfterEdit;


- (BOOL)isEqual:(id)object {
  return [self.id_ isEqual:object];
}

- (NSUInteger)hash {
  return [self.id_ hash];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ id=%@ name=%@>",
          [super description], self.id_, self.name];
}

- (void)dealloc {
  self.id_ = nil;
  self.source = nil;
  self.author = nil;
  self.authorHash = nil;
  self.email = nil;
  self.name = nil;
  self.added = nil;
  self.data = nil;
  self.firstDownloaded = nil;
  
  [super dealloc];
}

- (NSDictionary *)savePlist {
  NSMutableDictionary *d = [NSMutableDictionary dictionary];
  
  [d setObject:self.id_ forKey:@"id"];
  [d setObject:self.added forKey:@"added"];
  if (self.author != nil) {
    [d setObject:self.author forKey:@"author"];
  }
  if (self.email != nil) {
    [d setObject:self.email forKey:@"email"];
  }
  if (self.name != nil) {
    [d setObject:self.name forKey:@"name"];
  }
  [d setObject:[NSNumber numberWithInt:self.width] forKey:@"width"];
  [d setObject:[NSNumber numberWithInt:self.height] forKey:@"height"];
  [d setObject:self.data forKey:@"data"];
  
  if ([self.source isEqualToString:LevelDatabaseSourceCommunityName]) {
    [d setObject:[NSNumber numberWithInt:self.ratings] forKey:@"ratings"];
    [d setObject:[NSNumber numberWithFloat:self.rating] forKey:@"rating"];
    [d setObject:[NSNumber numberWithBool:self.new_] forKey:@"new"];
    if (self.firstDownloaded != nil) {
      [d setObject:self.firstDownloaded forKey:@"firstdownloaded"];
    }
    if (self.authorHash != nil) {
      [d setObject:self.authorHash forKey:@"authorhash"];
    }
  }
  
  if ([self.source isEqualToString:LevelDatabaseSourceYourName]) {
    [d setObject:[NSNumber numberWithBool:self.uploaded] forKey:@"uploaded"];
  }

  return [NSDictionary dictionaryWithDictionary:d];
}

@end
