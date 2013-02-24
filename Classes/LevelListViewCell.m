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

#import "LevelListViewCell.h"


@implementation LevelListViewCell

@synthesize border;

- (id)initWithFrame:(CGRect)frame
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
  if (self == nil) {
    return nil;
  }
  
  self.selectionStyle = AQGridViewCellSelectionStyleGlow;
  self.selectionGlowColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
  self.selectionGlowShadowRadius = 25;
  
  self.border = [[[CALayer alloc] init] autorelease];
  self.border.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor;
  if (_DeviceModel == MiscDeviceModelIPad) {
    self.border.frame = CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 20);
    self.border.cornerRadius = 20.0f;
  } else {
    self.border.frame = CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10);
    self.border.cornerRadius = 10.0f;
  }
  self.border.zPosition = -10;
  [self.contentView.layer addSublayer:self.border];
  
  return self;
}

- (void)dealloc {
  [self.border removeFromSuperlayer];
  self.border = nil;
  
  [super dealloc];
}

@end
