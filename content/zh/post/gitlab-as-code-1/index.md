---
title: "Gitlab as Code (一)"
summary: "使用 GitLab + Terraform 来管理你的 GitLab Group/Project"
authors: ["guoxudong"]
tags: ["GitLab", "GitOps", "Terraform"]
categories: ["GitOps"]
date: 2023-02-02T14:36:25+08:00
lastmod: 2023-02-02T14:36:25+08:00
draft: false
type: blog
image: "https://cdn.suuny0826.com/image/2023-02-02-gitlab-as-code.png"
---
## 前言

谈到 Infrastructure as Code 大家想到的大多都是管理各种云上资源，如管理几百个 EC2 实例，十几个 Kubernetes 集群或几千条 DNS 记录。而 GitLab 作为一个核心功能是代码管理的 DebOps 平台，很少有人将其作为“基础设施”来进行管理，更多的是作为存放 IaC 代码的平台。那么，我可以使用 IaC 的方式来管理我的 GitLab 吗？

早在两年前，GitLab 13.0 版本我们就引入了 [GitLab-managed Terraform state](https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_state.html) 来帮助用户使用 Terraform 来管理自己的基础设施；而早在[2017年7月12日](https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/tags/v0.1.0)，GitLab 就 Release 了 [GitLab Terraform Provider](https://registry.terraform.io/providers/gitlabhq/gitlab) 的第一个版本，一个月前 GitLab Terraform Provider 正式与 GitLab 版本号统一，进入了每月一个小版本，每年一个大版本的迭代状态。

## 有必要使用 Terraform 来管理 GitLab 吗？

GitLab 作为一个发展了10多年的开源项目，其功能本身已十分复杂，各式各样功能配置让 GitLab 管理员面临巨大的挑战。用户，项目权限的管理、推送规则设置、CI/CD 中各种密钥/变量的创建与轮换以及各种各样的 Label，每一项都需要投入大量的精力去维护与配置。

>假设有这么一个场景，我需要创建 10 个 project，每个 project 都要新建 10 个指定 Label 并将 2 个密钥保存在 CI/CD 变量中供 GitLab CI 使用，同时还要设置一套包含提交邮箱与 commit 信息规范的推送规则。

- 普通操作是手动在 GitLab UI 上逐个操作，花费一下午的时间也许能弄完；
- 进阶的方式是使用 python 用 gitLab-python 包来完成一个脚本，开发、调试、运行这个脚本，速度可能和手动操作差不多，但是减少了出错的概率，并且一部分代码将来也是可以复用的；
- 那么有更好的方法吗？使用 GitLab Terraform Provider 是个不错的选择，新建一个 `.tf` 文件，定义好 data 和 resource 后，将定义好的资源以 Merge Request 的形式推送到 GitLab 上，GitLab CI 会自动进行检查、安全扫描和测试，检查无误后 merge 代码完成所有的任务，速度要快得多。

如果只有我一个人要管理上千人使用的 GitLab，那么使用 Terraform 配合 GitLab 所提供的 Infrastructure as Code 相关功能是一个非常不错的选择。

## 快速上手

那么现在我们就使用 50 行代码快速构建一套使用 Terraform 管理 GitLab 的项目吧！

目标：

- 在指定 Group 中创建一个 Project
- 要求 Project 项目可见性为 public
- 在 CI/CD 变量中插入一个 `example_variable`
- 为项目创建两个个 Label `fixme`、`bug`，颜色为 `#ffcc00`
- 使用 MR 提交修改，修改 `bug` Label 的颜色为 `#ff0000`
- 销毁创建的项目

### 前期准备

- 使用 gitlab.com （版本号>15.0的 GitLab 均可）
- 新建一个空白的 GitLab 项目
<!-- markdown-link-check-disable-next-line -->
- 新建一个 [personal access token](https://gitlab.com/-/profile/personal_access_tokens) 并将 token 保存在 CI/CD 变量中，Key 为 `TF_VAR_gitlab_access_token`

![CI/CD Variables](https://cdn.suuny0826.com/image/2023-02-02-20230202155550.png)

### .gitlab-ci.yml

GitLab 默认提供了非常好用的 CI Template，直接将其加入 `include` 中即可，想了解其详细内容的可以查看：
- [Terraform.latest.gitlab-ci.yml](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Terraform.latest.gitlab-ci.yml)
- [Terraform/Base.latest.gitlab-ci.yml](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Terraform/Base.latest.gitlab-ci.yml)

```yml
#。gitlab-ci.yml
include:
  - template: Terraform.gitlab-ci.yml

variables:
  TF_STATE_NAME: default
  TF_CACHE_KEY: default
  # If your terraform files are in a subdirectory, set TF_ROOT accordingly. For example:
  # TF_ROOT: terraform/production

destroy:
  extends: .terraform:destroy
  environment:
    name: $TF_STATE_NAME
    action: stop
  rules:
  - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    when: manual
```

上文中添加了 `destroy` Job 用于手动销毁 GitLab CI 中 Terraform 创建的资源。

### Terraform

文章长度有限，这里只简单实现了目标中内容，如果希望实现更多的功能，请见 [官方文档](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs)。

首先需要创建 `backend.tf` 用于开启 GitLab 提供的 [Terraform HTTP backend](https://developer.hashicorp.com/terraform/language/settings/backends/http)，这样就可以：

- 版本化 Terraform state 文件
- 加密传输中和静止时的 state 文件
- 锁定和解锁状态
- 远程执行 `terraform plan` 和 `terraform apply` 命令

更多内容，详见 [官方文档](https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_state.html)。

```tf
# backend.tf
terraform {
  backend "http" {
  }
}
```

接下来创建 `main.tf` 文件，完成目标中的操作。

```tf
# mian.tf
terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "15.8.0"
    }
  }
}


variable "gitlab_access_token" {
  type = string
}

provider "gitlab" {
  token = var.gitlab_access_token
}

data "gitlab_group" "sample_group" {
  group_id = 12322981 # your group id
}

# Add a project to the group - guoxudong.io/example-create-by-tf
resource "gitlab_project" "sample_group_project" {
  name             = "Example Create by TF"
  namespace_id     = data.gitlab_group.sample_group.group_id
  visibility_level = "public"
}

# Add a variable to the project
resource "gitlab_project_variable" "sample_project_variable" {
  project = gitlab_project.sample_group_project.id
  key     = "example_variable"
  value   = "Greetings Master!"
}

# Add a label to the project
resource "gitlab_label" "fixme" {
  project     = gitlab_project.sample_group_project.id
  name        = "fixme"
  description = "issue with failing tests, create by terraform"
  color       = "#ffcc00"
}

# Add a label to the project
resource "gitlab_label" "bug" {
  project     = gitlab_project.sample_group_project.id
  name        = "bug"
  description = "bug label, create by terraform"
  color       = "#ffcc00"
}
```

提交代码后，会自动运行 Pipeline 进行 terraform 的 `fmt`，`validate` 和 `plan`，如果没有问题，就可以点击 `Deploy` 按钮，完成 Project 的创建。

![Pipeline](https://cdn.suuny0826.com/image/2023-02-02-20230202164203.png)

> 注意，如果这里只有 `fmt` Job 失败，请在项目所在目录执行 `terraform fmt` 命令，完成对 `tf` 文件的格式化，不过不执行也不影响实际使用效果 **（强迫症专有提示）**。

### Merge Request

项目创建成功了，接下来提交 MR，将 `bug` Label 的颜色修改为红色 `#ff0000`。

修改 `main.tf`。

```diff
resource "gitlab_label" "bug" {
  project     = gitlab_project.sample_group_project.id
  name        = "bug"
  description = "bug label, create by terraform"
- color       = "#ffcc00"
+ color       = "#ff0000"
}
```

创建 Merge Request 后，可以看到 `Terraform report` 以及 IaC 安全扫描报告。在 Merge Request 面板，可以查看这个 MR 会修改哪些资源，以及提交的内容是否安全，减少了误操作的概率，方便了项目维护者的 review。

![MR](https://cdn.suuny0826.com/image/2023-02-02-20230202170752.png)

### 销毁资源

在实验完成后，只需在最新的 Pipeline 中点击 `destroy` 即可执行 `terraform destroy` 命令，完成对创建资源的销毁。

![Destroy Job](https://cdn.suuny0826.com/image/2023-02-02-20230202193035.png)

## 结语

本文只是简单的实践了一些 GitLab Terraform Provider 的功能，更详细的说明请阅读 [官方文档](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs)。当然，除了本文介绍的 GitLab Terraform Provider 以及在 Merge Request 面板展示 Terraform Plan information 和 IaC 安全扫描报告以外，GitLab 还提供了诸如：[GitLab Terraform helpers](https://docs.gitlab.com/ee/user/infrastructure/iac/gitlab_terraform_helpers.html)、[Terraform module registry](https://docs.gitlab.com/ee/user/packages/terraform_module_registry/index.html) 等一系列非常好用的功能，这些功能会在后续的文档中进行介绍，敬请期待。

项目 Demo 地址：https://gitlab.com/guoxudong.io/terraform/gitlab-as-code
