import { initializeApp, getApps, getApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

// Public Firebase web config (identifies the project; not a secret). Used for phone OTP on Login and Delete Account.
const firebaseConfig = {
  apiKey: 'AIzaSyBOmbn0_LwNQhX_bitzh2Djae7NVPpFqro',
  authDomain: 'chillfi.firebaseapp.com',
  projectId: 'chillfi',
  storageBucket: 'chillfi.firebasestorage.app',
  messagingSenderId: '414620965564',
  appId: '1:414620965564:web:2e8affe35b1da184f20eb9',
};

export const firebaseApp = getApps().length ? getApp() : initializeApp(firebaseConfig);
export const firebaseAuth = getAuth(firebaseApp);

export const firebaseErrorMsg = (code?: string): string | null => {
  switch (code) {
    case 'auth/too-many-requests': return 'Too many attempts. Please wait and try again.';
    case 'auth/invalid-phone-number': return 'Invalid phone number.';
    case 'auth/unauthorized-domain': return 'Domain not authorized in Firebase. Contact support.';
    case 'auth/invalid-verification-code': return 'Incorrect OTP. Please try again.';
    case 'auth/code-expired': return 'OTP expired. Please request a new one.';
    default: return null;
  }
};
