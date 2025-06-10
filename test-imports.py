#!/usr/bin/env python3
"""
Test script to verify that imports work correctly in the Docker environment.
"""

import sys
import os

# Add the api directory to the Python path
sys.path.insert(0, '/app')

def test_imports():
    """Test all the imports that were causing issues."""
    try:
        print("Testing basic imports...")
        
        # Test index.py imports
        print("Testing index.py imports...")
        from index import app
        print("✓ Successfully imported app from index")
        
        # Test case_api.py imports
        print("Testing case_api.py imports...")
        from case_api import router
        print("✓ Successfully imported router from case_api")
        
        # Test platform_scanner.py imports
        print("Testing platform_scanner.py imports...")
        from platform_scanner import scan_stocks, prepare_stock_list
        print("✓ Successfully imported functions from platform_scanner")
        
        # Test combined_analyzer.py imports
        print("Testing combined_analyzer.py imports...")
        from analyzers.combined_analyzer import analyze_stock
        print("✓ Successfully imported analyze_stock from combined_analyzer")
        
        # Test enhanced_platform_analyzer.py imports
        print("Testing enhanced_platform_analyzer.py imports...")
        from analyzers.enhanced_platform_analyzer import analyze_enhanced_platform
        print("✓ Successfully imported analyze_enhanced_platform")
        
        print("\n🎉 All imports successful!")
        return True
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    print("Starting import test...")
    print(f"Python path: {sys.path}")
    print(f"Current working directory: {os.getcwd()}")
    print(f"Contents of current directory: {os.listdir('.')}")
    
    success = test_imports()
    sys.exit(0 if success else 1)
