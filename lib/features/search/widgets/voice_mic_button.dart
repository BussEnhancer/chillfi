import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceMicButton extends StatefulWidget {
  final ValueChanged<String>? onResult;
  const VoiceMicButton({super.key, this.onResult});

  @override
  State<VoiceMicButton> createState() => _VoiceMicButtonState();
}

class _VoiceMicButtonState extends State<VoiceMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _available = false;
  String _status = 'Tap the mic to start';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _status = 'Error: ${e.errorMsg}';
        });
      },
    );
    if (mounted) setState(() => _available = available);
  }

  Future<void> _toggleListening() async {
    if (!_available) {
      setState(() => _status = 'Speech recognition not available');
      return;
    }
    if (_isListening) {
      await _speech.stop();
      setState(() { _isListening = false; _status = 'Tap the mic to start'; });
      return;
    }

    setState(() { _isListening = true; _status = 'Listening...'; });
    void onResult(SpeechRecognitionResult result) {
      if (!mounted) return;
      if (result.finalResult && result.recognizedWords.isNotEmpty) {
        setState(() { _isListening = false; _status = result.recognizedWords; });
        widget.onResult?.call(result.recognizedWords);
      }
    }
    await _speech.listen(
      onResult: onResult,
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        localeId: 'en_IN',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (_isListening) ...[
                    _buildRipple(1.0 + (_controller.value * 0.5), 0.2 - (_controller.value * 0.2)),
                    _buildRipple(1.3 + (_controller.value * 0.6), 0.1 - (_controller.value * 0.1)),
                  ],
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isListening
                            ? [Colors.red.shade400, Colors.red.shade700]
                            : [AppColors.secondaryPurple, const Color(0xFFA166FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : AppColors.secondaryPurple).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 36.sp,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          _status,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            color: _isListening ? Colors.red : AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRipple(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 80.r,
        height: 80.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withOpacity(opacity > 0 ? opacity : 0),
        ),
      ),
    );
  }
}
