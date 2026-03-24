# mobile_arquitetura_07

Atividade 07 — Expansão de Navegação em Aplicação Flutter com Fake API.

Evolução do projeto `mobile_arquitetura_02`, adicionando múltiplas telas e fluxo de navegação
conforme o material "Múltiplas Telas - Aula 1".

---

## Fluxo de navegação

```
HomePage  →  ProductListPage  →  ProductDetailPage
   ↑               ↑                    ↑
Tela inicial   Lista da API       Detalhes do item
(ponto de      (com favoritos,    (nome, preço,
 entrada)       cache e estados)   descrição, imagem)
```

---

## O que foi adicionado nesta atividade

| Arquivo | O que mudou |
|--------|-------------|
| `presentation/pages/home_page.dart` | **Novo** — tela inicial com botão para acessar produtos |
| `main.dart` | Trocado `home: ProductListPage` por rotas nomeadas com `initialRoute: '/'` apontando para `HomePage` |

O restante do projeto (arquitetura em camadas, cache, tratamento de erros, favoritos) foi mantido intacto da atividade anterior.

---

## Estrutura de telas

```
lib/presentation/pages/
├── home_page.dart          ← NOVO — Tela Inicial
├── product_list_page.dart  ← Tela de Produtos (já existia)
├── product_detail_page.dart← Tela de Detalhes (já existia)
└── favorites_page.dart     ← Tela de Favoritos (já existia)
```

---

## Questionário

### 1. Qual era a estrutura do seu projeto antes da inclusão das novas telas?

O projeto já possuía duas telas: `ProductListPage` (lista de produtos da FakeStore API) e `ProductDetailPage` (detalhes do produto selecionado). O `main.dart` abria diretamente a lista de produtos, sem uma tela inicial de entrada. Não havia ponto de entrada explícito — o usuário já caia direto na listagem.

---

### 2. Como ficou o fluxo da aplicação após a implementação da navegação?

O fluxo passou a seguir três etapas:

```
HomePage → ProductListPage → ProductDetailPage
```

O usuário inicia na tela inicial, que apresenta o nome da loja e um botão. Ao clicar, é levado à lista de produtos carregados da API. Ao tocar em um produto, abre a tela de detalhes com nome, preço, descrição, imagem e avaliação.

---

### 3. Qual é o papel do `Navigator.push()` no seu projeto?

O `Navigator.push()` é usado para **avançar** na pilha de telas. Quando o usuário toca em um produto na lista, o método empilha a `ProductDetailPage` sobre a `ProductListPage`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ProductDetailPage(product: product),
  ),
);
```

A tela anterior não é descartada — ela permanece na pilha, o que permite o retorno.

---

### 4. Qual é o papel do `Navigator.pop()` no seu projeto?

O `Navigator.pop()` é responsável pelo **retorno** à tela anterior. Na `ProductDetailPage`, o botão de voltar da `AppBar` aciona o pop automaticamente, removendo a tela do topo da pilha e revelando novamente a `ProductListPage`. O mesmo ocorre ao sair da lista de volta para a `HomePage`.

---

### 5. Como os dados do produto selecionado foram enviados para a tela de detalhes?

Pelo **construtor** da `ProductDetailPage`. Quando o usuário toca em um item, o objeto `Product` completo (com todos os dados da API) é passado diretamente:

```dart
ProductDetailPage(product: product)
```

A tela de detalhes declara `final Product product` como parâmetro obrigatório, garantindo que sempre receba as informações necessárias para exibição.

---

### 6. Por que a tela de detalhes depende das informações da tela anterior?

Porque ela representa um **contexto específico** — os detalhes de um item particular. Sem receber o produto selecionado, ela não saberia qual nome, preço, descrição ou imagem exibir. A tela de detalhes não busca dados da API por conta própria; ela apenas exibe o que recebeu, respeitando a separação de responsabilidades.

---

### 7. Quais foram as principais mudanças feitas no projeto original?

Duas mudanças foram feitas:

**`home_page.dart`** — arquivo novo criado com a tela inicial contendo título da loja, descrição e botão "Ver Produtos".

**`main.dart`** — a propriedade `home` foi substituída por `initialRoute: '/'` com rotas nomeadas (`/` para `HomePage`, `/products` para `ProductListPage`), centralizando a navegação no `MaterialApp`.

---

### 8. Quais dificuldades você encontrou durante a adaptação do projeto para múltiplas telas?

A principal dificuldade foi **não quebrar o que já funcionava**. O projeto já tinha `ProductProvider`, `FavoritesProvider` e cache configurados no `main.dart`. Ao adicionar rotas nomeadas e trocar o ponto de entrada, foi necessário garantir que os providers continuassem disponíveis para todas as telas da árvore de widgets — o que foi resolvido mantendo o `MultiProvider` acima do `MaterialApp`.

---

## Como executar

```bash
flutter pub get
flutter run
```
