FROM alpine:3.8 as build
MAINTAINER David Chidell (dchidell@cisco.com)

FROM build as webproc
ENV WEBPROC_VERSION 0.2.2
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as snmptrap
RUN apk --no-cache add net-snmp
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
ADD mibs.tar.gz /mibs/
ADD snmptrapd.conf /etc/snmp/snmptrapd.conf
ENTRYPOINT ["webproc","--on-exit","restart","--config","/etc/snmp/snmptrapd.conf","--","snmptrapd","-n","-L","o","-f","-M","/mibs","-m","ALL"]
