#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Simple test script to verify basic functionality.
"""

import sys
import os

# Add current directory to path (simulating Docker environment)
sys.path.insert(0, os.getcwd())

def test_colorama_import():
    """Test colorama import specifically."""
    try:
        print("Testing colorama import...")
        from colorama import Fore, Style
        import colorama
        print("✅ Successfully imported colorama")
        return True
    except ImportError as e:
        print(f"❌ Failed to import colorama: {e}")
        return False

def test_basic_imports():
    """Test basic imports."""
    try:
        print("Testing basic imports...")
        import pandas as pd
        import numpy as np
        import fastapi
        import uvicorn
        import baostock as bs
        import tqdm
        print("✅ All basic imports successful")
        return True
    except ImportError as e:
        print(f"❌ Failed basic imports: {e}")
        return False

def main():
    print("🧪 Running simple import tests...")
    print("=" * 40)
    
    success = True
    success &= test_colorama_import()
    success &= test_basic_imports()
    
    print("=" * 40)
    if success:
        print("🎉 All tests passed!")
    else:
        print("❌ Some tests failed!")
    
    return success

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
