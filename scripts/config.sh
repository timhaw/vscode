#!/bin/bash -xe
groupmod -g 998 ubuntu
usermod -g 998 -u 998 ubuntu
chown -R ubuntu:ubuntu /home/ubuntu