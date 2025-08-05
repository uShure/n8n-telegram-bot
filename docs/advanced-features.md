# Расширенные возможности и кастомизация

## Содержание
1. [Добавление новых ролей](#добавление-новых-ролей)
2. [Настройка промптов](#настройка-промптов)
3. [Изменение лимитов](#изменение-лимитов)
4. [Интеграция с ЮKassa](#интеграция-с-юkassa)
5. [Добавление логирования](#добавление-логирования)
6. [Мультиязычность](#мультиязычность)
7. [Webhook настройки](#webhook-настройки)

## Добавление новых ролей

### 1. Обновление меню в Telegram

В ноде "Send Menu" добавьте новую кнопку:

```json
{
  "row": {
    "buttons": [
      {
        "text": "🎯 Новая роль",
        "callback_data": "role_newrole"
      }
    ]
  }
}
```

### 2. Добавление промпта

В ноде "Prepare Prompt" в объект `prompts` добавьте:

```javascript
newrole: {
  system: "Системный промпт для новой роли...",
  user: "Пользовательский промпт..."
}
```

### 3. Создание файла с промптом

Создайте файл `prompts/newrole.md` с детальным описанием.

## Настройка промптов

### Изменение существующих промптов

1. **Через n8n:**
   - Откройте ноду "Prepare Prompt"
   - Измените текст в объекте `prompts`
   - Сохраните workflow

2. **Через файлы промптов:**
   - Отредактируйте файлы в папке `prompts/`
   - Синхронизируйте с кодом в n8n

### Параметры генерации

В ноде "DeepSeek API" можно настроить:

```json
{
  "temperature": 0.7,      // Креативность (0-1)
  "max_tokens": 2000,      // Максимальная длина
  "top_p": 0.9,           // Разнообразие
  "frequency_penalty": 0   // Штраф за повторения
}
```

### Добавление контекста

Для улучшения генерации можно добавить контекст:

```javascript
messages: [
  {
    role: "system",
    content: systemPrompt
  },
  {
    role: "assistant",
    content: "Пример хорошей объяснительной..."
  },
  {
    role: "user",
    content: userPrompt
  }
]
```

## Изменение лимитов

### Базовый лимит

В ноде "Check Limits" измените условие:

```javascript
// Было: if (quota < 6)
if (quota < 10) // Новый лимит: 10 запросов
```

### Дифференцированные лимиты

Добавьте логику для разных типов пользователей:

```javascript
let limit = 6; // Базовый лимит

// VIP пользователи
if (vipUsers.includes(userId)) {
  limit = 20;
}

// Проверка
if (quota < limit) {
  // Разрешить генерацию
}
```

### Лимиты по времени

Добавьте сброс лимитов раз в день/неделю:

```javascript
// Добавьте колонку lastReset в Google Sheets
const lastReset = new Date(userData.lastReset);
const now = new Date();

// Если прошло больше суток
if (now - lastReset > 24 * 60 * 60 * 1000) {
  // Сбросить счетчик
  quota = 0;
}
```

## Интеграция с ЮKassa

### 1. Подготовка

1. Зарегистрируйтесь в ЮKassa
2. Получите shopId и secretKey
3. Настройте уведомления

### 2. Создание ноды для оплаты

```javascript
// HTTP Request нода для создания платежа
{
  "method": "POST",
  "url": "https://api.yookassa.ru/v3/payments",
  "authentication": "basicAuth",
  "credentials": {
    "user": "{{ $credentials.shopId }}",
    "password": "{{ $credentials.secretKey }}"
  },
  "body": {
    "amount": {
      "value": "299.00",
      "currency": "RUB"
    },
    "confirmation": {
      "type": "redirect",
      "return_url": "https://t.me/your_bot"
    },
    "description": "Подписка на бота",
    "metadata": {
      "userId": "{{ $json.userId }}"
    }
  }
}
```

### 3. Обработка webhook от ЮKassa

Создайте отдельный workflow для обработки уведомлений:

1. Webhook нода для приема уведомлений
2. Проверка подписи
3. Обновление статуса подписки в Google Sheets
4. Отправка уведомления пользователю

## Добавление логирования

### 1. Создание таблицы логов

В Google Sheets создайте лист "Logs" с колонками:
- timestamp
- userId
- action
- role
- status
- error

### 2. Добавление записи в лог

После каждого действия добавьте ноду Google Sheets:

```javascript
{
  "operation": "append",
  "sheetName": "Logs",
  "fieldsUi": {
    "values": [
      {
        "column": "timestamp",
        "fieldValue": "{{ new Date().toISOString() }}"
      },
      {
        "column": "userId",
        "fieldValue": "{{ $json.userId }}"
      },
      {
        "column": "action",
        "fieldValue": "generate"
      },
      {
        "column": "status",
        "fieldValue": "success"
      }
    ]
  }
}
```

### 3. Мониторинг ошибок

Добавьте Error Trigger для отлова ошибок:

```javascript
// В Code ноде для обработки ошибок
try {
  // Основная логика
} catch (error) {
  // Логирование ошибки
  await logError(userId, error.message);

  // Отправка уведомления админу
  await sendAdminNotification(error);

  throw error; // Пробросить дальше
}
```

## Мультиязычность

### 1. Определение языка пользователя

```javascript
// В Check User ноде
const userLang = callbackData.from.language_code || 'ru';

// Сохранить в Google Sheets
userData.language = userLang;
```

### 2. Мультиязычные промпты

```javascript
const prompts = {
  ru: {
    commander: { /* ... */ },
    witness: { /* ... */ }
  },
  en: {
    commander: { /* ... */ },
    witness: { /* ... */ }
  }
};

const userPrompts = prompts[userLang] || prompts.ru;
```

### 3. Перевод интерфейса

```javascript
const translations = {
  ru: {
    welcome: "Добро пожаловать!",
    choose_role: "Выберите роль:",
    limit_reached: "Лимит исчерпан"
  },
  en: {
    welcome: "Welcome!",
    choose_role: "Choose role:",
    limit_reached: "Limit reached"
  }
};

const t = translations[userLang] || translations.ru;
```

## Webhook настройки

### Production webhook

```bash
# Установка webhook
curl -X POST "https://api.telegram.org/bot{TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-n8n.com/webhook/telegram-bot",
    "max_connections": 40,
    "allowed_updates": ["message", "callback_query"]
  }'
```

### Проверка webhook

```bash
# Информация о webhook
curl "https://api.telegram.org/bot{TOKEN}/getWebhookInfo"
```

### Удаление webhook (для локальной разработки)

```bash
curl "https://api.telegram.org/bot{TOKEN}/deleteWebhook"
```

## Оптимизация производительности

### 1. Кеширование промптов

Используйте Static Data в n8n для хранения часто используемых данных:

```javascript
// В начале workflow
const staticData = $getWorkflowStaticData('global');

// Кеширование промптов
if (!staticData.prompts) {
  staticData.prompts = loadPrompts();
}
```

### 2. Батчинг запросов

При массовых операциях используйте batch API Google Sheets:

```javascript
// Вместо отдельных запросов
const batchData = users.map(user => ({
  range: `A${user.row}:E${user.row}`,
  values: [[user.userId, user.chatId, user.role, user.quota, user.sub]]
}));

// Один запрос
await sheets.batchUpdate(batchData);
```

### 3. Асинхронная обработка

Для длительных операций используйте SplitInBatches ноду:

- Batch Size: 10
- Разделение обработки на части
- Предотвращение таймаутов
