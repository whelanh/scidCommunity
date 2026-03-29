# spanish.tcl:
# Spanish translations for Scid.
# Contributed by Jordi GonzÃ¡lez Boada.
# Updated by Enrique Lopez.
# Updated by Benigno HernÃ¡ndez Bacallado.
# Updated by Pedro Reina.
# Untranslated messages are marked with a "***" comment.

proc setLanguage_S {} {

# File menu:
menuText S File "Archivo" 0
menuText S FileNew "Nuevo..." 0 {Crea una nueva base de datos Scid vacÃ­a}
menuText S FileOpen "Abrir..." 1 {Abre una base de datos Scid ya existente}
menuText S FileClose "Cerrar" 0 {Cierra la base de datos Scid activa}
menuText S FileFinder "Visor..." 0 {Abre la ventana del visor de archivos}
menuText S FileBookmarks "Partidas favoritas" 0 {Seleccionar partidas favoritas (Ctrl+B)}
menuText S FileBookmarksAdd "AÃ±adir" 0 \
  {SeÃ±ala la partida y posiciÃ³n actual de la base de datos}
menuText S FileBookmarksFile "Archivar" 8 \
  {Archiva un marcador para la partida y posiciÃ³n actual}
menuText S FileBookmarksEdit "Editar partidas favoritas..." 0 \
  {Edita los menÃºs de las partidas favoritas}
menuText S FileBookmarksList "Mostrar partidas favoritas" 0 \
  {Muestra las carpetas de favoritas en una sola lista, sin submenÃºs}
menuText S FileBookmarksSub "Mostrar partidas marcadas con submenÃºs" 0 \
  {Muestra las carpetas de favoritas como submenÃºs, no una sola lista}
menuText S FileMaint "Mantenimiento" 0 \
  {Herramientas de mantenimiento de la base de datos Scid}
menuText S FileMaintWin "Ventana de mantenimiento" 0 \
  {Abre/cierra la ventana de mantenimiento de la base de datos Scid}
menuText S FileMaintCompact "Compactar base de datos..." 0 \
  {Compacta los archivos de la base de datos, quitando partidas borradas y nombres no usados}
menuText S FileMaintClass "Clasificar partidas por ECO..." 24 \
  {Recalcula el cÃ³digo ECO de todas las partidas}
menuText S FileMaintSort "Ordenar base de datos..." 0 \
  {Ordena todas las partidas de la base de datos}
menuText S FileMaintDelete "Borrar partidas dobles..." 0 \
  {Encuentra partidas dobles y las coloca para ser borradas}
menuText S FileMaintTwin "Ventana de inspecciÃ³n de dobles" 11 \
  {Abre/actualiza la ventana de inspecciÃ³n de dobles}
menuText S FileMaintName "OrtografÃ­a de nombres" 0 {Herramientas de ortografÃ­a y ediciÃ³n de nombres}
menuText S FileMaintNameEditor "Ventana de ediciÃ³n de nombres" 22 \
  {Abre/cierra la ventana de ediciÃ³n de nombres}
menuText S FileMaintNamePlayer "ComprobaciÃ³n ortogrÃ¡fica de nombres de jugadores..." 39 \
  {ComprobaciÃ³n ortogrÃ¡fica de jugadores usando archivo de comprobaciÃ³n ortogrÃ¡fica}
menuText S FileMaintNameEvent "ComprobaciÃ³n ortogrÃ¡fica de nombres de eventos..." 39 \
  {ComprobaciÃ³n ortogrÃ¡fica de eventos usando el archivo de comprobaciÃ³n ortogrÃ¡fica}
menuText S FileMaintNameSite "ComprobaciÃ³n ortogrÃ¡fica de nombres de lugares..." 39 \
  {ComprobaciÃ³n ortogrÃ¡fica de lugares usando el archivo de comprobaciÃ³n ortogrÃ¡fica}
menuText S FileMaintNameRound "ComprobaciÃ³n ortogrÃ¡fica de rondas..." 28 \
  {ComprobaciÃ³n ortogrÃ¡fica de rondas usando el archivo de comprobaciÃ³n ortogrÃ¡fica}
menuText S FileReadOnly "SÃ³lo lectura..." 5 \
  {Trata la actual base de datos como de sÃ³lo lectura, previniendo cambios}
menuText S FileSwitch "Cambiar de base de datos" 0 \
  {Cambia a una base de datos abierta diferente}
menuText S FileOpenLichessTournament "Abrir Torneo de Lichess" 0 {Descargar y abrir partidas de transmisiÃ³n de torneos en vivo de Lichess}
menuText S FileImportLichess "Importar mis partidas de Lichess" 0 {Importar partidas de tu cuenta de Lichess}
menuText S FileImportChessCom "Importar mis partidas de Chess.com" 0 {Importar partidas de tu cuenta de Chess.com}
menuText S FileExit "Salir" 0 {Salir de Scid}
menuText S FileMaintFixBase "Arreglar base corrupta" 0 {Intenta arreglar una base corrupta}

# Edit menu:
menuText S Edit "Editar" 0
menuText S EditAdd "AÃ±adir variaciÃ³n" 0 \
  {AÃ±ade una variaciÃ³n a este movimiento en la partida}
menuText S EditDelete "Borrar variaciÃ³n" 0 {Borra variaciÃ³n para este movimiento}
menuText S EditFirst "Convertir en primera variaciÃ³n" 0 \
  {Hace que una variaciÃ³n sea la primera en la lista}
menuText S EditMain "VariaciÃ³n a lÃ­nea principal" 0 \
   {Promover una variaciÃ³n para que sea la lÃ­nea principal}
menuText S EditTrial "Probar variaciÃ³n" 1 \
  {Inicia/para el modo de prueba, para ensayar una idea en el tablero}
menuText S EditStrip "Eliminar" 2 \
  {Elimina comentarios o variaciones de esta partida}
menuText S EditUndo "Deshacer" 0 {Deshace el Ãºltimo cambio en la partida}
menuText S EditRedo "Rehacer" 0 {Rehacer el Ãºltimo cambio de juego}
menuText S EditStripComments "Comentarios" 0 \
  {Quita todos los comentarios y variaciones de esta partida}
menuText S EditStripVars "Variaciones" 0 {Quita todas las variaciones de esta partida}
menuText S EditStripBegin "Movimientos desde el principio" 1 \
  {Quita los movimientos desde el principio de la partida}
menuText S EditStripEnd "Movimientos hasta el final" 0 \
  {Quita los movimientos hasta el final de la partida}
menuText S EditReset "Poner a cero la base de trabajo" 0 \
  {Pone a cero la base de trabajo (clipbase) para que estÃ© completamente vacÃ­a}
menuText S EditCopy "Copiar esta partida a la base de trabajo" 1 \
  {Copia esta partida a la base de trabajo (clipbase)}
menuText S EditPaste "Pegar la Ãºltima partida de la base de trabajo" 2 \
  {Pega en la base actual la partida activa en la base de trabajo (clipbase)}
menuText S EditPastePGN "Pegar el texto del portapapeles como partida PGN..." 10 \
  {Interpreta el texto de la base de trabajo (clipbase) como una partida en notaciÃ³n PGN y la pega aquÃ­}
menuText S EditSetup "Iniciar tablero de posiciÃ³n..." 26 \
  {Inicia el tablero de posiciÃ³n con la posiciÃ³n de la partida}
menuText S EditCopyBoard "Copiar posiciÃ³n" 8 \
  {Copia el tablero actual en notaciÃ³n FEN al portapapeles}
menuText S EditPasteBoard "Pegar tablero inicial" 6 \
  {Coloca el tablero inicial en el portapapeles}
menuText S ConfigureScid "Preferencias..." 0 {Configurar todas las opciones para SCID}

# Game menu:
menuText S Game "Partida" 0
menuText S GameNew "Partida nueva" 0 \
  {Partida nueva, descarta cambios de la partida actual}
menuText S GameFirst "Cargar primera partida" 7 {Carga la primera partida filtrada}
menuText S GamePrev "Cargar partida anterior" 16 {Carga la anterior partida filtrada}
menuText S GameReload "Recargar partida actual" 0 \
  {Vuelve a cargar esta partida, descartando cualquier cambio hecho}
menuText S GameNext "Cargar siguiente partida" 7 {Carga la siguiente partida filtrada}
menuText S GameLast "Cargar Ãºltima partida" 9 {Carga la Ãºltima partida filtrada}
menuText S GameRandom "Cargar partida aleatoria" 16 {Carga aleatoriamente una partida filtrada}
menuText S GameNumber "Cargar partida nÃºmero..." 3 \
  {Carga una partida poniendo su nÃºmero}
menuText S GameReplace "Guardar: reemplazar partida..." 10 \
  {Guarda esta partida, reemplazando la antigua versiÃ³n}
menuText S GameAdd "Guardar: aÃ±adir nueva partida..." 9 \
  {Guarda esta partida como una nueva partida en la base de datos}
menuText S GameDeepest "Identificar apertura" 1 \
  {Va a la posiciÃ³n mÃ¡s avanzada de la partida segÃºn el libro ECO}
menuText S GameGotoMove "Ir al movimiento nÃºmero..." 6 \
  {Ir al nÃºmero de movimiento especificado en la partida actual}
menuText S GameNovelty "Encontrar novedad..." 12 \
  {Encuentra el primer movimiento de esta partida que no se ha jugado antes}

# Search Menu:
menuText S Search "Buscar" 0
menuText S SearchReset "Poner a cero el filtro" 0 \
  {Pone a cero el filtro para que todas la partidas estÃ©n incluidas}
menuText S SearchNegate "Invertir filtro" 0 \
  {Invierte el filtro para sÃ³lo incluir las partidas excluidas}
menuText S SearchCurrent "Tablero actual..." 0 \
  {Busca por la posiciÃ³n actual del tablero}
menuText S SearchHeader "Encabezamiento..." 0 \
  {Busca por informaciÃ³n de encabezamiento (jugador, evento, etc.)}
menuText S SearchMaterial "Material/PatrÃ³n..." 0 \
  {Busca por material o patrÃ³n del tablero}
menuText S SearchUsing "Usar archivo de bÃºsqueda..." 0 \
  {Busca usando un archivo de opciones de bÃºsqueda}

# Windows menu:
menuText S Windows "Ventanas" 0
menuText S WindowsComment "Editor de comentarios" 0 \
  {Abre/cierra el editor de comentarios}
menuText S WindowsGList "Listado de partidas" 0 \
  {Abre/cierra la  ventana de listado de partidas}
menuText S WindowsPGN "Ventana PGN" 8 \
  {Abre/cierra la ventana de PGN (notaciÃ³n de partida)}
menuText S WindowsPList "Buscador de jugadores" 2 {Abre/cierra el buscador de jugadores}
menuText S WindowsTmt "Visor de torneos" 9 {Abre/cierra el visor de torneos}
menuText S WindowsSwitcher "Bases de datos" 0 \
  {Abre/cierra la ventana de bases de datos}
menuText S WindowsMaint "Ventana de mantenimiento" 11 \
  {Abre/cierra la ventana de mantenimiento}
menuText S WindowsECO "Buscador ECO" 0 {Abre/cierra la ventana del buscador ECO}
menuText S WindowsStats "Ventana de estadÃ­sticas" 12 \
  {Abre/cierra la ventana de estadÃ­sticas del filtro}
menuText S WindowsTree "Ventana de Ã¡rbol de aperturas" 6 {Abre/cierra la ventana de Ã¡rbol de aperturas (Book)}
menuText S WindowsBook "Ventana de libros de aperturas (Book)" 0 {Abrir/Cerrar la ventana de libros de aperturas (Book)}
menuText S WindowsCorrChess "Ventana de Correo" 0 {Abrir/Cerrar la ventra de Correo}
menuText S WindowsGraph "GrÃ¡fico de anÃ¡lisis" 0 {Abra la ventana de GrÃ¡fico con tiempos y evaluaciones de movimientos.}

# Tools menu:
menuText S Tools "Herramientas" 0
menuText S ToolsConfigureEngines "Configurar motores" 10 {Administrar la configuraciÃ³n de los motores}
menuText S ToolsAnalysis "Motor de anÃ¡lisis #1..." 0 \
  {Inicia/para el anÃ¡lisis del motor de ajedrez #1}
menuText S ToolsAnalysis2 "Motor de anÃ¡lisis #2..." 18 \
  {Inicia/para el anÃ¡lisis del motor de ajedrez #2}
menuText S ToolsCross "Tabla cruzada" 0 {Muestra la tabla cruzada para esta partida}
menuText S ToolsFilterGraph "Filtro grÃ¡fico" 7 \
  {Abre/cierra la ventana del filtro grÃ¡fico}
menuText S ToolsAbsFilterGraph "Filtro grÃ¡fico Abs." 7 {Abrir/Cerrar la ventana de filtro grÃ¡fico para valores absolutos}
menuText S ToolsOpReport "Informe de la apertura" 1 \
  {Crea un informe de la apertura para la posiciÃ³n actual}
menuText S ToolsOpenBaseAsTree "Abrir base como Ã¡rbol" 0   {Abrir una base y usarla en la ventana de Ã¡rbol (Tree)}
menuText S ToolsOpenRecentBaseAsTree "Abrir base reciente como Ã¡rbol" 0   {Abre una base reciente y la usa en ventana de Ã¡rbol (Tree)} 
menuText S ToolsTracker "Rastreador de piezas"  14 {Abre la ventana del rastreador de piezas}
menuText S ToolsTraining "Entrenamiento"  0 {Entrenamiento (tÃ¡ctica, aperturas,...)}
menuText S ToolsTacticalGame "Partida tÃ¡ctica..."  0 {Juega una partida tÃ¡ctica}
menuText S ToolsSeriousGame "Partida seria..."  0 {Juega una partida seria}
menuText S ToolsTrainOpenings "Entrenamiento de aperturas"  0 {Entrenamiento con un repertorio}
menuText S ToolsTrainReviewGame "Revisar partida"  0 {Adivina movimientos jugados en una partida}
menuText S ToolsTrainTactics "TÃ¡ctica (problemas)"  0 {Resuelve problemas de tÃ¡ctica}
menuText S ToolsTrainCalvar "CÃ¡lculo de variaciones"  0 {CÃ¡lculo de variaciones}
menuText S ToolsTrainFindBestMove "Encontrar la mejor jugada"  0 {Busca el movimiento mejor}
menuText S ToolsTrainFics "Jugar en internet..."  0 {Conecta a freechess.org}
menuText S ToolsEngineTournament "Torneo de motores"  0 {Iniciar un torneo entre motores de ajedrez}
menuText S ToolsTimeAnalysis "Análisis de tiempo" 0 {Mostrar gráfico de tiempo del reloj del juego actual}
menuText S ToolsBookTuning "Sintonizar libro de aperturas" 0 {Sintoniza el libro (Book)}
menuText S ToolsDownloadTWIC "Descargar juegos TWIC" 0 {Descargar los ÃÂºltimos juegos The Week In Chess (TWIC)}
menuText S ToolsConnectHardware "Conectar hardware" 0 {Conecta hardware externo"}
menuText S ToolsConnectHardwareConfigure "ConfiguraciÃ³n..." 1 {ConfiguraciÃ³n}
menuText S ToolsConnectHardwareNovagCitrineConnect "Conectar Novag" 0 {Conecta Novag}
menuText S ToolsConnectHardwareInputEngineConnect "Conectar motor de entrada" 0 {Conecta un motor de entrada (e.d. DGT)}

menuText S ToolsPInfo "InformaciÃ³n del jugador" 16 \
  {Abre/actualiza la ventana de informaciÃ³n del jugador}
menuText S ToolsPlayerReport "Informe del jugador..." 3 \
  {Crea un informe sobre un jugador}
menuText S ToolsRating "GrÃ¡fico del Elo..." 0 \
  {GrÃ¡fico de la historia del Elo de los jugadores de la actual partida}
menuText S ToolsExpCurrent "Exportar la partida actual..." 0 \
  {Escribe la partida actual en un archivo de texto}
menuText S ToolsExpCurrentPGN "Exportar la partida a un archivo PGN..." 33 \
  {Escribe la partida actual en un archivo PGN}
menuText S ToolsExpCurrentHTML "Exportar la partida a un archivo HTML..." 33 \
  {Escribe la partida actual en un archivo HTML}
menuText S ToolsExpCurrentHTMLJS "Exportar la partida a un archivo HTML y JavaScript..." 15 \
  {Escribe la partida actual a un fichero HTML y JavaScript} 
menuText S ToolsExpFilter "Exportar todas las partidas filtradas..." 1 \
  {Escribe todas las partidas filtradas en un archivo de texto}
menuText S ToolsExpFilterPGN "Exportar filtro a un archivo PGN..." 29 \
  {Escribe todas las partidas filtradas en un archivo PGN}
menuText S ToolsExpFilterHTML "Exportar filtro a un archivo HTML..." 29 \
  {Escribe todas las partidas filtradas en un archivo HTML}
menuText S ToolsExpFilterHTMLJS "Exportar filtro a un archivo HTML y JavaScript..." 17 \
  {Escribe todas las partidas filtradas a ficheros HTML y JavaScript}  
menuText S ToolsImportOne "Importar una partida PGN..." 0 \
  {Importa una partida de un texto PGN}
menuText S ToolsImportFile "Importar un archivo de partidas PGN..." 2 \
  {Importa partidas de un archivo PGN}
menuText S ToolsStartEngine1 "Empezar motor 1" 0  {Empieza el motor 1}
menuText S ToolsStartEngine2 "Empezar motor 2" 0  {Empieza el motor 2}
menuText S ToolsCaptureBoard "Capturar Tablero Actual..." 0  {Guardar el tablero actual como imagen.}

# Play menu
menuText S Play "Jugar" 0

# --- Correspondence Chess
menuText S CCResign "Abandonar" 0 {Abandona}
menuText S CCClaimDraw "Reclamar tablas" 0 \
  {Envia un movimiento y reclama tablas}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText S Options "Opciones" 0
menuText S OptionsBoardGraphics "Escaques..." 0 {Elige texturas para escaques}
translate S OptionsBGW {Elegir textura para escaques}
translate S OptionsBoardGraphicsText {Elegir fichero grÃ¡fico para escaques blancos y negros}
menuText S OptionsBoardNames "Nombres de jugador..." 0 {Edita lista de nombres de jugador}
menuText S OptionsExport "ExportaciÃ³n" 0 {Cambia las opciones de exportaciÃ³n de texto}
menuText S OptionsFonts "Fuentes" 0 {Cambia las fuentes}
menuText S OptionsFontsRegular "Habitual" 0 {Cambia la fuente habitual}
menuText S OptionsFontsMenu "MenÃº" 0 {Cambia la fuente del menÃº}
menuText S OptionsFontsSmall "PequeÃ±a" 0 {Cambia la fuente pequeÃ±a}
menuText S OptionsFontsTiny "Tiny" 0 {Cambia la fuente diminuta}
menuText S OptionsFontsFixed "Ancho fijo" 0 {Cambia la fuente de ancho fijo}
menuText S OptionsGInfo "InformaciÃ³n de la partida" 0 {InformaciÃ³n de la partida}
menuText S OptionsLanguage "Idioma" 0 {Selecciona el idioma del programa}
menuText S OptionsMovesTranslatePieces "Traducir piezas" 0 \
  {Traduce la primera letra de las piezas}
menuText S OptionsMovesHighlightLastMove "Iluminar Ãºltima jugada" 0 \
  {Ilumina la Ãºltima jugada}
menuText S OptionsMovesHighlightLastMoveDisplay "Mostrar Escaques" 0 \
  {Muestra la Ãºltima jugada iluminada}
menuText S OptionsMovesHighlightLastMoveWidth "Ancho" 0 {Espesor de la lÃ­nea}
menuText S OptionsMovesHighlightLastMoveColor "Color" 0 {Color de lÃ­nea}
menuText S OptionsMovesHighlightLastMoveArrow "Mostrar Flechas" 0 {Show Arrow with Highlight}
menuText S OptionsMovesHighlightLastMoveNag "Mostrar sÃ­mbolos de evaluaciÃ³n" 0
menuText S OptionsMovesHighlightLastMoveEval "Mostrar símbolos de evaluación" 0
menuText S OptionsMoves "Movimientos" 0 {Opciones de la entrada de movimientos}
menuText S OptionsMovesAnimate "Velocidad de la animaciÃ³n" 1 \
  {Pone el tiempo usado para animar las jugadas}
menuText S OptionsMovesDelay "Demora del automovimiento..." 0 \
  {Pone el tiempo de demora para el modo de automovimiento}
menuText S OptionsMovesCoord "Entrada de movimientos coordinada" 0 \
  {Acepta entrada de movimientos en sistema "coordinado" ("g1f3")}
menuText S OptionsMovesSuggest "Mostrar movimientos sugeridos" 20 \
  {Activa/desactiva la sugerencia de movimientos}
menuText S OptionsShowVarPopup "Mostrar ventana de variaciones" 0 \
  {Activa/desactiva la ventana de variaciones}
menuText S OptionsMovesSpace "AÃ±adir espacios detrÃ¡s del nÃºmero de movimiento" 0 \
  {AÃ±ade espacios detrÃ¡s del nÃºmero de movimiento}
menuText S OptionsMovesLichess "Formato Lichess/ChessBase para Anotaciones" 0 {Usar formato Lichess/ChessBase para marcadores de casillas y flechas}
menuText S OptionsMovesKey "Teclado inteligente" 0 \
  {Activa/desactiva la funciÃ³n de autocompletado inteligente de movimientos con teclado}
menuText S OptionsMovesShowVarArrows "Mostrar flechas para las variaciones" 0 \
  {Activa/desactiva mostrar flechas para las variaciones}
menuText S OptionsMovesShowEngineVariationArrows "Mostrar Flechas para Variantes del Motor" 0 {Activar/desactivar flechas que muestran lÃ­neas de variaciÃ³n del motor en modo multiPV}
menuText S OptionsMovesGlossOfDanger "Brillo de peligro codificado por colores" 0 {Activar/desactivar el brillo de peligro codificado por colores}
translate S OptionsMovesTreeDepth {Profundidad de movimiento de ventana de árbol predeterminada}
menuText S OptionsNumbers "Formato de nÃºmeros" 11 \
  {Selecciona el formato de nÃºmeros}
menuText S OptionsTheme "Tema" 0 {Cambia el aspecto del interfaz}
menuText S OptionsWindows "Ventanas" 0 {Opciones de ventana}
menuText S OptionsSounds "Sonidos" 2 \
  {Configura el sonido del anuncio de las jugadas}
menuText S OptionsResources "Recursos..." 0 {Elija archivos y carpetas de recursos}
menuText S OptionsWindowsDock "Ventanas en dique" 0 {Ventanas en dique}
menuText S OptionsWindowsSaveLayout "Salvar disposiciÃ³n" 0 {Salva la disposiciÃ³n}
menuText S OptionsWindowsRestoreLayout "Restaurar disposiciÃ³n" 0 \
  {Restaura la disposiciÃ³n}
menuText S OptionsWindowsShowGameInfo "Mostrar informaciÃ³n de la partida" 0 \
  {Muestrar informaciÃ³n de la partida}
menuText S OptionsWindowsAutoLoadLayout "Auto cargar primera disposiciÃ³n" 0 \
  {Autocarga la primera disposiciÃ³n al iniciar}
menuText S OptionsECO "Cargar archivo ECO" 7 \
  {Cargar el archivo de clasificaciÃ³n ECO}
menuText S OptionsSpell "Cargar archivo de comprobaciÃ³n ortogrÃ¡fica" 2 \
  {Carga el archivo de comprobaciÃ³n ortogrÃ¡fica Scid}
menuText S OptionsTable "Directorio de las tablas de finales (TB)" 19 \
  {Selecciona el directorio de tablas finales; todas las TB de ese directorio serÃ¡n usadas}
menuText S OptionsRecent "Archivos recientes..." 9 \
  {Cambia el nÃºmero de archivos recientes mostrados en el menÃº Archivo}
menuText S OptionsBooksDir "Carpeta de libros de aperturas" 0 \
  {Fija la carpeta de los libros de aperturas (Books)}
menuText S OptionsTacticsBasesDir "Carpeta de bases de datos" 0 \
  {Fija la carpeta de la base de entrenamiento tÃ¡ctico}
menuText S OptionsPhotosDir "Directorio de fotos" 0 {Establece el directorio de bases de fotos.}
menuText S OptionsThemeDir "Archivo de tema(s):"  0 {Cargue un archivo de paquete de tema GUI}
menuText S OptionsSave "Guardar opciones" 0 \
  "Guarda todas las opciones en el fichero $::optionsFile"
menuText S OptionsAutoSave "Autoguardar opciones al salir" 0 \
  {Guarda automÃ¡ticamente todas las opciones cuando se sale de Scid}

# Help menu:
menuText S Help "Ayuda" 1
menuText S HelpContents "Contenidos" 0 {Show the help contents page}
menuText S HelpIndex "Ãndice" 0 {Muestra la pÃ¡gina Ã­ndice de la ayuda}
menuText S HelpGuide "GuÃ­a rÃ¡pida" 0 {Muestra la pÃ¡gina de la ayuda guÃ­a rÃ¡pida}
menuText S HelpHints "Sugerencias" 1 {Muestra la pÃ¡gina de la ayuda sugerencias}
menuText S HelpContact "InformaciÃ³n de contacto" 15 \
  {Muestra la pÃ¡gina de la ayuda de la informaciÃ³n de contacto}
menuText S HelpTip "Sugerencia del dÃ­a" 0 {Muestra una Ãºtil sugerencia para Scid}
menuText S HelpStartup "Ventana de inicio" 0 {Muestra la ventana de inicio}
menuText S HelpAbout "Acerca de Scid" 10 {InformaciÃ³n acerca de Scid}

# Toolbar tooltips:
menuText S RotateBoard "rotar tablero" 0 {rotar tablero}

# Game info box popup menu:
menuText S GInfoHideNext "Ocultar siguiente movimiento" 0
menuText S GInfoMaterial "Mostrar valor del material" 0
menuText S GInfoFEN "Mostrar FEN" 8
menuText S GInfoMarks "Mostrar casillas y flechas coloreadas" 29
menuText S GInfoWrap "Dividir lÃ­neas largas" 0
menuText S GInfoFullComment "Mostrar comentarios completos" 8
menuText S GInfoPhotos "Mostrar fotos" 5
menuText S GInfoTBNothing "TBs: nada" 5
menuText S GInfoTBResult  "TBs: sÃ³lo resultado" 10
menuText S GInfoTBAll "TBs: resultado y mejor movimiento" 23
menuText S GInfoDelete "(No)Borrar esta partida" 4
menuText S GInfoMark "(No)Marcar esta partida" 4
menuText S GInfoInformant "Configurar valores de informaciÃ³n" 0

# General buttons:
translate S Back {AtrÃ¡s}
translate S Browse {Hojear}
translate S Cancel {Cancelar}
translate S Continue {Continuar}
translate S Clear {Limpiar}
translate S Close {Cerrar}
translate S Contents {Contenidos}
translate S Defaults {Por defecto}
translate S InvertSearch {Invertir búsqueda}
translate S Delete {Borrar}
translate S Graph {GrÃ¡fico}
translate S Help {Ayuda}
translate S Hide {Esconder}
translate S Import {Importar}
translate S Index {Ãndice}
translate S LoadGame {Cargar partida}
translate S BrowseGame {Hojear partida}
translate S MergeGame {Incorporar partida}
translate S MergeGames {Mezclar o fusionar partidas}
translate S Preview {Vista previa}
translate S Revert {Retroceder}
translate S Save {Guardar}
translate S Search {Buscar}
translate S Stop {Parar}
translate S Store {Almacenar}
translate S Update {Actualizar}
translate S ChangeOrient {Cambiar orientaciÃ³n de la ventana}
translate S ShowIcons {Mostrar iconos}
translate S None {Ninguno}
translate S First {Primera}
translate S Current {Actual}
translate S Last {Ãltima}

# General messages:
translate S game {partida}
translate S games {partidas}
translate S move {movimiento}
translate S moves {movimientos}
translate S all {todo}
translate S Yes {SÃ­}
translate S No {No}
translate S Both {Ambos}
translate S King {Rey}
translate S Queen {Dama}
translate S Rook {Torre}
translate S Bishop {Alfil}
translate S Knight {Caballo}
translate S Pawn {PeÃ³n}
translate S White {Blancas}
translate S Black {Negras}
translate S Player {Jugador}
translate S Rating {Elo}
translate S RatingDiff {Diferencia de Elo (Blancas - Negras)}
translate S AverageRating {Elo promedio}
translate S Event {Evento}
translate S Site {Lugar}
translate S Country {PaÃ­s}
translate S IgnoreColors {Ignorar colores}
translate S Date {Fecha}
translate S EventDate {Evento fecha}
translate S Decade {DÃ©cada}
translate S Year {AÃ±o}
translate S Month {Mes}
translate S Months {enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre}
translate S Days {dom lun mar miÃ© jue vie sÃ¡b}
translate S YearToToday {Ãltimo aÃ±o hasta hoy}
translate S YearToTodayTooltip {Establecer fecha desde hace 1 aÃ±o hasta hoy}
translate S Result {Resultado}
translate S Round {Ronda}
translate S Length {Longitud}
translate S ECOCode {CÃ³digo ECO}
translate S ECO {ECO}
translate S Deleted {Borrar}
translate S SearchResults {Buscar resultados}
translate S OpeningTheDatabase {Abriendo base de datos}
translate S Database {Base de datos}
translate S Filter {Filtro}
translate S noGames {no hay partidas}
translate S allGames {todas las partidas}
translate S empty {vacÃ­a}
translate S clipbase {clipbase}
translate S score {puntuaciÃ³n}
translate S StartPos {PosiciÃ³n inicial}
translate S Total {Total}
translate S readonly {sÃ³lo lectura}

# Standard error messages:
translate S ErrNotOpen {Esta base de datos no estÃ¡ abierta.}
translate S ErrReadOnly {Esta base de datos es de sÃ³lo lectura; no puede ser cambiada.}
translate S ErrSearchInterrupted {La busqueda se interrumpiÃ³; los resultados son incompletos.}
translate S ErrEnginesOpen {No se puede continuar mientras los motores de ajedrez están abiertos.\nCierre todas las ventanas del motor e inténtelo de nuevo.}
translate S ErrNoClockComments {No se encontraron comentarios de reloj [%clk] en este juego.    Agregue tiempos de reloj a través de la ventana de comentarios (Ctrl+E) para usar esta función.}
translate S ErrFileInUse {Error: el archivo ya está en uso. Cierre cualquier otra aplicación que utilice esta base de datos. Si el programa se cerró inesperadamente, es posible que deba eliminar el archivo .lock asociado con la base de datos.}




# Game information:
translate S twin {doble}
translate S deleted {borradas}
translate S comment {comentario}
translate S hidden {oculto}
translate S LastMove {Ãltimo movimiento}
translate S NextMove {Siguiente}
translate S GameStart {Inicio de partida}
translate S LineStart {Inicio de lÃ­nea}
translate S GameEnd {Fin de partida}
translate S LineEnd {Fin de lÃ­nea}

# Player information:
translate S PInfoAll {Resultados para <b>todas</b> las partidas}
translate S PInfoFilter {Resultados para las partidas <b>filtradas</b>}
translate S PInfoAgainst {Resultados contra}
translate S PInfoMostWhite {Aperturas mÃ¡s comunes con blancas}
translate S PInfoMostBlack {Aperturas mÃ¡s comunes con negras}
translate S PInfoRating {Historial de clasificaciÃ³n}
translate S PInfoBio {BiografÃ­a}
translate S PInfoEditRatings {Editar Elos}
translate S PInfoEloFile {Archivo}

# Tablebase information:
translate S Draw {Tablas}
translate S with {con}
translate S only {sÃ³lo}
translate S lose {formas de perder}
translate S loses {hace perder}

# Tip of the day:
translate S Tip {Sugerencia}
translate S TipAtStartup {Sugerencia al iniciar}
translate S TipConvertPGN {Puede obtener un mejor rendimiento al convertir archivos PGN}

# Tree window menus:
menuText S TreeFile "Archivo" 0
menuText S TreeFileFillWithBase "Rellenar cachÃ© con base" 0 \
  {Rellena el archivo cachÃ© con todas las partidas de la base actual}
menuText S TreeFileFillWithGame "Rellenar cachÃ© con partida" 0 \
  {Rellena el fichero cachÃ© con movimientos de la partida actual en la base actual}
menuText S TreeFileSetCacheSize "TamaÃ±o de cachÃ©" 0 {Fija el tamaÃ±o del cachÃ©}
menuText S TreeFileCacheInfo "InformaciÃ³n de cachÃ©" 0 \
  {InformaciÃ³n y uso del cachÃ©}
menuText S TreeFileSave "Guardar archivo cachÃ©" 0 \
  {Guarda el archivo cachÃ© del Ã¡rbol (.stc)}
menuText S TreeFileFill "Construir archivo cachÃ©" 2 \
  {Construye archivo cachÃ© con posiciones de apertura comunes}
menuText S TreeFileBest "Lista de mejores partidas" 9 \
  {Muestra la lista del Ã¡rbol de mejores partidas}
menuText S TreeFileGraph "Ventana del grÃ¡fico" 0 \
  {Muestra el grÃ¡fico para esta rama del Ã¡rbol}
menuText S TreeFileCopy "Copiar texto del Ã¡rbol al portapapeles" 1 \
  {Copia texto del Ã¡rbol al portapapeles}
menuText S TreeFileClose "Cerrar ventana del Ã¡rbol" 0 \
  {Cerra ventana del Ã¡rbol}
menuText S TreeMask "MÃ¡scara" 0
menuText S TreeMaskNew "Nuevo" 0 {Nueva mÃ¡scara}
menuText S TreeMaskOpen "Abrir" 0 {Abre mÃ¡scara}
menuText S TreeMaskOpenRecent "Abrir reciente" 0 {Abre mÃ¡scara reciente}
menuText S TreeMaskSave "Salvar" 0 {Salva mÃ¡scara}
menuText S TreeMaskClose "Cerrar" 0 {Cierra mÃ¡scara}
menuText S TreeMaskFillWithGame "Llenar con partida" 0 \
  {Llena mÃ¡scara con partida}
menuText S TreeMaskFillWithBase "Llenar con base" 0 \
  {Llena mÃ¡scara con todas las partidas de la base}
menuText S TreeMaskInfo "Info" 0 {Muestra estadÃ­sticas para la mÃ¡scara actual}
menuText S TreeMaskDisplay "Mostrar mapa de la mÃ¡scara" 0 \
  {Muestra mÃ¡scara en forma de Ã¡rbol}
menuText S TreeMaskSearch "Buscar" 0 {Busca en mÃ¡scara actual}
menuText S TreeSort "Ordenar" 0
menuText S TreeSortAlpha "AlfabÃ©ticamente" 0
menuText S TreeSortECO "Por cÃ³digo ECO" 11
menuText S TreeSortFreq "Por frecuencia" 4
menuText S TreeSortScore "Por puntuaciÃ³n" 4
menuText S TreeOpt "Opciones" 1
menuText S TreeOptSlowmode "Modo Lento" 0 \
  {Movimiento lento para actualizaciones (alta calidad)}
menuText S TreeOptFastmode "Modo RÃ¡pido" 0 \
  {Movimiento rÃ¡pido para actualizaciones (no transpone movimientos)}
menuText S TreeOptFastAndSlowmode "Modo rÃ¡pido y lento" 0 \
  {Movimiento rÃ¡pido y modo lento para actualizaciones}
menuText S TreeOptStartStop "Auto actualizado" 0 \
  {Actualizado automÃ¡tico de la ventana del Ã¡rbol}
menuText S TreeOptLock "Bloquear" 1 \
  {Bloquea/desbloquea el Ã¡rbol de la base de datos actual}
menuText S TreeOptTraining "Entrenamiento" 2 \
  {Activa/desactiva el modo de entrenamiento de Ã¡rbol}
menuText S TreeOptDepth "Mover profundidad" 0 {Número de medios movimientos para mostrar en el árbol (1-4)}
menuText S TreeOptAutosave "Autoguardar archivo cachÃ©" 0 \
  {Guarda automÃ¡ticamente el archivo cachÃ© cuando se cierra la ventana de Ã¡rbol}
menuText S TreeHelp "Ayuda" 1
menuText S TreeHelpTree "Ayuda del Ã¡rbol" 4
menuText S TreeHelpIndex "Ãndice de la ayuda" 0
translate S SaveCache {Guardar cachÃ©}
translate S Training {Entrenamiento}
translate S LockTree {Bloquear}
translate S TreeDepth {Profundidad del árbol (medios movimientos):}
translate S TreeLocked {Bloqueado}
translate S TreeBest {Mejor}
translate S TreeBestGames {Mejores partidas del Ã¡rbol}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate S TreeTitleRow \
{Movim.                        ECO       Frecuencia   Puntu. AvElo Perf AvAÃ±o %Tablas   %Ganar}
translate S TreeTotal {TOTAL}
translate S DoYouWantToSaveFirst {Â¿Quieres salvar primero?}
translate S AddToMask {AÃ±adir a mÃ¡scara}
translate S RemoveFromMask {Eliminar desde la mÃ¡scara}
translate S AddThisMoveToMask {AÃ±adir este movimiento a la MÃ¡scara}
translate S SearchMask {Buscar en mÃ¡scara}
translate S DisplayMask {Mostrar mÃ¡scara}
translate S Nag {CÃ³digo de regaÃ±o}
translate S Marker {Marcador}
translate S Include {Incluir}
translate S Exclude {Excluir}
translate S MainLine {LÃ­nea principal}
translate S Bookmark {Marcador}
translate S NewLine {LÃ­nea nueva}
translate S ToBeVerified {Para ser verificado}
translate S ToTrain {Para entrenar}
translate S Dubious {Dudoso}
translate S ToRemove {Para quitar}
translate S NoMarker {Sin marcador}
translate S ColorMarker {Color}
translate S WhiteMark {Blanco}
translate S GreenMark {Verde}
translate S YellowMark {Amarillo}
translate S BlueMark {Azul}
translate S RedMark {Rojo}
translate S CommentMove {Comentar movimiento}
translate S CommentPosition {Comentar posiciÃ³n}
translate S AddMoveToMaskFirst {AÃ±adir primero el movimiento a la mÃ¡scara}
translate S OpenAMaskFileFirst {Abrir primero un fichero de mÃ¡scara}
translate S Positions {Posiciones}
translate S Moves {Jugadas}

# Finder window:
menuText S FinderFile "Archivo" 0
menuText S FinderFileSubdirs "Mirar en subdirectorios" 0
menuText S FinderFileClose "Cierra visor de archivos" 0
menuText S FinderSort "Ordenar" 0
menuText S FinderSortType "Tipo" 0
menuText S FinderSortSize "TamaÃ±o" 0
menuText S FinderSortMod "Modificado" 0
menuText S FinderSortName "Nombre" 0
menuText S FinderSortPath "Camino" 0
menuText S FinderTypes "Tipos" 0
menuText S FinderTypesScid "Bases de datos Scid" 0
menuText S FinderTypesOld "Bases de datos Scid en formato antiguo" 12
menuText S FinderTypesPGN "Archivos PGN" 9
menuText S FinderTypesEPD "Archivos EPD (libro)" 0
menuText S FinderTypesRep "Archivos de repertorio" 12
menuText S FinderHelp "Ayuda" 1
menuText S FinderHelpFinder "Ayuda del visor de archivos" 0
menuText S FinderHelpIndex "Ãndice de la ayuda" 0
translate S FileFinder {Visor de archivos}
translate S FinderDir {Directorio}
translate S FinderDirs {Directorios}
translate S FinderFiles {Archivos}
translate S FinderUpDir {Arriba}
translate S FinderCtxOpen {Abrir}
translate S FinderCtxBackup {Copia de seguridad (Backup)}
translate S FinderCtxCopy {Copia}
translate S FinderCtxMove {Jugada}
translate S FinderCtxDelete {Borrar}

# Player finder:
menuText S PListFile "Archivo" 0
menuText S PListFileUpdate "Actualizar" 0
menuText S PListFileClose "Cierra el buscador de jugadores" 0
menuText S PListSort "Ordenar" 0
menuText S PListSortName "Nombre" 0
menuText S PListSortElo "Elo" 0
menuText S PListSortGames "Partidas" 0
menuText S PListSortOldest "MÃ¡s antiguo" 10
menuText S PListSortNewest "MÃ¡s nuevo" 4

# Tournament finder:
menuText S TmtFile "Archivo" 0
menuText S TmtFileUpdate "Actualizar" 0
menuText S TmtFileClose "Cierra el visor de torneos" 0
menuText S TmtSort "Ordenar" 0
menuText S TmtSortDate "Fecha" 0
menuText S TmtSortPlayers "Jugadores" 0
menuText S TmtSortGames "Partidas" 0
menuText S TmtSortElo "Elo" 0
menuText S TmtSortSite "Lugar" 0
menuText S TmtSortEvent "Evento" 1
menuText S TmtSortWinner "Ganador" 0
translate S TmtLimit "LÃ­mite de lista"
translate S TmtMeanElo "Media de Elo inferior"
translate S TmtNone "No se han encontrado torneos concordantes."

# Graph windows:
menuText S GraphFile "Archivo" 0
menuText S GraphFileColor "Guardar como Postscript en color..." 24
menuText S GraphFileGrey "Guardar como Postscript en escala de grises..." 34
menuText S GraphFileClose "Cerrar ventana" 7
menuText S GraphOptions "Opciones" 0
menuText S GraphOptionsWhite "Blancas" 0
menuText S GraphOptionsBlack "Negras" 0
menuText S GraphOptionsBoth "Ambos" 0
menuText S GraphOptionsPInfo "Jugador InformaciÃ³n jugador" 0
menuText S GraphOptionsEloFile "Elo del archivo de calificaciÃ³n" 0
menuText S GraphOptionsEloDB "Elo de la base de datos" 0
translate S GraphFilterTitle "Filtro grÃ¡fico: frecuencia por 1000 partidas"
translate S GraphAbsFilterTitle "Filtro grÃ¡fico: frecuencia de las partidas"
translate S ConfigureFilter {Configurar Eje-X para AÃ±o, Rating y Movimientos}
translate S FilterEstimate "Estimar"
translate S TitleFilterGraph "Scid: Filtro GrÃ¡fico"

# Analysis window:
translate S AddVariation {AÃ±adir variaciÃ³n}
translate S AddAllVariations {AÃ±adir todas las variaciones}
translate S AddMove {AÃ±adir movimiento}
translate S Annotate {Anotar}
translate S ShowAnalysisBoard {Mostrar tablero de anÃ¡lisis}
translate S ShowInfo {Muestra info del motor}
translate S FinishGame {Finalizar partida}
translate S StopEngine {Parar motor}
translate S StartEngine {Empezar motor}
translate S LockEngine {Bloquea motor en posiciÃ³n actual}
translate S AnalysisCommand {DirecciÃ³n de anÃ¡lisis}
translate S PreviousChoices {ElecciÃ³n previa}
translate S AnnotateTime {Poner el tiempo entre movimientos en segundos}
translate S AnnotateWhich {AÃ±adir variaciones}
translate S AnnotateAll {Para movimientos de ambos lados}
translate S AnnotateAllMoves {Anotar todos los movimientos}
translate S AnnotateWhite {SÃ³lo para movimientos de las blancas}
translate S AnnotateBlack {SÃ³lo para movimientos de las negras}
translate S AnnotateBlundersOnly {Cuando el movimiento de la partida es un error}
translate S AnnotateBlundersOnlyScoreChange {AnÃ¡lisis reporta errores, con cambio de puntuaciÃ³n desde: }
translate S BlundersThreshold {Umbral del error }
translate S ScoreAllMoves {Puntuar todos los movimientos}
translate S LowPriority {Baja prioridad del procesador}
translate S ClickHereToSeeMoves {Pulsa aquÃ­ para ver movimientos}
translate S ConfigureInformant {Informaciones}
translate S Informant!? {Movimiento interesante}
translate S Informant? {Movimiento malo}
translate S Informant?? {Desastroso}
translate S Informant?! {Movimiento dudoso}
translate S Informant+= {Blancas tienen una ligera ventaja}
translate S Informant+/- {Blancas tienen ventaja}
translate S Informant+- {Blancas tienen una ventaja decisiva}
translate S Informant+-- {La partida es considerada ganada}
translate S AutoComment {Comentario automático}
translate S AutoCommentTooltip {Genere comentarios de IA para la posición actual}
translate S AnalysisAutoCommentTooltip {Genera comentarios de IA para todo el juego.}

# Book window
translate S Book {Libro}
translate S OtherBookMoves {Otros movimientos del libro}
translate S OtherBookMovesTooltip {Movimientos para los que el oponente tiene una respuesta}

# Analysis Engine open dialog:
translate S EngineList {Lista de motores de anÃ¡lisis}
translate S EngineName {Nombre}
translate S EngineCmd {Orden}
translate S EngineArgs {ParÃ¡metros}
translate S EngineDir {Directorio}
translate S EngineElo {Elo}
translate S EngineTime {Fecha}
translate S EngineNew {Nuevo}
translate S EngineEdit {Editar}
translate S EngineRequired {Los campos en negrita son obligatorios; los demÃ¡s opcionales}
translate S EngineProtocol {Protocolo de comunicaciÃ³n}
translate S EngineNotation {NotaciÃ³n de los movimientos.}
translate S EngineFlipEvaluation {Voltear la perspectiva de evaluaciÃ³n}
translate S EngineShowLog {Mostrar registro de comunicaciÃ³n}
translate S EngineNetworkd {Aceptar conexiones remotas}
translate S EngineSelect {Seleccione el motor actual}
translate S EngineAddLocal {Agregar un motor local}
translate S EngineAddRemote {Agregar un motor remoto}
translate S EngineReload {Recargar el motor actual}
translate S EngineClone {Crear una copia del motor actual.}
translate S EngineDelete {Eliminar el motor actual}

# PGN window menus:
menuText S PgnFile "Archivo" 0
menuText S PgnFileCopy "Copiar partida al portapapeles" 0
menuText S PgnFilePrint "Imprimir en archivo..." 0
menuText S PgnFileClose "Cerrar ventana PGN" 0
menuText S PgnOpt "PresentaciÃ³n" 0
menuText S PgnOptColor "Color de la presentaciÃ³n" 0
menuText S PgnOptShort "Encabezado pequeÃ±o (3 lÃ­neas)" 13
menuText S PgnOptSymbols "Anotaciones simbÃ³licas" 0
menuText S PgnOptIndentC "SangrÃ­a en comentarios" 0
menuText S PgnOptIndentV "SangrÃ­a en variaciones" 11
menuText S PgnOptColumn "Estilo de columna (un movimiento por lÃ­nea)" 1
menuText S PgnOptSpace "Espacio despuÃ©s del nÃºmero del movimiento" 0
menuText S PgnOptStripMarks "Quitar cÃ³digos de color en casilla/flecha" 3
menuText S PgnOptBoldMainLine "Usar texto en negrita para las jugadas principales" 4
menuText S PgnColor "Colores" 1
menuText S PgnColorHeader "Encabezamiento..." 0
menuText S PgnColorAnno "Anotaciones..." 0
menuText S PgnColorComments "Comentarios..." 0
menuText S PgnColorVars "Variaciones..." 0
menuText S PgnColorBackground "Fondo..." 0
menuText S PgnColorMain "LÃ­nea principal..." 0
menuText S PgnColorCurrent "Color de fondo del Ãºltimo movimiento..." 1
menuText S PgnHelp "Ayuda" 1
menuText S PgnHelpPgn "Ayuda de PGN" 9
menuText S PgnHelpIndex "Ãndice de la ayuda" 0
translate S PgnWindowTitle {Planilla - partida %u}

# Crosstable window menus:
menuText S CrosstabFile "Archivo" 0
menuText S CrosstabFileText "Imprimir en archivo texto..." 20
menuText S CrosstabFileHtml "Imprimir en archivo HTML..." 20
menuText S CrosstabFileClose "Cerrar ventana de tabla cruzada" 0
menuText S CrosstabEdit "Editar" 0
menuText S CrosstabEditEvent "Evento" 0
menuText S CrosstabEditSite "Lugar" 0
menuText S CrosstabEditDate "Fecha" 0
menuText S CrosstabOpt "PresentaciÃ³n" 0
menuText S CrosstabOptAll "Todos contra todos" 0
menuText S CrosstabOptSwiss "Suizo" 0
menuText S CrosstabOptKnockout "Eliminatoria directa" 0
menuText S CrosstabOptAuto "Auto" 0
menuText S CrosstabOptAges "Edad en aÃ±os" 1
menuText S CrosstabOptNats "Nacionalidades" 0
menuText S CrosstabOptRatings "Elo" 0
menuText S CrosstabOptTitles "TÃ­tulos" 0
menuText S CrosstabOptBreaks "Puntuaciones de desempate" 0
menuText S CrosstabOptDeleted "Incluir partidas borradas" 17
menuText S CrosstabOptColors "Colores (sÃ³lo en tabla de suizos)" 0
menuText S CrosstabOptColumnNumbers "Columnas numeradas (SÃ³lo en tabla todos contra todos)" 11
menuText S CrosstabOptGroup "Grupos de clasificaciÃ³n" 0
menuText S CrosstabSort "Ordenar" 0
menuText S CrosstabSortName "Por nombre" 4
menuText S CrosstabSortRating "Por Elo" 4
menuText S CrosstabSortScore "Por puntuaciÃ³n" 4
menuText S CrosstabColor "Color" 2
menuText S CrosstabColorPlain "Texto simple" 0
menuText S CrosstabColorHyper "Hipertexto" 0
menuText S CrosstabHelp "Ayuda" 1
menuText S CrosstabHelpCross "Ayuda de tabla cruzada" 9
menuText S CrosstabHelpIndex "Ãndice de la ayuda" 0
translate S SetFilter {Poner filtro}
translate S AddToFilter {AÃ±adir al filtro}
translate S Swiss {Suizo}
translate S Category {CategorÃ­a}

# Opening report window menus:
menuText S OprepFile "Archivo" 0
menuText S OprepFileText "Imprimir en archivo texto..." 20
menuText S OprepFileHtml "Imprimir en archivo HTML..." 20
menuText S OprepFileOptions "Opciones..." 0
menuText S OprepFileClose "Cerrar ventana del informe de la apertura" 0
menuText S OprepFavorites "Favoritos" 1
menuText S OprepFavoritesAdd "AÃ±adir informe..." 0
menuText S OprepFavoritesEdit "Editar informe favorito..." 0
menuText S OprepFavoritesGenerate "Generar informe..." 0
menuText S OprepHelp "Ayuda" 1
menuText S OprepHelpReport "Ayuda del informe de la apertura" 11
menuText S OprepHelpIndex "Ãndice de la ayuda" 0

# Header search:
translate S HeaderSearch {BÃºsqueda por encabezamiento}
translate S EndSideToMove {Bando a mover al final de la partida}
translate S GamesWithNoECO {Â¿Partidas sin ECO?}
translate S GameLength {DuraciÃ³n:}
translate S FindGamesWith {Encontrar partidas con}
translate S StdStart {Inicio estÃ¡ndar}
translate S Promotions {Promociones}
translate S Comments {Comentarios}
translate S Variations {Variaciones}
translate S Annotations {Anotaciones}
translate S DeleteFlag {SeÃ±al de borrado}
translate S WhiteOpFlag {Apertura de las blancas}
translate S BlackOpFlag {Apertura de las negras}
translate S MiddlegameFlag {Mediojuego}
translate S EndgameFlag {Finales}
translate S NoveltyFlag {Novedad}
translate S PawnFlag {Estructura de peones}
translate S TacticsFlag {TÃ¡cticas}
translate S QsideFlag {Juego del lado de dama}
translate S KsideFlag {Juego del lado de rey}
translate S BrilliancyFlag {Genialidad}
translate S BlunderFlag {Error}
translate S UserFlag {Usuario}
translate S PgnContains {PGN contiene texto}
translate S PgnTag {Etiqueta}
translate S TagContains {contiene}
translate S Variant {Variante}
translate S Annotator {Comentarista}
translate S Cmnts {SÃ³lo partidas comentadas}

# Game list window:
translate S GlistNumber {NÃºmero}
translate S GlistWhite {Blancas}
translate S GlistBlack {Negras}
translate S GlistWElo {B-Elo}
translate S GlistBElo {N-Elo}
translate S GlistEvent {Evento}
translate S GlistSite {Lugar}
translate S GlistRound {Ronda}
translate S GlistDate {Fecha}
translate S GlistYear {AÃ±o}
translate S GlistEDate {Evento-Fecha}
translate S GlistResult {Resultado}
translate S GlistLength {Longitud}
translate S GlistCountry {PaÃ­s}
translate S GlistECO {ECO}
translate S GlistOpening {Apertura}
translate S GlistEndMaterial {Material final}
translate S GlistDeleted {Borrado}
translate S GlistFlags {SeÃ±al}
translate S GlistVars {Variaciones}
translate S GlistComments {Comentarios}
translate S GlistAnnos {Anotaciones}
translate S GlistStart {Inicio}
translate S GlistGameNumber {NÃºmero de partida}
translate S GlistAverageElo {Elo promedio}
translate S GlistRating {ClasificaciÃ³n}
translate S GlistFindText {Encontrar texto}
translate S GlistMoveField {Movimiento}
translate S GlistEditField {Configurar}
translate S GlistAddField {AÃ±adir}
translate S GlistDeleteField {Quitar}
translate S GlistWidth {Anchura}
translate S GlistAlign {Alinear}
translate S GlistAlignL {Alinear: izquierda}
translate S GlistAlignR {Alinear: derecha}
translate S GlistAlignC {Alinear: centro}
translate S GlistColor {Color}
translate S GlistSep {Separador}
translate S GlistCurrentSep {-- Actual --}
translate S GlistNewSort {Nuevo}
translate S GlistAddToSort {Agregar}

# base sorting
translate S GsortSort {Clasificar...}
translate S GsortDate {Fecha}
translate S GsortYear {AÃ±o}
translate S GsortEvent {Evento}
translate S GsortSite {Sitio}
translate S GsortRound {Redondo}
translate S GsortWhiteName {Nombre blanco}
translate S GsortBlackName {Nombre negro}
translate S GsortECO {ECO}
translate S GsortResult {Resultado}
translate S GsortMoveCount {Conteo de movimientos}
translate S GsortAverageElo {Elo promedio}
translate S GsortCountry {PaÃ­s}
translate S GsortDeleted {Eliminado}
translate S GsortEventDate {Fecha del evento}
translate S GsortWhiteElo {Elo Blanco}
translate S GsortBlackElo {Elo Negro}
translate S GsortComments {Comentarios}
translate S GsortVariations {Variaciones}
translate S GsortNAGs {NAG}
translate S GsortAscending {Ascendente}
translate S GsortDescending {Descendente}
translate S GsortAdd {Agregar}
translate S GsortStore {Almacenar}
translate S GsortLoad {Carga}

# menu shown with right mouse button down on game list.
translate S GlistRemoveThisGameFromFilter  {Quita esta partida del filtro}
translate S GlistRemoveGameAndAboveFromFilter  {Quita esta partida y todas las de arriba del filtro}
translate S GlistRemoveGameAndBelowFromFilter  {Quita esta partida y todas las de abajo del filtro}
translate S GlistDeleteGame {Elimina/recupera esta partida de la base}
translate S GlistDeleteAllGames {Elimina todas las partidas de la base que aparecen en el filtro}
translate S GlistUndeleteAllGames {Recupera todas las partidas borradas de la base que aparecen en el filtro}
translate S GlistMergeGameInBase {Fusionar la partida en otra base} 

# Maintenance window:
translate S DatabaseName {Nombre de la base:}
translate S TypeIcon {Tipo de icono:}
translate S NumOfGames {Partidas:}
translate S NumDeletedGames {Partidas borradas:}
translate S NumFilterGames {Partidas en el filtro:}
translate S YearRange {Rango de aÃ±os:}
translate S RatingRange {Rango de Elo:}
translate S Description {DescripciÃ³n}
translate S Flag {SeÃ±al}
translate S CustomFlags {SeÃ±ales personalizadas}
translate S DeleteCurrent {Borrar partida actual}
translate S DeleteFilter {Borrar partidas filtradas}
translate S DeleteAll {Borrar todas las partidas}
translate S UndeleteCurrent {No borrar partida actual}
translate S UndeleteFilter {No borrar partidas filtradas}
translate S UndeleteAll {No borrar todas las partidas}
translate S DeleteTwins {Borrar partidas dobles}
translate S MarkCurrent {Marcar partida actual}
translate S MarkFilter {Marcar partidas filtradas}
translate S MarkAll {Marcar todas las partidas}
translate S UnmarkCurrent {No marcar partida actual}
translate S UnmarkFilter {No marcar partidas filtradas}
translate S UnmarkAll {No marcar todas las partidas}
translate S Spellchecking {RevisiÃ³n ortogrÃ¡fica}
translate S Players {Jugadores}
translate S Events {Eventos}
translate S Sites {Lugares}
translate S Rounds {Rondas}
translate S DatabaseOps {Operaciones con la base de datos}
translate S ReclassifyGames {Reclasificar partidas por ECO...}
translate S CompactDatabase {Compactar base de datos}
translate S SortDatabase {Ordenar base de datos}
translate S AddEloRatings {AÃ±adir clasificaciÃ³n Elo}
translate S AutoloadGame {Autocargar nÃºmero de partida}
translate S StripTags {Quitar etiquetas PGN}
translate S StripTag {Quitar etiquetas}
translate S Cleaner {MultiHerramienta}
translate S CleanerHelp {
Scid ejecutarÃ¡, en la actual base de datos, todas las acciones de mantenimiento
que selecciones de la siguiente lista.

Se aplicarÃ¡ el estado actual en la clasificaciÃ³n ECO y el diÃ¡logo de borrado de
dobles si seleccionas esas funciones.
}
translate S CleanerConfirm {
Â¡Una vez que la MultiHerramienta de mantenimiento se inicia no puede ser interrumpida!

Esto puede tomar mucho tiempo en una base de datos grande, dependiendo de las funciones que hallas seleccionado y su estado actual.

Â¿EstÃ¡s seguro de querer comenzar las funciones de mantenimiento que has seleccionado?
}
# Twinchecker
translate S TwinCheckUndelete {Pulsar "u" para no borrar ninguna (undelete)}
translate S TwinCheckprevPair {Pareja anterior}
translate S TwinChecknextPair {Pareja siguiente}
translate S TwinChecker {Scid: Verificar partidas dobles}
translate S TwinCheckTournament {Partidas en torneo:}
translate S TwinCheckNoTwin {No doble  }
translate S TwinCheckNoTwinfound {No fueron detectados dobles para esta partida.\nPara mostrar dobles usando esta ventana debes usar la funciÃ³n Borrar partidas dobles..." }
translate S TwinCheckTag {Compartir etiquetas...}
translate S TwinCheckFound1 {Scid encontrÃ³ $result partidas dobles}
translate S TwinCheckFound2 {y pone pone sus banderas de borrado}
translate S TwinCheckNoDelete {No hay partidas en esta base para borrar.}
translate S TwinCriteria1 {Tus parÃ¡metros para encontrar partidas dobles potencialmente pueden causar partidas no-dobles con movimientos similares a ser marcadas como dobles.}
translate S TwinCriteria2 {Es recomendable que si elijes "No" para "algunos movimientos", elijas "SÃ­" para los parÃ¡metros colores, eventos, lugar, ronda, aÃ±o y mes.\nÂ¿Quieres continuar y borrar partidas dobles en cualquier caso?}
translate S TwinCriteria3 {Es recomendable que especifiques "SÃ­" para al menos dos parÃ¡metros de "mismo lugar", "misma ronda" y "mismo aÃ±o".\nÂ¿Quieres continuar y borrar dobles en todo caso?}
translate S TwinCriteriaConfirm {Scid: Confirmar parÃ¡metros para partidas dobles}
translate S TwinChangeTag "Cambiar las siguientes etiquetas de las:\n\n partidas"
translate S AllocRatingDescription "Este comando usarÃ¡ el actual fichero SpellCheck para aÃ±adir  puntuaciones ELO y partidas en esta base. Donde quiera que un jugador no tenga puntuaciÃ³n pero su puntuaciÃ³n en el listado del  fichero  spellcheck , su puntuaciÃ³n serÃ¡ aÃ±adida."
translate S RatingOverride "Â¿Sobreescribir puntuaciones existentes no nulas?"
translate S AddRatings "AÃ±adir puntuaciones a:"
translate S AddedRatings {Scid aÃ±adiÃ³ $r puntuaciones Elo en $g partidas.}

#Bookmark editor
translate S NewSubmenu "Nuevo submenu"

# Comment editor:
translate S AnnotationSymbols  {SÃ­mbolos de anotaciÃ³n:}
translate S Comment {Comentario:}
translate S InsertMark {Insertar marca}
translate S InsertMarkHelp {
Insertar/quitar marca: Selecciona color, tipo, casilla.
Insertar/quitar flecha: BotÃ³n derecho sobre dos casillas.
}

# Nag buttons in comment editor:
translate S GoodMove {Buena jugada}
translate S PoorMove {Mala jugada}
translate S ExcellentMove {Jugada excelente}
translate S Blunder {Error}
translate S InterestingMove {Jugada interesante}
translate S DubiousMove {Jugada dudosa}
translate S WhiteDecisiveAdvantage {Las blancas tienen decisiva ventaja}
translate S BlackDecisiveAdvantage {Las negras tienen decisiva ventaja}
translate S WhiteClearAdvantage {Las blancas tienen clara ventaja}
translate S BlackClearAdvantage {Las negras tienen clara ventaja}
translate S WhiteSlightAdvantage {Las blancas tienen ligera ventaja}
translate S BlackSlightAdvantage {Las negras tienen ligera ventaja}
translate S WhiteCrushing {Las blancas tienen una ventaja aplastante}
translate S BlackCrushing {Las negras tienen una ventaja aplastante}
translate S Equality {Igualdad}
translate S Unclear {Incierto}
translate S Diagram {Diagrama}

# Board search:
translate S BoardSearch {Tablero de bÃºsqueda}
translate S FilterOperation {OperaciÃ³n en filtro actual:}
translate S FilterAnd {Y (Restringir filtro)}
translate S FilterOr {O (AÃ±adir al filtro)}
translate S FilterIgnore {IGNORAR (Poner a cero el filtro)}
translate S SearchType {Tipo de bÃºsqueda:}
translate S SearchBoardExact {PosiciÃ³n exacta (todas las piezas en las mismas casillas)}
translate S SearchBoardPawns {Peones (igual material, todos los peones en las mismas casillas)}
translate S SearchBoardFiles {Columnas (igual material, todos los peones en las mismas columnas)}
translate S SearchBoardAny {Cualquiera (igual material, peones y piezas en cualquier parte)}
translate S SearchInRefDatabase {BÃºsqueda en la base de referencia}
translate S LookInVars {Mirar en variaciones}

# Material search:
translate S MaterialSearch {BÃºsqueda de material}
translate S Material {Material}
translate S Patterns {Patrones}
translate S Zero {Cero}
translate S Any {Cualquiera}
translate S CurrentBoard {Tablero actual}
translate S CommonEndings {Finales comunes}
translate S CommonPatterns {Patrones comunes}
translate S MaterialDiff {Diferencia de material}
translate S squares {casillas}
translate S SameColor {Igual color}
translate S OppColor {Color opuesto}
translate S Either {Cualquiera}
translate S MoveNumberRange {Rango de nÃºmero de movimientos}
translate S MatchForAtLeast {Encuentro de al menos}
translate S HalfMoves {medios movimientos}

# Common endings in material search:
translate S EndingPawns {Finales de peones}
translate S EndingRookVsPawns {Torre vs. peon(es)}
translate S EndingRookPawnVsRook {Torre y un peÃ³n vs. torre}
translate S EndingRookPawnsVsRook {Torre y peon(es) vs. torre}
translate S EndingRooks {Finales de torre vs. torre}
translate S EndingRooksPassedA {Finales de torre vs. torre con peÃ³n pasado}
translate S EndingRooksDouble {Finales de dos torres}
translate S EndingBishops {Finales de alfil vs. alfil}
translate S EndingBishopVsKnight {Finales de alfil vs. caballo}
translate S EndingKnights {Finales de caballo vs. caballo}
translate S EndingQueens {Finales de dama vs. dama}
translate S EndingQueenPawnVsQueen {Dama y un peÃ³n vs. dama}
translate S BishopPairVsKnightPair {Medio juego de dos alfiles vs. dos caballos}

# Common patterns in material search:
translate S PatternWhiteIQP {PDA blanco}
translate S PatternWhiteIQPBreakE6 {PDA blanco: d4-d5 ruptura vs. e6}
translate S PatternWhiteIQPBreakC6 {PDA blanco: d4-d5 ruptura vs. c6}
translate S PatternBlackIQP {PDA negro}
translate S PatternWhiteBlackIQP {PDA blanco vs. PDA negro}
translate S PatternCoupleC3D4 {Pareja de peones aislados blancos c3+d4}
translate S PatternHangingC5D5 {Peones colgantes negros en c5 y d5}
translate S PatternMaroczy {Centro Maroczy (con peones en c4 y e4)}
translate S PatternRookSacC3 {Sacrificio de torre en c3}
translate S PatternKc1Kg8 {O-O-O vs. O-O (Rc1 vs. Rg8)}
translate S PatternKg1Kc8 {O-O vs. O-O-O (Rg1 vs. Rc8)}
translate S PatternLightFian {Fianchettos de casillas claras (Alfil-g2 vs. Alfil-b7)}
translate S PatternDarkFian {Fianchettos de casillas oscuras (Alfil-b2 vs. Alfil-g7)}
translate S PatternFourFian {Cuatro Fianchettos (Alfiles en b2,g2,b7,g7)}

# Game saving:
translate S Today {Hoy}
translate S ClassifyGame {Clasificar partida}

# Setup position:
translate S EmptyBoard {Tablero vacÃ­o}
translate S InitialBoard {Tablero inicial}
translate S SideToMove {Lado que mueve}
translate S MoveNumber {Movimiento nÃºmero}
translate S Castling {Enroque}
translate S EnPassantFile {Columna al paso}
translate S ClearFen {Quitar FEN}
translate S PasteFen {Pegar FEN}

translate S SaveAndContinue {Salvar (grabar) y continuar}
translate S DiscardChangesAndContinue {Descartar \n cambios y continuar}
translate S GoBack {Volver atrÃ¡s}

# Replace move dialog:
translate S ReplaceMove {Reemplazar movimiento}
translate S AddNewVar {AÃ±adir nueva variaciÃ³n}
translate S NewMainLine {Nueva lÃ­nea principal}
translate S ReplaceMoveMessage {Ya existe un movimiento.

Puedes reemplazarlo, descartando todos los movimientos posteriores, o aÃ±adirlo como una nueva variaciÃ³n.

(Puedes evitar seguir viendo este mensaje en el futuro desactivando la opciÃ³n "Preguntar antes de reemplazar movimientos" en el menÃº Opciones: Movimientos.)}

# Make database read-only dialog:
translate S ReadOnlyDialog {Si haces que esta base de datos sea de sÃ³lo lectura no se permitirÃ¡n hacer cambios. No se podrÃ¡n guardar o reemplazar partidas y no se podrÃ¡n alterar las seÃ±ales de borrada. Cualquier ordenaciÃ³n o clasificaciÃ³n por ECO serÃ¡ temporal.

Puedes hacer fÃ¡cilmente escribible la base de datos otra vez cerrÃ¡ndola y abriÃ©ndola.

Â¿Realmente quieres hacer que esta base de datos sea de sÃ³lo lectura?}

# Clear game dialog:
translate S ClearGameDialog {Esta partida ha sido cambiada.

Â¿Realmente quieres continuar y eliminar los cambios hechos en ella?
}

# Exit dialog:
translate S ExitDialog {Â¿Realmente quieres salir de Scid?}
translate S ExitUnsaved {La siguiente base de datos tiene cambios en partidas no guardados. Si sales ahora se perderÃ¡n estos cambios.}

# Import window:
translate S PasteCurrentGame {Pegar partida actual}
translate S ImportHelp1 \
  {Introducir o pegar una partida en formato PGN en el marco superior.}
translate S ImportHelp2 \
  {Cualquier error importando la partida serÃ¡ mostrado aquÃ­.}
translate S OverwriteExistingMoves {Â¿Sobreescribir movimientos existentes?}

# ECO Browser:
translate S ECOAllSections {todas las divisiones ECO}
translate S ECOSection {divisiÃ³n ECO}
translate S ECOSummary {Resumen de}
translate S ECOFrequency {Frecuencia de los subcÃ³digos para}

# Opening Report:
translate S OprepTitle {Informe de la apertura}
translate S OprepReport {Informe}
translate S OprepGenerated {Generado por}
translate S OprepStatsHist {EstadÃ­sticas e historia}
translate S OprepStats {EstadÃ­sticas}
translate S OprepStatAll {Todas las partidas referidas}
translate S OprepStatBoth {Ambos con Elo}
translate S OprepStatSince {Desde}
translate S OprepOldest {Partidas mÃ¡s antiguas}
translate S OprepNewest {Partidas mÃ¡s nuevas}
translate S OprepPopular {Popularidad actual}
translate S OprepFreqAll {Frecuencia durante todos los aÃ±os: }
translate S OprepFreq1   {Desde el Ãºltimo aÃ±o hasta hoy:     }
translate S OprepFreq5   {En los Ãºltimos 5 aÃ±os hasta hoy:   }
translate S OprepFreq10  {En los Ãºltimos 10 aÃ±os hasta hoy:  }
translate S OprepEvery {una vez cada %u partidas}
translate S OprepUp {sube un %u%s respecto al total de aÃ±os}
translate S OprepDown {baja un %u%s respecto al total de aÃ±os}
translate S OprepSame {no hay cambios respecto al total de aÃ±os}
translate S OprepMostFrequent {Jugadores mÃ¡s frecuentes}
translate S OprepMostFrequentOpponents {Rivales mÃ¡s frecuentes}
translate S OprepRatingsPerf {Elo y rendimiento}
translate S OprepAvgPerf {Promedio de Elo y rendimiento}
translate S OprepWRating {Elo de las blancas}
translate S OprepBRating {Elo de las negras}
translate S OprepWPerf {Rendimiento de las blancas}
translate S OprepBPerf {Rendimiento de las negras}
translate S OprepHighRating {Partida con el mayor promedio de Elo}
translate S OprepTrends {Tendencias de resultados}
translate S OprepResults {Resultado de duraciones y frecuencias}
translate S OprepLength {DuraciÃ³n de la partida}
translate S OprepFrequency {Frecuencia}
translate S OprepWWins {Blancas ganan: }
translate S OprepBWins {Negras ganan:  }
translate S OprepDraws {Tablas:        }
translate S OprepWholeDB {en el conjunto de la base de datos}
translate S OprepShortest {Triunfos mÃ¡s cortos}
translate S OprepMovesThemes {Movimientos y temas}
translate S OprepMoveOrders {LÃ­neas de movimientos que alcanzan la posiciÃ³n del informe}
translate S OprepMoveOrdersOne \
  {SÃ³lo hay una lÃ­nea de movimientos que alcanza esta posiciÃ³n:}
translate S OprepMoveOrdersAll \
  {Hay %u lÃ­neas de movimiento que alcanzan esta posiciÃ³n:}
translate S OprepMoveOrdersMany \
  {Hay %u lÃ­neas de movimiento que alcanzan esta posiciÃ³n. Las %u mÃ¡s comunes son:}
translate S OprepMovesFrom {Movimientos desde la posiciÃ³n del informe}
translate S OprepMostFrequentEcoCodes {Aperturas mÃ¡s frecuentes}
translate S OprepThemes {Temas posicionales}
translate S OprepThemeDescription {Frecuencia de los temas en las primeras %u jugadas de cada partida}
translate S OprepThemeSameCastling {Enroque al mismo lado}
translate S OprepThemeOppCastling {Enroque en lados opuestos}
translate S OprepThemeNoCastling {Ambos reyes no enrocados}
translate S OprepThemeKPawnStorm {Avanzada de los peones del rey}
translate S OprepThemeQueenswap {Damas intercambiadas}
translate S OprepThemeWIQP {PeÃ³n de dama aislado de las blancas}
translate S OprepThemeBIQP {PeÃ³n de dama aislado de las negras}
translate S OprepThemeWP567 {Peones blancos en 5/6/7Âª fila}
translate S OprepThemeBP234 {Peones negros en 2/3/4Âª fila}
translate S OprepThemeOpenCDE {Columnas c/d/e abiertas}
translate S OprepTheme1BishopPair {Un lado tiene los dos alfiles}
translate S OprepEndgames {Finales}
translate S OprepReportGames {Informe de partidas}
translate S OprepAllGames {Todas las partidas}
translate S OprepEndClass {Tipos de finales segÃºn la Ãºltima posiciÃ³n de las partidas}
translate S OprepTheoryTable {Tabla teÃ³rica}
translate S OprepTableComment {Generado a partir de las %u partidas con mejor Elo.}
translate S OprepExtraMoves {AnotaciÃ³n extra de movimientos en la tabla teÃ³rica}
translate S OprepMaxGames {MÃ¡ximas partidas en la tabla teÃ³rica}
translate S OprepMergeMoves {Límite de movimiento para juegos fusionados}
translate S OprepMergeUnique {Fusionar solo juegos únicos}
translate S OprepViewHTML {Ver HTML}

# Player Report:
translate S PReportTitle {Informe del jugador}
translate S PReportColorWhite {con las piezas blancas}
translate S PReportColorBlack {con las piezas negras}
translate S PReportMoves {%s despuÃ©s}
translate S PReportOpenings {Aperturas}
translate S PReportClipbase {Vaciar portapapeles y copiar las partidas}

# Piece Tracker window:
translate S TrackerSelectSingle {El botÃ³n izquierdo selecciona esta pieza.}
translate S TrackerSelectPair {El botÃ³n izquierdo selecciona esta pieza; el botÃ³n derecho tambiÃ©n selecciona su hermana.}
translate S TrackerSelectPawn {El botÃ³n izquierdo selecciona este peÃ³n; el botÃ³n derecho selecciona los ocho peones.}
translate S TrackerStat {EstadÃ­stica}
translate S TrackerGames {% de partidas con movimiento a esta casilla}
translate S TrackerTime {% de tiempo en esta casilla}
translate S TrackerMoves {Movimientos}
translate S TrackerMovesStart {Escribe el nÃºmero del movimiento desde donde debe empezar el rastreo.}
translate S TrackerMovesStop {Escribe el nÃºmero del movimiento donde debe parar el rastreo.}

# Game selection dialogs:
translate S SelectAllGames {Todas las partidas de la base de datos}
translate S SelectFilterGames {SÃ³lo las partidas filtradas}
translate S SelectTournamentGames {SÃ³lo las partidas del actual torneo}
translate S SelectOlderGames {SÃ³lo partidas antiguas}

# Delete Twins window:
translate S TwinsNote {Para ser dobles, dos partidas deben de tener al menos los mismos dos jugadores y los criterios que fijes debajo. Cuando un par de dobles es encontrado, la partida mÃ¡s corta es borrada. Sugerencia: es mejor hacer la correcciÃ³n ortogrÃ¡fica de la base de datos antes de iniciar el borrado de dobles, porque esto mejora su detecciÃ³n.}
translate S TwinsCriteria {Criterios: Las partidas dobles deben tener...}
translate S TwinsWhich {Partidas a examinar}
translate S TwinsColors {Â¿Jugadores con igual color?}
translate S TwinsEvent {Â¿Mismo evento?}
translate S TwinsSite {Â¿Mismo sitio?}
translate S TwinsRound {Â¿Misma ronda?}
translate S TwinsYear {Â¿Mismo aÃ±o?}
translate S TwinsMonth {Â¿Mismo mes?}
translate S TwinsDay {Â¿Mismo dÃ­a?}
translate S TwinsResult {Â¿Mismo resultado?}
translate S TwinsECO {Â¿Mismo cÃ³digo ECO?}
translate S TwinsMoves {Â¿Mismos movimientos?}
translate S TwinsPlayers {Comparando nombres de jugadores:}
translate S TwinsPlayersExact {Encuentro exacto}
translate S TwinsPlayersPrefix {SÃ³lo las primeras 4 letras}
translate S TwinsWhen {Cuando se borren partidas dobles}
translate S TwinsSkipShort {Â¿Ignorar todas las partidas con menos de cinco movimientos?}
translate S TwinsUndelete {Â¿Quitar marcas de borrado primero?}
translate S TwinsSetFilter {Â¿Poner filtro a todas las partidas borradas?}
translate S TwinsComments {Â¿Saltar siempre partidas con comentarios?}
translate S TwinsVars {Â¿Saltar siempre partidas con variaciones?}
translate S TwinsDeleteWhich {QuÃ© partida borrar:}
translate S TwinsDeleteShorter {Partida mÃ¡s corta}
translate S TwinsDeleteOlder {NÃºmero de partida menor}
translate S TwinsDeleteNewer {NÃºmero de partida mayor}
translate S TwinsDelete {Borrar partidas}

# Name editor window:
translate S NameEditType {Tipo de dato a editar}
translate S NameEditSelect {Partidas a editar}
translate S NameEditReplace {Reemplazar}
translate S NameEditWith {con}
translate S NameEditMatches {Encuentros: Presionar Ctrl+1 a Ctrl+9 para seleccionarlo}

# Check games window:
translate S CheckGames {Revisar partidas}
translate S CheckGamesWhich {Revisar partidas}
translate S CheckAll {Todas las partidas}
translate S CheckSelectFilterGames {SÃ³lo las partidas del filtro}

# Classify window:
translate S Classify {Clasificar}
translate S ClassifyWhich {Clasificar por cÃ³digos ECO}
translate S ClassifyAll {Todas las partidas (sobreescribir cÃ³digo ECO)}
translate S ClassifyYear {Todas las partidas jugadas en el Ãºltimo aÃ±o}
translate S ClassifyMonth {Todas las partidas jugadas en el Ãºltimo mes}
translate S ClassifyNew {SÃ³lo las partidas todavÃ­a sin cÃ³digo ECO}
translate S ClassifyCodes {CÃ³digo ECO a usar}
translate S ClassifyBasic {SÃ³lo cÃ³digo bÃ¡sico ("B12", ...)}
translate S ClassifyExtended {Extensiones Scid ("B12j", ...)}

# Compaction:
translate S NameFile {Archivo de nombres}
translate S GameFile {Archivo de partidas}
translate S Names {Nombres}
translate S Unused {No usado}
translate S SizeKb {TamaÃ±o (kb)}
translate S CurrentState {Estado actual}
translate S AfterCompaction {DespuÃ©s de la compactaciÃ³n}
translate S CompactNames {Compactar archivo de nombres}
translate S CompactGames {Compactar archivo de partidas}
translate S NoUnusedNames "No hay nombres sin usar, por tanto el nombre del fichero estÃ¡ ya totalmente compactado."
translate S NoUnusedGames "El fichero ya estÃ¡ totalmente compactado."
translate S GameFileCompacted {El fichero de partidas para la base de datos fue compactado.}

# Sorting:
translate S SortCriteria {Criterio}
translate S AddCriteria {AÃ±adir criterio}
translate S CommonSorts {Ordenaciones comunes}
translate S Sort {Ordenar}

# Exporting:
translate S AddToExistingFile {Â¿AÃ±adir partidas a un archivo existente?}
translate S ExportComments {Â¿Exportar comentarios?}
translate S ExportVariations {Â¿Exportar variaciones?}
translate S IndentComments {Â¿Sangrar comentarios?}
translate S IndentVariations {Â¿Sangrar variaciones?}
translate S ExportColumnStyle {Â¿Estilo de columna (un movimiento por lÃ­nea)?}
translate S ExportSymbolStyle {Estilo de anotaciÃ³n simbÃ³lico:}
translate S ExportStripMarks {Â¿Quitar marca de cÃ³digos de casilla/flecha de los comentarios?}

# Goto game/move dialogs:
translate S LoadGameNumber {Escribe el nÃºmero de la partida a cargar:}
translate S GotoMoveNumber {Ir al movimiento nÃºmero:}

# Copy games dialog:
translate S CopyAllGames {Copiar todos los juegos a}
translate S CopyGames {Copiar partidas}
translate S CopyConfirm {
 Realmente deseas copiar las [::utils::thousands $nGamesToCopy] partidas fitradas
 de la base de datos "$fromName"
 a la base de datos "$targetName"?
}
translate S CopyErr {No se pueden copiar las partidas}
translate S CopyErrSource {la base de datos fuente}
translate S CopyErrTarget {la base de datos de destino}
translate S CopyErrNoGames {no tiene partidas en su filtro}
translate S CopyErrReadOnly {es sÃ³lo de lectura}
translate S CopyErrNotOpen {no estÃ¡ abierta}

# Colors:
translate S LightSquares {Casillas claras}
translate S DarkSquares {Casillas oscuras}
translate S SelectedSquares {Casillas seleccionadas}
translate S SuggestedSquares {Casillas de movimiento sugerido}
translate S WhitePieces {Piezas blancas}
translate S BlackPieces {Piezas negras}
translate S WhiteBorder {Borde blancas}
translate S BlackBorder {Borde negras}

# Novelty window:
translate S FindNovelty {Encontrar novedad}
translate S Novelty {Novedad}
translate S NoveltyInterrupt {Busqueda de novedades interrumpida}
translate S NoveltyNone {Ninguna novedad encontrada para esta partida}
translate S NoveltyHelp {
Scid encontrarÃ¡ el primer movimiento de la actual partida que alcanza una posiciÃ³n no encontrada en la base de datos seleccionada o en el libro de aperturas ECO.
}

# Sounds configuration:
translate S SoundsFolder {Directorio de los archivos de sonido}
translate S SoundsFolderHelp {El directorio debe contener los archivos King.wav, a.wav, 1.wav, etc.}
translate S SoundsAnnounceOptions {Opciones de anunciamiento de movimientos}
translate S SoundsAnnounceNew {Anunciar nuevos movimientos cuando sean hechos}
translate S SoundsMoveSoundOnly {Mover solo sonido (desactivar anuncios)}
translate S SoundsAnnounceForward {Anunciar movimientos cuando avancemos un movimiento}
translate S SoundsAnnounceBack {Anunciar movimiento cuando rectifiquemos o retrocedamos una jugada}
translate S SoundsSoundDisabled {Scid no pudo encontrar el paquete de audio de Snack al inicio.\nEl sonido estÃ¡ desactivado.}

# Upgrading databases:
translate S Upgrading {ActualizaciÃ³n}
translate S ConfirmOpenNew {
Este es un formato de base de datos antiguo (Scid 3) que no puede ser abierto con Scid 4, pero ya se ha creado una versiÃ³n de formato nuevo (Scid 4).

Â¿Quieres abrir la versiÃ³n de formato nuevo de la base de datos?
}
translate S ConfirmUpgrade {
Esta es una base de datos en un formato antiguo (Scid 3). Se debe crear una versiÃ³n de formato nuevo de base de datos antes de poder ser usada en Scid 4.

La actualizaciÃ³n crearÃ¡ una nueva versiÃ³n de la base de datos.

Esto puede tomar un tiempo, pero sÃ³lo es necesario hacerlo una vez. Puedes cancelar si toma demasiado tiempo.

Â¿Quieres actualizar esta base de datos ahora?
}

# Recent files options:
translate S RecentFilesMenu {NÃºmero de archivos recientes en el menÃº Archivo}
translate S RecentFilesExtra {NÃºmero de archivos recientes en submenÃº extra}

# My Player Names options:
translate S MyPlayerNamesDescription {
Escriba una lista de nombres de jugadores preferidos, un nombre por cada lÃ­nea. EstÃ¡n permitidos los comodines (por ejemplo "?" para un sÃ³lo caracter, "*" para varios caracteres).

Cada vez que carge una partida con un jugador de la lista se girarÃ¡ el tablero, si fuese necesario, para ver la partida desde la perspectiva del jugador.
}

#Coach
translate S showblunderexists {Mostrar metedura de pata}
translate S showblundervalue {Mostrar valor de la metedura de pata}
translate S showscore {Mostrar marcador}
translate S coachgame {Entrenador}
translate S configurecoachgame {Configurar entrenador}
translate S configuregame {ConfiguraciÃ³n de partida}
translate S Phalanxengine {Motor Phalanx}
translate S Coachengine {Motor entrenador}
translate S difficulty {Dificultad}
translate S hard {Duro}
translate S easy {FÃ¡cil}
translate S Playwith {Juega con}
translate S white {blancas}
translate S black {negras}
translate S both {ambos}
translate S Play {Jugar}
translate S Noblunder {Sin errores}
translate S blunder {Meteduras de pata}
translate S Noinfo {-- Sin informaciÃ³n --}
translate S PhalanxOrTogaMissing {Phalanx o Toga no encontrado}
translate S moveblunderthreshold {El movimiento es una metedura de pata si la pÃ©rdida de puntuaciÃ³n es mayor que }
translate S limitanalysis {Tiempo lÃ­mite para anÃ¡lisis del motor}
translate S seconds {segundos}
translate S Abort {Abortar}
translate S Resume {Reanudar}
translate S OutOfOpening {Fuera de apertura}
translate S NotFollowedLine {TÃº no sigues la lÃ­nea}
translate S DoYouWantContinue {Â¿Quieres continuar?}
translate S CoachIsWatching {Entrenador}
translate S Ponder {Pensar siempre (el motor)}
translate S LimitELO {Limitar fuerza Elo}
translate S DubiousMovePlayedTakeBack {Movimiento dudoso, Â¿quieres rectificar?}
translate S WeakMovePlayedTakeBack {Movimiento flojo, Â¿quieres rectificar ?}
translate S BadMovePlayedTakeBack {Movimiento malo, Â¿quieres rectificar ?}
translate S Iresign {Yo abandono}
translate S yourmoveisnotgood {tu movimiento no es bueno}
translate S EndOfVar {Fin de la variante}
translate S Openingtrainer {Entrenador de aperturas}
translate S DisplayCM {Muestra posibles movimientos}
translate S DisplayCMValue {Muestra valor de posibles movimientos}
translate S DisplayOpeningStats {Muestra estadÃ­sticas}
translate S ShowReport {Muestra informe}
translate S NumberOfGoodMovesPlayed {buenos movimientos jugados}
translate S NumberOfDubiousMovesPlayed {dudosos momientos jugados}
translate S NumberOfMovesPlayedNotInRepertoire {movimientos jugados fuera de repertorio}
translate S NumberOfTimesPositionEncountered {veces encontrada la posiciÃ³n}
translate S PlayerBestMove  {Permite Ãºnicamente movimientos mejores}
translate S OpponentBestMove {Oponente juega mejores movimientos}
translate S OnlyFlaggedLines {SÃ³lo lÃ­neas marcadas}
translate S resetStats {Reinicia estadÃ­sticas}
translate S Repertoiretrainingconfiguration {ConfiguraciÃ³n del repertorio de entrenamiento}
translate S Loadingrepertoire {Cargando repertorio}
translate S Movesloaded {Movimientos cargados}
translate S Repertoirenotfound {Repertorio no encontrado}
translate S Openfirstrepertoirewithtype {Abrir primero una base con icono/tipo de repertorio colocado en el lado derecho}
translate S Movenotinrepertoire {Movimiento no estÃ¡ en el repertorio}
translate S PositionsInRepertoire {Posiciones en repertorio}
translate S PositionsNotPlayed {Posiciones no jugadas}
translate S PositionsPlayed {Posiciones jugadas}
translate S Success {Ãxitos}
translate S DubiousMoves {Movimientos dudosos}
translate S OutOfRepertoire {Fuera de repertorio}
translate S ConfigureTactics {Configurar tÃ¡ctica}
translate S ResetScores {Reiniciar marcadores (puntuaciones)}
translate S LoadingBase {Cargando base}
translate S Tactics {TÃ¡cticas}
translate S ShowSolution {Mostrar soluciÃ³n}
translate S NextExercise {Ejercicio siguiente}
translate S PrevExercise {Ejercicio anterior}
translate S StopTraining {Parar entrenamiento}
translate S Next {Siguiente}
translate S ResettingScore {Reiniciando marcador}
translate S LoadingGame {Cargando partida}
translate S MateFound {Mate encontrado}
translate S BestSolutionNotFound {Â¡No fue encontrada la mejor soluciÃ³n!}
translate S MateNotFound {Mate no encontrado}
translate S ShorterMateExists {Esiste un mate mÃ¡s corto}
translate S ScorePlayed {Marcador jugado}
translate S Expected {Esperado}
translate S ChooseTrainingBase {Elegir base de entrenamiento}
translate S Thinking {Pensando}
translate S AnalyzeDone {AnÃ¡lisis hecho}
translate S WinWonGame {Gana la partida ganada}
translate S Lines {LÃ­neas}
translate S ConfigureUCIengine {Configurar motor UCI}
translate S SpecificOpening {Apertura especÃ­fica}
translate S StartNewGame {Empezar partida nueva}
translate S FixedLevel {Nivel fijado}
translate S Opening {Abriendo}
translate S RandomLevel {Nivel aleatorio}
translate S StartFromCurrentPosition {Empezar desde la posiciÃ³n actual}
translate S FixedDepth {Profundidad fija}
translate S Nodes {Nodos} 
translate S Depth {Profundidad}
translate S Time {Tiempo} 
translate S SecondsPerMove {Segundos por movimiento}
translate S Engine {Motor}
translate S TimeMode {Modo de tiempo}
translate S TimeBonus {Tiempo + bonus}
translate S TimeMin {min}
translate S TimeSec {seg}
translate S AllExercisesDone {Todos los ejercicios hechos}
translate S MoveOutOfBook {Movimiento fuera del libro}
translate S LastBookMove {Ãltimo movimiento del libro}
translate S AnnotateSeveralGames {Anotar las partidas\ndesde la actual hasta la partida: }
translate S FindOpeningErrors {Encontrar errores en los primeros }
translate S MarkTacticalExercises {Marca ejercicios tÃ¡cticos}
translate S UseBook {Usar libro de aperturas (Book)}
translate S MultiPV {Variantes mÃºltiples}
translate S Hash {Memoria Hash}
translate S OwnBook {Usar libro (book) del motor}
translate S BookFile {Libro de aperturas}
translate S AnnotateVariations {Anotar variantes}
translate S ShortAnnotations {Anotaciones cortas}
translate S addAnnotatorTag {AÃ±adir etiqueta de anotador}
translate S AddScoreToShortAnnotations {AÃ±adir puntuaciÃ³n para anotaciones cortas}
translate S Export {Exportar}
translate S BookPartiallyLoaded {Libro parcialmente cargado}
translate S Calvar {CÃ¡lculo de variantes}
translate S ConfigureCalvar {ConfiguraciÃ³n}
# Opening names used in tacgame.tcl
translate S Reti {Apertura Reti}
translate S English {Apertura inglesa}
translate S d4Nf6Miscellaneous {1.d4 Cf6 variadas}
translate S Trompowsky {Apertura Trompowsky}
translate S Budapest {Gambito Budapest}
translate S OldIndian {Defensa india antigua}
translate S BenkoGambit {Gambito Benko}
translate S ModernBenoni {Defensa Benoni moderna}
translate S DutchDefence {Defensa holandesa}
translate S Scandinavian {Defensa escandinava}
translate S AlekhineDefence {Defensa Alekhine}
translate S Pirc {Defensa Pirc}
translate S CaroKann {Defensa Caro-Kann}
translate S CaroKannAdvance {Defensa Caro-Kann, variante del avance}
translate S Sicilian {Defensa Siciliana}
translate S SicilianAlapin {Defensa Siciliana, variante Alapin}
translate S SicilianClosed {Defensa Siciliana, variante cerrada}
translate S SicilianRauzer {Defensa Siciliana, variante Rauzer}
translate S SicilianDragon {Defensa Siciliana, variante del dragon}
translate S SicilianScheveningen {Defensa Siciliana, variante Scheveningen}
translate S SicilianNajdorf {Defensa Siciliana, Variante Najdorf}
translate S OpenGame {Apertura abierta}
translate S Vienna {Apertura Vienesa}
translate S KingsGambit {Gambito de rey}
translate S RussianGame {Partida rusa}
translate S ItalianTwoKnights {Apertura italiana, variante de los dos caballos}
translate S Spanish {Apertura espaÃ±ola}
translate S SpanishExchange {Apertura espaÃ±ola, variante del cambio}
translate S SpanishOpen {Apertura espaÃ±ola}
translate S SpanishClosed {Apertura espaÃ±ola, variante cerrada}
translate S FrenchDefence {Defensa francesa}
translate S FrenchAdvance {Defensa francesa, variante del avance}
translate S FrenchTarrasch {Defensa francesa, variante Tarrasch}
translate S FrenchWinawer {Defensa francesa, variante Winawer}
translate S FrenchExchange {Defensa francesa, variante del cambio}
translate S QueensPawn {Apertura de peÃ³n de dama}
translate S Slav {Defensa eslava}
translate S QGA {Gambito de dama aceptado}
translate S QGD {Gambito de dama declinado}
translate S QGDExchange {Gambito de dama declinado, variante del cambio}
translate S SemiSlav {Defensa semieslava del gambito de dama declinado}
translate S QGDwithBg5 {Gambito de dama declinado con Ag5}
translate S QGDOrthodox {Gambito de dama declinado, defensa ortodoxa}
translate S Grunfeld {Defensa GrÃ¼nfeld}
translate S GrunfeldExchange {Variante del cambio de la defensa GrÃ¼nfeld }
translate S GrunfeldRussian {Variante rusa de la defensa GrÃ¼nfeld}
translate S Catalan {Catalana}
translate S CatalanOpen {Apertura catalana}
translate S CatalanClosed {Apertura catalana, variante cerrada}
translate S QueensIndian {Defensa india de dama}
translate S NimzoIndian {Apertura Nimzo-India}
translate S NimzoIndianClassical {Apertura Nimzo-India clÃ¡sica}
translate S NimzoIndianRubinstein {Variante Rubinstein de la Nimzo-India}
translate S KingsIndian {India de rey}
translate S KingsIndianSamisch {Ataque SÃ¤mish de la india de rey}
translate S KingsIndianMainLine {LÃ­nea principal india de rey}

# FICS
translate S ConfigureFics {Configurar FICS}
translate S FICSGuest {AutentificaciÃ³n como invitado}
translate S FICSServerPort {Puerto del servidor}
translate S FICSServerAddress {DirecciÃ³n IP}
translate S FICSRefresh {Refrescar}
translate S FICSTimesealPort {Puerto Timeseal}
translate S FICSSilence {Silencio}
translate S FICSOffers {Ofertas}
translate S FICSConsole {Consola}
translate S FICSGames {Partidas}
translate S FICSUnobserve {Parar vistazo de partida}
translate S FICSProfile {Muestra tu historia y perfil}
translate S FICSRelayedGames {Partidas retransmitidas}
translate S FICSFindOpponent {Buscar oponente}
translate S FICSTakeback {Retrocede}
translate S FICSTakeback2 {Retrocede 2}
translate S FICSInitTime {Tiempo inicial (min)}
translate S FICSIncrement {Incremento (seg)}
translate S FICSRatedGame {Partida valorada}
translate S FICSAutoColour {automÃ¡tico}
translate S FICSManualConfirm {confirma manualmente}
translate S FICSFilterFormula {Filtrar con fÃ³rmula}
translate S FICSIssueSeek {Panel de retos}
translate S FICSChallenge {Retar}
translate S FICSAccept {aceptar}
translate S FICSDecline {rechazar}
translate S FICSColour {Color}
translate S FICSSend {enviar}
translate S FICSConnect {Conectar}
translate S FICSdefaultuservars {Usa valores por defecto}
translate S FICSObserveconfirm {Quieres observar la partida}
translate S FICSpremove {Habilitar premovimiento}
translate S FICSObserve {Observar}
translate S FICSRatedGames {Juegos clasificados}
translate S FICSUnratedGames {Juegos sin clasificar}
translate S FICSRated {Clasificado}
translate S FICSUnrated {Sin clasificar}
translate S FICSRegisteredPlayer {Solo jugador registrado}
translate S FICSFreePlayer {Solo jugador gratuito}
translate S FICSNetError {Error de red\No se puede conectar}

# Game review
translate S GameReview {RevisiÃ³n de partida}
translate S GameReviewTimeExtended {Tiempo extendido}
translate S GameReviewMargin {Margen de error}
translate S GameReviewAutoContinue {Autocontinuar cuando el movimiento es correcto}
translate S GameReviewReCalculate {Usar tiempo extendido}
translate S GameReviewAnalyzingMovePlayedDuringTheGame {Analizando movimiento jugado durante la partida}
translate S GameReviewAnalyzingThePosition {Analizando la posiciÃ³n}
translate S GameReviewEnterYourMove {Introduce tu movimiento}
translate S GameReviewCheckingYourMove {Comprobando tu movimiento}
translate S GameReviewYourMoveWasAnalyzed {Tu movimiento fue analizado}
translate S GameReviewYouPlayedSameMove {Jugaste el mismo movimiento que en la partida}
translate S GameReviewScoreOfYourMove {PuntuaciÃ³n de tu movimiento}
translate S GameReviewGameMoveScore {PuntuaciÃ³n del movimiento de la partida}
translate S GameReviewEngineScore {PuntuaciÃ³n del motor}
translate S GameReviewYouPlayedLikeTheEngine {TÃº jugaste como el motor}
translate S GameReviewNotEngineMoveButGoodMove {No es el movimiento del motor, pero es tambiÃ©n un buen movimiento}
translate S GameReviewMoveNotGood {Este movimiento no es bueno, la puntuaciÃ³n es }
translate S GameReviewMovesPlayedLike {Movimientos jugados como}
translate S GameReviewMovesPlayedEngine {Movimientos jugados como motor}

# Correspondence Chess Dialogs:
translate S CCDlgCGeneraloptions {Opciones generales}
translate S CCDlgLoginName  {Nombre de registro:}
translate S CCDlgPassword   {ContraseÃ±a:}
translate S CCDlgShowPassword {Mostrar contraseÃ±a}

# Connect Hardware dialogs
translate S ExtHWConfigConnection {Configurar hardware externo}
translate S ExtHWPort {Puerto}
translate S ExtHWEngineCmd {Comando del motor}
translate S ExtHWEngineParam {ParÃ¡metro del motor}
translate S ExtHWShowButton {Mostrar botÃ³n}
translate S ExtHWHardware {Hardware}
translate S ExtHWNovag {Novag Citrine}
translate S ExtHWInputEngine {Motor de entrada}
translate S ExtHWNoBoard {Sin tablero}
translate S NovagReferee {Ãrbitro}

# Input Engine dialogs
translate S IEConsole {Consola de entrada del motor}
translate S IESending {Movimientos enviados por}
translate S IESynchronise {Sincronizar}
translate S IERotate  {Rotar}
translate S IEUnableToStart {Imposible empezar con el motor de entrada:}

# Calculation of Variations
translate S DoneWithPosition {Terminado con la posiciÃ³n}

translate S Board {Tablero}
translate S showGameInfo {Mostrar informaciÃ³n de la partida}
translate S autoResizeBoard {TamaÃ±o automÃ¡tico del tablero}
translate S DockTop {Mover arriba}
translate S DockBottom {Mover abajo}
translate S DockLeft {Mover a la izquierda}
translate S DockRight {Mover a la derecha}
translate S Undock {Ventana flotante}

# Switcher window
translate S AboutDatabase {Acerca de esta base de datos}
translate S ChangeIcon {Cambiar icono...}
translate S NewGameListWindow {Nueva ventana de lista de juegos}
translate S LoadatStartup {Cargar al inicio}

# Gamelist window
translate S ShowHideDB {Mostrar/Ocultar bases de datos}
translate S ChangeFilter {Cambiar filtro}
translate S ChangeLayout {Cargar/Guardar/Cambiar criterios de clasificaciÃ³n y diseÃ±o de columnas}
translate S ShowHideStatistic {Mostrar/Ocultar estadÃ­sticas}
translate S BoardFilter {Mostrar solo juegos que coincidan con la posiciÃ³n actual del tablero}
translate S CopyGameTo {Copiar juego a}
translate S FindBar {Buscar barra}
translate S FindCurrentGame {Encuentra el juego actual}
translate S DeleteGame {eliminar juego}
translate S UndeleteGame {Recuperar juego}
translate S ResetSort {Restablecer clasificaciÃ³n}

translate S ConvertNullMove {Convertir movimientos nulos en comentarios}
translate S SetupBoard {Tablero de configuraciÃ³n}
translate S Rotate {Girar}
translate S SwitchColors {Cambiar colores}
translate S FlipBoard {Tablero giratorio}
translate S ImportPGN {Importar juego PGN}
translate S ImportingFiles {Importar archivos PGN en}
translate S ImportingFrom {Importando desde}
translate S ImportingIn {Importar juegos en}
translate S UseLastTag {Usar las etiquetas del Ãºltimo\njuego}
translate S Random {Aleatorio}
translate S BackToMainline {Volver a la lÃ­nea principal}
translate S LeaveVariant {Dejar variante}
translate S Autoplay {ReproducciÃ³n automÃ¡tica}
translate S ShowHideCoords {Mostrar/Ocultar Coord.}
translate S ShowHideEvalBar {Mostrar/Ocultar barra de evaluaciÃ³n}
translate S ShowHideMaterial {Mostrar/Ocultar material}
translate S SelectMarker {Seleccionar marcador}
translate S FullScreen {Pantalla completa}
translate S FilterStatistic {Filtrar estadÃ­sticas}
translate S MakeCorrections {hacer correcciones}
translate S Surnames {Apellidos}
translate S Ambiguous {Ambiguo}

#Preferences Dialog
translate S OptionsToolbar "Barra de herramientas ventana principal"
translate S OptionsBoard "Tablero"
translate S OptionsBoardSize "TamaÃ±o del tablero"
translate S OptionsBoardPieces "Estilo de piezas"
translate S OptionsInternationalization "InternacionalizaciÃ³n"
translate S OptionsTablebaseDir "Seleccione hasta 4 carpetas de la tablas de finales:"

# Evaluation bar
translate S BestMoveArrow "Mejor flecha de movimiento"
translate S NewLocalEngine "+ Motor nuevo..."
}
# end of english.tcl
