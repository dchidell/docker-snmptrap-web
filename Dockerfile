FROM alpine:3.14 as build
LABEL maintainer="David Chidell (dchidell@cisco.com)"

FROM build as webproc
ENV WEBPROCVERSION 0.4.0
ENV WEBPROCURL https://github.com/jpillora/webproc/releases/download/v$WEBPROCVERSION/webproc_"$WEBPROCVERSION"_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROCURL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as snmptrap
RUN apk --no-cache add net-snmp
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
ADD mibs.tar.gz /mibs/
ADD snmptrapd.conf /etc/snmp/snmptrapd.conf
ENTRYPOINT ["webproc","-o","restart","-c","/etc/snmp/snmptrapd.conf","--","snmptrapd","-n","-L","o","-f","-M","/mibs","-m","ALL"]
EXPOSE 162/udp 8080
