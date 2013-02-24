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

// TODO: width/height in level format
// TODO: editing level, current playing

#import "LevelDatabase.h"
#import "SlippyLevel.h"
#import "SlippyHTTP.h"

NSString *const LevelDatabaseDownloadStatusDone = @"done";
NSString *const LevelDatabaseDownloadStatusRequesting = @"requesting";
NSString *const LevelDatabaseDownloadStatusError = @"error";

NSString *const LevelDatabaseSourceOriginalName = @"original";
NSString *const LevelDatabaseSourceCommunityName = @"community";
NSString *const LevelDatabaseSourceYourName = @"your";
NSString *const LevelDatabaseSourceTutorialName = @"tutorial";


@interface LevelDatabase ()

@property(nonatomic, retain) NSMutableDictionary *database;

- (BOOL)isValidLevelDict:(NSDictionary *)lfdict;
- (int)loadLevelFile:(NSString *)path
              source:(NSString *)source
            isUpdate:(BOOL)isUpdate;
- (int)loadLevelDict:(NSDictionary *)lfdict
              source:(NSString *)source
            isUpdate:(BOOL)isUpdate;
- (void)saveLevelsFile:(NSString *)path source:(NSString *)source;

@end


@implementation LevelDatabase

@synthesize sourceUpdate;
@synthesize communityLevelCompleted;
@synthesize sourceAdded;
@synthesize downloadStatus;
@synthesize downloadErrorReason;
@synthesize database;


+ (LevelDatabase *)shared {
  static LevelDatabase *shared = nil;
  
  @synchronized(self) {
    if (shared == nil) {
      shared = [[LevelDatabase alloc] init];
      
      [[ObservableHTTPRequest shared]
       addObserver:shared
       forKeyPath:SlippyHTTPDownloadLevelsName
       options:NSKeyValueObservingOptionNew
       context:NULL];
    }
  }
  
  return shared;
}

- (NSString *)pathToCompletedLevels {
  return _pathToDocument(@"CompletedLevels.plist");
}

- (NSString *)pathToCommunityLevels {  
  return _pathToDocument(@"CommunityLevels.plist");
}

- (NSString *)pathToYourLevels {
  return _pathToDocument(@"YourLevels.plist");
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {  
  if ([keyPath isEqualToString:SlippyHTTPDownloadLevelsName]) {
    NSDictionary *dict = [change objectForKey:NSKeyValueChangeNewKey];
    NSString *event = [dict objectForKey:ObservableHTTPRequestDictEventKey];
    
    if ([event isEqualToString:ObservableHTTPRequestEventFinish]) {
      NSNumber *statusCode = [dict objectForKey:ObservableHTTPRequestDictStatusCodeKey];
      NSData *body = [dict objectForKey:ObservableHTTPRequestDictBodyKey];
      
      if ([statusCode intValue] == 200) {
        NSDictionary *lfdict;
        
        if ([NSPropertyListSerialization respondsToSelector:
             @selector(propertyListWithData:options:format:error:)]) {
          NSError *error = nil;
          lfdict = [NSPropertyListSerialization
                    propertyListWithData:body
                    options:0
                    format:nil
                    error:&error];
        } else {
          NSString *errorString;
          lfdict = [NSPropertyListSerialization
                    propertyListFromData:body
                    mutabilityOption:0
                    format:NULL
                    errorDescription:&errorString];
          if (errorString != nil) {
            [errorString release];
          }
        }
        
        if (lfdict == nil) {
          self.downloadErrorReason = @"plist deserialization failed";
          self.downloadStatus = LevelDatabaseDownloadStatusError;
          return;
        }
        
        if (![self isValidLevelDict:lfdict]) {
          self.downloadErrorReason = @"Invalid levels plist format";
          self.downloadStatus = LevelDatabaseDownloadStatusError;
          return;
        }
	
        int added = [self loadLevelDict:lfdict
                                 source:LevelDatabaseSourceCommunityName
                               isUpdate:YES];
        self.sourceAdded = added;
        self.sourceUpdate = LevelDatabaseSourceCommunityName;
        
        [self saveLevelsFile:[self pathToCommunityLevels]
                      source:LevelDatabaseSourceCommunityName];
        
        self.downloadStatus = LevelDatabaseDownloadStatusDone;
      } else {
        self.downloadErrorReason = [SlippyHTTP parseRequestError:body];
        self.downloadStatus = LevelDatabaseDownloadStatusError;
      }
    } else if ([event isEqualToString:ObservableHTTPRequestEventRequesting]) {
      self.downloadStatus = LevelDatabaseDownloadStatusRequesting;
    } else if ([event isEqualToString:ObservableHTTPRequestEventError]) {
      NSError *error = [dict objectForKey:ObservableHTTPRequestDictErrorKey];
      self.downloadErrorReason = [error localizedDescription];
      self.downloadStatus = LevelDatabaseDownloadStatusError;
    }
  }
}

- (BOOL)isValidLevelDict:(NSDictionary *)lfdict {
  if (lfdict == nil || ![lfdict isKindOfClass:[NSDictionary class]]) {
    return NO;
  }
  
  NSArray *levels = [lfdict objectForKey:@"levels"];
  if (levels == nil || ![levels isKindOfClass:[NSArray class]]) {
    return NO;
  }
  
  for (NSDictionary *ldict in levels) {
    if (![ldict isKindOfClass:[NSDictionary class]]) {
      return NO;
    }
    
    NSString *id_ = [ldict objectForKey:@"id"];
    if (id_ == nil || ![id_ isKindOfClass:[NSString class]]) {
      return NO;
    }
    
    NSNumber *width = [ldict objectForKey:@"width"];
    if (width != nil && ![width isKindOfClass:[NSNumber class]]) {
      return NO;
    }
    
    NSNumber *height = [ldict objectForKey:@"height"];
    if (height != nil && ![height isKindOfClass:[NSNumber class]]) {
      return NO;
    }
    
    NSString *data = [ldict objectForKey:@"data"];
    if (data == nil || ![data isKindOfClass:[NSString class]] ||
        [data length] != [width intValue] * [height intValue]) {
      return NO;
    }
    
    // optional keys
    
    NSString *author = [ldict objectForKey:@"author"];
    if (author != nil && ![author isKindOfClass:[NSString class]]) {
      return NO;
    }
    
    NSString *name = [ldict objectForKey:@"name"];
    if (name != nil && ![name isKindOfClass:[NSString class]]) {
      return NO;
    }
    
    NSDate *email = [ldict objectForKey:@"email"];
    if (email != nil && ![email isKindOfClass:[NSString class]]) {
      return NO;
    }
    
    NSDate *added = [ldict objectForKey:@"added"];
    if (added != nil && ![added isKindOfClass:[NSDate class]]) {
      return NO;
    }
    
    NSNumber *rating = [ldict objectForKey:@"rating"];
    if (rating != nil && ![rating isKindOfClass:[NSNumber class]]) {
      return NO;
    }
    
    NSNumber *ratings = [ldict objectForKey:@"ratings"];
    if (ratings != nil && ![ratings isKindOfClass:[NSNumber class]]) {
      return NO;
    }
    
    NSNumber *locked = [ldict objectForKey:@"locked"];
    if (locked != nil && ![locked isKindOfClass:[NSNumber class]]) {
      return NO;
    }
    
    NSArray *unlocks = [ldict objectForKey:@"unlocks"];
    if (unlocks != nil && ![unlocks isKindOfClass:[NSArray class]]) {      
      return NO;
    }
    for (NSString *s in unlocks) {
      if (![s isKindOfClass:[NSString class]]) {
        return NO;
      }
    }
    
    NSArray *required = [ldict objectForKey:@"required"];
    if (required != nil && ![required isKindOfClass:[NSArray class]]) {
      return NO;
    }
    for (NSString *s in required) {
      if (![s isKindOfClass:[NSString class]]) {
        return NO;
      }
    }
    
    NSString *uploaded = [ldict objectForKey:@"uploaded"];
    if (uploaded != nil && ![uploaded isKindOfClass:[NSNumber class]]) {
      return NO;
    }
    
    NSString *new_ = [ldict objectForKey:@"new"];
    if (new_ != nil && ![new_ isKindOfClass:[NSNumber class]]) {
      return NO;
    }
    
    NSDate *firstDownloaded = [ldict objectForKey:@"firstdownloaded"];
    if (firstDownloaded != nil && ![firstDownloaded isKindOfClass:[NSDate class]]) {
      return NO;
    }
    
    NSString *authorHash = [ldict objectForKey:@"authorhash"];
    if (authorHash != nil && ![authorHash isKindOfClass:[NSString class]]) {
      return NO;
    }
  }
  
  return YES;
}

- (int)loadLevelDict:(NSDictionary *)lfdict
              source:(NSString *)source
            isUpdate:(BOOL)isUpdate {
  if (![self isValidLevelDict:lfdict]) {
    return 0;
  }
  
  NSMutableSet *added = [NSMutableSet set];
  NSMutableSet *remove = [NSMutableSet set];
  for (SlippyLevel *slevel in [self.database allValues]) {
    if (![slevel.source isEqualToString:source]) {
      continue;
    }
    
    [remove addObject:slevel];
  }
  
  int order = 1;
  
  for (NSDictionary *ldict in [lfdict objectForKey:@"levels"]) {
    NSString *id_ = [ldict objectForKey:@"id"];
    
    SlippyLevel *slevel = [self levelWithId:id_];
    if (slevel == nil) {
      slevel = [[[SlippyLevel alloc] init] autorelease];
      slevel.id_ = id_;
      [self.database setValue:slevel forKey:id_];
      [added addObject:slevel];
    } else {
      [remove removeObject:slevel];
    }
    
    slevel.author = [ldict objectForKey:@"author"];
    if (slevel == nil) {
      slevel.author = @"";
    }
    slevel.email = [ldict objectForKey:@"email"];
    if (slevel.email == nil) {
      slevel.email = @"";
    }
    slevel.name = [ldict objectForKey:@"name"];
    if (slevel.name == nil) {
      slevel.name = @"";
    }
    slevel.added = [ldict objectForKey:@"added"];
    NSNumber *rating = [ldict objectForKey:@"rating"];
    if (rating != nil) {
      slevel.rating = [rating floatValue];
    }
    NSNumber *ratings = [ldict objectForKey:@"ratings"];
    if (ratings != nil) {
      slevel.ratings = [ratings intValue];
    }
    slevel.width = [((NSNumber *)[ldict objectForKey:@"width"]) intValue];
    slevel.height = [((NSNumber *)[ldict objectForKey:@"height"]) intValue];
    slevel.data = [ldict objectForKey:@"data"];
    NSNumber *locked = [ldict objectForKey:@"locked"];
    if (locked != nil) {
      slevel.locked = [locked boolValue];
    }
    NSNumber *uploaded = [ldict objectForKey:@"uploaded"];
    if (uploaded != nil) {
      slevel.uploaded = [uploaded boolValue];
    }
    NSNumber *new_ = [ldict objectForKey:@"new"];
    if (new_ != nil) {
      slevel.new_ = [new_ boolValue];
    }
    slevel.firstDownloaded = [ldict objectForKey:@"firstdownloaded"];
    if (slevel.firstDownloaded == nil) {
      slevel.firstDownloaded = [NSDate date];
    }
    slevel.authorHash = [ldict objectForKey:@"authorhash"];
    if (slevel.authorHash == nil) {
      slevel.authorHash = [NSString string];
    }
    
    slevel.order = order++;
    slevel.source = source;
    // completed is NO if new, leave as is if updated level
  }
  
  for (SlippyLevel *slevel in remove) {
    [self.database removeObjectForKey:slevel];
  }
  
  if (isUpdate && [added count] > 0) {
    for (SlippyLevel *slevel in [self.database allValues]) {
      if (![slevel.source isEqualToString:source]) {
        continue;
      }
      
      if ([added containsObject:slevel]) {
        slevel.new_ = YES;
        slevel.firstDownloaded = [NSDate date];
      } else {
        slevel.new_ = NO;
      }
    }
  }
  
  return [added count];
}

- (int)loadLevelFile:(NSString *)path
              source:(NSString *)source
            isUpdate:(BOOL)isUpdate {
  if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
    return 0;
  }
  
  NSDictionary *lfdict = [NSDictionary dictionaryWithContentsOfFile:path];
  if (lfdict == nil || ![self isValidLevelDict:lfdict]) {
    return 0;
  }
  
  return [self loadLevelDict:lfdict
                      source:source
                    isUpdate:isUpdate];
}

- (SlippyLevel *)addYourLevel {
  NSString *id_;
  
  for (int i = 0; YES; i++) {
    id_ = [NSString stringWithFormat:@"your%d", i];
    if (![self levelWithId:id_]) {
      break;
    }
  }
  
  SlippyLevel *slevel = [[[SlippyLevel alloc] init] autorelease];
  slevel.id_ = id_;
  slevel.source = LevelDatabaseSourceYourName;
  slevel.added = [NSDate date];
  slevel.author = [[NSUserDefaults standardUserDefaults]
                   stringForKey:SlippySettingAuthorName];
  if (slevel.author == nil) {
    slevel.author = @"";
  }
  slevel.authorHash = @"";
  slevel.email = [[NSUserDefaults standardUserDefaults]
                  stringForKey:SlippySettingEmail];
  if (slevel.email == nil) {
    slevel.email = @"";
  }
  slevel.name = @"";
  slevel.width = SLIPPY_LEVEL_WIDTH;
  slevel.height = SLIPPY_LEVEL_HEIGHT;
  
  [self.database setValue:slevel forKey:slevel.id_];
  
  self.sourceUpdate = LevelDatabaseSourceYourName;
  
  return slevel;
}

- (BOOL)isValidCompletedFile:(NSDictionary *)cldict {
  if (cldict == nil || ![cldict isKindOfClass:[NSDictionary class]]) {
    return NO;
  }
  
  NSArray *levels = [cldict objectForKey:@"levels"];
  if (levels == nil || ![levels isKindOfClass:[NSArray class]]) {
    return NO;
  }
  
  for (NSDictionary *ldict in levels) {
    if (![ldict isKindOfClass:[NSDictionary class]]) {
      return NO;
    }
    
    NSString *id_ = [ldict objectForKey:@"id"];
    if (id_ == nil || ![id_ isKindOfClass:[NSString class]]) {
      return NO;
    }
    
    NSNumber *rating = [ldict objectForKey:@"rating"];
    if (id_ == nil || ![rating isKindOfClass:[NSNumber class]]) {
      return NO;
    }
  }
  
  return YES;
}

- (void)loadCompletedFile:(NSString *)path {
  if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
    return;
  }
  
  NSDictionary *cldict = [NSDictionary dictionaryWithContentsOfFile:path];
  if (cldict == nil || ![self isValidCompletedFile:cldict]) {
    return;
  }
  
  NSArray *levels = [cldict objectForKey:@"levels"];
  
  for (NSDictionary *ldict in levels) {
    NSString *id_ = [ldict objectForKey:@"id"];
    SlippyLevel *slevel = [self.database objectForKey:id_];
    if (slevel == nil) {
      continue;
    }
    
    slevel.completed = YES;
    
    NSNumber *rating = [ldict objectForKey:@"rating"];
    slevel.userRating = [rating intValue];
  }
  
  for (SlippyLevel *slevel in [self.database allValues]) {
    if (!slevel.completed ||
	![slevel.source isEqualToString:LevelDatabaseSourceOriginalName]) {
      continue;
    }
    
    [self completeAndUnlockLevels:slevel save:NO];
  }
}

- (void)saveCompletedFile:(NSString *)path {
  NSMutableDictionary *sfdict = [NSMutableDictionary dictionary];
  NSMutableArray *levels = [NSMutableArray array];
  
  for (SlippyLevel *slevel in [self.database allValues]) {
    if (!slevel.completed) {
      continue;
    }
    
    [levels addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		       slevel.id_, @"id",
		       [NSNumber numberWithInt:slevel.userRating], @"rating",
		       nil]];
  }
  
  [sfdict setValue:levels forKey:@"levels"];
  [sfdict writeToFile:path atomically:YES];
}

- (void)saveCompleted {
  [self saveCompletedFile:[self pathToCompletedLevels]];
}

- (void)completeAndUnlockLevels:(SlippyLevel *)level save:(BOOL)save {
  if (save && !level.completed &&
      [level.source isEqualToString:LevelDatabaseSourceCommunityName]) {
    self.communityLevelCompleted = @"dummy";
  }
  
  level.completed = YES;

  if (save) {
    [self saveCompleted];    
  }
  
  if (![level.source isEqualToString:LevelDatabaseSourceOriginalName]) {
    return;
  }
 
  for (int i = 0; i < 3 ; i++) {
    SlippyLevel *ulevel = [self levelWithId:
			   [NSString stringWithFormat:@"slippy%d",
			    level.order + 1 + i]];
    if (ulevel == nil) {
      break;
    }
    
    ulevel.locked = NO;
  }
}

- (void)saveLevelsFile:(NSString *)path source:(NSString *)source {
  NSMutableDictionary *ldict = [NSMutableDictionary dictionary];
  NSMutableArray *levels = [NSMutableArray array];
  
  for (SlippyLevel *slevel in [self.database allValues]) {
    if (![slevel.source isEqualToString:source]) {
      continue;
    }
    
    [levels addObject:[slevel savePlist]];
  }
  
  [ldict setValue:[NSNumber numberWithInt:0] forKey:@"version"];
  [ldict setValue:levels forKey:@"levels"];
  [ldict writeToFile:path atomically:YES];
}

- (void)saveYourLevels {
  [self saveLevelsFile:[self pathToYourLevels]
                source:LevelDatabaseSourceYourName];
}

- (NSDate *)dateOfLastCommunityUpdate {  
  NSDictionary *attr = [[NSFileManager defaultManager]
                        attributesOfItemAtPath:[self pathToCommunityLevels]
                        error:NULL];
  if (attr == nil) {
    return nil;
  }
  
  return [attr objectForKey:NSFileModificationDate];
}

- (void)deleteLeveLWithId:(NSString *)id_ {
  [self.database removeObjectForKey:id_];
  [self saveYourLevels];
  self.sourceUpdate = LevelDatabaseSourceYourName;
}

- (SlippyLevel *)levelWithId:(NSString *)id_ {
  return [self.database objectForKey:id_];
}

- (NSArray *)levelsFromSource:(NSString *)source
              sortDescriptors:(NSArray *)descriptors {
  NSMutableArray *hits = [NSMutableArray array];
  
  for (SlippyLevel *l in [self.database allValues]) {
    if (![l.source isEqualToString:source]) {
      continue;
    }
    
    [hits addObject:l];
  }
  
  [hits sortUsingDescriptors:descriptors];
  
  return hits;
}

- (void)rateLevel:(SlippyLevel *)level
	   rating:(int)rating {
  level.userRating = rating;
  [self saveCompleted];
}

- (id)init {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  
  self.database = [NSMutableDictionary dictionary];
  
  [self loadLevelFile:P.levels.originalLevelsPlist
	       source:LevelDatabaseSourceOriginalName
	     isUpdate:NO];
  [self loadLevelFile:P.levels.tutorialLevelsPlist
	       source:LevelDatabaseSourceTutorialName
	     isUpdate:NO];
  [self loadLevelFile:[self pathToCommunityLevels]
	       source:LevelDatabaseSourceCommunityName
	     isUpdate:NO];
  [self loadLevelFile:[self pathToYourLevels]
	       source:LevelDatabaseSourceYourName
	     isUpdate:NO];
  [self loadCompletedFile:[self pathToCompletedLevels]];
  
  self.downloadStatus = LevelDatabaseDownloadStatusDone;
  
  return self;
}

- (void)dealloc {
  self.sourceUpdate = nil;
  self.downloadStatus = nil;
  self.downloadErrorReason = nil;
  self.database = nil;
  
  [super dealloc];
}

@end
