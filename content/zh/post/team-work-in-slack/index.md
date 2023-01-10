---
title: "团队使用 Slack 技巧"
summary: "本文介绍团队使用 Slack 进行协作的一些技巧"
authors: ["guoxudong"]
tags: ['远程办公', 'slack']
categories: ['远程办公']
date: 2021-07-14T15:30:12+08:00
lastmod: 2021-07-14T15:30:12+08:00
draft: false
type: blog
image: https://cdn.suuny0826.com/large/ad5fbf65gy1gsgm25e4t2j20p00anwfl.jpg
---
## 前言

对于一个开源人来说，Slack 是绕不过的一款即时通讯工具。当一些 Issue 需要更详细的描述，或者有实时交流需求时，很多开源项目的维护者和用户往往都会使用 Slack 来进行沟通的，所以笔者对 Slack 还是十分熟悉的。但当身处一个全员 remote 团队，技术、业务和其他团队都要求使用 Slack 进行沟通和交流时，自认 Slack 老炮的笔者，却发现很多之前完全不了解的关于团队使用 Slack 的技巧。

故本文将会介绍一些在团队中使用 Slack 的技巧，不含任何选型建议，只是为其他用户提供一些使用参考。

## Channel 命名很有讲究

Channel 也就是 Slack 里的频道，作用类似于微信中的群的概念，不过加入 Channel 的用户可以看到该 Channel 之前全部讨论的上下文，这使得用户可以通过上下文了解到之前的信息，避免了重复沟通。

同时，每个团队、每次活动甚至每个专项交流都建议使用单独专用的 Channel，这样可以使得所有讨论、记录和文件都保存在该 Channel 中，集中所有相关信息。这使得信息不再分散在多个群中，提高了信息检索速度和传递效率。

但这样做会带来一些问题，就是存在过多的 Channel，大家应该都明白工作群多了之后会有多么的麻烦。这时，约定一套 Channel  的命名规则就变的很有必要了，这不但可以很好的保持  Channel 的主题，还加快检索 Channel 的时间，下图是 Slack 官方建议的  Channel 命名规则。

![Channel 命名建议](https://cdn.suuny0826.com/large/ad5fbf65gy1gsgjsqr6ymj21880t07fs.jpg)

## #general 中的信息很重要

Slack 每个 WorkSpace 在创建时，都会默认创建一个名为 `#general` 的 Channel，并且每个加入 WorkSpace 的用户都会默认加入该 Channel。这个 Channel 一般用来发布一些组织或者公司级别的重要信息和通知。建议管理员将该 Channel 的发布权限设置为某些成员，以确保公告不被其他信息淹没。

相反 `#random` Channel 也是全体成员默认加入的，但这个 Channel 中的信息主要是和工作无关的一些信息，我司的同学就喜欢在这个 Channel 中晒自己的萌宠。如果觉得这个 Channel 打扰到了您的工作，将其设置静音即可。

![#random Channel](https://cdn.suuny0826.com/large/ad5fbf65gy1gsgkx5uz8qj20p20qye2f.jpg)

## Reply in thread 使交流更专注

除了通过 Channel 来划分讨论主题以外，Reply in thread（在消息列中回复）的功能是我认为非常好的一个功能。因为 Channel 的粒度还不够细，在 Channel 中进行的讨论往往有一个共同的主题，但同一主题也会有各种不同问题需要沟通。这时，Reply in thread 也就是在一条消息下单独开启一个 Thread 进行沟通，既不会影响整体讨论上下文的连贯，又可以专注于单一的问题，希望对该问题进行沟通的用户点开 Thread 进行沟通，不关心该问题的用户也不会被该问题的讨论影响了消息的连贯性，非常 Nice。

![](https://cdn.suuny0826.com/large/ad5fbf65gy1gsgoatvc9bj214o0wijzf.jpg)

## emoji 的妙用

emoji 也就是表情符号，基本所有即时聊天软件中都有的功能。但在实际使用中，尤其是在通知到一些令人振奋的好消息时，往往会出现以下场景（聊天群中充斥着 👍）。

![](https://cdn.suuny0826.com/large/ad5fbf65gy1gsgl4n120ej20kk0hmdgb.jpg)

这虽然表示了大家的喜悦之情，但是这会淹没大量的有用信息，使查找讨论和记录变的十分困难。所以在 Slack（以及其他办公通讯软件中），建议使用在单条消息后添加 emoji 来表示类似情感，这其实也广泛应用于 GitHub 和 GitLab 的 Issue 中。

![](https://cdn.suuny0826.com/large/ad5fbf65gy1gsgl7wd9iaj21880hu45f.jpg)

这么做不但没有破坏消息的上下文完整性，同时还能通过 emoji 传达出更多的信息。

![](https://cdn.suuny0826.com/large/ad5fbf65gy1gsglbo7cewj21880f0jwi.jpg)

## 集成其他应用

Slack 还有一个不错的功能在于他可以集成其他应用，如笔者就集成了 Google Calendar、Google Drive 和 Zoom 等应用。Slack 会根据 Google Calendar 中将要到来的日程安排进行提醒，这对远程办公的笔者来说十分重要；而集成 Zoom 则可以通过一行命令 `/zoom` 快速创建会议，十分方便。

![zoom 命令](https://cdn.suuny0826.com/large/ad5fbf65gy1gsglk59e1cj21580luace.jpg)

### ChatOps

早在 19 年笔者就开始使用 Slack 和 钉钉等应用进行 ChatOps 来完成一些基础设施运维工作，其实现就是通过 webhook 或其他技术来触发自研应用进行资源的巡检、混沌实验、云资源的创建和清理以及一些团队管理工作。不过这些内容和本文主题互关，相关内容会在后续分享。

## 结语：工具只是工具

对于一个全员远程办公的团队，一款合适的即时通讯软件十分重要。但工具只是工具，真正使用工具的是人。通过上文这些内容不难看出，**共识比功能更重要**。当大家都按照相同的共识进行团队合作，哪怕没有工具，效率都会高上不少。

## 参考

- [Your guide to working remotely in Slack](https://slack.com/intl/en-tw/resources/using-slack/slack-remote-work-tips)
