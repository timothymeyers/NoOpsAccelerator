# NoOps Accelerator Labs
## Module: NoOps - Lab - Create Management Groups Structure with NoOps
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
[**Objectives**](#objectives)  
[**Prerequisites**](#prerequisites)

<div style="page-break-after: always;"></div>

<a name="Introduction"></a>

## Introduction ##

The Enclave Management Groups module deploys a management group hierarchy in a tenant under the Tenant Root Group. This is accomplished through a tenant-scoped Azure Resource Manager (ARM) deployment.

In this lab, you will create a Enclave Management Groups structure and deploy it to your tenant.

> NOTE: In later labs, you will build out a full Enclave deployment that you will use this module to deploy management groups.

Module deploys the following resources:

* Enclave Management Groups

The hierarchy created by the deployment (`deploy.enclave.mg.parameters.json`) is:

* Tenant Root Group
  * Intermediate Level Management Group (defined by parameter in `parRootMg`)
    * Platform
      * Management
      * Transport
      * Identity
    * Landing Zones
      * Workloads
        * Internal
          * NonProd
          * Prod
    * Sandbox

<a name="Objectives"></a>
### Objectives ###

Upon completion of this lab, you will be able to:

- Understand the benefits of authoring templates in the Bicep language over JSON-based ARM Templates
- Understand the basic principles of Infrastructure-as-Code
- Understand the relationship between Bicep and the Azure Resource Manager
- Add relevant resources to Bicep templates

<a name="Prerequisites"></a>
### Prerequisites ###

Familiarity with the following will be beneficial, but is not required:

- Managment Groups concepts
- A basic understanding of JSON
- Familiarity with the Azure CLI

Installation required:

- [Visual Studio Code](https://code.visualstudio.com/) with the [Bicep](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp) extension installed.

- [Git for Windows](https://gitforwindows.org/) 2.33.0 or later.

- This lab requires you to complete the Setup Azure instructions.

**Estimated Time to Complete This Lab**  
60 minutes

<div style="page-break-after: always;"></div>

<a name="Exercise1"></a>
## Exercise 1: Cloning the NoOps repository ##

<a name="Ex1Task1"></a>
### Task 1: Cloning NoOps repository ###

1. If you caready cloned the repo, then you can skip to Exercise
2. To clone the repo, please look at lab: [Create Lab Environment](3_Create_Lab_Environment.md).

<a name="Ex1Task2"></a>
### Task 2: Create a Dev Branch ###

1. 

<a name="Exercise2"></a>
## Exercise 2: Creating Management Groups ##