//
//  INTUInterpolationFunctions.h
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

#ifndef INTU_INTERPOLATION_FUNCTIONS_H
#define INTU_INTERPOLATION_FUNCTIONS_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#pragma mark - Proximal Interpolation Functions

/** Interpolates proximally for two discrete values. The start value will be returned when (progress < 0.5), and the end value returned when (progress >= 0.5). */
#define INTUInterpolateDiscrete(start, end, progress)       (progress < 0.5 ? start : end)

/** Interpolates proximally between discrete values in an array (of arbitrary length). */
id INTUInterpolateDiscreteValues(NSArray *values, CGFloat progress);


#pragma mark - Linear Interpolation Functions

/** Interpolates linearly between a start CGFloat (progress = 0.0) and an end CGFloat (progress = 1.0), based on the progress value. */
CGFloat INTUInterpolateCGFloat(CGFloat start, CGFloat end, CGFloat progress);

/** Interpolates linearly between a start CGPoint (progress = 0.0) and an end CGPoint (progress = 1.0), based on the progress value. */
CGPoint INTUInterpolateCGPoint(CGPoint start, CGPoint end, CGFloat progress);

/** Interpolates linearly between a start CGSize (progress = 0.0) and an end CGSize (progress = 1.0), based on the progress value. */
CGSize INTUInterpolateCGSize(CGSize start, CGSize end, CGFloat progress);

/** Interpolates linearly between a start CGRect (progress = 0.0) and an end CGRect (progress = 1.0), based on the progress value. */
CGRect INTUInterpolateCGRect(CGRect start, CGRect end, CGFloat progress);

/** Interpolates linearly between a start CGVector (progress = 0.0) and an end CGVector (progress = 1.0), based on the progress value. */
CGVector INTUInterpolateCGVector(CGVector start, CGVector end, CGFloat progress);

/** Interpolates linearly between a start UIOffset (progress = 0.0) and an end UIOffset (progress = 1.0), based on the progress value. */
UIOffset INTUInterpolateUIOffset(UIOffset start, UIOffset end, CGFloat progress);

/** Interpolates linearly between a start UIEdgeInsets (progress = 0.0) and an end UIEdgeInsets (progress = 1.0), based on the progress value. */
UIEdgeInsets INTUInterpolateUIEdgeInsets(UIEdgeInsets start, UIEdgeInsets end, CGFloat progress);

/** Interpolates linearly between a start UIColor (progress = 0.0) and an end UIColor (progress = 1.0), based on the progress value. */
UIColor * INTUInterpolateUIColor(UIColor *start, UIColor *end, CGFloat progress);

/** Interpolates linearly between a start CGColorRef (progress = 0.0) and an end CGColorRef (progress = 1.0), based on the progress value. */
CGColorRef INTUInterpolateCGColor(CGColorRef start, CGColorRef end, CGFloat progress);

/** Interpolates between a start value (progress = 0.0) and an end value (progress = 1.0), based on the progress value.
    If both values are of the same type and linear interpolation is supported for that type, linear interpolation will
    be used. Otherwise, proximal interpolation will be used. */
id INTUInterpolate(id start, id end, CGFloat progress);

#endif /* INTU_INTERPOLATION_FUNCTIONS_H */
