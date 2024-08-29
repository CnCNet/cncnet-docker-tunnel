# cncnet-docker-tunnel
A repo that contains a dockerfile to create a cncnet tunnel server in docker

1
Clone the dockerfile from this repo to your server

2
Build the docker container from the docker file as below:
```sh
docker build -t my-tunnel-server .
```


3
Run your new container with the below:

```sh
docker run -d --name SERVERNAMEHERE \
    -p 50000:50000/tcp \
    -p 50000:50000/udp \
    -p 50001:50001/tcp \
    -p 50001:50001/udp \
    -p 8054:8054/udp \
    -p 3478:3478/udp \
    --cap-add=NET_RAW --cap-add=NET_ADMIN \
    --restart unless-stopped \
    my-tunnel-server
```
