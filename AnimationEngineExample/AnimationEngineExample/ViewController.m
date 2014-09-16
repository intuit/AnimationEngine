//
//  ViewController.m
//  AnimationEngineExample
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

#import "ViewController.h"
#import "INTUAnimationEngine.h"

static const CGFloat kAnimationDuration = 2.0; // in seconds

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *demoLabel;

@property (nonatomic, assign) CGPoint startCenter;
@property (nonatomic, assign) CGPoint endCenter;

@property (nonatomic, assign) CGFloat startCornerRadius;
@property (nonatomic, assign) CGFloat endCornerRadius;

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, assign) CGFloat startRotation;
@property (nonatomic, assign) CGFloat endRotation;

@property (nonatomic, strong) NSArray *textAlignmentValues;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.demoLabel.clipsToBounds = YES; // required for the cornerRadius animation to work
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.startCenter = CGPointMake(self.view.center.x * 0.7, self.view.center.y * 0.5);
    self.endCenter = CGPointMake(self.view.center.x * 1.2, self.view.center.y * 1.4);
    
    self.startCornerRadius = 0.0;
    self.endCornerRadius = 40.0;
    
    // Use the HSB color space for better interpolation results than RGB color space ([UIColor colorWithRed:blue:green:alpha:])
    self.startColor = [UIColor colorWithHue:1.0 saturation:1.0 brightness:1.0 alpha:1.0];
    self.endColor = [UIColor colorWithHue:0.7 saturation:1.0 brightness:1.0 alpha:1.0];
    
    // For a CGAffineTransform or CATransform3D, interpolate the amount of rotation, scale, etc instead of the transform (matrix) itself
    self.startRotation = 0.0;
    self.endRotation = M_PI_4 / 2.0;
    
    // NSTextAlignment can't be linearly interpolated because it is a few discrete values
    self.textAlignmentValues = @[@(NSTextAlignmentLeft), @(NSTextAlignmentCenter), @(NSTextAlignmentRight)];
    
    [self animateForward];
}

- (void)animateForward
{
    [INTUAnimationEngine animateWithDuration:kAnimationDuration
                                       delay:0.0
                                      easing:INTUEaseInOutQuadratic
                                  animations:^(CGFloat progress) {
                                      self.demoLabel.center = INTUInterpolateCGPoint(self.startCenter, self.endCenter, progress);
                                      self.demoLabel.layer.cornerRadius = INTUInterpolateCGFloat(self.startCornerRadius, self.endCornerRadius, progress);
                                      self.demoLabel.backgroundColor = INTUInterpolate(self.startColor, self.endColor, progress);
                                      CGFloat rotation = INTUInterpolateCGFloat(self.startRotation, self.endRotation, progress);
                                      self.demoLabel.transform = CGAffineTransformMakeRotation(rotation);
                                      self.demoLabel.textAlignment = [INTUInterpolateDiscreteValues(self.textAlignmentValues, progress) integerValue];
                                  }
                                  completion:^(BOOL finished) {
                                      // Animate back to the starting state
                                      [self animateReverse];
                                  }];
}

- (void)animateReverse
{
    [INTUAnimationEngine animateWithDuration:kAnimationDuration
                                       delay:0.0
                                      easing:INTUEaseInOutQuintic
                                  animations:^(CGFloat progress) {
                                      // Pass in (1.0 - progress) to the interpolation functions to reverse them. (Reversing the order of the first two arguments instead would achieve the same effect.)
                                      self.demoLabel.center = INTUInterpolateCGPoint(self.startCenter, self.endCenter, 1.0 - progress);
                                      self.demoLabel.layer.cornerRadius = INTUInterpolateCGFloat(self.startCornerRadius, self.endCornerRadius, 1.0 - progress);
                                      self.demoLabel.backgroundColor = INTUInterpolate(self.startColor, self.endColor, 1.0 - progress);
                                      CGFloat rotation = INTUInterpolateCGFloat(self.startRotation, self.endRotation, 1.0 - progress);
                                      self.demoLabel.transform = CGAffineTransformMakeRotation(rotation);
                                      self.demoLabel.textAlignment = [INTUInterpolateDiscreteValues(self.textAlignmentValues, 1.0 - progress) integerValue];
                                  }
                                  completion:^(BOOL finished) {
                                      // Loop the animation
                                      [self animateForward];
                                  }];
}

@end
