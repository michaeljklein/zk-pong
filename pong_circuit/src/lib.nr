// Pong circuit
//
// Kernel for ensuring Pong game rules are valid for a particular state transition

use dep::std;

struct GameState {
  ball_x: i64,
  ball_y: i64,
  ball_dx: i64,
  ball_dy: i64,
  game_tick: i64,
  is_first_player: bool,
  leftPaddle_x: i64,
  leftPaddle_y: i64,
  leftPaddle_score: i64,
  leftPaddle_won: bool,
  rightPaddle_x: i64,
  rightPaddle_y: i64,
  rightPaddle_score: i64,
  rightPaddle_won: bool,
}

struct GameMove {
  leftPaddle_dy: i64,
  rightPaddle_dy: i64,
}

impl GameMove {
  pub fn is_empty(self) {
    assert(self.leftPaddle_dy == 0);
    assert(self.rightPaddle_dy == 0);
  }
}

pub fn hash_game_state(state: GameState, move: GameMove) -> Field {
  std::hash::pedersen_hash([
    state.ball_x as Field,
    state.ball_y as Field,
    state.ball_dx as Field,
    state.ball_dy as Field,
    state.game_tick as Field,
    state.is_first_player as Field,
    state.leftPaddle_x as Field,
    state.leftPaddle_y as Field,
    state.leftPaddle_score as Field,
    state.leftPaddle_won as Field,
    state.rightPaddle_x as Field,
    state.rightPaddle_y as Field,
    state.rightPaddle_score as Field,
    state.rightPaddle_won as Field,
    move.leftPaddle_dy as Field,
    move.rightPaddle_dy as Field,
  ])
}


//////////////////////////////////////////
// utils
//////////////////////////////////////////

fn signum(x: i64) -> i64 {
  if (x < 0) {
    -1
  } else if (x == 0) {
    0
  } else {
    1
  }
}

//////////////////////////////////////////
// end utils
//////////////////////////////////////////

global canvas_width: i64 = 750;
global canvas_height: i64 = 585;

global grid_size: i64 = 15;
global paddleHeight: i64 = 80; // grid_size * 5;
global maxPaddleY: i64 = 495; // canvas_height - grid_size - paddleHeight;
global max_game_ticks: i64 = 128;
global paddleSpeed: i64 = 6;
global ballSpeed: i64 = 5;

global canvas_width_half: i64 = 375; // == 750 // 2
global canvas_height_half: i64 = 292; // == 585 // 2
global paddleHeight_half: i64 = 40;
global paddle_y0: i64 = 252; // canvas_height_half - paddleHeight_half;


struct GameObject {
  x: i64,
  y: i64,
  width: i64,
  height: i64,
  dy: i64,
}


// // check for collision between two objects using axis-aligned bounding box (AABB)
// // @see https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
// function collides(obj1, obj2) {
//   return obj1.x < obj2.x + obj2.width &&
//          obj1.x + obj1.width > obj2.x &&
//          obj1.y < obj2.y + obj2.height &&
//          obj1.y + obj1.height > obj2.y;
// }
fn collides(obj1: GameObject, obj2: GameObject) -> bool {
  obj1.x < obj2.x + obj2.width &
  obj1.x + obj1.width > obj2.x &
  obj1.y < obj2.y + obj2.height &
  obj1.y + obj1.height > obj2.y
}


// assert initial state valid
pub fn init_pong(state: GameState) {
  let leftPaddle = GameObject {
      x: grid_size * 2,
      y: paddle_y0,
      width: grid_size,
      height: paddleHeight,
      dy: 0,
  };

  let rightPaddle = GameObject {
      x: canvas_width - grid_size * 3,
      y: paddle_y0,
      width: grid_size,
      height: paddleHeight,
      dy: 0,
  };

  let ball = GameObject {
    x: canvas_width_half,
    y: canvas_height_half,
    width: grid_size,
    height: grid_size,
    dy: -ballSpeed,
  };

  let leftPaddle_won: bool = false;
  let leftPaddle_score: i64 = 0;
  let rightPaddle_score: i64 = 0;
  let rightPaddle_won: bool = false;
  let game_tick: i64 = 0;
  let ball_dx: i64 = ballSpeed;

  assert(ball.x            == state.ball_x,            "unexpected initial tick: ball.x           ");
  assert(ball.y            == state.ball_y,            "unexpected initial tick: ball.y           ");
  assert(ball_dx           == state.ball_dx,           "unexpected initial tick: ball_dx          ");
  assert(ball.dy           == state.ball_dy,           "unexpected initial tick: ball.dy          ");
  assert(game_tick         == state.game_tick,         "unexpected initial tick: game_tick        ");
  assert(leftPaddle.x      == state.leftPaddle_x,      "unexpected initial tick: leftPaddle_x     ");
  assert(leftPaddle.y      == state.leftPaddle_y,      "unexpected initial tick: leftPaddle_y     ");
  assert(leftPaddle_score  == state.leftPaddle_score,  "unexpected initial tick: leftPaddle_score ");
  assert(leftPaddle_won    == state.leftPaddle_won,    "unexpected initial tick: leftPaddle_won   ");
  assert(rightPaddle.x     == state.rightPaddle_x,     "unexpected initial tick: rightPaddle_x    ");
  assert(rightPaddle.y     == state.rightPaddle_y,     "unexpected initial tick: rightPaddle_y    ");
  assert(rightPaddle_score == state.rightPaddle_score, "unexpected initial tick: rightPaddle_score");
  assert(rightPaddle_won   == state.rightPaddle_won,   "unexpected initial tick: rightPaddle_won  ");
  assert(                     state.is_first_player,   "unexpected initial tick: is_first_player  ");
  // assert(leftPaddle.dy     == state.leftPaddle_dy,     "unexpected initial tick: leftPaddle_dy    ");
  // assert(rightPaddle.dy    == state.rightPaddle_dy,    "unexpected initial tick: rightPaddle_dy   ");
}


// validate state change on following i/o
//
// ball_x: i64
// ball_y: i64
// ball_dx: i64
// ball_dy: i64
// ball_tick: i64
// leftPaddle_x: i64
// leftPaddle_y: i64
// leftPaddle_dy: i64
// leftPaddle_score: i64
// rightPaddle_x: i64
// rightPaddle_y: i64
// rightPaddle_dy: i64
// rightPaddle_score: i64
pub fn step_pong(in_state: GameState, move: GameMove, out_state: GameState) {
  let mut leftPaddle = GameObject {
      x: in_state.leftPaddle_x,
      y: in_state.leftPaddle_y,
      width: grid_size,
      height: paddleHeight,
      dy: move.leftPaddle_dy,
  };

  let mut rightPaddle = GameObject {
      x: in_state.rightPaddle_x,
      y: in_state.rightPaddle_y,
      width: grid_size,
      height: paddleHeight,
      dy: move.rightPaddle_dy,
  };

  let mut ball = GameObject {
    x: in_state.ball_x,
    y: in_state.ball_y,
    width: grid_size,
    height: grid_size,
    dy: in_state.ball_dy,
  };

  let mut leftPaddle_score = in_state.leftPaddle_score;
  let mut rightPaddle_score = in_state.rightPaddle_score;
  let mut game_tick = in_state.game_tick;
  let mut ball_dx = in_state.ball_dx;

  // game active
  assert(game_tick < max_game_ticks, "game tick past end of game");

  // paddle velocity valid
  assert((leftPaddle.dy == 0) | (leftPaddle.dy == -paddleSpeed) | (leftPaddle.dy == paddleSpeed));
  assert((rightPaddle.dy == 0) | (rightPaddle.dy == -paddleSpeed) | (rightPaddle.dy == paddleSpeed));

  // move paddles by their velocity
  leftPaddle.y += leftPaddle.dy;
  rightPaddle.y += rightPaddle.dy;

  // prevent paddles from going through walls
  if (leftPaddle.y < grid_size) {
    leftPaddle.y = grid_size;
  }
  else if (leftPaddle.y > maxPaddleY) {
    leftPaddle.y = maxPaddleY;
  }
  
  if (rightPaddle.y < grid_size) {
    rightPaddle.y = grid_size;
  }
  else if (rightPaddle.y > maxPaddleY) {
    rightPaddle.y = maxPaddleY;
  }

  // move ball by its velocity
  ball.x += ball_dx;
  ball.y += ball.dy;

  // prevent ball from going through walls by changing its velocity
  if (ball.y < grid_size) {
    ball.y = grid_size;
    ball.dy *= -1;
  }
  else if (ball.y + grid_size > canvas_height - grid_size) {
    ball.y = canvas_height - grid_size * 2;
    ball.dy *= -1;
  }

  // points scored: reset ball if it goes past paddle
  if (ball.x < 0 | ball.x > canvas_width) {
  
    if (ball.x < 0) {
      rightPaddle_score += 1;
    } else {
      leftPaddle_score += 1;
    }
  
    ball.x = canvas_width_half;
    ball.y = canvas_height_half;
  
    // swap directions and reset speed
    ball_dx = ballSpeed * signum(ball_dx) * -1;
    ball.dy = -ballSpeed * signum(ball.dy) * -1;
  }

  // check to see if ball collides with paddle. if they do change x velocity
  if (collides(ball, leftPaddle)) {
    ball_dx *= -1;
    ball_dx += signum(ball_dx);
    ball.dy += signum(ball.dy);
  
    // move ball next to the paddle otherwise the collision will happen again
    // in the next frame
    ball.x = leftPaddle.x + leftPaddle.width;
  }
  else if (collides(ball, rightPaddle)) {
    ball_dx *= -1;
    ball_dx += signum(ball_dx);
    ball.dy += signum(ball.dy);
  
    // move ball next to the paddle otherwise the collision will happen again
    // in the next frame
    ball.x = rightPaddle.x - ball.width;
  }

  game_tick += 1;
  let is_first_player = !in_state.is_first_player;

  assert(ball.x            == out_state.ball_x,            "unexpected end of tick: ball.x           ");
  assert(ball.y            == out_state.ball_y,            "unexpected end of tick: ball.y           ");
  assert(ball_dx           == out_state.ball_dx,           "unexpected end of tick: ball_dx          ");
  assert(ball.dy           == out_state.ball_dy,           "unexpected end of tick: ball.dy          ");
  assert(game_tick         == out_state.game_tick,         "unexpected end of tick: game_tick        ");
  assert(is_first_player   == out_state.is_first_player,   "unexpected end of tick: is_first_player  ");
  assert(leftPaddle.x      == out_state.leftPaddle_x,      "unexpected end of tick: leftPaddle_x     ");
  assert(leftPaddle.y      == out_state.leftPaddle_y,      "unexpected end of tick: leftPaddle_y     ");
  assert(leftPaddle_score  == out_state.leftPaddle_score,  "unexpected end of tick: leftPaddle_score ");
  assert(rightPaddle.x     == out_state.rightPaddle_x,     "unexpected end of tick: rightPaddle_x    ");
  assert(rightPaddle.y     == out_state.rightPaddle_y,     "unexpected end of tick: rightPaddle_y    ");
  assert(rightPaddle_score == out_state.rightPaddle_score, "unexpected end of tick: rightPaddle_score");
  // assert(leftPaddle.dy     == out_state.leftPaddle_dy,     "unexpected end of tick: leftPaddle_dy    ");
  // assert(rightPaddle.dy    == out_state.rightPaddle_dy,    "unexpected end of tick: rightPaddle_dy   ");
}



// end of game assertions
pub fn final_step_pong(state: GameState) {
  if (max_game_ticks == state.game_tick) {
    if (state.leftPaddle_score > state.rightPaddle_score) {
      assert(state.leftPaddle_won);
      assert(!state.rightPaddle_won);
    } else if (state.rightPaddle_score > state.leftPaddle_score) {
      assert(!state.leftPaddle_won);
      assert(state.rightPaddle_won);
    } else {
      assert(!state.leftPaddle_won);
      assert(!state.rightPaddle_won);
    }
  }
}


// fn main(x: Field, y: pub Field) {
//
//   let leftPaddle = GameObject {
//       x: grid_size * 2,
//       y: paddle_y0,
//       width: grid_size,
//       height: paddleHeight,
//       dy: 0,
//   };
//
//   let rightPaddle = GameObject {
//       x: canvas_width - grid_size * 3,
//       y: paddle_y0,
//       width: grid_size,
//       height: paddleHeight,
//       dy: 0,
//   };
//
//   let ball = GameObject {
//     x: canvas_width_half,
//     y: canvas_height_half,
//     width: grid_size,
//     height: grid_size,
//     dy: -ballSpeed,
//   };
//
//   let leftPaddle_score: i64 = 0;
//   let rightPaddle_score: i64 = 0;
//   let game_tick: i64 = 0;
//   let ball_dx: i64 = ballSpeed;
//
//
//   init_pong(
//     ball.x,
//     ball.y,
//     ball_dx,
//     ball.dy,
//     game_tick,
//     leftPaddle.x,
//     leftPaddle.y,
//     leftPaddle.dy,
//     leftPaddle_score,
//     rightPaddle.x,
//     rightPaddle.y,
//     rightPaddle.dy,
//     rightPaddle_score,
//   );
//
//   step_pong(
//     ball.x,
//     ball.y,
//     ball_dx,
//     ball.dy,
//     game_tick,
//     leftPaddle.x,
//     leftPaddle.y,
//     leftPaddle.dy,
//     leftPaddle_score,
//     rightPaddle.x,
//     rightPaddle.y,
//     rightPaddle.dy,
//     rightPaddle_score,
//
//     ball.x + ball_dx,
//     ball.y + ball.dy,
//     ball_dx,
//     ball.dy,
//     game_tick + 1,
//     leftPaddle.x,
//     leftPaddle.y,
//     leftPaddle.dy,
//     leftPaddle_score,
//     rightPaddle.x,
//     rightPaddle.y,
//     rightPaddle.dy,
//     rightPaddle_score,
//   );
//
//   final_step(
//     max_game_ticks,
//     leftPaddle_score,
//     false, // out_leftPaddle_won
//     rightPaddle_score,
//     false, // out_rightPaddle_won
//   );
//
//   assert(x != y);
// }
//
// #[test]
// fn test_main() {
//     main(1, 2);
//
//     // Uncomment to make test fail
//     // main(1, 1);
// }

