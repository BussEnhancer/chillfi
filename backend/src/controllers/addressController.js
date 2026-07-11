const pool = require('../db/pool');

// GET /api/addresses
const getAddresses = async (req, res) => {
  const result = await pool.query(
    'SELECT * FROM addresses WHERE user_id = $1 ORDER BY is_default DESC, created_at DESC',
    [req.user.id]
  );
  res.json({ success: true, data: { addresses: result.rows } });
};

// POST /api/addresses
const createAddress = async (req, res) => {
  const { label = 'Home', name, phone, line1, line2, city, state, pincode, is_default = false } = req.body;
  if (!name || !phone || !line1 || !city || !state || !pincode) {
    return res.status(400).json({ success: false, message: 'All required fields must be filled' });
  }

  if (is_default) {
    await pool.query('UPDATE addresses SET is_default = FALSE WHERE user_id = $1', [req.user.id]);
  }

  const result = await pool.query(`
    INSERT INTO addresses (user_id, label, name, phone, line1, line2, city, state, pincode, is_default)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *
  `, [req.user.id, label, name, phone, line1, line2 || null, city, state, pincode, is_default]);

  res.status(201).json({ success: true, data: { address: result.rows[0] } });
};

// PUT /api/addresses/:id
const updateAddress = async (req, res) => {
  const { id } = req.params;
  const { label, name, phone, line1, line2, city, state, pincode, is_default } = req.body;

  if (is_default) {
    await pool.query('UPDATE addresses SET is_default = FALSE WHERE user_id = $1', [req.user.id]);
  }

  const result = await pool.query(`
    UPDATE addresses SET
      label = COALESCE($1, label), name = COALESCE($2, name), phone = COALESCE($3, phone),
      line1 = COALESCE($4, line1), line2 = COALESCE($5, line2), city = COALESCE($6, city),
      state = COALESCE($7, state), pincode = COALESCE($8, pincode),
      is_default = COALESCE($9, is_default)
    WHERE id = $10 AND user_id = $11 RETURNING *
  `, [label, name, phone, line1, line2, city, state, pincode, is_default, id, req.user.id]);

  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Address not found' });
  res.json({ success: true, data: { address: result.rows[0] } });
};

// DELETE /api/addresses/:id
const deleteAddress = async (req, res) => {
  const { id } = req.params;
  await pool.query('DELETE FROM addresses WHERE id = $1 AND user_id = $2', [id, req.user.id]);
  res.json({ success: true, message: 'Address deleted' });
};

// PUT /api/addresses/:id/set-default
const setDefault = async (req, res) => {
  const { id } = req.params;
  await pool.query('UPDATE addresses SET is_default = FALSE WHERE user_id = $1', [req.user.id]);
  await pool.query('UPDATE addresses SET is_default = TRUE WHERE id = $1 AND user_id = $2', [id, req.user.id]);
  res.json({ success: true, message: 'Default address updated' });
};

module.exports = { getAddresses, createAddress, updateAddress, deleteAddress, setDefault };
