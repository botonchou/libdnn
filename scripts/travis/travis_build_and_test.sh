#!/bin/bash
# Script called by Travis to do a CPU-only build of and test Caffe.

set -e
MAKE="make --jobs=$NUM_THREADS --keep-going"

./configure
$MAKE all
$MAKE test
