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

#import "PlayListViewController.h"
#import "OriginalLevelViewCell.h"
#import "CommunityLevelViewCell.h"
#import "CommunityDownloadViewCell.h"
#import "PlayGameViewController.h"
#import "LevelDatabase.h"
#import "SlippyLabel.h"
#import "SlippyHTTP.h"
#import "BlockingUIView.h"

enum {
  OriginalTag,
  CommunityTag,
  CompletedTag
};

static NSString *const PlayListOriginalSelection = @"Original";
static NSString *const PlayListCommunitySelection = @"Community";
static NSString *const PlayListCompletedSelection = @"Completed";


@interface PlayListViewController ()

@property(nonatomic, retain) UIButton *originalButton;
@property(nonatomic, retain) UIButton *communityButton;
@property(nonatomic, retain) UIButton *completedButton;
@property(nonatomic, copy) NSString *selection;
@property(nonatomic, assign) BOOL isObserving;
@property(nonatomic, retain) NSTimer *changeTimer;
@property(nonatomic, retain) SlippyLabel *noLevelsCompletedLabel;
@property(nonatomic, assign) BOOL communityLevelWasCompleted;
@property(nonatomic, retain) BlockingUIView *infoView;
@property(nonatomic, retain) SlippyLabel *infoViewName;
@property(nonatomic, retain) SlippyLabel *infoViewAuthor;
@property(nonatomic, retain) SlippyLabel *infoViewEmail;
@property(nonatomic, retain) SlippyLabel *infoViewRatingText;
@property(nonatomic, retain) RatingSlider *infoViewRating;
@property(nonatomic, retain) RatingSlider *infoViewUserRating;
@property(nonatomic, retain) BlockingUIView *infoEventBlockerView;
@property(nonatomic, assign) CGRect originalCellFrame;
@property(nonatomic, assign) CGRect communityCellFrame;

@end


@implementation PlayListViewController

@synthesize originalButton;
@synthesize communityButton;
@synthesize completedButton;
@synthesize selection;
@synthesize isObserving;
@synthesize changeTimer;
@synthesize noLevelsCompletedLabel;
@synthesize communityLevelWasCompleted;
@synthesize infoView;
@synthesize infoViewName;
@synthesize infoViewAuthor;
@synthesize infoViewEmail;
@synthesize infoViewRatingText;
@synthesize infoViewRating;
@synthesize infoViewUserRating;
@synthesize infoEventBlockerView;
@synthesize originalCellFrame;
@synthesize communityCellFrame;

+ (NSString *)name {
  return @"PlayList";
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"sourceUpdate"]) {    
    if ([self.selection isEqualToString:PlayListCommunitySelection] ||
	[self.selection isEqualToString:PlayListCompletedSelection]) {
      [self reload];
    }
  } else if ([keyPath isEqualToString:@"communityLevelCompleted"]) {
    self.communityLevelWasCompleted = YES;
  }
}

- (void)reload {
  [super reload];
  
  if ([self.selection isEqualToString:PlayListCompletedSelection] &&
      [self.cells count] == 0) {
    self.noLevelsCompletedLabel.hidden = NO;
  } else {
    self.noLevelsCompletedLabel.hidden = YES;
  }
}

- (void)changeTimerCallback:(NSTimer *)timer {
  [self.changeTimer invalidate];
  self.changeTimer = nil;
  
  self.cells = nil;  
  [self reload];
  
  CGFloat y = [[NSUserDefaults standardUserDefaults]
	       floatForKey:
	       [SlippySettingSourceScroll stringByAppendingString:self.selection]];
  if (y > self.gridView.contentSize.height - self.gridView.frame.size.height) {
    y = 0;
  }
  
  self.gridView.contentOffset = CGPointMake(0, y);
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.1f];
  self.gridView.alpha = 1.0f;
  [UIView commitAnimations];
}

- (void)startChangeSelection:(NSString *)newSelection {
  if (self.selection != nil && [self.selection isEqualToString:newSelection]) {
    return;
  }
  
  if (self.changeTimer != nil) {
    return;
  }
  
  [[NSUserDefaults standardUserDefaults] setObject:newSelection
                                            forKey:SlippySettingLevelSelection];
  if (self.selection != nil) {
    [[NSUserDefaults standardUserDefaults]
     setFloat:self.gridView.contentOffset.y
     forKey:[SlippySettingSourceScroll stringByAppendingString:self.selection]];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  self.selection = newSelection;
  
  UIColor *selecedColor = [UIColor colorWithWhite:1.0 alpha:0.6];
  if ([self.selection isEqualToString:PlayListOriginalSelection]) {
    self.originalButton.backgroundColor = selecedColor;
    self.communityButton.backgroundColor = nil;
    self.completedButton.backgroundColor = nil;
  }
  
  if ([self.selection isEqualToString:PlayListCommunitySelection]) {
    self.originalButton.backgroundColor = nil;
    self.communityButton.backgroundColor = selecedColor;
    self.completedButton.backgroundColor = nil;
  }
  
  if ([self.selection isEqualToString:PlayListCompletedSelection]) {
    self.originalButton.backgroundColor = nil;
    self.communityButton.backgroundColor = nil;
    self.completedButton.backgroundColor = selecedColor;
  }
  
  if (self.selection == nil) {
    [self reload];
  } else {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1f];
    self.gridView.alpha = 0.0f;
    [UIView commitAnimations];
    
    self.changeTimer = [NSTimer
                        scheduledTimerWithTimeInterval:0.1f
                        target:self
                        selector:@selector(changeTimerCallback:)
                        userInfo:nil
                        repeats:NO];
  }
}

- (void)clickSource:(id)sender {
  UIButton *button = sender;
  if (button.tag == OriginalTag) {
    [self startChangeSelection:PlayListOriginalSelection];
  } else if (button.tag == CommunityTag) {
    [self startChangeSelection:PlayListCommunitySelection];
  } else if (button.tag == CompletedTag) {
    [self startChangeSelection:PlayListCompletedSelection];
  }
}

- (void)infoViewShown:(BOOL)shown {
  float opacityTo;
  
  if (shown) {
    CABasicAnimation *anim;
    NSMutableArray *anims;
    anims = [NSMutableArray array];
    
    anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.toValue = [NSNumber numberWithFloat:1.1f];
    anim.duration = 0.15f;
    anim.timingFunction = [CAMediaTimingFunction
			   functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [anims addObject:anim];
    
    anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.fromValue = [NSNumber numberWithFloat:1.1f];
    anim.toValue = [NSNumber numberWithFloat:0.9f];
    anim.beginTime = 0.15f;
    anim.duration = 0.15f;
    anim.timingFunction = [CAMediaTimingFunction
			   functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [anims addObject:anim];
    
    anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.fromValue = [NSNumber numberWithFloat:0.9f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.beginTime = 0.3f;
    anim.duration = 0.15f;
    anim.timingFunction = [CAMediaTimingFunction
			   functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [anims addObject:anim];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.45f;
    group.animations = anims;
    [self.infoView.layer addAnimation:group forKey:nil];
    
    self.infoEventBlockerView.userInteractionEnabled = YES;
    self.infoView.hidden = NO;
    opacityTo = 0.3f;
  } else {
    self.infoEventBlockerView.userInteractionEnabled = NO;
    self.infoView.hidden = YES;
    opacityTo = 0.0f;
  }
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.25f];
  self.infoEventBlockerView.backgroundColor = [UIColor colorWithWhite:0
                                                                alpha:opacityTo];
  [UIView commitAnimations];
}

- (void)touchBlockingView:(id)sender {
  [self infoViewShown:NO];
}

- (void)longPressRecognizer:(UIGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateBegan) {
    return;
  }
  
  NSUInteger index = [self.gridView
		      indexForItemAtPoint:[recognizer locationInView:self.gridView]];
  
  
  if ([self.selection isEqualToString:PlayListCompletedSelection] ||
      ([self.selection isEqualToString:PlayListCommunitySelection] &&
       index != [self.cells count] - 1)) {
	SlippyLevel *level = [self.cells objectAtIndex:index];
	
	self.infoViewName.text = level.name;
	self.infoViewAuthor.text = level.author;
	self.infoViewEmail.text = level.email;
	self.infoViewRatingText.text = [NSString stringWithFormat:@"%.1f with %d rating%@",
					level.rating,
					level.ratings,
					level.ratings > 1 ? @"s" : @""];
	self.infoViewRating.value = level.rating;
	self.infoViewUserRating.value = level.userRating;
	
	[self infoViewShown:YES];    
      }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (_DeviceModel == MiscDeviceModelIPad) {
    self.originalCellFrame = CGRectMake(0, 0, 320, 200);
    self.communityCellFrame = CGRectMake(0, 0, 320, 260);
  } else {
    self.originalCellFrame = CGRectMake(0, 0, 320 / 2, 200 / 2);
    self.communityCellFrame = CGRectMake(0, 0, 320 / 2, 260 / 2);
  }
  
  // UILongPressGestureRecognizer exist only in 3.2 (is private previously)
  Class cls = NSClassFromString(@"UILongPressGestureRecognizer");
  if (cls != nil &&
      _IOSVersion >= __IPHONE_3_2) {
    UILongPressGestureRecognizer *longPress;
    longPress = [[[cls alloc]
		  initWithTarget:self
		  action:@selector(longPressRecognizer:)]
		 autorelease];
    longPress.minimumPressDuration = 1.0f;
    [self.gridView addGestureRecognizer:longPress];
  }
  
  self.infoEventBlockerView = [[[BlockingUIView alloc] init] autorelease];
  self.infoEventBlockerView.touchTarget = self;
  self.infoEventBlockerView.touchSelector = @selector(touchBlockingView:);
  self.infoEventBlockerView.userInteractionEnabled = NO;
  self.infoEventBlockerView.frame = self.view.frame;
  self.infoEventBlockerView.backgroundColor = [UIColor colorWithWhite:0.0f
                                                                alpha:0.0f];
  [self.view addSubview:self.infoEventBlockerView];
  
  self.infoView = [[[BlockingUIView alloc] init] autorelease];
  self.infoView.touchTarget = self;
  self.infoView.touchSelector = @selector(touchBlockingView:);
  self.infoView.userInteractionEnabled = NO;
  self.infoView.bounds = CGRectMake(0, 0,
				    self.view.bounds.size.width * 0.5f,
				    self.view.bounds.size.height * 0.5f);
  self.infoView.center = CGPointMake(self.view.bounds.size.width / 2,
				     self.view.bounds.size.height / 2);
  self.infoView.frame = CGRectInt(self.infoView.frame);
  self.infoView.backgroundColor = [UIColor colorWithWhite:0.0f
                                                    alpha:0.5f];
  self.infoView.layer.cornerRadius = 10.0f;
  self.infoView.hidden = YES;
  [self.infoEventBlockerView addSubview:self.infoView];
  
  CGFloat infoViewNameFontSize = (int)(self.view.frame.size.height / 20.f);
  CGFloat infoViewNameMinFontSize = (int)(self.view.frame.size.height / 40.f);
  CGFloat infoViewAuthorFontSize = (int)(self.view.frame.size.height / 35.f);
  CGFloat infoViewEmailFontSize = (int)(self.view.frame.size.height / 35.f);
  CGFloat infoViewRatingTextFontSize = (int)(self.view.frame.size.height / 30.f);
  
  self.infoViewName = [[[SlippyLabel alloc] init] autorelease];
  self.infoViewName.fontSize = infoViewNameFontSize;
  self.infoViewName.minimumFontSize = infoViewNameMinFontSize;
  self.infoViewName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.infoViewName.textAlignment = UITextAlignmentCenter;
  self.infoViewName.center = CGPointMake(self.infoView.bounds.size.width / 2,
					 self.infoView.bounds.size.height * 0.1f);
  self.infoViewName.bounds = CGRectMake(0, 0,
					self.infoView.bounds.size.width,
					infoViewNameFontSize  + 5);
  self.infoViewName.frame = CGRectInt(self.infoViewName.frame);
  [self.infoView addSubview:self.infoViewName];
  
  self.infoViewAuthor = [[[SlippyLabel alloc] init] autorelease];
  self.infoViewAuthor.fontSize = infoViewAuthorFontSize;
  self.infoViewAuthor.textAlignment = UITextAlignmentCenter;
  self.infoViewAuthor.center = CGPointMake(self.infoView.bounds.size.width / 2,
					   self.infoView.bounds.size.height * 0.2f);
  self.infoViewAuthor.bounds = CGRectMake(0, 0,
					  self.infoView.bounds.size.width,
					  infoViewAuthorFontSize  + 5);
  self.infoViewAuthor.frame = CGRectInt(self.infoViewAuthor.frame);
  [self.infoView addSubview:self.infoViewAuthor];
  
  self.infoViewEmail = [[[SlippyLabel alloc] init] autorelease];
  self.infoViewEmail.fontSize = infoViewEmailFontSize;
  self.infoViewEmail.textAlignment = UITextAlignmentCenter;
  self.infoViewEmail.center = CGPointMake(self.infoView.bounds.size.width / 2,
					  self.infoView.bounds.size.height * 0.26f);
  self.infoViewEmail.bounds = CGRectMake(0, 0,
					 self.infoView.bounds.size.width,
					 infoViewEmailFontSize  + 5);
  self.infoViewEmail.frame = CGRectInt(self.infoViewEmail.frame);
  [self.infoView addSubview:self.infoViewEmail];
  
  UIImage *starsBorderEmptyImage = I.images.bigStarsBorderEmpty;
  self.infoViewUserRating = [[[RatingSlider alloc] init] autorelease];
  self.infoViewUserRating.center = CGPointMake(self.infoView.bounds.size.width / 2,
					       self.infoView.bounds.size.height * 0.5f);
  self.infoViewUserRating.bounds = CGRectMake(0, 0,
					      starsBorderEmptyImage.size.width * 5,
					      starsBorderEmptyImage.size.height);
  self.infoViewUserRating.frame = CGRectInt(self.infoViewUserRating.frame);
  self.infoViewUserRating.emptyImage = starsBorderEmptyImage;
  self.infoViewUserRating.halfImage = I.images.bigStarsBorderHalf;
  self.infoViewUserRating.fullImage = I.images.bigStarsBorderFull;
  self.infoViewUserRating.min = 0.0;
  self.infoViewUserRating.max = 5.0;
  self.infoViewUserRating.stars = 5;
  self.infoViewUserRating.integerValue = NO;
  self.infoViewUserRating.enabled = NO;
  [self.infoView addSubview:self.infoViewUserRating];
  
  UIImage *starsEmptyImage = I.images.bigStarsEmpty;
  self.infoViewRating = [[[RatingSlider alloc] init] autorelease];
  self.infoViewRating.center = CGPointMake(self.infoView.bounds.size.width / 2,
					   self.infoView.bounds.size.height * 0.5f);
  self.infoViewRating.bounds = CGRectMake(0, 0,
					  starsEmptyImage.size.width * 5,
					  starsEmptyImage.size.height);
  self.infoViewRating.frame = CGRectInt(self.infoViewRating.frame);
  self.infoViewRating.emptyImage = starsEmptyImage;
  self.infoViewRating.halfImage = I.images.bigStarsHalf;
  self.infoViewRating.fullImage = I.images.bigStarsFull;
  self.infoViewRating.min = 0.0;
  self.infoViewRating.max = 5.0;
  self.infoViewRating.stars = 5;
  self.infoViewRating.integerValue = NO;
  self.infoViewRating.enabled = NO;
  [self.infoView addSubview:self.infoViewRating];
  
  self.infoViewRatingText = [[[SlippyLabel alloc] init] autorelease];
  self.infoViewRatingText.fontSize = infoViewRatingTextFontSize;
  self.infoViewRatingText.textAlignment = UITextAlignmentCenter;
  self.infoViewRatingText.center = CGPointMake(self.infoView.bounds.size.width / 2,
					       self.infoView.bounds.size.height * 0.8f);
  self.infoViewRatingText.bounds = CGRectMake(0, 0,
					      self.infoView.bounds.size.width,
					      infoViewRatingTextFontSize + 5);
  self.infoViewRatingText.frame = CGRectInt(self.infoViewRatingText.frame);
  [self.infoView addSubview:self.infoViewRatingText];
  
  
  UIImage *originalImage = I.images.original;
  UIImage *communityImage = I.images.community;
  UIImage *completedImage = I.images.completed;
  
  self.originalButton = [[[UIButton alloc] init] autorelease];
  self.originalButton.tag = OriginalTag;
  [originalButton addTarget:self
		       action:@selector(clickSource:)
	     forControlEvents:UIControlEventTouchUpInside];
  [self.originalButton setImage:originalImage
			 forState:UIControlStateNormal];
  self.originalButton.center = CGPointMake(0, 0);
  self.originalButton.frame = CGRectMake(self.view.frame.size.width - 
					   communityImage.size.width -
					   5 -
					   originalImage.size.width -
					   5 -
					   completedImage.size.width -
					   5
					   ,
					   0,
					   originalImage.size.width,
					   originalImage.size.height);
  self.originalButton.showsTouchWhenHighlighted = YES;
  self.originalButton.layer.cornerRadius = 5;
  [self.view addSubview:self.originalButton];
  
  self.communityButton = [[[UIButton alloc] init] autorelease];
  self.communityButton.tag = CommunityTag;
  [self.communityButton addTarget:self
			     action:@selector(clickSource:)
		   forControlEvents:UIControlEventTouchUpInside];
  [self.communityButton setImage:communityImage
			  forState:UIControlStateNormal];
  self.communityButton.center = CGPointMake(0, 0);
  self.communityButton.frame = CGRectMake(self.view.frame.size.width - 
					    communityImage.size.width -
					    5 -
					    completedImage.size.width -
					    5,
					    0,
					    communityImage.size.width,
					    communityImage.size.height);
  self.communityButton.showsTouchWhenHighlighted = YES;
  self.communityButton.layer.cornerRadius = 5;
  [self.view addSubview:self.communityButton];
  
  self.completedButton = [[[UIButton alloc] init] autorelease];
  self.completedButton.tag = CompletedTag;
  [self.completedButton addTarget:self
			     action:@selector(clickSource:)
		   forControlEvents:UIControlEventTouchUpInside];
  [self.completedButton setImage:completedImage
			  forState:UIControlStateNormal];
  self.completedButton.center = CGPointMake(0, 0);
  self.completedButton.frame = CGRectMake(self.view.frame.size.width - 
					    completedImage.size.width -
					    5,
					    0,
					    completedImage.size.width,
					    completedImage.size.height);
  self.completedButton.showsTouchWhenHighlighted = YES;
  self.completedButton.layer.cornerRadius = 5;
  [self.view addSubview:self.completedButton];
  
  CGFloat noLevelsCompletedFontSize = (int)(self.view.frame.size.height / 20.f);
  self.noLevelsCompletedLabel = [[[SlippyLabel alloc] init] autorelease];
  self.noLevelsCompletedLabel.center = CGPointMake(self.view.frame.size.width / 2,
						   self.view.frame.size.height / 2);
  self.noLevelsCompletedLabel.bounds = CGRectMake(0, 0,
						  self.view.frame.size.width,
						  noLevelsCompletedFontSize + 10);
  self.noLevelsCompletedLabel.frame = CGRectInt(self.noLevelsCompletedLabel.frame);
  self.noLevelsCompletedLabel.fontSize = noLevelsCompletedFontSize;
  self.noLevelsCompletedLabel.text = @"No community levels completed yet";
  self.noLevelsCompletedLabel.textAlignment = UITextAlignmentCenter;
  self.noLevelsCompletedLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.noLevelsCompletedLabel.hidden = YES;
  [self.view addSubview:self.noLevelsCompletedLabel];
  
  [[LevelDatabase shared] addObserver:self
                           forKeyPath:@"sourceUpdate"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
  [[LevelDatabase shared] addObserver:self
                           forKeyPath:@"communityLevelCompleted"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
  self.isObserving = YES;
  
  NSString *savedSelection = [[NSUserDefaults standardUserDefaults]
			      objectForKey:SlippySettingLevelSelection];
  if (![[NSSet setWithObjects:
	 PlayListOriginalSelection,
	 PlayListCommunitySelection,
	 PlayListCompletedSelection,
	 nil] containsObject:savedSelection]) {
    savedSelection = PlayListOriginalSelection;
  }  
  [self startChangeSelection:savedSelection];
  
  [self.view bringSubviewToFront:self.infoEventBlockerView];
}

- (void)unloadView {
  if (self.isObserving) {
    [[LevelDatabase shared] removeObserver:self
                                forKeyPath:@"sourceUpdate"];
    [[LevelDatabase shared] removeObserver:self
                                forKeyPath:@"communityLevelCompleted"];
    self.isObserving = NO;
  }
  
  [self.noLevelsCompletedLabel removeFromSuperview];
  self.noLevelsCompletedLabel = nil;
  [self.originalButton removeFromSuperview];
  self.originalButton = nil;
  [self.communityButton removeFromSuperview];
  self.communityButton = nil;
  [self.communityButton removeFromSuperview];
  self.completedButton = nil;
  
  [self.infoView removeFromSuperview];
  self.infoView = nil;
  [self.infoViewName removeFromSuperview];
  self.infoViewName = nil;
  [self.infoViewAuthor removeFromSuperview];
  self.infoViewAuthor = nil;
  [self.infoViewEmail removeFromSuperview];
  self.infoViewEmail = nil;
  [self.infoViewRating removeFromSuperview];
  self.infoViewRating = nil;
  [self.infoViewUserRating removeFromSuperview];
  self.infoViewUserRating = nil;
  [self.infoViewRatingText removeFromSuperview];
  self.infoViewRatingText = nil;
  
  if (self.changeTimer != nil) {
    [self.changeTimer invalidate];
    self.changeTimer = nil;
  }
  self.selection = nil;
  
  [super unloadView];
}

- (void)viewWillAppear:(BOOL)animated {
  if (!self.communityLevelWasCompleted) {
    return;
  }
  self.communityLevelWasCompleted = NO;
  
  [self reload];
  
  CABasicAnimation *anim;
  CAAnimationGroup *group = [CAAnimationGroup animation];
  NSMutableArray *anims = [NSMutableArray array];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:self.completedButton.layer.position];
  anim.toValue = [NSValue valueWithCGPoint:
		  CGPointDelta(self.completedButton.layer.position, CGPointMake(0, 4))];
  anim.duration = 0.5f;
  anim.removedOnCompletion = YES;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:
		    CGPointDelta(self.completedButton.layer.position, CGPointMake(0, 4))];
  anim.toValue = [NSValue valueWithCGPoint:
		  CGPointDelta(self.completedButton.layer.position, CGPointMake(0, -4))];
  anim.duration = 0.75f;
  anim.beginTime = 0.5f;
  anim.removedOnCompletion = YES;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:
		    CGPointDelta(self.completedButton.layer.position, CGPointMake(0, -4))];
  anim.toValue = [NSValue valueWithCGPoint:
		  CGPointDelta(self.completedButton.layer.position, CGPointMake(0, 2))];
  anim.duration = 0.75f;
  anim.beginTime = 1.25f;
  anim.removedOnCompletion = YES;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:
		    CGPointDelta(self.completedButton.layer.position, CGPointMake(0, 2))];
  anim.toValue = [NSValue valueWithCGPoint:self.completedButton.layer.position];
  anim.duration = 0.5f;
  anim.beginTime = 2.0f;
  anim.removedOnCompletion = YES;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  group.duration = 2.5f;
  group.animations = anims;
  
  [self.completedButton.layer addAnimation:group forKey:nil];
  
}

- (void)viewWillDisappear:(BOOL)animated {
  if (self.selection != nil) {
    [[NSUserDefaults standardUserDefaults]
     setFloat:self.gridView.contentOffset.y
     forKey:[SlippySettingSourceScroll stringByAppendingString:self.selection]];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidUnload {
  [self unloadView];
  [super viewDidUnload];
}

- (void)dealloc {
  [self unloadView];
  [super dealloc];
}

- (NSArray *)loadCells {
  NSMutableArray *cells;
  
  if ([self.selection isEqualToString:PlayListOriginalSelection]) {
    cells = [NSMutableArray arrayWithArray:
	     [[LevelDatabase shared]
	      levelsFromSource:LevelDatabaseSourceOriginalName
	      sortDescriptors:
	      [NSArray arrayWithObjects:
	       [[[NSSortDescriptor alloc]
		 initWithKey:@"order"
		 ascending:YES]
		autorelease],
	       nil
	       ]]];
  } else {
    cells = [NSMutableArray arrayWithArray:
	     [[LevelDatabase shared]
	      levelsFromSource:LevelDatabaseSourceCommunityName
	      sortDescriptors:
	      [NSArray arrayWithObjects:
	       [[[NSSortDescriptor alloc]
		 initWithKey:@"rating"
		 ascending:NO]
		autorelease],
	       [[[NSSortDescriptor alloc]
		 initWithKey:@"added"
		 ascending:YES]
		autorelease],
	       [[[NSSortDescriptor alloc]
		 initWithKey:@"id_"
		 ascending:NO]
		autorelease],
	       nil
	       ]]];
    
    BOOL completed = NO;
    if ([self.selection isEqualToString:PlayListCompletedSelection]) {
      completed = YES;
    }
    
    NSMutableArray *remove = [NSMutableArray array];
    for (SlippyLevel *level in cells) {      
      if (level.completed == completed) {
	continue;
      }
      
      [remove addObject:level];
    }
    
    [cells removeObjectsInArray:remove];
    
    if ([self.selection isEqualToString:PlayListCommunitySelection]) {
      [cells addObject:@"_download"];
    }
  }
  
  return cells;
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView
          cellForItemAtIndex:(NSUInteger)index {
  AQGridViewCell *cell;
  
  if ([self.selection isEqualToString:PlayListCommunitySelection] ||
      [self.selection isEqualToString:PlayListCompletedSelection]) {
    if ([self.selection isEqualToString:PlayListCommunitySelection] &&
	index == [self.cells count] - 1) {
      cell = [aGridView dequeueReusableCellWithIdentifier:@"_download"];
      if (cell != nil) {
        return cell;
      }
      
      return [[[CommunityDownloadViewCell alloc]
               initWithFrame:self.communityCellFrame
               reuseIdentifier:@"_download"]
              autorelease];
    }
    
    SlippyLevel *level = [self.cells objectAtIndex:index];
    
    cell = [aGridView dequeueReusableCellWithIdentifier:level.id_];
    if (cell != nil) {
      return cell;
    }
    
    return [[[CommunityLevelViewCell alloc]
             initWithFrame:self.communityCellFrame
             level:level
             reuseIdentifier:level.id_]
            autorelease];
  } else {    
    SlippyLevel *level = [self.cells objectAtIndex:index];
    
    cell = [aGridView dequeueReusableCellWithIdentifier:level.id_];
    if (cell != nil) {
      return cell;
    }
    
    return [[[OriginalLevelViewCell alloc]
             initWithFrame:self.originalCellFrame
             level:level
             reuseIdentifier:level.id_]
            autorelease];
  }
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
  if ([self.selection isEqualToString:PlayListCommunitySelection] ||
      [self.selection isEqualToString:PlayListCompletedSelection]) {
    return self.communityCellFrame.size;
  } else {
    return self.originalCellFrame.size;
  }
}

- (void)gridView:(AQGridView *)aGridView didSelectItemAtIndex:(NSUInteger)index {
  [aGridView deselectItemAtIndex:index animated:YES];
  
  if ([self.selection isEqualToString:PlayListCommunitySelection] ||
      [self.selection isEqualToString:PlayListCompletedSelection]) {
    
    if ([self.selection isEqualToString:PlayListCommunitySelection] &&
	index == [self.cells count] - 1) {
      [SlippyHTTP downloadLevels];
    } else {
      [self.navigationController
       pushViewController:[[[PlayGameViewController alloc]
                            initWithLevel:[self.cells objectAtIndex:index]]
                           autorelease]
       animated:YES];
      
    }
  } else {
    SlippyLevel *level = [self.cells objectAtIndex:index];
    
    if (!_isTester() && level.locked) {
      return;
    }
    
    [self.navigationController
     pushViewController:[[[PlayGameViewController alloc] initWithLevel:level]
                         autorelease]
     animated:YES];
  }
  
}

@end
