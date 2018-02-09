#!/usr/bin/env bash

ifconfig eno1 | grep 'inet ' | awk '{print $2}'
