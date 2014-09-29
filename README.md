# [![INTUAnimationEngine](https://github.com/intuit/AnimationEngine/blob/master/Images/INTUAnimationEngine.png?raw=true)](#)
INTUAnimationEngine makes it easy to build advanced custom animations on iOS.

INTUAnimationEngine provides a friendly interface to drive custom animations using a CADisplayLink, inspired by the UIView block-based animation API. It enables interactive animations (normally driven by user input, such as a pan or pinch gesture) to run automatically over a given duration. It can also be used to get a callback every frame of an animation.

INTUAnimationEngine includes an extensive library of easing functions that can be used to customize animation timing. A complete library of interpolation functions is also included to animate any type of value or property, including those that are not animatable by Core Animation.

## Installation
*INTUAnimationEngine requires iOS 5.0 or later.*

**Using [CocoaPods](http://cocoapods.org)**

1.	Add the pod `INTUAnimationEngine` to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html).

    	pod 'INTUAnimationEngine'

2.	Run `pod install` from Terminal, then open your app's `.xcworkspace` file to launch Xcode.
3.	`#import "INTUAnimationEngine.h"` wherever you want to use it.

**Manually from GitHub**

1.	Download all the files in the [Source directory](https://github.com/intuit/AnimationEngine/tree/master/Source).
2.	Add all the files to your Xcode project (drag and drop is easiest).
3.	`#import "INTUAnimationEngine.h"` wherever you want to use it.

## Usage
The major difference between INTUAnimationEngine and the UIView animation methods is how the `animations` block works. With the UIView methods, the `animations` block is only executed once, and the changes made to views within this block represent the new state at the end of the animation.

With INTUAnimationEngine, the `animations` block is called many times during the animation (once per frame), and each time it is called, your code should update the state of views based upon the current value of the `percentage` or `progress` passed into the block. Typically, you'll want to use one of the interpolation functions included in this library to help generate all the intermediate values between the start and end states for a given property.

### Animation Engine
INTUAnimationEngine has a few API methods that can be used to start an animation.

#### Without Easing (Linear)
	+ (INTUAnimationID)animateWithDuration:(NSTimeInterval)duration
	                                 delay:(NSTimeInterval)delay
	                            animations:(void (^)(CGFloat percentage))animations
	                            completion:(void (^)(BOOL finished))completion;

This method will start an animation that calls the `animations` block each frame of the animation, passing in a `percentage` value that represents the current percentage complete. The `completion` block will be executed when the animation completes, with the `finished` parameter indicating whether the animation was cancelled.

#### With Easing
	+ (INTUAnimationID)animateWithDuration:(NSTimeInterval)duration
	                                 delay:(NSTimeInterval)delay
	                                easing:(INTUEasingFunction)easingFunction
	                            animations:(void (^)(CGFloat progress))animations
	                            completion:(void (^)(BOOL finished))completion;

This method will start an animation that calls the `animations` block each frame of the animation, passing in a `progress` value that represents the current progress of the animation (taking into account the easing function). The `easingFunction` can be any of the easing functions in [`INTUEasingFunctions.h`](https://github.com/intuit/AnimationEngine/tree/master/Source/INTUEasingFunctions.h), or a custom function. The `completion` block will be executed when the animation completes, with the `finished` parameter indicating whether the animation was cancelled.

There is also another variant of the above method that takes an `options:` parameter, which is a mask of `INTUAnimationOptions`. This can be used to repeat or autoreverse animations.

#### Canceling Animations
	+ (void)cancelAnimationWithID:(INTUAnimationID)animationID;

When starting an animation, you can store the returned animation ID, and pass it to the above method to cancel the animation before it completes. If the animation is cancelled, the completion block will execute with `finished` parameter equal to NO.

### Easing Functions
[`INTUEasingFunctions.h`](https://github.com/intuit/AnimationEngine/tree/master/Source/INTUEasingFunctions.h) is a C library of standard easing functions. Here's a [handy cheat sheet](http://easings.net) that includes visualizations and animation demos for these functions.

### Interpolation Functions
[`INTUInterpolationFunctions.h`](https://github.com/intuit/AnimationEngine/tree/master/Source/INTUInterpolationFunctions.h) is a C library of interpolation functions.

#### Proximal Interpolation
For discrete values (where linear interpolation does not make sense), there are two proxmial interpolation functions. For example:

    INTUInterpolateDiscrete(NSTextAlignmentLeft, NSTextAlignmentRight, progress)
	// Returns NSTextAlignmentLeft when progress is < 0.5, NSTextAlignmentRight otherwise
	
    [INTUInterpolateDiscreteValues(@[@(NSTextAlignmentLeft), @(NSTextAlignmentCenter), @(NSTextAlignmentRight)], progress) integerValue]
	// Returns NSTextAlignmentLeft, then NSTextAlignmentCenter, and finally NSTextAlignmentRight as progress increases from 0.0 to 1.0


#### Linear Interpolation
For continuous values, there are a variety of linear interpolation functions. The following types are supported:

* `CGFloat`
* `CGPoint`
* `CGSize`
* `CGRect`
* `CGVector`
* `UIOffset`
* `UIEdgeInsets`
* `UIColor` / `CGColor`

There is also an untyped function `INTUInterpolate()` that takes values of type `id` and returns an interpolated value by automatically determining the type of the values. Proximal interpolation is used if the value types do not match, or if linear interpolation isn't supported for their type.

##### CGAffineTransform & CATransform3D
There are no functions that directly interpolate transforms. This is by design: linear interpolation of raw matrices often yields unexpected or invalid results. To interpolate between two transforms, decompose them into their translation, rotation, and scale components:

	CGFloat rotation = INTUInterpolateCGFloat(0.0, M_PI, progress);
	view.transform = CGAffineTransformMakeRotation(rotation);
	// view will rotate from upright (progress = 0.0) to upside down (progress = 1.0)

You can concatenate transforms to combine them:

    CGFloat rotation = INTUInterpolateCGFloat(0.0, M_PI, progress);
    CGFloat scale = INTUInterpolateCGFloat(1.0, 0.5, progress);
    view.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale), CGAffineTransformMakeRotation(rotation));
	// view will rotate from upright and full size (progress = 0.0), to upside down and half size (progress = 1.0)

##### UIColor / CGColor
When interpolating between two colors, both colors must be in the same color space (grayscale, RGB, or HSB). Interpolating between colors in the HSB color space will generally yield better visual results than the RGB color space.

	[UIColor colorWithWhite:1.0 alpha:1.0] // grayscale color space; white
	[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] // RGB color space, white
	[UIColor colorWithHue:0.0 saturation:0.0 brightness:1.0 alpha:1.0] // HSB color space; white

## Example Project
An [example project](https://github.com/intuit/AnimationEngine/tree/master/AnimationEngineExample) is provided. It requires Xcode 6 and iOS 6.0 or later.

## Issues & Contributions
Please [open an issue here on GitHub](https://github.com/intuit/AnimationEngine/issues/new) if you have a problem, suggestion, or other comment.

Pull requests are welcome and encouraged! There are no official guidelines, but please try to be consistent with the existing code style.

## License
INTUAnimationEngine is provided under the MIT license.
