// Endgame circuit
//
// Kernel for certifying a game log once it's ended

use dep::std;
use dep::pong::{GameMove, GameState, init_pong, step_pong, final_step_pong, hash_game_state};


// global MAX_PINGS = 256;
global MAX_PINGS = 10;

struct Sig {
  bytes: [u8; 64],
}


struct Pubkey {
  x: Field,
  y: Field,
}

impl Pubkey {
  fn verify(self, sig: Sig, x: Field) {
    let message_slice = x.to_le_radix(256, 32);
    let mut message: [u8; 32] = [0; 32];
    for i in 0..32 {
        message[i] = message_slice[i];
    }
    // assert(std::ecdsa_secp256k1::verify_signature(self.x, self.y, sig.bytes, message));
    assert(std::schnorr::verify_signature(self.x, self.y, sig.bytes, message));
  }
}


trait StepState<T> {
  fn assert_initial_state(self);
  fn assert_step(self, move: T, new_state: Self);
  fn assert_final_state(self);
  fn is_first_user(self) -> bool;
  fn hash_to_field(self, move: T) -> Field;
}

impl StepState<GameMove> for GameState {
  fn assert_initial_state(self) {
    init_pong(self)
  }

  fn assert_step(self, move: GameMove, new_state: Self) {
    step_pong(self, move, new_state)
  }

  fn assert_final_state(self) {
    final_step_pong(self)
  }

  fn is_first_user(self) -> bool {
    self.is_first_player
  }

  fn hash_to_field(self, move: GameMove) -> Field {
    hash_game_state(self, move)
  }
}


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
  sig: Sig,
  user_1: Pubkey,
  user_2: Pubkey,
)
where
  S: StepState<T>
{
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

    let current_user = if new_state.is_first_user() {
        user_1
    } else {
        user_2
    };
    current_user.verify(sig, new_state.hash_to_field(move));
}

fn main(
  index: Field,
  game_log: [GameState; MAX_PINGS],
  game_moves: [GameMove; MAX_PINGS],
  signatures: [Sig; MAX_PINGS],
  user_1: Pubkey,
  user_2: Pubkey,
) {
  if (index == 0) {
    assert(game_moves[0].leftPaddle_dy == game_moves[1].leftPaddle_dy);
    assert(game_moves[0].rightPaddle_dy == game_moves[1].rightPaddle_dy);
    assert(signatures[0].bytes == signatures[1].bytes);
  }
  step_kernel(
    game_log[index], 
    game_log[index+1], 
    game_moves[index+1], 
    index,
    signatures[index+1], 
    user_1,
    user_2
  )
}

