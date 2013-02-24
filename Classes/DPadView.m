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

#import "DPadView.h"

@interface DPadView ()
@property(nonatomic, retain) NSTimer *repeatTimer;
@property(nonatomic, assign) NSTimeInterval repeatInterval;
@property(nonatomic, assign) CGPoint currentLocation;
@property(nonatomic, assign) BOOL isTouching;
@end

@implementation DPadView

@synthesize image;
@synthesize touchImage;
@synthesize repeatTimer;
@synthesize repeatInterval;
@synthesize currentLocation;
@synthesize isTouching;

- (id)initWithImage:(UIImage *)aImage
	 touchImage:(UIImage *)aTouchImage
     repeatInterval:(NSTimeInterval)aRepeatInterval {
  self = [super initWithFrame:CGRectMake(0, 0,
					 aImage.size.width,
					 aImage.size.height)];
  if (self == nil) {
    return nil;
  }
  
  self.backgroundColor = [UIColor clearColor];
  self.image = aImage;
  self.touchImage = aTouchImage;
  self.repeatInterval = aRepeatInterval;
  self.isTouching = NO;
  
  return self;
}

- (CGPoint)locationToPoint:(CGPoint)location {
  location = CGPointMake(location.x / self.frame.size.width,
			 location.y / self.frame.size.height);
  
  if (location.y < 0.33 && location.x > 0.33 && location.x < 0.66) {
    return CGPointMake(0, -1);
  } else if (location.y > 0.66 && location.x > 0.33 && location.x < 0.66) {
    return CGPointMake(0, 1);
  } else if (location.x < 0.33 && location.y > 0.33 && location.y < 0.66) {
    return CGPointMake(-1, 0);
  } else if (location.x > 0.66 && location.y > 0.33 && location.y < 0.66) {
    return CGPointMake(1, 0);
  } else {
    return CGPointMake(0, 0);
  }
}

- (BOOL)hold {
  return self.repeatTimer != nil;
}

- (CGPoint)direction {
  return [self locationToPoint:self.currentLocation];
}

- (void)drawRect:(CGRect)rect {
  [self.image drawInRect:CGRectMake(0, 0,
				    self.image.size.width,
				    self.image.size.height)];
  
  CGPoint dir = self.direction;
  if (self.hold && (dir.x != 0 || dir.y != 0)) {
    [self.touchImage drawInRect:CGRectMake(self.image.size.width / 2 -
					   self.touchImage.size.width / 2 +
					   dir.x * self.image.size.width / 3,
					   self.image.size.height / 2 -
					   self.touchImage.size.height / 2 +
					   dir.y * self.image.size.height / 3,
					   self.touchImage.size.width,
					   self.touchImage.size.height)];
  }
}

- (void)sendActionIfHaveDirection {
  CGPoint dir = self.direction;
  if (dir.x == 0 && dir.y == 0) {
    return;
  }
  
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)updateCurrentLocation:(NSSet *)touches {
  UITouch *touch = [touches anyObject];
  self.currentLocation = [touch locationInView:self];
  [self setNeedsDisplay];
}

- (void)repeatTimerCallback:(NSTimer *)timer {
  if (self.isTouching) {
    [self sendActionIfHaveDirection];
  } else {
    [self.repeatTimer invalidate];
    self.repeatTimer = nil;
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.repeatTimer != nil) {
    return;
  }
  
  self.isTouching = YES;
  [self updateCurrentLocation:touches];
  [self sendActionIfHaveDirection];
  self.repeatTimer = [NSTimer
		      scheduledTimerWithTimeInterval:self.repeatInterval
		      target:self
		      selector:@selector(repeatTimerCallback:)
		      userInfo:nil
		      repeats:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [self updateCurrentLocation:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  self.isTouching = NO;
  [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  self.isTouching = NO;
  [self setNeedsDisplay];
}

- (void)dealloc {
  self.image = nil;
  if (self.repeatTimer != nil) {
    [self.repeatTimer invalidate];
    self.repeatTimer = nil;
  }
  
  [super dealloc];
}

@end
