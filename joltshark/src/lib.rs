#![no_std]
use core::ops::{Add, AddAssign, Div, DivAssign, Mul, MulAssign, Sub, SubAssign};
use num_traits::{One, Signed, Zero};

// Library Scalar trait.
pub trait Scalar:
    Add<Output = Self>
    + AddAssign
    + Sub<Output = Self>
    + SubAssign
    + Mul<Output = Self>
    + MulAssign
    + Div<Output = Self>
    + DivAssign
    + PartialOrd
    + Copy
    + Zero
    + One
    + Signed
{
}

// Blanket Scalar implementation.
impl<T> Scalar for T where
    T: Add<Output = Self>
        + AddAssign
        + Sub<Output = Self>
        + SubAssign
        + Mul<Output = Self>
        + MulAssign
        + Div<Output = Self>
        + DivAssign
        + PartialOrd
        + Copy
        + Zero
        + One
        + Signed
{
}

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
        for i in 0..D {
            result[i] = self.0[i] + rhs.0[i];
        }
        StateVector(result)
    }
}

impl<T: Scalar, const D: usize> Sub for StateVector<T, D> {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self::Output {
        let mut result = [T::zero(); D];
        for i in 0..D {
            result[i] = self.0[i] - rhs.0[i];
        }
        StateVector(result)
    }
}

pub struct GridConfig<T: Scalar> {
    pub base_price: T,
    pub range_upper: T,
    pub range_lower: T,
    pub spacing: T,
}

impl<T: Scalar> GridConfig<T> {
    pub fn index_at_price(&self, price: T) -> T {
        (price - self.base_price) / self.spacing
    }

    pub fn price_at_index(&self, index: T) -> T {
        self.base_price + (index * self.spacing)
    }
}

pub enum GridCommand<T: Scalar> {
    Buy { price: T },
    Sell { price: T },
    Hold,
    Wait,
    Exit,
}

pub fn update_grid<T: Scalar, const D: usize>(
    state: &StateVector<T, D>,
    config: &GridConfig<T>,
    jolt_limit: T,
) -> GridCommand<T> {
    if let Some(j) = state.jolt() {
        if jolt_limit < j.abs() {
            return GridCommand::Exit;
        }
    }

    if let Some(pos) = state.position() {
        let _current_index = config.index_at_price(pos);
        GridCommand::Hold
    } else {
        GridCommand::Wait
    }
}

#[cfg(test)]
mod tests {
    //use super::*;

    #[test]
    fn pass() {
        assert!(true);
    }
}
