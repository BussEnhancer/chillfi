const pool = require('../db/pool');

// Normalises an Indian mobile number to its 10 digits ("+91 98765-43210" → "9876543210").
const normPhone = (p) => {
  let d = String(p ?? '').replace(/\D/g, '');
  if (d.length === 12 && d.startsWith('91')) d = d.slice(2);
  if (d.length === 11 && d.startsWith('0')) d = d.slice(1);
  return d;
};

// Returns a customer-facing message for the first invalid field, or null. With partial=true only
// the fields present in the body are checked (updates).
const validateAddress = (b, partial = false) => {
  const has = (k) => b[k] !== undefined && b[k] !== null;
  const need = (k) => !partial || has(k);
  const str = (k) => String(b[k] ?? '').trim();
  if (need('name') && str('name').length < 2) return 'Please enter the full name (at least 2 characters).';
  if (need('phone') && !/^[6-9]\d{9}$/.test(normPhone(b.phone))) return 'Please enter a valid 10-digit mobile number.';
  if (need('line1') && str('line1').length < 3) return 'Please enter the house / street address.';
  if (need('city') && !str('city')) return 'Please enter the city.';
  if (need('state') && !str('state')) return 'Please enter the state.';
  if (need('pincode') && !/^[1-9]\d{5}$/.test(str('pincode'))) return 'Please enter a valid 6-digit pincode.';
  return null;
};

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
  const invalid = validateAddress(req.body);
  if (invalid) return res.status(400).json({ success: false, message: invalid });

  if (is_default) {
    await pool.query('UPDATE addresses SET is_default = FALSE WHERE user_id = $1', [req.user.id]);
  }

  const result = await pool.query(`
    INSERT INTO addresses (user_id, label, name, phone, line1, line2, city, state, pincode, is_default)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *
  `, [req.user.id, label, String(name).trim(), normPhone(phone), String(line1).trim(), line2 || null, String(city).trim(), String(state).trim(), String(pincode).trim(), is_default]);

  res.status(201).json({ success: true, data: { address: result.rows[0] } });
};

// PUT /api/addresses/:id
const updateAddress = async (req, res) => {
  const { id } = req.params;
  const { label, name, line1, line2, city, state, pincode, is_default } = req.body;
  const invalid = validateAddress(req.body, true);
  if (invalid) return res.status(400).json({ success: false, message: invalid });
  const phone = req.body.phone === undefined ? undefined : normPhone(req.body.phone);

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
  // Check ownership first — otherwise a wrong id would clear the customer's current default.
  const own = await pool.query('SELECT 1 FROM addresses WHERE id = $1 AND user_id = $2', [id, req.user.id]);
  if (!own.rows.length) return res.status(404).json({ success: false, message: 'Address not found' });
  await pool.query('UPDATE addresses SET is_default = (id = $1) WHERE user_id = $2', [id, req.user.id]);
  res.json({ success: true, message: 'Default address updated' });
};

module.exports = { getAddresses, createAddress, updateAddress, deleteAddress, setDefault };
