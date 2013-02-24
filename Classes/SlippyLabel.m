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

#import "SlippyLabel.h"

@implementation SlippyLabel

- (id)init {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  
  self.font = [UIFont fontWithName:@"Arial Rounded MT Bold"
                              size:[UIFont labelFontSize]];
  self.backgroundColor = [UIColor clearColor];
  self.gradientColors = [NSArray arrayWithObjects:
			 [UIColor colorWithWhite:1.0f alpha:1.0f],
			 [UIColor colorWithWhite:1.0f alpha:1.0f],
			 [UIColor colorWithWhite:0.65f alpha:1.0f],
			 nil];
  self.gradientLocations = [NSArray arrayWithObjects:
			    [NSNumber numberWithFloat:0.0f],
			    [NSNumber numberWithFloat:0.2f],
			    [NSNumber numberWithFloat:1.0f],
			    nil];
  self.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
  self.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
  if (_DeviceModel == MiscDeviceModelIPad) {
    self.shadowOffset = CGSizeMake(1.25f, 1.25f);
  } else {
    self.shadowOffset = CGSizeMake(0.75f, 0.75f);
  }
  self.backgroundColor = [UIColor clearColor];
  
  return self;
}

- (void)setFontSize:(CGFloat)size {
  self.font = [UIFont fontWithName:self.font.fontName size:size];
}

- (CGFloat)fontSize {
  return self.font.pointSize;
}

@end
