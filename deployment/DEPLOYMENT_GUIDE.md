# Руководство по развертыванию n8n Telegram Bot на First VDS

## 📋 Содержание
1. [Требования к серверу](#требования-к-серверу)
2. [Быстрая установка](#быстрая-установка)
3. [Ручная установка](#ручная-установка)
4. [Настройка после установки](#настройка-после-установки)
5. [Управление системой](#управление-системой)
6. [Резервное копирование](#резервное-копирование)
7. [Мониторинг и логи](#мониторинг-и-логи)
8. [Решение проблем](#решение-проблем)
9. [Обновление системы](#обновление-системы)

## Требования к серверу

### Минимальные требования:
- **ОС**: Ubuntu 20.04/22.04 LTS
- **CPU**: 2 vCPU
- **RAM**: 4 GB
- **Диск**: 20 GB SSD
- **Сеть**: Статический IP

### Рекомендуемые требования:
- **CPU**: 4 vCPU
- **RAM**: 8 GB
- **Диск**: 50 GB SSD

## Быстрая установка

### 1. Подключение к серверу
```bash
ssh root@your-server-ip
```

### 2. Загрузка и запуск скрипта установки
```bash
# Скачайте проект
git clone https://github.com/your-repo/n8n-telegram-bot.git
cd n8n-telegram-bot

# Сделайте скрипт исполняемым
chmod +x scripts/install.sh

# Запустите установку
./scripts/install.sh
```

### 3. Настройка переменных окружения
```bash
cd /opt/n8n-telegram-bot
cp deployment/.env.production deployment/.env
nano deployment/.env
```

Обязательно заполните:
- Пароли для PostgreSQL и Redis
- Данные администратора n8n
- Токен Telegram бота
- API ключи для Google Sheets и DeepSeek
- Ваш домен

### 4. Запуск системы
```bash
cd /opt/n8n-telegram-bot
docker-compose -f deployment/docker-compose.yml up -d
```

### 5. Настройка SSL
```bash
./scripts/setup-ssl.sh your-domain.com your-email@example.com
```

## Ручная установка

### 1. Обновление системы
```bash
apt update && apt upgrade -y
```

### 2. Установка Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### 3. Установка Docker Compose
```bash
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### 4. Настройка файрвола
```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 5. Создание структуры проекта
```bash
mkdir -p /opt/n8n-telegram-bot
cd /opt/n8n-telegram-bot
# Скопируйте файлы проекта
```

### 6. Настройка и запуск
```bash
# Настройте .env файл
cp deployment/.env.production deployment/.env
nano deployment/.env

# Запустите контейнеры
docker-compose -f deployment/docker-compose.yml up -d
```

## Настройка после установки

### 1. Первый вход в n8n
1. Откройте https://your-domain.com
2. Используйте логин/пароль из .env файла
3. Создайте первого пользователя

### 2. Импорт workflow
1. В n8n перейдите в Workflows
2. Нажмите Import
3. Выберите файл `workflows/telegram-bot-deepseek.json`
4. Настройте credentials для всех сервисов

### 3. Настройка Telegram Webhook
```bash
# Проверьте webhook
curl https://api.telegram.org/bot<YOUR_TOKEN>/getWebhookInfo

# Установите webhook
curl https://api.telegram.org/bot<YOUR_TOKEN>/setWebhook?url=https://your-domain.com/webhook/telegram-bot
```

### 4. Настройка Google Sheets
1. Создайте таблицу с нужными колонками
2. Настройте OAuth2 в n8n
3. Проверьте подключение

## Управление системой

### Основные команды

```bash
# Перейти в директорию проекта
cd /opt/n8n-telegram-bot

# Просмотр статуса
docker-compose -f deployment/docker-compose.yml ps

# Остановка
docker-compose -f deployment/docker-compose.yml stop

# Запуск
docker-compose -f deployment/docker-compose.yml start

# Перезапуск
docker-compose -f deployment/docker-compose.yml restart

# Полная остановка
docker-compose -f deployment/docker-compose.yml down

# Просмотр логов
docker-compose -f deployment/docker-compose.yml logs -f

# Логи конкретного сервиса
docker-compose -f deployment/docker-compose.yml logs -f n8n
```

### Systemd команды

```bash
# Статус службы
systemctl status n8n-telegram-bot

# Запуск
systemctl start n8n-telegram-bot

# Остановка
systemctl stop n8n-telegram-bot

# Перезапуск
systemctl restart n8n-telegram-bot

# Автозапуск
systemctl enable n8n-telegram-bot
```

## Резервное копирование

### Автоматическое резервное копирование
Система автоматически создает резервные копии каждую ночь в 3:00.

### Ручное резервное копирование
```bash
/opt/n8n-telegram-bot/scripts/backup.sh
```

### Восстановление из резервной копии

1. **Восстановление базы данных:**
```bash
# Остановите n8n
docker-compose -f deployment/docker-compose.yml stop n8n

# Восстановите базу
gunzip < /backup/n8n/db_20240101_030000.sql.gz | docker-compose -f deployment/docker-compose.yml exec -T postgres psql -U n8n n8n

# Запустите n8n
docker-compose -f deployment/docker-compose.yml start n8n
```

2. **Восстановление файлов n8n:**
```bash
# Распакуйте архив
tar -xzf /backup/n8n/n8n_data_20240101_030000.tar.gz -C /var/lib/docker/volumes/
```

## Мониторинг и логи

### Просмотр логов

```bash
# Все логи
docker-compose -f deployment/docker-compose.yml logs

# Логи n8n
docker-compose -f deployment/docker-compose.yml logs n8n

# Следить за логами в реальном времени
docker-compose -f deployment/docker-compose.yml logs -f

# Логи nginx
docker logs n8n-telegram-bot_nginx_1

# Системные логи
tail -f /var/log/n8n-monitor.log
tail -f /var/log/n8n-backup.log
```

### Мониторинг ресурсов

```bash
# Использование ресурсов контейнерами
docker stats

# Системные ресурсы
htop

# Дисковое пространство
df -h

# Использование памяти
free -h
```

### Проверка работоспособности

```bash
# Проверка всех сервисов
docker-compose -f deployment/docker-compose.yml ps

# Проверка n8n
curl -I https://your-domain.com

# Проверка webhook
curl https://api.telegram.org/bot<YOUR_TOKEN>/getWebhookInfo
```

## Решение проблем

### n8n не запускается

1. Проверьте логи:
```bash
docker-compose -f deployment/docker-compose.yml logs n8n
```

2. Проверьте базу данных:
```bash
docker-compose -f deployment/docker-compose.yml exec postgres psql -U n8n -c "SELECT 1;"
```

3. Проверьте права доступа:
```bash
ls -la /opt/n8n-telegram-bot/
```

### Проблемы с SSL

1. Проверьте сертификаты:
```bash
ls -la /opt/n8n-telegram-bot/certbot/conf/live/
```

2. Обновите сертификат вручную:
```bash
/opt/n8n-telegram-bot/scripts/renew-ssl.sh
```

### Бот не отвечает

1. Проверьте webhook:
```bash
curl https://api.telegram.org/bot<YOUR_TOKEN>/getWebhookInfo
```

2. Проверьте workflow в n8n
3. Проверьте логи выполнения в n8n UI

### База данных недоступна

```bash
# Перезапустите PostgreSQL
docker-compose -f deployment/docker-compose.yml restart postgres

# Проверьте логи
docker-compose -f deployment/docker-compose.yml logs postgres
```

## Обновление системы

### Обновление n8n

```bash
cd /opt/n8n-telegram-bot

# Сделайте резервную копию
./scripts/backup.sh

# Обновите образы
docker-compose -f deployment/docker-compose.yml pull

# Перезапустите
docker-compose -f deployment/docker-compose.yml up -d
```

### Обновление workflow

1. Экспортируйте текущий workflow в n8n
2. Импортируйте новую версию
3. Перенесите credentials
4. Протестируйте

## Безопасность

### Регулярные действия

1. **Обновляйте систему:**
```bash
apt update && apt upgrade -y
```

2. **Проверяйте логи безопасности:**
```bash
# fail2ban статистика
fail2ban-client status sshd

# Последние попытки входа
last -n 20
```

3. **Меняйте пароли каждые 3 месяца**

### Рекомендации

- Используйте сложные пароли
- Ограничьте SSH доступ по IP
- Регулярно проверяйте логи
- Делайте резервные копии

## Контакты поддержки

При возникновении проблем:
1. Проверьте логи
2. Обратитесь к этой документации
3. Свяжитесь с разработчиком

---

**Важно:** Сохраните все пароли и ключи в надежном месте!
