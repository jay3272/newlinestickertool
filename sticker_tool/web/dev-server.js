const express = require('express');
const app = express();
const port = 62876; // 固定端口

app.use(express.static('.'));

app.listen(port, () => {
  console.log(`開發服務器運行在 http://localhost:${port}`);
}); 