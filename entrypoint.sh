#!/bin/sh
nginx -g "daemon off;"
#ffmpeg -re -i 'Introducing App Platform by DigitalOcean [iom_nhYQIYk].mp4' -c:v copy -c:a aac -ar 44100 -ac 1 -f flv -flvflags no_duration_filesize rtmp://localhost/live/obs_stream
