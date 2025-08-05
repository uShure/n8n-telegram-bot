# 🚀 n8n Telegram Bot - Руководство по развертыванию

## 📋 Что включено в проект

### 1. **Demo версия** (для быстрого тестирования)
- Работает локально без настройки
- Реальный Telegram бот (тестовый токен)
- Mock API для демонстрации
- Готовые примеры объяснительных

### 2. **Production версия** (для сервера)
- Полная интеграция с DeepSeek AI
- Google Sheets для хранения данных
- Система лимитов и подписок
- SSL, backup, мониторинг

## 🎯 С чего начать?

### Вариант 1: Быстрый тест (5 минут)

```bash
cd deployment/demo
chmod +x start-demo.sh
./start-demo.sh
```

Откройте http://localhost:5678
- Логин: `demo`
- Пароль: `demo123`

📖 Подробнее: `demo/README_DEMO.md`

### Вариант 2: Установка на сервер

1. **Подготовьте данные:**
   - Telegram токен от @BotFather
   - Google Sheets API credentials
   - DeepSeek API ключ
   - Домен для сайта

2. **Запустите установку:**
   ```bash
   chmod +x scripts/install.sh
   ./scripts/install.sh
   ```

3. **Следуйте инструкциям**

📖 Подробнее: `DEPLOYMENT_GUIDE.md`

## 📁 Структура файлов

```
deployment/
├── docker-compose.yml        # Production конфигурация
├── docker-compose.demo.yml   # Demo конфигурация
├── .env.production          # Шаблон переменных
├── demo-env-config.txt      # Demo переменные (с тестовым токеном)
│
├── demo/                    # Всё для демо версии
│   ├── start-demo.sh       # Быстрый запуск демо
│   ├── README_DEMO.md      # Инструкция по демо
│   └── workflows/          # Демо workflow
│
├── nginx/                   # Конфигурация веб-сервера
├── scripts/                 # Скрипты управления
│   ├── install.sh          # Автоматическая установка
│   ├── manage.sh           # Меню управления
│   ├── backup.sh           # Резервное копирование
│   └── setup-ssl.sh        # Настройка SSL
│
└── docs/                    # Документация
    ├── QUICK_START.md      # Быстрый старт
    └── DEPLOYMENT_GUIDE.md # Полное руководство
```

## 🔐 Важные файлы с паролями

1. **Для демо**: `demo-env-config.txt`
   - Содержит тестовый токен бота
   - Готов к использованию

2. **Для production**: `.env.production`
   - Шаблон для заполнения
   - Требует ваши реальные данные

## 💡 Рекомендуемый порядок действий

1. **Запустите демо** - убедитесь, что всё работает
2. **Получите API ключи** - для production версии
3. **Настройте сервер** - используя `DEPLOYMENT_GUIDE.md`
4. **Протестируйте** - перед запуском в работу
5. **Включите backups** - для безопасности данных

## ⚡ Полезные команды

### Демо версия
```bash
# Запуск
cd deployment/demo && ./start-demo.sh

# Остановка
docker-compose -f deployment/docker-compose.demo.yml down

# Логи
docker-compose -f deployment/docker-compose.demo.yml logs -f
```

### Production версия
```bash
# Управление (рекомендуется)
/opt/n8n-telegram-bot/scripts/manage.sh

# Ручные команды
docker-compose -f deployment/docker-compose.yml up -d    # Запуск
docker-compose -f deployment/docker-compose.yml down     # Остановка
docker-compose -f deployment/docker-compose.yml logs -f  # Логи
```

## 📞 Если нужна помощь

1. Проверьте документацию в папке `docs/`
2. Посмотрите логи через `manage.sh`
3. Убедитесь, что все порты свободны
4. Проверьте правильность API ключей

## ⚠️ Безопасность

- **Смените демо токен** после тестирования
- **Используйте сложные пароли** в production
- **Настройте firewall** на сервере
- **Делайте backups** регулярно

---

**Успешного развертывания!** 🎉
