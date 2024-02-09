
# Endgame Circuit

Circuit to verify end of game:
- Who followed the rules
- Who won (player1, player2, tie)
- Who lagged out

## Design

High level:

```
ignore server: p0, p1
- state_0 := initial_state
- send(move, signature)
- receive(move, signature)

BOOTSTRAP
p0: (initial_state)
- state_0 = step(initial_state, move_0)
- sig_0 = sign(p0, state_0)
- send(move_0, sig_0)

p1: (initial_state)
- receive(move_0, sig_0)
- state_0 = step(initial_state, move_0)
- verify(p0, state_0, sig_0)
- state_1 = step(state_0, move_1)
- sig_1 = sign(p1, state_1)
- send(move_1, sig_1)

p0: (state_0)
- receive(move_1, sig_1)
- state_1 = step(state_0, move_1)
- verify(p1, state_1, sig_1)
- state_2 = step(state_1, move_2)
- sig_2 = sign(p0, state_2)
- send(move_2, sig_2)

p1: (state_1)
- receive(move_2, sig_2)
- state_2 = step(state_1, move_2)
- verify(p0, state_2, sig_2)
- state_3 = step(state_2, move_3)
- sig_3 = sign(p1, state_3)
- send(move_3, sig_3)

p0: (state_2)
- receive(move_3, sig_3)
- state_3 = step(state_1, move_3)
- verify(p1, state_3, sig_3)
- state_4 = step(state_3, move_4)
- sig_4 = sign(p0, state_4)
- send(move_4, sig_4)

N: (') = (+ 1)
  p(N' % 2) (state_N):
  - receive(move_N', sig_N')
  - state_N' = step(move_N', state_N)
  - verify(p(N % 2), state_N', sig_N')
  - state_N'' = step(state_N', move_N'')
  - sig_N'' = sign(p(N' % 2), state_N'')
  - send(move_N'', sig_N'')
```

Game log (minimal):

```
initial_state:
- (move_0, sig_0) // p0
- (move_1, sig_1) // p1
- (move_2, sig_2) // p0
- ..
- (move_N, sig_N) // p(N % 2)
```


Game log (step kernel's perspective):

```
initial_state:
- (state_0, move_0, sig_0) // p0
- (state_1, move_1, sig_1) // p1
- (state_2, move_2, sig_2) // p0
- ..
- (state_N, move_N, sig_N) // p(N % 2)

step kernel: (state_N, state_N', move_N', sig_N')
- state_N' = step(move_N', state_N)
- verify(p(N % 2), state_N', sig_N')

recursive kernel: (game_log: [(state, move, sig); NUM_TICKS], i: Index)
  for i <- [0..NUM_TICKS):
    if i == 0:
      // initialize
      old_state = initial_state
      new_state = game_log[i].0
      move      = game_log[i].1
      sig       = game_log[i].2
    else:
      // step
      old_state = game_log[i].0
      new_state = game_log[i+1].0
      move      = game_log[i+1].1
      sig       = game_log[i+1].2

    step_kernel(old_state, new_state, move, sig)

    // finalize
    if index + 1 == NUM_TICKS:
      finalize_kernel
    end
```

