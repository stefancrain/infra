#!/bin/bash
# Get an AMI for all regions

declare -a REGIONS=($(aws ec2 describe-regions --output json | jq -r '.Regions[].RegionName'))

echo ""
echo "VYOS"
# Sorted by Name (including version #)
for REGION in "${REGIONS[@]}" ; do
  AMI=$(aws ec2 describe-images \
    --region ${REGION} \
    --owners 679593333241 \
    --filters "Name=name,Values=VyOS (HVM) 1.2.*" "Name=state,Values=available" \
    --query "reverse(sort_by(Images, &Name))[:1].ImageId" | jq -r '.[]')
  echo '"'${REGION}'" = "'${AMI}'"'
done

echo ""
echo "Ubuntu LTS"
# Sorted by CreationDate
for REGION in "${REGIONS[@]}" ; do
  AMI=$(aws ec2 describe-images \
    --region ${REGION} \
    --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal*" "Name=state,Values=available" \
    --query "max_by(Images, &CreationDate).ImageId" )
  echo '"'${REGION}'" = '${AMI}
done
