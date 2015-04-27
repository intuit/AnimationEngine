//
//  RegularViewController.m
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

#import "RegularViewController.h"
#import "INTUAnimationEngine.h"

static const CGFloat kAnimationDuration = 2.0; // in seconds

@interface RegularViewController ()

@property (nonatomic, weak) IBOutlet UILabel *demoLabel; // the view that is animated in the demo

@property (nonatomic, weak) IBOutlet UIButton *toggleButton; // control to cancel/restart animation
@property (nonatomic, weak) IBOutlet UILabel *progressLabel; // displays the current progress

// Stores the Animation ID for the currently running animation, or NSNotFound if no animation is currently running.
@property (nonatomic, assign) INTUAnimationID animationID;


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

@implementation RegularViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.demoLabel.clipsToBounds = YES; // required for the cornerRadius animation to work
    
    self.animationID = NSNotFound;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.startCenter = CGPointMake(self.view.center.x * 0.6, self.view.center.y * 0.4);
    self.endCenter = CGPointMake(self.view.center.x * 1.2, self.view.center.y * 1.3);
    
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
    
    if (self.animationID == NSNotFound) {
        [self startAnimation];
    }
}

- (void)startAnimation
{
    self.animationID = [INTUAnimationEngine animateWithDuration:kAnimationDuration
                                                          delay:0.0
                                                         easing:INTUEaseInOutQuadratic
                                                        options:INTUAnimationOptionRepeat | INTUAnimationOptionAutoreverse
                                                     animations:^(CGFloat progress) {
                                                         self.demoLabel.center = INTUInterpolateCGPoint(self.startCenter, self.endCenter, progress);
                                                         self.demoLabel.layer.cornerRadius = INTUInterpolateCGFloat(self.startCornerRadius, self.endCornerRadius, progress);
                                                         self.demoLabel.backgroundColor = INTUInterpolate(self.startColor, self.endColor, progress);
                                                         CGFloat rotationAngle = INTUInterpolateCGFloat(self.startRotation, self.endRotation, progress);
                                                         self.demoLabel.transform = CGAffineTransformMakeRotation(rotationAngle);
                                                         self.demoLabel.textAlignment = [INTUInterpolateDiscreteValues(self.textAlignmentValues, progress) integerValue];
                                                         
                                                         self.progressLabel.text = [NSString stringWithFormat:@"Progress: %.2f", progress];
                                                     }
                                                     completion:^(BOOL finished) {
                                                         // NOTE: When passing INTUAnimationOptionRepeat, this completion block is NOT executed at the end of each cycle. It will only run if the animation is canceled.
                                                         self.progressLabel.text = finished ? @"Animation Completed" : @"Animation Canceled";
                                                         self.animationID = NSNotFound;
                                                         [self.toggleButton setTitle:@"Restart Animation" forState:UIControlStateNormal];
                                                     }];
    
    [self.toggleButton setTitle:@"Cancel Animation" forState:UIControlStateNormal];
}

- (void)stopAnimation
{
    [INTUAnimationEngine cancelAnimationWithID:self.animationID];
}

/** Callback when the "Start Animation"/"Cancel Animation" button is tapped. */
- (IBAction)toggleAnimation:(UIButton *)sender
{
    if (self.animationID == NSNotFound) {
        [self startAnimation];
    } else {
        [self stopAnimation];
    }
}

@end
