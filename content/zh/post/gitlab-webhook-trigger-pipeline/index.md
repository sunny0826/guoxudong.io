---
title: "GitLab 冷知识：使用 Gitlab Webhook 触发 Pipeline"
summary: "除了 push，还有很多方法可以出发 Gitlab Pipeline"
authors: ["guoxudong"]
tags: ["GitLab", "DevOps", "自动化", "CI/CD"]
categories: ["GitLab 冷知识"]
date: 2022-02-17T17:45:46+08:00
lastmod: 2022-02-17T17:45:46+08:00
draft: false
type: blog
image: http://rnxuex1zk.bkt.clouddn.com/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg
---
## 前言
<!-- markdown-link-check-disable -->
新年新气象，本年度新开一个系列，介绍那些 GitLab 中比较冷门却十分好玩的功能，本篇为该系列开篇。

GitLab 提供了非常丰富事件以及 Webhook，这项功能常被用于与其他系统集成。事实上，GitLab 的 Webhook 也可以用来触发 GitLab CI 并运行 Pipeline 的，这只需一些简单的配置。

## Step By Step

首先需要选择一个 Project，新建或者现有项目都行，推荐使用[极狐GitLab](https://jihulab.com/)，运行 CI 和触发 Webhook 的项目理论上可以是两个 Project，但为了管理和配置方便，这里推荐使用一个 Project。

### 获取 Webhooks 触发令牌

根据下面步骤获取 Webhook 触发令牌：

**设置** -> **CI/CD** -> **流水线触发器** -> **添加触发器** -> **复制触发令牌**

![pipeline triggers](http://rnxuex1zk.bkt.clouddn.com/large/ad5fbf65gy1gzgnuzrauxj22fe0y0qfb.jpg)

### 配置 Webhook

**设置** -> **Webhooks** -> 选择想要触发 Webhook 的事件进行勾选

在 **URL** 中插入： `https://GITLAB_HOST/api/v4/projects/PROJECT_ID/ref/REF_NAME/trigger/pipeline?token=TOKEN`

其中：
- **GITLAB_HOST** 为 GitLab 实例的域名，如：`https://jihulab.com`
- **PROJECT_ID**: 项目 ID
- **REF_NAME**: 分支名称
- **TOKEN**: 触发令牌

最后点击 `Add Webhook`

![webhook](http://rnxuex1zk.bkt.clouddn.com/large/ad5fbf65gy1gzgnwxwevsj22ci15kh3o.jpg)

### 修改 .gitlab-ci.yml

完成以上步骤，在出现相应事件时，就会触发 Webhook 并向指定 URL 发送请求，接下来介绍如何处理 Webhook 请求。

首先要确定 Webhook 的 CI 触发类型 `trigger`，在 `.gitlab-ci.yml` 文件中可以通过以下配置筛选触发类型：

```yaml
job:
  ...
  only:
    - trigger
```

除了 `only` 关键字之外，还可以使用 `rules` 关键字配合 `$CI_PIPELINE_SOURCE` 环境变量来使用，参考下表：

| `$CI_PIPELINE_SOURCE` value | `only`/`except` keywords | Trigger method      |
|-----------------------------|--------------------------|---------------------|
| `trigger`                   | `triggers`               | In pipelines triggered with the [pipeline triggers API](https://docs.gitlab.com/ee/api/pipeline_triggers.html) by using a [trigger token](https://docs.gitlab.com/ee/ci/triggers/index.html#create-a-trigger-token). |
| `pipeline`                  | `pipelines`              | In [multi-project pipelines](https://docs.gitlab.com/ee/ci/pipelines/multi_project_pipelines.html#create-multi-project-pipelines-by-using-the-api) triggered with the [pipeline triggers API](https://docs.gitlab.com/ee/api/pipeline_triggers.html) by using the [`$CI_JOB_TOKEN`](https://docs.gitlab.com/ee/ci/jobs/ci_job_token.html), or by using the [`trigger`](https://docs.gitlab.com/ee/ci/yaml/index.html#trigger) keyword in the CI/CD configuration file. |

### 获取 Webhook 事件请求参数

所有的请求参数都会以[文件类型的 CI/CD Variable](https://docs.gitlab.com/ee/ci/variables/index.html#cicd-variable-types)  形式保存在 CI Job 中，可以使用 `cat $TRIGGER_PAYLOAD` 或者运行类似的命令来查看。

> 注意：这里的 `$TRIGGER_PAYLOAD` 是一个文件地址，使用 `echo` 命令只能得到一个类似 `/builds/xxx/xxx.tmp/TRIGGER_PAYLOAD` 这样的地址，请求内容被以 JSON 形式保存在这个文件中。

同时还可以使用 `variables[key]=value` 这样的形式来给 CI Job 传递 Variable，例如：

```shell
curl --request POST \
  --form token=TOKEN \
  --form ref=main \
  --form "variables[UPLOAD_TO_S3]=true" \
  "https://jihulab.com/api/v4/projects/123456/trigger/pipeline"
```

## 结语

GitLab 给开发者提供了非常大的自由空间来 DIY 和自动化工作流，只需掌握一些编程技巧就可以玩出千变万化的效果。
<!-- markdown-link-check-enable -->
