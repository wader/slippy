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

#import "CommunityLevelViewCell.h"
#import "LevelPreviewView.h"
#import "UIImage+extra.h"

@interface CommunityLevelViewCell ()

@property(nonatomic, retain) SlippyLevel *level;
@property(nonatomic, retain) SlippyLabel *nameLabel;
@property(nonatomic, retain) SlippyLabel *authorLabel;
@property(nonatomic, retain) UIImageView *newImage;
@property(nonatomic, retain) RatingSlider *rating;
@property(nonatomic, retain) RatingSlider *userRating;
@property(nonatomic, retain) LevelPreviewView *preview;

@end


@implementation CommunityLevelViewCell

@synthesize level;
@synthesize nameLabel;
@synthesize authorLabel;
@synthesize newImage;
@synthesize rating;
@synthesize userRating;
@synthesize preview;

- (void)update {  
  self.nameLabel.text = self.level.name;
  self.authorLabel.text = self.level.author;
  
  self.rating.value = self.level.rating;
  
  self.userRating.hidden = !self.level.completed;
  self.userRating.value = self.level.userRating;
  
  NSTimeInterval age = [self.level.firstDownloaded timeIntervalSinceNow];
  NSTimeInterval maxage = -(60*60*24*2);
  
  if (self.level.new_ && age > maxage) {
    self.newImage.hidden = NO;
  } else {
    self.newImage.hidden = YES;
  }
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
  
  CGFloat nameFontSize = (int)(self.contentView.bounds.size.height / 11.0f);
  CGFloat nameFontSizeMin = (int)(self.contentView.bounds.size.height / 14.0f);
  CGFloat authorFontSize = (int)(self.contentView.bounds.size.height / 16.0f);
  CGFloat authorFontSizeMin = (int)(self.contentView.bounds.size.height / 22.0f);
  CGFloat padding = (int)(self.contentView.bounds.size.height / 80.0f);
  
  self.nameLabel = [[[SlippyLabel alloc] init] autorelease];
  self.nameLabel.fontSize = nameFontSize;
  self.nameLabel.minimumFontSize = nameFontSizeMin;
  self.nameLabel.text = self.level.name;
  self.nameLabel.textAlignment = UITextAlignmentCenter;
  self.nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.nameLabel.frame = CGRectMake(self.border.frame.origin.x + padding,
				    self.border.frame.origin.y + padding,
				    self.border.frame.size.width - padding * 2,
				    nameFontSize + 3);
  self.nameLabel.adjustsFontSizeToFitWidth = YES;
  [self.contentView addSubview:self.nameLabel];
  
  self.authorLabel = [[[SlippyLabel alloc] init] autorelease];
  self.authorLabel.fontSize = authorFontSize;
  self.nameLabel.minimumFontSize = authorFontSizeMin;
  self.authorLabel.text = self.level.name;
  self.authorLabel.textAlignment = UITextAlignmentCenter;
  self.authorLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.authorLabel.frame = CGRectMake(self.border.frame.origin.x + padding,
				      self.border.frame.origin.y + padding +
				      authorFontSize + padding * 2,
				      self.border.frame.size.width - padding * 2,
				      authorFontSize + 3);
  [self.contentView addSubview:self.authorLabel];
  
  self.preview = [[[LevelPreviewView alloc]
                   initWithFrame:CGRectMake(0, 0,
                                            SLIPPY_LEVEL_WIDTH * 8,
                                            SLIPPY_LEVEL_HEIGHT * 8)
                   level:level]
                  autorelease];
  self.preview.center = CGPointMake(self.contentView.bounds.size.width / 2,
				    self.contentView.bounds.size.height * 0.5f);
  self.preview.frame = CGRectInt(self.preview.frame);
  self.preview.userInteractionEnabled = NO;
  [self.contentView addSubview:self.preview];
  
  self.newImage = [[[UIImageView alloc]
                    initWithImage:I.images.new_]
                   autorelease];
  self.newImage.frame = CGRectMake(self.border.frame.origin.x +
				   self.border.frame.size.width -
				   self.newImage.image.size.width,
				   self.border.frame.origin.y,
				   self.newImage.image.size.width,
				   self.newImage.image.size.height);
  self.newImage.hidden = YES;
  [self.contentView addSubview:self.newImage];
  [self.contentView sendSubviewToBack:self.newImage];
  
  UIImage *emptyImage = I.images.starsBorderEmpty;
  self.userRating = [[[RatingSlider alloc] init] autorelease];
  self.userRating.bounds = CGRectMake(0, 0,
				      emptyImage.size.width * 5,
				      emptyImage.size.height);
  self.userRating.center = CGPointMake(self.contentView.frame.size.width / 2,
				       self.contentView.frame.size.height * 0.86f);
  self.userRating.frame = CGRectInt(self.userRating.frame);
  self.userRating.emptyImage = emptyImage;
  self.userRating.halfImage = I.images.starsBorderHalf;
  self.userRating.fullImage = I.images.starsBorderFull;
  self.userRating.min = 0.0;
  self.userRating.max = 5.0;
  self.userRating.stars = 5;
  self.userRating.enabled = NO;
  [self.contentView addSubview:self.userRating];
  
  self.rating = [[[RatingSlider alloc] init] autorelease];
  self.rating.frame = self.userRating.frame;
  self.rating.emptyImage = I.images.starsEmpty;
  self.rating.halfImage = I.images.starsHalf;
  self.rating.fullImage = I.images.starsFull;
  self.rating.min = 0.0;
  self.rating.max = 5.0;
  self.rating.stars = 5;
  self.rating.enabled = NO;
  [self.contentView addSubview:self.rating];
  
  [self update];
  
  [self.level addObserver:self forKeyPath:@"completed" options:0 context:NULL];
  [self.level addObserver:self forKeyPath:@"rating" options:0 context:NULL];
  [self.level addObserver:self forKeyPath:@"userRating" options:0 context:NULL];
  [self.level addObserver:self forKeyPath:@"name" options:0 context:NULL];
  [self.level addObserver:self forKeyPath:@"author" options:0 context:NULL];
  [self.level addObserver:self forKeyPath:@"new_" options:0 context:NULL];
  
  return self;
}

- (void)dealloc {
  [self.level removeObserver:self forKeyPath:@"completed"];
  [self.level removeObserver:self forKeyPath:@"rating"];
  [self.level removeObserver:self forKeyPath:@"userRating"];
  [self.level removeObserver:self forKeyPath:@"name"];
  [self.level removeObserver:self forKeyPath:@"author"];
  [self.level removeObserver:self forKeyPath:@"new_"];
  
  [self.rating removeFromSuperview];
  self.rating = nil;
  [self.userRating removeFromSuperview];
  self.userRating = nil;
  [self.nameLabel removeFromSuperview];
  self.nameLabel = nil;
  [self.authorLabel removeFromSuperview];
  self.authorLabel = nil;
  [self.newImage removeFromSuperview];
  self.newImage = nil;
  [self.preview removeFromSuperview];
  self.preview = nil;
  
  [super dealloc];
}

@end

