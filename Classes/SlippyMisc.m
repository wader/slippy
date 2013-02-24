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

#import "SlippyMisc.h"
#import "NSString+digest.h"

NSString *const SlippyErrorDomain = @"slippy";

NSString *const SlippySettingVersion = @"version";
NSString *const SlippySettingLevelSelection = @"levelSelection";
NSString *const SlippySettingSourceScroll = @"sourceScroll";
NSString *const SlippySettingShowUnratedLevels = @"showUnratedLevels";
NSString *const SlippySettingMusicVolume = @"musicVolume";
NSString *const SlippySettingEffectVolume = @"effectVolume";
NSString *const SlippySettingDPadAlpha = @"dpadAlpha";
NSString *const SlippySettingAuthorName = @"authorName";
NSString *const SlippySettingEmail = @"email";


NSString *slippyUDIDHash(void) {
  return [[@"slippy" stringByAppendingString:
	   [[UIDevice currentDevice] uniqueIdentifier]]
	  md5];  
}

BOOL _isTester(void) {
  return [[NSArray arrayWithObjects:
           nil]
          containsObject:[[UIDevice currentDevice] uniqueIdentifier]];
}

BOOL _isDeveloper(void) {
  return [[NSArray arrayWithObjects:
           nil]
          containsObject:[[UIDevice currentDevice] uniqueIdentifier]];
}
