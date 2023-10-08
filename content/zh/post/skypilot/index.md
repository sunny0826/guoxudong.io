---
title: "SkyPilot：一键在任意云上运行 LLMs"
summary: "跨云平台运行AI和批处理作业的新框架"
authors: ["guoxudong"]
tags: ["AI","Cloud","Cross-platform"]
categories: ["AI"]
date: 2023-10-08T10:00:58+08:00
lastmod: 2023-10-08T10:00:58+08:00
draft: false
type: blog
image: "https://cdn.suuny0826.com/large/ad5fbf65ly1g0s2czlmofj21jl15o43r.jpg"
---
## 引言

在云计算日益普及的今天，如何有效、经济且无缝地在各种云平台上运行大语言模型（LLMs）、AI 和批处理作业成为了迫切的需求。SkyPilot 项目应运而生，旨在解决这一核心问题。它不仅抽象并简化了云基础设施操作，为用户提供了在任何云平台上轻松部署和扩展作业的能力，还通过自动获取多个云平台 GPU 的实时价格并进行实时比价，帮助用户选择最优的云平台来运行自己的 Job。这样做极大地降低了成本，提供了高度的 GPU 可用性，让云基础设施管理变得轻而易举。这样做极大的满足了市场对高效、低成本云资源利用的需求。通过 SkyPilot，企业和开发者能够最大化地利用 GPU，进一步推动了人工智能和大数据处理技术的发展，为云计算市场带来了新的可能。

## SkyPilot 介绍

SkyPilot 是一个为大型语言模型（LLMs）、AI 和批处理作业设计的框架，能在任何云平台上运行。它是一个 CLI 工具，对于熟悉命令行的用户来说，使用起来非常方便。仅通过一行命令就能启动一个完整的云环境，而无需关心具体的 VM、网络或安全组配置。相较于使用 Terraform 进行自行配置，SkyPilot 提供了更快的速度和更好体验。最重要的是，它允许用户在多个云平台上使用同一套配置，大大节省了学习和适配的时间。

SkyPilot 主要优势如下：

1. **云基础设施抽象**：简化在任何云上启动作业和集群的过程，便于扩展和对象存储访问。
2. **最大化 GPU 可用性**：自动在所有可访问的区域和云中分配资源，实现故障的自动切换。
3. **降低云成本**：采用 spot VMs 节省成本，自动选择最便宜的资源并自动关闭空闲集群。
4. **无代码更改**：兼容现有的 GPU、TPU 和 CPU 工作负载，无需改动代码。

除了上述优点，SkyPilot 的核心功能还在于简化云基础设施的管理。其核心功能包括：

- **Managed Spot**：通过优化资源分配，利用 spot VMs（临时虚拟机），为用户带来3-6倍的成本节省。并在遭遇预占事件时保证作业稳定运行。
- **Smarter Optimizer**：智能选择最便宜的虚拟机、区域或云平台，进一步节省用户成本。
- **其他功能和特点**：
   - **跨云平台支持**：支持在 AWS、Azure、GCP 等多个云平台上运行。
   - **简易扩展**：轻松地运行多个作业，这些作业将自动管理，确保资源的有效利用。
   - **对象存储访问**：简化对 S3、GCS、R2 等对象存储的访问，方便数据管理和存储。

目前支持的云提供商包括 AWS、Azure、GCP、Lambda Cloud、IBM、Samsung、OCI、Cloudflare 和 Kubernetes：

![支持的云平台](https://cdn.suuny0826.com/image/2023-10-08-cloud-logos-light.png)

## 快速开始

下面以在 Azure 上部署 [Llama-2 Chatbot](https://github.com/skypilot-org/skypilot/tree/master/llm/llama-2) 为例，介绍 SkyPilot 的使用方法。

### 安装

首先，确保您的系统中已安装了 Python 3.7 或更高版本。对于 Apple Silicon，建议使用 Python 3.8 或更高版本。以下是安装 SkyPilot 的步骤:

- 创建并激活一个新的 conda 环境（推荐，但非必需）:

```bash
conda create -y -n sky python=3.8
conda activate sky
```

- 使用 pip 安装 SkyPilot。你可以根据所使用的云服务提供商选择附加安装选项。例如，如果你想在 AWS 和 Azure 上使用 SkyPilot，你可以运行：

```bash
pip install "skypilot[aws,azure]"
```

或者，你可以选择安装所有可用的附加选项：

```bash
pip install "skypilot[all]"
```

此外，你还可以选择安装最新的 nightly 构建：

```bash
pip install -U "skypilot-nightly[all]"
```

或从源代码安装 SkyPilot：

```bash
git clone https://github.com/skypilot-org/skypilot.git
cd skypilot
pip install ".[all]"
```

### 配置

安装完成后，需进行配置以连接到你的云服务提供商，配置过程可能会因云服务提供商而异。整体配置相对简单，如果已经在本地配置了云服务提供商的 CLI，可以使用以下命令来检查 SkyPilot 是否可以正常访问已启动的云：

```bash
sky check
```

这将获得如下的输出，访问成功和失败一目了然：

![sky check](https://cdn.suuny0826.com/image/2023-10-08-202310081156979.png)

接下来简单介绍 Azure 的配置方法，其他云的配置方法请参考 [官方文档](https://skypilot.readthedocs.io/en/latest/getting-started/installation.html#cloud-account-setup)。

- 安装 [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?WT.mc_id=AZ-MVP-5005283)
- 运行 `az login` 命令以登录到 Azure CLI。
- 运行 `az account subscription list` 命令可以获取你账户下的 `subscription_id` 列表。
- 运行 `az account set -s <subscription_id>` 命令可以设置要使用的订阅。

    ```bash
    # Login
    az login
    # Set the subscription to use
    az account set -s <subscription_id>
    ```

- 最后再次运行 `sky check` 检查是否配置成功。

### 创建和运行 Llama-2 Chatbot

以下仅为简要步骤，详细操作请参考[官方文档](https://github.com/skypilot-org/skypilot/tree/master/llm/llama-2)。

#### 前提条件

- 申请使用 Llama-2 模型，进入[申请页面](https://ai.meta.com/resources/models-and-libraries/llama-downloads/)，申请使用模型。
- 从 huggingface 获取访问令牌，在 huggingface [生成只读访问令牌](https://huggingface.co/settings/token)，并确保你的 huggingface 账户[可以访问 Llama-2 模型](https://huggingface.co/meta-llama/Llama-2-7b-chat/tree/main)。
- 在 `chatbot-hf.yaml` 文件中填写访问令牌。

    ```yaml
    envs:
    MODEL_SIZE: 7
    HF_TOKEN: <your-huggingface-token>
    ```

    ![Access granted](https://cdn.suuny0826.com/image/2023-10-08-20231008140311.png)

#### 使用 SkyPilot 运行 Llama-2 Chatbot

- 创建一个新的 YAML 文件，例如 `chatbot-meta.yaml`，并添加以下内容：

```yaml
resources:
  accelerators: V100:1
  disk_size: 1024

envs:
  MODEL_SIZE: 7
  HF_TOKEN: <your-huggingface-token> # TODO: Replace with huggingface token

setup: |
  set -ex

  git clone https://github.com/facebookresearch/llama.git || true
  cd ./llama
  pip install -e .
  cd -

  git clone https://github.com/skypilot-org/sky-llama.git || true
  cd sky-llama
  pip install torch==1.12.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113
  pip install -r requirements.txt
  pip install -e .
  cd -

  # Download the model weights from the huggingface hub, as the official
  # download script has some problem.
  git config --global credential.helper cache
  sudo apt -y install git-lfs
  pip install transformers
  python -c "import huggingface_hub; huggingface_hub.login('${HF_TOKEN}', add_to_git_credential=True)"
  git clone https://huggingface.co/meta-llama/Llama-2-${MODEL_SIZE}b-chat

  wget https://github.com/tsl0922/ttyd/releases/download/1.7.2/ttyd.x86_64
  sudo mv ttyd.x86_64 /usr/local/bin/ttyd
  sudo chmod +x /usr/local/bin/ttyd

run: |
  cd sky-llama
  ttyd /bin/bash -c "torchrun --nproc_per_node $SKYPILOT_NUM_GPUS_PER_NODE chat.py --ckpt_dir ~/sky_workdir/Llama-2-${MODEL_SIZE}b-chat --tokenizer_path ~/sky_workdir/Llama-2-${MODEL_SIZE}b-chat/tokenizer.model"
```

- 运行以下命令以启动集群并运行任务

    ```bash
    sky launch -c llama chatbot-meta.yaml
    ```

    ![launch](https://cdn.suuny0826.com/image/2023-10-08-202310081456420.png)

- 打开另一个终端，运行以下命令以将本地端口 7681 与集群中的端口 7681 进行绑定

    ```bash
    ssh -L 7681:localhost:7681 llama
    ```

- 在浏览器中打开 `http://localhost:7681` 并开始聊天！

    ![ttyd chat](https://cdn.suuny0826.com/image/2023-10-08-202310081711404.png)

在这个示例中，`llama` 是你的集群名称，`chatbot-meta.yaml` 是你的任务配置文件。在几分钟内，集群将被创建和配置，任务将在 Azure 的 V100 GPU 实例上运行。

### 停止并清理集群

当使用完成后，可以使用以下命令停止或清理集群：

- 停止集群

    ```bash
    sky stop lama  # or pass your custom name if you used "-c <other name>"
    ```

- 您可以使用以下命令重启已停止的群集并重新启动 Chatbot：

    ```bash
    sky launch chatbot-meta.yaml -c llama --no-setup
    ```

    `--no-setup`：停止的集群会保留其磁盘内容，因此可以跳过 setup 步骤。
- 彻底清理集群

    ```bash
    sky down llama  # or pass your custom name if you used "-c <other name>"
    ```

清理完成后，可以使用 `sky status` 命令来查看集群，其可以查看你在不同 regions/clouds 中的所有集群。

## 进阶使用

除了上文中介绍的基本使用方法外，SkyPilot 还提供了更多的功能，下面将介绍一些进阶功能。

### 显示支持的 GPU/TPU/accelerators 及其价格

可以在任务 YAML 的 `accelerators` 字段或 CLI 命令的 `--gpus` flag 中显示的设置名称和数量。例如，如果该表显示支持 8xV100，那么上述命令将接受字符串 `V100:8`。

而各个云给出的 GPU 型号及其价格总是给人一种眼花缭乱的感觉，SkyPilot 将相同型号的 GPU 及价格进行了统一的整理与命名，并提供了一个命令来显示当前支持的 GPU/TPU/accelerators 及其价格：

```bash
sky show-gpus <gpu>
```

### Public IP 与 Ports

如果您你喜欢使用 ssh 或 gradio 的方式来访问您的集群，可以使用以下命令来获取集群的 Public IP：

```bash
sky status --ip <your-custom-name>
```

同时，如果您希望开放一些端口，则可以使用 `resources.ports` 来开放指定端口：

```yaml
resources:
# ports: 8888
  ports:
    - 8888
    - 10020-10040
    - 20000-20010
```

或者直接在 CLI 命令中使用 `--ports` 来指定：

```bash
sky launch -c jupyter --ports 8888 jupyter_lab.yaml
```

### 快速启动 GPU/CPU/TPU 实例

SkyPilot 还提供交互式节点，即用户在公有云上快速拉起指定单节点 VM，只需简单的 CLI 命令，无需 YAML 配置文件即可快速访问实例。

- `sky gpunode`
- `sky cpunode`
- `sky tpunode`

```bash
# Launch a default gpunode.
sky gpunode

# Do work, then log out. The node is kept running. Attach back to the
# same node and do more work.
sky gpunode

# Create many interactive nodes by assigning names via --cluster (-c).
sky gpunode -c node0
sky gpunode -c node1

# Port forward.
sky gpunode --port-forward 8080 --port-forward 4650 -c cluster_name
sky gpunode -p 8080 -p 4650 -c cluster_name

# Sync current working directory to ~/workdir on the node.
rsync -r . cluster_name:~/workdir
```

### 显示已经运行集群的预估成本

SkyPilot 同样提供了一个命令来显示已经运行集群的预估成本：

```bash
sky cost-report
```

注意：该 CLI 还属于试验性质。估计成本是根据群集状态的本地缓存计算的，可能并不准确。

### 获取 Azure 与 GCP 全球区域信息

默认情况下，SkyPilot 支持 AWS 上的大部分全球区域，仅支持 GCP 和 Azure 上的美国区域。如果您指定美国以外的 region，将会得到如下报错：

```bash
ValueError: Invalid region 'australiaeast'
List of supported azure regions: 'centralus, eastus, eastus2, northcentralus, southcentralus, westcentralus, westus, westus2, westus3'
```

如果您想使用所有全球地区，需要运行额外的命令来获取 Azure 和 GCP 的全球区域信息：

```bash
version=$(python -c 'import sky; print(sky.clouds.service_catalog.constants.CATALOG_SCHEMA_VERSION)')
mkdir -p ~/.sky/catalogs/${version}
cd ~/.sky/catalogs/${version}
# GCP
pip install lxml
# Fetch all regions for GCP
python -m sky.clouds.service_catalog.data_fetchers.fetch_gcp --all-regions

# Azure
# Fetch all regions for Azure
python -m sky.clouds.service_catalog.data_fetchers.fetch_azure --all-regions
```

更多内容见 [Frequently Asked Questions](https://skypilot.readthedocs.io/en/latest/reference/faq.html#advanced-how-to-make-skypilot-use-all-global-regions)。

## 结语

SkyPilot 不仅仅是一个为开发者和企业提供便捷的云资源管理和优化方案的工具，它更是一个为未来的云计算发展趋势奠定基础的项目。通过 SkyPilot，用户可以在不同的云平台上自如地部署和管理他们的应用，开发者和企业可以将更多的精力投入到实现他们的业务目标上，而非消耗在繁琐的云资源管理任务中。随着 SkyPilot 的不断完善和发展，未来的云计算将会变得更加高效、经济和人性化。

## 参考资料

- [SkyPilot Document](https://skypilot.readthedocs.io/en/latest/index.html)
- [skypilot-org/skypilot](https://github.com/skypilot-org/skypilot)
- [Run LLaMA LLM chatbots on any cloud with one click](https://github.com/skypilot-org/skypilot/tree/master/llm/llama-chatbots)
- [How to install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?WT.mc_id=AZ-MVP-5005283)
