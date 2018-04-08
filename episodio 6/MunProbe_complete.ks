// episodio: 6 -- astronave: MunProbe

// ag1 = toggle solar panels
// ag2 = deploy fairings
// ag4 = toggle small antenna
// ag5 = all the scienceee

// import libraries
copypath("0:LAUNCH_LIB.ks", "1:").
copypath("0:MNV_LIB.ks", "1:").
run LAUNCH_LIB. // tilt - checkflameout
run MNV_LIB. // deltavcirc - mnvtimeprecise - hohmanndeltav

// calculate angle to the mun
function MunAngle
{
  set munLongitude to body("Mun"):longitude.
  set vesselLongitude to ship:longitude.

  if (munLongitude < 0)
  {
    set munLongitude to munLongitude + 360.
  }
  if (vesselLongitude < 0)
  {
    set vesselLongitude to vesselLongitude + 360.
  }

  return mod(body("Mun"):longitude - ship:longitude + 720, 360).
}

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
lock steering to heading(dir,85) + R(0,0,-90).
until (airspeed > 170)
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
  lock steering to srfprograde + R(0,0,-90).
  wait 0.1.
}
lock throttle to 0.

// circularization
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

print "Parking orbit achieved!".

// deploy fairings
ag2 on.
wait 3.

// extend solar panels
ag1 on.
wait 3.

// detach launcher
lock throttle to 0.
wait 2.
stage.
wait 2.

// align for max sun exposure
lock steering to sun:position.

wait 20.


// wait for launch window
print "Waiting for launch window".
until (MunAngle() < 140 and MunAngle() > 130)
{
  print "angle = " + MunAngle().
  wait (10).
}
set warp to 0.

// munar injection burn
print "Beginning transfer burn".
set dir to prograde.
lock steering to prograde.
wait 10.
lock throttle to 1.
wait until (apoapsis > body("Mun"):apoapsis).
lock throttle to 0.
print "transfer burn completed".
lock steering to sun:position.
wait 10.

// high over mun science
wait until (ship:orbit:body:name = "Mun").
set warp to 0.
wait 10.
print "performing science high over the mun!".
ag5 on.

// low over mun science
if (periapsis < 30000)
{
  wait until(eta:periapsis < 5).
  wait 10.
  print "performing science low over the mun!".
  ag5 on.
}


// wait for burn location
print "Waiting for burn window".
wait until (ship:orbit:body:name = "Kerbin").
wait until (eta:apoapsis < 120).
set warp to 0.
wait until (eta:apoapsis < 20).
if (periapsis > 40000)
{
  lock steering to retrograde.
  wait 10.
  lock throttle to 0.2.
  wait until (periapsis < 40000).
  lock throttle to 0.
}
else
{
  lock steering to prograde.
  wait 10.
  lock throttle to 0.2.
  wait until (periapsis > 40000).
  lock throttle to 0.
}

// align for max sun exposure
lock steering to sun:position.
wait 5.

// wait until close to kerbin atmo
wait until (altitude < 85000).
set warp to 0.
print "align for reentry".
lock steering to srfretrograde.
print "retracting solar panels".
ag1 on.

// detach engine
print "detach engine".
stage.
wait 5.

// deploy parachutes
print "deploy parachute".
//wait until (alt:radar < 3000).
stage.

// try ground science
wait until (alt:radar < 20).
wait 30.
ag5 on.
