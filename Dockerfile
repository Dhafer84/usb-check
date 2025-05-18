FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    usbutils \
    udev \
    bash \
    coreutils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY check_usb.sh /check_usb.sh
RUN chmod +x /check_usb.sh

CMD ["/check_usb.sh"]
