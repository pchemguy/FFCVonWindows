Building FFCV natively on Windows turned out to be a small adventure through the usual maze of build errors. To make the process reproducible, I developed a set of cmd.exe scripts that bootstrap a minimal Python environment and build FFCV automatically - with no preinstalled Python required.

The accompanying notes document the investigation and fixes, including:

- pip/setuptools failing to detect MS Build Tools
- Linker errors traced to faulty logic in FFCV’s setup.py, resolved by predefining compiler and linker variables    
- Diagnosing "ImportError: DLL load failed" using ProcMon and Dependencies

Sharing this project in case it saves someone else the same frustration when working with the native Python/MSVC build process on Windows.

https://github.com/pchemguy/FFCVonWindows

#Python #Windows #MSVC #FFCV #Scripting

