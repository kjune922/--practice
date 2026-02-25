from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def read_root():
  return { "message": "안녕, 이경준의 Fastapi 앱" }

@app.get("/health")
def health_check():
  return { "status": "healthy"}

