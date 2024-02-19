import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { Fr } from '@aztec/bb.js';
import { Noir } from '@noir-lang/noir_js';
import endgame_circuit from './endgame_circuit/target/endgame_circuit.json';

// import rec_test_circuit from './rec_test_circuit/target/rec_test_circuit.json';
// import input_json from './rec_test_circuit/Prover.json';


// https://stackoverflow.com/a/30832210
// Function to download data to a file
function download_as_file(data, filename, type) {
    var file = new Blob([data], {type: type});
    if (window.navigator.msSaveOrOpenBlob) // IE10+
        window.navigator.msSaveOrOpenBlob(file, filename);
    else { // Others
        var a = document.createElement("a"),
                url = URL.createObjectURL(file);
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        setTimeout(function() {
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);  
        }, 0); 
    }
}

// check for collision between two objects using axis-aligned bounding box (AABB)
// @see https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
function collides(obj1, obj2) {
  return obj1.x < obj2.x + obj2.width &&
         obj1.x + obj1.width > obj2.x &&
         obj1.y < obj2.y + obj2.height &&
         obj1.y + obj1.height > obj2.y;
}


document.addEventListener('DOMContentLoaded', async () => {

  ////////////////////////////////////////////////////////////////////////
  // BEGIN PONG GAME LOGIC
  ////////////////////////////////////////////////////////////////////////

  const canvas = document.getElementById('game');
  const context = canvas.getContext('2d');

  // const max_game_ticks = 128;
  const max_game_ticks = 10;

  const canvas_width = canvas.width;
  const canvas_height = canvas.height;
  const grid_size = 15;
  const paddleHeight = 80; // grid_size * 5;
  const maxPaddleY = 495; // canvas_height - grid_size - paddleHeight;
  const paddleSpeed = 6;
  const ballSpeed = 5;
  const canvas_width_half = 375; // == 750 // 2
  const canvas_height_half = 292; // == 585 // 2
  const paddleHeight_half = 40;
  const paddle_y0 = 252; // canvas_height_half - paddleHeight_half;

  const leftPaddle = {
    // start in the middle of the game on the left side
    x: grid_size * 2,
    y: paddle_y0,
    width: grid_size,
    height: paddleHeight,

    // paddle velocity: 0 | paddleSpeed
    dy: 0
  };
  const rightPaddle = {
    // start in the middle of the game on the right side
    x: canvas_width - grid_size * 3,
    y: paddle_y0,
    width: grid_size,
    height: paddleHeight,

    // paddle velocity: 0 | paddleSpeed
    dy: 0
  };
  const ball = {
    // start in the middle of the game
    x: canvas_width_half,
    y: canvas_height_half,
    width: grid_size,
    height: grid_size,

    // ball velocity (start going to the top-right corner)
    // just dy here so all three objects have the same shape
    dy: -ballSpeed,
  };

  var leftPaddle_score = 0;
  var rightPaddle_score = 0;
  var game_tick = 0;
  var ball_dx = ballSpeed;
  var is_first_player = true;
  var game_log = [];

  // game loop
  async function loop() {
    // check if game over
    if (max_game_ticks <= game_tick) {
      // if (leftPaddle_score > rightPaddle_score) {
      //   alert(`Game over: left player won with ${leftPaddle_score} points!`)
      // } else if (rightPaddle_score > leftPaddle_score) {
      //   alert(`Game over: right player won with ${rightPaddle_score} points!`)
      // } else {
      //   // TODO tie breaker?
      //   alert(`Game tied!`)
      // }

      let game_log_item = {
        game_tick: game_tick,
        ball_x: ball.x,
        ball_y: ball.y,
        ball_dx: ball_dx,
        ball_dy: ball.dy,
        leftPaddle_x: leftPaddle.x,
        leftPaddle_y: leftPaddle.y,
        leftPaddle_dy: leftPaddle.dy,
        leftPaddle_score: leftPaddle_score,
        rightPaddle_x: rightPaddle.x,
        rightPaddle_y: rightPaddle.y,
        rightPaddle_dy: rightPaddle.dy,
        rightPaddle_score: rightPaddle_score,
        leftPaddle_won: (leftPaddle_score > rightPaddle_score),
        rightPaddle_won: (leftPaddle_score < rightPaddle_score),
        is_first_player: is_first_player,
      };
      // DEBUG game log
      console.log(game_log_item);
      game_log.push(game_log_item);


      ////////////////////////////////////////////////////////////////////////////////////
      // ZK PROOF
      ////////////////////////////////////////////////////////////////////////////////////

      console.log('beginning to generate proof..')

      const backend = new BarretenbergBackend(endgame_circuit);
      const noir = new Noir(endgame_circuit, backend);

      const pk = Fr.fromBuffer(
        new Uint8Array([
          0x0b, 0x9b, 0x3a, 0xde, 0xe6, 0xb3, 0xd8, 0x1b, 0x28, 0xa0, 0x88, 0x6b, 0x2a, 0x84, 0x15, 0xc7, 0xda, 0x31,
          0x29, 0x1a, 0x5e, 0x96, 0xbb, 0x7a, 0x56, 0x63, 0x9e, 0x17, 0x7d, 0x30, 0x1b, 0xeb,
        ]),
      );
      const pubKey = await backend.schnorrComputePublicKey(pk);

      var game_moves_json = [];
      var signatures_json = [];
      var game_log_json = game_log.map((x) => {

        // const current_hash = backend.pedersenCommit([
        //   new Fr(state.ball_x),             
        //   new Fr(state.ball_y),             
        //   new Fr(state.ball_dx),            
        //   new Fr(state.ball_dy),            
        //   new Fr(state.game_tick),          
        //   new Fr(state.is_first_player),    
        //   new Fr(state.leftPaddle_x),       
        //   new Fr(state.leftPaddle_y),       
        //   new Fr(state.leftPaddle_score),   
        //   new Fr(state.leftPaddle_won),     
        //   new Fr(state.rightPaddle_x),      
        //   new Fr(state.rightPaddle_y),      
        //   new Fr(state.rightPaddle_score),  
        //   new Fr(state.rightPaddle_won),    
        //   new Fr(move.leftPaddle_dy),       
        //   new Fr(move.rightPaddle_dy),
        // ]);
        //
        // const [s, e] = await backend.schnorrConstructSignature(msg, pk);
        // console.log('sig', [s, e]);
        //
        // const verified = await backend.schnorrVerifySignature(msg, pubKey, s, e);
        // console.log('sig verified', verified);
        //
        // throw 'hi!'
        //
        // game_moves_json.push({
        //   leftPaddle_dy: x.leftPaddle_dy,
        //   rightPaddle_dy: x.rightPaddle_dy,
        // });
        // delete x[leftPaddle_dy];
        // delete x[rightPaddle_dy];
        return x
      });

      const user_1_json = pubKey;
      const user_2_json = user_1_json;

      const input = {
        index: 0,
        game_log: game_log_json,
        game_moves: game_moves_json,
        signatures: signatures_json,
        user_1: user_1_json,
        user_2: user_2_json,
      };

      // const input = { x: 1, y: 2 };
      // (toml2json --pretty Prover.toml > Prover.json)
      // const input = { x: 1, y: 2 };
      console.log('input', input);

      display('logs', 'Generating proof... ⌛');
      const proof = await noir.generateFinalProof(input);
      display('logs', 'Generating proof... ✅');
      display('results', proof.proof);
      display('logs', 'Verifying proof... ⌛');
      const verification = await noir.verifyFinalProof(proof);
      if (verification) display('logs', 'Verifying proof... ✅');

      ////////////////////////////////////////////////////////////////////////////////////
      // END ZK PROOF
      ////////////////////////////////////////////////////////////////////////////////////

      // TODO: enable to download file
      // download_as_file(JSON.stringify(game_log), 'ping_game_log.json', 'text/plain');
      return
    }

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
    if (ball.x < 0 || ball.x > canvas_width) {

      if (ball.x < 0) {
        rightPaddle_score += 1;
      } else {
        leftPaddle_score += 1;
      }

      ball.x = canvas_width_half;
      ball.y = canvas_height_half;

      // swap directions and reset speed
      ball_dx = ballSpeed * Math.sign(ball_dx) * -1;
      ball.dy = -ballSpeed * Math.sign(ball.dy) * -1;
    }

    // check to see if ball collides with paddle. if they do change x velocity
    if (collides(ball, leftPaddle)) {
      ball_dx *= -1;
      ball_dx += Math.sign(ball_dx);
      ball.dy += Math.sign(ball.dy);

      // move ball next to the paddle otherwise the collision will happen again
      // in the next frame
      ball.x = leftPaddle.x + leftPaddle.width;
    }
    else if (collides(ball, rightPaddle)) {
      ball_dx *= -1;
      ball_dx += Math.sign(ball_dx);
      ball.dy += Math.sign(ball.dy);

      // move ball next to the paddle otherwise the collision will happen again
      // in the next frame
      ball.x = rightPaddle.x - ball.width;
    }

    game_tick += 1;
    is_first_player = !is_first_player;

    let game_log_item = {
      game_tick: game_tick,
      ball_x: ball.x,
      ball_y: ball.y,
      ball_dx: ball_dx,
      ball_dy: ball.dy,
      leftPaddle_x: leftPaddle.x,
      leftPaddle_y: leftPaddle.y,
      leftPaddle_dy: leftPaddle.dy,
      leftPaddle_score: leftPaddle_score,
      rightPaddle_x: rightPaddle.x,
      rightPaddle_y: rightPaddle.y,
      rightPaddle_dy: rightPaddle.dy,
      rightPaddle_score: rightPaddle_score,
      leftPaddle_won: false,
      rightPaddle_won: false,
      is_first_player: is_first_player,
    };
    // DEBUG game log
    // console.log(game_log_item);
    game_log.push(game_log_item);

    ////////////////////////////////////
    // ANIMATION
    ////////////////////////////////////

    // get next frame and clear canvas
    requestAnimationFrame(loop);
    context.clearRect(0, 0, canvas_width,canvas_height);

    // draw paddles
    context.fillStyle = 'white';
    context.fillRect(leftPaddle.x, leftPaddle.y, leftPaddle.width, leftPaddle.height);
    context.fillRect(rightPaddle.x, rightPaddle.y, rightPaddle.width, rightPaddle.height);

    // draw ball
    context.fillRect(ball.x, ball.y, ball.width, ball.height);

    // draw walls
    context.fillStyle = 'lightgrey';
    context.fillRect(0, 0, canvas_width, grid_size);
    context.fillRect(0, canvas_height - grid_size, canvas_width, canvas_height);

    // draw dotted line down the middle
    for (let i = grid_size; i < canvas_height - grid_size; i += grid_size * 2) {
      context.fillRect(canvas_width / 2 - grid_size / 2, i, grid_size, grid_size);
    }

    let score_height = canvas_height - 32;
    context.fillText(`Score: ${leftPaddle_score}`, 32, score_height);
    context.fillText(`Score: ${rightPaddle_score}`, canvas_width - 64, score_height);
  }

  // listen to keyboard events to move the paddles
  document.addEventListener('keydown', function(e) {
    // up arrow key
    if (e.which === 38) {
      rightPaddle.dy = -paddleSpeed;
    }
    // down arrow key
    else if (e.which === 40) {
      rightPaddle.dy = paddleSpeed;
    }

    // w key
    if (e.which === 87) {
      leftPaddle.dy = -paddleSpeed;
    }
    // a key
    else if (e.which === 83) {
      leftPaddle.dy = paddleSpeed;
    }
  });

  // listen to keyboard events to stop the paddle if key is released
  document.addEventListener('keyup', function(e) {
    if (e.which === 38 || e.which === 40) {
      rightPaddle.dy = 0;
    }

    if (e.which === 83 || e.which === 87) {
      leftPaddle.dy = 0;
    }
  });

  // start the game
  requestAnimationFrame(loop);

});


function display(container, msg) {
  const c = document.getElementById(container);
  const p = document.createElement('p');
  p.textContent = msg;
  c.appendChild(p);
  console.log(container, msg);
}

