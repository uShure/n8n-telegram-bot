# 🚀 Быстрый старт - n8n Telegram Bot

## Установка за 10 минут

### 1️⃣ Подключитесь к серверу
```bash
ssh root@ВАШ_IP_АДРЕС
```

### 2️⃣ Скачайте и распакуйте проект
```bash
# Создайте директорию
mkdir -p /opt/n8n-telegram-bot
cd /opt/n8n-telegram-bot

# Распакуйте архив проекта (загрузите через SFTP или wget)
# Или склонируйте из репозитория
```

### 3️⃣ Запустите установку
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

### 4️⃣ Настройте переменные окружения
```bash
# Скопируйте шаблон
cp deployment/.env.production deployment/.env

# Откройте для редактирования
nano deployment/.env
```

**Обязательно заполните:**
```env
# Пароли (придумайте сложные!)
POSTGRES_PASSWORD=ваш_сложный_пароль_для_БД
REDIS_PASSWORD=ваш_сложный_пароль_для_redis
N8N_BASIC_AUTH_PASSWORD=ваш_пароль_для_входа_в_n8n

# Ваш домен
N8N_HOST=n8n.вашдомен.ru
N8N_WEBHOOK_URL=https://n8n.вашдомен.ru/
N8N_EDITOR_BASE_URL=https://n8n.вашдомен.ru/

# Telegram
TELEGRAM_BOT_TOKEN=токен_от_BotFather

# Google Sheets
GOOGLE_SHEET_ID=id_вашей_таблицы
GOOGLE_CLIENT_ID=ваш_client_id
GOOGLE_CLIENT_SECRET=ваш_client_secret

# DeepSeek
DEEPSEEK_API_KEY=ваш_api_ключ

# Email для SSL
CERTBOT_EMAIL=ваш@email.ru
```

### 5️⃣ Добавьте ключ шифрования
```bash
# Возьмите ключ из файла .env.generated
cat .env.generated
# Скопируйте строку N8N_ENCRYPTION_KEY=... в ваш .env файл
```

### 6️⃣ Запустите систему
```bash
cd /opt/n8n-telegram-bot
docker-compose -f deployment/docker-compose.yml up -d
```

### 7️⃣ Настройте SSL сертификат
```bash
./scripts/setup-ssl.sh n8n.вашдомен.ru ваш@email.ru
```

### 8️⃣ Проверьте работу
Откройте в браузере: https://n8n.вашдомен.ru

## 📱 Настройка бота в n8n

### 1. Войдите в n8n
- URL: https://n8n.вашдомен.ru
- Логин: admin (или из .env)
- Пароль: из .env файла

### 2. Импортируйте workflow
1. Нажмите **Workflows** → **Import**
2. Выберите файл `workflows/telegram-bot-deepseek.json`
3. Нажмите **Import**

### 3. Настройте подключения

#### Telegram:
1. Дважды кликните на любую Telegram ноду
2. В Credentials нажмите **Create New**
3. Вставьте токен бота
4. Нажмите **Create**

#### Google Sheets:
1. Дважды кликните на Google Sheets ноду
2. В Credentials нажмите **Create New**
3. Выберите **OAuth2**
4. Вставьте Client ID и Secret
5. Нажмите **Connect**
6. Авторизуйтесь в Google

#### DeepSeek API:
1. В ноде **DeepSeek API**
2. В Headers найдите **Authorization**
3. Замените `YOUR_DEEPSEEK_API_KEY` на ваш ключ

### 4. Обновите ID таблицы
Во всех Google Sheets нодах замените `YOUR_GOOGLE_SHEET_ID` на ID вашей таблицы

### 5. Активируйте workflow
Нажмите переключатель **Active** в правом верхнем углу

### 6. Установите webhook
```bash
# Получите URL webhook из n8n (Telegram Trigger нода)
# Затем выполните:
curl "https://api.telegram.org/bot{ВАШ_ТОКЕН}/setWebhook?url={WEBHOOK_URL}"
```

## ✅ Готово!

Теперь ваш бот работает! Проверьте его в Telegram.

## 🛠 Управление системой

Используйте удобное меню управления:
```bash
/opt/n8n-telegram-bot/scripts/manage.sh
```

## 📞 Если что-то не работает

1. Проверьте логи:
```bash
cd /opt/n8n-telegram-bot
docker-compose -f deployment/docker-compose.yml logs -f
```

2. Проверьте статус:
```bash
docker-compose -f deployment/docker-compose.yml ps
```

3. Используйте меню управления (опция 5 для просмотра логов)

## 🔐 Важные файлы

- **Пароли**: `/opt/n8n-telegram-bot/deployment/.env`
- **Резервные копии**: `/backup/n8n/`
- **Логи**: `/var/log/n8n-*.log`

**Обязательно сохраните .env файл в безопасном месте!**
