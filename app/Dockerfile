From python:3

LABEL maintainer="Kranthi Kavuri <kranthik123@gmail.com>"

WORKDIR /app
ADD . /app/

RUN pip install -r /app/tests/requirements.txt

WORKDIR /app/tests
ENTRYPOINT ['nose2']
