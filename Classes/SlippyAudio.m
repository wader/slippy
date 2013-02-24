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

#import "SlippyAudio.h"
#import "AudioPlayer.h"

#import <AVFoundation/AVFoundation.h>


static NSString *const SlippyAudioNameMusic = @"music";
static NSString *const SlippyAudioVolumeMusic = @"music";
static NSString *const SlippyAudioVolumeEffect = @"effect";


@implementation SlippyAudio

+ (void)init {
  [[AVAudioSession sharedInstance]
   setCategory:AVAudioSessionCategoryPlayback
   error:NULL];
  
  [AudioPlayer setVolumeForName:SlippyAudioVolumeMusic
                         volume:[[NSUserDefaults standardUserDefaults]
                                 floatForKey:SlippySettingMusicVolume]];
  [AudioPlayer setVolumeForName:SlippyAudioVolumeEffect
                         volume:[[NSUserDefaults standardUserDefaults]
                                 floatForKey:SlippySettingEffectVolume]];
}

+ (float)musicVolume {
  return [[NSUserDefaults standardUserDefaults]
	  floatForKey:SlippySettingMusicVolume];
}

+ (void)setMusicVolume:(float)volume {
  [AudioPlayer setVolumeForName:SlippyAudioVolumeMusic volume:volume];
  [[NSUserDefaults standardUserDefaults] setFloat:volume
                                           forKey:SlippySettingMusicVolume];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (float)effectVolume {
  return [[NSUserDefaults standardUserDefaults]
	  floatForKey:SlippySettingEffectVolume];
}

+ (void)setEffectVolume:(float)volume {
  [AudioPlayer setVolumeForName:SlippyAudioVolumeEffect volume:volume];
  [[NSUserDefaults standardUserDefaults] setFloat:volume
                                           forKey:SlippySettingEffectVolume];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSURL *)urlToResource:(NSString *)resource
                  ofType:(NSString *)type
             inDirectory:(NSString *)directory {
  return [[[NSURL alloc] initFileURLWithPath:
           [[NSBundle mainBundle] pathForResource:resource
                                           ofType:type
                                      inDirectory:directory]]
          autorelease];
}

+ (void)playMenuMusic {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"menumusic"
                                                 ofType:@"mp3"
                                            inDirectory:@"audio"]
                startDelay:0
              playDuration:0
                shouldLoop:YES
                      name:SlippyAudioNameMusic
                volumeName:SlippyAudioVolumeMusic
              fadeDuration:1.0f];
}

+ (void)playAmbinceMusic {
  [AudioPlayer playWithURL:nil
                startDelay:0
              playDuration:0
                shouldLoop:YES
                      name:SlippyAudioNameMusic
                volumeName:SlippyAudioVolumeMusic
              fadeDuration:1.0f];
}

+ (void)playIceCollisionMoveableEffect:(float)delay {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"blockblock"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:delay
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playIceCollisionSolidEffect:(float)delay {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"blockwall"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:delay
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playIceCollisionBlockEffect:(float)delay {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"blockwater"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:delay
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playIceCollisionScoreEffect:(float)delay {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"blocksquish"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:delay
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playIceGlideEffect:(float)duration {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"blockglide"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:0
              playDuration:duration
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playEatEffect:(float)delay {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"eat"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:delay
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playLeveLCompletedEffect:(float)delay {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"completed"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:delay
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playNextLevelEffect {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"swoosh"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:0.1f
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playWalkEffect {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"walk"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:0
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

+ (void)playWarpEffect {
  [AudioPlayer playWithURL:[[self class ] urlToResource:@"swoosh"
                                                 ofType:@"wav"
                                            inDirectory:@"audio"]
                startDelay:0
              playDuration:0
                shouldLoop:NO
                      name:nil
                volumeName:SlippyAudioVolumeEffect
              fadeDuration:0];
}

@end
