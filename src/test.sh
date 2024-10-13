#!/usr/bin/env bash

echo "this is stdout"
sleep 1
>&2 echo "this is stderr"
sleep 1
echo "scipt done"
sleep 1
>&2 echo "no error"

