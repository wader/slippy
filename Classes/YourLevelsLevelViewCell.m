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

#import "YourLevelsLevelViewCell.h"
#import "LevelPreviewView.h"


@interface YourLevelsLevelViewCell ()

@property(nonatomic, retain) SlippyLevel *level;
@property(nonatomic, retain) LevelPreviewView *preview;

@end


@implementation YourLevelsLevelViewCell

@synthesize level;
@synthesize preview;

- (void)update {
  [self.preview rerender];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {  
  [self update];
}

- (id)initWithFrame:(CGRect)frame
              level:(SlippyLevel *)aLevel
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
  if (self == nil) {
    return nil;
  }
  
  self.level = aLevel;
  
  self.preview = [[[LevelPreviewView alloc]
                   initWithFrame:CGRectMake(0, 0,
                                            SLIPPY_LEVEL_WIDTH * 16,
                                            SLIPPY_LEVEL_HEIGHT * 16)
                   level:level]
                  autorelease];
  self.preview.center = CGPointMake(self.contentView.bounds.size.width / 2,
				    self.contentView.bounds.size.height / 2);
  self.preview.frame = CGRectInt(self.preview.frame);
  self.preview.userInteractionEnabled = NO;
  [self.contentView addSubview:self.preview];
  
  [self.level addObserver:self forKeyPath:@"data" options:0 context:NULL];
  
  return self;
}

- (void)dealloc {
  [self.level removeObserver:self forKeyPath:@"data"];
  
  [self.preview removeFromSuperview];
  self.preview = nil;
  
  [super dealloc];
}

@end
