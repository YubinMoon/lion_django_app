FROM python:3.11

ARG APP_NAME=/app

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR ${APP_NAME}

COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . ${APP_NAME}

WORKDIR ${APP_NAME}/lion_app

CMD ["gunicorn", "lion_app.wsgi:application", "--config", "lion_app/gunicorn_config.py"]
