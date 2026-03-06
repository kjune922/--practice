#!/bin/bash
exec > >(tee /var/log/user-data-ollama.log|logger -t user-data-ollama -s 2>/dev/console) 2>&1

echo "클라우드 AI인프라 프로비저닝"

sudo dnf update -y
sudo dnf install -y python3 python3-pip nginx git

curl -L https://ollama.com/install.sh | sh

OLLAMA_APP_DIR="/home/ec2-user/app"
mkdir -p $OLLAMA_APP_DIR
chown ec2-user:ec2-user $OLLAMA_APP_DIR
cd $OLLAMA_APP_DIR

python3 -m venv venv
./venv/bin/pip install fastapi uvicorn psycopg2-binary redis celery ollama

cat <<EOF | sudo tee /etc/nginx/conf.d/ai_app.conf
server {
  listen 80;
  server_name _;
  location / {
    proxy_pass http://127.0.0.1:8000;

    proxy_read_timeout 300s;
    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;

    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOF

sudo systemctl restart nginx
sudo systemctl enable nginx

# Ollama환경변수문제
export HOME=/home/ec2-user

ollama serve &
sleep 15
ollama pull tinyllama

cat <<EOF > $OLLAMA_APP_DIR/test_ai_main.py

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
import psycopg2
import ollama
import uvicorn
from datetime import datetime

app = FastAPI()

# 1. 테라폼에서 주입받은 RDS 접속 정보
db_config = {
    "host": "${db_endpoint}",
    "database": "test_PostgreSQL",
    "user": "test",
    "password": "dlrudalswns2!",
    "port": 5432
}

# 2. DB 테이블 초기화 로직
def init_db():
    try:
        conn = psycopg2.connect(**db_config)
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS ai_history (
                id SERIAL PRIMARY KEY,
                prompt TEXT,
                response TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        conn.commit()
        cur.close()
        conn.close()
        print("DB 초기화 완료")
    except Exception as e:
        print(f"DB 연결 실패: {e}")

init_db()

# 3. 메인 채팅 화면 (HTMLResponse)
@app.get("/", response_class=HTMLResponse)
async def read_root():
    return """
    <!DOCTYPE html>
    <html lang="ko">
    <head>
        <meta charset="UTF-8">
        <title>K-June AI Chatbot</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <style>
            .chat-bg { background-color: #f3f4f6; }
            .user-msg { background-color: #fb923c; color: white; margin-left: auto; }
            .ai-msg { background-color: white; color: #1f2937; margin-right: auto; }
        </style>
    </head>
    <body class="chat-bg h-screen flex flex-col">
        <header class="bg-orange-600 text-white p-4 shadow-lg flex justify-between items-center">
            <h1 class="text-xl font-bold">🚀 Llama 3 AI Chatbot Service</h1>
            <span class="text-sm opacity-80">이경준의 클라우드 포트폴리오</span>
        </header>
        
        <div id="chat-box" class="flex-1 p-6 overflow-y-auto flex flex-col gap-4">
            <div class="ai-msg p-4 rounded-2xl shadow-sm max-w-[80%]">
                안녕하세요! 무엇이든 물어보세요!!
            </div>
        </div>

        <div class="p-4 bg-white border-t-2 border-gray-200 flex gap-4">
            <input id="prompt" type="text" 
                   class="flex-1 border-2 border-gray-200 p-3 rounded-xl focus:outline-none focus:border-orange-500" 
                   placeholder="AI에게 질문을 입력하세요..." 
                   onkeyup="if(window.event.keyCode==13){send()}">
            <button onclick="send()" class="bg-orange-600 text-white px-8 py-3 rounded-xl font-bold hover:bg-orange-700 transition-colors">
                전송
            </button>
        </div>

        <script>
            async function send() {
                const input = document.getElementById('prompt');
                const box = document.getElementById('chat-box');
                const text = input.value;
                if(!text) return;
                
                // 사용자 메시지 추가
                box.innerHTML += '<div class="user-msg p-4 rounded-2xl shadow-sm max-w-[80%]">' + text + '</div>';
                input.value = '';
                box.scrollTop = box.scrollHeight;
                
                // 로딩 표시
                const loadingId = 'loading-' + Date.now();
                box.innerHTML += '<div id="' + loadingId + '" class="ai-msg p-4 rounded-2xl shadow-sm max-w-[80%] italic text-gray-400">답변을 생각하는 중...</div>';
                box.scrollTop = box.scrollHeight;
                
                try {
                    const res = await fetch('/ask?prompt=' + encodeURIComponent(text));
                    const data = await res.json();
                    
                    document.getElementById(loadingId).remove();
                    
                    if(data.answer) {
                        box.innerHTML += '<div class="ai-msg p-4 rounded-2xl shadow-sm max-w-[80%]">' + data.answer + '</div>';
                    } else {
                        box.innerHTML += '<div class="ai-msg p-4 rounded-2xl shadow-sm max-w-[80%] text-red-500">에러 발생: ' + (data.error || '알 수 없는 에러') + '</div>';
                    }
                } catch (e) {
                    document.getElementById(loadingId).innerText = "서버 연결에 실패했습니다.";
                }
                box.scrollTop = box.scrollHeight;
            }
        </script>
    </body>
    </html>
    """

@app.get("/ask")
def ask_ai(prompt: str):
    try:
        # 4. Ollama를 통한 Llama 3 모델 추론
        response = ollama.chat(model='llama3', messages=[
            {'role': 'user', 'content': prompt},
        ])
        answer = response['message']['content']

        # 5. 질문과 답변을 PostgreSQL에 저장
        conn = psycopg2.connect(**db_config)
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO ai_history (prompt, response) VALUES (%s, %s)",
            (prompt, answer)
        )
        conn.commit()
        cur.close()
        conn.close()

        return {"prompt": prompt, "answer": answer}
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
EOF

# 5. 앱 실행 권한 부여 및 백그라운드 실행
sudo chown ec2-user:ec2-user $OLLAMA_APP_DIR/test_ai_main.py
sudo -u ec2-user nohup $OLLAMA_APP_DIR/venv/bin/python3 $OLLAMA_APP_DIR/test_ai_main.py > $OLLAMA_APP_DIR/app.log 2>&1 &

echo "모든 인프라 세팅 및 앱 가동 끝"
