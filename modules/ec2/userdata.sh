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

sudo systemctl restart nginx
sudo systemctl enable nginx


cat <<EOF > test_main.py
from fastapi import FastAPI, Request
import uvicorn
import pymysql
from datetime import datetime

app = FastAPI()

db_config = {
    'host': 'terraform-20260303081151004400000003.cfo6ci2g6uc2.ap-northeast-2.rds.amazonaws.com',
    'user': 'test',
    'password': 'dlrudalswns2!',
    'db': 'testdb',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

def init_db():
    try:
        connection = pymysql.connect(**db_config)
        with connection.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS visitors (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    visit_time DATETIME,
                    ip_address VARCHAR(50)
                )
            """)
        connection.commit()
        connection.close()
        print("DB 테이블 초기화 성공")
    except Exception as e:
        print(f"연결 실패: {e}")

init_db()

@app.get("/")
def root_page(request: Request):
    client_ip = request.client.host
    current_time = datetime.now()

    try:
        connection = pymysql.connect(**db_config)

        # 1. DB에 방문기록 저장
        with connection.cursor() as cursor:
            cursor.execute(
                "INSERT into visitors (visit_time,ip_address) values (%s,%s)",
                (current_time, client_ip)
            ) # <- 닫는 괄호 추가된 부분!
        connection.commit()

        # 2. 총 방문자 수 조회 (SELECT)
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as count FROM visitors")
            result = cursor.fetchone()
            total_visits = result['count']

        connection.close()

        # 브라우저에 결과 출력
        return {
            "message": "환영합니다! RDS DB 연동에 성공했습니다 🎉",
            "your_ip": client_ip,
            "total_visits": total_visits
        }
    except Exception as e:
        return {"error": "DB 연동 실패", "detail": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
EOF

python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install fastapi uvicorn pymysql

# 권한설정
chown -R ec2-user:ec2-user $APP_DIR

# 5. 앱 실행 (백그라운드)
sudo ./venv/bin/python3 test_main.py > $APP_DIR/app.log 2>&1 &
