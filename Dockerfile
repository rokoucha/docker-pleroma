FROM elixir:1.7-alpine

ENV UID=911 GID=911 \
    MIX_ENV=prod

ARG PLEROMA_VER=develop

RUN apk -U upgrade \
    && apk add --no-cache \
       build-base \
       git

RUN addgroup -g ${GID} pleroma \
    && adduser -h /pleroma -s /bin/sh -D -G pleroma -u ${UID} pleroma

USER pleroma
WORKDIR pleroma

RUN git clone -b develop https://git.pleroma.social/pleroma/pleroma.git /pleroma \
    && git checkout ${PLEROMA_VER}

COPY config/config /pleroma/config/

COPY config/tos.html /pleroma/priv/static/static/terms-of-service.html
COPY config/instance /pleroma/priv/static/instance/
COPY config/emoji /pleroma/priv/static/emoji/custom/

RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mix compile

VOLUME /pleroma/uploads/

CMD ["mix", "phx.server"]
