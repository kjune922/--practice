from locust import HttpUser, task, between

class AIAppUser(HttpUser):
    # 각 요청 사이 대기 시간 (1초~3초)
    wait_time = between(1, 3)

    @task
    def chat_test(self):
        # 채팅 서비스의 질문 던지는 엔드포인트
        # 실제 사용자가 묻는 것처럼 프롬프트를 구성
        self.client.get("/ask?prompt=부산의 날씨는 어때?")
