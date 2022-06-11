#!/bin/python
import os
import shutil
import subprocess

def run(command, **kwargs):
    subprocess.run(command, check=True, **kwargs)

remove = os.remove
move = shutil.move

def symlink(source, target):
    try:
        os.symlink(source, target)
    except FileExistsError:
        os.remove(target)
        os.symlink(source, target)