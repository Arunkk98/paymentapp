const express = require('express');
const app = express();
const PORT = process.env.PORT || 5678;

app.use(express.json());

// Liveness / Readiness probe endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', service: 'payment-api', timestamp: new Date() });
});

// Mock transfer endpoint
app.post('/transfer', (req, res) => {
  const { sender, recipient, amount } = req.body;
  if (!sender || !recipient || !amount) {
    return res.status(400).json({ error: 'Missing required fields: sender, recipient, amount' });
  }

  res.status(200).json({
    transactionId: `TXN-${Math.random().toString(36).substring(2, 11).toUpperCase()}`,
    status: 'SUCCESS',
    details: { sender, recipient, amount, currency: 'USD' },
    message: 'Payment processed successfully'
  });
});

app.listen(PORT, () => {
  console.log(`Payment API listening on port ${PORT}`);
});
