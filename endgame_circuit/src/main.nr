// Endgame circuit
//
// Kernel for certifying a game log once it's ended

use dep::std;

// fn main(
//     ping_type: pub Field, 
//     // These inputs are only used by the 
//     in_ball_x: i64,
//     in_ball_y: i64,
//     in_ball_dx: i64,
//     in_ball_dy: i64,
//     in_game_tick: i64,
//     in_leftPaddle_x: i64,
//     in_leftPaddle_y: i64,
//     in_leftPaddle_dy: i64,
//     in_leftPaddle_score: i64,
//     in_rightPaddle_x: i64,
//     in_rightPaddle_y: i64,
//     in_rightPaddle_dy: i64,
//     in_rightPaddle_score: i64,
//     // TODO: we probably want a hash of all `in` and `out` state
//     // This hash will be the public input we use rather than each of these values
//
//     out_ball_x: i64,
//     out_ball_y: i64,
//     out_ball_dx: i64,
//     out_ball_dy: i64,
//     out_game_tick: i64,
//     out_leftPaddle_x: i64,
//     out_leftPaddle_y: i64,
//     out_leftPaddle_dy: i64,
//     out_leftPaddle_score: i64,
//     out_rightPaddle_x: i64,
//     out_rightPaddle_y: i64,
//     out_rightPaddle_dy: i64,
//     out_rightPaddle_score: i64,
//
//     // TODO: also need a public finish game hash here
//     out_leftPaddle_score: i64,
//     out_leftPaddle_won: bool,
//     out_rightPaddle_score: i64,
//     out_rightPaddle_won: bool,
//
//     message: [u8;38],
//     hashed_message: [u8;32],
//     pub_key_x: [u8;32],
//     pub_key_y: [u8;32],
//     signature: [u8;64]
// ) {

// empty_ping: Field
// in_state_hash: Field
// out_state_hash: Field
// user_id: Field
// signature: [Field; 3] // eddsa posiedon
//
// [Field; 7]

global MAX_PINGS = 256;
global PUBLIC_INPUTS = 1792; // 7 * 256

fn main(
    verification_key : [Field; 114],
    proof_a : [Field; 94],
    proof_b : [Field; 94],
    public_inputs : [Field; PUBLIC_INPUTS],
    key_hash : Field,
    input_aggregation_object : [Field; 16],
) -> pub [Field; 16] {
    let output_aggregation_object_a = std::verify_proof(
        verification_key.as_slice(),
        proof_a.as_slice(),
        public_inputs.as_slice(),
        key_hash,
        input_aggregation_object
    );

    let output_aggregation_object = std::verify_proof(
        verification_key.as_slice(),
        proof_b.as_slice(),
        public_inputs.as_slice(),
        key_hash,
        output_aggregation_object_a
    );

    let mut output = [0; 16];
    for i in 0..16 {
        output[i] = output_aggregation_object[i];
    }
    output
}


