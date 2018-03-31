// episodio: 4 -- astronave: OrbitingBacon

// ATTENTI!! questo script e' stato migliorato nell'episodio 5!

// FUNCTIONS
function tilt
{
  parameter minAlt.
  parameter angle.

  wait until altitude > minAlt.
  lock steering to heading(0,angle).
}


// MAIN PROGRAM

lock throttle to 0.7.
lock steering to heading(0,90).

// launching
print "Launching".
stage.

// detect staging
wait until (stage:solidfuel < 0.1).
print "boosters separation".
stage.

// perform gravity turn
tilt(8000, 80).

tilt(12000, 60).

tilt(20000, 40).

tilt(30000, 20).

wait until (apoapsis > 80000).
lock throttle to 0.

// circularization
print "circularizing".
lock steering to prograde.
wait until (eta:apoapsis < 5).
lock throttle to 1.
wait until (periapsis > apoapsis)
lock throttle to 0.
print "Orbit achieved!! hopefully".
