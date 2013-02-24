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

#import "NSDate+fuzzy.h"


@implementation NSDate (fuzzy)

- (NSString *)fuzzySince:(NSDate *)date {
  NSTimeInterval delta = fabs([self timeIntervalSinceDate:date]);
    
  if (delta < 60) {
    return @"a few seconds";
  } else if (delta < 60*30) {
    return @"a few minutes";
  } else if (delta < 60*60*12) {
    return @"a few hours";
  } else if (delta < 60*60*24) {
    return @"less then a day";
  } else {
    int days = round((float)delta /
                     (float)(60*60*24));
                     
    return [NSString stringWithFormat:@"%d day%@",
            days, days > 1 ? @"s" : @""];
  }
}

- (NSString *)fuzzySinceNow {
  return [self fuzzySince:[NSDate date]];
}

@end
