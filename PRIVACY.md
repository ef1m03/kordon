# Kordon - политика конфиденциальности

Обновлено: 3 ноября 2026. English below.

Kordon делает Efimov Dev (https://efimovdev.ru). Здесь описано, какие данные обрабатывают приложение Kordon и расширение Kordon для браузера.

## Расширение Kordon для браузера

Расширение **не собирает, не хранит и никуда не отправляет ваши данные**. Оно не видит, что вы пишете на сайтах, не читает переписку с ИИ, не ведёт историю и не подключает аналитику.

Что оно делает и зачем:

- **Спрашивает приложение Kordon на вашем компьютере** (`http://127.0.0.1:47833`, а если этот порт занят - запасные `41833`, `35833` и `29833`), разрешён ли сейчас ваш внешний IP. Это запрос внутри компьютера, в интернет он не уходит. В ответе - состояние защиты, текущий IP и страна, их расширение показывает в своём окне.
- **Ставит на паузу вкладки ИИ-сайтов** (claude.ai, chatgpt.com, gemini.google.com и другие из списка), когда приложение Kordon говорит, что IP не тот: блокирует их сетевые запросы правилами браузера (declarativeNetRequest) и показывает поверх страницы заглушку. Содержимое страниц расширение не читает и не меняет.
- **Хранит в браузере только ваш список сайтов** (какие выключены и какие вы добавили) - в `chrome.storage.local`, на вашем компьютере.
- **Проверка WebRTC** по вашей кнопке узнаёт у STUN-сервера Kordon (`stun.kordon.tech`, ничего не записывает), а если он не ответил - у публичного STUN-сервера Google (`stun.l.google.com`), какой адрес браузер выдаёт сайтам, и сравнивает его с IP. Результат показывается только вам.
- **«Закрыть утечку»** по вашей кнопке меняет настройку браузера WebRTC (`webRTCIPHandlingPolicy`), чтобы браузер не выдавал адрес в обход прокси и VPN. «Вернуть как было» отменяет это.

Разрешения: `storage` - список сайтов; `declarativeNetRequest` - пауза запросов ИИ-сайтов; `alarms` - раз в 30 секунд сверять состояние; `privacy` - настройка WebRTC по вашей кнопке; доступ к `127.0.0.1` на портах `47833`, `41833`, `35833`, `29833` - связь с приложением Kordon; доступ к ИИ-сайтам из списка - пауза их вкладок.

## Приложение Kordon

Приложение работает у вас на компьютере. Чтобы знать ваш внешний IP, оно обращается к публичным сервисам (ipify, icanhazip, ident.me, checkip.amazonaws.com, ipinfo.io), узнаёт страну адреса (ipinfo.io и запасные) и через какой DNS вы ходите. Каждые 15 минут проверяет, вышла ли новая версия (`efimovdev.ru/kordon/api/latest`, без каких-либо данных; если не ответил - GitHub).

- **Вход через Telegram (обязателен):** чтобы пользоваться Kordon, нужно один раз войти через бота @kordon_security_bot. Наш сервер хранит номер чата, хеш секрета вашего Kordon и имя компьютера (чтобы в одном чате различать компьютеры). В этот чат приходят новости о новых версиях. Пока вы вошли, Kordon раз в 15 секунд сообщает серверу для пульта в Telegram: статус защиты, страну, названия программ под защитой, что делают агенты в терминале и итоги недели (сколько раз подводил VPN). IP-адресов там нет; сервер держит это только в памяти и забывает при перезапуске. Оттуда же Kordon забирает нажатые на пульте кнопки. Чтобы настройки переезжали на новый компьютер, сервер хранит для вашего чата последний профиль настроек: какие программы под защитой, разрешённые страны и переключатели. IP-адресов и домашних сетей в нём нет - Kordon их не отправляет, а сервер такой профиль не примет. Имени, телефона и адресов Kordon не передаёт. Выйти - `/stop` в боте, после этого Kordon попросит войти снова; защита при этом не выключается.
- **Поддержка в боте:** если вы пишете в поддержку через бота, переписка (текст, а у фото и файлов - их номер в Telegram) хранится на нашем сервере как обращение, чтобы ни одно не потерялось. Видит её только разработчик Kordon. Закрытые обращения удаляются через 90 дней.

Только если вы сами включили:

- **Счётчика пользователей больше нет:** с входом через Telegram отдельный ежедневный пинг не нужен, новые версии его не отправляют.
- **Уведомления о VPN в Telegram** (включены после входа, выключаются в панели): текст уведомления без адресов, только со страной, уходит через наш сервер боту @kordon_security_bot. Сервер хранит номер чата, хеш секрета вашего Kordon и имя компьютера (чтобы в одном чате различать уведомления с разных компьютеров); сами сообщения не хранятся. Кнопки под уведомлением («Пауза на час», «Разрешить этот IP») работают так: нажатие ждёт на сервере, пока ваш Kordon его заберёт, и сразу удаляется; после уведомления с кнопками Kordon полчаса спрашивает сервер, не нажата ли кнопка. Сами сообщения не хранятся.

Настройки, журнал и статистика лежат только у вас на компьютере. Данные не продаются и не передаются третьим лицам.

Вопросы: Telegram [@efimov_dev](https://t.me/efimov_dev), https://efimovdev.ru

---

# Kordon privacy policy (English)

Updated 3 November 2026. Kordon is made by Efimov Dev (https://efimovdev.ru).

## The Kordon browser extension

The extension **does not collect, store or send your data anywhere**. It doesn't see what you type on websites, doesn't read your AI chats, keeps no history and has no analytics.

- It asks the Kordon app on your computer (`http://127.0.0.1:47833`, or the spare `41833`, `35833` and `29833` if that port is taken) whether your public IP is allowed right now. This request stays on your computer. The answer (protection state, current IP and country) is shown in the extension's popup.
- When the app says the IP is wrong, it pauses tabs of the listed AI sites: blocks their requests with the browser's declarativeNetRequest rules and covers the page. It doesn't read or change page content.
- It stores only your site list (which are off, which you added) in `chrome.storage.local` on your computer.
- The WebRTC check, on your click, asks Kordon's STUN server (`stun.kordon.tech`, logs nothing), or Google's public one (`stun.l.google.com`) if it doesn't answer, which address the browser exposes, and compares it with your IP. The result is shown only to you.
- "Close the leak", on your click, changes the browser's WebRTC setting (`webRTCIPHandlingPolicy`); "Undo" restores it.

Permissions: `storage` (site list), `declarativeNetRequest` (pausing AI sites' requests), `alarms` (checking the state every 30 seconds), `privacy` (the WebRTC setting on your click), access to `127.0.0.1` on ports `47833`, `41833`, `35833`, `29833` (the Kordon app) and to the listed AI sites (pausing their tabs).

## The Kordon app

The app runs on your computer. To know your public IP it asks public services (ipify, icanhazip, ident.me, checkip.amazonaws.com, ipinfo.io), looks up the IP's country and which DNS you use, and every 15 minutes checks for a new version (`efimovdev.ru/kordon/api/latest`, no data sent; GitHub as a fallback).

**Sign in with Telegram (required):** to use Kordon you sign in once with @kordon_security_bot. Our server keeps the chat id, a hash of your Kordon's secret and the computer's name; news about new versions comes to that chat. While signed in, Kordon tells the server every 15 seconds, for the remote panel in Telegram: the protection status, the country, the names of protected apps, what terminal agents are doing and the week's numbers. No IP addresses; the server keeps this in memory only. That's also how Kordon picks up buttons pressed in the panel. So settings can follow you to a new computer, the server keeps your chat's last settings profile: the protected apps, allowed countries and switches. No IP addresses or home networks: Kordon doesn't send them and the server won't accept a profile with an address. Kordon sends no name, phone or addresses. To sign out: `/stop` in the bot, then Kordon asks to sign in again; protection stays on.

**Support in the bot:** when you write to support through the bot, the conversation (the text, and for photos and files their Telegram id) is kept on our server as a ticket, so none gets lost. Only Kordon's developer sees it. Closed tickets are deleted after 90 days.

Only if you turn them on: the **user count** (once a day the version and OS, no IP, no install id; the server keeps no address log for it) and **VPN alerts in Telegram** (on after signing in, can be turned off; alert text without addresses, only the country, passed through our server to @kordon_security_bot; the server keeps the chat id, a hash of your Kordon's secret and the computer's name, not the messages; a pressed button under an alert waits on the server until your Kordon picks it up, and Kordon asks for it for half an hour after such an alert).

Settings, logs and statistics stay on your computer. Data is not sold or shared with third parties.

Contact: Telegram [@efimov_dev](https://t.me/efimov_dev), https://efimovdev.ru
