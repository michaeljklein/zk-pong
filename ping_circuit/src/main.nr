use pong::step_pong;
use dep::std;

// Ping circuit
//
// Kernel for ensuring timliness in a distributed system (two actors)

// (previous_state(w/ update?), signature(..))
// (current_state(w/ update?), signature(..))

// Noir does not support enums so we must use a `Field` type 
// These are the values that `ping_type` can be:
// 0: empty ping
// 1: move in pong game
// 2: finish pong game
fn main(
    ping_type: pub Field, 
    // These inputs are only used by the 
    in_ball_x: i64,
    in_ball_y: i64,
    in_ball_dx: i64,
    in_ball_dy: i64,
    in_game_tick: i64,
    in_leftPaddle_x: i64,
    in_leftPaddle_y: i64,
    in_leftPaddle_dy: i64,
    in_leftPaddle_score: i64,
    in_rightPaddle_x: i64,
    in_rightPaddle_y: i64,
    in_rightPaddle_dy: i64,
    in_rightPaddle_score: i64,
    // TODO: we probably want a hash of all `in` and `out` state
    // This hash will be the public input we use rather than each of these values

    out_ball_x: i64,
    out_ball_y: i64,
    out_ball_dx: i64,
    out_ball_dy: i64,
    out_game_tick: i64,
    out_leftPaddle_x: i64,
    out_leftPaddle_y: i64,
    out_leftPaddle_dy: i64,
    out_leftPaddle_score: i64,
    out_rightPaddle_x: i64,
    out_rightPaddle_y: i64,
    out_rightPaddle_dy: i64,
    out_rightPaddle_score: i64,

    // TODO: also need a public finish game hash here
    out_leftPaddle_score: i64,
    out_leftPaddle_won: bool,
    out_rightPaddle_score: i64,
    out_rightPaddle_won: bool,

    message: [u8;38],
    hashed_message: [u8;32],
    pub_key_x: [u8;32],
    pub_key_y: [u8;32],
    signature: [u8;64]
) {
    // In the case we have ping_type == 0 we do not have to do anything
    // The cirucit is trivially valid
    if ping_type == 1 {
        step_pong(
            in_ball_x,
            in_ball_y,
            in_ball_dx,
            in_ball_dy,
            in_game_tick,
            in_leftPaddle_x,
            in_leftPaddle_y,
            in_leftPaddle_dy,
            in_leftPaddle_score,
            in_rightPaddle_x,
            in_rightPaddle_y,
            in_rightPaddle_dy,
            in_rightPaddle_score,
            out_ball_x,
            out_ball_y,
            out_ball_dx,
            out_ball_dy,
            out_game_tick,
            out_leftPaddle_x,
            out_leftPaddle_y,
            out_leftPaddle_dy,
            out_leftPaddle_score,
            out_rightPaddle_x,
            out_rightPaddle_y,
            out_rightPaddle_dy,
            out_rightPaddle_score
        )
    } else if ping_type == 2 {
        final_step(
            out_game_tick,
            out_leftPaddle_score,
            out_leftPaddle_won,
            out_rightPaddle_score,
            out_rightPaddle_won
        );
    }

    // Hash the message, since secp256k1 expects a hashed_message
    let expected = std::hash::sha256(message);
    assert(hashed_message == expected);

    // TODO: debate other signatures (also dependent on what is convenient to use with the bb.js library)
    // just doing ecdsa here cause maybe we can use it in the contract as well 
    let valid_signature = std::ecdsa_secp256k1::verify_signature(pub_key_x, pub_key_y, signature, hashed_message);
    assert(valid_signature);
}

#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}

