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

#import "PlayGameTileView.h"
#import "DPadView.h"

#define TOUCH_THRESHOLD_START 30
#define TOUCH_THRESHOLD_CHANGE 10
#define TOUCH_THRESHOLD_REPEAT 50



@interface PlayGameTileView ()

@property(nonatomic, assign) CGPoint touchStartPos;
@property(nonatomic, assign) CGPoint touchLastPos;
@property(nonatomic, retain) PlayerDirection *touchStartDir;
@property(nonatomic, retain) PlayerDirection *touchLastDir;
@property(nonatomic, retain) NSTimer *moveTimer;

@property(nonatomic, retain) NSMutableArray *_steps;
@property(nonatomic, retain) NSDate *_start;

@end


@implementation PlayGameTileView

@synthesize dpad;

@synthesize touchStartPos;
@synthesize touchLastPos;
@synthesize touchStartDir;
@synthesize touchLastDir;
@synthesize moveTimer;

@synthesize _steps;
@synthesize _start;

- (void)test:(id)sender {  
  for (PlayerDirection *dir in [NSArray arrayWithObjects:
				self.directionLeft,
				self.directionRight,
				self.directionUp,
				self.directionDown,
				nil]) {
    if (dir.delta.x == self.dpad.direction.x &&
	dir.delta.y == self.dpad.direction.y) {
      [super move:dir hold:self.dpad.hold];
    }
  }
}


- (id)initWithFrame:(CGRect)aRect {
  self = [super initWithFrame:aRect];
  if (self == nil) {
    return nil;
  }
  
  if (_isDeveloper()) {
    self._steps = [NSMutableArray array];
    self._start = [NSDate date];
  }
  
  self.dpad = [[[DPadView alloc] initWithImage:I.images.dpad
				    touchImage:I.images.dpadTouch
				repeatInterval:0.2f]
	       autorelease];
  self.dpad.center = CGPointMake(self.dpad.image.size.width * 0.52,
				 self.bounds.size.height - dpad.image.size.height * 0.52);
  self.dpad.frame = CGRectInt(dpad.frame);
  [self.dpad addTarget:self
		action:@selector(test:)
      forControlEvents:UIControlEventValueChanged];
  [self addSubview:dpad];
  self.dpad.layer.zPosition = 200;
  
  float dpadAlpha = [[NSUserDefaults standardUserDefaults]
		     floatForKey:SlippySettingDPadAlpha];
  if (dpadAlpha > 0) {
    self.dpad.alpha = dpadAlpha;
  } else {
    self.dpad.hidden = YES;
  }
  
  return self;
}

- (PlayerDirection *)shouldMoveFromStart:(CGPoint)start
                                    stop:(CGPoint)stop
                               threshold:(float)threshold {
  float dx = start.x - stop.x;
  float dy = start.y - stop.y;
  
  if (fabs(dx) < threshold && fabs(dy) < threshold) {
    return nil;
  }
  
  if (fabs(dx) > fabs(dy)) {
    if (dx > 0) {
      return self.directionLeft;
    } else {
      return self.directionRight;
    }
  } else  {
    if (dy > 0) {
      return self.directionUp;
    } else {
      return self.directionDown;
    }
  }
}

- (BOOL)shouldRepeatFromStart:(CGPoint)start
                         stop:(CGPoint)stop
                          dir:(PlayerDirection *)dir {
  float dx = start.x - stop.x;
  float dy = start.y - stop.y;
  
  if(dir == self.directionLeft && dx > TOUCH_THRESHOLD_REPEAT) {
    return YES;
  } else if(dir == self.directionRight && dx < -TOUCH_THRESHOLD_REPEAT) {
    return YES;
  } else if(dir == self.directionUp && dy > TOUCH_THRESHOLD_REPEAT) {
    return YES;
  } else if(dir == self.directionDown && dy < -TOUCH_THRESHOLD_REPEAT) {
    return YES;
  }
  
  return NO;
}

- (void)logStep:(NSDictionary *)step {
  NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:step];
  
  [d setObject:[NSNumber numberWithFloat:[[NSDate date]
                                          timeIntervalSinceDate:self._start]]
        forKey:@"delay"];
  [self._steps addObject:d];
}

- (void)logMoveDir:(PlayerDirection *)dir hold:(BOOL)hold {
  if (self._steps == nil) {
    return;
  }
  
  NSString *dirName;
  
  if (dir == self.directionUp) {
    dirName = @"up";
  } else if (dir == self.directionDown) {
    dirName = @"down";
  } else if (dir == self.directionLeft) {
    dirName = @"left";
  } else if (dir == self.directionRight) {
    dirName = @"right";
  } else {
    dirName = @"unknown";
  }
  
  [self logStep:[NSDictionary
                 dictionaryWithObjectsAndKeys:
                 dirName,
                 @"action",
                 [NSNumber numberWithBool:hold],
                 @"hold",
                 nil
                 ]];
}

- (void)logHandPos:(CGPoint)pos touch:(BOOL)touch {
  if (self._steps == nil) {
    return;
  }
  
  [self logStep:[NSDictionary
                 dictionaryWithObjectsAndKeys:
                 touch ? @"touch" : @"point",
                 @"action",
                 [NSNumber numberWithFloat:pos.x],
                 @"x",
                 [NSNumber numberWithFloat:pos.y],
                 @"y",
                 nil
                 ]];
}

- (void)move:(PlayerDirection *)dir hold:(BOOL)hold {
  [self logMoveDir:dir hold:hold];
  [super move:dir hold:hold];
}

- (void)moveTimerMethod:(NSTimer *)timer {
  [self move:self.touchLastDir hold:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.disableInput) {
    return;
  }
  
  if ([touches count] != 1) {
    return;
  }
  
  UITouch *touch = [[touches objectEnumerator] nextObject];
  CGPoint pos = [touch locationInView:self];
  self.touchStartPos = pos;
  self.touchStartDir = nil;
  self.touchLastPos = pos;
  self.touchLastDir = nil;
  
  [self logHandPos:pos touch:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.disableInput) {
    return;
  }
  
  if ([touches count] != 1) {
    return;
  }
  
  UITouch *touch = [[touches objectEnumerator] nextObject];
  CGPoint pos = [touch locationInView:self];
  PlayerDirection *dir;
  
  if (self.moveTimer == nil) {
    dir = [self shouldMoveFromStart:self.touchLastPos
                               stop:pos
                          threshold:TOUCH_THRESHOLD_START];
    
    if (self.touchStartDir != nil &&
        ([self shouldRepeatFromStart:self.touchStartPos
                                stop:pos
                                 dir:self.touchStartDir])) {
      
      self.moveTimer = [NSTimer
                        scheduledTimerWithTimeInterval:0.2f
                        target:self
                        selector:@selector(moveTimerMethod:)
                        userInfo:nil
                        repeats:YES];
    } else if (dir != nil) {
      [self move:dir hold:NO];
      self.touchLastDir = dir;
      self.touchLastPos = pos;
      self.touchStartDir = dir;
    }
  } else {
    dir = [self shouldMoveFromStart:self.touchLastPos
                               stop:pos
                          threshold:TOUCH_THRESHOLD_CHANGE];
    
    if (dir != nil && dir != self.touchLastDir) {
      self.touchLastDir = dir;
      self.touchLastPos = pos;
    }
  }
  
  [self logHandPos:pos touch:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.disableInput) {
    return;
  }
  
  if ([touches count] != 1) {
    return;
  }
  
  if (self.moveTimer != nil) {
    [self.moveTimer invalidate];
    self.moveTimer = nil;
  }
  
  UITouch *touch = [[touches objectEnumerator] nextObject];
  CGPoint pos = [touch locationInView:self];
  
  [self logHandPos:pos touch:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.disableInput) {
    return;
  }
  
  if ([touches count] != 1) {
    return;
  }
  
  if (self.moveTimer != nil) {
    [self.moveTimer invalidate];
    self.moveTimer = nil;
  }
  
  UITouch *touch = [[touches objectEnumerator] nextObject];
  CGPoint pos = [touch locationInView:self];
  
  [self logHandPos:pos touch:NO];
}

- (void)dealloc {
  self.touchLastDir = nil;
  self.touchStartDir = nil;
  
  if (self.moveTimer != nil) {
    [self.moveTimer invalidate];
    self.moveTimer = nil;
  }
  
  if (self._steps != nil) {
    [self logStep:[NSDictionary dictionary]];
    
    NSMutableArray *steps = [NSMutableArray array];
    float delay = 0;
    
    for (int i = 0; i < [self._steps count] - 1; i++) {
      NSDictionary *current = [self._steps objectAtIndex:i];
      NSDictionary *next = [self._steps objectAtIndex:i + 1];
      
      NSNumber *currentTimestamp = [current objectForKey:@"delay"];
      NSString *currentAction = [current objectForKey:@"action"];
      NSNumber *nextTimestamp = [next objectForKey:@"delay"];
      NSString *nextAction = [next objectForKey:@"action"];
      
      delay += [nextTimestamp floatValue] - [currentTimestamp floatValue];
      
      if ([currentAction isEqualToString:@"touch"] &&
          [nextAction isEqualToString:@"touch"] &&
          delay < 0.1f) {
        continue;
      }
      
      NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:current];
      [d setObject:[NSNumber numberWithFloat:delay]
            forKey:@"delay"];
      
      [steps addObject:d];
      delay = 0;
    }
    
    NSString *file = _pathToDocument(@"Steps.plist");
    [steps writeToFile:file atomically:YES];
    
    self._steps = nil;
    self._start = nil;
  }
  
  
  [super dealloc];
}

@end
