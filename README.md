# HTWK QIS Check

This script will perform a login on the QIS System of the HTWK Leipzig (qisserver.htwk-leipzig.de) and compare previous polls by their MD5 hash. If they don't match it'll notify you over telegram and optionally send you the HTML file.

It can be used to frequently poll for new exam grades.

## Usage

Requirements:
* standard unix core utils
* bash
* curl

Clone the repo and copy the `qisCheck.service` and `qistCheck.timer` files to `/etc/systemd/system`.

Create `/etc/qisCheck` and copy `config` in that directory.
Adjust the following environment variables in `/etc/qisCheck/config`:
* `TELEGRAM_TOKEN`
* `TELEGRAM_CHAT_ID`
* `HTWK_SHIBBOLETH_USERNAME`
* `HTWK_SHIBBOLETH_PASSWORD`
* `STUDY_COURSE`

Please note that if you adjust the optional variable `TELEGRAM_SEND_FILE` to `true` your exam marks will be sent over telegram servers without E2E!

Make sure `/etc/qisCheck/config` is only readable by root since it contains authentication data.

Afterwards you can enable the hourly timer:

`systemctl enable --now qisCheck.timer`

## Example

![example](https://fb.hash.works/GuiHMy/)
