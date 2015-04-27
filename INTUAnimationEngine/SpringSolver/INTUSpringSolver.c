//
//  INTUSpringSolver.c
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

#include "INTUSpringSolver.h"
#include "INTUVector.h"
#include <stdlib.h>

/** The time step that the solver uses, in seconds. */
const double kINTUSolverDt = 0.001;

/** The factor that is multiplied with the norm of the initial position to determine a threshold value. */
const double kINTUThresholdFactor = 0.0001; // 0.01%

struct INTUSpringSolverContext {
    /** The stiffness of the spring. Must be greater than zero. */
    double stiffness;
    /** The amount of friction. Must be greater than or equal to zero. If exactly zero, the harmonic motion will continue forever and the solver will never converge.  */
    double damping;
    /** The amount of mass being moved by the spring. Must be greater than zero. */
    double mass;
    
    /** The threshold used to determine when the position is sufficiently close to the quiescent state. */
    double thresholdPosition;
    /** The threshold used to determine when the velocity is sufficiently close to the quiescent state. */
    double thresholdVelocity;
    /** The threshold used to determine when the acceleration is sufficiently close to the quiescent state. */
    double thresholdAcceleration;
    
    /** The time when the spring solver was last advanced. */
    double lastTime;
    /** The accumulated time that remains over which the spring's state needs to be calculated. */
    double accumulatedTime;
    
    /** The current position of the mass on the spring. */
    double currentPosition[kINTUSpringSolverDimensions];
    /** The current velocity of the mass on the spring. */
    double currentVelocity[kINTUSpringSolverDimensions];
    /** The current acceleration of the mass on the spring. */
    double currentAcceleration[kINTUSpringSolverDimensions];
    
    /** Whether the system that this context represents has been advanced yet. */
    bool started;
};
/** A private struct that stores the internal state of the spring solver. */
typedef struct INTUSpringSolverContext INTUSpringSolverContext;


static void resetContext(INTUSpringSolverContextRef context);

static void setConstants(INTUSpringSolverContextRef context, double k, double b, double m);

static void setThreshold(INTUSpringSolverContextRef context, double t);

static void integrate(INTUSpringSolverContextRef context,
                      const double *positionVector,
                      const double *velocityVector,
                      double t,
                      double dt,
                      double *outputPositionVector,
                      double *outputVelocityVector);

static void derivative(int dimension,
                       double *ax,
                       double *bx,
                       double *cx,
                       double *dx,
                       double *output);

static void evaluate(INTUSpringSolverContextRef context,
                     const double *positionVector,
                     const double *velocityVector,
                     double t,
                     double *deltaPosition,
                     double *deltaVelocity);

static void evaluateWithDerivative(INTUSpringSolverContextRef context,
                                   const double *positionVector,
                                   const double *velocityVector,
                                   double t,
                                   double dt,
                                   const double *inputDeltaPosition,
                                   const double *inputDeltaVelocity,
                                   double *outputDeltaPosition,
                                   double *outputDeltaVelocity);

static void acceleration(const INTUSpringSolverContextRef context,
                         const double *positionVector,
                         const double *velocityVector,
                         double t,
                         double *accelerationVector);

static void interpolate(int dimension,
                        const double *previousPositionVector,
                        const double *previousVelocityVector,
                        const double *currentPositionVector,
                        const double *currentVelocityVector,
                        double alpha,
                        double *outputPositionVector,
                        double *outputVelocityVector);


#pragma mark Public API

INTUSpringSolverContextRef INTUSpringSolverContextCreate(double stiffness,
                                                         double damping,
                                                         double mass,
                                                         const double *initialPosition,
                                                         const double *initialVelocity)
{
    if (stiffness <= 0.0 ||
        damping < 0.0 ||
        mass <= 0.0 ||
        initialPosition == NULL ||
        initialVelocity == NULL) {
        return NULL;
    }
    
    INTUSpringSolverContextRef context = malloc(sizeof(INTUSpringSolverContext));
    
    resetContext(context);
    
    setConstants(context, stiffness, damping, mass);
    
    // Take the norm of the initial position and multiply it by the threshold factor to get the threshold value.
    // This makes the threshold relative to the scale of whatever unit is being used in the starting position.
    double threshold = norm(kINTUSpringSolverDimensions, initialPosition) * kINTUThresholdFactor;
    setThreshold(context, threshold);
    
    copyVector(kINTUSpringSolverDimensions, initialPosition, context->currentPosition);
    copyVector(kINTUSpringSolverDimensions, initialVelocity, context->currentVelocity);
    
    return context;
}

void INTUSpringSolverContextDestroy(INTUSpringSolverContextRef context)
{
    free(context);
}

INTUSpringState INTUAdvanceSpringSolver(INTUSpringSolverContextRef context, double newTime)
{
    context->started = true;
    
    if (newTime < context->lastTime) {
        // The spring solver must always be advanced; sending in a newTime earlier than the last time is invalid.
        resetContext(context);
        INTUSpringState zeroState = {0};
        return zeroState;
    }
    
    context->accumulatedTime += (newTime - context->lastTime);
    double t = context->lastTime;
    context->lastTime = newTime;
    
    double currentPosition[kINTUSpringSolverDimensions], currentVelocity[kINTUSpringSolverDimensions];
    double previousPosition[kINTUSpringSolverDimensions], previousVelocity[kINTUSpringSolverDimensions];
    
    copyVector(kINTUSpringSolverDimensions, context->currentPosition, currentPosition);
    copyVector(kINTUSpringSolverDimensions, context->currentVelocity, currentVelocity);
    copyVector(kINTUSpringSolverDimensions, currentPosition, previousPosition);
    copyVector(kINTUSpringSolverDimensions, currentVelocity, previousVelocity);
    
    while (context->accumulatedTime >= kINTUSolverDt) {
        copyVector(kINTUSpringSolverDimensions, currentPosition, previousPosition);
        copyVector(kINTUSpringSolverDimensions, currentVelocity, previousVelocity);
        
        integrate(context, previousPosition, previousVelocity, t, kINTUSolverDt, currentPosition, currentVelocity);
        
        t += kINTUSolverDt;
        context->accumulatedTime -= kINTUSolverDt;
    }
    
    double alpha = context->accumulatedTime / kINTUSolverDt;
    double advancedPosition[kINTUSpringSolverDimensions], advancedVelocity[kINTUSpringSolverDimensions];
    
    interpolate(kINTUSpringSolverDimensions, previousPosition, previousVelocity, currentPosition, currentVelocity, alpha, advancedPosition, advancedVelocity);
    copyVector(kINTUSpringSolverDimensions, advancedPosition, context->currentPosition);
    copyVector(kINTUSpringSolverDimensions, advancedVelocity, context->currentVelocity);
    
    INTUSpringState newState;
    copyVector(kINTUSpringSolverDimensions, context->currentPosition, newState.position);
    return newState;
}

bool INTUSpringSolverHasConverged(INTUSpringSolverContextRef context)
{
    if (!context->started) {
        return false;
    }
    
    // Look at each dimension of the position vector, if any is significantly far away from zero, we have not converged.
    // In order for the spring solver to converge, the position vector must be approaching zero (with a tolerance of the threshold value).
    for (int i = 0; i < kINTUSpringSolverDimensions; i++) {
        if (fabs(context->currentPosition[i]) >= context->thresholdPosition) {
            return false;
        }
    }
    
    bool velocityConverged = (squaredNorm(kINTUSpringSolverDimensions, context->currentVelocity) < context->thresholdVelocity);
    
    bool accelerationConverged = (squaredNorm(kINTUSpringSolverDimensions, context->currentAcceleration) < context->thresholdAcceleration);
    
    return velocityConverged && accelerationConverged;
}

#pragma mark Internal Functions

static void resetContext(INTUSpringSolverContextRef context)
{
    context->lastTime = 0.0;
    context->accumulatedTime = 0.0;
    zeroVector(kINTUSpringSolverDimensions, context->currentPosition);
    zeroVector(kINTUSpringSolverDimensions, context->currentVelocity);
    zeroVector(kINTUSpringSolverDimensions, context->currentAcceleration);
    context->started = false;
}

static void setConstants(INTUSpringSolverContextRef context, double k, double b, double m)
{
    context->stiffness = k;
    context->damping = b;
    context->mass = m;
}

static void setThreshold(INTUSpringSolverContextRef context, double threshold)
{
    context->thresholdPosition = threshold / 2; // half a unit
    context->thresholdVelocity = 25.0 * threshold; // 5 units per second, squared for comparison
    context->thresholdAcceleration = 625.0 * threshold * threshold; // 5 units per second squared, squared for comparison
}

static void integrate(INTUSpringSolverContextRef context,
                      const double *positionVector,
                      const double *velocityVector,
                      double t,
                      double dt,
                      double *outputPositionVector,
                      double *outputVelocityVector)
{
    double derivativePositionA[kINTUSpringSolverDimensions], derivativeVelocityA[kINTUSpringSolverDimensions];
    double derivativePositionB[kINTUSpringSolverDimensions], derivativeVelocityB[kINTUSpringSolverDimensions];
    double derivativePositionC[kINTUSpringSolverDimensions], derivativeVelocityC[kINTUSpringSolverDimensions];
    double derivativePositionD[kINTUSpringSolverDimensions], derivativeVelocityD[kINTUSpringSolverDimensions];
    double dpdt[kINTUSpringSolverDimensions], dvdt[kINTUSpringSolverDimensions];
    double dpdtTimesDt[kINTUSpringSolverDimensions], dvdtTimesDt[kINTUSpringSolverDimensions];
    
    evaluate(context, positionVector, velocityVector, t, derivativePositionA, derivativeVelocityA);
    
    evaluateWithDerivative(context, positionVector, velocityVector, t, dt*0.5, derivativePositionA, derivativeVelocityA, derivativePositionB, derivativeVelocityB);
    evaluateWithDerivative(context, positionVector, velocityVector, t, dt*0.5, derivativePositionB, derivativeVelocityB, derivativePositionC, derivativeVelocityC);
    evaluateWithDerivative(context, positionVector, velocityVector, t, dt, derivativePositionC, derivativeVelocityC, derivativePositionD, derivativeVelocityD);
    
    derivative(kINTUSpringSolverDimensions, derivativePositionA, derivativePositionB, derivativePositionC, derivativePositionD, dpdt);
    derivative(kINTUSpringSolverDimensions, derivativeVelocityA, derivativeVelocityB, derivativeVelocityC, derivativeVelocityD, dvdt);
    
    multiplyScalarWithVector(kINTUSpringSolverDimensions, dt, dpdt, dpdtTimesDt);
    multiplyScalarWithVector(kINTUSpringSolverDimensions, dt, dvdt, dvdtTimesDt);
    
    addVectors(kINTUSpringSolverDimensions, positionVector, dpdtTimesDt, outputPositionVector);
    addVectors(kINTUSpringSolverDimensions, velocityVector, dvdtTimesDt, outputVelocityVector);
    
    copyVector(kINTUSpringSolverDimensions, dvdt, context->currentAcceleration);
}

static void derivative(int dimension,
                       double *ax,
                       double *bx,
                       double *cx,
                       double *dx,
                       double *output)
{
    addVectors(dimension, bx, cx, output);
    multiplyScalarWithVector(dimension, 2.0, output, output);
    addVectors(dimension, ax, output, output);
    addVectors(dimension, output, dx, output);
    multiplyScalarWithVector(dimension, (1.0/6.0), output, output);
}

static void evaluate(INTUSpringSolverContextRef context,
                     const double *positionVector,
                     const double *velocityVector,
                     double t,
                     double *deltaPosition,
                     double *deltaVelocity)
{
    copyVector(kINTUSpringSolverDimensions, velocityVector, deltaPosition);
    acceleration(context, positionVector, velocityVector, t, deltaVelocity);
}

static void evaluateWithDerivative(INTUSpringSolverContextRef context,
                                   const double *initialPositionVector,
                                   const double *initialVelocityVector,
                                   double t,
                                   double dt,
                                   const double *inputDeltaPosition,
                                   const double *inputDeltaVelocity,
                                   double *outputDeltaPosition,
                                   double *outputDeltaVelocity)
{
    double dpdt[kINTUSpringSolverDimensions], dvdt[kINTUSpringSolverDimensions];
    double positionVector[kINTUSpringSolverDimensions], velocityVector[kINTUSpringSolverDimensions];
    
    multiplyScalarWithVector(kINTUSpringSolverDimensions, dt, inputDeltaPosition, dpdt);
    multiplyScalarWithVector(kINTUSpringSolverDimensions, dt, inputDeltaVelocity, dvdt);
    
    addVectors(kINTUSpringSolverDimensions, initialPositionVector, dpdt, positionVector);
    addVectors(kINTUSpringSolverDimensions, initialVelocityVector, dvdt, velocityVector);
    
    copyVector(kINTUSpringSolverDimensions, velocityVector, outputDeltaPosition);
    acceleration(context, positionVector, velocityVector, t+dt, outputDeltaVelocity);
}

static void acceleration(const INTUSpringSolverContextRef context,
                         const double *positionVector,
                         const double *velocityVector,
                         double t,
                         double *accelerationVector)
{
    double intermediate1[kINTUSpringSolverDimensions], intermediate2[kINTUSpringSolverDimensions];
    
    multiplyScalarWithVector(kINTUSpringSolverDimensions, (-context->stiffness/context->mass), positionVector, intermediate1);
    multiplyScalarWithVector(kINTUSpringSolverDimensions, (context->damping/context->mass), velocityVector, intermediate2);
    
    subVectors(kINTUSpringSolverDimensions, intermediate1, intermediate2, accelerationVector);
}

static void interpolate(int dimension,
                        const double *previousPositionVector,
                        const double *previousVelocityVector,
                        const double *currentPositionVector,
                        const double *currentVelocityVector,
                        double alpha,
                        double *outputPositionVector,
                        double *outputVelocityVector)
{
    double currentPositionTimesAlpha[kINTUSpringSolverDimensions], currentVelocityTimesAlpha[kINTUSpringSolverDimensions];
    
    multiplyScalarWithVector(dimension, alpha, currentPositionVector, currentPositionTimesAlpha);
    multiplyScalarWithVector(dimension, alpha, currentVelocityVector, currentVelocityTimesAlpha);
    
    multiplyScalarWithVector(dimension, (1-alpha), previousPositionVector, outputPositionVector);
    multiplyScalarWithVector(dimension, (1-alpha), previousVelocityVector, outputVelocityVector);
    
    addVectors(dimension, currentPositionTimesAlpha, outputPositionVector, outputPositionVector);
    addVectors(dimension, currentVelocityTimesAlpha, outputVelocityVector, outputVelocityVector);
}
