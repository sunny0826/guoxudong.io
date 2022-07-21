---
title: "在 Gitlab CI Pipeline 中进行 Git Push 操作 🦊"
summary: "在 Pipeline 中推送代码的技巧"
authors: ["guoxudong"]
tags: ["GitLab", "DevOps"]
categories: ["GitLab 冷知识"]
date: 2022-07-21T10:58:10+08:00
lastmod: 2022-07-21T10:58:10+08:00
draft: false
type: blog
image: "https://tvax1.sinaimg.cn/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg"
---
## 前言

在日常工作中，经常会遇到这样一种场景：需要在 GItLab CI Job 中进行 Git Push 操作，将修改或构建好的代码推送到远端 Git 代码仓库当中。这是一个十分常见操作，本篇文章将会提供一个最简单且使用的方法来实现这个场景，希望对您有所帮助。

## 预备知识

在开始之前，有一些预备知识需要介绍，这些知识也会帮您进一步掌握 GItLab CI 的使用技巧。

### `incloud` 关键字

使用 `include` 在 CI/CD 配置中 import 外部 YAML 文件。您可以将一个长的 `.gitlab-ci.yml` 文件拆分为多个文件以提高可读性，或减少同一配置在多个位置的重复。

`include` 目前支持 4 种导入模式：

- `local`：导入位于同一仓库中的文件
    ```yaml
    # example
    include:
      - local: '/templates/.gitlab-ci-template.yml'
    ```
- `file`：导入同一实例上另一个私有仓库的文件
    ```yaml
    # 可以导入同一项目的多个文件
    include:
      - project: 'my-group/my-project'
        ref: main
        file:
          - '/templates/.builds.yml'
          - '/templates/.tests.yml'
    ```
- `remote`：使用完整 URL 导入远程实例中文件
    ```yaml
    # 可通过 HTTP/HTTPS GET 请求访问的公共 URL。不支持使用远端 URL 进行身份验证。
    include:
      - remote: 'https://gitlab.com/example-project/-/raw/main/.gitlab-ci.yml'
    ```
- `template`：导入 GItLab 提供的 CI Template
    ```yaml
    # File sourced from the GitLab template collection
    include:
      - template: Auto-DevOps.gitlab-ci.yml
    ```

使用 `include` 关键字可以将 git push 相关操作与 `.gitlab-ci.yml` 文件进行解耦，方便维护也更易于阅读。

### `extends` 关键字

使用 `extends` 来重用配置，也是将 git push 相关操作插入具体 Job 的方法。它是 [YAML 锚点](https://docs.gitlab.cn/jh/ci/yaml/yaml_optimization.html#%E9%94%9A%E7%82%B9) 的替代方案，并且更加灵活和可读。

```yaml
# extend example
.tests:
  script: rake test
  stage: test
  only:
    refs:
      - branches

rspec:
  extends: .tests
  script: rake rspec
  only:
    variables:
      - $RSPEC
```

### `before_script` 与 `after_script`

使用 `before_script` 可以定义一系列命令，这些命令应该在每个 Job 的 `script` 命令之前，但在 `artifacts` 恢复之后运行。

使用 `after_script` 定义在每个作业之后运行一系列命令，需要注意的是，即使是失败的 Job 也会运行这一系列命令。

我们可以非常方便的在 `before_script` 定义 Git 操作的预备逻辑，如： clone 代码、配置 email/username 等；而在 `after_script` 中我们会定义 Git 的 commit 以及 push 操作。

### CI 预定义变量

预定义变量是每个 GitLab CI/CD 流水线中都有的 CI/CD 变量，使用这些变量可以快速获得该运行 Job 的一些常用信息，同时也应该尽量避免覆盖这些变量，否则可能导致 Pipeline 的运行出现意外。

本文我们要用到的 CI 预定义变量有：

| 变量 | 说明 | 示例 |
| ------ | ------ | ------ |
| `CI_COMMIT_SHA` | Commit SHA，用于创建名称唯一的文件 | `e46f153dd47ce5f3ca8c56be3fb5d55039853655` |
| `CI_DEFAULT_BRANCH` | 项目默认分支的名称 | `main` |
| `CI_PROJECT_PATH` | 包含项目名称的项目命名空间 | `gitlab/gitlab-cn` |
|  `CI_SERVER_HOST` | GitLab 实例 URL 的主机，没有协议或端口 | `gitlab.example.com` |
| `GITLAB_USER_EMAIL` | 开始作业的用户的 email | `guoxudong.dev@gmail.com` |
| `GITLAB_USER_NAME` | 启动作业的用户的姓名 | `Xudong Guo` |
| `CI_PROJECT_DIR` | 仓库克隆到的完整路径，以及作业从哪里运行 | `/builds/gitlab/gitlab-cn/` |
| `CI_COMMIT_BRANCH` | 提交分支名称 | `feat/git_push` |
| `CI_COMMIT_MESSAGE` | 完整的提交消息 | `feat: add git push stage` |

更多的预定义变量，见[官方文档](https://docs.gitlab.cn/jh/ci/variables/predefined_variables.html)。

## Step by step

有了上面这些知识储备，我们就可以开始动手实践了。

### 创建访问令牌

要完成 Git Push 操作，首先我们需要有一个具有相应权限的访问令牌，如果您使用的是极狐 GItLab SaaS 平台，可以直接访问 <https://jihulab.com/-/profile/personal_access_tokens> 来进行创建。

创建个人访问令牌时，需要勾选以下范围：
- `read_repository`
- `write_repository`

> 请保管好您的个人访问令牌，推荐为每个令牌设置到期时间，如果令牌泄露，请尽快到个人访问令牌页面**撤销**该令牌并重新生成新的令牌。

### 设置变量

在生成好个人访问令牌，就可以在 **设置**->**CI/CD**->**变量** 中插入相应 KV 了，插入的 KV 会作为环境变量注入到 GItLab CI Pipeline 中。这里需要插入的变量有：

| 变量 | 说明 | 示例 |
| ------ | ------ | ------ |
| `GITLAB_TOKEN` | 个人访问令牌，请勾选**隐藏变量** | `xxxxxxxxxxx` |
| `GITLAB_USERNAME` | 个人访问令牌对应的用户名 | `guoxudong` |

### 创建 CI Template

在 `.gitlab/ci/` 目录中新建 `git-push.yaml` 文件（当然您也可以在其他位置创建）。

```yaml
.git:push:
  #  请确保 extends 的 Job 中安装了 git，如果没有安装，可以使用类似 `apk add git` 命令来安装 git
  #  image:
  #    name: alpine/git:v2.32.0
  #    entrypoint: ['']
  before_script:
    # Clone the repository via HTTPS inside a new directory
    - |
      git clone "https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git" "${CI_COMMIT_SHA}"
      cd "${CI_COMMIT_SHA}"

    # Check out branch if it's not master
    - |
      if [[ "${CI_COMMIT_BRANCH}" != "${CI_DEFAULT_BRANCH}" ]]; then
        git fetch
        git checkout -t "origin/${CI_COMMIT_BRANCH}"
      fi

    - git branch
    # Set the displayed user with the commits that are about to be made
    - git config --global user.name "${GIT_USER_NAME:-$GITLAB_USER_NAME}"
    - git config --global user.email "${GIT_USER_EMAIL:-$GITLAB_USER_EMAIL}"

    - cd "${CI_PROJECT_DIR}"
  after_script:
    # Go to the new directory
    - cd "${CI_COMMIT_SHA}"

    # Add all generated files to Git
    - git add .

    - |-
      # Check if we have modifications to commit
      CHANGES=$(git status --porcelain | wc -l)

      if [ "$CHANGES" -gt "0" ]; then
        # Show the status of files that are about to be created, updated or deleted
        git status

        # Commit all changes
        git commit -m "${CI_COMMIT_MESSAGE}"

        # Update the repository
        if [ "${SKIP_CI}" -gt "0" ]; then
          # Skip the pipeline create for this commit
          echo "Skip"
          git push -o ci.skip 
        else
          echo "no Skip"
          git push
        fi
        echo "Over"
      else
        echo "Nothing to commit"
      fi

```

细心的读者可能会发现，上面这个 `git-push.yaml` 中并没有 `script` 关键字，也就是说，这个 Job 是不能单独运行的，您需要将其 `incloud` 到您的 `.gitlab-ci.yml` 并且 `extends` 到相关 Job，效果如下：

```yaml
#.gitlab-ci.yml
include:
  - local: .gitlab/ci/docs-git-push.yaml

...
Git push:
  stage: deploy
  extends:
    - .git:push
  script:
    - |
      # Move some generated files
      mv dist/* "${CI_COMMIT_SHA}"
...
```

此处的 `${CI_COMMIT_SHA}` 就是我们在 `before_script` 中 clone 的仓库目录，理论上可以使用任何名称来代替，这里使用 `${CI_COMMIT_SHA}` 是为了确保这个目录名称唯一不会和其他目录名称重复。

## 结语

GItLab CI 一直在努力平衡易用性和灵活性，通过多种关键字和预定义变量来让用户更好的使用和构建 Pipeline，同时也不会过多的限制用户的发挥空间，上面这段逻辑，完全可以使用其他 shell 或 Python、JS、Go 等编程语言来实现其功能。本文也只是一个引子，通过 Git Push 这个场景来引出 `include` 、 `before_script` 与 `after_script` 以及预定义变量的使用，如果您有更好的方式，欢迎留言。
