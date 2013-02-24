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

#import "TileView.h"
#import "UIImage+extra.h"
#import "NSArray+random.h"


static CGPoint directions[8] = {
  {0, -1},
  {1, -1},
  {1, 0},
  {1, 1},
  {0, 1},
  {-1, 1},
  {-1, 0},
  {-1, -1}
};


@implementation TileType

@synthesize image;
@synthesize combiner;
@synthesize variantSize;
@synthesize displaceAbove;

- (void)dealloc {
  self.image = nil;
  self.combiner = nil;
  
  [super dealloc];
}

- (UIImage *)imageAt:(CGPoint)pos random:(BOOL)random {
  if (self.combiner == nil) {
    if (self.variantSize.width != 0) {
      unsigned int i;
      
      if (random) {
        i = arc4random();
      } else {
        i = (int)(pos.x * 234231 + pos.y);
      }
      
      i %= (int)(self.image.size.height / self.variantSize.height);
      
      return [self.image
              UImageFromRect:CGRectMake(0,
                                        i * self.variantSize.height,
                                        self.variantSize.width,
                                        self.variantSize.height)];
    } else {
      return self.image;
    }
  } else {
    return [self.combiner UImageAt:pos];
  }
  
}

- (UIImage *)imageAt:(CGPoint)pos {
  return [self imageAt:pos random:NO];
}

@end

@implementation TileSquareLayer

@synthesize layer;
@synthesize type;

- (void)dealloc {
  self.layer = nil;
  self.type = nil;
  
  [super dealloc];
}

@end


@implementation TileSquare

@synthesize layer;
@synthesize layerPosition;
@synthesize layers;
@synthesize position;

- (TileSquareLayer *)topLayer {
  if ([self.layers count] > 0) {
    return [self.layers objectAtIndex:[self.layers count] - 1];
  } else {
    return nil;
  }
}

- (TileType *)topType {
  TileSquareLayer *top = [self topLayer];
  if (top != nil) {
    return top.type;
  } else {
    return nil;
  }
}

- (TileSquareLayer *)layerUnderLayer:(TileSquareLayer *)over {
  NSUInteger i = [self.layers indexOfObject:over];
  if (i == NSNotFound || i == 0) {
    return nil;
  }
  
  return [self.layers objectAtIndex:i - 1];
}

- (void)updateLayers {
  for (TileSquareLayer *squareLayer in self.layers) {
    UIImage *image = [squareLayer.type imageAt:self.position];
    if (image == nil) {
      if (squareLayer.layer != nil) {
	[squareLayer.layer removeFromSuperlayer];
	squareLayer.layer = nil;
      }
    } else {
      if (squareLayer.layer == nil) {
	TileSquareLayer *below = [self layerUnderLayer:squareLayer];
	squareLayer.layer = [[[NoAnimationLayer alloc] init] autorelease];
	squareLayer.layer.position = CGPointDelta(self.layerPosition,
					  below ? below.type.displaceAbove : CGPointMake(0, 0));
	squareLayer.layer.zPosition = [self.layers count] - 1;
	[self.layer addSublayer:squareLayer.layer];
      }
      
      squareLayer.layer.contents = (id)image.CGImage;
      squareLayer.layer.bounds = CGRectMake(0, 0,
                                            image.size.width, image.size.height);
    }
  }
}

- (void)setTop:(TileType *)type {
  [self topLayer].type = type;
}

- (void)pushLayerWithType:(TileType *)type layer:(NoAnimationLayer *)aLayer {
  TileSquareLayer *below = [self topLayer];
  TileSquareLayer *top = [[[TileSquareLayer alloc] init] autorelease];
  
  top.type = type;
  if (aLayer != nil) {
    top.layer = aLayer;
    top.layer.position = CGPointDelta(self.layerPosition,
				      below ? below.type.displaceAbove : CGPointMake(0, 0));
    top.layer.zPosition = [self.layers count];
  }
  
  [self.layers addObject:top];
}

- (void)pushLayerWithType:(TileType *)type {
  NoAnimationLayer *aLayer = nil;
  
  if (type.image != nil) {
    aLayer = [[[NoAnimationLayer alloc] init] autorelease];
    [self.layer addSublayer:aLayer];
  }
  
  [self pushLayerWithType:type layer:aLayer];
}

- (void)popLayer {
  if ([self.layers count] == 0) {
    return;
  }
  
  TileSquareLayer *top = [self topLayer];
  if (top.layer != nil) {
    [top.layer removeFromSuperlayer];
  }
  [self.layers removeObject:top];
}

- (void)flush {
  while ([self.layers count] > 0) {
    [self popLayer];
  }
}

- (void)dealloc {
  self.layer = nil;
  self.layers = nil;
  
  [super dealloc];
}

@end

@implementation TileView

@synthesize size;
@synthesize tileSize;
@synthesize squares;
@synthesize offset;

- (id)initWithFrame:(CGRect)aRect
               size:(CGSize)aSize
           tileSize:(CGSize)aTileSize {
  self = [super initWithFrame:aRect];
  if (self == nil) {
    return nil;
  }
  
  self.offset = CGPointMake((int)((aRect.size.width - (aTileSize.width * aSize.width)) / 2),
			    (int)((aRect.size.height - (aTileSize.height * aSize.height)) / 2));
  
  self.squares = [Array2D arrayWithSize:aSize];
  self.size = aSize;
  self.tileSize = aTileSize;
  
  for (int x = 0; x < aSize.width; x++) {
    for (int y = 0; y < aSize.height; y++) {
      TileSquare *s = [[[TileSquare alloc] init] autorelease];
      s.layer = self.layer;
      s.layers = [NSMutableArray array];
      s.position = CGPointMake(x, y);
      s.layerPosition = CGPointMake(self.offset.x + x * tileSize.width + tileSize.width / 2,
                                    self.offset.y + y * tileSize.height + tileSize.height / 2);
      [self.squares setObject:s atX:x y:y];
    }
  }
  
  return self;
}

- (TileSquare *)squareAt:(CGPoint)pos {
  if (pos.x < 0 || pos.x >= (int)self.size.width ||
      pos.y < 0 || pos.y >= (int)self.size.height) {
    return nil;
  }
  
  return [self.squares objectAt:pos];
}

- (void)updateAt:(CGPoint)pos {
  for (int i = 0; i < 8; i++) {
    CGPoint dpos = CGPointDelta(pos, directions[i]);
    TileSquare *s = [self squareAt:dpos];
    if (s == nil || [s topType] == nil) {
      continue;
    }
    
    [s updateLayers];
  }
}

- (void)updateAll {
  for (int x = 0; x < self.squares.size.width; x++) {
    for (int y = 0; y < self.squares.size.height; y++) {
      CGPoint pos = CGPointMake(x, y);
      [[self.squares objectAt:pos] updateLayers];
    }
  } 
}

- (TileSquare *)findType:(TileType *)type {
  for (int x = 0; x < self.squares.size.width; x++) {
    for (int y = 0; y < self.squares.size.height; y++) {
      TileSquare *square = [self.squares objectAt:CGPointMake(x, y)];
      if (square != nil && [square topType] == type) {
        return square;
      }
    }
  }
  
  return nil;
}

- (TileSquare *)findRandomType:(TileType *)type {
  NSMutableArray *hits = [NSMutableArray array];
  
  for (int x = 0; x < self.squares.size.width; x++) {
    for (int y = 0; y < self.squares.size.height; y++) {
      TileSquare *square = [self.squares objectAt:CGPointMake(x, y)];
      if (square != nil && [square topType] == type) {
        [hits addObject:square];
      }
    }
  }
  
  return [hits randomObject];
}

- (int)countType:(TileType *)type {
  int count = 0;
  
  for (int x = 0; x < self.squares.size.width; x++) {
    for (int y = 0; y < self.squares.size.height; y++) {
      if ([[self.squares objectAt:CGPointMake(x, y)] topType] == type)
        count++;
    }
  }
  
  return count;
}

- (void)dealloc {
  self.squares = nil;
  
  [super dealloc];
}

@end
