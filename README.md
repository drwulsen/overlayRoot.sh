# overlayRoot.sh
Overlay your root FS on a Rasbperry Pi with TMPFS to keep the root (SD Card) read-only.

This script acts as a "replacement" for init and does not require an initramfs.
Well, it executes and then calls init, of course.
It remounts the (already mounted) root read-only and mounts a TMPFS via OverlayFS on top.

The SD is kept read-only, therefore not prone to filesystem corruption on a hard power-off.
Ideal for a use as media center at home or in a car.

The original script was created by Pascal Suter.
It would not work with gentoo so I did some edits to get it running, as well as some restructuring.

Installation is simple:
* Download the script overlayRoot.sh into /sbin/overlayRoot.sh
* chmod +x /sbin/overlayRoot.sh
* edit /boot/cmdline.txt to read init=/sbin/overlayRoot.sh
* Reboot

If any changes to the underlying (lower) root FS are necessary:
* Edit /boot/cmdline.txt to read init=/sbin/init (or /sbin/systemd if you use it)
* Reboot

Currently it's been only tested with following constellation:

Fstab uses /dev/mmcblk0pX as identifier.
So does cmdline.txt
System running is Gentoo linux.

An original error reported on the Raspberry Pi forum, saying it would not boot wihtout any display connected to HDMI is not happening here.
