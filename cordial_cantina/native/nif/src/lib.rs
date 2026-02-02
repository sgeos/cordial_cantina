//! Cordial Cantina NIF bindings
//!
//! This crate provides Erlang NIF bindings for the Cordial Cantina trading system.
//! It exposes Rust functions from joltshark to the Elixir application via Rustler.

mod atoms {
    rustler::atoms! {
        ok,
    }
}

/// A no-operation function used to verify NIF loading.
///
/// This function does nothing but return :ok. It is called during application
/// startup to verify that the NIF library was loaded successfully.
#[rustler::nif]
fn nop() -> rustler::Atom {
    atoms::ok()
}

rustler::init!("Elixir.CordialCantina.Nif");

#[cfg(test)]
mod tests {
    /// Verify the crate compiles and joltshark is accessible.
    #[test]
    fn joltshark_accessible() {
        // Verify joltshark types are accessible
        let _: joltshark::GridCommand<f64> = joltshark::GridCommand::Hold;
    }
}
