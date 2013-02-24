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

#import "Array2D.h"
#import "TileView.h"

// forward declaration
@class TileType;

@protocol TileCombinerDelegate
- (BOOL)isTypeAt:(CGPoint)pos type:(id)type;
@end

@interface TileCombiner : NSObject

@property(nonatomic, retain) UIImage *backgroundImage;
@property(nonatomic, retain) UIImage *backgroundMask;

@property(nonatomic, retain) UIImage *image;
@property(nonatomic, assign) CGSize size;
@property(nonatomic, retain) id type;
@property(nonatomic, assign) id<TileCombinerDelegate> delegate;
@property(nonatomic, retain) NSString *cacheName;

+ (void)memoryWarning;

+ (id)combinerWithImage:(UIImage *)aImage
                   size:(CGSize)aAize
                   type:(id)aType
              cacheName:aCacheName;

- (id)initWithImage:(UIImage *)aImage
               size:(CGSize)aSize
               type:(id)aType
          cacheName:aCacheName;

- (UIImage *)UImageAt:(CGPoint)pos;
- (void)drawInContext:(CGContextRef)context
                  dst:(CGPoint)dst
                   at:(CGPoint)pos;
@end
