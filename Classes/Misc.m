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

CGFloat _CGScale;
BOOL _CGHasScaleFunctions;
NSInteger _IOSVersion;
MiscDeviceModelType _DeviceModel;


void _MiscInit(void) {
  if (UIGraphicsBeginImageContextWithOptions == NULL) {
    _CGHasScaleFunctions = NO;
  } else {
    _CGHasScaleFunctions = YES;
  }
  
  // Only care about scale if scale functions exist
  // Fixes problem with iPad in iPhone 2x mode (scale is 2 but no functions)
  // TODO: native iPad
  UIScreen *screen = [UIScreen mainScreen];
  if (_CGHasScaleFunctions &&
      [screen respondsToSelector:@selector(scale)]) {
    _CGScale = screen.scale;
  } else {
    _CGScale = 1;
  }
  
  _IOSVersion = _IOSVersionAsInteger();

  _DeviceModel = _DeviceModelAsEnum();
}

// only use _CGContextRelease with _CGBitmapContextCreate 
CGContextRef _CGBitmapContextCreate(CGSize size) {
  size = CGSizeMake(size.width * _CGScale, size.height * _CGScale);
  
  void *data = malloc(size.width * 4 * size.height);
  
  CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(data,
                                               size.width, size.height,
                                               8,
                                               4 * size.width,
                                               colorSpaceRef,
                                               kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(colorSpaceRef);
  CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
  CGContextClearRect(context, rect);
  
  return context;
}

void _CGContextRelease(CGContextRef context) {
  if (CFGetRetainCount(context) == 1) {
    free(CGBitmapContextGetData(context));
  }
  
  CGContextRelease(context);
}

UIImage *_CGUIImageFromContext(CGContextRef context) {
  CGImageRef cgImage = CGBitmapContextCreateImage(context);
  
  UIImage *image;
  if(_CGHasScaleFunctions) {
    image = [UIImage imageWithCGImage:cgImage
                                scale:_CGScale
                          orientation:UIImageOrientationUp];
  } else {
    image = [UIImage imageWithCGImage:cgImage];
  }  
  CGImageRelease(cgImage);
  
  return image;
}

NSDate *_compileDate(void) {
  NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
  [df setDateFormat:@"MMM d yyyy HH:mm:SS"];
  [df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]
                 autorelease]];
  return [df dateFromString:[NSString stringWithUTF8String:
                             __DATE__ " " __TIME__]];
}

NSString *_pathToResource(NSString *component) {
  return [[[NSBundle mainBundle] resourcePath]
          stringByAppendingPathComponent:component];
}

NSString *_pathToDocument(NSString *component) {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask,
                                                       YES);
  return [((NSString *)[paths objectAtIndex:0])
          stringByAppendingPathComponent:component];
}

// from http://stackoverflow.com/questions/3862933/check-ios-version-at-runtime
NSInteger _IOSVersionAsInteger(void) {
  int index = 0;
  NSInteger version = 0;
  
  NSArray* digits = [[UIDevice currentDevice].systemVersion
		     componentsSeparatedByString:@"."];
  NSEnumerator* enumer = [digits objectEnumerator];
  NSString* number;
  while ((number = [enumer nextObject])) {
    if (index>2) {
      break;
    }
    NSInteger multipler = powf(100, 2-index);
    version += [number intValue]*multipler;
    index++;
  }
  
  return version;
}

MiscDeviceModelType _DeviceModelAsEnum(void) {
  NSString *model = [UIDevice currentDevice].model;
  
  if ([model rangeOfString:@"iPhone"].location != NSNotFound) {
    return MiscDeviceModelIPhone;
  } else if ([model rangeOfString:@"iPod"].location != NSNotFound) {
    return MiscDeviceModelIPod;
  } else if ([model rangeOfString:@"iPad"].location != NSNotFound) {
    return MiscDeviceModelIPad;
  }
  
  return MiscDeviceModelIPhone;
}

