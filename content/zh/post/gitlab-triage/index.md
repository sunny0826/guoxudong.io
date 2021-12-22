---
title: "Gitlab Triage：自动管理 Issue 与 Merge Request"
summary: "使用 Gitlab Triage 自动管理 Epic、Issue 与 MR"
authors: ["guoxudong"]
tags: ["gitlab", "工具"]
categories: ["gitlab"]
date: 2021-12-22T08:58:38+08:00
lastmod: 2021-12-22T08:58:38+08:00
draft: false
type: blog
image: "https://tvax1.sinaimg.cn/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg"
---
## 前言

极狐GitLab 中使用 Epic、Issue、Merge Request 进行计划和管理，继而组织和追踪进度。尤其是在 GitLab 主库 [gitlab-org/gitlab](https://gitlab.com/gitlab-org/gitlab) 存在总计超过 **10W+** 的 Issue 以及 **4W+** 打开的 Issue，如果每个 Issue 都要手动分类管理，那将是一场噩梦。

## Gitlab Triage

[gitlab-triage](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage) 是使用 `gem` 管理，旨在让项目经理和 maintainers 能够通过自定义策略自动处理 GitLab 项目或组中的 Issue 和 Merge Request。

### 安装

使用 `gem` 安装，以二进制可执行文件运行在本地或 CI Pipeline 中。

```bash
gem install gitlab-triage
```

### 本地运行

`gitlab-triage` 本质上是 CLI 工具，可以在本地与 GitLab CI 或是任何可以运行 CLI 的环境与平台运行。

- 在指定项目运行

    ```bash
    gitlab-triage --dry-run --token $GITLAB_API_TOKEN --source-id gitlab-org/triage
    ```

- 在指定群组运行

    ```bash
    gitlab-triage --dry-run --token $GITLAB_API_TOKEN --source-id gitlab-org --source groups
    ```

- 在整个实例运行

    ```bash
    gitlab-triage --dry-run --token $GITLAB_API_TOKEN --all-projects
    ```

    > 💡 `--all-projects` 用于指定对于 `$GITLAB_API_TOKEN` 所有可见的资源

- 指定相应实例

    ```bash
    gitlab-triage --dry-run --token $GITLAB_API_TOKEN --host-url https://gitlab.cn --all-projects
    ```

    > 💡 使用 `--host-url` 指定需要添加 `https` 或 `http`，也可以在策略文件中指定 `host_url`
    >```yaml
    >host_url: https://gitlab.host.com
    >resource_rules:
    >	...
    >```

### 在 GItLab CI Pipeline 中运行

> 💡 可以使用 `—init-ci` 选项生成示例 `.gitlab-ci.yml` 文件

推荐使用 GitLab CI 自动运行 `gitlab-triage`，配合 GitLab Scheduling Pipelines 进行定时执行，或者配合 Webhook 在 Issues events 和 Merge request events 时触发执行，不过这需要少量的编程。

```yaml
run:triage:triage:
  stage: triage
  script:
    - gem install gitlab-triage
    - gitlab-triage --token $GITLAB_API_TOKEN --source-id $CI_PROJECT_PATH
  only:
    - schedules
```

## 策略

生成 **triage policy** 策略文件 `./.triage-policies.yml` 来保存所有策略。

> 💡 可以使用 `--init` 选项命令可以生成示例策略文件

支持的资源：

- epics
- issues
- merge_request

使用 `rueles` (array 类型)字段来定义所有策略，如：

```yaml
resource_rules:
  epics:
    rules:
      - name: epic policy A
      - name: epic policy B
  issues:
    rules:
      - name: issue policy A
      - name: issue policy B  
  merge_requests:
    rules:
      - name: merge request policy A
      - name: merge request policy B
```

### 策略字段

`gitlab-triage` 提供了非常丰富的策略字段，描述策略的主体部分由4个字段组成：

| 字段名 | 描述 |
| --- | --- |
| [name](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage#name-field) | 声明策略名称和用途 |
| [condition](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage#conditions-field) | 声明策略的执行条件 |
| [limits](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage#limits-field) | 声明限制运行 action 的资源数量 |
| [action](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage#actions-field) | 声明对满足条件资源进行的操作 |

`condition` 字段提供了 14 种条件类型，同时 `ruby` 字段还可以执行 ruby 表达式来进行判断；`action` 也提供了多种操作，还可以在 `comment` 中配合 [GitLab quick actions](https://docs.gitlab.com/ee/user/project/quick_actions.html) 进行更多的操作，详细内容请参考[官方文档](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage#fields)。

### 插件系统

同时可以使用[插件](https://gitlab.com/gitlab-org/gitlab-triage#can-i-customize)来定制策略。使用 `-r` 或 `--request` 在执行操作前加载一个 ruby 文件，在该文件中完成想要进行的操作。就如下面 `my_plugin.rb` 这个文件：

```ruby
module MyPlugin
  def has_severity_label?
    labels.grep(/^S\d+$/).any?
  end

  def has_priority_label?
    labels.grep(/^P\d+$/).any?
  end

  def labels
    resource[:labels]
  end
end

Gitlab::Triage::Resource::Context.include MyPlugin
```

执行命令

```bash
gitlab-triage -r ./my_plugin.rb --token $GITLAB_API_TOKEN --source-id gitlab-org/triage
```

现在就可以在 `ruby` 中判断 `has_severity_label` 了

```yaml
resource_rules:
  issues:
    rules:
      - name: Apply default severity or priority labels
        conditions:
          ruby: |
            !has_severity_label? || !has_priority_label?
        actions:
          comment: |
            #{'/label ~S3' unless has_severity_label?}
            #{'/label ~P3' unless has_priority_label?}
```

## 场景推荐

> 💡 一般情况下，会新建一个 Bot 用户用来完成 Triage 的任务，这样可以做到很精细的管理

下面是一些比较常见的使用场景：

- 处理没有使用 Label 的 Epic、Issue 和 MR
- 处理无人反馈的 Issue 和 MR，指定 review
- 清理长时间不活跃的 Issue 和 MR
- 统计一周没有进行更新的 Issue 并生成统计 Issue

示例项目: <https://gitlab.cn/cloud-native/demo/triage-demo/-/snippets>

目前 `gitlab-triage` 已经是一个比较完备的工具，在 GitLab 内部基于该项目孵化了 [triage-ops](https://gitlab.com/gitlab-org/quality/triage-ops) 这样的原型来进行内部 dogfooding，并希望将其整合到 GitLab 产品当中。
