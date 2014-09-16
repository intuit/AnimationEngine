//
//  INTUEasingFunctions.h
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

#ifndef INTU_EASING_FUNCTIONS_H
#define INTU_EASING_FUNCTIONS_H

#include <CoreGraphics/CGBase.h>

/**
 A C function that takes 1 argument (completion percentage) of type CGFloat (in range 0.0 <= p <= 1.0) and returns a CGFloat.
 When the completion percentage argument is 0.0, the returned progress is typically also 0.0; similarly, when the completion percentage
 argument is 1.0, the returned progress is typically also 1.0. For completion percentage values in between 0.0 and 1.0, the returned
 progress may be any number (not necessarily confined to the range of 0.0 to 1.0).
 */
typedef CGFloat (*INTUEasingFunction)(CGFloat);

// Linear interpolation (no easing)
CGFloat INTULinear(CGFloat p);

// Sine wave easing; sin(p * PI/2)
CGFloat INTUEaseInSine(CGFloat p);
CGFloat INTUEaseOutSine(CGFloat p);
CGFloat INTUEaseInOutSine(CGFloat p);

// Quadratic easing; p^2
CGFloat INTUEaseInQuadratic(CGFloat p);
CGFloat INTUEaseOutQuadratic(CGFloat p);
CGFloat INTUEaseInOutQuadratic(CGFloat p);

// Cubic easing; p^3
CGFloat INTUEaseInCubic(CGFloat p);
CGFloat INTUEaseOutCubic(CGFloat p);
CGFloat INTUEaseInOutCubic(CGFloat p);

// Quartic easing; p^4
CGFloat INTUEaseInQuartic(CGFloat p);
CGFloat INTUEaseOutQuartic(CGFloat p);
CGFloat INTUEaseInOutQuartic(CGFloat p);

// Quintic easing; p^5
CGFloat INTUEaseInQuintic(CGFloat p);
CGFloat INTUEaseOutQuintic(CGFloat p);
CGFloat INTUEaseInOutQuintic(CGFloat p);

// Exponential easing, base 2
CGFloat INTUEaseInExponential(CGFloat p);
CGFloat INTUEaseOutExponential(CGFloat p);
CGFloat INTUEaseInOutExponential(CGFloat p);

// Circular easing; sqrt(1 - p^2)
CGFloat INTUEaseInCircular(CGFloat p);
CGFloat INTUEaseOutCircular(CGFloat p);
CGFloat INTUEaseInOutCircular(CGFloat p);

// Overshooting cubic easing;
CGFloat INTUEaseInBack(CGFloat p);
CGFloat INTUEaseOutBack(CGFloat p);
CGFloat INTUEaseInOutBack(CGFloat p);

// Exponentially-damped sine wave easing
CGFloat INTUEaseInElastic(CGFloat p);
CGFloat INTUEaseOutElastic(CGFloat p);
CGFloat INTUEaseInOutElastic(CGFloat p);

// Exponentially-decaying bounce easing
CGFloat INTUEaseInBounce(CGFloat p);
CGFloat INTUEaseOutBounce(CGFloat p);
CGFloat INTUEaseInOutBounce(CGFloat p);

#endif /* INTU_EASING_FUNCTIONS_H */
