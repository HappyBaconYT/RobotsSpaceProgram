// episode 3 -- astronave:nomeacaso

lock steering to heading(270,90).
lock throttle to 0.7.

print "Launching".
stage.

wait until (altitude > 8000).
print "performing gravity turn".
set dir to 270.
set angle to 90.
until (angle < 40)
{
   set angle to angle -5.
   lock steering to heading(dir, angle).
   print "   set steering to " + angle.
   wait 10.
}
lock steering to srfprograde.

wait until (verticalspeed < 0).
print "detach launcher and align for reentry".
stage.
lock steering to retrograde.

wait until (alt:radar < 15000).
print "bleed off speed increasing AoA".
until (verticalspeed < 200)
{
  lock steering to srfprograde.
  wait 1.
  lock steering to srfrerograde.
  wait 1.
}

wait until (alt:radar < 2000 and verticalspeed < 250).
print "deploying parachute".
unlock steering.
stage.
print "good luck with the landing!".
