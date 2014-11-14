//
//  INTUEasingFunctions.m
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

#import "INTUEasingFunctions.h"
#include <math.h>

// Modeled after the line y = x
INTUEasingFunction INTULinear = ^CGFloat (CGFloat p) {
    return p;
};

// Modeled after quarter-cycle of sine wave
INTUEasingFunction INTUEaseInSine = ^CGFloat (CGFloat p) {
    return sin((p - 1) * M_PI_2) + 1;
};

// Modeled after quarter-cycle of sine wave (different phase)
INTUEasingFunction INTUEaseOutSine = ^CGFloat (CGFloat p) {
    return sin(p * M_PI_2);
};

// Modeled after half sine wave
INTUEasingFunction INTUEaseInOutSine = ^CGFloat (CGFloat p) {
    return 0.5 * (1 - cos(p * M_PI));
};

// Modeled after the parabola y = x^2
INTUEasingFunction INTUEaseInQuadratic = ^CGFloat (CGFloat p) {
    return p * p;
};

// Modeled after the parabola y = -x^2 + 2x
INTUEasingFunction INTUEaseOutQuadratic = ^CGFloat (CGFloat p) {
    return -(p * (p - 2));
};

// Modeled after the piecewise quadratic
// y = (1/2)((2x)^2)             ; [0, 0.5)
// y = -(1/2)((2x-1)*(2x-3) - 1) ; [0.5, 1]
INTUEasingFunction INTUEaseInOutQuadratic = ^CGFloat (CGFloat p) {
    if(p < 0.5)
    {
        return 2 * p * p;
    }
    else
    {
        return (-2 * p * p) + (4 * p) - 1;
    }
};

// Modeled after the cubic y = x^3
INTUEasingFunction INTUEaseInCubic = ^CGFloat (CGFloat p) {
    return p * p * p;
};

// Modeled after the cubic y = (x - 1)^3 + 1
INTUEasingFunction INTUEaseOutCubic = ^CGFloat (CGFloat p) {
    CGFloat f = (p - 1);
    return f * f * f + 1;
};

// Modeled after the piecewise cubic
// y = (1/2)((2x)^3)       ; [0, 0.5)
// y = (1/2)((2x-2)^3 + 2) ; [0.5, 1]
INTUEasingFunction INTUEaseInOutCubic = ^CGFloat (CGFloat p) {
    if(p < 0.5)
    {
        return 4 * p * p * p;
    }
    else
    {
        CGFloat f = ((2 * p) - 2);
        return 0.5 * f * f * f + 1;
    }
};

// Modeled after the quartic x^4
INTUEasingFunction INTUEaseInQuartic = ^CGFloat (CGFloat p) {
    return p * p * p * p;
};

// Modeled after the quartic y = 1 - (x - 1)^4
INTUEasingFunction INTUEaseOutQuartic = ^CGFloat (CGFloat p) {
    CGFloat f = (p - 1);
    return f * f * f * (1 - p) + 1;
};

// Modeled after the piecewise quartic
// y = (1/2)((2x)^4)        ; [0, 0.5)
// y = -(1/2)((2x-2)^4 - 2) ; [0.5, 1]
INTUEasingFunction INTUEaseInOutQuartic = ^CGFloat (CGFloat p) {
    if(p < 0.5)
    {
        return 8 * p * p * p * p;
    }
    else
    {
        CGFloat f = (p - 1);
        return -8 * f * f * f * f + 1;
    }
};

// Modeled after the quintic y = x^5
INTUEasingFunction INTUEaseInQuintic = ^CGFloat (CGFloat p) {
    return p * p * p * p * p;
};

// Modeled after the quintic y = (x - 1)^5 + 1
INTUEasingFunction INTUEaseOutQuintic = ^CGFloat (CGFloat p) {
    CGFloat f = (p - 1);
    return f * f * f * f * f + 1;
};

// Modeled after the piecewise quintic
// y = (1/2)((2x)^5)       ; [0, 0.5)
// y = (1/2)((2x-2)^5 + 2) ; [0.5, 1]
INTUEasingFunction INTUEaseInOutQuintic = ^CGFloat (CGFloat p) {
    if(p < 0.5)
    {
        return 16 * p * p * p * p * p;
    }
    else
    {
        CGFloat f = ((2 * p) - 2);
        return  0.5 * f * f * f * f * f + 1;
    }
};

// Modeled after the exponential function y = 2^(10(x - 1))
INTUEasingFunction INTUEaseInExponential = ^CGFloat (CGFloat p) {
    return (p == 0.0) ? p : pow(2, 10 * (p - 1));
};

// Modeled after the exponential function y = -2^(-10x) + 1
INTUEasingFunction INTUEaseOutExponential = ^CGFloat (CGFloat p) {
    return (p == 1.0) ? p : 1 - pow(2, -10 * p);
};

// Modeled after the piecewise exponential
// y = (1/2)2^(10(2x - 1))         ; [0,0.5)
// y = -(1/2)*2^(-10(2x - 1))) + 1 ; [0.5,1]
INTUEasingFunction INTUEaseInOutExponential = ^CGFloat (CGFloat p) {
    if(p == 0.0 || p == 1.0) return p;
    
    if(p < 0.5)
    {
        return 0.5 * pow(2, (20 * p) - 10);
    }
    else
    {
        return -0.5 * pow(2, (-20 * p) + 10) + 1;
    }
};

// Modeled after shifted quadrant IV of unit circle
INTUEasingFunction INTUEaseInCircular = ^CGFloat (CGFloat p) {
    return 1 - sqrt(1 - (p * p));
};

// Modeled after shifted quadrant II of unit circle
INTUEasingFunction INTUEaseOutCircular = ^CGFloat (CGFloat p) {
    return sqrt((2 - p) * p);
};

// Modeled after the piecewise circular function
// y = (1/2)(1 - sqrt(1 - 4x^2))           ; [0, 0.5)
// y = (1/2)(sqrt(-(2x - 3)*(2x - 1)) + 1) ; [0.5, 1]
INTUEasingFunction INTUEaseInOutCircular = ^CGFloat (CGFloat p) {
    if(p < 0.5)
    {
        return 0.5 * (1 - sqrt(1 - 4 * (p * p)));
    }
    else
    {
        return 0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1);
    }
};

// Modeled after the overshooting cubic y = x^3-x*sin(x*pi)
INTUEasingFunction INTUEaseInBack = ^CGFloat (CGFloat p) {
    return p * p * p - p * sin(p * M_PI);
};

// Modeled after overshooting cubic y = 1-((1-x)^3-(1-x)*sin((1-x)*pi))
INTUEasingFunction INTUEaseOutBack = ^CGFloat (CGFloat p) {
    CGFloat f = (1 - p);
    return 1 - (f * f * f - f * sin(f * M_PI));
};

// Modeled after the piecewise overshooting cubic function:
// y = (1/2)*((2x)^3-(2x)*sin(2*x*pi))           ; [0, 0.5)
// y = (1/2)*(1-((1-x)^3-(1-x)*sin((1-x)*pi))+1) ; [0.5, 1]
INTUEasingFunction INTUEaseInOutBack = ^CGFloat (CGFloat p) {
    if(p < 0.5)
    {
        CGFloat f = 2 * p;
        return 0.5 * (f * f * f - f * sin(f * M_PI));
    }
    else
    {
        CGFloat f = (1 - (2*p - 1));
        return 0.5 * (1 - (f * f * f - f * sin(f * M_PI))) + 0.5;
    }
};

// Modeled after the damped sine wave y = sin(13pi/2*x)*pow(2, 10 * (x - 1))
INTUEasingFunction INTUEaseInElastic = ^CGFloat (CGFloat p) {
    return sin(13 * M_PI_2 * p) * pow(2, 10 * (p - 1));
};

// Modeled after the damped sine wave y = sin(-13pi/2*(x + 1))*pow(2, -10x) + 1
INTUEasingFunction INTUEaseOutElastic = ^CGFloat (CGFloat p) {
    return sin(-13 * M_PI_2 * (p + 1)) * pow(2, -10 * p) + 1;
};

// Modeled after the piecewise exponentially-damped sine wave:
// y = (1/2)*sin(13pi/2*(2*x))*pow(2, 10 * ((2*x) - 1))      ; [0,0.5)
// y = (1/2)*(sin(-13pi/2*((2x-1)+1))*pow(2,-10(2*x-1)) + 2) ; [0.5, 1]
INTUEasingFunction INTUEaseInOutElastic = ^CGFloat (CGFloat p) {
    if(p < 0.5)
    {
        return 0.5 * sin(13 * M_PI_2 * (2 * p)) * pow(2, 10 * ((2 * p) - 1));
    }
    else
    {
        return 0.5 * (sin(-13 * M_PI_2 * ((2 * p - 1) + 1)) * pow(2, -10 * (2 * p - 1)) + 2);
    }
};

INTUEasingFunction INTUEaseInBounce = ^CGFloat (CGFloat p) {
    return 1 - INTUEaseOutBounce(1 - p);
};

INTUEasingFunction INTUEaseOutBounce = ^CGFloat (CGFloat p) {
    if(p < 4/11.0)
    {
        return (121 * p * p)/16.0;
    }
    else if(p < 8/11.0)
    {
        return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0;
    }
    else if(p < 9/10.0)
    {
        return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0;
    }
    else
    {
        return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0;
    }
};

INTUEasingFunction INTUEaseInOutBounce = ^CGFloat (CGFloat p) {
    if(p < 0.5)
    {
        return 0.5 * INTUEaseInBounce(p*2);
    }
    else
    {
        return 0.5 * INTUEaseOutBounce(p * 2 - 1) + 0.5;
    }
};
