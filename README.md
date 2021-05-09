# busy-linux
Busybox-based really small Linux distribution made with docker

# Building

1. Clone repository
2. Run: `docker build -t busy-linux .` to build as `busy-linux`.
3. Run built container with `docker run --detach --name busy-dev -it busy-linux`
4. Copy from container to host: `docker cp busy-dev:/root/busy-linux.efi ./`

# Installation

1. Copy to EFI partition: `cp busy-linux.efi $ESP/EFI/linux/` or any other directory you prefer
2. Optionally add to boot manager: `efibootmgr --create --disk /dev/sdz --part 1 --loader /EFI/linux/linux.efi --label "My Own Linux Distro" --verbose`, where /dev/sdz1 is your EFI system partition.
