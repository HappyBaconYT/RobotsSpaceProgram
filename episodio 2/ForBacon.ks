// ForBacon script episode 2

// point up
lock steering to heading(90,90).

// launch
stage.

// detect staging
wait until (stage:solidfuel < 0.1).
lock throttle to 0.
stage.
wait 1.
lock throttle to 1.
wait 1.

// pitch
lock steering to heading(90,80).
wait 10.
lock steering to heading(90,70).

wait until (alt:radar < 1).
