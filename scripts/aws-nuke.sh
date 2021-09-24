#!/bin/bash
# https://github.com/gruntwork-io/cloud-nuke
# brew install cloud-nuke
# cloud-nuke aws --list-resource-types
cloud-nuke aws --resource-type ec2 --resource-type ami
