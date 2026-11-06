# Безопасность Kordon

Kordon - kill switch для программ: он стоит между вашими программами и сетью, поэтому сам должен быть надёжнее всего остального. Здесь коротко и проверяемо: что Kordon делает на компьютере, что знает наш сервер, как подписаны вход и обновления и куда сообщить об уязвимости.

English below.

## На компьютере

- **Без прав администратора.** Kordon работает от вашего пользователя и управляет только вашими программами: ставит их на паузу (SIGSTOP на macOS и Linux, приостановка процесса на Windows), продолжает и закрывает.
- **Панель - только для вас.** Окно и панель говорят с Kordon по `127.0.0.1` со случайным ключом, который лежит в файле, доступном только вашей учётной записи. Чужой сайт в браузере не может ни прочитать, ни изменить настройки: проверяются адрес, ключ и источник запроса (защита от DNS rebinding и CSRF).
- **Расширение для браузера** спрашивает только сам Kordon на `127.0.0.1:47833` (или на запасных `41833`, `35833`, `29833`, если этот порт занят) и принимает только ответ Kordon; ответ получают только расширения, не сайты.
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
- последний профиль настроек для переноса на новый компьютер - без адресов и сетей;
- какие уведомления вы выключили в боте;
- статистику для владельца Kordon, тоже без IP-адресов: какие компьютеры (по хешу секрета) были на связи в какой день и час, с версией Kordon и системой; сколько компьютеров на связи поминутно; счётчики событий по видам - входы, уведомления о VPN и утечках по видам, нажатия «Скачать» на сайте - без привязки к людям. Записи о компьютерах и почасовые и поминутные цифры удаляются через 60 дней, остаются только дневные суммы по видам событий;
- обращения в поддержку: ваш @username в Telegram, имена компьютеров, переписку и присланные файлы. Закрытые обращения удаляются через 90 дней;
- ссылку входа, пока она действует (15 минут): хеш кода, хеш секрета и имя компьютера.

Сервер Kordon стоит отдельно (Амстердам). Вход, пульт и уведомления вашего IP не получают вовсе: запросы к ним проходят через сайт efimovdev.ru, у которого журнал доступа для Kordon выключен. IP видят только наши проверки `ip.kordon.tech` и `stun.kordon.tech` - ровно затем, чтобы назвать его вам в ответ; журнала у них нет, адрес нигде не сохраняется. Проверка DNS `dns.kordon.tech` вашего IP не видит вовсе: к ней приходит ваш DNS-сервер (провайдера, VPN или публичный), и его адрес она так же только называет в ответ. Ограничение частоты запросов держится только в памяти nginx и ничего не пишет. Ежедневный бэкап базы уходит владельцу Kordon.

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
- **Our server** knows the Telegram chat id, a SHA-256 hash of each computer's secret, the computer's name, and - for the remote, while signed in - status, country, protected app names and weekly numbers, in memory, **never IP addresses**. It also keeps the last settings profile (no addresses), which alerts you turned off, statistics for Kordon's owner without IP addresses (which computers, by secret hash, checked in on which day and hour with the Kordon version and OS; how many are online each minute; counts of events by kind - sign ins, VPN and leak alerts by kind, Download clicks - not tied to people; records about computers and the hourly and per-minute numbers are deleted after 60 days, only daily totals by kind of event stay), support conversations (your Telegram @username, computer names, messages and files; closed ones are deleted after 90 days) and a sign in link while it's valid (15 minutes). Kordon's server runs on its own (Amsterdam). Sign in, the remote and alerts never get your IP: requests reach them through efimovdev.ru, which keeps no access log for Kordon; rate limiting lives in nginx memory only. Only our checks `ip.kordon.tech` and `stun.kordon.tech` see the address - to say it back to you; they keep no log and store it nowhere. The DNS check `dns.kordon.tech` never sees your IP at all: your DNS server (the provider's, the VPN's or a public one) is what asks it, and it only says that server's address back.
- **Sign in:** an Ed25519-signed ticket from the server, valid 7 days, refreshed every 6 hours, checked against a key built into the app.
- **Updates:** `SHA256SUMS.txt` is signed with an Ed25519 key only the owner holds; Kordon installs nothing without a valid signature, even if the GitHub account were taken over. Every release is built on GitHub Actions, not on someone's computer. macOS builds are Developer ID signed; Apple's notarization comes with the next version. Verify a release yourself (OpenSSL 3):

```bash
printf -- '-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEAV0AkZc32DAnaNF2S9eJL+jsWdLjlSnLwAdxmysIs3MQ=\n-----END PUBLIC KEY-----\n' > kordon-update.pem
base64 -d < SHA256SUMS.txt.sig > SHA256SUMS.sig.bin
openssl pkeyutl -verify -pubin -inkey kordon-update.pem -rawin -in SHA256SUMS.txt -sigfile SHA256SUMS.sig.bin
shasum -a 256 -c SHA256SUMS.txt --ignore-missing
```
- **Report a vulnerability** in the bot [@kordon_security_bot](https://t.me/kordon_security_bot) (Support → Write). Please don't publish details before a fix is out; we answer within 72 hours.

## Добровольные проверка и диагностика (готовится)

Проверка запускает одноразовый процесс. Изолированный Guard может приостановить только его; список рабочих процессов пользователя в тест не передаётся. Секрет входа не попадает в дочерний процесс: через stdin он получает отдельный токен на 3 минуты. Наблюдатель хранит только временные счётчики без IP. Результат подтверждает измеренную паузу и возобновление, а не отсутствие всех сетевых утечек и не защиту от блокировки аккаунта.

Диагностика отправляется только после просмотра и подтверждения точного JSON. Сервер отклоняет неизвестные поля, связывает отчёт с вошедшей установкой, ограничивает частоту, удаляет отчёты после 14 дней и позволяет владельцу удалить их раньше. Идентификатор отчёта сам по себе не даёт права чтения: поддержке нужна проверка владельца Telegram, установке - собственный секрет. Повтор той же отправки не создаёт дубликат. Локальный журнал и переписка в облако не загружаются.
