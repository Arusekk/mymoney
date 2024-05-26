mymoney
=======

mymoney

This project has been abandoned by the original author,
and unfortunately he deleted his GH account.

Initially, with the source repo gone, I started an effort to reverse-engineer
the app's C++ parts, which was not a very hard task thanks to NSA's Ghidra
and Qt's extensive QObject introspection capabilities.
You can see the results of my effort on the `blind-recover` git tag.

Then, I was able to recover the project's history thanks to The Software
Heritage Foundation.
You can use their API to download full repositories, with all metadata,
of projects that have long been gone.

And only then, I realized there were forks of the repo on GitHub.
But here follows my analysis nevertheless.

The repository's latest version was 0.1.1, but the latest available was 0.1.3.
Fortunately, the C++ code has not changed since.
I was able to reproduce a byte-identical binary (the only different thing was
debuginfo's crc32, and since it contains an absolute path, I was unable to guess
that).
If you want to do it too, use SDK toolchain and target 2.0.2.51 (latest
available at the time of 0.1.3 compilation); it is no longer available in SDK
installation, but you can install it by copying toolchains/targets inside the
builder image and force-downgrading them (note that glibc downgrades need extra
care, downgrade other packages first, or try some `LD_PRELOAD` tricks).

Some keywords if you want to do it: `/srv/mer/t*`, `chroot`,
`binfmt-misc+qemu-arm-static`, `ssu rel 2.0.2.51 && zypper ref && zypper dup`,
`chown targets`, `sb2-init`.
Maybe there is an easier way, not sure.

For older targets (like 1.1.2.16), modify `/usr/bin/updateQtCreatorTargets` to
include gnu++98:
```py
    for std in ["gnu++17", "gnu++14", "gnu++11", "gnu++03", "gnu++98"]:
```
