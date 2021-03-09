#!/bin/bash
# install tools for container standup
echo "cwd: $(pwd)"
echo "---getting tools---"
# folder permissions
pre-commit install
echo "---tools done---"
exit
