FROM huggla/busybox as stage1
FROM huggla/alpine-official as stage2

COPY --from=stage1 / /rootfs

RUN apk --no-cache --quiet manifest libressl2.7-libcrypto libressl2.7-libssl apk-tools | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && tar -xvp -f /apks_files.tar -C /rootfs/
 
FROM huggla/busybox

COPY --from=stage2 /rootfs /
