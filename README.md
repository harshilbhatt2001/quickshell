# VoidBar

_Minimal, Verbose, Clean_

## Ethos

This bar is a retort to all of the "dynamic island" style bars that have been popular
recently. I'm sure you know the ones, with a cramped, forced "minimalistic" aesthetic,
that, even though marketed toward window manager users such as myself, usually end up
being mouse driven spring animation slop.

Nobody wants that.

If you use something like Caelestia or Noctalia, sure, whatever. I'm not going to be some
elitist and say they aren't without their uses. If you want a cohesive shell with theme
switching and everything working perfectly out of the box, then they're good enough
solutions for new users, or even experienced ones that just claim they don't want to waste
their time writing from scratch.

However, everything outside of those shells is bullshit. Lately, all the shells I've seen
have been "dynamic islands", bars that only show the time when dormant and have a shitload
of features that you're never going to use effectively. They have no concept of workspace
identifiers, instead opting for nondescript nerd icon blobs rather than the tried and true
numbers that seem to always be more useful. Not that it matters, they're hidden anyway,
until you change workspaces and they get shown for a second or two after the point that
you actually needed to see them.

Then come the theme switchers, a sorry excuse for a feature that just ends up being a
party trick at the end of the day. Changing wallpapers every so often I can get behind,
but the whole theme? Really? The prophecy is borderline self fulfilling, you're going to
pick a favorite eventually and end up never touching the switcher again, no matter how
many variations of gruvbox you have configured. On top of that, are you really going to be
switching wallpapers at runtime that often? I for one never even considered implementing a
feature so distracting, opting instead to actually getting shit done, to the behest of
everyone on r/unixporn.

The final gripe I have with these so called "minimal bars" is, ironically, the
over-abundance of features. No, you don't need an android-style pull down menu to adjust
your brightness, no, you don't need a button to change your screen scaling on the fly, and
no, you don't need to be able to authenticate with your fucking desktop shell. Just use
sudo like the rest of us. Many such features are jammed into bars like these, it's as if
they need some standout feature in order to actually get used (oh wait). Bars shouldn't
need a whole custom settings app. Bars shouldn't need tutorials for what keybinds to use
to access some obscure feature. Bars shouldn't implement entire bluetooth management
interfaces. Bars should show the time, what workspace you're on, and maybe, at a stretch,
how much battery you have left. However, none of the geniuses over in the quickshell
discussions tab can figure out how to put numbers where the workspace blobs are.

So, I had no choice to fix the problem.

### The problem

I like minimalistic apps, and minimalism in general. But there comes a point where being
"minimal" either wraps around to being over the top and useless, or practically unusable.
Theoretically, the most minimal bar is no bar at all, but that suffers from not existing
by definition, so I did my best to come up with something that looks good, has utility,
and, most of the time, stays out of your way when you don't care about what it says.

The first thing I did was to expand from a magical single pill to the more classical
layout, a left, center and right section, ripped straight from waybar. If you only have a
left or right section, then your screen looks lopsided, and if you only have a center
section, then your bar either looks weirdly wide, or becomes just another useless capsule.
As I have ordained, the left section is solely for the workspace switcher, the center is
for the clock, and the right is for optional information, like bluetooth connection and
battery level, which you wouldn't need on a desktop machine.

The second innovation I came up with (fr fr no cap) was removing useless information from
the bar entirely. When wifi is disconnected, what good is it to have a "no wifi" icon
taking up space on the screen? None at all, in fact. Instead, I have opted to hide unused
modules entirely. For example, if no bluetooth devices are connected, instead of leaving a
useless logo in the top right, the module slides up off of the screen, telling you that
there is nothing connected simply through its absence. Plus, it looks better. That means
that on a system with no battery, no wifi connection (ethernet hides the module), and no
bluetooth devices connected, like my main pc most of the time, there are no needless icons
cluttering the top right of the screen.

The third and final main feature that I implemented is monitor-exclusive modules. If you
have multiple monitors, you most likely won't be looking at the second if you're doing
work on the first. If that's the case, then why would you need a ticking clock on your
second monitor? Why would you need an entire shell over there taking up space and being a
potential distraction (yes I know I'm being melodramatic but stfu)? This was one of my
main gripes with waybar, the fact that the same bar with the same information was
plastered across all of your screens, regardless of whether the information was needed or
not. A simple check can be done within an instance of the bar in quickshell, as to whether
that instance of the bar is on the currently focused monitor. If it is? Display the
modules. If not? Hide them away to keep the desktop clean. It's as simple as that.

No repeated information, no unnecesarry "disconnected" icons, and, most importantly, no
useless features. Speaking of...

## Features

### Tl;Dr

- _Workspace switcher:_ Displaying only the workspaces on that monitor. When on a
  different monitor, highlights the focused workspace as to distinguish it from unfocused
  workspaces
- _Clock:_ It's a clock. When a notification comes in, the clock is substituted for a
  notification popup. If music is playing (any playerctld compatible player), when the
  track changes a toast will appear, and when hovered over, the clock will be replaced
  with a music information screen. The hovered clock is a pager: the mouse's thumb
  (horizontal) wheel flips between the music screen and a month calendar. Click a day to
  list its events. Events come from Google Calendar through
  [gcalcli](https://github.com/insanum/gcalcli): install it and run `gcalcli init` once,
  and the calendar picks them up (refreshing every five minutes). Without gcalcli it is
  just a calendar. Views: month (default), day, 3-day and week. Click the title to cycle
  them, use the arrows or the normal wheel to move through time. Click an event, an empty
  time slot, or the `+` to add, edit or delete events (written back through gcalcli;
  calendars listed in `CalendarManager.excludedCalendars` are hidden).
- _Network:_ Displays whether the machine is connected to wifi or not. Ethernet is assumed
  a permanent feature, and the module is thus hidden even though a network is connected.
  When clicked, shows the network name, local ip address, interface that is being used to
  connect, and whether the network has saved login information.
- _Bluetooth:_ Displays whether there are any connected bluetooth devices. Does NOT
  function as a full bluetooth interface because I have bluetui for that. When clicked,
  displays connected devices, appropriate icons, and their mac addresses. The box
  containing the icon doubles as a battery indicator, and when the icon is hovered over it
  is replaced with a numerical percentage referring to the device's battery level
- _Battery:_ Displays battery level, and state through coloring and icons. When unplugged,
  battery icon is reactive to every 10%. When plugged in but not recieving charge, the
  module is highlighted orange. when plugged in and recieving charge, the module is
  highlighted purple (the best color). When plugged in and full, the module is highlighted
  blue. Icons also change to reflect the battery state, using the `nf-md-battery` class of
  icons, as labeled on the nerd font website. When clicked on, The module shows the
  battery's UPower reference (eg `BAT0`), reported charge in Wh, change rate in watts for
  both charging and discharging, the time remaining until the battery is either fully
  charged or empty, and a numerical percentage alongside another vertical battery meter
  (same component as the bluetooth devices)

- Planned features (when I get around to it)
  - Logout menu (wlogout is still broken lol)
  - Notification menu/management
  - Lock screen
  - Volume control? (probably not, way-edges clears)
  - Music indicator on the left of the clock when music is playing

### More rambling

If you read the above section, you will notice there is no mention of a theme switcher or
launcher functionality. That is because I made a bar, not a theme switcher or a launcher.
Other, more knowledgeable people have made those things already, and they are almost
definately more feature rich and polished than anything you or I could make in qml. Once
again, this bar has NO BULLSHIT!!! NONE!!!

One thing I found cool while making this bar is all the interesting information that most
other bars will hide from you. Instead of what my cpu temperature is, I can see how fast
my battery is charging down to 8 decimal places of precision. On top of this, because qml
is just fancy javascript under the hood, you can do surprisingly complex data manipulation
if needs be. Of course, you can pull out an old trusty `toFixed(2)` so that there aren't
so many decimals, but beyond that, for example, the mpris api gives you track info in
miliseconds, which means you have to make a utility function to convert from that format
into a readable one, and then manipulate those values again, because they don't have
leading zeros by default.

Because of how qml works, I worried less about how inefficient my polling code was, and
how things were going to react with eachother, and update order, and instead focused on
how I wanted the bar to act. I'll tell you a little secret, qml is a really really easy
language to learn. That's how it's supposed to be, and why there's a quick in the name.
Qml is to desktop apps what tailwind is to html, almost. You can throw together something
that looks cohesive in a few minutes, and because of how state management works, adding
reactivity like a hover animation is stupidly easy. Everything is predictable, and because
you don't have to worry about how to update components, you can just throw in a few js
functions here and there regardless of whether you need them. I have to tell you, having a
bunch of heights and margins and then using a bunch of maths in a function to dynamically
calculate the height of a window or a textbox is the coolest shit ever.

I will actually use this bar on my main machine. There might be some weird shit going on
with the battery module, because the only machine I had while making this was a laptop,
but once I get home everything will be resolved. This was not made to post on reddit. This
wasn't made on a whim. I hate the state of places like r/unixporn, where, for every decent
and original rice, there are 300 copycats or people just running a prefab shell with a
custom wallpaper. And don't even get me going on the damn islands again. If I can make
something like this in a few days, then so can you. Go make something, and thanks for
reading <3
