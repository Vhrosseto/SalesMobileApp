<h1 align="center">SalesMobile</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
</p>

<p align="center">
  SalesMobile é um aplicativo de força de vendas desenvolvido em Flutter para gerenciamento de clientes, produtos e usuários.
</p>

<h2>🚀 Funcionalidades</h2>

<h3>Autenticação de Usuários</h3>
<ul>
  <li>Login seguro</li>
  <li>Gerenciamento de usuários (criar, editar, excluir)</li>
  <li>Acesso administrativo padrão (admin/admin)</li>
</ul>

<h3>Gerenciamento de Clientes</h3>
<ul>
  <li>Cadastro de clientes físicos e jurídicos</li>
  <li>Informações completas (nome, CPF/CNPJ, contato, endereço)</li>
  <li>Edição e exclusão de clientes</li>
</ul>

<h3>Gerenciamento de Produtos</h3>
<ul>
  <li>Cadastro de produtos com múltiplas unidades (un, cx, kg, lt, ml)</li>
  <li>Controle de estoque</li>
  <li>Preço de venda e custo</li>
  <li>Código de barras</li>
  <li>Status ativo/inativo</li>
</ul>

<h2>🛠️ Tecnologias Utilizadas</h2>
<ul>
  <li>Flutter</li>
  <li>Dart</li>
  <li>path_provider (para armazenamento local)</li>
  <li>JSON (para persistência de dados)</li>
</ul>

<h2>📱 Interface</h2>
<ul>
  <li>Design moderno e intuitivo</li>
  <li>Tema escuro</li>
  <li>Navegação por bottom navigation bar</li>
  <li>Formulários com validação</li>
  <li>Tabelas para visualização de dados</li>
</ul>

<h2>🔧 Instalação</h2>

<ol>
  <li>
    Clone o repositório:
    <pre><code>git clone [URL_DO_REPOSITÓRIO]</code></pre>
  </li>
  <li>
    Instale as dependências:
    <pre><code>flutter pub get</code></pre>
  </li>
  <li>
    Execute o aplicativo:
    <pre><code>flutter run</code></pre>
  </li>
</ol>

<h2>📦 Estrutura do Projeto</h2>

<pre>
lib/
├── controllers/
│   ├── cliente_controller.dart
│   ├── produto_controller.dart
│   └── usuario_controller.dart
├── models/
│   ├── cliente.dart
│   ├── produto.dart
│   └── usuario.dart
├── screens/
│   ├── clientes_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── produtos_screen.dart
│   └── usuarios_screen.dart
└── main.dart
</pre>

<h2>🔐 Credenciais Padrão</h2>

<ul>
  <li>
    <strong>Usuário Administrador</strong>
    <ul>
      <li>Login: admin</li>
      <li>Senha: admin</li>
    </ul>
  </li>
</ul>

<h2>📝 Observações</h2>
<ul>
  <li>Os dados são armazenados localmente no dispositivo</li>
  <li>O aplicativo utiliza JSON para persistência de dados</li>
</ul>

<h2>👥 Desenvolvedores</h2>
<table>
  <tr>
    <th>Nome</th>
    <th>Matrícula</th>
  </tr>
  <tr>
    <td>Victor Hugo Paulo Rosseto</td>
    <td>123100013</td>
  </tr>
  <tr>
    <td>Gabriel Dondoni Pecly</td>
    <td>123100010</td>
  </tr>
</table>
