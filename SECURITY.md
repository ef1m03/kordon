# Безопасность Kordon

Kordon - kill switch для программ: он стоит между вашими программами и сетью, поэтому сам должен быть надёжнее всего остального. Здесь коротко и проверяемо: что Kordon делает на компьютере, что знает наш сервер, как подписаны вход и обновления и куда сообщить об уязвимости.

English below.

## На компьютере

- **Без прав администратора.** Kordon работает от вашего пользователя и управляет только вашими программами: ставит их на паузу (SIGSTOP на macOS и Linux, приостановка процесса на Windows), продолжает и закрывает.
- **Панель - только для вас.** Окно и панель говорят с Kordon по `127.0.0.1` со случайным ключом, который лежит в файле, доступном только вашей учётной записи. Чужой сайт в браузере не может ни прочитать, ни изменить настройки: проверяются адрес, ключ и источник запроса (защита от DNS rebinding и CSRF).
- **Расширение для браузера** спрашивает только сам Kordon на `127.0.0.1:47833`; ответ получают только расширения, не сайты.
- **Секреты на диске** (подключение к Telegram, ключ панели) хранятся с правами `0600`.

## Защиты, которых нет у обычного kill switch

- **Пауза перед сном.** Ноутбук просыпается, Wi-Fi подключается раньше VPN, и программы успели бы отправить первые запросы с настоящим IP. Kordon ставит их на паузу прямо перед сном и отпускает только после свежей проверки IP.
- **Защита при сбое.** Если Kordon упал или его убили, сторожевой процесс сразу ставит защищаемые программы на паузу; они продолжают, когда Kordon поднялся и проверил IP. Падает раз за разом - программы остаются на паузе, а не работают без защиты.
- **Смена сети** - пауза за долю секунды, пока IP не проверен. Плюс утечки IPv6, DNS в другую страну, WebRTC, программы мимо системного прокси и маршрут до самих ИИ-сервисов (Kordon спрашивает у Claude и ChatGPT, какой адрес они видят).
- **`kordon run`** - то же для одной команды на сервере или в CI.

## Что знает наш сервер

Сервер нужен для входа через Telegram, уведомлений и пульта. Он знает:

- номер чата Telegram и хеш (SHA-256) секрета каждого компьютера - самого секрета нет;
- имя компьютера, которое вы видите в пульте;
- для пульта, только пока вы вошли: статус защиты, страну, имена защищаемых программ, что делают агенты, недельные цифры - **без IP-адресов**, в памяти;
- последний профиль настроек для переноса на новый компьютер - без адресов и сетей.

Журнал доступа на сервере выключен: он не знает, с какого адреса к нему обращались. Ограничение частоты запросов держится только в памяти nginx и ничего не пишет. Ежедневный бэкап базы уходит владельцу Kordon.

## Вход через Telegram

Вход подтверждает сервер **подписанным пропуском** (Ed25519) на 7 дней; Kordon обновляет его каждые 6 часов и проверяет подпись открытым ключом, зашитым в программу. Закрытый ключ есть только на сервере. Поэтому вход нельзя обойти правкой файлов, а без интернета Kordon работает дальше до конца срока пропуска. Убрали компьютер из пульта - он выходит за секунды.

## Обновления

Каждый релиз собирается на GitHub Actions, а не на чьём-то компьютере. Файл с контрольными суммами `SHA256SUMS.txt` **подписан ключом Ed25519**, закрытая часть которого есть только у владельца. Kordon не установит обновление без верной подписи - даже если кто-то получит доступ к аккаунту GitHub и подменит файл вместе с его суммой.

Проверить подпись самостоятельно (OpenSSL 3):

```bash
printf -- '-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEAV0AkZc32DAnaNF2S9eJL+jsWdLjlSnLwAdxmysIs3MQ=\n-----END PUBLIC KEY-----\n' > kordon-update.pem
base64 -d < SHA256SUMS.txt.sig > SHA256SUMS.sig.bin
openssl pkeyutl -verify -pubin -inkey kordon-update.pem -rawin -in SHA256SUMS.txt -sigfile SHA256SUMS.sig.bin
shasum -a 256 -c SHA256SUMS.txt --ignore-missing
```

Сборка для macOS подписана сертификатом Developer ID; проверку Apple (нотаризацию) она пройдёт со следующей версии. В описании каждого релиза - результаты проверки файлов антивирусами (VirusTotal).

## Как сообщить об уязвимости

Нашли уязвимость - напишите в бота [@kordon_security_bot](https://t.me/kordon_security_bot): «Поддержка» → «Написать». Пожалуйста, не публикуйте подробности, пока мы не выпустили исправление. Мы ответим в течение 72 часов, а исправление выйдет обновлением со ссылкой на вас, если хотите.

---

# Kordon security (English)

- **On the computer:** no admin rights; the panel talks to Kordon on `127.0.0.1` with a random key in a user-only file, and checks the host, the key and the origin (DNS rebinding and CSRF); the browser extension answers only to extensions; secrets on disk are `0600`.
- **Beyond a plain kill switch:** apps are paused right before the computer sleeps and let go only after a fresh IP check on waking; if Kordon crashes or is killed, a watchdog pauses the protected apps until it's back; IPv6, DNS, WebRTC, proxy-bypass and per-service route checks; `kordon run` for a single command on a server or in CI.
- **Our server** knows the Telegram chat id, a SHA-256 hash of each computer's secret, the computer's name, and - for the remote, while signed in - status, country, protected app names and weekly numbers, in memory, **never IP addresses**. No access log; rate limiting lives in nginx memory only.
- **Sign in:** an Ed25519-signed ticket from the server, valid 7 days, refreshed every 6 hours, checked against a key built into the app.
- **Updates:** `SHA256SUMS.txt` is signed with an Ed25519 key only the owner holds; Kordon installs nothing without a valid signature, even if the GitHub account were taken over. Every release is built on GitHub Actions, not on someone's computer. macOS builds are Developer ID signed; Apple's notarization comes with the next version. Verify a release yourself (OpenSSL 3):

```bash
printf -- '-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEAV0AkZc32DAnaNF2S9eJL+jsWdLjlSnLwAdxmysIs3MQ=\n-----END PUBLIC KEY-----\n' > kordon-update.pem
base64 -d < SHA256SUMS.txt.sig > SHA256SUMS.sig.bin
openssl pkeyutl -verify -pubin -inkey kordon-update.pem -rawin -in SHA256SUMS.txt -sigfile SHA256SUMS.sig.bin
shasum -a 256 -c SHA256SUMS.txt --ignore-missing
```
- **Report a vulnerability** in the bot [@kordon_security_bot](https://t.me/kordon_security_bot) (Support → Write). Please don't publish details before a fix is out; we answer within 72 hours.
