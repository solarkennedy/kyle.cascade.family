---
title: "The Kubernetes Pendulum?"
date: 2025-01-05
---

![The Kubernetes Pendulum](/uploads/2025-01-05-the-kubernetes-pendulum/pendulum.png)

## Mainframes

In the beginning was the mainframe and time-sharing systems:

![punchcards](/uploads/2025-01-05-the-kubernetes-pendulum/punchcards.jpg)

IT's job was to protect the sacred mainframe.
Time was money.

Users could humbly submit their stack of punch cards and wait for a response.

> Would I have asked for time on one of these mainframes? Absolutely.

## PCs

The PC revolutionized computing in the enterprise:

![The Business PC](/uploads/2025-01-05-the-kubernetes-pendulum/ibmpc.jpg)

Computing became more accessible.
You could have your own computer at your desk!

IT's job was to ... maintain countless PCs.
The support burden ballooned.
Later, as PCs proliferated, so did viruses, malware, and printer problems.
It sucked for IT.

But it was worth it.
Giving compute to people on their desk instead of the mainframe was a business multiplier.

> Would I have asked for my own PC? Absolutely.

## Servers

If you wanted to run some software on the new-fangled network, you could get a server:

![The Rack](/uploads/2025-01-05-the-kubernetes-pendulum/rack.jpg)

IT treated these servers kinda like a PC.
For the most part, IT ran the servers.

Sometimes you could get more freedom and responsibility and maintain it yourself.

> Would I have asked for my own Server? Absolutely.

**Note**: Around this time, the term `IT` started to not be cool, but I'll still be using it for the rest of this blog post to represent whatever team that is in charge of empowering its employees with technology.

## Virtual Machines

If you wanted a server to deploy software to, a new era came with the invention of virtual machines (VMs):

![VMware Screenshot](/uploads/2025-01-05-the-kubernetes-pendulum/vmware.png)

You could get servers in an instant, no need to wait for hardware provisioning.

And with the advent of VMs as a service ("Cloud"), another revolution began!

IT had to rethink how to manage these.
If you wanted to _enable_ your enterprise, you had to let go of the old "PC" model and instead shift into _vending_ VMs as a service.

_On-demand VMs for everyone!_

> Would I have asked for my own VMs? Yes

## Kubernetes

The next wave of computing enablement is upon us with Kubernetes (k8s):

![Kubernetes Screenshot](/uploads/2025-01-05-the-kubernetes-pendulum/kubernetes.jpg)

Combined with the "Cloud", one can get a k8s cluster in **seconds**, and use a new kind of packaging (Helm charts, etc) that enables the deployment of complex distributed systems.

It's so ~~simple~~ ~~easy~~ at hand!

This is all still new, but the current IT trend is to treat k8s clusters like we did with VMs: vend them out to our engineers to use.

_Self-service on-demand k8s clusters for everyone!_

> Would I ask for my own k8s cluster? .... No.

## What Makes It (k8s) Different This Time?

Kubernetes _feels_ different to me due to the sheer weight and complexity of a fully laden k8s cluster.
It isn't like a familiar PC with all your programs on it.
It isn't like a VM that is humming along running a mail server or a web server.

The (apparent) value _is_ the cluster configuration and capabilities itself.
And oh boy, a lot of configuration is required just to run [an app](https://artifacthub.io/packages/helm/bitnami/wordpress).
That complexity is [incidental](https://xkyle.com/The-Incidental-Complexity-of-Kubernetes/), and not inherent to the problem you are trying to solve.

Another way that k8s feels different is in the pace of things.
Kubernetes' releases are only supported for [14 months](https://kubernetes.io/releases/patch-releases/#support-period).
This is very different from running a VM using Redhat with support for ... [13 **years**](https://access.redhat.com/support/policy/updates/errata/#Overview).

A k8s cluster's configuration complexity dwarfs that of a VM.
Sure, you can mess up a VM or PC in many ways, but a k8s cluster can have oodles of moving parts (webhooks, objects, operators, etc.) that have spooky actions at a distance.
Don't forget the mountains of YAML configuration!

## Vending Kubernetes Clusters, Is It Good?

Good for whom?

Probably "good" for the user who wants to load up that cluster with a service mesh, some ingress controllers, some CSI storage drivers, some stateful sets, and more!

It sure feels good to unblock your developers!

But maybe it isn't good for the enterprise to enable this.

## Will The Pendulum Swing Back?

I think we might look back on this time and think how absurd it is that we have engineering teams (teams _other_ than centralized platform teams) administrating k8s clusters **at all**.

I think platform teams _believe_ they are providing a valuable service by vending k8s clusters for their users to have, but I think the long run this is a disservice to them.
I think what they actually need is a centralized cluster to run their apps, not a _decentralized_ k8s cluster free-for-all.

However, I would not bet on the pendulum swinging back away from k8s.
Just like the historical compute revolutions before it, I don't think we can go back.

![Old man yells at cloud](/uploads/2025-01-05-the-kubernetes-pendulum/oldmanyellsatcloud.jpg)

## But Kyle, YOU are IT, YOU Are The Bad Guy

I've been on both sides, as a consumer of IT and a producer.

I've been the guy who says NO and the guy who gets said NO to.

This is just the first time when I wouldn't be asking for it (k8s clusters) in the first place.

But I'm in the minority, and it is hard to stop the industry momentum.

![kubecon](/uploads/2025-01-05-the-kubernetes-pendulum/kubecon.jpeg)

## Conclusion

If giving out k8s clusters to engineers isn't the answer, what is?

Infra teams should run the clusters, not the end engineers.

Infra teams should be providing a good place for engineers to run their stuff, without the burden of managing compute clusters.
Give them services to consume (storage, compute, metrics, datastores), but don't make them run that themselves.

These vended k8s clusters are racking up tech debt in your enterprise, it's just a type of debt we haven't learned to recognize because it is in YAML form.
