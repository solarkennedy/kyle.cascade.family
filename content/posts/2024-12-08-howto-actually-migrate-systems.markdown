---
title: "How to Actually Migrate to New Systems in Infrastructure"
date: 2024-12-08
published: false
---

## TL;DR:

Whenever doing a big migration from `system` to `system2`, frontload as work as possible into making `system2` as identical to `system` for the purposes of migration.
That way you can migrate to `system2` as seamlessly as possible, without a huge manual migration effort.
_Then_ you can undo the scaffolding from `system`.

## Intro

Work long enough in tech and you will hear the analogy we're ["rebuilding the plane in midflight"](https://venturebeat.com/business/facebooks-platform-rebuilding-the-plane-in-midflight/).

It just means engineers are upgrading and replacing technology _while_ keeping the lights on and users happy.
Generally we strive for no downtime, no loss of functionality, and no dataloss.

And sure, it is a [bad analogy](https://medium.com/@jpaulreed/rewriting-harmful-analogies-while-theyre-in-use-d01442c0728b).

[![Changing Tires on a Moving Vehicle](/uploads/2024-12-08-howto-actually-migrate-systems/changing-tires.gif)](https://www.youtube.com/watch?v=cIpBpGQ0XTI)

The types of changes you might encounter could be anything from:

* standards OS upgrades
* library upgrades
* language version upgrades
* runtime upgrades
* moving to containers
* moving to Kubernetes
* moving to the "cloud"
* rewriting of your core software!

It is a lot of change, all the time.
Sometimes referred to as "running to stand still".

For this blog post I'll be writing about the **biggest* changes, like rewrites, big migrations, or "modernizing" something.

## Big Migrations

For the rest of this blog I'll reference two theoretical systems, `system` and `system2` (we never think to call the first system `system1`).

Let's imagine what it might look like encountering a big `system` and thinking through how to modernize it.

### Step1: Shit All Over the "Legacy"

Of course the first think you do is shit all over the code.

> "It's spagetti!"
>
> "There are not enough tests/documentation!"
>
> "It is in a language/framework I don't like!"
> 
> "Nobody understands it, everyone who built it left!"
>



["Strangler Fig Pattern"](https://martinfowler.com/bliki/StranglerFigApplication.html)


https://en.wikipedia.org/wiki/Strangler_fig#/media/File:Strangler_tree.jpg

https://en.wikipedia.org/wiki/Strangler_fig#/media/File:Corkscrew_-_bald_cypress_with_strangler_fig_inside.jpg