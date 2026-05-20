# uprightlab — Workstation Setup

This file documents manual setup steps required on the MacBook workstation that cannot be automated via the Brewfile.

- An alias needs adding to use `rpi-imager`, as the Pi Imager installs as macOS app, not a CLI tool. That can be done with the following command:

    `echo "alias rpi-imager='/Applications/Raspberry\ Pi\ Imager.app/Contents/MacOS/rpi-imager'" >> ~/.zshrc`

    `source ~/.zshrc`