---
title: "GitLab 冷知识：妙用 Badge 徽章"
summary: "在 Gitlab 中使用 Badge"
authors: ["guoxudong"]
tags: ["GitLab", "DevOps", "开源"]
categories: ["GitLab 冷知识"]
date: 2022-05-26T16:13:31+08:00
lastmod: 2022-05-26T16:13:31+08:00
draft: false
type: blog
image: "https://tvax1.sinaimg.cn/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg"
---
## 前言
<!-- markdown-link-check-disable -->
在前一篇文章 [《GitLab 冷知识：如何美化 issue 内容》](../gitlab-beautify-issue/#自定义-badge) 中就有介绍**自定义 Badge**的使用方式。实际上 GitLab 本身就提供了一些实用的 Badge 以及专门的 Badge 展示位置和配置，本文就介绍一些 GitLab 自带 Badge 的使用以及一些 Badge 的妙用。

## Badge 设置

与 GItHub 只能在 `README` 中，以 Markdown 形式展示 Badge 不同，GitLab 的 Project 页面，留有专门的 Badge 展示位。这样用户打开 Project 页面，无需再继续滑动到 `README` 内容，映入眼帘的就是醒目的 Badge。

![project page](https://tvax3.sinaimg.cn/large/ad5fbf65gy1h2lwgsf9tgj20ye0hcgow.jpg)

其设置方式也十分简单：**Settings**->**General**->**Badges**，根据要求依次填入名称、链接和徽章图片网址，即可看到 Badge 预览，如果这个 Badge 样式符合您的预期，点击 **Add badge** 即可将其添加到您的 Project 首页。同时还提供了[变量](https://jihulab.com/help/user/project/badges)以供用户填入通用值，这里的 Badge 也是可以展示 [shields.io](https://shields.io/) 中各种自定义 Badge 样式的。

![settings](https://tva1.sinaimg.cn/large/ad5fbf65gy1h2lwlcpxq2j21ie0tkjy0.jpg)

## 常用 Pipeline badges

除了在 Project 页面配置和展示 Badge，GitLab 还提供了三种内置的 Pipeline badges，它们分别是：**Pipeline status**、**Coverage report**、**Latest release**。

开启方式也很简单：**Settings**->**CI/CD**->**General pipelines** 然后下滑滚轮即可看到三个已经贴心配置好并提供了 `Markdown`、`HTML`、`AsciiDoc` 三种格式的 Badges。

![Pipeline badges](https://tva3.sinaimg.cn/large/ad5fbf65gy1h2lwv97udwj226u18wkit.jpg)

### 配置 Coverage report

以上三种 Badge 中，只有 Coverage 需要进行额外的配置，需要在 Pipeline 中运行 coverage 并在对应 CI Stage 增加 [`coverage` 字段](https://docs.gitlab.cn/ee/ci/yaml/index.html#coverage)。

下面就以 GO 为例，讲解一下如何使用该字段：

```yaml
...
Coverage:
  stage: coverage
  coverage: \d+.\d+% of statements
  script:
    - go test -coverprofile=coverage.out ./...
...
```

这里的 `coverage` 内容是一个正则表达式，用来匹配 coverage 覆盖率的值，不同语言有不同的正则表达式，可以参考[这个文档](https://docs.gitlab.cn/jh/ci/pipelines/settings.html#%E6%B5%8B%E8%AF%95%E8%A6%86%E7%9B%96%E7%8E%87%E7%A4%BA%E4%BE%8B)。逻辑上 `coverage` 只是抓取了对应 CI Job 的 Log 值并通过正则表达式将其提取出来，如果您打印的值格式是自定义的，就需要调整 `coverage` 中的正则表达式。

> 关于 Coverage，GitLab 还提供了一些增强功能来帮助 Merge Request 和 Code Review，后续会专门进行介绍。

当 Coverage 正常运行了，Badge 相应的内容就可以正常展示了。

## 动态 Badge

细心研究过 [shields.io](https://shields.io/) 的同学肯定知道其提供了很多关于 GItHub 的 Badge，如 GItHub Open Issue 数量、PR 数量等。但是对于 GitLab 的支持却非常的少，不过我们可以根据其提供的 `Dynamic` 也就是动态功能配合 GitLab 的 API 在 GitLab 上实现相同的效果。

![shields](https://tva4.sinaimg.cn/large/ad5fbf65gy1h2lxqsbyg0j21rk0aidp0.jpg)

以 Open Issue 数为例，首先找到 GitLab 相应的 API：[Get issues statistics](https://docs.gitlab.com/ee/api/issues_statistics.html)，使用 `Curl` 测试一下其返回值：

```shell
# 13953 是 gitlab-cn/gitlab 的 project id
$ curl "https://jihulab.com/api/v4/projects/13953/issues_statistics"
{"statistics":{"counts":{"all":882,"closed":531,"opened":351}}}
```

之后只需使用 `jsonpath` 来获取 `opened` 中的值即可，可以使用 [jsonpath.com/](https://jsonpath.com/) 来进行调试。通过调试得出其 `query` 表达式为 `$.statistics.counts.opened`，现在就可以将  `label`、`data-url`、`query` 和 `color` 填入并点击 **Make Badge** 按钮即可生成。

![Dynamic](https://tva2.sinaimg.cn/large/ad5fbf65gy1h2lxmyt6m0j21r40b6481.jpg)

Markdown:
```markdown
![Issue Num](https://img.shields.io/badge/dynamic/json?color=9cf&label=issues&query=%24.statistics.counts.opened&suffix=%20opened&url=https%3A%2F%2Fjihulab.com%2Fapi%2Fv4%2Fprojects%2F13953%2Fissues_statistics)
```
Badge：
![Issue Num](https://img.shields.io/badge/dynamic/json?color=9cf&label=issues&query=%24.statistics.counts.opened&suffix=%20opened&url=https%3A%2F%2Fjihulab.com%2Fapi%2Fv4%2Fprojects%2F13953%2Fissues_statistics)

## 结语

Badge 在实际生产活动中用处不大，但对于开源项目却有着不同的效果，它可以帮助新成员和维护者快速了解到一些关键信息，同时也有一些美化文档的作用，推荐感兴趣的朋友在自己的开源项目中使用。
<!-- markdown-link-check-enable -->
