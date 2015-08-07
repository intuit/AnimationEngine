//
//  INTUSpringSolver.h
//  https://github.com/intuit/AnimationEngine
//
//  Copyright (c) 2014 Facebook, Inc. All rights reserved.
//  Copyright (c) 2015 Intuit Inc.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * Neither the name Facebook nor the names of its contributors may be used to
//     endorse or promote products derived from this software without specific
//     prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#ifndef INTUSpringSolver_h
#define INTUSpringSolver_h

#include <stdbool.h>

// The spring solver defaults to simulating a spring in a single dimension.
// To use more than one dimension, define the preprocessor macro INTU_SPRING_SOLVER_DIMENSIONS to the number of dimensions.
#ifdef INTU_SPRING_SOLVER_DIMENSIONS
#   define kINTUSpringSolverDimensions     INTU_SPRING_SOLVER_DIMENSIONS
#else
#   define kINTUSpringSolverDimensions     1
#endif

/** A reference to a private struct that stores the internal state of the spring solver. */
typedef struct INTUSpringSolverContext *INTUSpringSolverContextRef;

struct INTUSpringState {
    /** The position of the spring. */
    double position[kINTUSpringSolverDimensions];
};
/** A structure that holds the state of the spring solver at a given point in time. */
typedef struct INTUSpringState INTUSpringState;

/**
 Creates and returns a reference to a new spring solver context, initialized with the given properties.
 
 @param stiffness       The stiffness of the spring. Must be greater than zero. Typical range: 1.0 to 500.0
 @param damping         The amount of friction. Must be greater than or equal to zero. If exactly zero, the harmonic motion will continue
                        indefinitely (solver will never converge). Typical range: 1.0 to 30.0
 @param mass            The amount of mass being moved by the spring. Must be greater than zero. Typical range: 0.1 to 10.0
 @param initialPosition A vector representing the starting position of the mass attached to the spring. The spring always acts in the direction of the zero vector.
                        The vector must be an array of n double values, where n is the number of dimensions of the spring solver (kINTUSpringSolverDimensions).
 @param initialVelocity A vector representing the starting velocity of the mass attached to the spring.
                        The vector must be an array of n double values, where n is the number of dimensions of the spring solver (kINTUSpringSolverDimensions).
 
 @return A reference to the fully initialized spring solver context.
 
 @discussion The calling code takes ownership of the created context, and when finished with it must call INTUSpringSolverContextDestroy()
             passing in the reference to this context to avoid a memory leak.
 */
INTUSpringSolverContextRef  INTUSpringSolverContextCreate(double stiffness,
                                                          double damping,
                                                          double mass,
                                                          const double *initialPosition,
                                                          const double *initialVelocity);

/**
 Destroys (deallocates) the spring solver context at the given reference.
 
 @param context A reference to the spring solver context.
 
 @discussion This function must be called for each spring solver context created by INTUSpringSolverContextCreate() in order to
             deallocate the context and prevent a memory leak.
 */
void                        INTUSpringSolverContextDestroy(INTUSpringSolverContextRef context);

/**
 Advances the spring solver to the new time by calculating and returning the new state of the spring.
 
 @param context A reference to the spring solver context.
 @param newTime The new time (in seconds) to advance the spring solver to. The new time must be greater than zero,
                and greater than the time passed into the previous call to advance the spring solver.
 
 @return The new state of the spring after advancing the solver.
 */
INTUSpringState             INTUAdvanceSpringSolver(INTUSpringSolverContextRef context, double newTime);

/**
 Returns whether or not the spring solver has converged (reached its quiescent state).
 
 @param context A reference to the spring solver context.
 
 @return Whether or not the spring-mass system has reached its quiescent state.
 */
bool                        INTUSpringSolverHasConverged(INTUSpringSolverContextRef context);

#endif /* INTUSpringSolver_h */
