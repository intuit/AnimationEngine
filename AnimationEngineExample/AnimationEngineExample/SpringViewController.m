//
//  SpringViewController.m
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

#import "SpringViewController.h"
#import "INTUAnimationEngine.h"

typedef NS_ENUM(NSInteger, INTUAnimationProperty) {
    INTUAnimationPropertyMove   = 0,
    INTUAnimationPropertyScale  = 1,
    INTUAnimationPropertyRotate = 2,
};

@interface SpringViewController ()

@property (nonatomic, weak) IBOutlet UIView *demoView; // the view that is animated in the demo

@property (nonatomic, weak) IBOutlet UIButton *toggleButton; // control to cancel/restart animation
@property (nonatomic, weak) IBOutlet UILabel *progressLabel; // displays the current progress

// The labels that display the current values of damping/stiffness/mass
@property (nonatomic, weak) IBOutlet UILabel *dampingLabel;
@property (nonatomic, weak) IBOutlet UILabel *stiffnessLabel;
@property (nonatomic, weak) IBOutlet UILabel *massLabel;

// Stores the Animation ID for the currently running animation, or NSNotFound if no animation is currently running.
@property (nonatomic, assign) INTUAnimationID animationID;

// The spring-mass system properties, controlled by the sliders
@property (nonatomic, assign) CGFloat damping;
@property (nonatomic, assign) CGFloat stiffness;
@property (nonatomic, assign) CGFloat mass;

// Which property of the view to animate, controlled by the segmented control
@property (nonatomic, assign) INTUAnimationProperty animationProperty;

@end

@implementation SpringViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set property defaults to match the UI defaults in the Storyboard
    self.damping = 5;
    self.stiffness = 100;
    self.mass = 1;
    self.animationProperty = INTUAnimationPropertyScale;
    
    self.animationID = NSNotFound;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.animationID == NSNotFound) {
        [self startAnimation];
    }
}

- (void)resetDemoViewState
{
    self.demoView.center = self.view.center;
    self.demoView.transform = CGAffineTransformIdentity;
}

- (void)startAnimation
{
    [self resetDemoViewState];
    
    INTUAnimationProperty animationProperty = self.animationProperty;
    CGPoint moveStart = CGPointMake(self.demoView.center.x, self.view.center.y - CGRectGetHeight(self.demoView.bounds));
    CGPoint moveEnd = CGPointMake(self.demoView.center.x, self.view.center.y + CGRectGetHeight(self.demoView.bounds));
    
    self.animationID = [INTUAnimationEngine animateWithDamping:self.damping
                                                     stiffness:self.stiffness
                                                          mass:self.mass
                                                         delay:0
                                                    animations:^(CGFloat progress) {
                                                        switch (animationProperty) {
                                                            case INTUAnimationPropertyMove:
                                                            {
                                                                self.demoView.center = INTUInterpolateCGPoint(moveStart, moveEnd, progress);
                                                            }
                                                                break;
                                                            case INTUAnimationPropertyScale:
                                                            {
                                                                CGFloat scaleFactor = INTUInterpolateCGFloat(0.5, 1.5, progress);
                                                                self.demoView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
                                                            }
                                                                break;
                                                            case INTUAnimationPropertyRotate:
                                                            {
                                                                CGFloat rotationAngle = INTUInterpolateCGFloat(0.0, M_PI_2, progress);
                                                                self.demoView.transform = CGAffineTransformMakeRotation(rotationAngle);
                                                            }
                                                                break;
                                                        }
                                                        
                                                        self.progressLabel.text = [NSString stringWithFormat:@"Progress: %.2f", progress];
                                                    }
                                                    completion:^(BOOL finished) {
                                                        self.progressLabel.text = finished ? @"Animation Completed" : @"Animation Canceled";
                                                        self.animationID = NSNotFound;
                                                        [self.toggleButton setTitle:@"Restart Animation" forState:UIControlStateNormal];
                                                        [self resetDemoViewState];
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

- (IBAction)dampingSliderChanged:(UISlider *)sender
{
    self.damping = sender.value;
}

- (IBAction)stiffnessSliderChanged:(UISlider *)sender
{
    self.stiffness = sender.value;
}

- (IBAction)massSliderChanged:(UISlider *)sender
{
    self.mass = sender.value;
}

- (IBAction)animationPropertyChanged:(UISegmentedControl *)sender
{
    self.animationProperty = sender.selectedSegmentIndex;
}

- (void)setDamping:(CGFloat)damping
{
    _damping = damping;
    self.dampingLabel.text = [NSString stringWithFormat:@"Damping: %.1f", damping];
}

- (void)setStiffness:(CGFloat)stiffness
{
    _stiffness = stiffness;
    self.stiffnessLabel.text = [NSString stringWithFormat:@"Stiffness: %.1f", stiffness];
}

- (void)setMass:(CGFloat)mass
{
    _mass = mass;
    self.massLabel.text = [NSString stringWithFormat:@"Mass: %.1f", mass];
}

@end
