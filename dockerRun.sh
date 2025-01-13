#!/bin/bash
docker rm -f alpine-free-surfer || echo ""
docker run -it \
  --name alpine-free-surfer \
  -e DISPLAY=host.docker.internal:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ~/.Xauthority:/root/.Xauthority \
  -p 2222:22 \
  xp6qhg9fmuolztbd2ixwdbtd1/free-surfer-debian