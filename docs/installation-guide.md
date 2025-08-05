# Руководство по установке Telegram-бота на n8n

## Оглавление
1. [Требования](#требования)
2. [Подготовка](#подготовка)
3. [Создание Telegram-бота](#создание-telegram-бота)
4. [Настройка Google Sheets](#настройка-google-sheets)
5. [Получение API ключа DeepSeek](#получение-api-ключа-deepseek)
6. [Импорт workflow в n8n](#импорт-workflow-в-n8n)
7. [Настройка credentials](#настройка-credentials)
8. [Тестирование](#тестирование)
9. [Решение проблем](#решение-проблем)

## Требования

- Аккаунт n8n (self-hosted или cloud)
- Telegram аккаунт
- Google аккаунт
- Аккаунт DeepSeek с API доступом
- Базовые знания n8n

## Подготовка

### 1. Установка n8n (если еще не установлен)

**Вариант 1: Docker**
```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

**Вариант 2: npm**
```bash
npm install n8n -g
n8n start
```

### 2. Доступ к n8n
Откройте браузер и перейдите на `http://localhost:5678`

## Создание Telegram-бота

### 1. Создание бота через BotFather

1. Откройте Telegram и найдите `@BotFather`
2. Отправьте команду `/newbot`
3. Введите имя бота (например: "Объяснительные Бот")
4. Введите username бота (должен заканчиваться на `bot`, например: `explanatory_notes_bot`)
5. Сохраните полученный токен:
   ```
   5923674521:AAHxN9IiF6pN9fo5YG7X7_xYf_DFgf7n0dI
   ```

### 2. Настройка команд бота

Отправьте BotFather:
```
/setcommands
@your_bot_username
start - Начать работу с ботом
```

## Настройка Google Sheets

### 1. Создание таблицы

1. Перейдите на [Google Sheets](https://sheets.google.com)
2. Создайте новую таблицу с названием "Bot"
3. Переименуйте первый лист в "Users"
4. Добавьте заголовки в первую строку:
   - A1: `userId`
   - B1: `chatId`
   - C1: `role`
   - D1: `quota`
   - E1: `sub`

### 2. Получение ID таблицы

ID находится в URL таблицы:
```
https://docs.google.com/spreadsheets/d/[ВАШ_ID_ТАБЛИЦЫ]/edit
```
Сохраните этот ID.

### 3. Настройка доступа API

1. Перейдите в [Google Cloud Console](https://console.cloud.google.com)
2. Создайте новый проект или выберите существующий
3. Включите Google Sheets API:
   - Перейдите в "APIs & Services" > "Library"
   - Найдите "Google Sheets API"
   - Нажмите "Enable"

### 4. Создание OAuth2 credentials

1. Перейдите в "APIs & Services" > "Credentials"
2. Нажмите "Create Credentials" > "OAuth client ID"
3. Выберите "Web application"
4. Добавьте в Authorized redirect URIs:
   ```
   http://localhost:5678/rest/oauth2-credential/callback
   ```
   Для n8n cloud используйте:
   ```
   https://[ваш-домен].n8n.cloud/rest/oauth2-credential/callback
   ```
5. Сохраните Client ID и Client Secret

## Получение API ключа DeepSeek

1. Зарегистрируйтесь на [DeepSeek Platform](https://platform.deepseek.com)
2. Перейдите в раздел API Keys
3. Создайте новый API ключ
4. Сохраните ключ (показывается только один раз)

## Импорт workflow в n8n

### 1. Импорт JSON файла

1. В n8n нажмите на меню (три точки) в правом верхнем углу
2. Выберите "Import from File"
3. Выберите файл `workflows/telegram-bot-deepseek.json`
4. Нажмите "Import"

### 2. Обзор workflow

После импорта вы увидите полный workflow с нодами:
- **Telegram Trigger** - получение сообщений
- **Router** - маршрутизация команд
- **Google Sheets** - работа с данными пользователей
- **DeepSeek API** - генерация текста
- **Code nodes** - логика обработки

## Настройка credentials

### 1. Telegram Bot API

1. Дважды кликните на любую Telegram ноду
2. В поле "Credential for Telegram API" нажмите "Create New"
3. Введите:
   - **Credential Name**: Telegram Bot API
   - **Access Token**: Ваш токен от BotFather
4. Нажмите "Create"

### 2. Google Sheets OAuth2

1. Дважды кликните на любую Google Sheets ноду
2. В поле "Credential" нажмите "Create New"
3. Выберите "Google Sheets OAuth2 API"
4. Введите:
   - **Client ID**: Ваш Client ID
   - **Client Secret**: Ваш Client Secret
5. Нажмите "Connect my account"
6. Авторизуйтесь в Google
7. Разрешите доступ

### 3. Настройка параметров в workflow

#### В нодах Google Sheets:
- Замените `YOUR_GOOGLE_SHEET_ID` на ID вашей таблицы

#### В ноде DeepSeek API:
- В Headers замените `YOUR_DEEPSEEK_API_KEY` на ваш API ключ

## Тестирование

### 1. Активация workflow

1. Нажмите на переключатель "Active" в правом верхнем углу
2. Workflow должен стать активным (зеленый индикатор)

### 2. Настройка webhook

1. Кликните на ноду "Telegram Trigger"
2. Скопируйте Production URL
3. Установите webhook через браузер:
   ```
   https://api.telegram.org/bot[ВАШ_ТОКЕН]/setWebhook?url=[PRODUCTION_URL]
   ```

### 3. Тестирование бота

1. Найдите вашего бота в Telegram
2. Отправьте `/start`
3. Должно появиться меню с кнопками
4. Нажмите любую кнопку
5. Проверьте Google Sheets - должна появиться запись

## Решение проблем

### Бот не отвечает

1. Проверьте, активен ли workflow
2. Проверьте webhook:
   ```
   https://api.telegram.org/bot[ВАШ_ТОКЕН]/getWebhookInfo
   ```
3. Проверьте логи в n8n

### Ошибка Google Sheets

1. Проверьте права доступа к таблице
2. Убедитесь, что API включен
3. Переподключите OAuth2

### Ошибка DeepSeek API

1. Проверьте баланс аккаунта
2. Проверьте правильность API ключа
3. Проверьте лимиты API

### Неправильный подсчет квоты

1. Проверьте формат данных в Google Sheets
2. Убедитесь, что в колонке quota числа, а не текст
3. Проверьте логику в Code нодах

## Дополнительные настройки

### Изменение промптов

1. Откройте ноду "Prepare Prompt"
2. Измените тексты в объекте `prompts`
3. Сохраните изменения

### Добавление новых ролей

1. В ноде "Send Menu" добавьте новую кнопку
2. В "Prepare Prompt" добавьте новый промпт
3. Обновите логику обработки

### Изменение лимитов

В ноде "Check Limits" измените условие:
```javascript
if (quota < 6) { // Измените 6 на нужное число
```

## Поддержка

При возникновении проблем:
1. Проверьте логи выполнения в n8n
2. Обратитесь к документации n8n
3. Проверьте статус API сервисов
