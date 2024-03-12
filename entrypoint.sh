#!/bin/bash

# 유튜브 동영상 다운로드 및 HLS 변환
VIDEO_URL="https://www.youtube.com/watch?v=_fhRBvbTXDI"
HLS_DIR="/usr/share/nginx/html/hls"

# HLS 디렉토리 생성
mkdir -p $HLS_DIR

# yt-dlp를 사용하여 유튜브 동영상 다운로드
yt-dlp $VIDEO_URL --verbose --embed-metadata -o - > "${HLS_DIR}/video.mp4"

# ffmpeg를 사용하여 HLS 포맷으로 변환
#ffmpeg -i "${HLS_DIR}/video.mp4" -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls "${HLS_DIR}/stream.m3u8"
ffmpeg -re -i "${HLS_DIR}/video.mp4" -c:v copy -c:a aac -ar 44100 -ac 1 -hls_time 10 -hls_list_size 0 -f hls "${HLS_DIR}/stream.m3u8"

# nginx 시작
nginx -g "daemon off;"
