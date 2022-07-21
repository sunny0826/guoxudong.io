---
title: "GitLab 冷知识：试用 git push 创建 Merge Request"
summary: "无需 UI 操作，只需 git push 命令就可以在 GitLab 创建 Merge Request"
authors: ["guoxudong"]
tags: ["GitLab", "DevOps", "CI/CD"]
categories: ["GitLab 冷知识"]
date: 2022-06-10T09:28:14+08:00
lastmod: 2022-06-10T09:28:14+08:00
draft: false
type: blog
image: "https://tvax1.sinaimg.cn/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg"
---
## 前言

在使用 GitLab 时，创建 Merge Request 是最常用的功能之一，每天有大量的 Merge Request 被 Create、Review、Approve 和 Merge，尽管 GitLab 的产品经理和 UX 设计师们已经尽力的将 UI 设计的简洁易懂好操作，并提供了一些诸如使用 `Email`、`API`、`Web IDE`、`VS Code 插件`等创建 Merge Request 的功能，但这些操作都逃不过：**create new branch** ==> **git push** ==> **create merge request** 这三步。

那么有没有方法可以将这三步合并成一步呢？答案是有的，**[git push options](https://git-scm.com/docs/git-push#Documentation/git-push.txt--oltoptiongt)** 可以直接通过 `git push` 来创建 GitLab Merge Request。

> Tips:
> 在您向 GitLab 推送新分支完成后，GitLab 会在您的终端用链接提示您创建合并请求，效果如下：
> ```shell
>...
>remote: To create a merge request for my-new-branch, visit:
>remote:   https://gitlab.example.com/my-group/my-project/merge_requests/new?merge_request%5Bsource_branch%5D=my-new-branch 
>```
> `⌘+点击该链接` 即可直接跳转 Merge Request 创建页面。

## 版本要求

GitLab 自 11.7 版本开始支持 `git push options`，目前(GitLab 15.0)支持的 push options 有 **[CI/CD 操作](#cicd-push-options)** 和 **[Merge Request 操作](#创建-merge-request)** 两种。

Git push options 仅适用于 `Git 2.10` 或更新版本。

对于 Git 版本 `2.10` 到 `2.17`，使用 `--push-option`：

```shell
git push --push-option=<push_option>
```

对于 2.18 及更高版本，您可以使用上述格式，或者更短的 `-o`：

```shell
git push -o <push_option>
```

## 创建 Merge Request

现在您就可以使用一行 `git push` 命令来完成推送代码+创建 Merge Request 的操作了：

```shell
git push -o merge_request.create -o merge_request.target=my-target-branch
```

> Tips: 通过使用多个 `-o`（或 `--push-option`）标志，您可以组合推送选项以一次完成多个任务。

### 可用选项

GitLab 提供了多种操作项来帮您完成 Merge Request 的创建。当然，您也可以通过 `merge_request.description` + [Quick action](../gitlab-quick-actions/) 的方式完成更多的操作。 

| 推送选项                                  | 描述                                                                                                     | 引入版本 |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------- |
| `merge_request.create`                       | 为推送的分支创建一个新的合并请求。                                                               | 11.10 |
| `merge_request.target=<branch_name>`         | 将合并请求的目标设置为特定分支，或上游项目，比如：`git push -o merge_request.target=project_path/branch`                                                     | 11.10 |
| `merge_request.merge_when_pipeline_succeeds` | 将合并请求设置为流水线成功时合并。    | 11.10 |
| `merge_request.remove_source_branch`         | 设置合并请求以在合并时删除源分支。                                             | 12.2          |
| `merge_request.title="<title>"`              | 设置合并请求的标题。例如：`git push -o merge_request.title="我想要的标题"`。                   | 12.2          |
| `merge_request.description="<description>"`  | 设置合并请求的描述。例如：`git push -o merge_request.description="我想要的描述"`。 | 12.2         |
| `merge_request.draft`                        | 将合并请求标记为 draft。例如：`git push -o merge_request.draft`。                                      | 15.0          |
| `merge_request.milestone="<milestone>"`      | 设置合并请求的里程碑。例如：`git push -o merge_request.milestone="3.0"`。                        | 14.1       |
| `merge_request.label="<label>"`              | 向合并请求添加标签。如果标签不存在，则创建它。例如，对于两个标签：`git push -o merge_request.label="label1" -o merge_request.label="label2"`。 | 12.3 |
| `merge_request.unlabel="<label>"`            | 从合并请求中删除标签。例如，对于两个标签：`git push -o merge_request.unlabel="label1" -o merge_request.unlabel="label2"`。 | 12.3 |
| `merge_request.assign="<user>"`              | 将用户分配给合并请求。接受用户名或用户 ID。例如，对于两个用户：`git push -o merge_request.assign="user1" -o merge_request.assign="user2"`。 | 13.10 |
| `merge_request.unassign="<user>"`            | 从合并请求中删除分配的用户。接受用户名或用户 ID。例如，对于两个用户：`git push -o merge_request.unassign="user1" -o merge_request.unassign="user2"`。 | 13.10 |

如果您使用要求文本中包含空格的推送选项，则需要将其括在引号 (`"`) 中。如果没有空格，您可以省略引号。一些示例：

```shell
git push -o merge_request.label="Label with spaces"
git push -o merge_request.label=Label-with-no-spaces
```

### 在 GitLab CI 中创建 Merge Request

目前网上对于在 GitLab CI 中创建 Merge Request 的方法，全是使用 `curl` 调用 GitLab API 来实现的。其实不必那么麻烦，`git push options` 一个操作即可解决。

```yaml
Create Merge Request:
  stage: push
  image: alpine:latest
  before_script:
    - sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
    - apk add --update git
    - git config --global user.name "${GITLAB_USER_NAME}"
    - git config --global user.email "${GITLAB_USER_EMAIL}"
  script: |    
    echo "create merge request"
    git checkout -b auto-${CI_JOB_ID}
    git add .
    git commit -m "auto create merge request"
    git push "https://${GITLAB_USER_LOGIN}:${CI_GIT_TOKEN}@${CI_REPOSITORY_URL#*@}" "HEAD:auto-${CI_JOB_ID}" \
     -o merge_request.create -o merge_request.target=develop -o merge_request.remove_source_branch \
     -o merge_request.title="auto generator swagger api" -o merge_request.label="auto-generation" -o merge_request.assign="qk44077907"
```

这里的 `$CI_GIT_TOKEN` 需要先创建[用户访问令牌](https://jihulab.com/-/profile/personal_access_tokens)，并将其添加到 [CI/CD Variables](https://docs.gitlab.cn/jh/ci/variables) 当中。如果使用的是[项目访问令牌](https://docs.gitlab.cn/jh/user/project/settings/project_access_tokens.html)，则需要将 `${GITLAB_USER_NAME}` 和 `${GITLAB_USER_EMAIL}` 配置为项目机器人用户：

- Name：`project_{project_id}_bot`
- Email：`project{project_id}_bot@noreply.{Gitlab.config.gitlab.host}`

更多内容见[官方文档](https://docs.gitlab.cn/jh/user/project/settings/project_access_tokens.html#%E9%A1%B9%E7%9B%AE%E6%9C%BA%E5%99%A8%E4%BA%BA%E7%94%A8%E6%88%B7)。

## CI/CD Push options

目前支持的 CI/CD push options 有两个：**跳过 CI Jobs** 和 **插入 CI/CD Variable**，比较常用的是 **插入 CI/CD Variable**，可以用来测试一些 Variable 的效果。

| 推送选项                    | 描述                                                                                 | 引入版本 |
| ------------------------------ | ------------------------------------------------------------------------------------------- |---------------------- |
| `ci.skip`                      | 不要为最新推送创建 CI 流水线。只跳过分支流水线而**不是合并请求流水线**。                                            | 11.7 |
| `ci.variable="<name>=<value>"` | 提供 CI/CD 变量以在 CI 流水线中使用（如果由于推送而创建）。 | 12.6 |

使用 `ci.skip` 的示例：

```shell
git push -o ci.skip
```

为流水线传递一些 CI/CD 变量的示例：

```shell
git push -o ci.variable="MAX_RETRIES=10" -o ci.variable="MAX_TIME=600"
```

## 使用 git alias 简化命令

一般来说使用 git push options 的场景都比较固定，可以考虑将很长的 push options 设置为 [Git aliases](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases) 来简化命令。

设置 Git alias：

```shell
git config --global alias.mwps "push -o merge_request.create -o merge_request.target=master -o merge_request.merge_when_pipeline_succeeds"
```

然后快速推送以默认分支为目标的本地分支，并在流水线成功时合并：

```shell
git mwps origin <local-branch-name>
```

## 结语

[极狐 GitLab 文档中心](https://docs.gitlab.cn/)现已正式上线，本文的大部分内容来自[使用 Git --> 推送选项](https://docs.gitlab.cn/ee/user/project/push_options.html)部分。在开始动手工作之前仔细阅读一下文档是一个非常好的习惯，可以帮助您少走很多弯路。

## 参考资料

- [推送选项 - docs.gitlab.cn](https://docs.gitlab.cn/ee/user/project/push_options.html)
