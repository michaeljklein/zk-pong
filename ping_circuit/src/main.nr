// Ping circuit
//
// Kernel for ensuring timliness in a distributed system (two actors)

// (previous_state(w/ update?), signature(..))
// (current_state(w/ update?), signature(..))

fn main(x: Field, y: pub Field) {
    assert(x != y);
}

#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}

