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

  // let nullifier = std::hash::pedersen_hash([in_x as Field, in_y as Field, out_x as Field, out_y as Field]);
  // let nullifier = std::hash::poseidon::bn254::hash_5([index as Field, in_x as Field, in_y as Field, out_x as Field, out_y as Field]);

  let _nullifier = std::hash::poseidon::bn254::hash_2([index as Field,
    std::hash::poseidon::bn254::hash_2([in_x as Field,
      std::hash::poseidon::bn254::hash_2([in_y as Field,
        std::hash::poseidon::bn254::hash_2([out_x as Field, out_y as Field])
      ])
    ])
  ]);
  // TODO!
  // assert(root == nullifier);

  assert(in_y == out_x);
  assert(in_x + in_y == out_y);
}

global PUBLIC_INPUTS = 3;
// PUBLIC_INPUTS + 1
global PRIVATE_INPUTS = 4;

// TODO: check against MAIN
fn main(
    index: u64,
    verification_key: [Field; 114], // always 114
    proof: [[Field; 93]; 10], // 93 + num_public_inputs
    public_inputs: [[Field; 1]; PUBLIC_INPUTS],
    private_inputs: [[u64; 3]; PRIVATE_INPUTS],
    key_hash: Field,
) {
  assert(index < PUBLIC_INPUTS);

  step_fib(
      index,
      public_inputs[index][0],
      private_inputs[index][0],
      private_inputs[index][1],
      private_inputs[index][2],
      private_inputs[index+1][0],
      private_inputs[index+1][1],
      private_inputs[index+1][2],
  );

  if (index != 0) {
    std::verify_proof(
        verification_key.as_slice(),
        proof[index].as_slice(),
        public_inputs[index].as_slice(),
        key_hash,
    );

    std::verify_proof(
        verification_key.as_slice(),
        proof[index+1].as_slice(),
        public_inputs[index+1].as_slice(),
        key_hash,
    );

  }
}

