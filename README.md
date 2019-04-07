PID control for your ESO view distance slider.

## What does it do? 

If your framerate drops below 50 FPS this addon will adjust the view distance to try to bring the FPS back up.

If your framerate is above 50 FPS but the view distance is not maxed, it will increase the view distance until either
your FPS is around 50 or the view distance slider is maxed (100).

In other words, it balances between view distance and FPS, while aiming for 50+ FPS.

> "But my hardware can handle much more than 50 FPS!"

It does not limit your FPS to 50! If your hardware can handle 100 FPS and 100% view distance, then that is what you will
get.

## How do I use it?

Install the addon, then make sure it is enabled in ESO. Then forget about it :)

If you want to manally set your view distance then either disable the addon or use `/ddpid` to turn it off temporarily.

## How do I install it?

Sorry, I'm very lazy, so you have to do this by hand at the moment (no Minion). It's not hard, though:

* Click 'Clone or download' and 'Download ZIP', near the top of the page.
* Extract the `ddpid-master.zip` that you downloaded. This creates a folder called `ddpid-master`.
* Rename this folder to `DDPID` (this must be exact)
* Drop this folder into your ESO Addons folder: Documents > Elder Scrolls Online > live > AddOns
* Enable the addon in game.

## Tell me more 

The default set point of 50 FPS is fairly ideal for most cases. It is smooth without being out of the reach of 
reasonable hardware in the majority of locations in the game. 

That said, you can change it with e.g. `/ddpid 60` if you want to. This resets every time you log in. 

For a permanent change you must edit the variable `targetFps` at the top of `DDPID.lua`. You can edit this file with
any text editor, e.g. notepad. This is considered advanced usage and is unnecessary most of the time. Try 50 first.

Do not set `targetFps` to the FPS you want. Instead, pick a value having answered the question 'what is the 
minimum FPS I can tolerate in open-world locations outside of cities?'
