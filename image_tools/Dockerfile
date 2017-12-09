FROM scaleway/ubuntu:amd64-16.10
# following 'FROM' lines are used dynamically thanks do the image-builder
# which dynamically update the Dockerfile if needed.
#FROM scaleway/ubuntu:armhf-16.10       # arch=armv7l
#FROM scaleway/ubuntu:arm64-16.10       # arch=arm64
#FROM scaleway/ubuntu:i386-16.10        # arch=i386
#FROM scaleway/ubuntu:mips-16.10        # arch=mips

# Prepare rootfs
RUN /usr/local/sbin/scw-builder-enter

# Add your commands here (before scw-builder-leave and after scw-builder-enter)
RUN sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

RUN sudo apt-add-repository ppa:ansible/ansible

RUN  apt-get update && sudo apt-get install -y docker-ce ansible

RUN mkdir -p /etc/systemd/system/docker.d
COPY docker.conf /etc/systemd/system/docker.service.d/override.conf
RUN systemctl enable docker



# Clean rootfs
RUN /usr/local/sbin/scw-builder-leave
