#![no_std]
use core::ops::{Add, AddAssign, Div, DivAssign, Mul, MulAssign, Sub, SubAssign};
use num_traits::{Euclid, One, Signed, Zero, float::Float};

/// Trait for types that support trigonometric functions.
/// `Float` already implements this for f32/f64.
pub trait FloatMath: Copy {
    fn cos(self) -> Self;
    fn frac_pi_2() -> Self;
    fn max(self, other: Self) -> Self;
    fn min(self, other: Self) -> Self;
    fn pi() -> Self;
    fn sin(self) -> Self;
    fn sin_cos(self) -> (Self, Self);
    fn tau() -> Self;
}

// Blanket implementation for all Floats
impl<T: Float + num_traits::FromPrimitive> FloatMath for T {
    fn cos(self) -> Self {
        Float::cos(self)
    }
    fn frac_pi_2() -> Self {
        T::from_f64(core::f64::consts::FRAC_PI_2).unwrap()
    }
    fn max(self, other: Self) -> Self {
        Float::max(self, other)
    }
    fn min(self, other: Self) -> Self {
        Float::min(self, other)
    }
    fn pi() -> Self {
        T::from_f64(core::f64::consts::PI).unwrap()
    }
    fn sin(self) -> Self {
        Float::sin(self)
    }
    fn sin_cos(self) -> (Self, Self) {
        Float::sin_cos(self)
    }
    fn tau() -> Self {
        T::from_f64(core::f64::consts::TAU).unwrap()
    }
}

// Library Scalar trait.
pub trait Scalar:
    Add<Output = Self>
    + AddAssign
    + Copy
    + Div<Output = Self>
    + DivAssign
    + Euclid
    + FloatMath
    + Mul<Output = Self>
    + MulAssign
    + One
    + PartialOrd
    + Signed
    + Sub<Output = Self>
    + SubAssign
    + Zero
{
}

// Blanket Scalar implementation.
impl<T> Scalar for T where
    T: Add<Output = Self>
        + AddAssign
        + Copy
        + Div<Output = Self>
        + DivAssign
        + Euclid
        + FloatMath
        + Mul<Output = Self>
        + MulAssign
        + One
        + PartialOrd
        + Signed
        + Sub<Output = Self>
        + SubAssign
        + Zero
{
}

/// State vector for tracking position and derivatives.
/// Used for price momentum and jolt-based signal detection.
pub struct StateVector<T: Scalar, const D: usize>(pub [T; D]);

impl<T: Scalar, const D: usize> StateVector<T, D> {
    pub fn position(&self) -> Option<T> {
        self.derivative(0)
    }
    pub fn velocity(&self) -> Option<T> {
        self.derivative(1)
    }
    pub fn acceleration(&self) -> Option<T> {
        self.derivative(2)
    }
    pub fn jolt(&self) -> Option<T> {
        self.derivative(3)
    }
    pub fn derivative(&self, n: usize) -> Option<T> {
        self.0.get(n).copied()
    }
}

impl<T: Scalar, const D: usize> Add for StateVector<T, D> {
    type Output = Self;

    fn add(self, rhs: Self) -> Self::Output {
        let mut result = [T::zero(); D];
        for (r, (a, b)) in result.iter_mut().zip(self.0.iter().zip(rhs.0.iter())) {
            *r = *a + *b;
        }
        StateVector(result)
    }
}

impl<T: Scalar, const D: usize> Sub for StateVector<T, D> {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self::Output {
        let mut result = [T::zero(); D];
        for (r, (a, b)) in result.iter_mut().zip(self.0.iter().zip(rhs.0.iter())) {
            *r = *a - *b;
        }
        StateVector(result)
    }
}

// =============================================================================
// CLMM (Concentrated Liquidity Market Maker) Types
// =============================================================================

/// Configuration for a CLMM liquidity range.
///
/// In concentrated liquidity AMMs like Raydium CLMM, liquidity is provided
/// within specific price ranges defined by ticks. This replaces the traditional
/// grid trading approach with DeFi-native tick-based positioning.
///
/// ## Tick Math
///
/// Price at tick i: `price = 1.0001^i`
/// Tick at price p: `tick = log(price) / log(1.0001)`
///
/// ## Example
///
/// ```
/// use joltshark::CLMMConfig;
/// let config: CLMMConfig<f64> = CLMMConfig {
///     tick_lower: -1000,  // Lower bound tick
///     tick_upper: 1000,   // Upper bound tick
///     tick_spacing: 10,   // Minimum tick increment
///     current_tick: 0,    // Current price tick
///     base_price: 1.0,    // Base price at tick 0
/// };
/// ```
pub struct CLMMConfig<T: Scalar> {
    /// Lower tick boundary of the liquidity range
    pub tick_lower: i32,
    /// Upper tick boundary of the liquidity range
    pub tick_upper: i32,
    /// Tick spacing (determines valid tick values)
    pub tick_spacing: i32,
    /// Current price tick
    pub current_tick: i32,
    /// Base price for tick 0 (optional reference)
    pub base_price: T,
}

impl<T: Scalar> CLMMConfig<T> {
    /// Returns true if the current tick is within the liquidity range.
    pub fn is_in_range(&self) -> bool {
        self.current_tick >= self.tick_lower && self.current_tick < self.tick_upper
    }

    /// Rounds a tick to the nearest valid tick based on tick_spacing.
    pub fn round_tick(&self, tick: i32) -> i32 {
        let spacing = self.tick_spacing;
        ((tick as f64 / spacing as f64).round() as i32) * spacing
    }
}

impl<T: ScalarExt> CLMMConfig<T> {
    /// Returns the tick at a given price.
    ///
    /// Uses the formula: tick = log(price / base_price) / log(1.0001)
    pub fn tick_at_price(&self, price: T) -> i32 {
        // log(price / base_price) / log(1.0001)
        let ratio = price / self.base_price;
        let log_ratio = ratio.ln();
        let log_base = T::from_f64(Float::ln(1.0001_f64)).unwrap();
        let tick = log_ratio / log_base;
        tick.to_i32().unwrap_or(0)
    }

    /// Returns the price at a given tick.
    ///
    /// Uses the formula: price = base_price * 1.0001^tick
    pub fn price_at_tick(&self, tick: i32) -> T {
        let base = T::from_f64(1.0001).unwrap();
        let tick_scalar = T::from_i32(tick).unwrap();
        self.base_price * base.powf(tick_scalar)
    }

    /// Returns the position within the range as a normalized value [0, 1].
    pub fn range_position(&self) -> T {
        if !self.is_in_range() {
            if self.current_tick < self.tick_lower {
                return T::zero();
            } else {
                return T::one();
            }
        }
        let current = T::from_i32(self.current_tick).unwrap();
        let lower = T::from_i32(self.tick_lower).unwrap();
        let upper = T::from_i32(self.tick_upper).unwrap();
        (current - lower) / (upper - lower)
    }
}

/// Commands for CLMM position management.
///
/// These commands represent actions that can be taken on a concentrated
/// liquidity position based on market conditions and signal analysis.
pub enum CLMMCommand<T: Scalar> {
    /// Add liquidity at the specified tick range
    AddLiquidity {
        tick_lower: i32,
        tick_upper: i32,
        amount: T,
    },
    /// Remove liquidity from the current position
    RemoveLiquidity { amount: T },
    /// Rebalance position to a new tick range
    Rebalance {
        new_tick_lower: i32,
        new_tick_upper: i32,
    },
    /// Collect accumulated fees
    CollectFees,
    /// Hold current position (no action)
    Hold,
    /// Wait for better conditions
    Wait,
    /// Exit position entirely (emergency)
    Exit,
}

/// Evaluates the current state and returns a CLMM command.
///
/// Uses jolt (4th derivative of price) as a volatility indicator.
/// High jolt values suggest rapid momentum changes that may require
/// position adjustment or exit.
pub fn evaluate_clmm_position<T: Scalar, const D: usize>(
    state: &StateVector<T, D>,
    config: &CLMMConfig<T>,
    jolt_limit: T,
) -> CLMMCommand<T> {
    // Check for extreme volatility via jolt
    if let Some(j) = state.jolt() {
        if jolt_limit < j.abs() {
            return CLMMCommand::Exit;
        }
    }

    // Check if price is in range
    if !config.is_in_range() {
        // Price has moved out of range, consider rebalancing
        let new_center = config.current_tick;
        let half_range = (config.tick_upper - config.tick_lower) / 2;
        let new_lower = config.round_tick(new_center - half_range);
        let new_upper = config.round_tick(new_center + half_range);

        return CLMMCommand::Rebalance {
            new_tick_lower: new_lower,
            new_tick_upper: new_upper,
        };
    }

    // Position is in range, hold
    CLMMCommand::Hold
}

// =============================================================================
// Range Utility Functions
// =============================================================================

pub fn range_clamp<T: Scalar>(position: T, range_start: T, range_end: T) -> T {
    range_start.max(position).min(range_end)
}

pub fn range_normalize<T: Scalar>(position: T, range_start: T, range_end: T) -> T {
    (position - range_start) / (range_end - range_start)
}

pub fn range_normalize_clamped<T: Scalar>(position: T, range_start: T, range_end: T) -> T {
    let normalized_position = range_normalize(position, range_start, range_end);
    range_clamp(normalized_position, T::zero(), T::one())
}

pub fn range_map<T: Scalar>(
    position: T,
    range_start: T,
    range_end: T,
    blend_start: T,
    blend_end: T,
) -> T {
    let normalized_position = range_normalize(position, range_start, range_end);
    blend_start + normalized_position * (blend_end - blend_start)
}

pub fn range_map_clamped<T: Scalar>(
    position: T,
    range_start: T,
    range_end: T,
    blend_start: T,
    blend_end: T,
) -> T {
    let mapped_position = range_map(position, range_start, range_end, blend_start, blend_end);
    range_clamp(mapped_position, blend_start, blend_end)
}

/// Maps a position within a modular (wrapped) range.
///
/// Assumes `position` is between `range_start` and `range_end` in modular space.
/// Result will overflow past `blend_end` if this is not the case.
fn range_map_modular<T: Scalar>(
    position: T,
    divisor: T,
    range_start: T,
    range_end: T,
    blend_start: T,
    blend_end: T,
) -> T {
    // compute modular interval length
    let length = (range_end - range_start).rem_euclid(&divisor);

    // compute modular offset of value from start
    let offset = (position - range_start).rem_euclid(&divisor);

    // scale to output range
    blend_start + offset / length * (blend_end - blend_start)
}

// =============================================================================
// Cyclic Signal Functions
// =============================================================================

/// Cyclic interpolation between two signals.
///
/// `phase` is expected to be in [0, tau), representing a full cycle.
/// Produces a smooth blend: +primary -> +alternative -> -primary -> -alternative.
/// For an orthogonal spherical linear interpolation, restrict `phase` to [0, pi/2].
pub fn cycle_interpolate<T: Scalar>(phase: T, primary_signal: T, alternative_signal: T) -> T {
    let (s, c) = phase.sin_cos();
    primary_signal * c + alternative_signal * s
}

/// Returns true if `value` is inside the modular interval [start, end).
fn in_modular_range<T: Scalar>(value: T, start: T, end: T) -> bool {
    if start <= end {
        // Normal interval
        start <= value && value < end
    } else {
        // Wrapped interval
        value < end || start <= value
    }
}

/// Generates a smooth pulse signal for event-based blending.
///
/// `phase` is expected to be in [0, tau), representing a full cycle.
/// `event_start` and `event_end` are expected to be in [0, tau).
/// Returns (x, y) coordinates on a unit circle representing the blend state.
pub fn event_pulse<T: Scalar>(
    phase: T,
    event_start: T,
    event_end: T,
    blend_outer: T,
    blend_inner: T,
) -> (T, T) {
    // neutral signal
    let (ns, nc) = T::zero().sin_cos();

    // blending start and end points
    let ta = (event_start - blend_outer).rem_euclid(&T::tau());
    let tb = (event_start + blend_inner).rem_euclid(&T::tau());
    let tc = (event_end - blend_inner).rem_euclid(&T::tau());
    let td = (event_end + blend_outer).rem_euclid(&T::tau());

    // blending phase
    let in_blend_in = in_modular_range(phase, ta, tb);
    let in_event = in_modular_range(phase, tb, tc);
    let in_blend_out = in_modular_range(phase, tc, td);

    let (es, ec) = if in_blend_in {
        let blend_phase = range_map_modular(phase, T::tau(), ta, tb, T::zero(), T::frac_pi_2());
        let blend_target =
            range_map_modular(tb, T::tau(), event_start, event_end, T::zero(), T::tau());
        let (ts, tc) = blend_target.sin_cos();
        (
            cycle_interpolate(blend_phase, ns, ts),
            cycle_interpolate(blend_phase, nc, tc),
        )
    } else if in_event {
        let event_phase =
            range_map_modular(phase, T::tau(), event_start, event_end, T::zero(), T::tau());
        event_phase.sin_cos()
    } else if in_blend_out {
        let blend_phase = range_map_modular(phase, T::tau(), tc, td, T::zero(), T::frac_pi_2());
        let blend_target =
            range_map_modular(tc, T::tau(), event_start, event_end, T::zero(), T::tau());
        let (ts, tc) = blend_target.sin_cos();
        (
            cycle_interpolate(blend_phase, ts, ns),
            cycle_interpolate(blend_phase, tc, nc),
        )
    } else {
        (ns, nc)
    };
    (ec, es)
}

// =============================================================================
// Trait Extensions for Scalar Conversions
// =============================================================================

/// Extension trait for converting between scalar types and integers.
pub trait ScalarExt: Scalar {
    fn from_i32(n: i32) -> Option<Self>;
    fn from_f64(n: f64) -> Option<Self>;
    fn to_i32(self) -> Option<i32>;
    fn ln(self) -> Self;
    fn powf(self, n: Self) -> Self;
}

impl<T: Scalar + num_traits::FromPrimitive + num_traits::ToPrimitive + Float> ScalarExt for T {
    fn from_i32(n: i32) -> Option<Self> {
        <T as num_traits::FromPrimitive>::from_i32(n)
    }

    fn from_f64(n: f64) -> Option<Self> {
        <T as num_traits::FromPrimitive>::from_f64(n)
    }

    fn to_i32(self) -> Option<i32> {
        <T as num_traits::ToPrimitive>::to_i32(&self)
    }

    fn ln(self) -> Self {
        Float::ln(self)
    }

    fn powf(self, n: Self) -> Self {
        Float::powf(self, n)
    }
}

// =============================================================================
// Tests
// =============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::*;

    #[test]
    fn test_clmm_config_in_range() {
        let config = CLMMConfig {
            tick_lower: -1000,
            tick_upper: 1000,
            tick_spacing: 10,
            current_tick: 0,
            base_price: 1.0_f64,
        };
        assert!(config.is_in_range());
    }

    #[test]
    fn test_clmm_config_out_of_range() {
        let config = CLMMConfig {
            tick_lower: -1000,
            tick_upper: 1000,
            tick_spacing: 10,
            current_tick: 1500,
            base_price: 1.0_f64,
        };
        assert!(!config.is_in_range());
    }

    #[test]
    fn test_clmm_range_position() {
        let config = CLMMConfig {
            tick_lower: 0,
            tick_upper: 100,
            tick_spacing: 10,
            current_tick: 50,
            base_price: 1.0_f64,
        };
        let position = config.range_position();
        assert!((position - 0.5).abs() < 0.001);
    }

    #[test]
    fn test_clmm_round_tick() {
        let config = CLMMConfig {
            tick_lower: 0,
            tick_upper: 100,
            tick_spacing: 10,
            current_tick: 0,
            base_price: 1.0_f64,
        };
        assert_eq!(config.round_tick(15), 20);
        assert_eq!(config.round_tick(14), 10);
        assert_eq!(config.round_tick(25), 30);
    }

    #[rstest]
    #[case::midday_early(0.25, 11.0, 10.0, 14.0)]
    #[case::midday_exact(0.5, 12.0, 10.0, 14.0)]
    #[case::midday_late(0.75, 13.0, 10.0, 14.0)]
    #[case::midnight_early(0.25, 23.5, 23.0, 25.0)]
    #[case::midnight_exact(0.5, 0.0, 23.0, 25.0)]
    #[case::midnight_late(0.75, 0.5, 23.0, 25.0)]
    #[case::out_of_range(0.0, 9.0, 0.0, 8.0)]
    fn test_event_pulse_no_blending(
        #[case] expected_position: f64,
        #[case] phase: f64,
        #[case] event_start: f64,
        #[case] event_end: f64,
    ) {
        let acceptable_error = 0.001;
        let tau = core::f64::consts::TAU;
        let expected_position = range_map(expected_position, 0.0, 1.0, 0.0, tau);
        let (expected_y, expected_x) = expected_position.sin_cos();
        let phase = range_map(phase, 0.0, 24.0, 0.0, tau);
        let event_start = range_map(event_start, 0.0, 24.0, 0.0, tau);
        let event_end = range_map(event_end, 0.0, 24.0, 0.0, tau);
        let blend_outer = core::f64::EPSILON;
        let blend_inner = core::f64::EPSILON;
        let (x, y) = event_pulse(phase, event_start, event_end, blend_outer, blend_inner);
        assert!(
            (expected_x - x).abs() < acceptable_error,
            "x is not expected value"
        );
        assert!(
            (expected_y - y).abs() < acceptable_error,
            "y is not expected value"
        );
    }

    #[rstest]
    #[case::midday_symmetrical_full_blend_in_starting_point(0.0, 8.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_in_early(0.25, 9.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_in_middle(0.5, 10.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_in_late(0.75, 11.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_in_ending_point(1.0, 12.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_out_starting_point(1.0, 12.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_out_early(0.75, 13.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_out_middle(0.5, 14.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_out_late(0.25, 15.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_full_blend_out_ending_point(0.0, 16.0, 10.0, 14.0, 2.0, 2.0)]
    #[case::midday_symmetrical_half_blend_in_starting_point(0.0, 9.0, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_in_early(0.25, 9.5, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_in_middle(0.5, 10.0, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_in_late(0.75, 10.5, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_in_ending_point(1.0, 11.0, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_out_starting_point(1.0, 13.0, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_out_early(0.75, 13.5, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_out_middle(0.5, 14.0, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_out_late(0.25, 14.5, 10.0, 14.0, 1.0, 1.0)]
    #[case::midday_symmetrical_half_blend_out_ending_point(0.0, 15.0, 10.0, 14.0, 1.0, 1.0)]
    #[case::midnight_blend_in_starting_point(0.0, 22.5, 23.5, 3.5, 1.0, 1.0)]
    #[case::midnight_blend_in_early(0.25, 23.0, 23.5, 3.5, 1.0, 1.0)]
    #[case::midnight_blend_in_middle(0.5, 23.5, 23.5, 3.5, 1.0, 1.0)]
    #[case::midnight_blend_in_late(0.75, 0.0, 23.5, 3.5, 1.0, 1.0)]
    #[case::midnight_blend_in_ending_point(1.0, 0.5, 23.5, 3.5, 1.0, 1.0)]
    #[case::out_of_range(0.0, 0.0, 10.0, 14.0, 1.0, 1.0)]
    fn test_event_pulse_blending(
        #[case] expected_position: f64,
        #[case] phase: f64,
        #[case] event_start: f64,
        #[case] event_end: f64,
        #[case] blend_outer: f64,
        #[case] blend_inner: f64,
    ) {
        let acceptable_error = 0.001;
        let tau = core::f64::consts::TAU;
        let (ns, nc) = 0.0_f64.sin_cos();
        let event_length = (event_end - event_start + 2.0 * blend_inner).rem_euclid(24.0);
        let event_offset = (phase - event_start + blend_inner).rem_euclid(24.0);
        let target = if event_offset <= event_length / 2.0 {
            range_map_modular(
                event_start + blend_inner,
                24.0,
                event_start,
                event_end,
                0.0,
                tau,
            )
        } else {
            range_map_modular(
                event_end - blend_inner,
                24.0,
                event_start,
                event_end,
                0.0,
                tau,
            )
        };
        let (ts, tc) = target.sin_cos();
        let expected_position = range_map(expected_position, 0.0, 1.0, 0.0, tau / 4.0);
        let (es, ec) = expected_position.sin_cos();
        let (expected_x, expected_y) = ((nc * ec + tc * es), (ns * ec + ts * es));
        let phase = range_map(phase, 0.0, 24.0, 0.0, tau);
        let event_start = range_map(event_start, 0.0, 24.0, 0.0, tau);
        let event_end = range_map(event_end, 0.0, 24.0, 0.0, tau);
        let blend_outer = range_map(blend_outer, 0.0, 24.0, 0.0, tau);
        let blend_inner = range_map(blend_inner, 0.0, 24.0, 0.0, tau);
        let (x, y) = event_pulse(phase, event_start, event_end, blend_outer, blend_inner);
        assert!(
            (expected_x - x).abs() < acceptable_error,
            "x is not expected value"
        );
        assert!(
            (expected_y - y).abs() < acceptable_error,
            "y is not expected value"
        );
    }
}
