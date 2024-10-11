---
title: "Automating a Roomba with ESPHome"
date: 2024-10-10
---

When I first bought this wifi-connected Roomba, I knew that someday it might have to join the [Internet of Shit](https://x.com/internetofshit).

![Wifi Roomba](/uploads/2024-10-10-roomba-esphome/roomba-wifi.jpeg)

The iRobot corporation has a pretty good track record for supporting their products, but at **some** point those servers are going to come down, or the app will break, or the SSL certificates will expire, etc.

These products need continuous support from their companies in order to operate, and products simply cannot be supported forever.

How can I ensure this Roomba will last just as long as my "dumb" Roomba that just bounces off of walls?
What if I didn't need continuous support from the iRobot corporation's servers?

## Taking Ownership

Luckily, at the time of this writing, you can actually extract the your Roomba's [Username and Password](https://github.com/koalazak/dorita980?tab=readme-ov-file#how-to-get-your-usernameblid-and-password) from it.

But even if you do, you are still just one firmware upgrade away from your vacuum turning into a boat anchor.

What I really want to do is to disconnect my Roomba from the internet entirely.
I don't want it to do a little jingle in the middle of the night after a firmware upgrade ever again.
I never want it to upload photographs of me in a robe to iRobot servers ever again.
I also never want to use the app or get push notifications from it ever again.

One way to achieve this independence is with some open source software I'm releasing today: [The Roomba-Bridge ESPHome component](https://github.com/solarkennedy/roomba-bridge-esphome).

## The Roomba Bridge

Without even opening up the Roomba you can flash this software onto a microcontroller and get access to all the Roomba's functions, _without internet access or an app_.

![ESPHome Web Interface Screenshot](/uploads/2024-10-10-roomba-esphome/esphome-screenshot.png)

[ESPHome](https://esphome.io/) is my framework of choice for building reliable, secure, and functional IOT dohickies in my house, and this bridge is built as an ESPHome component.

This means you get goodies like:

* Wide integration with an enormous number of integrations
* Easy to use and well-documented config language
* Over-the-air updates and logging
* Decent web interface

The biggest downside is the learning curve.
If you have some sort of server (like a Raspberry Pi) and are just getting into home automation, Home Assistant is probably a better choice and also has a [Roomba Integration](https://www.home-assistant.io/integrations/roomba/).

## Prior Art

I was only able to build this based on the prior art of others:

* [Home Assistant Roomba Integration](https://www.home-assistant.io/integrations/roomba/) - Runs on your existing HA installation
* [Roomba980-Python](https://github.com/NickWaterton/Roomba980-Python) - the Python library upon which the HA extension is based
* [Rest980](https://github.com/koalazak/rest980) - REST API for Roombas written in NodeJS
* [Dorita980](https://github.com/koalazak/dorita980) - Node library upon which Rest980 is based

My code just means you can control your Roomba, without Home Assistant, and without running nodejs or python or anything that requires a "server".

## Demo

ESPHome is extremely flexible, and allows you to wire automations together.
With my bridge in place, I can hook up another ESPHome running a [rf-bridge](https://esphome.io/components/rf_bridge.html) and get what I _actually_ wanted: Real physical buttons to control the Roomba!

{{< video src="/uploads/2024-10-10-roomba-esphome/start.mp4" width=800 >}}
{{< video src="/uploads/2024-10-10-roomba-esphome/dock.mp4"  width=800 >}}

I plan on adding more buttons for cleaning each room.

## Conclusion

I have a lot of mixed feelings about "the internet of things".
One on the one hand, I love automating physical things and making my life more convenient.
On the other hand, I detest apps, firmware updates, and just generally any time where "my stuff" is not in my control, but really in the control of some other company.

You can have both!
Tools like ESPHome and Home Assistant are great ways for consumers to take back control of their things and shed dependence on special apps, remote servers you don't control, and heck dependence on the internet!
(one should still be able to turn on their lights or run the vacuum if the internet is down)