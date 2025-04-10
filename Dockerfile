FROM python:3.9-alpine3.13
LABEL maintainer="Popa Vasile Andrei"

ENV PYTHONUNBUFFERED 1 
#Recommended when you're running python in a Docker container
# What it does it tells python that you don't want to buffer the output, the output from python will be printed directly to the
# console which prevents any delays of the massages getting from our pyhton running application to the screen so you can see the logs 
# immediately as the're running

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    # add postgresql database adaptor
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # shell code , soo, hell
    if [ "$DEV" = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    # hell end
    rm -rf /tmp && \
    # postgresql database adaptor continuation
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user    
