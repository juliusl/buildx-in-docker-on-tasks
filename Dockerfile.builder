FROM docker

COPY --from=docker/buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx
COPY build_entrypoint.sh build_entrypoint.sh

RUN chmod +x ./build_entrypoint.sh
ENTRYPOINT ["/build_entrypoint.sh"]