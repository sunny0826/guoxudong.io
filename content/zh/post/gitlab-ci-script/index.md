---
title: "GitLab 冷知识：GitLab CI 最熟悉的陌生关键字 script"
summary: "介绍 `script` 关键字的一些实用技巧，帮助您快速、高效的玩转 GItLab CI"
authors: ["guoxudong"]
tags: ["GitLab", "DevOps", "CI/CD"]
categories: ["GitLab 冷知识"]
date: 2022-06-14T15:36:48+08:00
lastmod: 2022-06-14T15:36:48+08:00
draft: false
type: blog
image: http://rnxuex1zk.bkt.clouddn.com/large/ad5fbf65gy1gqupsoso0bj20zk0f4q3w.jpg
---
## 前言

在 GItLab CI 中 `script` 是最常用的关键字，用于指定 Runner 要执行的命令，同时也是除了 [trigger](https://docs.gitlab.cn/jh/ci/yaml/index.html#trigger) 之外所有 Job 都必须包含一个关键字。本文就来介绍 `script` 关键字的一些实用技巧，帮助您快速、高效地玩转 GItLab CI。

## 拆分长命令
<!-- markdown-link-check-disable-next-line -->
这个也是在日常工作中最常遇到的场景，在一个 `script` 中要执行多个命令而又无法使用 array `-` 的方式（如：需要执行一个 for 循环），这时就可以使用 `|` 和 `>` 将长命令拆分为多行命令以提高可读性。

使用 `|` 在 `script` 中每行将被视为一个单独的命令，在日志中只是打印第一行的命令，但后续的命令仍会正常执行。

```yaml
job:
  script:
    - |
      echo "First command line."
      echo "Second command line."
      echo "Third command line."
```

Job 日志：

```shell
$ echo First command line # collapsed multiline command
First command line
Second command line.
Third command line.
```

而使用 `>` 则会将空行视为新命令的开始，同样在日志中也只会打印第一行的命令。

```yaml
job:
  script:
    - >
      echo "First command line
      is split over two lines."

      echo "Second command line."
```

Job 日志：

```shell
$ echo First command line is split over two lines. # collapsed multiline command
First command line is split over two lines.
Second command line.
```

值得注意的是，非空行会被识别为同一个命令执行，但日志依旧只会打印一行命令，如下面这个将小写字母转化为大写字母的命令：

```yaml
job:
  script:
    - |
      tr a-z A-Z << END_TEXT
        one two three
        four five six
      END_TEXT
```

Job 日志：

```shell
$ tr a-z A-Z << END_TEXT # collapsed multiline command
  ONE TWO THREE
  FOUR FIVE SIX
```

### 已知问题

如果一个 `script` 中由多个命令字符串组成，GItLab 只会根据最后一个命令的成功与否展示 Job 结果，之前命令的失败将会被忽略，这可能影响到您的整个 Pipeline。要解决这个问题，可以将命令存放在单独的脚本中（**推荐**），或在每个命令的字符串添加一个 `exit 1` 的判断，类似这样：

```yaml
...
  script:
    - opa eval --format pretty --data "${CI_PROJECT_DIR}/opa/terraform.rego" --input "${CI_PROJECT_DIR}/${ENVIRONMENT}-${PRODUCT}-${CI_PIPELINE_ID}.tfplan.json"  "data.terraform.analysis.score" > score.txt
    - cat score.txt
    - opa eval --format pretty --data "${CI_PROJECT_DIR}/opa/terraform.rego" --input "${CI_PROJECT_DIR}/${ENVIRONMENT}-${PRODUCT}-${CI_PIPELINE_ID}.tfplan.json"  "data.terraform.analysis.authz" > result.txt
    - cat result.txt
    - mapfile opa_flag  < result.txt 
    - echo $opa_flag
    - if [ "$opa_flag" == 'false' ]; then exit 1; else exit 0; fi
```

很明显，这样**并不优雅**，但目前这个问题依旧没有解决，所以在生产环境中，推荐使用单独的脚本来存放多行命令。

## 忽略非 0 退出代码

当脚本命令返回非 0 的退出代码时，作业将失败并且不会执行进一步的命令。

可以将退出代码存储在变量中以避免这种行为：

```yaml
job:
  script:
    - false || exit_code=$?
    - if [ $exit_code -ne 0 ]; then echo "Previous command failed"; fi;
```

## `before_script` 和 `after_script` 的妙用

在 `script` 执行前和执行后可以使用 `before_script` 和 `after_script` 来执行一些命令，值得注意的是：

- `before_script` 在 `script` 之前，在 **artifacts 恢复之后**执行
- `after_script` 则会在 `script` 之后执行，**包括失败的 Job**

在 `default` 关键字中定义 `before_script` 和 `after_script` 将会在所有 Job 执行命令的前后执行命令。如果您不想在指定 Job 执行这些命令或想执行其他的命令，可以在 Job 中使用  `before_script` 和 `after_script` 来覆盖这些命令，不想执行请使用 `before_script: []` 或 `after_script: []` 来覆盖默认的命令：

```yaml
default:
  before_script:
    - echo "Execute this `before_script` in all jobs by default."
  after_script:
    - echo "Execute this `after_script` in all jobs by default."

job1:
  script:
    - echo "These script commands execute after the default `before_script`,"
    - echo "and before the default `after_script`."

job2:
  before_script:
    - echo "Execute this script instead of the default `before_script`."
  script:
    - echo "This script executes after the job's `before_script`,"
    - echo "but the job does not use the default `after_script`."
  after_script: []
```

## 在 Job 日志打印彩色字符

要在 Job 日志中打印彩色字符，需要使用 ANSI 转义码或通过运行输出 ANSI 转义码的命令或程序对脚本输出进行着色。

例如使用 [Bash 彩色代码](https://misc.flogisoft.com/bash/tip_colors_and_formatting) 中，通过 `before_script` 将彩色代码以变量的形式注入以提高可读性与重用性，当然，使用 `variables` 也是可以的：

```yaml
job:
  before_script:
    - TXT_RED="\e[31m" && TXT_CLEAR="\e[0m"
  script:
    - echo -e "${TXT_RED}This text is red,${TXT_CLEAR} but this part isn't${TXT_RED} however this part is again."
    - echo "This text is not colored"
```

或者使用 [PowerShell 彩色代码](https://superuser.com/a/1259916)：

```yaml
job:
  before_script:
    - $esc="$([char]27)"; $TXT_RED="$esc[31m"; $TXT_CLEAR="$esc[0m"
  script:
    - Write-Host $TXT_RED"This text is red,"$TXT_CLEAR" but this text isn't"$TXT_RED" however this text is red again."
    - Write-Host "This text is not colored"
```

## 特殊字符的使用

在 `script` 中有些命令是需要使用单引号或双引号括起来的，最常碰到的就是包含 `:` 的命令必须使用 `'` 括起来，YAML 解释器需要将文本解析为字符串而非键值对。

例如使用下面这个脚本就会报错 `Syntax is incorrect`：

```yaml
job:
  script:
    - curl --request POST --header 'Content-Type: application/json' "https://gitlab/api/v4/projects"
```

需要将其修改为：

```yaml
job:
  script:
    - 'curl --request POST --header "Content-Type: application/json" "https://gitlab/api/v4/projects"'
```

还有这些符号在使用时也需要小心：

- `{`、`}`、`[`、`]`、`,`、`&`、`*`、`#`、`?`、`|`、`-`、`<`、`>`、`=`、`!`、`%`、`@`、`` ` ``
<!-- markdown-link-check-disable-next-line -->
GItLab 提供了 [CI Lint](https://docs.gitlab.cn/jh/ci/lint.html) 工具来验证语法是否有效，这个工具在调试 `.gitlab-ci.yml` 时非常好用。

## 结语

`script` 作为最常用的关键字也是出错最多和最消耗调试时间的关键字，掌握这些常用技巧可以非常有效的提高工作效率，减少时间的浪费。
