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
#import "TileCombiner.h"

@implementation SlippyTileView

@synthesize typeEmpty;
@synthesize typeScore;
@synthesize typeBlock;
@synthesize typeSolid;
@synthesize typeMoveable;
@synthesize typePlayer;

- (id)initWithFrame:(CGRect)aRect skipFixed:(BOOL)skipFixed {
  CGSize tileSize;
  CGFloat displaceAbove;
  if (_DeviceModel == MiscDeviceModelIPad) {
    tileSize = CGSizeMake(64, 74);
    displaceAbove = 10;
  } else {
    tileSize = CGSizeMake(30, 32);
    displaceAbove = 5;
  }
  
  self = [super initWithFrame:aRect
                         size:CGSizeMake(SLIPPY_LEVEL_WIDTH,
                                         SLIPPY_LEVEL_HEIGHT)
                     tileSize:tileSize];
  if (self == nil) {
    return nil;
  }
  
  self.typeEmpty = [[[TileType alloc] init] autorelease];
  
  self.typeScore = [[[TileType alloc] init] autorelease];
  self.typeScore.image = I.images.tiles.normal.score;
  self.typeScore.variantSize = self.tileSize;
  
  self.typeBlock = [[[TileType alloc] init] autorelease];
  self.typeBlock.displaceAbove = CGPointMake(0, displaceAbove);
  if (!skipFixed) {
    self.typeBlock.image = I.images.tiles.normal.block;
    self.typeBlock.combiner = [TileCombiner
			       combinerWithImage:self.typeBlock.image
			       size:self.tileSize
			       type:self.typeBlock
			       cacheName:P.images.tiles.normal.blockPng];
    self.typeBlock.combiner.backgroundImage = I.images.water;
    self.typeBlock.combiner.backgroundMask = I.images.tiles.normal.blockMask;
    self.typeBlock.combiner.delegate = self;
  }
  
  self.typeSolid = [[[TileType alloc] init] autorelease];
  if (!skipFixed) {
    self.typeSolid.image = I.images.tiles.normal.solid;
    self.typeSolid.combiner = [TileCombiner
			       combinerWithImage:self.typeSolid.image
			       size:self.tileSize
			       type:self.typeSolid
			       cacheName:P.images.tiles.normal.solidPng];
    self.typeSolid.combiner.delegate = self;
  }
  
  self.typeMoveable = [[[TileType alloc] init] autorelease];
  self.typeMoveable.image = I.images.tiles.normal.moveable;
  
  self.typePlayer = [[[TileType alloc] init] autorelease];
  self.typePlayer.image = I.images.tiles.normal.player;
  
  return self;
}  

- (void)dealloc {
  self.typeEmpty = nil;
  self.typeScore = nil;
  self.typeBlock.combiner = nil;
  self.typeBlock = nil;
  self.typeSolid.combiner = nil;
  self.typeSolid = nil;
  self.typeMoveable = nil;
  self.typePlayer = nil;
  
  [super dealloc];
}

- (BOOL)isTypeAt:(CGPoint)pos type:(id)type {
  TileSquare *s = [self squareAt:pos];
  
  if (s == nil) {
    return NO;
  }
  
  for (TileSquareLayer *squareLayer in s.layers) {
    if (squareLayer.type == type) {
      return YES;
    }
  }
  
  return NO;
}

- (TileType *)charToType:(char)c {
  switch (c) {
    case ' ': return self.typeEmpty; break;
    case '$': return self.typeScore; break;
    case '#': return self.typeBlock; break;
    case 'O': return self.typeSolid; break;
    case 'M': return self.typeMoveable; break;
    case 'P': return self.typePlayer; break;
  }
  
  return self.typeEmpty;
}

- (char)typeToChar:(TileType *)type {
  if (type == self.typeEmpty) {
    return ' ';
  } else if (type == self.typeScore) {
    return '$';
  } else if (type == self.typeBlock) {
    return '#';
  } else if (type == self.typeSolid) {
    return 'O';
  } else if (type == self.typeMoveable) {
    return 'M';
  } else if (type == self.typePlayer) {
    return 'P';
  }
  
  return ' ';
}

- (void)loadLevel:(SlippyLevel *)level {
  if (level == nil) {
    return;
  }
  
  for (int y = 0; y < self.squares.size.height; y++) {
    for (int x = 0; x < self.squares.size.width; x++) {
      TileSquare *square = [self squareAt:CGPointMake(x, y)];
      
      [square flush];
      
      TileType *type = [self charToType:
			[level.data characterAtIndex:
			 y*self.squares.size.width+x]];
      
      [square pushLayerWithType:type];
    }
  }
  
  [self updateAll];
}

- (NSString *)levelData {
  NSMutableString *data = [NSMutableString string];
  
  for (int y = 0; y < self.squares.size.height; y++) {
    for (int x = 0; x < self.squares.size.width; x++) {
      [data appendFormat:@"%c",
       [self typeToChar:[[self squareAt:CGPointMake(x, y)] topType]]];
    }
  }
  
  return [NSString stringWithString:data];
}

- (NSArray *)tileState {
  NSMutableArray *asquares = [NSMutableArray array];
  
  for (int y = 0; y < self.squares.size.height; y++) {
    for (int x = 0; x < self.squares.size.width; x++) {
      TileSquare *square = [self squareAt:CGPointMake(x, y)];
      
      NSMutableArray *layers = [NSMutableArray array];
      for (TileSquareLayer *layer in square.layers) {
        [layers addObject:[NSString stringWithFormat:@"%c",
                           [self typeToChar:layer.type]]];
      }
      
      NSMutableDictionary *dsquare = [NSMutableDictionary dictionary];
      [dsquare setObject:[NSNumber numberWithInt:x] forKey:@"x"];
      [dsquare setObject:[NSNumber numberWithInt:y] forKey:@"y"];
      [dsquare setObject:layers forKey:@"layers"];
      
      [asquares addObject:dsquare];
    }
  }
  
  return asquares;
}

- (BOOL)loadTileState:(NSArray *)squares validate:(BOOL)validate {
  if (![squares isKindOfClass:[NSArray class]]) {
    return NO;
  }
  
  for (NSDictionary *dsquare in squares) {
    if (![dsquare isKindOfClass:[NSDictionary class]]) {
      return NO;
    }
    
    NSNumber *x = [dsquare objectForKey:@"x"];
    NSNumber *y = [dsquare objectForKey:@"y"];
    NSArray *layers = [dsquare objectForKey:@"layers"];
    
    if (x == nil || y == nil || layers == nil ||
        ![x isKindOfClass:[NSNumber class]] ||
        ![y isKindOfClass:[NSNumber class]] ||
        ![layers isKindOfClass:[NSArray class]]) {
      return NO;
    }
    
    TileSquare *square = [self squareAt:CGPointMake([x intValue],
						    [y intValue])];
    if (square == nil) {
      return NO;
    }
    
    if (!validate) {
      [square flush];
    }
    
    for (NSString *stype in layers) {
      if (![stype isKindOfClass:[NSString class]] ||
          [stype length] != 1) {
        return NO;
      }
      
      TileType *type = [self charToType:[stype characterAtIndex:0]];
      if (type == nil) {
        return NO;
      }
      
      if (!validate) {
        [square pushLayerWithType:type];
      }
    }
  }
  
  if (!validate) {
    [self updateAll];
  }
  
  return YES;
}

@end
