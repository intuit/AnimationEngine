//
//  INTUAnimationEngine.m
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

#import "INTUAnimationEngine.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark - INTUAnimation

/**
 An internal class that represents an animation.
 */
@interface INTUAnimation : NSObject

@property (nonatomic, readonly) INTUAnimationID animationID;

// These properties correspond directly to the parameters when creating a new animation with INTUAnimationEngine.
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) INTUEasingFunction easingFunction;
@property (nonatomic, assign) BOOL repeat; // INTUAnimationOptionRepeat
@property (nonatomic, assign) BOOL autoreverse; // INTUAnimationOptionAutoreverse
@property (nonatomic, copy) void (^animations)(CGFloat);
@property (nonatomic, copy) void (^completion)(BOOL);

@property (nonatomic, assign) CFTimeInterval startTime;

/** Computed. Calculated based on animation start time, delay, and duration. */
@property (nonatomic, readonly) CGFloat percentComplete;
/** Computed. If no easing function, same as percentComplete; otherwise returns percentComplete transformed by easingFunction. */
@property (nonatomic, readonly) CGFloat progress;

- (void)applyOptions:(INTUAnimationOptions)options;
- (void)tick;
- (void)complete:(BOOL)finished;

@end

@implementation INTUAnimation

static INTUAnimationID _nextAnimationID = 0;

/**
 Returns the next animation ID (unique within the lifetime of the application).
 */
+ (INTUAnimationID)getNextAnimationID
{
    NSAssert([NSThread isMainThread], @"INTUAnimationEngine should only be called from the main thread.");
    _nextAnimationID++;
    return _nextAnimationID;
}

- (id)init
{
    self = [super init];
    if (self) {
        _animationID = [[self class] getNextAnimationID];
    }
    return self;
}

/**
 Applies the given mask of options to this animation, setting the corresponding properties as needed.
 */
- (void)applyOptions:(INTUAnimationOptions)options
{
    self.repeat = options & INTUAnimationOptionRepeat;
    self.autoreverse = options & INTUAnimationOptionAutoreverse;
}

/**
 How much of the delay is remaining before the animation should start. This will be equal to 0.0 once the animation starts.
 Range is: x >= 0.0
 */
- (NSTimeInterval)remainingDelay
{
    return MAX(0.0, self.delay - (CACurrentMediaTime() - self.startTime));
}

/**
 The percent complete that this animation is, based on its start time, delay, and duration. Does not incorporate the easing function.
 Range is: 0.0 <= x <= 1.0
 */
- (CGFloat)percentComplete
{
    CGFloat percent = ((CACurrentMediaTime() - self.startTime) - self.delay) / self.duration;
    if (self.repeat) {
        NSUInteger repeatCount = (NSUInteger)percent;
        percent = percent - repeatCount;
        if (self.autoreverse) {
            percent = (repeatCount % 2 == 0) ? percent : (1.0 - percent);
        }
    }
    return MAX(0.0, MIN(1.0, percent));
}

/**
 The progress of this animation, incorporating the easing function. If there is no easing function, the progress is the same as percentComplete.
 The range is not confined to any bounds (may exceed 1.0 or go below 0.0).
 */
- (CGFloat)progress
{
    if (self.easingFunction) {
        return self.easingFunction(self.percentComplete);
    } else {
        return self.percentComplete;
    }
}

/**
 Triggers one execution of the animations block, passing in the current progress.
 */
- (void)tick
{
    if ([self remainingDelay] > FLT_EPSILON) {
        return;
    }
    
    if (self.animations) {
        self.animations(self.progress);
    }
}

/**
 Triggers the execution of the completion block, passing in whether or not the animation finished.
 */
- (void)complete:(BOOL)finished
{
    if (self.completion) {
        self.completion(finished);
    }
}

@end


#pragma mark - INTUAnimationEngine

@interface INTUAnimationEngine ()

// A dictionary that associates animation IDs to active animations. It is in the format:
//      { NSNumber *animationID : INTUAnimation *animation, ... }
@property (nonatomic, strong) NSMutableDictionary *activeAnimations;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation INTUAnimationEngine

static id _sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (INTUAnimationID)animateWithDuration:(NSTimeInterval)duration
                                 delay:(NSTimeInterval)delay
                            animations:(void (^)(CGFloat percentage))animations
                            completion:(void (^)(BOOL finished))completion
{
    return [self animateWithDuration:duration
                               delay:delay
                              easing:nil
                          animations:animations
                          completion:completion];
}

+ (INTUAnimationID)animateWithDuration:(NSTimeInterval)duration
                                 delay:(NSTimeInterval)delay
                                easing:(INTUEasingFunction)easingFunction
                            animations:(void (^)(CGFloat progress))animations
                            completion:(void (^)(BOOL finished))completion
{
    return [self animateWithDuration:duration
                               delay:delay
                              easing:easingFunction
                             options:INTUAnimationOptionNone
                          animations:animations
                          completion:completion];
}

+ (INTUAnimationID)animateWithDuration:(NSTimeInterval)duration
                                 delay:(NSTimeInterval)delay
                                easing:(INTUEasingFunction)easingFunction
                               options:(INTUAnimationOptions)options
                            animations:(void (^)(CGFloat progress))animations
                            completion:(void (^)(BOOL finished))completion
{
    INTUAnimation *animation = [INTUAnimation new];
    animation.duration = duration;
    animation.delay = delay;
    animation.easingFunction = easingFunction;
    animation.animations = animations;
    animation.completion = completion;
    [animation applyOptions:options];
    [[self sharedInstance] addAnimation:animation];
    return animation.animationID;
}

/**
 Cancels the currently active animation with the given animation ID. The completion block for the animation will be executed, with the finished parameter equal to NO.
 */
+ (void)cancelAnimationWithID:(INTUAnimationID)animationID
{
    NSAssert([NSThread isMainThread], @"INTUAnimationEngine should only be called from the main thread.");
    [[self sharedInstance] removeAnimationWithID:animationID didFinish:NO];
}

- (id)init
{
    self = [super init];
    if (self) {
        _activeAnimations = [NSMutableDictionary new];
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tickActiveAnimations)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes]; // NSRunLoopCommonModes will cause the display link to fire even during scroll view scrolling, etc
    }
    return self;
}

/**
 Callback when the CADisplayLink fires.
 */
- (void)tickActiveAnimations
{
    NSMutableArray *finishedAnimationIDs = [NSMutableArray new];
    for (INTUAnimation *animation in [self.activeAnimations objectEnumerator]) {
        if (animation.repeat == NO && animation.percentComplete >= 1.0) {
            [finishedAnimationIDs addObject:@(animation.animationID)];
        }
        [animation tick];
    }
    for (NSNumber *animationID in finishedAnimationIDs) {
        [self removeAnimationWithID:[animationID integerValue] didFinish:YES];
    }
}

- (void)addAnimation:(INTUAnimation *)animation
{
    if ([self.activeAnimations count] == 0) {
        self.displayLink.paused = NO;
    }
    animation.startTime = CACurrentMediaTime();
    [self.activeAnimations setObject:animation forKey:@(animation.animationID)];
}

- (void)removeAnimationWithID:(INTUAnimationID)animationID didFinish:(BOOL)finished
{
    INTUAnimation *animation = [self.activeAnimations objectForKey:@(animationID)];
    [animation complete:finished];
    [self.activeAnimations removeObjectForKey:@(animationID)];
    if ([self.activeAnimations count] == 0) {
        self.displayLink.paused = YES;
    }
}

@end
