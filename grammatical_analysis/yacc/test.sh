#!/bin/bash

for f in samples/*.c; do
  ./c < $f &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "test $f succeeded"
  else
    echo "test $f failed"
  fi
done
