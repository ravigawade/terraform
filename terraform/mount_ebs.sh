#!/bin/bash

# install common packages
apt-get update
apt-get install -y build-essential gcc g++ wget curl dnsutils openssl

# install awscli
apt-get install -y python-dev python-pip
pip install awscli

# attach ebs
export EC2_URL="https://ec2.${aws_region}.amazonaws.com"
export AWS_DEFAULT_REGION="${aws_region}"

echo "export EC2_URL=$EC2_URL" >> /etc/environment
echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /etc/environment

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
DEVICE="${data_ebs_device}"
VOLUME_ID="${volume_id}"

echo "Attach ebs volume"
aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device $DEVICE

sleep 5

# format volume and mount
fstab_string="${data_ebs_device} ${ebs_mount_point} ext4 defaults 0 2"
if grep -q -F -v "$fstab_string" /etc/fstab; then
        echo "$fstab_string" >> /etc/fstab
fi
echo "Fomarting data ebs"
mkfs.ext4 "${data_ebs_device}"
echo "Mount data ebs"
mkdir "${ebs_mount_point}" && mount -t ext4 "${data_ebs_device}" "${ebs_mount_point}"
