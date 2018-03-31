// episodio: 5 -- astronave: OrbitingBacon2.0

// FUNCTIONS
function tilt
{
  parameter minAlt.
  parameter angle.

  wait until altitude > minAlt.
  lock steering to heading(0,angle).
}

function MNVLIB_DeltaVCircularization
{
  set mu to ship:orbit:body:mu.
  set apo to body:radius + apoapsis.
  set peri to body:radius + periapsis.

  set DeltaV to sqrt(mu/apo) - sqrt((2*peri*mu)/(apo*(peri + apo))).
  return DeltaV.
}

function MNVLIB_ManeuverTime
{
  parameter deltaV.
  set accel to ship:maxthrust/ship:mass.
  return deltaV/accel.
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
lock steering to srfprograde.

// circularization
wait until (altitude > 70000).
lock steering to heading(0,0).
set mnvTime to MNVLIB_ManeuverTime(MNVLIB_DeltaVCircularization()).
wait until (eta:apoapsis < mnvTime/2).
set start_mnv to time:seconds.
lock throttle to 1.
wait until time:seconds > start_mnv + mnvTime.
lock throttle to 0.

print "Orbit achieved!".

// deorbit
lock steering to retrograde.
wait until eta:periapsis < 5.
print "deorbiting".
lock throttle to 1.
wait until (periapsis < 30000).
lock throttle to 0.
wait 5.

// detach engine
print "detatch engine".
stage.
wait 5.

// align for reentry
print "align for reentry".
lock steering to srfretrograde.

// deploy parachutes
wait until (alt:radar < 3000).
print "deploy parachutes".
stage.
