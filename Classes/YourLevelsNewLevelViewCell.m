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

#import "YourLevelsNewLevelViewCell.h"
#import "SlippyLabel.h"

@implementation YourLevelsNewLevelViewCell

- (id)initWithFrame:(CGRect)frame
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
  if (self == nil) {
    return nil;
  }
  
  UIImageView *image = [[[UIImageView alloc]
			 initWithImage:I.images.plus]
			autorelease];
  image.center = CGPointMake(self.contentView.bounds.size.width / 2,
			     self.contentView.bounds.size.height * 0.44f);
  image.frame = CGRectInt(image.frame);
  [self.contentView addSubview:image];
  
  SlippyLabel *text = [[[SlippyLabel alloc] init] autorelease];
  text.fontSize = (int)(self.contentView.bounds.size.height / 8.0f);
  text.frame = CGRectMake(0, frame.size.height / 2 + 5,
                          frame.size.width, 20);
  text.textAlignment = UITextAlignmentCenter;
  text.text = @"New level";
  text.bounds = CGRectMake(0, 0,
			   self.contentView.bounds.size.width,
			   text.fontSize + 5);
  text.center = CGPointMake(self.contentView.bounds.size.width / 2,
			    self.contentView.bounds.size.height * 0.66f);
  text.frame = CGRectInt(text.frame);
  [self.contentView addSubview:text];
  
  return self;
}

@end
