const multer = require('multer');
const { v2: cloudinary } = require('cloudinary');
const { Readable } = require('stream');
const { getSetting } = require('../utils/settings');

const uploadError = (status, message) => Object.assign(new Error(message), { status, expose: true });
const NOT_SET_UP = 'Image uploads aren\'t set up yet. Add the Cloudinary credentials in Admin → Settings → API Keys → Media / CDN.';

// Credentials come from Admin → API Keys (store_settings, encrypted) with the server env as fallback.
const configureCloudinary = async () => {
  const [cloud_name, api_key, api_secret] = await Promise.all(
    ['CLOUDINARY_CLOUD_NAME', 'CLOUDINARY_API_KEY', 'CLOUDINARY_API_SECRET'].map(getSetting)
  );
  const placeholder = (v) => !v || /^your[_-]/i.test(v);
  if ([cloud_name, api_key, api_secret].some(placeholder)) throw uploadError(503, NOT_SET_UP);
  cloudinary.config({ cloud_name, api_key, api_secret });
};

// Store file in memory (buffer), upload to Cloudinary manually
const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) cb(null, true);
    else cb(uploadError(400, 'Only image files (JPG, PNG, WebP) can be uploaded.'));
  },
});

const uploadToCloudinary = async (buffer, folder = 'chillfi') => {
  await configureCloudinary();
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder, resource_type: 'image', quality: 'auto', fetch_format: 'auto' },
      (err, result) => {
        if (!err) return resolve(result);
        if (err.http_code === 401 || err.http_code === 403) {
          return reject(uploadError(503, 'Cloudinary rejected the credentials. Check Admin → Settings → API Keys → Media / CDN.'));
        }
        reject(err);
      }
    );
    Readable.from(buffer).pipe(stream);
  });
};

module.exports = { upload, uploadToCloudinary, configureCloudinary, cloudinary };
