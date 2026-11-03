# Kordon - политика конфиденциальности

Обновлено: 3 ноября 2026. English below.

Kordon делает Efimov Dev (https://efimovdev.ru). Здесь описано, какие данные обрабатывают приложение Kordon и расширение Kordon для браузера.

## Расширение Kordon для браузера

Расширение **не собирает, не хранит и никуда не отправляет ваши данные**. Оно не видит, что вы пишете на сайтах, не читает переписку с ИИ, не ведёт историю и не подключает аналитику.

Что оно делает и зачем:

- **Спрашивает приложение Kordon на вашем компьютере** (`http://127.0.0.1:47833`), разрешён ли сейчас ваш внешний IP. Это запрос внутри компьютера, в интернет он не уходит. В ответе - состояние защиты, текущий IP и страна, их расширение показывает в своём окне.
- **Ставит на паузу вкладки ИИ-сайтов** (claude.ai, chatgpt.com, gemini.google.com и другие из списка), когда приложение Kordon говорит, что IP не тот: блокирует их сетевые запросы правилами браузера (declarativeNetRequest) и показывает поверх страницы заглушку. Содержимое страниц расширение не читает и не меняет.
- **Хранит в браузере только ваш список сайтов** (какие выключены и какие вы добавили) - в `chrome.storage.local`, на вашем компьютере.
- **Проверка WebRTC** по вашей кнопке узнаёт у публичного STUN-сервера Google (`stun.l.google.com`), какой адрес браузер выдаёт сайтам, и сравнивает его с IP. Результат показывается только вам.
- **«Закрыть утечку»** по вашей кнопке меняет настройку браузера WebRTC (`webRTCIPHandlingPolicy`), чтобы браузер не выдавал адрес в обход прокси и VPN. «Вернуть как было» отменяет это.

Разрешения: `storage` - список сайтов; `declarativeNetRequest` - пауза запросов ИИ-сайтов; `alarms` - раз в 30 секунд сверять состояние; `privacy` - настройка WebRTC по вашей кнопке; доступ к `127.0.0.1:47833` - связь с приложением Kordon; доступ к ИИ-сайтам из списка - пауза их вкладок.

## Приложение Kordon

Приложение работает у вас на компьютере. Чтобы знать ваш внешний IP, оно обращается к публичным сервисам (ipify, icanhazip, ident.me, checkip.amazonaws.com, ipinfo.io), узнаёт страну адреса (ipinfo.io и запасные) и через какой DNS вы ходите. Каждые 15 минут проверяет, вышла ли новая версия (`efimovdev.ru/kordon/api/latest`, без каких-либо данных; если не ответил - GitHub).

Только если вы сами включили:

- **Счётчик пользователей:** раз в день номер версии и система (например, `1.3.1, darwin`). Без IP, без номера установки, без имени компьютера. Журнал адресов на нашем сервере для этого выключен.
- **Уведомления в Telegram:** текст уведомления без адресов, только со страной, уходит через наш сервер боту @kordon_security_bot. Сервер хранит номер чата и хеш секрета вашего Kordon; сами сообщения не хранятся. Отключить - `/stop` в боте или в панели Kordon.

Настройки, журнал и статистика лежат только у вас на компьютере. Данные не продаются и не передаются третьим лицам.

Вопросы: Telegram [@efimov_dev](https://t.me/efimov_dev), https://efimovdev.ru

---

# Kordon privacy policy (English)

Updated 3 November 2026. Kordon is made by Efimov Dev (https://efimovdev.ru).

## The Kordon browser extension

The extension **does not collect, store or send your data anywhere**. It doesn't see what you type on websites, doesn't read your AI chats, keeps no history and has no analytics.

- It asks the Kordon app on your computer (`http://127.0.0.1:47833`) whether your public IP is allowed right now. This request stays on your computer. The answer (protection state, current IP and country) is shown in the extension's popup.
- When the app says the IP is wrong, it pauses tabs of the listed AI sites: blocks their requests with the browser's declarativeNetRequest rules and covers the page. It doesn't read or change page content.
- It stores only your site list (which are off, which you added) in `chrome.storage.local` on your computer.
- The WebRTC check, on your click, asks Google's public STUN server (`stun.l.google.com`) which address the browser exposes, and compares it with your IP. The result is shown only to you.
- "Close the leak", on your click, changes the browser's WebRTC setting (`webRTCIPHandlingPolicy`); "Undo" restores it.

Permissions: `storage` (site list), `declarativeNetRequest` (pausing AI sites' requests), `alarms` (checking the state every 30 seconds), `privacy` (the WebRTC setting on your click), access to `127.0.0.1:47833` (the Kordon app) and to the listed AI sites (pausing their tabs).

## The Kordon app

The app runs on your computer. To know your public IP it asks public services (ipify, icanhazip, ident.me, checkip.amazonaws.com, ipinfo.io), looks up the IP's country and which DNS you use, and every 15 minutes checks for a new version (`efimovdev.ru/kordon/api/latest`, no data sent; GitHub as a fallback).

Only if you turn them on: the **user count** (once a day the version and OS, no IP, no install id; the server keeps no address log for it) and **Telegram alerts** (alert text without addresses, only the country, passed through our server to @kordon_security_bot; the server keeps the chat id and a hash of your Kordon's secret, not the messages).

Settings, logs and statistics stay on your computer. Data is not sold or shared with third parties.

Contact: Telegram [@efimov_dev](https://t.me/efimov_dev), https://efimovdev.ru
