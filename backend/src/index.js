require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const initDB = require('./db/init');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// Trust the first proxy hop (Nginx on EC2) so express-rate-limit reads the real client IP
app.set('trust proxy', 1);

// Middleware
app.use(helmet());
const allowedOrigins = [
  'http://3.111.32.220',       // production EC2 website (legacy plain-HTTP IP access)
  'https://chillfi.in',        // production custom domain
  'https://www.chillfi.in',
  'https://chillfi.web.app',   // Firebase Hosting default domain
  'https://chillfi.firebaseapp.com',
  process.env.FRONTEND_URL,    // override via env (optional)
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:5174',
  'http://localhost:5200',
].filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    // Allow mobile apps (no origin) and listed origins
    if (!origin || allowedOrigins.includes(origin)) return callback(null, true);
    callback(new Error(`CORS blocked: ${origin}`));
  },
  credentials: true,
  exposedHeaders: ['Content-Disposition'], // invoice file names for browser downloads
}));
app.use(morgan('dev'));

// Global rate limit: 200 req/min per IP (generous for legitimate use, blocks scrapers/attacks).
// RATE_LIMIT_MAX may raise it only outside production (local automated QA runs from one IP).
const RATE_MAX = process.env.NODE_ENV !== 'production' && process.env.RATE_LIMIT_MAX ? parseInt(process.env.RATE_LIMIT_MAX, 10) : 200;
app.use(rateLimit({
  windowMs: 60 * 1000,
  max: RATE_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please slow down.' },
  // Courier webhooks arrive in bursts from a few Delhivery IPs; they are token-authenticated instead.
  skip: (req) => req.path === '/health' || req.path === '/api/health' || req.path.startsWith('/api/shipping/'),
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', env: process.env.NODE_ENV, time: new Date().toISOString() });
});

// Public uptime-monitor endpoint (nginx only forwards /api/*). 200 = API + database OK, 503 = something is down.
app.get('/api/health', async (req, res) => {
  const started = Date.now();
  let db = 'ok';
  try {
    await Promise.race([
      require('./db/pool').query('SELECT 1'),
      new Promise((_, rej) => setTimeout(() => rej(new Error('timeout')), 3000)),
    ]);
  } catch { db = 'down'; }
  const ok = db === 'ok';
  res.status(ok ? 200 : 503).json({
    status: ok ? 'ok' : 'degraded', db, uptime_s: Math.round(process.uptime()),
    response_ms: Date.now() - started, time: new Date().toISOString(),
  });
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/products', require('./routes/products'));
app.use('/api/categories', require('./routes/categories'));
app.use('/api/brands', require('./routes/brands'));
app.use('/api/search', require('./routes/search'));
app.use('/api/home', require('./routes/home'));
app.use('/api/cart', require('./routes/cart'));
app.use('/api/addresses', require('./routes/addresses'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/payment', require('./routes/payment'));
app.use('/api/wishlist', require('./routes/wishlist'));
app.use('/api/profile', require('./routes/profile'));
app.use('/api/contact', require('./routes/contact'));
app.use('/api/app-config', require('./routes/appConfig'));
app.use('/api/shipping', require('./routes/shipping'));
app.use('/api/admin', require('./routes/admin'));

// 404
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.path} not found` });
});

// Error handler
app.use(errorHandler);

const PORT = process.env.PORT || 5000;

const start = async () => {
  try {
    await initDB();
    app.listen(PORT, () => {
      console.log(`🚀 ChillFi API running on http://localhost:${PORT}`);
      console.log(`📋 Health: http://localhost:${PORT}/health`);
      require('./services/shipmentService').startScheduler();
    });
  } catch (err) {
    console.error('❌ Failed to start:', err.message);
    process.exit(1);
  }
};

start();
