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

@interface SlippyAudio : NSObject

+ (void)init;
+ (float)musicVolume;
+ (void)setMusicVolume:(float)volume;
+ (float)effectVolume;
+ (void)setEffectVolume:(float)volume;
+ (void)playMenuMusic;
+ (void)playAmbinceMusic;
+ (void)playIceCollisionMoveableEffect:(float)delay;
+ (void)playIceCollisionSolidEffect:(float)delay;
+ (void)playIceCollisionBlockEffect:(float)delay;
+ (void)playIceCollisionScoreEffect:(float)delay;
+ (void)playIceGlideEffect:(float)duration;
+ (void)playEatEffect:(float)delay;
+ (void)playLeveLCompletedEffect:(float)delay;
+ (void)playNextLevelEffect;
+ (void)playWalkEffect;
+ (void)playWarpEffect;

@end
