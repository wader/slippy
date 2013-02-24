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

#import "GameTileView.h"
#import "UIImage+extra.h"
#import "SlippyAudio.h"
#import "LevelFixedView.h"


@implementation PlayerDirection

@synthesize name;
@synthesize delta;
@synthesize CGImageStand;
@synthesize CGImageBlink;
@synthesize CGImageScratch1;
@synthesize CGImageScratch2;
@synthesize CGImageScratch3;
@synthesize CGImageWalk1;
@synthesize CGImageWalk2;
@synthesize CGImagePush1;
@synthesize CGImagePush2;
@synthesize CGImageEat1;
@synthesize CGImageEat2;

+ (id)playerDirectionWithName:(NSString *)aName
                        delta:(CGPoint)aDelta
                        stand:(UIImage *)stand
                        blink:(UIImage *)blink
		     scratch1:(UIImage *)scratch1
		     scratch2:(UIImage *)scratch2
		     scratch3:(UIImage *)scratch3
                        walk1:(UIImage *)walk1
                        walk2:(UIImage *)walk2
                        push1:(UIImage *)push1
                        push2:(UIImage *)push2
                         eat1:(UIImage *)eat1
                         eat2:(UIImage *)eat2 {
  return [[[PlayerDirection alloc]
           initWithName:aName
           delta:aDelta
           stand:stand
           blink:blink
	   scratch1:scratch1
	   scratch2:scratch2
	   scratch3:scratch3
           walk1:walk1
           walk2:walk2
           push1:push1
           push2:push2
           eat1:eat1
           eat2:eat2]
          autorelease];
}

- (id)initWithName:(NSString *)aName
             delta:(CGPoint)aDelta
             stand:(UIImage *)stand
             blink:(UIImage *)blink
	  scratch1:(UIImage *)scratch1
	  scratch2:(UIImage *)scratch2
	  scratch3:(UIImage *)scratch3
	     walk1:(UIImage *)walk1
	     walk2:(UIImage *)walk2
             push1:(UIImage *)push1
             push2:(UIImage *)push2
              eat1:(UIImage *)eat1
              eat2:(UIImage *)eat2 {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  
  self.name = aName;
  self.delta = aDelta;
  self.CGImageStand = (id)stand.CGImage;
  self.CGImageBlink = (id)blink.CGImage;
  self.CGImageScratch1 = (id)scratch1.CGImage;
  self.CGImageScratch2 = (id)scratch2.CGImage;
  self.CGImageScratch3 = (id)scratch3.CGImage;
  self.CGImageWalk1 = (id)walk1.CGImage;
  self.CGImageWalk2 = (id)walk2.CGImage;
  self.CGImagePush1 = (id)push1.CGImage;
  self.CGImagePush2 = (id)push2.CGImage;
  self.CGImageEat1 = (id)eat1.CGImage;
  self.CGImageEat2 = (id)eat2.CGImage;
  
  return self;
}

- (void)dealloc {
  self.name = nil;
  self.CGImageStand = nil;
  self.CGImageBlink = nil;
  self.CGImageScratch1 = nil;
  self.CGImageScratch2 = nil;
  self.CGImageScratch3 = nil;
  self.CGImageWalk1 = nil;
  self.CGImageWalk2 = nil;
  self.CGImagePush1 = nil;
  self.CGImagePush2 = nil;
  self.CGImageEat1 = nil;
  self.CGImageEat2 = nil;
  
  [super dealloc];
}

@end

@implementation GameTileView

@synthesize playerPosition;
@synthesize playerLayer;
@synthesize fixedLayer;
@synthesize currentDirection;

@synthesize directionDown;
@synthesize directionUp;
@synthesize directionRight;
@synthesize directionLeft;

@synthesize gameDelegate;

@synthesize scoresLeft;
@synthesize disableInput;

@synthesize actionTimer;

@synthesize statsSolveTime;
@synthesize statsPushes;
@synthesize statsMoves;

@synthesize lastMove;

@synthesize scale;


- (id)initWithFrame:(CGRect)aRect {
  self = [super initWithFrame:aRect skipFixed:YES];
  if (self == nil) {
    return nil;
  }
  
  self.scale = _DeviceModel == MiscDeviceModelIPad ? 2 : 1;
  
  self.fixedLayer = [[[CALayer alloc] init] autorelease];
  self.fixedLayer.zPosition = -1;
  self.fixedLayer.anchorPoint = CGPointMake(0, 0);
  self.fixedLayer.position = CGPointMake(0, self.offset.y);
  [self.layer addSublayer:self.fixedLayer];
  
  UIImage *images = I.images.playerFrames;
  int w = images.size.width / 11;
  int h = images.size.height / 4;
  
  CGRect stand = CGRectMake(w * 0, 0, w, h);
  CGRect blink = CGRectMake(w * 1, 0, w, h);
  CGRect scratch1 = CGRectMake(w * 2, 0, w, h);
  CGRect scratch2 = CGRectMake(w * 3, 0, w, h);
  CGRect scratch3 = CGRectMake(w * 4, 0, w, h);
  CGRect walk1 = CGRectMake(w * 5, 0, w, h);
  CGRect walk2 = CGRectMake(w * 6, 0, w, h);
  CGRect push1 = CGRectMake(w * 7, 0, w, h);
  CGRect push2 = CGRectMake(w * 8, 0, w, h);
  CGRect eat1 = CGRectMake(w * 9, 0, w, h);
  CGRect eat2 = CGRectMake(w * 10, 0, w, h);
  
  self.directionDown = [PlayerDirection
                        playerDirectionWithName:@"down"
                        delta:CGPointMake(0, 1)
                        stand:[images UImageFromRect:CGRectMove(stand, 0, h * 0)]
                        blink:[images UImageFromRect:CGRectMove(blink, 0, h * 0)]
			scratch1:[images UImageFromRect:CGRectMove(scratch1, 0, h * 0)]
			scratch2:[images UImageFromRect:CGRectMove(scratch2, 0, h * 0)]
			scratch3:[images UImageFromRect:CGRectMove(scratch3, 0, h * 0)]
                        walk1:[images UImageFromRect:CGRectMove(walk1, 0, h * 0)]
                        walk2:[images UImageFromRect:CGRectMove(walk2, 0, h * 0)]
                        push1:[images UImageFromRect:CGRectMove(push1, 0, h * 0)]
                        push2:[images UImageFromRect:CGRectMove(push2, 0, h * 0)]
                        eat1:[images UImageFromRect:CGRectMove(eat1, 0, h * 0)]
                        eat2:[images UImageFromRect:CGRectMove(eat2, 0, h * 0)]];
  
  self.directionUp = [PlayerDirection
                      playerDirectionWithName:@"up"
                      delta:CGPointMake(0, -1)
		      stand:[images UImageFromRect:CGRectMove(stand, 0, h * 1)]
		      blink:[images UImageFromRect:CGRectMove(blink, 0, h * 1)]
		      scratch1:[images UImageFromRect:CGRectMove(scratch1, 0, h * 1)]
		      scratch2:[images UImageFromRect:CGRectMove(scratch2, 0, h * 1)]
		      scratch3:[images UImageFromRect:CGRectMove(scratch3, 0, h * 1)]
		      walk1:[images UImageFromRect:CGRectMove(walk1, 0, h * 1)]
		      walk2:[images UImageFromRect:CGRectMove(walk2, 0, h * 1)]
		      push1:[images UImageFromRect:CGRectMove(push1, 0, h * 1)]
		      push2:[images UImageFromRect:CGRectMove(push2, 0, h * 1)]
		      eat1:[images UImageFromRect:CGRectMove(eat1, 0, h * 1)]
		      eat2:[images UImageFromRect:CGRectMove(eat2, 0, h * 1)]];
  
  self.directionRight = [PlayerDirection
                         playerDirectionWithName:@"right"
                         delta:CGPointMake(1, 0)
			 stand:[images UImageFromRect:CGRectMove(stand, 0, h * 2)]
			 blink:[images UImageFromRect:CGRectMove(blink, 0, h * 2)]
			 scratch1:[images UImageFromRect:CGRectMove(scratch1, 0, h * 2)]
			 scratch2:[images UImageFromRect:CGRectMove(scratch2, 0, h * 2)]
			 scratch3:[images UImageFromRect:CGRectMove(scratch3, 0, h * 2)]
			 walk1:[images UImageFromRect:CGRectMove(walk1, 0, h * 2)]
			 walk2:[images UImageFromRect:CGRectMove(walk2, 0, h * 2)]
			 push1:[images UImageFromRect:CGRectMove(push1, 0, h * 2)]
			 push2:[images UImageFromRect:CGRectMove(push2, 0, h * 2)]
			 eat1:[images UImageFromRect:CGRectMove(eat1, 0, h * 2)]
			 eat2:[images UImageFromRect:CGRectMove(eat2, 0, h * 2)]];
  
  self.directionLeft = [PlayerDirection
                        playerDirectionWithName:@"left"
                        delta:CGPointMake(-1, 0)
                        stand:[images UImageFromRect:CGRectMove(stand, 0, h * 3)]
                        blink:[images UImageFromRect:CGRectMove(blink, 0, h * 3)]
			scratch1:[images UImageFromRect:CGRectMove(scratch1, 0, h * 3)]
			scratch2:[images UImageFromRect:CGRectMove(scratch2, 0, h * 3)]
			scratch3:[images UImageFromRect:CGRectMove(scratch3, 0, h * 3)]
                        walk1:[images UImageFromRect:CGRectMove(walk1, 0, h * 3)]
                        walk2:[images UImageFromRect:CGRectMove(walk2, 0, h * 3)]
                        push1:[images UImageFromRect:CGRectMove(push1, 0, h * 3)]
                        push2:[images UImageFromRect:CGRectMove(push2, 0, h * 3)]
                        eat1:[images UImageFromRect:CGRectMove(eat1, 0, h * 3)]
                        eat2:[images UImageFromRect:CGRectMove(eat2, 0, h * 3)]];
  
  self.playerLayer = [[[NoAnimationLayer alloc] init] autorelease];
  self.playerLayer.bounds = CGRectMake(0, 0, w, h);
  self.playerLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
  self.playerLayer.zPosition = 100;
  [self.layer addSublayer:self.playerLayer];
  
  self.disableInput = YES;
  
  self.actionTimer = [NSTimer
                      scheduledTimerWithTimeInterval:1.0f
                      target:self
                      selector:@selector(actionTimerCallback:)
                      userInfo:nil
                      repeats:YES];
  
  self.lastMove = [NSDate date];
  
  return self;
}  

- (void)dealloc {
  self.playerLayer = nil;
  self.currentDirection = nil;
  self.directionDown = nil;
  self.directionUp = nil;
  self.directionRight = nil;
  self.directionLeft = nil;
  self.gameDelegate = nil;
  
  if (self.actionTimer != nil) {
    [self.actionTimer invalidate];
    self.actionTimer = nil;
  }
  
  self.lastMove = nil;
  
  [super dealloc];
}

// TODO: 
- (void)stop {
  [self.actionTimer invalidate];
}

+ (void)contentsAnimationAddToArray:(NSMutableArray *)anims
			     images:(NSArray *)images
			   duration:(NSTimeInterval)duration
			      delay:(NSTimeInterval)delay {
  float l = [images count];
  
  CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
  anim.calculationMode = kCAAnimationDiscrete;
  anim.beginTime = delay;
  NSMutableArray *keyTimes = [NSMutableArray array];
  int i = 0;
  for (id image in images) {
    [keyTimes addObject:[NSNumber numberWithFloat:(float)i / l]];
     i++;
  }
  anim.keyTimes = keyTimes;
  anim.values = images;
  
  [anims addObject:anim];

  
  /*
  for (id image in images) {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"contents"];
    anim.fromValue = image;
    anim.toValue = image;
    anim.beginTime = t;
    anim.duration = duration / l;
    [anims addObject:anim];
    t += duration / l;
  }
   */
}

+ (CAAnimationGroup *)contentsGroupAnimation:(NSArray *)images
				    duration:(NSTimeInterval)duration {
  NSMutableArray *anims = [NSMutableArray array];
  [[self class] contentsAnimationAddToArray:anims
				     images:images
				   duration:duration
				      delay:0];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.duration = duration;
  group.animations = anims;
  
  return group;
}


- (void)actionTimerCallback:(NSTimer *)timer {
  NSTimeInterval sinceMove = [self.lastMove timeIntervalSinceNow];
  
  if ((arc4random() % 100) < 20 && sinceMove < -1) {
    if ((arc4random() % 100) < 30) {
      
      [self.playerLayer
       addAnimation:
       [[self class]
	contentsGroupAnimation:
	[NSArray arrayWithObjects:
	 (id)self.currentDirection.CGImageScratch1,
	 (id)self.currentDirection.CGImageScratch2,
	 (id)self.currentDirection.CGImageScratch3,
	 (id)self.currentDirection.CGImageScratch2,
	 (id)self.currentDirection.CGImageScratch3,
	 (id)self.currentDirection.CGImageScratch2,
	 (id)self.currentDirection.CGImageScratch1,
	 nil]
	duration:1.0f]
       forKey:@"scratch"];
      
    } else {      
      CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"contents"];
      anim.fromValue = (id)self.currentDirection.CGImageBlink;
      anim.toValue = (id)self.currentDirection.CGImageBlink;
      anim.duration = 0.1f;
      [self.playerLayer addAnimation:anim forKey:@"blink"];
    }
  }
  
  if ((arc4random() % 100) < 40) {
    TileSquare *square = [self findRandomType:self.typeScore];
    
    if (square != nil) {
      TileSquareLayer *layer = [square topLayer];
      
      UIImage *new = [layer.type imageAt:square.position random:YES];
      CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"contents"];
      anim.fromValue = (id)new.CGImage;
      anim.toValue = (id)new.CGImage;
      anim.duration = 0.2f;
      [layer.layer addAnimation:anim forKey:nil];
      
      anim = [CABasicAnimation animationWithKeyPath:@"position"];
      anim.fromValue = [NSValue valueWithCGPoint:layer.layer.position];
      anim.toValue = [NSValue valueWithCGPoint:
                      CGPointDelta(layer.layer.position, CGPointMake(0, -0.5))];
      anim.duration = 0.2f;
      anim.autoreverses = YES;
      [layer.layer addAnimation:anim forKey:nil];
    }
  }
  
  // TODO: FIXME
  self.statsSolveTime++;
}

- (CGPoint)playerPosToPosition:(CGPoint)pos {
  return CGPointMake((self.offset.x + pos.x * self.tileSize.width) + self.tileSize.width / 2.0f,
                     (self.offset.y + pos.y * self.tileSize.height) + self.tileSize.height / 2.0f - 5
                     );
}

- (void)initLevel:(SlippyLevel *)level {  
  TileSquare *start = [self findType:self.typePlayer];
  if (start != nil) {
    [start setTop:self.typeEmpty];
    [start updateLayers];
    self.playerPosition = start.position;
    self.playerLayer.contents = directionDown.CGImageStand;
    self.currentDirection = directionDown;
    self.playerLayer.position = [self playerPosToPosition:start.position];
    self.disableInput = NO;
  }
  
  self.scoresLeft = [self countType:self.typeScore];
  
  LevelFixedView *fixedLevel = [[[LevelFixedView alloc]
				 initWithLevel:level]
				autorelease];
  UIImage *image = [fixedLevel render];
  self.fixedLayer.bounds = CGRectSize(image.size);
  self.fixedLayer.contents = (id)image.CGImage;
}

- (void)loadLevel:(SlippyLevel *)level {
  [super loadLevel:level];
  
  [self initLevel:level];
  
  self.statsSolveTime = 0;
  self.statsPushes = 0;
  self.statsMoves = 0;
  
  [self.gameDelegate levelChanged];
}

+ (float)distanceFrom:(CGPoint)from to:(CGPoint)to {
  float dx = from.x - to.x;
  float dy = from.y - to.y;
  return sqrt(dx*dx+dy*dy);
}

- (float)distanceDurationFrom:(CGPoint)from to:(CGPoint)to {
  CGFloat distance = [[self class] distanceFrom:from to:to];
  return 1.9f * (distance / self.bounds.size.width);
}

- (BOOL)tilesquareIsSolid:(TileSquare *)square {
  TileSquareLayer *topLayer = [square topLayer];
  TileSquareLayer *underLayer = [square layerUnderLayer:topLayer];
  
  return (topLayer.type == self.typeSolid ||
          topLayer.type == self.typeBlock ||
          (topLayer.type == self.typeMoveable &&
           (underLayer == nil ||
            underLayer.type == self.typeEmpty ||
            underLayer.type == self.typeMoveable ||
            underLayer.type == self.typeScore)));
}

- (BOOL)tilesquareIsMoveable:(TileSquare *)square {
  TileSquareLayer *topLayer = [square topLayer];
  TileSquareLayer *underLayer = [square layerUnderLayer:topLayer];
  
  return (topLayer.type == self.typeMoveable &&
          (underLayer == nil || 
           underLayer.type == self.typeMoveable));
}

- (TileSquare *)findObstacleFromPos:(CGPoint)pos
                                dir:(PlayerDirection *)dir {
  TileSquare *square = NULL;
  
  while (pos.x >= 0 && pos.x < self.size.width &&
         pos.y >= 0 && pos.y < self.size.height) {
    pos = CGPointDelta(pos, dir.delta);
    square = [self squareAt:pos];
    if ([self tilesquareIsSolid:square] ||
        [square topType] == self.typeScore) {
      return square;
    }
  }
  
  return nil;
}

- (void)animateLayerRemove:(CALayer *)layer
                  contents:(id)contents
                     delay:(float)delay {
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"contents"];
  anim.fromValue = contents;
  anim.toValue = contents;
  anim.duration = delay;
  
  [layer addAnimation:anim forKey:nil];
}

- (void)animatePlayerWalk:(CALayer *)layer
                     from:(CGPoint)from
                       to:(CGPoint)to
                direction:(PlayerDirection *)dir
                 duration:(float)duration
                    delay:(float)delay
                      eat:(BOOL)eat
            animationName:(NSString *)animationName {
  NSMutableArray *anims = [NSMutableArray array];
  
  CABasicAnimation *move = [CABasicAnimation
                            animationWithKeyPath:@"position"];
  move.fromValue = [NSValue valueWithCGPoint:from];
  move.toValue = [NSValue valueWithCGPoint:to];
  move.beginTime = delay;
  move.duration = duration;
  [anims addObject:move];


  [[self class] contentsAnimationAddToArray:anims
				     images:[NSArray arrayWithObjects:
					     dir.CGImageWalk1,
					     dir.CGImageWalk1,
					     dir.CGImageStand,
					     dir.CGImageWalk2,
					     dir.CGImageWalk2,
					     dir.CGImageStand,
					     nil]
				   duration:duration
				      delay:delay];
  
  if (eat) {
    [[self class] contentsAnimationAddToArray:anims
				       images:[NSArray arrayWithObjects:
					       dir.CGImageEat1,
					       dir.CGImageEat2,
					       dir.CGImageEat1,
					       nil]
				     duration:0.2f
					delay:duration + delay];
  }
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.duration = duration + delay + (eat ? 0.2f : 0);
  group.animations = anims;
  [layer addAnimation:group forKey:animationName];
}

- (void)animatePlayerPush:(CALayer *)layer direction:(PlayerDirection *)dir {
  layer.contents = dir.CGImageStand;
  
  NSMutableArray *anims = [NSMutableArray array];
  
  [[self class] contentsAnimationAddToArray:anims
				     images:[NSArray arrayWithObjects:
					     dir.CGImagePush1,
					     dir.CGImagePush2,
					     dir.CGImagePush1,
					     nil]
				   duration:0.2
				      delay:0];
  
  
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:layer.position];
  anim.toValue = [NSValue valueWithCGPoint:
                  CGPointMake(layer.position.x + dir.delta.x * 2,
                              layer.position.y + dir.delta.y * 2)];
  anim.duration = 0.2f;
  anim.autoreverses = YES;
  [anims addObject:anim];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.duration = 0.2;
  group.animations = anims;
  
  [layer addAnimation:group forKey:@"player"];
}

- (void)animateLayerPush:(CALayer *)layer
                    from:(CGPoint)from
                      to:(CGPoint)to
                     dir:(PlayerDirection *)dir
                   delay:(float)delay
                  bounce:(float)bounce
                  wobble:(float)wobble
		     end:(CGPoint)end {
  float duration = delay;
  CABasicAnimation *anim;
  NSMutableArray *anims = [NSMutableArray array];
  
  if (!CGPointEqualToPoint(from, to)) {
    anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:from];
    anim.toValue = [NSValue valueWithCGPoint:
                    CGPointDelta(to, CGPointMulti(dir.delta, bounce))];
    anim.beginTime = duration;
    anim.duration = [self distanceDurationFrom:from to:to];
    anim.timingFunction = [CAMediaTimingFunction
                           functionWithName:kCAMediaTimingFunctionEaseOut];
    [anims addObject:anim];
    duration += anim.duration;
    
    anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:
                      CGPointDelta(to, CGPointMulti(dir.delta, bounce))];
    anim.toValue = [NSValue valueWithCGPoint:to];
    anim.beginTime = duration;
    anim.duration = 0.2f;
    anim.timingFunction = [CAMediaTimingFunction
                           functionWithName:kCAMediaTimingFunctionEaseOut];
    [anims addObject:anim];
    duration += anim.duration;
    
  } else {
    anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:to];
    anim.toValue = [NSValue valueWithCGPoint:
                    CGPointDelta(to, CGPointMulti(dir.delta, bounce))];
    anim.beginTime = duration;
    anim.duration = 0.1f;
    anim.autoreverses = YES;
    anim.timingFunction = [CAMediaTimingFunction
                           functionWithName:kCAMediaTimingFunctionEaseOut];
    [anims addObject:anim];
    duration += anim.duration * 2;
  }
  
  if (to.x != end.x || to.y != end.y) {
    anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:to];
    anim.toValue = [NSValue valueWithCGPoint:end];
    anim.beginTime = duration;
    anim.duration = 0.4f;
    anim.timingFunction = [CAMediaTimingFunction
                           functionWithName:kCAMediaTimingFunctionEaseOut];
    [anims addObject:anim];
    duration += anim.duration;
  }
  
  if (wobble > 0.0f) {
    anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:end];
    anim.toValue = [NSValue valueWithCGPoint:
                    CGPointDelta(end, CGPointMake(0, wobble))];
    anim.beginTime = duration;
    anim.duration = 0.4f;
    anim.autoreverses = YES;
    anim.repeatCount = 1;
    anim.timingFunction = [CAMediaTimingFunction
                           functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [anims addObject:anim];
    duration += anim.duration * 2 * anim.repeatCount;
    
    anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:end];
    anim.toValue = [NSValue valueWithCGPoint:
                    CGPointDelta(end, CGPointMake(0, wobble / 2.0f))];
    anim.beginTime = duration;
    anim.duration = 0.4f;
    anim.autoreverses = YES;
    anim.repeatCount = 1;
    anim.timingFunction = [CAMediaTimingFunction
                           functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [anims addObject:anim];
    duration += anim.duration * 2  *anim.repeatCount;
  }
  
  anim = [CABasicAnimation animationWithKeyPath:@"zPosition"];
  // make sure layer is above other layers while animating
  anim.fromValue = [NSNumber numberWithFloat:10.0f];
  anim.toValue = [NSNumber numberWithFloat:10.0f];
  anim.duration = duration;
  [anims addObject:anim];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.duration = duration;
  group.animations = anims;
  
  [layer addAnimation:group forKey:nil];
}

- (void)move:(PlayerDirection *)dir hold:(BOOL)hold {
  BOOL wrap = NO;
  CGPoint pos = CGPointDelta(self.playerPosition, dir.delta);
  
  self.lastMove = [NSDate date];
  
  if (pos.x < 0) {
    pos.x = self.size.width-1;
    wrap = YES;
  }
  if (pos.x >= self.size.width) {
    pos.x = 0;
    wrap = YES;
  }
  if (pos.y < 0) {
    pos.y = self.size.height-1;
    wrap = YES;
  }
  if (pos.y >= self.size.height) {
    pos.y = 0;
    wrap = YES;
  }
  
  [self.playerLayer removeAnimationForKey:@"scratch"];
  
  TileSquare *infront = [self squareAt:pos];
  TileSquareLayer *infrontLayer = [infront topLayer];
  BOOL eat = NO;
  
  self.playerLayer.contents = dir.CGImageStand;
  self.currentDirection = dir;
  
  if ([self tilesquareIsMoveable:infront]) {
    
    // dont allow block push when holding down and moving
    if (hold) {
      return;
    }
    
    TileSquare *obstacle = [self findObstacleFromPos:pos dir:dir];
    TileSquareLayer *obstacleLayer = [obstacle topLayer];
    
    if (obstacleLayer.type == nil) {
      
      CGPoint moveFrom = infrontLayer.layer.position;
      CGPoint outside = CGPointDelta(infrontLayer.layer.position,
                                     CGPointMulti(dir.delta,
                                                  self.size.width *
                                                  self.tileSize.width));
      
      infrontLayer.type = self.typeEmpty;
      infrontLayer.layer.position = outside;
      [infront setTop:self.typeEmpty];
      
      self.statsPushes++;
      
      [self animateLayerPush:infrontLayer.layer
                        from:moveFrom
                          to:outside
                         dir:dir
                       delay:0.0f
                      bounce:0.0f
                      wobble:0.0f
			 end:outside];
      
      [SlippyAudio playIceGlideEffect:[self
                                       distanceDurationFrom:moveFrom
                                       to:outside]];
    } else if (obstacleLayer.type == self.typeBlock ||
               obstacleLayer.type == self.typeScore) {
      
      [obstacle pushLayerWithType:self.typeMoveable layer:infrontLayer.layer];
      TileSquareLayer *topLayer = [obstacle topLayer];
      
      infrontLayer.layer = nil;
      infrontLayer.type = self.typeEmpty;
      if ([infront layerUnderLayer:infrontLayer] != nil) {
        [infront popLayer];
      }
      
      self.statsPushes++;
      
      [self animateLayerPush:topLayer.layer
                        from:infront.layerPosition
                          to:obstacle.layerPosition
                         dir:dir
                       delay:0.0f
                      bounce:0.0f
                      wobble:obstacleLayer.type == self.typeBlock ? 3.0f * self.scale : 0.0f
			 end:topLayer.layer.position];
      
      [SlippyAudio playIceGlideEffect:[self
                                       distanceDurationFrom:infront.layerPosition
                                       to:obstacle.layerPosition]];
      if (obstacleLayer.type == self.typeBlock) {
        [SlippyAudio playIceCollisionBlockEffect:
         [self
          distanceDurationFrom:infront.layerPosition
          to:obstacle.layerPosition]];
      }
      
      if (obstacleLayer.type == self.typeScore) {
        [SlippyAudio playIceCollisionScoreEffect:
         [self
          distanceDurationFrom:infront.layerPosition
          to:obstacle.layerPosition]];
      }
      
    } else if (obstacleLayer.type == self.typeSolid ||
               obstacleLayer.type == self.typeMoveable) {
      
      TileSquare *to = [self squareAt:
                        CGPointDelta(obstacle.position,
                                     CGPointMake(-dir.delta.x,
                                                 -dir.delta.y))];
      TileSquareLayer *toLayer = [to topLayer];
      
      CGPoint moveFrom = infront.layerPosition;
      CGPoint moveTo = to.layerPosition;
      
      if (to != infront) {
        if (toLayer.type == self.typeMoveable) {
          [to pushLayerWithType:self.typeMoveable layer:infrontLayer.layer];
          toLayer = [to topLayer];
        } else {
          toLayer.layer = infrontLayer.layer;
          toLayer.layer.position = moveTo;
          toLayer.type = self.typeMoveable;
        }
        
        infrontLayer.layer = nil;
        infrontLayer.type = self.typeEmpty;
        if ([infront layerUnderLayer:infrontLayer] != nil) {
          [infront popLayer];
        }
      }
      
      self.statsPushes++;
      
      [self animateLayerPush:toLayer.layer
                        from:moveFrom
                          to:moveTo
                         dir:dir
                       delay:0.0f
                      bounce:10.0f * self.scale
                      wobble:0.0f
			 end:moveTo];
      
      [SlippyAudio playIceGlideEffect:[self
                                       distanceDurationFrom:infront.layerPosition
                                       to:obstacle.layerPosition]];
      if (obstacleLayer.type == self.typeSolid) {
        [SlippyAudio playIceCollisionSolidEffect:
         [self
          distanceDurationFrom:infront.layerPosition
          to:obstacle.layerPosition]];
      }
      
      if (obstacleLayer.type == self.typeMoveable) {
        [SlippyAudio playIceCollisionMoveableEffect:
         [self
          distanceDurationFrom:infront.layerPosition
          to:obstacle.layerPosition]];
      }
      
      /*
       if (obstacleLayer.type == self.typeMoveable) {
       [self animateLayerPush:obstacleLayer.layer
       from:obstacleLayer.layer.position
       to:obstacleLayer.layer.position
       dir:dir
       delay:[GameTileView distanceDurationFrom:moveFrom to:moveTo] + 0.1f
       bounce:3.0f
       wobble:0.0f];
       }
       */
    }
    
    [self animatePlayerPush:self.playerLayer direction:dir];
    [self.gameDelegate levelChanged];
    
    return;
    
  } else if ([self tilesquareIsSolid:infront]) {
    return;
  } else if (infrontLayer.type == self.typeScore) {
    id contents = infrontLayer.layer.contents;
    
    infrontLayer.type = self.typeEmpty;
    infrontLayer.layer.contents = nil;
    eat = YES;
    
    [self animateLayerRemove:infrontLayer.layer
                    contents:contents
                       delay:0.2f];
    [SlippyAudio playEatEffect:0.2f];
    
    self.scoresLeft--;
    if (self.scoresLeft == 0) {
      [self.gameDelegate levelCompleted];
      [SlippyAudio playLeveLCompletedEffect:0.2f];
    }
  }
  
  self.statsMoves++;
  
  CGPoint moveFrom = self.playerLayer.position;
  CGPoint moveTo = [self playerPosToPosition:pos];
  self.playerLayer.position = moveTo;
  self.playerPosition = pos;
  
  if (wrap) {
    CGPoint outside1 = CGPointDelta(moveFrom,
                                    CGPointMulti(dir.delta,
                                                 self.tileSize.width * 2.0f));
    CGPoint outside2 = CGPointDelta(moveTo,
                                    CGPointMulti(dir.delta,
                                                 -self.tileSize.width * 2.0f));
    
    [self animatePlayerWalk:self.playerLayer
                       from:moveFrom
                         to:outside1
                  direction:dir
                   duration:0.1f
                      delay:0.0f
                        eat:NO
              animationName:@"wrap1"];
    [self animatePlayerWalk:self.playerLayer
                       from:outside2
                         to:moveTo
                  direction:dir
                   duration:0.1f
                      delay:0.1f
                        eat:eat
              animationName:@"wrap2"];
    
    [SlippyAudio playWarpEffect];
  } else {
    [self animatePlayerWalk:self.playerLayer
                       from:moveFrom
                         to:moveTo
                  direction:dir
                   duration:0.2f
                      delay:0.0f
                        eat:eat
              animationName:@"player"];
    
    [SlippyAudio playWalkEffect];
    
  }
  
  if (self.scoresLeft > 0) {
    [self.gameDelegate levelChanged];
  }
}

- (NSDictionary *)gameState {
  if (self.currentDirection == nil) {
    return nil;
  }
  
  NSMutableDictionary *dstate = [NSMutableDictionary dictionary];
  
  [dstate setObject:[NSNumber numberWithInt:self.playerPosition.x] forKey:@"x"];
  [dstate setObject:[NSNumber numberWithInt:self.playerPosition.y] forKey:@"y"];
  [dstate setObject:self.currentDirection.name forKey:@"direction"];
  [dstate setObject:[NSNumber numberWithInt:self.statsSolveTime]
             forKey:@"solvetime"];
  [dstate setObject:[NSNumber numberWithInt:self.statsPushes]
             forKey:@"pushes"];
  [dstate setObject:[NSNumber numberWithInt:self.statsMoves]
             forKey:@"moves"];
  [dstate setObject:[self tileState] forKey:@"tiles"];  
  
  return dstate;
}

- (BOOL)loadGameState:(NSDictionary *)state validate:(BOOL)validate {
  if (![state isKindOfClass:[NSDictionary class]]) {
    return NO;
  }
  
  // TODO: is used for undo, dont restore solvetime etc
  
  NSNumber *x = [state objectForKey:@"x"];
  NSNumber *y = [state objectForKey:@"y"];
  NSString *direction = [state objectForKey:@"direction"];
  NSNumber *solveTime = [state objectForKey:@"solvetime"];
  NSNumber *pushes = [state objectForKey:@"pushes"];
  NSNumber *moves = [state objectForKey:@"moves"];
  NSArray *tiles = [state objectForKey:@"tiles"];
  
  if (x == nil || y == nil || direction == nil || solveTime == nil ||
      pushes == nil || moves == nil || tiles == nil ||
      ![x isKindOfClass:[NSNumber class]] ||
      ![y isKindOfClass:[NSNumber class]] ||
      ![direction isKindOfClass:[NSString class]] ||
      ![solveTime isKindOfClass:[NSNumber class]] ||
      ![pushes isKindOfClass:[NSNumber class]] ||
      ![moves isKindOfClass:[NSNumber class]]) {
    return NO;
  }
  
  if ([x intValue] < 0 || [x intValue] >= self.size.width ||
      [y intValue] < 0 || [y intValue] >= self.size.height) {
    return NO;
  }
  
  PlayerDirection *dir = nil;
  for (dir in [NSArray arrayWithObjects:
	       self.directionUp,
	       self.directionDown,
	       self.directionLeft,
	       self.directionRight,
	       nil]) {
    if ([dir.name isEqualToString:direction]) {
      break;
    }
  }
  if (dir == nil) {
    return NO;
  }
  
  if (![self loadTileState:tiles validate:validate]) {
    return NO;
  }
  
  if (!validate) {
    self.playerLayer.contents = dir.CGImageStand;
    self.currentDirection = dir;
    CGPoint playerPos = CGPointMake([x intValue], [y intValue]);
    self.playerLayer.position = [self playerPosToPosition:playerPos];
    self.playerPosition = playerPos;
    
    self.statsSolveTime = [solveTime intValue];
    self.statsPushes = [pushes intValue];
    self.statsMoves = [moves intValue];
  }
  
  return YES;
}

- (void)loadGameState:(NSDictionary *)state level:(SlippyLevel *)level{
  [self loadGameState:state validate:NO];
  [self initLevel:level];
  self.disableInput = NO;
}

- (BOOL)validateGameState:(NSDictionary *)state {
  return [self loadGameState:state validate:YES];
}

@end
