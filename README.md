<h1 align="center">Coprocessador gráfico especializado em redimensionamento de imagens</h1>

<h2>Descrição do Projeto</h2>
<p>
Para o desenvolvimento do projeto, foi utilizado o kit de desenvolvimento DE1-SoC, equipado com o processador Cyclone V, possibilitando a leitura e escrita de dados diretamente na memória SDRAM do dispositivo. O ambiente de desenvolvimento adotado foi o Intel Quartus Prime Lite 23.1, utilizando a linguagem de descrição de hardware Verilog. O objetivo do projeto é implementar o redimensionamento de imagens por meio de algoritmos de zoom in e zoom out, operações fundamentais em sistemas de processamento digital de imagens por permitirem ajustar a escala de exibição, melhorar a análise visual e atender aplicações como compressão de dados, reconhecimento de padrões, visão computacional embarcada, processamento em tempo real e interfaces gráficas.

<div align="center">
    <img src="imagens/placa.jpg"><br>
    <strong>Imagem do Site da Altera</strong><br><br>
</div>

O coprocessador é capaz de lidar com os seguintes algoritmos de redimensionamento: 

* Replicação de Pixel(Zoom-in)
* Vizinho mais próximo(Zoom-in)
* Vizinho mais próximo/Decimação(Zoom-out)
* Média de Blocos(Zoom-out)

Sumário
=================
<!--ts-->   
   * [Arquitetura do Projeto](#arquitetura)
   * [Máquina de Estados](#maquina-de-estados)
      * [IDLE](#idle)
      * [READ_ROM](#read)
      * [WRITE_RAM](#write)
      * [PROCESS(RESIZE)](#resize)
      * [MEMORY](#memory)
      * [DONE](#done)
   * [Unidade Lógica e Aritmética (ULA)](#ula)
      * [Replicação de Pixel](#rep_pixel)
      * [Vizinho mais próximo (Zoom-in)](#nn_zoomin)
      * [Decimação/Vizinho mais próximo (Zoom-out)](#dec)
      * [Média de Blocos](#media)
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

  <h3 id="resize">PROCESS (RESIZE)</h3>
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
  <p>Expande a imagem replicando os pixels, preservando a simplicidade computacional.</p>

  <h3 id="nn_zoomin">Vizinho mais próximo (Zoom-in)</h3>
  <p>Amplia a imagem escolhendo o pixel mais próximo na escala, gerando menos serrilhado que a replicação simples.</p>

  <h3 id="dec">Decimação / Vizinho mais próximo (Zoom-out)</h3>
  <p>Reduz a resolução da imagem descartando pixels de acordo com um fator de escala.</p>

  <h3 id="media">Média de Blocos (Zoom-out)</h3>
  <p>Reduz a imagem calculando a média de blocos de pixels, garantindo uma suavização visual maior.</p>
</div>


</div>

<div>
  <h2 id="referencias">Referências</h2>
  PATTERSON, D. A.; HENNESSY, J. L. Computer organization and design : the hardware/software interface, ARM edition / Computer organization and design : the hardware/software interface, ARM edition.<br>
  
‌  FPGAcademy. Disponível em: <https://fpgacademy.org>.<br>
‌
  Cyclone V Device Overview. Disponível em: <https://www.intel.com/content/www/us/en/docs/programmable/683694/current/cyclone-v-device-overview.html>.<br>

  TECHNOLOGIES, T. Terasic - SoC Platform - Cyclone - DE1-SoC Board. Disponível em: <https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836>.<br>

  DUNNE, Robert. Computer Architecture Tutorial Using an FPGA: ARM & Verilog Introductions. Downers Grove, Illinois: Gaul Communications, 2020. ISBN 978-0-970112491.<br>

</div>
