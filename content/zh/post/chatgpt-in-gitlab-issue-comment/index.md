---
title: "将 ChatGPT 接入 GitLab Issue"
summary: "无需外网服务器与翻墙，即可在 GitLab Issue 中与 ChatGPT 畅聊"
authors: ["guoxudong"]
tags: ["GitLab", "ChatGPT"]
categories: ["GitLab"]
date: 2022-12-13T08:55:02+08:00
lastmod: 2022-12-13T08:55:02+08:00
draft: false
type: blog
image: "https://tva2.sinaimg.cn/large/ad5fbf65gy1h922ztce3yj20p00anwkv.jpg"
---
## 前言

<!-- markdown-link-check-disable-next-line -->
最近 [ChatGPT](https://chat.openai.com/chat) 着实是火了一把，一时间各种问题与回答充满整个朋友圈，大家玩的不亦乐乎。但由于网络的限制，很多人并不能注册和访问 OpenAI 网站，但这么好玩的东西我们怎么错过呢？本文就介绍一种在 GitLab Issue 中与 ChatGPT 聊天的方式，无需顾虑网络问题即可与 ChatGPT 畅聊！

## 预先准备

如果您只想和 ChatGPT 聊天，那么您仅需访问 https://gitlab.com/guoxudong.io/chatgpt-in-issue/-/issues/2 ，在该 Issue（或者新建的 Issue）中 Comment，ChatGPT 就会自动回复您的消息，效果如下：

![ChatGPT in Issue](https://tvax1.sinaimg.cn/large/ad5fbf65gy1h91zg84tv4j21ke0qiajd.jpg)

如果您想自己在 GitLab 中与 ChatGPT 进行聊天，那么你需要：

- 注册 [gitlab.com](https://gitlab.com) 账号
- 注册 [openai](https://openai.com) 账号

<!-- markdown-link-check-disable-next-line -->
> Tips：如果您希望使用 `Self-Manager`(自部署)版或者 `jihulab.com`，那么请确保您的 GitLab Runner 能正常访问到 https://api.openai.com

具体的注册方法我就不再赘述了，已经有很多文章在介绍如何注册了。

## 原理解析

实现的原理非常的简单，利用 [GitLab Comment Webhook](https://docs.gitlab.com/ee/user/project/integrations/webhook_events.html#comment-events) 触发运行 GitLab CI Pipeline，在 Pipeline Job 中调用 ChatGPT API 与 GitLab API 来完成提问的接收与回复。

也就是说您需要配置的只有 **GitLab Webhook** + **GitLab CI** + **ChatGPT**。

> 更多关于使用 Webhook 触发 Pipline，请阅读之前的文章[《GitLab 冷知识：使用 GitLab Webhook 触发 Pipeline》](https://guoxudong.io/post/gitlab-webhook-trigger-pipeline/)

## 操作步骤

那么现在我们就开始配置我们的 GitLab Project，让我们的 Issue comment 来自动回复吧！

### 创建 GitLab Project

可以新建一个 GitLab Project 或使用已有的 Project。

![创建 GitLab Project](https://tvax1.sinaimg.cn/large/ad5fbf65gy1h920vxligbj21u211ytjf.jpg)

### 配置 Pipeline Trigger

根据下面步骤获取 Webhook 触发令牌：

**Settings** -> **CI/CD** -> **Pipeline triggers** -> **Add trigger** -> **Copy Token**

![pipeline triggers](https://tvax4.sinaimg.cn/large/ad5fbf65gy1gzgnuzrauxj22fe0y0qfb.jpg)

### 配置 Webhook

**Settings** -> **Webhooks** -> **勾选 Comments**

在 **URL** 中插入： `https://GITLAB_HOST/api/v4/projects/PROJECT_ID/ref/REF_NAME/trigger/pipeline?token=TOKEN`

其中：
- **GITLAB_HOST** 为 GitLab 实例的域名，如：`https://jihulab.com`
- **PROJECT_ID**: 项目 ID
- **REF_NAME**: 分支名称
- **TOKEN**: 触发令牌，请将上一步中生成的 token 复制到这里

最后点击 `Add Webhook`

![Webhook](https://tva1.sinaimg.cn/large/ad5fbf65gy1h9214k52uzj21n012e13w.jpg)

### 获取 OpenAI API Token

登录并访问 https://beta.openai.com/account/api-keys 点击 `Create new secret key` 并复制生成的 Token。

![OpenAI API Token](https://tvax3.sinaimg.cn/large/ad5fbf65gy1h92170nvo6j21ei0xkb25.jpg)

### 获取 GitLab Access Token

<!-- markdown-link-check-disable-next-line -->
访问 https://gitlab.com/-/profile/personal_access_tokens 生成一个 access token 用于调用 GitLab API。

这里需要勾选 `api`。

![Access Token](https://tvax4.sinaimg.cn/large/ad5fbf65gy1h921cpwicnj21oe18kdzb.jpg)

### 配置 CI/CD Variables

现在就可以将获取的 Token 配置为 CI/CD Variables：

**Settings** -> **CI/CD** -> **Variables** -> **Add ariable**

将上文获取的 `OpenAI API Token` 和 `GitLab Access Token` 添加为 **Variables**，对应的 Key 分别为 `API_KEY` 和 `GITLAB_API_TOKEN`。

![CI/CD Variables](https://tva2.sinaimg.cn/large/ad5fbf65gy1h921bbqlxcj22ia1bghdu.jpg)

### 新增 .gitlab-ci.yml

前期准备工作已经差不了，现在只需创建 `.gitlab-ci.yml` 并提交以下内容：

```yaml
job:
  image: registry.gitlab.com/guoxudong.io/chatgpt-in-issue:latest
  script:
    - app
  only:
    - trigger
```

## Let's Chat

现在我们就可以在 Issue 中使用 comment 进行聊天了！开始我们开始快乐的聊天吧。本项目使用的源码均已上传，有兴趣的同学可以自行查看: https://gitlab.com/guoxudong.io/chatgpt-in-issue 。

![chat with chagpt](https://tva1.sinaimg.cn/large/ad5fbf65gy1h921o7czs9j21lq0no7aa.jpg)