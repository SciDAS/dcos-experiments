#!/usr/bin/env bash

IFACE_NAME=$(ifconfig | head -1 | awk -F':' '{print $1}')
ifconfig ${IFACE_NAME} | grep 'inet ' | awk '{print $2}'
