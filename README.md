# mobile_arquitetura_02

Evolução da Atividade 1 — melhorias arquiteturais: estados explícitos de UI, tratamento de erros tipado e cache local com fallback offline.

---

## O que foi adicionado

### 1. Estados explícitos da interface
O `ProductProvider` representa 5 estados via enum `ProductStatus`:

| Estado | Quando ocorre |
|--------|--------------|
| `initial` | App recém aberto, antes da primeira requisição |
| `loading` | Requisição em andamento |
| `loaded` | Dados recebidos com sucesso da API |
| `stale` | Falha na API, mas dados antigos do cache estão disponíveis |
| `error` | Falha sem nenhum dado de fallback disponível |

### 2. Tratamento de erros
Erros são capturados no `AppHttpClient` e convertidos em tipos específicos:
- `NetworkError` — sem internet ou timeout
- `ServerError` — status HTTP de erro
- `ParseError` — JSON inválido
- `UnknownError` — exceção não mapeada

### 3. Cache local com fallback offline
Implementado em `core/cache/product_cache.dart` com TTL de 5 minutos.

Fluxo no `ProductRepositoryImpl`:
```
Cache válido? → retorna cache
      ↓ não
Busca na API → sucesso → salva cache → retorna
      ↓ falha
Tem dados antigos? → estado "stale" (banner de aviso)
      ↓ não
Estado "error" (tela de erro completa)
```

---

## Questionário de Reflexão

### 1. Em qual camada foi implementado o mecanismo de cache? Por quê?

O cache foi implementado na camada **data**, dentro do `ProductRepositoryImpl`, com o utilitário `ProductCache` em **core**.

Essa decisão é correta porque o repositório é responsável por decidir *de onde os dados vêm*. A UI não deve saber nada sobre infraestrutura, e o domínio define apenas contratos. O repositório abstrai a origem — rede, cache, banco local — e expõe um resultado uniforme.

### 2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?

Porque isso violaria o princípio de responsabilidade única. O ViewModel coordena **estado da UI**. Se fizesse HTTP diretamente, ficaria acoplado à biblioteca de rede, impossibilitando testes isolados. Qualquer mudança na API exigiria alterar o ViewModel, e a lógica de cache ficaria misturada com lógica de estado.

### 3. O que poderia acontecer se a interface acessasse diretamente o DataSource?

A UI passaria a conhecer detalhes de infraestrutura (URLs, parsing, timeouts). Cada tela reimplementaria tratamento de erros. Uma mudança na API quebraria múltiplas telas. Testes de UI precisariam de uma API real. A UI dependeria de `dart:io` e `http`, violando a separação de camadas.

### 4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?

Bastaria criar `LocalProductRepository` implementando `ProductRepository` e trocar uma linha no `main.dart`. Nenhum arquivo de `domain`, `presentation` ou `core` mudaria. O `ProductProvider` continuaria chamando `repository.getProducts()` sem saber que a fonte de dados mudou.

---

## Como executar

```bash
flutter pub get
flutter run
```

Para testar o fallback: abra o app com internet, aguarde carregar, desative a conexão e puxe para atualizar.

---

## Arquivos novos/alterados em relação à Atividade 1

```
🆕 core/cache/product_cache.dart
🔄 core/errors/app_error.dart
🔄 core/network/http_client.dart
🔄 data/repositories/product_repository_impl.dart
🔄 presentation/providers/product_provider.dart
🔄 presentation/pages/product_list_page.dart
🆕 presentation/widgets/cache_banner.dart
🆕 presentation/widgets/error_view.dart
🔄 main.dart
```
