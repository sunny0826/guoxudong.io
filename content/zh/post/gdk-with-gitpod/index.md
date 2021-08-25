---
title: "Gitpod 配合 GDK 随时随地开发 GitLab"
summary: "GDK 配合 Gitpod 使用，开发者完全不需要担心本地环境、项目依赖和终端的性能，直接在云上运行配置好的开发环境，快速参与到项目贡献当中。"
authors: ["guoxudong"]
tags: ["GitLab","工具"]
categories: ["GitLab"]
date: 2021-08-25T11:11:51+08:00
lastmod: 2021-08-25T11:11:51+08:00
draft: false
type: blog
image: "https://tva3.sinaimg.cn/large/ad5fbf65gy1gtt9lieoqqj21j10z942u.jpg"
---
## 前言

对于开发者而言，最痛苦的莫过于接手新项目，搭建新的开发环境，我们不得不处理各种工具的版本、依赖冲突以及一些未知问题。越复杂的项目搭建开发环境所需的时间越多，有时还会由于开发终端的芯片架构、系统版本等原因，导致无法运行特定开发环境。

## GitLab Development Kit (GDK)

对于开源软件来讲，困难的开发环境搭建带来的直接影响就是潜在项目贡献者的流失以及随之而来贡献者的减少。为此各个开源项目都在尝试解决这个问题，就比如 GitLab 就专门为开发者开发了一个工具包 [GitLab Development Kit (GDK)](https://gitlab.com/gitlab-org/gitlab-development-kit/-/tree/main) 用来帮助 GitLab  Team Member 和社区贡献者快速的搭建和启动一整套 GitLab 的开发环境。

## Gitpod

正如我前不久翻译的文章[《开发环境即代码》](https://guoxudong.io/post/dev-env-as-code/)所述，Gitpod 以 Serverless Function 的方式，将开发环境的配置、生成和销毁通过包含完整 IDE 终端的 Docker 镜像运行，以**自动化**、**可复用**和**版本化**的方式来管理开发环境。从而简化了开发环境的搭建和运行，用户只要有一台可以联网的终端（甚至可以是手机或平板电脑）即可参与开发，极大的降低了参与项目的门槛。

## GDK + Gitpod

GDK 配合 Gitpod 来使用，开发者完全不需要担心本地环境、项目依赖和终端的性能，直接在云上运行配置好的开发环境，快速参与到项目贡献当中。

### 如何开始

如果您是极狐 GitLab 团队成员：

- 打开 [GitLab 项目页面](https://gitlab.com/gitlab-jh/gitlab)
- 点击 `Gitpod` 按钮，如果没有该按钮则需在 [Preferences](https://gitlab.com/-/profile/preferences) 中开启 Gitpod 集成

![集成](https://tvax3.sinaimg.cn/large/ad5fbf65gy1gtt7hqt9stj21lk0da76v.jpg)

如果您是社区贡献者：

- Fork [GitLab 项目代码库](https://gitlab.com/gitlab-jh/gitlab)
- 在 Fork 的项目中点击 `Gitpod` 按钮

![Gitpod按钮](https://tvax3.sinaimg.cn/large/ad5fbf65gy1gtt7d5y8hbj22xs1fu4qp.jpg)

如果您从未使用过 Gitpod，则需要：

- 创建一个 Gitpod 账户
- 可以直接使用 GitLab 来登录 Gitpod 来完成集成

Gitpod 免费为用户提供了每月 50 个小时的使用时长，可以放心使用。

### 开发调试

在完成上述步骤后，等待 7 到 8 分钟，就可以看到完整的 IDE UI 了，Gitpod 提供 IDE UI 为 VSCode，不过也提供了 Theia（已弃用），以及 Light 和 Dark 两种 UI 主题。熟悉 VSCode 的同学对下面这个界面一定不会陌生。

![](https://tva1.sinaimg.cn/large/ad5fbf65gy1gtt8lhsemyj216o0mjdun.jpg)

不过这时 GDK 还没有启动完毕，这时访问 GitLab Web 页面会显示 `504 Gateway Time-out`，耐心等待一会儿，当终端如上图所示那样，GDK 就正常启动了，这时就配合代码就可以登录 GitLab，并开始开发和调试了。

> Tips：GDK 启动的 GitLab 默认用户为 `root`，密码为 `5iveL!fe`，首次登录需要修改密码。

## 结语

GitLab 最新版本 `14.2` [与 Gitpod 进行了更深度的集成](https://about.gitlab.com/releases/2021/08/22/gitlab-14-2-released/#launch-a-preconfigured-gitpod-workspace-from-a-merge-request)，现在可以在 MR 中直接打开该分支的代码，在云上对运行效果进行 Review，十分方便。

![](https://tva4.sinaimg.cn/large/ad5fbf65gy1gtt96u0pzgj21d90hgjxp.jpg)

GDK + Gitpod 将开发者的体验放在了首位，提供了快速、安全且易于销毁的开发环境，完美解决了本地开发中遇到的各种难题，实现了我 **随时随地都能 Coding** 的愿望。

更多内容：

- [Gitpod 文档](https://www.gitpod.io/docs/)
- [GDK 命令文档](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/gdk_commands.md)