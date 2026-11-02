# Teoria da modulação em frequência (FM)

## 1. Introdução

A modulação em frequência, ou **FM** (*Frequency Modulation*), é uma forma de
modulação angular. Nela, a informação contida no sinal de mensagem altera a
frequência instantânea de uma portadora, enquanto a amplitude ideal da
portadora permanece constante.

A FM é utilizada em radiodifusão, telemetria, comunicação de voz e diversos
sistemas digitais e analógicos. Entre suas características estão:

- maior imunidade a ruídos que afetam a amplitude;
- envoltória idealmente constante;
- possibilidade de uso de amplificadores de potência não lineares e
  eficientes;
- ocupação de banda maior que a da modulação em amplitude, dependendo do
  desvio de frequência e da largura de banda da mensagem.

Neste projeto, a teoria será inicialmente aplicada a sinais em ponto flutuante
no MATLAB R2013a. Em etapas posteriores, o modelo será convertido para ponto
fixo e utilizado como referência para a implementação em VHDL no FPGA
Cyclone V.

## 2. Sinal portador

Uma portadora senoidal sem modulação pode ser escrita como

```text
c(t) = Ac cos(2*pi*fc*t + phi0)
```

onde:

- `Ac` é a amplitude da portadora;
- `fc` é a frequência da portadora, em hertz;
- `phi0` é a fase inicial, em radianos;
- `t` é o tempo, em segundos.

A fase total da portadora é

```text
theta(t) = 2*pi*fc*t + phi0
```

A frequência instantânea de qualquer sinal com fase `theta(t)` é dada por

```text
fi(t) = (1/(2*pi)) * d(theta(t))/dt
```

Para a portadora não modulada, a derivada da fase é constante e, portanto,
`fi(t) = fc`.

## 3. Definição matemática da FM

Seja `m(t)` o sinal de mensagem normalizado. Na modulação FM, a frequência
instantânea é

```text
fi(t) = fc + kf*m(t)
```

onde `kf` é a sensibilidade do modulador em `Hz/unidade`. A variação em torno
de `fc` é denominada desvio instantâneo de frequência:

```text
delta_f(t) = fi(t) - fc = kf*m(t)
```

O desvio de frequência de pico é

```text
Delta_f = kf * max(abs(m(t)))
```

Como a frequência é a derivada da fase, a fase do sinal FM precisa conter a
integral da mensagem:

```text
theta_FM(t) = 2*pi*fc*t + 2*pi*kf*integral(m(tau) d(tau)) + phi0
```

Assim, o sinal FM é

```text
s_FM(t) = Ac cos(theta_FM(t))
```

ou, explicitamente,

```text
s_FM(t) = Ac cos(2*pi*fc*t
                 + 2*pi*kf*integral(m(tau) d(tau))
                 + phi0)
```

Essa integral é essencial. Somar diretamente a mensagem à fase sem integrá-la
produz modulação de fase, e não modulação em frequência.

## 4. FM e PM

FM e PM pertencem à família das modulações angulares, mas não são idênticas.

Na modulação de fase, ou PM:

```text
s_PM(t) = Ac cos(2*pi*fc*t + kp*m(t))
```

Na modulação em frequência:

```text
s_FM(t) = Ac cos(2*pi*fc*t + 2*pi*kf*integral(m(tau) d(tau)))
```

Consequentemente:

- em PM, a fase é proporcional à mensagem;
- em FM, a frequência instantânea é proporcional à mensagem;
- um modulador de fase precedido por um integrador pode produzir FM;
- um modulador FM precedido por um diferenciador pode produzir PM.

## 5. Modulação por uma mensagem senoidal

Considere uma mensagem senoidal normalizada:

```text
m(t) = Am cos(2*pi*fm*t)
```

O desvio de pico será

```text
Delta_f = kf*Am
```

Integrando a mensagem e substituindo-a na expressão de FM:

```text
s_FM(t) = Ac cos(2*pi*fc*t + beta sin(2*pi*fm*t))
```

O parâmetro `beta` é o índice de modulação FM:

```text
beta = Delta_f/fm
```

O índice indica o quanto a frequência da portadora se desvia em relação à
frequência da mensagem. Para uma mensagem composta por várias frequências, o
índice máximo costuma ser relacionado ao desvio de pico e à maior frequência
significativa da mensagem.

## 6. FM de banda estreita e de banda larga

Uma classificação teórica comum é:

- **FM de banda estreita (NBFM):** `beta << 1`;
- **FM de banda larga (WBFM):** `beta > 1`.

Para `beta` pequeno, podem-se utilizar aproximações trigonométricas que fazem o
espectro se parecer com uma portadora acompanhada por um par principal de
bandas laterais. Quando `beta` aumenta, surgem vários pares de bandas laterais
significativas.

A distinção não deve ser interpretada como uma fronteira normativa exata. Ela
serve para selecionar aproximações matemáticas e compreender a ocupação
espectral.

## 7. Espectro e funções de Bessel

Para uma mensagem senoidal, o sinal FM pode ser expandido em uma série cujas
amplitudes são determinadas pelas funções de Bessel de primeira espécie:

```text
s_FM(t) = Ac * soma de n=-infinito até infinito de
          Jn(beta) cos(2*pi*(fc + n*fm)*t)
```

O espectro contém componentes em

```text
fc, fc +/- fm, fc +/- 2*fm, fc +/- 3*fm, ...
```

As amplitudes relativas são dadas por `Jn(beta)`. Em teoria, uma FM senoidal
possui infinitas bandas laterais. Na prática, somente um número finito delas
tem amplitude relevante.

Algumas consequências importantes são:

- a amplitude da componente em `fc` é proporcional a `J0(beta)`;
- a componente central pode desaparecer para determinados valores de `beta`;
- a potência total permanece constante no modelo ideal, mas é redistribuída
  entre a portadora e as bandas laterais;
- aumentar `beta` normalmente aumenta a quantidade de bandas laterais
  relevantes.

## 8. Regra de Carson

A regra de Carson fornece uma estimativa prática da largura de banda que
concentra a maior parte da potência de um sinal FM:

```text
B_FM aproximadamente 2*(Delta_f + Bm)
```

onde:

- `Delta_f` é o desvio de frequência de pico;
- `Bm` é a maior frequência significativa da mensagem.

Exemplo: para `Delta_f = 75 kHz` e `Bm = 15 kHz`, tem-se

```text
B_FM aproximadamente 2*(75 kHz + 15 kHz) = 180 kHz
```

A regra de Carson é uma aproximação de engenharia, não uma máscara espectral.
Limites de canal, níveis do sinal MPX e requisitos de emissão devem ser
verificados na regulamentação aplicável antes de qualquer transmissão real.

## 9. Potência e envoltória

No modelo ideal,

```text
s_FM(t) = Ac cos(theta_FM(t))
```

tem amplitude constante `Ac`. Assim, a potência média sobre uma carga
normalizada é proporcional a

```text
Pmedia = Ac^2/2
```

e não depende do índice de modulação. A modulação redistribui a potência no
espectro, mas não altera a potência total do sinal ideal.

Essa envoltória constante permite que sistemas FM utilizem limitadores de
amplitude no receptor e amplificadores de potência eficientes. Entretanto,
imperfeições de hardware, filtros e quantização podem introduzir variações de
amplitude.

## 10. Representação complexa em banda-base

Não é necessário amostrar diretamente uma portadora de aproximadamente
`100 MHz` para estudar a modulação. O sinal FM pode ser representado por sua
envoltória complexa:

```text
x_BB(t) = Ac exp(j*phi(t))
```

com

```text
phi(t) = 2*pi*kf*integral(m(tau) d(tau))
```

O sinal passabanda correspondente seria

```text
s_FM(t) = real{x_BB(t) * exp(j*2*pi*fc*t)}
```

Na representação complexa em banda-base:

```text
I(t) = Ac cos(phi(t))
Q(t) = Ac sin(phi(t))
```

Essa forma é especialmente conveniente para o MATLAB e para arquiteturas
digitais, pois separa o estudo da modulação da geração analógica da portadora
de RF.

## 11. Modelo em tempo discreto

Para uma frequência de amostragem `Fs`, define-se

```text
Ts = 1/Fs
```

A fase pode ser acumulada amostra a amostra:

```text
phi[n] = phi[n-1] + 2*pi*kf*m[n]/Fs
```

O sinal complexo em banda-base é então

```text
x[n] = exp(j*phi[n])
```

Se for utilizada uma portadora discreta compatível com `Fs`:

```text
theta[n] = theta[n-1] + 2*pi*(fc + kf*m[n])/Fs
s[n] = Ac*cos(theta[n])
```

O acumulador de fase pode crescer indefinidamente na formulação matemática.
Em software ou hardware, a fase pode ser mantida em um intervalo equivalente,
como `[0, 2*pi)`, pois seno e cosseno são periódicos.

### 11.1 Restrição de amostragem

Em uma representação passabanda real, é necessário escolher `Fs` de modo que
as frequências de interesse possam ser representadas sem aliasing e com margem
para os filtros. Não é possível representar diretamente uma portadora de
`100 MHz` com `Fs = 384 kS/s` por amostragem convencional.

No projeto, `384 kS/s` é uma taxa inicial para o sinal MPX e para uma
representação complexa em banda-base. A taxa final do FPGA dependerá da
arquitetura, dos clocks, dos conversores e da interface de RF selecionada.

## 12. Demodulação FM

O objetivo do demodulador é estimar a frequência instantânea e recuperar uma
grandeza proporcional à mensagem:

```text
m_estimado(t) = (fi(t) - fc)/kf
```

Existem diferentes métodos de demodulação.

### 12.1 Derivada da fase

Para um sinal analítico ou complexo:

```text
phi(t) = unwrap(angle(x(t)))
fi(t) = (1/(2*pi))*d(phi(t))/dt
```

Em tempo discreto:

```text
fi[n] aproximadamente Fs/(2*pi) * (phi[n] - phi[n-1])
```

O desempacotamento de fase (*unwrap*) evita saltos artificiais de `2*pi`.

### 12.2 Diferença de fase entre amostras

Uma forma adequada para sinais complexos é

```text
delta_phi[n] = angle(x[n] * conj(x[n-1]))
```

Logo,

```text
delta_f[n] = Fs*delta_phi[n]/(2*pi)
m_estimado[n] = delta_f[n]/kf
```

Esse método evita calcular separadamente a fase absoluta e seu *unwrap*. Ele é
uma referência útil para uma futura arquitetura em hardware.

### 12.3 Outros métodos

Também podem ser empregados:

- discriminador em quadratura;
- detector baseado em PLL;
- detector de cruzamento por zero;
- filtros ou redes com resposta dependente da frequência.

A escolha depende da representação do sinal, do desempenho desejado e dos
recursos disponíveis.

## 13. Pré-ênfase e de-ênfase

Em radiodifusão FM, o ruído demodulado tende a crescer nas frequências mais
altas. A pré-ênfase reforça as componentes de alta frequência do áudio antes
da modulação. O receptor aplica uma de-ênfase complementar para restaurar a
resposta do áudio e reduzir o ruído de alta frequência.

Uma rede analógica de de-ênfase de primeira ordem pode ser representada por

```text
H_de(s) = 1/(1 + s*tau)
```

com frequência de transição

```text
f0 = 1/(2*pi*tau)
```

O valor de `tau` depende do padrão adotado. Ele deve ser um parâmetro do
projeto, e não um número fixado em vários blocos. A discretização deverá levar
em conta `Fs`, precisão numérica, resposta desejada e compatibilidade entre o
modelo MATLAB e o VHDL.

## 14. FM mono, estéreo e sinal MPX

É importante separar dois processos:

1. construção do sinal composto de banda-base, chamado MPX;
2. modulação em frequência da portadora usando o MPX como mensagem.

No caso mono, o áudio condicionado pode modular diretamente a frequência. No
caso estéreo, a mensagem do modulador FM é o sinal MPX, que pode conter:

- `L+R` na faixa de áudio;
- piloto em `19 kHz`;
- `L-R` em DSB-SC ao redor de `38 kHz`;
- RDS centrado em `57 kHz`;
- subcanais auxiliares, quando aplicáveis.

Assim, o piloto de `19 kHz` e as subportadoras fazem parte da mensagem composta
e não são a portadora de RF do transmissor.

## 15. Ruído, limiar e efeito de captura

Como a informação está na frequência instantânea, variações moderadas de
amplitude podem ser removidas por um limitador antes da demodulação. Isso
contribui para a imunidade da FM a ruídos de amplitude.

Entretanto, essa vantagem não é ilimitada:

- abaixo de determinada relação sinal-ruído, a qualidade pode piorar
  rapidamente, fenômeno conhecido como efeito de limiar;
- sinais impulsivos podem causar grandes erros instantâneos de fase;
- em presença de dois sinais na mesma frequência, o receptor FM tende a
  favorecer o sinal mais forte, fenômeno chamado efeito de captura;
- erros de oscilador e deslocamento de frequência aparecem como componentes
  constantes ou lentas na saída do discriminador.

## 16. Considerações para ponto fixo e FPGA

Uma implementação em VHDL exigirá decisões que não aparecem no modelo ideal:

- largura do acumulador de fase;
- resolução da palavra de controle de frequência;
- representação com ou sem sinal;
- largura e escala da mensagem;
- arredondamento ou truncamento;
- saturação ou retorno modular em caso de overflow;
- geração de seno e cosseno por LUT, CORDIC ou outra técnica;
- latência e sinais de `valid`, `enable` e `reset`;
- relação entre clock do sistema e taxa das amostras.

Para um NCO com acumulador de `N` bits e clock ou taxa de atualização `Fclk`, a
resolução ideal de frequência é aproximadamente

```text
Delta_f_NCO = Fclk/(2^N)
```

Uma palavra de incremento `K` gera, idealmente,

```text
fout = K*Fclk/(2^N)
```

Na FM digital, a mensagem escalada altera essa palavra de incremento. A escala
deve ser escolhida de forma que o valor máximo da mensagem corresponda ao
desvio de frequência especificado.

## 17. Medições essenciais no modelo MATLAB

O primeiro experimento deve permitir medir e verificar:

1. mensagem no domínio do tempo;
2. fase acumulada;
3. sinal FM real ou complexo;
4. frequência instantânea;
5. desvio de pico medido;
6. espectro e bandas laterais;
7. estimativa de largura de banda pela regra de Carson;
8. mensagem recuperada pelo demodulador;
9. erro entre a mensagem original e a recuperada;
10. efeito da frequência de amostragem e da quantização.

Para um teste senoidal, os resultados devem confirmar aproximadamente:

```text
max(abs(fi(t) - fc)) = Delta_f
beta = Delta_f/fm
B_FM aproximadamente 2*(Delta_f + fm)
```

## 18. Sequência sugerida de estudo

1. Gerar e analisar uma senoide sem modulação.
2. Implementar um acumulador de fase em tempo discreto.
3. Modular uma mensagem senoidal em banda-base complexa.
4. Calcular a frequência instantânea do sinal gerado.
5. Comparar o desvio configurado com o desvio medido.
6. Observar as bandas laterais para diferentes valores de `beta`.
7. Implementar o demodulador por diferença de fase.
8. Comparar a mensagem original com a recuperada.
9. Adicionar filtragem, pré-ênfase e de-ênfase.
10. Repetir o experimento com quantização em ponto fixo.

Essa sequência estabelece a base necessária para construir o modulador FM
mono, validar o sinal MPX e posteriormente definir a arquitetura sintetizável
em VHDL.
