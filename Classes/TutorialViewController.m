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

#import "TutorialViewController.h"
#import "LevelDatabase.h"


@interface HelpAction : NSObject

@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *action;
@property(nonatomic, assign) float delay;
@property(nonatomic, assign) CGPoint handPos;
@property(nonatomic, assign) BOOL hold;

+ (id)actionWithDelay:(float)aDelay
                 text:(NSString *)aText
               action:(NSString *)aAction
              handPos:(CGPoint)aHandPos
                 hold:(BOOL)hold;

- (id)initWithDelay:(float)aDelay
               text:(NSString *)aText
             action:(NSString *)aAction
            handPos:(CGPoint)aHandPos
               hold:(BOOL)hold;

@end

@implementation HelpAction

@synthesize text;
@synthesize action;
@synthesize delay;
@synthesize handPos;
@synthesize hold;

+ (id)actionWithDelay:(float)aDelay
                 text:(NSString *)aText
               action:(NSString *)aAction
              handPos:(CGPoint)aHandPos
                 hold:(BOOL)aHold {
  return [[[HelpAction alloc] initWithDelay:aDelay
                                       text:aText
                                     action:aAction
                                    handPos:aHandPos
                                       hold:aHold]
          autorelease];
}

- (id)initWithDelay:(float)aDelay
               text:(NSString *)aText
             action:(NSString *)aAction
            handPos:(CGPoint)aHandPos
               hold:(BOOL)aHold {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  
  self.delay = aDelay;
  self.text = aText;
  self.action = aAction;
  self.handPos = aHandPos;
  self.hold = aHold;
  
  return self;
}

- (void)dealloc {
  self.text = nil;
  self.action = nil;
  
  [super dealloc];
}

@end


@interface TutorialViewController ()

@property(nonatomic, retain) SlippyLabel *textLabel;
@property(nonatomic, retain) NSMutableArray *actions;
@property(nonatomic, assign) int actionsPosition;
@property(nonatomic, retain) NSTimer *actionTimer;
@property(nonatomic, retain) UIImageView *handImage;
@property(nonatomic, retain) UIImage *handTouch;
@property(nonatomic, retain) UIImage *handPoint;
@property(nonatomic, assign) CGPoint handAnchorPoint;
@property(nonatomic, assign) CGPoint posScale;

@end


@implementation TutorialViewController

@synthesize actions;
@synthesize actionsPosition;
@synthesize actionTimer;
@synthesize textLabel;
@synthesize handImage;
@synthesize handTouch;
@synthesize handPoint;
@synthesize handAnchorPoint;
@synthesize posScale;

+ (NSString *)name {
  return @"Tutorial";
}

- (IBAction)clickBack:(id)sender {
  if (self.actionTimer != nil) {
    [self.actionTimer invalidate];
    self.actionTimer = nil;
  }
  
  [self.gameView stop];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)levelChanged {  
  self.state = nil;
}

- (IBAction)clickRestart:(id)sender {
}

+ (CGFloat)angleFrom:(CGPoint)middle pos:(CGPoint)pos {
  CGFloat dx = pos.x - middle.x;
  CGFloat dy = middle.y - pos.y;
  
  CGFloat angle = atan((CGFloat)dy/dx);
  /* translate to "whole" circle angle */
  if(dx < 0)
    angle += (CGFloat)M_PI;
  else if(dx > 0 && dy < 0)
    angle += (CGFloat)M_PI*2;
  
  return angle;
}

- (void)doAction {
  HelpAction *a = [self.actions objectAtIndex:self.actionsPosition];
  self.actionsPosition++;
  
  if (a.action != nil) {
    if ([a.action isEqualToString:@"up"]) {
      [self.gameView move:self.gameView.directionUp hold:a.hold];
    } else if ([a.action isEqualToString:@"down"]) {
      [self.gameView move:self.gameView.directionDown hold:a.hold];
    } else if ([a.action isEqualToString:@"left"]) {
      [self.gameView move:self.gameView.directionLeft hold:a.hold];
    } else if ([a.action isEqualToString:@"right"]) {
      [self.gameView move:self.gameView.directionRight hold:a.hold];
    } else if ([a.action isEqualToString:@"restart"]) {
      [self restart];
      self.restartButton.highlighted = YES;
      self.restartButton.highlighted = NO;
    } else if ([a.action isEqualToString:@"dpad_show"]) {
      [UIView beginAnimations:nil context:NULL];
      [UIView setAnimationDuration:1.0];
      self.gameView.dpad.alpha = 0.5f;
      [UIView commitAnimations];
    } else if ([a.action isEqualToString:@"dpad_hide"]) {
      [UIView beginAnimations:nil context:NULL];
      [UIView setAnimationDuration:1.0];
      self.gameView.dpad.alpha = 0.0f;
      [UIView commitAnimations];
    } else if ([a.action isEqualToString:@"point"] ||
               [a.action isEqualToString:@"touch"]) {
      UIImage *img;
      if ([a.action isEqualToString:@"point"]) {
        img = self.handPoint;
      } else {
        img = self.handTouch;
      }
      
      CGPoint pos = CGPointMake(a.handPos.x * self.posScale.x,
				a.handPos.y * self.posScale.y);
      
      CGFloat d = [[self class] angleFrom:self.handAnchorPoint
                                      pos:pos];
      d -= M_PI/2;
      d = -d;
      
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:a.delay];
      self.handImage.image = img;
      self.handImage.center = CGPointDelta(pos, self.gameView.frame.origin);
      self.handImage.bounds = CGRectMake(0, 0,
                                         img.size.width,
                                         img.size.width);
      self.handImage.transform = CGAffineTransformMakeRotation(d);
      [UIView commitAnimations];
    }
  }
  
  if (a.text != nil) {
    if([a.text isEqualToString:@""]) {
      [UIView beginAnimations:nil context:NULL];
      [UIView setAnimationDuration:0.5];
      self.textLabel.alpha = 0.0f;
      [UIView commitAnimations];
    } else {
      self.textLabel.text = a.text;
      [UIView beginAnimations:nil context:NULL];
      [UIView setAnimationDuration:0.5];
      self.textLabel.alpha = 1.0f;
      [UIView commitAnimations];
    }
  }
  
  if (self.actionTimer != nil) {
    [self.actionTimer invalidate];
    self.actionTimer = nil;
  }
  
  if (self.actionsPosition >= [self.actions count]) {
    return;
  }
  
  self.actionTimer = [NSTimer
                      scheduledTimerWithTimeInterval:a.delay
                      target:self
                      selector:@selector(actionTimerCallback:)
                      userInfo:nil
                      repeats:NO];
}

- (void)actionTimerCallback:(NSTimer*)theTimer {
  [self doAction];
}

- (void)loadActions:(NSString *)path {
  NSArray *array = [NSArray arrayWithContentsOfFile:path];
  if (array == nil) {
    return;
  }
  
  for (NSDictionary *step in array) {
    NSNumber *delay = nil;
    NSString *text = nil;
    NSString *action = nil;
    NSNumber *repeat = nil;
    NSNumber *n = nil;
    CGPoint handPos = CGPointMake(0, 0);
    NSNumber *hold;
    
    delay = [step objectForKey:@"delay"];
    if (delay == nil) {
      delay = [NSNumber numberWithFloat:0.0f];
    }
    repeat = [step objectForKey:@"repeat"];
    if (repeat == nil) {
      repeat = [NSNumber numberWithInt:1];
    }
    text = [step objectForKey:@"text"];
    action = [step objectForKey:@"action"];
    
    n = [step objectForKey:@"x"];
    if (n != nil) {
      handPos.x = [n floatValue];
    }
    n = [step objectForKey:@"y"];
    if (n != nil) {
      handPos.y = [n floatValue];
    }
    hold = [step objectForKey:@"hold"];
    if (hold == nil) {
      hold = [NSNumber numberWithBool:NO];
    }
    
    for (int i = 0; i < [repeat intValue]; i++) {
      [self.actions addObject:[HelpAction actionWithDelay:[delay floatValue]
                                                     text:text
                                                   action:action
                                                  handPos:handPos
                                                     hold:[hold boolValue]]];
    }
  }
}

- (id)init {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  
  self.startLevel = [[LevelDatabase shared] levelWithId:@"tutorial"];
  
  return self;
} 

- (void)viewDidLoad {
  self.state = nil;
  
  [super viewDidLoad];
  
  if (_DeviceModel == MiscDeviceModelIPad) {
    self.handAnchorPoint = CGPointMake(420 * 2, 800 * 2);
    self.posScale = CGPointMake(1024.0f / 480.0f, 768.0f / 320.0f);
  } else {
    self.handAnchorPoint = CGPointMake(420, 800);
    self.posScale = CGPointMake(1, 1);
  }
  
  self.gameView.dpad.hidden = NO;
  self.gameView.dpad.alpha = 0.0f;
  
  self.gameView.disableInput = YES;
  
  CGFloat textLabelFontSize = (int)(self.view.bounds.size.height / 18.f);
  self.textLabel = [[[SlippyLabel alloc] init] autorelease];
  self.textLabel.center = CGPointMake(self.view.bounds.size.width / 2,
				      self.view.bounds.size.height * 0.89f);
  self.textLabel.bounds = CGRectMake(0, 0,
				     self.view.bounds.size.width * 0.8f,
				     self.view.bounds.size.height * 0.15f);
  self.textLabel.frame = CGRectInt(self.textLabel.frame);
  self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.textLabel.textAlignment = UITextAlignmentCenter;
  self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  self.textLabel.numberOfLines = 3;
  self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  self.textLabel.fontSize = textLabelFontSize;
  self.textLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
  self.textLabel.layer.cornerRadius = _DeviceModel == MiscDeviceModelIPad ? 20 : 10;
  [self.view addSubview:self.textLabel];
  
  self.actions = [NSMutableArray array];
  self.actionsPosition = 0;
  
  [self loadActions:P.levels.tutorialIntroPlist];
  [self loadActions:P.levels.tutorialMove1Plist];
  [self loadActions:P.levels.tutorialMove2Plist];
  [self loadActions:P.levels.tutorialWorld1Plist];
  [self loadActions:P.levels.tutorialWorld2Plist];
  [self loadActions:P.levels.tutorialScoreBlockPlist];
  [self loadActions:P.levels.tutorialRestartPlist];
  [self loadActions:P.levels.tutorialPush1Plist];
  [self loadActions:P.levels.tutorialPush2Plist];
  
  self.handTouch = I.images.handTouch;
  self.handPoint = I.images.handPoint;
  
  self.handImage = [[[UIImageView alloc] init] autorelease];
  self.handImage.layer.anchorPoint = CGPointMake(0.28f, 0.15f);
  self.handImage.layer.zPosition = 1000;
  self.handImage.image = I.images.handTouch;
  self.handImage.frame = CGRectMake(500 * self.posScale.x,
				    100 * self.posScale.y,
                                    self.handTouch.size.width,
                                    self.handTouch.size.height);
  [self.view addSubview:self.handImage];
  
  [self doAction];
}

- (void)unloadView {
  if (self.actionTimer != nil) {
    [self.actionTimer invalidate];
    self.actionTimer = nil;
  }
  
  self.actions = nil;
  self.textLabel = nil;
  self.gameView = nil;
  self.handImage = nil;
  self.handTouch = nil;
  self.handPoint = nil;
  
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
