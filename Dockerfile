FROM openjdk:7-jre-alpine

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN addgroup -S jetty && adduser -D -S -H -G jetty jetty && rm -rf /etc/group- /etc/passwd- /etc/shadow-

ENV JETTY_HOME /usr/local/jetty
ENV PATH $JETTY_HOME/bin:$PATH
RUN mkdir -p "$JETTY_HOME"
WORKDIR $JETTY_HOME

# time zone
ENV TZ Asia/Shanghai
RUN set -xe \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# lang
ENV LANG C.UTF-8
# add libs
RUN set -xe \
    && apk --update add curl tar bash
# download and Extract
ENV JETTY_VERSION 8.1.17.v20150415
ENV JETTY_TGZ_URL http://central.maven.org/maven2/org/eclipse/jetty/jetty-distribution/$JETTY_VERSION/jetty-distribution-$JETTY_VERSION.tar.gz
RUN set -xe \
	&& curl -SL "$JETTY_TGZ_URL" -o jetty.tar.gz \
    && tar -xvf jetty.tar.gz --strip-components=1

RUN set -xe \
    && sed -i '/jetty-logging/d' etc/jetty.conf \
    && rm -fr javadoc \
    && rm jetty.tar.gz* \
    && rm contexts/javadoc.xml \
    && rm contexts/test.xml \
    && rm -fr contexts/test.d \
    && rm webapps/spdy.war \
    && rm webapps/test.war
# remove libs  
RUN set -xe \
    && apk del curl tar \
    && chown -R jetty:jetty "$JETTY_HOME"

EXPOSE 8080
CMD ["jetty.sh", "run"]