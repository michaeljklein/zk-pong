// Endgame circuit
//
// Kernel for certifying a game log once it's ended

use dep::std;


global MAX_PINGS = 256;
// global PUBLIC_INPUTS = 1792; // 7 * 256
global PUBLIC_INPUTS = 850; // 7 * 256



// step kernel: (state_N, state_N', move_N', sig_N')
// - state_N' = step(move_N', state_N)
// - verify(p(N % 2), state_N', sig_N')
//
// if i == 0:
//   // initialize
//   old_state = initial_state
//   new_state = game_log[i].0
//   move      = game_log[i].1
//   sig       = game_log[i].2
// else:
//   // step
//   old_state = game_log[i].0
//   new_state = game_log[i+1].0
//   move      = game_log[i+1].1
//   sig       = game_log[i+1].2
//
// step_kernel(old_state, new_state, move, sig)
//
// // finalize
// if index + 1 == MAX_PINGS:
//   finalize_kernel
// end
fn step_kernel<S, T>(
    old_state: S,
    new_state: S,
    move: T,
    index: Field,
    sig: (),
    summary: pub Field,
    user_1: Field,
    user_2: Field,
) {

    // bootstrap with old_state = new_state = initial_state
    if (index == 0) {
        old_state.assert_initial_state();
        new_state.assert_initial_state();

    }

    if (index + 1 == MAX_PINGS) {
        new_state.assert_final_state();
    }

    // do this in state.assert_step()
    // assert(old_state.is_first_user != new_state.is_first_user);
    old_state.assert_step(move, new_state);

    let current_user = if new_state.is_first_user {
        user_1
    } else {
        user_2
    };
    verify(current_user, new_state, sig)
}






fn main(
    verification_key : [Field; 114],
    key_hash : Field,
    index : Field,
    proof_a : [[Field; 97]; PUBLIC_INPUTS],
    public_inputs : [[Field; 3]; PUBLIC_INPUTS],
    input_aggregation_object : [Field; 16],
) -> pub [Field; 16] {
    let output_aggregation_object_a = std::verify_proof(
        verification_key.as_slice(),
        proof_a[index].as_slice(),
        public_inputs[index].as_slice(),
        key_hash,
        input_aggregation_object
    );

    output_aggregation_object_a

    // let output_aggregation_object = std::verify_proof(
    //     verification_key.as_slice(),
    //     proof_b.as_slice(),
    //     public_inputs.as_slice(),
    //     key_hash,
    //     output_aggregation_object_a
    // );
    //
    // let mut output = [0; 16];
    // for i in 0..16 {
    //     output[i] = output_aggregation_object[i];
    // }
    // output
}






