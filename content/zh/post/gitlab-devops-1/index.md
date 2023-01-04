---
title: "重新认识 GitLab | 基础篇"
summary: "用了这么多年 Gitlab，可能还不了解这些知识"
authors: ["guoxudong"]
tags: ["devops","GitLab"]
categories: ["GitLab"]
date: 2021-06-03T16:53:31+08:00
lastmod: 2021-06-03T16:53:31+08:00
draft: false
type: blog
image: http://rnxuex1zk.bkt.clouddn.com/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg
---

## 背景

作为一款著名的代码管理平台，GitLab 凭借强大的功能、活跃的社区和完全开源的策略，使其成为众多企业代码托管平台的首选。但正如其官网 Slogan - **GitLab is the open
DevOps platform**，GitLab 并非只是一个代码管理平台，还是一个开源 DevOps 平台，从项目管理、代码托管到 CI/CD 、制品仓库及安全合规，甚至还有发布后的分析和监控功能，实现了整个 DevOps 流程的闭环。

但在实际使用中，GitlLab 中有很多组件和功能并没有被很好的使用，很多团队只是使用了其代码管理功能，在 Google 搜索 *GitLab 教程*，搜到的都是一些安装配置或介绍 GitLab CI 的教程，并没有一篇文章去介绍 GitLab 的核心组件和基本概念，而这些内容对于一个初学者往往是最重要的。

## 核心组件

虽然大家都在使用 GitLab，但大多数企业还是会另外使用像 Jira 或是禅道这样的产品来进行项目管理，其实 GitLab 本身的项目管理能力就十分强大。下面的这些组件，在工作中经常可以见到，但其中的一些组件很大一部分人都没有用过。下面我会把这些组件列出来，在讲解其功能的同时，还会列出在其他产品（如 GitHub、Jira 等）中与其类似的概念。

### Group（群组）

Group 是一组 Project 的集合，形式类似于文件夹。但其与 GitHub 中的 Organization 是不同的，因为 Organization 的再下一级只能是 Repository，也就是 GitLab 中的 Project，而 Group 下面是允许存在 Sub Group 的，这更符合企业较复杂的组织架构，权限也更好分配。

**类似概念**：Project

### Project（项目）

Project 是 GitLab 的核心组件，是最基础的模块，除了保存代码以外，还是管理、交付和协作的核心构建块。

**类似概念**：Repository

### Issue（议题）

Issue 是 Project 的一部分，它也是整个 DevOps 工作流的起始。在 Issue 中可以记录需求、讨论实现、估算工作量、跟踪项目进度、分配工作等，通过不同的标签（label）来管理整个进度。
注意：GitLab 中的 Issue 是有 Group 和 Project 两个维度的，可以跟踪不同维度的流程。

**类似概念**：Story、Narrative、Ticket

### Merge Request（MR，合并请求）

MR 连接 Issue 和实际代码的变化，包括：设计、实现细节（code change）、讨论（code review）、审批、测试（CI Pipeline）和安全扫描，是 DevOps 流程中非常重要的一环。

**类似概念**：Pull Request（PR）

### Label（标签）

用于标记和追踪 Project 或 Group 的工作，并将 Issue 与不同的 initiatives 联系起来。

**类似概念**：Tag

### Epic（史诗）

一组拥有相同主题位于不同 Group 和 Project 的相关 Issue。

**类似概念**：initiatives、Themes

### Board（面板）

Project 和 Issue 的可视化列表、有助于管理积压的团队工作，确定项目优先级，并将 Issue 移动到 Group 或 Project 的特定阶段。

**类似概念**：Kanban

### Milestone（里程碑）

一个 Sprint 或（多个）deliverable，帮助你把代码、Issue 和 MR 组织成一个整体。

**类似概念**：Release

### Roadmap（路线图）

将各种 Epic 进行可视化展示，以非常清晰状态来展现所有 Epic 的状态和进度。

![Roadmap](http://rnxuex1zk.bkt.clouddn.com/large/ad5fbf65gy1gr576t79ljj22yi1d0nc0.jpg)

## 项目组织结构

使用 GitLab 进行项目管理，首先需要了解的就是如何合理的组织项目，不同于 GitHub 中的 organization 的下一级只能是 repo，GitLab 中的 Group 可以有 Sub Group 也就是子组的存在，这对于企业的组织架构来说更加灵活，可以非常方便的展示组织和项目之间的从属关系，和更精细的权限管理，再配合 Epic 和 Roadmap 清晰的了解项目当前的进度。

![组织结构](http://rnxuex1zk.bkt.clouddn.com/large/ad5fbf65gy1gr60mk43erj20mi0deqch.jpg)

## Workflow 最佳实践

GitLab 推荐使用 Issue 并配合 Label 完成整个 DevOps 工作流，在体验上与 GitHub 上的操作类似，但在企业内部团队协作方面 GitLab 做的更加精细。以 Issue 为起点，通过添加和删除不同 Label 进行协作，不同的 Label 可以代表不同的**团队**、**阶段**、**环境**以及一些特定需求（如需要技术文档团队或营销团队接入）；在不同阶段不同的团队介入开发，完成后提交 MR（合并请求）并运行 CI Pipeline 和 review，通过不同环境的 CI 直到最终审核通过；接下来就是合并触发 CD Pipeline 完成发布并关闭 Issue。之后是监控和分析的接入，然后开启下一轮的 DevOps 工作流。

![gitlab workflow](http://rnxuex1zk.bkt.clouddn.com/large/ad5fbf65gy1grawt8qrklj22yk1nuhdt.jpg)

## 结语

在了解了这些基本组件和知识后，GitLab 作为一体化 DevOps 平台的面纱才会徐徐展开。为什么 GitLab 会介绍自己是 **A Single Application delivering the Full DevOps Lifecycle**，在本系列文章中都会有详细说明，敬请期待。
