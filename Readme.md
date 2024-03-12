# 스트리밍 서버 구축 가이드
이 가이드는 nginx를 사용하여 HLS 스트리밍 서버를 구축하고, 유튜브 동영상을 스트리밍하는 방법에 대해 설명합니다. nginx를 이용해 HLS(HTTP Live Streaming) 포맷으로 동영상을 제공하는 방법을 다룹니다.

## 준비사항
- Ubuntu 기반의 리눅스 시스템
- `nginx`
- `ffmpeg` - 동영상을 스트리밍 포맷으로 변환하는 데 사용
- `yt-dlp` - 유튜브 동영상을 다운로드하는 데 사용

## 1. 시스템 업데이트 및 필수 패키지 설치
시스템 패키지 리스트를 업데이트하고 필요한 도구들을 설치합니다.

```bash
#!/bin/bash

apt update
apt install nginx ffmpeg python3-pip -y
pip3 install yt-dlp
```

## 2. nginx 구성
nginx 설정을 수정하여 HLS 스트리밍을 활성화합니다. 주요 설정 파일(/etc/nginx/nginx.conf)에 HLS 설정을 추가합니다.

nginx.conf 예시
```
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       8080;
        server_name  localhost;

        location / {
            root   html;
            index  index.html index.htm;
        }
    }

    # HTTP can be used for HLS and DASH delivery
    server {
        listen 8088;

        location /hls {
            types {
                application/vnd.apple.mpegurl m3u8;
            }
            root /usr/share/nginx/html; # 수정된 부분
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin http://localhost:8080;
        }


        location /dash {
            root /usr/share/nginx/html;
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin http://localhost:8080;
        }
    }
}
```

## 3. HLS 스트리밍 컨텐츠 제공 
동영상 파일을 HLS 포맷으로 변환하고, 스트리밍을 위한 컨텐츠를 준비합니다. ffmpeg를 사용하여 이 과정을 자동화할 수 있는 스크립트를 작성합니다.

```bash
#!/bin/bash

VIDEO_URL="youtube url"
HLS_DIR="/usr/share/nginx/html/hls"

mkdir -p $HLS_DIR
yt-dlp -o "${HLS_DIR}/video.mp4" --merge-output-format mp4 "$VIDEO_URL"
ffmpeg -i "${HLS_DIR}/video.mp4" -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls "${HLS_DIR}/stream.m3u8"

nginx -g "daemon off;"
```


## 4. 웹 페이지를 통한 스트리밍 재생
웹 페이지에서 스트리밍 컨텐츠를 재생하기 위해 HTML 파일을 생성합니다. 이 파일은 8080 포트에서 제공되며, HLS 스트리밍 컨텐츠를 8088 포트에서 로드합니다.

index.html 예시
```html
<!DOCTYPE html>
<html>
<head>
    <title>Live Streaming</title>
</head>
<body>
<video id="video" controls></video>
<script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
<script>
    if(Hls.isSupported()) {
        var video = document.getElementById('video');
        var hls = new Hls();
        hls.loadSource('http://localhost:8088/hls/stream.m3u8'); // 수정된 부분
        hls.attachMedia(video);
        hls.on(Hls.Events.MANIFEST_PARSED,function() {
            video.play();
        });
    }
    // 추가: Hls가 지원되지 않는 경우 (예: Safari)
    else if (video.canPlayType('application/vnd.apple.mpegurl')) {
        video.src = 'http://localhost:8088/hls/stream.m3u8'; // 수정된 부분
        video.addEventListener('canplay',function() {
            video.play();
        });
    }
</script>
</body>
</html>
```

위의 과정을 통해 HLS 스트리밍 서버를 구축하고, 유튜브 동영상을 스트리밍하는 웹 페이지를 제공할 수 있습니다. 설정이 완료된 후에는, nginx를 재시작하고 웹 브라우저를 통해 스트리밍을 시청할 수 있습니다.

## 실행

```shell
$ docker build . -t nginx-for-hls
$ docker run -it -p 8080:8080 -p 8088:8088 nginx-for-hls
```

## 예제

![image](https://github.com/lee20h/nginx-setting-for-hls/assets/59367782/86e840ab-0782-452a-bea5-f84c293e7eb2)

한번에 브라우저에서 파일을 다운로드 받는 것이 아닌 플레이 시점을 기준으로 다운로드 받아서 버퍼를 잡아놓는 것을 볼 수 있습니다.

## 주의 사항
- 동일 출처 정책 및 CORS 관련 설정을 확인
- 방화벽 및 네트워크 보안 설정을 검토하여 포트 확인
- 스트리밍 서버의 공개적인 접근성과 보안을 고려
