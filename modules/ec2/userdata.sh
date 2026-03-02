#!/bin/bash
# 에러확인용
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Amazon-Linux 2 배포 시작중..."



# 1. 패키지 업데이트 및 파이썬 설치
sudo dnf update -y
sudo dnf install -y python3
sudo dnf install -y nginx

# 2. 앱 디렉토리 생성 및 이동 (예시)
APP_DIR="/home/ec2-user/app"
mkdir -p $APP_DIR
cd $APP_DIR

cat <<EOF | sudo tee /etc/nginx/conf.d/test_app.conf
server {
  listen 80;
  server_name _;

  location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOF

sudo systemctl start nginx
sudo systemctl enable nginx


cat <<EOF > test_main.py
from fastapi import FastAPI
import uvicorn
import pymysql

app = FastAPI()

db_config = {
    'host': '${db_endpoint}',
    'user': 'test',
    'password': 'dlrudalswns2!',
    'db': 'testdb',
    'charset': 'utf8mb4'
}

try:
    connection = pymysql.connect(**db_config)
    print("RDS 연결 성공!")
    connection.close()
except Exception as e:
    print(f"연결 실패: {e}")

@app.get("/")
def root_page():
  return {"message": "테스트용 성공"}

if __name__ == "__main__":
  uvicorn.run(app,host="127.0.0.1", port=8000)
EOF

python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install fastapi uvicorn pymysql

# 권한설정
chown -R ec2-user:ec2-user $APP_DIR

# 5. 앱 실행 (백그라운드)
sudo ./venv/bin/python3 test_main.py > $APP_DIR/app.log 2>&1 &
