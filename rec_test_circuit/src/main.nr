use dep::std;

fn step_fib(
    index: u64,
    root: Field,
    in_x: u64,
    in_y: u64,
    in_index: u64,
    out_x: u64,
    out_y: u64,
    out_index: u64,
) {
  assert(index == in_index);
  assert(index + 1 == out_index);

  let nullifier = std::hash::pedersen_hash([in_x as Field, in_y as Field, out_x as Field, out_y as Field]);
  assert(root == nullifier);

  assert(in_y == out_x);
  assert(in_x + in_y == out_y);
}

global PUBLIC_INPUTS = 10;
// PUBLIC_INPUTS + 1
global PRIVATE_INPUTS = 11;

fn main(
    index: u64,
    verification_key: [Field; 114],
    proof: [[Field; 97]; 10],
    public_inputs: [[Field; 1]; PUBLIC_INPUTS],
    private_inputs: [(u64, u64, u64); PRIVATE_INPUTS],
    key_hash: Field,
    input_aggregation_object: [Field; 16],
) -> pub [Field; 16] {
    assert(index < PUBLIC_INPUTS);

    step_fib(
        index,
        public_inputs[index][0],
        private_inputs[index].0,
        private_inputs[index].1,
        private_inputs[index].2,
        private_inputs[index+1].0,
        private_inputs[index+1].1,
        private_inputs[index+1].2,
    );

    std::verify_proof(
        verification_key.as_slice(),
        proof[index].as_slice(),
        public_inputs[index].as_slice(),
        key_hash,
        input_aggregation_object
    )
}

