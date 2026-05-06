#!/usr/bin/env python3

import os
import runpy
import sys

app_dir = os.path.join(os.path.dirname(__file__), "Node_App")
os.chdir(app_dir)
sys.path.insert(0, app_dir)
runpy.run_path(os.path.join(app_dir, "index.mu"), run_name="__main__")
