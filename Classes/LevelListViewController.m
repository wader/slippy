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

#import "LevelListViewController.h"
#import "LevelDatabase.h"
#import "AQGridView.h"

@implementation LevelListViewController

@synthesize gridView;
@synthesize cells;

- (IBAction)clickBack:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)reload {
  if (self.cells == nil) {
    self.cells = [self loadCells];
    [self.gridView reloadData];
    return;
  }
  
  NSArray *updated = [self loadCells];
  
  NSSet *old = [NSSet setWithArray:self.cells];
  NSSet *new = [NSSet setWithArray:updated];
  NSMutableSet *removed = [NSMutableSet setWithSet:old];
  [removed minusSet:new];
  NSMutableSet *added = [NSMutableSet setWithSet:new];
  [added minusSet:old];
  NSMutableSet *keep = [NSMutableSet setWithSet:old];
  [keep intersectSet:new];
  
  [self.gridView beginUpdates];
  
  for (SlippyLevel *l in removed) {
    int i = [self.cells indexOfObject:l];
    [self.gridView deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:i]
                          withAnimation:AQGridViewItemAnimationNone];
  }
  
  for (SlippyLevel *l in added) {
    int i = [updated indexOfObject:l];
    [self.gridView insertItemsAtIndices:[NSIndexSet indexSetWithIndex:i]
                          withAnimation:AQGridViewItemAnimationNone];
  }
  
  for (SlippyLevel *l in keep) {
    int from = [self.cells indexOfObject:l];
    int to = [updated indexOfObject:l];
    [self.gridView moveItemAtIndex:from toIndex:to withAnimation:YES];
  }
  
  self.cells = updated;
  
  [self.gridView endUpdates];
}

- (void)viewDidLoad {  
  [super viewDidLoad];
  
  self.gridView = [[[AQGridView alloc] init] autorelease];
  self.gridView.frame = self.view.frame;
  self.gridView.dataSource = self;
  self.gridView.delegate = self;
  self.gridView.backgroundColor = [UIColor clearColor];
  UIView *header = [[[UIView alloc] init] autorelease];
  header.frame = CGRectMake(0, 0, self.view.frame.size.width, 25);
  self.gridView.gridHeaderView = header;
  [self.view addSubview:self.gridView];
  
  UIButton *backwardButton = [[[UIButton alloc] init] autorelease];
  [backwardButton addTarget:self
                     action:@selector(clickBack:)
           forControlEvents:UIControlEventTouchUpInside];
  UIImage *leftImage = I.images.left;
  [backwardButton setImage:leftImage
                  forState:UIControlStateNormal];
  backwardButton.center = CGPointMake(0, 0);
  backwardButton.frame = CGRectMake(0, 0,
				    leftImage.size.width,
				    leftImage.size.height);
  backwardButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:backwardButton];
}

- (void)unloadView {
  self.gridView = nil;
  self.cells = nil;
  
  [super unloadView];
}

- (void)viewDidUnload {
  [self unloadView];
  [super viewDidUnload];
}

- (void)dealloc {
  [((LevelListViewController *)self) unloadView];
  [super dealloc];
}

- (NSArray *)loadCells {
  return [NSArray array];
}

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView {
  return [self.cells count];
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView
          cellForItemAtIndex:(NSUInteger)index {
  return nil;
}

@end
