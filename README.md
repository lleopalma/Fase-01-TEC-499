<h1 align="center">Coprocessador gráfico especializado em redimensionamento de imagens</h1>

<h2>Descrição do Projeto</h2>
<p>
Para o desenvolvimento do projeto, foi utilizado o kit de desenvolvimento DE1-SoC, equipado com o processador Cyclone V, possibilitando a leitura e escrita de dados diretamente na memória SDRAM do dispositivo. O ambiente de desenvolvimento adotado foi o Intel Quartus Prime Lite 23.1, utilizando a linguagem de descrição de hardware Verilog. O objetivo do projeto é implementar o redimensionamento de imagens por meio de algoritmos de zoom in e zoom out, operações fundamentais em sistemas de processamento digital de imagens por permitirem ajustar a escala de exibição, melhorar a análise visual e atender aplicações como compressão de dados, reconhecimento de padrões, visão computacional embarcada, processamento em tempo real e interfaces gráficas.

<div align="center">
    <img src="imagens/placa.jpg"><br>
    <strong>Imagem do Site da Altera</strong><br><br>
</div>

O coprocessador é capaz de lidar com os seguintes algoritmos de redimensionamento: 

* Replicação de Pixel (Zoom-in)
* Vizinho mais próximo( Zoom-in)
* Vizinho mais próximo/Decimação (Zoom-out)
* Média de Blocos (Zoom-out)

Sumário
=================
<!--ts-->   
   * [Arquitetura do Projeto](#arquitetura)
   * [Máquina de Estados](#maquina-de-estados)
      * [IDLE](#idle)
      * [READ_ROM](#read)
      * [WRITE_RAM](#write)
      * [DECODE](#resize)
      * [MEMORY](#memory)
      * [DONE](#done)
   * [Unidade Lógica e Aritmética (ULA)](#ula)
      * [Replicação de Pixel (Zoom_in)](#rep_pixel)
      * [Vizinho mais próximo (Zoom-in)](#nn_zoomin)
      * [Decimação/Vizinho mais próximo (Zoom-out)](#dec)
      * [Média de Blocos(Zoom-out)](#media)
   * [Referências](#referencias)

<div>
  <h2 id="arquitetura">Arquitetura do Projeto</h2>
  <p>
  O coprocessador foi desenvolvido utilizando módulos em Verilog que interagem entre si para realizar a leitura da ROM, escrita na RAM e processamento por algoritmos de redimensionamento. A arquitetura é composta pelos módulos principais: <strong>ROM</strong>, <strong>RAM</strong>, <strong>Unidade de Controle</strong> e <strong>Unidade Lógica e Aritmética (ULA)</strong>.
  </p>
</div>

<div>
  <h2 id="maquina-de-estados">Máquina de Estados</h2>
  <p>
  A máquina de estados é responsável por coordenar as operações de leitura, processamento e escrita de dados entre a ROM e a RAM. Abaixo estão os estados planejados para o fluxo:
  </p>

  <h3 id="idle">IDLE</h3>
  <p>Estado inicial, aguardando alteração de imagem ou comando de processamento.</p>

  <h3 id="read">READ_ROM</h3>
  <p>Realiza a leitura da imagem a partir da memória ROM.</p>

  <h3 id="write">WRITE_RAM</h3>
  <p>Escreve a imagem na RAM após leitura e/ou processamento.</p>

  <h3 id="resize">DECODE</h3>
  <p>Executa os algoritmos de redimensionamento (zoom in ou zoom out), caso habilitado.</p>

  <h3 id="memory">MEMORY</h3>
  <p>Confirma a integridade da operação de escrita na RAM.</p>

  <h3 id="done">DONE</h3>
  <p>Finaliza o ciclo e retorna ao estado IDLE.</p>
</div>

<div>
  <h2 id="ula">Unidade Lógica e Aritmética (ULA)</h2>
  <p>
  A ULA do coprocessador é responsável por aplicar os algoritmos de redimensionamento sobre a imagem.
  Abaixo estão descritas as técnicas utilizadas:
  </p>

<h3 id="rep_pixel">Replicação de Pixel (Zoom-in)</h3>
<p>O módulo implementa o algoritmo de <b>Zoom-in por replicação de pixels</b>, uma técnica simples e eficiente para ampliar imagens digitais.  

#### ⚙️ Funcionamento
- A imagem original é armazenada na **ROM** com dimensões <code>LARGURA × ALTURA</code>.  
- Cada pixel é copiado várias vezes em sequência, formando um bloco de tamanho <code>FATOR × FATOR</code> na imagem de saída.  
- Assim, a resolução final é multiplicada pelo fator escolhido. Exemplo: com <code>FATOR = 2</code>, uma imagem de <code>160 × 120</code> se torna <code>320 × 240</code>.  

#### 🔄 Lógica do processo
1. A imagem é percorrida pixel a pixel na ordem de linhas e colunas.  
2. Cada pixel é replicado para gerar um bloco ampliado na saída.  
3. Quando todos os pixels são processados, o módulo sinaliza a conclusão através de <code>done</code>.  

#### 🎯 Vantagens
- Implementação de **baixa complexidade** e rápida em hardware.  
- Preserva as cores e a estrutura da imagem original.  

#### ⚠️ Limitação
- A ampliação pode gerar uma aparência **mais quadrada ou pixelada**, principalmente em fatores maiores. </p>

<h3 id="nn_zoomin">Vizinho mais próximo (Zoom-in)</h3>
<p>O módulo implementa o algoritmo de <b>Zoom-in por vizinho mais próximo</b>, uma técnica clássica de reamostragem de imagens utilizada para aumentar a resolução.  

#### ⚙️ Funcionamento
- A imagem original está armazenada na **ROM** com dimensões <code>LARGURA × ALTURA</code>.  
- A saída é uma nova versão ampliada, armazenada na **RAM VGA**, com dimensões <code>NEW_LARG × NEW_ALTURA</code>.  
- Cada posição da imagem ampliada é associada ao pixel mais próximo da imagem original por meio de um cálculo simples de reamostragem.  

#### 🔄 Lógica do processo
1. A imagem ampliada é percorrida em todas as posições de saída.  
2. Para cada coordenada, identifica-se o pixel correspondente da imagem original mais próximo.  
3. Esse pixel é então copiado para a nova posição da saída.  
4. Ao final do processamento, o módulo indica que a ampliação está completa.  

#### 🎯 Vantagens
- Método **rápido** e de **fácil implementação**.  
- Mantém a **nitidez relativa** da imagem original.  
- Muito adequado para uso em hardware por não exigir cálculos complexos.  

#### ⚠️ Limitação
- Pode deixar a imagem com uma aparência **mais quadrada ou pixelada**, já que não aplica técnicas de suavização ou interpolação. </p>


<h3 id="dec">Decimação / Vizinho mais próximo (Zoom-out)</h3>
<p>O módulo implementa o algoritmo de <b>Zoom-out por decimação de pixels</b>, uma técnica utilizada para reduzir a resolução de imagens digitais descartando amostras.  

#### ⚙️ Funcionamento
- A imagem original está armazenada na **ROM** com dimensões <code>LARGURA × ALTURA</code> (neste projeto, <code>160 × 120</code>).  
- A nova imagem reduzida é escrita na **RAM VGA** com dimensões <code>NEW_LARG × NEW_ALTURA</code>.  
- O módulo seleciona apenas alguns pixels da entrada, pulando outros de acordo com o fator de redução definido (<code>FATOR</code>).  

#### 🔄 Lógica do processo
1. A imagem original é percorrida em passos de <code>FATOR</code> em ambas as direções (horizontal e vertical).  
2. Apenas os pixels nas posições múltiplas de <code>FATOR</code> são copiados para a saída.  
3. Assim, uma imagem de <code>160 × 120</code> com <code>FATOR = 2</code> é reduzida para <code>80 × 60</code>.  
4. Ao final, o módulo aciona o sinal <code>done</code>, indicando que a redução está concluída.  

#### 🎯 Vantagens
- Implementação **simples** e **rápida** em hardware.  
- Reduz significativamente a quantidade de dados a serem processados ou armazenados.  
- Útil em aplicações de **pré-processamento** e **compressão de imagens**.  

#### ⚠️ Limitação
- Como pixels são descartados, pode haver **perda de detalhes** visuais.  
- Linhas e bordas finas da imagem original podem desaparecer após a redução. </p>
</p>

<h3 id="media">Média de Blocos (Zoom-out)</h3>
<p>O módulo implementa o algoritmo de <b>Zoom-out por média de blocos</b>, uma técnica que reduz a resolução da imagem calculando a média dos pixels em cada região.  

#### ⚙️ Funcionamento
- A imagem original é armazenada na **ROM** com dimensões <code>LARGURA × ALTURA</code>.  
- A imagem reduzida é gerada na **RAM VGA** com dimensões <code>NEW_LARG × NEW_ALTURA</code>.  
- Para cada bloco de tamanho <code>FATOR × FATOR</code> da imagem original, o módulo calcula a **média dos valores de intensidade** e escreve um único pixel na saída.  

#### 🔄 Lógica do processo
1. A imagem é dividida em blocos de <code>FATOR × FATOR</code>.  
2. Os pixels de cada bloco são lidos e somados em um acumulador.  
3. Ao final da leitura de todos os pixels do bloco, o valor médio é calculado.  
4. Esse valor médio é armazenado na posição correspondente da imagem de saída.  
5. O processo se repete para todos os blocos até completar a imagem.  

#### 🎯 Vantagens
- Reduz a imagem de forma mais **suave** que a decimação simples.  
- Mantém mais informações globais da imagem, evitando perda brusca de detalhes.  
- Adequado para aplicações de **compressão**, **pré-processamento** e **redução de ruído**.  

#### ⚠️ Limitação
- A operação de média pode causar **perda de nitidez** em áreas com muitos detalhes.  
- Linhas ou padrões muito finos podem ficar menos visíveis após a redução. </p>
</div>


</div>

<div>
  <h2 id="referencias">Referências</h2>
    
  * PATTERSON, D. A.; HENNESSY, J. L. Computer organization and design : the hardware/software interface, ARM edition / Computer organization and design : the hardware/software interface, ARM edition.<br>
‌  * FPGAcademy. Disponível em: <https://fpgacademy.org>.<br>
  * Cyclone V Device Overview. Disponível em: <https://www.intel.com/content/www/us/en/docs/programmable/683694/current/cyclone-v-device-overview.html>.<br>
  * TECHNOLOGIES, T. Terasic - SoC Platform - Cyclone - DE1-SoC Board. Disponível em: <https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836>.<br>

  * DUNNE, Robert. Computer Architecture Tutorial Using an FPGA: ARM & Verilog Introductions. Downers Grove, Illinois: Gaul Communications, 2020. ISBN 978--970112491.<br>

</div>
