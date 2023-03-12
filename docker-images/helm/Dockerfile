FROM alpine:3.7

USER root
RUN apk add --no-cache -U curl bash openssl git &&\
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 &&\
    chmod 700 get_helm.sh &&\
    ./get_helm.sh

USER 1234
ENTRYPOINT ["helm"]