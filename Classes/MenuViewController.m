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

#import "MenuViewController.h"
#import "PlayListViewController.h"
#import "YourLevelsViewController.h"
#import "TutorialViewController.h"
#import "AboutViewController.h"
#import "SlippyHTTP.h"
#import "SlippyAudio.h"
#import "LevelDatabase.h"


@interface MenuViewController ()

@property(nonatomic, retain) CALayer *slippyImage;
@property(nonatomic, retain) UIImage *slippyImageBlink;
@property(nonatomic, retain) NSTimer *slippyTimer;
@property(nonatomic, retain) UIImageView *dpadSettingsDisableImage;

@end

@implementation MenuViewController

@synthesize slippyImage;
@synthesize slippyImageBlink;
@synthesize slippyTimer;
@synthesize dpadSettingsDisableImage;

- (void)timerCallback:(NSTimer *)timer {
  if ((arc4random() % 2) == 0) {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"contents"];
    anim.fromValue = (id)self.slippyImageBlink.CGImage;
    anim.toValue = (id)self.slippyImageBlink.CGImage;
    anim.duration = 0.1f;
    anim.removedOnCompletion = YES;
    [self.slippyImage addAnimation:anim forKey:nil];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:SlippyHTTPUploadStatisticsName]) {
    NSDictionary *dict = [change objectForKey:NSKeyValueChangeNewKey];
    NSString *event = [dict objectForKey:ObservableHTTPRequestDictEventKey];
    
    if ([event isEqualToString:ObservableHTTPRequestEventFinish]) {
      NSNumber *statusCode = [dict objectForKey:ObservableHTTPRequestDictStatusCodeKey];
      NSData *body = [dict objectForKey:ObservableHTTPRequestDictBodyKey];
      
      if ([statusCode intValue] == 200) {
        // went fine
      } else if ([statusCode intValue] == 400) {
        // show error from server
        [[[[UIAlertView alloc]
           initWithTitle:@"Upload statistics"
           message:[SlippyHTTP parseRequestError:body]
           delegate:nil
           cancelButtonTitle:@"OK"
           otherButtonTitles:nil]
          autorelease]
         show];
      } else {
        // some other error, ignore
      }
    } else if ([event isEqualToString:ObservableHTTPRequestEventRequesting]) {
      // request in progress, ignore, done in background
    } else if ([event isEqualToString:ObservableHTTPRequestEventError]) {
      // networks error etc, ignore
    }
  } else if ([keyPath isEqualToString:SlippyHTTPUploadLevelName]) {
    NSDictionary *dict = [change objectForKey:NSKeyValueChangeNewKey];
    NSString *event = [dict objectForKey:ObservableHTTPRequestDictEventKey];
    
    if ([event isEqualToString:ObservableHTTPRequestEventFinish]) {
      NSNumber *statusCode = [dict objectForKey:ObservableHTTPRequestDictStatusCodeKey];
      NSData *body = [dict objectForKey:ObservableHTTPRequestDictBodyKey];
      SlippyLevel *slevel = [dict objectForKey:ObservableHTTPRequestDictContextKey];
      
      if ([statusCode intValue] == 200) {
        [[[[UIAlertView alloc]
	   initWithTitle:@"Upload level"
	   message:
	   @"Uploaded successfully! Thanks!"
	   delegate:nil
	   cancelButtonTitle:@"OK"
	   otherButtonTitles:nil]
	  autorelease]
	 show];
        slevel.uploaded = YES;
        [[LevelDatabase shared] saveYourLevels];
      } else {
        [[[[UIAlertView alloc]
	   initWithTitle:@"Upload level"
	   message:
	   [NSString stringWithFormat:
	    @"Upload failed, server gave reason:\n\n%@",
	    [SlippyHTTP parseRequestError:body]]
	   delegate:nil
	   cancelButtonTitle:@"OK"
	   otherButtonTitles:nil]
	  autorelease]
	 show];
      }
    } else if ([event isEqualToString:ObservableHTTPRequestEventRequesting]) {
      // ignore
    } else if ([event isEqualToString:ObservableHTTPRequestEventError]) {
      NSError *error = [dict objectForKey:ObservableHTTPRequestDictErrorKey];
      [[[[UIAlertView alloc]
	 initWithTitle:@"Upload level"
	 message:
	 [NSString stringWithFormat:@"Upload failed :(\n\n%@",
	  [error localizedDescription]]
	 delegate:nil
	 cancelButtonTitle:@"OK"
	 otherButtonTitles:nil]
	autorelease]
       show];
    }
  }
}

- (IBAction)clickPlay:(id)sender {
  [self.navigationController
   pushViewController:[[[PlayListViewController alloc] init] autorelease]
   animated:YES];
}

- (IBAction)clickTutorial:(id)sender {
  [self.navigationController
   pushViewController:[[[TutorialViewController alloc] init] autorelease]
   animated:YES];
}

- (IBAction)clickYourLevels:(id)sender {
  [self.navigationController
   pushViewController:[[[YourLevelsViewController alloc] init] autorelease]
   animated:YES];
}

- (IBAction)clickAbout:(id)sender {
  [self.navigationController
   pushViewController:[[[AboutViewController alloc] init] autorelease]
   animated:YES];
}

- (IBAction)changeMusicVolume:(id)sender {
  UISlider *slider = sender;
  [SlippyAudio setMusicVolume:slider.value];
}

- (IBAction)changeEffectVolume:(id)sender {
  UISlider *slider = sender;
  [SlippyAudio setEffectVolume:slider.value];
}

- (IBAction)changeEffectVolumeTest:(id)sender {
  UISlider *slider = sender;
  static float previous = -1;
  
  if (previous == slider.value) {
    return;
  }
  previous = slider.value;
  
  [SlippyAudio playEatEffect:0];
}

- (void)dpadUpdateImages:(UISlider *)slider {
  if (slider.value < 0.1f) {
    self.dpadSettingsDisableImage.frame = CGRectMake(slider.frame.origin.x + slider.currentThumbImage.size.width * 0.5f +
						     (slider.frame.size.width - slider.currentThumbImage.size.width) * (slider.value / slider.maximumValue),
						     slider.frame.origin.y + slider.currentThumbImage.size.height * 0.35f,
						     self.dpadSettingsDisableImage.frame.size.width,
						     self.dpadSettingsDisableImage.frame.size.height);
    self.dpadSettingsDisableImage.frame = CGRectInt(self.dpadSettingsDisableImage.frame);
    self.dpadSettingsDisableImage.hidden = NO;
    slider.alpha = 1.0f;
  } else {
    slider.alpha = slider.value == 0.5f ? 0.49f : slider.value;
    self.dpadSettingsDisableImage.hidden = YES;
  }
}

- (IBAction)changeDPadSetting:(id)sender {
  UISlider *slider = sender;
  float dpadAlpha = slider.value < 0.1f ? 0.0 : slider.value;
  
  [[NSUserDefaults standardUserDefaults] setFloat:dpadAlpha
					   forKey:SlippySettingDPadAlpha];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [self dpadUpdateImages:slider];
}

- (id)init {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  
  [[ObservableHTTPRequest shared] addObserver:self
				   forKeyPath:SlippyHTTPUploadStatisticsName
				      options:NSKeyValueObservingOptionNew
				      context:NULL];
  
  [[ObservableHTTPRequest shared] addObserver:self
				   forKeyPath:SlippyHTTPUploadLevelName
				      options:NSKeyValueObservingOptionNew
				      context:NULL];
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  CALayer *background = [[[CALayer alloc] init] autorelease];
  background.contents = (id)I.images.menuOverlay.CGImage;
  background.bounds = self.view.bounds;
  background.position = CGPointMake(0, 0);
  background.anchorPoint = CGPointMake(0, 0);
  background.zPosition = -1;
  [self.view.layer addSublayer:background];
  
  UIImage *image = I.images.menuSlippy;
  self.slippyImage = [[[CALayer alloc] init] autorelease];
  self.slippyImage.contents = (id)image.CGImage;
  self.slippyImage.frame = CGRectMake(self.view.bounds.size.width * 0.05f,
				      self.view.bounds.size.height * 0.3f,
				      image.size.width,
				      image.size.height);
  self.slippyImage.frame = CGRectInt(self.slippyImage.frame);
  [self.view.layer addSublayer:self.slippyImage];
  self.slippyImageBlink = I.images.menuSlippyBlink;
  
  self.slippyTimer = [NSTimer
		      scheduledTimerWithTimeInterval:5.0f
		      target:self
		      selector:@selector(timerCallback:)
		      userInfo:nil
		      repeats:YES];
  
  UIImage *playImage = I.images.menuPlay;
  UIButton *playButton = [[[UIButton alloc] init] autorelease];
  [playButton addTarget:self
		 action:@selector(clickPlay:)
       forControlEvents:UIControlEventTouchUpInside];
  [playButton setImage:playImage
	      forState:UIControlStateNormal];
  playButton.bounds = CGRectMake(0, 0,
				 playImage.size.width,
				 playImage.size.height);
  playButton.center = CGPointMake(self.view.bounds.size.width / 2,
				  self.view.bounds.size.height * 0.35f);
  playButton.frame = CGRectInt(playButton.frame);
  playButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:playButton];
  
  UIImage *yourLevelsImage = I.images.menuYourLevels;
  UIButton *yourLevelsButton = [[[UIButton alloc] init] autorelease];
  [yourLevelsButton addTarget:self
		       action:@selector(clickYourLevels:)
	     forControlEvents:UIControlEventTouchUpInside];
  [yourLevelsButton setImage:yourLevelsImage
		    forState:UIControlStateNormal];
  yourLevelsButton.bounds = CGRectMake(0, 0,
				       yourLevelsImage.size.width,
				       yourLevelsImage.size.height);
  yourLevelsButton.center = CGPointMake(self.view.bounds.size.width / 2,
					self.view.bounds.size.height * 0.56f);
  yourLevelsButton.frame = CGRectInt(yourLevelsButton.frame);
  yourLevelsButton.showsTouchWhenHighlighted = YES;
  yourLevelsButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:yourLevelsButton];
  
  UIImage *tutorialImage = I.images.menuTutorial;
  UIButton *tutorialButton = [[[UIButton alloc] init] autorelease];
  [tutorialButton addTarget:self
		     action:@selector(clickTutorial:)
	   forControlEvents:UIControlEventTouchUpInside];
  [tutorialButton setImage:tutorialImage
		  forState:UIControlStateNormal];
  tutorialButton.bounds = CGRectMake(0, 0,
				     tutorialImage.size.width,
				     tutorialImage.size.height);
  tutorialButton.center = CGPointMake(self.view.bounds.size.width / 2,
				      self.view.bounds.size.height * 0.68f);
  tutorialButton.frame = CGRectInt(tutorialButton.frame);
  tutorialButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:tutorialButton];
  
  UIImage *aboutImage = I.images.menuAbout;
  UIButton *aboutButton = [[[UIButton alloc] init] autorelease];
  [aboutButton addTarget:self
		  action:@selector(clickAbout:)
	forControlEvents:UIControlEventTouchUpInside];
  [aboutButton setImage:aboutImage
	       forState:UIControlStateNormal];
  aboutButton.bounds = CGRectMake(0, 0,
				  aboutImage.size.width,
				  aboutImage.size.height);
  aboutButton.center = CGPointMake(self.view.bounds.size.width / 2,
				   self.view.bounds.size.height * 0.8f);
  aboutButton.frame = CGRectInt(aboutButton.frame);
  aboutButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:aboutButton];
  
  
  UIImage *scaleBarsImage = I.images.scaleBars;
  UIImage *scaleFadeImage = I.images.scaleFade;
  
  UISlider *dpadSetting = [[[UISlider alloc] init] autorelease];
  dpadSetting.minimumValue = 0.0f;
  dpadSetting.maximumValue = 0.8f;
  dpadSetting.value = [[NSUserDefaults standardUserDefaults]
		       floatForKey:SlippySettingDPadAlpha];
  [dpadSetting addTarget:self
		  action:@selector(changeDPadSetting:)
	forControlEvents:UIControlEventValueChanged];
  [dpadSetting setThumbImage:I.images.dpadIcon
		    forState:UIControlStateNormal];
  [dpadSetting setThumbImage:I.images.dpadIcon
		    forState:UIControlStateHighlighted];
  // disable slider scale images
  [dpadSetting setMinimumTrackImage:[[[UIImage alloc] init] autorelease]
			   forState:UIControlStateNormal];
  [dpadSetting setMaximumTrackImage:[[[UIImage alloc] init] autorelease]
			   forState:UIControlStateNormal];
  dpadSetting.bounds = CGRectMake(0, 0,
				  scaleFadeImage.size.width,
				  scaleFadeImage.size.height);
  dpadSetting.center = CGPointMake(self.view.bounds.size.width * 0.87f,
				   self.view.bounds.size.height - scaleBarsImage.size.height * 2.5f * 1.5f);
  dpadSetting.frame = CGRectInt(dpadSetting.frame);
  dpadSetting.alpha = 0.4f;
  [self.view addSubview:dpadSetting];
  UIImageView *dpadScale = [[[UIImageView alloc] initWithImage:scaleFadeImage]
			    autorelease];
  dpadScale.center = CGPointMake(self.view.bounds.size.width * 0.87f,
				 self.view.bounds.size.height - scaleBarsImage.size.height * 2.5f * 1.5f);
  dpadScale.frame = CGRectInt(dpadScale.frame);
  [self.view addSubview:dpadScale];
  [self.view sendSubviewToBack:dpadScale];
  self.dpadSettingsDisableImage = [[[UIImageView alloc]
				    initWithImage:I.images.disable]
				   autorelease];
  self.dpadSettingsDisableImage.hidden = YES;
  [self.view addSubview:self.dpadSettingsDisableImage];
  [self dpadUpdateImages:dpadSetting];
  
  UISlider *effectVolume = [[[UISlider alloc] init] autorelease];
  effectVolume.minimumValue = 0.0f;
  effectVolume.maximumValue = 1.0f;
  effectVolume.value = [SlippyAudio effectVolume];
  [effectVolume addTarget:self
		   action:@selector(changeEffectVolume:)
	 forControlEvents:UIControlEventValueChanged];
  [effectVolume addTarget:self
		   action:@selector(changeEffectVolumeTest:)
	 forControlEvents:UIControlEventTouchUpInside];
  [effectVolume setThumbImage:I.images.effect
		     forState:UIControlStateNormal];
  [effectVolume setThumbImage:I.images.effect
		     forState:UIControlStateHighlighted];
  // disable slider scale images
  [effectVolume setMinimumTrackImage:[[[UIImage alloc] init] autorelease]
			    forState:UIControlStateNormal];
  [effectVolume setMaximumTrackImage:[[[UIImage alloc] init] autorelease]
			    forState:UIControlStateNormal];
  effectVolume.bounds = CGRectMake(0, 0,
				   scaleBarsImage.size.width,
				   scaleBarsImage.size.height);
  effectVolume.center = CGPointMake(self.view.bounds.size.width * 0.87f,
				    self.view.bounds.size.height - scaleBarsImage.size.height * 1.5f * 1.5f);
  effectVolume.frame = CGRectInt(effectVolume.frame);
  [self.view addSubview:effectVolume];
  UIImageView *effectScale = [[[UIImageView alloc] initWithImage:scaleBarsImage]
			      autorelease];
  effectScale.center = CGPointMake(self.view.bounds.size.width * 0.87f,
				   self.view.bounds.size.height - scaleBarsImage.size.height * 1.5f * 1.5f);
  effectScale.frame = CGRectInt(effectScale.frame);
  [self.view addSubview:effectScale];
  [self.view sendSubviewToBack:effectScale];
  
  UISlider *musicVolume = [[[UISlider alloc] init] autorelease];
  musicVolume.minimumValue = 0.0f;
  musicVolume.maximumValue = 1.0f;
  musicVolume.value = [SlippyAudio musicVolume];
  [musicVolume addTarget:self
		  action:@selector(changeMusicVolume:)
	forControlEvents:UIControlEventValueChanged];
  [musicVolume setThumbImage:I.images.music
		    forState:UIControlStateNormal];
  [musicVolume setThumbImage:I.images.music
		    forState:UIControlStateHighlighted];
  // disable slider scale images
  [musicVolume setMinimumTrackImage:[[[UIImage alloc] init] autorelease]
			   forState:UIControlStateNormal];
  [musicVolume setMaximumTrackImage:[[[UIImage alloc] init] autorelease]
			   forState:UIControlStateNormal];
  musicVolume.bounds = CGRectMake(0, 0,
				  scaleBarsImage.size.width,
				  scaleBarsImage.size.height);
  musicVolume.center = CGPointMake(self.view.bounds.size.width * 0.87f,
				   self.view.bounds.size.height - scaleBarsImage.size.height * 0.5 * 1.5f);
  musicVolume.frame = CGRectInt(musicVolume.frame);
  [self.view addSubview:musicVolume];
  UIImageView *musicScale = [[[UIImageView alloc] initWithImage:scaleBarsImage]
			     autorelease];
  musicScale.center = CGPointMake(self.view.bounds.size.width * 0.87f,
				  self.view.bounds.size.height - scaleBarsImage.size.height * 0.5 * 1.5f);
  musicScale.frame = CGRectInt(musicScale.frame);
  [self.view addSubview:musicScale];
  [self.view sendSubviewToBack:musicScale];
}

- (void)unloadView {
  self.slippyImage = nil;
  self.slippyImageBlink = nil;
  [self.slippyTimer invalidate];
  self.slippyTimer = nil;
  
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

@end
