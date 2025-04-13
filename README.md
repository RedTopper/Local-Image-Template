# Local Image Template

Build and deploy simple immutable customizations, locally!

## About

The traditional method of layering with `rpm-ostree` can be unreliable. One way to avoid this is to build and publish 
your own image with the ublue [image-template](https://github.com/ublue-os/image-template).

If you only have a few packages you want to layer (for example, a single .rpm for a VPN provider), this can be a bit of 
a pain to set up. Instead, this repo will build a new image and switch to it locally with minimal commands.

A similar and more automated/official concept is currently being discussed in 
[fedora/bootc#4](https://gitlab.com/fedora/bootc/tracker/-/issues/4).

## Usage

1. Clone this repo
2. `just examples` to select an example to get started from
3. Make modifications to your `Containerfile`
4. `just update` to build and switch to your image!

> [!TIP]
> Consider pinning your active deployment before switching to your own image with `sudo ostree admin pin #`

> [!NOTE]  
> The scripts in this repo rely on [the just runner](https://github.com/casey/just), which not all base images have. You
> may need to bootstrap `just` with `./boostrap-just.sh` first.

> [!WARNING]  
> Make sure your `FROM` command is based off of your current desktop environment! Switching between desktop environments
> can cause undefined behavior.

## Examples

All example Containerfiles are provided in the `examples` directory. 

### install-local-rpms

This example demonstrates how to layer local .rpm files. You can use this for installing RPMs provided by VPNs or other
software that cannot otherwise be installed in a distrobox.

### fedora-kinoite-with-rpmfusion

This example provides a way for layering rpmfusion packages on Fedora's base Kinoite image. You can use this image if
you are not using the ublue base images. It also shows how to replace normally read-only SDDM files.

### ublue-kinoite-lightweight-gaming

This example layers steam on `ublue-os/kinoite-nvidia`, along with some other packages. It shows how to enable and
install software from custom `copr` repositories.
