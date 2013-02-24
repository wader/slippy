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

#import "AboutViewController.h"
#import "SlippyLabel.h"

@interface NSString (stringByReplacingStringDict)

- (NSString *)stringByReplacingStringDict:(NSDictionary *)dict;

@end

@implementation NSString (stringByReplacingStringDict)

- (NSString *)stringByReplacingStringDict:(NSDictionary *)dict {
  NSString *r = [[self copy] autorelease];
  
  for (NSString *key in dict) {
    r = [r stringByReplacingOccurrencesOfString:key
				     withString:[dict objectForKey:key]];
  }
  
  return r;
}

@end


@implementation AboutViewController

+ (NSString *)name {
  return @"About";
}

- (IBAction)clickBack:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)inWeb
shouldStartLoadWithRequest:(NSURLRequest *)inRequest
navigationType:(UIWebViewNavigationType)inType {
  if (inType == UIWebViewNavigationTypeLinkClicked) {
    [[UIApplication sharedApplication] openURL:[inRequest URL]];
    return NO;
  }
  
  return YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIWebView *content = [[[UIWebView alloc] init] autorelease];
  content.frame = self.view.frame;
  content.backgroundColor = [UIColor clearColor];
  content.opaque = NO;
  content.delegate = self;
    
  NSString *html = [NSString
                    stringWithContentsOfURL:
                    [[[NSURL alloc] initFileURLWithPath:
                      [[NSBundle mainBundle] pathForResource:@"about"
                                                      ofType:@"html"]]
                     autorelease]
                    encoding:NSUTF8StringEncoding
                    error:NULL];
  
  UIImage *logo = I.images.slippy;
  
  html = [html stringByReplacingStringDict:
	  [NSDictionary dictionaryWithObjectsAndKeys:
	   [[NSBundle mainBundle]
	    objectForInfoDictionaryKey:@"CFBundleVersion"],
	   @"%VERSION%",
	   _CGScale == 2.0 || _DeviceModel == MiscDeviceModelIPad ?
	   [NSString stringWithFormat:@"images/slippy@2x%@.png",
            _DeviceModel == MiscDeviceModelIPad ? @"~ipad" : @""] :
	   @"images/slippy.png" ,
           
	   @"%LOGO_SRC%",
	   [NSString stringWithFormat:@"%d", (int)logo.size.width],
	   @"%LOGO_WIDTH%",
	   [NSString stringWithFormat:@"%d", (int)logo.size.height],
	   @"%LOGO_HEIGHT%",
	   nil]];
  
  [content loadHTMLString:html
                  baseURL:[NSURL fileURLWithPath:
                           [[NSBundle mainBundle] resourcePath]]];
  /* HACK: remove scroll off fade at top and bottom */
  id scroller = [content.subviews objectAtIndex:0];
  for (UIView *subView in [scroller subviews])
    if ([[[subView class] description] isEqualToString:@"UIImageView"])
      subView.hidden = YES;
  [self.view addSubview:content];
  
  UIImage *leftImage = I.images.left;
  UIButton *backwardButton = [[[UIButton alloc] init] autorelease];
  [backwardButton addTarget:self
                     action:@selector(clickBack:)
           forControlEvents:UIControlEventTouchUpInside];
  [backwardButton setImage:leftImage
                  forState:UIControlStateNormal];
  backwardButton.bounds = CGRectSize(leftImage.size);
  backwardButton.center = CGPointMake(leftImage.size.width / 2,
				      leftImage.size.height / 2);
  backwardButton.frame = CGRectInt(backwardButton.frame);
  [self.view addSubview:backwardButton];
}

@end
