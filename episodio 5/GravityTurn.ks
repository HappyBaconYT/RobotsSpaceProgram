// episodio: 5 astronave: OrbitingBacon

// FUNCTIONS

function CheckFlameout
{
  list engines in enginesList.
  for eng in enginesList
  {
    if (eng:flameout)
    {
      return 1.
    }
  }
  return 0.
}

function MNVLIB_DeltaVCircularization
{
  local mu is body:mu.
  local apo is body:radius + apoapsis.
  local peri is body:radius + periapsis.

  return sqrt(mu/apo) - sqrt((peri*mu)/(apo*(peri + apo)/2)).
}

function MNVLIB_ManeuverTime
{
  parameter deltaV.
  return deltaV/ship:maxthrust/ship:mass.
}

function MNVLIB_ManeuverTimePrecise
{
  parameter deltaV.

  local e is constant():e.
  // get active engine isp
  list engines in eng_list.
  for eng in eng_list
  {
    if (eng:ignition)
    local isp is eng:isp.
  }
  local isp is eng_list[0]:isp.
  local mass_in is ship:mass.
  local mass_fin is mass_in/(e^(deltaV/isp/9.81)).
  local thrust is ship:maxthrust.

  return 9.81*ship:mass*isp*(1 - e^(-deltaV/9.81/isp))/thrust.
}


// MAIN PROGRAM

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
until (airspeed > 200)
{
  if (CheckFlameout)
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
  if (CheckFlameout)
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
  if (CheckFlameout)
  {
    stage.
  }
  wait 0.1.
}
lock throttle to 0.

print "Orbit achieved!".
