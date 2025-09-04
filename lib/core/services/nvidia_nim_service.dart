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

  Future<Map<String, dynamic>> validateCpfWithFraudDetection(String cpf) async {
    final prompt = '''
Analise este CPF brasileiro para validação e detecção de fraude:

CPF: $cpf

IMPORTANTE: Execute uma validação matemática PRECISA dos dígitos verificadores antes de qualquer análise.

Forneça uma análise completa incluindo:
1. Validação matemática rigorosa do CPF usando o algoritmo oficial brasileiro
2. Detecção APENAS de padrões claramente fraudulentos:
   - CPFs com todos os dígitos iguais (111.111.111-11, 000.000.000-00)
   - CPFs sequenciais óbvios como 123.456.789-XX ou 987.654.321-XX
   - NÃO considere fraudulento CPFs que apenas tenham alguns dígitos repetidos naturalmente
3. Score de confiabilidade baseado na validade matemática real
4. Recomendação baseada apenas na validação matemática e fraudes óbvias

CRITÉRIOS:
- Se matematicamente válido E sem padrões óbvios de fraude = ACEITAR (score 85-95)
- Se matematicamente válido MAS com padrões suspeitos = REVISAR (score 60-80)  
- Se matematicamente inválido OU fraude óbvia = REJEITAR (score 0-30)

Responda APENAS em formato JSON válido:
{
  "valido": true/false,
  "fraudulento": true/false,
  "score_confiabilidade": número_0_a_100,
  "recomendacao": "ACEITAR/REVISAR/REJEITAR",
  "motivos": ["lista", "de", "motivos"],
  "analise_detalhada": "texto explicativo"
}
''';
    
    try {
      final response = await generateResponse(prompt: prompt, temperature: 0.1);
      
      // Tentar parsear como JSON
      try {
        final jsonResponse = json.decode(response.trim());
        return jsonResponse as Map<String, dynamic>;
      } catch (e) {
        // Se falhar o parse, extrair informações básicas
        return {
          'valido': _isValidCpf(cpf),
          'fraudulento': _hasCommonFraudPatterns(cpf),
          'score_confiabilidade': _isValidCpf(cpf) && !_hasCommonFraudPatterns(cpf) ? 85 : 20,
          'recomendacao': _isValidCpf(cpf) && !_hasCommonFraudPatterns(cpf) ? 'ACEITAR' : 'REJEITAR',
          'motivos': ['Análise básica aplicada devido a erro na resposta da AI'],
          'analise_detalhada': response,
        };
      }
    } catch (e) {
      // Fallback para validação básica em caso de erro da API
      return {
        'valido': _isValidCpf(cpf),
        'fraudulento': _hasCommonFraudPatterns(cpf),
        'score_confiabilidade': _isValidCpf(cpf) && !_hasCommonFraudPatterns(cpf) ? 70 : 10,
        'recomendacao': _isValidCpf(cpf) && !_hasCommonFraudPatterns(cpf) ? 'REVISAR' : 'REJEITAR',
        'motivos': ['Análise offline devido a erro na conexão com AI'],
        'analise_detalhada': 'Erro na conexão: $e',
      };
    }
  }

  // Validação básica de CPF (fallback)
  bool _isValidCpf(String cpf) {
    // Remove formatação
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cpf.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;
    
    // Calcula primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 > 9) digit1 = 0;
    
    // Calcula segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int digit2 = 11 - (sum % 11);
    if (digit2 > 9) digit2 = 0;
    
    return cpf[9] == digit1.toString() && cpf[10] == digit2.toString();
  }

  // Detecção de padrões fraudulentos comuns
  bool _hasCommonFraudPatterns(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Lista de CPFs inválidos conhecidos (todos os dígitos iguais)
    final invalidCpfs = [
      '00000000000', '11111111111', '22222222222', '33333333333',
      '44444444444', '55555555555', '66666666666', '77777777777',
      '88888888888', '99999999999'
    ];
    
    if (invalidCpfs.contains(cpf)) return true;
    
    // Verifica apenas sequências óbvias nos primeiros 9 dígitos
    bool isObviousSequential = true;
    for (int i = 1; i < 9; i++) { // Apenas os primeiros 9 dígitos
      if (int.parse(cpf[i]) != int.parse(cpf[i-1]) + 1) {
        isObviousSequential = false;
        break;
      }
    }
    
    // Verifica sequências decrescentes
    bool isDescendingSequential = true;
    for (int i = 1; i < 9; i++) {
      if (int.parse(cpf[i]) != int.parse(cpf[i-1]) - 1) {
        isDescendingSequential = false;
        break;
      }
    }
    
    return isObviousSequential || isDescendingSequential;
  }
}