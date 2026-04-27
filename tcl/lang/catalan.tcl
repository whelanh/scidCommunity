# catalan.tcl:
# Catalan translation for Scid
# Contributed by Natalia Pares Vives (natalia%paresvives.net)
# Date: 2009-04-07
# Version: 1

proc setLanguage_K {} {

# File menu:
menuText K File "Arxiu" 0
menuText K FileNew "Nova base..." 0 {Crea una nova base de dades Scid buida}
menuText K FileOpen "Obrir base..." 1 {Obre una base de dades Scid existent}
menuText K FileClose "Tancar base" 0 {Tanca la base de dades Scid activa}
menuText K FileFinder "Visor de fitxers" 0 {Obre la finestra del visor de fitxers}
menuText K FileBookmarks "Partides preferides" 0 {Seleccionar partides preferides (Ctrl+B)}
menuText K FileBookmarksAdd "Afegir" 0 \
  {Marca la partida i posici actual de la base de dades}
menuText K FileBookmarksFile "Arxivar" 8 \
  {Arxiva un marcador de la partida i posici actuals}
menuText K FileBookmarksEdit "Editar partides preferides..." 0 \
  {Edita els mens de les partides preferides}
menuText K FileBookmarksList "Mostrar partides preferides" 0 \
  {Mostra les carpetes preferides a una sola llista, sense submens}
menuText K FileBookmarksSub "Mostrar partides marcades amb submens" 0 \
  {Mostrar les carpetes preferides com submens, no a una sola llista}
menuText K FileMaint "Manteniment" 0 \
  {Eines de manteniment de bases de dades Scid}
menuText K FileMaintWin "Finestra de manteniment" 0 \
  {Obre/tanca la finestra de manteniment de bases de dades Scid}
menuText K FileMaintCompact "Compactar base de dades..." 0 \
  {Compacta els arxius de la base de dades, treient-hi partides esborrades i noms sense utilitzar}
menuText K FileMaintClass "Classificar partides per ECO..." 24 \
  {Recalcula el codi ECO de totes les partides}
menuText K FileMaintSort "Ordenar base de dades..." 0 \
  {Ordena totes les partides de la base de dades}
menuText K FileMaintDelete "Esborrar partides duplicades..." 0 \
  {Cerca partides duplicades i les marca per ser esborrades}
menuText K FileMaintTwin "Finestra d'inspecci de duplicades" 11 \
  {Obre/actualiza la finestra d'inspecci de duplicades}
menuText K FileMaintName "Ortografia de noms" 0 {Eines d'ortografia i edici de noms}
menuText K FileMaintNameEditor "Finestra d'edici de noms" 22 \
  {Obre/tanca la finestra d'edici de noms}
menuText K FileMaintNamePlayer "Comprovaci ortogrfica de noms de jugadors..." 39 \
  {Comprovaci ortogrfica de jugadors fent servir un arxiu de comprovaci ortogrfica}
menuText K FileMaintNameEvent "Comprovaci ortogrfica de noms de torneigs..." 39 \
  {Comprovaci ortogrfica de torneigs fent servir l'arxiu de comprovaci ortogrfica}
menuText K FileMaintNameSite "Comprovaci ortogrfica de noms de llocs..." 39 \
  {Comprovaci ortogrfica de llocs fent servir l'arxiu de comprovaci ortogrfica}
menuText K FileMaintNameRound "Comprovaci ortogrfica de rondes..." 28 \
  {Comprovaci ortogrfica de rondes fent servir l'arxiu de comprovaci ortogrfica}
menuText K FileReadOnly "Noms de lectura..." 5 \
  {Tracta la actual base de dades com noms de lectura, prevenint canvis}
menuText K FileSwitch "Canviar de base de dades" 0 \
  {Canvia a una base de dades oberta diferent}
menuText K FileOpenLichessTournament "Torneig obert de Lichess" 0 {Baixeu i obriu jocs de transmissi del torneig Lichess en directe}
menuText K FileImportLichess "Importa la meva Lichess" 0 {Importa jocs des del teu compte de Lichess}
menuText K FileImportChessCom "Importa el meu chess.com" 0 {Importa jocs des del teu compte de chess.com}
menuText K FileExit "Sortir" 0 {Sortir de Scid}
menuText K FileMaintFixBase "Arreglar base corrupta" 0 {Intenta arreglar una base corrupta}

# Edit menu:
menuText K Edit "Editar" 0
menuText K EditAdd "Afegir variant" 0 \
  {Afegeix una variant amb aquesta jugada a la partida}
menuText K EditDelete "Esborrar variant" 0 {Esborra la variant d'aquesta jugada}
menuText K EditFirst "Convertir a primera variant" 0 \
  {Fa que una variant sigui la primera a la llista}
menuText K EditMain "Variant a lnia principal" 0 \
   {Promou una variant per a que sigui la lnia principal}
menuText K EditTrial "Provar variant" 1 \
  {Inicia/Atura el mode de prova, per a verificar una idea a l'escaquer}
menuText K EditStrip "Eliminar" 2 \
  {Eliminar comentaris o variants d'aquesta partida}
menuText K EditUndo "Desfs" 0 {Desfs l'ltim canvi de la partida}
menuText K EditRedo "Refs" 0 {Refs l'ltim canvi de la partida}
menuText K EditStripComments "Comentaris" 0 \
  {Esborra tots els comentaris i variants d'aquesta partida}
menuText K EditStripVars "Variants" 0 {Esborra totes les variants d'aquesta partida}
menuText K EditStripBegin "Jugades des del comenament" 1 \
  {Treu els moviments des del comenament de la partida}
menuText K EditStripEnd "Jugades fins el final" 0 \
  {Treu els moviments fins al final de la partida}
menuText K EditReset "Neteja la base de treball" 0 \
  {Neteja la base de treball (clipbase) per deixar-la completament buida}
menuText K EditCopy "Copiar aquesta partida a la base de treball" 1 \
  {Copia aquesta partida a la base de treball (clipbase)}
menuText K EditPaste "Enganxar l'ltima partida de la base de treball" 2 \
  {Enganxa al final de la base actual la partida activa de la base de treball (clipbase)}
menuText K EditPastePGN "Enganxa el text del Clipboard com una partida PGN..." 10 \
  {Interpreta el text de la base de treball (clipbase) com una partida en notaci PGN i l'enganxa}
menuText K EditSetup "Establir posici inicial..." 26 \
  {Inicia una posici a l'escaquer amb la posici de la partida}
menuText K EditCopyBoard "Copiar posici" 8 \
  {Copia la posici actual en notaci FEN a la selecci de text (clipboard)}
menuText K EditPasteBoard "Enganxar posici inicial" 6 \
  {Posa la posici inicial des de la selecci de text actual (clipboard)}
menuText K ConfigureScid "Preferncies..." 0 {Configura totes les opcions de l'SCID}

# Game menu:
menuText K Game "Partida" 0
menuText K GameNew "Nova partida" 0 \
  {Nova partida, descarta canvis de la partida actual}
menuText K GameFirst "Carregar primera partida" 7 {Carrega la primera partida filtrada}
menuText K GamePrev "Carregar partida anterior" 16 {Carrega la anterior partida filtrada}
menuText K GameReload "Recargar partida actual" 0 \
  {Torna a carregar aquesta partida, descartant qualsevol canvi introdut}
menuText K GameNext "Carregar propera partida " 7 {Carrega la propera partida filtrada}
menuText K GameLast "Carregar ltima partida" 9 {Carrega l'ltima partida filtrada}
menuText K GameRandom "Carregar partida aleatoria" 16 {Carrega aleatriament una partida filtrada}
menuText K GameNumber "Carregar partida nmero..." 3 \
  {Carrega una partida posant el seu nmero}
menuText K GameReplace "Desar: Reemplaa la partida..." 10 \
  {Desa aquesta partida, reemplaant-ne la versi anterior}
menuText K GameAdd "Desar: Afegir nova partida..." 9 \
  {Enregistra aquesta partida com una nova entrada a la base de dades}
menuText K GameDeepest "Identificar obertura" 1 \
  {Ves a la posici ms avanada de la partida d'acord amb el llibre ECO}
menuText K GameGotoMove "Anar a la jugada nmero..." 6 \
  {Ves al nmero de jugada especificat dins la partida actual}
menuText K GameNovelty "Trobar Novetat..." 12 \
  {Cerca la primera jugada d'aquesta partida que no s'ha jugat abans}

# Search Menu:
menuText K Search "Cercar" 0
menuText K SearchReset "Netejar el filtre" 0 \
  {Retorna el filtre a l'estat per defecte per a incloure-hi totes les partides}
menuText K SearchNegate "Invertir filtre" 0 \
  {Inverteix el filtre per incloure noms les partides prviament excloses}
menuText K SearchCurrent "Posici actual..." 0 \
  {Cerca per la posici actual de l'escaquer}
menuText K SearchHeader "Metadades..." 0 \
  {Cerca per les metadades de la capalera (jugador, torneig, etc)}
menuText K SearchMaterial "Material/Patr..." 0 \
  {Cerca posici per material o patr}
menuText K SearchUsing "Fer servir arxiu de recerca..." 0 \
  {Cerca fent servir un arxiu d'opcions de recerca}

# Windows menu:
menuText K Windows "Finestres" 0
menuText K WindowsComment "Editor de comentaris" 0 \
  {Obre/tanca l'editor de comentaris}
menuText K WindowsGList "Llistat de partides" 0 \
  {Obre/tanca la  finestra de llistat de partides}
menuText K WindowsPGN "Finestra PGN" 8 \
  {Obre/tanca la finestra PGN (notaci de partida)}
menuText K WindowsPList "Cercador de jugadors" 2 {Obre/tanca el cercador de jugadors}
menuText K WindowsTmt "Visor de torneigs" 9 {Obre/tanca el visor de torneigs}
menuText K WindowsSwitcher "Bescanviador de bases de dades" 0 \
  {Obre/tanca la finestra del bescanviador de bases de dades}
menuText K WindowsMaint "Finestra de manteniment" 11 \
  {Obre/tanca la finestra de manteniment}
menuText K WindowsECO "Cercador ECO" 0 {Obre/tanca la finestra del cercador ECO}
menuText K WindowsStats "Finestra d'estadstiques" 12 \
  {Obre/tanca la finestra d'estadstiques del filtre}
menuText K WindowsTree "Finestra de l'Arbre d'Obertures" 6 {Obre/tanca la finestra de l'Arbre d'Obertures (Book)}
menuText K WindowsBook "Finestra de Llibres d'Obertures" 0 {Obrir/Tancar la finestra de Llibres d'Obertures (Book)}
menuText K WindowsCorrChess "Finestra d'Escacs Postal" 0 {Obrir/Tancar la Finestra d'Escacs Postal}
menuText K WindowsGraph "Grfic d'anlisi" 0 {Obriu la finestra Grfic amb els temps i les avaluacions dels moviments}

# Tools menu:
menuText K Tools "Eines" 0
menuText K ToolsConfigureEngines "Configura motors" 10 {Canvia parmetres dels diferents motors}
menuText K ToolsAnalysis "Motor d'anlisi..." 0 \
  {Inicia/Atura un motor d'anlisi d'escacs}
menuText K ToolsAnalysis2 "Motor d'anlisi #2..." 18 \
  {Inicia/Atura el segon motor d'anlisi d'escacs}
menuText K ToolsCross "Quadre" 0 {Mostra el Quadre del torneig per aquesta partida}
menuText K ToolsFilterGraph "Filtre Grfic Rel." 7 \
  {Obre/tanca la finestra del filtre grfic per valors relatius}
menuText K ToolsAbsFilterGraph "Filtre grfic Abs." 7 {Obrir/Tancar la finestra de filtre grfic per valors absoluts}
menuText K ToolsOpReport "Informe d'obertura" 1 \
  {Crea un informe de l'obertura per la posici actual}
menuText K ToolsOpenBaseAsTree "Obrir base com a arbre" 0   {Obrir una base i utilitzar-la a la Finestre Arbre (Tree)}
menuText K ToolsOpenRecentBaseAsTree "Obrir base recent com a arbre" 0   {Obre una base recent i utilitzar-la a la Finestra Arbre (Tree)} 
menuText K ToolsTracker "Rastrejador de peces"  14 {Obre la finestra del rastrejador de peces}
menuText K ToolsTraining "Entrenament"  0 {Entrenament (tctica, obertures,...}
menuText K ToolsTacticalGame "Partida tctica"  0 {Jugar una partida tctica}
menuText K ToolsSeriousGame "Partida seriosa"  0 {Jugar una partida seriosa}
menuText K ToolsTrainOpenings "Obertures"  0 {Entrenament amb un repertori}
menuText K ToolsTrainReviewGame "Revisar partida"  0 {Endevina les jugades realitzades en una partida}
menuText K ToolsTrainTactics "Tctica"  0 {Resoldre problemes de tctica}
menuText K ToolsTrainCalvar "Clcul de variants"  0 {Clcul de variants}
menuText K ToolsTrainFindBestMove "Trobar la millor jugada"  0 {Cerca la millor jugada}
menuText K ToolsTrainFics "Jugar a Internet"  0 {Jugar a freechess.org}
menuText K ToolsEngineTournament "Torneig de motors"  0 {Comena un torneig entre motors}
menuText K ToolsTimeAnalysis "Anlisi del temps" 0 {Mostra el grfic del temps del rellotge per al joc actual}
menuText K ToolsBookTuning "Ajustar Llibre d'obertures" 0 {Ajustar Llibre (Book)}
menuText K ToolsDownloadTWIC "Descarrega partides TWIC" 0 {Descarrega les partides mÃ©s recents The Week In Chess (TWIC)}
menuText K ToolsConnectHardware "Connectar maquinari" 0 {Connectar maquinari extern}
menuText K ToolsConnectHardwareConfigure "Configuraci" 1 {Configuraci}
menuText K ToolsConnectHardwareNovagCitrineConnect "Connectar Novag" 0 {Connectar Novag}
menuText K ToolsConnectHardwareInputEngineConnect "Connectar dispositiu d'entrada" 0 {Connectar dispositiu d'entrada (com el de DGT) a Scid}

menuText K ToolsPInfo "Informaci del Jugador" 16 \
  {Obrir/actualitzar la finestra d'Informaci del Jugador}
menuText K ToolsPlayerReport "Informe del jugador..." 3 \
  {Crea un informe sobre un jugador}
menuText K ToolsRating "Grfic de l'Elo" 0 \
  {Grfic del historial Elo dels jugadors de la partida actual}
menuText K ToolsExpCurrent "Exportar la partida actual" 0 \
  {Escriu la partida actual a un arxiu de text}
menuText K ToolsExpCurrentPGN "Exportar la partida a un arxiu PGN..." 33 \
  {Escriu la partida actual a un arxiu PGN}
menuText K ToolsExpCurrentHTML "Exportar la partida a un arxiu HTML..." 33 \
  {Escriu la partida actual a un arxiu HTML}
menuText K ToolsExpCurrentHTMLJS "Exportar la partida a un arxiu HTML i JavaScript..." 15 {Escriu la partida actual a un arxiu HTML i JavaScript} 
menuText K ToolsExpFilter "Exportar totes les partides filtrades" 1 \
  {Escriu totes les partides filtrades a un arxiu de text}
menuText K ToolsExpFilterPGN "Exportar filtre a un arxiu PGN..." 29 \
  {Escriu totes les partides filtrades a un arxiu PGN}
menuText K ToolsExpFilterHTML "Exportar filtre a un arxiu HTML..." 29 \
  {Escriu totes les partides filtrades a un arxiu HTML}
menuText K ToolsExpFilterHTMLJS "Exportar filtre a un arxiu HTML i JavaScript..." 17 {Escriu totes les partides filtrades a un arxiu HTML i JavaScript}  
menuText K ToolsImportOne "Importar una partida PGN..." 0 \
  {Importa una partida de un text PGN}
menuText K ToolsImportFile "Importar un arxiu de partides PGN..." 2 \
  {Importa partides de un arxiu PGN}
menuText K ToolsStartEngine1 "Iniciar motor 1" 0  {Iniciar motor 1}
menuText K ToolsStartEngine2 "Iniciar motor 2" 0  {Iniciar Motor 2}
menuText K ToolsCaptureBoard "Desa posici actual" 0  {Desa la posici del tauler actual com a imatge.}

# Play menu
menuText K Play "Jugar" 0

# --- Correspondence Chess
menuText K CCResign "Abandonar" 0 {Abandonar}
menuText K CCClaimDraw "Reclamar taules" 0 {Enviar un jugada i reclamar taules}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText K Options "Opcions" 0
menuText K OptionsBoardGraphics "Caselles..." 0 {Escollir textures per les caselles}
translate K OptionsBGW {Escollir textura per les caselles}
translate K OptionsBoardGraphicsText {Escollir arxiu grfic per a les caselles blanques i negres}
menuText K OptionsBoardNames "Els meus noms..." 0 {Edita els noms amb els que pot aparixer un jugador}
menuText K OptionsExport "Exportaci" 0 {Canvia les opcions d'exportaci de text}
menuText K OptionsFonts "Fonts" 0 {Canvia les fonts}
menuText K OptionsFontsRegular "Habitual" 0 {Canvia la font habitual}
menuText K OptionsFontsMenu "Men" 0 {Canvia la font del men}
menuText K OptionsFontsSmall "Petita" 0 {Canvia a mida de font petita}
menuText K OptionsFontsTiny "Diminuta" 0 {Canvia a mida de font diminuta}
menuText K OptionsFontsFixed "Fixa" 0 {Canvia la amplada de la font a fixa}
menuText K OptionsGInfo "Informaci de la partida" 0 {Informaci de la partida}
menuText K OptionsLanguage "Llenguatge" 0 {Selecciona el llenguatge del programa}
menuText K OptionsMovesTranslatePieces "Tradueix nom de les peces" 0 {Tradueix la primera lletra del nom de les peces al tauler de notaci}
menuText K OptionsMovesHighlightLastMove "Mostra ltima jugada" 0 {Ressalta l'ltima jugada'}
menuText K OptionsMovesHighlightLastMoveDisplay "Mostra casella" 0 {Ressalta la casella de l'ltima jugada}
menuText K OptionsMovesHighlightLastMoveWidth "Gruix" 0 {Gruix de lnia}
menuText K OptionsMovesHighlightLastMoveColor "Color" 0 {Color de lnia}
menuText K OptionsMovesHighlightLastMoveArrow "Mostra fletxa" 0 {Inclou fletxa amb ressaltat}
menuText K OptionsMovesHighlightLastMoveNag "Mostra smbols d'avaluaci" 0
menuText K OptionsMovesHighlightLastMoveEval "Mostra smbols d'avaluaci" 0
menuText K OptionsMoves "Jugades" 0 {Opcions d'entrada de jugades}
menuText K OptionsMovesAnimate "Velocitat d'animaci" 1 \
  {Posa el temps d'animaci entre jugades}
menuText K OptionsMovesDelay "Retard de la jugada automtica..." 0 \
  {Posa el temps de retard per la modalitat de autojugada}
menuText K OptionsMovesCoord "Entrada de jugades per coordenades" 0 \
  {Accepta entrada de jugades pel sistema de "coordenades" ("g1f3")}
menuText K OptionsMovesSuggest "Mostrar suggeriments" 20 \
  {Activa/desactiva el suggeriment de jugades}
menuText K OptionsShowVarPopup "Mostrar finestra de variants" 0 {Activar/Desactivar la finestra de variants}
menuText K OptionsMovesSpace "Afegir espai desprs del nmero de jugada" 0 {Afegir espai desprs del nmero de jugada}  
menuText K OptionsMovesLichess "Format Lichess/ChessBase per a anotacions" 0 {Utilitzeu el format Lichess/ChessBase per als marcadors quadrats i les fletxes}
menuText K OptionsMovesKey "Teclat Intelligent" 0 \
{Activa/desactiva la funci d'autocompletat intelligent de jugades amb teclat}
menuText K OptionsMovesShowVarArrows "Mostra fletxes per a les variants" 0 {Activa o desactiva la mostra de fletxes per a les variants sobre el tauler}
menuText K OptionsMovesShowEngineVariationArrows "Mostra les fletxes per a les variacions del motor" 0 {Activar/desactivar les fletxes que mostren les lnies de variaci del motor en mode multiPV}
menuText K OptionsMovesGlossOfDanger "Marques de perill de colors" 0 {Activa o desactiva les marques de perill de colors}
translate K OptionsMovesTreeDepth {Profunditat de moviment de la finestra de l'arbre per defecte}
menuText K OptionsNumbers "Format de nmeros" 11 {Selecciona el format de nmeros}
menuText K OptionsTheme "Tema" 0 {Canviar l'aspecte del programari}
menuText K OptionsWindows "Finestres" 0 {Opcions de finestra}
menuText K OptionsSounds "Sons" 2 {Configura el so d'anunci de les jugades}
menuText K OptionsResources "Recursos..." 0 {Tria carpetes i fitxers de recursos}
menuText K OptionsWindowsDock "Bloqueja finestres" 0 {Bloqueja i agrupa finestres}
menuText K OptionsWindowsSaveLayout "Desar disposici" 0 {Desar disposici}
menuText K OptionsWindowsRestoreLayout "Restaurar disposici" 0 {Restaurar disposici}
menuText K OptionsWindowsShowGameInfo "Mostrar informaci de la partida" 0 {Mostrar informaci de la partida}
menuText K OptionsWindowsAutoLoadLayout "Auto carregar primera disposici" 0 {Autocarregar primera disposici en comenar}
menuText K OptionsECO "Cargar arxiu ECO..." 7 \
  {Cargar l'arxiu de clasificaci ECO}
menuText K OptionsSpell "Cargar arxiu de comprovaci ortogrfica..." 2 \
  {Carga l'arxiu de comprovaci ortogrfica Scid}
menuText K OptionsTable "Directori de les TB...(Taules de finals)" 19 \
  {Selecciona el directori de finals; s'utilitzaran totes les TB d'aquest directori}
menuText K OptionsRecent "Arxius recents..." 9 \
  {Canvia el nombre d'arxius recentes que es mostren al men Arxiu}
menuText K OptionsBooksDir "Carpeta de llibres d'obertures..." 0 {Fixa la carpeta d'els llibres d'obertures (Books)}
menuText K OptionsTacticsBasesDir "Carpeta de bases de dades..." 0 {Fixa la carpeta de la base d'entrenament tctic}
menuText K OptionsPhotosDir "Directori d'imatges..." 0 {Configura el directori base per a imatges}
menuText K OptionsThemeDir "Fitxer(s) d'aspecte:"  0 { Carrega un fitxer d'aspecte de la interfcie }
menuText K OptionsSave "Desar opcions" 0 \
  {Desa totes les opcions a l'arxiu $::optionsFile}
menuText K OptionsAutoSave "Autoguardar opcions en sortir" 0 \
  {Guarda automticament totes les opcions quan es surt de Scid}

# Help menu:
menuText K Help "Ajuda" 1
menuText K HelpContents "Continguts" 0 {Mostra la pgina de continguts del fitxer d'ajuda}
menuText K HelpIndex "ndex" 0 {Mostra la pgina d'ndex del fitxer d'ajuda}
menuText K HelpGuide "Guia rpida" 0 {Mostra la pgina de guia rpida del fitxer d'ajuda}
menuText K HelpHints "Suggeriments" 1 {Mostra la pgina de suggeriments del fitxer d'ajuda}
menuText K HelpContact "Informaci de contacte" 15 \
  {Mostra la pgina d'informaci de contacte del fitxer d'ajuda}
menuText K HelpTip "Suggeriment del dia" 0 {Mostra un prctic suggerimentent de Scid}
menuText K HelpStartup "Finestra d'inici" 0 {Mostra la finestra d'inici}
menuText K HelpAbout "Sobre l'Scid" 10 {Informaci al voltant de Scid}

# Toolbar tooltips:
menuText K RotateBoard "Gira el tauler" 0 {Gira el tauler}

# Game info box popup menu:
menuText K GInfoHideNext "Ocultar segent jugada" 0
menuText K GInfoMaterial "Mostrar valor del material" 0
menuText K GInfoFEN "Mostrar FEN" 8
menuText K GInfoMarks "Mostrar caselles i fletxes de colors" 29
menuText K GInfoWrap "Dividir lnies llargues" 0
menuText K GInfoFullComment "Mostrar comentaris complets" 8
menuText K GInfoPhotos "Mostrar fotografies" 5
menuText K GInfoTBNothing "TBs: res" 5
menuText K GInfoTBResult  "TBs: noms resultat" 10
menuText K GInfoTBAll "TBs: resultat i millor jugada" 23
menuText K GInfoDelete "(No)Esborrar aquesta partida" 4
menuText K GInfoMark "(No)Marcar aquesta partida" 4
menuText K GInfoInformant "Configurar valors d'informaci" 0

# General buttons:
translate K Back {Enrera}
translate K Browse {Mirar}
translate K Cancel {Cancellar}
translate K Continue {Continuar}
translate K Clear {Netejar}
translate K Close {Tancar}
translate K Contents {Continguts}
translate K Defaults {Per defecte}
translate K InvertSearch {Inverteix la cerca}
translate K Delete {Esborrar}
translate K Graph {Grfic}
translate K Help {Ajut}
translate K Hide {Amaga}
translate K Import {Importar}
translate K Index {ndex}
translate K LoadGame {Cargar partida}
translate K BrowseGame {Mirar partida}
translate K MergeGame {Incorporar partida}
translate K MergeGames {Barrejar o fusionar partides}
translate K Preview {Vista prvia}
translate K Revert {Retrocedir}
translate K Save {Desar}
translate K Search {Cercar}
translate K Stop {Aturar}
translate K Store {Enregistrar}
translate K Update {Actualitzar}
translate K ChangeOrient {Canviar l'orientaci de la finestra}
translate K ShowIcons {Mostra Icones} 
translate K None {Cap}
translate K First {Primera}
translate K Current {Actual}
translate K Last {ltima}

# General messages:
translate K game {partida}
translate K games {partides}
translate K move {jugada}
translate K moves {jugades}
translate K all {tod}
translate K Yes {S}
translate K No {No}
translate K Both {Ambdos}
translate K King {Rei}
translate K Queen {Dama}
translate K Rook {Torre}
translate K Bishop {Alfil}
translate K Knight {Cavall}
translate K Pawn {Pe}
translate K White {Blanques}
translate K Black {Negres}
translate K Player {Jugador}
translate K Rating {Elo}
translate K RatingDiff {Diferncia d'Elo (Blanques - Negres)}
translate K AverageRating {Elo promig}
translate K Event {Torneig}
translate K Site {Lloc}
translate K Country {Pais}
translate K IgnoreColors {Ignorar colors}
translate K Date {Data}
translate K EventDate {Data del torneig}
translate K Decade {Dcada}
translate K Year {Any}
translate K Month {Mes}
translate K Months {gener febrer mar abril maig juny juliol agost setembre octubre novembre desembre}
translate K Days {diu dil dim dic dij div dis}
translate K YearToToday {Any fins avui}
translate K YearToTodayTooltip {Estableix la data a la d'un any abans d'avui}
translate K Result {Resultat}
translate K Round {Ronda}
translate K Length {Longitut}
translate K ECOCode {Codi ECO}
translate K ECO {ECO}
translate K Deleted {Esborrar}
translate K SearchResults {Cercar resultats}
translate K OpeningTheDatabase {Obrint base de dades}
translate K Database {Base de dades}
translate K Filter {Filtre}
translate K noGames {no hi ha partides}
translate K allGames {totes les partides}
translate K empty {buida}
translate K clipbase {clipbase}
translate K score {puntuaci}
translate K StartPos {Posici inicial}
translate K Total {Total}
translate K readonly {noms de lectura}

# Standard error messages:
translate K ErrNotOpen {La base de dades no est oberta.}
translate K ErrReadOnly {Aquesta base de dades es noms de lectura; no pot ser modificada.}
translate K ErrSearchInterrupted {Recerca aturada; els resultats den ser incomplets.}
translate K ErrNoClockComments {No s'han trobat comentaris de rellotge [%clk] en aquest joc.    Afegiu hores de rellotge mitjanant la finestra de comentaris (Ctrl+E) per utilitzar aquesta funci.}
translate K ErrFileInUse {Error: el fitxer ja est en s. Tanqueu qualsevol altra aplicaci que utilitzi aquesta base de dades. Si el programa es va tancar de manera inesperada, s possible que hgiu d'eliminar el fitxer .lock associat a la base de dades.}




# Game information:
translate K twin {doble}
translate K deleted {esborrades}
translate K comment {comentari}
translate K hidden {ocult}
translate K LastMove {ltima jugada}
translate K NextMove {Seguent}
translate K GameStart {Inici de partida}
translate K LineStart {Inici de lnia}
translate K GameEnd {Final de partida}
translate K LineEnd {Final de lnia}

# Player information:
translate K PInfoAll {Resultats per <b>totes</b> les partides}
translate K PInfoFilter {Resultats per les partides <b>filtrades</b>}
translate K PInfoAgainst {Resultats en contra}
translate K PInfoMostWhite {Obertures ms comuns amb Blanques}
translate K PInfoMostBlack {Obertures ms comuns amb Negres}
translate K PInfoRating {Historial de classificaci}
translate K PInfoBio {Biografia}
translate K PInfoEditRatings {Editar elos}
translate K PInfoEloFile {Fitxer}

# Tablebase information:
translate K Draw {Taules}
translate K with {amb}
translate K only {noms}
translate K lose {maneres de perdre}
translate K loses {fa perdre}

# Tip of the day:
translate K Tip {Suggeriment}
translate K TipAtStartup {Suggeriment en comenar}
translate K TipConvertPGN {Pots obtenir un millor rendiment convertint fitxers PGN}

# Tree window menus:
menuText K TreeFile "Arxiu" 0
menuText K TreeFileFillWithBase "Omplir memria cau amb base" 0 {Omplir la memria cau amb totes les partides de la base actual}
menuText K TreeFileFillWithGame "Omplir memria cau amb partida" 0 {Omple la memria cau amb la partida actual de la base actual}
menuText K TreeFileSetCacheSize "Tamany de memria cau" 0 {Estableix el tamany del memria cau}
menuText K TreeFileCacheInfo "Informaci de memria cau" 0 {Informaci i s de la memria cau}
menuText K TreeFileSave "Desar arxiu memria cau" 0 \
  {Desa l'arxiu memria cau de l'arbre (.stc)}
menuText K TreeFileFill "Construir arbre a la memria cau" 2 \
  {Construir arxiu memria cau amb posiciones d'obertura comunes}
menuText K TreeFileBest "Llista de millors partides" 9 {Mostra la llista de l'arbre amb les millors partides}
menuText K TreeFileGraph "Finestra grfica de l'arbre" 0 \
  {Mostra un grfic per aquesta branca de l'arbre}
menuText K TreeFileCopy "Copiar text de l'arbre al clipboard" 1 \
  {Copiar text de l'arbre al clipboard}
menuText K TreeFileClose "Tancar finestra de l'arbre" 0 \
  {Tancar finestra de l'arbre}
menuText K TreeMask "Mscara" 0
menuText K TreeMaskNew "Nova" 0 {Nova mscara}
menuText K TreeMaskOpen "Obrir" 0 {Obrir mscara}
menuText K TreeMaskOpenRecent "Obre recent" 0 {Obre mscara recent}
menuText K TreeMaskSave "Desar" 0 {Desar mscara}
menuText K TreeMaskClose "Tancar" 0 {Tancar mscara}
menuText K TreeMaskFillWithGame "Omplir amb partida" 0 {Omple la mscara amb la partida}
menuText K TreeMaskFillWithBase "Omplir amb base" 0 {Omple la mscara amb totes les partides de la base}
menuText K TreeMaskInfo "Info" 0 {Mostra estadstiques per la mscara actual}
menuText K TreeMaskDisplay "Mostra el mapa de mscares" 0 {Mostra les dades de la mscara en forma d'arbre}
menuText K TreeMaskSearch "Cerca" 0 {Cerca dins de la mscara actual}
menuText K TreeSort "Ordenar" 0
menuText K TreeSortAlpha "Alfabticament" 0
menuText K TreeSortECO "Per codi ECO" 11
menuText K TreeSortFreq "Per freqencia" 4
menuText K TreeSortScore "Per puntuaci" 4
menuText K TreeOpt "Opcions" 1
menuText K TreeOptSlowmode "Mode Lent" 0 {Jugada lenta per actualitzacions (Alta qualitat)}
menuText K TreeOptFastmode "Mode Rpid" 0 {Jugada rpida per actualitzacions (no trasllada jugades)}
menuText K TreeOptFastAndSlowmode "Mode Rpid i Lent" 0 {Jugada rpida i mode lent per actualitzacions}
menuText K TreeOptStartStop "Auto actualitzat" 0 {Actualizat automtic de la finestra de l'arbre}
menuText K TreeOptLock "Bloquejar" 1 {Bloqueja/desbloqueja l'arbre de la base de dades actual}
menuText K TreeOptTraining "Entrenament" 2 {Activa/desactiva el mode d'entrenament de l'arbre}
menuText K TreeOptDepth "Moure la profunditat" 0 {Nombre de mig moviments per mostrar a l'arbre (1-4)}
menuText K TreeOptAutosave "Autoguardar arxiu memria cau" 0 \
  {Desar automticament l'arxiu memria cau quan es tanca la finestra de l'arbre}
menuText K TreeHelp "Ajut" 1
menuText K TreeHelpTree "Ajut de l'arbre" 4
menuText K TreeHelpIndex "ndex del fitxer d'ajuda" 0
translate K SaveCache {Desar memria cau}
translate K Training {Entrenament}
translate K LockTree {Bloquejar}
translate K TreeDepth {Profunditat de l'arbre (meitat de moviments):}
translate K TreeLocked {Bloquejat}
translate K TreeBest {Millor}
translate K TreeBestGames {Millors partides de l'arbre}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate K TreeTitleRow \
{Movim.                        ECO       Freqencia   Puntu. EloPm Perf AnyPm %Taules      %Guanyar}
translate K TreeTotal {TOTAL}
translate K DoYouWantToSaveFirst {Vols desar-ho abans}
translate K AddToMask {Afegir a mscara}
translate K RemoveFromMask {Elimina des de la mscara}
translate K AddThisMoveToMask {Afegir aquesta jugada a la Mscara}
translate K SearchMask {Cerca a la mscara}
translate K DisplayMask {Mostra mscara}
translate K Nag {Codi Nag}
translate K Marker {Marcador}
translate K Include {Incloure}
translate K Exclude {Excloure}
translate K MainLine {Lnia principal}
translate K Bookmark {Preferida}
translate K NewLine {Lnia nova}
translate K ToBeVerified {Per a verificar}
translate K ToTrain {Per a entrenar}
translate K Dubious {Dubts}
translate K ToRemove {Per a treure}
translate K NoMarker {Sense marcador}
translate K ColorMarker {Color}
translate K WhiteMark {Blanc}
translate K GreenMark {Verd}
translate K YellowMark {Groc}
translate K BlueMark {Blau}
translate K RedMark {Vermell}
translate K CommentMove {Comentar jugada}
translate K CommentPosition {Comentar posici}
translate K AddMoveToMaskFirst {Afegir primer la jugada a la mscara}
translate K OpenAMaskFileFirst {Obrir primer un arxiu de mscara}
translate K Positions {Posicions}
translate K Moves {Jugades}

# Finder window:
menuText K FinderFile "Arxiu" 0
menuText K FinderFileSubdirs "Mirar als subdirectoris" 0
menuText K FinderFileClose "Tanca el visor d'Arxius" 0
menuText K FinderSort "Ordenar" 0
menuText K FinderSortType "Tipus" 0
menuText K FinderSortSize "Tamany" 0
menuText K FinderSortMod "Modificat" 0
menuText K FinderSortName "Nom" 0
menuText K FinderSortPath "Cam" 0
menuText K FinderTypes "Tipus" 0
menuText K FinderTypesScid "Bases de dades Scid" 0
menuText K FinderTypesOld "Bases de dades Scid en format antic" 12
menuText K FinderTypesPGN "Arxius PGN" 9
menuText K FinderTypesEPD "Arxius EPD (llibre)" 0
menuText K FinderTypesRep "Arxius de Repertori" 12
menuText K FinderHelp "Ajut" 1
menuText K FinderHelpFinder "Ajut del visor d'Arxius" 0
menuText K FinderHelpIndex "ndex de l'ajut" 0
translate K FileFinder {Visor d'Arxius}
translate K FinderDir {Directori}
translate K FinderDirs {Directoris}
translate K FinderFiles {Arxius}
translate K FinderUpDir {amunt}
translate K FinderCtxOpen {Obrir}
translate K FinderCtxBackup {Cpia de seguretat (Backup)}
translate K FinderCtxCopy {Cpia}
translate K FinderCtxMove {Jugada}
translate K FinderCtxDelete {Esborrar}

# Player finder:
menuText K PListFile "Arxiu" 0
menuText K PListFileUpdate "Actualitzar" 0
menuText K PListFileClose "Tanca el Cercador de Jugadors" 0
menuText K PListSort "Ordenar" 0
menuText K PListSortName "Nom" 0
menuText K PListSortElo "Elo" 0
menuText K PListSortGames "Partides" 0
menuText K PListSortOldest "Ms antiga" 10
menuText K PListSortNewest "Ms nova" 4

# Tournament finder:
menuText K TmtFile "Arxiu" 0
menuText K TmtFileUpdate "Actualitzar" 0
menuText K TmtFileClose "Tanca el visor de torneigs" 0
menuText K TmtSort "Ordenar" 0
menuText K TmtSortDate "Data" 0
menuText K TmtSortPlayers "Jugadors" 0
menuText K TmtSortGames "Partides" 0
menuText K TmtSortElo "Elo" 0
menuText K TmtSortSite "Lloc" 0
menuText K TmtSortEvent "Torneig" 1
menuText K TmtSortWinner "Guanyador" 0
translate K TmtLimit "Lmit de llista"
translate K TmtMeanElo "Promig d'Elo inferior"
translate K TmtNone "No s'han trovat torneig que coincideixin."

# Graph windows:
menuText K GraphFile "Arxiu" 0
menuText K GraphFileColor "Guardar com Postscript Color..." 24
menuText K GraphFileGrey "Guardar com Postscript escala de grisos..." 34
menuText K GraphFileClose "Tancar finestra" 7
menuText K GraphOptions "Opcions" 0
menuText K GraphOptionsWhite "Blanques" 0
menuText K GraphOptionsBlack "Negres" 0
menuText K GraphOptionsBoth "Ambdos" 0
menuText K GraphOptionsPInfo "Opcions informaci jugador" 0
menuText K GraphOptionsEloFile "Elo des de fitxer de qualificaci" 0
menuText K GraphOptionsEloDB "Elo des de la base de dades" 0
translate K GraphFilterTitle "Filtre Grfic: percentatge de jocs que arriben a la posici"
translate K GraphAbsFilterTitle "Filtre grfic: freqencia de les partides"
translate K ConfigureFilter {Configurar Eix-X per Any, Rating i Jugades}
translate K FilterEstimate "Estimar"
translate K TitleFilterGraph "Scid: Filtre Grfic"

# Analysis window:
translate K AddVariation {Afegir variant}
translate K AddAllVariations {Afegir totes les variants}
translate K AddMove {Afegir jugada}
translate K Annotate {Anotar}
translate K ShowAnalysisBoard {Mostrar escaquer d'anlisi}
translate K ShowInfo {Mostra info del motor}
translate K FinishGame {Finalitzar partida}
translate K StopEngine {Parar motor}
translate K StartEngine {Iniciar motor}
translate K LockEngine {Bloqueja motor en la posici actual}
translate K AnalysisCommand {Direcci d'anlisi}
translate K PreviousChoices {Eleccions prvies}
translate K AnnotateTime {Posar el temps entre jugades a segons}
translate K AnnotateWhich {Afegir variants}
translate K AnnotateAll {Per a jugades dels dos bndols}
translate K AnnotateAllMoves {Anotar totes les jugades}
translate K AnnotateWhite {Noms per jugades de les Blanques}
translate K AnnotateBlack {Noms per jugades de les Negres}
translate K AnnotateBlundersOnly {Quan la jugada de la partida es un error}
translate K AnnotateBlundersOnlyScoreChange {Anlisi informant d'errors, amb canvi de puntuaci des de: }
translate K BlundersThreshold {Marge d'error }
translate K ScoreAllMoves {Avalua totes les jugades}
translate K LowPriority {Baixa prioritat del processador}
translate K ClickHereToSeeMoves {Prem aqu per veure les jugades}
translate K ConfigureInformant {Anotacions}
translate K Informant!? {Jugada interesant}
translate K Informant? {Jugada dolenta}
translate K Informant?? {Jugada desastrosa}
translate K Informant?! {Jugada dubtosa}
translate K Informant+= {Les Blanques tenen un lleuger avantatge}
translate K Informant+/- {Les Blanques tenen avantatge}
translate K Informant+- {Les Blanques tenen un avantatge decisiu}
translate K Informant+-- {La partida es considerada com guanyada}
translate K AutoComment {Comentari automtic}
translate K AutoCommentTooltip {Genereu comentaris d'IA per a la posici actual}
translate K AnalysisAutoCommentTooltip {Genera comentaris d'IA per a tot el joc}
translate K GameComment {Comentari del joc}
translate K GameCommentTooltip {Escaneja el joc per trobar moviments anotats i genera un resum de l'IA}
translate K TimeMs {Temps (ms)}


# Book window
translate K Book {Llibre}
translate K OtherBookMoves {Altres jugades del llibre}
translate K OtherBookMovesTooltip {Jugades a les que el contrari te una respuesta}

# Analysis Engine open dialog:
translate K EngineList {Llista de Motors d'Anlisi}
translate K EngineName {Nom}
translate K EngineCmd {Ordre}
translate K EngineArgs {Parmetres}
translate K EngineDir {Directori}
translate K EngineElo {Elo}
translate K EngineTime {Data}
translate K EngineNew {Nova}
translate K EngineEdit {Editar}
translate K EngineRequired {Els camps en negreta son obligatoris; la resta opcionals}
translate K EngineProtocol {Protocol de comunicaci}
translate K EngineNotation {Anotaci de les jugades}
translate K EngineFlipEvaluation {Inverteix perspectiva d'avaluaci}
translate K EngineShowLog {Mostra histric de comunicacions}
translate K EngineNetworkd {Accepta connexions remotes}
translate K EngineSelect {Selecciona el motor actual}
translate K EngineAddLocal {Afegeix motor local}
translate K EngineAddRemote {Afegeix motor en remot}
translate K EngineReload {Recarrega motor actual}
translate K EngineClone {Crea una cpia del motor actual}
translate K EngineDelete {Esborra el motor actual}

# PGN window menus:
menuText K PgnFile "Arxiu" 0
menuText K PgnFileCopy "Copiar partida al portapapers" 0
menuText K PgnFilePrint "Imprimir a arxiu..." 0
menuText K PgnFileClose "Tancar finestra PGN" 0
menuText K PgnOpt "Presentaci" 0
menuText K PgnOptColor "Color de la presentaci" 0
menuText K PgnOptShort "Encapalament petit (3 lnies)" 13
menuText K PgnOptSymbols "Anotacions simbliques" 0
menuText K PgnOptIndentC "Sangria a comentaris" 0
menuText K PgnOptIndentV "Sangria a variants" 11
menuText K PgnOptColumn "Estil de columna (un jugada per lnia)" 1
menuText K PgnOptSpace "Espai desprs del nmero del jugada" 0
menuText K PgnOptStripMarks "Treure codis de color a cassella/fletxa" 3
menuText K PgnOptBoldMainLine "Utilitzar text en negreta per les jugades principals" 4
menuText K PgnColor "Colors" 1
menuText K PgnColorHeader "Encapalament..." 0
menuText K PgnColorAnno "Anotacions..." 0
menuText K PgnColorComments "Comentaris..." 0
menuText K PgnColorVars "Variants..." 0
menuText K PgnColorBackground "Fons..." 0
menuText K PgnColorMain "Lnia principal..." 0
menuText K PgnColorCurrent "Color de fons de l'ltima jugada..." 1
menuText K PgnHelp "Ajut" 1
menuText K PgnHelpPgn "Ajut de PGN" 9
menuText K PgnHelpIndex "ndex de l'ajut" 0
translate K PgnWindowTitle {Planilla - partida %u}

# Crosstable window menus:
menuText K CrosstabFile "Arxiu" 0
menuText K CrosstabFileText "Imprimir a arxiu text..." 20
menuText K CrosstabFileHtml "Imprimir a arxiu HTML..." 20
menuText K CrosstabFileClose "Tancar finestra de graella" 0
menuText K CrosstabEdit "Editar" 0
menuText K CrosstabEditEvent "Torneig" 0
menuText K CrosstabEditSite "Lloc" 0
menuText K CrosstabEditDate "Data" 0
menuText K CrosstabOpt "Presentaci" 0
menuText K CrosstabOptAll "Tots contra tots" 0
menuText K CrosstabOptSwiss "Sus" 0
menuText K CrosstabOptKnockout "Eliminatria directa" 0
menuText K CrosstabOptAuto "Auto" 0
menuText K CrosstabOptAges "Edat en anys" 1
menuText K CrosstabOptNats "Nacionalitats" 0
menuText K CrosstabOptRatings "Elo" 0
menuText K CrosstabOptTitles "Ttols" 0
menuText K CrosstabOptBreaks "Puntuacions de desempat" 0
menuText K CrosstabOptDeleted "Incluore partides esborrades" 17
menuText K CrosstabOptColors "Colors (noms a la taula d'un Sus)" 0
menuText K CrosstabOptColumnNumbers "Columnes numerades (Noms en la taula tots contra tots)" 11
menuText K CrosstabOptGroup "Grups de classificaci" 0
menuText K CrosstabSort "Ordenar" 0
menuText K CrosstabSortName "Per nom" 4
menuText K CrosstabSortRating "Per Elo" 4
menuText K CrosstabSortScore "Per puntuaci" 4
menuText K CrosstabColor "Color" 2
menuText K CrosstabColorPlain "Text simple" 0
menuText K CrosstabColorHyper "Hipertext" 0
menuText K CrosstabHelp "Ajut" 1
menuText K CrosstabHelpCross "Ajut de Classificaci" 9
menuText K CrosstabHelpIndex "ndex de l'ajut" 0
translate K SetFilter {Posar filtre}
translate K AddToFilter {Afegir al filtre}
translate K Swiss {Sus}
translate K Category {Categora}

# Opening report window menus:
menuText K OprepFile "Arxiu" 0
menuText K OprepFileText "Imprimir a arxiu text..." 20
menuText K OprepFileHtml "Imprimir a arxiu HTML..." 20
menuText K OprepFileOptions "Opcions..." 0
menuText K OprepFileClose "Tancar finestra de l'informe d'obertura" 0
menuText K OprepFavorites "Preferits" 1
menuText K OprepFavoritesAdd "Afegir informe..." 0
menuText K OprepFavoritesEdit "Editar informe preferit..." 0
menuText K OprepFavoritesGenerate "Generar informe..." 0
menuText K OprepHelp "Ajut" 1
menuText K OprepHelpReport "Ajut de l'informe de l'obertura" 11
menuText K OprepHelpIndex "ndex de l'ajut" 0

# Header search:
translate K HeaderSearch {Cerca per metadades}
translate K EndSideToMove {Bndol a moure ver al final de la partida}
translate K GamesWithNoECO {Partides sense ECO?}
translate K GameLength {Duraci:}
translate K FindGamesWith {Trobar partides amb}
translate K StdStart {Inici estandar}
translate K Promotions {Promocions}
translate K Comments {Comentaris}
translate K Variations {Variants}
translate K Annotations {Anotacions}
translate K DeleteFlag {Marques d'esborrat}
translate K WhiteOpFlag {Obertura de les blanques}
translate K BlackOpFlag {Obertura de les negres}
translate K MiddlegameFlag {Mig joc}
translate K EndgameFlag {Finals}
translate K NoveltyFlag {Novetat}
translate K PawnFlag {Estructura de peons}
translate K TacticsFlag {Tctiques}
translate K QsideFlag {Joc de flanc de dama}
translate K KsideFlag {Joc de flanc de rei}
translate K BrilliancyFlag {Genialitat}
translate K BlunderFlag {Error}
translate K UserFlag {Usuari}
translate K PgnContains {PGN cont text}
translate K PgnTag {Etiqueta}
translate K TagContains {cont}
translate K Variant {Variant}
translate K Annotator {Comentarista}
translate K Cmnts {Noms partides comentades}

# Game list window:
translate K GlistNumber {Nmero}
translate K GlistWhite {Blanques}
translate K GlistBlack {Negres}
translate K GlistWElo {Elo-B}
translate K GlistBElo {Elo-N}
translate K GlistEvent {Torneig}
translate K GlistSite {Lloc}
translate K GlistRound {Ronda}
translate K GlistDate {Data}
translate K GlistYear {Any}
translate K GlistEDate {Torneig-Data}
translate K GlistResult {Resultat}
translate K GlistLength {Longitud}
translate K GlistCountry {Pais}
translate K GlistECO {ECO}
translate K GlistOpening {Obertura}
translate K GlistEndMaterial {Material final}
translate K GlistDeleted {Esborrat}
translate K GlistFlags {Senyal}
translate K GlistVars {Variants}
translate K GlistComments {Comentaris}
translate K GlistAnnos {Anotacions}
translate K GlistStart {Inici}
translate K GlistGameNumber {Nmero de partida}
translate K GlistAverageElo {Elo Mitj}
translate K GlistRating {Qualificaci}
translate K GlistFindText {Trobar text}
translate K GlistMoveField {Jugades}
translate K GlistEditField {Configurar}
translate K GlistAddField {Afegir}
translate K GlistDeleteField {Treure}
translate K GlistWidth {Amplada}
translate K GlistAlign {Alinear}
translate K GlistAlignL {Alinea: esquerra}
translate K GlistAlignR {Alinea: dreta}
translate K GlistAlignC {Alinea: centre}
translate K GlistColor {Color}
translate K GlistSep {Separador}
translate K GlistCurrentSep {-- Actual --}
translate K GlistNewSort {Nova}
translate K GlistAddToSort {Afegir}

# base sorting
translate K GsortSort {Ordena...}
translate K GsortDate {Data}
translate K GsortYear {Any}
translate K GsortEvent {Esdeveniment}
translate K GsortSite {Lloc}
translate K GsortRound {Ronda}
translate K GsortWhiteName {Nom Blanques}
translate K GsortBlackName {Nom Negres}
translate K GsortECO {ECO}
translate K GsortResult {Resultat}
translate K GsortMoveCount {Nombre de jugades}
translate K GsortAverageElo {Elo Mitj}
translate K GsortCountry {Pais}
translate K GsortDeleted {Esborrada}
translate K GsortEventDate {Data Esdeveniment}
translate K GsortWhiteElo {Elo Blanques}
translate K GsortBlackElo {Elo Negres}
translate K GsortComments {Comentaris}
translate K GsortVariations {Variants}
translate K GsortNAGs {NAGs}
translate K GsortAscending {Ascendent}
translate K GsortDescending {Descendent}
translate K GsortAdd {Afegeix}
translate K GsortStore {Emmagatzema}
translate K GsortLoad {Carrega}

# menu shown with right mouse button down on game list.
translate K GlistRemoveThisGameFromFilter  {Treu aquesta partida del Filtre}
translate K GlistRemoveGameAndAboveFromFilter  {Treu aquesta partida i totes les de sobre del Filtre}
translate K GlistRemoveGameAndBelowFromFilter  {Treu aquesta partida i totes les de sota del Filtre}
translate K GlistDeleteGame {Elimina/Recupera aquesta partida de la base} 
translate K GlistDeleteAllGames {Elimina totes les partides de la base que hi son al Filtre} 
translate K GlistUndeleteAllGames {Recupera totes les partides esborrades de la base que hi son al filtre} 
translate K GlistMergeGameInBase {Barreja la partida a una altra base} 

# Maintenance window:
translate K DatabaseName {Nom de la base:}
translate K TypeIcon {Tipus d'icona:}
translate K NumOfGames {Partides:}
translate K NumDeletedGames {Partides esborrades:}
translate K NumFilterGames {Partides al filtre:}
translate K YearRange {Rang d'anys:}
translate K RatingRange {Rang d'Elo:}
translate K Description {Descripci}
translate K Flag {Marca}
translate K CustomFlags {Etiquetes personalitzades}
translate K DeleteCurrent {Esborrar partida actual}
translate K DeleteFilter {Esborrar partides filtrades}
translate K DeleteAll {Esborrar totes les partides}
translate K UndeleteCurrent {No esborrar partida actual}
translate K UndeleteFilter {No esborrar partides filtrades}
translate K UndeleteAll {No esborrar totes les partides}
translate K DeleteTwins {Esborrar partides duplicades}
translate K MarkCurrent {Marcar partida actual}
translate K MarkFilter {Marcar partides filtrades}
translate K MarkAll {Marcar totes les partides}
translate K UnmarkCurrent {No marcar partida actual}
translate K UnmarkFilter {No marcar partides filtrades}
translate K UnmarkAll {No marcar totes les partides}
translate K Spellchecking {Revisi ortogrfica}
translate K Players {Jugadors}
translate K Events {Torneigs}
translate K Sites {Llocs}
translate K Rounds {Rondes}
translate K DatabaseOps {Operacions amb la base de dades}
translate K ReclassifyGames {Reclassificar partides per ECO...}
translate K CompactDatabase {Compactar base de dades}
translate K SortDatabase {Ordenar base de dades}
translate K AddEloRatings {Afegir classificaci Elo}
translate K AutoloadGame {Autocargar nmero de partida}
translate K StripTags {Treure etiquetes PGN}
translate K StripTag {Treure etiquetes}
translate K Cleaner {MultiEines}
translate K CleanerHelp {
L'Scid executar, a l'actual base de dades, totes les accions de manteniment
que seleccionis de la llista segent.

S'aplicar l'estat actual a la classificaci ECO i al dileg d'esborrat de
duplicades si selecciones aquestes funcions.
}
translate K CleanerConfirm {
Un cop la MultiEina de manteniment comena no pot ser aturada!

En una base de dades gran pot trigar molt de temps, depenent de les funcions que s'hagi seleccionat i el seu estat actual.

N'ests segur/a de voler comenar les funcions de manteniment que has escollit?
}
# Twinchecker
translate K TwinCheckUndelete {Prem "u" per no esborrar-ne cap (undelete)}
translate K TwinCheckprevPair {Parella previa}
translate K TwinChecknextPair {Prxima Parella}
translate K TwinChecker {Scid: Verificar partides duplicades}
translate K TwinCheckTournament {Partides d'un torneig:}
translate K TwinCheckNoTwin {No duplicada  }
translate K TwinCheckNoTwinfound {No s'han trovat duplicades per aquesta partida.\nper mostrar duplicades amb aquesta finestra fes servir la funci "Esborrar partides duplicades..." }
translate K TwinCheckTag {Compartir etiquetes...}
translate K TwinCheckFound1 {Scid ha trobat $result partides duplicades}
translate K TwinCheckFound2 {i les marca com esborrades}
translate K TwinCheckNoDelete {No hi ha partides en aquesta base per esborrar.}
translate K TwinCriteria1 {Els teus parmetres per cercar duplicades potencialment poden fer que partides diferents amb jugades similars siguin marcades com a duplicades.}
translate K TwinCriteria2 {Es recomenable que escolleixis "No" per "algunes jugades", hauries d'escollir "S"  pels parmetres colors, torneigs, lloc, ronda, any i mes.\nVols continuar, malgrat aix, i esborrar les partides duplicades?}
translate K TwinCriteria3 {Es recomenable que especifiquis "S" per al menys dos parmetres de "mateix lloc", "mateixa ronda" i "mateix any".\nVols continuar, malgrat aix, i esborrar duplicades?}
translate K TwinCriteriaConfirm {Scid: Confirmar parmetres per partides duplicades}
translate K TwinChangeTag "Canviar les sigents etiquetes de les:\n\n partides"
translate K AllocRatingDescription "Aquesta ordre far servir l'arxiu actual SpellCheck per afegir puntuacions ELO i partides a la base. On un jugador no tingui Elo per si el tingui al llistat d'Spellcheck, se li afegir l'Elo."
translate K RatingOverride "Sobre-escriure Elos existents no buits?"
translate K AddRatings "Afegir Elos a:"
translate K AddedRatings {Scid ha afegit $r ratings Elo a $g partides.}

#Bookmark editor
translate K NewSubmenu "Nou submen"

# Comment editor:
translate K AnnotationSymbols  {Smbols d'annotaci:}
translate K Comment {Comentari:}
translate K InsertMark {Insertar marca}
translate K InsertMarkHelp {
Insertar/treure marca: Selecciona color, tipus, cassella.
Insertar/treure fletxa: Bot dret sobre dos caselles.
}

# Nag buttons in comment editor:
translate K GoodMove {Bona jugada}
translate K PoorMove {Mala jugada}
translate K ExcellentMove {Jugada excelent}
translate K Blunder {Error}
translate K InterestingMove {Jugada interessant}
translate K DubiousMove {Jugada dubtosa}
translate K WhiteDecisiveAdvantage {Les blanque tenen avantatge decisiu}
translate K BlackDecisiveAdvantage {Les negres tenen avantatge decisiu}
translate K WhiteClearAdvantage {Les blanques tenen clar avantatge}
translate K BlackClearAdvantage {Les negres tenen clar avantatge}
translate K WhiteSlightAdvantage {Les blanques tenen lleuger avantatge}
translate K BlackSlightAdvantage {Les negres tenen lleuger avantatge}
translate K WhiteCrushing {Les blanques tenen un avantatge aclaparador}
translate K BlackCrushing {Les negres tenen un avantatge aclaparador}
translate K Equality {Igualtat}
translate K Unclear {Poc clar}
translate K Diagram {Diagrama}

# Board search:
translate K BoardSearch {Escaquer de recerca}
translate K FilterOperation {Operaci al filtre actual:}
translate K FilterAnd {Y (Restringir filtre)}
translate K FilterOr {O (Afegir al filtre)}
translate K FilterIgnore {IGNORAR (Posar a zero el filtre)}
translate K SearchType {Tipus de recerca:}
translate K SearchBoardExact {Posici exacta (totes les peces a les mateixes caselles)}
translate K SearchBoardPawns {Peons (igual material, tots els peons a les mateixes caselles)}
translate K SearchBoardFiles {Columnes (igual material, tots els peons a les mateixes columnes)}
translate K SearchBoardAny {Qualsevol (igual material, peons i peces a qualsevol lloc)}
translate K SearchInRefDatabase { Cerca a la base }
translate K LookInVars {Mirar a les variants}

# Material search:
translate K MaterialSearch {Cerca per Material}
translate K Material {Material}
translate K Patterns {Patrons}
translate K Zero {Zero}
translate K Any {Qualsevol}
translate K CurrentBoard {Escaquer Actual}
translate K CommonEndings {Finals comuns}
translate K CommonPatterns {Patrons comuns}
translate K MaterialDiff {Diferencia de material}
translate K squares {caselles}
translate K SameColor {Igual color}
translate K OppColor {Color contrari}
translate K Either {Qualsevol}
translate K MoveNumberRange {Rang de nombre de jugades}
translate K MatchForAtLeast {Coincideix quan menys}
translate K HalfMoves {mitges jugades}

# Common endings in material search:
translate K EndingPawns {Finals de peons}
translate K EndingRookVsPawns {Torre vs. pe(ns)}
translate K EndingRookPawnVsRook {Torre i 1 pe vs. torre}
translate K EndingRookPawnsVsRook {Torre i pe(ns) vs. torre}
translate K EndingRooks {Finals de torre vs. torre}
translate K EndingRooksPassedA {Finals de torre vs. torre amb pe passat}
translate K EndingRooksDouble {Finals de dues torres}
translate K EndingBishops {Finals d'alfil vs. alfil}
translate K EndingBishopVsKnight {Finals d'alfil vs. cavall}
translate K EndingKnights {Finals de cavall vs. cavall}
translate K EndingQueens {Finals de dama vs. dama}
translate K EndingQueenPawnVsQueen {Dama i 1 pe vs. dama}
translate K BishopPairVsKnightPair {Mig joc de dos alfils vs. dos cavalls}

# Common patterns in material search:
translate K PatternWhiteIQP {PDA blanc}
translate K PatternWhiteIQPBreakE6 {PDA blanc: d4-d5 ruptura vs. e6}
translate K PatternWhiteIQPBreakC6 {PDA blanc: d4-d5 ruptura vs. c6}
translate K PatternBlackIQP {PDA negre}
translate K PatternWhiteBlackIQP {PDA blanc vs. PDA negre}
translate K PatternCoupleC3D4 {Parella de peons allats blancs c3+d4}
translate K PatternHangingC5D5 {Peons penjants negres a c5 i d5}
translate K PatternMaroczy {Anell de Maroczy (amb peons a c4 i e4)}
translate K PatternRookSacC3 {Sacrifici de torre a c3}
translate K PatternKc1Kg8 {O-O-O vs. O-O (Rc1 vs. Rg8)}
translate K PatternKg1Kc8 {O-O vs. O-O-O (Rg1 vs. Rc8)}
translate K PatternLightFian {Fianchettos de caselles blanques (Alfil-g2 vs. Alfil-b7)}
translate K PatternDarkFian {Fianchettos de caselles negres (Alfil-b2 vs. Alfil-g7)}
translate K PatternFourFian {Quatre Fianchettos (Alfils a b2,g2,b7,g7)}

# Game saving:
translate K Today {Avui}
translate K ClassifyGame {Classificar partida}

# Setup position:
translate K EmptyBoard {Escaquer buit}
translate K InitialBoard {Escaquer inicial}
translate K SideToMove {Bndol que mou}
translate K MoveNumber {Jugada nmero}
translate K Castling {Enroc}
translate K EnPassantFile {Columna al pas}
translate K ClearFen {Treure FEN}
translate K PasteFen {Enganxar FEN}

translate K SaveAndContinue {Desar (enregistrar) i continuar}
translate K DiscardChangesAndContinue {Descartar \n canvis i continuar}
translate K GoBack {Tornar enrera}

# Replace move dialog:
translate K ReplaceMove {Substituir jugada}
translate K AddNewVar {Afegir nova variant}
translate K NewMainLine {Nova Lnia Principal}
translate K ReplaceMoveMessage {Ja existeix una jugada.

Pots substituir-la, descartant totes les jugades posteriors, o afegir-la com una nova variant.

(Pots evitar seguir veient aquest missatge en el futur desactivant l'opci "Preguntar abans de substituir moviments" al men Opcions: Jugades.)}

# Make database read-only dialog:
translate K ReadOnlyDialog {Si fas que aquesta base de dades sigui noms de lectura no es permetran fer canvis. No es podran desar o substituir partides, i no es podran alterar les senyals d'esborrat. Qualsevol ordenaci o classificaci per ECO ser temporal.

Pots recuperar fcilment el mode d'escriptura tancant-la i obrint-la de nou.

Realment vols fer que aquesta base de dades sigui noms de lectura?}

# Clear game dialog:
translate K ClearGameDialog {Aquesta partida ha estat modificada.

Realment vols continuar i eliminar els canvis fets?
}

# Exit dialog:
translate K ExitDialog {Vols sortir de l'Scid?}
translate K ExitUnsaved {La segent base de dades t canvis a partides no desades. Si surts ara es perdran aquests canvis.}

# Import window:
translate K PasteCurrentGame {Enganxar partida actual}
translate K ImportHelp1 \
  {Introduir o enganxar una partida en format PGN al marc superior.}
translate K ImportHelp2 \
  {Qualsevol error important la partida es mostrar aqu.}
translate K OverwriteExistingMoves {Sobreescriure jugades existents?}

# ECO Browser:
translate K ECOAllSections {totes les divisions ECO}
translate K ECOSection {divisi ECO}
translate K ECOSummary {Resum de}
translate K ECOFrequency {Freqencia dels subcodis per}

# Opening Report:
translate K OprepReportFor {Informe per}
translate K OprepTitle {Informe de l'obertura}
translate K OprepReport {Informe}
translate K OprepGenerated {Generat per}
translate K OprepStatsHist {Estadstiques e Historia}
translate K OprepStats {Estadstiques}
translate K OprepStatAll {Totes les partides referides}
translate K OprepStatBoth {Ambdues amb Elo}
translate K OprepStatSince {Des de}
translate K OprepOldest {Partides ms antigues}
translate K OprepNewest {Partides ms noves}
translate K OprepPopular {Popularitat actual}
translate K OprepFreqAll {Freqencia a tots els anys: }
translate K OprepFreq1   {Des de l'ltim any fins avui:     }
translate K OprepFreq5   {En els ltims 5 anys fins avui:   }
translate K OprepFreq10  {En els ltimos 10 anys fins avui:  }
translate K OprepEvery {un cop cada %u partides}
translate K OprepUp {puja un %u%s respecte al total d'anys}
translate K OprepDown {baixa un %u%s respecte al total d'anys}
translate K OprepSame {no hi han canvis respecte al total d'anys}
translate K OprepMostFrequent {Jugadors ms freqents}
translate K OprepMostFrequentOpponents {Rivals ms freqentes}
translate K OprepRatingsPerf {Elo i Rendiment}
translate K OprepAvgPerf {Promig Elo i rendiment}
translate K OprepWRating {Elo de les blanques}
translate K OprepBRating {Elo de les negres}
translate K OprepWPerf {Rendiment de les blanques}
translate K OprepBPerf {Rendiment de les negres}
translate K OprepHighRating {Partida amb el promig d'Elo ms gran}
translate K OprepTrends {Tendencies de Resultats}
translate K OprepResults {Resultat de duracions i freqencies}
translate K OprepLength {Duraci de la partida}
translate K OprepFrequency {Freqencia}
translate K OprepWWins {Blanques guanyen: }
translate K OprepBWins {Negres guanyen:  }
translate K OprepDraws {Taules:        }
translate K OprepWholeDB {al conjunt de la base de dades}
translate K OprepShortest {Victries ms curtes}
translate K OprepMovesThemes {Jugades i temes}
translate K OprepMoveOrders {Lnies de jugades que arriben a la posici de l'informe}
translate K OprepMoveOrdersOne \
  {Noms hi ha una lnia de jugades que arriba fins aquesta posici:}
translate K OprepMoveOrdersAll \
  {Hi han %u lnies que arriben a aquesta posici:}
translate K OprepMoveOrdersMany \
  {Hi han %u lnies que arriben a aquesta posici. Les %u ms comuns son:}
translate K OprepMovesFrom {Jugades des de la posici de l'informe}
translate K OprepMostFrequentEcoCodes {Obertures ms freqents}
translate K OprepThemes {Temes Posicionals}
translate K OprepThemeDescription {Freqencia dels temes a les primeres %u jugades de cada partida}
translate K OprepThemeSameCastling {Enroc al mateix flanc}
translate K OprepThemeOppCastling {Enrocs a flancs diferents}
translate K OprepThemeNoCastling {El dos Reis sense enrocar}
translate K OprepThemeKPawnStorm {Avalantxa dels peons del Rei}
translate K OprepThemeQueenswap {Canvi de Dames}
translate K OprepThemeWIQP {Pe de dama allat de les blanques}
translate K OprepThemeBIQP {Pen de dama allat de les negres}
translate K OprepThemeWP567 {Peons blancs a 5/6/7 fila}
translate K OprepThemeBP234 {Peons negres a 2/3/4 fila}
translate K OprepThemeOpenCDE {Columnes c/d/e obertes}
translate K OprepTheme1BishopPair {Un bndol te parella d'alfils}
translate K OprepEndgames {Finals}
translate K OprepReportGames {Informe de partides}
translate K OprepAllGames {Totes les partides}
translate K OprepEndClass {Tipus de finales d'acord a l'ltima posici de les partides}
translate K OprepTheoryTable {Taula de Teoria}
translate K OprepTableComment {Generada a partir de les %u partides amb millor Elo.}
translate K OprepExtraMoves {Annotaci extra de moviments a la taula de teoria}
translate K OprepMaxGames {Mxim de partides a la taula de teoria}
translate K OprepMergeMoves {Lmit de moviment per a jocs combinats}
translate K OprepMergeUnique {Combina noms jocs nics}
translate K OprepViewHTML {Veure HTML}

# Player Report:
translate K PReportTitle {Informe del jugador}
translate K PReportColorWhite {amb les peces blanques}
translate K PReportColorBlack {amb les peces negres}
translate K PReportMoves {%s desprs}
translate K PReportOpenings {Obertures}
translate K PReportClipbase {Buidar el portapapers i copiar les partides}

# Piece Tracker window:
translate K TrackerSelectSingle {El bot esquerra selecciona la pea.}
translate K TrackerSelectPair {El bot esquerra selecciona la pea; el botn dret tamb selecciona la germana.}
translate K TrackerSelectPawn {El bot esquerra selecciona el pe; el bot dret selecciona els 8 peons.}
translate K TrackerStat {Estadstica}
translate K TrackerGames {% de partides amb jugada a aquesta cassella}
translate K TrackerTime {% de temps cap aquesta cassella}
translate K TrackerMoves {Jugades}
translate K TrackerMovesStart {Escriu el nmero de la jugada des d'on comenar la recerca.}
translate K TrackerMovesStop {Escriu el nmero de la jugada on s'ha d'aturar la recerca.}

# Game selection dialogs:
translate K SelectAllGames {Totes les partides de la base de dades}
translate K SelectFilterGames {Noms les partides filtrades}
translate K SelectTournamentGames {Noms les partides de l'actual torneig}
translate K SelectOlderGames {Noms partides antigues}

# Delete Twins window:
translate K TwinsNote {Per a ser duplicades, dos partides han de tenir quan menys els mateixos dos jugadors i els criteris que fixis a sota. Quan es troba un parell de duplicades, es borra la partida ms curta. Suggeriment: es millor fer la correcci ortogrfica de la base de dades abans d'iniciar l'esborrat de duplicades, per que millora la seva detecci.}
translate K TwinsCriteria {Criteris: Les partides duplicades han de tenir...}
translate K TwinsWhich {Partides a examinar}
translate K TwinsColors {Jugadors amb igual color?}
translate K TwinsEvent {Mateix torneig?}
translate K TwinsSite {Mateix lloc?}
translate K TwinsRound {Mateixa ronda?}
translate K TwinsYear {Mateix any?}
translate K TwinsMonth {Mateix mes?}
translate K TwinsDay {Mateix da?}
translate K TwinsResult {Mateix resultat?}
translate K TwinsECO {Mateix codi ECO?}
translate K TwinsMoves {Mateixes jugades?}
translate K TwinsPlayers {Comparant noms de jugadors:}
translate K TwinsPlayersExact {Trobo exactes}
translate K TwinsPlayersPrefix {Noms les primeres 4 lletres}
translate K TwinsWhen {Quan es borren partides duplicades}
translate K TwinsSkipShort {Ignorar totes les partides amb menys de 5 jugades?}
translate K TwinsUndelete {Treure en primer lloc marques d'esborrat?}
translate K TwinsSetFilter {Posar al filtre totes les partides esborrades?}
translate K TwinsComments {Saltar sempre partides amb comentaris?}
translate K TwinsVars {Saltar sempre partides amb variants?}
translate K TwinsDeleteWhich {Quina partida esborrar:}
translate K TwinsDeleteShorter {Partida ms curta}
translate K TwinsDeleteOlder {Nmero de partida ms petit}
translate K TwinsDeleteNewer {Nmero de partida ms gran}
translate K TwinsDelete {Esborrar partides}

# Name editor window:
translate K NameEditType {Tipus de dada a editar}
translate K NameEditSelect {Partides a editar}
translate K NameEditReplace {Reemplaar}
translate K NameEditWith {amb}
translate K NameEditMatches {Ja hi son: Presionar Ctrl+1 a Ctrl+9 per seleccionar-ne}

# Check games window:
translate K CheckGames {Veure partides}
translate K CheckGamesWhich {Veure partides}
translate K CheckAll {Totes les partides}
translate K CheckSelectFilterGames {Noms partides al filtre}

# Classify window:
translate K Classify {Classificar}
translate K ClassifyWhich {Classificar per codi ECO}
translate K ClassifyAll {Totes les partides (sobreescriure codi ECO)}
translate K ClassifyYear {Totes les partides jugades a l'ltim any}
translate K ClassifyMonth {Totes les partides jugades a l'ltim mes}
translate K ClassifyNew {Noms les partides sense codi ECO}
translate K ClassifyCodes {Codi ECO a utilitzar}
translate K ClassifyBasic {Noms codi bsic ("B12", ...)}
translate K ClassifyExtended {Extensions Scid ("B12j", ...)}
translate K ClassifyResult {Classificaci ECO completa: joc(s) de $resultat actualitzat.}

# Compaction:
translate K NameFile {Arxiu de noms}
translate K GameFile {Arxiu de partides}
translate K Names {Noms}
translate K Unused {No utilitzat}
translate K SizeKb {Tamany (kb)}
translate K CurrentState {Estat actual}
translate K AfterCompaction {Desprs de la compactaci}
translate K CompactNames {Compactar arxiu de noms}
translate K CompactGames {Compactar arxiu de partides}
translate K NoUnusedNames "No hi han noms sense utilitzar, per tant l'arxiu de noms ja est compactat."
translate K NoUnusedGames "L'arxiu ja est totalment compactat."
translate K GameFileCompacted {L'arxiu de partides de la base de dades ha estat compactada.}

# Sorting:
translate K SortCriteria {Criteri}
translate K AddCriteria {Afegir criteri}
translate K CommonSorts {Ordenacions habituals}
translate K Sort {Ordenar}

# Exporting:
translate K AddToExistingFile {Afegir partides a un arxiu existent?}
translate K ExportComments {Exportar comentaris?}
translate K ExportVariations {Exportar variants?}
translate K IndentComments {Sangrar comentaris?}
translate K IndentVariations {Sangrar variants?}
translate K ExportColumnStyle {Estil de columna (una jugada per lnia)?}
translate K ExportSymbolStyle {Estil d'anotaci simblica:}
translate K ExportStripMarks {Treure marca de codis de cassella/fletxa dels comentaris?}

# Goto game/move dialogs:
translate K LoadGameNumber {Entra el nmero de la partida a carregar:}
translate K GotoMoveNumber {Anar a la jugada nmero:}

# Copy games dialog:
translate K CopyAllGames {Copia totes les jugades a}
translate K CopyGames {Copiar partides}
translate K CopyConfirm {
 Realment vols copiar les [::utils::thousands $nGamesToCopy] partides fitrades
 de la base de dades "$fromName"
 a la base de dades "$targetName"?
}
translate K CopyErr {No es poden copiar les partides}
translate K CopyErrSource {la base de dades font}
translate K CopyErrTarget {la base de dades de desti}
translate K CopyErrNoGames {no te partides al filtre}
translate K CopyErrReadOnly {es de noms lectura}
translate K CopyErrNotOpen {no est oberta}

# Colors:
translate K LightSquares {Caselles blanques}
translate K DarkSquares {Caselles negres}
translate K SelectedSquares {Caselles seleccionades}
translate K SuggestedSquares {Caselles de jugada suggerida}
translate K WhitePieces {Peces blanques}
translate K BlackPieces {Peces negres}
translate K WhiteBorder {Vora blanques}
translate K BlackBorder {Vora negres}

# Novelty window:
translate K FindNovelty {Trobar Novetat}
translate K Novelty {Novetat}
translate K NoveltyInterrupt {Recerca de novetat interrompuda}
translate K NoveltyNone {Cap novetat trobada en aquesta partida}
translate K NoveltyHelp {
L'Scid trobar la primera jugada de l'actual partida que representi una posici no existent a la base de dades seleccionada o al llibre d'obertures ECO.
}

# Sounds configuration:
translate K SoundsFolder {Directori d'arxius de so}
translate K SoundsFolderHelp {El directori ha de tenir els arxius King.wav, a.wav, 1.wav, etc}
translate K SoundsAnnounceOptions {Opcions d'anunci de jugades}
translate K SoundsAnnounceNew {Anunciar noves jugades quan estiguin fetes}
translate K SoundsMoveSoundOnly {Mou noms el so (desactiva els anuncis)}
translate K SoundsAnnounceForward {Anunciar jugades quan avancem una jugada}
translate K SoundsAnnounceBack {Anunciar jugada quan rectifiquem o retrocedim una jugada}
translate K SoundsSoundDisabled {L'Scid no ha pogut trobar el paquet d'udio Snack al inicialitzar;\nEl so est desactivat.}

# Upgrading databases:
translate K Upgrading {Actualitzaci}
translate K ConfirmOpenNew {
Aquest es un format de base de dades antico (Scid 3) que no es pot obrir amb Scid 4, pero ja s'ha creat una versin en el format nou (Scid 4).

Vols abrir la versi de format nou de la base de dades?
}
translate K ConfirmUpgrade {
Aquesta es una base de dades en un format antic (Scid 3). S'ha de crear una versi amb el nou format abans de poder utilitzar-la a Scid 4.

L'actualitzaci crear una nova versi de la base de dades.

Pot trigar temps, pero noms cal fer-ho un cop. Pots cancelar si triga massa temps.

Vols actualitzar aquesta base de dades ara?
}

# Recent files options:
translate K RecentFilesMenu {Nombre d'arxius recents al men Arxiu}
translate K RecentFilesExtra {Nombre d'arxius recents al submen extra}

# My Player Names options:
translate K MyPlayerNamesDescription {
Escriu una llista de noms alternatius per jugador, un nom per cada lnia. Es permeten comodins (per exemple "?" per un caracter, "*" per varis caracters).

Cada cop que es carregui una partida amb un jugador de la llista es girar l'escaquer, si fos necessari, per veure la partida des de la perspectiva del jugador.
}

#Coach
translate K showblunderexists {Mostrar ficada de pota}
translate K showblundervalue {Mostrar valor de la ficada de pota}
translate K showscore {Mostrar marcador}
translate K coachgame {Entrenador}
translate K configurecoachgame {Configurar entrenador}
translate K configuregame {Configuraci de partida}
translate K Phalanxengine {Motor Phalanx}
translate K Coachengine {Motor entrenador}
translate K difficulty {Dificultat}
translate K hard {Dur}
translate K easy {Fcil}
translate K Playwith {Juga amb}
translate K white {blanques}
translate K black {negres}
translate K both {ambdos}
translate K Play {Jugar}
translate K Noblunder {Sense errors}
translate K blunder {Ficades de pota}
translate K Noinfo {-- Sense informaci --}
translate K PhalanxOrTogaMissing {No es troben ni Phalanx ni Toga}
translate K moveblunderthreshold {La jugada es un error si la prdua de puntuaci es ms gran que }
translate K limitanalysis {Temps lmit per l'anlisi del motor}
translate K seconds {segons}
translate K Abort {Abortar}
translate K Resume {Reanudar}
translate K OutOfOpening {Fora de l'obertura}
translate K NotFollowedLine {No segueixes la lnia}
translate K DoYouWantContinue {Vols continuar?}
translate K CoachIsWatching {Entrenador}
translate K Ponder {Pensar sempre (motor)}
translate K LimitELO {Limitar fora ELO}
translate K DubiousMovePlayedTakeBack {Jugada dubtosa, vols rectificar?}
translate K WeakMovePlayedTakeBack {Jugada fluixa, vols rectificar?}
translate K BadMovePlayedTakeBack {Jugada dolenta, vols rectificar?}
translate K Iresign {Abandono}
translate K yourmoveisnotgood {la teva jugada es dolenta}
translate K EndOfVar {Fi de la variant}
translate K Openingtrainer {Entrenador d'obertures}
translate K DisplayCM {Mostra jugades possibles}
translate K DisplayCMValue {Mostra valor de les jugades possibles}
translate K DisplayOpeningStats {Mostra estadstiques}
translate K ShowReport {Mostra informe}
translate K NumberOfGoodMovesPlayed {jugades bones fetes}
translate K NumberOfDubiousMovesPlayed {jugades dubtoses fetes}
translate K NumberOfMovesPlayedNotInRepertoire {jugades fetes fora del repertori}
translate K NumberOfTimesPositionEncountered {vegades trobada la posici}
translate K PlayerBestMove  {Permet nicament les millors jugades}
translate K OpponentBestMove {El contrari juga les millors jugades}
translate K OnlyFlaggedLines {Noms lnies marcades}
translate K resetStats {Reinicia estadstiques}
translate K Repertoiretrainingconfiguration {Configuraci del repertori d'entrenament}
translate K Loadingrepertoire {Carregant repertori}
translate K Movesloaded {Jugades carregades}
translate K Repertoirenotfound {Repertori no trobat}
translate K Openfirstrepertoirewithtype {Obrir primer una base amb una icona/tipus de repertori al costat dret}
translate K Movenotinrepertoire {La jugada no est al repertori}
translate K PositionsInRepertoire {Posicions al repertori}
translate K PositionsNotPlayed {Posicions no jugades}
translate K PositionsPlayed {Posicions jugades}
translate K Success {Exits}
translate K DubiousMoves {Jugades dubtoses}
translate K OutOfRepertoire {Fora de repertori}
translate K ConfigureTactics {Configurar tctica}
translate K ResetScores {Reiniciar marcadors (puntuacions)}
translate K LoadingBase {Cargant base}
translate K Tactics {Tctica}
translate K ShowSolution {Mostrar resposta}
translate K NextExercise {Proper exercici}
translate K PrevExercise {Exercici anterior}
translate K StopTraining {Atura l'entrenament}
translate K Next {Segent}
translate K ResettingScore {Reiniciant marcador}
translate K LoadingGame {Cargant partida}
translate K MateFound {Trobat mat}
translate K BestSolutionNotFound { NO s'ha trobat la millor resposta!}
translate K MateNotFound {Mat no trobat}
translate K ShorterMateExists {Existeix un mat ms curt}
translate K ScorePlayed {Marcador jugat}
translate K Expected {Esperat}
translate K ChooseTrainingBase {Escollir base d'entrenament}
translate K Thinking {Pensant}
translate K AnalyzeDone {Anlisi fet}
translate K WinWonGame {Guanya la partida guanyada}
translate K Lines {Lnies}
translate K ConfigureUCIengine {Configurar motor UCI}
translate K SpecificOpening {Obertura especfica}
translate K StartNewGame {Iniciar nova partida}
translate K FixedLevel {Nivell fix}
translate K Opening {Obrint}
translate K RandomLevel {Nivell aleatori}
translate K StartFromCurrentPosition {Iniciar des de la posici actual}
translate K FixedDepth {Profunditat fixe}
translate K Nodes {Nodes} 
translate K Depth {Profunditat}
translate K Time {Temps} 
translate K SecondsPerMove {Segons per jugada}
translate K Engine {Motor}
translate K TimeMode {Mode de temps}
translate K TimeBonus {Temps + bonus}
translate K TimeMin {min}
translate K TimeSec {seg}
translate K AllExercisesDone {Tots els exercicis fets}
translate K MoveOutOfBook {Jugada fora del llibre}
translate K LastBookMove {ltima jugada del llibre}
translate K AnnotateSeveralGames {Anotar les partides\ndes de l'actual fins la partida: }
translate K FindOpeningErrors {Trobar errors als primers }
translate K MarkTacticalExercises {Marca exercicis tctics}
translate K UseBook {Utilitzar llibre d'obertures}
translate K MultiPV {Mltiples Variants}
translate K Hash {Memria Hash}
translate K OwnBook {Utilitzar el llibre del motor}
translate K BookFile {Llibre d'obertures}
translate K AnnotateVariations {Anotar variants}
translate K ShortAnnotations {Anotacions curtes}
translate K addAnnotatorTag {Afegir etiqueta d'anotador}
translate K AddScoreToShortAnnotations {Afegir puntuaci per anotaciones curtes}
translate K Export {Exportar}
translate K BookPartiallyLoaded {Llibre carregat parcialment}
translate K Calvar {Clcul de variants}
translate K ConfigureCalvar {Configuraci}
# Opening names used in tacgame.tcl
translate K Reti {Obertura Reti}
translate K English {Obertura Anglesa}
translate K d4Nf6Miscellaneous {1.d4 Cf6 altres}
translate K Trompowsky {Obertura Trompowsky}
translate K Budapest {Gambit Budapest}
translate K OldIndian {Defensa India Antiga}
translate K BenkoGambit {Gambit Benko}
translate K ModernBenoni {Defensa Benoni Moderna}
translate K DutchDefence {Defensa Holandesa}
translate K Scandinavian {Defensa Escandinava}
translate K AlekhineDefence {Defensa Alekhine}
translate K Pirc {Defensa Pirc}
translate K CaroKann {Defensa Caro-Kann}
translate K CaroKannAdvance {Defensa Caro-Kann, Variant de l'avanament}
translate K Sicilian {Defensa Siciliana}
translate K SicilianAlapin {Defensa Siciliana, Variant Alapin}
translate K SicilianClosed {Defensa Siciliana, Variant Tancada}
translate K SicilianRauzer {Defensa Siciliana, Variant Rauzer}
translate K SicilianDragon {Defensa Siciliana, Variant del Drac}
translate K SicilianScheveningen {Defensa Siciliana, Variant Scheveningen}
translate K SicilianNajdorf {Defensa Siciliana, Variant Najdorf}
translate K OpenGame {Obertura Oberta}
translate K Vienna {Obertura Vienesa}
translate K KingsGambit {Gambit de Rei}
translate K RussianGame {Partida Rusa}
translate K ItalianTwoKnights {Obertura Italiana, Variant dels Dos Cavalls}
translate K Spanish {Obertura Espanyola}
translate K SpanishExchange {Obertura Espanyola, Variant del Canvi}
translate K SpanishOpen {Obertura Espanyola}
translate K SpanishClosed {Obertura Espanyola, Variant Tancada}
translate K FrenchDefence {Defensa Francesa}
translate K FrenchAdvance {Defensa Francesa, Variant de l'Avanament}
translate K FrenchTarrasch {Defensa Francesa, Variant Tarrasch}
translate K FrenchWinawer {Defensa Francesa, Variant Winawer}
translate K FrenchExchange {Defensa Francesa, Variant del canvi}
translate K QueensPawn {Obertura de Pe de Dama}
translate K Slav {Defensa Eslava}
translate K QGA {Gambit de Dama Acceptat}
translate K QGD {Gambit de Dama Declinat}
translate K QGDExchange {Gambit de Dama Declinat, Variant del Canvi}
translate K SemiSlav {Defensa Semi-Eslava del Gambit de Dama Declinat}
translate K QGDwithBg5 {Gambit de Dama Declinat amb Ag5}
translate K QGDOrthodox {Gambit de Dama Declinat,  Defensa Ortodoxa}
translate K Grunfeld {Defensa Grnfeld}
translate K GrunfeldExchange {Defensa Grnfeld, Variant del canvi}
translate K GrunfeldRussian {Defensa Grnfeld, Variant Russa}
translate K Catalan {Catalana}
translate K CatalanOpen {Obertura Catalana}
translate K CatalanClosed {Obertura Catalana, Variant Tancada}
translate K QueensIndian {Defensa India de Dama}
translate K NimzoIndian {Obertura Nimzo-India}
translate K NimzoIndianClassical {Obertura Nimzo-India Clssica}
translate K NimzoIndianRubinstein {Defensa Nimzo-India, Variant Rubinstein}
translate K KingsIndian {India de Rei}
translate K KingsIndianSamisch {Defensa India de Rei, Variant Smisch}
translate K KingsIndianMainLine {India de Rei, Linia Principal}

# FICS
translate K ConfigureFics {Configurar FICS}
translate K FICSGuest {Autentificaci com convidat}
translate K FICSServerPort {Port del servidor}
translate K FICSServerAddress {Adrea IP}
translate K FICSRefresh {Refresca}
translate K FICSTimesealPort {Port Timeseal}
translate K FICSSilence {Silenci}
translate K FICSOffers {Ofertes}
translate K FICSConsole {Consola}
translate K FICSGames {Partides}
translate K FICSUnobserve {Atura l'observaci d'una partida}
translate K FICSProfile {Mostra la teva histria i perfil}
translate K FICSRelayedGames {Partides ajornades}
translate K FICSFindOpponent {Cercar contrari}
translate K FICSTakeback {Retrocedeix}
translate K FICSTakeback2 {Retrocedeix 2}
translate K FICSInitTime {Temps inicial (min)}
translate K FICSIncrement {Increment (seg)}
translate K FICSRatedGame {Partida amb rating}
translate K FICSAutoColour {automtic}
translate K FICSManualConfirm {confirma manualment}
translate K FICSFilterFormula {Filtrar amb frmula}
translate K FICSIssueSeek {Panell de desafiaments}
translate K FICSChallenge {Desafiar}
translate K FICSAccept {acceptar}
translate K FICSDecline {refusar}
translate K FICSColour {Color}
translate K FICSSend {enviar}
translate K FICSConnect {Connectar}
translate K FICSdefaultuservars {Utilitza valors per defecte}
translate K FICSObserveconfirm {Vols observar la partida}
translate K FICSpremove {Activa pre-moviment}
translate K FICSObserve {Observa}
translate K FICSRatedGames {Partides avaluades}
translate K FICSUnratedGames {Partides no avaluades}
translate K FICSRated {Avaluada}
translate K FICSUnrated {No Avaluada}
translate K FICSRegisteredPlayer {Noms perfils registrats}
translate K FICSFreePlayer {Noms perfils gratuts}
translate K FICSNetError {Error de xarxa\nNo es pot connectar amb }

# Game review
translate K GameReview {Revisi de la partida}
translate K GameReviewTimeExtended {Temps incrementat}
translate K GameReviewMargin {Marge d'error}
translate K GameReviewAutoContinue {Continua automticament quan la jugada sigui correcta}
translate K GameReviewReCalculate {Fes servir temps addicional}
translate K GameReviewAnalyzingMovePlayedDuringTheGame {Analitzant jugada feta a la partida}
translate K GameReviewAnalyzingThePosition {Analitzant la posici}
translate K GameReviewEnterYourMove {Introdueix la teva jugada}
translate K GameReviewCheckingYourMove {Analitzant la teva jugada}
translate K GameReviewYourMoveWasAnalyzed {La teva jugada ha estat analitzada}
translate K GameReviewYouPlayedSameMove {Has jugat la mateixa jugada que la partida}
translate K GameReviewScoreOfYourMove {Valoraci de la teva jugada}
translate K GameReviewGameMoveScore {Valoraci de la jugada de la partida}
translate K GameReviewEngineScore {Valoraci del motor}
translate K GameReviewYouPlayedLikeTheEngine {Has jugat com el motor}
translate K GameReviewNotEngineMoveButGoodMove {No s la jugada del motor, per tamb s bona}
translate K GameReviewMoveNotGood {Aquesta jugada no s bona, per la valoraci si}
translate K GameReviewMovesPlayedLike {Jugades com}
translate K GameReviewMovesPlayedEngine {Jugades del motor}

# Correspondence Chess Dialogs:
translate K CCDlgCGeneraloptions {Opcions Generals}
translate K CCDlgLoginName  {Nom del perfil:}
translate K CCDlgPassword   {Contrasenya:}
translate K CCDlgShowPassword {Mostra contrasenya}

# Connect Hardware dialogs
translate K ExtHWConfigConnection {Configurar maquinari extern}
translate K ExtHWPort {Port}
translate K ExtHWEngineCmd {Lnia d'ordres del motor}
translate K ExtHWEngineParam {Parmetre del motor}
translate K ExtHWShowButton {Mostrar bot}
translate K ExtHWHardware {Maquinari}
translate K ExtHWNovag {Novag Citrine}
translate K ExtHWInputEngine {Motor d'entrada}
translate K ExtHWNoBoard {Sense escaquer}
translate K NovagReferee {rbitre}

# Input Engine dialogs
translate K IEConsole {Consola d'entrada del motor}
translate K IESending {Jugades enviades per}
translate K IESynchronise {Sincronitzar}
translate K IERotate  {Rotar}
translate K IEUnableToStart {Impossible comenar amb el motor d'entrada:}

# Calculation of Variations
translate K DoneWithPosition {Fet amb la posici}

translate K Board {Escaquer}
translate K showGameInfo {Mostrar informaci de la partida}
translate K autoResizeBoard {Tamany automtic de l'escaquer}
translate K DockTop {Moure amunt}
translate K DockBottom {Moure abaix}
translate K DockLeft {Moure a l'esquerra}
translate K DockRight {Moure a la dreta}
translate K Undock {Finestra flotant}

# Switcher window
translate K AboutDatabase {Sobre aquesta base de dades}
translate K ChangeIcon {Canvia d'icona...}
translate K NewGameListWindow {Finestra de llista de noves partides}
translate K LoadatStartup {Carrega al engegar}

# Gamelist window
translate K ShowHideDB {Mostra/amaga bases de dades}
translate K ChangeFilter {Canvia filtre}
translate K ChangeLayout {Carrega/Desa/canvia criteris d'ordenaci i disposici de columnes}
translate K ShowHideStatistic {Mostra/amaga estadstiques}
translate K BoardFilter {Mostra noms partides que continguin aquesta mateixa posici}
translate K CopyGameTo {Copia partida a...}
translate K FindBar {Barra de cerca}
translate K FindCurrentGame {Troba partida actual}
translate K DeleteGame {Esborra partida}
translate K UndeleteGame {Desfs esborrar partida}
translate K ResetSort {Neteja criteri d'ordre}

translate K ConvertNullMove {Converteix jugades nulles en comentaris}
translate K SetupBoard {Configura posici}
translate K Rotate {Gira}
translate K SwitchColors {Canvia colors}
translate K FlipBoard {Gira tauler}
translate K ImportPGN {Importa partida en PGN}
translate K ImportingFiles {Important fitxers PGN a}
translate K ImportingFrom {Important des de}
translate K ImportingIn {Importa partides a}
translate K UseLastTag {Fes servir etiquetes\nde la partida anterior}
translate K Random {Aleatori}
translate K BackToMainline {Ves a la lnia principal}
translate K LeaveVariant {Surt de la variant}
translate K Autoplay {Juga automticament}
translate K ShowHideCoords {Mostra/amaga coordenades}
translate K ShowHideEvalBar {Mostra/amaga la barra d'avaluaci}
translate K ShowHideMaterial {Mostra/amaga material}
translate K SelectMarker {Seleccioneu Marcador}
translate K FullScreen {Pantalla completa}
translate K FilterStatistic {Filtra estadstiques}
translate K MakeCorrections {Fes correccions}
translate K Surnames {Cognoms}
translate K Ambiguous {Ambigu}

#Preferences Dialog
translate K OptionsToolbar "Barra d'eines de la finestra principal"
translate K OptionsBoard "Escaquer"
translate K OptionsBoardSize "Tamany de l'escaquer"
translate K OptionsBoardPieces "Estil de peces"
translate K OptionsInternationalization "Localitzaci"
translate K OptionsTablebaseDir "Selecciona fins a 4 fitxers de base de taules:"

# Evaluation bar
translate K BestMoveArrow "Fletxa de la millor jugada"
translate K NewLocalEngine "+ Nou Motor ..."

# Batch Annotate
translate K BatchAnnotate {Anotació per lots}
translate K BatchEngineSelection {Selecció del motor}
translate K BatchChessEngine {Motor d'escacs:}
translate K BatchNumberOfInstances {Nombre d'instàncies:}
translate K BatchGameReview {Revisió del joc}
translate K BatchTimePerMove {Temps per moviment (s):}
translate K BatchAnnotateBlunders {Anoteu només errors}
translate K BatchBlunderThreshold {Llindar d'error:}
translate K BatchVariationLength {Durada de la variació (moviments):}
translate K BatchOpeningBook {Llibre d'obertura}
translate K BatchUseBook {Utilitza el llibre}
translate K BatchAnnotateVariations {Anotar variacions}
translate K BatchShortAnnotations {Anotacions breus}
translate K BatchAddScoreToShort {Afegiu puntuació a anotacions curtes}
translate K BatchClearOld {Esborra els comentaris i les variacions antigues}
translate K BatchInitializingEngines {Inicialitzant motors...}
translate K BatchAnalyzingGames {S'estan analitzant els jocs...}
translate K BatchProgress {Progrés de l'anotació per lots}
translate K BatchComplete {Anotació per lots completada!}
translate K BatchCancelled {S'ha cancel·lat l'anotació del lot}
}
# end of english.tcl
