const pool = require('../db/pool');

// POST /api/contact
const createContactMessage = async (req, res) => {
  const { name, email, phone, subject, message } = req.body;
  if (!name || !email || !subject || !message) {
    return res.status(400).json({ success: false, message: 'Name, email, subject and message are required' });
  }

  const result = await pool.query(
    `INSERT INTO contact_messages (name, email, phone, subject, message)
     VALUES ($1, $2, $3, $4, $5) RETURNING *`,
    [name, email, phone || null, subject, message]
  );

  res.status(201).json({ success: true, message: 'Message sent successfully', data: { contact: result.rows[0] } });
};

module.exports = { createContactMessage };
