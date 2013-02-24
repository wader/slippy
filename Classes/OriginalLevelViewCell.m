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

#import "OriginalLevelViewCell.h"
#import "LevelPreviewView.h"
#import "SlippyLabel.h"


@interface OriginalLevelViewCell ()

@property(nonatomic, retain) SlippyLevel *level;
@property(nonatomic, retain) UIImageView *dotGreyImage;
@property(nonatomic, retain) UIImageView *doneImage;
@property(nonatomic, retain) SlippyLabel *levelNumber;
@property(nonatomic, retain) LevelPreviewView *preview;

@end


@implementation OriginalLevelViewCell

@synthesize level;
@synthesize dotGreyImage;
@synthesize doneImage;
@synthesize levelNumber;
@synthesize preview;

- (void)update {
  self.doneImage.hidden = !self.level.completed;
  self.levelNumber.hidden = self.level.completed;
  
  self.alpha = self.level.locked ? 0.25f : 1.0f;
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
  self.preview.center = CGPointMake(self.bounds.size.width / 2,
				    self.bounds.size.height / 2);
  self.preview.frame = CGRectInt(self.preview.frame);
  self.preview.userInteractionEnabled = NO;
  [self.contentView addSubview:self.preview];
  
  UIImage *dotImage = I.images.dot;
  self.dotGreyImage = [[[UIImageView alloc] initWithImage:dotImage]
                       autorelease];
  self.dotGreyImage.center = CGPointMake(self.bounds.size.width * 0.85f,
					 self.bounds.size.height * 0.8f);
  self.dotGreyImage.frame = CGRectInt(self.dotGreyImage.frame);
  [self.contentView addSubview:self.dotGreyImage];
  
  UIImage *checkImage = I.images.check;
  self.doneImage = [[[UIImageView alloc] initWithImage:checkImage]
                    autorelease];
  self.doneImage.center = CGPointMake(self.bounds.size.width * 0.87f,
				      self.bounds.size.height * 0.75);
  self.doneImage.frame = CGRectInt(self.doneImage.frame);
  self.doneImage.hidden = YES;
  [self.contentView addSubview:self.doneImage];
  
  self.levelNumber = [[[SlippyLabel alloc] init] autorelease];
  self.levelNumber.fontSize = (int)(dotImage.size.height * 0.55f);
  self.levelNumber.text = [NSString stringWithFormat:@"%d", self.level.order];
  self.levelNumber.textAlignment = UITextAlignmentCenter;
  self.levelNumber.bounds = CGRectMake(0, 0,
				       dotImage.size.width,
				       dotImage.size.height);
  self.levelNumber.center = CGPointMake(self.bounds.size.width * 0.85f,
					self.bounds.size.height * 0.79f);
  self.levelNumber.frame = CGRectInt(self.levelNumber.frame);
  self.levelNumber.gradientColors = [NSArray arrayWithObjects:
				     [UIColor colorWithWhite:0.1f alpha:1.0f],
				     [UIColor colorWithWhite:0.1f alpha:1.0f],
				     [UIColor colorWithWhite:0.3f alpha:1.0f],
				     nil];
  self.levelNumber.gradientLocations = [NSArray arrayWithObjects:
					[NSNumber numberWithFloat:0.0f],
					[NSNumber numberWithFloat:0.5f],
					[NSNumber numberWithFloat:1.0f],
					nil];
  self.levelNumber.textColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
  self.levelNumber.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
  self.levelNumber.shadowOffset = CGSizeMake(0.5f, 1.0f);
  
  self.levelNumber.hidden = YES;
  [self.contentView addSubview:self.levelNumber];
  
  [self update];
  
  [self.level addObserver:self forKeyPath:@"completed" options:0 context:NULL];
  [self.level addObserver:self forKeyPath:@"locked" options:0 context:NULL];
  
  return self;
}

- (void)dealloc {
  [self.level removeObserver:self forKeyPath:@"completed"];
  [self.level removeObserver:self forKeyPath:@"locked"];
  
  [self.dotGreyImage removeFromSuperview];
  self.dotGreyImage = nil;
  [self.doneImage removeFromSuperview];
  self.doneImage = nil;
  [self.levelNumber removeFromSuperview];
  self.levelNumber = nil;
  [self.preview removeFromSuperview];
  self.preview = nil;
  
  [super dealloc];
}

@end
