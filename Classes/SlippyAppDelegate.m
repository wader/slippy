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

#import "SlippyAppDelegate.h"
#import "MenuViewController.h"
#import "LevelPreviewView.h"
#import "TileCombiner.h"
#import "SlippyAudio.h"
#import "PlayListViewController.h"
#import "PlayGameViewController.h"
#import "YourLevelsViewController.h"
#import "EditViewController.h"
#import "TutorialViewController.h"
#import "AboutViewController.h"
#import "LevelDatabase.h"

static NSString *stateFile;
static NSArray *slippyViewControllers;

@interface SlippyAppDelegate ()

@property(nonatomic, retain) UINavigationController *controller;
@property(nonatomic, retain) NSTimer *timer;

@end


@implementation SlippyAppDelegate

@synthesize controller;
@synthesize timer;

- (void)loadState {
  if (![[NSFileManager defaultManager] isReadableFileAtPath:stateFile]) {
    return;
  }
  
  NSArray *controllerStates = [NSArray
                               arrayWithContentsOfFile:stateFile];
  [[NSFileManager defaultManager] removeItemAtPath:stateFile error:NULL];
  if (controllerStates == nil) {
    return;
  }
  
  for (NSDictionary *controllerState in controllerStates) {
    NSString *name = [controllerState objectForKey:@"name"];
    NSDictionary *state = [controllerState objectForKey:@"state"];
    
    if (name == nil) {
      return;
    }
    
    Class slippyClass = nil;
    for (slippyClass in slippyViewControllers) {
      if ([[slippyClass name] isEqualToString:name]) {
        break;
      }
    }
    
    if (slippyClass == nil) {
      return;
    }
    
    SlippyViewController *viewController = [[[slippyClass alloc] init]
                                            autorelease];
    viewController.state = state;    
    [self.controller pushViewController:viewController animated:NO];
  }
}


- (void)saveState:(BOOL)forced {
  BOOL stateChanged = forced;
  
  for (SlippyViewController *slippyController in
       self.controller.viewControllers) {
    if ([slippyController class] == [MenuViewController class]) {
      continue;
    }
    
    stateChanged |= slippyController.stateChanged;
    slippyController.stateChanged = NO;
  }
  
  if (!stateChanged) {
    return;
  }
  
  NSMutableArray *controllerStates = [NSMutableArray array];
  for (SlippyViewController *slippyController in
       self.controller.viewControllers) {
    if ([slippyController class] == [MenuViewController class]) {
      continue;
    }
    
    NSMutableDictionary *controllerState = [NSMutableDictionary dictionary];
    [controllerState setValue:[[slippyController class] name] forKey:@"name"];
    if (slippyController.state != nil) {
      [controllerState setValue:slippyController.state forKey:@"state"];
    }
    
    [controllerStates addObject:controllerState];
  }
  
  if ([controllerStates count] == 0) {
    [[NSFileManager defaultManager] removeItemAtPath:stateFile error:NULL];
  } else {
    [controllerStates writeToFile:stateFile atomically:YES];
  }
}

- (void)timerCallback:(NSTimer *)timer {
  [self saveState:NO];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if ([viewController class] == [PlayGameViewController class] ||
      [viewController class] == [EditViewController class]) {
    [SlippyAudio playAmbinceMusic];
  } else {
    [SlippyAudio playMenuMusic];
  }
  
  if ([viewController class] == [PlayGameViewController class] ||
      [viewController class] == [EditViewController class] ||
      [viewController class] == [TutorialViewController class]) {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
  } else {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
  }
  
  [self saveState:YES];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  _MiscInit();

  [I.images loadImages];
      
  stateFile = [_pathToDocument(@"State.plist") retain];
  slippyViewControllers = [[NSArray arrayWithObjects:
                            [PlayListViewController class],
                            [PlayGameViewController class],
                            [YourLevelsViewController class],
                            [EditViewController class],
                            [TutorialViewController class],
                            [AboutViewController class],
                            nil]
                           retain];
  
  NSDateFormatter *compileDateFormatter = [[[NSDateFormatter alloc] init]
                                           autorelease];
  [compileDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
  [[NSUserDefaults standardUserDefaults]
   setValue:[NSString stringWithFormat:@"%@ %@",
	     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
	     [compileDateFormatter stringFromDate:_compileDate()]]
   forKey:SlippySettingVersion];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:
   [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithFloat:1.0f], SlippySettingMusicVolume,
    [NSNumber numberWithFloat:1.0f], SlippySettingEffectVolume,
    [NSNumber numberWithFloat:0.0f], SlippySettingDPadAlpha,
    LevelDatabaseSourceOriginalName, SlippySettingLevelSelection,
    nil]];
  
  UIWindow *window = [[UIWindow alloc]
		      initWithFrame:[UIScreen mainScreen].bounds];
  self.controller = [[[UINavigationController alloc] init] autorelease];
  if ([window respondsToSelector:@selector(setRootViewController:)]) {
    [window setRootViewController:self.controller];
  } else {
    [window addSubview:self.controller.view];
  }

  [self.controller setNavigationBarHidden:YES animated:NO];
  [self.controller pushViewController:[[[MenuViewController alloc] init]
				       autorelease]
			     animated:NO];
  [self loadState]; // before setting delegate
  self.controller.delegate = self;
  
  [window makeKeyAndVisible];
  
  self.timer = [NSTimer
                scheduledTimerWithTimeInterval:1.0f
                target:self
                selector:@selector(timerCallback:)
                userInfo:nil
                repeats:YES];
  
  [SlippyAudio init];
  
  return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  [LevelPreviewView memoryWarning];
  [TileCombiner memoryWarning];
}

// dummy dealloc to make static analyzer happy
- (void)applicationWillTerminate:(UIApplication *)application {
  [self.timer invalidate];
  self.timer = nil;
}

@end
