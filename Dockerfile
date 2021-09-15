FROM --platform=linux/arm/v7 ubuntu:14.04 as PHANTOMJS

# Dependencies we just need for building phantomjs
ENV buildDependencies\
  wget unzip python build-essential g++ flex bison gperf\
  ruby perl libsqlite3-dev libssl-dev libpng-dev

# Dependencies we need for running phantomjs
ENV phantomJSDependencies\
  libicu-dev libfontconfig1-dev libjpeg-dev libfreetype6

# Installing phantomjs
RUN \
    # Installing dependencies
    apt-get update -yqq \
&&  apt-get install -fyqq ${buildDependencies} ${phantomJSDependencies}\
    # Downloading src, unzipping & removing zip
&&  mkdir phantomjs \
&&  cd phantomjs \
&&  wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.0.0-source.zip \
&&  unzip phantomjs-2.0.0-source.zip \
&&  rm -rf /phantomjs/phantomjs-2.0.0-source.zip \
    # Building phantom
&&  cd phantomjs-2.0.0/ \
&&  ./build.sh --confirm --silent \
    # Removing everything but the binary
&&  ls -A | grep -v bin | xargs rm -rf \
    # Symlink phantom so that we are able to run `phantomjs`
&&  ln -s /phantomjs/phantomjs-2.0.0/bin/phantomjs /usr/local/share/phantomjs \
&&  ln -s /phantomjs/phantomjs-2.0.0/bin/phantomjs /usr/local/bin/phantomjs \
&&  ln -s /phantomjs/phantomjs-2.0.0/bin/phantomjs /usr/bin/phantomjs \
    # Removing build dependencies, clean temporary files
&&  apt-get purge -yqq ${buildDependencies} \
&&  apt-get autoremove -yqq \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # Checking if phantom works
&&  phantomjs -v

CMD \
    echo "phantomjs binary is located at /phantomjs/phantomjs-2.0.0/bin/phantomjs"\
&&  echo "just run 'phantomjs' (version `phantomjs -v`)"


FROM --platform=linux/arm/v7 alpine:latest as MPV
LABEL maintainer="Justin Hoppensteadt <justinrocksmadscience+git@gmail.com>"

COPY --from=PHANTOMJS /phantomjs /phantomjs

RUN ln -s /phantomjs/phantomjs-2.0.0/bin/phantomjs /usr/local/share/phantomjs \
&&  ln -s /phantomjs/phantomjs-2.0.0/bin/phantomjs /usr/local/bin/phantomjs \
&&  ln -s /phantomjs/phantomjs-2.0.0/bin/phantomjs /usr/bin/phantomjs

ENV UID_GID=1000
ENV RUNAS=pi

RUN apk add --no-cache \
        bash \
        ca-certificates \
        ffmpeg \
        git \
        libstdc++ \
        mesa-dri-gallium \
        mpv \
        mutagen \
        py3-keyring \
        py3-pip \
        py3-pycryptodome \
        py3-requests \
        py3-libxml2 \
        py3-yaml \
        py3-websockets \
        rtmpdump \
        sqlite \
        ttf-opensans \
        ttf-inconsolata  \
        unzip \
        wget \
        xdriinfo \
    && \
    cd /tmp && wget https://github.com/wez/atomicparsley/releases/download/20210715.151551.e7ad03a/AtomicParsleyAlpine.zip && \
    cd /usr/local/bin && unzip /tmp/AtomicParsleyAlpine.zip && rm /tmp/AtomicParsleyAlpine.zip && cd / && \
    python3 -m pip install --upgrade youtube-dl requests-cache feedparser xmltodict docopt && \
    python3 -m pip install --upgrade git+https://github.com/yt-dlp/yt-dlp && \
    true

COPY group /etc/group
RUN chown 0:0 /etc/group && chmod 644 /etc/group
COPY pulse-client.conf /etc/pulse/client.conf
COPY config /home/pi/.config
COPY playlists /home/pi/playlists

RUN find /home/pi/.config -type f -exec chmod -v 644 {} \; && rm -rf /home/pi/.config/mpv-old

RUN adduser -h /home/${RUNAS} -G ${RUNAS} -D -u ${UID_GID} ${RUNAS}
USER pi
RUN mkdir /home/${RUNAS}/tube
ENTRYPOINT /usr/bin/mpv
