---
title: "基础设施设施即代码（IaC）平台 Pulumi | 混合云管理利器"
summary: "本文将介绍现代的基础设施设施即代码（IaC）平台 Pulumi。"
authors: ["guoxudong"]
tags: ["Pulumi", "IaC", "基础设施即代码"]
categories: ["IaC"]
date: 2021-05-18T13:37:31+08:00
lastmod: 2021-05-18T13:37:31+08:00
draft: false
type: blog
image: https://tva1.sinaimg.cn/large/ad5fbf65gy1gqnpvnkbo2j20xc0hidkn.jpg
---
## 前言

在之前的文章中，笔者介绍过 [AWS CDK](../aws-cdk-introduction) ，其是 AWS 开源的一款开发框架，使用常用的编程语言（如 TypeScript、Python 等），利用函数快速构建代码框架来配置、更新和管理云资源，但只支持 AWS 资源的定义和维护，其他公有云无法使用。而 
Pulumi 可以以同样的方式在其他公有云上完成与 AWS CDK 类似的工作。

## 介绍

Pulumi 是一个现代的基础设施设施即代码（IaC）平台。它利用现有的编程语言（TypeScript、JavaScript、Python、Go 和 .NET）及其原生生态系统通过 Pulumi SDK与云资源进行交互。可下载的 CLI、runtime、库和托管服务一起提供一种可靠的配置、更新和管理云基础架构的方式（这里的云既指 AWS、Azure、阿里云等，也指 Kubernetes）。

究其本质，就如 AWS CDK 是构建在 AWS CloudFormation 基础之上；Pulumi 的大部分能力则是构建在 Terraform 工具基础上的，其依托 Terraform 上丰富的 Provider，可以在大多数公有云和 Kubernetes 上配置、更新和管理资源。

## 结构

![Pulumi 的结构和主要组件](https://tva1.sinaimg.cn/large/ad5fbf65gy1gqnoo4y1r0j20yg0pcgnr.jpg)

程序结构如上图，Pulumi 代码是保存在一个项目中，该项目是一个包含程序源码和运行程序元数据的目录。程序编写完成后，只需在项目目录中运行 [Pulumi CLI](https://www.pulumi.com/docs/reference/cli/) 命令 `pulumi up`，就可以为你的程序创建了一个独立的、可配置的实例，称为堆栈（Stack）。堆栈类似于你在测试和部署应用程序更新时使用的不同部署环境。例如，你可以有不同的 dev、qa 和 prod 堆栈，并在其上测试和构建资源。同时还提供了 `pulumi new` 和 `pulumi destroy` 等命令来帮助构建和销毁项目和堆栈。

## 优势

Pulumi 可以让你使用最喜欢的编程语言在多云（包括 AWS、Azure、谷歌云、Kubernetes、OpenStack等）上配置和管理资源。它对众多的云基础设施和应用程序非常有效，包括容器、虚拟机、数据库、云服务和 Serverless。

由于这种广泛的支持场景，使得许多工具与 Pulumi 的能力相重叠。其中许多是互补的，可以一起使用；而有些则是 "非此即彼"。而 Pulumi 的优势在于：

- **多语言支持**
    支持常用的编程语言来编写配置，学习成本低。
- **混合云支持**
    维护人员可以使用 Pulumi 来管理和维护多个公有云、OpenStack 和 Kubernetes。
- **组件可重复使用**
    因为使用的是编程语言开发，可以进行一些逻辑的抽象和方法的编写，免去了每次配置都需要拷贝大量的重复配置或重复操作的麻烦。
- **堆栈**
    就如前文所述，每个环境都可以维护一个堆栈（Stack），而这些堆栈可以管理大量云资源，开发者无需去记录每次都开启了哪些服务，使用了哪些资源，这里都会被记录在堆栈中。如果堆栈创建失败，则会进行回滚，之前创建的资源也会被销毁，这样就避免了大量无聊的，由于失误造成重复劳动和危害；同样的，如果删除堆栈，则可以一次性释放堆栈中的全部资源，大大提升了清理的准确性和效率。

## 结语

Pulumi 的使用体验虽然不及 AWS CDK，但是其广泛的公有云支持大大的便利了混合云用户；与 Terraform 相比，Pulumi 使用常用编程语言来编写，这大大降低了学习成本，同时可以根据使用场景抽象出各种方法，而不是每次都是通过 Python 或其他编程语言拼接出 HCL 配置，再通过 Terraform 来管理资源。Pulumi 对于云资源管理者，特别是混合云管理者无疑是一个非常不错的选择。
