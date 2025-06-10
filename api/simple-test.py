# -*- coding: utf-8 -*-
"""
Simple test to check if the import fixes work.
"""

import sys
import os

# Add current directory to path (simulating Docker environment)
sys.path.insert(0, os.getcwd())

def test_basic_imports():
    """Test basic imports without dependencies."""
    try:
        print("Testing config import...")
        import config
        print("Config import successful")
        
        print("Testing task_manager import...")
        import task_manager
        print("Task manager import successful")
        
        print("Testing json_utils import...")
        import json_utils
        print("JSON utils import successful")
        
        return True
    except Exception as e:
        print("Error: " + str(e))
        return False

if __name__ == "__main__":
    print("Running simple import test...")
    success = test_basic_imports()
    if success:
        print("Basic imports work! The fix should work in Docker.")
    else:
        print("Basic imports failed.")
    sys.exit(0 if success else 1)
