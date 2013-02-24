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

#import "SlippyLevel.h"

NSString *const LevelDatabaseDownloadStatusDone;
NSString *const LevelDatabaseDownloadStatusRequesting;
NSString *const LevelDatabaseDownloadStatusError;

NSString *const LevelDatabaseSourceOriginalName;
NSString *const LevelDatabaseSourceCommunityName;
NSString *const LevelDatabaseSourceYourName;
NSString *const LevelDatabaseSourceTutorialName;


@interface LevelDatabase : NSObject

@property(nonatomic, retain) NSString *sourceUpdate;
@property(nonatomic, retain) NSString *communityLevelCompleted;
@property(nonatomic, assign) int sourceAdded;
@property(nonatomic, retain) NSString *downloadStatus;
@property(nonatomic, retain) NSString *downloadErrorReason;

+ (LevelDatabase *)shared;

- (void)saveCompleted;
- (SlippyLevel *)addYourLevel;
- (void)saveYourLevels;
- (void)deleteLeveLWithId:(NSString *)id_;
- (NSDate *)dateOfLastCommunityUpdate;
- (void)completeAndUnlockLevels:(SlippyLevel *)level save:(BOOL)save;
- (SlippyLevel *)levelWithId:(NSString *)id_;
- (NSArray *)levelsFromSource:(NSString *)source
              sortDescriptors:(NSArray *)descriptors;
- (void)rateLevel:(SlippyLevel *)level
	   rating:(int)rating;

@end
