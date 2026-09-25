import React, { useState } from 'react';
import { ShieldOff, Phone, KeyRound, Trash2, CheckCircle, AlertTriangle, ChevronRight, Loader2 } from 'lucide-react';
import { api } from '../../utils/api';
import { friendlyError } from '../../utils/api';
import { useStoreContact } from '../../utils/useStoreContact';

type Step = 'phone' | 'otp' | 'confirm' | 'done';

const DeleteAccountPage: React.FC = () => {
  const contact = useStoreContact();
  const [step, setStep] = useState<Step>('phone');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const sendOtp = async () => {
    if (!/^\d{10}$/.test(phone)) { setError('Enter a valid 10-digit mobile number'); return; }
    setLoading(true); setError('');
    try {
      await api('/auth/send-otp', 'POST', { phone, purpose: 'login' });
      setStep('otp');
    } catch (e: any) {
      setError(friendlyError(e, 'Failed to send OTP. Please try again.'));
    } finally { setLoading(false); }
  };

  const verifyOtp = async () => {
    if (otp.length !== 6) { setError('Enter the 6-digit OTP'); return; }
    setStep('confirm');
    setError('');
  };

  const deleteAccount = async () => {
    setLoading(true); setError('');
    try {
      await api('/profile/request-delete', 'POST', { phone, otp });
      setStep('done');
    } catch (e: any) {
      setError(friendlyError(e, 'Deletion failed. OTP may have expired — please start over.'));
      setStep('phone');
      setOtp('');
    } finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen bg-[#F9F9F9] font-['Poppins'] flex flex-col">
      {/* Header */}
      <header className="bg-white border-b border-[#ECECEC] px-6 py-4 flex items-center gap-3">
        <div className="w-8 h-8 rounded-full bg-orange-50 flex items-center justify-center">
          <span className="text-lg font-black text-[#FF6B2C]">C</span>
        </div>
        <span className="text-base font-black text-[#111827]">ChillFi</span>
      </header>

      <div className="flex-1 flex items-start justify-center px-4 py-12">
        <div className="w-full max-w-md">

          {step !== 'done' && (
            <>
              {/* Title */}
              <div className="text-center mb-8">
                <div className="w-16 h-16 bg-red-50 rounded-2xl flex items-center justify-center mx-auto mb-4">
                  <ShieldOff size={28} className="text-red-500" />
                </div>
                <h1 className="text-2xl font-black text-[#111827] mb-2">Delete Your Account</h1>
                <p className="text-sm font-bold text-gray-400 leading-relaxed">
                  This will permanently delete your account and all associated data including orders, wishlist, reviews, and saved addresses.
                </p>
              </div>

              {/* Warning box */}
              <div className="bg-amber-50 border border-amber-200 rounded-2xl p-4 mb-6 flex gap-3">
                <AlertTriangle size={18} className="text-amber-500 shrink-0 mt-0.5" />
                <div>
                  <p className="text-xs font-black text-amber-700 mb-1">This action cannot be undone</p>
                  <ul className="text-xs font-bold text-amber-600 space-y-0.5 list-disc list-inside">
                    <li>All personal data will be permanently erased</li>
                    <li>Order history will be anonymised</li>
                    <li>Active orders will not be affected</li>
                  </ul>
                </div>
              </div>
            </>
          )}

          {/* Step: Phone */}
          {step === 'phone' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <div className="flex items-center gap-2 mb-5">
                <div className="w-7 h-7 rounded-full bg-[#FF6B2C] flex items-center justify-center">
                  <span className="text-white text-xs font-black">1</span>
                </div>
                <h2 className="text-sm font-black text-[#111827]">Verify your mobile number</h2>
              </div>
              <div className="flex gap-2 mb-4">
                <div className="flex items-center gap-2 bg-[#F9F9F9] border border-[#ECECEC] rounded-xl px-3 py-3 shrink-0">
                  <Phone size={14} className="text-gray-400" />
                  <span className="text-sm font-bold text-gray-500">+91</span>
                </div>
                <input
                  type="tel"
                  maxLength={10}
                  value={phone}
                  onChange={e => setPhone(e.target.value.replace(/\D/g, ''))}
                  placeholder="10-digit mobile number"
                  className="flex-1 bg-[#F9F9F9] border border-[#ECECEC] rounded-xl px-4 py-3 text-sm font-bold text-[#111827] outline-none focus:border-[#FF6B2C] transition-colors"
                />
              </div>
              {error && <p className="text-xs font-bold text-red-500 mb-3">{error}</p>}
              <button
                onClick={sendOtp}
                disabled={loading || phone.length !== 10}
                className="w-full bg-[#FF6B2C] text-white py-3.5 rounded-xl font-black text-sm hover:bg-[#E05520] disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2 active:scale-[0.98]"
              >
                {loading ? <><Loader2 size={16} className="animate-spin" /> Sending OTP…</> : <>Send OTP <ChevronRight size={16} /></>}
              </button>
            </div>
          )}

          {/* Step: OTP */}
          {step === 'otp' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <div className="flex items-center gap-2 mb-5">
                <div className="w-7 h-7 rounded-full bg-[#FF6B2C] flex items-center justify-center">
                  <span className="text-white text-xs font-black">2</span>
                </div>
                <h2 className="text-sm font-black text-[#111827]">Enter OTP</h2>
              </div>
              <p className="text-xs font-bold text-gray-400 mb-4">OTP sent to +91 {phone}</p>
              <div className="flex items-center gap-2 bg-[#F9F9F9] border border-[#ECECEC] rounded-xl px-4 py-3 mb-4">
                <KeyRound size={14} className="text-gray-400 shrink-0" />
                <input
                  type="tel"
                  maxLength={6}
                  value={otp}
                  onChange={e => setOtp(e.target.value.replace(/\D/g, ''))}
                  placeholder="6-digit OTP"
                  className="flex-1 bg-transparent text-sm font-bold text-[#111827] outline-none tracking-widest"
                  autoFocus
                />
              </div>
              {error && <p className="text-xs font-bold text-red-500 mb-3">{error}</p>}
              <button
                onClick={verifyOtp}
                disabled={otp.length !== 6}
                className="w-full bg-[#FF6B2C] text-white py-3.5 rounded-xl font-black text-sm hover:bg-[#E05520] disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2 active:scale-[0.98]"
              >
                Verify OTP <ChevronRight size={16} />
              </button>
              <button onClick={() => { setStep('phone'); setOtp(''); setError(''); }} className="w-full mt-3 text-xs font-bold text-gray-400 hover:text-[#FF6B2C] transition-colors">
                ← Change number
              </button>
            </div>
          )}

          {/* Step: Confirm */}
          {step === 'confirm' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-6">
              <div className="flex items-center gap-2 mb-5">
                <div className="w-7 h-7 rounded-full bg-red-500 flex items-center justify-center">
                  <span className="text-white text-xs font-black">3</span>
                </div>
                <h2 className="text-sm font-black text-[#111827]">Confirm Deletion</h2>
              </div>
              <div className="bg-[#F9F9F9] rounded-xl p-4 mb-5">
                <p className="text-xs font-bold text-gray-500">Deleting account for</p>
                <p className="text-sm font-black text-[#111827] mt-1">+91 {phone}</p>
              </div>
              <p className="text-xs font-bold text-gray-500 mb-5 leading-relaxed">
                By tapping <span className="text-red-500">Delete My Account</span>, you agree that all your data will be permanently removed from ChillFi's servers. This cannot be reversed.
              </p>
              {error && <p className="text-xs font-bold text-red-500 mb-3">{error}</p>}
              <button
                onClick={deleteAccount}
                disabled={loading}
                className="w-full bg-red-500 text-white py-3.5 rounded-xl font-black text-sm hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2"
              >
                <Trash2 size={16} />
                {loading ? <><Loader2 size={16} className="animate-spin" /> Deleting account…</> : 'Delete My Account'}
              </button>
              <button onClick={() => setStep('otp')} className="w-full mt-3 text-xs font-bold text-gray-400 hover:text-[#111827] transition-colors">
                ← Go back
              </button>
            </div>
          )}

          {/* Step: Done */}
          {step === 'done' && (
            <div className="bg-white rounded-2xl border border-[#ECECEC] shadow-sm p-8 text-center">
              <div className="w-16 h-16 bg-green-50 rounded-2xl flex items-center justify-center mx-auto mb-5">
                <CheckCircle size={32} className="text-green-500" />
              </div>
              <h2 className="text-xl font-black text-[#111827] mb-3">Account Deleted</h2>
              <p className="text-sm font-bold text-gray-400 leading-relaxed mb-6">
                Your ChillFi account and all associated data have been permanently deleted. We're sorry to see you go.
              </p>
              <div className="bg-[#F9F9F9] rounded-xl p-4 text-left mb-6">
                <p className="text-xs font-black text-[#111827] mb-2">What was deleted:</p>
                {['Account profile & personal info', 'Wishlist & saved addresses', 'Reviews & ratings', 'Notification preferences', 'Login sessions & device tokens'].map((item, i) => (
                  <div key={i} className="flex items-center gap-2 py-1">
                    <CheckCircle size={12} className="text-green-500 shrink-0" />
                    <span className="text-xs font-bold text-gray-500">{item}</span>
                  </div>
                ))}
              </div>
              <p className="text-xs font-bold text-gray-400">
                Questions? Email us at{' '}
                {contact.email
                  ? <a href={`mailto:${contact.email}`} className="text-[#FF6B2C] hover:underline">{contact.email}</a>
                  : <a href="/contact" className="text-[#FF6B2C] hover:underline">contact us</a>}
              </p>
            </div>
          )}

          {/* Steps indicator */}
          {step !== 'done' && (
            <div className="flex items-center justify-center gap-2 mt-6">
              {(['phone', 'otp', 'confirm'] as Step[]).map((s, i) => (
                <div key={s} className={`h-1.5 rounded-full transition-all ${step === s ? 'w-8 bg-[#FF6B2C]' : ['phone', 'otp', 'confirm'].indexOf(step) > i ? 'w-4 bg-[#FF6B2C]/40' : 'w-4 bg-[#ECECEC]'}`} />
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Footer */}
      <footer className="border-t border-[#ECECEC] bg-white px-6 py-4 text-center">
        <p className="text-xs font-bold text-gray-400">
          © {new Date().getFullYear()} ChillFi · <a href="/privacy-policy" target="_blank" rel="noopener noreferrer" className="hover:text-[#FF6B2C]">Privacy Policy</a> · <a href="/terms" target="_blank" rel="noopener noreferrer" className="hover:text-[#FF6B2C]">Terms</a>
        </p>
      </footer>
    </div>
  );
};

export default DeleteAccountPage;
