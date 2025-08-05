const express = require('express');
const app = express();
const port = 3001;

app.use(express.json());

// Middleware to log requests
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Mock Telegram webhook
app.post('/webhook/telegram-demo', (req, res) => {
  console.log('Telegram webhook received:', req.body);

  // Simulate Telegram update
  setTimeout(() => {
    console.log('Processing Telegram update...');
  }, 100);

  res.json({ ok: true });
});

// Mock DeepSeek API
app.post('/api/deepseek/chat/completions', (req, res) => {
  const { messages } = req.body;
  const lastMessage = messages[messages.length - 1];

  // Generate mock response based on role
  const mockResponses = {
    commander: `ОБЪЯСНИТЕЛЬНАЯ ЗАПИСКА

Командиру воинской части 12345
полковнику Иванову И.И.

от командира взвода
лейтенанта Петрова П.П.

${new Date().toLocaleDateString('ru-RU')}

Довожу до Вашего сведения, что ${new Date().toLocaleDateString('ru-RU')} в 14:30 во вверенном мне подразделении произошло нарушение воинской дисциплины...

[Демо-текст объяснительной от командира]

Меры приняты:
1. Проведена беседа с личным составом
2. Усилен контроль за соблюдением распорядка дня
3. Назначены дополнительные занятия

Выводы: Считаю необходимым усилить воспитательную работу в подразделении.

Лейтенант                    П.П. Петров`,

    witness: `ОБЪЯСНИТЕЛЬНАЯ ЗАПИСКА

${new Date().toLocaleDateString('ru-RU')}

Я, рядовой Сидоров С.С., находясь ${new Date().toLocaleDateString('ru-RU')} в расположении части, стал свидетелем следующего происшествия...

[Демо-текст объяснительной от очевидца]

Время происшествия: примерно 14:30
Место: территория КПП-1
Участники: младший сержант Козлов К.К., рядовой Васильев В.В.

Описание событий:
1. Услышал громкие голоса
2. Увидел, как...
3. После этого...

Других подробностей не помню.

Рядовой                    С.С. Сидоров`,

    sergeant: `ОБЪЯСНИТЕЛЬНАЯ ЗАПИСКА

Командиру роты
капитану Николаеву Н.Н.

от старшины роты
старшего прапорщика Михайлова М.М.

${new Date().toLocaleDateString('ru-RU')}

Докладываю, что в ходе проверки расположения роты ${new Date().toLocaleDateString('ru-RU')} мною было выявлено...

[Демо-текст объяснительной от старшины]

Принятые меры:
- Проведен дополнительный инструктаж
- Усилен контроль за порядком в казарме
- Назначены ответственные

Предложения:
1. Провести внеплановую проверку всех помещений
2. Усилить дежурство в выходные дни

Старший прапорщик                    М.М. Михайлов`,

    default: `ОБЪЯСНИТЕЛЬНАЯ ЗАПИСКА

${new Date().toLocaleDateString('ru-RU')}

[Демо-текст стандартной объяснительной записки]

Прошу принять во внимание изложенные обстоятельства.

Подпись                    Фамилия И.О.`
  };

  // Determine which response to use
  let responseText = mockResponses.default;
  if (lastMessage && lastMessage.content) {
    if (lastMessage.content.includes('командир')) responseText = mockResponses.commander;
    else if (lastMessage.content.includes('очевидец')) responseText = mockResponses.witness;
    else if (lastMessage.content.includes('старшина')) responseText = mockResponses.sergeant;
  }

  res.json({
    id: 'demo-' + Date.now(),
    object: 'chat.completion',
    created: Date.now(),
    model: 'deepseek-demo',
    choices: [{
      index: 0,
      message: {
        role: 'assistant',
        content: responseText
      },
      finish_reason: 'stop'
    }],
    usage: {
      prompt_tokens: 100,
      completion_tokens: 200,
      total_tokens: 300
    }
  });
});

// Mock Google Sheets API
app.get('/api/sheets/:sheetId/values/:range', (req, res) => {
  // Return mock user data
  res.json({
    range: req.params.range,
    majorDimension: 'ROWS',
    values: [
      ['userId', 'chatId', 'role', 'quota', 'sub'],
      ['123456', '123456', 'commander', '3', 'false'],
      ['789012', '789012', 'witness', '6', 'false'],
      ['345678', '345678', 'sergeant', '1', 'true']
    ]
  });
});

app.post('/api/sheets/:sheetId/values/:range:append', (req, res) => {
  console.log('Mock Google Sheets append:', req.body);
  res.json({
    spreadsheetId: req.params.sheetId,
    updates: {
      updatedRows: 1,
      updatedColumns: 5,
      updatedCells: 5
    }
  });
});

app.put('/api/sheets/:sheetId/values/:range', (req, res) => {
  console.log('Mock Google Sheets update:', req.body);
  res.json({
    spreadsheetId: req.params.sheetId,
    updatedRows: 1,
    updatedColumns: 5,
    updatedCells: 5
  });
});

// Mock Telegram API endpoints
app.post('/bot:token/sendMessage', (req, res) => {
  console.log('Mock Telegram sendMessage:', req.body);
  res.json({
    ok: true,
    result: {
      message_id: Date.now(),
      from: { id: 1, is_bot: true, first_name: 'Demo Bot' },
      chat: { id: req.body.chat_id, type: 'private' },
      date: Date.now(),
      text: req.body.text
    }
  });
});

app.post('/bot:token/setWebhook', (req, res) => {
  console.log('Mock Telegram setWebhook:', req.body);
  res.json({
    ok: true,
    result: true,
    description: 'Webhook was set'
  });
});

app.get('/bot:token/getWebhookInfo', (req, res) => {
  res.json({
    ok: true,
    result: {
      url: 'http://localhost:5678/webhook/telegram-demo',
      has_custom_certificate: false,
      pending_update_count: 0,
      last_error_date: null,
      last_error_message: null,
      max_connections: 40,
      allowed_updates: ['message', 'callback_query']
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {
      telegram: 'mocked',
      deepseek: 'mocked',
      googleSheets: 'mocked'
    }
  });
});

// Start server
app.listen(port, () => {
  console.log(`Mock API server running at http://localhost:${port}`);
  console.log('Available endpoints:');
  console.log('- POST /webhook/telegram-demo');
  console.log('- POST /api/deepseek/chat/completions');
  console.log('- GET/POST/PUT /api/sheets/:sheetId/*');
  console.log('- POST /bot:token/sendMessage');
  console.log('- GET /health');
});

// Simulate periodic Telegram updates
setInterval(() => {
  console.log('Simulating Telegram activity...');
  // In a real demo, this could trigger webhook calls to n8n
}, 30000);
