FROM haproxy:2.7.5-alpine

USER root

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY out/anime-app.com /anime-app.com
COPY out/root-app.com /root-app.com
COPY index.html /index.html
RUN chmod +x /anime-app.com && \
  chmod +x /root-app.com && \
  sh /anime-app.com --assimilate && \
  sh /root-app.com --assimilate

