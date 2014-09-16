//
//  INTUAnimationEngine.m
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

#import "INTUAnimationEngine.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark - INTUAnimation

/**
 An internal class that represents an animation.
 */
@interface INTUAnimation : NSObject

@property (nonatomic, readonly) NSInteger animationID;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) INTUEasingFunction easingFunction;
@property (nonatomic, copy) void (^animations)(CGFloat);
@property (nonatomic, copy) void (^completion)(BOOL);

@property (nonatomic, assign) CFTimeInterval startTime;

- (CGFloat)percentComplete;
- (CGFloat)progress;
- (void)tick;
- (void)complete:(BOOL)finished;

@end

@implementation INTUAnimation

static NSInteger _nextAnimationID = 0;

/**
 Returns the next animation ID (unique within the lifetime of the application).
 */
+ (NSInteger)getNextAnimationID
{
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
    return MAX(0.0, MIN(1.0, ((CACurrentMediaTime() - self.startTime) - self.delay) / self.duration));
}

/**
 The progress of this animation, incorporating the easing function.
 The range is not confined to any bounds (may exceed 1.0 or go below 0.0).
 */
- (CGFloat)progress
{
    return self.easingFunction([self percentComplete]);
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
        if (self.easingFunction) {
            self.animations([self progress]);
        } else {
            self.animations([self percentComplete]);
        }
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

+ (NSInteger)animateWithDuration:(NSTimeInterval)duration
                           delay:(NSTimeInterval)delay
                      animations:(void (^)(CGFloat percentage))animations
                      completion:(void (^)(BOOL finished))completion
{
    INTUAnimation *animation = [INTUAnimation new];
    animation.duration = duration;
    animation.delay = delay;
    animation.animations = animations;
    animation.completion = completion;
    [[self sharedInstance] addAnimation:animation];
    return animation.animationID;
}

+ (NSInteger)animateWithDuration:(NSTimeInterval)duration
                           delay:(NSTimeInterval)delay
                          easing:(INTUEasingFunction)easingFunction
                      animations:(void (^)(CGFloat progress))animations
                      completion:(void (^)(BOOL finished))completion
{
    INTUAnimation *animation = [INTUAnimation new];
    animation.duration = duration;
    animation.delay = delay;
    animation.easingFunction = easingFunction;
    animation.animations = animations;
    animation.completion = completion;
    [[self sharedInstance] addAnimation:animation];
    return animation.animationID;
}

/**
 Cancels the currently active animation with the given animation ID. The completion block for the animation will be executed, with the finished parameter equal to NO.
 */
+ (void)cancelAnimationWithID:(NSInteger)animationID
{
    [[self sharedInstance] removeAnimationWithID:animationID didFinish:NO];
}

- (id)init
{
    self = [super init];
    if (self) {
        _activeAnimations = [NSMutableDictionary new];
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tickActiveAnimations)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

/**
 Callback when the CADisplayLink fires a notification.
 */
- (void)tickActiveAnimations
{
    NSMutableArray *finishedAnimationIDs = [NSMutableArray new];
    for (INTUAnimation *animation in [self.activeAnimations objectEnumerator]) {
        if ([animation percentComplete] >= 1.0) {
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

- (void)removeAnimationWithID:(NSInteger)animationID didFinish:(BOOL)finished
{
    INTUAnimation *animation = [self.activeAnimations objectForKey:@(animationID)];
    [animation complete:finished];
    [self.activeAnimations removeObjectForKey:@(animationID)];
    if ([self.activeAnimations count] == 0) {
        self.displayLink.paused = YES;
    }
}

@end
