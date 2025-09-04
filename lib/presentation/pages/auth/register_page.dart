import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../home/home_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Controllers para dados pessoais
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  // Controllers para endereço
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  DateTime? _dataNascimento;
  String _sexoSelecionado = 'M';
  bool _isPasswordVisible = false;
  bool _isLoadingCep = false;
  int _currentPage = 0;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8) {
      setState(() => _isLoadingCep = true);

      try {
        final authNotifier = ref.read(authProvider.notifier);
        final addressInfo = await authNotifier.searchZipCode(cep);

        if (addressInfo != null) {
          _enderecoController.text = addressInfo['address'] ?? '';
          _bairroController.text = addressInfo['neighborhood'] ?? '';
          _cidadeController.text = addressInfo['city'] ?? '';
          _ufController.text = addressInfo['stateCode'] ?? '';
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('CEP não encontrado')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Erro ao buscar CEP')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingCep = false);
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dataNascimento = picked);
    }
  }

  void _nextPage() {
    if (_currentPage == 0 && _validatePersonalData()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  bool _validatePersonalData() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);

      await authNotifier.register(
        fullName: _nomeController.text.trim(),
        cpf: _cpfController.text,
        email: _emailController.text.trim().toLowerCase(),
        phone: _telefoneController.text,
        birthDate: _dataNascimento!,
        gender: _sexoSelecionado,
        password: _senhaController.text,
      );

      // Atualizar endereço
      await authNotifier.updateAddress(
        zipCode: _cepController.text,
        address: _enderecoController.text.trim(),
        neighborhood: _bairroController.text.trim(),
        city: _cidadeController.text.trim(),
        stateCode: _ufController.text.trim().toUpperCase(),
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro no cadastro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<dynamic>>(authProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro: $error')));
        },
      );
    });

    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPage == 0 ? 'Dados Pessoais' : 'Endereço'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [_buildPersonalDataPage(), _buildAddressPage()],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentPage == 0
            ? ElevatedButton(
                onPressed: _nextPage,
                child: const Text('Continuar'),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Cadastrar'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPersonalDataPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome Completo',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Nome é obrigatório';
              if (value!.split(' ').length < 2) {
                return 'Digite nome e sobrenome';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cpfController,
            decoration: const InputDecoration(
              labelText: 'CPF',
              prefixIcon: Icon(Icons.assignment_ind),
              hintText: '000.000.000-00',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (value) {
              if (value?.isEmpty ?? true) return 'CPF é obrigatório';
              if (value!.length < 11) {
                return AppConstants.invalidCpfMessage;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email é obrigatório';
              if (!value!.contains('@')) return 'Email inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              prefixIcon: Icon(Icons.phone),
              hintText: '(00) 00000-0000',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Telefone é obrigatório';
              return null;
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _dataNascimento != null
                    ? '${_dataNascimento!.day.toString().padLeft(2, '0')}/'
                          '${_dataNascimento!.month.toString().padLeft(2, '0')}/'
                          '${_dataNascimento!.year}'
                    : 'Selecione a data',
                style: TextStyle(
                  color: _dataNascimento != null
                      ? null
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _sexoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Sexo',
              prefixIcon: Icon(Icons.wc),
            ),
            items: const [
              DropdownMenuItem(value: 'M', child: Text('Masculino')),
              DropdownMenuItem(value: 'F', child: Text('Feminino')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _sexoSelecionado = value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _senhaController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Senha é obrigatória';
              if (value!.length < 6) {
                return 'Senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cepController,
                  decoration: const InputDecoration(
                    labelText: 'CEP',
                    prefixIcon: Icon(Icons.location_on),
                    hintText: '00000-000',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  onChanged: (value) {
                    if (value.length == 8) _searchCep();
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'CEP é obrigatório';
                    if (value!.length < 8) return 'CEP deve ter 8 dígitos';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isLoadingCep ? null : _searchCep,
                icon: _isLoadingCep
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _enderecoController,
            decoration: const InputDecoration(
              labelText: 'Endereço',
              prefixIcon: Icon(Icons.home),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Endereço é obrigatório';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bairroController,
            decoration: const InputDecoration(
              labelText: 'Bairro',
              prefixIcon: Icon(Icons.location_city),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Bairro é obrigatório';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Cidade é obrigatória';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _ufController,
                  decoration: const InputDecoration(
                    labelText: 'UF',
                    prefixIcon: Icon(Icons.map),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'UF é obrigatória';
                    if (value!.length != 2) return 'UF deve ter 2 letras';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
