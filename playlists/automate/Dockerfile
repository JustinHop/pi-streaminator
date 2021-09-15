FROM alpine:3.12
LABEL MAINTAINER="Justin Hoppensteadt <justinrocksmadscience+git@gmail.com>"

RUN apk add --no-cache  \
    chromium \
    chromium-chromedriver \
    curl \
    libexif \
    py3-pip \
    py3-lxml \
    py3-simplejson \
    python3 \
    udev \
    unzip \
    xvfb \
    && \
pip3 install \
    docopt \
    selenium \
    pyvirtualdisplay \
    youtube-dl \
    && \
    addgroup -g 1000 chrome && adduser -D -G chrome -h /home/chrome -u 1000 chrome

RUN mkdir -p /home/chrome/.config /home/chome/.cache
ADD ./chrome-settings /home/chrome/.config/chromium
ADD ./subs.py /subs.py
RUN chmod 755 /subs.py
RUN chown -R 1000:1000 /home/chrome

USER chrome

ENTRYPOINT /usr/bin/python3
CMD /subs.py
