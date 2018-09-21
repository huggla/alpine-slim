FROM huggla/alpine-official:20180921-edge as stage1

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN apk --no-cache --quiet manifest $APKS | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && rm -rf /lib/apk/db \
 && apk add --initdb \
 && mkdir -p /rootfs/etc/apk /rootfs/lib/apk /rootfs/var/cache/apk \
 && cp -a /etc/apk/repositories /etc/apk/keys /rootfs/etc/apk/ \
 && touch /rootfs/etc/apk/world \
 && cp -a /lib/apk/db /rootfs/lib/apk/ \
 && tar -xvp -f /apks_files.tar -C /rootfs/
 
FROM huggla/busybox:20180921-edge

COPY --from=stage1 /rootfs /
