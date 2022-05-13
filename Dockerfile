FROM klakegg/hugo AS hugo


COPY . /opt
WORKDIR /opt/site-src

ENTRYPOINT ["hugo"]
CMD ["--destination", "public"]
#CMD ["--config", "/src/site-src/config.yaml", "--contentDir", "/src/site-src/content", "--themesDir", "/src/site-src/themes", "--destination", "public"]

FROM caddy:alpine
RUN apk add --no-cache tree
RUN mkdir /hugocontents
COPY --from=hugo /opt/site-src/ /hugocontents
CMD ["tree", ,"-d", "/hugocontents/public"]
#CMD ["ls", "-l", "/hugocontents"]
#CMD ["ls", "-l", "/usr/share/caddy/"]
