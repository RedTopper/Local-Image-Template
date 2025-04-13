# What to call your image
image := "localhost/local-image"

# Internally used variables
current_time := shell("date '+%Y%m%d-%H%M'")
format := "{{.ID}}"

[private]
default:
    @just --list

[private]
[no-exit-message]
requires-root:
    @if [[ "$EUID" -ne 0 ]]; then echo "This command requires sudo/root."; exit 1; fi

[private]
[no-exit-message]
prompt message="Are you sure?" decline="Abort!":
    @read -er -p "{{ message }} [y/N] " choice; \
    if [[ "$choice" != [Yy] ]]; then echo "{{ decline }}"; exit 1; fi

[private]
[no-exit-message]
clean-images *images: requires-root
    @buildah rm --all  # Remove failed/ctrl-c'd builds first
    @if [[ -z "{{ images }}" ]]; then echo "No images to clean!"; exit 1; fi
    buildah rmi {{ images }}

# Build your custom image (use 'just switch $tag' to switch to the built image)
build tag=current_time: requires-root
    podman build --tag "{{ image }}:{{ tag }}" --tag "{{ image }}:latest" --pull=always .

# Switch to custom image (use 'just check-built-images' to see all built tags)
switch tag: requires-root
    bootc switch --transport containers-storage "{{ image }}:{{ tag }}"
    rpm-ostree db diff

# Build and switch to new custom image
update: (build current_time) (switch current_time)

# List out previously built custom images
[group('List')]
list-built-images: requires-root
    buildah images --filter "reference={{ image }}"

# List out all images fetched or built
[group('List')]
list-all-images: requires-root
    buildah images

# List the contents of the mount cache for root, filtered to .rpm files
[group('List')]
list-cache:
    -tree "/var/tmp/buildah-cache-0" -P "*.rpm" --prune -h --du

# [destructive, will prompt] Clean all custom images
[group('Clean')]
clean-built-images: requires-root list-built-images
    @just prompt "Really clean all above images?" "Didn't clean images."
    @just clean-images $(buildah images --filter "reference={{ image }}" --format "{{ format }}")
    buildah rmi --prune

# [destructive, will prompt] Clean non-latest custom images
[group('Clean')]
clean-old-built-images: requires-root list-built-images
    @just prompt "Really clean above non-latest old images?" "Didn't clean images."
    @just clean-images $(buildah images --filter "reference={{ image }},before={{ image }}:latest" --format "{{ format }}")
    buildah rmi --prune

# [destructive, will prompt] Clean ALL images
[group('Clean')]
clean-all-images: requires-root list-all-images
    @just prompt "Really remove ALL the above images?" "Didn't clean images."
    buildah rm --all
    buildah rmi --all

# [destructive, will prompt] Clean mount cache, including previously cached .rpm files
[group('Clean')]
clean-cache: requires-root list-cache
    @just prompt "Really clear the above cache?" "Didn't clear cache."
    buildah rm --all
    buildah prune

# [destructive, will prompt] Clean everything
[group('Clean')]
clean:
    -just clean-old-built-images
    -just clean-built-images
    -just clean-all-images
    -just clean-cache

# Choose an example to start from!
[group('Start Here')]
[no-exit-message]
examples:
    #!/usr/bin/env bash
    set -euo pipefail
    just prompt "This will overwrite your current files! Is that OK?" "Didn't copy any files."
    SELECTED=$(find examples -mindepth 1 -maxdepth 1 -type d -print | fzf --multi --preview 'cat {}/Containerfile' || true)
    if [[ -n "$SELECTED" && -d "$SELECTED" ]]; then
      cp -r "$SELECTED"/* .
      echo "Have fun!"
    else
      echo "Didn't select anything."
    fi
