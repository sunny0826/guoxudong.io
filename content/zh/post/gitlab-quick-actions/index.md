---
title: "GitLab 冷知识：Quick Actions 快速操作 Issue"
summary: "使用 Quick Actions 在评论中快速操作 GitLab 的 Issue、Merge Request、Epic"
authors: ["guoxudong"]
tags: ["GitLab", "DevOps"]
categories: ["GitLab 冷知识"]
date: 2022-02-23T10:05:26+08:00
lastmod: 2022-02-23T10:05:26+08:00
draft: false
type: blog
image: "https://tvax1.sinaimg.cn/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg"
---
## 前言

使用 GitLab 进行项目管理和协作开发时最离不开的就是 Epic、Issue、Merge Request 这项目管理三剑客了。但在实际操作中，PM 或 Maintainer 需要花费大量的时间创建它们并添加如 `label`、`assign`、`weight`、`health_status` 等信息，同时还要将其与相关 Epic、Issue 进行关联并加入 Milestone 当中，执行这些操作需要在 GitLab UI 点击大量的选择按钮与下拉菜单，非常的耗时。

## Quick Actions

Quick Actions 的诞生就是为了解决上面提到的这些痛点，用户只需在 Epic、Issue 和 Merge Request 的**描述**或**评论**中键入 `/`，就可以获得 Quick Actions 命令提示，选择想要执行操作的命令并填入参数，最后完成创建或提交评论即可一次性完成输入的所有命令！这也就是为什么创建同样一个 Issue 你需要 1min 而我只需要 10s 的原因。

![action](https://tvax4.sinaimg.cn/large/ad5fbf65gy1gzn8yganvvj21c20i2dio.jpg)

### 使用说明

 GitLab 中所有 Epic、Issue 和 MR 的描述以及评论中都可以使用 Quick Actions，用户可以使用 GitLab UI、API 以及 Email 来创建这些  Epic、Issue 和 MR，这也大大方便了 API 的调用，通过 API 来创建 Issue 可以不再配置 label、assign、weight 等参数，直接将其以 Quick Actions Command 的形式输入在 Issue 的 Description 中就可以完成同样的操作，非常好用！

Quick Actions 配合 API 使用：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
"https://jihulab.com/api/v4/projects/4/issues?title=new%20Issues&description=/assign%20@guoxudong%0A/weight%2010"
# 通过 description 就完成了 assign 和 weight 的功能
# %20 = 空格
# %0A = 换行
```

在使用 Quick Actions 时，请务必将每条命令放在**单独的一行**中，否则 GitLab 将无法正确检测和执行命令。

### 参数使用

大部分 Quick Actions 都需要配合参数使用，比如：`/assign` 命令需要指定用户名。GitLab 也提供了快速完成字符来帮助用户迅速输入参数，只需输入相应字符，就会得到相应的提示。

| Character | Autocompletes | Relevant matches shown |
| :-------- | :------------ | :---- |
| `~`       | Labels | 20 |
| `%`       | Milestones | 5 |
| `@`       | Users and groups | 10 |
| `#`       | Issues | 5 |
| `!`       | Merge requests | 5 |
| `&`       | Epics | 5 |
| `$`       | Snippets | 5 |
| `:`       | Emoji | 5 |
| `/`       | Quick Actions | 100 |

除此之外，如果是手动输入参数，则必须使用双引号（`"`）包裹参数，除非参数仅由以下字符组成：

- ASCII 字母
- 数字 (0-9)
- 符号：`_`、`-`、`?`、`.`、`&`、`@`

参数**区分大小写**，使用自动完成(Autocompletes)选择的参数，会帮忙选定正确且符合要求的参数。

### 常见用法

多数情况下，用户只需在 Issue、Epic、MR 的描述或评论中键入 `/`，Quick Actions 就会自动提示哪些命令可以使用，再配合自动完成(Autocompletes)字符，用户可以非常快速的完成任务。这里例举一些常见用法，以供参考：

#### 快速创建 Issue

如下图，在创建 Issue 的同时，快速设置了 label，assign 给了相应负责人，同时与相关 Epic 关联，并加入 `14.11` 里程碑中，并 `@` 了相关人员，最后配合快捷键  `Command` + `Enter` 完成提交。

![create issue](https://tvax2.sinaimg.cn/large/ad5fbf65gy1gznb94447lj21ty0s6te9.jpg)

#### 评论快速操作

如下图，这个 Issue 与 `#669` 重复了，通过 Quick Actions 添加 label，标出重复，修改 Issue 标题，重新指派开发者，最后关闭这个 Issue。

![comment quick action](https://tvax3.sinaimg.cn/large/ad5fbf65gy1gznc8f12hvj20xs0hqtbm.jpg)

## 结语

对于高强度使用 GitLab 的用户，Quick Actions 和 Keyboard 快捷键配合使用可以大大提升工作效率与使用体验，十分推荐尝试。更多内容见[官方文档](https://docs.gitlab.com/ee/user/project/quick_actions.html#gitlab-quick-actions)。
