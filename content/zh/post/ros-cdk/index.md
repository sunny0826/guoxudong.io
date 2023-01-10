---
title: "ROS CDK | 云上资源自动化部署新模式"
summary: "使用 ROS CDK 自动化部署云资源"
authors: ["guoxudong"]
tags: ["阿里云", "ROS CDK", "IaC", "基础设施即代码"]
categories: ["IaC"]
date: 2021-06-22T09:13:24+08:00
lastmod: 2021-06-22T09:13:24+08:00
draft: false
type: blog
image: https://cdn.suuny0826.com/large/ad5fbf65gy1grr2t5dhigj20p00anac1.jpg
---
## 前言

在之前的文章中，笔者分别介绍了 [AWS CDK](../aws-cdk-introduction) 和 [Pulumi](../pulumi-introduction) 两种目前比较流行的编程式 IaC 框架，通过使用熟悉的编程语言，用编程的方式快速定义云资源。即获得了基础设施即代码的便利，又增加了配置的可读性和可维护性，降低了心智负担，将云资源管理者从复杂的模板和各种 YAML/JSON 配置中解放出来。

与 AWS CloudFormation 和 Terraform 类似，阿里云也有自己的 IaC 产品：资源编排（ROS），使用 ROS 笔者将大量云资源的变更和部署抽象为 ROS Template，不但提高了工作效率还降低了出错的概率。与 AWS CDK 基于 CloudFormation 类似，阿里云也提供了是基于 ROS 的 ROS CDK，不过在先前的尝试中，ROS CDK 的体验不佳，且与 AWS CDK 还有一些差距，所以就暂时搁置了。

在 2021 阿里云开发者大会上，ROS CDK 的身影再次出现，在看完整个分享之后，再次激起了笔者对 ROS CDK 的兴趣，此次笔者还联系到了 ROS CDK  的几位核心开发，在他们的指导下利用一个周末的时间重新体验了 ROS CDK。

## ROS CDK

ROS CDK 是资源编排（ROS）提供的一种命令行工具和多语言 SDK，利用面向对象的高级抽象模式对云资源进行标准定义，从而快速构建云资源。

ROS CDK 以应用作为资源管理的入口，一个应用可管理多个资源栈，而每个资源栈中则可以有多个构件。构件可以理解为云上资源的组件，能包含一个或多个资源。

我们可以选择自己熟悉的编程语言（TypeScript/JavaScript/Java/Python/C#）编写应用代码声明想要部署的资源，ROS CDK 会将项目代码转换成 ROS 模板，然后使用该模板进行自动化部署。

如果使用过 AWS CDK 或者 Pulumi，上手 ROS CDK 会更加容易。

## 上手实践

ROS CDK 上手非常简单，只需安装好 CLI 工具，立刻就能利用面向对象的高级抽象模式对云资源进行标准定义，快速构建云资源。

### 安装

AWS CDK 类似，ROS CDK 也是使用 TypeScript 开发，安装前需要满足：

- `Node.js`：10.23.0 及以上版本
- `TypeScript`：2.7 及以上版本

使用 `npm` 进行安装：

```bash
# 安装 lerna
npm install lerna -g
# 安装 ros-cdk-cli
npm install @alicloud/ros-cdk-cli -g
```

安装完成后，可以使用 `-h` 来查看 ros-cdk 的功能列表：

```bash
ros-cdk -h
```

### 配置登录凭证

在安装好 ros-cdk-cli 之后就可以配置凭证连接阿里云了，这里需要注意的是要选择好 region，推荐加 `-g` 进行全局配置，否则每建一个 ROS CDK 项目都会要求重新配置（不加的话只是配置当前目录）。

```bash
# 推荐全局配置 -g
ros-cdk config -g
# 选择 endpoint
endpoint(optional, default:https://ros.aliyuncs.com):
# 选择 region
defaultRegionId(optional, default:cn-hangzhou):cn-shanghai
# 选择认证方式
[1] AK
[2] StsToken
[3] RamRoleArn
[4] EcsRamRole
[0] CANCEL

Authenticate mode [1...4 / 0]: 1
# 配置 AK/AS
accessKeyId:************************
accessKeySecret:******************************

 ✅ Your cdk configuration has been saved successfully!
```

### 初始化项目

初始化项目，与 AWS CDK 和 Pulumi 类似：

```bash
mkdir ros-cdk-simple-gitlab
cd ros-cdk-simple-gitlab
# 在这里选择生成项目的编程语言
ros-cdk init --language=typescript --generate-only=true
```

### 项目结构

生成的项目结构如下：

```bash
tree .
├── bin
│   └── ros-cdk-simple-gitlab.ts # 入口文件，定义应用和资源栈，一般无需修改
├── cdk.json
├── jest.config.js
├── lib
│   └── ros-cdk-simple-gitlab-stack.ts # 资源栈定义文件，主要修改该文件
├── package.json # 依赖文件，需要在该文件添加相应模块的依赖包
├── README.md
├── test
│   └── ros-cdk-simple-gitlab.test.ts # 单元测试文件
└── tsconfig.json
```

### 规划云资源

本文我们使用 ROS CDK 创建一套简单的云上环境，并在 ECS 上安装[极狐 GitLab](https://about.gitlab.cn/)，新建资源包括：

- VPC 1个
- VSwitch 1个
- 安全组 1个
- ECS 1台

资源之间关系为：

![可视化架构图](https://cdn.suuny0826.com/large/ad5fbf65gy1grqzmgfbsqj21020vgjug.jpg)

### Show me the code

首先需要导入依赖包，本文我们用到了 `@alicloud/ros-cdk-ecs` 和 `@alicloud/ros-cdk-ros` 两个，修改 `package.json`，添加依赖包：

```diff
{
  "name": "ros-cdk-simple-gitlab",
  "version": "0.1.0",
  "bin": {
    "ros-cdk-simple-gitlab": "bin/ros-cdk-simple-gitlab.js"
  },
  "scripts": {
    "build": "tsc",
    "test": "jest"
  },
  "devDependencies": {
    "@types/jest": "^25.2.1",
    "@types/node": "10.17.5",
    "typescript": "^3.9.7",
    "jest": "^25.5.0",
    "ts-jest": "^25.3.1",
    "ts-node": "^8.1.0",
    "babel-jest": "^26.6.3",
    "@babel/core": "^7.12.9",
    "@babel/preset-env": "7.12.7",
    "@babel/preset-typescript": "^7.12.7",
    "@alicloud/ros-cdk-assert": "^1.0.1"
  },
  "dependencies": {
    "@alicloud/ros-cdk-core": "^1.0.1",
+    "@alicloud/ros-cdk-ecs": "^1.0.0",
+    "@alicloud/ros-cdk-ros": "1.0.0"
  }
}
```

执行如下命令，安装依赖：

```bash
npm i
```

待依赖安装完成后，就可以开始编写代码，构建云资源了。修改 `lib/ros-gitlab-stack.ts` 文件：

```ts
import * as ros from '@alicloud/ros-cdk-core';
import * as ecs from '@alicloud/ros-cdk-ecs';
import * as ROS from '@alicloud/ros-cdk-ros';

export class RosGitlabStack extends ros.Stack {
  constructor(scope: ros.Construct, id: string, props?: ros.StackProps) {
    super(scope, id, props);
    new ros.RosInfo(this, ros.RosInfo.description, "This is the simple ros cdk app example.");
    // The code that defines your stack goes here
    // 下载 GItLab 地址
    let GitLabDownloadUrl = 'https://omnibus.gitlab.cn/el/7/gitlab-jh-13.12.4-jh.0.el7.x86_64.rpm'
    // 本地 IP，用于安全组
    let YourIpAddress = '101.224.119.123'
    // 安全组开放的端口
    let PortList = ['22', '3389', '80']
    // ECS 密码，用于 SSH 登录
    let YourPass = 'eJXuYnNT6LD4PS'
    // URL 地址，用于访问安装好的 GitLab
    let ExternalUrl = ''
    

    // 构建 VPC
    const vpc = new ecs.Vpc(this, 'vpc-from-ros-cdk', {
      vpcName: 'test-jh-gitlab',
      cidrBlock: '10.0.0.0/8',
      description: 'test jh gitlab'
    });

    // 构建 VSwitch
    const vsw = new ecs.VSwitch(this,'vsw-from-ros-cdk',{
      vpcId: vpc.attrVpcId,
      zoneId: 'cn-shanghai-b',
      vSwitchName: 'test-jh-gitlab-vsw',
      cidrBlock:'10.0.0.0/16',
    })

    // 构建安全组
    const sg = new ecs.SecurityGroup(this, 'ros-cdk-gitlab-sg', {
      vpcId: vpc.attrVpcId,
      securityGroupName: 'test-jh-gitlab-sg',
    })

    // 为安全组增加记录
    for (let port of PortList) {
      new ecs.SecurityGroupIngress(this, `ros-cdk-sg-ingree-${port}`, {
        portRange: `${port}/${port}`,
        nicType: 'intranet',
        sourceCidrIp: `${YourIpAddress}`,
        ipProtocol: 'tcp',
        securityGroupId: sg.attrSecurityGroupId,
      }, true)
    }

    // 等待逻辑，用于等待 ECS 中应用安装完成
    const ecsWaitConditionHandle = new ROS.WaitConditionHandle(this, 'RosWaitConditionHandle', {
      count: 1
    })

    const ecsWaitCondition = new ROS.WaitCondition(this, 'RosWaitCondition', {
      timeout: 1200,
      handle: ros.Fn.ref('RosWaitConditionHandle'),
      count: 1
    })

    // 构建 ECS
    const git_ecs = new ecs.Instance(this, 'ecs-form-ros-cdk', {
      vpcId: vpc.attrVpcId,
      vSwitchId: vsw.attrVSwitchId,
      imageId: 'centos_7',
      securityGroupId: sg.attrSecurityGroupId,
      instanceType: 'ecs.g7.xlarge',
      instanceName: 'jh-gitlab-ros',
      systemDiskCategory: 'cloud_essd',
      password: `${YourPass}`,
      userData: ros.Fn.replace({ NOTIFY: ecsWaitConditionHandle.attrCurlCli }, `#!/bin/bash
      sudo yum install -y curl policycoreutils-python openssh-server perl
      sudo systemctl enable sshd
      sudo systemctl start sshd
      sudo firewall-cmd --permanent --add-service=http
      sudo firewall-cmd --permanent --add-service=https
      sudo systemctl reload firewalld

      sudo firewall-cmd --permanent --add-service=http
      sudo firewall-cmd --permanent --add-service=https
      sudo systemctl reload firewalld

      sudo yum install postfix
      sudo systemctl enable postfix
      sudo systemctl start postfix

      wget ${GitLabDownloadUrl}

      sudo EXTERNAL_URL=${ExternalUrl} rpm -Uvh gitlab-jh-13.12.4-jh.0.el7.x86_64.rpm

      NOTIFY
      `),
    })

    // 输出，将构建 ECS 的公网 IP 输出在 ROS Stack 中
    new ros.RosOutput(this, 'ips-output', {
      description: 'ipAddress',
      value: git_ecs.attrPublicIp,
    })
  }
}
```

执行如下命令，查看生成的模板文件：

```bash
ros-cdk synth --json
{
  "Description": "This is the simple ros cdk app example.",
  "ROSTemplateFormatVersion": "2015-09-01",
  "Resources": {
    "vpc-from-ros-cdk": {
      "Type": "ALIYUN::ECS::VPC",
      "Properties": {
        "CidrBlock": "10.0.0.0/8",
        "Description": "test jh gitlab",
        "EnableIpv6": false,
        "VpcName": "test-jh-gitlab"
...
```

确认无误，开始部署云资源：

```bash
ros-cdk deploy

 ✅ The deployment(create stack) has completed!
RequestedId: 6BCBC6AA-FA5C-419E-9DF9-14DF9C6D4461
StackId: 54901066-6228-46d8-a0ff-4bf523a95f16
```

资源栈部署成功，到控制台查看资源栈部署情况了

![资源栈开始部署](https://cdn.suuny0826.com/large/ad5fbf65gy1grr0tenvhvj21iy0fk0uz.jpg)

等待部署成功，在输出中 copy 公网IP，将其写入本地 `hosts` 文件：

![获取公网 IP](https://cdn.suuny0826.com/large/ad5fbf65gy1grr1376gofj217e0i6dhf.jpg)

```bash
# 写入 /etc/hosts
echo "47.100.198.131  jh.gxd">>/etc/hosts
```
<!-- markdown-link-check-disable-next-line -->
完成后访问 [http://jh.gxd](http://jh.gxd) 就可以使用 ROS CDK 部署的极狐 GitLab 了！

![首页](https://cdn.suuny0826.com/large/ad5fbf65gy1grr17ezsf0j225e15ojy0.jpg)

测试完成后，删除资源栈，清理云资源：

```bash
ros-cdk destroy
The following stack(s) will be destroyed(Only deployed stacks will be displayed).

RosCdkSimpleGitlabStack

Please confirm.(Y/N)
Y

 ✅ Deleted
RequestedId: F761DE09-F8E3-431C-B897-06667207A6C5
```

## 一些不足

总体来说，ROS CDK 有着不错的使用体验，但还有些许不足：

- ROS CDK 缺乏默认的最佳实践配置，如 AWS CDK  在创建 VPC 时，只需一行代码 `new Vpc(scope, 'Vpc', { maxAzs: 3, natGateways: 1 })` 就会自动创建 3 AZ 的 VSwitch 和 NAT Gateway，ROS 中并不支持这样的写法
- 缺乏资源动作方法，如我要给 ECS 打 Tag，只能在 `tags` 字段进行配置，而无法使用类似 `addTag()` 的方法来完成这个动作，增加端口或绑定资源也是如此
- 不支持在 CLI 终端实时查看 Stack 事件，需要登录阿里云控制台才能看到 Stack 事件，体验十分割裂
- 不支持在 CLI 终端查看输出内容，希望能增加 `cdk.CfnOutput()` 这样的在终端打印输出内容的方法

## 结语

总体来说，笔者对 ROS CDK 的使用体验还是十分满意的，推荐大家使用 ROS CDK 去尝试创建和管理云资源，后续笔者也会分享一些较为复杂的 ROS CDK 实践。感谢来自阿里云的 **闲炎**、**王怀宇**、**白晨旭** 同学的帮助，在周末休息时间还能为我答疑解惑。

本文涉及代码已经全部上传 GitHub，地址：[https://github.com/sunny0826/ros-cdk-simple-gitlab](https://github.com/sunny0826/ros-cdk-simple-gitlab)

## 参考
<!-- markdown-link-check-disable-next-line -->
- [从原子操作走向模板部署，详解云上资源自动化部署新模式](https://developer.aliyun.com/article/784662)
- [ROS  CDK](https://help.aliyun.com/document_detail/204690.html?spm=a2c4g.11186623.6.644.1eb37f2eXMjNHy)
