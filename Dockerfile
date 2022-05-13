FROM klakegg/hugo AS hugo


COPY . /opt
WORKDIR /opt/site-src

ENTRYPOINT ["hugo"]
CMD ["--destination", "public"]

FROM caddy:alpine
RUN rm -f /usr/share/caddy/index.html
COPY --from=hugo /opt/site-src/public /usr/share/caddy