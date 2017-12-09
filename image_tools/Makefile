NAME =                  my-image
VERSION =               latest
VERSION_ALIASES =       1.2.3 1.2 1
TITLE =                 Ansible
DESCRIPTION =           My image with Ansible
DOC_URL =
SOURCE_URL =            https://github.com/scaleway-community/...
VENDOR_URL =
DEFAULT_IMAGE_ARCH =    x86_64


IMAGE_VOLUME_SIZE =     50G
IMAGE_BOOTSCRIPT =      x86-64-4-10-8-std-1-stable
IMAGE_NAME =            ansible_image

## Image tools  (https://github.com/scaleway/image-tools)
all:    docker-rules.mk
docker-rules.mk:
        wget -qO - https://j.mp/scw-builder | bash
-include docker-rules.mk
