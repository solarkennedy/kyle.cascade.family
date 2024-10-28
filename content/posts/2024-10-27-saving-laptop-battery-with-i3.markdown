---
title: "Saving Laptop Battery by Suspending Workspaces in i3"
date: 2024-10-27
---

I love my little [OneNetbook 4](https://www.1netbook.com/businesepc/onenetbook-4-platinum/):

[![Palm PVG100 plus OneNetbook 4](/uploads/2024-10-27-saving-laptop-battery-with-i3/palm-pvg100-one-netbook4.thumb.jpg)](/uploads/2024-10-27-saving-laptop-battery-with-i3/palm-pvg100-one-netbook4.jpg)


I love its capabilities and size.

For the nerds:

```
            .-/+oossssoo+/-.               kyle@netbook4
        `:+ssssssssssssssssss+:`           -------------
      -+ssssssssssssssssssyyssss+-         OS: Ubuntu 24.04.1 LTS x86_64
    .ossssssssssssssssssdMMMNysssso.       Host: SYSTEM_PRODUCT_NAME
   /ssssssssssshdmmNNmmyNMMMMhssssss/      Kernel: 6.8.0-45-generic
  +ssssssssshmydMMMMMMMNddddyssssssss+     Uptime: 23 hours, 2 mins
 /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/    Packages: 4492 (dpkg), 33 (flatpak)
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Shell: bash 5.2.21
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Resolution: 2560x1600
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   DE: Regolith 4.3
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   WM: i3
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Theme: Nordic [GTK2/3]
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Icons: Arc [GTK2/3]
 /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/    Terminal: st
  +sssssssssdmydMMMMMMMMddddyssssssss+     Terminal Font: UbuntuMono Nerd Font Mono
   /ssssssssssshdmNNNNmyNMMMMhssssss/      CPU: 11th Gen Intel i7-1160G7 (8) @ 4.400GHz
    .ossssssssssssssssssdMMMNysssso.       GPU: Intel Tiger Lake-UP4 GT2 [Iris Xe Graphics]
      -+sssssssssssssssssyyyssss+-         Memory: 5625MiB / 15717MiB
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.
```

Haha `SYSTEM_PRODUCT_NAME`.
That is how you can tell it is a quality laptop.

It has plenty of speed, ram, and disk for me.
It has two Thunderbolt 4 ports, which means I can plug in an eGPU and play games or tinker with LLMs.

Incredibly, all of its hardware, including the touch screen and accelerometer, worked out of the box for me.
The only exception was the fingerprint reader, but a driver is [in progress](https://github.com/ftfpteams/ubuntu_spi) by the manufacturer.

There are three main compromises:
* No webcam
* Small battery
* Noisy fan

Today I'm writing about a hack to squeeze out even more battery life in Linux.
I'm fine without a webcam, and the noisy fan can wait another day.

## Tuning Battery Life on Linux

One the one hand, the battery life of any particular laptop running Linux is going to suck compared to whatever operating system it came with.

More engineering effort has gone into tuning the energy usage on laptops for Windows and MacOS than Linux.

Luckily, Linux doesn't stop you from spending many hours tuning your system for the best battery life possible, and making tradeoffs no other sane laptop manufacturer would!

### TLP

I think the first thing one should do when looking to get better battery life on Linux is to install [TLP](https://linrunner.de/tlp/index.html) and the [TLPUI](https://github.com/d4nj1/TLPUI).

TLP provides tons of tweakable knobs for both AC and Battery modes.
I personally crank everything to the absolute minimum when on battery, and everything cranked to the max on AC.

That is right, on battery life my CPU hovers at around **400mhz** like the good old days.

When plugged in, the CPU (and fan!) screams up to **4.4ghz**.
Just how I like it.

But this blog post is about i3 (the window manager).
The second thing one should do is add an i3 status bar widget to show you the TLP status and *exactly how much power the laptop is consuming*:

[![TLP & Power Meter](/uploads/2024-10-27-saving-laptop-battery-with-i3/i3-status.png)](/uploads/2024-10-27-saving-laptop-battery-with-i3/i3-status.png)

The code that powers that is this:

```
#!/bin/bash
status=$(sudo tlp-stat | grep 'Mode' | head -n 1 | awk '{print $3 " " $4}')
echo -n "TLP: $status "
echo "$(bc <<< "scale=2; $(cat /sys/class/power_supply/BAT0/power_now) / 1000000") W"
```

Just being aware of how much power the laptop is using at any given time is a great way to pause high-draw activities.
Plus it is just cool.
Who doesn't love a cool status bar.

## Auto-Suspending Workspaces

One day when wondering what is consuming all of the precious joules out of my battery, I ran `top` and saw this:

[![Steam in top](/uploads/2024-10-27-saving-laptop-battery-with-i3/steam-top.png)](/uploads/2024-10-27-saving-battery-with-i3/steam-top.png)

Steam!

The thing is, I wasn't even playing a game or *using* steam.
It was just doing it's thing in the tray, but it was _open_ on workspace 10.

In order to explain how to suspend this, we need to explain i3 workspaces.

## i3 Workspaces

[![i3 Workspaces Example](/uploads/2024-10-27-saving-laptop-battery-with-i3/i3-workspaces.png)](/uploads/2024-10-27-saving-battery-with-i3/i3-workspaces.png)

In i3, "Workspaces" are a key feature to save yourself from moving windows around with a mouse.
On MacOS there is a similar feature called "Spaces" (but you have to use the mouse even more).

For me, I stick the important stuff in the front, and the more idly stuff in the back.
In practice that means:

* 1: Email and calendar
* 2: Messaging
* 3-8: Active projects
* 9-10: Games

But if we are trying to optimize battery life, how can we make sure that 9 & 10 don't use any power?

## Autosuspending Workspaces

With steam and games, if I'm not actively looking at them, I don't want them to use any electricity.
I don't want them to show up in `top`!

Sure, I could open and exit Steam or a game every time, but it would be nice if I could have the best of both worlds and allow them to stay "running" on workspaces 9 & 10, but just paused while I'm not looking at them?

In Linux, one way to "pause" a process is with the `SIGSTOP` signal.
When this signal is sent to a process, the process is suspended by the kernel and won't get going again until unpaused (`SIGCONT`).

`SIGSTOP` is the uncatchable signal, which should not be confused with `SIGTSTP`, which is what a process gets when you press CTRL-Z ([ref](https://stackoverflow.com/questions/11886812/what-is-the-difference-between-sigstop-and-sigtstp)).

Given that, our program will work like this:

* When there is a workspace switch away from workspaces 9 or 10
  * Send a `SIGSTOP` to every process on that workspace
* When we switch onto either workspace 9 or 10
  * Send a `SIGCONT` to resume any process on that workspace
* For good measure we can send a notification to the screen to assure the user that it did something

[![i3 Workspaces Example](/uploads/2024-10-27-saving-laptop-battery-with-i3/screenshot-suspend.png)](/uploads/2024-10-27-saving-battery-with-i3/screenshot-suspend.png)

There are a lot of details for how to *actually* do that, see the [github repo](https://github.com/solarkennedy/i3-workspace-autosuspender) for the actual python script.

## Caveats

There is a reason that i3 doesn't do this by default!

I'm willing to live with some glitches in the pursuit of battery life, like:

* Some applications really don't tolerate being suspended, where as others can resume/suspend just as fast as switching the workspace
* Multi-process apps like Chromium or VS Codium can't be suspended like this either
* You can't (obviously) use this for a music playing app, or an app that you _want_ to run in the background, like an instant messenger
* The autosuspender can only find "the main" pid associated with that workspace
  * Apps like steam have complex process trees, and not all of those have windows with a `_NET_WM_PID` associated with them
  * There is probably a better way to do it

Feel free to check out the [code](https://github.com/solarkennedy/i3-workspace-autosuspender) and contribute if you too run i3 and which to maximize your laptop battery life.
