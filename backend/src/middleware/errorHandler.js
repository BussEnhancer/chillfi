const crypto = require('crypto');

// Customer-safe error responses.
//  - 4xx: the message is a deliberate, user-facing validation/business message → passed through.
//  - 5xx / unexpected: never leak internal text (SQL, stack, third-party errors). Return a friendly
//    message + a short reference id that is logged with the real cause for support/debugging.
const FRIENDLY_5XX = 'Something went wrong on our side. Please try again in a moment.';

const errorHandler = (err, req, res, next) => {
  if (res.headersSent) return next(err);

  // Known database errors → clear 4xx messages
  if (err.code === '23505') return res.status(409).json({ success: false, message: 'This already exists.' });
  if (err.code === '23503') return res.status(400).json({ success: false, message: 'The item you referenced no longer exists.' });
  if (err.code === '23502') return res.status(400).json({ success: false, message: 'A required field is missing.' });
  if (err.code === '22P02' || err.code === '22003' || err.code === '22007') {
    return res.status(400).json({ success: false, message: 'Some of the information sent was invalid. Please check and try again.' });
  }
  // Malformed JSON body
  if (err.type === 'entity.parse.failed') return res.status(400).json({ success: false, message: 'The request could not be read. Please try again.' });
  if (err.type === 'entity.too.large') return res.status(413).json({ success: false, message: 'The file or data is too large.' });

  const status = Number(err.status || err.statusCode) || 500;
  if (status < 500) {
    return res.status(status).json({ success: false, message: err.message || 'Request could not be completed.' });
  }

  const ref = crypto.randomBytes(4).toString('hex').toUpperCase();
  console.error(`[${new Date().toISOString()}] ERR-${ref} ${req.method} ${req.originalUrl || req.path} → ${err.message}`);
  if (err.stack && process.env.NODE_ENV !== 'production') console.error(err.stack.split('\n').slice(1, 4).join('\n'));
  return res.status(status).json({ success: false, message: FRIENDLY_5XX, errorRef: ref });
};

module.exports = errorHandler;
