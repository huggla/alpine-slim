FROM huggla/alpine-official:20180907-edge as stage1

RUN apk --no-cache --quiet manifest libressl2.7-libcrypto libressl2.7-libssl apk-tools | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && mkdir -p /rootfs/etc/apk /rootfs/usr/share/apk/keys /rootfs/var/cache/apk \
 && cp -a /etc/apk/repositories /rootfs/etc/apk/ \
# && cp -a /usr/share/apk /rootfs/usr/share/ \
 && tar -xvp -f /apks_files.tar -C /rootfs/
 
FROM huggla/busybox:20180907-edge as stage2

COPY --from=stage1 /rootfs /rootfs
COPY --from=stage1 /rootfs /

RUN apk add --initdb \
 && cp -a /lib/apk /rootfs/lib/
 
FROM huggla/busybox:20180907-edge

COPY --from=stage2 /rootfs /

