//
//  INTUEasingFunctions.h
//  https://github.com/intuit/AnimationEngine
//
//  Copyright (c) 2014-2015 Intuit Inc.
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

#import <CoreGraphics/CGBase.h>

/**
 A block that takes 1 argument (completion percentage) of type CGFloat (in range 0.0 <= p <= 1.0) and returns a CGFloat.
 When the completion percentage argument is 0.0, the returned progress is typically also 0.0; similarly, when the completion percentage
 argument is 1.0, the returned progress is typically also 1.0. For completion percentage values in between 0.0 and 1.0, the returned
 progress may be any number (not necessarily confined to the range of 0.0 to 1.0).
 */
typedef CGFloat (^INTUEasingFunction)(CGFloat);

// Linear interpolation (no easing)
extern INTUEasingFunction INTULinear;

// Sine wave easing; sin(p * PI/2)
extern INTUEasingFunction INTUEaseInSine;
extern INTUEasingFunction INTUEaseOutSine;
extern INTUEasingFunction INTUEaseInOutSine;

// Quadratic easing; p^2
extern INTUEasingFunction INTUEaseInQuadratic;
extern INTUEasingFunction INTUEaseOutQuadratic;
extern INTUEasingFunction INTUEaseInOutQuadratic;

// Cubic easing; p^3
extern INTUEasingFunction INTUEaseInCubic;
extern INTUEasingFunction INTUEaseOutCubic;
extern INTUEasingFunction INTUEaseInOutCubic;

// Quartic easing; p^4
extern INTUEasingFunction INTUEaseInQuartic;
extern INTUEasingFunction INTUEaseOutQuartic;
extern INTUEasingFunction INTUEaseInOutQuartic;

// Quintic easing; p^5
extern INTUEasingFunction INTUEaseInQuintic;
extern INTUEasingFunction INTUEaseOutQuintic;
extern INTUEasingFunction INTUEaseInOutQuintic;

// Exponential easing, base 2
extern INTUEasingFunction INTUEaseInExponential;
extern INTUEasingFunction INTUEaseOutExponential;
extern INTUEasingFunction INTUEaseInOutExponential;

// Circular easing; sqrt(1 - p^2)
extern INTUEasingFunction INTUEaseInCircular;
extern INTUEasingFunction INTUEaseOutCircular;
extern INTUEasingFunction INTUEaseInOutCircular;

// Overshooting cubic easing;
extern INTUEasingFunction INTUEaseInBack;
extern INTUEasingFunction INTUEaseOutBack;
extern INTUEasingFunction INTUEaseInOutBack;

// Exponentially-damped sine wave easing
extern INTUEasingFunction INTUEaseInElastic;
extern INTUEasingFunction INTUEaseOutElastic;
extern INTUEasingFunction INTUEaseInOutElastic;

// Exponentially-decaying bounce easing
extern INTUEasingFunction INTUEaseInBounce;
extern INTUEasingFunction INTUEaseOutBounce;
extern INTUEasingFunction INTUEaseInOutBounce;
