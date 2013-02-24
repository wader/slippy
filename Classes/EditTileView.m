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

#import "EditTileView.h"

@interface EditTileView ()

@property(nonatomic, assign) BOOL hasCalledDelegate;

@end


@implementation EditTileView

@synthesize currentType;
@synthesize editDelegate;
@synthesize hasCalledDelegate;

- (void)loadLevel:(SlippyLevel *)level {
  [super loadLevel:level];
}

- (void)setType:(TileType *)type {
  self.currentType = type;
}

- (void)setSquareCurrentTypeAt:(CGPoint)pos {
  TileSquare *square = [self squareAt:
                        CGPointMake(pos.x / self.tileSize.width,
                                    pos.y / self.tileSize.height)];
  if (square == nil) {
    return;
  }
  
  TileSquareLayer *topLayer = [square topLayer];
  if (topLayer.type == self.currentType) {
    return;
  }
  
  if ((self.currentType == self.typePlayer ||
      self.currentType == self.typeMoveable ||
      self.currentType == self.typeScore) &&
      topLayer.type != self.typeEmpty) {
    return;
  }
  
  if (self.currentType == self.typePlayer) {
    TileSquare *currentPlayer = [self findType:self.typePlayer];
    if (currentPlayer != nil) {
      [currentPlayer setTop:self.typeEmpty];
      [currentPlayer updateLayers];
    }
  }
  
  if (self.editDelegate != nil && !self.hasCalledDelegate) {
    [self.editDelegate beforeChange];
    self.hasCalledDelegate = YES;
  }

  [topLayer setType:self.currentType];
  [square updateLayers];
  [self updateAt:square.position];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([touches count] == 1) {
    for (UITouch *touch in touches) {
      [self setSquareCurrentTypeAt:[touch locationInView:self]];
    }
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([touches count] == 1) {
    for (UITouch *touch in touches) {
      [self setSquareCurrentTypeAt:[touch locationInView:self]];
    }
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  self.hasCalledDelegate = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  self.hasCalledDelegate = NO;
}

@end
