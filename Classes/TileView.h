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
#import "NoAnimationLayer.h"
#import "TileCombiner.h"

@class TileCombiner;

@interface TileType : NSObject

@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) TileCombiner *combiner;
@property(nonatomic, assign) CGSize variantSize;
@property(nonatomic, assign) CGPoint displaceAbove;

- (UIImage *)imageAt:(CGPoint)pos random:(BOOL)random;
- (UIImage *)imageAt:(CGPoint)pos;

@end

@interface TileSquareLayer : NSObject

@property(nonatomic, retain) NoAnimationLayer *layer;
@property(nonatomic, retain) TileType *type;

@end


@interface TileSquare : NSObject

@property(nonatomic, retain) CALayer *layer;
@property(nonatomic, assign) CGPoint layerPosition;
@property(nonatomic, retain) NSMutableArray *layers;
@property(nonatomic, assign) CGPoint position;

- (TileSquareLayer *)topLayer;
- (TileType *)topType;
- (TileSquareLayer *)layerUnderLayer:(TileSquareLayer *)over;
- (void)updateLayers;
- (void)setTop:(TileType *)type;
- (void)pushLayerWithType:(TileType *)type layer:(NoAnimationLayer *)aLayer;
- (void)pushLayerWithType:(TileType *)type;
- (void)flush;
- (void)popLayer;

@end

@interface TileView : UIView

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGSize tileSize;
@property(nonatomic, retain) Array2D *squares;
@property(nonatomic, assign) CGPoint offset;

- (id)initWithFrame:(CGRect)aRect
               size:(CGSize)aSize 
           tileSize:(CGSize)aTileSize;  

- (TileSquare *)squareAt:(CGPoint)pos;
- (void)updateAt:(CGPoint)pos;
- (void)updateAll;
- (TileSquare *)findType:(TileType *)type;
- (TileSquare *)findRandomType:(TileType *)type;
- (int)countType:(TileType *)type;

@end
