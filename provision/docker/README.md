# Local stack with docker

```shell
docker buildx build --load --tag=ubuntu-ssh:latest .
```

```shell 
docker run --name=ubuntu-ssh -d -p 8022:22 ubuntu-ssh:latest
```
