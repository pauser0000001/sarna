FROM python:3.6-alpine

RUN apk --update --no-cache add \
    yarn && \
	mkdir -p /sarna/static/ && \
	mkdir -p /sarna/database/ && \
	mkdir -p /sarna/uploaded_data

ADD requirements.txt /tmp/
RUN apk --no-cache add build-base libxslt-dev python3-dev jpeg-dev zlib-dev && \
    pip install -r /tmp/requirements.txt && \
    apk del build-base libxslt-dev python3-dev jpeg-dev zlib-dev

ADD static/package.json /sarna/static/
RUN cd /sarna/static && yarn install
RUN apk --no-cache add libmagic libxslt jpeg zlib

WORKDIR /sarna
COPY ./ /sarna/

RUN echo "sarna:x:3000:3000:sarna:/sarna:/bin/sh" >> /etc/passwd && \
    echo "sarna:x:3000:" >> /etc/group && \
    chown sarna:sarna /sarna/database /sarna/uploaded_data
USER sarna
ENV FLASK_ENV=development

EXPOSE 5000
ENTRYPOINT ["/sarna/entrypoint.sh"]
