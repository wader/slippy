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

#import "SlippyHTTP.h"
#import "ObservableHTTPRequest.h"


NSString *const SlippyHTTPDownloadLevelsName = @"downloadLevels";
NSString *const SlippyHTTPUploadLevelName = @"uploadLevel";
NSString *const SlippyHTTPUploadStatisticsName = @"uploadStatistics";


@implementation SlippyHTTP

+ (NSString *)baseURL {
  if (_isDeveloper() && NO) {
    return @"http://192.168.1.148:8080";
  } else {
    return @"http://slippy.inwader.com";
  }
}

+ (NSString *)fullURL:(NSString *)path {
  return [[self baseURL] stringByAppendingString:path];
}

+ (NSString *)parseRequestError:(NSData *)data {
  NSDictionary *errorDict;
  
  if ([NSPropertyListSerialization respondsToSelector:
       @selector(propertyListWithData:options:format:error:)]) {
    NSError *error = nil;
    errorDict = [NSPropertyListSerialization
                 propertyListWithData:data
                 options:0
                 format:nil
                 error:&error];
  } else {
    NSString *errorString;
    errorDict = [NSPropertyListSerialization
                 propertyListFromData:data
                 mutabilityOption:0
                 format:NULL
                 errorDescription:&errorString];
    if (errorString != nil) {
      [errorString release];
    }
  }
  
  if (errorDict == nil || ![errorDict isKindOfClass:[NSDictionary class]]) {
    return @"Invalid error plist";
  }
  
  NSString *message = [errorDict objectForKey:@"error"];
  if (message == nil) {
    return @"No error key set";
  }
  
  return message;
}

+ (void)downloadLevels {
  NSString *url;
  
  if ([[NSUserDefaults standardUserDefaults]
       boolForKey:SlippySettingShowUnratedLevels]) {
    url = @"/api/1/levels/all.plist";
  } else {
    url = @"/api/1/levels/rated.plist";
  }
  
  [[ObservableHTTPRequest shared]
   get:[self fullURL:url]
   arguments:nil
   observableName:SlippyHTTPDownloadLevelsName];
}

+ (void)uploadLevel:(SlippyLevel *)level {
  [[ObservableHTTPRequest shared]
   post:[self fullURL:@"/api/1/uploadlevel.plist"]
   arguments:[NSDictionary dictionaryWithObjectsAndKeys:
              slippyUDIDHash(), @"udid",
              level.author, @"author",
              level.email, @"email",
              level.name, @"name",
              level.data, @"data",
              nil]
   observableName:SlippyHTTPUploadLevelName
   context:level];
}

+ (void)uploadStatistics:(SlippyLevel *)level
           rating:(int)rating
        solvetime:(int)solvetime
           pushes:(int)pushes
            moves:(int)moves {
  [[ObservableHTTPRequest shared]
   post:[self fullURL:@"/api/1/uploadstatistics.plist"]
   arguments:[NSDictionary dictionaryWithObjectsAndKeys:
              level.id_, @"levelid",
              slippyUDIDHash(), @"udid",
              [NSString stringWithFormat:@"%d", rating], @"rating",
              [NSString stringWithFormat:@"%d", solvetime], @"solvetime",
              [NSString stringWithFormat:@"%d", pushes], @"pushes",
              [NSString stringWithFormat:@"%d", moves], @"moves",
              nil]
   observableName:SlippyHTTPUploadStatisticsName];
}

@end
