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

#import "SlippyBarViewController.h"


@implementation SlippyBarViewController

@synthesize barHeight;

+ (NSString *)name {
  return @"SlippyBar";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (_DeviceModel == MiscDeviceModelIPad) {
    self.barHeight = 60;
  } else {
    self.barHeight = 30;
  }
  
  CALayer *fade = [[[CALayer alloc] init] autorelease];
  fade.backgroundColor = [UIColor colorWithRed:0.18f
                                         green:0.55f
                                          blue:0.74f
                                         alpha:1.0f].CGColor;
  fade.frame = CGRectMake(0, 0,
			  self.view.bounds.size.width,
			  self.barHeight);
  [self.view.layer addSublayer:fade];
  
  float d = _CGScale == 2.0 ? 0.5f : 1.0f;
  
  CALayer *line = [[[CALayer alloc] init] autorelease];
  line.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f].CGColor;
  line.frame = CGRectMake(0, self.barHeight, self.view.bounds.size.width, d);
  [self.view.layer addSublayer:line];
  
  line = [[[CALayer alloc] init] autorelease];
  line.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.6f].CGColor;
  line.frame = CGRectMake(0, self.barHeight + d, self.view.bounds.size.width, d);
  [self.view.layer addSublayer:line];
}

@end
