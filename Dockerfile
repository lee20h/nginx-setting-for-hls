FROM ubuntu:20.04

RUN apt update
RUN apt install nginx -y && \
    apt install python3-pip -y \
 && pip install yt-dlp \
 && apt install -y ffmpeg

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /usr/share/nginx/html/hls && \
    mkdir -p /usr/share/nginx/html/dash

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
