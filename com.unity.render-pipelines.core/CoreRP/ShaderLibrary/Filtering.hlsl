#ifndef UNITY_FILTERING_INCLUDED
#define UNITY_FILTERING_INCLUDED

// Basic B-Spline of the 2nd degree (3rd order, support = 4).
// The fractional coordinate of each part is assumed to be in the [0, 1] range.
// https://www.desmos.com/calculator/479pgatwlt
//
// Sample use-case:
// float2 xy = uv * resolution.xy;
// float2 ic = floor(xy);    // Note-centered (primal grid)
// float2 fc = 1 - frac(xy); // Inverse-translate the filter centered around 0.5
// Then pass x = fc.
//
real2 BSpline2Left(real2 x)
{
    return 0.5 * x * x;
}

real2 BSpline2Middle(real2 x)
{
    return (1 - x) * x + 0.5;
}

real2 BSpline2Right(real2 x)
{
    return (0.5 * x - 1) * x + 0.5;
}

// Basic B-Spline of the 3nd degree (4th order, support = 4).
// The fractional coordinate of each part is assumed to be in the [0, 1] range.
// https://www.desmos.com/calculator/479pgatwlt
//
// Sample use-case:
// float2 xy = uv * resolution.xy;
// float2 ic = round(xy) + 0.5; // Cell-centered (dual grid)
// float2 fc = ic - xy;         // Inverse-translate the the filter around 0.5 with a wrap
// Then pass x = fc.
//
real2 BSpline3Leftmost(real2 x)
{
    return 0.16666667 * x * x * x;
}

real2 BSpline3MiddleLeft(real2 x)
{
    return 0.16666667 + x * (0.5 + x * (0.5 - x * 0.5));
}

real2 BSpline3MiddleRight(real2 x)
{
    return 0.66666667 + x * (-1.0 + 0.5 * x) * x;
}

real2 BSpline3Rightmost(real2 x)
{
    return 0.16666667 + x * (-0.5 + x * (0.5 - x * 0.16666667));
}

// Compute weights & offsets for 4x bilinear taps for the biquadratic B-Spline filter.
// The fractional coordinate should be in the [0, 1] range (centered on 0.5).
// Inspired by: http://vec3.ca/bicubic-filtering-in-fewer-taps/
void BiquadraticFilter(float2 fracCoord, out float2 weights[2], out float2 offsets[2])
{
    float2 l = BSpline2Left(fracCoord);
    float2 m = BSpline2Middle(fracCoord);
    float2 r = 1 - l - m;

    // Compute offsets for 4x bilinear taps for the quadratic B-Spline reconstruction kernel.
    // 0: lerp between left and middle
    // 1: lerp between middle and right
    weights[0] = l + 0.5 * m;
    weights[1] = r + 0.5 * m;
    offsets[0] = -0.5 + 0.5 * m * rcp(weights[0]);
    offsets[1] =  0.5 + r * rcp(weights[1]);
}

// If half is natively supported, create another variant
#if HAS_HALF
void BiquadraticFilter(half2 fracCoord, out half2 weights[2], out half2 offsets[2])
{
    half2 l = BSpline2Left(fracCoord);
    half2 m = BSpline2Middle(fracCoord);
    half2 r = 1 - l - m;

    // Compute offsets for 4x bilinear taps for the quadratic B-Spline reconstruction kernel.
    // 0: lerp between left and middle
    // 1: lerp between middle and right
    weights[0] = l + 0.5 * m;
    weights[1] = r + 0.5 * m;
    offsets[0] = -0.5 + 0.5 * m * rcp(weights[0]);
    offsets[1] =  0.5 + r * rcp(weights[1]);
}
#endif

#endif // UNITY_FILTERING_INCLUDED
