---
title: "Get an OpenSSF Best Practices badge for your open source project!"
summary: "The article presents OpenSSF best practice badges designed to improve the security, quality and trust of open source projects."
authors: ["guoxudong"]
tags: ["OpenSSF"]
categories: ["OpenSSF"]
date: 2023-04-18T14:01:26+08:00
lastmod: 2023-04-18T14:01:26+08:00
draft: false
type: blog
image: "https://cdn.suuny0826.com/image/2023-04-19-20230419113427.png"
---

As open-source software is widely used globally, ensuring its security becomes increasingly important. The Open Source Security Foundation (OpenSSF) was born to address this challenge. Supported by the Linux Foundation, this project aims to enhance the security, reliability, and sustainability of open-source software. To achieve this goal, OpenSSF has launched the Best Practices Badge Program. This project was originally developed under the CII, but it is now part of the Open Source Security Foundation (OpenSSF) Best Practices Working Group (WG). The original name of the project was the CII Best Practices badge, but it is now the OpenSSF Best Practices badge project.

![Kubernetes README](https://cdn.suuny0826.com/image/2023-04-19-20230419101516.png)

## OpenSSF

The OpenSSF (Open Source Security Foundation) is a cross-industry organization dedicated to improving the security of open source software. Established in 2020, the organization was initiated by several technology companies (including Google, Microsoft, IBM, GitHub, Red Hat, and others) and later attracted many other companies and organizations to join. The establishment of OpenSSF aims to address the growing security challenges in the open source software ecosystem, striving to enhance the security of open source software through collaboration, education, research, and best practices.

The main work of OpenSSF includes:

1. Enhancing open source software supply chain security: OpenSSF focuses on software supply chain security to mitigate risks within the supply chain. This includes ensuring the security of source code, build processes, and distribution channels, thus preventing the infiltration of malware, backdoors, and other security vulnerabilities.
2. Promoting open source security best practices: OpenSSF helps projects and organizations improve security by formulating and promoting open source security best practices. These practices involve various stages of the software development lifecycle, including design, coding, testing, and deployment.
3. Training and education: OpenSSF provides training and education resources to raise awareness and skills of developers and maintainers in open source software security. These resources include online courses, guides, best practice documents, and more.
4. Funding critical projects: OpenSSF ensures the continuous development and proper maintenance of projects that are of significant importance to open source security by providing funding. These projects may include infrastructure projects, security tools, and research projects, among others.
5. Research and development: OpenSSF also supports security research and development efforts to continuously improve and innovate open source security technologies.

In summary, OpenSSF is committed to enhancing the security of open source software through cross-industry collaboration, education, research, and funding, creating a safer future for the entire open source ecosystem.

## What is the OpenSSF Best Practices Badge Program

The Best Practices Badge Program aims to encourage and assist open-source projects in following software security best practices. Inspired by the many badge systems available on GitHub, this voluntary, free, self-assessment program allows users to quickly complete an evaluation of their open-source project by filling out each best practice on the web page, while also providing guidance and standards for improving project security. The badge program has three levels: PASSING, SILVER, and GOLD, each with a certain number of security requirements.

### Badge levels and requirements

First, you need to understand the three levels of the badge program: PASSING, SILVER, and GOLD, as well as their corresponding security requirements. These requirements cover various aspects such as security policies, version control, continuous integration, etc. You can view these requirements by visiting the [official documentation](https://bestpractices.coreinfrastructure.org/en/criteria_stats) of the OpenSSF Best Practices Badge Program.

![Criteria Statistics](https://cdn.suuny0826.com/image/2023-04-19-20230419114806.png)

### Register and link your project

Visit the OpenSSF Best Practices Badge [project website](https://bestpractices.coreinfrastructure.org/), log in with your GitHub account, or register a new account. After completing the registration, log in to your account, click Get Your Badge Now!, and if you are logged in with a GitHub account, you can directly select your project from the Select one of your GitHub repos dropdown. Of course, open-source projects on non-GitHub platforms are also supported; just fill in the home page URL and version control repository address as required.

![New badge](https://cdn.suuny0826.com/image/2023-04-19-20230419103555.png)

### Project evaluation

![Email](https://cdn.suuny0826.com/image/2023-04-18-20230418142755.png)

After submitting, you will receive an explanatory email containing some necessary instructions and an address for continuing the evaluation of your open-source project. Next, you will need to self-assess your open-source project.

![Evaluation page](https://cdn.suuny0826.com/image/2023-04-19-20230419110106.png)

The self-assessment is divided into six main categories: `Basics`, `Change Control`, `Reporting`, `Quality`, `Security`, and `Analysis`. There are 67 items for the `Passing` level, 55 for `Silver`, and 23 for `Gold`. The form will automatically fill in some content based on your GitHub project's configuration, but it's not 100% accurate. You need to fill in the content according to the actual situation of the project and supplement the proof URL or explanation in the form. After completing all the items, click `Submit(and exit)` to finish filling in the content.

### Display the badge

OpenSSF provides badge images and embedding code for easy display on various platforms. On your project page, click `Show details`, and the Markdown and HTML formats for the badge will be displayed. You can add the corresponding content to your project's `README` file, official website, etc., to show the project's commitment to following software security best practices.

![embedding md](https://cdn.suuny0826.com/image/2023-04-19-20230419105508.png)

Please note that as your project evolves, you need to continue paying attention to badge requirements and ensure that your project always meets these requirements. Additionally, you can use the badge as an incentive to further improve your project's security, aiming for a SILVER or GOLD badge.

## Conclusion

In summary, the OpenSSF Best Practices Badge Program provides a practical framework for open-source projects, guiding them to follow software security best practices. By encouraging project teams to focus on security, providing core guidelines and clear evaluation criteria, this program helps to raise the overall security level of the open-source ecosystem. Every member of the open-source community should pay attention to and support this project, working together to make our digital world safer and more reliable.
