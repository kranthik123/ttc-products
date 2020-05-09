From python:3

LABEL maintainer="Kranthi Kavuri <kranthik123@gmail.com>"

WORKDIR /app
ADD app/. /app/

RUN pip install -r ./requirements.txt

ENTRYPOINT [ "python" ]
CMD [ "flask_app.py"]
