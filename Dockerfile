FROM ubuntu:20.04

RUN apt update
RUN apt install nginx -y && \
    apt install libnginx-mod-rtmp -y

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.default.conf /etc/nginx/site-available/default
COPY index.html /usr/share/nginx/html/index.html

RUN mkdir -p /var/www/html/stream/hls && \
    mkdir -p /var/www/html/stream/dash

RUN apt install python3-pip -y && \
    pip install yt-dlp && \
    yt-dlp --merge-output-format mp4 https://www.youtube.com/watch?v=iom_nhYQIYk && \
    apt install ffmpeg -y

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1935
EXPOSE 80
EXPOSE 8088

ENTRYPOINT ["/entrypoint.sh"]
