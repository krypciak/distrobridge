<!-- markdownlint-disable MD013 MD024 MD001 MD045 -->

# Distrobridge

My personal linux install script.  
I mostly use it to generate custom-built iso's for my usage.  
CAUTION: You PC might explode if you use it.  

```
>> doas sh install.sh --help 
Usage:
    -h --help              Displays this message
    -y --noconfim          Skips confirmations
    -q  --quiet            Silence a lot of output
    -m --mode MODE         Installation mode: [ disk, dir, live, iso ]
    -v --variant VARIANT   [ artix, arch ]
       --offline           Install packages from disk (if available)

 --type=disk options:
       --device DEVICE     Device to install to. Eg. /dev/sda

 --type=dir options:
       --dir DIR           Destination install directory

 --type=iso options:
       --iso ISO           Destination directory for .iso image
       --iso-copy-to DIR   Copy the iso to that dir and delete all previous variant iso's
       --wait-for-dir DIR  Dont start iso build until that dir is mounted
```

You need to be on the same distro as the `--variant` argument, so for example you need to be on arch to use the `arch` variant.  
The `artix` variant may or may not work, I haven't tested it in a while.  
The `--offline` option may or may not work, I haven't tested it in a while.  

### Installing to disk

```bash
sudo sh install.sh --mode disk --variant arch --device /dev/vda
```

### Installing to the current system

```bash
sudo sh install.sh --mode live -variant arch
```

### Installing to a directory

```bash
sudo sh install.sh --mode dir -variant arch --dir /mnt/mymountedroot
```

### Generating an ISO

```bash
sudo sh install.sh  --mode iso --variant arch --iso ./
```
