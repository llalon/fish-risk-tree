#!/bin/bash

# Created by: Liam Lalonde for ANSC*6330 on Nov 2021

# Runs all steps of the pipeline in order

# Usage: run_pipeline.sh <path to params.json>

# Abort on error of any steps.
set -e

# Get config json
PARAMS_PATH=$1

# Run each step in order
01-download-seqs.pl $PARAMS_PATH
02-add-iucn.pl $PARAMS_PATH
03-align-seqs.pl $PARAMS_PATH
04-build-tree.pl $PARAMS_PATH
05-annotate-tree.pl $PARAMS_PATH