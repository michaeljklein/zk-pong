use dep::std;

global PUBLIC_INPUTS = 3;
// PUBLIC_INPUTS + 1
global PRIVATE_INPUTS = 4;

fn main(
    index: u64,
    // verification_key: [Field; 114], // always 114
    // proof: [[Field; 93]; 10], // 93 + num_public_inputs
    // public_inputs: [[Field; 1]; PUBLIC_INPUTS],
    // private_inputs: [[u64; 3]; PRIVATE_INPUTS],
    key_hash: Field,
) {
}

// fn main(
//     root: pub Field,
//     in_x: u64,
//     in_y: u64,
//
//     out_x: u64,
//     out_y: u64,
// ) {
//   let nullifier = std::hash::pedersen_hash([in_x as Field, in_y as Field, out_x as Field, out_y as Field]);
//   assert(root == nullifier);
//   assert(in_y == out_x);
//   assert(in_x + in_y == out_y);
// }
//
//
// #[test]
// fn test_main() {
//     let in_x = 0;
//     let in_y = 1;
//     let out_x = 1;
//     let out_y = 1;
//     let nullifier = std::hash::pedersen_hash([in_x as Field, in_y as Field, out_x as Field, out_y as Field]);
//     main(nullifier, in_x, in_y, out_x, out_y);
//
//     // Uncomment to make test fail
//     // main(1, 1);
// }
