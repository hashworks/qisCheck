# HTWK QIS Check

This script will perform a login on the QIS System of the HTWK Leipzig (qisserver.htwk-leipzig.de) and compare previous polls by their MD5 hash. If they don't match it'll notify you over telegram and optionally send you the HTML file.

It can be used to frequently poll for new exam grades.

## Usage

Requirements:
* standard unix core utils
* bash
* curl

Clone the repo and copy the `qisCheck.service` and `qistCheck.timer` files to `/etc/systemd/system`.

Adjust the following environment variables in `qisCheck.service`:
* `TELEGRAM_TOKEN`
* `TELEGRAM_CHAT_ID`
* `HTWK_SHIBBOLETH_USERNAME`
* `HTWK_SHIBBOLETH_PASSWORD`

Also you might need to adjust the path to `qisCheck.sh`.

Please note that if you adjust the optional variable `TELEGRAM_SEND_FILE` to `true` your exam marks will be send over telegram servers!
Telegram bot chats are not E2E.

Make sure `qisCheck.service` is only readable by root since it contains authentication data:

`chmod 0600 /etc/systemd/system/qisCheck.service`

Afterwards you can enable the hourly timer:

`systemctl enable --now qisCheck.timer`

## Example

![example](https://fb.hash.works/GuiHMy/)
