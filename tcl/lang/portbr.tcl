# portbr.tcl:
# Scid in Brazilian Portuguese.

proc setLanguage_B {} {

# File menu:
menuText B File "Arquivo" 0
menuText B FileNew "Novo..." 0 {Cria uma nova base de dados Scid}
menuText B FileOpen "Abrir..." 0 {Abre uma base de dados Scid existente}
menuText B FileClose "Fechar" 0 {Fecha a base de dados Scid ativa}
menuText B FileFinder "Buscador" 0 {Abre a janela do Buscador de Arquivos}
menuText B FileBookmarks "Favoritos" 0 {Menu de Favoritos (atalho: Ctrl+B)}
menuText B FileBookmarksAdd "Adicionar a Favoritos" 0 \
  {Adiciona o posio do jogo do banco de dados atual}
menuText B FileBookmarksFile "Arquivar Favorito" 0 \
  {Arquiva um Favorito para a posio do jogo atual}
menuText B FileBookmarksEdit "Editar favoritos..." 0 \
  {Editar o menu de favoritos}
menuText B FileBookmarksList "Mostrar pastas como lista" 0 \
  {Mostra as pastas de favoritos em lista unica}
menuText B FileBookmarksSub "Mostrar pastas como submenus" 0 \
  {Mostra as pastas de favoritos como submenus}
menuText B FileMaint "Manuteno" 0 {Ferramentas de manuteno de bases de dados Scid}
menuText B FileMaintWin "Janela de Manuteno" 0 \
  {Abre/Fecha a janela de manutencao de bases de dados Scid}
menuText B FileMaintCompact "Compactar base de dados..." 0 \
  {Compacta arquivos de bases de dados, removendo jogos deletados e nomes nao utilizados}
menuText B FileMaintClass "Classificar jogos por ECO..." 2 \
  {Recalcula o codigo ECO de todos os jogos}
menuText B FileMaintSort "Ordenar base de dados..." 0 \
  {Ordena todos os jogos da base de dados}
menuText B FileMaintDelete "Apagar jogos duplicados..." 13 \
  {Encontra jogos duplicados e os marca para excluso}
menuText B FileMaintTwin "Janela de verificao de duplicadas" 10 \
  {Abre/atualiza a janela de verificao de duplicadas}
menuText B FileMaintName "Ortografia de nomes" 14 {Ferramentas de edio e correo ortogrfica de nomes}
menuText B FileMaintNameEditor "Editor de Nomes" 0 \
  {Abre/fecha a janela do editor de nomes}
menuText B FileMaintNamePlayer "Verificao Ortogrfica de Nomes de Jogadores..." 11 \
  {Verifica a correo dos nomes dos jogadores de acordo com o arquivo de correo ortogrfica}
menuText B FileMaintNameEvent "Verificao Ortogrfica de Nomes de Eventos..." 11 \
  {Verifica a correo dos nomes de eventos de acordo com o arquivo de verificao ortogrfica}
menuText B FileMaintNameSite "Verificao Ortogrfica de Lugares..." 11 \
  {Verifica a correo dos nomes de lugares usando o arquivo de correo ortogrfica}
menuText B FileMaintNameRound "Verificaoo Ortogrfica de Rodadas..." 11 \
  {Verificacao dos nomes de rodadas usando o arquivo de correo ortogrfica}
menuText B FileReadOnly "Apenas Leitura..." 7 \
  {Trata a base de dados corrente como arquivo de leitura, impedindo mudans}
menuText B FileSwitch "Mudar a base de dados" 0 \
  {Muda para uma base de dados diferente, j aberta} 
menuText B FileOpenLichessTournament "Torneio Aberto de Lichess" 0 {Baixe e abra jogos de transmisso do torneio Lichess ao vivo}
menuText B FileImportLichess "Importe meu Lichess" 0 {Importe jogos da sua conta Lichess}
menuText B FileImportChessCom "Importe meu xadrez.com" 0 {Importe jogos da sua conta chess.com}
menuText B FileExit "Sair" 0 {Encerrar o Scid}
menuText B FileMaintFixBase "Corrigir base corrompida" 0 {Tenta corrigir uma base corrompida}

# Edit menu:
menuText B Edit "Editar" 0
menuText B EditAdd "Adiciona variante" 0 {Adiciona variante do movimento}
menuText B EditDelete "Apaga Variante" 0 {Exclui variante do movimento}
menuText B EditFirst "Converte para Primeira Variante" 14 \
  {Faz com que uma variante seja a primeira da lista}
menuText B EditMain "Converte variante para Linha Principal" 24 \
  {Faz com que uma variante se torne a Linha Principal}
menuText B EditTrial "Experimentar variante" 0 \
  {Inicia/Para experimentao, para testar alguma nova ideia no tabuleiro}
menuText B EditStrip "Limpar Comentrios e Variantes" 2 \
  {Limpa comentrios e variantes no jogo atual}
menuText B EditUndo "Desfazer" 0 {Desfaz ltima mudana no jogo}
menuText B EditRedo "Repetir" 0 {Repete ltima mudana no jogo}
menuText B EditStripComments "Limpar Comentrios" 0 \
  {Limpa comentrios e anotaes no jogo atual}
menuText B EditStripVars "Limpar Variantes" 0 \
  {Limpa todas as variantes no jogo atual}
menuText B EditStripBegin "Movimentos a partir do incio" 1 \
  {Remove movimentos a partir do incio do jogo} 
menuText B EditStripEnd "Movimentos at o final do jogo" 0 \
  {Remove movimentos at o final do jogo} 
menuText B EditReset "Limpar a base de trabalho" 0 \
  {Limpa completamente a base de trabalho}
menuText B EditCopy "Copiar jogo para a base de trabalho" 0 \
  {Copia o jogo corrente para a base de trabalho}
menuText B EditPaste "Colar jogo da base de trabalho" 1 \
  {Cola o jogo ativo da base de trabalho}
menuText B EditPastePGN "Colar como jogo em PGN..." 10 \
  {Interpreta o texto na rea de transferncia como um jogo em notao PGN e cola na posio corrente} 
menuText B EditSetup "Configura posio inicial..." 12 \
  {Configura a posio inicial para o jogo}
menuText B EditCopyBoard "Copia posio" 6 \
  {Copia o tabuleiro corrente em notao FEN para a rea de transferncia} 
menuText B EditPasteBoard "Colar Posio" 12 \
  {Configura a posio inicial a partir da rea de transferncia}
menuText B ConfigureScid "Preferncias..." 0 {Configurar todas as opes para o SCID}

# Game menu:
menuText B Game "Jogo" 0
menuText B GameNew "Novo Jogo" 0 \
  {Limpa o jogo corrente, descartando qualquer alterao}
menuText B GameFirst "Primeiro Jogo" 5 {Carrega o primeiro jogo filtrado}
menuText B GamePrev "Jogo Anterior" 5 {Carrega o jogo anterior}
menuText B GameReload "Recarrega o Jogo atual" 3 \
  {Recarrega o jogo, descartando qualquer alterao}
menuText B GameNext "Prximo Jogo" 5 {Carrega o prximo jogo}
menuText B GameLast "ltimo Jogo" 8 {Carrega o ltimo jogo}
menuText B GameRandom "Carrega jogo aleatrio" 8 {Carrega um jogo filtrado aleatoriamente} 
menuText B GameNumber "Carrega Jogo Nmero..." 5 \
  {Carrega um jogo pelo seu nmero}
menuText B GameReplace "Salvar: Substituir Jogo..." 8 \
  {Salva o jogo e substitui a verso antiga}
menuText B GameAdd "Salvar: Adicionar Jogo..." 9 \
  {Salva este jogo como um novo jogo na base de dados}
menuText B GameDeepest "Identificar Abertura" 0 \
  {Vai para a posio mais avanada da partida, de acordo com o cdigo ECO}
menuText B GameGotoMove "Ir para o movimento nmero..." 5 \
  {Avanca o jogo at o movimento desejado}
menuText B GameNovelty "Pesquisa Novidade..." 7 \
  {Procura o primeiro movimento deste jogo que no tenha sido jogado antes}

# Search Menu:
menuText B Search "Pesquisa" 0
menuText B SearchReset "Limpar Filtragem" 0 {Limpa o critrio de pesquisa para incluir todos os jogos}
menuText B SearchNegate "Inverter Filtragem" 0 {Inverte o critrio de pesquisa para incluir apenas os jogos que no atendem o critrio}
menuText B SearchCurrent "Posio Atual..." 0 {Pesquisa a posio atual do tabuleiro}
menuText B SearchHeader "Cabealho..." 0 {Pesquisa por cabealho (jogador, evento, etc)}
menuText B SearchMaterial "Material/Padro..." 0 {Pesquisa por material ou padro de posio}
menuText B SearchUsing "Usar arquivo de opes de filtro..." 0 {Pesquisa usando arquivo com opes de filtro}

# Windows menu:
menuText B Windows "Janelas" 0
menuText B WindowsComment "Editor de Comentrios" 0 {Abre/fecha o editor de comentrios}
menuText B WindowsGList "Lista de Jogos" 0 {Abre/fecha a janela com a lista de jogos}
menuText B WindowsPGN "Notao PGN" 0 \
  {Abre/fecha a janela com a notao PGN do jogo}
menuText B WindowsPList "Procura Jogador" 2 {Abre/Fecha o buscador de jogadores} 
menuText B WindowsTmt "Buscador de Torneio" 2 {Abre/Fecha o buscador de torneio}
menuText B WindowsSwitcher "Intercmbio de bases de dados" 0 \
  {Abre/fecha a janela de intercmbio de bases de dados}
menuText B WindowsMaint "Manuteno" 0 \
  {Abre/fecha a janela de manuteno}
menuText B WindowsECO "Listagem ECO" 0 {Abre/fecha a janela de listagem de cdigo ECO}
menuText B WindowsStats "Estatsticas" 0 \
  {Abre/fecha a janela de estatsticas}
menuText B WindowsTree "rvore" 0 {Abre/fecha a janela da rvore de pesquisa}
menuText B WindowsBook "Janela do Livro de Aberturas" 0 {Abre/Fecha  a janela do livro de aberturas}
menuText B WindowsCorrChess "Janela de Correspondncia" 0 {Abre/Fecha a janela de correspondncia}
menuText B WindowsGraph "Grfico de anlise" 0 {Abra a janela Grfico com tempos e avaliaes dos movimentos}

# Tools menu:
menuText B Tools "Ferramentas" 0
menuText B ToolsConfigureEngines "Configurar Engines" 10 {Gerencia configurao dos engines}
menuText B ToolsAnalysis "Analisador #1..." 0 \
  {Inicia ou para o 1o. Analisador}
menuText B ToolsAnalysis2 "Analisador #2..." 17 \
  {Inicia ou para o 2o. Analisador}
menuText B ToolsCross "Tabela de Cruzamento" 0 {Mostra a tabela de cruzamentos do torneio para o jogo corrente}
menuText B ToolsFilterGraph "Grfico de Filtro Relativo" 7 \
  {Abre/Fecha a janela do grfico de filtro} 
menuText B ToolsAbsFilterGraph "Grfico de Filtro Absoluto" 7 {Abre/Fecha a janela do grfico de filtro por valor absoluto}
menuText B ToolsOpReport "Relatrio de Abertura" 0 \
  {Gera um relatrio de abertura para a posio corrente}
menuText B ToolsOpenBaseAsTree "Abre base como rvore" 0   {Abre uma base e a utiliza numa janela de rvore}
menuText B ToolsOpenRecentBaseAsTree "Abre base recente como rvore" 0   {Abre uma base recente e a utiliza numa janela de rvore}
menuText B ToolsTracker "Acompanha Pea"  0 {Abre a janela de acompanhamento de peas} 
menuText B ToolsTraining "Treinamento"  0 {Ferramentas de Treinamento (tticas, aberturas,...) }
menuText B ToolsTacticalGame "Jogo Ttico"  0 {Jogar com tticas}
menuText B ToolsSeriousGame "Jogo Srio"  0 {Jogar um jogo srio}
menuText B ToolsTrainOpenings "Aberturas"  0 {Treinamento com um repertrio}
menuText B ToolsTrainReviewGame "Rever jogo"  0 {Acompanhar movimentos de um jogo}
menuText B ToolsTrainTactics "Tticas"  0 {Exerccios de ttica}
menuText B ToolsTrainCalvar "Clculo de Variantes"  0 {Treinamento de clculo de variantes}
menuText B ToolsTrainFindBestMove "Procurar melhor movimento"  0 {Procura o melhor movimento}
menuText B ToolsTrainFics "Jogar na internet"  0 {Jogar em  freechess.org}
menuText B ToolsEngineTournament "Torneio de Engines de Xadrez"  0 {Inicia um torneio entre engines de Xadrez}
menuText B ToolsTimeAnalysis "Anlise de Tempo" 0 {Mostrar grfico de tempo do relgio para o jogo atual}
menuText B ToolsBookTuning "Sintonizar Livro" 0 {Sintonizar livro de aberturas}
menuText B ToolsDownloadTWIC "Baixar Partidas TWIC" 0 {Baixar as partidas mais recentes The Week In Chess (TWIC)}
menuText B ToolsConnectHardware "Conectar Hardware" 0 {Conectar hardware externo}
menuText B ToolsConnectHardwareConfigure "Configurar..." 0 {Configurar hardware e conexo externa}
menuText B ToolsConnectHardwareNovagCitrineConnect "Conectar Novag Citrine" 0 {Conectar Novag Citrine}
menuText B ToolsConnectHardwareInputEngineConnect "Conectar Engine de Entrada" 0 {Conectar engine de entrada (ex. DGT)}

menuText B ToolsPInfo "Informao do Jogador"  0 \
  {Abre/atualiza a janela de informacao do jogador}
menuText B ToolsPlayerReport "Relatrio de jogador..." 3 \
  {Gera um relatrio de jogador} 
menuText B ToolsRating "Grafico de Rating" 0 \
  {Mostra, em um grafico, a evoluo do rating de um jogador}
menuText B ToolsExpCurrent "Exporta jogo corrente" 8 \
  {Grava o jogo corrente em um arquivo texto}
menuText B ToolsExpCurrentPGN "Exporta para PGN..." 15 \
  {Grava o jogo corrente em um arquivo PGN}
menuText B ToolsExpCurrentHTML "Exporta para HTML..." 15 \
  {Grava o jogo corrente em um arquivo HTML}
menuText B ToolsExpCurrentHTMLJS "Exportar jogo para arquivo HTML e JavaScript..." 15 {Escreve o jogo corrente em um arquivo HTML e JavaScript}  
menuText B ToolsExpFilter "Exporta jogos filtrados" 1 \
  {Exporta todos os jogos filtrados para um arquivo texto}
menuText B ToolsExpFilterPGN "Exporta jogos filtrados - PGN..." 17 \
  {Exporta todos os jogos filtrados para um arquivo PGN}
menuText B ToolsExpFilterHTML "Exporta jogos filtrados - HTML..." 17 \
  {Exporta todos os jogos filtrados para um arquivo HTML}
menuText B ToolsExpFilterHTMLJS "Exporta filtro para arquivo HTML e JavaScript..." 17 {Escreve todos os jogos filtrados para um arquivo HTML e JavaScript}  
menuText B ToolsImportOne "Importa PGN texto..." 0 \
  {Importa jogo de um texto em PGN}
menuText B ToolsImportFile "Importa arquivo de jogos PGN..." 7 \
  {Importa jogos de um arquivo PGN}
menuText B ToolsStartEngine1 "Iniciar engine 1" 0  {Inicia engine 1}
menuText B ToolsStartEngine2 "Iniciar engine 2" 0  {Inicia engine 2}
menuText B ToolsCaptureBoard "Capturar posioo atual..." 5  {Salva uma imagem da posio atual.}

# Play menu
menuText B Play "Jogar" 0

# --- Correspondence Chess
menuText B CCResign "Abandonar" 0 {Aceita a derrota (no via eMail)}
menuText B CCClaimDraw "Declarar empate" 0 {Envia o movimento e declara empate (no via eMail)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText B Options "Opes" 0
menuText B OptionsBoardGraphics "Casas..." 0 {Seleciona texturas para as casas}
translate B OptionsBGW {Seleciona texturas para as casas}
translate B OptionsBoardGraphicsText {Seleciona arquivos grficos para as casas brancas e pretas:}
menuText B OptionsBoardNames "Meus nomes de jogadores..." 0 {Edita meus nomes de jogadores} 
menuText B OptionsExport "Exportao" 0 {Muda as opes de exportao de texto}
menuText B OptionsFonts "Fontes" 0 {Muda os fontes}
menuText B OptionsFontsRegular "Normal" 0 {Fonte Normal}
menuText B OptionsFontsMenu "Menu" 0 {Alterar fontes no menu} 
menuText B OptionsFontsSmall "Pequeno" 0 {Fonte pequena}
menuText B OptionsFontsTiny "Pequeno" 0 {Muda a fonte pequena}
menuText B OptionsFontsFixed "Fixo" 0 {Fonte de largura fixa}
menuText B OptionsGInfo "Informaes do Jogo" 0 {Opes de informao do jogo}
menuText B OptionsLanguage "Linguagem" 0 {Menu de seleo de linguagem}
menuText B OptionsMovesTranslatePieces "Traduzir Peas" 0 {Traduz a primeira letra do nome das peas}
menuText B OptionsMovesHighlightLastMove "Destacar ltimo movimento" 0 {Destaca o ltimo movimento}
menuText B OptionsMovesHighlightLastMoveDisplay "Mostrar Casas" 0 {Mostra o destaque do ltimo movimento}
menuText B OptionsMovesHighlightLastMoveWidth "Espessura" 0 {Espessura da linha}
menuText B OptionsMovesHighlightLastMoveColor "Cor" 0 {Cor da linha}
menuText B OptionsMovesHighlightLastMoveArrow "Mostrar Seta" 0 {Seta de Incluso Destacada}
menuText B OptionsMovesHighlightLastMoveNag "Mostrar smbolos de avaliao" 0
menuText B OptionsMovesHighlightLastMoveEval "Mostrar smbolos de avaliao" 0
menuText B OptionsMoves "Movimentos" 0 {Opes para entrada dos movimentos}
menuText B OptionsMovesAnimate "Tempo de animao" 1 \
  {Define a quantidade de tempo usada para animar os movimentos} 
menuText B OptionsMovesDelay "Tempo de atraso p/ Jogo automtico..." 1 \
  {Define o tempo de espera antes de entrar no modo de jogo automtico}
menuText B OptionsMovesCoord "Entrada de movimentos por coordenadas" 0 \
  {Aceita o estilo de entrada de movimentos por coordenadas ("g1f3")}
menuText B OptionsMovesSuggest "Mostrar movimentos sugeridos" 0 \
  {Liga/desliga sugesto de movimentos}
menuText B OptionsShowVarPopup "Mostrar janela de variantes" 0 {Liga/Desliga a janela de variantes}  
menuText B OptionsMovesSpace "Adicionar espaos aps o nmero do movimento" 0 {Adiciona espaos aps o nmero do movimento}  
menuText B OptionsMovesLichess "Formato Lichess/ChessBase para anotaes" 0 {Use o formato Lichess/ChessBase para marcadores quadrados e setas}
menuText B OptionsMovesKey "Auto completar" 0 \
  {Liga/desliga auto completar a partir do que for digitado}
menuText B OptionsMovesShowVarArrows "Mostrar Setas para variantes" 0 {Liga/Desliga as setas que mostram movimentos em variantes}
menuText B OptionsMovesShowEngineVariationArrows "Mostrar setas para variaes do motor" 0 {Setas liga/desliga mostrando linhas de variao do motor no modo multiPV}
menuText B OptionsMovesGlossOfDanger "Cdigos de Cor para Perigo" 0 {Liga/Desliga os cdigos de cor para perigo}
translate B OptionsMovesTreeDepth {Profundidade de movimentao da janela de rvore padro}
menuText B OptionsNumbers "Formato de Nmeros" 0 {Selecione o formato usado para nmeros}
menuText B OptionsTheme "Tema" 0 {Muda a aparncia da interface}
menuText B OptionsWindows "Janelas" 0 {Opes para Janelas}
menuText B OptionsSounds "Sons" 2 {Configura sons para anunciar os movimentos} 
menuText B OptionsResources "Recursos..." 0 {Escolher pastas e arquivos de recursos}
menuText B OptionsWindowsDock "Estacionar janelas" 0 {Estaciona as janelas}
menuText B OptionsWindowsSaveLayout "Salvar layout" 0 {Salva o layout das janelas}
menuText B OptionsWindowsRestoreLayout "Restaurar layout" 0 {Restaura layout}
menuText B OptionsWindowsShowGameInfo "Mostrar Informaes do Jogo" 0 {Mostra informaes do jogo}
menuText B OptionsWindowsAutoLoadLayout "Carregar primeiro layout na entrada" 0 {Carrega automaticamente o primeiro layout ao entrar na aplicao}
menuText B OptionsECO "Carregar arquivo ECO" 7 {Carrega o arquivo com a classificao ECO}
menuText B OptionsSpell "Carregar arquivo de verificao ortogrfica" 6 \
  {Carrega o arquivo de verificao ortogrfica do Scid}
menuText B OptionsTable "Diretrio de tabelas de base" 0 \
  {Selecione um arquivo de tabela de base; todas as tabelas nesse diretorio sero usadas}
menuText B OptionsRecent "Arquivos recentes..." 0 \
  {Muda o nmero de arquivos recentes no menu Arquivo} 
menuText B OptionsBooksDir "Diretrio de Livros" 0 {Define o diretrio para os livros de aberturas}
menuText B OptionsTacticsBasesDir "Diretrio de bases" 0 {Define o diretrio para as bases de treinamento de tticas}
menuText B OptionsPhotosDir "Diretrio de Fotos" 0 {Define o diretrio base de fotos}
menuText B OptionsThemeDir "Carregar Tema(s)"  0 {Carrega arquivo de tema para a tela}
menuText B OptionsSave "Salvar Configurao" 0 \
  "Salva a configurao no arquivo $::optionsFile"
menuText B OptionsAutoSave "Salva Opes ao sair" 0 \
  {Salva automaticamente todas as opes quando sair do Scid}

# Help menu:
menuText B Help "Ajuda" 0
menuText B HelpContents "Contedo" 0 {Mostra a pgina de contedo da ajuda}
menuText B HelpIndex "ndice" 0 {ndice da Ajuda}
menuText B HelpGuide "Consulta Rpida" 0 {Mostra a pgina de consulta rpida}
menuText B HelpHints "Dicas" 0 {Mostra a pgina de dicas}
menuText B HelpContact "Informaes para contato" 0 {Mostra a pgina com informaes para contato}
menuText B HelpTip "Dica do dia" 0 {Mostra uma dica til do Scid}
menuText B HelpStartup "Janela de Inicializao" 0 {Mostra a janela de inicializao}
menuText B HelpAbout "Sobre Scid" 0 {Informaes sobre o Scid}

# Toolbar tooltips:
menuText B RotateBoard "Girar tabuleiro" 0 {Girar tabuleiro}

# Game info box popup menu:
menuText B GInfoHideNext "Ocultar prximo movimento" 0
menuText B GInfoMaterial "Mostra valor de material" 0
menuText B GInfoFEN "Mostra Diagrama FEN" 16
menuText B GInfoMarks "Mostra setas e casas coloridas" 7
menuText B GInfoWrap "Quebra de linhas longas" 0
menuText B GInfoFullComment "Mostrar comentario completo" 8
menuText B GInfoPhotos "Mostrar Fotos" 5 
menuText B GInfoTBNothing "Tabelas de Base: nada" 12
menuText B GInfoTBResult "Tabelas de Base: apenas resultado" 12
menuText B GInfoTBAll "Tabelas de Base: resultado e melhores movimentos" 19
menuText B GInfoDelete "Recuperar este jogo" 0
menuText B GInfoMark "Desmarcar este jogo" 0
menuText B GInfoInformant "Configurar valores do informante" 0

# General buttons:
translate B Back {Voltar}
translate B Browse {Navegar} 
translate B Cancel {Cancelar}
translate B Continue {Continuar}
translate B Clear {Limpar}
translate B Close {Fechar}
translate B Contents {Contedo} 
translate B Defaults {Defaults}
translate B InvertSearch {Inverter pesquisa}
translate B Delete {Apagar}
translate B Graph {Grfico}
translate B Help {Ajuda}
translate B Hide {Ocultar}
translate B Import {Importar}
translate B Index {ndice}
translate B LoadGame {Carrega jogo}
translate B BrowseGame {Listar jogo}
translate B MergeGame {Fazer fuso do jogo}
translate B MergeGames {Fuso dos jogos}
translate B Preview {Visualizao}
translate B Revert {Reverter}
translate B Save {Salvar}
translate B Search {Pesquisar}
translate B Stop {Parar}
translate B Store {Guardar}
translate B Update {Atualizar}
translate B ChangeOrient {Muda orientao da janela}
translate B ShowIcons {Mostrar cones} 
translate B None {Nenhum}
translate B First {Primeiro}
translate B Current {Atual}
translate B Last {ltimo}

# General messages:
translate B game {jogo}
translate B games {jogos}
translate B move {movimento}
translate B moves {movimentos}
translate B all {tudo}
translate B Yes {Sim}
translate B No {No}
translate B Both {Ambos}
translate B King {Rei}
translate B Queen {Dama}
translate B Rook {Torre}
translate B Bishop {Bispo}
translate B Knight {Cavalo}
translate B Pawn {Peo}
translate B White {Brancas}
translate B Black {Pretas}
translate B Player {Jogador}
translate B Rating {Rating}
translate B RatingDiff {Diferena de Rating (Brancas - Pretas)}
translate B AverageRating {Rating Mdio} 
translate B Event {Evento}
translate B Site {Lugar}
translate B Country {Pas}
translate B IgnoreColors {Ignorar cores}
translate B Date {Data}
translate B EventDate {Evento data}
translate B Decade {Dcada} 
translate B Year {Ano}
translate B Month {Ms}
translate B Months {Janeiro Fevereiro Maro Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro}
translate B Days {Dom Seg Ter Qua Qui Sex Sab}
translate B YearToToday {Anos ate hoje}
translate B YearToTodayTooltip {Define a data para 1 ano atrs}
translate B Result {Resultado}
translate B Round {Rodada}
translate B Length {Tamanho}
translate B ECOCode {ECO}
translate B ECO {ECO}
translate B Deleted {Apagado}
translate B SearchResults {Resultados da Pesquisa}
translate B OpeningTheDatabase {Abrindo a Base de Dados}
translate B Database {Base de dados}
translate B Filter {Filtro}
translate B noGames {nenhum jogo}
translate B allGames {todos os jogos}
translate B empty {vazio}
translate B clipbase {base de trabalho}
translate B score {Pontuao}
translate B StartPos {Posio Inicial}
translate B Total {Total}
translate B readonly {apenas leitura}

# Standard error messages:
translate B ErrNotOpen {Esta base no est aberta.} 
translate B ErrReadOnly {Esta base  apenas para leitura; no pode ser alterada.} 
translate B ErrSearchInterrupted {Pesquisa interrompida; os resultados esto incompletos.} 
translate B ErrNoClockComments {Nenhum comentrio de relgio [%clk] foi encontrado neste jogo.    Adicione horrios de relgio atravs da janela de comentrios (Ctrl+E) para usar este recurso.}
translate B ErrFileInUse {Erro: o arquivo j est em uso. Feche qualquer outro aplicativo que use este banco de dados. Se o programa foi fechado inesperadamente, pode ser necessrio excluir o arquivo .lock associado ao banco de dados.}




# Game information:
translate B twin {duplicado}
translate B deleted {apagado}
translate B comment {comentrio}
translate B hidden {oculto}
translate B LastMove {ltimo movimento}
translate B NextMove {Prximo}
translate B GameStart {Incio do jogo}
translate B LineStart {Incio da linha}
translate B GameEnd {Fim do jogo}
translate B LineEnd {Fim da linha}

# Player information:
translate B PInfoAll {Resultados para <b>todos</b> os jogos}
translate B PInfoFilter {Resultados para os jogos <b>filtrados</b>}
translate B PInfoAgainst {Resultados contra}
translate B PInfoMostWhite {Aberturas mais comuns com as Brancas}
translate B PInfoMostBlack {Aberturas mais comuns com as Pretas}
translate B PInfoRating {Histrico de Rating}
translate B PInfoBio {Biografia}
translate B PInfoEditRatings {Editar Ratings} 
translate B PInfoEloFile {Arquivo}

# Tablebase information:
translate B Draw {Empate}
translate B with {com}
translate B only {apenas}
translate B lose {derrota}
translate B loses {derrotas}

# Tip of the day:
translate B Tip {Dica}
translate B TipAtStartup {Dica ao iniciar}
translate B TipConvertPGN {Voc pode obter melhor desempenho convertendo seus arquivos PGN}

# Tree window menus:
menuText B TreeFile "Arquivo" 0
menuText B TreeFileFillWithBase "Carregar Cache com base" 0 {Carrega todos os jogos da base corrente no Cache}
menuText B TreeFileFillWithGame "Carregar Cache com jogo" 0 {Carrega o jogo corrente da base corrente no Cache}
menuText B TreeFileSetCacheSize "Tamanho do Cache" 0 {Define o tamanho do cache}
menuText B TreeFileCacheInfo "Informao do Cache" 0 {Informaes sobre a utilizao do cache}
menuText B TreeFileSave "Salvar arquivo de cache" 0 \
  {Salvar o arquivo de cache da arvore (.stc)}
menuText B TreeFileFill "Criar arquivo de cache" 0 \
  {Enche o arquivo de cache com as posicoes comuns na abertura}
menuText B TreeFileBest "Lista dos melhores jogos" 0 \
  {Mostra a lista dos melhores jogos da arvore}
menuText B TreeFileGraph "Janela de Grfico" 0 \
  {Mostra o grafico para este galho da arvore}
menuText B TreeFileCopy "Copiar texto da rvore para a rea de transferncia" \
  1 {Copiar texto da rvore para a rea de transferncia}
menuText B TreeFileClose "Fechar janela de rvore" 0 {Fechar janela de rvore}
menuText B TreeMask "Mscara" 0
menuText B TreeMaskNew "Nova" 0 {Nova mscara}
menuText B TreeMaskOpen "Abrir" 0 {Abrir mscara}
menuText B TreeMaskOpenRecent "Abrir recente" 0 {Abre mscara recente}
menuText B TreeMaskSave "Salvar" 0 {Salva mscara}
menuText B TreeMaskClose "Fechar" 0 {Fecha mscara}
menuText B TreeMaskFillWithGame "Preencher com jogo" 0 {Preenche mscara com jogo}
menuText B TreeMaskFillWithBase "Preencher com base" 0 {Preenche a mscara com todos os jogos da base}
menuText B TreeMaskInfo "Info" 0 {Mostrar estatisticas para a mscara corrente}
menuText B TreeMaskDisplay "Mostrar mapa da mscara" 0 {Mostra os dados da mscara em forma de rvore}
menuText B TreeMaskSearch "Pesquisar" 0 {Pesquisa na mscara corrente}
menuText B TreeSort "Ordenar" 0
menuText B TreeSortAlpha "Alfabtica" 0
menuText B TreeSortECO "ECO" 0
menuText B TreeSortFreq "Frequncia" 0
menuText B TreeSortScore "Pontuao" 0
menuText B TreeOpt "Opes" 0
menuText B TreeOptSlowmode "Modo Lento" 0 {Modo lento para atualizaes (mais acurado)}
menuText B TreeOptFastmode "Modo Rpido" 0 {Modo rpido para atualizaes (sem transsposies de movimentos)}
menuText B TreeOptFastAndSlowmode "Modo rpido e lento" 0 {Modo rpido e lento para atualizaes}
menuText B TreeOptStartStop "Atualizao automtica" 0 {Liga/Desliga a atualizao automtica da janela de rvore}
menuText B TreeOptLock "Lock" 0 {Trava/Destrava a rvore para o banco corrente}
menuText B TreeOptTraining "Treinamento" 0 \
  {Liga/Desliga o modo treinamento na rvore}
menuText B TreeOptDepth "Mover profundidade" 0 {Nmero de meias jogadas a serem exibidas na rvore (1-4)}
menuText B TreeOptAutosave "Salvar automaticamente arquivo de cache" 0 \
  {Salvar automaticamente o arquivo de cache quando fechar a janela de rvore}
menuText B TreeHelp "Ajuda" 0
menuText B TreeHelpTree "Ajuda para rvore" 0
menuText B TreeHelpIndex "Indice da Ajuda" 0
translate B SaveCache {Salvar Cache}
translate B Training {Treinamento}
translate B LockTree {Travamento}
translate B TreeDepth {Profundidade da rvore (meio movimento):}
translate B TreeLocked {Travada} 
translate B TreeBest {Melhor}
translate B TreeBestGames {Melhores jogos da rvore}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate B TreeTitleRow \
{Mov.                          ECO       Frequncia   Score  AvElo Perf AvYear %Empat   %Ganhar}
translate B TreeTotal {TOTAL}
translate B DoYouWantToSaveFirst {Quer salvar primeiro?}
translate B AddToMask {Adicionar  mscara}
translate B RemoveFromMask {Remover da mscara}
translate B AddThisMoveToMask {Adicionar este movimento  mscara}
translate B SearchMask {Pesquisar na mscara}
translate B DisplayMask {Mostrar mscara}
translate B Nag {Cdigo Nag}
translate B Marker {Marcador}
translate B Include {Incluir}
translate B Exclude {Excluir}
translate B MainLine {Linha Principal}
translate B Bookmark {Marcador}
translate B NewLine {Nova Linha}
translate B ToBeVerified {Verificar}
translate B ToTrain {Para treinar}
translate B Dubious {Duvidoso}
translate B ToRemove {Para remover}
translate B NoMarker {Sem marcador}
translate B ColorMarker {Cor}
translate B WhiteMark {Branca}
translate B GreenMark {Verde}
translate B YellowMark {Amarela}
translate B BlueMark {Azul}
translate B RedMark {Vermelha}
translate B CommentMove {Comentar movimento}
translate B CommentPosition {Comentar posio}
translate B AddMoveToMaskFirst {Adicionar movimento  mscara primeiro}
translate B OpenAMaskFileFirst {Abrir uma mscara primeiro}
translate B Positions {Posies}
translate B Moves {Movimentos}

# Finder window:
menuText B FinderFile "Arquivo" 0
menuText B FinderFileSubdirs "Buscar nos subdiretorios" 0
menuText B FinderFileClose "Fecha buscador de arquivos" 0
menuText B FinderSort "Ordenar" 0
menuText B FinderSortType "Tipo" 0
menuText B FinderSortSize "Tamanho" 0
menuText B FinderSortMod "Modificado" 0
menuText B FinderSortName "Nome" 0
menuText B FinderSortPath "Caminho" 0
menuText B FinderTypes "Tipos" 0
menuText B FinderTypesScid "Bases Scid" 0
menuText B FinderTypesOld "Bases Scid antigas" 0
menuText B FinderTypesPGN "Arquivos PGN" 0
menuText B FinderTypesEPD "Arquivos EPD (book)" 0
menuText B FinderTypesRep "Arquivos de Repertrio" 0
menuText B FinderHelp "Ajuda" 0
menuText B FinderHelpFinder "Ajuda do Buscador" 0
menuText B FinderHelpIndex "Indice da Ajuda" 0
translate B FileFinder {Buscador de Arquivos}
translate B FinderDir {Diretrio}
translate B FinderDirs {Diretrios}
translate B FinderFiles {Arquivos}
translate B FinderUpDir {Acima}
translate B FinderCtxOpen {Abrir}
translate B FinderCtxBackup {Backup}
translate B FinderCtxCopy {Copiar}
translate B FinderCtxMove {Mover}
translate B FinderCtxDelete {Apagar}

# Player finder:
menuText B PListFile "Arquivo" 0
menuText B PListFileUpdate "Atualizar" 0
menuText B PListFileClose "Close Player Finder" 0 
menuText B PListSort "Ordenar" 0
menuText B PListSortName "Nome" 0 
menuText B PListSortElo "Elo" 0
menuText B PListSortGames "Jogos" 0
menuText B PListSortOldest "Mais antigo" 0 
menuText B PListSortNewest "Mais novo" 0 

# Tournament finder:
menuText B TmtFile "Arquivo" 0
menuText B TmtFileUpdate "Atualizar" 0
menuText B TmtFileClose "Fecha Buscador de Torneios" 0
menuText B TmtSort "Ordenar" 0
menuText B TmtSortDate "Data" 0
menuText B TmtSortPlayers "Jogadores" 0
menuText B TmtSortGames "Jogos" 0
menuText B TmtSortElo "Elo" 0
menuText B TmtSortSite "Lugar" 0
menuText B TmtSortEvent "Evento" 1
menuText B TmtSortWinner "Vencedor" 0
translate B TmtLimit "Limite de Lista"
translate B TmtMeanElo "Menor Elo"
translate B TmtNone "Nenhum torneio encontrado."

# Graph windows:
menuText B GraphFile "Arquivo" 0
menuText B GraphFileColor "Salvar como Postscript Colorido..." 12
menuText B GraphFileGrey "Salvar como Postscript Cinza..." 23
menuText B GraphFileClose "Fecha janela" 6
menuText B GraphOptions "Opes" 0
menuText B GraphOptionsWhite "Branco" 0
menuText B GraphOptionsBlack "Preto" 0
menuText B GraphOptionsBoth "Ambos" 0
menuText B GraphOptionsPInfo "Informao do Jogador" 0
menuText B GraphOptionsEloFile "Elo do arquivo de rating" 0
menuText B GraphOptionsEloDB "Elo da base de dados" 0
translate B GraphFilterTitle "Grfico de filtro: porcentagem de jogos alcanando posio"
translate B GraphAbsFilterTitle "Grfico de filtro: frequncia dos jogos"
translate B ConfigureFilter {Configurar Eixos X para Ano, Rating e Movimentos}
translate B FilterEstimate "Estimar"
translate B TitleFilterGraph "Scid: Grfico de Filtro"

# Analysis window:
translate B AddVariation {Adicionar variante}
translate B AddAllVariations {Adicionar todas as Variantes}
translate B AddMove {Adicionar movimento}
translate B Annotate {Anotar}
translate B ShowAnalysisBoard {Mostrar tabuleiro de anlise}
translate B ShowInfo {Mostrar informaes do engine}
translate B FinishGame {Encerrar jogo}
translate B StopEngine {Parar engine}
translate B StartEngine {Iniciar engine}
translate B LockEngine {Travar engine na posio corrente}
translate B AnalysisCommand {Comando de Anlise}
translate B PreviousChoices {Escolhas Anteriores}
translate B AnnotateTime {Define o tempo entre movimentos em segundos}
translate B AnnotateWhich {Adiciona variante}
translate B AnnotateAll {Parar movimentos de ambos os lados}
translate B AnnotateAllMoves {Anotar todos os movimentos}
translate B AnnotateWhite {Apenas para movimentos das Brancas}
translate B AnnotateBlack {Apenas para movimentos das Pretas}
translate B AnnotateBlundersOnly {Quando o movimento for um erro crasso}
translate B AnnotateBlundersOnlyScoreChange {As anlises indicam um erro crasso, com mudana de score de/para: }
translate B BlundersThreshold {Limite}
translate B ScoreAllMoves {Analise todos os movimentos}
translate B LowPriority {Baixa prioridade da CPU} 
translate B ClickHereToSeeMoves {Clique aqui para ver os movimentos}
translate B ConfigureInformant {Informante}
translate B Informant!? {Movimento interessante}
translate B Informant? {Movimento pobre}
translate B Informant?? {Erro crasso}
translate B Informant?! {Movimento duvidoso}
translate B Informant+= {Branca tem alguma vantagem}
translate B Informant+/- {Branca tem vantagem moderada}
translate B Informant+- {Branca tem vantagem decisiva}
translate B Informant+-- {O jogo  considerado como ganho}
translate B AutoComment {Comentrio automtico}
translate B AutoCommentTooltip {Gere comentrios de IA para a posio atual}
translate B AnalysisAutoCommentTooltip {Gere comentrios de IA para todo o jogo}
translate B GameComment {Comentrio do jogo}
translate B GameCommentTooltip {Analise o jogo em busca de movimentos anotados e gere um resumo de IA}
translate B TimeMs {Tempo (ms)}


# Book window
translate B Book {Livro}
translate B OtherBookMoves {Livro do oponente}
translate B OtherBookMovesTooltip {Movimentos para os quais o oponente tem resposta}

# Analysis Engine open dialog:
translate B EngineList {Lista de Programas de Anlise}
translate B EngineName {Nome}
translate B EngineCmd {Comando}
translate B EngineArgs {Parmetros}
translate B EngineDir {Diretrio}
translate B EngineElo {Elo}
translate B EngineTime {Data}
translate B EngineNew {Novo}
translate B EngineEdit {Editar}
translate B EngineRequired {Campos em negrito so obrigatrios; os demais so opcionais}
translate B EngineProtocol {Protocolo de comunicao}
translate B EngineNotation {Notao dos movimentos}
translate B EngineFlipEvaluation {Perspectiva de avaliao invertida}
translate B EngineShowLog {Mostrar registro de comunicao}
translate B EngineNetworkd {Aceitar conexes remotas}
translate B EngineSelect {Selecione o mecanismo atual}
translate B EngineAddLocal {Adicione um mecanismo local}
translate B EngineAddRemote {Adicionar um mecanismo remoto}
translate B EngineReload {Recarregue o mecanismo atual}
translate B EngineClone {Crie uma cpia do mecanismo atual}
translate B EngineDelete {Exclua o mecanismo atual}

# PGN window menus:
menuText B PgnFile "Arquivo" 0
menuText B PgnFileCopy "Copiar o jogo para a rea de transferncia" 0 
menuText B PgnFilePrint "Imprimir para arquivo..." 0
menuText B PgnFileClose "Fechar janela PGN" 0
menuText B PgnOpt "Monitor" 0
menuText B PgnOptColor "Monitor Colorido" 0
menuText B PgnOptShort "Cabealho curto (3 linhas)" 0
menuText B PgnOptSymbols "Anotaes simbolicas" 0
menuText B PgnOptIndentC "Identar comentrios" 0
menuText B PgnOptIndentV "Identar variantes" 7
menuText B PgnOptColumn "Estilo Coluna (um movimento por linha)" 0
menuText B PgnOptSpace "Espao aps o nmero do movimento" 0
menuText B PgnOptStripMarks "Remover os cdigos coloridos das casas/setas" 1 
menuText B PgnOptBoldMainLine "Use negrito para movimentos da linha principal" 4 
menuText B PgnColor "Cores" 0
menuText B PgnColorHeader "Cabealho..." 0
menuText B PgnColorAnno "Anotaes..." 0
menuText B PgnColorComments "Comentrios..." 0
menuText B PgnColorVars "Variantes..." 0
menuText B PgnColorBackground "Cor de fundo..." 0
menuText B PgnColorMain "Linha principal..." 0
menuText B PgnColorCurrent "Cor de fundo do movimento atual..." 1
menuText B PgnHelp "Ajuda" 0
menuText B PgnHelpPgn "Ajuda PGN" 0
menuText B PgnHelpIndex "ndice" 0
translate B PgnWindowTitle {Notao do Jogo - jogo %u} 

# Crosstable window menus:
menuText B CrosstabFile "Arquivo" 0
menuText B CrosstabFileText "Imprime para arquivo texto..." 9
menuText B CrosstabFileHtml "Imprime para arquivo HTML..." 9
menuText B CrosstabFileClose "Fechar tabela de cruzamentos" 0
menuText B CrosstabEdit "Editar" 0
menuText B CrosstabEditEvent "Evento" 0
menuText B CrosstabEditSite "Lugar" 0
menuText B CrosstabEditDate "Data" 0
menuText B CrosstabOpt "Monitor" 0
menuText B CrosstabOptAll "Todos contra todos" 0
menuText B CrosstabOptSwiss "Suio" 0
menuText B CrosstabOptKnockout "Knockout" 0
menuText B CrosstabOptAuto "Automtico" 0
menuText B CrosstabOptAges "Idade em anos" 0
menuText B CrosstabOptNats "Nacionalidades" 0
menuText B CrosstabOptRatings "Ratings" 0
menuText B CrosstabOptTitles "Ttulos" 0
menuText B CrosstabOptBreaks "Scores de desempate" 0
menuText B CrosstabOptDeleted "Incluir jogos apagados" 8 
menuText B CrosstabOptColors "Cores (apenas para tabela Swiss)" 0
menuText B CrosstabOptColumnNumbers "Colunas numeradas (apenas tabelas Todos-contra-Todos)" 2 
menuText B CrosstabOptGroup "Pontuao do Grupo" 0
menuText B CrosstabSort "Ordenar" 0
menuText B CrosstabSortName "Nome" 0
menuText B CrosstabSortRating "Rating" 0
menuText B CrosstabSortScore "Pontuao" 0
menuText B CrosstabColor "Cor" 0
menuText B CrosstabColorPlain "Texto puro" 0
menuText B CrosstabColorHyper "Hipertexto" 0
menuText B CrosstabHelp "Ajuda" 0
menuText B CrosstabHelpCross "Ajuda para tabela de cruzamentos" 0
menuText B CrosstabHelpIndex "ndice da Ajuda" 0
translate B SetFilter {Setar filtro}
translate B AddToFilter {Adicionar ao filtro}
translate B Swiss {Suio}
translate B Category {Categoria} 

# Opening report window menus:
menuText B OprepFile "Arquivo" 0
menuText B OprepFileText "Imprimir para arquivo texto..." 9
menuText B OprepFileHtml "Imprimir para arquivo HTML..." 9
menuText B OprepFileOptions "Opes..." 0
menuText B OprepFileClose "Fechar janela de relatrio" 0
menuText B OprepFavorites "Favoritos" 1 
menuText B OprepFavoritesAdd "Adicionar Relatrio..." 0 
menuText B OprepFavoritesEdit "Editar Relatrio de Favoritos..." 0 
menuText B OprepFavoritesGenerate "Gerar Relatrios..." 0 
menuText B OprepHelp "Ajuda" 0
menuText B OprepHelpReport "Ajuda para Relatrio de abertura" 0
menuText B OprepHelpIndex "ndice da Ajuda" 0

# Header search:
translate B HeaderSearch {Busca por cabealho}
translate B EndSideToMove {Lado que tem o movimento ao final do jogo} 
translate B GamesWithNoECO {Jogos sem ECO?}
translate B GameLength {Tamanho do jogo}
translate B FindGamesWith {Encontrar jogos com}
translate B StdStart {Incio padro}
translate B Promotions {Promoes}
translate B Comments {Comentrios}
translate B Variations {Variantes}
translate B Annotations {Anotaes}
translate B DeleteFlag {Apagar Flag}
translate B WhiteOpFlag {Abertura Brancas}
translate B BlackOpFlag {Abertura Pretas}
translate B MiddlegameFlag {Meio-jogo}
translate B EndgameFlag {Final}
translate B NoveltyFlag {Novidade}
translate B PawnFlag {Estrutura de Pees}
translate B TacticsFlag {Ttica}
translate B QsideFlag {Jogo na ala da Dama}
translate B KsideFlag {Jogo na ala do Rei}
translate B BrilliancyFlag {Brilhantismo}
translate B BlunderFlag {Erro!!!}
translate B UserFlag {Usurio}
translate B PgnContains {PGN contm texto}
translate B PgnTag {Marcao}
translate B TagContains {contm}
translate B Variant {Variante}
translate B Annotator {Anotador}
translate B Cmnts {Apenas jogos anotados}

# Game list window:
translate B GlistNumber {Nmero}
translate B GlistWhite {Brancas}
translate B GlistBlack {Pretas}
translate B GlistWElo {B-Elo}
translate B GlistBElo {P-Elo}
translate B GlistEvent {Evento}
translate B GlistSite {Lugar}
translate B GlistRound {Rodada}
translate B GlistDate {Data}
translate B GlistYear {Ano}
translate B GlistEDate {Evento-Data}
translate B GlistResult {Resultado}
translate B GlistLength {Tamanho}
translate B GlistCountry {Pas}
translate B GlistECO {ECO}
translate B GlistOpening {Abertura}
translate B GlistEndMaterial {Material-Final}
translate B GlistDeleted {Apagado}
translate B GlistFlags {Sinalizador}
translate B GlistVars {Variantes}
translate B GlistComments {Comentrios}
translate B GlistAnnos {Anotaes}
translate B GlistStart {Iniciar}
translate B GlistGameNumber {Nmero do Jogo}
translate B GlistAverageElo {Elo Medio}
translate B GlistRating {Rating}
translate B GlistFindText {Encontrar texto}
translate B GlistMoveField {Mover}
translate B GlistEditField {Configurar}
translate B GlistAddField {Adicionar}
translate B GlistDeleteField {Remover}
translate B GlistWidth {Largura}
translate B GlistAlign {Alinhar}
translate B GlistAlignL {Alinhar: esquerda}
translate B GlistAlignR {Alinhar: direita}
translate B GlistAlignC {Alinhar: centro}
translate B GlistColor {Cor}
translate B GlistSep {Separador}
translate B GlistCurrentSep {--  Atual  --}
translate B GlistNewSort {Novo}
translate B GlistAddToSort {Adicionar}

# base sorting
translate B GsortSort {Classificar...}
translate B GsortDate {Data}
translate B GsortYear {Ano}
translate B GsortEvent {Evento}
translate B GsortSite {Local}
translate B GsortRound {Rodada}
translate B GsortWhiteName {Nome Brancas}
translate B GsortBlackName {Nome Pretas}
translate B GsortECO {ECO}
translate B GsortResult {Resultado}
translate B GsortMoveCount {Movimentos}
translate B GsortAverageElo {Elo medio}
translate B GsortCountry {Pas}
translate B GsortDeleted {Apagado}
translate B GsortEventDate {Data Evento}
translate B GsortWhiteElo {Elo Brancas}
translate B GsortBlackElo {Elo Pretas}
translate B GsortComments {Comentrios}
translate B GsortVariations {Variantes}
translate B GsortNAGs {NAGs}
translate B GsortAscending {Ascendente}
translate B GsortDescending {Descendente}
translate B GsortAdd {Adicionar}
translate B GsortStore {Salvar}
translate B GsortLoad {Carregar}

# menu shown with right mouse button down on game list.
translate B GlistRemoveThisGameFromFilter  {Remover este jogo do filtro}
translate B GlistRemoveGameAndAboveFromFilter  {Remover jogo (e todos antes dele) do filtro}
translate B GlistRemoveGameAndBelowFromFilter  {Remover jogo (e todos depois dele) do filtro}
translate B GlistDeleteGame {Recuperar este jogo} 
translate B GlistDeleteAllGames {Apagar todos os jogos no filtro} 
translate B GlistUndeleteAllGames {Recuperar todos os jogos no filtro} 
translate B GlistMergeGameInBase {Incorporar jogo em outra base} 

# Maintenance window:
translate B DatabaseName {Nome da base de dados:}
translate B TypeIcon {cone de Tipo:}
translate B NumOfGames {Jogos:}
translate B NumDeletedGames {Jogos apagados:}
translate B NumFilterGames {Jogos no filtro:}
translate B YearRange {Faixa de Anos:}
translate B RatingRange {Faixa de Rating:}
translate B Description {Descrio} 
translate B Flag {Sinalizador}
translate B CustomFlags {Flags customizadas}
translate B DeleteCurrent {Apagar jogo corrente}
translate B DeleteFilter {Apagar jogos filtrados}
translate B DeleteAll {Apagar todos os jogos}
translate B UndeleteCurrent {Recuperar jogo corrente}
translate B UndeleteFilter {Recuperar jogos filtrados}
translate B UndeleteAll {Recuperar todos os jogos}
translate B DeleteTwins {Apagar duplicadas}
translate B MarkCurrent {Marcar jogo corrente}
translate B MarkFilter {Marcar jogos filtrados}
translate B MarkAll {Marcar todos os jogos}
translate B UnmarkCurrent {Desmarcar jogo corrente}
translate B UnmarkFilter {Desmarcar jogos filtrados}
translate B UnmarkAll {Desmarcar todos os jogos}
translate B Spellchecking {Verificacao Ortogrfica}
translate B Players {Jogadores}
translate B Events {Eventos}
translate B Sites {Lugares}
translate B Rounds {Rodadas}
translate B DatabaseOps {Operaes na base de dados}
translate B ReclassifyGames {Jogos classificados por ECO}
translate B CompactDatabase {Compactar base de dados}
translate B SortDatabase {Ordenar base de dados}
translate B AddEloRatings {Adicionar ratings}
translate B AutoloadGame {Carregar autom. o jogo numero}
translate B StripTags {Remover tags PGN} 
translate B StripTag {Remover tag} 
translate B Cleaner {Limpador}
translate B CleanerHelp {
O Limpador do Scid executara todas as acoes de manutencao selecionadas da lista abaixo, no banco corrente.

As configuraes atuais na classificao por ECO e dilogos de excluso de duplicadas sero aplicadas se voc escolher estas funes.
}
translate B CleanerConfirm {
Uma vez iniciado, o Limpador nao poder ser interrompido!

Esta operao pode levar muito tempo para ser executada em uma grande base de dados, dependendo das funes selecionadas e das configuraes atuais.

Voc esta certo de que quer iniciar as aes de manuteno selecionadas?
}
# Twinchecker
translate B TwinCheckUndelete {para virar; "u" recupera ambos)}
translate B TwinCheckprevPair {Par anterior}
translate B TwinChecknextPair {Prximo par}
translate B TwinChecker {Scid: Verificador de duplicadas}
translate B TwinCheckTournament {Jogos no torneio:}
translate B TwinCheckNoTwin {Nenhuma duplicada  }
translate B TwinCheckNoTwinfound {Nenhuma duplicada foi detectada para este jogo.\nPara mostrar duplicadas nesta janela, voc deve usar primeiro a funo "Apagar Duplicadas...". }
translate B TwinCheckTag {Compartilhar tags...}
translate B TwinCheckFound1 {Scid encontrou $result duplicadas}
translate B TwinCheckFound2 { e definiu suas flags de excluso}
translate B TwinCheckNoDelete {No h jogos para excluir nesta base.}
translate B TwinCriteria1 { Suas configuraes para encontrar duplicadas podem \nfazer com que no duplicadas com movimentos similares sejam marcadas como se fossem.}
translate B TwinCriteria2 { recomendado que, se voc selecionar "No" para "mesmos movimentos", voc selecione "Sim" para as cores, evento, local, rodada, ano e ms.\nVoc quer continuar e excluir as duplicatas mesmo assim? }
translate B TwinCriteria3 { recomendado que voc especifique "Sim" para pelo menos duas das configuraes de "mesmo local", "mesma rodada" e "mesmo ano".\nVoc quer continuar e excluir as duplicatas mesmo assim?}
translate B TwinCriteriaConfirm {Scid: Confirme as configuraes de duplicatas}
translate B TwinChangeTag "Alterar as seguintes tags:\n\n"
translate B AllocRatingDescription "Este comando utilizar o arquivo corrente de verificao ortogrfica para adicionar ratings Elo aos jogos nesta base. Sempre que um jogador no tiver um rating corrente, mas seu rating no momento do jogo estiver listado no arquivo de verificao, esse rating ser adicionado."
translate B RatingOverride "Sobrescrever ratings existentes diferentes de zero?"
translate B AddRatings "Adicionar ratings a:"
translate B AddedRatings {Scid adicionou $r ratings Elo em $g jogos.}

#Bookmark editor
translate B NewSubmenu "Novo Submenu"

# Comment editor:
translate B AnnotationSymbols  {Smbolos de Anotao:}
translate B Comment {Comentrio:}
translate B InsertMark {Inserir marca} 
translate B InsertMarkHelp {
Insere/remove marca: Seleciona cor, tipo, casa.
Insere/remove seta: Clique com o boto direito em duas casas.
} 

# Nag buttons in comment editor:
translate B GoodMove {Bom Movimento} 
translate B PoorMove {Movimento Pobre} 
translate B ExcellentMove {Movimento Excelente} 
translate B Blunder {Erro!!!} 
translate B InterestingMove {Movimento Interessante} 
translate B DubiousMove {Movimento Duvidoso} 
translate B WhiteDecisiveAdvantage {Brancas tem vantagem decisiva} 
translate B BlackDecisiveAdvantage {Pretas tem vantagem decisiva} 
translate B WhiteClearAdvantage {Brancas tem clara vantagem} 
translate B BlackClearAdvantage {Pretas tem clara vantagem} 
translate B WhiteSlightAdvantage {Brancas tem alguma vantagem} 
translate B BlackSlightAdvantage {Pretas tem alguma vantagem} 
translate B WhiteCrushing {Brancas tem enorme vantagem}
translate B BlackCrushing {Pretas tem enorme vantagem}
translate B Equality {Igualdade} 
translate B Unclear {No claro} 
translate B Diagram {Diagrama} 

# Board search:
translate B BoardSearch {Pesquisa Tabuleiro}
translate B FilterOperation {Operao no filtro corrente:}
translate B FilterAnd {E (Filtro restrito)}
translate B FilterOr {OU (Adicionar ao filtro)}
translate B FilterIgnore {IGNORAR (Limpar filtro)}
translate B SearchType {Tipo de pesquisa:}
translate B SearchBoardExact {Posio exata (todas as peas nas mesmas casas)}
translate B SearchBoardPawns {Pees (mesmo material, todos os pees nas mesmas casas)}
translate B SearchBoardFiles {Colunas (mesmo material, todos os pees na mesma coluna)}
translate B SearchBoardAny {Qualquer (mesmo material, pees e peas em qualquer posio)}
translate B SearchInRefDatabase { Pesquisa na base }
translate B LookInVars {Olhar nas variantes}

# Material search:
translate B MaterialSearch {Pesquisa Material}
translate B Material {Material}
translate B Patterns {Padres}
translate B Zero {Zero}
translate B Any {Qualquer}
translate B CurrentBoard {Tabuleiro corrente}
translate B CommonEndings {Finais comuns}
translate B CommonPatterns {Padres comuns}
translate B MaterialDiff {Diferena de Material}
translate B squares {casas}
translate B SameColor {Mesma cor}
translate B OppColor {Cor oposta}
translate B Either {Qualquer}
translate B MoveNumberRange {Faixa do nmero de movimentos}
translate B MatchForAtLeast {Conferem por pelo menos}
translate B HalfMoves {meios movimentos}

# Common endings in material search:
translate B EndingPawns {Finais com Pees} 
translate B EndingRookVsPawns {Torre contra Pees} 
translate B EndingRookPawnVsRook {Torre e 1 Peo contra Torre} 
translate B EndingRookPawnsVsRook {Torre e Pees contra Torre} 
translate B EndingRooks {Finais Torre contra Torre} 
translate B EndingRooksPassedA {Finais Torre contra Torre com Peo passado na coluna a} 
translate B EndingRooksDouble {Finais com Torres dobradas} 
translate B EndingBishops {Finais Bispo contra Bispo} 
translate B EndingBishopVsKnight {Finais Bispo contra Cavalo} 
translate B EndingKnights {Finais Cavalo contra Cavalo} 
translate B EndingQueens {Finais Dama contra Dama} 
translate B EndingQueenPawnVsQueen {Dama e 1 Peo contra Dama} 
translate B BishopPairVsKnightPair {Meio-jogo com 2 Bispos contra 2 Cavalos} 

# Common patterns in material search:
translate B PatternWhiteIQP {IQP Branca} 
translate B PatternWhiteIQPBreakE6 {IQP Branca: avano d4-d5 contra e6} 
translate B PatternWhiteIQPBreakC6 {IQP Branca: avano d4-d5 contra c6} 
translate B PatternBlackIQP {IQP Preta} 
translate B PatternWhiteBlackIQP {IQP Branca vs. IQP Preta} 
translate B PatternCoupleC3D4 {Pees Brancos isolados em c3+d4} 
translate B PatternHangingC5D5 {Pees Pretos em c5 e d5} 
translate B PatternMaroczy {Maroczy Center (com Pees em c4 e e4)} 
translate B PatternRookSacC3 {Sacrifcio de Torre em c3} 
translate B PatternKc1Kg8 {O-O-O vs. O-O (Rc1 vs. Rg8)} 
translate B PatternKg1Kc8 {O-O vs. O-O-O (Rg1 vs. Rc8)} 
translate B PatternLightFian {Fianchettos nas casas brancas(Bispo-g2 vs. Bispo-b7)} 
translate B PatternDarkFian {Fianchettos nas casas pretas (Bispo-b2 vs. Bispo-g7)} 
translate B PatternFourFian {Quatro Fianchettos (Bispos em b2,g2,b7,g7)} 

# Game saving:
translate B Today {Hoje}
translate B ClassifyGame {Classificar Jogo}

# Setup position:
translate B EmptyBoard {Tabuleiro vazio}
translate B InitialBoard {Tabuleiro Inicial}
translate B SideToMove {Lado que move}
translate B MoveNumber {No. do Movimento}
translate B Castling {Roque}
translate B EnPassantFile {coluna En Passant}
translate B ClearFen {Limpar FEN}
translate B PasteFen {Colar FEN}

translate B SaveAndContinue {Salvar e continuar}
translate B DiscardChangesAndContinue {Descartar alteraes\ne continuar}
translate B GoBack {Voltar}

# Replace move dialog:
translate B ReplaceMove {Substituir movimento}
translate B AddNewVar {Adicionar nova variante}
translate B NewMainLine {Nova linha principal}
translate B ReplaceMoveMessage {Um movimento j existe nesta posio.

Voce pode substitu-lo, descartar todos os movimentos que o seguem, ou adicionar seu movimento como uma nova variante.

(Voce pode evitar que esta mensagem apareca no futuro desligando a opo "Perguntar antes de substituir movimentos" no menu Opcoes:Movimentos.)}

# Make database read-only dialog:
translate B ReadOnlyDialog {Se voc tornar esta base de dados apenas para leitura, nenhuma alterao sera permitida.
Nenhum jogo poder ser salvo ou substitudo, e nenhuma flag de excluso poder ser alterada.
Qualquer ordenao ou resultados de classificao por ECO sero temporrios.

Para poder tornar a base de dados atualizvel novamente, feche-a e abra-a novamente.

Voc realmente quer que esta base de dados seja apenas de leitura?}

# Clear game dialog:
translate B ClearGameDialog {Este jogo foi alterado.

Voc realmente quer continuar e descartar as mudanas feitas?
}

# Exit dialog:
translate B ExitDialog {Voc quer realmente sair do Scid?}
translate B ExitUnsaved {As bases a seguir tem mudanas nos jogos que no foram salvas. Se voc sair agora, essas mudanas sero perdidas.} 

# Import window:
translate B PasteCurrentGame {Colar jogo corrente}
translate B ImportHelp1 {Introduzir ou colar um jogo em formato PGN no quadro acima.}
translate B ImportHelp2 {Quaisquer erros ao importar o jogo sero mostrados aqui.}
translate B OverwriteExistingMoves {Sobrescrever movimentos existentes ?}

# ECO Browser:
translate B ECOAllSections {todas as seces ECO}
translate B ECOSection {seco ECO}
translate B ECOSummary {Resumo para}
translate B ECOFrequency {Frequncia de subcodigos para}

# Opening Report:
translate B OprepReportFor {Relatrio para}
translate B OprepTitle {Relatrio de Abertura}
translate B OprepReport {Relatrio}
translate B OprepGenerated {Gerado por}
translate B OprepStatsHist {Estatsticas e Histrico}
translate B OprepStats {Estatsticas}
translate B OprepStatAll {Todas as partidas do relatrio}
translate B OprepStatBoth {Ambos com rating}
translate B OprepStatSince {Desde}
translate B OprepOldest {Jogos mais antigos}
translate B OprepNewest {Jogos mais recentes}
translate B OprepPopular {Popularidade Atual}
translate B OprepFreqAll {Frequncia em todos os anos:   }
translate B OprepFreq1   {No ltimo ano: }
translate B OprepFreq5   {Nos ltimos 5 anos: }
translate B OprepFreq10  {Nos ltimos 10 anos: }
translate B OprepEvery {uma vez em cada %u jogos}
translate B OprepUp {ate %u%s de todos os anos}
translate B OprepDown {menos que %u%s de todos os anos}
translate B OprepSame {nenhuma mudana em todos os anos}
translate B OprepMostFrequent {Jogadores mais frequentes}
translate B OprepMostFrequentOpponents {Oponentes mais frequentes} 
translate B OprepRatingsPerf {Ratings e Desempenho}
translate B OprepAvgPerf {Ratings e desempenho mdios}
translate B OprepWRating {Rating Brancas}
translate B OprepBRating {Rating Pretas}
translate B OprepWPerf {Desempenho Brancas}
translate B OprepBPerf {Desempenho Pretas}
translate B OprepHighRating {Jogos com o maior rating medio}
translate B OprepTrends {Tendncias de Resultados}
translate B OprepResults {Qtd. e frequncia de resultados}
translate B OprepLength {Tamanho do jogo}
translate B OprepFrequency {Frequncia}
translate B OprepWWins {Brancas vencem: }
translate B OprepBWins {Pretas vencem:  }
translate B OprepDraws {Empates:        }
translate B OprepWholeDB {toda a base de dados}
translate B OprepShortest {Vitrias mais rpidas}
translate B OprepMovesThemes {Movimentos e Temas}
translate B OprepMoveOrders {Ordem dos movimentos para atingir a posio do relatrio}
translate B OprepMoveOrdersOne \
  {Houve apenas uma ordem de movimentos que atinge esta posio: }
translate B OprepMoveOrdersAll \
  {Houve apenas %u ordens de movimentos que atingem esta posio:}
translate B OprepMoveOrdersMany \
  {Houve %u ordens de movimentos que atingem esta posio. As %u primeiras so:}
translate B OprepMovesFrom {Movimentos da posio do relatrio}
translate B OprepMostFrequentEcoCodes {Cdigos ECO mais frequentes} 
translate B OprepThemes {Temas Posicionais}
translate B OprepThemeDescription {Frequncia dos temas nos primeiros  %u movimentos de cada jogo} 
translate B OprepThemeSameCastling {Roque do mesmo lado}
translate B OprepThemeOppCastling {Roques opostos}
translate B OprepThemeNoCastling {Ningum efetuou o roque}
translate B OprepThemeKPawnStorm {Tempestade de Pees no lado do Rei}
translate B OprepThemeQueenswap {Damas ja trocadas}
translate B OprepThemeWIQP {Peo branco da Dama isolado} 
translate B OprepThemeBIQP {Peo preto da Dama isolado} 
translate B OprepThemeWP567 {Peo Branco na 5/6/7a fila}
translate B OprepThemeBP234 {Peo Preto na 2/3/4a fila}
translate B OprepThemeOpenCDE {Colunas c/d/e abertas}
translate B OprepTheme1BishopPair {Um lado tem o par de Bispos}
translate B OprepEndgames {Finais}
translate B OprepReportGames {Jogos no Relatrio}
translate B OprepAllGames {Todos os jogos}
translate B OprepEndClass {Material ao fim de cada jogo}
translate B OprepTheoryTable {Tabela de Teoria}
translate B OprepTableComment {Gerada a partir dos %u jogos com rating mais alto.}
translate B OprepExtraMoves {Movimentos com nota extra na Tabela de Teoria}
translate B OprepMaxGames {Qtde. Mxima de jogos na tabela de teoria}
translate B OprepMergeMoves {Limite de movimentao para jogos mesclados}
translate B OprepMergeUnique {Mesclar apenas jogos nicos}
translate B OprepViewHTML {Visualizar HTML} 

# Player Report:
translate B PReportTitle {Relatrio do Jogador} 
translate B PReportColorWhite {com as Brancas} 
translate B PReportColorBlack {com as Pretas} 
translate B PReportMoves {aps %s} 
translate B PReportOpenings {Aberturas} 
translate B PReportClipbase {Limpa base de cpia e copia os jogos encontrados para ela} 

# Piece Tracker window:
translate B TrackerSelectSingle {Use o boto esquerdo do mouse para selecionar esta pea.} 
translate B TrackerSelectPair {Boto esquerdo seleciona esta pea; boto direito seleciona sua parceira.}
translate B TrackerSelectPawn {Boto esquerdo seleciona este Peo; boto direito seleciona os 8 Pees}
translate B TrackerStat {Estatsticas}
translate B TrackerGames {% jogos com movimentos para a casa}
translate B TrackerTime {% tempo em cada casa}
translate B TrackerMoves {Movimentos}
translate B TrackerMovesStart {Entre o nmero do movimento a partir do qual o acompanhamento deve ser feito.}
translate B TrackerMovesStop {Entre com o nmero do movimento onde deve parar o acompanhamento.}

# Game selection dialogs:
translate B SelectAllGames {Todos os jogos na base de dados}
translate B SelectFilterGames {Apenas jogos no filtro}
translate B SelectTournamentGames {Somente jogos no torneio atual}
translate B SelectOlderGames {Somente jogos antigos}

# Delete Twins window:
translate B TwinsNote {Para serem duplicados, dois jogos devem ter pelo menos os mesmos dois jogadores, alm de critrios que voc pode definir abaixo. Quando um par de duplicados  encontrado, o jogo menor e apagado. Dica: e melhor fazer a verificao ortogrfica da base de dados antes de remover duplicados, pois isso melhora o processo de deteo de duplicados. }
translate B TwinsCriteria {Critrio: Duplicadas devem ter...}
translate B TwinsWhich {Jogos a examinar}
translate B TwinsColors {Jogadores com a mesma cor?}
translate B TwinsEvent {Mesmo evento?}
translate B TwinsSite {Mesmo lugar?}
translate B TwinsRound {Mesma rodada?}
translate B TwinsYear {Mesmo ano?}
translate B TwinsMonth {Mesmo ms?}
translate B TwinsDay {Mesmo dia?}
translate B TwinsResult {Mesmo resultado?}
translate B TwinsECO {Mesmo codigo ECO?}
translate B TwinsMoves {Mesmos movimentos?}
translate B TwinsPlayers {Comparao dos nomes dos jogadores:}
translate B TwinsPlayersExact {Comparao exata}
translate B TwinsPlayersPrefix {Primeiras 4 letras apenas}
translate B TwinsWhen {Quando apagar duplicadas}
translate B TwinsSkipShort {Ignorar todos os jogos com menos de 5 movimentos?}
translate B TwinsUndelete {Recuperar todos os jogos antes?}
translate B TwinsSetFilter {Definir filtro para todas as duplicadas apagadas?}
translate B TwinsComments {Manter sempre os jogos com comentrios?}
translate B TwinsVars {Manter sempre os jogos com variantes?}
translate B TwinsDeleteWhich {Excluir qual jogo:} 
translate B TwinsDeleteShorter {Menor jogo} 
translate B TwinsDeleteOlder {Menor numero de jogo} 
translate B TwinsDeleteNewer {Maior numero de jogo} 
translate B TwinsDelete {Apagar jogos}

# Name editor window:
translate B NameEditType {Tipo de nome para editar}
translate B NameEditSelect {Jogos para editar}
translate B NameEditReplace {Substituir}
translate B NameEditWith {com}
translate B NameEditMatches {Confere: Pressione Ctrl+1 a Ctrl+9 para selecionar}

# Check games window:
translate B CheckGames {Marcar jogos}
translate B CheckGamesWhich {Marcar jogos}
translate B CheckAll {Todos os jogos}
translate B CheckSelectFilterGames {Somente jogos filtrados}

# Classify window:
translate B Classify {Classificar}
translate B ClassifyWhich {Que jogos devem ser classificados por ECO}
translate B ClassifyAll {Todos os Jogos (substituir cdigos ECO antigos)}
translate B ClassifyYear {Todos os jogos do ltimo ano}
translate B ClassifyMonth {Todos os jogos do ltimo ms}
translate B ClassifyNew {Somente jogos ainda sem cdigo ECO}
translate B ClassifyCodes {Cdigos ECO a serem usados}
translate B ClassifyBasic {Cdigos Bsicos apenas ("B12", ...)}
translate B ClassifyExtended {Extenses Scid ("B12j", ...)}
translate B ClassifyResult {Classificao ECO concluda: $resultado(s) jogo(s) atualizado(s).}

# Compaction:
translate B NameFile {Arquivo de nomes}
translate B GameFile {Arquivo de jogos}
translate B Names {Nomes}
translate B Unused {No usado}
translate B SizeKb {Tamanho (kb)}
translate B CurrentState {Estado Atual}
translate B AfterCompaction {Aps compactao}
translate B CompactNames {Compactar arquivo de nomes}
translate B CompactGames {Compactar arquivo de nomes}
translate B NoUnusedNames "No h nomes no utilizados, ento o arquivo j est totalmente compactado."
translate B NoUnusedGames "O arquivo de jogo j est totalmente compactado."
translate B GameFileCompacted {O arquivo de jogos para a base est compactado.}

# Sorting:
translate B SortCriteria {Critrio}
translate B AddCriteria {Adicionar critrio}
translate B CommonSorts {Ordenaes comuns}
translate B Sort {Ordenar}

# Exporting:
translate B AddToExistingFile {Adicionar jogos a um arquivo existente?}
translate B ExportComments {Exportar comentrios?}
translate B ExportVariations {Exportar variantes?}
translate B IndentComments {Identar Comentrios?}
translate B IndentVariations {Identar Variantes?}
translate B ExportColumnStyle {Estilo Coluna (um movimento por linha)?}
translate B ExportSymbolStyle {Estilo de anotao simblica:}
translate B ExportStripMarks {Remover cdigos de marca de casa/seta dos comentrios?} 

# Goto game/move dialogs:
translate B LoadGameNumber {Entre o nmero do jogo a ser carregado:}
translate B GotoMoveNumber {Ir p/ o lance no.:}

# Copy games dialog:
translate B CopyAllGames {Copiar todos os jogos}
translate B CopyGames {Copiar jogos}
translate B CopyConfirm {
 Voce realmente quer copiar
 os [::utils::thousands $nGamesToCopy] jogos filtrados
 da base de dados "$fromName"
 para a base de dados "$targetName"?
}
translate B CopyErr {Cpia no permitida}
translate B CopyErrSource {a base de dados origem}
translate B CopyErrTarget {a base de dados destino}
translate B CopyErrNoGames {no tem jogos que atendam o filtro}
translate B CopyErrReadOnly { apenas de leitura}
translate B CopyErrNotOpen {no est aberta}

# Colors:
translate B LightSquares {Casas Brancas}
translate B DarkSquares {Casas Pretas}
translate B SelectedSquares {Casas selecionadas}
translate B SuggestedSquares {Casas Sugeridas}
translate B WhitePieces {Peas Brancas}
translate B BlackPieces {Peas Pretas}
translate B WhiteBorder {Borda Branca}
translate B BlackBorder {Borda Preta}

# Novelty window:
translate B FindNovelty {Buscar Novidade}
translate B Novelty {Novidade}
translate B NoveltyInterrupt {Busca interrompida}
translate B NoveltyNone {Nenhuma novidade encontrada}
translate B NoveltyHelp {
Scid buscara o primeiro movimento do jogo atual que alcana uma posio no encontrada na base selecionada ou no arquivo ECO.
}

# Sounds configuration:
translate B SoundsFolder {Pasta de arquivos de som} 
translate B SoundsFolderHelp {A pasta deve conter os arquivos King.wav, a.wav, 1.wav, etc} 
translate B SoundsAnnounceOptions {Opes de anncio de movimentos} 
translate B SoundsAnnounceNew {Anuncia novos movimentos quando eles so feitos} 
translate B SoundsMoveSoundOnly {Mover apenas som (desativar anncios)}
translate B SoundsAnnounceForward {Anuncia movimentos quando avanar um movimento} 
translate B SoundsAnnounceBack {Anuncia movimentos quando retroceder um movimento} 
translate B SoundsSoundDisabled {O Scid no conseguiu encontrar o pacote de udio Snack na inicializao;\nSound est desativado.}

# Upgrading databases:
translate B Upgrading {Atualizando}
translate B ConfirmOpenNew {
Esta  uma base em formato antigo (Scid 3) que no pode ser aberta pelo Scid 4, mas uma verso no novo formato (Scid 4) ja foi criada.

Voc quer abrir a nova verso da base Scid 4?
}
translate B ConfirmUpgrade {
Esta  uma base em formato antigo (Scid 3). Uma verso da base no novo formato deve ser criada antes de poder ser usada no Scid 4.

A atualizao criar uma nova verso da base; isto no altera nem remove os registros originais.

Este processo pode levar algum tempo, mas s precisa ser feito uma vez e pode ser cancelado se estiver demorando muito.

Voc quer atualizar esta base agora?
}

# Recent files options:
translate B RecentFilesMenu {Nmero de arquivos recentes no menu Arquivo} 
translate B RecentFilesExtra {Nmero de arquivos recentes no submenu extra} 

# My Player Names options:
translate B MyPlayerNamesDescription {
Entre com uma lista dos nomes de jogadores preferidos, abaixo, um nome por linha. Substitutos (ex. "?" para qualquer caracter nico, "*" para qualquer sequncia de caracteres) so permitidas.

Cada vez que um jogo com um jogador da lista  carregado, o tabuleiro da janela principal sofrer rotao, se necessrio, para mostrar o jogo da perspectiva desse jogador..
} 

#Coach
translate B showblunderexists {mostra que existe um erro crasso}
translate B showblundervalue {mostra o valor do erro crasso}
translate B showscore {mostra o score}
translate B coachgame {auxlio ao jogo}
translate B configurecoachgame {configura auxlio ao jogo}
translate B configuregame {Configurao do jogo}
translate B Phalanxengine {Engine Phalanx}
translate B Coachengine {Engine de auxlio}
translate B difficulty {dificuldade}
translate B hard {difcil}
translate B easy {fcil}
translate B Playwith {Jogar com}
translate B white {brancas}
translate B black {pretas}
translate B both {ambas}
translate B Play {Jogar}
translate B Noblunder {Nenhum erro crasso}
translate B blunder {erro crasso}
translate B Noinfo {-- Sem informaes --}
translate B PhalanxOrTogaMissing {Phalanx ou Toga no encontrado}
translate B moveblunderthreshold {movimento e um erro crasso se a perda  maior que}
translate B limitanalysis {limita tempo de anlise do engine}
translate B seconds {segundos}
translate B Abort {Abortar}
translate B Resume {Continuar}
translate B OutOfOpening {Fora da abertura}
translate B NotFollowedLine {Voc no seguiu a linha}
translate B DoYouWantContinue {Voc quer continuar ?}
translate B CoachIsWatching {Auxlio est observando}
translate B Ponder {Pensando permanentemente}
translate B LimitELO {Limite da fora ELO}
translate B DubiousMovePlayedTakeBack {Movimento duvidoso, quer voltar ?}
translate B WeakMovePlayedTakeBack {Movimento fraco, quer voltar ?}
translate B BadMovePlayedTakeBack {Movimento ruim, quer voltar ?}
translate B Iresign {Eu desisto}
translate B yourmoveisnotgood {seu movimento no  bom}
translate B EndOfVar {Fim da variante}
translate B Openingtrainer {Treinador de aberturas}
translate B DisplayCM {Mostrar movimentos candidatos}
translate B DisplayCMValue {Mostrar valor dos movimentos candidatos}
translate B DisplayOpeningStats {Mostrar estatsticas}
translate B ShowReport {Mostrar relatrio}
translate B NumberOfGoodMovesPlayed {bom movimentos jogados}
translate B NumberOfDubiousMovesPlayed {movimentos duvidosos jogados}
translate B NumberOfMovesPlayedNotInRepertoire {movimentos jogados no existem no repertrio}
translate B NumberOfTimesPositionEncountered {vezes a posio foi encontrada}
translate B PlayerBestMove  {Permitir somente os melhores movimentos}
translate B OpponentBestMove {Oponente joga os melhores movimentos}
translate B OnlyFlaggedLines {Somente linhas marcadas}
translate B resetStats {Reiniciar estatsticas}
translate B Repertoiretrainingconfiguration {Configurao do repertrio de treinamento}
translate B Loadingrepertoire {Carregando repertrio}
translate B Movesloaded {Movimentos carregados}
translate B Repertoirenotfound {Repertrio no encontrado}
translate B Openfirstrepertoirewithtype {Abra primeiro uma base de repertrio com o cone/tipo definido do lado direito}
translate B Movenotinrepertoire {Movimento no existe no repertrio}
translate B PositionsInRepertoire {Posies no repertrio}
translate B PositionsNotPlayed {Posies no jogadas}
translate B PositionsPlayed {Posies jogadas}
translate B Success {Successo}
translate B DubiousMoves {Movimentos duvidosos}
translate B OutOfRepertoire {Fora do Repertrio}
translate B ConfigureTactics {Configurar tticas}
translate B ResetScores {Reiniciar scores}
translate B LoadingBase {Carregando base}
translate B Tactics {Tticas}
translate B ShowSolution {Mostrar soluo}
translate B NextExercise {Prximo exerccio}
translate B PrevExercise {exerccio anterior}
translate B StopTraining {Parar treinamento}
translate B Next {Prximo}
translate B ResettingScore {Reinicializando score}
translate B LoadingGame {Carregando jogo}
translate B MateFound {Mate encontrado}
translate B BestSolutionNotFound {Melhor soluo NO encontrada !}
translate B MateNotFound {Mate no encontrado}
translate B ShorterMateExists {Existe mate mais curto}
translate B ScorePlayed {Score obtido}
translate B Expected {esperado}
translate B ChooseTrainingBase {Escolher base de treinamento}
translate B Thinking {Pensando}
translate B AnalyzeDone {Anlise completa}
translate B WinWonGame {Win venceu o jogo}
translate B Lines {Linhas}
translate B ConfigureUCIengine {Configurar engine UCI}
translate B SpecificOpening {Abertura especifica}
translate B StartNewGame {Iniciar novo jogo}
translate B FixedLevel {Nivel fixo}
translate B Opening {Abertura}
translate B RandomLevel {Nivel aleatrio}
translate B StartFromCurrentPosition {Iniciar a partir da posio corrente}
translate B FixedDepth {Profundidade fixa}
translate B Nodes {Ns} 
translate B Depth {Profundidade}
translate B Time {Tempo} 
translate B SecondsPerMove {Segundos por movimento}
translate B Engine {Engine}
translate B TimeMode {Modo de tempo}
translate B TimeBonus {Bonus de tempo}
translate B TimeMin {min}
translate B TimeSec {seg}
translate B AllExercisesDone {Todos os exerccios completos}
translate B MoveOutOfBook {Movimento fora do livro}
translate B LastBookMove {Ultimo movimento do livro}
translate B AnnotateSeveralGames {Anotar diversos jogos\ndo atual at :}
translate B FindOpeningErrors {Encontrar erros na abertura}
translate B MarkTacticalExercises {Marcar exerccios taticos}
translate B UseBook {Usar livro}
translate B MultiPV {Variantes mltiplas}
translate B Hash {Varrer memria}
translate B OwnBook {Usar livro do engine}
translate B BookFile {Livro de aberturas}
translate B AnnotateVariations {Anotar variantes}
translate B ShortAnnotations {Anotaes curtas}
translate B addAnnotatorTag {Adicionar tag do anotador}
translate B AddScoreToShortAnnotations {Adicionar o score s anotaes curtas}
translate B Export {Exportar}
translate B BookPartiallyLoaded {Livro parcialmente carregado}
translate B Calvar {Clculo de variantes}
translate B ConfigureCalvar {Configurao}
# Opening names used in tacgame.tcl
translate B Reti {Reti}
translate B English {Inglesa}
translate B d4Nf6Miscellaneous {1.d4 Nf6 Diversas}
translate B Trompowsky {Trompowsky}
translate B Budapest {Budapest}
translate B OldIndian {India antiga}
translate B BenkoGambit {Gambito Benko}
translate B ModernBenoni {Moderna Benoni}
translate B DutchDefence {Defesa Holandesa}
translate B Scandinavian {Escandinava}
translate B AlekhineDefence {Defesa Alekhine}
translate B Pirc {Pirc}
translate B CaroKann {Caro-Kann}
translate B CaroKannAdvance {Caro-Kann Advance}
translate B Sicilian {Siciliana}
translate B SicilianAlapin {Siciliana Alapin}
translate B SicilianClosed {Siciliana Fechada}
translate B SicilianRauzer {Siciliana Rauzer}
translate B SicilianDragon {Siciliana Drago}
translate B SicilianScheveningen {Siciliana Scheveningen}
translate B SicilianNajdorf {Siciliana Najdorf}
translate B OpenGame {Jogo aberto}
translate B Vienna {Vienense}
translate B KingsGambit {Gambito do Rei}
translate B RussianGame {Russa}
translate B ItalianTwoKnights {Italiana/Dois Cavalos}
translate B Spanish {Espanhola}
translate B SpanishExchange {Espanhola Trocas}
translate B SpanishOpen {Espanhola Aberta}
translate B SpanishClosed {Espanhola Fechada}
translate B FrenchDefence {Defesa Francesa}
translate B FrenchAdvance {Francesa Avano}
translate B FrenchTarrasch {Francesa Tarrasch}
translate B FrenchWinawer {Francesa Winawer}
translate B FrenchExchange {Francesa Trocas}
translate B QueensPawn {Peo da Dama}
translate B Slav {Eslava}
translate B QGA {Gambito de Dama Aceite}
translate B QGD {Gambito de Dama Recusado}
translate B QGDExchange {Gambito de Dama das Trocas}
translate B SemiSlav {Semi-Eslava}
translate B QGDwithBg5 {Gambioto de Dama com Bg5}
translate B QGDOrthodox {Gambito de Dama Ortodoxa}
translate B Grunfeld {Grnfeld}
translate B GrunfeldExchange {Grnfeld Trocas}
translate B GrunfeldRussian {Grnfeld Russa}
translate B Catalan {Catal}
translate B CatalanOpen {Catal Aberta}
translate B CatalanClosed {Catal Fechada}
translate B QueensIndian {India da Dama}
translate B NimzoIndian {Nimzo-India}
translate B NimzoIndianClassical {Nimzo-India Clssica}
translate B NimzoIndianRubinstein {Nimzo-India Rubinstein}
translate B KingsIndian {ndia do Rei}
translate B KingsIndianSamisch {ndia do Rei Smisch}
translate B KingsIndianMainLine {ndia do Rei Linha Principal}

# FICS
translate B ConfigureFics {Configurar FICS}
translate B FICSGuest {Login como convidado}
translate B FICSServerPort {Porta do Servidor}
translate B FICSServerAddress {Endereo IP}
translate B FICSRefresh {Atualizar}
translate B FICSTimesealPort {Porta Timeseal}
translate B FICSSilence {Silncio}
translate B FICSOffers {Ofertas}
translate B FICSConsole {Console}
translate B FICSGames {Jogos}
translate B FICSUnobserve {Parar de observar jogo}
translate B FICSProfile {Exibir seu perfil e histrico}
translate B FICSRelayedGames {Jogos conectados}
translate B FICSFindOpponent {Encontrar Oponente}
translate B FICSTakeback {Voltar}
translate B FICSTakeback2 {Voltar 2}
translate B FICSInitTime {Tempo inicial (min)}
translate B FICSIncrement {Incremento (seg)}
translate B FICSRatedGame {Jogo com rate}
translate B FICSAutoColour {automatico}
translate B FICSManualConfirm {confirmar manualmente}
translate B FICSFilterFormula {Filtro com frmula}
translate B FICSIssueSeek {Busca item}
translate B FICSChallenge {Desafiar}
translate B FICSAccept {aceitar}
translate B FICSDecline {recusar}
translate B FICSColour {Cor}
translate B FICSSend {enviar}
translate B FICSConnect {Conectar}
translate B FICSdefaultuservars {Usar variveis padro}
translate B FICSObserveconfirm {Voc quer observar o jogo}
translate B FICSpremove {Habilita Pr-movimento}
translate B FICSObserve {Observar}
translate B FICSRatedGames {Jogos com rating}
translate B FICSUnratedGames {Jogos sem rating}
translate B FICSRated {Com rating}
translate B FICSUnrated {Sem rating}
translate B FICSRegisteredPlayer {Apenas jogador registrado}
translate B FICSFreePlayer {Apenas jogador no registado}
translate B FICSNetError {Erro de rede\nNao pode conectar }

# Game review
translate B GameReview {Rever jogo}
translate B GameReviewTimeExtended {Tempo estendido}
translate B GameReviewMargin {Margem de erro}
translate B GameReviewAutoContinue {Continuar automaticamente quando o movimento estiver correto}
translate B GameReviewReCalculate {Usar tempo estendido}
translate B GameReviewAnalyzingMovePlayedDuringTheGame {Analisando movimento feito durante o jogo}
translate B GameReviewAnalyzingThePosition {Analisando a posio}
translate B GameReviewEnterYourMove {Entre seu movimento}
translate B GameReviewCheckingYourMove {Verificando seu movimento}
translate B GameReviewYourMoveWasAnalyzed {Seu movimento foi analisado}
translate B GameReviewYouPlayedSameMove {Voc usou o mesmo movimento como na resposta}
translate B GameReviewScoreOfYourMove {Score do seu movimento}
translate B GameReviewGameMoveScore {Score do movimento do jogo}
translate B GameReviewEngineScore {Score do Engine}
translate B GameReviewYouPlayedLikeTheEngine {Voc jogou como o engine}
translate B GameReviewNotEngineMoveButGoodMove {No  o movimento do engine, mas  um bom movimento}
translate B GameReviewMoveNotGood {Este movimento no  bom; seu score }
translate B GameReviewMovesPlayedLike {Movimentos semelhantes}
translate B GameReviewMovesPlayedEngine {Movimentos semelhantes aos do engine}

# Correspondence Chess Dialogs:
translate B CCDlgCGeneraloptions {Opes Gerais}
translate B CCDlgLoginName  {Login Name:}
translate B CCDlgPassword   {Senha:}
translate B CCDlgShowPassword {Mostra a Senha}

# Connect Hardware dialogs
translate B ExtHWConfigConnection {Configurar hardware externo}
translate B ExtHWPort {Porta}
translate B ExtHWEngineCmd {Comando do Engine}
translate B ExtHWEngineParam {Parmetro do Engine}
translate B ExtHWShowButton {Mostrar boto}
translate B ExtHWHardware {Hardware}
translate B ExtHWNovag {Novag Citrine}
translate B ExtHWInputEngine {Entrar com o Engine}
translate B ExtHWNoBoard {Nenhum tabuleiro}
translate B NovagReferee {Arbitro}

# Input Engine dialogs
translate B IEConsole {Entrar na console do Engine}
translate B IESending {Movimentos enviados para}
translate B IESynchronise {Sincronizar}
translate B IERotate  {Girar}
translate B IEUnableToStart {No  possvel iniciar Engine:}

# Calculation of Variations
translate B DoneWithPosition {Posio definida}

translate B Board {Tabuleiro}
translate B showGameInfo {Mostrar informaes do jogo}
translate B autoResizeBoard {Tamanho automtico do tabuleiro}
translate B DockTop {Mover para cima}
translate B DockBottom {Mover para o final}
translate B DockLeft {Mover para a esquerda}
translate B DockRight {Mover para a direita}
translate B Undock {Desacoplar}

# Switcher window
translate B AboutDatabase {Sobre este banco de dados}
translate B ChangeIcon {Alterar cone...}
translate B NewGameListWindow {Lista de Novos Jogos}
translate B LoadatStartup {Carregar ao inicializar}

# Gamelist window
translate B ShowHideDB {Exibe/Oculta base de dados}
translate B ChangeFilter {Altera filtro}
translate B ChangeLayout {Carrega/Salva/Altera critrio de ordenao e layout das colunas}
translate B ShowHideStatistic {Exibe/Oculta Estatsticas}
translate B BoardFilter {Mostra apenas jogos que atendam a posio atual no tabuleiro}
translate B CopyGameTo {Copiar jogo para}
translate B FindBar {Barra de Pesquisa}
translate B FindCurrentGame {Pesquisar jogo atual}
translate B DeleteGame {Excluir jogo}
translate B UndeleteGame {Recuperar jogo deletado}
translate B ResetSort {Reiniciar ordenao}

translate B ConvertNullMove {Converter movimentos nulos para comentrios}
translate B SetupBoard {Definir tabuleiro}
translate B Rotate {Rotacionar}
translate B SwitchColors {Trocar cores}
translate B FlipBoard {Virar o tabuleiro}
translate B ImportPGN {Importar jogo em PGN}
translate B ImportingFiles {Importar arquivos PGN para}
translate B ImportingFrom {Importando de}
translate B ImportingIn {Importar jogos para}
translate B UseLastTag {Usar ultimas\ntags do jogo}
translate B Random {Aleatrio}
translate B BackToMainline {Voltar para linha principal}
translate B LeaveVariant {Deixar variante}
translate B Autoplay {Jogo automtico}
translate B ShowHideCoords {Exibir/Ocultar Coord.}
translate B ShowHideEvalBar {Mostrar/ocultar barra de avaliao}
translate B ShowHideMaterial {Exibir/Ocultar Material}
translate B SelectMarker {Selecione o marcador}
translate B FullScreen {Tela Cheia}
translate B FilterStatistic {Estatsticas de Filtro}
translate B MakeCorrections {Fazer Correes}
translate B Surnames {Sobrenomes}
translate B Ambiguous {Ambguo}

#Preferences Dialog
translate B OptionsToolbar "Barra de Ferramentas da Janela Principal"
translate B OptionsBoard "Tabuleiro"
translate B OptionsBoardSize "Tamanho do Tabuleiro"
translate B OptionsBoardPieces "Estilo de Peas no Tabuleiro"
translate B OptionsInternationalization "Internacionalizao"
translate B OptionsTablebaseDir "Selecione at 4 pastas tabela base de finais:"

# Evaluation bar
translate B BestMoveArrow "Seta de melhor movimento"
translate B NewLocalEngine "+ Novo engine ..."

# Batch Annotate
translate B BatchAnnotate {Anotar em lote}
translate B BatchEngineSelection {Seleção do motor}
translate B BatchChessEngine {Motor de xadrez:}
translate B BatchNumberOfInstances {Número de instâncias:}
translate B BatchGameReview {Revisão do jogo}
translate B BatchTimePerMove {Tempo por movimento (seg):}
translate B BatchAnnotateBlunders {Anote apenas erros}
translate B BatchBlunderThreshold {Limite de erro:}
translate B BatchVariationLength {Comprimento da variação (movimentos):}
translate B BatchOpeningBook {Livro de Abertura}
translate B BatchUseBook {Usar livro}
translate B BatchAnnotateVariations {Anotar variações}
translate B BatchShortAnnotations {Anotações curtas}
translate B BatchAddScoreToShort {Adicionar pontuação a anotações curtas}
translate B BatchClearOld {Limpar comentários e variações antigos}
translate B BatchInitializingEngines {Inicializando motores...}
translate B BatchAnalyzingGames {Analisando Jogos...}
translate B BatchProgress {Progresso da anotação em lote}
translate B BatchComplete {Anotação de lote concluída!}
translate B BatchCancelled {Anotação de lote cancelada}
translate B BatchStart {Começar}
translate B BatchCancel {Cancelar}
translate B BatchCompleted {concluído}
translate B BatchGames {jogos}
translate B BatchProcessed {processado}
}
# end of english.tcl
