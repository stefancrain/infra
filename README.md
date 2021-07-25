# Router - NOT FOR RELEASE

A test harness for deploying a small cluster of VyOS _stable_ routers
and Ubuntu testing instances in AWS.

## WHY?

My Home network has some semi-complicated elements (VLANs, VPNs, WAN failover).
To confidently make any changes to it I needed an IaC implementation.

## OS images

Using AWS Marketplace provided AMIs

- [Ubuntu 20.04](https://aws.amazon.com/marketplace/pp/prodview-iftkyuwv2sjxi)
- [VyOS 1.2.x](https://aws.amazon.com/marketplace/pp/prodview-6i4irz5gqfkru).

VyOS AMI requires AWS Marketplace
[subscription](https://aws.amazon.com/marketplace/server/procurement?productId=9c9395f4-e891-4577-82e9-a6d5bccfb3c9) to function.

### Updating AMIs

```shell
# TODO: set this up in ci
./external/update-aws-ami.sh
```

## AWS

```shell
# TODO: hi
```

---

### Notes

```shell
alias tf-retry='terraform destroy -auto-approve && terraform apply -auto-approve'
```

Sometimes terraform destroy fails.
[gruntwork-io/cloud-nuke](https://github.com/gruntwork-io/cloud-nuke) is a very
destructive command, but it stops the billing.

```shell
cloud-nuke aws --region us-west-2
```

### Help from

- [packet-labs/packet-router](https://github.com/packet-labs/packet-router)
