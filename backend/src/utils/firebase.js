const { initializeApp, cert } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');
const path = require('path');

let app = null;

const getFirebaseApp = () => {
  if (app) return app;

  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (!serviceAccountPath) {
    console.warn('⚠️  FIREBASE_SERVICE_ACCOUNT_PATH not set — push notifications will not be delivered');
    return null;
  }

  try {
    const serviceAccount = require(path.resolve(serviceAccountPath));
    app = initializeApp({ credential: cert(serviceAccount) });
    return app;
  } catch (err) {
    console.warn('⚠️  Firebase Admin SDK failed to initialize:', err.message);
    return null;
  }
};

// tokens: string[], returns { successCount, failureCount, invalidTokens: string[] }
const sendPushToTokens = async (tokens, { title, body, data = {} }) => {
  const fbApp = getFirebaseApp();
  if (!fbApp || !tokens.length) {
    return { successCount: 0, failureCount: tokens.length, invalidTokens: [] };
  }

  const message = {
    notification: { title, body },
    data,
    tokens,
  };

  const response = await getMessaging(fbApp).sendEachForMulticast(message);

  const invalidTokens = [];
  response.responses.forEach((r, i) => {
    if (!r.success && ['messaging/invalid-registration-token', 'messaging/registration-token-not-registered'].includes(r.error?.code)) {
      invalidTokens.push(tokens[i]);
    }
  });

  return { successCount: response.successCount, failureCount: response.failureCount, invalidTokens };
};

module.exports = { getFirebaseApp, sendPushToTokens };
