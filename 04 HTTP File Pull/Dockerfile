FROM python:3.11-slim-bullseye

WORKDIR /app

COPY requirements.txt .

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "pull_http_file_put_blob.py"]
