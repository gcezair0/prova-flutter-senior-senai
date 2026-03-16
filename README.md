# README.md — Task Radar

---

## Sobre o Projeto

Task Radar é um aplicativo de gerenciamento de tarefas desenvolvido em Flutter que consome a API pública [DummyJSON]. O app implementa autenticação JWT, persistência local offline-first, controle de acesso por role e um CRUD completo de tarefas.

---

## Arquitetura

O projeto segue os **requisitos arquiteturais definidos no enunciado do teste**, que solicitava separação clara de responsabilidades, uso de BLoC para gerenciamento de estado e uma solução de injeção de dependência.

A estrutura foi organizada utilizando **Clean Architecture**, pois ela se encaixa naturalmente nesses requisitos e facilita a separação entre camadas de apresentação, domínio e dados.

Essa abordagem traz benefícios como:

- **Testabilidade**: cada camada pode ser testada isoladamente com mocks
- **Manutenibilidade**: mudanças em uma camada não impactam diretamente as demais
- **Escalabilidade**: novas features podem seguir a mesma estrutura sem aumentar o acoplamento
- **Separação de responsabilidades**: a UI não depende diretamente de detalhes de API ou persistência

---

## Gerenciamento de Estado — BLoC

O enunciado do teste solicita explicitamente o uso de **BLoC** para gerenciamento de estado. Para isso, foi utilizado o pacote **flutter_bloc**, que fornece uma implementação madura do padrão.

Essa abordagem também facilita:

- estados imutáveis e previsíveis
- separação entre lógica de negócio e UI
- testes unitários com `bloc_test`
- tratamento claro de estados assíncronos (loading, success, error)

---

## Injeção de Dependência — GetIt

O teste solicita o uso de uma solução de **injeção de dependência**. Para atender a esse requisito foi utilizado o **GetIt**, que funciona como um service locator simples e amplamente utilizado em projetos Flutter.

Ele permite:

- registrar dependências como singletons ou factories
- desacoplar a criação das classes do ponto de uso
- facilitar a substituição por mocks durante testes

---

## Navegação — GoRouter

O enunciado também pede **gerenciamento declarativo de rotas**. Para isso foi utilizado o **GoRouter**, solução recomendada pelo Flutter team para esse tipo de abordagem.

Ele foi utilizado para implementar:

- redirecionamento automático baseado no estado de autenticação
- controle de acesso por role (`admin` vs `moderator`)
- definição centralizada das rotas da aplicação

---

## Serialização — Freezed + json_serializable

Para implementação de modelos imutáveis e serialização JSON foram utilizados **Freezed** e **json_serializable**, conforme sugerido no próprio enunciado.

Essas ferramentas ajudam a:

- reduzir boilerplate
- gerar `copyWith`, `==` e `toString`
- garantir serialização tipada entre API e modelos

---

## Estrutura de Pastas

Separei o projeto em duas grandes partes: **core** e **features**.
O core guarda tudo que é infraestrutura — banco de dados, rede, roteamento, DI, tema, widgets compartilhados. Nada de lógica de negócio aqui, só as fundações que as features usam.
Já o features é onde mora cada funcionalidade do app, cada uma com sua própria camada de dados, domínio e apresentação:

**shared** — só o UserModel, que acabou sendo usado por auth, perfil e admin ao mesmo tempo, então fez sentido tirar de dentro de uma feature específica
**auth**— login, logout e o fluxo de autenticação JWT
**splash** — verifica se o token ainda é válido e decide pra onde mandar o usuário
**loading** — tela intermediária entre o login e o dashboard que pré-carrega as tarefas e os dados do usuário
**dashboard** — resumo das tarefas e a frase motivacional
**tasks** — o CRUD completo com paginação, filtros, busca e ordenação
**profile** — dados do usuário autenticado e o switch de tema
**admin** — listagem de usuários com as tarefas de cada um, visível só pra admins

Uma coisa que talvez chame atenção: o loading_screen.dart ficou dentro de features/loading/presentation em vez de core/widgets. Isso foi uma decisão deliberada — ele tem um BLoC próprio e pertence ao fluxo de navegação, então faz mais sentido estar junto da feature do que espalhado no core.

---

## Como rodar

### Necessário

Como rodar
Você vai precisar do Flutter 3.41.4 com Dart 3.11.1 e o Android Studio ou VSCode instalado.

### Instalação

```bash
# Clone o repositório
git clone https://github.com/SENAI-SD/prova-flutter-senior-00696-2026-097.669.154-07.git
cd task_radar

flutter pub get

# Esse comando é importante pois ele gera arquivos do freezed/drift e sem eles o código fica dando erro.
dart run build_runner build --delete-conflicting-outputs
```

Com tudo instalado, é só rodar:

Aqui eu acho importante observar que:
```bash
# Modo produção (API real)
flutter run --dart-define=USE_MOCK=false

# Modo mock (sem API, usuários simulados)
flutter run --dart-define=USE_MOCK=true
```
> Aqui eu acho importante observar que: O modo mock é útil pra testar os dois roles sem depender da internet. Use essas credenciais:

Role      | Username    | Password        
Admin     | `emilys`    | `emilyspass`    
Moderador | `moderator` | `moderatorpass`

> No modo mock, as credenciais acima são aceitas localmente sem chamada à API.

### Build de Produção

```bash
# Android
flutter build apk --dart-define=USE_MOCK=false

# iOS
flutter build ios --dart-define=USE_MOCK=false
```

---

## Testes

O projeto conta com ** projeto conta com **15 testes unitários**, todos passando, cobrindo os BLoCs principais com mocks via `mocktail` e `bloc_test`.

```
✅ All tests passed! (15/15)
```

| BLoC          | Casos testados                                                                       |
| `AuthBloc`    | Login bem-sucedido, credenciais inválidas, logout                                    |
| `TaskBloc`    | Carregamento inicial, paginação (loadMore), filtro pendentes, busca por texto        |
| `ProfileBloc` | Carregamento via API, fallback do banco local, falha total                           |
| `UsersBloc`   | Carregamento, filtro admin, filtro moderator, busca por nome, falha de rede          |



```bash
# Todos os testes
flutter test

# Com cobertura
flutter test --coverage

# Teste específico
flutter test test/features/auth/auth_bloc_test.dart
flutter test test/features/tasks/task_bloc_test.dart
flutter test test/features/profile/profile_bloc_test.dart
flutter test test/features/admin/users_bloc_test.dart
```

Os testes ficam em test/ espelhando a estrutura de features/. Tem uma pasta mocks/ com os repositórios mockados e os usuários falsos que os testes usam, e uma pasta por feature com o teste do BLoC de cada uma — auth, tasks, profile e admin.

---

## Variáveis de Ambiente

As variáveis são injetadas via `--dart-define` e lidas em `lib/core/config/env.dart`:

| Variável   | Padrão                    | Descrição                        |
| `BASE_URL` | `https://dummyjson.com`   | URL base da API                  |
| `USE_MOCK` | `false`                   | Ativa repositório mockado local  |

Para configurar no VSCode, crie `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=USE_MOCK=false"]
    },
    {
      "name": "Mock",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=USE_MOCK=true"]
    }
  ]
}
```

---

## Decisões durante o desenvolvimento e mudanças de layout

### Unificação do UserModel

Durante o desenvolvimento, percebi que o `AuthModel` e o modelo de usuário iriam ficar exatamente iguais e percebi que não fazia sentido manter separado, nisso foram unificados em um único `UserModel` em `features/shared/`. Isso eliminou duplicação de código e tornou o modelo acessível para auth, perfil e admin sem dependências cruzadas entre features.

### Controle de Acesso por Role no Client

A API não impõe restrições por role. O controle é feito inteiramente no client:

- O `GoRouter` redireciona moderators que tentam acessar `/users` para `/dashboard`
- O `MainShell` oculta o item "Usuários" da bottom nav para moderators
- O `UsersScreen` só é instanciado para admins

### Tema Persistido no Banco

A preferência de tema (claro/escuro) é salva na `SettingsTable` do Drift via `ThemeCubit`, garantindo que a escolha do usuário persista entre sessões sem dependência de `SharedPreferences`.

### Cores de Avatar Geradas Automaticamente

As cores dos avatares de usuários são geradas a partir do `userId` usando o ângulo dourado (137.5°) no espaço HSL. Isso garante cores visualmente distintas e consistentes para cada usuário sem necessidade de lista fixa ou escolha manual.

### Carregando imagens do usuário

Imagens de usuário agora são carregadas na tela de admin(usuários) e Perfil aonde caso não tenha imagem irá mostrar a inicial do usuário no local da imagem.

### Mudança no layout da tela de admin

Acreditei que a tela de admin caso esteja sem internet não iria retornar os usuário e por ser uma tela que necessita de internet, decidi que caso esteja sem conexão iria mostrar um container com infomações para verificar a conexão

---

## Dependências Principais

| Pacote                   | Uso                                      |
|--------------------------|------------------------------------------|
| `flutter_bloc`           | Gerenciamento de estado                  |
| `get_it`                 | Injeção de dependência                   |
| `go_router`              | Navegação declarativa                    |
| `drift`                  | Banco de dados local (SQLite)            |
| `dio`                    | Cliente HTTP com interceptores           |
| `flutter_secure_storage` | Armazenamento seguro de tokens JWT       |
| `freezed`                | Classes imutáveis e union types          |
| `json_serializable`      | Serialização/deserialização JSON         |
| `bloc_test`              | Testes unitários de BLoCs                |
| `mocktail`               | Mocks para testes                        |

## O que eu faria diferente com mais tempo

- Testes de widget para as telas principais
- Animações de transição entre rotas
- Suporte a biometria no login
