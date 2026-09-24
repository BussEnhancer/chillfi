# Real Device Test Checklist

| Feature | Reason (hardware-dependent) | Status |
|---------|------------------------------|--------|
| Real SMS OTP receipt | Emulator can't receive real SMS | UNTESTED — REAL DEVICE REQUIRED |
| Push notifications (FCM) delivery + tap-to-open | Needs real Google Play services / APNs | UNTESTED — REAL DEVICE REQUIRED |
| Voice search (microphone) | Emulator mic unreliable | UNTESTED — REAL DEVICE REQUIRED |
| GPS-based location accuracy | Emulator location is simulated | UNTESTED — REAL DEVICE REQUIRED |
| Biometric login (local_auth) | Needs real fingerprint/FaceID hardware | UNTESTED — REAL DEVICE REQUIRED |
| Camera (image_picker) for profile/upload | Emulator camera is fake feed | UNTESTED — REAL DEVICE REQUIRED |
| Background/app-switch behavior | OS-level scheduling differs from emulator | UNTESTED — REAL DEVICE REQUIRED |
| Real payment (PhonePe/UPI app switch) | Needs installed UPI apps | UNTESTED — REAL DEVICE REQUIRED |
| App icon / splash on real launcher | Emulator rendering can differ from OEM skins | UNTESTED — REAL DEVICE REQUIRED |
