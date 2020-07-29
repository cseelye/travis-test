# pylint: disable=R,C
import os
import subprocess
import sys

SCRIPT_DIR = "tool"
SCRIPT_NAME = "standalone.py"
SCRIPT_ABSDIR = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", SCRIPT_DIR))
SCRIPT_ABSPATH = os.path.join(SCRIPT_ABSDIR, SCRIPT_NAME)

# Add script directory to path so it can be imported
sys.path.append(SCRIPT_ABSDIR)

import standalone # pylint: disable=import-error

def test_main():
    assert standalone.main() == True

def test_scriptmain():
    p = subprocess.run(SCRIPT_ABSPATH, check=False)
    assert p.returncode == 0
