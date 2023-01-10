---
title: "使用 Github Dependabot 自动更新依赖版本"
summary: "使用 Github Dependabot 配合 PR，轻松升级依赖包"
authors: ["guoxudong"]
tags: ["github","工具","kubecm"]
categories: ["工具"]
date: 2021-12-01T14:18:59+08:00
lastmod: 2021-12-01T14:18:59+08:00
draft: false
type: blog
image: https://cdn.suuny0826.com/large/ad5fbf65gy1gwyf75bzdgj20p00anq9w.jpg
---
## 前言

在软件开发工作中，代码依赖管理是个绕不过的话题。针对依赖管理，不同的语言、工具、平台和团队都有自己的解决方案。本文将会介绍 GitHub 推出依赖版本更新工具 Dependabot。正如其名字，Dependabot 就是一个机器人，用来自动更新项目依赖，确保仓库代码依赖的包和应用程序一直处于最新版本。经过一段时间的试用，笔者认为这是一款不错的工具，尤其对于开源项目。

## Dependabot

> 通过将配置文件检入仓库，可启用 Dependabot 版本更新。 配置文件指定存储在仓库中的清单或其他包定义文件的位置。 Dependabot 使用此信息来检查过时的软件包和应用程序。 Dependabot 确定依赖项是否有新版本，它通过查看依赖的语义版本 (semver) 来决定是否应更新该版本。 对于某些软件包管理器，Dependabot 版本更新 也支持供应。 供应（或缓存）的依赖项是检入仓库中特定目录的依赖项，而不是在清单中引用的依赖项。 即使包服务器不可用，供应的依赖项在生成时也可用。 Dependabot 版本更新可以配置为检查为新版本供应的依赖项，并在必要时更新它们。

以上内容来自 GitHub 官方文档，简单的讲 Dependabot 就是一个没有感情的依赖更新机器人，在您的项目所依赖的上游软件包或应用程序发布新版本后，它会在您的 GitHub 仓库自动创建一个 PR 来更新依赖文件，并说明依赖更新内容，用户自己选择是否 merge 该 PR，效果如下图：

![Dependabot PR](https://cdn.suuny0826.com/large/ad5fbf65gy1gwybrb0l31j21z0144tud.jpg)

### 开启 Dependabot

开启方式比较简单，仅需将 `dependabot.yml` 配置文件放入仓库的 `.github` 目录中即可开启。之后 Dependabot 就会自动提交 PR 来更新您项目中的依赖项了。您也可以在 GitHub 页面上进行操作，在仓库页面通过 `Insights` -> `Dependency graph` -> `Dependabot` -> `Enable Dependabot` 路径即可开启，之后就可以点击 `Create config file` 来创建配置文件了。

![开启 Dependabot](https://cdn.suuny0826.com/large/ad5fbf65gy1gwyc6ro8brj21zq0vathl.jpg)

配置完成后，即可看到需要监控的依赖文件和上次检查更新的时间。

![](https://cdn.suuny0826.com/large/ad5fbf65gy1gwycg01mi7j21wo0ke11x.jpg)

### 配置 dependabot.yml

文件的配置也相对较为简单的直接，`version`、`updates`、`package-ecosystem` 、`schedule` 是必填的，还可以配置 `registries` 来指定私有仓库地址及认证信息。下面这个是官方示例，该示例中为 `npm` 和 `Docker` 配置了依赖自动更新，同时指定其依赖文件的地址和更新频率。有意思的是，在下面这个示例中，如果 Docker 依赖项已过时很久，可能会先执行 `daily` 安排，直到这些依赖项达到最新状态，然后降回每周安排。更多内容，可以参考[官方文档](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/configuration-options-for-dependency-updates)。

```yaml
# Basic dependabot.yml file with
# minimum configuration for two package managers

version: 2
updates:
  # Enable version updates for npm
  - package-ecosystem: "npm"
    # Look for `package.json` and `lock` files in the `root` directory
    directory: "/"
    # Check the npm registry for updates every day (weekdays)
    schedule:
      interval: "daily"

  # Enable version updates for Docker
  - package-ecosystem: "docker"
    # Look for a `Dockerfile` in the `root` directory
    directory: "/"
    # Check for updates once a week
    schedule:
      interval: "weekly"
```

### 支持的包管理器

目前 Dependabot 支持很多包管理器，具体内容可以参考下表：

- 要用于 `dependabot.yml` 文件中的 YAML 值
- 支持的包管理器版本
- 是否支持私有 GitHub 仓库或注册表中的依赖项
- 是否支持供应的依赖项

Package manager | YAML value      | Supported versions | Private repositories | Private registries | Vendoring 
---------------|------------------|------------------|:---:|:---:|:---:
Bundler        | `bundler`        | v1, v2           | | **✓** | **✓** |
Cargo          | `cargo`          | v1               | **✓** | **✓** | |
Composer       | `composer`       | v1, v2           | **✓** | **✓** | |
Docker         | `docker`         | v1               | **✓** | **✓** | |
Hex            | `mix`            | v1               | | **✓** | |
elm-package    | `elm`            | v0.19            | **✓** | **✓** | |
git submodule  | `gitsubmodule`   | N/A (no version) | **✓** | **✓** | |
GitHub Actions | `github-actions` | N/A (no version) | **✓** | **✓** | |
Go modules     | `gomod`          | v1               | **✓** | **✓** | **✓** |
Gradle         | `gradle`         | N/A (no version)   | **✓** | **✓** | |
Maven          | `maven`          | N/A (no version)   | **✓** | **✓** | |
npm            | `npm`            | v6, v7           | **✓** | **✓** | |
NuGet          | `nuget`          | <= 4.8 | **✓** | **✓** | |
pip            | `pip`            | v21.1.2          | | **✓** | |
pipenv         | `pip`            | <= 2021-05-29    | | **✓** | |
pip-compile    | `pip`            | 6.1.0            | | **✓** | |
poetry         | `pip`            | v1               | | **✓** | |
Terraform      | `terraform`      | >= 0.13, <= 1.0  | **✓** | **✓** | |
yarn           | `npm`            | v1               | **✓** | **✓** | |
<!-- markdown-link-check-disable-next-line -->
更多内容可以参考[官方文档](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/about-dependabot-version-updates#supported-repositories-and-ecosystems)。

## 亮点及注意事项

经过一段时间的使用，笔者发现 Dependabot 的一些细节做的很有意思。以 [kubecm](https://github.com/sunny0826/kubecm) 为例，笔者在项目里配置了 `go.mod` 和 `github-actions` 依赖的自动升级，依赖升级的 PR 是直接修改 `go.mod` 和 `go.sum`。如果同时有多个 Dependabot 触发的 PR 时，在合并一个 PR 之后，其他的 PR 会显示代码冲突，这里无需手动处理代码冲突，Dependabot 会自动处理冲突并重新提交代码，自动化程度很高。

需要注意的是**请勿盲目升级依赖到最新版**，对于项目来说，使用 Dependabot 的前提是有较为完善的 CI 单元测试流程来保证在依赖升级后应用的可用性，否则盲目的升级会导致更多的麻烦。

## 结语

依赖管理一直都是应用开发管理的一大难点，尤其对于一些小型开源项目，维护人手有限且无法高效获得依赖包的最新版本号。Dependabot 很好的解决了这一问题，当有依赖更新时都会自动推送 PR 来更新依赖，项目维护者只需提高测试覆盖率和增加单元测试用例，保证项目可用性即可。

## 参考
<!-- markdown-link-check-disable-next-line -->
- [About Dependabot version update - github.com](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/about-dependabot-version-updates)
