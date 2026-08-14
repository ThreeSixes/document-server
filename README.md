# Document server

## Background

This project serves as a mobile document server that can also host [Mediawiki](https://www.mediawiki.org/wiki/MediaWiki) content packaged as [ZIM](https://en.wikipedia.org/wiki/ZIM_(file_format)) files. This is inended to run on a small portable system like a Raspberry Pi, but can also run on a standard laptop or desktop computer.

## Theory of operation

When the host starts and fails to connect to a wifi network within 30 seconds of the `ap-mode-handler` systemd unit starts a script is called that starts `hostapd` to generate a wirless network for clients to join. DHCP and DNS are provided by `dnsmasq`. A set of records can be added to `dnsmasq.com` that allow client machines to more easily access the web page served from the Pi. A web server started by `docker compose` serves files stored under `nginx-root/content` with `nginx` and any ZIM files stored under `nginx-root/content/wikis-active` with `kiwx-serve`. A simple landing page provies a link to each category.

All content is stored under the `content/` subpath of the web server and active wiki ZIM files are served under the `wiki/` subpath.


## Installation

This project can be installed using two methods. The recommended method is using an [Ansible]() playbook but manual installation instructions are also provided. Ansible allows for automated installation of all needed applications and files and has been tested on Ubuntu 26.04 and Raspbian.

### Installation using Ansible

Requirements:
  - Pyenv (optional)
  - Pipenv (optional)
  - Ansible

### Manual installation


