---
title: "GitLab 冷知识：使用 Email 也可以创建 Issue？"
summary: "Gitlab 使用 Incoming Email 来操作 Issue 和 MR"
authors: ["guoxudong"]
tags: ["GitLab", "DevOps"]
categories: ["GitLab 冷知识"]
date: 2022-02-28T16:45:07+08:00
lastmod: 2022-02-28T16:45:07+08:00
draft: false
type: blog
image: https://cdn.suuny0826.com/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg
---
## 前言

在使用 GitLab 时，创建 Issue 和 Merge Request 的方法，除了常规的使用 GitLab Web UI 进行操作和通过 API 调用操作，还有一些比较好玩的，比如使用 Email 来创建。

## Incoming email
<!-- markdown-link-check-disable-next-line -->
如果是 Self-Manager 的 GitLab 用户，在使用前需要配置，具体的配置方法和要求详见[官方文档](https://docs.gitlab.com/ee/administration/incoming_email.html#incoming-email)。本文采用[极狐 GitLab SaaS 平台](https://jihulab.com/)进行展示。

### New Issue by email

使用 email 来创建 Issue 要求项目内至少存在一个 Issue，而操作者至少需要具有 `Guest` 权限。

进入项目页面选择 **议题** -> **通过电子邮件创建新的 议题** 就可以得到一个 email 地址，**copy** 该地址都即可用于发送 email。

这个地址中包含用户私人令牌，请勿泄露给他人，否则将会获得您创建 Issue 和 MR 的能力（下图令牌已重置），如果泄露点击 **重置这个令牌** 即可。

![create issue](https://cdn.suuny0826.com/large/ad5fbf65gy1gztcdrisgij219y0js44m.jpg)

在 Email 中，email 主题将作为 Issue 的标题，而信息则作为 Issue 的内容，在内容中用户可以使用 [Markdown](https://jihulab.com/help/user/markdown) 和上一篇文章提到的 [Quick Actions](../gitlab-quick-actions/) 来操作 Issue 完成更多任务，非常方便。

### New merge request by email

与 Issue 类似，您可以通过向 GitLab 发送 email 来创建合并请求，进入项目页面选择 **合并请求** -> **通过电子邮件创建新的 合并请求** 就可以得到一个 email 地址。

合并请求目标分支是项目的默认分支，其他操作与创建 Issue 类似。

![create mr](https://cdn.suuny0826.com/large/ad5fbf65gy1gztcxhid3kj21a60jgwks.jpg)

## 结语

正如我在[《由一封邮件看 Mailing List 在开源项目中的重要性》](https://guoxudong.io/post/kubernetes-client-python/)中所说使用 email 交流在很多社区的交流中具有很重要的位置。和 email 有关的功能还有 [Reply by Email](https://docs.gitlab.com/ee/administration/reply_by_email.html) 和 [Service Desk](https://docs.gitlab.com/ee/user/project/service_desk.html) 这里就不做详细介绍了，有兴趣的朋友可以移步[官方文档](https://docs.gitlab.com/ee/administration/incoming_email.html)，体验更多内容。