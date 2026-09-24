const errorHandler = (err, req, res, next) => {
  console.error(`[${new Date().toISOString()}] ${req.method} ${req.path} →`, err.message);

  if (err.code === '23505') {
    return res.status(409).json({ success: false, message: 'Already exists' });
  }
  if (err.code === '23503') {
    return res.status(400).json({ success: false, message: 'Invalid reference ID' });
  }
  if (err.code === '23502') {
    return res.status(400).json({ success: false, message: 'A required field is missing' });
  }

  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
  });
};

module.exports = errorHandler;
