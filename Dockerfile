FROM alpine:3.11 as build
LABEL maintainer="David Chidell (dchidell@cisco.com)"

FROM build as webproc
ENV WEBPROC_VERSION 0.3.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as snmptrap
RUN apk --no-cache add net-snmp
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
ADD mibs.tar.gz /mibs/
ADD snmptrapd.conf /etc/snmp/snmptrapd.conf
ENTRYPOINT ["webproc","--on-exit","restart","-c","/etc/snmp/snmptrapd.conf","--","snmptrapd","-n","-L","o","-f","-M","/mibs","-m","ALL"]
