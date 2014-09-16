//
//  AnimationEngineInterpolationTests.m
//  AnimationEngineExampleTests
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "INTUInterpolationFunctions.h"

@interface AnimationEngineInterpolationTests : XCTestCase

@end

@implementation AnimationEngineInterpolationTests

- (void)testInterpolateDiscreteValues
{
    NSArray *values = @[@"A", @"B", @"C"];
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.0), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.5), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 1.0), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, -0.5), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, -500.0), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 1.5), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 800.0), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.32), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.34), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.66), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.67), @"C");
    
    values = @[@"A", @"B", @"C", @"D"];
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.0), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.33), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.66), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 1.0), @"D");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, -0.5), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, -500.0), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 1.5), @"D");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 800.0), @"D");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.24), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.26), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.49), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.51), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.74), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.76), @"D");
    
    values = @[@"A", @"B", @"C", @"D", @"E"];
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.0), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.25), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.5), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.75), @"D");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 1.0), @"E");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, -0.5), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, -500.0), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 1.5), @"E");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 800.0), @"E");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.19), @"A");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.21), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.39), @"B");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.41), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.59), @"C");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.61), @"D");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.79), @"D");
    XCTAssertEqualObjects(INTUInterpolateDiscreteValues(values, 0.81), @"E");
}

- (void)testInterpolateCGFloat
{
    XCTAssert(INTUInterpolateCGFloat(50.0, 100.0, 0.0) == 50.0);
    XCTAssert(INTUInterpolateCGFloat(50.0, 100.0, 1.0) == 100.0);
    XCTAssert(INTUInterpolateCGFloat(50.0, 100.0, 0.5) == 75.0);
    XCTAssert(INTUInterpolateCGFloat(50.0, 100.0, 0.2) == 60.0);
    XCTAssert(INTUInterpolateCGFloat(50.0, 100.0, -0.2) == 40.0);
    XCTAssert(INTUInterpolateCGFloat(50.0, 100.0, 1.2) == 110.0);
}

- (void)testInterpolate
{
    XCTAssertEqualObjects(INTUInterpolate(@(10), @(20), -0.5), @(5));
    XCTAssertEqualObjects(INTUInterpolate(@(10), @(20), 0.0), @(10));
    XCTAssertEqualObjects(INTUInterpolate(@(10), @(20), 0.5), @(15));
    XCTAssertEqualObjects(INTUInterpolate(@(10), @(20), 1.0), @(20));
    XCTAssertEqualObjects(INTUInterpolate(@(10), @(20), 1.5), @(25));
    
    XCTAssertEqualObjects(INTUInterpolate(@(-4.5), @(2.5), 0.0), @(-4.5));
    XCTAssertEqualObjects(INTUInterpolate(@(-4.5), @(2.5), 0.5), @(-1.0));
    XCTAssertEqualObjects(INTUInterpolate(@(-4.5), @(2.5), 1.0), @(2.5));
}

@end
