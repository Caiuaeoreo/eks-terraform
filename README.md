# 🌈 EKS e Istio: Uma Aventura na Terra de Ooo!

```
         .-.
        (o.o)
         |=|
        __|__
      //.=|=.\\
     // .=|=. \\
     \\ .=|=. //
      \\(_=_)//
       (:| |:)
        || ||
        () ()
        || ||
        || ||
       ==' '==
```

## 🗺️ Bem-vindo à Terra de Ooo!

Olá, aventureiros! Finn e Jake aqui para guiar você na incrível jornada de construir seu próprio Reino do Doce com EKS e equipá-lo com a magia do Istio Service Mesh! Assim como exploramos a Terra de Ooo, vamos explorar juntos o mundo do Kubernetes!

## 📋 Mapa da Aventura

```
/projects/eks-terraform/
├── 01-deploy-eks.sh           # Pergaminho para construir o Reino do Doce
├── 02-deploy-addons.sh        # Pergaminho para invocar os guardiões mágicos
├── 03-deploy-istio.sh         # Pergaminho para criar a rede telepática
├── 04-deploy-sample-app.sh    # Pergaminho para testar o reino com uma festa
├── cleanup-all.sh             # Pergaminho para desfazer toda a magia
├── eks/                       # Plantas do Reino do Doce
├── istio/                     # Plantas da rede telepática
├── addons/                    # Itens mágicos para o reino
└── sample-app/                # Planos para a festa de teste
```

## 🏰 Construindo o Reino do Doce (EKS)

### O Reino e suas Terras (Rede)

Assim como a Princesa Jujuba precisa de um reino bem estruturado, seu cluster EKS precisa de uma boa infraestrutura de rede!

| Componente | O que é tecnicamente | Analogia Hora de Aventura | Por que é necessário |
|------------|----------------------|---------------------------|----------------------|
| **VPC** | Virtual Private Cloud | Reino do Doce | O território onde todo seu reino existe, com fronteiras claras |
| **Subnets Públicas** | Subredes com acesso à internet | Praça do Reino | Áreas onde visitantes de outros reinos podem chegar |
| **Subnets Privadas** | Subredes sem acesso direto à internet | Laboratório Secreto da Princesa | Áreas protegidas onde ficam os segredos do reino |
| **Internet Gateway** | Gateway para internet | Portão Principal do Reino | Permite que pessoas entrem e saiam do reino |
| **NAT Gateway** | Network Address Translation | Passagem Secreta | Permite que habitantes do laboratório secreto enviem mensagens para fora sem revelar a localização |
| **Route Tables** | Tabelas de roteamento | Mapas do Reino | Mostram como ir de um lugar para outro dentro do reino |
| **Security Groups** | Grupos de segurança | Força de Segurança Doce | Decidem quem pode entrar em cada área do reino |

### Os Guardiões do Reino (IAM)

Assim como a Princesa Jujuba tem seus guardiões de confiança, seu cluster EKS precisa de papéis e permissões!

| Componente | O que é tecnicamente | Analogia Hora de Aventura | Por que é necessário |
|------------|----------------------|---------------------------|----------------------|
| **Cluster Role** | IAM Role para o cluster | Princesa Jujuba | Governa todo o reino e toma as decisões importantes |
| **Node Role** | IAM Role para os nós | Guardas Banana | Permitem que as vilas do reino acessem recursos necessários |
| **OIDC Provider** | Provedor de identidade | Distintivos Reais | Permite identificar quem é quem no reino |

### Os Construtores do Reino (Computação)

Estes são os componentes que realmente fazem o trabalho pesado, como Finn e Jake em suas aventuras!

| Componente | O que é tecnicamente | Analogia Hora de Aventura | Por que é necessário |
|------------|----------------------|---------------------------|----------------------|
| **EKS Control Plane** | Plano de controle gerenciado | Sala do Trono da Princesa | Onde todas as decisões importantes são tomadas |
| **Node Groups** | Grupos de instâncias EC2 | Vilas do Reino do Doce | Onde os habitantes (pods) vivem e trabalham |
| **Launch Template** | Modelo de lançamento | Planta de Construção da Princesa | O projeto que define como cada nova casa do reino deve ser construída |
| **Auto Scaling** | Escalabilidade automática | Fórmula de Crescimento da Princesa | Faz o reino crescer ou diminuir conforme necessário |

## 🧙‍♂️ Os Guardiões Mágicos (EKS Addons)

Assim como Finn e Jake têm itens mágicos que os ajudam em suas aventuras, seu cluster EKS precisa de addons essenciais!

| Addon | O que é tecnicamente | Analogia Hora de Aventura | Por que é necessário |
|-------|----------------------|---------------------------|----------------------|
| **CoreDNS** | Serviço de DNS | BMO | Ajuda todos a se encontrarem no reino |
| **kube-proxy** | Proxy de rede | Jake Esticando | Conecta diferentes partes do reino, esticando-se entre elas |
| **VPC CNI** | Container Network Interface | Tubos de Transporte do Doce Reino | Conecta todas as pequenas casas (pods) à estrutura principal |
| **EBS CSI Driver** | Driver de armazenamento | Bolsas Mágicas de Finn | Permite guardar tesouros que não desaparecem quando você sai de uma aventura |

## 🧠 A Rede Telepática (Istio Service Mesh)

Se o Kubernetes é seu Reino do Doce, o Istio é como a rede telepática da Princesa Jujuba que conecta e monitora todos os habitantes!

| Componente | O que é tecnicamente | Analogia Hora de Aventura | Por que é necessário |
|------------|----------------------|---------------------------|----------------------|
| **istiod** | Plano de controle do Istio | Mentalgum (Chiclete Psíquico) | O cérebro por trás da rede telepática |
| **Envoy Proxies** | Proxies sidecar | Mini-Clones de Chiclete | Cada habitante recebe um pequeno clone telepático que se comunica com o Mentalgum |
| **Gateway** | Istio Gateway | Amplificador Telepático | Controla como pensamentos de outros reinos entram na rede |
| **Virtual Services** | Regras de roteamento | Ondas Cerebrais Direcionais | Decide para onde os pensamentos devem ir |

### Observatório Mágico

| Ferramenta | O que é tecnicamente | Analogia Hora de Aventura | Por que é necessário |
|------------|----------------------|---------------------------|----------------------|
| **Kiali** | Visualização do service mesh | Olho Mágico de Glob | Permite ver todas as conexões telepáticas do reino de uma vez |
| **Prometheus** | Sistema de coleta de métricas | Diário da Princesa | Registra tudo o que acontece no reino |
| **Grafana** | Ferramenta de visualização | Tela Mágica | Transforma as anotações do diário em imagens coloridas |
| **Jaeger** | Sistema de rastreamento | Rastros de Jake | Segue o caminho de cada pensamento pela rede telepática |

## 🎉 A Festa de Teste (Aplicação com nginx)

Para testar se o reino está funcionando corretamente, vamos dar uma festa! A aplicação com nginx é como uma pequena celebração no Reino do Doce.

## 🎒 Iniciando a Aventura

Esta aventura foi projetada para ser modular, assim como os episódios de Hora de Aventura!

### 1. Construindo o Reino do Doce

```bash
./01-deploy-eks.sh
```

Este pergaminho mágico irá:
- Criar o território do Reino do Doce (VPC) com praças (subnets públicas) e laboratórios secretos (subnets privadas)
- Construir a sala do trono (EKS Control Plane)
- Estabelecer as vilas (Node Group) com min=1, desired=2, max=3 casas
- Criar um mapa mágico para chegar ao reino (kubeconfig)

### 2. Invocando os Guardiões Mágicos

```bash
./02-deploy-addons.sh
```

Este pergaminho irá invocar:
- BMO (CoreDNS)
- Jake Esticando (kube-proxy)
- Tubos de Transporte (VPC CNI)
- Bolsas Mágicas (EBS CSI Driver)

### 3. Criando a Rede Telepática

```bash
./03-deploy-istio.sh
```

Este pergaminho irá:
- Criar o Mentalgum (istiod)
- Distribuir Mini-Clones de Chiclete para todos (injeção de sidecar)
- Instalar o Observatório Mágico (Kiali, Prometheus, Grafana, Jaeger)
- Corrigir um problema com os distintivos duplicados da Força de Segurança Doce (Security Groups)

### 4. Organizando a Festa de Teste

```bash
./04-deploy-sample-app.sh
```

Este pergaminho irá:
- Preparar a festa (aplicação com nginx)
- Configurar o Amplificador Telepático (Gateway)
- Estabelecer as regras da festa (Virtual Service)
- Criar convites para a festa (URL do Gateway)

## 🔧 Problemas Conhecidos e Soluções

### Distintivos Duplicados da Força de Segurança

**Problema**: Múltiplos membros da Força de Segurança Doce com o mesmo distintivo causam confusão na entrada do reino (AWS Load Balancer Controller).

**Solução**: O pergaminho `03-deploy-istio.sh` inclui um feitiço que remove o distintivo duplicado.

## 🔭 Visitando o Reino

Após organizar a festa, você pode visitá-la:

```bash
# Convite para a festa
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "Convite para a festa: http://$GATEWAY_URL/ping"

# Observatório Mágico
istioctl dashboard kiali       # Olho Mágico de Glob
istioctl dashboard grafana     # Tela Mágica
istioctl dashboard jaeger      # Rastros de Jake
istioctl dashboard prometheus  # Diário da Princesa
```

## 🧹 Desfazendo a Magia

Quando a aventura terminar e você quiser desfazer toda a magia:

```bash
./cleanup-all.sh
```

---

*"Hora de Kubernetes, vamos nessa, com Jake o Proxy e Finn o Container, a diversão nunca vai acabar, é Hora de Kubernetes!"*
