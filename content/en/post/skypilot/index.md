---
title: "SkyPilot: Run LLMs and AI on any cloud with one click"
summary: "A New Framework for Running AI and Batch Jobs Across Cloud Platforms"
authors: ["guoxudong"]
tags: []
categories: []
date: 2023-10-08T10:00:58+08:00
lastmod: 2023-10-08T10:00:58+08:00
draft: false
type: blog
image: "https://cdn.suuny0826.com/image/2023-10-08-skypilot.png"
---
## Introduction

With the increasing prevalence of cloud computing today, there is an urgent need to effectively, economically, and seamlessly run large language models (LLMs), AI, and batch jobs on various cloud platforms. The SkyPilot project was born to address this core issue. It not only abstracts and simplifies cloud infrastructure operations, giving users the ability to easily deploy and scale jobs on any cloud platform but also automatically fetches real-time GPU prices from multiple cloud platforms for real-time price comparison, helping users choose the best cloud platform to run their jobs. This greatly reduces costs, offers high GPU availability, and makes cloud infrastructure management a breeze. This approach greatly meets the market demand for efficient, low-cost cloud resource utilization. Through SkyPilot, enterprises and developers can maximize GPU utilization, further promoting the development of artificial intelligence and big data processing technologies, bringing new possibilities to the cloud computing market.

## SkyPilot

SkyPilot is a framework designed for large language models (LLMs), AI, and batch jobs that can run on any cloud platform. It's a CLI tool and is very convenient for users familiar with the command line. With just one command, a complete cloud environment can be started without worrying about the specifics of VM, network, or security group configurations. Compared to self-configuring with Terraform, SkyPilot offers faster speed and a better experience. Most importantly, it allows users to use the same configuration on multiple cloud platforms, saving a lot of learning and adaptation time.

Key advantages of SkyPilot include:

1. **Cloud Infrastructure Abstraction**: Simplifies the process of launching jobs and clusters on any cloud, making it easy to scale and access object storage.
2. **Maximized GPU Availability**: Automatically allocates resources in all accessible regions and clouds, achieving automatic failover.
3. **Reduced Cloud Costs**: Uses spot VMs to save costs, automatically selects the cheapest resources, and shuts down idle clusters.
4. **No Code Changes Needed**: Compatible with existing GPU, TPU, and CPU workloads without code modifications.

In addition to these advantages, a core feature of SkyPilot is simplifying cloud infrastructure management. Its key features include:

- **Managed Spot**: Optimizes resource allocation by leveraging spot VMs (temporary virtual machines), offering users a 3-6x cost saving. It also ensures stable job operation in case of preemption events.
- **Smarter Optimizer**: Smartly chooses the cheapest virtual machine, region, or cloud platform to further save user costs.
- **Other Features and Characteristics**:
   - **Cross-Cloud Platform Support**: Runs on AWS, Azure, GCP, and other cloud platforms.
   - **Easy Expansion**: Easily runs multiple jobs, which are automatically managed to ensure effective resource utilization.
   - **Object Storage Access**: Simplifies access to object storage like S3, GCS, R2, etc., facilitating data management and storage.

Currently supported cloud providers include AWS, Azure, GCP, Lambda Cloud, IBM, Samsung, OCI, Cloudflare, and Kubernetes:

![Supported Cloud Platforms](https://cdn.suuny0826.com/image/2023-10-08-cloud-logos-light.png)

## Quick Start

Here's how to use SkyPilot to deploy the [Llama-2 Chatbot](https://github.com/skypilot-org/skypilot/tree/master/llm/llama-2) on Azure.

### Installation

First, ensure you have Python 3.7 or higher installed on your system. For Apple Silicon, it's recommended to use Python 3.8 or higher. Here's how to install SkyPilot:

- Create and activate a new conda environment (recommended but not mandatory):

```bash
conda create -y -n sky python=3.8
conda activate sky
```

- Install SkyPilot using pip. Depending on the cloud service providers you plan to use with SkyPilot, you can choose additional installation options. For instance, if you wish to use SkyPilot on AWS and Azure, run:

```bash
pip install "skypilot[aws,azure]"
```

Alternatively, you can install all available additional options:

```bash
pip install "skypilot[all]"
```

Moreover, you can opt to install the latest nightly build:

```bash
pip install -U "skypilot-nightly[all]"
```

Or install SkyPilot from the source code:

```bash
git clone https://github.com/skypilot-org/skypilot.git
cd skypilot
pip install ".[all]"
```

### Configuration

After installation, some initial configurations are necessary to connect to your cloud service provider. These configuration steps may vary depending on the cloud service provider. The overall configuration process is relatively simple. If you've already set up the corresponding cloud service CLI locally, you can use the following command to check if SkyPilot can access it properly:

```bash
sky check
```

You'll

 see output indicating the access status for each cloud service:

![sky check](https://cdn.suuny0826.com/image/2023-10-08-202310081156979.png)

Next, we'll briefly cover how to configure for Azure. For configurations for other clouds, refer to the [official documentation](https://skypilot.readthedocs.io/en/latest/getting-started/installation.html#cloud-account-setup).

- Install the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?WT.mc_id=AZ-MVP-5005283).
- Use the `az login` command to log into the Azure CLI.
- Use the `az account subscription list` command to obtain the `subscription_id` list for your account.
- Use the `az account set -s <subscription_id>` command to specify which subscription to use.

    ```bash
    # Login
    az login
    # Set the subscription to use
    az account set -s <subscription_id>
    ```

- Finally, run `sky check` again to verify the successful configuration.

### Creating and Running Llama-2 Chatbot

Below are basic steps; for detailed operations, please refer to the [official documentation](https://github.com/skypilot-org/skypilot/tree/master/llm/llama-2).

#### Prerequisites

- Visit [this link](https://ai.meta.com/resources/models-and-libraries/llama-downloads/) to apply for the Llama-2 model.
- Obtain an access token from huggingface, [generate a read-only access token on huggingface](https://huggingface.co/settings/token), and ensure your huggingface account [can access the Llama-2 model](https://huggingface.co/meta-llama/Llama-2-7b-chat/tree/main).
- Fill in the obtained access token in the `chatbot-meta.yaml` file.

    ```yaml
    envs:
      MODEL_SIZE: 7
      HF_TOKEN: <your-huggingface-token>
    ```

    ![Access granted](https://cdn.suuny0826.com/image/2023-10-08-20231008140311.png)

#### Running Llama-2 Chatbot with SkyPilot

- Create a new YAML file named `chatbot-meta.yaml` and add the following content:

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
  # download script has some issues.
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

- Run the following command to start the cluster and execute the task:

    ```bash
    sky launch -c llama chatbot-meta.yaml
    ```

    ![launch](https://cdn.suuny0826.com/image/2023-10-08-202310081742271.png)

    In the above steps, `llama` is the name of the cluster, and `chatbot-meta.yaml` is the task configuration file. Within a few minutes, SkyPilot will complete cluster creation, configuration, and task execution on Azure's V100 GPU.

- Open a new terminal and execute the following command to bind local

 port `7681` to the cluster's `7681` port:

    ```bash
    ssh -L 7681:localhost:7681 llama
    ```

- Visit `http://localhost:7681` in your browser to start the chat experience!

    ![ttyd chat](https://cdn.suuny0826.com/image/2023-10-08-202310081711404.png)

### Stopping and Cleaning Up the Cluster

Once the task is completed, you can use the following commands to stop or completely delete the cluster:

- Stop the cluster:

    ```bash
    sky stop lama  # or pass your custom name if you used "-c <other name>"
    ```

- Restart a stopped cluster and rerun Chatbot:

    ```bash
    sky launch chatbot-meta.yaml -c llama --no-setup
    ```

    Using `--no-setup` aims to skip the setup step since the stopped cluster has retained its disk contents.
- Completely delete the cluster:

    ```bash
    sky down llama  # or pass your custom name if you used "-c <other name>"
    ```

After cleanup, you can run `sky status` to view all your clusters in different regions/clouds.

## Advanced Usage

Beyond the basic methods mentioned above, SkyPilot has numerous advanced features. Here's a brief introduction to some of them.

### Display Supported GPU/TPU/Accelerators and Their Prices

You can set the name and number of GPU/TPU/accelerators in the task YAML's `accelerators` field or in the CLI's `--gpus` flag. For instance, if a supported list displays 8xV100, you can use `V100:8` in the `accelerators` field.

Different public clouds have confusing GPU model names and their prices. SkyPilot has standardized the naming and pricing of the same GPU model and provides a `show-gpus` command to display currently supported GPU/TPU/accelerators and their prices:

```bash
sky show-gpus <gpu>
```

### Public IP and Ports

If you prefer to access your clusters using ssh or gradio, you can use the following command to get the cluster's Public IP:

```bash
sky status --ip <your-custom-name>
```

Moreover, if you wish to open some ports, you can use `resources.ports` to specify ports to open:

```yaml
resources:
# ports: 8888
  ports:
    - 8888
    - 10020-10040
    - 20000-20010
```

Or directly specify in the CLI command with `--ports`:

```bash
sky launch -c jupyter --ports 8888 jupyter_lab.yaml
```

### Quickly Launch GPU/CPU/TPU Instances

SkyPilot also offers interactive nodes, allowing users to quickly start specified single node VMs on public clouds with simple CLI commands, without needing a YAML configuration file.

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

### Display Estimated Cost of Running Clusters

SkyPilot also provides a command to display the estimated cost of running clusters:

```bash
sky cost-report
```

Note: This CLI is still experimental. The estimated cost is calculated based on the local cache of cluster status and may not be accurate.

### Obtain Global Region Information for Azure and GCP

By default, SkyPilot supports most global regions on AWS, but only US regions on GCP and Azure. If you specify a region outside of the US, you might encounter an error like:

```bash
ValueError: Invalid region 'australiaeast'
List of supported azure regions: 'centralus, eastus, eastus2, northcentralus, southcentralus, westcentralus, westus, westus2, westus3'
```

If you wish to use all global regions, additional commands are required to fetch global region information for Azure and GCP:

```bash
version=$(python -c 'import sky; print(sky.clouds.service_catalog.constants.CATALOG_SCHEMA_VERSION)')
mkdir -p ~/.sky/catalogs/${version

}
wget https://github.com/skypilot-org/service-catalog/blob/master/catalogs/${version}/gcp.json -O ~/.sky/catalogs/${version}/gcp.json
wget https://github.com/skypilot-org/service-catalog/blob/master/catalogs/${version}/azure.json -O ~/.sky/catalogs/${version}/azure.json
```

## Community and Contribution

SkyPilot is a collaborative project. Everyone interested can participate in its development and improvement. Here are ways to contribute:

- **Discussion**: If you have any ideas, suggestions, or problems, you can join the community discussion and share them.
- **Bug Reports**: If you encounter any issues during use, please report them on GitHub.
- **Documentation**: Improve documentation and tutorials to help more users.
- **Code**: Improve SkyPilot's code or add new features.

## Conclusion

SkyPilot is a highly versatile and powerful tool that brings a new level of simplicity and efficiency to cloud infrastructure management, especially for large language models and AI batch jobs. By automatically selecting the cheapest and most effective resources, and providing a smooth user experience, SkyPilot is poised to be a game-changer for enterprises and developers in the cloud computing space. Whether you're a solo developer or part of a large organization, SkyPilot offers features and benefits that can streamline your cloud operations, save costs, and ensure maximum efficiency. With an active and growing community, the future of SkyPilot looks very promising. Give it a try and experience the future of cloud computing today!

## References

- [SkyPilot Document](https://skypilot.readthedocs.io/en/latest/index.html)
- [skypilot-org/skypilot](https://github.com/skypilot-org/skypilot)
- [Run LLaMA LLM chatbots on any cloud with one click](https://github.com/skypilot-org/skypilot/tree/master/llm/llama-chatbots)
- [How to install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?WT.mc_id=AZ-MVP-5005283)
