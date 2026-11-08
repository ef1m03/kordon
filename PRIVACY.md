# Kordon - политика конфиденциальности

Обновлено: 3 ноября 2026. English below.

Kordon делает Efimov Dev (https://efimovdev.ru). Здесь описано, какие данные обрабатывают приложение Kordon и расширение Kordon для браузера.

## Расширение Kordon для браузера

Расширение не извлекает переписку с ИИ или текст страниц, не ведёт отдельный журнал посещений и не содержит аналитики или рекламных SDK. Для работы оно обрабатывает сетевое состояние, адреса выбранных сайтов и локальные настройки.

- **Связь с приложением:** расширение запрашивает состояние защиты, IP и страну у Kordon на этом же компьютере через `127.0.0.1`, порты `47833`, `41833`, `35833`, `29833`. Эти запросы не уходят на внешний сервер.
- **Пауза сайтов:** правила браузера блокируют запросы выбранных сайтов. На поддерживаемых страницах расширение добавляет заглушку и изменяет поведение сетевых API для приостановки соединений. Адрес заблокированной страницы передаётся во фрагменте адреса локальной страницы расширения, чтобы вернуться к нему после паузы.
- **Локальное хранение:** `chrome.storage.local` содержит выключенные и добавленные домены, флаг несовпадения IP при проверке WebRTC и служебную метку перезагрузки. Браузер также хранит правила блокировки.
- **Ручная проверка WebRTC:** по вашей кнопке браузер собирает ICE-кандидаты с настроенными STUN-серверами `stun.kordon.tech:3478` и `stun.l.google.com:19302`. Браузер может обратиться к обоим серверам; Google не является исключительно последовательным резервом. Серверам виден сетевой IP запроса. Найденные адреса сравниваются с IP приложения локально и показываются в расширении. Код расширения не управляет журналами стороннего сервера Google.
- **Настройка WebRTC:** по вашей кнопке расширение устанавливает общую политику браузера `disable_non_proxied_udp`. Это может повлиять на WebRTC-звонки. Отмена снимает настройку расширения; итоговое значение определяется браузером и другими действующими политиками.
- **Ссылка разработчика:** открытие сайта выполняет обычные интернет-запросы с метками источника `utm_source=kordon&utm_medium=extension`. Обработка данных сайтом и настольным приложением описана отдельно ниже.

Разрешения: `storage` - локальные настройки и служебные флаги; `declarativeNetRequest` - правила блокировки запросов; `alarms` - периодическая проверка состояния; `privacy` - настройка WebRTC по кнопке; доступ к адресам loopback - связь с приложением; доступ к сайтам из списка - пауза их запросов и отображение заглушки.

## Приложение Kordon

Приложение работает у вас на компьютере. Чтобы знать ваш внешний IP, оно обращается к публичным сервисам (ipify, icanhazip, ident.me, checkip.amazonaws.com, ipinfo.io), узнаёт страну адреса (ipinfo.io, ipapi.co, api.country.is в выбранном порядке; ручная диагностика может сравнить все выбранные базы) и через какой DNS вы ходите. Каждые 15 минут проверяет, вышла ли новая версия (`efimovdev.ru/kordon/api/latest`, без каких-либо данных; если не ответил - GitHub).

- **Вход через Telegram (обязателен):** чтобы пользоваться Kordon, нужно один раз войти через бота @kordon_security_bot. Наш сервер хранит номер чата, хеш секрета вашего Kordon и имя компьютера (чтобы в одном чате различать компьютеры). В этот чат приходят новости о новых версиях. Пока вы вошли, Kordon раз в 15 секунд сообщает серверу для пульта в Telegram: статус защиты, страну, названия программ под защитой, что делают агенты в терминале и итоги недели (сколько раз подводил VPN). IP-адресов там нет; сервер держит это только в памяти и забывает при перезапуске. Оттуда же Kordon забирает нажатые на пульте кнопки. Чтобы настройки переезжали на новый компьютер, сервер хранит для вашего чата последний профиль настроек: какие программы под защитой, разрешённые страны и переключатели. IP-адресов и домашних сетей в нём нет - Kordon их не отправляет, а сервер такой профиль не примет. Имени, телефона и адресов Kordon не передаёт. Выйти - `/stop` в боте, после этого Kordon попросит войти снова; защита при этом не выключается.
- **Поддержка в боте:** если вы пишете в поддержку через бота, переписка (текст, а у фото и файлов - их номер в Telegram) хранится на нашем сервере как обращение, чтобы ни одно не потерялось. Видит её только разработчик Kordon. Закрытые обращения удаляются через 90 дней.

Только если вы сами включили:

- **Напоминания об обновлениях:** облако сохраняет последнюю версию приложения, ОС и время связи устройства, привязанные к уже существующему хешу секрета. Записи старше 72 часов удаляются при следующих синхронизациях. Чтобы не повторять сообщения, сохраняются номер чата, версия релиза, время и результат попытки отправки; эти записи остаются между перезапусками. IP, переписка и содержимое программ для этого не передаются. Напоминания отправляются не чаще раза в три дня, максимум дважды на релиз, с 12:00 до 18:00 МСК.

- **Счётчика пользователей больше нет:** с входом через Telegram отдельный ежедневный пинг не нужен, новые версии его не отправляют.
- **Уведомления о VPN в Telegram** (включены после входа, выключаются в панели): текст уведомления без адресов, только со страной, уходит через наш сервер боту @kordon_security_bot. Сервер хранит номер чата, хеш секрета вашего Kordon и имя компьютера (чтобы в одном чате различать уведомления с разных компьютеров); сами сообщения не хранятся. Кнопки под уведомлением («Пауза на час», «Разрешить этот IP») работают так: нажатие ждёт на сервере, пока ваш Kordon его заберёт, и сразу удаляется; после уведомления с кнопками Kordon полчаса спрашивает сервер, не нажата ли кнопка. Сами сообщения не хранятся.

Полный журнал и подробная локальная статистика остаются на компьютере. Данные для пульта, переноса профиля и добровольной диагностики описаны отдельно. Данные не продаются и не передаются третьим лицам.

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

Full logs and detailed local statistics stay on your computer. Data used by the remote, profile transfer and voluntary diagnostics is described separately. Data is not sold or shared with third parties.

Contact: Telegram [@efimov_dev](https://t.me/efimov_dev), https://efimovdev.ru

## Проверка защиты и диагностика (готовится)

Эти действия запускаете только вы. Проверка использует отдельный тестовый процесс и временный облачный счётчик: сессия действует 3 минуты, IP-адреса в ней не записываются. Рабочие приложения и настройки VPN не меняются.

Перед отправкой диагностики Kordon показывает точный состав отчёта и просит подтвердить отправку. В отчёте только версия, система, коды состояния, счётчики и переключатели. Нет IP, имени компьютера, путей, названий программ, журнала, секретов и переписки. Отчёт связан с вашим входом через Telegram, доступен поддержке до 14 дней и может быть удалён вами раньше. Без подтверждения отчёт не отправляется.

## Voluntary self-test and diagnostics (upcoming)

Only your explicit action starts these features. A separate probe sends requests to a temporary cloud counter; its session expires after 3 minutes and request IP addresses are not stored. Your working apps and VPN configuration are unchanged.

Before a diagnostic report is sent, Kordon displays its exact contents and asks for consent. Only version, system, state codes, counters and switches are included. No IP addresses, computer names, paths, app names, logs, secrets or conversations. Reports are associated with your Telegram sign-in, are available to support for up to 14 days, and can be deleted earlier by you. No report is sent without confirmation.
