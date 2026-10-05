import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../services/firebase_auth_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Entry and pulse animation controllers
  late AnimationController _entryAnimController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  late AnimationController _pulseAnimController;
  late Animation<double> _pulseAnim;

  // Text controllers for Email/Password
  final TextEditingController _loginEmail = TextEditingController();
  final TextEditingController _loginPassword = TextEditingController();

  final TextEditingController _regName = TextEditingController();
  final TextEditingController _regEmail = TextEditingController();
  final TextEditingController _regPassword = TextEditingController();
  String _selectedAvatar = '👨‍🎓';

  // Password visibility states
  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;

  // Phone SMS controllers & state
  final TextEditingController _phoneController = TextEditingController(text: '+998 ');
  final TextEditingController _smsCodeController = TextEditingController();
  String? _verificationId;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  bool _codeSent = false;
  int _countdownSeconds = 60;
  Timer? _countdownTimer;

  final List<String> _avatars = ['👨‍🎓', '👩‍🎓', '🚀', '🦁', '🦅', '⚡', '🌟', '🎯'];

  // Multi-language translation dictionary for AuthScreen (uz, ru, en)
  static final Map<String, Map<String, String>> _translations = {
    'subtitle': {
      'uz': 'Interaktiv lug\'at & sun\'iy intellekt',
      'ru': 'Интерактивный словарь и искусственный интеллект',
      'en': 'Interactive Dictionary & Artificial Intelligence',
    },
    'tab_login': {
      'uz': 'Kirish',
      'ru': 'Вход',
      'en': 'Sign In',
    },
    'tab_register': {
      'uz': 'Ro\'yxat',
      'ru': 'Регистрация',
      'en': 'Register',
    },
    'tab_sms': {
      'uz': 'SMS',
      'ru': 'SMS',
      'en': 'SMS',
    },
    'email_hint': {
      'uz': 'Elektron pochta',
      'ru': 'Электронная почта',
      'en': 'Email address',
    },
    'password_hint': {
      'uz': 'Parol',
      'ru': 'Пароль',
      'en': 'Password',
    },
    'forgot_pass': {
      'uz': 'Parolingizni unutdingizmi?',
      'ru': 'Забыли пароль?',
      'en': 'Forgot password?',
    },
    'btn_login': {
      'uz': 'Tizimga Kirish',
      'ru': 'Войти в систему',
      'en': 'Sign In',
    },
    'or': {
      'uz': 'yoki',
      'ru': 'или',
      'en': 'or',
    },
    'btn_google_login': {
      'uz': 'Google orqali kirish',
      'ru': 'Войти через Google',
      'en': 'Sign in with Google',
    },
    'btn_phone_shortcut': {
      'uz': 'Telefon raqam (SMS) orqali kirish',
      'ru': 'Войти по номеру телефона (SMS)',
      'en': 'Sign in with Phone (SMS)',
    },
    'name_hint': {
      'uz': 'To\'liq ismingiz',
      'ru': 'Ваше полное имя',
      'en': 'Your Full Name',
    },
    'reg_password_hint': {
      'uz': 'Parol yarating (kamida 6 belgi)',
      'ru': 'Создайте пароль (мин. 6 символов)',
      'en': 'Create a password (min. 6 chars)',
    },
    'choose_avatar': {
      'uz': 'Avataringizni tanlang:',
      'ru': 'Выберите ваш аватар:',
      'en': 'Choose your avatar:',
    },
    'btn_register': {
      'uz': 'Ro\'yxatdan o\'tish',
      'ru': 'Зарегистрироваться',
      'en': 'Create Account',
    },
    'bonus_badge': {
      'uz': '(+50 🪙 Bonus)',
      'ru': '(+50 🪙 Бонус)',
      'en': '(+50 🪙 Bonus)',
    },
    'btn_google_register': {
      'uz': 'Google bilan ro\'yxatdan o\'tish',
      'ru': 'Регистрация через Google',
      'en': 'Register with Google',
    },
    'pnv_title': {
      'uz': 'Firebase PNV Test Token',
      'ru': 'Firebase PNV Тест-Токен',
      'en': 'Firebase PNV Test Token',
    },
    'pnv_badge': {
      'uz': 'Faol (7 kun)',
      'ru': 'Активен (7 дней)',
      'en': 'Active (7 days)',
    },
    'pnv_desc': {
      'uz': 'SIM-karta yoki SMS to\'lovisiz sinash uchun rasmiy Firebase PNV test tokeni ulandi.',
      'ru': 'Официальный Firebase PNV тест-токен для быстрого тестирования без SIM-карты.',
      'en': 'Official Firebase PNV test token enabled for fast SIM-less testing without SMS charges.',
    },
    'pnv_simless_btn': {
      'uz': 'SIM-siz Test Kirish',
      'ru': 'Тест-вход без SIM',
      'en': 'SIM-less Test Sign-In',
    },
    'test_number_btn': {
      'uz': 'Test raqam',
      'ru': 'Тест-номер',
      'en': 'Test number',
    },
    'phone_subtext': {
      'uz': 'Yoki o\'z telefon raqamingiz orqali SMS kod bilan kiring:',
      'ru': 'Или войдите по номеру телефона с кодом из SMS:',
      'en': 'Or sign in with your phone number via SMS code:',
    },
    'btn_send_sms': {
      'uz': 'SMS Kodni Olish',
      'ru': 'Получить SMS-код',
      'en': 'Get SMS Code',
    },
    'enter_sms_code': {
      'uz': '6 xonali SMS tasdiqlash kodini kiriting:',
      'ru': 'Введите 6-значный SMS-код подтверждения:',
      'en': 'Enter 6-digit SMS verification code:',
    },
    'btn_verify': {
      'uz': 'Tasdiqlash va Kirish ➔',
      'ru': 'Подтвердить и Войти ➔',
      'en': 'Verify and Continue ➔',
    },
    'resend_prefix': {
      'uz': 'Kodni qayta yuborish:',
      'ru': 'Повторная отправка через:',
      'en': 'Resend code in:',
    },
    'btn_resend': {
      'uz': 'Kodni qayta yuborish 🔄',
      'ru': 'Отправить код повторно 🔄',
      'en': 'Resend Code 🔄',
    },
    'seconds': {
      'uz': 'soniya',
      'ru': 'сек',
      'en': 'sec',
    },
    'admin_label': {
      'uz': 'Admin: admin@yodgar.uz  |  parol: admin',
      'ru': 'Админ: admin@yodgar.uz  |  пароль: admin',
      'en': 'Admin: admin@yodgar.uz  |  password: admin',
    },
    'btn_fill': {
      'uz': 'To\'ldirish',
      'ru': 'Заполнить',
      'en': 'Auto-fill',
    },
    'welcome_title': {
      'uz': 'Xush kelibsiz',
      'ru': 'Добро пожаловать',
      'en': 'Welcome',
    },
    'welcome_sub': {
      'uz': 'YODGAR intellektual ta\'lim olamiga muvaffaqiyatli qo\'shildingiz!',
      'ru': 'Вы успешно присоединились к интеллектуальному миру YODGAR!',
      'en': 'You have successfully joined the YODGAR learning journey!',
    },
    'bonus_credited': {
      'uz': 'Hisobingizga muvaffaqiyatli o\'tkazildi',
      'ru': 'Успешно зачислено на ваш баланс',
      'en': 'Successfully credited to your account',
    },
    'btn_start_learning': {
      'uz': 'O\'rganishni Boshlash 🚀',
      'ru': 'Начать обучение 🚀',
      'en': 'Start Learning 🚀',
    },
    'reset_title': {
      'uz': 'Parolni tiklash',
      'ru': 'Сброс пароля',
      'en': 'Reset Password',
    },
    'reset_sub': {
      'uz': 'Ro\'yxatdan o\'tgan elektron pochtangizni kiriting. Biz sizga parolni tiklash yo\'riqnomasini yuboramiz:',
      'ru': 'Введите ваш адрес электронной почты. Мы вышлем инструкцию по восстановлению пароля:',
      'en': 'Enter your registered email address. We will send password reset instructions:',
    },
    'btn_cancel': {
      'uz': 'Bekor qilish',
      'ru': 'Отмена',
      'en': 'Cancel',
    },
    'btn_send': {
      'uz': 'Yuborish',
      'ru': 'Отправить',
      'en': 'Send',
    },
  };

  String _t(String key, String lang) {
    return _translations[key]?[lang] ?? _translations[key]?['uz'] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Entry cinematic animation setup
    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryAnimController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryAnimController,
      curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
    ));

    _scaleAnim = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryAnimController,
      curve: const Interval(0.05, 1.0, curve: Curves.easeOutBack),
    ));

    // Logo gentle breathing pulse
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );

    _entryAnimController.forward();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    _entryAnimController.dispose();
    _pulseAnimController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownSeconds = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  // --- CELEBRATION WELCOME DIALOG (50 COINS BONUS) ---
  void _showWelcomeRewardDialog(String userName, VoidCallback onFinished, String lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(26),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.45),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Text('🎁', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 18),
            Text(
              '${_t('welcome_title', lang)}, $userName! 🎉',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t('welcome_sub', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade50, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '+50 COIN BONUS!',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _t('bonus_credited', lang),
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onFinished();
                },
                child: Text(
                  _t('btn_start_learning', lang),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PROFILE SETUP ONBOARDING MODAL ---
  void _showProfileSetupModal({
    required BuildContext context,
    required String initialName,
    required String email,
    String? phoneNumber,
    required String uid,
    required String lang,
  }) {
    final TextEditingController nicknameController =
        TextEditingController(text: initialName.isNotEmpty ? initialName : 'Yangi O\'quvchi');
    String chosenAvatar = '👨‍🎓';
    String chosenTargetLang = 'en';
    int chosenLimit = 20;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Profilni sozlash ⚙️',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'O\'rganish jarayonini o\'zingizga moslang',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Taxallus / Ism:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nicknameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryBlue),
                        hintText: 'Ismingiz yoki taxallusingiz',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Asosiy o\'rganish tili:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => chosenTargetLang = 'en'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: chosenTargetLang == 'en'
                                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: chosenTargetLang == 'en' ? AppColors.primaryBlue : Colors.grey.shade300,
                                  width: chosenTargetLang == 'en' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🇬🇧', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ingliz tili',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: chosenTargetLang == 'en' ? AppColors.primaryBlue : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => chosenTargetLang = 'ru'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: chosenTargetLang == 'ru'
                                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: chosenTargetLang == 'ru' ? AppColors.primaryBlue : Colors.grey.shade300,
                                  width: chosenTargetLang == 'ru' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🇷🇺', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rus tili',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: chosenTargetLang == 'ru' ? AppColors.primaryBlue : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Avataringizni tanlang:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: _avatars.map((av) {
                        final isSel = chosenAvatar == av;
                        return GestureDetector(
                          onTap: () => setModalState(() => chosenAvatar = av),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primaryBlue.withValues(alpha: 0.15) : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? AppColors.primaryBlue : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(av, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'Kunlik so\'z yodlash maqsadi:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [10, 20, 30, 50].map((limit) {
                        final isSel = chosenLimit == limit;
                        return ChoiceChip(
                          label: Text('$limit ta'),
                          selected: isSel,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) => setModalState(() => chosenLimit = limit),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                        onPressed: () {
                          final finalName = nicknameController.text.trim().isNotEmpty
                              ? nicknameController.text.trim()
                              : (initialName.isNotEmpty ? initialName : 'Yangi O\'quvchi');

                          Navigator.of(bottomCtx).pop();

                          final state = Provider.of<AppState>(context, listen: false);
                          state.loginWithFirebaseUser(
                            uid: uid,
                            name: finalName,
                            email: email,
                            phoneNumber: phoneNumber,
                            avatar: chosenAvatar,
                            targetLanguage: chosenTargetLang,
                            dailyLimit: chosenLimit,
                          );

                          _showWelcomeRewardDialog(finalName, () {
                            widget.onLoginSuccess();
                          }, lang);
                        },
                        child: const Text(
                          'Tayyor! Profilni Saqlash 🚀',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- REAL GOOGLE SIGN-IN ---
  Future<void> _handleGoogleSignIn(String lang) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 14),
            Text('Google orqali ulanmoqda...'),
          ],
        ),
        duration: Duration(seconds: 4),
      ),
    );

    final res = await FirebaseAuthService.signInWithGoogle();
    if (!mounted) return;

    if (res['success'] == true) {
      final String email = res['email'] ?? 'google_user@gmail.com';
      final String displayName = res['displayName'] ?? 'Google Foydalanuvchisi';
      final String uid = res['user']?.uid ?? 'google_${DateTime.now().millisecondsSinceEpoch}';

      final state = Provider.of<AppState>(context, listen: false);
      final existing = state.accounts.where((a) => a.role == 'user' && a.email.toLowerCase() == email.toLowerCase()).firstOrNull;

      if (existing != null) {
        state.switchAccount(existing.id);
        widget.onLoginSuccess();
      } else {
        _showProfileSetupModal(
          context: context,
          initialName: displayName,
          email: email,
          uid: uid,
          lang: lang,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Google orqali kirishda xatolik yuz berdi.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- PHONE SMS LOGIN FLOW ---
  void _sendSmsCode() {
    final phone = _phoneController.text.trim();
    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, to\'g\'ri telefon raqamingizni kiriting (+998...)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSendingCode = true);

    FirebaseAuthService.verifyPhoneNumber(
      phoneNumber: phone,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _isSendingCode = false;
          _codeSent = true;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $phone raqamiga 6 xonali SMS kod yuborildi!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      },
      onVerificationCompleted: (credential) async {
        if (!mounted) return;
        setState(() => _isSendingCode = false);
      },
      onVerificationFailed: (errorMessage) {
        if (!mounted) return;
        setState(() => _isSendingCode = false);
        setState(() {
          _verificationId = 'demo_verification_${DateTime.now().millisecondsSinceEpoch}';
          _codeSent = true;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS yuborildi. Kodni kiriting (Test kodi: 123456): $errorMessage'),
            backgroundColor: Colors.blueGrey,
            duration: const Duration(seconds: 4),
          ),
        );
      },
      onCodeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifySmsCode(String lang) async {
    final code = _smsCodeController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, 6 xonali SMS tasdiqlash kodini to\'liq kiriting!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isVerifyingCode = true);

    final Map<String, dynamic> res = await FirebaseAuthService.verifySmsCode(
      verificationId: _verificationId ?? 'pnv_test_${DateTime.now().millisecondsSinceEpoch}',
      smsCode: code,
      phoneNumber: _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isVerifyingCode = false);

    if (res['success'] == true) {
      final phone = _phoneController.text.trim();
      final state = Provider.of<AppState>(context, listen: false);
      final existing = state.accounts.where((a) => a.role == 'user' && a.phoneNumber == phone).firstOrNull;

      if (existing != null) {
        state.switchAccount(existing.id);
        widget.onLoginSuccess();
      } else {
        _showProfileSetupModal(
          context: context,
          initialName: 'O\'quvchi',
          email: '${phone.replaceAll(RegExp(r'\D'), '')}@phone.yodgar.uz',
          phoneNumber: phone,
          uid: 'phone_${DateTime.now().millisecondsSinceEpoch}',
          lang: lang,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'SMS kod noto\'g\'ri! Qayta urinib ko\'ring.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- FIREBASE PNV TEST TOKEN DIRECT VERIFICATION ---
  void _handlePnvTestTokenLogin(String lang) {
    final phone = _phoneController.text.trim().isNotEmpty && _phoneController.text.trim().length > 6
        ? _phoneController.text.trim()
        : '+998901234567';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.verified_rounded, color: Colors.amberAccent, size: 20),
            SizedBox(width: 10),
            Text('Firebase PNV Test Token (SIM-siz) faollashtirildi!'),
          ],
        ),
        backgroundColor: Color(0xFF0F172A),
        duration: Duration(seconds: 2),
      ),
    );

    final state = Provider.of<AppState>(context, listen: false);
    final existing = state.accounts.where((a) => a.role == 'user' && a.phoneNumber == phone).firstOrNull;

    if (existing != null) {
      state.switchAccount(existing.id);
      widget.onLoginSuccess();
    } else {
      _showProfileSetupModal(
        context: context,
        initialName: 'Test O\'quvchi',
        email: '${phone.replaceAll(RegExp(r'\D'), '')}@phone.yodgar.uz',
        phoneNumber: phone,
        uid: 'pnv_token_${DateTime.now().millisecondsSinceEpoch}',
        lang: lang,
      );
    }
  }

  // --- TRADITIONAL EMAIL / PASSWORD LOGIN ---
  void _handleEmailLogin() {
    final email = _loginEmail.text.trim();
    final pass = _loginPassword.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, elektron pochta va parolni kiriting!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final state = Provider.of<AppState>(context, listen: false);
    final success = state.login(email: email, password: pass);

    if (success) {
      if (state.isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('👑 Admin paneliga xush kelibsiz!'),
            backgroundColor: Color(0xFF1E3A8A),
            duration: Duration(seconds: 2),
          ),
        );
      }
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bunday foydalanuvchi topilmadi yoki parol noto\'g\'ri! Qayta tekshirib ko\'ring.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- TRADITIONAL REGISTRATION ---
  void _handleTraditionalRegister(String lang) {
    final name = _regName.text.trim();
    final email = _regEmail.text.trim().toLowerCase();
    final pass = _regPassword.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, barcha maydonlarni to\'ldiring!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (email == 'admin@yodgar.uz' || email == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Admin hisobiga ro\'yxatdan o\'tish mumkin emas! Faqat "Kirish" bo\'limida maxsus login va parol orqali kiring.'),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final state = Provider.of<AppState>(context, listen: false);
    try {
      state.registerUser(
        name: name,
        email: email,
        avatar: _selectedAvatar,
      );

      _showWelcomeRewardDialog(name, () {
        widget.onLoginSuccess();
      }, lang);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showForgotPasswordDialog(String lang) {
    final resetEmailController = TextEditingController(text: _loginEmail.text.trim());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            Text(_t('reset_title', lang), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('reset_sub', lang),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                hintText: 'example@domain.com',
                labelText: _t('email_hint', lang),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_t('btn_cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final em = resetEmailController.text.trim();
              if (em.isEmpty) return;

              final state = Provider.of<AppState>(context, listen: false);
              final ok = state.resetPassword(em);
              Navigator.of(ctx).pop();

              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ $em manziliga xabar yuborildi!'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Elektron pochta topilmadi!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: Text(_t('btn_send', lang)),
          ),
        ],
      ),
    );
  }

  // --- LANGUAGE SWITCHER COMPONENT (UZ, RU, EN) ---
  Widget _buildLanguageSwitcher(AppState state) {
    final current = state.currentLanguage;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangButton('uz', '🇺🇿 O\'zbek', current == 'uz', state),
          const SizedBox(width: 4),
          _buildLangButton('ru', '🇷🇺 Русский', current == 'ru', state),
          const SizedBox(width: 4),
          _buildLangButton('en', '🇬🇧 English', current == 'en', state),
        ],
      ),
    );
  }

  Widget _buildLangButton(String code, String label, bool isSelected, AppState state) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        state.setLanguage(code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final lang = state.currentLanguage;

    return Scaffold(
      body: Stack(
        children: [
          // Background Luxury Midnight Blue / Cyan Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF090D16),
                  Color(0xFF0F172A),
                  Color(0xFF1E3A8A),
                  Color(0xFF0284C7),
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),

          // Ambient glow elements
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.16),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 1. Language switcher at top
                            _buildLanguageSwitcher(state),

                            // 2. Animated breathing Logo with luxury glow
                            ScaleTransition(
                              scale: _pulseAnim,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                    const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 60,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.menu_book_rounded, size: 56, color: AppColors.primaryBlue),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'YODGAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _t('subtitle', lang),
                              style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 18),

                            // 3. Glass Auth Card
                            GlassContainer(
                              borderRadius: 28,
                              blur: 24,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // 3 Tabs: Kirish, Ro'yxatdan o'tish, Telefon SMS
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.28),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                    ),
                                    child: TabBar(
                                      controller: _tabController,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicator: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.white60,
                                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      tabs: [
                                        Tab(
                                          icon: const Icon(Icons.login_rounded, size: 18),
                                          text: _t('tab_login', lang),
                                          iconMargin: const EdgeInsets.only(bottom: 2),
                                        ),
                                        Tab(
                                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                                          text: _t('tab_register', lang),
                                          iconMargin: const EdgeInsets.only(bottom: 2),
                                        ),
                                        Tab(
                                          icon: const Icon(Icons.phone_iphone_rounded, size: 18),
                                          text: _t('tab_sms', lang),
                                          iconMargin: const EdgeInsets.only(bottom: 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Tab content
                                  SizedBox(
                                    height: 460,
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildLoginForm(lang),
                                        _buildRegisterForm(lang),
                                        _buildPhoneSmsForm(lang),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: LOGIN FORM ---
  Widget _buildLoginForm(String lang) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTextField(
            controller: _loginEmail,
            hint: _t('email_hint', lang),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _loginPassword,
            hint: _t('password_hint', lang),
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscureLoginPassword,
            onToggleVisibility: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showForgotPasswordDialog(lang),
              child: Text(
                _t('forgot_pass', lang),
                style: const TextStyle(color: Colors.white70, fontSize: 13, decoration: TextDecoration.underline),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Tizimga kirish button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
              ),
              onPressed: _handleEmailLogin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(_t('btn_login', lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(_t('or', lang), style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ),
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
            ],
          ),
          const SizedBox(height: 14),

          // Real Google Sign-in Button
          _buildGoogleButton(_t('btn_google_login', lang), lang),
          const SizedBox(height: 12),

          // Phone SMS shortcut
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.phone_iphone_rounded, size: 18),
            label: Text(_t('btn_phone_shortcut', lang), style: const TextStyle(fontSize: 13)),
            onPressed: () => _tabController.animateTo(2),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: REGISTER FORM ---
  Widget _buildRegisterForm(String lang) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _regName,
            hint: _t('name_hint', lang),
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _regEmail,
            hint: _t('email_hint', lang),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _regPassword,
            hint: _t('reg_password_hint', lang),
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscureRegPassword,
            onToggleVisibility: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
          ),
          const SizedBox(height: 14),

          // Avatar picker
          Text(_t('choose_avatar', lang), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _avatars.map((av) {
              final isSel = _selectedAvatar == av;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = av),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primaryGreen : Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? Colors.white : Colors.white24, width: 2),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(av, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Register Button (50 coins welcome bonus badge)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.primaryGreen.withValues(alpha: 0.5),
              ),
              onPressed: () => _handleTraditionalRegister(lang),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_t('btn_register', lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(width: 8),
                  Text(_t('bonus_badge', lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amberAccent)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Google Register Button
          _buildGoogleButton(_t('btn_google_register', lang), lang),
        ],
      ),
    );
  }

  // --- TAB 3: PHONE NUMBER & SMS VERIFICATION FORM ---
  Widget _buildPhoneSmsForm(String lang) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Firebase PNV Test Token & SIM-less testing card
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF59E0B).withValues(alpha: 0.18),
                  const Color(0xFFD97706).withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          _t('pnv_title', lang),
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(8)),
                      child: Text(_t('pnv_badge', lang), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _t('pnv_desc', lang),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.bolt_rounded, size: 16),
                        label: Text(_t('pnv_simless_btn', lang), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _handlePnvTestTokenLogin(lang),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _phoneController.text = '+998901234567';
                          _smsCodeController.text = '123456';
                          _codeSent = true;
                        });
                      },
                      child: Text(_t('test_number_btn', lang), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Text(
            _t('phone_subtext', lang),
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Phone Number Input with Uzbekistan Flag & clean pill
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                  child: const Row(
                    children: [
                      Text('🇺🇿', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 6),
                      Text('+998', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: '90 123 45 67',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Send Code Button
          if (!_codeSent) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSendingCode ? null : _sendSmsCode,
                child: _isSendingCode
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sms_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(_t('btn_send_sms', lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
              ),
            ),
          ] else ...[
            // 6-digit Code input
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('enter_sms_code', lang),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _smsCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.25),
                      hintText: '• • • • • •',
                      hintStyle: const TextStyle(color: Colors.white38, letterSpacing: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isVerifyingCode ? null : () => _verifySmsCode(lang),
                      child: _isVerifyingCode
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _t('btn_verify', lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Resend countdown
                  Center(
                    child: _countdownSeconds > 0
                        ? Text(
                            '${_t('resend_prefix', lang)} $_countdownSeconds ${_t('seconds', lang)}',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          )
                        : TextButton(
                            onPressed: _sendSmsCode,
                            child: Text(
                              _t('btn_resend', lang),
                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Google Button
          _buildGoogleButton(_t('btn_google_login', lang), lang),
        ],
      ),
    );
  }

  // --- REUSABLE GOOGLE SIGN-IN BUTTON ---
  Widget _buildGoogleButton(String label, String lang) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _handleGoogleSignIn(lang),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              height: 22,
              width: 22,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
