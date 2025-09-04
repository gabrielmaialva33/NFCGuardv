#!/bin/bash

# Script para criar build da versão trial do NFCGuard
# Versão trial: 3 dias de funcionamento

echo "🚀 Construindo NFCGuard - Versão Trial (3 dias)"
echo "================================================"

# Verifica se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Instale o Flutter primeiro."
    exit 1
fi

# Limpa builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean

# Instala dependências
echo "📦 Instalando dependências..."
flutter pub get

# Gera código (Riverpod providers)
echo "⚙️ Gerando código..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build APK para Android (Trial)
echo "🤖 Construindo APK Android (Trial)..."
flutter build apk --release \
  --dart-define=TRIAL_MODE=true \
  --build-name=1.0.0-trial \
  --build-number=1

# Move APK para pasta organizada
mkdir -p builds/trial
cp build/app/outputs/flutter-apk/app-release.apk builds/trial/NFCGuard-Trial-v1.0.0.apk

# Build AAB para Google Play (Trial)
echo "📱 Construindo AAB Android (Trial)..."
flutter build appbundle --release \
  --dart-define=TRIAL_MODE=true \
  --build-name=1.0.0-trial \
  --build-number=1

# Move AAB para pasta organizada  
cp build/app/outputs/bundle/release/app-release.aab builds/trial/NFCGuard-Trial-v1.0.0.aab

# Build iOS (se disponível)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Construindo iOS (Trial)..."
    flutter build ios --release \
      --dart-define=TRIAL_MODE=true \
      --build-name=1.0.0-trial \
      --build-number=1
    
    echo "💡 Para iOS: Abra ios/Runner.xcworkspace no Xcode para gerar IPA"
fi

# Relatório final
echo ""
echo "✅ Build Trial Concluído!"
echo "========================="
echo ""
echo "📁 Arquivos gerados:"
echo "  • builds/trial/NFCGuard-Trial-v1.0.0.apk (Android)"
echo "  • builds/trial/NFCGuard-Trial-v1.0.0.aab (Google Play)"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  • build/ios/Release-iphoneos/Runner.app (iOS - use Xcode para IPA)"
fi
echo ""
echo "⚠️  IMPORTANTE:"
echo "  • Esta versão expira em 3 dias após instalação"
echo "  • Usa device fingerprinting (não funciona em emuladores)"
echo "  • Requer NFC físico para testar funcionalidades"
echo ""
echo "📋 Próximos passos:"
echo "  1. Teste em dispositivo físico com NFC"
echo "  2. Envie APK para cliente testar"
echo "  3. Monitore feedback por 3 dias"
echo "  4. Prepare versão full após aprovação"
echo ""

# Mostra tamanho dos arquivos
if [ -f "builds/trial/NFCGuard-Trial-v1.0.0.apk" ]; then
    APK_SIZE=$(du -h builds/trial/NFCGuard-Trial-v1.0.0.apk | cut -f1)
    echo "📊 Tamanho APK: $APK_SIZE"
fi

if [ -f "builds/trial/NFCGuard-Trial-v1.0.0.aab" ]; then
    AAB_SIZE=$(du -h builds/trial/NFCGuard-Trial-v1.0.0.aab | cut -f1)
    echo "📊 Tamanho AAB: $AAB_SIZE"
fi

echo ""
echo "🎯 Trial construído com sucesso!"