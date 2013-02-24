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

#import "LevelFixedView.h"
#import "TileCombiner.h"
#import "UIImage+extra.h"


@interface LevelFixedView ()

@property(nonatomic, retain) SlippyLevel *level;
@property(nonatomic, assign) CGSize tileSize;
@property(nonatomic, retain) TileType *typeEmpty;
@property(nonatomic, retain) TileType *typeBlock;
@property(nonatomic, retain) TileType *typeSolid;


@end


@implementation LevelFixedView

@synthesize level;
@synthesize tileSize;
@synthesize typeEmpty;
@synthesize typeBlock;
@synthesize typeSolid;

- (id)initWithLevel:(SlippyLevel *)aLevel {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  
  self.level = aLevel;
  if (_DeviceModel == MiscDeviceModelIPad) {
    self.tileSize = CGSizeMake(64, 74);
  } else {
    self.tileSize = CGSizeMake(30, 32);
  }
  
  self.typeEmpty = [[[TileType alloc] init] autorelease];
  self.typeEmpty.image = nil;
  
  self.typeBlock = [[[TileType alloc] init] autorelease];
  self.typeBlock.image = I.images.tiles.normal.block;
  self.typeBlock.combiner = [TileCombiner
                             combinerWithImage:self.typeBlock.image
                             size:self.tileSize
                             type:self.typeBlock
                             cacheName:P.images.tiles.normal.blockPng];
  self.typeBlock.combiner.backgroundImage = I.images.water;
  self.typeBlock.combiner.backgroundMask = I.images.tiles.normal.blockMask;
  self.typeBlock.combiner.delegate = self;
  
  self.typeSolid = [[[TileType alloc] init] autorelease];
  self.typeSolid.image = I.images.tiles.normal.solid;
  self.typeSolid.combiner = [TileCombiner
			     combinerWithImage:self.typeSolid.image
			     size:self.tileSize
			     type:self.typeSolid
			     cacheName:P.images.tiles.normal.solidPng];
  self.typeSolid.combiner.delegate = self;
  
  return self;
} 

- (void)dealloc {
  self.level = nil;
  self.typeEmpty = nil;
  // TODO: combiner delegate
  self.typeBlock.combiner = nil;
  self.typeBlock = nil;
  self.typeSolid.combiner = nil;
  self.typeSolid = nil;
  
  [super dealloc];
}

- (TileType *)charToType:(char)c {
  switch (c) {
    case ' ': return self.typeEmpty; break;
    case '$': return self.typeEmpty; break;
    case '#': return self.typeBlock; break;
    case 'O': return self.typeSolid; break;
    case 'M': return self.typeEmpty; break;
    case 'P': return self.typeEmpty; break;
  }
  
  return self.typeEmpty;
}

- (TileType *)typeAt:(CGPoint)pos {
  if (pos.x < 0 || pos.x >= self.level.width ||
      pos.y < 0 || pos.y >= self.level.height) {
    return nil;
  }
  id t = [self charToType:
          [self.level.data characterAtIndex:pos.y*self.level.width+pos.x]];
  
  return t;
}

- (BOOL)isTypeAt:(CGPoint)pos type:(id)type {
  return [self typeAt:pos] == type;
}

- (UIImage *)render {
  CGContextRef context = _CGBitmapContextCreate(CGSizeMake(self.level.width * self.tileSize.width,
							   self.level.height * self.tileSize.height));
  
  for (int y = 0; y < self.level.height; y++) {
    for (int x = 0; x < self.level.width; x++) {
      CGPoint pos = CGPointMake(x, y);
      TileType *type = [self typeAt:pos];
      
      if (type.combiner == nil) {
        [type.image
         drawInContext:context
         src:CGRectMake(0, 0,
                        type.image.size.width,
                        type.image.size.height)
         dst:CGRectMake(x * self.tileSize.width,
                        y * self.tileSize.height,
                        type.image.size.width,
                        type.image.size.height)];
      } else  {
        [type.combiner
         drawInContext:context
         dst:CGPointMake(x * self.tileSize.width,
                         y * self.tileSize.height)
         at:pos];
      }
    }
  }
  
  UIImage *image = _CGUIImageFromContext(context);
  _CGContextRelease(context);
  
  return image;
}

@end
