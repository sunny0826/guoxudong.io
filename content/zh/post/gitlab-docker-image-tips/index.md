---
title: "GitLab Docker 镜像实用技巧"
summary: "Docker, Inc. 道歉了，然后呢？"
authors: ["guoxudong"]
tags: ['Docker', 'GitLab']
categories: [ 'GitLab' ]
date: 2023-03-30T08:36:01+08:00
lastmod: 2023-03-30T08:36:01+08:00
draft: false
type: blog
image: "https://cdn.suuny0826.com/image/2023-03-30-gitlab-docker-image-tips.png"
---
## 前言

前段时间 Docker, Inc. 宣布将[停止免费团队服务](https://www.infoworld.com/article/3690890/docker-sunsets-free-team-subscriptions-roiling-open-source-projects.html)的事情闹得沸沸扬扬，事情最终以 Docker, Inc. [撤销决定并道歉](https://www.docker.com/blog/we-apologize-we-did-a-terrible-job-announcing-the-end-of-docker-free-teams/)结束。笔者并没有追赶这个“热点”对这件事进行评论或抨击，现在这个热度过去了，笔者希望就着这个事情分享一些自己的观点以及日常工作可以用到的很实用技巧。

## 浅见

事实上，国内很少有企业直接使用 DockerHub 作为容器镜像仓库，这个生态位上有更多体验更好且免费提供服务的玩家。既然如此，为何 Docker, Inc. 的声明会在国内外掀起如此大的风波？笔者认为更多的是大量的开源组织/项目将他们的容器镜像托管在了 DockerHub 上，有的托管时间甚至已经持续了10年（DockerHub 于 2013 年上线），如果无法继续使用，迁移工作无疑巨大且痛苦。

除了这部分因素，笔者认为还有其他两个因素：

**耸人听闻的标题**

《DockerHub 开始清退开源组织和开源项目》这个标题太吓人了。很多人只看了一下标题，就已经脑补了文章的内容了。这是自媒体（包括我）的通病，务实的标题无法吸引足够多的读者，于是各种 UC 体标题充斥着整个互联网，网上甚至诞生了专门教授这种技能的课程。这是大部分自媒体/博客作者不得不面对的事情。要么文章没人看，要么被骂成标题党，只能找个平衡点。

**镜像使用者的关注**

笔者认为这部分影响最大，因为容器镜像是分层存储的（Layered）。你的镜像可能是我的基础镜像，我的镜像也可能是你的基础镜像。 对于 `alpine`、`busybox` 或 `scratch` 等基础镜像，即使镜像地址或名称只进行了微小的修改，也会产生指数级增长的影响。 而像 GitLab CI、Drone、Tekton 这些基于容器技术构建的 CI/CD 工具更是会受到巨大的影响，一觉起来所有流水线都无法运行，这是一个多么可怕的噩梦啊。

## 一些小技巧

为了规避再有类似的事情发生，这里分享一些在使用 GitLab 时与容器镜像相关的小技巧，这些技巧小到可能在官方文档中都没有一页用来专门介绍，但是却实实在在可以帮我们规避一些前文中提到的问题。

### 获取依赖容器清单

一般在 GitLab CI 中 DockerHub 的基础镜像被广泛使用，这些广泛分布在 `.gitlab-ci.yml` 与 `Dockerfile` 中，如果您想要快速找到自己项目中都使用了哪些镜像，不妨试试以下两个命令。

1. 直接使用 `find` 命令来查看 `.gitlab-ci.yml` 中使用的镜像

```shell
find . -type f -iname '*ci.yml' -exec sh -c "grep 'image:' '{}' && echo {}" \;
```

2. GitLab API 提供了更简单的方法来查看查看 `Dockerfile` 中使用的镜像

```shell
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://${YOUR-GITLAB-HOST}/api/v4/projects/${YOUR-PROJECT-ID}/search?scope=blobs&search=FROM%20filename:Dockerfile*"
```

![运行结果](https://cdn.suuny0826.com/image/2023-03-30-20230330142936.png)

### 开启 Dependency Proxy

强烈建议所有 GitLab 用户都开启这个功能，该功能提供了的 Docker 镜像缓存机制，可以减少下载和拉取镜像所需的带宽和时间，有助于缓解之前 DockerHub 开启的拉取速率限制。配置十分简单，只需开启  [Dependency Proxy](https://docs.gitlab.cn/jh/user/packages/dependency_proxy) 功能，并在在 `.gitlab-ci.yml` 中的 `image` 字段加入 `${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}` 变量，这样每次运行 Pipeline 的时候之后在没有找到缓存镜像时才会去拉取一次镜像，大大提升了 CI/CD 的运行速率。配置如下：

```yaml
.test-python-version:
  script:
    - echo "Testing Python version:"
    - python --version

image-docker-hub:
  extends: .test-python-version
  image: python:3.11

image-docker-hub-dep-proxy:
  extends: .test-python-version
  image: ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/python:3.11
```

缓存的镜像可以在 Group 级别的 `Package and container registries` -> `Dependency Proxy` 看到。

### 迁移镜像

将使用的基础镜像迁移到自建容器仓库，一般的团队都会使用比如 Harbor 来维护自己的容器镜像仓库，但如果维护人员有限，不想再单独维护一个容器镜像仓库，那么直接使用 GitLab Container Registry 也是一个不错的选择。

容器迁移工具推荐使用 [Skopeo](https://github.com/containers/skopeo)，相关的文章有很多，这里就只写一个简单的单容器迁移示例：

```shell
skopeo copy \
    --dest-tls-verify=false \
    --dest-creds=user-a:mypass123 \
    docker://docker.io/library/busybox:1.33-glibc \
    docker://registry-a-docker-registry:5000/mybusybox:1.33-glibc
```

## 结语

同样来自主打开源产品团队的笔者，更能与 Docker, Inc. 共情，高昂的维护成本、巨大的竞争压力、下行的经济形势，哪一个都足以压倒这家成立了 10 年的公司。我不会去批判他们的决定，大家都有各自的现状与苦衷。只是会思考对于一家主打开源产品的公司，什么样的商业模式才更能让开源项目健康、可持续的发展。
