---
title: "GitLab as Code (二) 离线运行优化"
summary: "介绍离线运行 GitLab + Terraform，提高用户的使用 GitOps 的体验。"
authors: ["guoxudong"]
tags: ["GitLab", "GitOps", "Terraform"]
categories: ["GitOps"]
date: 2023-02-07T15:35:38+08:00
lastmod: 2023-02-07T15:35:38+08:00
draft: false
type: blog
image: "https://cdn.suuny0826.com/image/2023-02-08-p5cc_262465.png"
---
## 前言

本文是对[上一篇文章](../gitlab-as-code-1)（使用 GitLab + Terraform 管理 GitLab 的 Group 和 Project）的补充。在生产环境中，我们经常会遇到以下问题：

- GitLab 部署在内网，未开放公网访问，无法访问 [Terraform Registry](https://registry.terraform.io)
- Initializing Terraform Provider 时，频繁出现类似 `Get "https://registry.terraform.io/.well-known/terraform.json": net/http: TLS handshake timeout` 这样由网络卡顿引起的错误
- 拉取不到 `Terraform.gitlab-ci.yml` template 中的 `registry.gitlab.com/gitlab-org/terraform-images/releases` 镜像

## 解决方案

上述这些问题均由网络因素造成，其有多种解决方案：

- 在可以访问公网的机器（甚至是您的笔记本电脑）注册[私有 GitLab Runner](https://docs.gitlab.cn/runner/register/#%E6%B3%A8%E5%86%8C-runner)，通过该 Runner 运行 Pipeline

> GitLab Runner 支持多系统（Linux、macOS、Windows、FreeBSD等）、多架构（x86、ARM）以及 Docker/Kubernetes 容器平台

- 使用 [Terraform Providers Mirror](https://developer.hashicorp.com/terraform/cli/commands/providers/mirror) 将需要的 Terraform Provider 镜像下载到本地

本文主要介绍第二种方案，关于第一种方案，详情请参阅[官方文档](https://docs.gitlab.cn/runner/)。

## 离线运行优化

基于[上一篇文章](../gitlab-as-code-1)的内容，只需几步即可实现离线运行优化，并使 Pipeline 运行速度提高一倍。

![优化前后](https://cdn.suuny0826.com/image/2023-02-07-20230207165247.png)

### Terraform Providers Mirror

在无法访问 [Terraform Registry](https://registry.terraform.io) 或访问境外站点速度过慢时，可以使用 Terraform Providers Mirror 解决问题。只需一行命令即可将 `.tf` 文件中使用的 Providers 下载到本地：

```shell
terraform providers mirror -platform=linux_amd64 .
```

> `terraform providers mirror` 仅适用于 Terraform v0.13 或更高版本

- `-platform=OS_ARCH`: 指定需要运行的 providers 的系统架构，默认是本机架构。因为 [jihulab.com](https://jihulab.com) 的 share-runner 是 linux 系统 `amd64` 架构，所以这里使用了 `linux_amd64`
- `.`: 指定下载后的 `<target-dir>`，即 providers 镜像将保存在该目录中。

运行命令后，项目的根目录会多出一个名为 `registry.terraform.io` 的文件夹，里面是已下载的镜像文件。

### `.terraformrc` 文件

下载好 Providers 镜像后，下一步是编辑 Terraform CLI 配置文件 `.terraformrc`，指定运行 Terraform 时使用镜像的 Providers。

以下是配置示例：

```json
provider_installation {
    filesystem_mirror {
        path    = "${TF_ROOT}"
        include = ["registry.terraform.io/gitlabhq/*"]
    }
}
```

- `path`: 镜像的路径
- `include`: 指定为哪些 Providers 提供镜像，也可以使用 `exclude` 来排除

如果有 Terraform Providers 镜像站地址，可以直接使用 `network_mirror` 指定 URL。有关详细内容，请参阅[官方文档](https://developer.hashicorp.com/terraform/cli/config/config-file#explicit-installation-method-configuration)。

### GitLab CI

在编辑完 `.terraformrc` 文件后，接下来即可编辑 `.gitlab-ci.yml` 文件。

在 `.gitlab-ci.yml` 文件中，需要进行如下修改：

1. 在 `before_script` 中生成 `.terraformrc` 供 terraform CLI 使用：

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

2. 增加 `Variables`：

    ```yaml
    variables:
    TF_STATE_NAME: default
    TF_CACHE_KEY: default
    # If your terraform files are in a subdirectory, set TF_ROOT accordingly. For example:
    # TF_ROOT: terraform/production
    TF_CLI_CONFIG_FILE: ${TF_ROOT}/.terraformrc
    GITLAB_BASE_URL: ${CI_API_V4_URL}
    ```

- `TF_CLI_CONFIG_FILE`: 设置为指定的 terraform CLI 配置文件路径，即生成的 `.terraformrc` 文件路径。`${TF_ROOT}` 表示 Terraform 配置的根路径，该环境变量由 [GitLab Terraform helpers](https://docs.gitlab.com/ee/user/infrastructure/iac/gitlab_terraform_helpers.html#generic-variables) 提供
- `GITLAB_BASE_URL`: 设置为 GitLab Provider 的 `base_url`，默认为 `https://gitlab.com/api/v4/`，此处使用了[预定义 CI/CD 变量](https://docs.gitlab.cn/ee/ci/variables/predefined_variables.html) `CI_API_V4_URL`

这样每次运行 Pipeline 时，都会通过指定的 `.terraformrc` 文件从本地 Terraform Providers Mirror 拉取 Terraform Providers。

### GitLab Container Registry

有些 GitLab 实例没有公网访问权限，无法拉取到 GitLab 提供的 Terraform 基础镜像 `registry.gitlab.com/gitlab-org/terraform-images/releases`，解决方案很简单：

- 在公网拉取该镜像并上传到私有镜像仓库（如 Harbor）
- 将镜像上传到 GitLab 提供的 Container Registry 使用

## 结语

在实际使用中，即使没有网络连接的困扰，我仍然强烈推荐使用这套离线运行方案。不管是 `validate`、`plan` 还是 `apply` 等操作，它们的执行速度都快得多，因此特别适合那些正在学习并尝试使用 GitLab + Terraform 整套方案的用户。

Demo 地址：<https://jihulab.com/cloud-native/gitops/gitlab-as-code/>
