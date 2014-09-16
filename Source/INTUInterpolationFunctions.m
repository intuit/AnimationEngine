//
//  INTUInterpolationFunctions.m
//
//  Copyright (c) 2014 Intuit Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "INTUInterpolationFunctions.h"

id INTUInterpolateDiscreteValues(NSArray *values, CGFloat progress)
{
    if ([values count] == 0) {
        return nil;
    }
    NSInteger index = lround((progress * [values count]) - 0.5);
    index = MIN([values count] - 1, MAX(0, index));
    return values[index];
}

CGFloat INTUInterpolateCGFloat(CGFloat start, CGFloat end, CGFloat progress)
{
    return start * (1.0 - progress) + end * progress;
}

CGPoint INTUInterpolateCGPoint(CGPoint start, CGPoint end, CGFloat progress)
{
    CGFloat x = INTUInterpolateCGFloat(start.x, end.x, progress);
    CGFloat y = INTUInterpolateCGFloat(start.y, end.y, progress);
    return CGPointMake(x, y);
}

CGSize INTUInterpolateCGSize(CGSize start, CGSize end, CGFloat progress)
{
    CGFloat width = INTUInterpolateCGFloat(start.width, end.width, progress);
    CGFloat height = INTUInterpolateCGFloat(start.height, end.height, progress);
    return CGSizeMake(width, height);
}

CGRect INTUInterpolateCGRect(CGRect start, CGRect end, CGFloat progress)
{
    CGFloat x = INTUInterpolateCGFloat(start.origin.x, end.origin.x, progress);
    CGFloat y = INTUInterpolateCGFloat(start.origin.y, end.origin.y, progress);
    CGFloat width = INTUInterpolateCGFloat(start.size.width, end.size.width, progress);
    CGFloat height = INTUInterpolateCGFloat(start.size.height, end.size.height, progress);
    return CGRectMake(x, y, width, height);
}

CGVector INTUInterpolateCGVector(CGVector start, CGVector end, CGFloat progress)
{
    CGFloat dx = INTUInterpolateCGFloat(start.dx, end.dx, progress);
    CGFloat dy = INTUInterpolateCGFloat(start.dy, end.dy, progress);
    return CGVectorMake(dx, dy);
}

UIOffset INTUInterpolateUIOffset(UIOffset start, UIOffset end, CGFloat progress)
{
    CGFloat horizontal = INTUInterpolateCGFloat(start.horizontal, end.horizontal, progress);
    CGFloat vertical = INTUInterpolateCGFloat(start.vertical, end.vertical, progress);
    return UIOffsetMake(horizontal, vertical);
}

UIEdgeInsets INTUInterpolateUIEdgeInsets(UIEdgeInsets start, UIEdgeInsets end, CGFloat progress)
{
    CGFloat top = INTUInterpolateCGFloat(start.top, end.top, progress);
    CGFloat left = INTUInterpolateCGFloat(start.left, end.left, progress);
    CGFloat bottom = INTUInterpolateCGFloat(start.bottom, end.bottom, progress);
    CGFloat right = INTUInterpolateCGFloat(start.right, end.right, progress);
    return UIEdgeInsetsMake(top, left, bottom, right);
}

UIColor * INTUInterpolateUIColor(UIColor *start, UIColor *end, CGFloat progress)
{
    CGFloat startHue, startSaturation, startBrightness, startHSBAlpha;
    BOOL isHSBColorSpace = [start getHue:&startHue saturation:&startSaturation brightness:&startBrightness alpha:&startHSBAlpha];
    CGFloat endHue, endSaturation, endBrightness, endHSBAlpha;
    isHSBColorSpace &= [end getHue:&endHue saturation:&endSaturation brightness:&endBrightness alpha:&endHSBAlpha];
    if (isHSBColorSpace) {
        CGFloat hue = INTUInterpolateCGFloat(startHue, endHue, progress);
        CGFloat saturation = INTUInterpolateCGFloat(startSaturation, endSaturation, progress);
        CGFloat brightness = INTUInterpolateCGFloat(startBrightness, endBrightness, progress);
        CGFloat alpha = INTUInterpolateCGFloat(startHSBAlpha, endHSBAlpha, progress);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    
    CGFloat startRed, startGreen, startBlue, startRGBAlpha;
    BOOL isRGBColorSpace = [start getRed:&startRed green:&startGreen blue:&startBlue alpha:&startRGBAlpha];
    CGFloat endRed, endGreen, endBlue, endRGBAlpha;
    isRGBColorSpace &= [end getRed:&endRed green:&endGreen blue:&endBlue alpha:&endRGBAlpha];
    if (isRGBColorSpace) {
        CGFloat red = INTUInterpolateCGFloat(startRed, endRed, progress);
        CGFloat green = INTUInterpolateCGFloat(startGreen, endGreen, progress);
        CGFloat blue = INTUInterpolateCGFloat(startBlue, endBlue, progress);
        CGFloat alpha = INTUInterpolateCGFloat(startRGBAlpha, endRGBAlpha, progress);
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    
    CGFloat startWhite, startGrayscaleAlpha;
    BOOL isGrayscaleColorSpace = [start getWhite:&startWhite alpha:&startGrayscaleAlpha];
    CGFloat endWhite, endGrayscaleAlpha;
    isGrayscaleColorSpace &= [end getWhite:&endWhite alpha:&endGrayscaleAlpha];
    if (isGrayscaleColorSpace) {
        CGFloat white = INTUInterpolateCGFloat(startWhite, endWhite, progress);
        CGFloat alpha = INTUInterpolateCGFloat(startGrayscaleAlpha, endGrayscaleAlpha, progress);
        return [UIColor colorWithWhite:white alpha:alpha];
    }
    
    NSCAssert(false, @"Cannot interpolate between two UIColors in different color spaces.");
    return nil;
}

CGColorRef INTUInterpolateCGColor(CGColorRef start, CGColorRef end, CGFloat progress)
{
    return [INTUInterpolateUIColor([UIColor colorWithCGColor:start], [UIColor colorWithCGColor:end], progress) CGColor];
}

id INTUInterpolate(id start, id end, CGFloat progress)
{
    // NSNumber (CGFloat)
    if ([start isKindOfClass:[NSNumber class]] && [end isKindOfClass:[NSNumber class]]) {
#if CGFLOAT_IS_DOUBLE
        return [NSNumber numberWithDouble:INTUInterpolateCGFloat([(NSNumber *)start doubleValue], [(NSNumber *)end doubleValue], progress)];
#else
        return [NSNumber numberWithFloat:INTUInterpolateCGFloat([(NSNumber *)start floatValue], [(NSNumber *)end floatValue], progress)];
#endif /* CGFLOAT_IS_DOUBLE */
    }
    
    // NSValue
    if ([start isKindOfClass:[NSValue class]] && [end isKindOfClass:[NSValue class]]) {
        // CGPoint
        if (strcmp([start objCType], @encode(CGPoint)) == 0 && strcmp([end objCType], @encode(CGPoint)) == 0) {
            return [NSValue valueWithCGPoint:INTUInterpolateCGPoint([start CGPointValue], [end CGPointValue], progress)];
        }
        
        // CGSize
        if (strcmp([start objCType], @encode(CGSize)) == 0 && strcmp([end objCType], @encode(CGSize)) == 0) {
            return [NSValue valueWithCGSize:INTUInterpolateCGSize([start CGSizeValue], [end CGSizeValue], progress)];
        }
        
        // CGRect
        if (strcmp([start objCType], @encode(CGRect)) == 0 && strcmp([end objCType], @encode(CGRect)) == 0) {
            return [NSValue valueWithCGRect:INTUInterpolateCGRect([start CGRectValue], [end CGRectValue], progress)];
        }
        
        // UIOffset
        if (strcmp([start objCType], @encode(UIOffset)) == 0 && strcmp([end objCType], @encode(UIOffset)) == 0) {
            return [NSValue valueWithUIOffset:INTUInterpolateUIOffset([start UIOffsetValue], [end UIOffsetValue], progress)];
        }
        
        // UIEdgeInsets
        if (strcmp([start objCType], @encode(UIEdgeInsets)) == 0 && strcmp([end objCType], @encode(UIEdgeInsets)) == 0) {
            return [NSValue valueWithUIEdgeInsets:INTUInterpolateUIEdgeInsets([start UIEdgeInsetsValue], [end UIEdgeInsetsValue], progress)];
        }
    }
    
    // UIColor
    if ([start isKindOfClass:[UIColor class]] && [end isKindOfClass:[UIColor class]]) {
        return INTUInterpolateUIColor(start, end, progress);
    }
    
    // CGColor
    if ((CFGetTypeID((__bridge CFTypeRef)start) == CGColorGetTypeID()) && (CFGetTypeID((__bridge CFTypeRef)end) == CGColorGetTypeID())) {
        return [UIColor colorWithCGColor:INTUInterpolateCGColor((__bridge CGColorRef)start, (__bridge CGColorRef)end, progress)];
    }
    
    // Unknown/unsupported type, use proximal interpolation
    return INTUInterpolateDiscrete(start, end, progress);
}
