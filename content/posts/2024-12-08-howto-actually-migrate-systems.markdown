---
title: "How to Actually Migrate Complex Systems in Infrastructure"
date: 2024-12-08
---

{{< rawhtml >}}
<div class="form-container" style="border: 2px solid #EEE; padding: 10px; border-radius: 5px;">
    <p>
        Want to make this blog post more fun to read?
        <br>
        Replace the placeholder system names with ones you are familiar with.
        Then share the updated <a id="currentURL" href="#">URL</a>
        with your friends, and it will retain those replacements—a personalized blog post just for you!
    </p>
    <label for="old-word">Word for your old legacy system:</label>
    <input type="text" id="old-word" placeholder="perl, monolith, docker swarm, syslog"><br>
    <label for="new-word">Word for your new shiny system:</label>
    <input type="text" id="new-word" placeholder="rust, microservices, k8s, syslog-ng"><br>
    <button id="apply-btn" onclick="applyChanges()" style="">Replace</button>
    <button id="reset-btn" onclick="resetChanges()" style="display: none;">Reset</button>
</div>
<script>
    function resetChanges() {
        const baseUrl = `${window.location.origin}${window.location.pathname}`;
        window.location.href = baseUrl;
    }
    function getUrlParams() {
        const params = new URLSearchParams(window.location.search);
        return {
            oldWord: params.get('old') || '',
            newWord: params.get('new') || '',
        };
    }
    function updateUrl(oldWord, newWord) {
        const newUrl = `${window.location.origin}${window.location.pathname}?old=${encodeURIComponent(oldWord)}&new=${encodeURIComponent(newWord)}`;
        history.pushState(null, '', newUrl);
        document.getElementById('currentURL').href = newUrl;
    }
    function replaceWordsInContent(oldWord, newWord) {
        const placeholders = document.querySelectorAll('code');
        placeholders.forEach((code) => {
            if (code.textContent === 'system') code.textContent = oldWord;
            else if (code.textContent === 'system1') code.textContent = `${oldWord}1`;
            else if (code.textContent === 'system2') code.textContent = newWord;
        });
    }
    function applyChanges() {
        const oldWord = document.getElementById('old-word').value.trim();
        const newWord = document.getElementById('new-word').value.trim();
        if (!oldWord || !newWord) {
            alert('Please enter both replacements!');
            return;
        }
        replaceWordsInContent(oldWord, newWord);
        updateUrl(oldWord, newWord);
        document.getElementById('reset-btn').style.display = '';
        document.getElementById('apply-btn').style.display = 'none';
    }
    window.onload = () => {
        const { oldWord, newWord } = getUrlParams();
        if (!oldWord || !newWord) {
            return;
        }
        replaceWordsInContent(oldWord, newWord);
        document.getElementById('old-word').value = oldWord;
        document.getElementById('new-word').value = newWord;
        document.getElementById('currentURL').href = window.location.href;
        document.getElementById('reset-btn').style.display = '';
        document.getElementById('apply-btn').style.display = 'none';
    };
</script>
{{< /rawhtml >}}

## TL;DR:

Whenever doing a big migration from `system` to `system2`, front-load as work as possible into building migration scaffolding to `system2`.
That way you can migrate to `system2` as seamlessly as possible, without a huge manual migration effort, one piece of functionality at a time.
_Then_ you can undo the scaffolding from `system`.
This "Strangler Fig Pattern" is the key to making large migrations successful without putting the burden on your customers.

## Intro

Work long enough in tech and you will hear the analogy we're ["rebuilding the plane in midflight"](https://venturebeat.com/business/facebooks-platform-rebuilding-the-plane-in-midflight/).

[![Changing Tires on a Moving Vehicle](/uploads/2024-12-08-howto-actually-migrate-systems/changing-tires.gif)](https://www.youtube.com/watch?v=cIpBpGQ0XTI)

It just means engineers are upgrading and replacing technology _while_ keeping the lights on and users happy.
Generally we strive for no downtime, no loss of functionality, and no data loss.

And sure, it is a [bad analogy](https://medium.com/@jpaulreed/rewriting-harmful-analogies-while-theyre-in-use-d01442c0728b).
But it helps us collectively visualize a difficult and common activity.

The types of changes you might encounter could be anything from:

- standard OS upgrades
- library upgrades
- language version upgrades
- runtime upgrades
- moving to containers
- moving to Kubernetes
- moving to the "cloud"
- rewriting of your core software!

It is a lot of change, all the time.
Sometimes referred to as "running to stand still".

For this blog post I'll be writing about the **biggest** of changes, like rewrites, big migrations, or "modernizing" something.

## Big Migrations

For the rest of this blog I'll reference two theoretical systems, `system` and `system2` (we never think to call the first system `system1`).

Let's imagine what it might look like encountering a big `system` and thinking through how to modernize it.

## Step 1: Shit All Over the "Legacy" Code

Of course the first think you do is shit all over the code.

> "It's spaghetti!"
>
> "There are not enough tests/documentation!"
>
> "It is in a language/framework I don't like!"
>
> "Nobody understands it, everyone who built it left!"

I've heard it all.
But you know, now that I'm older and wiser, you will never hear me say anything like this, ever.
It's all fine.
All code can be improved, get more tests, more docs.
The real question is: how urgent is it that we improve the codebase compared to other priorities?

I never use the word "legacy" either.
There is just too much negative connotation for that word.
I always use the word "classic", because it reminds me of "classic" cars, and feels more respectful the software right in front of us that is paying the bills.

I swear the term "legacy" or "deprecated" is so overused, it might as well just mean "code I don't like" or "code I'm not interested in learning how it works".

So no, don't shit over _your_ codebase.
Just be realistic and honest about the state that it is in, and balance the priorities that you have with the urge to just throw it all in the trash.

But there are cases where is a real business justification for making significant changes to a ~~legacy~~ classic codebase.

How should one actually do that?

## Step 2: Be Honest With Yourself About How Long You Must "Roman Ride"

Roman riding is where you stand on two horses at the same time:

[![Roman Riding](/uploads/2024-12-08-howto-actually-migrate-systems/roman-riding.jpeg)](https://www.texastrickriders.com/rodeos)

Any non-trivial migration is going to require _some_ roman riding of `system` and `system2`.

In my experience, the less time, the better.

> **Migration Tenet 1**: Minimize the time you roman ride at all costs.
> Do NOT underestimate the burden of roman riding.

I feel like roman riding with two systems costs a team _more_ than 2x.
I feel like it is more like 4x the work due to inter-system interactions and switching overhead.

Let's explore some other tenets as we look at some Bad Ideas.

## Bad Idea 1: Hard Fork

So you've decided to make a significant change to `system`.
What if you fork the code, and do all new development on that fork, while leaving the old fork behind?

{{< mermaid >}}
---
title: The Hard Fork
---
%%{init: {'gitGraph': {'showBranches': true, 'showCommitLabel':true,'mainBranchName': 'system'}} }%%
gitGraph
commit id: "Feature 1"
commit id: "Feature 2"
branch system2
checkout system2
commit id: "Feature 3"
commit id: "Feature 4"
checkout system
commit id: "Feature 5"
commit id: "Feature 6"
{{< /mermaid >}}

The big problems with this are:

- The business is not going to stop development on `system`.
  The show must go on, so you have to deal with that.
- This means that while you build `system2`, you have to keep up with `system`s features, twice the work!
- This drift is usually worse than you think.

It is hard for us engineers to be honest with ourselves about how long we will have both `system` and `system2` when we hard fork.
Will it be months or years?

I don't think there are any tenets here, sometimes you gotta do this, but gosh, absolutely minimize the time you need to keep a fork.

**Better way**: Don't fork!
Instead, use new files, modules, logical branches, or anything else.

## Bad Idea 2: Split Teams

It might be very tempting to take the `system` team and split them into two: The `system` team and the `system2` team.

{{< mermaid >}}
---
title: The Great Team Split
---
graph TD
subgraph Infrastructure Team
direction TB
System[System Team]
System2[System2 Team]
end
{{< /mermaid >}}

The idea here is that you can have half the team work on `system`, keeping it running and maintained with features from the business, while the other half works on `system2`, bringing it to feature parity.

This is a bad idea because:

- Team `system` is going to miss out on the shared [theory building](https://gwern.net/doc/cs/algorithm/1985-naur.pdf) of building up `system2` and how it works
- Team `system` might even feel slighted.
  Why should they have to only work on the "legacy" codebase?
- Team `system2` misses out on first-hand experience with the continued changes that happen on `system`, the drift continues.
- Team `system2` may being to "leave the ground" (sometimes called "infrastructure astronauts") as they are further removed from `system` (in other words, they might start building things they don't need).
  They don't have any customers (yet) to keep happy, so they might let it go to their heads and have a true [second-system effect](https://en.wikipedia.org/wiki/Second-system_effect).

**Better Way**: Keep the team unified because they all need to be able to maintain `system2` when it takes over.
They also all need to stay informed with the changes `system` is also undergoing.
Stay together, prevent an "us vs them" from happening, and keep all the shared knowledge distributed across all team members.

## Bad Idea 3: The One-Man Army

Sometimes there is only one strong advocate for a change on a team.
Maybe it is one vocal Rust proponent.
Maybe the team thinks Vue is fine except one person on the team thinks they should move to React.
Maybe there is just a hotshot on the team who thinks they can move the code from Python 2 to Python 3 "in a week" and just wants to do it.

Don't let this happen.

It is a bad idea because:

- If you let just the one person do all the work, none of the other team members will learn anything.
  They may miss out on essential knowledge about how `system2` works and won't be able to maintain it.
- The one-man may be just wrong.
  Maybe not wrong on a global level, but wrong for team.
  Rust may be a good language, but if the _team_ isn't ready to support a Rust codebase, then they shouldn't rewrite.

On the plus side, working solo can be very efficient!
Only on the most mechanical of migrations would I advocate for this approach.
Only when there is nothing really to be learned by doing the migration, when it is just kinda busy work.

**Better Way**: At the very least make the one person bring a junior engineer along for the ride!

A counterpoint to this bad idea is something I actually _like_ to see, where one person builds up a prototype (sometimes called a Spike or Tracer Bullet).
As long as these prototype are planned to be ["the one to throw away"](https://wiki.c2.com/?PlanToThrowOneAway), and the rest of the team helps swarm on the production version of that prototype, then I'm a fan.

## Bad Idea 4: Stacking Bets

"Stacking Bets" in this context means that you set up your big change (migration, rewrite, upgrade, etc.) upon another one that happens to be going on in the organization.

An example might be that you might bet your upgrade your python monolith from Python 2 to Python 3 _will stack upon_ an OS upgrade from Ubuntu 18.04 to Ubuntu 22.04, because you will do both together.
Often the other change you are stacking upon is doing by some other team.

On the surface it sounds fine, you might even convince yourself that you are getting something "for free".
You are not, and this stacking is a bad idea.

Here is why:

- Your timelines are now coupled.
  If one team has to delay or advance the thing you are stacked upon, you may be screwed.
- Your coupled changes but extra burdens on _both_ teams.
  The team doing the OS upgrade has to worry about breaking the team doing the Python 3 migration because they are getting it "For Free".
- They may be showstopping issues on _either_ upgrade that will hard block both.
  Now you both lose.
- Sometimes we stack bets for the wrong political reasons, because it feels good to "support" or "provide momentum" behind other organizational efforts.
  Same deal, you are not helping, you are hurting by coupling your timelines.

I've never seen this work.
It is just plain better to architect your change such that it is independent of any other changes.

> **Migration Tenet 2**: Try as hard as possible to keep all the potential blockers of your migration within your control.

## Bad Idea 5: Making Your Customers Do The Work

Not all migrations are simple OS upgrades.
Sometimes you really need to build a new thing with a new API.
`system2` is going to be new and great!

How are we going to get our customers to move from `system` to `systems2`?
Well we could write docs on how to migrate and let them move on their own time!
Make them do the work!

This is a terrible idea:

- Your customers usually have no incentive to move.
  They will drag their feet as long as possible.
- You will be violating the first tenet by making the time that your roman ride `system` and `system2` dependent on your customers.
  It could be centuries before you decommission `system`!
- While it may make the migration "easy" for your team, you are imposing an even larger burden on the whole org.

> **Migration Tenet 3**: Never make your customers do any work.

All the successful migrations I've seen involve the same team that builds `system2` be the team that does the hard legwork of moving customers over from `system` too.

## Bad Idea 6: Moving Your Biggest Customer Last

Even if you did figure out a way to build `system2` and perhaps set up some tooling to migrate customers one at a time.
You might be tempted to move your largest and biggest customer (or whatever thing `system` processes), _last_.

This is not a good idea. Even though saving your biggest customer for last seems like a good way to reduce risk, it does the **opposite**:

* Moving the biggest customer last to `system2` means you miss out on learning the weird ways that the biggest customer stretches `system`.
  For example, it may have the most records in a database, or the highest QPS, or the most disk space, who knows.
  If you had moved that biggest customer to `system2` _earlier_, you may have added fundamental architectural changes that are too late to do now!
* Your biggest customer may have been the one to benefit the most from `system2`'s new features, but they were last in line because of the migration strategy!
* Because the hardest is left for last, the lifetime of `system` has become unknowable.
  Maybe you will _never_ be able to migrate that biggest customer to `system2`, that would be a shame!

Ideally your migration plan doesn't involve moving customers at a time, but instead moves pieces of _functionality_ at a time, for _all_ customers.
But even if you must move things one customer at a time, try to front-load your biggest and most complex customer early, to ensure it is even possible to do it!
Then it will be smooth sailing moving all the simpler customers.

## Good Idea: "Strangler Fig Pattern"

Luckily, people more experienced than me have written entire books on how to migrate systems!

One of my favorite and easy-to-remember patterns for this is Martin Fowler's ["Strangler Fig Pattern"](https://martinfowler.com/bliki/StranglerFigApplication.html) (_not_ "Strangler Pattern").

The Strangler Fig tree is a strange tree.
It germinates at the top of a tree and then its roots descend, slowly enveloping the host tree:

[![Strangler Fig](/uploads/2024-12-08-howto-actually-migrate-systems/strangler_fig_tree.jpeg)](https://en.wikipedia.org/wiki/Strangler_fig#/media/File:Strangler_tree.jpg)

If it wasn't obvious, the Strangler Fig tree represents `system2`, while the host tree is `system`.

`system2` slowly envelops `system` by finding [seams](https://martinfowler.com/bliki/LegacySeam.html), and replaces all structure, including the trunk!

[![Strangler Fig Inside](/uploads/2024-12-08-howto-actually-migrate-systems/bald_cypress_with_strangler_fig_inside.jpeg)](https://en.wikipedia.org/wiki/Strangler_fig#/media/File:Corkscrew_-_bald_cypress_with_strangler_fig_inside.jpg)

This is how great migrations are done.
Slow and safe, with incremental progress.
_Not_ a big bang cutover and _not_ a huge rewrite.

For example, if you had a monolithic application running on bare metal that you wanted to get on the hype train and be on k8s + microservices, you might first set up a proxy and carve of a single endpoint and move that one portion of an application to the new stack, while the monolith lives on.
Use a feature toggle so that you can flip traffic on and off, gaining confidence that the new system works.
You would _not_ spend years rewriting the system and then point the whole application to it overnight.
You also would _not_ just set up a whole new website and ask your customers to update their browsing habits!

It is true that there is apparent waste with the [transitional scaffolding](https://martinfowler.com/articles/patterns-legacy-displacement/transitional-architecture.html) (the extra roots in this analogy) that are required to transition systems this way.
In order to pull this off you _must_ build some sort of transitional router or middleware to give yourself a space inject `system2`'s innards into `system`.
This scaffolding is discarded after `system` is fully decommissioned.
I assure you that this apparent waste is well worth the reduced risk compared to other approaches.

Let's apply these same principles apply to `system` and `system2`.
The evolution of `system` to `system2` starts with embedding tiny new parts of `system2` inside `system`, just like the Strangler Fig.
`system2` starts taking over different parts of the _functionality_ of `system`.
Notice that I didn't say **customers**.
Ideally things move over one piece of _functionality_ at a time, **not** one _customer_ at a time.
(It is fine to use eager customers to help beta test, but generally once things are going, _you_ drive the migration pace.)

Eventually, `system2` has kinda "vendored" in all the business logic from `system`, but with no architectural components of `system` are left.
For your customers, whatever API they were using, from their perspective, hasn't changed.
The `system2` API has subsumed the `system` API, or at least transmogrifies it.
Either way, your customers don't mind that this migration happened.

## Conclusion

For infrastructure systems, I think the Strangler Fig Pattern is the only sane way to migrate from one platform to another.
There is just too much risk to do it any other way.

`system` _becomes_ `system2` though incremental delivery and piecemeal functionality upgrades.
It does _not_ get there through a big rewrite and brute force migration.

To recap some core migration tenets:

> **Tenet 1**: Minimize the time you roman ride at all costs.

> **Tenet 2**: Try as hard as possible to keep all the potential blockers of your migration within your control.

> **Tenet 3**: Never make your customers do any work.

If you follow these tenets and use the Strangler Fig Pattern, your migrations will not be _easier_, but they will be less risky and less... dreadful.
Your engineers will thank you because they will see the light at the end of the tunnel when `system` is decommissioned instead of roman riding forever.
Your customers will thank you for ensuring business continuity and for not making them do any work.
