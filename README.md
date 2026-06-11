# DocScanner

![Versão](https://img.shields.io/badge/versão-v1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)

> Uma solução móvel eficiente para digitalização, gestão e organização de documentos físicos e digitais, focada em performance, privacidade e usabilidade.

---

## Instalação

Existem duas formas principais de começar a utilizar o DocScanner:

### 1. Instalação via APK (Recomendado para usuários)

Se deseja apenas utilizar o aplicativo no seu dispositivo Android, pode baixar a versão mais recente diretamente da nossa página de releases:

**[Instalar o APK (Android APENAS) - GitHub Releases](https://github.com/ohomemcodigos/DocScanner/releases)**

### 2. Instalação via Código-Fonte (Para desenvolvedores)

Se deseja contribuir ou executar o projeto localmente, siga os passos abaixo:

**Pré-requisitos:**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.0 ou superior)
- VS Code ou Android Studio com as extensões do Flutter instaladas

**Passos:**

1. Clone este repositório:
    ```bash
    git clone https://github.com/ohomemcodigos/DocScanner.git
    ```

2. Acesse a pasta do projeto:
    ```bash
    cd DocScanner
    ```

3. Instale as dependências:
    ```bash
    flutter pub get
    ```

4. Execute o aplicativo no seu dispositivo ou emulador:
    ```bash
    flutter run
    ```

> **Nota:** Para compilar o seu próprio APK de produção, utilize:
```bash
flutter build apk --release
```
## Sobre o Projeto

O **DocScanner** foi desenvolvido para simplificar o fluxo de trabalho de usuários que necessitam digitalizar documentos, gerir pastas (PDF, Word, Excel) e manter uma organização impecável no dispositivo móvel.

O projeto prioriza a experiência do usuário, oferecendo um sistema de busca inteligente e edição rápida de PDFs.

---

## Funcionalidades Principais

### Digitalização e Gestão
Importação direta de documentos do armazenamento local com filtragem automática, ignorando arquivos de mídia desnecessários.

### Edição de PDF
Ferramentas integradas para manipulação de páginas, permitindo ajustes rápidos sem a necessidade de aplicativos de terceiros.

### Organização Inteligente
Sistema de favoritos, renomeação de arquivos e ocultação de documentos sensíveis, com persistência de estado.

### Tematização Dinâmica
Suporte nativo aos modos Claro e Escuro, respeitando automaticamente as preferências do sistema.

### Privacidade
Gestão de permissões granular, garantindo que o usuário tenha controle total sobre o acesso do aplicativo aos seus arquivos.

---

## Tecnologias e Bibliotecas Utilizadas

O projeto foi construído em **Flutter (Dart)**, com foco em uma arquitetura limpa, reativa e de fácil manutenção.

### Gerenciamento e Arquitetura

- **provider (^6.1.1)** — Gerenciamento de estado para garantir a consistência dos dados entre diferentes telas e componentes.

### Persistência de Dados e Resiliência

- **sqflite** — Banco de dados relacional local para armazenamento persistente dos metadados dos documentos.

- **Engine de Sincronização** — Lógica customizada de varredura profunda de arquivos que detecta automaticamente novos documentos em subpastas de Downloads e Documentos, com fallback seguro para evitar erros em pastas protegidas.

### Integrações e Manipulação

- **pdfx** — Motor de renderização de alta performance para visualização e manipulação de arquivos PDF.

- **permission_handler** — Controle de acesso a recursos do sistema operacional com fluxos de permissão nativos.

- **image_picker** — Interface nativa para captura de novos documentos via câmera.

### UI e Visualização

- **Design System Customizado** — Implementação de componentes reutilizáveis focados em acessibilidade e consistência visual, garantindo uma interface moderna tanto no modo claro quanto no escuro.

---

## Status do Projeto

Este é um projeto em constante evolução.

Funcionalidades como **backup em nuvem (Google Drive)** e **autenticação social** estão previstas no roadmap de desenvolvimento para futuras versões.
