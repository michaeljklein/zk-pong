// Pong circuit
//
// Kernel for ensuring Pong game rules are valid for a particular state transition

global canvas_width: u64 = 750;
global canvas_height: u64 = 585;

global grid_size: u64 = 15;
global paddleHeight: u64 = 80; // grid_size * 5;
global maxPaddleY: u64 = 495; // canvas_height - grid_size - paddleHeight;
global game_ticks: u64 = 128;
global paddleSpeed: u64 = 6;
global ballSpeed: u64 = 5;

global canvas_width_half: u64 = 375; // == 750 // 2
global canvas_height_half: u64 = 292; // == 585 // 2
global paddleHeight_half: u64 = 40;

global paddle_y0: u64 = 252; // canvas_height_half - paddleHeight_half;


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


fn main(x: Field, y: pub Field) {
    assert(x != y);
}

#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}

