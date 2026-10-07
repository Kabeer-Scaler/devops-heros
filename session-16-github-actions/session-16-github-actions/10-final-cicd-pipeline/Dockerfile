FROM python:3.12-slim

WORKDIR /app

COPY app ./app

USER 65532:65532

CMD ["python", "-c", "from app.calculator import add, divide; print(f'Calculator smoke test: 2 + 3 = {add(2, 3)}; 10 / 2 = {divide(10, 2)}')"]
