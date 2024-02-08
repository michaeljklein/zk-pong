// Pong circuit
//
// Kernel for ensuring Pong game rules are valid for a particular state transition

global canvas_width: u64 = 750;
global canvas_height: u64 = 585;

global grid_size: u64 = 15;
global paddleHeight: u64 = 80; // grid_size * 5;
global maxPaddleY: u64 = 495; // canvas_height - grid_size - paddleHeight;
global max_game_ticks: u64 = 128;
global paddleSpeed: u64 = 6;
global ballSpeed: i64 = 5;

global canvas_width_half: u64 = 375; // == 750 // 2
global canvas_height_half: u64 = 292; // == 585 // 2
global paddleHeight_half: u64 = 40;
global paddle_y0: u64 = 252; // canvas_height_half - paddleHeight_half;


struct GameObject {
  x: u64,
  y: u64,
  width: u64,
  height: u64,
  dy: i64,
}


// GOAL: validate state change on following i/o
//
// ball_x: u64
// ball_y: u64
// ball_dx: i64
// ball_dy: i64
// ball_tick: u64
// leftPaddle_x: u64
// leftPaddle_y: u64
// leftPaddle_dy: i64
// leftPaddle_score: u64
// rightPaddle_x: u64
// rightPaddle_y: u64
// rightPaddle_dy: i64
// rightPaddle_score: u64


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
fn init_pong(
  out_ball_x: u64,
  out_ball_y: u64,
  out_ball_dx: i64,
  out_ball_dy: i64,
  out_game_tick: u64,
  out_leftPaddle_x: u64,
  out_leftPaddle_y: u64,
  out_leftPaddle_dy: i64,
  out_leftPaddle_score: u64,
  out_rightPaddle_x: u64,
  out_rightPaddle_y: u64,
  out_rightPaddle_dy: i64,
  out_rightPaddle_score: u64
) {
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

  let leftPaddle_score: u64 = 0;
  let rightPaddle_score: u64 = 0;
  let game_tick: u64 = 0;
  let ball_dx: i64 = ballSpeed;

  assert(ball.x            == out_ball_x,            "unexpected initial tick: ball.x           ");
  assert(ball.y            == out_ball_y,            "unexpected initial tick: ball.y           ");
  assert(ball_dx           == out_ball_dx,           "unexpected initial tick: ball_dx          ");
  assert(ball.dy           == out_ball_dy,           "unexpected initial tick: ball.dy          ");
  assert(game_tick         == out_game_tick,         "unexpected initial tick: game_tick        ");
  assert(leftPaddle.x      == out_leftPaddle_x,      "unexpected initial tick: leftPaddle_x     ");
  assert(leftPaddle.y      == out_leftPaddle_y,      "unexpected initial tick: leftPaddle_y     ");
  assert(leftPaddle.dy     == out_leftPaddle_dy,     "unexpected initial tick: leftPaddle_dy    ");
  assert(leftPaddle_score  == out_leftPaddle_score,  "unexpected initial tick: leftPaddle_score ");
  assert(rightPaddle.x     == out_rightPaddle_x,     "unexpected initial tick: rightPaddle_x    ");
  assert(rightPaddle.y     == out_rightPaddle_y,     "unexpected initial tick: rightPaddle_y    ");
  assert(rightPaddle.dy    == out_rightPaddle_dy,    "unexpected initial tick: rightPaddle_dy   ");
  assert(rightPaddle_score == out_rightPaddle_score, "unexpected initial tick: rightPaddle_score");
}



fn step_pong(
  in_ball_x: u64,
  in_ball_y: u64,
  in_ball_dx: i64,
  in_ball_dy: i64,
  in_game_tick: u64,
  in_leftPaddle_x: u64,
  in_leftPaddle_y: u64,
  in_leftPaddle_dy: i64,
  in_leftPaddle_score: u64,
  in_rightPaddle_x: u64,
  in_rightPaddle_y: u64,
  in_rightPaddle_dy: i64,
  in_rightPaddle_score: u64,

  out_ball_x: u64,
  out_ball_y: u64,
  out_ball_dx: i64,
  out_ball_dy: i64,
  out_game_tick: u64,
  out_leftPaddle_x: u64,
  out_leftPaddle_y: u64,
  out_leftPaddle_dy: i64,
  out_leftPaddle_score: u64,
  out_rightPaddle_x: u64,
  out_rightPaddle_y: u64,
  out_rightPaddle_dy: i64,
  out_rightPaddle_score: u64
) {
  let mut leftPaddle = GameObject {
      x: in_leftPaddle_x,
      y: in_leftPaddle_y,
      width: grid_size,
      height: paddleHeight,
      dy: in_leftPaddle_dy,
  };

  let mut rightPaddle = GameObject {
      x: in_rightPaddle_x,
      y: in_rightPaddle_y,
      width: grid_size,
      height: paddleHeight,
      dy: in_rightPaddle_dy,
  };

  let mut ball = GameObject {
    x: in_ball_x,
    y: in_ball_y,
    width: grid_size,
    height: grid_size,
    dy: in_ball_dy,
  };

  let mut leftPaddle_score = in_leftPaddle_score;
  let mut rightPaddle_score = in_rightPaddle_score;
  let mut game_tick = in_game_tick;
  let mut ball_dx = in_ball_dx;

  assert(game_tick <= max_game_ticks, "game tick past end of game");

  // // move paddles by their velocity
  // leftPaddle.y += leftPaddle.dy;
  // rightPaddle.y += rightPaddle.dy;
  //
  // // prevent paddles from going through walls
  // if (leftPaddle.y < grid_size) {
  //   leftPaddle.y = grid_size;
  // }
  // else if (leftPaddle.y > maxPaddleY) {
  //   leftPaddle.y = maxPaddleY;
  // }
  //
  // if (rightPaddle.y < grid_size) {
  //   rightPaddle.y = grid_size;
  // }
  // else if (rightPaddle.y > maxPaddleY) {
  //   rightPaddle.y = maxPaddleY;
  // }
  //
  // // move ball by its velocity
  // ball.x += ball_dx;
  // ball.y += ball.dy;
  //
  // // prevent ball from going through walls by changing its velocity
  // if (ball.y < grid_size) {
  //   ball.y = grid_size;
  //   ball.dy *= -1;
  // }
  // else if (ball.y + grid_size > canvas_height - grid_size) {
  //   ball.y = canvas_height - grid_size * 2;
  //   ball.dy *= -1;
  // }
  //
  // // points scored: reset ball if it goes past paddle
  // if (ball.x < 0 || ball.x > canvas_width) {
  //
  //   if (ball.x < 0) {
  //     rightPaddle_score += 1;
  //   } else {
  //     leftPaddle_score += 1;
  //   }
  //
  //   ball.x = canvas_width_half;
  //   ball.y = canvas_height_half;
  //
  //   // swap directions and reset speed
  //   ball_dx = ballSpeed * Math.sign(ball_dx) * -1;
  //   ball.dy = -ballSpeed * Math.sign(ball.dy) * -1;
  // }
  //
  // // check to see if ball collides with paddle. if they do change x velocity
  // if (collides(ball, leftPaddle)) {
  //   ball_dx *= -1;
  //   ball_dx += Math.sign(ball_dx);
  //   ball.dy += Math.sign(ball.dy);
  //
  //   // move ball next to the paddle otherwise the collision will happen again
  //   // in the next frame
  //   ball.x = leftPaddle.x + leftPaddle.width;
  // }
  // else if (collides(ball, rightPaddle)) {
  //   ball_dx *= -1;
  //   ball_dx += Math.sign(ball_dx);
  //   ball.dy += Math.sign(ball.dy);
  //
  //   // move ball next to the paddle otherwise the collision will happen again
  //   // in the next frame
  //   ball.x = rightPaddle.x - ball.width;
  // }

    game_tick += 1;

    assert(ball.x            == out_ball_x,            "unexpected end of tick: ball.x           ");
    assert(ball.y            == out_ball_y,            "unexpected end of tick: ball.y           ");
    assert(ball_dx           == out_ball_dx,           "unexpected end of tick: ball_dx          ");
    assert(ball.dy           == out_ball_dy,           "unexpected end of tick: ball.dy          ");
    assert(game_tick         == out_game_tick,         "unexpected end of tick: game_tick        ");
    assert(leftPaddle.x      == out_leftPaddle_x,      "unexpected end of tick: leftPaddle_x     ");
    assert(leftPaddle.y      == out_leftPaddle_y,      "unexpected end of tick: leftPaddle_y     ");
    assert(leftPaddle.dy     == out_leftPaddle_dy,     "unexpected end of tick: leftPaddle_dy    ");
    assert(leftPaddle_score  == out_leftPaddle_score,  "unexpected end of tick: leftPaddle_score ");
    assert(rightPaddle.x     == out_rightPaddle_x,     "unexpected end of tick: rightPaddle_x    ");
    assert(rightPaddle.y     == out_rightPaddle_y,     "unexpected end of tick: rightPaddle_y    ");
    assert(rightPaddle.dy    == out_rightPaddle_dy,    "unexpected end of tick: rightPaddle_dy   ");
    assert(rightPaddle_score == out_rightPaddle_score, "unexpected end of tick: rightPaddle_score");
}



// end of game assertions
fn final_step() {
  // if (max_game_ticks == game_tick) {
  //   if (leftPaddle_score > rightPaddle_score) {
  //     alert(`Game over: left player won with ${leftPaddle_score} points!`)
  //   } else if (rightPaddle_score > leftPaddle_score) {
  //     alert(`Game over: right player won with ${rightPaddle_score} points!`)
  //   } else {
  //     // TODO tie breaker?
  //     alert(`Game tied!`)
  //   }
  // }

}


fn main(x: Field, y: pub Field) {

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

  let leftPaddle_score: u64 = 0;
  let rightPaddle_score: u64 = 0;
  let game_tick: u64 = 0;
  let ball_dx: i64 = ballSpeed;

  step_pong(
    ball.x,
    ball.y,
    ball_dx,
    ball.dy,
    game_tick,
    leftPaddle.x,
    leftPaddle.y,
    leftPaddle.dy,
    leftPaddle_score,
    rightPaddle.x,
    rightPaddle.y,
    rightPaddle.dy,
    rightPaddle_score,

    ball.x,
    ball.y,
    ball_dx,
    ball.dy,
    game_tick + 1,
    leftPaddle.x,
    leftPaddle.y,
    leftPaddle.dy,
    leftPaddle_score,
    rightPaddle.x,
    rightPaddle.y,
    rightPaddle.dy,
    rightPaddle_score,
  );

  assert(x != y);
}

#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}

