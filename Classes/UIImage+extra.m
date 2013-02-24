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

#import "UIImage+extra.h"


@implementation UIImage (extra)

- (void)drawInContext:(CGContextRef)context
                  src:(CGRect)src
                  dst:(CGRect)dst {
  if (_CGScale != 1) {
    src = CGRectMake(src.origin.x * _CGScale,
                     src.origin.y * _CGScale,
                     src.size.width * _CGScale,
                     src.size.height * _CGScale);
    
    dst = CGRectMake(dst.origin.x * _CGScale,
                     dst.origin.y * _CGScale,
                     dst.size.width * _CGScale,
                     dst.size.height * _CGScale);
  }
  CGImageRef c = CGImageCreateWithImageInRect(self.CGImage, src);
  
  // TODO: figure out why
  dst.origin.y = CGBitmapContextGetHeight(context) - dst.size.height - dst.origin.y;
  
  CGContextDrawImage(context, dst, c);
  
  CGImageRelease(c);
}

- (UIImage *)UImageFromRect:(CGRect)rect {
  CGContextRef context = _CGBitmapContextCreate(rect.size);
  
  [self drawInContext:context
                  src:rect
                  dst:CGRectMake(0, 0, rect.size.width, rect.size.height)];
  UIImage *image = _CGUIImageFromContext(context);
  
  _CGContextRelease(context);
  
  return image;
}

- (UIImage *)monochrome {
  CGContextRef context = _CGBitmapContextCreate(self.size);
  
  CGContextDrawImage(context,
                     CGRectMake(0, 0,
                                CGImageGetWidth(self.CGImage),
                                CGImageGetHeight(self.CGImage)),
                     self.CGImage);
  
  CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
  CGContextSetBlendMode(context, kCGBlendModeSourceIn);
  CGContextFillRect(context,
                    CGRectMake(0, 0,
                               CGImageGetWidth(self.CGImage),
                               CGImageGetHeight(self.CGImage)));
  
  UIImage *image = _CGUIImageFromContext(context);
  _CGContextRelease(context);
  
  context = _CGBitmapContextCreate(self.size);
  
  CGContextDrawImage(context,
                     CGRectMake(0, 0,
                                CGImageGetWidth(self.CGImage),
                                CGImageGetHeight(self.CGImage)),
                     self.CGImage);
  CGContextSetBlendMode(context, kCGBlendModeColor);
  CGContextDrawImage(context,
                     CGRectMake(0, 0,
                                CGImageGetWidth(self.CGImage),
                                CGImageGetHeight(self.CGImage)),
                     image.CGImage);
  
  image = _CGUIImageFromContext(context);
  _CGContextRelease(context);
  
  return image;
}

- (UIImage *)maskWithImage:(UIImage *)image {  
  CGContextRef context = _CGBitmapContextCreate(self.size);
  CGContextDrawImage(context,
                     CGRectMake(0, 0,
                                CGImageGetWidth(self.CGImage),
                                CGImageGetHeight(self.CGImage)),
                     image.CGImage);
  UIImage *filled = _CGUIImageFromContext(context);
  _CGContextRelease(context);
  
  CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(self.CGImage),
                                      CGImageGetHeight(self.CGImage),
                                      CGImageGetBitsPerComponent(self.CGImage),
                                      CGImageGetBitsPerPixel(self.CGImage),
                                      CGImageGetBytesPerRow(self.CGImage),
                                      CGImageGetDataProvider(self.CGImage),
                                      NULL,
				      NO);
  CGImageRef masked = CGImageCreateWithMask(filled.CGImage, mask);
  CGImageRelease(mask);
  
  UIImage *maskImage;
  
  if(_CGHasScaleFunctions) {
    maskImage = [UIImage imageWithCGImage:masked
                                    scale:_CGScale
                              orientation:UIImageOrientationUp];
  } else {
    maskImage = [UIImage imageWithCGImage:masked];
  }
  
  CGImageRelease(masked);
  
  return maskImage;
}

- (UIImage *)maskWithColor:(UIColor *)color {  
  CGContextRef context = _CGBitmapContextCreate(self.size);
  CGContextSetFillColorWithColor(context, color.CGColor);
  CGContextFillRect(context,
                    CGRectMake(0, 0,
                               CGImageGetWidth(self.CGImage),
                               CGImageGetHeight(self.CGImage)));
  UIImage *filled = _CGUIImageFromContext(context);
  _CGContextRelease(context);
  
  CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(self.CGImage),
                                      CGImageGetHeight(self.CGImage),
                                      CGImageGetBitsPerComponent(self.CGImage),
                                      CGImageGetBitsPerPixel(self.CGImage),
                                      CGImageGetBytesPerRow(self.CGImage),
                                      CGImageGetDataProvider(self.CGImage),
                                      NULL,
				      NO);
  CGImageRef masked = CGImageCreateWithMask(filled.CGImage, mask);
  CGImageRelease(mask);

  UIImage *maskImage;
  
  if(_CGHasScaleFunctions) {
    maskImage = [UIImage imageWithCGImage:masked
                               scale:_CGScale
                         orientation:UIImageOrientationUp];
  } else {
    maskImage = [UIImage imageWithCGImage:masked];
  }
  
  CGImageRelease(masked);
  
  return maskImage;
}

- (UIImage *)maskInset:(BOOL)inset color:(UIColor *)color {
  CGContextRef context = _CGBitmapContextCreate(self.size);
  
  CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
  
  [[self maskWithColor:[UIColor blackColor]]
   drawInContext:context
   src:rect
   dst:rect]; 
  
  [[self maskWithColor:color]
   drawInContext:context
   src:rect
   dst:CGRectMove(rect, inset ? 1 : -1, inset ? 1 : -1)];
  
  UIImage *image = _CGUIImageFromContext(context);
  
  _CGContextRelease(context);
  
  return image;
}

- (UIImage *)maskInset:(BOOL)inset {
  return [self maskInset:inset color:[UIColor whiteColor]];
}

@end
