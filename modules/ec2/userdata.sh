#!/bin/bash
# 에러확인용
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Amazon-Linux 2 배포 시작중..."



# 1. 패키지 업데이트 및 파이썬 설치
sudo yum update -y
sudo yum install -y python3

# 2. 앱 디렉토리 생성 및 이동 (예시)
APP_DIR="/home/ec2-user/app"
mkdir -p $APP_DIR
cd $APP_DIR

cat <<EOF > test_main.py
from fastapi import FastAPI
import uvicorn
import pymysql

app = FastAPI()

@app.get("/")
def root_page():
  return {"message": "테스트용 성공"}

if __name__ == "__main__":
  uvicorn.run(app,host="0.0.0.0", port=80)
EOF

python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install fastapi uvicorn pymysql

# 권한설정
chown -R ec2-user:ec2-user $APP_DIR

# 5. 앱 실행 (백그라운드)
sudo ./venv/bin/python3 test_main.py > $APP_DIR/app.log 2>&1 &
