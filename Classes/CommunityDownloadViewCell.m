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

#import "CommunityDownloadViewCell.h"
#import "LevelDatabase.h"
#import "SlippyLabel.h"
#import "UIImage+extra.h"
#import "NSDate+fuzzy.h"


@interface CommunityDownloadViewCell ()

@property(nonatomic, retain) SlippyLabel *statusText;
@property(nonatomic, retain) UIImageView *statusImage;
@property(nonatomic, retain) SlippyLabel *lastUpdatedText;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end


@implementation CommunityDownloadViewCell

@synthesize statusText;
@synthesize statusImage;
@synthesize lastUpdatedText;
@synthesize activityIndicator;


- (void)update:(NSString *)status first:(BOOL)first {
  LevelDatabase *leveldb = [LevelDatabase shared];
  
  if ([status isEqualToString:LevelDatabaseDownloadStatusDone] ||
      (first && [status isEqualToString:LevelDatabaseDownloadStatusError])) {
    NSDate *lastUpdate = [leveldb dateOfLastCommunityUpdate];
    
    if (lastUpdate == nil) {
      self.statusText.text = @"Download levels";
    } else {
      self.statusImage.image = I.images.download;
      [self.activityIndicator stopAnimating];
      
      if ([leveldb.sourceUpdate isEqualToString:LevelDatabaseSourceCommunityName] &&
          [lastUpdate timeIntervalSinceNow] > -60) {
        if (leveldb.sourceAdded == 0) {
          self.statusText.text = @"No new levels :(";
        } else {
          self.statusText.text = [NSString stringWithFormat:@"%d new level%@!",
                                  leveldb.sourceAdded,
                                  leveldb.sourceAdded > 1 ? @"s" : @""];
        }
      } else {
        self.statusText.text = @"Update levels";
      }
      
      self.lastUpdatedText.text = [NSString stringWithFormat:@"Last updated %@ ago",
                                   [lastUpdate fuzzySinceNow]];
    }
  } else if ([status isEqualToString:LevelDatabaseDownloadStatusRequesting]) {
    self.statusImage.image = I.images.downloadSun;
    [self.activityIndicator startAnimating];
    self.statusText.text = @"Updating...";
    self.lastUpdatedText.text = @"";
  } else if ([status isEqualToString:LevelDatabaseDownloadStatusError]) {
    self.statusImage.image = I.images.downloadRain;
    [self.activityIndicator stopAnimating];
    self.statusText.text = @"Update failed :(";
    self.lastUpdatedText.text = leveldb.downloadErrorReason;
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"downloadStatus"]) {    
    [self update:[change objectForKey:NSKeyValueChangeNewKey] first:NO];
  }
}

- (id)initWithFrame:(CGRect)frame
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
  if (self == nil) {
    return nil;
  }
  
  CGFloat statusFontSize = (int)(self.contentView.bounds.size.height / 10.0f);
  CGFloat lastUpdateFontSize = (int)(self.contentView.bounds.size.height / 15.0f);
  
  UIImage *downloadImage = I.images.download;
  
  self.activityIndicator = [[[UIActivityIndicatorView alloc]
			     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]
			    autorelease];
  self.activityIndicator.bounds = CGRectMake(0, 0,
					     downloadImage.size.width,
					     downloadImage.size.height);
  self.activityIndicator.center = CGPointMake(self.contentView.frame.size.width / 2,
					      self.contentView.frame.size.height * 0.25f);
  self.activityIndicator.center = CGPointDelta(self.activityIndicator.center,
					       CGPointMake(downloadImage.size.width * 0.3f,
							   -downloadImage.size.width * 0.27f));
  self.activityIndicator.frame = CGRectInt(self.activityIndicator.frame);
  self.activityIndicator.hidesWhenStopped = YES;
  [self.contentView addSubview:self.activityIndicator];
  
  self.statusImage = [[[UIImageView alloc] initWithImage:downloadImage]
		      autorelease];
  self.statusImage.center = CGPointMake(self.contentView.frame.size.width / 2,
					self.contentView.frame.size.height * 0.25f);
  self.statusImage.frame = CGRectInt(self.statusImage.frame);
  [self.contentView addSubview:self.statusImage];
  
  self.statusText = [[[SlippyLabel alloc] init] autorelease];
  self.statusText.fontSize = statusFontSize;
  self.statusText.center = CGPointMake(self.contentView.frame.size.width / 2,
				       self.contentView.frame.size.height / 2);
  self.statusText.bounds = CGRectMake(0, 0,
				      self.contentView.frame.size.width,
				      statusFontSize + 5);
  self.statusText.frame = CGRectInt(self.statusText.frame);
  self.statusText.textAlignment = UITextAlignmentCenter;
  [self.contentView addSubview:self.statusText];
  
  self.lastUpdatedText = [[[SlippyLabel alloc] init] autorelease];
  self.lastUpdatedText.fontSize = lastUpdateFontSize;
  self.lastUpdatedText.bounds = CGRectMake(0, 0,
					   self.contentView.frame.size.width,
					   lastUpdateFontSize + 5);
  self.lastUpdatedText.center = CGPointMake(self.contentView.frame.size.width / 2,
					    self.contentView.frame.size.height * 0.7f);
  self.lastUpdatedText.frame = CGRectInt(self.lastUpdatedText.frame);
  self.lastUpdatedText.lineBreakMode = UILineBreakModeWordWrap;
  self.lastUpdatedText.numberOfLines = 2;
  self.lastUpdatedText.textAlignment = UITextAlignmentCenter;
  [self.contentView addSubview:self.lastUpdatedText];
  
  [[LevelDatabase shared] addObserver:self
                           forKeyPath:@"downloadStatus"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
  
  [self update:[LevelDatabase shared].downloadStatus first:YES];
  
  return self;
}

- (void)dealloc {
  [[LevelDatabase shared] removeObserver:self
                              forKeyPath:@"downloadStatus"];
  
  [self.statusText removeFromSuperview];
  self.statusText = nil;
  [self.statusImage removeFromSuperview];
  self.statusImage = nil;
  [self.lastUpdatedText removeFromSuperview];
  self.lastUpdatedText = nil;
  [self.activityIndicator removeFromSuperview];
  self.activityIndicator = nil;
  
  [super dealloc];
}

@end
