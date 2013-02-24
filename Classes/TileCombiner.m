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

#import "TileCombiner.h"
#import "TileView.h"
#import "UIImage+extra.h"


static NSMutableDictionary *cache = nil;

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

typedef struct match_pattern_s {
  BOOL matches[3];
  CGPoint source;
} match_pattern_t;

typedef struct match_patterns_s {
  CGPoint deltas[3];
  match_pattern_t patterns[8];
} match_patterns_t;

typedef struct match_part_s {
  CGPoint dest;
  match_patterns_t patterns;
} match_part_t;

match_part_t match_parts[] = {
  {
    {0, 0}, // upper left
    {
      {{-1, 0}, {-1, -1}, {0, -1}},
      {
        {{NO, NO, NO},    {0, 0}},
        {{NO, NO, YES},   {0, 1}},
        {{NO, YES, NO},   {0, 0}},
        {{NO, YES, YES},  {0, 1}},
        {{YES, NO, NO},   {1, 0}},
        {{YES, NO, YES},  {4, 4}},
        {{YES, YES, NO},  {1, 0}},
        {{YES, YES, YES}, {6, 0}}
      }
    }
  },
  {
    {1, 0}, // upper right
    {
      {{1, 0}, {1, -1}, {0, -1}},
      {
        {{NO, NO, NO},    {5, 0}},
        {{NO, NO, YES},   {5, 1}},
        {{NO, YES, NO},   {5, 0}},
        {{NO, YES, YES},  {5, 1}},
        {{YES, NO, NO},   {1, 0}},
        {{YES, NO, YES},  {1, 4}},
        {{YES, YES, NO},  {1, 0}},
        {{YES, YES, YES}, {6, 0}}
      }
    }
  },
  {
    {0, 1}, // lower left
    {
      {{-1, 0}, {-1, 1}, {0, 1}},
      {
        {{NO, NO, NO},    {0, 5}},
        {{NO, NO, YES},   {0, 1}},
        {{NO, YES, NO},   {0, 5}},
        {{NO, YES, YES},  {0, 1}},
        {{YES, NO, NO},   {1, 5}},
        {{YES, NO, YES},  {4, 1}},
        {{YES, YES, NO},  {1, 5}},
        {{YES, YES, YES}, {6, 0}}
      }
    }
  },
  {
    {1, 1}, // lower right
    {
      {{1, 0}, {1, 1}, {0, 1}},
      {
        {{NO, NO, NO},    {5, 5}},
        {{NO, NO, YES},   {5, 1}},
        {{NO, YES, NO},   {5, 5}},
        {{NO, YES, YES},  {5, 1}},
        {{YES, NO, NO},   {1, 5}},
        {{YES, NO, YES},  {1, 1}},
        {{YES, YES, NO},  {1, 5}},
        {{YES, YES, YES}, {6, 0}}
      }
    }
  }
};

@implementation TileCombiner

@synthesize backgroundImage;
@synthesize backgroundMask;

@synthesize image;
@synthesize size;
@synthesize type;
@synthesize delegate;
@synthesize cacheName;


+ (void)initialize {
  @synchronized(self) {
    if (cache == nil) {
      cache = [[NSMutableDictionary alloc] init];
    }
  }
}

+ (void)memoryWarning {
  @synchronized(cache) {
    [cache removeAllObjects];
  }
}

+ (id)combinerWithImage:(UIImage *)aImage
                   size:(CGSize)aSize
                   type:(id)aType
              cacheName:(NSString *)aCacheName {
  return [[[TileCombiner alloc] initWithImage:aImage
                                         size:aSize
                                         type:aType
                                    cacheName:aCacheName]
          autorelease];
}

- (id)initWithImage:(UIImage *)aImage
               size:(CGSize)aSize
               type:(id)aType
          cacheName:(NSString *)aCacheName {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  
  self.image = aImage;
  self.size = aSize;
  self.type = aType;
  self.cacheName = aCacheName;
  
  return self;
}

- (void)dealloc {
  self.image = nil;
  self.type = nil;
  self.cacheName = nil;  
  self.backgroundImage = nil;
  self.backgroundMask = nil;
  
  [super dealloc];
}

- (CGPoint)findPattern:(CGPoint)pos
                  type:(id)aType
              patterns:(match_patterns_t *)mp {
  for (int i = 0; i < 8; i++) {
    BOOL allMatch = YES;
    
    for (int j = 0; j < 3; j++) {
      BOOL match = [self.delegate isTypeAt:CGPointDelta(pos, mp->deltas[j])
                                      type:self.type];
      
      if (mp->patterns[i].matches[j] != match) {
        allMatch = NO;
        break;
      }
    }
    
    if (allMatch) {
      return mp->patterns[i].source;
    }
  }
  
  return CGPointMake(0, 0);
}

- (UIImage *)_combineMatchAt:(CGPoint)pos
                  contextDst:(CGPoint)contextDst
                       image:(UIImage *)combinerImage {
  UIImage *combined;
  CGContextRef combineContext = _CGBitmapContextCreate(self.size);
  
  for (int i = 0; i < 4; i++) {
    match_part_t *mp = &match_parts[i];
    
    CGPoint src = [self findPattern:pos
                               type:self.type
                           patterns:&mp->patterns];
    [combinerImage
     drawInContext:combineContext
     src:CGRectMake(src.x * (self.size.width / 2),
                    src.y * (self.size.height / 2),
                    self.size.width / 2,
                    self.size.height / 2)
     dst:CGRectMake(mp->dest.x * (self.size.width / 2),
                    mp->dest.y * (self.size.height / 2),
                    self.size.width / 2,
                    self.size.height / 2)];
  }
  
  combined = _CGUIImageFromContext(combineContext);
  _CGContextRelease(combineContext);
  
  return combined;
}

- (void)combineMatchAt:(CGPoint)pos
               context:(CGContextRef)context
            contextDst:(CGPoint)contextDst {
  UIImage *combined;
  
  @synchronized(cache) {
    NSMutableDictionary *typeCache = [cache objectForKey:self.cacheName];
    if (typeCache == nil) {
      typeCache = [NSMutableDictionary dictionary];
      [cache setObject:typeCache forKey:self.cacheName];
    }
    
    NSMutableArray *key = [NSMutableArray arrayWithCapacity:8];
    for (int i = 0; i < 8; i++) {
      [key addObject:[NSNumber numberWithBool:
                      [self.delegate isTypeAt:CGPointDelta(pos, directions[i])
                                         type:self.type]]];
    }
    
    combined = [typeCache objectForKey:key];
    if (combined == nil) {
      
      combined = [self _combineMatchAt:pos
                            contextDst:contextDst
                                 image:self.image];
      
      [typeCache setObject:combined forKey:key];
    }
    
    [combined drawInContext:context
                        src:CGRectMake(0,
                                       0,
                                       self.size.width,
                                       self.size.height)
                        dst:CGRectMake(contextDst.x,
                                       contextDst.y,
                                       self.size.width,
                                       self.size.height)];
    
    if (self.backgroundImage != nil) {
      UIImage *mask = [self _combineMatchAt:pos
                                 contextDst:contextDst
                                      image:self.backgroundMask];
      
      UIImage *part = [self.backgroundImage
                       UImageFromRect:CGRectMake(pos.x * self.size.width,
                                                 pos.y * self.size.height,
                                                 self.size.width,
                                                 self.size.height)];
      
      UIImage *masked = [mask maskWithImage:part];
      
      [masked drawInContext:context
                        src:CGRectMake(0,
                                       0,
                                       self.size.width,
                                       self.size.height)
                        dst:CGRectMake(contextDst.x,
				       contextDst.y,
                                       self.size.width,
                                       self.size.height)];
    }
  }
}

- (UIImage *)UImageAt:(CGPoint)pos {
  CGContextRef context = _CGBitmapContextCreate(self.size);
  [self combineMatchAt:pos context:context contextDst:CGPointMake(0, 0)];
  UIImage *new = _CGUIImageFromContext(context);
  _CGContextRelease(context);
  
  return new;
}

- (void)drawInContext:(CGContextRef)context
                  dst:(CGPoint)dst
                   at:(CGPoint)pos {
  [self combineMatchAt:pos context:context contextDst:dst];
}

@end
