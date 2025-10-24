<!--
https://chatgpt.com/c/68f3a65b-232c-8329-be89-c05bc8cbf013
https://gemini.google.com/app/b9d7ea94951fc8c3
-->

---
title: "Installing FFCV and Fastxtend on Windows with Micromamba and MSVC"
published: false
description: "A reflective walkthrough of building and installing FFCV and Fastxtend on Windows using self-contained batch scripts, Micromamba, and MSVC."
tags: [windows, python, msvc, ffcv]
cover_image: "https://raw.githubusercontent.com/pchemguy/FFCVonWindows/refs/heads/main/coverw.jpg"
canonical_url: "https://github.com/pchemguy/FFCVonWindows"
---

# 🧠 TL;DR

This project automates building and installing [FFCV](https://github.com/libffcv/ffcv) on Windows using Micromamba and MSVC - no preinstalled Python required.  
It also serves as a technical exploration of pip/MSVC integration, dependency resolution, and DLL behavior on Windows.

---

# 🧭 Summary

This project offers a fully automated Windows build pipeline for the FFCV and Fastxtend libraries.  
It rebuilds the missing installation logic for native dependencies and configures a clean, reproducible environment using Micromamba and MS Build Tools - all without requiring a preinstalled Python setup.

The scripts:

- Bootstrap a self-contained, Conda-compatible environment (`Anaconda.bat`);
- Automatically fetch and prepare OpenCV, pthreads, and LibJPEG-Turbo;
- Detect and activate the MSVC toolchain (`msbuild.bat`);
- Build and install **FFCV** and **Fastxtend** directly from PyPI without developer intervention.

The environment targets Windows 10+ with ANSI-color-capable terminals (set `NOCOLOR=1` for graceful fallback).  
Its modular design emphasizes transparency, reproducibility, and debuggability - valuable not only for building these specific libraries, but also for understanding how Python’s native compilation process behaves on Windows.

The repository with build scripts is available here:  
👉 [**FFCVonWindows on GitHub**](https://github.com/pchemguy/FFCVonWindows)

---

# 💡 Motivation

While FFCV and Fastxtend are powerful tools for high-throughput data loading and fastai integration, their Windows installation process has long been underdocumented and partially broken. The upstream build workflow fails to configure native dependencies and does not properly integrate with the MSVC toolchain.

This project does not claim to “fix” FFCV building bugs - it simply bypasses defective code and makes the process reproducible and inspectable.  
The goal was to create a transparent, script-driven environment setup that others could study, adapt, and improve upon.

> Personally, I found that stepping through the build process, even when it fails, often teaches more than a successful one-liner installation.  
> This project came out of that curiosity - understanding why pip, MSVC, and native libraries fail to cooperate under Windows.

---

# ⚡ Quick Start

### 🧭 Prerequisites

- Windows 10 or later  
- [MS Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools) (C++ workload)  
- `curl` and `tar` available in PATH (default on modern Windows)  
- Internet access  

> 💡 Tip: set `NOCOLOR=1` if your console does not support ANSI colors.

---

### 🚀 Installation

**1. Clone the repository**

```
git clone https://github.com/pchemguy/FFCVonWindows.git
cd AIFFCV
```

**2. Run the bootstrapper**

From a clean `cmd.exe` shell (no active Python/Conda environment):

```cmd
>Anaconda.bat
```

This will:

- Verify prerequisites (MSVC, GPU, curl/tar);  
- Download and prepare libraries (OpenCV, pthreads, LibJPEG-Turbo);  
- Download Micromamba;  
- Create the environment;  
- Build and install FFCV and Fastxtend from PyPI.  

---

# 🎨 Color Convention

Scripts use consistent, minimal ANSI labels (fallback to plain text with `NOCOLOR=1`):

|Label|Meaning|
|---|---|
|`[WARN]`|Major task or subtask banner|
|`[INFO]`|Progress or diagnostic output|
|`[-OK-]`|Successful step|
|`[ERROR]`|Critical failure (aborts execution)|

**MS Build Tools Check - Failed**

![](https://raw.githubusercontent.com/pchemguy/FFCVonWindows/refs/heads/main/AIFFCV/Screenshots/MSBuild_failed.jpg)

**MS Build Tools Check - Passed**

![](https://raw.githubusercontent.com/pchemguy/FFCVonWindows/refs/heads/main/AIFFCV/Screenshots/MSBuild_passed.jpg)

**Successful Completion**

![](https://raw.githubusercontent.com/pchemguy/FFCVonWindows/refs/heads/main/AIFFCV/Screenshots/completion.jpg)

---

# 🗂️ Project Structure

|File / Directory|Role|
|---|---|
|**Anaconda.bat**|Main entry point – orchestrates bootstrap, download, and installation|
|**conda_far.bat**|Environment activator – prepares MSVC and dependency paths|
|**msbuild.bat**|MSVC detector and activator|
|**libs.bat**|Manages native libraries (OpenCV, pthreads, LibJPEG-Turbo)|
|`pthreads/activate.bat`|Sets pthreads `PATH`, `LIB`, `INCLUDE`, and `LINK`|
|`opencv/activate.bat`|Sets OpenCV environment variables|
|`libjpeg-turbo/activate.bat`|Configures Conda-provided LibJPEG-Turbo|
|`Anaconda.yml`, `Anaconda_bootstrap.yml`|Conda environment definitions|

---

# 🔬 Deep Dive: Why Windows Builds Fail

Building native Python packages on Windows often fails due to:

- Missing compiler detection (`pip` ignoring your `PATH`);  
- Inconsistent dependency paths;  
- MSVC ABI mismatches;  
- Windows DLL search order changes since Python 3.8.  

---

## 🧩 Key Variables

|Variable|Purpose|
|---|---|
|`INCLUDE`|C/C++ header directories|
|`LIB`|Import library directories|
|`LINK`|Explicit linker targets (e.g., `pthreadVC2.lib`)|
|`PATH`|Runtime DLL directories|

Setting these variables correctly before `pip install` prevents setup errors due to broken dependency discovery logic.

---

## ⚙️ The MSVC Detection Trap

A common frustration is:

```
error: Microsoft Visual C++ 14.0 or greater is required
```

Even if `cl.exe` is in your PATH, `pip` and `setuptools` may still fail to detect it.  
The fix is to set:

```cmd
set "DISTUTILS_USE_SDK=1"
```

This forces `setuptools` to trust the already active MSVC environment instead of rerunning its own fragile discovery logic.

---

## 🧠 FFCV-Specific Problem

`setup.py`’s `pkgconfig_windows()` function produces invalid dependency configuration.  
Rather than modifying upstream code, the scripts predefine correct values via MSVC environment variables before calling `pip`.

---

## 🔧 Library Integration Summary

|Library|Version|Source|Integration|
|---|---|---|---|
|OpenCV|4.6.0 (VC15)|Official Release|External|
|pthreads-win32|2.9.1|Sourceware FTP|External|
|LibJPEG-Turbo|Conda|Internal|Provided by Conda|

|Variable|pthreads|OpenCV|LibJPEG-Turbo|
|---|---|---|---|
|`PATH`|`pthreads\dll\x64`|`opencv\build\x64\vc15\bin`|`Anaconda\Library\bin`|
|`INCLUDE`|`pthreads\include`|`opencv\build\include`|`Anaconda\Library\include`|
|`LIB`|`pthreads\lib\x64`|`opencv\build\x64\vc15\lib`|`Anaconda\Library\lib`|
|`LINK`|`pthreadVC2.lib`|`opencv_world460.lib`|`turbojpeg.lib`|

---

# 🧩 Diagnosing "DLL load failed"

After successful build, you may still see:

```
ImportError: DLL load failed while importing _libffcv
```

This does not always mean `_libffcv.pyd` is missing - it might mean its dependencies were not found.

To debug:

- Use [Dependencies](https://github.com/lucasg/Dependencies) to identify missing DLLs.
- Use [ProcMon](https://learn.microsoft.com/en-us/sysinternals/downloads/procmon) to trace real-time DLL lookup behavior.


> Since Python 3.8, DLL search order is hardened: it no longer checks arbitrary `PATH` entries for extension module dependencies.  
> To comply with this policy, the final installation step copies required DLLs (e.g., `opencv_world460.dll`, `pthreadVC2.dll`) into `Anaconda\Library\bin`, which Python _does_ trust.

![](https://raw.githubusercontent.com/pchemguy/FFCVonWindows/refs/heads/main/AIFFCV/Screenshots/DLLL_Load_Error.jpg)

---

# 📚 References

- [FFCV GitHub Repository](https://github.com/libffcv/ffcv)  
- [Fastxtend GitHub Repository](https://github.com/warner-benjamin/fastxtend)  
- [Microsoft Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools)  
- [SO: Installing MS Build Tools for pip](https://stackoverflow.com/a/64262038/17472988)  
- [Field Notes: Bootstrapping Python Environments on Windows](https://github.com/pchemguy/Field-Notes/blob/main/03-python-env-windows/README.md)  
- [Field Notes: Python pip & MSVC Detection Issues](https://github.com/pchemguy/Field-Notes/blob/main/05-python-pip-msvc/README.md)  
- [Dependencies](https://github.com/lucasg/Dependencies)  
- [ProcMon (Sysinternals)](https://learn.microsoft.com/en-us/sysinternals/downloads/procmon)  
