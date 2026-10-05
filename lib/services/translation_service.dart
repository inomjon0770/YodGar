import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/vocabulary_data.dart';

class TranslationService {
  // Built-in comprehensive tri-lingual dictionary & phrasebook
  static final Map<String, Map<String, String>> _dictionary = {
    // Greetings & Common courtesies
    'hello': {'uz': 'salom', 'ru': 'привет'},
    'hi': {'uz': 'salom', 'ru': 'привет'},
    'good morning': {'uz': 'xayrli tong', 'ru': 'доброе утро'},
    'good afternoon': {'uz': 'xayrli kun', 'ru': 'добрый день'},
    'good evening': {'uz': 'xayrli kech', 'ru': 'добрый вечер'},
    'good night': {'uz': 'xayrli tun', 'ru': 'спокойной ночи'},
    'how are you': {'uz': 'qandaysiz?', 'ru': 'как дела?'},
    'how are you doing': {'uz': 'ishlaringiz qanday?', 'ru': 'как ваши дела?'},
    'i am fine': {'uz': 'men yaxshiman', 'ru': 'я в порядке'},
    'i am good': {'uz': 'men yaxshiman', 'ru': 'у меня всё хорошо'},
    'thank you': {'uz': 'rahmat', 'ru': 'спасибо'},
    'thank you very much': {'uz': 'katta rahmat', 'ru': 'большое спасибо'},
    'thanks': {'uz': 'tashakkur', 'ru': 'спасибо'},
    'please': {'uz': 'iltimos', 'ru': 'пожалуйста'},
    'you are welcome': {'uz': 'arzimaydi', 'ru': 'пожалуйста, не за что'},
    'yes': {'uz': 'ha', 'ru': 'да'},
    'no': {'uz': 'yo\'q', 'ru': 'нет'},
    'okay': {'uz': 'yaxshi', 'ru': 'хорошо'},
    'welcome': {'uz': 'xush kelibsiz', 'ru': 'добро пожаловать'},
    'goodbye': {'uz': 'xayr, salomat bo\'ling', 'ru': 'до свидания'},
    'bye': {'uz': 'xayr', 'ru': 'пока'},
    'see you': {'uz': 'ko\'rishguncha', 'ru': 'до встречи'},
    'see you soon': {'uz': 'tez orada ko\'rishguncha', 'ru': 'до скорой встречи'},
    'what is your name': {'uz': 'ismingiz nima?', 'ru': 'как вас зовут?'},
    'my name is': {'uz': 'mening ismim', 'ru': 'меня зовут'},
    'nice to meet you': {'uz': 'tanishganimdan xursandman', 'ru': 'приятно познакомиться'},
    'excuse me': {'uz': 'kechirasiz', 'ru': 'извините'},
    'sorry': {'uz': 'uzr, kechirasiz', 'ru': 'простите'},
    'i love you': {'uz': 'men sizni yaxshi ko\'raman', 'ru': 'я люблю тебя'},
    'i miss you': {'uz': 'sizni sog\'indim', 'ru': 'я скучаю по тебе'},

    // People & Family
    'friend': {'uz': 'do\'st', 'ru': 'друг'},
    'family': {'uz': 'oila', 'ru': 'семья'},
    'father': {'uz': 'ota', 'ru': 'отец'},
    'mother': {'uz': 'ona', 'ru': 'мать'},
    'brother': {'uz': 'aka, uka', 'ru': 'брат'},
    'sister': {'uz': 'opa, singil', 'ru': 'сестра'},
    'parents': {'uz': 'ota-ona', 'ru': 'родители'},
    'son': {'uz': 'o\'g\'il', 'ru': 'сын'},
    'daughter': {'uz': 'qiz', 'ru': 'дочь'},
    'child': {'uz': 'bola', 'ru': 'ребенок'},
    'children': {'uz': 'bolalar', 'ru': 'дети'},
    'man': {'uz': 'erkak', 'ru': 'мужчина'},
    'woman': {'uz': 'ayol', 'ru': 'женщина'},
    'boy': {'uz': 'bola', 'ru': 'мальчик'},
    'girl': {'uz': 'qiz bola', 'ru': 'девочка'},
    'people': {'uz': 'odamlar, insonlar', 'ru': 'люди'},
    'person': {'uz': 'shaxs, inson', 'ru': 'человек'},

    // Education, Learning & Language
    'book': {'uz': 'kitob', 'ru': 'книга'},
    'notebook': {'uz': 'daftar', 'ru': 'тетрадь'},
    'pen': {'uz': 'ruchka', 'ru': 'ручка'},
    'pencil': {'uz': 'qalam', 'ru': 'карандаш'},
    'word': {'uz': 'so\'z', 'ru': 'слово'},
    'dictionary': {'uz': 'lug\'at', 'ru': 'словарь'},
    'translator': {'uz': 'tarjimon', 'ru': 'переводчик'},
    'translation': {'uz': 'tarjima', 'ru': 'перевод'},
    'language': {'uz': 'til', 'ru': 'язык'},
    'english': {'uz': 'ingliz tili', 'ru': 'английский язык'},
    'russian': {'uz': 'rus tili', 'ru': 'русский язык'},
    'uzbek': {'uz': 'o\'zbek tili', 'ru': 'узбекский язык'},
    'school': {'uz': 'maktab', 'ru': 'школа'},
    'university': {'uz': 'universitet', 'ru': 'университет'},
    'college': {'uz': 'kollej', 'ru': 'колледж'},
    'student': {'uz': 'talaba, o\'quvchi', 'ru': 'студент'},
    'teacher': {'uz': 'o\'qituvchi', 'ru': 'учитель'},
    'lesson': {'uz': 'dars', 'ru': 'урок'},
    'homework': {'uz': 'uy vazifasi', 'ru': 'домашнее задание'},
    'exam': {'uz': 'imtihon', 'ru': 'экзамен'},
    'test': {'uz': 'test', 'ru': 'тест'},
    'study': {'uz': 'o\'qimoq, o\'rganmoq', 'ru': 'учиться'},
    'learn': {'uz': 'yodlamoq, o\'rganmoq', 'ru': 'изучать'},
    'read': {'uz': 'o\'qimoq', 'ru': 'читать'},
    'write': {'uz': 'yozmoq', 'ru': 'писать'},
    'speak': {'uz': 'gapirmoq', 'ru': 'говорить'},
    'listen': {'uz': 'tinglamoq', 'ru': 'слушать'},
    'understand': {'uz': 'tushunmoq', 'ru': 'понимать'},
    'i understand': {'uz': 'men tushunaman', 'ru': 'я понимаю'},
    'i do not understand': {'uz': 'men tushunmayapman', 'ru': 'я не понимаю'},
    'repeat': {'uz': 'takrorlamoq', 'ru': 'повторить'},

    // Technology, Work & Money
    'work': {'uz': 'ish, ishlamoq', 'ru': 'работа, работать'},
    'job': {'uz': 'kasb, vazifa', 'ru': 'профессия'},
    'office': {'uz': 'ofis', 'ru': 'офис'},
    'company': {'uz': 'kompaniya', 'ru': 'компания'},
    'computer': {'uz': 'kompyuter', 'ru': 'компьютер'},
    'laptop': {'uz': 'noutbuk', 'ru': 'ноутбук'},
    'phone': {'uz': 'telefon', 'ru': 'телефон'},
    'application': {'uz': 'ilova', 'ru': 'приложение'},
    'app': {'uz': 'ilova', 'ru': 'приложение'},
    'internet': {'uz': 'internet', 'ru': 'интернет'},
    'message': {'uz': 'xabar', 'ru': 'сообщение'},
    'email': {'uz': 'elektron pochta', 'ru': 'электронная почта'},
    'password': {'uz': 'parol', 'ru': 'пароль'},
    'login': {'uz': 'kirish', 'ru': 'вход'},
    'register': {'uz': 'ro\'yxatdan o\'tish', 'ru': 'регистрация'},
    'admin': {'uz': 'administrator', 'ru': 'администратор'},
    'user': {'uz': 'foydalanuvchi', 'ru': 'пользователь'},
    'money': {'uz': 'pul', 'ru': 'деньги'},
    'coin': {'uz': 'tanga, coin', 'ru': 'монета'},
    'coins': {'uz': 'tangalar', 'ru': 'монеты'},
    'card': {'uz': 'karta', 'ru': 'карта'},
    'bank': {'uz': 'bank', 'ru': 'банк'},
    'buy': {'uz': 'sotib olmoq', 'ru': 'купить'},
    'sell': {'uz': 'sotmoq', 'ru': 'продавать'},
    'price': {'uz': 'narx', 'ru': 'цена'},
    'free': {'uz': 'bepul', 'ru': 'бесплатно'},
    'success': {'uz': 'muvaffaqiyat', 'ru': 'успех'},
    'knowledge': {'uz': 'bilim', 'ru': 'знание'},
    'opportunity': {'uz': 'imkoniyat', 'ru': 'возможность'},
    'achievement': {'uz': 'yutuq', 'ru': 'достижение'},
    'perseverance': {'uz': 'matonat, qat\'iyat', 'ru': 'настойчивость'},
    'goal': {'uz': 'maqsad', 'ru': 'цель'},

    // Nature, Food & Place
    'water': {'uz': 'suv', 'ru': 'вода'},
    'tea': {'uz': 'choy', 'ru': 'чай'},
    'coffee': {'uz': 'kofe', 'ru': 'кофе'},
    'bread': {'uz': 'non', 'ru': 'хлеб'},
    'apple': {'uz': 'olma', 'ru': 'яблоко'},
    'food': {'uz': 'taom, ovqat', 'ru': 'еда'},
    'breakfast': {'uz': 'nonushta', 'ru': 'завтрак'},
    'lunch': {'uz': 'tushlik', 'ru': 'обед'},
    'dinner': {'uz': 'kechki ovqat', 'ru': 'ужин'},
    'home': {'uz': 'uy', 'ru': 'дом'},
    'house': {'uz': 'uy', 'ru': 'дом'},
    'room': {'uz': 'xona', 'ru': 'комната'},
    'city': {'uz': 'shahar', 'ru': 'город'},
    'country': {'uz': 'davlat, mamlakat', 'ru': 'страна'},
    'world': {'uz': 'dunyo, olam', 'ru': 'мир'},
    'car': {'uz': 'mashina', 'ru': 'машина'},
    'street': {'uz': 'ko\'cha', 'ru': 'улица'},
    'road': {'uz': 'yo\'l', 'ru': 'дорога'},
    'sun': {'uz': 'quyosh', 'ru': 'солнце'},
    'moon': {'uz': 'oy', 'ru': 'луна'},
    'cloud': {'uz': 'bulut', 'ru': 'облако'},
    'sky': {'uz': 'osmon', 'ru': 'небо'},
    'rain': {'uz': 'yomg\'ir', 'ru': 'дождь'},
    'snow': {'uz': 'qor', 'ru': 'снег'},
    'wind': {'uz': 'shamol', 'ru': 'ветер'},

    // Time & Days
    'time': {'uz': 'vaqt, soat', 'ru': 'время'},
    'hour': {'uz': 'soat', 'ru': 'час'},
    'minute': {'uz': 'daqiqa', 'ru': 'минута'},
    'second': {'uz': 'soniya', 'ru': 'секунда'},
    'day': {'uz': 'kun', 'ru': 'день'},
    'week': {'uz': 'hafta', 'ru': 'неделя'},
    'month': {'uz': 'oy', 'ru': 'месяц'},
    'year': {'uz': 'yil', 'ru': 'год'},
    'morning': {'uz': 'ertalab, tong', 'ru': 'утро'},
    'afternoon': {'uz': 'tushdan keyin', 'ru': 'день'},
    'night': {'uz': 'tun, oqshom', 'ru': 'ночь'},
    'today': {'uz': 'bugun', 'ru': 'сегодня'},
    'tomorrow': {'uz': 'ertaga', 'ru': 'завтра'},
    'yesterday': {'uz': 'kecha', 'ru': 'вчера'},
    'now': {'uz': 'hozir', 'ru': 'сейчас'},
    'monday': {'uz': 'dushanba', 'ru': 'понедельник'},
    'tuesday': {'uz': 'seshanba', 'ru': 'вторник'},
    'wednesday': {'uz': 'chorshanba', 'ru': 'среда'},
    'thursday': {'uz': 'payshanba', 'ru': 'четверг'},
    'friday': {'uz': 'juma', 'ru': 'пятница'},
    'saturday': {'uz': 'shanba', 'ru': 'суббота'},
    'sunday': {'uz': 'yakshanba', 'ru': 'воскресенье'},

    // Adjectives & Descriptions
    'good': {'uz': 'yaxshi', 'ru': 'хороший'},
    'bad': {'uz': 'yomon', 'ru': 'плохой'},
    'big': {'uz': 'katta', 'ru': 'большой'},
    'small': {'uz': 'kichik', 'ru': 'маленький'},
    'beautiful': {'uz': 'chiroyli, go\'zal', 'ru': 'красивый'},
    'clean': {'uz': 'toza', 'ru': 'чистый'},
    'new': {'uz': 'yangi', 'ru': 'новый'},
    'old': {'uz': 'eski', 'ru': 'старый'},
    'young': {'uz': 'yosh', 'ru': 'молодой'},
    'easy': {'uz': 'oson', 'ru': 'легкий'},
    'hard': {'uz': 'qiyin', 'ru': 'трудный'},
    'fast': {'uz': 'tez', 'ru': 'быстрый'},
    'slow': {'uz': 'sekin', 'ru': 'медленный'},
    'hot': {'uz': 'issiq', 'ru': 'горячий, жаркий'},
    'cold': {'uz': 'sovuq', 'ru': 'холодный'},
    'happy': {'uz': 'baxtli, xursand', 'ru': 'счастливый'},
    'sad': {'uz': 'xafa', 'ru': 'грустный'},
    'important': {'uz': 'muhim', 'ru': 'важный'},
    'interesting': {'uz': 'qiziqarli', 'ru': 'интересный'},
    'strong': {'uz': 'kuchli', 'ru': 'сильный'},
    'smart': {'uz': 'aqlli', 'ru': 'умный'},

    // Pronouns & Questions
    'i': {'uz': 'men', 'ru': 'я'},
    'you': {'uz': 'siz, sen', 'ru': 'ты, вы'},
    'he': {'uz': 'u (erkak)', 'ru': 'он'},
    'she': {'uz': 'u (ayol)', 'ru': 'она'},
    'it': {'uz': 'u (narsa)', 'ru': 'оно'},
    'we': {'uz': 'biz', 'ru': 'мы'},
    'they': {'uz': 'ular', 'ru': 'они'},
    'what': {'uz': 'nima', 'ru': 'что'},
    'where': {'uz': 'qayerda', 'ru': 'где'},
    'when': {'uz': 'qachon', 'ru': 'когда'},
    'why': {'uz': 'nega, nima uchun', 'ru': 'почему'},
    'who': {'uz': 'kim', 'ru': 'кто'},
    'how': {'uz': 'qanday', 'ru': 'как'},
    'how much': {'uz': 'qancha', 'ru': 'сколько'},
    'how many': {'uz': 'nechta', 'ru': 'сколько'},
    'where is': {'uz': 'qayerda joylashgan?', 'ru': 'где находится?'},
    'help': {'uz': 'yordam bermoq, yordam', 'ru': 'помощь, помочь'},
  };

  static String _getLangCode(String lang) {
    final lower = lang.toLowerCase();
    if (lower.contains('ingliz') || lower.contains('english') || lower.contains('en')) {
      return 'en';
    }
    if (lower.contains('rus') || lower.contains('russian') || lower.contains('ru')) {
      return 'ru';
    }
    return 'uz';
  }

  /// Main Translation method: Multi-engine with automatic fallback
  static Future<String> translate({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    final query = text.trim();
    if (query.isEmpty) return '';

    final fromCode = _getLangCode(fromLanguage);
    final toCode = _getLangCode(toLanguage);

    if (fromCode == toCode) return query;

    // 1. Google Translate GTX Free API (Full sentences, multi-words, punctuations)
    try {
      final googleUrl = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$fromCode&tl=$toCode&dt=t&q=${Uri.encodeComponent(query)}',
      );

      final response = await http.get(googleUrl).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final sb = StringBuffer();
          for (final part in decoded[0]) {
            if (part is List && part.isNotEmpty && part[0] != null) {
              sb.write(part[0].toString());
            }
          }
          final translated = sb.toString().trim();
          if (translated.isNotEmpty) {
            return translated;
          }
        }
      }
    } catch (e) {
      debugPrint('Google Translate API error/CORS fallback: $e');
    }

    // 2. Google Dictionary / Translation Client alternative endpoint
    try {
      final clientUrl = Uri.parse(
        'https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=$fromCode&tl=$toCode&q=${Uri.encodeComponent(query)}',
      );
      final response = await http.get(clientUrl).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded[0];
          if (first is String && first.trim().isNotEmpty) {
            return first.trim();
          } else if (first is List && first.isNotEmpty && first[0] is String) {
            return first[0].toString().trim();
          }
        }
      }
    } catch (e) {
      debugPrint('Google Client API fallback: $e');
    }

    // 3. MyMemory API fallback
    try {
      final myMemoryUrl = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(query)}&langpair=$fromCode|$toCode',
      );
      final response = await http.get(myMemoryUrl).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['responseData'] != null && data['responseData']['translatedText'] != null) {
          final res = data['responseData']['translatedText'].toString().trim();
          if (res.isNotEmpty && !res.contains('MYMEMORY WARNING')) {
            return res;
          }
        }
      }
    } catch (e) {
      debugPrint('MyMemory API error: $e');
    }

    // 4. Offline Dictionary & Vocabulary match (Full phrase or word)
    final offlineRes = _lookupOffline(query, fromCode, toCode);
    if (offlineRes.isNotEmpty) {
      return offlineRes;
    }

    // 5. Intelligent Multi-Word / Phrase Assembler
    final words = query.split(RegExp(r'\s+'));
    if (words.length > 1) {
      final translatedWords = words.map((w) {
        // Strip punctuation safely
        final clean = w.replaceAll(RegExp(r'''[.,!?'"():;]'''), '').trim();
        if (clean.isEmpty) return w;
        final match = _lookupOffline(clean, fromCode, toCode);
        if (match.isNotEmpty) {
          // Re-attach punctuation if any
          final lastChar = w[w.length - 1];
          if (['.', ',', '!', '?', ';', ':'].contains(lastChar)) {
            return '$match$lastChar';
          }
          return match;
        }
        return w;
      }).toList();
      return translatedWords.join(' ');
    }

    return query;
  }

  static String _lookupOffline(String rawQuery, String fromCode, String toCode) {
    final query = rawQuery.toLowerCase().trim();
    if (query.isEmpty) return '';

    // Check custom dictionary
    if (fromCode == 'en') {
      if (_dictionary.containsKey(query)) {
        return _dictionary[query]?[toCode] ?? '';
      }
    } else if (fromCode == 'ru') {
      for (final entry in _dictionary.entries) {
        final ruVal = entry.value['ru']?.toLowerCase() ?? '';
        final synonyms = ruVal.split(',').map((s) => s.trim().toLowerCase());
        if (synonyms.contains(query) || ruVal == query) {
          if (toCode == 'uz') return entry.value['uz'] ?? '';
          if (toCode == 'en') return entry.key;
        }
      }
    } else if (fromCode == 'uz') {
      for (final entry in _dictionary.entries) {
        final uzVal = entry.value['uz']?.toLowerCase() ?? '';
        final synonyms = uzVal.split(',').map((s) => s.trim().toLowerCase());
        if (synonyms.contains(query) || uzVal == query) {
          if (toCode == 'en') return entry.key;
          if (toCode == 'ru') return entry.value['ru'] ?? '';
        }
      }
    }

    // Check vocabulary database from initialVocabulary
    for (final word in initialVocabulary) {
      if (fromCode == 'en' && word.english.toLowerCase() == query) {
        if (toCode == 'uz') return word.uzbek;
        if (toCode == 'ru') return word.russian;
      } else if (fromCode == 'ru') {
        final ruSynonyms = word.russian.toLowerCase().split(',').map((s) => s.trim());
        if (ruSynonyms.contains(query) || word.russian.toLowerCase() == query) {
          if (toCode == 'uz') return word.uzbek;
          if (toCode == 'en') return word.english;
        }
      } else if (fromCode == 'uz') {
        final uzSynonyms = word.uzbek.toLowerCase().split(',').map((s) => s.trim());
        if (uzSynonyms.contains(query) || word.uzbek.toLowerCase() == query) {
          if (toCode == 'en') return word.english;
          if (toCode == 'ru') return word.russian;
        }
      }
    }

    return '';
  }
}
