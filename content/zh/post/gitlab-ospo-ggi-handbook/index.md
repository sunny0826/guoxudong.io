---
title: "使用 GitLab 协助 OSPO 快速构建 GGI Dashboard"
summary: "介绍如何使用 GitLab 为 OSPO 快速构建 GGI Dashboard"
authors: ["guoxudong"]
tags: ["OSPO", "GitLab"]
categories: ["OSPO"]
date: 2023-02-20T09:41:55+08:00
lastmod: 2023-02-20T09:41:55+08:00
draft: false
type: blog
image: "https://cdn.suuny0826.com/image/2023-02-20-20230220120940.png"
---
## 前言

成立 OSPO（开源办公室）旨在推动企业参与开源社区的活动，包括贡献代码、发布项目、参与治理等。OSPO 可以帮助企业提高开源技术的利用率，增强创新能力，建立良好的品牌形象和合作关系。OSPO 的主要职责有：制定开源战略、管理开源项目、培训和指导员工、维护社区关系、遵守法律和规范等。目前，国内外许多知名企业都设立了 OSPO，例如腾讯、阿里巴巴、华为、微软等。

GitLab 作为一个开源的软件开发平台，也支持企业建立和运营自己的开源项目办公室（OSPO），以推动开源文化和协作。OSPO 是一个专门负责管理和支持企业内外的开源活动的组织，可以帮助企业提高创新能力、降低风险、增加影响力。

为了帮助更多的企业建立和发展自己的 OSPO，GitLab 与 OSPO Alliance 合作，共同制定了一份名为 [GGI Handbook](https://ggi.ow2.io/my-ggi-onramp/)（Guide for Generating an OSPO）的指南。GGI Handbook 是一个基于 GitLab 的可部署实例，包含了一套完整的方法论和最佳实践，指导企业如何从零开始创建、运行和优化自己的 OSPO。GGI Handbook 还提供了一些实用的工具和模板，例如 OSPO 成熟度模型、OSPO 策略框架、OSPO 指标仪表盘等。

> GGI Handbook 是一个开放和协作的项目，欢迎任何对 OSPO 感兴趣或有经验的人参与贡献。你可以在 [GitLab](https://gitlab.ow2.org/) 上找到 [GGI Handbook](https://gitlab.ow2.org/ggi/ggi) 和 [My GGI Board](https://gitlab.ow2.org/ggi/my-ggi-board) 的项目页面，并通过提交 Issue 或 Merge Qequest 来提出建议或改进。你也可以加入 [OSPO Alliance](https://ospo.zone/) 的社区，与其他 OSPO 从业者交流经验和想法。

## GGI Handbook

GGI Handbook 是一本指导组织实施好的治理倡议（Good Governance Initiative）的手册。Good Governance Initiative 是一项旨在提高组织治理水平和透明度的计划，由 [OSPO Alliance](https://ospo.zone/) 发起。该手册提供了一套标准化的流程和工具，帮助组织评估自身的治理状况，制定改进措施，并分享最佳实践。该手册于2021年10月9日首次发布，于2022年11月8日更新了 [v1.1](https://ospo.zone/docs/ggi_handbook_v1.1.pdf) 版本，增加了手册的多语言翻译和快速部署功能。

GGI Handbook 根据一个组织可能寻求通过开源完成的各种目标定义了 25 项活动或最佳实践。活动包括 “开源技能和资源管理”、“软件依赖性管理”、“Upstream first” 和 “积极参与开源项目” 等建议。这些活动中的每一项都有相应的描述和理由，Handbook 还提供了成功实施这些活动需要的资源、工具和提示。

这些活动都是通用的，必须根据组织的实际情况进行灵活调整。GGI Handbook 还提供了记分卡，记分卡可以帮你评估你的组织在各种开源最佳实践中的参与情况与进展。

在将 GGI Handbook 应用与你的组织时，你需要：

1. 评估 Handbook 中提出的与 Open Source 有关的活动，并删除那些不适合你实际情况的活动（也许有些活动需要进行一些调整，以便与你的领域更加相关，而其他一些活动则可能被抛弃）
2. 识别那些最有利于实现你的组织参与开源的目标的活动
3. 为这些活动中的一小部分构建一个类似敏捷的迭代过程，以冲刺的形式进行，用记分卡跟踪你的进展，并根据你的当地环境、团队文化和可用资源调整活动
4. 在每个迭代结束时，回顾你的团队已经完成的活动，选择一个新的改进范围，并重复这个过程

[My GGI Board](https://gitlab.ow2.org/ggi/my-ggi-board) 项目提供了一个开箱即用的 GGI Dashboard，下面我们就花一点时间，在 GitLab 上部署它。

## 快速开始

My GGI Board 项目的 README 中详细的说明了如何快速开始，等不及的朋友可以直接查看该项目的说明。

> GitLab 实例要求开启 Pipelines 和 Pages 服务，在 gitlab.com 上可以免费尝试。

### 导入项目

直接在你的 GitLab 实例中创建一个新项目，选择 `Import project` -> `From repository by URL`，填入 My GGI Board 项目地址 `https://gitlab.ow2.org/ggi/my-ggi-board.git`（如何网络缓慢，你也可以导入极狐 Mirror 的项目地址 `https://jihulab.com/ospo/my-ggi-board.git`，这个 Mirror 是实时更新的），配置完成后点击 `Create project` 即可。

### 创建 Access Tokens

接下来需要为后续的自动化操作配置一个 Access Tokens。这里推荐 `Project Settings` -> `Access Tokens` 来创建 Access Tokens，但该功能需要购买 GitLab 专业版，如果你的 GitLab 实例为社区版，则可以使用 Personal Access Tokens 代替，使用效果是一样的。

选择 `Maintainer` 角色并勾选 `api`。

![Access Tokens](https://cdn.suuny0826.com/image/2023-02-20-20230220111550.png)

> 创建 Access Tokens 后，请将其复制到安全的地方，因为一旦关闭这个页面**您将永远无法再看到它**

之后将生成的 Access Tokens 添加入 `Project Settings` -> `CI/CD` -> `Variables` 中，Key 的名称为 `GGI_GITLAB_TOKEN`。

![CI/CD Variables](https://cdn.suuny0826.com/image/2023-02-20-20230220112020.png)

### 运行 Pipeline

现在所有的准备工作就都结束了，接下来 `CI/CD` -> `Pipelines` -> `Run pipeline` 运行 CI/CD，完成 My GGI Board 的初始化配置。

![Pipeline](https://cdn.suuny0826.com/image/2023-02-20-20230220112358.png)

## Welcome to your GGI Dashboard

Pipeline 运行成功后，你的 GGI Board 就已经准备就绪了！

### Issues Boards

`Issues` -> `Boards` 就可以看到全部 25 个创建好的活动，所有的活动都使用 Labels 做好了分类，点击进入可以看到更详细的说明。

![Boards](https://cdn.suuny0826.com/image/2023-02-20-20230220113008.png)

你可以根据这些说明以及实际情况，灵活的调整所有的活动，修改和删除那些和你组织的实际情况不符的活动。

![Details](https://cdn.suuny0826.com/image/2023-02-20-20230220113218.png)

### Dashboard

当然所有的这些活动也会以网页的形式托管在 GitLab Pages 上的静态网站上，这个 Dashboard 会在每天晚上根据 Issues Boards 自动生成相关活动的运行情况并更新网站，如果您行增加或减少自动更新的频率，可以在 `CI/CD` -> `Scheduled` 中进行调整。

![Activities page](https://cdn.suuny0826.com/image/2023-02-20-20230220115012.png)

> 这个页面是自动部署的，地址你可以在 `Project description` 中找到，比如说我部署的 Dashboard 地址就是：<http://guoxudong.io.gitlab.io/my-ggi-board>

![Project description](https://cdn.suuny0826.com/image/2023-02-20-20230220115252.png)

随着项目及其 Issue 的更新，您的 OSPO 静态网站将定期更新以反映活动、任务和总体进度的当前状态。例如，一段时间后，仪表板可能如下所示：

![Dashboard](https://cdn.suuny0826.com/image/2023-02-20-20230220115120.png)

## 结语

希望这个项目能帮助到正着手建立组织的开源项目办公室（OSPO）的你，希望可以有越来越多的组织建立和运营自己的 OSPO，共同推动开源文化和开源协作的发展。

Demo 地址：

- Project: <https://gitlab.com/guoxudong.io/my-ggi-board>
- Dashboard: <https://guoxudong.io.gitlab.io/my-ggi-board>

## 参考

- [Start an open source center of excellence in 10 minutes using GitLab - about.gitlab.com](https://about.gitlab.com/blog/2023/01/30/how-start-ospo-ten-minutes-using-gitlab/)
- [Good Governance Initiative - ospo.zone](https://ospo.zone/ggi/)
