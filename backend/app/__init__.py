import os
import sys

# Ensure Windows OpenSSL DLLs from Anaconda base are discovered if running on Windows
if sys.platform == "win32":
    anaconda_bin = r"C:\Users\Dell\anaconda3\Library\bin"
    if os.path.isdir(anaconda_bin):
        if hasattr(os, "add_dll_directory"):
            try:
                os.add_dll_directory(anaconda_bin)
            except Exception:
                pass
        if anaconda_bin not in os.environ.get("PATH", ""):
            os.environ["PATH"] = anaconda_bin + os.pathsep + os.environ.get("PATH", "")
