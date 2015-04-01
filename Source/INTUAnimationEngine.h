//
//  INTUAnimationEngine.h
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

#import <Foundation/Foundation.h>
#import "INTUEasingFunctions.h"
#import "INTUInterpolationFunctions.h"


/**
 A unique ID that corresponds to one animation.
 */
typedef NSInteger INTUAnimationID;

/**
 Animation options that can be used with INTUAnimationEngine.
 */
typedef NS_OPTIONS(NSUInteger, INTUAnimationOptions) {
    /** Default, no options. */
    INTUAnimationOptionNone         = 0,
    /** Repeat animation indefinitely until cancelled. Note: completion block will only be executed if animation is cancelled. */
    INTUAnimationOptionRepeat       = 1 << 0,
    /** If repeat, run animation forwards and backwards. */
    INTUAnimationOptionAutoreverse  = 1 << 1
};


/**
 A friendly interface to drive custom animations using a CADisplayLink, inspired by the UIView block-based animation API. Enables interactive
 animations (normally driven by user input, such as a pan or pinch gesture) to run automatically over a given duration.
 */
@interface INTUAnimationEngine : NSObject

/**
 Executes a block of animations multiple times over a given duration, passing in a percentage value each time to be used to drive the animation.
 The percentage value is simply the percentage complete the animation is, based on its duration. It will increase from 0.0 to 1.0 linearly with
 time.
 
 @param duration    The duration of the animation in seconds.
 @param delay       The delay before starting the animation in seconds.
 @param animations  A block which is executed at each display frame with the current animation percentage complete. This percentage value should
                    be used to update views so that they can be rendered onscreen in the next frame with this updated state.
 @param completion  A block which is executed at the completion of the animation, with the finished parameter indicating whether the animation
                    completed without interruption (or was cancelled).
 
 @return A unique INTUAnimationID for this animation. Can be used to cancel the animation at a later point in time.
 */
+ (INTUAnimationID)animateWithDuration:(NSTimeInterval)duration
                                 delay:(NSTimeInterval)delay
                            animations:(void (^)(CGFloat percentage))animations
                            completion:(void (^)(BOOL finished))completion;

/**
 Executes a block of animations multiple times over a given duration, passing in a progress value each time to be used to drive the animation.
 The progress value is a function of the animation's percentage complete (based on its duration) and the easing function provided.
 
 @param duration        The duration of the animation in seconds.
 @param delay           The delay before starting the animation in seconds.
 @param easingFunction  An easing function used to apply a curve to the animation (affects the progress value passed into the animations block).
 @param animations      A block which is executed at each display frame with the current animation progress. This progress value should be used to
                        update views so that they can be rendered onscreen in the next frame with this updated state.
 @param completion      A block which is executed at the completion of the animation, with the finished parameter indicating whether the animation
                        completed without interruption (or was cancelled).
 
 @return A unique INTUAnimationID for this animation. Can be used to cancel the animation at a later point in time.
 */
+ (INTUAnimationID)animateWithDuration:(NSTimeInterval)duration
                                 delay:(NSTimeInterval)delay
                                easing:(INTUEasingFunction)easingFunction
                            animations:(void (^)(CGFloat progress))animations
                            completion:(void (^)(BOOL finished))completion;

/**
 Executes a block of animations multiple times over a given duration, passing in a progress value each time to be used to drive the animation.
 The progress value is a function of the animation's percentage complete (based on its duration) and the easing function provided.
 
 @param duration        The duration of the animation in seconds.
 @param delay           The delay before starting the animation in seconds.
 @param easingFunction  An easing function used to apply a curve to the animation (affects the progress value passed into the animations block).
 @param options         A mask of options to apply to the animation. See the constants in INTUAnimationOptions.
 @param animations      A block which is executed at each display frame with the current animation progress. This progress value should be used to
                        update views so that they can be rendered onscreen in the next frame with this updated state.
 @param completion      A block which is executed at the completion of the animation, with the finished parameter indicating whether the animation
                        completed without interruption (or was cancelled).
 
 @return A unique INTUAnimationID for this animation. Can be used to cancel the animation at a later point in time.
 */
+ (INTUAnimationID)animateWithDuration:(NSTimeInterval)duration
                                 delay:(NSTimeInterval)delay
                                easing:(INTUEasingFunction)easingFunction
                               options:(INTUAnimationOptions)options
                            animations:(void (^)(CGFloat progress))animations
                            completion:(void (^)(BOOL finished))completion;

/**
 Cancels the currently active animation with the given animation ID.
 The completion block for the animation will be executed, with the finished parameter equal to NO.
 If there is no active animation for the given ID, this method will do nothing.
 */
+ (void)cancelAnimationWithID:(INTUAnimationID)animationID;

@end
