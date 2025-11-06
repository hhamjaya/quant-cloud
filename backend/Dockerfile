# # Local-only container for testing the same logic with Uvicorn
# FROM python:3.11-slim
# WORKDIR /app
# COPY handler.py /app/handler.py
# RUN pip install fastapi==0.115.2 uvicorn==0.30.6
# # Minimal FastAPI wrapper
# RUN printf '%s\n' \
# "from fastapi import FastAPI, Request" \
# "import handler as h" \
# "app = FastAPI()" \
# "@app.get('/hello')" \
# "async def hello(name: str = 'World'):" \
# "    event = {'queryStringParameters': {'name': name}}" \
# "    res = h.lambda_handler(event, None)" \
# "    return {'message': res['body']}" \
# > /app/app.py
# EXPOSE 8000
# CMD [\"uvicorn\", \"app:app\", \"--host\", \"0.0.0.0\", \"--port\", \"8000\"]

# Local-only container for testing the same logic with Uvicorn
FROM python:3.11-slim
WORKDIR /app
COPY handler.py /app/handler.py
RUN pip install fastapi==0.115.2 uvicorn==0.30.6

# Minimal FastAPI wrapper
RUN printf '%s\n' \
"from fastapi import FastAPI, Request" \
"import handler as h" \
"app = FastAPI()" \
"@app.get('/hello')" \
"async def hello(name: str = 'World'):" \
"    event = {'queryStringParameters': {'name': name}}" \
"    res = h.lambda_handler(event, None)" \
"    return {'message': res['body']}" \
> /app/app.py

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]