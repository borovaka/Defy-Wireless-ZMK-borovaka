# Defy Wireless ZMK: borovaka's keymap

My keymap for the Dygma Defy wireless running ZMK, made from the [Defy-Wireless-ZMK](https://github.com/borovaka/Defy-Wireless-ZMK) template. To make your own, use that template rather than forking this repository. The firmware comes from the [zmk-defy-wireless](https://github.com/borovaka/zmk-defy-wireless) module, pinned by its release tag; its README explains what the port supports, its risks, and how the keyboard is installed and taken back to stock.

This is a community project, not affiliated with or endorsed by Dygma.

The keymap, in [config/defy_neuron.keymap](config/defy_neuron.keymap), is five layers saved from Bazecor plus the Defy controls on Fn; the module's README lists the [layers and controls](https://github.com/borovaka/zmk-defy-wireless#keymap). [config/defy_neuron.conf](config/defy_neuron.conf) holds the Neuron's settings and [config/defy.conf](config/defy.conf) the halves'.

## The images

Each push builds them into the run's `firmware` artifact. A push to `main` also replaces the release tagged `firmware`, where [defy-installer](https://github.com/borovaka/defy-installer) finds them:

```sh
defy-installer update --from borovaka/Defy-Wireless-ZMK-borovaka   # the first time
defy-installer update                                              # after that
```

| File | Goes to |
|---|---|
| `left-hybrid-radio.bin`, `right-hybrid-radio.bin` | The halves. Each carries the radio firmware it installs when its radio runs another version |
| `neuron-hybrid.hex` | The Neuron. It holds the keymap, so after a keymap change only this one is new |
| `neuron-hybrid.uf2` | The Neuron's ZMK alone, to copy onto its `DEFY` drive. Fn with the left half's inner top key, beside 5, shows the drive |
| `manifest.json` | What the build holds: the module version, this repository and commit, and each image's size and SHA-256 |

The artifact also holds `.uf2` copies of the halves' images and the radio's own `radio.bin`, `radio.seal` and `radio.c`, from which the halves' images are built; the installer does not use them.

## Building on your computer

With Docker installed:

```sh
./build.sh                  # both halves and the Neuron
./build.sh neuron-hybrid    # only the Neuron, after a keymap change
```

The images land in `firmware/`, with `manifest.json`; `defy-installer update --firmware firmware` installs them. The first run fetches ZMK, Zephyr and the module into this folder, about 3 GB; git ignores them. The module's README lists the [other targets](https://github.com/borovaka/zmk-defy-wireless#build-targets).

## Updating the firmware

The module's version is the tag in [config/west.yml](config/west.yml) and in [.github/workflows/build.yml](.github/workflows/build.yml). Change both to a newer release tag and push. The module's release notes say what changed and whether the halves need new images too. For builds on this computer, also copy the container image's digest from the module's `scripts/zmk` at that tag into [build.sh](build.sh).

## Licence

MIT; see [LICENSE](LICENSE).
