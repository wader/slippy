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

#import "LevelPreviewView.h"
#import "TileCombiner.h"
#import "UIImage+extra.h"

static NSOperationQueue* operationQueue = nil;
static NSMutableDictionary *previewCache = nil;

@interface LevelPreviewView ()

@property(nonatomic, retain) SlippyLevel *level;
@property(nonatomic, assign) CGSize tileSize;
@property(nonatomic, retain) TileType *type_empty;
@property(nonatomic, retain) TileType *type_score;
@property(nonatomic, retain) TileType *type_block;
@property(nonatomic, retain) TileType *type_solid;
@property(nonatomic, retain) TileType *type_moveable;
@property(nonatomic, retain) TileType *type_player;

- (void)renderStart;

@end


@implementation LevelPreviewView

@synthesize level;
@synthesize tileSize;
@synthesize type_empty;
@synthesize type_score;
@synthesize type_block;
@synthesize type_solid;
@synthesize type_moveable;
@synthesize type_player;


+ (void)initialize {
  @synchronized(self) {
    if (operationQueue == nil) {
      operationQueue = [[NSOperationQueue alloc] init];
    }
    if (previewCache == nil) {
      previewCache = [[NSMutableDictionary alloc] init]; 
    }
  }
}

+ (void)memoryWarning {
  [previewCache removeAllObjects];
}

- (id)initWithFrame:(CGRect)aRect level:(SlippyLevel *)aLevel {
  self = [super initWithFrame:aRect];
  if (self == nil) {
    return nil;
  }
  
  self.level = aLevel;
  if (_DeviceModel == MiscDeviceModelIPad) {
    self.tileSize = CGSizeMake(16, 16);
  } else {
    self.tileSize = CGSizeMake(8, 8);
  }
  
  self.bounds = CGRectMake(0, 0,
			   level.width * self.tileSize.width,
			   level.height * self.tileSize.height);
  
  self.type_empty = [[[TileType alloc] init] autorelease];
  self.type_empty.image = nil;
  self.type_score = [[[TileType alloc] init] autorelease];
  self.type_score.image = [I.images.tiles.preview.score
                           UImageFromRect:CGRectMake(0, 0,
                                                     tileSize.width,
                                                     tileSize.height)];
  self.type_block = [[[TileType alloc] init] autorelease];
  self.type_block.image = I.images.tiles.preview.block;
  self.type_block.combiner = [TileCombiner
                              combinerWithImage:self.type_block.image
                              size:self.tileSize
                              type:self.type_block
                              cacheName:P.images.tiles.preview.blockPng];
  self.type_block.combiner.delegate = self;
  self.type_solid = [[[TileType alloc] init] autorelease];
  self.type_solid.image = I.images.tiles.preview.solid;
  self.type_solid.combiner = [TileCombiner
                              combinerWithImage:self.type_solid.image
                              size:self.tileSize
                              type:self.type_solid
                              cacheName:P.images.tiles.preview.solidPng];
  self.type_solid.combiner.delegate = self;
  self.type_moveable = [[[TileType alloc] init] autorelease];
  self.type_moveable.image = I.images.tiles.preview.moveable;
  self.type_player = [[[TileType alloc] init] autorelease];
  self.type_player.image = I.images.tiles.preview.player;
  
  [self renderStart];
  
  return self;
} 

- (void)dealloc {
  self.level = nil;
  self.type_empty = nil;
  self.type_score = nil;
  // TODO: combiner delegate
  self.type_block.combiner = nil;
  self.type_block = nil;
  self.type_solid.combiner = nil;
  self.type_solid = nil;
  self.type_moveable = nil;
  self.type_player = nil;
  self.layer.contents = nil;
  
  [super dealloc];
}

- (TileType *)charToType:(char)c {
  switch (c) {
    case ' ': return self.type_empty; break;
    case '$': return self.type_score; break;
    case '#': return self.type_block; break;
    case 'O': return self.type_solid; break;
    case 'M': return self.type_moveable; break;
    case 'P': return self.type_player; break;
  }
  
  return self.type_empty;
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

- (UIImage *)renderPreview {
  CGContextRef context = _CGBitmapContextCreate(self.layer.bounds.size);
  
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
  
  UIImage *preview = _CGUIImageFromContext(context);
  _CGContextRelease(context);
  
  return preview;
}

- (void)updatePreviewImage:(UIImage *)image fromCache:(BOOL)fromCache {
  self.layer.contents = (id)image.CGImage;
  
  if (fromCache) {
    return;
  }
  
  self.layer.opaque = 0.0f;
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
  anim.fromValue = [NSNumber numberWithFloat:0.0f];
  anim.toValue = [NSNumber numberWithFloat:1.0f];
  anim.duration = 0.3f;
  anim.timingFunction = [CAMediaTimingFunction
			 functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.layer addAnimation:anim forKey:nil];
}

- (void)renderDone:(UIImage *)image {
  [previewCache setObject:image forKey:self.level.id_];
  [self updatePreviewImage:image fromCache:NO];
}

- (void)renderTask:(id)data {
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  
  UIImage *preview = [self renderPreview];
  [self performSelectorOnMainThread:@selector(renderDone:)
                         withObject:preview
                      waitUntilDone:NO];
  
  
  [pool release];
}

- (void)rerender {
  [previewCache removeObjectForKey:self.level.id_];
  [self renderStart];
}

- (void)renderStart {
  UIImage *image = [previewCache objectForKey:self.level.id_];
  if (image != nil) {
    [self updatePreviewImage:image fromCache:YES];
    return;
  } 
  
  [operationQueue addOperation:[[[NSInvocationOperation alloc]
                                 initWithTarget:self
                                 selector:@selector(renderTask:)
                                 object:nil]
                                autorelease]];
}

@end
