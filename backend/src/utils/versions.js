// Dot-separated numeric version compare, e.g. atLeast('1.0.10', '1.0.3') === true.
const atLeast = (v, min) => {
  const a = String(v || '0').split('.').map((n) => parseInt(n, 10) || 0); const b = String(min).split('.').map((n) => parseInt(n, 10) || 0);
  for (let i = 0; i < Math.max(a.length, b.length); i += 1) { if ((a[i] || 0) !== (b[i] || 0)) return (a[i] || 0) > (b[i] || 0); }
  return true;
};
module.exports = { atLeast };
