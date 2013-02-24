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
#import "SlippyLevel.h"


@interface SlippyTileView : TileView <TileCombinerDelegate>

@property(nonatomic, retain) TileType *typeEmpty;
@property(nonatomic, retain) TileType *typeScore;
@property(nonatomic, retain) TileType *typeBlock;
@property(nonatomic, retain) TileType *typeSolid;
@property(nonatomic, retain) TileType *typeMoveable;
@property(nonatomic, retain) TileType *typePlayer;

- (id)initWithFrame:(CGRect)aRect skipFixed:(BOOL)skipFixed;
- (void)loadLevel:(SlippyLevel *)level;
- (NSString *)levelData;
- (NSArray *)tileState;
- (BOOL)loadTileState:(NSArray *)squares validate:(BOOL)validate;
  
@end
