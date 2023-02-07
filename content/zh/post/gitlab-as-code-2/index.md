---
title: "GitLab as Code (二) 离线运行优化"
summary: "介绍离线运行 GitLab + Terraform 来提高用户的使用 GitOps 的体验。"
authors: ["guoxudong"]
tags: ["GitLab", "GitOps", "Terraform"]
categories: ["GitOps"]
date: 2023-02-07T15:35:38+08:00
lastmod: 2023-02-07T15:35:38+08:00
draft: false
type: blog
image: "https://cdn.suuny0826.com/image/2023-02-07-gitlab-as-code-2.png"
---
## 前言

[上篇文章](../gitlab-as-code-1)中笔者介绍了如何使用 GitLab + Terraform 来管理 GitLab 的 Group 与 Project。但在生产场景中，经常会遇到以下情况：

- GitLab 部署在企业内网，没有开放公网访问，无法访问 [Terraform Registry](https://registry.terraform.io)
- Initializing Terraform Provider 时，频繁出现类似 `Get "https://registry.terraform.io/.well-known/terraform.json": net/http: TLS handshake timeout` 这样由网络卡顿引起的错误
- 拉取不到 `Terraform.gitlab-ci.yml` template 中的 `registry.gitlab.com/gitlab-org/terraform-images/releases` 镜像

## 解决方案

上述的这些问题都是由于网络因素造成的问题，解决方案不止一种：

- 在可以访问公网的机器（甚至是您的笔记本电脑）注册[私有 GitLab Runner](https://docs.gitlab.cn/runner/register/#%E6%B3%A8%E5%86%8C-runner)，通过这个指定的 Runner 来运行 Pipeline

> GitLab Runner 支持多系统（Linux、macOS、Windows、FreeBSD等）、多架构（x86、ARM）以及 Docker/Kubernetes 容器平台

- 使用 [Terraform Providers Mirror](https://developer.hashicorp.com/terraform/cli/commands/providers/mirror) 将需要使用的 Terraform Provider 下载到本地使用

本文主要介绍第二种解决方案，如果对第一种方案感兴趣，[官方文档](https://docs.gitlab.cn/runner/)中有更详细的说明。

## 离线运行优化

基于[上篇文章](../gitlab-as-code-1)中的内容，只需几步就能完成离线运行优化，Pipeline 运行速度提升一倍。

![优化前后](https://cdn.suuny0826.com/image/2023-02-07-20230207165247.png)

### Terraform Providers Mirror

在无法访问 [Terraform Registry](https://registry.terraform.io) 或访问境外站点速度过慢时，Terraform Providers Mirror 可以很好的帮助用户解决这个问题。

只需一行命令，即可将 `.tf` 文件中使用到的 Providers 下载到本地：

```shell
terraform providers mirror -platform=linux_amd64 .
```

> `terraform providers mirror` 只对 Terraform v0.13 或更高的版本有效

- `-platform=OS_ARCH` 该参数为选择需要运行的 providers 的系统架构，默认为本机架构，由于 [jihulab.com] 的 share-runner 为 linux 系统 amd64 架构，而非我本地的 `darwin_amd64` 架构，故这里使用 `linux_amd64`
- `.` 为指定下载的 `<target-dir>`，这里直接下载到项目根目录

命令运行成功后，项目的根目录就会多出一个文件夹 `registry.terraform.io`，文件夹内就是我们下载的镜像文件。

### `.terraformrc` 文件

下载好 providers 镜像后，下一步就是修改 Terraform CLI 配置，指定运行 Terraform 时，哪些 Provider 使用镜像。

```json
provider_installation {
    filesystem_mirror {
        path    = "${TF_ROOT}"
        include = ["registry.terraform.io/gitlabhq/*"]
    }
}
```

- `path` 为镜像所在的路径
- `include` 指定为哪些 Providers 提供进项，也可以使用 `exclude` 来排除

当然，如果有提供 Terraform Providers 的镜像站地址，也可以直接使用 `network_mirror` 来指定 URL。详细内容，见[官方文档](https://developer.hashicorp.com/terraform/cli/config/config-file#explicit-installation-method-configuration)

### GitLab CI

编辑好 `.terraformrc` 文件后，就可以开始修改 `.gitlab-ci.yml` 文件了。

需要修改的地方很少，首先是在 `before_script` 中生成 `.terraformrc` 以供 `terraform` CLI 使用：

```yaml
before_script:
- | 
    cat>.terraformrc<<EOF
    provider_installation {
        filesystem_mirror {
            path    = "${TF_ROOT}"
            include = ["registry.terraform.io/gitlabhq/*"]
        }
    }
    EOF
```

接下来是增加 `Variables`：

```yaml
variables:
  TF_STATE_NAME: default
  TF_CACHE_KEY: default
  # If your terraform files are in a subdirectory, set TF_ROOT accordingly. For example:
  # TF_ROOT: terraform/production
  TF_CLI_CONFIG_FILE: ${TF_ROOT}/.terraformrc
  GITLAB_BASE_URL: ${CI_API_V4_URL}
```

- `TF_CLI_CONFIG_FILE` 为指定 `terraform` CLI 的配置文件路径，也就是我们生成的 `.terraformrc` 文件路径，`${TF_ROOT}` 为 Terraform 配置的根路径，该环境变量由 [GitLab Terraform helpers](https://docs.gitlab.com/ee/user/infrastructure/iac/gitlab_terraform_helpers.html#generic-variables) 提供
- `GITLAB_BASE_URL` 为指定 GitLab Provider 的 `base_url`，默认为 `https://gitlab.com/api/v4/`，这里直接使用[预定义 CI/CD 变量](https://docs.gitlab.cn/ee/ci/variables/predefined_variables.html) `CI_API_V4_URL`

这样每次在运行 Pipeline 的时候，就可以通过指定的 `.terraformrc` 文件来拉取本地的 Terraform Providers Mirror 了。

### GitLab Container Registry

有部分没有公网访问的 GitLab 用户无法拉取到 GitLab 提供的 Terraform 基础镜像 `registry.gitlab.com/gitlab-org/terraform-images/releases`，解决这个问题也很简单。用户可以：

- 在公网拉取该镜像，将其上传到自己的私有镜像仓库（如 Harbor）使用
- 将镜像上传到 GitLab 提供的 Container Registry 使用

## 结语

实际使用下来，哪怕并没有网络环境的困扰，我也比较推荐使用这套离线运行方案，无论是 `validate` 还是 `plan` 和 `apply` 速度都要快上很多，非常使用还在学习个尝试的朋友使用。

Demo 地址：<https://jihulab.com/cloud-native/gitops/gitlab-as-code/>
