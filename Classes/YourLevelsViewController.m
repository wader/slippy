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

#import "YourLevelsViewController.h"
#import "YourLevelsLevelViewCell.h"
#import "YourLevelsNewLevelViewCell.h"
#import "EditViewController.h"
#import "LevelDatabase.h"

@interface YourLevelsViewController ()

@property(nonatomic, assign) BOOL isObserving;
@property(nonatomic, assign) CGRect cellFrame;

@end


@implementation YourLevelsViewController

@synthesize isObserving;
@synthesize cellFrame;

+ (NSString *)name {
  return @"YourLevels";
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"sourceUpdate"]) {
    NSString *source = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([source isEqualToString:LevelDatabaseSourceYourName]) {
      [self reload];
    }
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (_DeviceModel == MiscDeviceModelIPad) {
    self.cellFrame = CGRectMake(0, 0, (480 / 3) * 2, 100 * 2);
  } else {
    self.cellFrame = CGRectMake(0, 0, 480 / 3, 100);
  }
  
  [[LevelDatabase shared] addObserver:self
                           forKeyPath:@"sourceUpdate"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
  self.isObserving = YES;
  
  [self reload];
}

- (void)unloadView {
  if (self.isObserving) {
    [[LevelDatabase shared] removeObserver:self
                                forKeyPath:@"sourceUpdate"];
    self.isObserving = NO;
  }
  
  [super unloadView];
}

- (void)viewDidUnload {
  [self unloadView];
  [super viewDidUnload];
}

- (void)dealloc {
  [self unloadView];
  [super dealloc];
}

- (NSArray *)loadCells {
  NSMutableArray *cells = [NSMutableArray arrayWithArray:
                           [[LevelDatabase shared]
                            levelsFromSource:LevelDatabaseSourceYourName
                            sortDescriptors:
                            [NSArray arrayWithObject:
                             [[[NSSortDescriptor alloc]
			       initWithKey:@"added"
			       ascending:YES]
			      autorelease]]]];
  [cells addObject:@"_new"];
  
  return cells;
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView
          cellForItemAtIndex:(NSUInteger)index {
  AQGridViewCell *cell;
  
  if (index == [self.cells count] - 1) {
    cell = [aGridView dequeueReusableCellWithIdentifier:@"_new"];
    if (cell != nil) {
      return cell;
    }
    
    return [[[YourLevelsNewLevelViewCell alloc]
             initWithFrame:self.cellFrame
             reuseIdentifier:@"_new"]
            autorelease];
  }
  
  SlippyLevel *level = [self.cells objectAtIndex:index];  
  
  cell = [aGridView dequeueReusableCellWithIdentifier:level.id_];
  if (cell != nil) {
    return cell;
  }
  
  return [[[YourLevelsLevelViewCell alloc]
           initWithFrame:self.cellFrame
           level:level
           reuseIdentifier:level.id_]
          autorelease];
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
  return self.cellFrame.size;
}

- (void)gridView:(AQGridView *)aGridView didSelectItemAtIndex:(NSUInteger)index {
  [aGridView deselectItemAtIndex:index animated:YES];
  
  SlippyLevel *level;
  if (index == [self.cells count] - 1) {
    level = [[LevelDatabase shared] addYourLevel];
  } else {
    level = [self.cells objectAtIndex:index];
  }
  
  [self.navigationController
   pushViewController:[[[EditViewController alloc] initWithLevel:level]
                       autorelease]
   animated:YES];
}

@end
