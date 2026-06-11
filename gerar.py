import os

# Configurações
ARQUIVO_SAIDA = 'codigo_completo_docscanner.txt'
PASTAS_IGNORADAS = {'.git', '.dart_tool', 'build', '.idea', 'ios', 'windows', 'macos', 'linux', 'web', 'assets'}
EXTENSOES_PERMITIDAS = {'.dart', '.yaml', '.md'}

# Arquivos específicos fora da pasta lib que são cruciais para debugar
ARQUIVOS_EXTRAS = [
    'android/app/src/main/AndroidManifest.xml',
    'android/app/build.gradle'
]

def compilar_projeto():
    with open(ARQUIVO_SAIDA, 'w', encoding='utf-8') as f:
        f.write("=== CÓDIGO COMPLETO DOCSCANNER ===\n\n")
        
        # 1. Varre a pasta lib e arquivos da raiz
        for root, dirs, files in os.walk('.'):
            dirs[:] = [d for d in dirs if d not in PASTAS_IGNORADAS and not d.startswith('.')]
            
            for file in files:
                extensao = os.path.splitext(file)[1]
                if extensao in EXTENSOES_PERMITIDAS:
                    caminho_completo = os.path.join(root, file)
                    _escrever_arquivo(f, caminho_completo)

        # 2. Adiciona os arquivos extras (Manifest e Gradle)
        for extra in ARQUIVOS_EXTRAS:
            caminho_extra = os.path.join(os.getcwd(), extra.replace('/', os.sep))
            _escrever_arquivo(f, caminho_extra)

def _escrever_arquivo(f, caminho):
    if os.path.exists(caminho):
        try:
            with open(caminho, 'r', encoding='utf-8') as conteudo:
                f.write(f"\n{'='*60}\n")
                f.write(f"ARQUIVO: {caminho}\n")
                f.write(f"{'='*60}\n\n")
                f.write(conteudo.read() + "\n")
        except Exception as e:
            f.write(f"\n[Erro ao ler {caminho}: {e}]\n")

if __name__ == '__main__':
    compilar_projeto()
    print(f"✅ Arquivo '{ARQUIVO_SAIDA}' gerado com sucesso! Cole o conteúdo para o Gemini.")