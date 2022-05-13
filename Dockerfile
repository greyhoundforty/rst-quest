FROM klakegg/hugo AS hugo


COPY . /opt
WORKDIR /opt/site-src

ENTRYPOINT ["hugo"]
CMD ["--destination", "public"]

FROM caddy:alpine
COPY --from=hugo /opt/site-src/ /usr/share/caddy