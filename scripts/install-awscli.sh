#!/bin/bash -xe

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 1. install aws-cli
pip install awscli
/usr/local/bin/aws configure set default.region ${REGION}
/usr/local/bin/aws configure set default.output json