#!/bin/bash
path="./scripts"
scripts=$(ls $path)
# menu
function menu {
  echo "==== scripts ===="
  for script in $scripts
  do
    echo "${script%.*}"
  done
}
# imports
for script in $scripts
do
    source $path/$script
    echo "adding: ${script%.*}"
done
echo "==== init done ===="
