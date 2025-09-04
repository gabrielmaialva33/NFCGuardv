import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class NvidiaNimService {
  static const String _baseUrl = AppConstants.nvidiaApiUrl;
  static const String _apiKey = AppConstants.nvidiaApiKey;
  static const String _model = AppConstants.bestModel;

  Future<String> generateResponse({
    required String prompt,
    double temperature = 0.7,
    double topP = 0.8,
    int maxTokens = 4096,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': temperature,
          'top_p': topP,
          'frequency_penalty': 0,
          'presence_penalty': 0,
          'max_tokens': maxTokens,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Erro na API NVIDIA: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com NVIDIA NIM: $e');
    }
  }

  Future<String> analyzeSecurityCode(String code) async {
    const prompt = '''
Analise este código de segurança NFC e forneça insights sobre:
1. Força da segurança
2. Possíveis melhorias
3. Recomendações para uso

Código: ''';
    
    return await generateResponse(prompt: '$prompt$code');
  }

  Future<String> generateSecureCode({
    required int length,
    bool includeNumbers = true,
    bool includeLetters = true,
    bool includeSymbols = false,
  }) async {
    final prompt = '''
Gere um código seguro de $length caracteres para uso em tags NFC com as seguintes características:
- Incluir números: $includeNumbers
- Incluir letras: $includeLetters  
- Incluir símbolos: $includeSymbols

Retorne apenas o código gerado, sem explicações adicionais.
''';
    
    return await generateResponse(prompt: prompt);
  }
}