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

#import "SlippyTileView.h"

@interface PlayerDirection : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) CGPoint delta;
@property(nonatomic, retain) id CGImageStand;
@property(nonatomic, retain) id CGImageBlink;
@property(nonatomic, retain) id CGImageScratch1;
@property(nonatomic, retain) id CGImageScratch2;
@property(nonatomic, retain) id CGImageScratch3;
@property(nonatomic, retain) id CGImageWalk1;
@property(nonatomic, retain) id CGImageWalk2;
@property(nonatomic, retain) id CGImagePush1;
@property(nonatomic, retain) id CGImagePush2;
@property(nonatomic, retain) id CGImageEat1;
@property(nonatomic, retain) id CGImageEat2;

+ (id)playerDirectionWithName:(NSString *)name
                        delta:(CGPoint)delta
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
                         eat2:(UIImage *)eat2;

- (id)initWithName:(NSString *)name
             delta:(CGPoint)delta
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
              eat2:(UIImage *)eat2;

@end

@protocol GameTileViewDelegate
- (void)levelCompleted;
- (void)levelChanged;
@end

@interface GameTileView : SlippyTileView

@property(nonatomic, assign) CGPoint playerPosition;
@property(nonatomic, retain) CALayer *playerLayer;
@property(nonatomic, retain) CALayer *fixedLayer;
@property(nonatomic, retain) PlayerDirection *currentDirection;

@property(nonatomic, retain) PlayerDirection *directionDown;
@property(nonatomic, retain) PlayerDirection *directionUp;
@property(nonatomic, retain) PlayerDirection *directionRight;
@property(nonatomic, retain) PlayerDirection *directionLeft;

@property(nonatomic, assign) id<GameTileViewDelegate> gameDelegate;

@property(nonatomic, assign) BOOL disableInput;
@property(nonatomic, assign) int scoresLeft;

@property(nonatomic, retain) NSTimer *actionTimer;

@property(nonatomic, assign) NSUInteger statsSolveTime;
@property(nonatomic, assign) NSUInteger statsPushes;
@property(nonatomic, assign) NSUInteger statsMoves;

@property(nonatomic, retain) NSDate *lastMove;

@property(nonatomic, assign) CGFloat scale;

- (void)move:(PlayerDirection *)dir hold:(BOOL)hold;
- (void)stop;
- (NSDictionary *)gameState;
- (void)loadGameState:(NSDictionary *)state level:(SlippyLevel *)level;
- (BOOL)validateGameState:(NSDictionary *)state;

@end
