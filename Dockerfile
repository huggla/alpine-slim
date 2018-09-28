FROM huggla/alpine-official:20180927-edge as stage1

ARG APKS="libressl2.7-libcrypto libressl2.7-libssl apk-tools"

RUN apk --no-cache --quiet manifest $APKS | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && rm -rf /lib/apk/db \
 && apk add --initdb \
 && mkdir -p /rootfs/rootfs/lib /rootfs/rootfs/etc /rootfs/rootfs/usr/local/bin /rootfs/etc/apk /rootfs/lib/apk /rootfs/var/cache/apk /rootfs/bin /rootfs/sbin /rootfs/usr/bin /rootfs/usr/sbin /rootfs/usr/local/bin /rootfs/tmp /rootfs/run \
 && cp -a /etc/apk/repositories /etc/apk/keys /rootfs/etc/apk/ \
 && touch /rootfs/etc/apk/world \
 && cp -a /lib/apk/db /rootfs/lib/apk/ \
 && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && cp -a /lib/libz.so* /lib/*musl* /rootfs/lib/ \
 && cp -a /bin/busybox /bin/sh /rootfs/bin/ \
 && cp -a $(find /bin/* -type l | xargs) /rootfs/bin/ \
 && cp -a $(find /sbin/* -type l | xargs) /rootfs/sbin/ \
 && cp -a $(find /usr/bin/* -type l | xargs) /rootfs/usr/bin/ \
 && cp -a $(find /usr/sbin/* -type l | xargs) /rootfs/usr/sbin/ \
 && echo 'root:x:0:0:root:/dev/null:/sbin/nologin' > /rootfs/etc/passwd \
 && echo 'root:x:0:root' > /rootfs/etc/group \
 && echo 'root:::0:::::' > /rootfs/etc/shadow \
 && chmod o= /rootfs/etc/* \
 && chmod ugo=rwx /rootfs/tmp \
 && cd /rootfs/var \
 && ln -s ../tmp tmp \
 && cd /rootfs/rootfs/lib \
 && ln -s ../../lib/apk apk \
 && cd /rootfs/rootfs/etc \
 && ln -s ../../etc/apk apk \
 && find /rootfs -type l -exec sh -c 'for x; do [ -e "$x" ] || rm "$x"; done' _ {} +

FROM scratch
 
COPY --from=stage1 /rootfs /

ONBUILD ARG APKS

ONBUILD RUN apk --no-cache --root /rootfs add $APKS
