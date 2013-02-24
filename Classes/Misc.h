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

typedef enum MiscDeviceModelEnum {
  MiscDeviceModelIPhone,
  MiscDeviceModelIPod,
  MiscDeviceModelIPad
} MiscDeviceModelType;

extern CGFloat _CGScale;
extern BOOL _CGHasScaleFunctions;
extern NSInteger _IOSVersion;
extern MiscDeviceModelType _DeviceModel;


#define CLAMP(v, min, max) (((v) < (min) ? (min) : (v) > (max) ? (max) : v))


void _MiscInit(void);
CGContextRef _CGBitmapContextCreate(CGSize size);
void _CGContextRelease(CGContextRef context);
UIImage *_CGUIImageFromContext(CGContextRef context);


CG_INLINE CGPoint CGPointDelta(CGPoint pos, CGPoint dpos) {
  pos.x += dpos.x;
  pos.y += dpos.y;
  
  return pos;
}

CG_INLINE CGPoint CGPointMulti(CGPoint pos, float m) {
  pos.x *= m;
  pos.y *= m;
  
  return pos;
}

CG_INLINE CGRect CGRectMove(CGRect rect, float x, float y) {
  rect.origin.x += x;
  rect.origin.y += y;
  
  return rect;
}

CG_INLINE NSString* CGRectString(CGRect rect) {
  return [NSString stringWithFormat:@"CGRect(%f, %f, %f, %f)",
          rect.origin.x, rect.origin.y,
          rect.size.width, rect.size.height];
}

CG_INLINE CGRect CGRectInt(CGRect rect) {
  return CGRectMake(round(rect.origin.x),
		    round(rect.origin.y),
		    round(rect.size.width),
		    round(rect.size.height));
}

CG_INLINE CGRect CGRectSize(CGSize size) {
  return CGRectMake(0,
		    0,
		    size.width,
		    size.height);
}

NSDate *_compileDate(void);
NSString *_pathToResource(NSString *component);
NSString *_pathToDocument(NSString *component);
NSInteger _IOSVersionAsInteger(void);
MiscDeviceModelType _DeviceModelAsEnum(void);
