# compulab-l4t

Supports NVIDIA L4T/JetPack 35.6.4, 36.4.3, and 36.4.4 layouts.

* How to install:
```
curl -fsSL https://github.com/compulab-yokneam/compulab-l4t/archive/refs/heads/Linux_for_Tegra.tar.gz | tar -C ${L4T_ROOT} --strip-components=1 -xvz
```

After installing into a 35.6.4 tree, source `compulab-l4t.env` and use
`select_bootloader` or `deploy_bootloader*` so the 35.6.4 UEFI payload is
copied from `bootloader/UEFI/35.6.4/` before flashing.
