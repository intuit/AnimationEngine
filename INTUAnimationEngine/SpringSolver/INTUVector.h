//
//  INTUVector.h
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

#ifndef INTUVector_h
#define INTUVector_h

#include <math.h>

static inline void zeroVector(int dimensions, double *components)
{
    for (int i = 0; i < dimensions; i++) {
        components[i] = 0.0;
    }
}

static inline void copyVector(int dimensions, const double *input, double *output)
{
    for (int i = 0; i < dimensions; i++) {
        output[i] = input[i];
    }
}

static inline void multiplyScalarWithVector(int dimensions, double scalar, const double *input, double *output)
{
    for (int i = 0; i < dimensions; i++) {
        output[i] = input[i] * scalar;
    }
}

static inline void addVectors(int dimensions, const double *v1, const double *v2, double *output)
{
    for (int i = 0; i < dimensions; i++) {
        output[i] = v1[i] + v2[i];
    }
}

static inline void subVectors(int dimensions, const double *v1, const double *v2, double *output)
{
    for (int i = 0; i < dimensions; i++) {
        output[i] = v1[i] - v2[i];
    }
}

static inline double squaredNorm(int dimensions, const double *v)
{
    double result = 0.0;
    
    for (int i = 0; i < dimensions; i++) {
        result += v[i] * v[i];
    }
    
    return result;
}

static inline double norm(int dimensions, const double *v)
{
    return sqrt(squaredNorm(dimensions, v));
}

#endif /* INTUVector_h */
