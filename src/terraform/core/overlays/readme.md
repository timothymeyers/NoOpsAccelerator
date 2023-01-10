# Authoring Guide for Overlays with Terraform

Azure NoOps Accelerator Overlays are self-contained Bicep deployment templates that allows to extend AzResources services with specific configurations or combine them to create more useful objects. Therefore, deploying an overlay will result in an enahancing a Azure landing zone that can be scaled and refined based on business or deployment need.

The goal of this authoring guide is to provide step-by-step instructions to create new and update existing overlays.

## Table of Contents

- [Overlay Authoring Guide](#overlay-authoring-guide)
  - [Table of Contents](#table-of-contents)  
  - [Create a new overlays](#create-a-new-overlays)
    - [Build new overlays](#build-new-overlays)
    - [Requirements for overlays](#requirements-for-overlays)
    - [Approach](#approach)
  - [Common features](#common-features)

---
