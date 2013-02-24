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

#import "EditViewController.h"
#import "PlayGameViewController.h"
#import "GameTileView.h"
#import "LevelDatabase.h"
#import "UIImage+extra.h"
#import "ObservableHTTPRequest.h"
#import "SlippyHTTP.h"


enum {
  DeleteTag,
  UploadTag
};

enum type {
  TYPE_EMPTY,
  TYPE_SCORE,
  TYPE_BLOCK,
  TYPE_SOLID,
  TYPE_MOVEABLE,
  TYPE_PLAYER
};

@interface EditViewController ()

@property(nonatomic, retain) SlippyLevel *level;
@property(nonatomic, retain) UIButton *typeEmptyButton;
@property(nonatomic, retain) UIButton *typeScoreButton;
@property(nonatomic, retain) UIButton *typeBlockButton;
@property(nonatomic, retain) UIButton *typeSolidButton;
@property(nonatomic, retain) UIButton *typeMoveableButton;
@property(nonatomic, retain) UIButton *typePlayerButton;
@property(nonatomic, retain) EditTileView *editView;
@property(nonatomic, retain) UIButton *currentType;
@property(nonatomic, retain) NSTimer *saveTimer;
@property(nonatomic, retain) BlockingUIView *infoView;
@property(nonatomic, retain) UITextField *infoName;
@property(nonatomic, retain) UITextField *infoAuthor;
@property(nonatomic, retain) UITextField *infoEmail;

@property(nonatomic, retain) BlockingUIView *infoEventBlockerView;

@property(nonatomic, retain) UIButton *undoButton;
@property(nonatomic, retain) UIButton *uploadButton;
@property(nonatomic, retain) UIActivityIndicatorView *uploadActivity;

@property(nonatomic, assign) BOOL isObserving;

@property(nonatomic, retain) NSMutableArray *undoStack;

@end


@implementation EditViewController

@synthesize level;
@synthesize typeEmptyButton;
@synthesize typeScoreButton;
@synthesize typeBlockButton;
@synthesize typeSolidButton;
@synthesize typeMoveableButton;
@synthesize typePlayerButton;
@synthesize editView;
@synthesize currentType;
@synthesize saveTimer;
@synthesize infoView;
@synthesize infoName;
@synthesize infoAuthor;
@synthesize infoEmail;

@synthesize infoEventBlockerView;

@synthesize undoButton;
@synthesize uploadButton;
@synthesize uploadActivity;

@synthesize isObserving;

@synthesize undoStack;

+ (NSString *)name {
  return @"Edit";
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {  
  if ([keyPath isEqualToString:SlippyHTTPUploadLevelName]) {
    NSDictionary *dict = [change objectForKey:NSKeyValueChangeNewKey];
    NSString *event = [dict objectForKey:ObservableHTTPRequestDictEventKey];
    
    if ([event isEqualToString:ObservableHTTPRequestEventFinish]) {
      NSNumber *statusCode = [dict objectForKey:ObservableHTTPRequestDictStatusCodeKey];
      
      if ([statusCode intValue] == 200) {
        [self.uploadButton setImage:I.images.uploadCheck
                           forState:UIControlStateNormal];
        [self.uploadActivity stopAnimating];
      } else {
        [self.uploadButton setImage:I.images.uploadRain
                           forState:UIControlStateNormal];
        [self.uploadActivity stopAnimating];
      }
    } else if ([event isEqualToString:ObservableHTTPRequestEventRequesting]) {
      [self.uploadButton setImage:I.images.uploadSun
                         forState:UIControlStateNormal];
      [self.uploadActivity startAnimating];
    } else if ([event isEqualToString:ObservableHTTPRequestEventError]) {
      [self.uploadButton setImage:I.images.uploadRain
                         forState:UIControlStateNormal];
      [self.uploadActivity stopAnimating];
    }
  }
}

- (void)goBack {
  [self.saveTimer invalidate];
  self.saveTimer = nil;
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)wobbleMoveAnimation:(CALayer *)layer
                       from:(CGPoint)from
                         to:(CGPoint)to
               wobbleVector:(CGPoint)wobbleVector {  
  CGPoint wobble, wobble2;
  wobble = CGPointDelta(to, wobbleVector);
  wobble2 = CGPointDelta(to, CGPointMake(-wobbleVector.x / 2,
                                         -wobbleVector.y / 2));
  
  NSMutableArray *anims = [NSMutableArray array];
  
  CABasicAnimation *anim;
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:from];
  anim.toValue = [NSValue valueWithCGPoint:wobble];
  anim.duration = 0.25f;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:wobble];
  anim.toValue = [NSValue valueWithCGPoint:wobble2];
  anim.beginTime = 0.25f;
  anim.duration = 0.25f;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  anim = [CABasicAnimation animationWithKeyPath:@"position"];
  anim.fromValue = [NSValue valueWithCGPoint:wobble2];
  anim.toValue = [NSValue valueWithCGPoint:to];
  anim.beginTime = 0.5f;
  anim.duration = 0.25f;
  anim.timingFunction = [CAMediaTimingFunction
                         functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [anims addObject:anim];
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.duration = 0.75f;
  group.animations = anims;
  [layer addAnimation:group forKey:nil];
}

- (void)infoViewShown:(BOOL)shown {
  CGPoint delta, wobble;
  float opacityTo;
  
  if (shown) {
    delta = CGPointMake(0, self.view.bounds.size.height);
    wobble = CGPointMake(0, 10);
    [self.infoName becomeFirstResponder];
    self.infoEventBlockerView.userInteractionEnabled = YES;
    opacityTo = 0.3f;
  } else {
    delta = CGPointMake(0, -self.view.bounds.size.height);
    wobble = CGPointMake(0, -10);
    self.infoEventBlockerView.userInteractionEnabled = NO;
    opacityTo = 0.0f;
    
    [self.infoName resignFirstResponder];
    [self.infoAuthor resignFirstResponder];
    [self.infoEmail resignFirstResponder];
  }
  
  CGPoint from = self.infoView.layer.position;
  self.infoView.layer.position = CGPointDelta(self.infoView.layer.position,
                                              delta);
  [self wobbleMoveAnimation:self.infoView.layer
                       from:from
                         to:self.infoView.layer.position
               wobbleVector:wobble];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.25f];
  self.infoEventBlockerView.backgroundColor = [UIColor colorWithWhite:0
                                                                alpha:opacityTo];
  [UIView commitAnimations];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (alertView.tag == DeleteTag && buttonIndex == 1) {
    [[LevelDatabase shared] deleteLeveLWithId:self.level.id_];
    [self goBack];
  } else if (alertView.tag == UploadTag && buttonIndex == 1) {
    self.level.data = [self.editView levelData];
    [[LevelDatabase shared] saveYourLevels];
    [SlippyHTTP uploadLevel:self.level];
    
    [[NSUserDefaults standardUserDefaults] setValue:self.level.author
                                             forKey:SlippySettingAuthorName];
    [[NSUserDefaults standardUserDefaults] setValue:self.level.email
                                             forKey:SlippySettingEmail];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self infoViewShown:NO];
  }
}

- (void)selectType:(UIButton *)button {
  if (self.currentType != nil) {
    self.currentType.backgroundColor = nil;
  }
  self.currentType = button;
  self.currentType.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
  
  switch (button.tag) {
    case TYPE_EMPTY:
      [self.editView setType:self.editView.typeEmpty];
      break;
    case TYPE_SCORE:
      [self.editView setType:self.editView.typeScore];
      break;
    case TYPE_BLOCK:
      [self.editView setType:self.editView.typeBlock];
      break;
    case TYPE_SOLID:
      [self.editView setType:self.editView.typeSolid];
      break;
    case TYPE_MOVEABLE:
      [self.editView setType:self.editView.typeMoveable];
      break;
    case TYPE_PLAYER:
      [self.editView setType:self.editView.typePlayer];
      break;
    default:
      break;
  }
}

- (void)saveLevelIfDataChange {
  NSString *data = [self.editView levelData];
  
  if ([self.level.data isEqualToString:data]) {
    return;
  }
  
  self.level.data = data;
  
  [[LevelDatabase shared] saveYourLevels];
}

- (void)touchBlockingView:(id)sender {
  [self infoViewShown:NO];
}

- (void)clickInfoViewClose:(id)sender {
  [self infoViewShown:NO];
}

- (IBAction)clickType:(id)sender {
  [self selectType:(UIButton *)sender];
}

- (IBAction)clickBack:(id)sender {
  [self saveLevelIfDataChange];
  [self goBack];
}

- (BOOL)alertIfNotValidLevel:(NSString *)title {
  if ([self.editView findType:self.editView.typePlayer] == nil ||
      [self.editView findType:self.editView.typeScore] == nil) {
    [[[[UIAlertView alloc]
       initWithTitle:title
       message:
       @"Sorry, your level does not have a start position "
       @"or fishes to eat! please fix that and try again."
       delegate:nil
       cancelButtonTitle:@"OK"
       otherButtonTitles:nil]
      autorelease]
     show];
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {  
  UIAlertView *alert = [[[UIAlertView alloc]
                         initWithTitle:@"Upload agreement"
                         message:
                         @"Do you really want to upload this level?\n"
                         @"\n"
                         @"By uploading you agree that your level will be "
                         @"available to other Slippy users."
                         delegate:self
                         cancelButtonTitle:@"No"
                         otherButtonTitles:@"Yes", nil]
                        autorelease];
  alert.tag = UploadTag;
  [alert show];
  
  return NO;
}

- (void)beforeChange {
  [self.undoStack addObject:[self.editView levelData]];
  self.undoButton.enabled = YES;
  self.level.completedAfterEdit = NO;
}

- (IBAction)clickUndo:(id)sender {
  self.level.data = [self.undoStack lastObject];
  [self.editView loadLevel:self.level];
  
  [self.undoStack removeLastObject];
  self.undoButton.enabled = [self.undoStack count] > 0;
}

- (IBAction)clickDelete:(id)sender {
  UIAlertView *alert = [[[UIAlertView alloc]
                         initWithTitle:@"Delete level"
                         message:@"Do you really want to delete this level?"
                         delegate:self
                         cancelButtonTitle:@"No"
                         otherButtonTitles:@"Yes", nil]
                        autorelease];
  alert.tag = DeleteTag;
  [alert show];
}

- (IBAction)clickUpload:(id)sender {
  if (self.level.uploaded) {
    [[[[UIAlertView alloc]
       initWithTitle:@"Upload level"
       message:
       @"Sorry, this level has already been uploaded."
       delegate:nil
       cancelButtonTitle:@"OK"
       otherButtonTitles:nil]
      autorelease]
     show];
  } else if ([self alertIfNotValidLevel:@"Upload level"]) {
    /* nothing, alert already shown */
  } else if (!self.level.completedAfterEdit) {
    [[[[UIAlertView alloc]
       initWithTitle:@"Upload level"
       message:
       @"Sorry, you have to play and complete your level before uploading!"
       delegate:nil
       cancelButtonTitle:@"OK"
       otherButtonTitles:nil]
      autorelease]
     show];
  } else {    
    [self infoViewShown:YES];
  }
}

- (IBAction)changeValueInfoView:(id)sender {
  self.level.name = self.infoName.text;
  self.level.author = self.infoAuthor.text;
  self.level.email = self.infoEmail.text;
  
  [[LevelDatabase shared] saveYourLevels];
}

- (IBAction)clickPlay:(id)sender {
  if ([self alertIfNotValidLevel:@"Play level"]) {
    return;
  }
  
  self.level.data = [self.editView levelData];
  [self.navigationController
   pushViewController:[[[PlayGameViewController alloc]
                        initWithLevel:self.level]
                       autorelease]
   animated:YES];
}

- (void)saveTimerMethod:(NSTimer *)timer {
  [self saveLevelIfDataChange];
}

- (id)initWithLevel:(SlippyLevel *)aLevel {
  self = [self init];
  if (self == nil) {
    return nil;
  }
  
  self.level = aLevel;
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (self.state != nil) {
    NSString *slevel = [self.state objectForKey:@"level"];
    
    if (slevel != nil && [slevel isKindOfClass:[NSString class]]) {
      self.level = [[LevelDatabase shared] levelWithId:slevel];
    }
    
    if (self.level == nil) {
      [self.navigationController popViewControllerAnimated:NO];
      return;
    }
  } else {
    self.state = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.level.id_,
                  @"level",
                  nil];
    self.stateChanged = YES;
  }
  
  if (self.undoStack == nil) {
    self.undoStack = [NSMutableArray array];
  }
  
  self.editView = [[[EditTileView alloc]
                    initWithFrame:CGRectMake(0, self.barHeight,
					     self.view.bounds.size.width,
					     self.view.bounds.size.height -
					     self.barHeight)
		    skipFixed:NO]
                   autorelease];
  self.editView.editDelegate = self;
  [self.editView loadLevel:self.level];
  [self.view addSubview:editView];
  [self.view sendSubviewToBack:editView];
  
  UIImage *leftImage = I.images.left;
  UIButton *backwardButton = [[[UIButton alloc] init] autorelease];
  [backwardButton addTarget:self
                     action:@selector(clickBack:)
           forControlEvents:UIControlEventTouchUpInside];
  [backwardButton setImage:leftImage
                  forState:UIControlStateNormal];
  backwardButton.center = CGPointMake(leftImage.size.width / 2,
				      leftImage.size.height / 2);
  backwardButton.bounds = CGRectSize(leftImage.size);
  backwardButton.frame = CGRectInt(backwardButton.frame);
  backwardButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:backwardButton];
  
  UIImage *undoImage = I.images.undo;
  self.undoButton = [[[UIButton alloc] init] autorelease];
  [self.undoButton addTarget:self
		      action:@selector(clickUndo:)
	    forControlEvents:UIControlEventTouchUpInside];
  [self.undoButton setImage:undoImage
		   forState:UIControlStateNormal];
  undoButton.center = CGPointMake(self.view.bounds.size.width * 0.71f,
				  undoImage.size.height / 2);
  undoButton.bounds = CGRectSize(undoImage.size);
  undoButton.frame = CGRectInt(undoButton.frame);
  self.undoButton.showsTouchWhenHighlighted = YES;
  self.undoButton.enabled = [self.undoStack count] > 0;
  [self.view addSubview:self.undoButton];
  
  UIImage *deleteImage = I.images.delete_;
  UIButton *deleteButton = [[[UIButton alloc] init] autorelease];
  [deleteButton addTarget:self
                   action:@selector(clickDelete:)
         forControlEvents:UIControlEventTouchUpInside];
  [deleteButton setImage:deleteImage
                forState:UIControlStateNormal];
  deleteButton.center = CGPointMake(self.view.bounds.size.width * 0.78f,
				    deleteImage.size.height / 2);
  deleteButton.bounds = CGRectSize(deleteImage.size);
  deleteButton.frame = CGRectInt(deleteButton.frame);
  deleteButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:deleteButton];
  
  UIImage *uploadImage;
  if (self.level.uploaded) {
    uploadImage = I.images.uploadCheck;
  } else {
    uploadImage = I.images.upload;
  }
  self.uploadActivity = [[[UIActivityIndicatorView alloc]
			  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]
			 autorelease];
  self.uploadActivity.bounds = CGRectMake(0, 0,
					  uploadImage.size.width,
					  uploadImage.size.height);
  self.uploadActivity.center = CGPointMake(self.view.bounds.size.width * 0.85f,
					   uploadImage.size.height / 2);
  self.uploadActivity.center = CGPointDelta(self.uploadActivity.center,
					    CGPointMake(uploadImage.size.width * 0.3f,
							-uploadImage.size.width * 0.27f));
  self.uploadActivity.frame = CGRectInt(self.uploadActivity.frame);
  self.uploadActivity.hidesWhenStopped = YES;
  [self.view addSubview:self.uploadActivity];
  
  self.uploadButton = [[[UIButton alloc] init] autorelease];
  [self.uploadButton addTarget:self
                        action:@selector(clickUpload:)
              forControlEvents:UIControlEventTouchUpInside];
  [self.uploadButton setImage:uploadImage
		     forState:UIControlStateNormal];
  self.uploadButton.center = CGPointMake(self.view.bounds.size.width * 0.85f,
					 uploadImage.size.height / 2);
  self.uploadButton.bounds = CGRectSize(uploadImage.size);
  self.uploadButton.frame = CGRectInt(self.uploadButton.frame);
  self.uploadButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:self.uploadButton];
  
  UIImage *playImage = I.images.play;
  UIButton *playButton = [[[UIButton alloc] init] autorelease];
  [playButton addTarget:self
		 action:@selector(clickPlay:)
       forControlEvents:UIControlEventTouchUpInside];
  [playButton setImage:playImage
	      forState:UIControlStateNormal];
  playButton.center = CGPointMake(self.view.bounds.size.width -
				  playImage.size.width / 2,
				  playImage.size.height / 2);
  playButton.bounds = CGRectSize(playImage.size);
  playButton.frame = CGRectInt(playButton.frame);
  playButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:playButton];
  
  CGFloat cornerRadius = _DeviceModel == MiscDeviceModelIPad ? 10 : 5;
  
  UIImage *eraseImage = I.images.erase;
  UIButton *eraseButton = [[[UIButton alloc] init] autorelease];
  eraseButton.tag = TYPE_EMPTY;
  [eraseButton addTarget:self
		  action:@selector(clickType:)
	forControlEvents:UIControlEventTouchUpInside];
  [eraseButton setImage:eraseImage
	       forState:UIControlStateNormal];
  eraseButton.center = CGPointMake(self.view.bounds.size.width * 0.15f,
				   eraseImage.size.height / 2);
  eraseButton.bounds = CGRectSize(eraseImage.size);
  eraseButton.frame = CGRectInt(eraseButton.frame);
  eraseButton.layer.cornerRadius = cornerRadius;
  eraseButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:eraseButton];
  self.typeEmptyButton = eraseButton;
  
  UIImage *solidImage = I.images.solid;
  UIButton *solidButton = [[[UIButton alloc] init] autorelease];
  solidButton.tag = TYPE_SOLID;
  [solidButton addTarget:self
		  action:@selector(clickType:)
	forControlEvents:UIControlEventTouchUpInside];
  [solidButton setImage:solidImage
	       forState:UIControlStateNormal];
  solidButton.center = CGPointMake(self.view.bounds.size.width * 0.22f,
				   solidImage.size.height / 2);
  solidButton.bounds = CGRectSize(solidImage.size);
  solidButton.frame = CGRectInt(solidButton.frame);
  solidButton.layer.cornerRadius = cornerRadius;
  solidButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:solidButton];
  self.typeSolidButton = solidButton;
  
  UIImage *blockImage = I.images.block;
  UIButton *blockButton = [[[UIButton alloc] init] autorelease];
  blockButton.tag = TYPE_BLOCK;
  [blockButton addTarget:self
		  action:@selector(clickType:)
	forControlEvents:UIControlEventTouchUpInside];
  [blockButton setImage:blockImage
	       forState:UIControlStateNormal];
  blockButton.center = CGPointMake(self.view.bounds.size.width * 0.29f,
				   blockImage.size.height / 2);
  blockButton.bounds = CGRectSize(blockImage.size);
  blockButton.frame = CGRectInt(blockButton.frame);
  blockButton.layer.cornerRadius = cornerRadius;
  blockButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:blockButton];
  self.typeBlockButton = blockButton;
  
  UIImage *moveableImage = I.images.moveable;
  UIButton *moveableButton = [[[UIButton alloc] init] autorelease];
  moveableButton.tag = TYPE_MOVEABLE;
  [moveableButton addTarget:self
		     action:@selector(clickType:)
	   forControlEvents:UIControlEventTouchUpInside];
  [moveableButton setImage:moveableImage
		  forState:UIControlStateNormal];
  moveableButton.center = CGPointMake(self.view.bounds.size.width * 0.36f,
				      moveableImage.size.height / 2);
  moveableButton.bounds = CGRectSize(moveableImage.size);
  moveableButton.frame = CGRectInt(moveableButton.frame);
  moveableButton.layer.cornerRadius = cornerRadius;
  moveableButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:moveableButton];
  self.typeMoveableButton = moveableButton;
  
  UIImage *scoreImage = I.images.score;
  UIButton *scoreButton = [[[UIButton alloc] init] autorelease];
  scoreButton.tag = TYPE_SCORE;
  [scoreButton addTarget:self
		  action:@selector(clickType:)
	forControlEvents:UIControlEventTouchUpInside];
  [scoreButton setImage:scoreImage
	       forState:UIControlStateNormal];
  scoreButton.center = CGPointMake(self.view.bounds.size.width * 0.43f,
				   scoreImage.size.height / 2);
  scoreButton.bounds = CGRectSize(scoreImage.size);
  scoreButton.frame = CGRectInt(scoreButton.frame);
  scoreButton.layer.cornerRadius = cornerRadius;
  scoreButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:scoreButton];
  self.typeScoreButton = scoreButton;
  
  UIImage *playerImage = I.images.player;
  UIButton *playerButton = [[[UIButton alloc] init] autorelease];
  playerButton.tag = TYPE_PLAYER;
  [playerButton addTarget:self
		   action:@selector(clickType:)
	 forControlEvents:UIControlEventTouchUpInside];
  [playerButton setImage:playerImage
		forState:UIControlStateNormal];
  playerButton.center = CGPointMake(self.view.bounds.size.width * 0.5f,
				    playerImage.size.height / 2);
  playerButton.bounds = CGRectSize(playerImage.size);
  playerButton.frame = CGRectInt(playerButton.frame);
  playerButton.layer.cornerRadius = cornerRadius;
  playerButton.showsTouchWhenHighlighted = YES;
  [self.view addSubview:playerButton];
  self.typePlayerButton = playerButton;
  
  [self selectType:self.typeSolidButton];
  
  
  self.infoEventBlockerView = [[[BlockingUIView alloc] init] autorelease];
  self.infoEventBlockerView.touchTarget = self;
  self.infoEventBlockerView.touchSelector = @selector(touchBlockingView:);
  self.infoEventBlockerView.frame = self.view.frame;
  self.infoEventBlockerView.userInteractionEnabled = NO;
  self.infoEventBlockerView.backgroundColor = [UIColor colorWithWhite:0.0f
                                                                alpha:0.0f];
  [self.view addSubview:self.infoEventBlockerView];
  
  self.infoView = [[[BlockingUIView alloc] init] autorelease];
  self.infoView.bounds = CGRectMake(0, 0, 440, 140);
  self.infoView.center = CGPointMake(self.view.bounds.size.width / 2,
				     self.view.bounds.size.width * 0.17f);
  self.infoView.frame = CGRectInt(self.infoView.frame);
  self.infoView.center = CGPointDelta(self.infoView.center,
				      CGPointMake(0,-self.view.bounds.size.height));
  
  self.infoView.backgroundColor = [UIColor colorWithWhite:0.0f
                                                    alpha:0.5f];
  self.infoView.layer.cornerRadius = cornerRadius;
  [self.infoEventBlockerView addSubview:self.infoView];
  
  UIButton *closeButton = [[[UIButton alloc] init] autorelease];
  [closeButton addTarget:self
                  action:@selector(clickInfoViewClose:)
        forControlEvents:UIControlEventTouchUpInside];
  [closeButton setImage:I.images.close
               forState:UIControlStateNormal];
  closeButton.center = CGPointMake(0, 0);
  closeButton.frame = CGRectMake(self.infoView.frame.size.width - 30, 0,
                                 30, 30);
  closeButton.showsTouchWhenHighlighted = YES;
  [self.infoView addSubview:closeButton];
  
  CGFloat uploadTextFontSize = (int)(self.infoView.bounds.size.height / 8.0f);
  SlippyLabel *uploadText = [[[SlippyLabel alloc] init] autorelease];
  uploadText.text = @"Upload level";
  uploadText.fontSize = uploadTextFontSize;
  uploadText.textAlignment = UITextAlignmentCenter;
  uploadText.center = CGPointMake(self.infoView.bounds.size.width / 2,
				  self.infoView.bounds.size.height * 0.1f);
  uploadText.bounds = CGRectMake(0, 0, self.infoView.bounds.size.width,
				 uploadTextFontSize + 5);
  uploadText.frame = CGRectInt(uploadText.frame);
  [self.infoView addSubview:uploadText];
  
  CGFloat uploadFildsTextFontSize = (int)(self.infoView.bounds.size.height / 13.0f);
  SlippyLabel *uploadFildsText = [[[SlippyLabel alloc] init] autorelease];
  uploadFildsText.text = @"All fields are optional";
  uploadFildsText.fontSize = uploadFildsTextFontSize;
  uploadFildsText.fontSize = uploadFildsTextFontSize;
  uploadFildsText.textAlignment = UITextAlignmentCenter;
  uploadFildsText.center = CGPointMake(self.infoView.bounds.size.width / 2,
				       self.infoView.bounds.size.height * 0.21f);
  uploadFildsText.bounds = CGRectMake(0, 0, self.infoView.bounds.size.width,
				      uploadFildsTextFontSize + 5);
  uploadFildsText.frame = CGRectInt(uploadFildsText.frame);
  [self.infoView addSubview:uploadFildsText];
  
  self.infoName = [[[UITextField alloc] init] autorelease];
  self.infoName.font = [UIFont fontWithName:@"Arial Rounded MT Bold"
                                       size:[UIFont labelFontSize]];
  self.infoName.delegate = self;
  self.infoName.text = self.level.name;
  self.infoName.clearButtonMode = UITextFieldViewModeWhileEditing;
  self.infoName.borderStyle = UITextBorderStyleRoundedRect;
  self.infoName.returnKeyType = UIReturnKeySend;
  self.infoName.placeholder = @"Level name";
  self.infoName.center = CGPointMake(self.infoView.bounds.size.width / 2,
				     self.infoView.bounds.size.height * 0.4f);
  self.infoName.bounds = CGRectMake(0, 0,
				    self.infoView.bounds.size.width * 0.9f,
				    25);
  self.infoName.frame = CGRectInt(self.infoName.frame);
  [self.infoName addTarget:self
                    action:@selector(changeValueInfoView:)
          forControlEvents:UIControlEventEditingChanged];
  [self.infoView addSubview:self.infoName];
  
  self.infoAuthor = [[[UITextField alloc] init] autorelease];
  self.infoAuthor.font = [UIFont fontWithName:@"Arial Rounded MT Bold"
                                         size:[UIFont labelFontSize]];
  self.infoAuthor.delegate = self;
  self.infoAuthor.text = self.level.author;
  self.infoAuthor.clearButtonMode = UITextFieldViewModeWhileEditing;
  self.infoAuthor.borderStyle = UITextBorderStyleRoundedRect;
  self.infoAuthor.returnKeyType = UIReturnKeySend;
  self.infoAuthor.autocapitalizationType = UITextAutocapitalizationTypeWords;
  self.infoAuthor.placeholder = @"Author name";
  self.infoAuthor.center = CGPointMake(self.infoView.bounds.size.width / 2,
				       self.infoView.bounds.size.height * 0.6f);
  self.infoAuthor.bounds = CGRectMake(0, 0,
				      self.infoView.bounds.size.width * 0.9f,
				      25);
  self.infoAuthor.frame = CGRectInt(self.infoAuthor.frame);
  [self.infoAuthor addTarget:self
                      action:@selector(changeValueInfoView:)
            forControlEvents:UIControlEventEditingChanged];
  [self.infoView addSubview:self.infoAuthor];
  
  self.infoEmail = [[[UITextField alloc] init] autorelease];
  self.infoEmail.font = [UIFont fontWithName:@"Arial Rounded MT Bold"
                                        size:[UIFont labelFontSize]];
  self.infoEmail.delegate = self;
  self.infoEmail.text = self.level.email;
  self.infoEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
  self.infoEmail.keyboardType = UIKeyboardTypeEmailAddress;
  self.infoEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
  self.infoEmail.borderStyle = UITextBorderStyleRoundedRect;
  self.infoEmail.returnKeyType = UIReturnKeySend;
  self.infoEmail.placeholder = @"E-mail";
  self.infoEmail.center = CGPointMake(self.infoView.bounds.size.width / 2,
				      self.infoView.bounds.size.height * 0.8f);
  self.infoEmail.bounds = CGRectMake(0, 0,
				     self.infoView.bounds.size.width * 0.9f,
				     25);
  self.infoEmail.frame = CGRectInt(self.infoEmail.frame);
  [self.infoEmail addTarget:self
                     action:@selector(changeValueInfoView:)
           forControlEvents:UIControlEventEditingChanged];
  [self.infoView addSubview:self.infoEmail];
  
  
  self.saveTimer = [NSTimer
                    scheduledTimerWithTimeInterval:2.0f
                    target:self
                    selector:@selector(saveTimerMethod:)
                    userInfo:nil
                    repeats:YES];
  
  [[ObservableHTTPRequest shared] addObserver:self
                                   forKeyPath:SlippyHTTPUploadLevelName
                                      options:NSKeyValueObservingOptionNew
                                      context:NULL];
  self.isObserving = YES;
}

- (void)unloadView {
  if (self.isObserving) {
    [[ObservableHTTPRequest shared] removeObserver:self
                                        forKeyPath:SlippyHTTPUploadLevelName];
    self.isObserving = NO;
  }
  
  self.typeEmptyButton = nil;
  self.typeScoreButton = nil;
  self.typeBlockButton = nil;
  self.typeSolidButton = nil;
  self.typeMoveableButton = nil;
  self.typePlayerButton = nil;
  self.editView = nil;
  self.currentType = nil;
  
  if (self.saveTimer != nil) {
    [self.saveTimer invalidate];
    self.saveTimer = nil;
  }
  
  [self.undoButton removeFromSuperview];
  self.undoButton = nil;
  [self.uploadButton removeFromSuperview];
  self.uploadButton = nil;
  [self.uploadActivity removeFromSuperview];
  self.uploadActivity = nil;
  
  self.infoView = nil;
  self.infoName = nil;
  self.infoAuthor = nil;
  self.infoEmail = nil;
  
  [super unloadView];
}

- (void)viewDidUnload {
  [self unloadView];
  [super viewDidUnload];
}

- (void)dealloc {
  [self unloadView];
  
  self.undoStack = nil;
  
  [super dealloc];
}

@end
