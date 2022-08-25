# NoOps Accelerator Labs
## Module: NoOps - Lab - Creating Lab Environment
### Lab Manual
**Conditions and Terms of Use**  

The contents of this package are for informational and training purposes only and are provided "as is" without warranty of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.

Training package content, including URLs and other Internet Web site references, is subject to change without notice. Because Microsoft must respond to changing market conditions, the content should not be interpreted to be a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of publication. Unless otherwise noted, the companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place, or event is intended or should be inferred.

**Copyright and Trademarks**

© Microsoft Corporation. All rights reserved.

Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.

Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.

For more information, see **Use of Microsoft Copyrighted Content** at [https://www.microsoft.com/en-us/legal/copyright/permissions](https://www.microsoft.com/en-us/legal/copyright/permissions)

Microsoft®, Internet Explorer®, and Windows® are either registered trademarks or trademarks of Microsoft Corporation in the United States and/or other countries. Other Microsoft products mentioned herein may be either registered trademarks or trademarks of Microsoft Corporation in the United States and/or other countries. All other trademarks are property of their respective owners.

</br>

## Contents
[**Introduction**](#introduction)  
[**Prerequisites**](#prerequisites)  
[**Exercise 1: Configuring the lab environment**](#exercise-1-configuring-the-lab-environment)  
[Task 1: Configuring Visual Studio Code](#task-1-configuring-visual-studio-code)  
[**Exercise 2: Saving work with commits**](#exercise-2-saving-work-with-commits)  
[Task 1: Committing changes](#task-1-committing-changes)  
[Task 2: Reviewing commits](#task-2-reviewing-commits)  
[Task 3: Staging changes](#task-3-staging-changes)  
[**Exercise 3: Reviewing history**](#exercise-3-reviewing-history)  
[Task 1: Comparing files](#task-1-comparing-files)  
[**Exercise 4: Working with branches**](#exercise-4-working-with-branches)  
[Task 1: Creating a new branch in your local repository](#task-1-creating-a-new-branch-in-your-local-repository)  
[Task 2: Working with branches](#task-2-working-with-branches)  
[**Exercise 5: Managing branches from Azure DevOps**](#exercise-5-managing-branches-from-azure-devops)  
[Task 1: Creating a new branch](#task-1-creating-a-new-branch)  
[Task 2: Deleting a branch](#task-2-deleting-a-branch)  
[Task 3: Locking a branch](#task-3-locking-a-branch)  
[Task 4: Tagging a release](#task-4-tagging-a-release)  
[**Exercise 6: Managing repositories**](#exercise-6-managing-repositories)  
[Task 1: Creating a new repo from Azure DevOps](#task-1-creating-a-new-repo-from-azure-devops)  
[Task 2: Deleting and renaming Git repos](#task-2-deleting-and-renaming-git-repos)  
[**Exercise 7: Working with pull requests**](#exercise-7-working-with-pull-requests)  
[Task 1: Creating a new pull request](#task-1-creating-a-new-pull-request)  
[Task 2: Managing pull requests](#task-2-managing-pull-requests)  
[Task 3: Managing Git branch and pull request policies](#task-3-managing-git-branch-and-pull-request-policies) 

<div style="page-break-after: always;"></div>

<a name="Introduction"></a>

## Introduction ##

This document outlines the required steps to setup NoOps Accelerator, we will utilize in the following labs.

Azure DevOps supports two types of version control, Git and Team Foundation Version Control (TFVC). Here is a quick overview of the two version control systems:

- **Git**: Git is a distributed version control system. Git repositories can live locally (such as on a developer's machine). Each developer has a copy of the source repository on their dev machine. Developers can commit each set of changes on their dev machine and perform version control operations such as history and compare without a network connection.

Git is the default version control provider for new projects. You should use Git for version control in your projects unless you have a specific need for centralized version control features in TFVC.

In this lab, you will learn how to establish a local Git repository, which can easily be synchronized with a centralized Git repository in GitHub.

<a name="Prerequisites"></a>
### Prerequisites ###

- [Visual Studio Code](https://code.visualstudio.com/) with the [C#](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp) extension installed.

- [Git for Windows](https://gitforwindows.org/) 2.33.0 or later.

- This lab requires you to complete the End to End Prerequisite instructions.

**Estimated Time to Complete This Lab**  
60 minutes

<div style="page-break-after: always;"></div>

<a name="Exercise1"></a>
## Exercise 1: Configuring the lab environment ##

<a name="Ex1Task1"></a>
### Task 1: Configuring Visual Studio Code ###

1. Open **Visual Studio Code**. In this task, you will configure a Git credential helper to securely store the Git credentials used to communicate with Azure DevOps. If you have already configured a credential helper and Git identity, you can skip to the next task.

1. From the main menu, select **Terminal \| New Terminal** to open a terminal window.

1. Execute the command below to configure a credential helper.

    ```
    git config --global credential.helper wincred
    ```
1. The commands below will configure your user name and email for Git commits. Replace the parameters with your preferred user name and email and execute them.

    ```
    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com
    ```

<a name="Exercise2"></a>
## Exercise 2: Cloning the NoOps repository ##

<a name="Ex2Task1"></a>
### Task 1: Cloning NoOps repository ###

1. In a browser tab, navigate to the NoOps Accelerator git repo at [http://aka.ms/azurenoops](http://aka.ms/azurenoops).

1. Getting a local copy of a Git repo is called "cloning". Every mainstream development tool supports this and will be able to connect to GitHub to pull down the latest source to work with. Navigate to the **Repos** hub.

    ![](images/reposMenu.png)

1. Click **Clone**.

    ![](images/cloneRepo.png)

1. Click the **Copy to clipboard** button next to the repo clone URL. You can plug this URL into any Git-compatible tool to get a copy of the codebase.

    ![](images/cloneRepoURL.png)