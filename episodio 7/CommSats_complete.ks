// astronave: CommSats

// ag1 = extend solar panels
// ag2 = deploy fairings
// ag3 = toggle small antenna

// import libraries
runpath("0:LAUNCH_LIB.ks").
runpath("0:MNV_LIB.ks").

// set to known state
sas off.
rcs off.

// set launch parametes
set dir to 90.
set desTWR to 2.
set desApo to 80000.

lock steering to heading(dir,90) + R(0,0,-90).
lock throttle to 1.

// launch
stage.

// pitch-over
wait until (airspeed > 50).
lock steering to heading(dir,80) + R(0,0,-90).
//wait until (airspeed > 100).
//lock steering to heading(dir,75) + R(0,0,-90).
until (airspeed > 200)
{
  if (CheckFlameout())
  {
    stage.
  }
  if (maxthrust > 0)
  {
    set newThrottle to desTWR*9.8*ship:mass/maxthrust.
    lock throttle to newThrottle.
  }
  wait 0.1.
}

// gravity turn
until (apoapsis > desApo)
{
  if (CheckFlameout())
  {
    stage.
  }
  if (maxthrust > 0)
  {
    set newThrottle to desTWR*9.8*ship:mass/maxthrust.
    lock throttle to newThrottle.
  }
  if (altitude < 40000)
  {
    lock steering to srfprograde + R(0,0,-90).
  }
  else
  {
    lock steering to prograde + R(0,-3,-90).
  }
  wait 0.1.
}
lock throttle to 0.

// deploy fairings
ag2 on.
wait 3.

// circularization
rcs on.
wait until (altitude > 70000).
lock steering to heading(dir,0) + R(0,0,-90).
set mnvTime to MNVLIB_ManeuverTimePrecise(MNVLIB_DeltaVCircularization()).
wait until (eta:apoapsis < mnvTime/2).
set start_mnv to time:seconds.
until (time:seconds > start_mnv + mnvTime)
{
  lock throttle to 1.
  if (CheckFlameout())
  {
    stage.
  }
  wait 0.1.
}
lock throttle to 0.
wait 1.

print "Parking orbit achieved!".

// detach launcher
stage.
wait 1.
stage.

// extend solar panels
ag1 on.
wait 1.

// activate antennas
ag3 on.
wait 1.

// align for max sun exposure
lock steering to sun:position.
wait 10.
set warp to 3.
wait until (eta:apoapsis < 30).


// hohmann transfer to 100 km orbit
set desApo to 1000000.
set dv to MNVLIB_HohmannDeltaV(desApo).
set t1 to MNVLIB_ManeuverTimePrecise(dv[0]).
print "burn 1: periapsis - " + t1.

until eta:periapsis < t1 + 120
{
  set warp to 3.
}
until eta:periapsis < t1 + 60
{
  set warp to 2.
}
set warp to 0.
lock steering to prograde.
wait until eta:periapsis < t1.
set start_mnv to time:seconds.
lock throttle to 0.5.
wait until apoapsis > desApo. //time:seconds > start_mnv + 2*t1.
lock throttle to 0.
wait 1.

set t2 to MNVLIB_ManeuverTimePrecise(dv[1]).
print "burn 2: apoapsis - " + t2.
until eta:apoapsis < t2 + 120
{
  set warp to 3.
}
until eta:apoapsis < t2 + 60
{
  set warp to 2.
}
set warp to 0.
lock steering to prograde.
wait until eta:apoapsis < t2.
set start_mnv to time:seconds.
lock throttle to 0.5.
wait until time:seconds > start_mnv + 2*t2.
lock throttle to 0.

print "hohmann transfer completed".


// deployment phase
ship:partstagged("controlprobe")[0]:controlfrom().
set circPeriod to orbit:period.
set flag to 1.

until (flag = 4)
{
  // detach satellite
  lock steering to vcrs(ship:velocity:orbit,-body:position).
  wait 10.
  stage.
  lock steering to retrograde.
  wait 10.

  // transfer orbit
  print "starting transfer orbit".
  lock throttle to 1.
  wait until (orbit:period < 3/4*circPeriod).
  lock throttle to 0.
  print "transfer orbit completed".
  wait 1.

  print "completing one orbit".

  set warp to 3.
  wait until (eta:periapsis < 5).

  // circularization
  set mnvTime to MNVLIB_ManeuverTimePrecise(MNVLIB_DeltaVCircularization()).
  until eta:apoapsis < mnvTime/2 + 120
  {
    set warp to 3.
  }
  until eta:apoapsis < mnvTime/2 + 30
  {
    set warp to 2.
  }
  set warp to 0.
  print "starting circularization".
  lock steering to prograde.
  wait until (eta:apoapsis < mnvTime/2).
  set start_mnv to time:seconds.
  until (time:seconds > start_mnv + mnvTime)
  {
    lock throttle to 1.
  }
  lock throttle to 0.
  print "circularization completed".





  set flag to flag + 1.
}
