# FM Transmitter — MATLAB & FPGA (VHDL)

Projeto educacional para estudar, modelar, verificar e futuramente implementar um transmissor FM mono/estéreo, com MPX, piloto estéreo, RDS e SCA. O **MATLAB R2013a** será usado como modelo de referência e **VHDL** como linguagem de implementação em FPGA.

> **Status:** planejamento e estrutura inicial. Os blocos serão desenvolvidos incrementalmente. Este repositório não representa um transmissor pronto para uso em RF.

## 1. Objetivos

- Estudar DSP aplicado à radiodifusão FM.
- Construir um modelo de referência em MATLAB R2013a.
- Gerar e analisar o sinal composto MPX.
- Implementar blocos selecionados em VHDL.
- Validar o RTL com testbenches e vetores gerados pelo MATLAB.
- Estudar quantização, ponto fixo, largura de palavra, saturação e overflow.
- Preparar uma base para futura implementação em FPGA.

## 2. Arquitetura geral

```text
 AUDIO L ─► DC BLOCK ─► LPF / PRE-EMPHASIS ─┐
                                            │
 AUDIO R ─► DC BLOCK ─► LPF / PRE-EMPHASIS ─┤
                                            ▼
                                     STEREO ENCODER
                                     ├─ L+R (0–15 kHz)
                                     ├─ L-R DSB-SC (38 kHz)
                                     └─ PILOT (19 kHz)
                                            │
 RDS DATA ─► RDS ENCODER ─► 57 kHz ──────────┤
                                            │
 SCA DATA/AUDIO ─► SCA MODULATOR ────────────┤
                                            ▼
                                       MPX COMBINER
                                            │
                                       MPX CONDITIONING
                                            │
                                            ▼
                                        FM MODULATOR
                                            │
                                            ▼
                                    FM BASEBAND SIGNAL
```

Receptor de referência para validação:

```text
FM SIGNAL ─► FM DEMODULATOR ─► RECOVERED MPX
                                      │
                  ┌───────────────────┼──────────────────┐
                  ▼                   ▼                  ▼
            STEREO DECODER        RDS DECODER        SCA DECODER
                  │
               AUDIO L/R
```

## 3. Componentes do MPX

| Componente | Faixa/frequência típica | Função |
|---|---:|---|
| L+R | 0–15 kHz | Informação mono |
| Piloto estéreo | 19 kHz | Referência para regeneração de 38 kHz |
| L-R | bandas laterais em torno de 38 kHz | Informação estéreo diferencial |
| RDS | centrado em 57 kHz | Dados da estação |
| SCA | depende do serviço | Subcanal auxiliar |

O sinal estéreo básico combina L+R, piloto e L-R em DSB-SC. RDS e SCA serão adicionados em etapas posteriores. Níveis, tolerâncias, filtros, pré-ênfase, desvio e requisitos espectrais deverão ser parametrizados e confirmados conforme a norma/regulamentação aplicável.

## 4. Amostragem e modelagem

**384 kS/s** é um ponto de partida conveniente para simular o MPX até componentes abaixo da frequência de Nyquist (192 kHz), incluindo subportadoras de estudo em 67 kHz e 92 kHz.

Atenção:
- 384 kS/s é adequada para o modelo de banda-base MPX descrito, desde que o projeto dos filtros respeite Nyquist.
- Essa taxa não permite representar diretamente uma portadora RF de, por exemplo, 100 MHz por amostragem convencional.
- Para estudar FM inicialmente, usar representação em **banda-base complexa** ou portadora reduzida compatível com Fs.
- Para uma portadora real em frequência intermediária, escolher Fs considerando a maior frequência representada e a margem dos filtros.
- A taxa e o formato de amostra do FPGA serão definidos conforme placa, clock, interfaces e recursos disponíveis.
- A taxa de amostragem do aúdio deverá ser 48kHz.

## 5. Cronograma de desenvolvimento

### Fase 0 — Especificação e ambiente
- Definir placa FPGA, ferramentas de síntese/simulação e versão VHDL.
- Definir Fs, clocks, interfaces e formatos numéricos.
- Registrar requisitos de nível, banda, desvio e máscara espectral.
- Definir convenções e formatos dos vetores de teste.

**Entrega:** requisitos e parâmetros documentados em `docs/`.

### Fase 1 — Fundamentos de DSP
- Amostragem, Nyquist e aliasing.
- Senoides, fase, frequência e frequência instantânea.
- FFT, espectro e espectrograma.
- Filtros FIR/IIR, resposta em frequência e estabilidade.
- Quantização, ponto fixo, SNR, overflow e saturação.

**Entrega:** scripts MATLAB e notas teóricas.

### Fase 2 — Cadeia de áudio
- Gerar sinais de teste e importar áudio.
- Remover offset DC.
- Projetar LPF de áudio.
- Implementar pré-ênfase.
- Avaliar níveis, pico e RMS.

**Entrega:** cadeia de áudio testada.

### Fase 3 — FM mono
- Implementar modulador FM.
- Controlar sensibilidade e desvio.
- Implementar demodulador para teste.
- Medir frequência instantânea, desvio e espectro.
- Estudar largura de banda e regra de Carson.

**Entrega:** loop FM mono validado.

### Fase 4 — Encoder estéreo e MPX
- Gerar L+R.
- Gerar piloto de 19 kHz.
- Gerar L-R com DSB-SC em 38 kHz.
- Somar e analisar o MPX.
- Implementar decodificador e recuperar L/R.

**Entrega:** encoder/decoder estéreo verificados.

### Fase 5 — RDS
- Estudar grupos e blocos RDS.
- Implementar PI, PS, PTY, RT e campos necessários.
- Implementar checkword/CRC conforme especificação.
- Implementar codificação diferencial e de linha.
- Gerar subportadora de 57 kHz e validar a recuperação dos dados.

**Entrega:** gerador e testes de decodificação RDS.

### Fase 6 — SCA
- Definir serviço e método de modulação a estudar.
- Implementar geração de dados/áudio, modulação e filtragem.
- Avaliar interferência e ocupação espectral.
- Integrar ao MPX.

**Entrega:** bloco SCA parametrizado.

### Fase 7 — MPX completo
- Integrar estéreo, piloto, RDS e SCA.
- Controlar níveis relativos.
- Verificar espectro, picos e excursão.
- Conferir requisitos aplicáveis.

**Entrega:** gerador MPX completo em MATLAB.

### Fase 8 — Modelo fixed-point
- Definir larguras de palavra e posição do ponto binário.
- Quantizar sinais e coeficientes.
- Avaliar arredondamento, truncamento, saturação e overflow.
- Comparar floating-point e fixed-point.
- Exportar vetores para VHDL.

**Entrega:** modelo fixed-point e vetores de referência.

### Fase 9 — Implementação VHDL
Implementar incrementalmente:
- NCOs/geradores de seno e cosseno;
- filtros e DC blocker;
- caminhos L+R e L-R;
- piloto e combinador MPX;
- RDS;
- SCA;
- modulador/demodulador ou interface com o bloco de RF escolhido.

Cada bloco deve possuir interface documentada, parâmetros, testbench e resultados de simulação.

**Entrega:** RTL sintetizável e testbenches por bloco.

### Fase 10 — Integração e FPGA
- Integrar os blocos no top-level.
- Verificar clocks, resets, temporização e interfaces.
- Comparar saídas RTL com vetores MATLAB.
- Executar testes em hardware após definir a plataforma.
- Documentar limitações e resultados.

**Entrega:** protótipo FPGA validado dentro do escopo implementado.

## 6. Estrutura do repositório

```text
FM_Transmitter/
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── architecture/
│   ├── theory/
│   └── verification/
├── matlab/
│   ├── src/
│   │   ├── audio/
│   │   ├── stereo/
│   │   ├── rds/
│   │   ├── sca/
│   │   ├── mpx/
│   │   ├── fm/
│   │   ├── receiver/
│   │   ├── filters/
│   │   └── utils/
│   ├── tests/
│   ├── scripts/
│   └── test_vectors/
├── fpga/
│   ├── rtl/
│   │   ├── common/
│   │   ├── audio/
│   │   ├── stereo/
│   │   ├── rds/
│   │   ├── sca/
│   │   ├── mpx/
│   │   └── fm/
│   ├── tb/
│   ├── sim/
│   ├── constraints/
│   ├── scripts/
│   └── ip/
├── test_vectors/
│   ├── audio/
│   ├── mpx/
│   ├── rds/
│   └── fm/
└── tools/
```

### Responsabilidade dos diretórios

| Diretório | Conteúdo |
|---|---|
| `docs/` | Diagramas, requisitos, teoria e decisões de arquitetura |
| `matlab/src/` | Funções MATLAB reutilizáveis |
| `matlab/tests/` | Testes e validações MATLAB |
| `matlab/scripts/` | Scripts de demonstração/execução |
| `matlab/test_vectors/` | Vetores gerados pelo MATLAB |
| `fpga/rtl/` | VHDL sintetizável |
| `fpga/tb/` | Testbenches VHDL |
| `fpga/sim/` | Scripts e configurações de simulação |
| `fpga/constraints/` | Pinos, clocks e timing |
| `fpga/scripts/` | Automação de compilação e síntese |
| `fpga/ip/` | IPs e wrappers, respeitando licenças |
| `test_vectors/` | Vetores compartilhados entre MATLAB e FPGA |
| `tools/` | Utilitários de conversão e análise |

## 7. Estratégia de validação MATLAB × VHDL

O MATLAB será o modelo de referência:

```text
MATLAB floating-point
          │
          ▼
MATLAB fixed-point
          │
          ▼
Exportação (.txt / .hex / .bin)
          │
          ▼
VHDL testbench
          │
          ▼
Simulação RTL
          │
          ▼
Comparação dos resultados
```

Para cada bloco, documentar:
- taxa de amostragem e clock;
- largura e formato dos dados;
- latência;
- reset e enable;
- arredondamento/truncamento;
- saturação/overflow;
- tolerância de comparação;
- arquivos de entrada e saída do teste.

Não comparar diretamente floating-point com RTL fixed-point sem definir escalas, arredondamento e tolerâncias.

## 8. Convenções

- Nomes de arquivos e funções em `snake_case`.
- Usar unidades explícitas: `Hz`, `kHz`, `S/s`, `dB`, `dBFS`.
- Centralizar parâmetros configuráveis.
- Documentar interfaces, entradas, saídas, parâmetros e testes de cada bloco.
- Evitar duplicação não controlada de parâmetros entre MATLAB e VHDL.
- Manter artefatos de compilação fora do Git, exceto evidências selecionadas e reproduzíveis.

## 9. Arquivos que normalmente não devem ir para o Git

- Temporários e cache do MATLAB.
- Resultados de compilação/síntese.
- Diretórios Quartus `db/`, `incremental_db/` e `output_files/`.
- Waveforms grandes, exceto amostras úteis para regressão.
- IPs proprietários que não possam ser redistribuídos.
- Áudios protegidos por direitos autorais.

Versionar vetores pequenos e relevantes. Para arquivos grandes, avaliar Git LFS ou documentar como regenerá-los.

## 10. Primeiro marco: FM mono em MATLAB

```text
Sinal de áudio
      │
      ▼
Remoção de DC
      │
      ▼
Filtro passa-baixas
      │
      ▼
Pré-ênfase
      │
      ▼
Modulador FM
      │
      ▼
Demodulador FM
      │
      ▼
Áudio recuperado
```

Critérios de conclusão:
1. Gráficos no domínio do tempo.
2. FFT antes/depois dos filtros.
3. Forma de onda FM ou representação complexa em banda-base.
4. Frequência instantânea calculada.
5. Desvio de frequência medido.
6. Comparação do áudio original e recuperado.
7. Testes repetíveis com parâmetros documentados.

Depois desse marco, avançar para encoder estéreo e MPX.

## 11. Observação sobre RF

Este é inicialmente um projeto de estudo e validação. Antes de qualquer transmissão em RF, devem ser observadas as normas técnicas e regulamentações aplicáveis, limites de emissão, autorização de operação, filtragem e requisitos do equipamento. Os parâmetros deste README são referências iniciais e devem ser confirmados para o padrão e serviço escolhidos.
