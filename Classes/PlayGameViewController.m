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

#import "PlayGameViewController.h"
#import "LevelDatabase.h"
#import "SlippyHTTP.h"
#import "SlippyAudio.h"
#import "LevelFixedView.h"

@interface PlayGameViewController () 

@property(nonatomic, retain) SlippyLevel *nextLevel;
@property(nonatomic, retain) NSTimer *restartTimer;
@property(nonatomic, retain) NSTimer *nextLevelTimer;
@property(nonatomic, retain) UIButton *backwardButton;
@property(nonatomic, retain) UIButton *forwardButton;
@property(nonatomic, retain) SlippyLabel *topLabel;
@property(nonatomic, retain) UIView *completedView;
@property(nonatomic, retain) SlippyLabel *completedLabel;
@property(nonatomic, retain) RatingSlider *completedRating;
@property(nonatomic, retain) SlippyLabel *completedRatingCommentLabel;
@property(nonatomic, assign) BOOL completedRatingWasTouched;

@end


@implementation PlayGameViewController

@synthesize startLevel;
@synthesize nextLevel;
@synthesize gameView;
@synthesize restartTimer;
@synthesize nextLevelTimer;
@synthesize backwardButton;
@synthesize restartButton;
@synthesize forwardButton;
@synthesize topLabel;
@synthesize completedView;
@synthesize completedLabel;
@synthesize completedRating;
@synthesize completedRatingCommentLabel;
@synthesize completedRatingWasTouched;

+ (NSString *)name {
  return @"PlayGame";
}

- (BOOL)shouldShowRating {
  if (![self.startLevel.source
        isEqualToString:LevelDatabaseSourceCommunityName]) {
    return NO;
  }
  
  if ([self.startLevel.authorHash isEqualToString:slippyUDIDHash()]) {
    return NO;
  }
  
  // already compeleted and rated (probably)
  if (self.startLevel.completed) {
    return NO;
  }
  
  return YES;
}

- (void)uploadStatistics {
  [[LevelDatabase shared] rateLevel:self.startLevel
			     rating:self.completedRating.value];
  [SlippyHTTP uploadStatistics:self.startLevel
                        rating:self.completedRating.value
                     solvetime:self.gameView.statsSolveTime
                        pushes:self.gameView.statsPushes
                         moves:self.gameView.statsMoves];
}

- (IBAction)clickBack:(id)sender {
  // stop timers etc
  [self.gameView stop];
  
  if (self.nextLevelTimer != nil) {
    [self.nextLevelTimer invalidate];
    self.nextLevelTimer = nil;
  }
  
  if (self.completedRatingWasTouched) {
    [self uploadStatistics];
  }
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoNextLevel {
  // stop timers etc
  [self.gameView stop];
  
  if (self.nextLevelTimer != nil) {
    [self.nextLevelTimer invalidate];
    self.nextLevelTimer = nil;
  }
  
  [SlippyAudio playNextLevelEffect];
  
  UINavigationController *nc = self.navigationController;
  
  [[self retain] autorelease];
  
  [nc popViewControllerAnimated:NO];
  [nc pushViewController:[[[PlayGameViewController alloc]
                           initWithLevel:self.nextLevel]
                          autorelease]
                animated:YES];
}

- (IBAction)clickForward:(id)sender {
  [self gotoNextLevel];
}

- (IBAction)touchCompletedRating:(id)sender {
  self.completedRatingWasTouched = YES;
}

- (void)nextLevelTimerMethod:(NSTimer *)timer {
  [self gotoNextLevel];
}

- (void)restartTimerMethod:(NSTimer *)timer {
  [self.gameView loadLevel:self.startLevel];
  [self.restartTimer invalidate];
  self.restartTimer = nil;
  
  self.gameView.layer.opacity = 1.0f;
  CABasicAnimation *fade;
  fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fade.fromValue = [NSNumber numberWithFloat:0.0f];
  fade.toValue = [NSNumber numberWithFloat:1.0f];
  fade.duration = 0.3f;
  fade.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.gameView.layer addAnimation:fade forKey:nil];
}

- (void)restart {
  if (self.restartTimer != nil) {
    return;
  }
  
  self.gameView.layer.opacity = 0.0f;
  CABasicAnimation *fade;
  fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fade.fromValue= [NSNumber numberWithFloat:1.0f];
  fade.toValue = [NSNumber numberWithFloat:0.0f];
  fade.duration = 0.3f;
  fade.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.gameView.layer addAnimation:fade forKey:nil];
  
  self.restartTimer = [NSTimer
                       scheduledTimerWithTimeInterval:0.3f
                       target:self
                       selector:@selector(restartTimerMethod:)
                       userInfo:nil
                       repeats:NO];
}

- (IBAction)clickRestart:(id)sender {
  [self restart];
}

- (void)levelChanged {  
  self.state = [NSDictionary dictionaryWithObjectsAndKeys:
                self.startLevel.id_,
                @"level",
                [self.gameView gameState],
                @"state",
                nil];
  self.stateChanged = YES;
}

- (void)levelCompleted {
  CGPoint from, to, wobble, wobble2;
  CABasicAnimation *anim;
  NSMutableArray *anims;
  CAAnimationGroup *group;
  
  // only if not completed and not edit mode (id nil?)
  
  if ([self shouldShowRating]) {
    CGFloat d = (int)(self.completedView.bounds.size.height * 1.2f);
    CGRect r = self.completedView.frame;
    r.size.height += d;
    r.origin.y -= d / 2;
    self.completedView.frame = r;
    self.completedView.frame = CGRectInt(self.completedView.frame);
    self.completedRating.hidden = NO;
    self.completedRatingCommentLabel.hidden = NO;
  }
  
  if ([self.startLevel.source isEqualToString:LevelDatabaseSourceOriginalName] ||
      [self.startLevel.source isEqualToString:LevelDatabaseSourceCommunityName]) {
    [[LevelDatabase shared] completeAndUnlockLevels:self.startLevel save:YES];
  } else if ([self.startLevel.source isEqualToString:LevelDatabaseSourceYourName]) {
    self.startLevel.completedAfterEdit = YES;
  }
  
  from = self.completedView.layer.position;
  to = CGPointDelta(from, CGPointMake(self.view.bounds.size.width, 0));
  wobble = CGPointDelta(to, CGPointMake(20, 0));
  wobble2 = CGPointDelta(to, CGPointMake(-10, 0));
  self.completedView.layer.position = to;
  self.completedView.hidden = NO;
  
  anims = [NSMutableArray array];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:from];
  anim.toValue = [NSValue valueWithCGPoint:wobble];
  anim.duration = 0.5f;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:wobble];
  anim.toValue = [NSValue valueWithCGPoint:wobble2];
  anim.beginTime = 0.5f;
  anim.duration = 0.5f;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:wobble2];
  anim.toValue = [NSValue valueWithCGPoint:to];
  anim.beginTime = 1.0f;
  anim.duration = 0.5f;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  group = [CAAnimationGroup animation];
  group.duration = 1.5f;
  group.animations = anims;
  [self.completedView.layer addAnimation:group forKey:nil];
  
  from = restartButton.layer.position;
  to = CGPointDelta(self.restartButton.layer.position,
                    CGPointMake(self.forwardButton.frame.size.width, 0));
  restartButton.layer.position = to;
  
  // move out
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:from];
  anim.toValue = [NSValue valueWithCGPoint:to];
  anim.duration = 0.25f;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [restartButton.layer addAnimation:anim forKey:nil];
  
  if (self.nextLevel == nil) {
    anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:self.backwardButton.layer.position];
    anim.toValue = [NSValue valueWithCGPoint:
                    CGPointDelta(self.backwardButton.layer.position,
                                 CGPointMake(20, 0))];
    anim.duration = 0.5f;
    anim.autoreverses = YES;
    anim.repeatCount = MAXFLOAT;
    anim.timingFunction = [CAMediaTimingFunction
                           functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.backwardButton.layer addAnimation:anim forKey:nil];
    
    return;
  }
  
  from = self.forwardButton.layer.position;
  to = CGPointDelta(self.forwardButton.layer.position,
                    CGPointMake(-self.forwardButton.frame.size.width, 0));
  wobble = CGPointDelta(to, CGPointMake(-15, 0));
  forwardButton.layer.position = to;
  
  anims = [NSMutableArray array];
  // move in
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:from];
  anim.toValue = [NSValue valueWithCGPoint:wobble];
  anim.duration = 0.5f;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  // then bounce
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:wobble];
  anim.toValue = [NSValue valueWithCGPoint:to];
  anim.beginTime = 0.5f;
  anim.duration = 0.5f;
  anim.autoreverses = YES;
  anim.repeatCount = MAXFLOAT;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  group = [CAAnimationGroup animation];
  group.duration = MAXFLOAT;
  group.animations = anims;
  [forwardButton.layer addAnimation:group forKey:nil];
  
  self.nextLevelTimer = [NSTimer
                         scheduledTimerWithTimeInterval:3.0f
                         target:self
                         selector:@selector(nextLevelTimerMethod:)
                         userInfo:nil
                         repeats:NO];
}

- (SlippyLevel *)nextLevel {
  if (![self.startLevel.source
        isEqualToString:LevelDatabaseSourceOriginalName]) {
    return nil;
  }
  
  for (SlippyLevel *level in [[LevelDatabase shared]
			      levelsFromSource:LevelDatabaseSourceOriginalName
			      sortDescriptors:
			      [NSArray arrayWithObject:
			       [[[NSSortDescriptor alloc]
				 initWithKey:@"order"
				 ascending:YES]
				autorelease]]]) {
				 if (!level.locked && !level.completed) {
				   return level;
				 }
			       }
  
  return nil;
}

- (id)initWithLevel:(SlippyLevel *)level {
  self = [self init];
  if (self == nil) {
    return nil;
  }
  
  self.startLevel = level;
  self.nextLevel = [self nextLevel];
  self.completedRatingWasTouched = NO;
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSDictionary *gameState = nil;
  
  if (self.state != nil) {
    NSString *slevel = [self.state objectForKey:@"level"];
    gameState = [self.state objectForKey:@"state"];
    
    if (slevel != nil && [slevel isKindOfClass:[NSString class]]) {
      self.startLevel = [[LevelDatabase shared] levelWithId:slevel];
    }
    
    if (self.startLevel == nil) {
      [self.navigationController popViewControllerAnimated:NO];
      return;
    }
  }
  
  self.gameView = [[[PlayGameTileView alloc]
                    initWithFrame:CGRectMake(0, self.barHeight,
					     self.view.bounds.size.width,
					     self.view.bounds.size.height -
					     self.barHeight)]
                   autorelease];
  self.gameView.gameDelegate = self;
  if (gameState != nil && [self.gameView validateGameState:gameState]) {
    [self.gameView loadGameState:gameState level:self.startLevel];
  } else {
    [self.gameView loadLevel:self.startLevel];
    [self levelChanged];
  }
  [self.view addSubview:self.gameView];
  
  UIImage *leftImage = I.images.left;
  UIImage *restartImage = I.images.restart;
  
  self.topLabel = [[[SlippyLabel alloc] init] autorelease];
  self.topLabel.bounds = CGRectMake(0, 0,
				    self.view.bounds.size.width -
				    leftImage.size.width -
				    restartImage.size.width,
				    self.barHeight * 0.85f);
  self.topLabel.center = CGPointMake(self.view.bounds.size.width / 2,
				     self.barHeight / 2);
  self.topLabel.frame = CGRectInt(self.topLabel.frame);
  self.topLabel.fontSize = (int)(self.barHeight * 0.7f);
  self.topLabel.minimumFontSize =  (int)(self.barHeight * 0.5f);
  self.topLabel.adjustsFontSizeToFitWidth = YES;
  self.topLabel.textAlignment = UITextAlignmentCenter;
  self.topLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  if (self.startLevel != nil) {
    self.topLabel.text = self.startLevel.name;
  }
  [self.view addSubview:self.topLabel];
  
  self.backwardButton = [[[UIButton alloc] init] autorelease];
  [self.backwardButton addTarget:self
                          action:@selector(clickBack:)
                forControlEvents:UIControlEventTouchUpInside];
  [self.backwardButton setImage:leftImage
                       forState:UIControlStateNormal];
  self.backwardButton.frame = CGRectMake(0, 0,
					 leftImage.size.width,
					 leftImage.size.height);
  self.backwardButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:self.backwardButton];
  
  self.restartButton = [[[UIButton alloc] init] autorelease];
  [self.restartButton addTarget:self
                         action:@selector(clickRestart:)
               forControlEvents:UIControlEventTouchUpInside];
  [self.restartButton setImage:restartImage
                      forState:UIControlStateNormal];
  self.restartButton.frame = CGRectMake(self.view.frame.size.width -
					restartImage.size.width,
                                        0,
                                        restartImage.size.width,
					restartImage.size.height);
  self.restartButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:self.restartButton];
  
  UIImage *rightImage = I.images.right;
  self.forwardButton = [[[UIButton alloc] init] autorelease];
  [self.forwardButton addTarget:self
                         action:@selector(clickForward:)
               forControlEvents:UIControlEventTouchUpInside];
  [self.forwardButton setImage:rightImage
                      forState:UIControlStateNormal];
  self.forwardButton.center = CGPointMake(0, 0);
  // outside screen
  self.forwardButton.frame = CGRectMake(self.view.frame.size.width,
                                        0,
                                        rightImage.size.width,
					rightImage.size.height);
  self.forwardButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:self.forwardButton];
  
  self.completedView = [[[UIView alloc] init] autorelease];
  self.completedView.center = CGPointMake(self.view.bounds.size.width / 2,
					  self.view.bounds.size.height / 2);
  self.completedView.bounds = CGRectMake(0, 0,
					 self.view.bounds.size.width * 0.7f,
					 self.view.bounds.size.height * 0.15f);
  self.completedView.frame = CGRectInt(self.completedView.frame);
  self.completedView.center = CGPointDelta(self.completedView.center,
					   CGPointMake(-self.view.bounds.size.width, 0));
  self.completedView.backgroundColor = [UIColor colorWithWhite:0.0f
                                                         alpha:0.3f];
  self.completedView.layer.cornerRadius = _DeviceModel == MiscDeviceModelIPad ? 20 : 10;
  self.completedView.hidden = YES;
  [self.view addSubview:self.completedView];
  
  CGFloat completedLabelFontSize = (int)(self.view.bounds.size.height / 10.0f);
  self.completedLabel = [[[SlippyLabel alloc] init] autorelease];
  self.completedLabel.center = CGPointMake(self.completedView.bounds.size.width / 2,
					   self.completedView.bounds.size.height / 2);
  self.completedLabel.bounds = CGRectMake(0, 0,
					  self.completedView.bounds.size.width,
					  completedLabelFontSize + 10);
  self.completedLabel.frame = CGRectInt(self.completedLabel.frame);
  self.completedLabel.fontSize = completedLabelFontSize;
  self.completedLabel.textAlignment = UITextAlignmentCenter;
  self.completedLabel.text = @"Level completed!";
  [self.completedView addSubview:self.completedLabel];
  
  UIImage *startsEmptyImage = I.images.bigStarsEmpty;
  self.completedRating = [[[RatingSlider alloc] init] autorelease];
  self.completedRating.center = CGPointMake(self.completedView.bounds.size.width / 2,
					    self.completedView.bounds.size.height * 1.3f);
  self.completedRating.bounds = CGRectMake(0, 0,
					   startsEmptyImage.size.width * 5,
					   startsEmptyImage.size.height);
  self.completedRating.frame = CGRectInt(self.completedRating.frame);
  self.completedRating.emptyImage = startsEmptyImage;
  self.completedRating.halfImage = I.images.bigStarsHalf;
  self.completedRating.fullImage = I.images.bigStarsFull;
  self.completedRating.min = 0.0;
  self.completedRating.max = 5.0;
  self.completedRating.stars = 5;
  self.completedRating.integerValue = YES;
  self.completedRating.hidden = YES;
  [self.completedRating addTarget:self
                           action:@selector(touchCompletedRating:)
                 forControlEvents:UIControlEventTouchUpInside];
  [self.completedView addSubview:self.completedRating];
  
  CGFloat completedRatingLabelFontSize = (int)(self.view.bounds.size.height / 32.0f);
  self.completedRatingCommentLabel = [[[SlippyLabel alloc] init] autorelease];
  self.completedRatingCommentLabel.center = CGPointMake(self.completedView.bounds.size.width / 2,
							self.completedView.bounds.size.height * 1.9f);
  self.completedRatingCommentLabel.bounds = CGRectMake(0, 0,
						       self.completedView.bounds.size.width,
						       completedRatingLabelFontSize + 5);
  self.completedRatingCommentLabel.frame = CGRectInt(self.completedRatingCommentLabel.frame);
  self.completedRatingCommentLabel.fontSize = completedRatingLabelFontSize;
  self.completedRatingCommentLabel.textAlignment = UITextAlignmentCenter;
  self.completedRatingCommentLabel.text = @"Touch stars to submit rating";
  self.completedRatingCommentLabel.hidden = YES;
  [self.completedView addSubview:self.completedRatingCommentLabel];
}

- (void)unloadView {
  self.startLevel = nil;
  self.nextLevel = nil;
  self.gameView = nil;
  
  if (self.restartTimer != nil) {
    [self.restartTimer invalidate];
    self.restartTimer = nil;
  }
  
  if (self.nextLevelTimer != nil) {
    [self.nextLevelTimer invalidate];
    self.nextLevelTimer = nil;
  }
  
  self.backwardButton = nil;
  self.restartButton = nil;
  self.forwardButton = nil;
  self.topLabel = nil;
  self.completedView = nil;
  self.completedLabel = nil;
  self.completedRating = nil;
  
  [super unloadView];
}

- (void)viewDidUnload {  
  [self unloadView];
  [super viewDidUnload];
}

- (void)dealloc {
  [self unloadView];
  [super dealloc];
}

@end
