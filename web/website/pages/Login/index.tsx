import React, { useState, useEffect, useRef } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { initializeApp, getApps, getApp } from 'firebase/app';
import { getAuth, signInWithPhoneNumber, RecaptchaVerifier, ConfirmationResult } from 'firebase/auth';
import Header from '../../components/navigation/Header';
import TopBar from '../../components/navigation/TopBar';
import Footer from '../../components/navigation/Footer';
import Container from '../../components/common/Container';
import AuthHeroSection from '../../components/auth/AuthHeroSection';
import CheckoutTrustStrip from '../../sections/Checkout/CheckoutTrustStrip';
import { ChevronRight, Smartphone, ArrowLeft, Loader2, CheckCircle2, RefreshCw } from 'lucide-react';
import { apiPost } from '../../utils/api';
import { useStore } from '../../context/StoreContext';
import { friendlyError } from '../../utils/api';

const firebaseConfig = {
  apiKey: 'AIzaSyBOmbn0_LwNQhX_bitzh2Djae7NVPpFqro',
  authDomain: 'chillfi.firebaseapp.com',
  projectId: 'chillfi',
  storageBucket: 'chillfi.firebasestorage.app',
  messagingSenderId: '414620965564',
  appId: '1:414620965564:web:2e8affe35b1da184f20eb9',
};

const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
const auth = getAuth(app);

type Tab = 'login' | 'register';
type Step = 'phone' | 'otp';

const OTP_LENGTH = 6;
const RESEND_SECONDS = 30;

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { loginUser, isLoggedIn } = useStore();
  const from = (location.state as { from?: string })?.from || '/';

  useEffect(() => { if (isLoggedIn) navigate(from, { replace: true }); }, [isLoggedIn]);

  const [tab, setTab] = useState<Tab>('login');
  const [step, setStep] = useState<Step>('phone');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [timer, setTimer] = useState(0);
  const otpRefs = useRef<(HTMLInputElement | null)[]>([]);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const confirmationRef = useRef<ConfirmationResult | null>(null);
  const recaptchaRef = useRef<RecaptchaVerifier | null>(null);

  const startTimer = () => {
    setTimer(RESEND_SECONDS);
    timerRef.current = setInterval(() => {
      setTimer(t => {
        if (t <= 1) { clearInterval(timerRef.current!); return 0; }
        return t - 1;
      });
    }, 1000);
  };

  useEffect(() => () => {
    if (timerRef.current) clearInterval(timerRef.current);
    recaptchaRef.current?.clear();
  }, []);

  const validatePhone = (p: string) => /^[6-9]\d{9}$/.test(p);
  const otpValue = otp.join('');

  const switchTab = (t: Tab) => {
    setTab(t); setStep('phone'); setError('');
    setPhone(''); setOtp(['', '', '', '', '', '']); setName(''); setEmail('');
    confirmationRef.current = null;
  };

  const getRecaptchaVerifier = () => {
    if (recaptchaRef.current) { recaptchaRef.current.clear(); recaptchaRef.current = null; }
    recaptchaRef.current = new RecaptchaVerifier(auth, 'recaptcha-container', { size: 'invisible' });
    return recaptchaRef.current;
  };

  const firebaseErrorMsg = (code: string) => {
    switch (code) {
      case 'auth/too-many-requests': return 'Too many attempts. Please wait and try again.';
      case 'auth/invalid-phone-number': return 'Invalid phone number.';
      case 'auth/unauthorized-domain': return 'Domain not authorized in Firebase. Contact support.';
      case 'auth/invalid-verification-code': return 'Incorrect OTP. Please try again.';
      case 'auth/code-expired': return 'OTP expired. Please request a new one.';
      default: return null;
    }
  };

  const handleSendOtp = async () => {
    if (!validatePhone(phone)) { setError('Enter a valid 10-digit Indian mobile number'); return; }
    setLoading(true); setError('');
    try {
      const verifier = getRecaptchaVerifier();
      const result = await signInWithPhoneNumber(auth, `+91${phone}`, verifier);
      confirmationRef.current = result;
      setStep('otp');
      startTimer();
      setTimeout(() => otpRefs.current[0]?.focus(), 100);
    } catch (e: any) {
      setError(firebaseErrorMsg(e.code) ?? 'Failed to send OTP. Try again.');
      recaptchaRef.current?.clear(); recaptchaRef.current = null;
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async () => {
    if (otpValue.length < OTP_LENGTH) { setError('Enter the 6-digit OTP'); return; }
    if (tab === 'register' && !name.trim()) { setError('Please enter your name'); return; }
    if (!confirmationRef.current) { setError('Session expired. Please go back and request a new OTP.'); return; }
    setLoading(true); setError('');
    try {
      const credential = await confirmationRef.current.confirm(otpValue);
      const idToken = await credential.user.getIdToken();
      const res = await apiPost<{ success: boolean; data: { user: any; accessToken: string; refreshToken: string } }>(
        '/auth/firebase-verify',
        { idToken, name: name.trim() || undefined, email: email.trim() || undefined }
      );
      loginUser(res.data.accessToken, res.data.refreshToken);
      navigate(from, { replace: true });
    } catch (e: any) {
      setError(firebaseErrorMsg(e.code) ?? friendlyError(e, 'Verification failed. Try again.'));
    } finally {
      setLoading(false);
    }
  };

  const handleOtpChange = (i: number, val: string) => {
    if (!/^\d*$/.test(val)) return;
    const next = [...otp];
    next[i] = val.slice(-1);
    setOtp(next);
    setError('');
    if (val && i < OTP_LENGTH - 1) otpRefs.current[i + 1]?.focus();
  };

  const handleOtpKeyDown = (i: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otp[i] && i > 0) otpRefs.current[i - 1]?.focus();
    if (e.key === 'Enter') { if (otpValue.length === OTP_LENGTH) handleVerify(); }
  };

  const handleOtpPaste = (e: React.ClipboardEvent) => {
    const text = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, OTP_LENGTH);
    if (text.length) {
      const next = Array(OTP_LENGTH).fill('');
      text.split('').forEach((c, i) => { next[i] = c; });
      setOtp(next);
      otpRefs.current[Math.min(text.length, OTP_LENGTH - 1)]?.focus();
    }
    e.preventDefault();
  };

  const handleResend = async () => {
    if (timer > 0) return;
    setLoading(true); setError(''); setOtp(['', '', '', '', '', '']);
    try {
      const verifier = getRecaptchaVerifier();
      const result = await signInWithPhoneNumber(auth, `+91${phone}`, verifier);
      confirmationRef.current = result;
      startTimer();
      setTimeout(() => otpRefs.current[0]?.focus(), 100);
    } catch (e: any) {
      setError(firebaseErrorMsg(e.code) ?? 'Failed to resend OTP. Try again.');
      recaptchaRef.current?.clear(); recaptchaRef.current = null;
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white font-['Poppins']">
      <TopBar />
      <Header />

      <Container className="py-12 md:py-20">
        <div className="flex flex-col lg:flex-row gap-12 items-stretch">
          <AuthHeroSection />

          <div className="flex-1 max-w-[550px] mx-auto w-full">
            <div className="bg-white rounded-[32px] border border-[#ECECEC] p-8 md:p-12 shadow-sm h-full flex flex-col">

              {/* Login / Register tabs */}
              <div className="flex items-center justify-center gap-16 border-b border-[#ECECEC] mb-10">
                {(['login', 'register'] as Tab[]).map(t => (
                  <button key={t} onClick={() => switchTab(t)} className="relative pb-4 group">
                    <span className={`text-lg transition-colors ${tab === t ? 'font-black text-[#111827]' : 'font-bold text-gray-400 group-hover:text-[#FF6B2C]'}`}>
                      {t === 'login' ? 'Login' : 'Register'}
                    </span>
                    <div className={`absolute bottom-0 left-0 right-0 h-1 rounded-t-full transition-all ${tab === t ? 'bg-[#FF6B2C]' : 'bg-transparent group-hover:bg-[#FF6B2C]/30'}`} />
                  </button>
                ))}
              </div>

              {step === 'phone' ? (
                <>
                  {/* Step 1 — Phone number */}
                  <div className="mb-8">
                    <h3 className="text-sm font-black text-[#111827] mb-2 uppercase tracking-wider">
                      {tab === 'login' ? 'Login with Mobile Number' : 'Create Your Account'}
                    </h3>
                    <p className="text-xs font-bold text-gray-400 mb-6">
                      {tab === 'login' ? 'We\'ll send an OTP to verify your number' : 'Enter your number to get started'}
                    </p>

                    {tab === 'register' && (
                      <div className="mb-4">
                        <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Full Name *</label>
                        <input
                          value={name}
                          onChange={e => setName(e.target.value)}
                          placeholder="Enter your full name"
                          className="w-full border border-[#ECECEC] rounded-xl px-5 py-3.5 text-sm font-bold outline-none focus:border-[#FF6B2C] transition-all shadow-sm"
                        />
                      </div>
                    )}

                    <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Mobile Number *</label>
                    <div className="flex gap-3">
                      <div className="w-20 bg-gray-50 border border-[#ECECEC] rounded-xl px-4 py-3.5 flex items-center justify-center shrink-0">
                        <span className="text-sm font-black">+91</span>
                      </div>
                      <div className={`flex-1 bg-white border rounded-xl px-5 py-3.5 focus-within:border-[#FF6B2C] transition-all flex items-center shadow-sm gap-3 ${error ? 'border-red-400' : 'border-[#ECECEC]'}`}>
                        <Smartphone size={16} className="text-gray-400 shrink-0" />
                        <input
                          type="tel"
                          maxLength={10}
                          value={phone}
                          onChange={e => { setPhone(e.target.value.replace(/\D/g, '')); setError(''); }}
                          onKeyDown={e => e.key === 'Enter' && handleSendOtp()}
                          placeholder="Enter your mobile number"
                          className="w-full bg-transparent outline-none text-sm font-bold"
                          autoFocus
                        />
                      </div>
                    </div>

                    {tab === 'register' && (
                      <div className="mt-4">
                        <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Email (optional)</label>
                        <input
                          type="email"
                          value={email}
                          onChange={e => setEmail(e.target.value)}
                          placeholder="Enter your email address"
                          className="w-full border border-[#ECECEC] rounded-xl px-5 py-3.5 text-sm font-bold outline-none focus:border-[#FF6B2C] transition-all shadow-sm"
                        />
                      </div>
                    )}
                  </div>

                  {error && <p className="text-xs font-bold text-red-500 mb-4 -mt-4">{error}</p>}

                  <button
                    onClick={handleSendOtp}
                    disabled={loading || !phone}
                    className="w-full bg-gradient-to-r from-[#FF6B2C] to-[#E05520] text-white py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl shadow-[#FF6B2C]/20 hover:scale-[1.02] active:scale-[0.98] transition-all mb-8 disabled:opacity-60 disabled:scale-100"
                  >
                    {loading ? <><Loader2 size={18} className="animate-spin" />Sending OTP...</> : <>{tab === 'login' ? 'Get OTP' : 'Send OTP'}<ChevronRight size={18} /></>}
                  </button>
                </>
              ) : (
                <>
                  {/* Step 2 — OTP entry */}
                  <button onClick={() => { setStep('phone'); setError(''); setOtp(['', '', '', '', '', '']); confirmationRef.current = null; }} className="flex items-center gap-2 text-xs font-black text-gray-400 hover:text-[#FF6B2C] mb-6 transition-colors">
                    <ArrowLeft size={14} /> Change number
                  </button>

                  <div className="mb-8">
                    <div className="flex items-center gap-3 mb-2">
                      <div className="w-10 h-10 rounded-full bg-green-50 flex items-center justify-center shrink-0">
                        <CheckCircle2 size={20} className="text-green-500" />
                      </div>
                      <div>
                        <p className="text-sm font-black text-[#111827]">OTP sent to +91 {phone}</p>
                        <p className="text-[11px] font-bold text-gray-400">Enter the 6-digit code below</p>
                      </div>
                    </div>
                  </div>

                  {tab === 'register' && (
                    <div className="mb-6">
                      <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-1.5">Full Name *</label>
                      <input
                        value={name}
                        onChange={e => setName(e.target.value)}
                        placeholder="Enter your full name"
                        className="w-full border border-[#ECECEC] rounded-xl px-5 py-3.5 text-sm font-bold outline-none focus:border-[#FF6B2C] transition-all shadow-sm"
                      />
                    </div>
                  )}

                  {/* OTP boxes */}
                  <div className="mb-6">
                    <label className="text-[11px] font-black text-gray-400 uppercase tracking-wider block mb-3">Enter OTP</label>
                    <div className="flex gap-3 justify-between" onPaste={handleOtpPaste}>
                      {otp.map((digit, i) => (
                        <input
                          key={i}
                          ref={el => { otpRefs.current[i] = el; }}
                          type="tel"
                          maxLength={1}
                          value={digit}
                          onChange={e => handleOtpChange(i, e.target.value)}
                          onKeyDown={e => handleOtpKeyDown(i, e)}
                          className={`w-12 h-14 text-center text-xl font-black rounded-xl border-2 outline-none transition-all ${digit ? 'border-[#FF6B2C] bg-[#FFF3ED] text-[#FF6B2C]' : 'border-[#ECECEC] bg-white text-[#111827]'} focus:border-[#FF6B2C] focus:bg-[#FFF3ED]`}
                        />
                      ))}
                    </div>
                  </div>

                  {error && <p className="text-xs font-bold text-red-500 mb-4">{error}</p>}

                  <button
                    onClick={handleVerify}
                    disabled={loading || otpValue.length < OTP_LENGTH || (tab === 'register' && !name.trim())}
                    className="w-full bg-gradient-to-r from-[#FF6B2C] to-[#E05520] text-white py-4 rounded-xl font-black flex items-center justify-center gap-3 shadow-xl shadow-[#FF6B2C]/20 hover:scale-[1.02] active:scale-[0.98] transition-all mb-6 disabled:opacity-60 disabled:scale-100"
                  >
                    {loading ? <><Loader2 size={18} className="animate-spin" />{tab === 'login' ? 'Verifying...' : 'Creating Account...'}</> : <>{tab === 'login' ? 'Verify & Login' : 'Verify & Register'}<ChevronRight size={18} /></>}
                  </button>

                  {/* Resend */}
                  <div className="text-center">
                    {timer > 0 ? (
                      <p className="text-[11px] font-bold text-gray-400">Resend OTP in <span className="text-[#FF6B2C] font-black">{timer}s</span></p>
                    ) : (
                      <button onClick={handleResend} disabled={loading} className="flex items-center gap-2 mx-auto text-xs font-black text-[#FF6B2C] hover:underline disabled:opacity-50">
                        <RefreshCw size={12} /> Resend OTP
                      </button>
                    )}
                  </div>
                </>
              )}

              <div className="mt-auto pt-6">
                <p className="text-[11px] font-bold text-gray-400 text-center leading-relaxed">
                  By continuing, you agree to our{' '}
                  <a href="/terms" className="text-[#FF6B2C] hover:underline font-black uppercase">Terms & Conditions</a>
                  {' '}and{' '}
                  <a href="/privacy-policy" className="text-[#FF6B2C] hover:underline font-black uppercase">Privacy Policy</a>
                </p>
              </div>
            </div>
          </div>
        </div>

        <CheckoutTrustStrip />
      </Container>

      <Footer />

      {/* Invisible reCAPTCHA container — required by Firebase Phone Auth */}
      <div id="recaptcha-container" />
    </div>
  );
};

export default LoginPage;
