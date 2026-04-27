# swedish.tcl:
# Text for menu names and status bar help messages in Swedish.
# Part of Scid (Shane's Chess Information Database).
# Contributed by Martin Skjldebrand, martin@skjoldebrand.org
# Thanks to: Hans Eriksson, for looking over the translation file

proc setLanguage_W {} {

# File menu:
menuText W File "Arkiv" 0
menuText W FileNew "Ny..." 0 {Skapa en ny Scid databas}
menuText W FileOpen "ppna..." 0 {ppna en befintlig Scid databas}
menuText W FileClose "Stng" 0 {Stng den aktiva Scid databasen}
menuText W FileFinder "Sk filer" 4 {ppna skdialogen}
menuText W FileBookmarks "Bokmrken" 0 {Hantera bokmrken (kortkommando: Ctrl+B)}
menuText W FileBookmarksAdd "Nytt bokmrke" 0 \
  {Markera den aktiva stllningen i partiet}
menuText W FileBookmarksFile "Spara bokmrke" 0 \
  {Spara bokmrket fr den aktiva stllningen i partiet}
menuText W FileBookmarksEdit "Redigera bokmrken..." 0 \
  {Redigera bokmrken}
menuText W FileBookmarksList "Visa bokmrken som lista" 19 \
  {Visar bokmrkena som lista, inte undermenyer}
menuText W FileBookmarksSub "Visa bokmrken i undermenyer" 17 \
  {Visar bokmrkena som undermenyer, inte lista}
menuText W FileMaint "Databasverktyg" 0 {Scids databasverktyg}
menuText W FileMaintWin "Verktygsfnster" 0 \
  {ppna/ stng verktygsfnstret}
menuText W FileMaintCompact "Komprimera databasen..." 0 \
  {Komprimera databasen, avlgsna raderade partier och oanvnda namn}
menuText W FileMaintClass "Klassificera partier enligt ECO..." 2 \
  {Klassificera om alla partier enligt ECO-systemet}
menuText W FileMaintSort "Sortera databasen..." 0 \
  {Sortera partierna i den aktiva databasen}
menuText W FileMaintDelete "Radera dubbletter..." 0 \
  {Sk dubbletter och markera dem som raderingsbara}
menuText W FileMaintTwin "Sk dubbletter" 0 \
  {ppna/ stng dubblettfnstret fr att ska dubblettpartier}
menuText W FileMaintName "Stavningskontroll" 0 {Namnredigering och stavningskontroll}
menuText W FileMaintNameEditor "Redigera namn" 0 \
  {Redigera spelarnamn utifrn rttstavningsfilen}
menuText W FileMaintNamePlayer "Stavningskontrollera namn..." 22 \
  {Stavningskontrollera namn utifrn rttstavningsfilen}
menuText W FileMaintNameEvent "Stavningskontrollera evenemang..." 21 \
  {Stavningskontrollera evenemang utifrn rttstavningsfilen}
menuText W FileMaintNameSite "Stavningskontrollera platser..." 21 \
  {Stavningskontrollera platser utifrn rttstavningsfilen}
menuText W FileMaintNameRound "Stavningskontrollera ronder..." 21 \
  {Stavningskontrollera ronder utifrn rttstavningsfilen}
menuText W FileReadOnly "Enbart lsbar..." 8 \
  {Avlgsna temporrt redigeringsmjligheterna till databasen}
menuText W FileSwitch "Byt databas" 0 \
  {Byt till en annan ppnad databas} 
menuText W FileOpenLichessTournament "ppen Lichess-turnering" 0 {Ladda ner och ppna livesndningsspel frn Lichess-turneringar}
menuText W FileImportLichess "Importera min Lichess" 0 {Importera spel frn ditt Lichess-konto}
menuText W FileImportChessCom "Importera mitt schack.com" 0 {Importera spel frn ditt chess.com-konto}
menuText W FileExit "Avsluta" 0 {Avsluta Scid}
menuText W FileMaintFixBase "Fixa trasig databas" 0 {Frsk att fixa en trasig databas}

# Edit menu:
menuText W Edit "Redigera" 0
menuText W EditAdd "Lgg till variant" 0 {Skapa en variant vid denna stllning}
menuText W EditDelete "Radera variant" 0 {Radera en variant vid denna stllning}
menuText W EditFirst "Skapa huvudvariant" 6 \
  {Gr en av varianterna till huvudvariant}
menuText W EditMain "Skapa nytt textdrag" 11 \
  {Gr en av varianterna till partifortsttning}
menuText W EditTrial "Testa variant" 6 \
  {Starta/ stoppa testlge, undersk en id p brdet}
menuText W EditStrip "Ta bort" 3 {Avlgsna kommentarer eller varianter frn partiet}
menuText W EditUndo "ngra" 0 {ngra senaste ndring i parti}
menuText W EditRedo "Gra om" 0 {Gr om senaste spelbyte}
menuText W EditStripComments "Kommentarer" 0 \
  {Avlgsna alla kommentarer och noteringar frn partiet}
menuText W EditStripVars "Varianter" 0 {Avlgsna alla varianter frn partiet}
menuText W EditStripBegin "Avlgsna tidigare drag" 9 \
  {Avlgsna dragen fram till den aktuella stllningen} 
menuText W EditStripEnd "Avlgsna resterande drag" 0 \
  {Avlgsna partiets resterande drag} 
menuText W EditReset "Tm Clipbase" 1 \
  {Tmmer den temporra databasen}
menuText W EditCopy "Kopiera partiet till Clipbase" 21 \
  {Kopierar det aktuella partiet till Clipbase}
menuText W EditPaste "Klistra in det senaste Clipbasepartiet" 8 \
  {Klistrar in det senaste tillagda i Clipbase i den aktiva databasen}
menuText W EditPastePGN "Klistra in Clipbasetext som PGNparti..." 10 \
  {Tolka Clipbasetexten som ett parti i PGN notation och klistra in det hr}
menuText W EditSetup "Skapa stllning..." 0 \
  {Skapa en utgngsstllning fr aktuellt parti}
menuText W EditCopyBoard "Kopiera stllning" 0 \
  {Kopiera den aktuella stllningen i FEN kod till urklippshanteraren} 
menuText W EditPasteBoard "Klistra in utgngsstllning" 10 \
  {Klistra in stllningen frn aktuellt parti i den temporra databasen}
menuText W ConfigureScid "Instllningar..." 0 {Konfigurera alla alternativ fr SCID}

# Game menu:
menuText W Game "Partier" 0
menuText W GameNew "Nytt parti" 0 \
  {terstll brdet infr ett nytt parti (raderar alla ndringar)}
menuText W GameFirst "Ladda det frsta partiet" 10 {Laddar det frsta partiet i filtret}
menuText W GamePrev "Ladda fregende parti" 7 {Ladda fregende parti i filtret}
menuText W GameReload "Brja om partiet" 0 \
  {terstll partiet (raderar alla ndringar)}
menuText W GameNext "Ladda nsta parti" 6 {Ladda nsta parti i filtret}
menuText W GameLast "Ladda det sista partiet" 10 {Ladda det sista partiet i filtret}
menuText W GameRandom "Ladda parti slumpmssigt" 14 \
  {Ladda ett av datorn slumpmssigt valt parti} 
menuText W GameNumber "Ladda parti nummer..." 6 \
  {Ladda ett parti genom att ange dess nummer}
menuText W GameReplace "Spara: Erstt parti..." 7 \
  {Spara partiet och erstt tidigare version}
menuText W GameAdd "Spara: Nytt parti..." 1 \
  {Spara ett nytt parti}
menuText W GameDeepest "Identifiera ppningen" 0 \
  {G till den mest detaljerade stllningen i ECO boken}
menuText W GameGotoMove "G till drag nummer..." 8 \
  {G till ett specifikt drag i partiet}
menuText W GameNovelty "Hitta nyhet..." 7 \
  {Hitta det frsta draget i partiet som inte spelats tidigare}

# Search Menu:
menuText W Search "Sk" 0
menuText W SearchReset "terstll skfilter" 0 {terstll skfiltret s att alla partiet ingr}
menuText W SearchNegate "Omvnt filter" 0 {Ta med partier som utesluts av filtret}
menuText W SearchCurrent "Aktuell position..." 8 {Sk partier med aktuell position p brdet}
menuText W SearchHeader "I huvud..." 2 {Anvnd fast information (spelare, evenemang, plats, mm)}
menuText W SearchMaterial "Material/stllning..." 0 {Skning baserad p material eller stllning}
menuText W SearchUsing "Anvnd skfil..." 10 {Anvnd en fil med lagrade skvillkor}

# Windows menu:
menuText W Windows "Fnster" 0
menuText W WindowsComment "Kommentarseditor" 0 {ppna/ stng kommentarseditorn}
menuText W WindowsGList "Partilista" 5 {ppna/ stng partilistan}
menuText W WindowsPGN "PGN fnster" 0 \
  {ppna/ stng PGN fnstret}
menuText W WindowsPList "Spelarfrteckning" 7 {ppna/ stng en frteckning ver spelarna i den aktiva databasen} 
menuText W WindowsTmt "Turneringar" 0 {Lista turneringar}
menuText W WindowsSwitcher "Databasvxlaren" 0 \
  {ppna/ stng databasvxlaren}
menuText W WindowsMaint "Verktygsfnster" 0 \
  {ppna/ stng verktygsfnstret}
menuText W WindowsECO "ECO fnster" 0 {ppna/ stng ECO blddraren}
menuText W WindowsStats "Statistikfnster" 0 \
  {ppna/ stng statistikfnstret}
menuText W WindowsTree "Trdfnster" 2 {ppna/ stng varianttrdets fnster}
menuText W WindowsBook "Bokfnster" 0 {ppna/stng Bokfnstret}
menuText W WindowsCorrChess "Korrespondensfnster" 0 {ppna/stng Korrespondensfnstret}
menuText W WindowsGraph "Analysdiagram" 0 {ppna graffnstret med dragtider och utvrderingar}

# Tools menu:
menuText W Tools "Verktyg" 0
menuText W ToolsConfigureEngines "Konfigurera motorer" 10 {Hantera motorernas konfiguration}
menuText W ToolsAnalysis "Analysmotor..." 6 \
  {Starta/ stoppa en analysmotor}
menuText W ToolsAnalysis2 "Analysmotor 2..." 12 \
  {Starta/ stoppa en andra analysmotor}
menuText W ToolsCross "Resultattabell" 0 {Visa en resultattabell fr den aktuella turneringen}
menuText W ToolsFilterGraph "Filterdiagram" 7 \
  {ppna/ stng filterdiagramfnstret} 
menuText W ToolsAbsFilterGraph "Absolut Filtergraf" 7 {ppna/stng filtergraffnstret fr absolutvrden}
menuText W ToolsOpReport "ppningsrapport" 0 \
  {Skapa en ppningsrapport utifrn den aktuella stllningen}
menuText W ToolsOpenBaseAsTree "ppna databas som trd" 0   {ppna en databas och anvnd den i Trdfnstret}
menuText W ToolsOpenRecentBaseAsTree "ppna senaste databasen som trd" 0   {ppna den senaste databasen och anvnd den i Trdfnstret}
menuText W ToolsTracker "Sk material"  0 {ppnar dialog fr att ska efter en viss materiell balans} 
menuText W ToolsTraining "Trning"  0 {Trningsverktyg (taktik, ppningar,...) }
menuText W ToolsTacticalGame "Taktiskt parti"  0 {Spela ett parti med taktik}
menuText W ToolsSeriousGame "Serist parti"  0 {Spela ett serist parti}
menuText W ToolsTrainOpenings "ppningar"  0 {Trna med en repetoar}
menuText W ToolsTrainReviewGame "Granska parti"  0 {Gissa drag spelade i ett parti}
menuText W ToolsTrainTactics "Taktik"  0 {Lsa taktik}
menuText W ToolsTrainCalvar "Variantberkning"  0 {Variantberkningstrning}
menuText W ToolsTrainFindBestMove "Hitta bst drag"  0 {Hitta bsta draget}
menuText W ToolsTrainFics "Spela p Internet"  0 {Spela p freechess.org}
menuText W ToolsEngineTournament "Motorturnering"  0 {Starta en turnering mellan schackmotorer}
menuText W ToolsTimeAnalysis "Tidsanalys" 0 {Visa klocktidsdiagram fr det aktuella spelet}
menuText W ToolsBookTuning "Bokfininstllning" 0 {Bokfininstllning}
menuText W ToolsDownloadTWIC "Ladda ner TWIC-spel" 0 {Ladda ner de senaste spelen The Week In Chess (TWIC).}
menuText W ToolsConnectHardware "Anslut Hrdvara" 0 {Anslut extern hrdvara}
menuText W ToolsConnectHardwareConfigure  "Konfiguration" 0 {Konfiguration}
menuText W ToolsConnectHardwareNovagCitrineConnect "Anslut Novag Citrine" 0 {Anslut Novag Citrine}
menuText W ToolsConnectHardwareInputEngineConnect "Anslut Inmatningsschackmotor" 0 {Anslut Inmatningsschackmotor (t.ex. DGT)}

menuText W ToolsPInfo "Spelarinformation"  0 \
  {ppna/ uppdatera spelarinformation}
menuText W ToolsPlayerReport "Spelarrapport..." 3 \
  {Skapa en spelarrapport}
menuText W ToolsRating "Ratingdiagram" 0 \
  {Skapa ett ratingdiagram fr spelarna i partiet}
menuText W ToolsExpCurrent "Exportera aktuellt parti" 1 \
  {Spara aktuellt parti till en textfil}
menuText W ToolsExpCurrentPGN "Exportera till PGN..." 15 \
  {Spara aktuellt parti till en PGN-fil}
menuText W ToolsExpCurrentHTML "Exportera till HTML..." 15 \
  {Spara aktuellt parti till en HTML-fil}
menuText W ToolsExpCurrentHTMLJS "Exportera till HTML och JavaScript-fil..." 15 {Spara aktuellt parti till en HTML och JavaScript-fil}  
menuText W ToolsExpFilter "Exportera alla filtrerade partier" 15 \
  {Spara alla filterade partier till en textfil}
menuText W ToolsExpFilterPGN "Exportera till PGN..." 15 \
  {Spara alla filterade partier till en PGN-fil}
menuText W ToolsExpFilterHTML "Exportera till HTML..." 15 \
  {Spara alla filterade partier till en HTML-fil}
menuText W ToolsExpFilterHTMLJS "Exportera filtrerade till HTML och JavaScript-fil..." 17 {Spara alla filtrerade partier till en HTML och JavaScript-fil}  
menuText W ToolsImportOne "Importera ett parti i PGN-format..." 0 \
  {Importera ett parti i PGN-format}
menuText W ToolsImportFile "Importera flera partier i PGN-format..." 16 \
  {Importera flera partier i PGN-format frn en fil}
menuText W ToolsStartEngine1 "Starta schackmotor 1" 0  {Starta schackmotor 1}
menuText W ToolsStartEngine2 "Starta schackmotor 2" 0  {Starta schackmotor 2}
menuText W ToolsCaptureBoard "Spara aktuellt schackbrde..." 0  {Spara det aktuella schackbrdet som en bild.}

# Play menu
menuText W Play "Spela" 0

# --- Correspondence Chess
menuText W CCResign "Ge upp" 0 {Ge upp (inte via eMail)}
menuText W CCClaimDraw "Hvda Remi" 0 {Skicka drag och hvda Remi (inte via eMail)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText W Options "Alternativ" 2
menuText W OptionsBoardGraphics "Rutor..." 0 {Vlj texturer fr rutor}
translate W OptionsBGW {Vlj textur fr rutor}
translate W OptionsBoardGraphicsText {Vlj grafikfiler fr vita och svarta rutor:}
menuText W OptionsBoardNames "Spelarnamn..." 0 {Redigera spelares namn}
menuText W OptionsExport "Export" 0 {ndra exportalternativ}
menuText W OptionsFonts "Typsnitt" 0 {ndra typsnitt}
menuText W OptionsFontsRegular "Normal" 0 {ndra det normala typsnittet}
menuText W OptionsFontsMenu "Menu" 0 {ndra menytypsnittet}
menuText W OptionsFontsSmall "Liten" 0 {ndra det lilla typsnittet}
menuText W OptionsFontsTiny "Tiny" 0 {Change the tiny font}
menuText W OptionsFontsFixed "Fixerad" 0 {ndra det fixerade typsnittet}
menuText W OptionsGInfo "Partiinformation" 0 {Alternativ fr partiinformation}
menuText W OptionsLanguage "Sprk" 0 {Vlj sprk}
menuText W OptionsMovesTranslatePieces "verstt pjser" 0 {verstt frsta bokstaven fr pjser}
menuText W OptionsMovesHighlightLastMove "Visa Rutor" 0 {Markera senaste draget}
menuText W OptionsMovesHighlightLastMoveDisplay "Visa" 0 {Visa senaste markerade draget}
menuText W OptionsMovesHighlightLastMoveWidth "Bredd" 0 {Tjockhet p rad}
menuText W OptionsMovesHighlightLastMoveColor "Frg" 0 {Frg p rad}
menuText W OptionsMovesHighlightLastMoveArrow "Visa pil" 0 {Visa pil med markering}
menuText W OptionsMovesHighlightLastMoveNag "Visa utvrderingssymboler" 0
menuText W OptionsMovesHighlightLastMoveEval "Visa utvrderingssymboler" 0
menuText W OptionsMoves "Drag" 0 {Alternativ fr dragangivelse}
menuText W OptionsMovesAnimate "Frdrjning vid manuellt spel" 1 \
  {Ange tid mellan varje drag nr dragen grs automatiskt}
menuText W OptionsMovesDelay "Frdrjning vid automatspel..." 1 \
  {Ange frdrjning mellan dragen nr datorn spelar sjlv}
menuText W OptionsMovesCoord "Koordinater" 0 \
  {Acceptera koordinater ("g1f3") vid dragangivelse}
menuText W OptionsMovesSuggest "Visa freslagna drag" 0 \
  {Visa/ Dlj freslagna drag}
menuText W OptionsShowVarPopup "Visa Variantfnster" 0 {Starta/Avsluta visningen av ett Variantfnster}  
menuText W OptionsMovesSpace "Lgg till mellanslag efter dragnummer" 0 {Lgg till mellanslag efter dragnummer}  
menuText W OptionsMovesLichess "Lichess/ChessBase-format fr anteckningar" 0 {Anvnd formatet Lichess/ChessBase fr fyrkantiga markrer och pilar}
menuText W OptionsMovesKey "Tangentkomplettering" 0 \
  {Starta/ stng av dragkomplettering vid tangentinmatning}
menuText W OptionsMovesShowVarArrows "Visa pilar fr variationer" 0 {Vxlar p/av pilar som visar drag i variationer}
menuText W OptionsMovesShowEngineVariationArrows "Visa pilar fr motorvariationer" 0 {Sl p/av-pilar som visar motorvariationslinjer i multiPV-lge}
menuText W OptionsMovesGlossOfDanger "Frgkodad Gloss of Danger" 0 {Sl p/av frgkodad glans av fara}
translate W OptionsMovesTreeDepth {Standard trdfnster Flytta djup}
menuText W OptionsNumbers "Talformat" 3 {Vlj hur tal visas}
menuText W OptionsTheme "Tema" 0 {ndra utseende p grnssnitt}
menuText W OptionsWindows "Fnster" 1 {Fnsteralternativ}
menuText W OptionsSounds "Ljud" 2 {Konfigurera ljud fr att annonsera drag}
menuText W OptionsResources "Resurser..." 0 {Vlj resursfiler och mappar}
menuText W OptionsWindowsDock "Dockningsfnster" 0 {Dockningsfnster}
menuText W OptionsWindowsSaveLayout "Spara layout" 0 {Sparar layout}
menuText W OptionsWindowsRestoreLayout "terstll layout" 0 {terstller layout}
menuText W OptionsWindowsShowGameInfo "Visa partiinformation" 0 {Visar partiinformation}
menuText W OptionsWindowsAutoLoadLayout "Automatiskt ppna frsta layouten" 0 {ppnar automatiskt frsta layouten vid uppstart}
menuText W OptionsECO "Ladda ECO fil" 7 {Ladda ECO-klassificeringen vid start}
menuText W OptionsSpell "Ladda Rttstavningsfil" 7 \
  {Ladda rttstavningsfilen vid start}
menuText W OptionsTable "Katalog fr slutspelsdatabaser" 0 \
  {Vlj en fil som innehller en slutspelsdatabas; alla vriga filer i samma katalog kommer att anvndas}
menuText W OptionsRecent "Senast anvnda filer..." 16 \
  {ndra antalet senast anvnda filer som visas i Arkivmenyn} 
menuText W OptionsBooksDir "ppningsbokskatalog" 0 {Anger ppningsbokskatalogen}
menuText W OptionsTacticsBasesDir "Taktikbaskatalog" 0 {Anger Taktikbaskatalog (fr trning)}
menuText W OptionsPhotosDir "Fotokatalog" 0 {Stller in fotobaskatalogen}
menuText W OptionsThemeDir "Temafil:"  0 {Ladda en GUI-temapaketfil}
menuText W OptionsSave "Spara alternativ" 7 \
  "Spara alla alternativ till en instllningsfil"
menuText W OptionsAutoSave "Autospara vid avslut" 1 \
  {Spara alla alternativ nr du avslutar Scid}

# Help menu:
menuText W Help "Hjlp" 0
menuText W HelpContents "Innehll" 0 {Visa innehll} 
menuText W HelpIndex "Index" 0 {Hjlpsystemets indexsida}
menuText W HelpGuide "Snabbguide" 0 {Visa snabbguiden}
menuText W HelpHints "Tips" 0 {Visa tips}
menuText W HelpContact "Kontaktinformation" 0 {Visa kontaktinformation}
menuText W HelpTip "Dagens tips" 0 {Anvndbara Scid tips}
menuText W HelpStartup "Startfnster" 5 {Visa startfnstret}
menuText W HelpAbout "Om Scid" 0 {Information om Scid}

# Toolbar tooltips:
menuText W RotateBoard "Vrid brdet" 0 {Vrid brdet}

# Game info box popup menu:
menuText W GInfoHideNext "Dlj nsta drag" 0
menuText W GInfoMaterial "Visa materialvrden" 0
menuText W GInfoFEN "Visa FEN" 5
menuText W GInfoMarks "Visa frgade flt och pilar" 22 
menuText W GInfoWrap "Radbrytning" 0
menuText W GInfoFullComment "Visa fullstndiga kommentarer" 18
menuText W GInfoPhotos "Visa bilder" 5 ;
menuText W GInfoTBNothing "Slutspelsdatabaser: inget" 20
menuText W GInfoTBResult "Slutspelsdatabaser: endast resultat" 28
menuText W GInfoTBAll "Slutspelsdatabaser: resultat och bsta drag" 33
menuText W GInfoDelete "terta/Radera detta parti" 0
menuText W GInfoMark "(Av-)Markera detta parti" 5
menuText W GInfoInformant "Konfigurera Informant-parametrar" 0

# General buttons:
translate W Back {Tillbaka}
translate W Browse {Blddra}
translate W Cancel {Avbryt}
translate W Continue {Fortstt}
translate W Clear {Rensa}
translate W Close {Stng}
translate W Contents {Innehll}
translate W Defaults {Standard}
translate W InvertSearch {Invertera skning}
translate W Delete {Radera}
translate W Graph {Diagram}
translate W Help {Hjlp}
translate W Hide {Dlja}
translate W Import {Importera}
translate W Index {Index}
translate W LoadGame {Ladda parti}
translate W BrowseGame {Blddra genom partier}
translate W MergeGame {Sl samman parti}
translate W MergeGames {Sl samman partier}
translate W Preview {Frhandsgranska}
translate W Revert {ngra inmatning}
translate W Save {Spara}
translate W Search {Sk}
translate W Stop {Stoppa}
translate W Store {Spara}
translate W Update {Uppdatera}
translate W ChangeOrient {ndra fnstrets orientering}
translate W ShowIcons {Visa Ikoner} ;# ***
translate W None {Ingen}
translate W First {Frsta}
translate W Current {Aktuella}
translate W Last {Sista}

# General messages:
translate W game {parti}
translate W games {partier}
translate W move {drag}
translate W moves {drag}
translate W all {alla}
translate W Yes {Ja}
translate W No {Nej}
translate W Both {Bda}
translate W King {Kung}
translate W Queen {Dam}
translate W Rook {Torn}
translate W Bishop {Lpare}
translate W Knight {Springare}
translate W Pawn {Bonde}
translate W White {Vit}
translate W Black {Svart}
translate W Player {Spelare}
translate W Rating {Rating}
translate W RatingDiff {Ratingskillnad (Vit - Svart)}
translate W AverageRating {Medelrating}
translate W Event {Evenemang}
translate W Site {Plats}
translate W Country {Land}
translate W IgnoreColors {Ignorera frger}
translate W Date {Datum}
translate W EventDate {Evenemangsdatum}
translate W Decade {Decennium}
translate W Year {r}
translate W Month {Mnad}
translate W Months {Januari Februari Mars April Maj Juni Juli Augusti September Oktober November December}
translate W Days {Sn Mn Tis Ons Tor Fre Lr}
translate W YearToToday {Idag}
translate W YearToTodayTooltip {Ange datum frn 1 r tillbaka till idag}
translate W Result {Resultat}
translate W Round {Rond}
translate W Length {Lngd}
translate W ECOCode {ECO kod}
translate W ECO {ECO}
translate W Deleted {Raderad}
translate W SearchResults {Skresultat}
translate W OpeningTheDatabase {ppnar databas}
translate W Database {Databas}
translate W Filter {Filter}
translate W noGames {inga partier}
translate W allGames {alla partier}
translate W empty {tom}
translate W clipbase {Clipbase}
translate W score {resultat}
translate W StartPos {Utgngsstllning}
translate W Total {Totalt}
translate W readonly {bara lsbar} ;# ***

# Standard error messages:
translate W ErrNotOpen {Databasen r inte ppen.}
translate W ErrReadOnly {Databasen r skrivskyddad. Du kan inte ndra i den.}
translate W ErrSearchInterrupted {Skningen avbrts; resultatet r inte fullstndigt.}
translate W ErrNoClockComments {Inga [%clk] klockkommentarer hittades i det hr spelet.    Lgg till klocktider via kommentarsfnstret (Ctrl+E) fr att anvnda den hr funktionen.}
translate W ErrFileInUse {Fel: filen anvnds redan. Stng alla andra program som anvnder denna databas. Om programmet stngdes ovntat kan du behva ta bort .lock-filen som r kopplad till databasen.}




# Game information:
translate W twin {dubblett}
translate W deleted {raderad}
translate W comment {kommentar}
translate W hidden {dold}
translate W LastMove {Senaste draget}
translate W NextMove {Nsta}
translate W GameStart {Utgngsstllning}
translate W LineStart {Varianten brjar}
translate W GameEnd {Slutstllning}
translate W LineEnd {Varianten slut}

# Player information:
translate W PInfoAll {Resultat fr <b>alla</b> partier}
translate W PInfoFilter {Resultat fr <b>filtrerade</b> partier}
translate W PInfoAgainst {Resultat mot}
translate W PInfoMostWhite {De vanligaste ppningarna som vit}
translate W PInfoMostBlack {De vanligaste ppningarna som svart}
translate W PInfoRating {Ratinghistoria}
translate W PInfoBio {Biografisk information}
translate W PInfoEditRatings {Redigera rating} 
translate W PInfoEloFile {Fil}

# Tablebase information:
translate W Draw {Remi}
translate W with {med}
translate W only {bara}
translate W lose {frlust}
translate W loses {frluster}

# Tip of the day:
translate W Tip {Tips}
translate W TipAtStartup {Tips vid start}
translate W TipConvertPGN {Du kan f bttre prestanda genom att konvertera PGN-filer}

# Tree window menus:
menuText W TreeFile "Fil" 0
menuText W TreeFileFillWithBase "Fyll Cache med databas" 0 {Fyll Cachefilen med alla partier i den aktuella databasen}
menuText W TreeFileFillWithGame "Fyll Cache med parti" 0 {Fyll Cachefilen med aktuellt parti i den aktuella databasen}
menuText W TreeFileSetCacheSize "Cachestorlek" 0 {Ange Cachestorleken}
menuText W TreeFileCacheInfo "Cacheinformation" 0 {F information om Cacheanvndning}
menuText W TreeFileSave "Spara cachefil" 0 {Spara trdcache (*.stc)-filen}
menuText W TreeFileFill "Fyll cachefil" 0 \
 {Fyll cachefilen med vanliga ppningar}
menuText W TreeFileBest "Lista bsta partier" 0 {Visa lista ver de bsta partierna i trdet}
menuText W TreeFileGraph "Diagramfnster" 0 {Visa diagrammet fr denna gren i trdet}
menuText W TreeFileCopy "Kopiera trd till urklipp" 1 \
  {Kopierar trdrelaterad statistik till urklipp}
menuText W TreeFileClose "Stng trdfnstret" 0 {Stng trdfnstret}
menuText W TreeMask "Skmask" 0
menuText W TreeMaskNew "Ny" 0 {Ny skmask}
menuText W TreeMaskOpen "ppna" 0 {ppna skmask}
menuText W TreeMaskOpenRecent "ppna senaste" 0 {ppna senaste skmasken}
menuText W TreeMaskSave "Spara" 0 {Spara skmask}
menuText W TreeMaskClose "Stng" 0 {Stng skmask}
menuText W TreeMaskFillWithGame "Fyll med parti" 0 {Fyll skmask med parti}
menuText W TreeMaskFillWithBase "Fyll med databas" 0 {Fyll skmask med alla partier i databasen}
menuText W TreeMaskInfo "Info om skmask" 0 {Visa statistik fr aktuell skmask}
menuText W TreeMaskDisplay "Visa skmaskkarta" 0 {Visa skmaskdata i trdform}
menuText W TreeMaskSearch "Sk" 0 {Sk i aktuell skmask}
menuText W TreeSort "Sortera" 0
menuText W TreeSortAlpha "Alfabetiskt" 0
menuText W TreeSortECO "ECO kod" 0
menuText W TreeSortFreq "Frekvens" 0
menuText W TreeSortScore "Resultat" 0
menuText W TreeOpt "Alternativ" 0
menuText W TreeOptSlowmode "Lngsam mod" 0 {Lngsam mod fr uppdateringar (hg noggrannhet)}
menuText W TreeOptFastmode "Snabb mod" 0 {Snabb mod fr uppdateringar (ingen dragtranspositionering)}
menuText W TreeOptFastAndSlowmode "Snabb och lngsam mod" 0 {Snabb mod sedan lngsam mod fr uppdateringar}
menuText W TreeOptStartStop "Automatisk uppdatering" 0 {Vxlar automatisk uppdatering av trdfnstret}
menuText W TreeOptLock "Ls" 0 {Ls/ ls upp trdet fr den aktuella databasen}
menuText W TreeOptTraining "Trna" 0 {Starta/ stng av trningslge}
menuText W TreeOptDepth "Flytta djup" 0 {Antal halva drag som ska visas i trdet (1-4)}
menuText W TreeOptAutosave "Spara cache filen automatiskt" 0 \
  {Spara cachefilen automatiskt nr trdfnstret stngs}
menuText W TreeHelp "Hjlp" 0
menuText W TreeHelpTree "Trdhjlp" 0
menuText W TreeHelpIndex "Hjlpindex" 0
translate W SaveCache {Spara cache}
translate W Training {Trna}
translate W LockTree {Ls}
translate W TreeDepth {Trddjup (halva rrelser):}
translate W TreeLocked {Lst}
translate W TreeBest {Bst}
translate W TreeBestGames {Bsta partier i trdet}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate W TreeTitleRow \
{Drag                          ECO     Frekvens      Res.    Elo~  Niv  r~   %Remi      %Vinna} 
translate W TreeTotal {TOTALT} 
translate W DoYouWantToSaveFirst {Vill du spara frst}
translate W AddToMask {Lgg till i skmask}
translate W RemoveFromMask {Ta bort frn skmask}
translate W AddThisMoveToMask {Lgg till deta drag i skmask}
translate W SearchMask {Sk i skmask}
translate W DisplayMask {Visa skmask}
translate W Nag {NAG-kod}
translate W Marker {Markera}
translate W Include {Inkludera}
translate W Exclude {Exkludera}
translate W MainLine {Huvudvariant}
translate W Bookmark {Bokmrke}
translate W NewLine {Ny variant}
translate W ToBeVerified {Att bli verifierad}
translate W ToTrain {Att trna}
translate W Dubious {Tveksam}
translate W ToRemove {Att ta bort}
translate W NoMarker {Ingen markering}
translate W ColorMarker {Frg}
translate W WhiteMark {Vit}
translate W GreenMark {Grn}
translate W YellowMark {Gul}
translate W BlueMark {Bl}
translate W RedMark {Rd}
translate W CommentMove {Kommentera drag}
translate W CommentPosition {Kommentera position}
translate W AddMoveToMaskFirst {Lgg till drag till skmask frst}
translate W OpenAMaskFileFirst {ppna en skmaskmaskfil frst}
translate W Positions {Positioner}
translate W Moves {Drag}

# Finder window:
menuText W FinderFile "Fil" 0
menuText W FinderFileSubdirs "Sk i underkataloger" 0
menuText W FinderFileClose "Stng Filskaren" 0
menuText W FinderSort "Sortera" 0
menuText W FinderSortType "Typ" 0
menuText W FinderSortSize "Storlek" 0
menuText W FinderSortMod "Frndrad" 0
menuText W FinderSortName "Namn" 0
menuText W FinderSortPath "Skvg" 0
menuText W FinderTypes "Typer" 0
menuText W FinderTypesScid "Sciddatabaser" 0
menuText W FinderTypesOld "Sciddatabaser i ldre format" 0
menuText W FinderTypesPGN "PGN-filer" 0
menuText W FinderTypesEPD "EPD-filer" 0
menuText W FinderTypesRep "ppningsfiler" 0
menuText W FinderHelp "Hjlp" 0
menuText W FinderHelpFinder "Hjlp fr Filskaren" 0
menuText W FinderHelpIndex "Hjlpindex" 0
translate W FileFinder {Filskaren}
translate W FinderDir {Katalog}
translate W FinderDirs {Kataloger}
translate W FinderFiles {Filer}
translate W FinderUpDir {upp}
translate W FinderCtxOpen {ppna}
translate W FinderCtxBackup {Spara}
translate W FinderCtxCopy {Kopiera}
translate W FinderCtxMove {Flytta}
translate W FinderCtxDelete {Ta bort}

# Player finder:
menuText W PListFile "Fil" 0
menuText W PListFileUpdate "Uppdatera" 0
menuText W PListFileClose "Stng spelarfrteckningen" 1 
menuText W PListSort "Sortera" 0
menuText W PListSortName "Namn" 0
menuText W PListSortElo "Elo" 0
menuText W PListSortGames "Partier" 0
menuText W PListSortOldest "ldst" 0 
menuText W PListSortNewest "Yngst" 0

# Tournament finder:
menuText W TmtFile "Fil" 0
menuText W TmtFileUpdate "Uppdatera" 0
menuText W TmtFileClose "Stng turneringshanteraren" 0
menuText W TmtSort "Sortera" 0
menuText W TmtSortDate "Datum" 0
menuText W TmtSortPlayers "Spelare" 0
menuText W TmtSortGames "Partier" 0
menuText W TmtSortElo "Elo" 0
menuText W TmtSortSite "Plats" 0
menuText W TmtSortEvent "Evenemang" 1
menuText W TmtSortWinner "Vinnare" 0
translate W TmtLimit "Listbegrnsningar"
translate W TmtMeanElo "Lgsta snitt Elo"
translate W TmtNone "Inga turneringar hittades."

# Graph windows:
menuText W GraphFile "Fil" 0
menuText W GraphFileColor "Spara som Postscript (i frg)" 8
menuText W GraphFileGrey "Spara som Postscript (i grskala)" 8
menuText W GraphFileClose "Stng fnster" 6
menuText W GraphOptions "Alternativ" 0
menuText W GraphOptionsWhite "Vit" 0
menuText W GraphOptionsBlack "Svart" 0
menuText W GraphOptionsBoth "Bda" 1
menuText W GraphOptionsPInfo "Spelarinformation" 0
menuText W GraphOptionsEloFile "Elo frn betygsfil" 0
menuText W GraphOptionsEloDB "Elo frn databasen" 0
translate W GraphFilterTitle "Filterdiagram: procentandel av spel som nr position"
translate W GraphAbsFilterTitle "Filtergraf: frekvens fr partierna"
translate W ConfigureFilter {Konfigurera X-axlar fr r, Rating och Drag}
translate W FilterEstimate "Uppskatta"
translate W TitleFilterGraph "Scid: Filtergraf"

# Analysis window:
translate W AddVariation {Lgg till variation}
translate W AddAllVariations {Lgg till alla variationer}
translate W AddMove {Lgg till drag}
translate W Annotate {Kommentera}
translate W ShowAnalysisBoard {Visa Analysbrde}
translate W ShowInfo {Visa schackmotorinformation}
translate W FinishGame {Avsluta parti}
translate W StopEngine {Stoppa schackmotor}
translate W StartEngine {Starta schackmotor}
translate W LockEngine {Ls schackmotor vid nuvarande position}
translate W AnalysisCommand {Analysera}
translate W PreviousChoices {Fregende val}
translate W AnnotateTime {Ange tid mellan drag i sekunder}
translate W AnnotateWhich {Lgg till variationer}
translate W AnnotateAll {Fr bda sidors drag}
translate W AnnotateAllMoves {Kommentera alla drag}
translate W AnnotateWhite {Endast vits drag}
translate W AnnotateBlack {Endast svarts drag}
translate W AnnotateBlundersOnly {Nr partidraget r en uppenbar blunder}
translate W AnnotateBlundersOnlyScoreChange {Analysen rapporterar blunder, med vrderingsfrndringar frn/till: }
translate W BlundersThreshold {Trskelvrde}
translate W ScoreAllMoves {Score all moves}
translate W LowPriority {Kr som lgprioriterad process} 
translate W ClickHereToSeeMoves {Klicka hr fr att se drag}
translate W ConfigureInformant {Informant-parametrar}
translate W Informant!? {Intressant drag}
translate W Informant? {Dligt drag}
translate W Informant?? {Blunder}
translate W Informant?! {Tveksamt drag}
translate W Informant+= {Vit har en mindre frdel}
translate W Informant+/- {Vit har en liten frdel}
translate W Informant+- {Vit har en avgrande frdel}
translate W Informant+-- {Partiet anses vara vunnet}
translate W AutoComment {Autokommentar}
translate W AutoCommentTooltip {Generera AI-kommentarer fr den aktuella positionen}
translate W AnalysisAutoCommentTooltip {Generera AI-kommentarer fr hela spelet}
translate W GameComment {Spelkommentar}
translate W GameCommentTooltip {Skanna spelet efter kommenterade drag och generera AI-sammanfattningar}
translate W TimeMs {Tid(ms)}


# Book window
translate W Book {Bok}
translate W OtherBookMoves {Motstndarens bok}
translate W OtherBookMovesTooltip {Drag som motstndaren har ett svar p}

# Analysis Engine open dialog:
translate W EngineList {Lista ver schackprogram}
translate W EngineName {Namn}
translate W EngineCmd {Startkommando}
translate W EngineArgs {Parametrar} 
translate W EngineDir {Katalog}
translate W EngineElo {Elo}
translate W EngineTime {Datum}
translate W EngineNew {Ny}
translate W EngineEdit {Redigera}
translate W EngineRequired {Fet stil indikerar obligatoriska flt; vriga flt r frivilliga} 
translate W EngineProtocol {Kommunikationsprotokoll}
translate W EngineNotation {Notering av rrelserna}
translate W EngineFlipEvaluation {Flip utvrdering perspektiv}
translate W EngineShowLog {Visa kommunikationslogg}
translate W EngineNetworkd {Acceptera fjrranslutningar}
translate W EngineSelect {Vlj den aktuella motorn}
translate W EngineAddLocal {Lgg till en lokal motor}
translate W EngineAddRemote {Lgg till en fjrrmotor}
translate W EngineReload {Ladda om den nuvarande motorn}
translate W EngineClone {Skapa en kopia av den aktuella motorn}
translate W EngineDelete {Ta bort den aktuella motorn}

# PGN window menus:
menuText W PgnFile "Fil" 0
menuText W PgnFileCopy "Kopiera partiet till Clipbase" 0
menuText W PgnFilePrint "Skriv ut till..." 0
menuText W PgnFileClose "Stng PGN-fnster" 0
menuText W PgnOpt "Presentation" 0
menuText W PgnOptColor "Frg" 0
menuText W PgnOptShort "Kort (3-raders) huvud" 0
menuText W PgnOptSymbols "Symbolbaserad kommentar" 1
menuText W PgnOptIndentC "Indragna kommentarer" 0
menuText W PgnOptIndentV "Indragna variationer" 7
menuText W PgnOptColumn "Spaltstil (ett drag per rad)" 1
menuText W PgnOptSpace "Utrymme efter dragnummer" 1
menuText W PgnOptStripMarks "Avlgsna koder fr frgade flt och pilar" 1 
menuText W PgnOptBoldMainLine "Anvnd Fet Text fr Huvudvariationsdrag" 4
menuText W PgnColor "Frger" 0
menuText W PgnColorHeader "Huvud..." 0
menuText W PgnColorAnno "Noteringar..." 0
menuText W PgnColorComments "Kommentarer..." 0
menuText W PgnColorVars "Variationer..." 0
menuText W PgnColorBackground "Bakgrund..." 0
menuText W PgnColorMain "Huvudvariation..." 0
menuText W PgnColorCurrent "Aktuellt drag bakgrund..." 1
menuText W PgnHelp "Hjlp" 0
menuText W PgnHelpPgn "PGN-hjlp" 0
menuText W PgnHelpIndex "Index" 0
translate W PgnWindowTitle {PGN-version av partiet %u} 

# Crosstable window menus:
menuText W CrosstabFile "Fil" 0
menuText W CrosstabFileText "Skriv ut till textfil..." 9
menuText W CrosstabFileHtml "Skriv ut till HTML-fil..." 9
menuText W CrosstabFileClose "Stng resultattabellsfnstret" 0
menuText W CrosstabEdit "Redigera" 0
menuText W CrosstabEditEvent "Evenemang" 0
menuText W CrosstabEditSite "Plats" 0
menuText W CrosstabEditDate "Datum" 0
menuText W CrosstabOpt "Presentation" 0
menuText W CrosstabOptAll "Alla-mter-alla" 0
menuText W CrosstabOptSwiss "Schweizer" 0
menuText W CrosstabOptKnockout "Knock Out" 0
menuText W CrosstabOptAuto "Auto" 1
menuText W CrosstabOptAges "lder i r" 8
menuText W CrosstabOptNats "Nationalitet" 0
menuText W CrosstabOptRatings "Rating" 0
menuText W CrosstabOptTitles "Titlar" 0
menuText W CrosstabOptBreaks "Tie-break pong" 4
menuText W CrosstabOptDeleted "Inkludera raderade partier" 8 
menuText W CrosstabOptColors "Frg (endast Schweizer)" 0
menuText W CrosstabOptColumnNumbers "Numrerade kolumner (Endast alla-mot-alla)" 2 
menuText W CrosstabOptGroup "Gruppresultat" 0
menuText W CrosstabSort "Sortera" 0
menuText W CrosstabSortName "Namn" 0
menuText W CrosstabSortRating "Rating" 0
menuText W CrosstabSortScore "Resultat" 0
menuText W CrosstabColor "Frg" 0
menuText W CrosstabColorPlain "Ren text" 0
menuText W CrosstabColorHyper "Hypertext" 0
menuText W CrosstabHelp "Hjlp" 0
menuText W CrosstabHelpCross "Hjlp fr resultattabell" 0
menuText W CrosstabHelpIndex "Hjlpindex" 0
translate W SetFilter {Bestm filter}
translate W AddToFilter {Utka filter}
translate W Swiss {Schweizer}
translate W Category {Kategori} 

# Opening report window menus:
menuText W OprepFile "Fil" 0
menuText W OprepFileText "Skriv ut till textfil..." 9
menuText W OprepFileHtml "Skriv ut till HTML-fil..." 9
menuText W OprepFileOptions "Alternativ..." 0
menuText W OprepFileClose "Stng rapportfnstret" 0
menuText W OprepFavorites "Favoriter" 1 
menuText W OprepFavoritesAdd "Lgg till rapport..." 0 
menuText W OprepFavoritesEdit "Redigera favoritrapport..." 0 
menuText W OprepFavoritesGenerate "Skapa rapport..." 0 
menuText W OprepHelp "Hjlp" 0
menuText W OprepHelpReport "Hjlp fr ppningsrapporter" 0
menuText W OprepHelpIndex "Hjlpindex" 0

# Header search:
translate W HeaderSearch {Sk i partihuvud}
translate W EndSideToMove {Sida vid draget vid slutet av partiet}
translate W GamesWithNoECO {Partier utan ECO-kod?}
translate W GameLength {Partilngd}
translate W FindGamesWith {Hitta flaggade partier}
translate W StdStart {Normal utgngsstllning}
translate W Promotions {Frvandlingar}
translate W Comments {Kommentarer}
translate W Variations {Variationer}
translate W Annotations {Noteringar}
translate W DeleteFlag {Raderingsflagga}
translate W WhiteOpFlag {Vits ppning}
translate W BlackOpFlag {Svarts ppning}
translate W MiddlegameFlag {Mittspel}
translate W EndgameFlag {Slutspel}
translate W NoveltyFlag {Nyhet}
translate W PawnFlag {Bondestruktur}
translate W TacticsFlag {Taktiska stllningar}
translate W QsideFlag {Damflygelsinitiativ}
translate W KsideFlag {Kungsflygelsinitiativ}
translate W BrilliancyFlag {Utmrkt parti}
translate W BlunderFlag {Bortsttningar}
translate W UserFlag {Anvndare}
translate W PgnContains {PGN innehller text}
translate W PgnTag {Mrka}
translate W TagContains {innehller}
translate W Variant {Variant}
translate W Annotator {Kommentator}
translate W Cmnts {Bara kommenterade partier}

# Game list window:
translate W GlistNumber {Nummer}
translate W GlistWhite {Vit}
translate W GlistBlack {Svart}
translate W GlistWElo {Elo, vit}
translate W GlistBElo {Elo, svart}
translate W GlistEvent {Evenemang}
translate W GlistSite {Plats}
translate W GlistRound {Rond}
translate W GlistDate {Datum}
translate W GlistYear {r}
translate W GlistEDate {Startdatum}
translate W GlistResult {Resultat}
translate W GlistLength {Lngd}
translate W GlistCountry {Land}
translate W GlistECO {ECO}
translate W GlistOpening {ppning}
translate W GlistEndMaterial {Slutmaterial}
translate W GlistDeleted {Raderad}
translate W GlistFlags {Flaggor}
translate W GlistVars {Variationer}
translate W GlistComments {Kommentarer}
translate W GlistAnnos {Noteringar}
translate W GlistStart {Start}
translate W GlistGameNumber {Partinummer}
translate W GlistAverageElo {Medel-Elo}
translate W GlistRating {Rating}
translate W GlistFindText {Sk text}
translate W GlistMoveField {Drag}
translate W GlistEditField {Konfiguration}
translate W GlistAddField {Lgg till}
translate W GlistDeleteField {Ta bort}
translate W GlistWidth {Bredd}
translate W GlistAlign {Justering}
translate W GlistAlignL {Justera: vnster}
translate W GlistAlignR {Justera: hger}
translate W GlistAlignC {Justera: centrera}
translate W GlistColor {Frg}
translate W GlistSep {Separator}
translate W GlistCurrentSep {-- Aktuell --}
translate W GlistNewSort {Ny}
translate W GlistAddToSort {Lgg till}

# base sorting
translate W GsortSort {Sortera...}
translate W GsortDate {Datum}
translate W GsortYear {r}
translate W GsortEvent {Evenemang}
translate W GsortSite {Plats}
translate W GsortRound {Runda}
translate W GsortWhiteName {Vits namn}
translate W GsortBlackName {Svarts namn}
translate W GsortECO {ECO}
translate W GsortResult {Resultat}
translate W GsortMoveCount {Antal drag}
translate W GsortAverageElo {Medel-Elo}
translate W GsortCountry {Land}
translate W GsortDeleted {Borttagen}
translate W GsortEventDate {Evenemangsdatum}
translate W GsortWhiteElo {Vits Elo}
translate W GsortBlackElo {Svarts Elo}
translate W GsortComments {Kommentarer}
translate W GsortVariations {Variationer}
translate W GsortNAGs {Kommentarssymboler}
translate W GsortAscending {Stigande}
translate W GsortDescending {Sjunkande}
translate W GsortAdd {Lgg till}
translate W GsortStore {Spara}
translate W GsortLoad {ppna}

# menu shown with right mouse button down on game list.
translate W GlistRemoveThisGameFromFilter  {Ta bort detta parti frn Filter}
translate W GlistRemoveGameAndAboveFromFilter  {Ta bort parti (och alla ovanfr det) frn Filter}
translate W GlistRemoveGameAndBelowFromFilter  {Ta bort parti (och alla nedanfr det) frn Filter}
translate W GlistDeleteGame {Ta tillbaka detta parti} 
translate W GlistDeleteAllGames {Ta bort alla partier i filtret} 
translate W GlistUndeleteAllGames {Ta tillbaka alla partier i filtret} 
translate W GlistMergeGameInBase {Lgg till parti i annan databas} 

# Maintenance window:
translate W DatabaseName {Databasnamn:}
translate W TypeIcon {Ikontyp:}
translate W NumOfGames {Partier:}
translate W NumDeletedGames {Raderade partier:}
translate W NumFilterGames {Partier i filter:}
translate W YearRange {Tidsperiod:}
translate W RatingRange {Ratingintervall:}
translate W Description {Beskrivning} 
translate W Flag {Flagga}
translate W CustomFlags {Anpassade flaggor}
translate W DeleteCurrent {Ta bort aktuellt parti}
translate W DeleteFilter {Ta bort partierna i filtret}
translate W DeleteAll {Ta bort alla partier}
translate W UndeleteCurrent {terta aktuellt parti}
translate W UndeleteFilter {terta partierna i filtret}
translate W UndeleteAll {terta alla partier}
translate W DeleteTwins {Ta bort dubbletter}
translate W MarkCurrent {Markera aktuellt parti}
translate W MarkFilter {Markera partierna i filtret}
translate W MarkAll {Markera alla partier}
translate W UnmarkCurrent {Avmarkera aktuellt parti}
translate W UnmarkFilter {Avmarkera partierna i filtret}
translate W UnmarkAll {Avmarkera alla partier}
translate W Spellchecking {Rttstava}
translate W Players {Spelare}
translate W Events {Evenemang}
translate W Sites {Platser}
translate W Rounds {Ronder}
translate W DatabaseOps {Databashantering}
translate W ReclassifyGames {ECO-klassificera partier}
translate W CompactDatabase {Komprimera databasen}
translate W SortDatabase {Sortera databasen}
translate W AddEloRatings {Lgg till Elorating}
translate W AutoloadGame {Ladda partinummer automatiskt}
translate W StripTags {Avlgsna PGN-taggar}
translate W StripTag {Avlgsna taggar}
translate W Cleaner {Snygga till databasen}
translate W CleanerHelp {
Databasstdaren i Scid genomfr allt det underhll av databasen du vljer nedan p den aktiva databasen.

De nuvarande instllningarna i ECO-klassificering och Radera dubbletter kommer att appliceras om du vljer dessa tgrder.
}
translate W CleanerConfirm {
Nr du vl startat Databasstdaren kan du inte avbryta den!

P en stor databas kan detta ta ett bra tag. Tidstgngen beror p valda tgrder och deras instllningar.

r du sker p att du vill pbrja databasunderhllet nu?
}
# Twinchecker
translate W TwinCheckUndelete {att vxla; "u" tar tillbaka bda)}
translate W TwinCheckprevPair {Tidigare par}
translate W TwinChecknextPair {Nsta par}
translate W TwinChecker {Scid: Dublettpartikontrollerare}
translate W TwinCheckTournament {Partier i turnering:}
translate W TwinCheckNoTwin {Ingen dublett  }
translate W TwinCheckNoTwinfound {Ingen dublett detekterades fr detta parti.\nFr att visa dubletter med detta fnster, mste du frst anvnda "Ta bort dublettpartier..."-funktionen. }
translate W TwinCheckTag {Dela taggar...}
translate W TwinCheckFound1 {Scid hittade $result dublettpartier}
translate W TwinCheckFound2 { och ange deras borttagningsflaggor}
translate W TwinCheckNoDelete {Det finns inga partier i denna databas att ta bort.}
translate W TwinCriteria1 { Dina instllningar fr att hitta dublettpartier r potentiellt sannorlika att\norsaka att icke-dublettpartier med liknande drag blir markerade som dubletter.}
translate W TwinCriteria2 {Det r rekommenderat att om du vljer "Nej" fr "samma drag" och att du vljer "Ja" fr Frger, Evenemang, Plats, Runda, r och Mnads instllningar.\nVill du fortstta och ta bort dubletter nd? }
translate W TwinCriteria3 {Det r rekommenderat att du specificerar "Ja" fr tminstonde tv av "samma plats", "samma runda" och "samma r" instllningar.\nVill du fortstta och ta bort dubletter nd?}
translate W TwinCriteriaConfirm {Scid: Bekrfta dublettinstllningar}
translate W TwinChangeTag "ndra fljande partitaggar:\n\n"
translate W AllocRatingDescription "Detta kommando kommer att anvnda den aktuella stavningskontrollfilen fr att lgga till Elo-rating till partier i denna databas. Dr en spelare inte har en aktuell rating men hans/hennes rating vid tiden fr partiet r listat i stavningskontrollfilen, kommer denna rating att lggas till."
translate W RatingOverride "Skriv ver existerande inte-noll rating?"
translate W AddRatings "Lgg till rating till:"
translate W AddedRatings {Scid lade till $r Elo-ratingar i $g partier.}

#Bookmark editor
translate W NewSubmenu "Ny undermeny"

# Comment editor:
translate W AnnotationSymbols  {Symboler:}
translate W Comment {Kommentar:}
translate W InsertMark {Infoga symbol} 
translate W InsertMarkHelp {
Infoga/ta bort markering: Vlj frg, typ av markering samt ruta.
Infoga/ta bort pil: Hger-klicka tv rutor.
}

# Nag buttons in comment editor:
translate W GoodMove {Bra drag}
translate W PoorMove {Dligt drag}
translate W ExcellentMove {Utmrkt drag}
translate W Blunder {Blunder}
translate W InterestingMove {Intressant drag}
translate W DubiousMove {Tveksamt drag}
translate W WhiteDecisiveAdvantage {Vit har en avgrande frdel}
translate W BlackDecisiveAdvantage {Svart har en avgrande frdel}
translate W WhiteClearAdvantage {Vit har en klar frdel}
translate W BlackClearAdvantage {Svart har en klar frdel}
translate W WhiteSlightAdvantage {Vit har en liten frdel}
translate W BlackSlightAdvantage {Svart har en liten frdel}
translate W WhiteCrushing {Vitt har en krossande frdel}
translate W BlackCrushing {Svart har en frkrossande frdel}
translate W Equality {Jmnvikt}
translate W Unclear {Oklar}
translate W Diagram {Diagram}

# Board search:
translate W BoardSearch {Positionsskningar}
translate W FilterOperation {Hantering av aktuellt filter:}
translate W FilterAnd {AND (Restriktivt filter)}
translate W FilterOr {OR (Ackumulativt filter)}
translate W FilterIgnore {IGNORE (Anvnd ej filter)}
translate W SearchType {Sktyp:}
translate W SearchBoardExact {Exakt position (alla pjser p samma rutor)}
translate W SearchBoardPawns {Bnder (samma material, alla bnder p samma rutor)}
translate W SearchBoardFiles {Filer (samma material, alla bnder p samma filer)}
translate W SearchBoardAny {Obestmt (samma material, bnder och pjser p valfria rutor)}
translate W SearchInRefDatabase {Sk i databas}
translate W LookInVars {Sk i variationer}

# Material search:
translate W MaterialSearch {Materialskning}
translate W Material {Material}
translate W Patterns {Stllningar}
translate W Zero {Inga/-en}
translate W Any {Flera}
translate W CurrentBoard {Aktuell stllning}
translate W CommonEndings {Vanliga slutspel}
translate W CommonPatterns {Vanliga stllningar}
translate W MaterialDiff {Skillnad i material}
translate W squares {rutor}
translate W SameColor {Samma frg}
translate W OppColor {Motsatt frg}
translate W Either {Antingen eller}
translate W MoveNumberRange {Dragintervall}
translate W MatchForAtLeast {Trffa minst}
translate W HalfMoves {halvdrag}

# Common endings in material search:
translate W EndingPawns {Bondeslutspel}
translate W EndingRookVsPawns {Torn mot Bonde (Bnder)}
translate W EndingRookPawnVsRook {Torn och 1 Bonde mot Torn}
translate W EndingRookPawnsVsRook {Torn och Bonde (Bnder) mot Torn}
translate W EndingRooks {Torn mot Torn slutspel}
translate W EndingRooksPassedA {Torn mot Torn slutspel med en fri a-bonde}
translate W EndingRooksDouble {Dubbla Torn slutspel}
translate W EndingBishops {Lpare mot Lpare slutspel}
translate W EndingBishopVsKnight {Lpare mot Springare slutspel}
translate W EndingKnights {Springare mot Springare slutspel}
translate W EndingQueens {Dam mot Dam slutspel}
translate W EndingQueenPawnVsQueen {Dam och 1 Bonde mot Dam}
translate W BishopPairVsKnightPair {Tv Lpare mot Tv Springare mittspel}

# Common patterns in material search:
translate W PatternWhiteIQP {Vit Isolerad dambonde}
translate W PatternWhiteIQPBreakE6 {Vit Isolerad dambonde: d4-d5 brott mot e6}
translate W PatternWhiteIQPBreakC6 {Vit Isolerad dambonde: d4-d5 brott mot c6}
translate W PatternBlackIQP {Svart Isolerad dambonde}
translate W PatternWhiteBlackIQP {Vit Isolerad dambonde mot Svart Isolerad dambonde}
translate W PatternCoupleC3D4 {Vit c3+d4 Isolaterat Bondepar}
translate W PatternHangingC5D5 {Svart Hngande Bnder p c5 och d5}
translate W PatternMaroczy {Maroczy Center (med Bnder p c4 och e4)}
translate W PatternRookSacC3 {Tornoffer p c3}
translate W PatternKc1Kg8 {O-O-O mot O-O (Kc1 mot Kg8)}
translate W PatternKg1Kc8 {O-O mot O-O-O (Kg1 mot Kc8)}
translate W PatternLightFian {Ljus-Ruta Fianchetton (Lpare-g2 mot Lpare-b7)}
translate W PatternDarkFian {Mrk-Ruta Fianchetton (Lpare-b2 mot Lpare-g7)}
translate W PatternFourFian {Fyra Fianchetton (Lpare p b2,g2,b7,g7)}

# Game saving:
translate W Today {Idag}
translate W ClassifyGame {Klassificera parti}

# Setup position:
translate W EmptyBoard {Tm brdet}
translate W InitialBoard {Utgngsstllning}
translate W SideToMove {Frg vid draget}
translate W MoveNumber {Antal drag}
translate W Castling {Rockad}
translate W EnPassantFile {En Passant fil}
translate W ClearFen {Rensa FEN}
translate W PasteFen {Klistra in FEN}

translate W SaveAndContinue {Spara och fortstt}
translate W DiscardChangesAndContinue {Ignorera ndringar\noch fortstt}
translate W GoBack {G tillbaka}

# Replace move dialog:
translate W ReplaceMove {Erstt drag}
translate W AddNewVar {Lgg till ny variation}
translate W NewMainLine {Ny huvudvariation}
translate W ReplaceMoveMessage {Det finns redan ett drag i denna stllning.

Du kan erstta detta drag, och frlora samtliga fljande, eller lgga till ditt drag som en ny variation.

(Om du stnger av "Frga fre erstt drag" i Alternativ:Drag menyn slipper du denna frga i framtiden.)}

# Make database read-only dialog:
translate W ReadOnlyDialog {Om du ger denna databas endast lsbar kan du inte gra ngra ndringar i den.
Inga partier kan sparas eller ersttas, och du kan inte ndra flaggor fr raderbara partier.
Alla sorteringsinstllningar eller ECO-klassificeringar kommer att vara temporra.

Du kan gra den skrivbar igen genom att helt enkelt stnga och ppna den igen.

Vill du verkligen ange att databasen endast ska vara lsbar?}

# Clear game dialog:
translate W ClearGameDialog {Detta parti har ndrats.

Vill du verkligen fortstta och frlora ndringarna?
}

# Exit dialog:
translate W ExitDialog {Vill du verkligen avsluta Scid?}
translate W ExitUnsaved {De fljande databaserna har osparade frndringar. Om du avslutar nu, kommer dessa frndringar att g frlorade.} 

# Import window:
translate W PasteCurrentGame {Klistra in aktuellt parti}
translate W ImportHelp1 {Ange eller klistra in ett parti i PGN-format i omrdet ovan.}
translate W ImportHelp2 {Eventuella felaktigheter kommer att anges hr.}
translate W OverwriteExistingMoves {Skriv ver existerande drag ?}

# ECO Browser:
translate W ECOAllSections {alla ECO avdelningar}
translate W ECOSection {ECO avdelning}
translate W ECOSummary {Sammanfattning fr}
translate W ECOFrequency {Underkodsfrekvens fr}

# Opening Report:
translate W OprepReportFor {Anml fr}
translate W OprepTitle {ppningsrapport}
translate W OprepReport {Rapport}
translate W OprepGenerated {Skapad av}
translate W OprepStatsHist {Statistik och historik}
translate W OprepStats {Statistik}
translate W OprepStatAll {Rapporterade partier}
translate W OprepStatBoth {Bda med rating}
translate W OprepStatSince {Sedan}
translate W OprepOldest {De ldsta partierna}
translate W OprepNewest {De yngsta partierna}
translate W OprepPopular {Aktuell popularitet}
translate W OprepFreqAll {Frekvens totalt:   }
translate W OprepFreq1   {Under det senaste ret: }
translate W OprepFreq5   {Under de 5 senaste ren: }
translate W OprepFreq10  {Under de 10 senaste ren: }
translate W OprepEvery {en gng var %u parti}
translate W OprepUp {kat %u%s gentemot samtliga r}
translate W OprepDown {minskat %u%s gentemot samtliga r}
translate W OprepSame {ingen frndring gentemot samtliga r}
translate W OprepMostFrequent {Spelas mest av}
translate W OprepMostFrequentOpponents {Vanligaste motstndaren}
translate W OprepRatingsPerf {Rating och resultat}
translate W OprepAvgPerf {Genomsnittrating och resultat}
translate W OprepWRating {Vits rating}
translate W OprepBRating {Svarts rating}
translate W OprepWPerf {Vits resultat}
translate W OprepBPerf {Svarts resultat}
translate W OprepHighRating {Partierna med hgst genomsnittsrating}
translate W OprepTrends {Resultattrender}
translate W OprepResults {Lngd och frekvens}
translate W OprepLength {Partiets lngd}
translate W OprepFrequency {Frekvens}
translate W OprepWWins {Vita vinster: }
translate W OprepBWins {Svarta vinster: }
translate W OprepDraws {Remier:      }
translate W OprepWholeDB {Hela databasen}
translate W OprepShortest {Kortaste vinster}
translate W OprepMovesThemes {Drag och teman}
translate W OprepMoveOrders {Dragordning fr att n rapportstllningen}
translate W OprepMoveOrdersOne \
  {Stllningen nddes bara genom en dragordning:}
translate W OprepMoveOrdersAll \
  {Det fanns %u dragordningar som ledde fram denna stllning:}
translate W OprepMoveOrdersMany \
  {Det fanns %u dragordningar som ledde fram denna stllning. De %u vanligaste r:}
translate W OprepMovesFrom {Drag frn rapportstllningen}
translate W OprepMostFrequentEcoCodes {De mest frekommande ECO-koderna}
translate W OprepThemes {Positionella teman}
translate W OprepThemeDescription {Temanfrekvens de frsta %u dragen av varje parti}
translate W OprepThemeSameCastling {Rockad p samma flygel}
translate W OprepThemeOppCastling {Rockad p olika flyglar}
translate W OprepThemeNoCastling {Ingen har gjort rockad}
translate W OprepThemeKPawnStorm {Bondestorm p kungsflygeln}
translate W OprepThemeQueenswap {Dambyte}
translate W OprepThemeWIQP {Isolerad vit dambonde} 
translate W OprepThemeBIQP {Isolerad svart dambonde}
translate W OprepThemeWP567 {Vit bonde p 5e/6e/7e raden}
translate W OprepThemeBP234 {Svart bonde p 2a/3e/4e raden}
translate W OprepThemeOpenCDE {ppen c/d/e linje}
translate W OprepTheme1BishopPair {Endast den ena sidan har lparparet}
translate W OprepEndgames {Slutspel}
translate W OprepReportGames {Antal partier i rapporten}
translate W OprepAllGames    {Samtliga partier}
translate W OprepEndClass {Material i slutstllningen}
translate W OprepTheoryTable {Teorisammanstllning}
translate W OprepTableComment {Skapad frn de %u hgst rankade partierna.}
translate W OprepExtraMoves {Ytterligare antal drag i notfrteckningen}
translate W OprepMaxGames {Maximalt antal partier i sammanstllningen}
translate W OprepMergeMoves {Flyttgrns fr sammanslagna spel}
translate W OprepMergeUnique {Sl endast samman unika spel}
translate W OprepViewHTML {Visa HTML}

# Player Report:
translate W PReportTitle {Spelarrapport} 
translate W PReportColorWhite {med de vita pjserna} 
translate W PReportColorBlack {med de svarta pjserna} 
translate W PReportMoves {efter %s} 
translate W PReportOpenings {ppningar} 
translate W PReportClipbase {Tm Clipbase och kopiera liknande partier dit} 

# Piece Tracker window:
translate W TrackerSelectSingle {Vnsterklicka fr att vlja denna pjs.} 
translate W TrackerSelectPair {Vnsterklicka fr att vlja denna pjs; anvnd hger musknapp fr att ocks vlja den relaterade pjsen.}
translate W TrackerSelectPawn {Vnsterklicka fr att vlja denna pjs; anvnd hger musknapp fr att vlja alla tta bnder.}
translate W TrackerStat {Statistik}
translate W TrackerGames {% partier med drag till rutan}
translate W TrackerTime {% tid p varje ruta}
translate W TrackerMoves {Drag}
translate W TrackerMovesStart {Ange vid vilket drag skningen ska brja.}
translate W TrackerMovesStop {Ange vid vilket drag skningen ska sluta.}

# Game selection dialogs:
translate W SelectAllGames {Alla partier i databasen}
translate W SelectFilterGames {Endast partierna i filtret}
translate W SelectTournamentGames {Endast partierna i den aktuella turneringen}
translate W SelectOlderGames {Endast ldre partier}

# Delete Twins window:
translate W TwinsNote {Partier mste minst ha samma spelare fr att kunna identifieras som dubbletter samt uppfylla andra kriterier du kan ange nedan. Nr dubbletter hittas raderas det kortare partiet. Tips: det bsta r att anvnda rttstavningen innan dubblettjmfrelsen eftersom detta frbttrar mjligheten fr upptckt av dubbletter.}
translate W TwinsCriteria {Kriterium: Dubbletter mste ha...}
translate W TwinsWhich {Ange vilka partier som ska jmfras}
translate W TwinsColors {Samma frger?}
translate W TwinsEvent {Samma evenemang?}
translate W TwinsSite {Samma plats?}
translate W TwinsRound {Samma rond?}
translate W TwinsYear {Samma r?}
translate W TwinsMonth {Samma mnad?}
translate W TwinsDay {Samma dag?}
translate W TwinsResult {Samma resultat?}
translate W TwinsECO {Samma ECO-kod?}
translate W TwinsMoves {Samma drag?}
translate W TwinsPlayers {Jmfr spelarnas namn:}
translate W TwinsPlayersExact {Exakt kopia}
translate W TwinsPlayersPrefix {Endast de 4 frsta bokstverna}
translate W TwinsWhen {Nr dubbletter tas bort}
translate W TwinsSkipShort {Ignorera alla partier som r kortare n 5 drag?}
translate W TwinsUndelete {terta alla partier frst?}
translate W TwinsSetFilter {Filtrera alla borttagna dubbletter?}
translate W TwinsComments {Spara alltid partier med kommentarer?}
translate W TwinsVars {Spara alltid partier med variationer?}
translate W TwinsDeleteWhich {Ange vilket parti som ska tas bort:} 
translate W TwinsDeleteShorter {Det kortare partiet} 
translate W TwinsDeleteOlder {Partiet med lgst nummer} 
translate W TwinsDeleteNewer {Partiet med hgst nummer} 
translate W TwinsDelete {Ta bort partier}

# Name editor window:
translate W NameEditType {Typ av namn att redigera}
translate W NameEditSelect {Partier att redigera}
translate W NameEditReplace {Erstt}
translate W NameEditWith {med}
translate W NameEditMatches {Matchar: Tryck Ctrl+1 till Ctrl+9 fr att vlja}

# Check games window:
translate W CheckGames {Kontrollera partier}
translate W CheckGamesWhich {Kontrollera partier}
translate W CheckAll {Alla partier}
translate W CheckSelectFilterGames {Bara partier i filter}

# Classify window:
translate W Classify {Klassificera}
translate W ClassifyWhich {ECO-klassificera vilka partier?}
translate W ClassifyAll {Alla partier (skriv ver gamla ECO-koder)}
translate W ClassifyYear {Alla partier spelade under det senaste ret}
translate W ClassifyMonth {Alla partier spelade den senaste mnaden}
translate W ClassifyNew {Endast partier som nnu ej klassificerats}
translate W ClassifyCodes {ECO-koder som ska anvndas}
translate W ClassifyBasic {Enbart standardkoder ("B12", ...)}
translate W ClassifyExtended {Scidextensioner ("B12j", ...)}
translate W ClassifyResult {ECO-klassificering klar: $resultatspel uppdaterade.}

# Compaction:
translate W NameFile {Namnfil}
translate W GameFile {Partifil}
translate W Names {Namn}
translate W Unused {Ej anvnd}
translate W SizeKb {Storlek (kb)}
translate W CurrentState {Aktuell status}
translate W AfterCompaction {Efter komprimering}
translate W CompactNames {Namn, komprimera namnfil}
translate W CompactGames {Partier, komprimera partifil}
translate W NoUnusedNames "Det finns inga oanvnda namn, s namnfilen r redan fullt komprimerad."
translate W NoUnusedGames "Partifilen r redan fullt komprimerad."
translate W GameFileCompacted {Partifilen fr databasen blev komprimerad.}

# Sorting:
translate W SortCriteria {Kriterium}
translate W AddCriteria {Lgg till kriterium}
translate W CommonSorts {Normal sortering}
translate W Sort {Sortering}

# Exporting:
translate W AddToExistingFile {Lgg till partier till en existerande fil?}
translate W ExportComments {Exportera kommentarer?}
translate W ExportVariations {Exportera variationer?}
translate W IndentComments {Dra in kommentarer?}
translate W IndentVariations {Dra in variationer?}
translate W ExportColumnStyle {Kolumnstil (ett drag per rad)?}
translate W ExportSymbolStyle {Symbolbaserade kommentarer:}
translate W ExportStripMarks {Avlgsna koder fr flt och pilar frn kommentarerna?} 

# Goto game/move dialogs:
translate W LoadGameNumber {Ange partiets nummer:}
translate W GotoMoveNumber {G till drag nummer:}

# Copy games dialog:
translate W CopyAllGames {Kopiera alla spel till}
translate W CopyGames {kopiera partier}
translate W CopyConfirm {
 Vill du verkligen kopiera
 de [::utils::thousands $nGamesToCopy] filtrerade partierna
 ur databasen "$fromName"
 till databasen "$targetName"?
}
translate W CopyErr {Kan ej kopiera partier}
translate W CopyErrSource {klldatabasen}
translate W CopyErrTarget {mldatabasen}
translate W CopyErrNoGames {har inga partier i filtret}
translate W CopyErrReadOnly {kan bara lsas}
translate W CopyErrNotOpen {r ej ppen}

# Colors:
translate W LightSquares {Ljusa flt}
translate W DarkSquares {Mrka flt}
translate W SelectedSquares {Valda flt}
translate W SuggestedSquares {Freslagna flt}
translate W WhitePieces {Vita pjser}
translate W BlackPieces {Svarta pjser}
translate W WhiteBorder {Vit kantlinje}
translate W BlackBorder {Svart kantlinje}

# Novelty window:
translate W FindNovelty {Hitta nyhet}
translate W Novelty {Nyhet}
translate W NoveltyInterrupt {Nyhetsskningen avbrts}
translate W NoveltyNone {Inga nyheter hittades i detta parti}
translate W NoveltyHelp {
Scid kommer att frska hitta det frsta draget som leder till en position som inte annars finns i denna databas eller i spelppingsboken baserad p ECO.
}

# Sounds configuration:
translate W SoundsFolder {Ljudfilskatalog}
translate W SoundsFolderHelp {Katalogen ska ha filerna King.wav, a.wav, 1.wav, etc}
translate W SoundsAnnounceOptions {Instllningar fr Dragannonsering}
translate W SoundsAnnounceNew {Annonsera nya drag nr de grs}
translate W SoundsMoveSoundOnly {Flytta endast ljud (avaktivera meddelanden)}
translate W SoundsAnnounceForward {Annonsera drag nr du gr fram ett drag}
translate W SoundsAnnounceBack {Annonsera drag nr du gr fram eller tillbaka ett drag}
translate W SoundsSoundDisabled {Scid kunde inte hitta Snack-ljudpaketet vid start;\nLjudet r inaktiverat.}

# Upgrading databases:
translate W Upgrading {Uppdaterar}
translate W ConfirmOpenNew {
Denna databas r i ett gammal format (Scid 3) och kan inte ppnas i Scid 4, men en databas i det nya formatet (Scid 4) har redan skapats.

Vill du ppna den senare databasen istllet?
}
translate W ConfirmUpgrade {
Denna databas r i ett gammalt format (Scid 3). En databas i det nyare formatet mste skapas innan den kan anvndas i Scid 4.

Genom att uppdatera skapas en databas i det nya formatet med samma innehll; uppdateringen ndrar ingenting i den gamla databasen.

Detta kan ta ett tag men behver bara gras en gng. Om du tycker att det tar alltfr lng tid kan du avbryta processen.

Vill du uppdatera denna databas nu?
}

# Recent files options:
translate W RecentFilesMenu {Antal senast ppnade filer i Arkivmenyn}
translate W RecentFilesExtra {Antal senast ppnade filer i extra undermeny}

# My Player Names options:
translate W MyPlayerNamesDescription {
Ange en lista p dina favoritspelare hr nedanfr. Skriv ett namn per rad. Jokertecken ("?", t ex, motsvarar ett enstaka tecken medan "*" str fr flera tecken) r tilltna.

Varje gng ett parti med en spelare vars namn str i denna lista ppnas kommer brdet automatiskt att vridas s att partiet visas frn spelarens perspektiv.
} 

#Coach
translate W showblunderexists {visa blunder finns}
translate W showblundervalue {visa blundervrde}
translate W showscore {visa vrdering}
translate W coachgame {trnarparti}
translate W configurecoachgame {konfigurera trnarparti}
translate W configuregame {Konfigurera parti}
translate W Phalanxengine {Phalanx schackmotor}
translate W Coachengine {Trnarschackmotor}
translate W difficulty {svrighetsgrad}
translate W hard {svr}
translate W easy {ltt}
translate W Playwith {Spela med}
translate W white {vit}
translate W black {svart}
translate W both {bda}
translate W Play {Spela}
translate W Noblunder {Ingen blunder}
translate W blunder {blunder}
translate W Noinfo {-- Ingen information --}
translate W PhalanxOrTogaMissing {Phalanx eller Toga hittades inte}
translate W moveblunderthreshold {drag r en blunder om frlust r strre n}
translate W limitanalysis {begrnsa schackmotors analystid}
translate W seconds {sekunder}
translate W Abort {Avbryt}
translate W Resume {Fortstt}
translate W OutOfOpening {utanfr ppning}
translate W NotFollowedLine {Du fljde inte variationen}
translate W DoYouWantContinue {Vill du fortstta ?}
translate W CoachIsWatching {Trnaren observerar}
translate W Ponder {Permanent tnkande}
translate W LimitELO {Begrnsa ELO-styrka}
translate W DubiousMovePlayedTakeBack {Ett tveksamt drag spelades, vill du ta tillbaka det ?}
translate W WeakMovePlayedTakeBack {Ett svagt drag spelades, vill du ta tillbaka det ?}
translate W BadMovePlayedTakeBack {Ett dligt drag spelades, vill du ta tillbaka det ?}
translate W Iresign {Jag ger upp}
translate W yourmoveisnotgood {ditt drag r inte bra}
translate W EndOfVar {Slut p variation}
translate W Openingtrainer {ppningstrnare}
translate W DisplayCM {Visa kandidatdrag}
translate W DisplayCMValue {Visa kandidatdragens vrden}
translate W DisplayOpeningStats {Visa statistik}
translate W ShowReport {Visa rapport}
translate W NumberOfGoodMovesPlayed {bra drag spelade}
translate W NumberOfDubiousMovesPlayed {tveksamma drag spelade}
translate W NumberOfMovesPlayedNotInRepertoire {drag spelade som inte finns i repetoar}
translate W NumberOfTimesPositionEncountered {gnger positionen ptrffats}
translate W PlayerBestMove  {Tillt bara bsta dragen}
translate W OpponentBestMove {Motstndare spelar bsta dragen}
translate W OnlyFlaggedLines {Bara markerade variationer}
translate W resetStats {Nollstll statistik}
translate W Repertoiretrainingconfiguration {Repetoartrnings-konfiguration}
translate W Loadingrepertoire {ppnar repetoar}
translate W Movesloaded {ppnat drag}
translate W Repertoirenotfound {Repetoar hittades inte}
translate W Openfirstrepertoirewithtype {ppna frst en repetoardatabas med ikon/typ angivet p hger sida}
translate W Movenotinrepertoire {Drag finns inte i repetoar}
translate W PositionsInRepertoire {Positioner i repetoar}
translate W PositionsNotPlayed {Positioner inte spelade}
translate W PositionsPlayed {Positioner spelade}
translate W Success {Framgng}
translate W DubiousMoves {Tveksamma drag}
translate W OutOfRepertoire {Utanfr repetoar}
translate W ConfigureTactics {Konfigurera taktik}
translate W ResetScores {Nollstll pong}
translate W LoadingBase {ppnar bas}
translate W Tactics {Taktik}
translate W ShowSolution {Visa lsning}
translate W NextExercise {Nsta vning}
translate W PrevExercise {Tidigare vning}
translate W StopTraining {Avbryt trning}
translate W Next {Nsta}
translate W ResettingScore {Nollstller pong}
translate W LoadingGame {ppnar parti}
translate W MateFound {Matt hittad}
translate W BestSolutionNotFound {Bsta lsningen hittades INTE !}
translate W MateNotFound {Matt hittades inte}
translate W ShorterMateExists {En kortare matt finns}
translate W ScorePlayed {Pong spelad}
translate W Expected {frvntat}
translate W ChooseTrainingBase {Vlj trningsbas}
translate W Thinking {Tnker}
translate W AnalyzeDone {Analys klar}
translate W WinWonGame {Vinn vunnet parti}
translate W Lines {Variationer}
translate W ConfigureUCIengine {Konfigurera UCI-schackmotor}
translate W SpecificOpening {Specifik ppning}
translate W StartNewGame {Starta nytt parti}
translate W FixedLevel {Fast niv}
translate W Opening {ppning}
translate W RandomLevel {Slumpmssig niv}
translate W StartFromCurrentPosition {Starta frn den aktuella positionen}
translate W FixedDepth {Fast skdjup}
translate W Nodes {Noder} 
translate W Depth {Skdjup}
translate W Time {Tid} 
translate W SecondsPerMove {Sekunder per drag}
translate W Engine {Schackmotor}
translate W TimeMode {Tidsmod}
translate W TimeBonus {Tid + bonus}
translate W TimeMin {min}
translate W TimeSec {sek}
translate W AllExercisesDone {Alla vningar gjorda}
translate W MoveOutOfBook {Drag utanfr bok}
translate W LastBookMove {Sista bokdrag}
translate W AnnotateSeveralGames {Kommentera flera partier\nfrn aktuellt till :}
translate W FindOpeningErrors {Hitta ppningsfel}
translate W MarkTacticalExercises {Markera taktiska vningar}
translate W UseBook {Anvnd bok}
translate W MultiPV {Flera variationer}
translate W Hash {Hashminne}
translate W OwnBook {Anvnd schackmotorbok}
translate W BookFile {ppningsbok}
translate W AnnotateVariations {Kommentera variationer}
translate W ShortAnnotations {Korta kommentarer}
translate W addAnnotatorTag {Lgg till kommentator-tagg}
translate W AddScoreToShortAnnotations {Lgg till vrdering till korta kommentarer}
translate W Export {Exportera}
translate W BookPartiallyLoaded {Bok delvis ppnad}
translate W Calvar {Berkning av variationer}
translate W ConfigureCalvar {Konfiguration}
# Opening names used in tacgame.tcl
translate W Reti {Reti}
translate W English {Engelsk}
translate W d4Nf6Miscellaneous {1.d4 Nf6 Diverse}
translate W Trompowsky {Trompowsky}
translate W Budapest {Budapest}
translate W OldIndian {Gammalindisk}
translate W BenkoGambit {Benko-gambit}
translate W ModernBenoni {Modern Benoni}
translate W DutchDefence {Hollndskt frsvar}
translate W Scandinavian {Skandinaviskt}
translate W AlekhineDefence {Alekhines frsvar}
translate W Pirc {Pirc}
translate W CaroKann {Caro-Kann}
translate W CaroKannAdvance {Caro-Kann Avancemang}
translate W Sicilian {Siciliansk}
translate W SicilianAlapin {Siciliansk Alapin}
translate W SicilianClosed {Stngd Siciliansk}
translate W SicilianRauzer {Siciliansk Rauzer}
translate W SicilianDragon {Siciliansk Drake}
translate W SicilianScheveningen {Siciliansk Scheveningen}
translate W SicilianNajdorf {Siciliansk Najdorf}
translate W OpenGame {ppet parti}
translate W Vienna {Wiener}
translate W KingsGambit {Kungsgambit}
translate W RussianGame {Ryskt parti}
translate W ItalianTwoKnights {Italianskt/Tvspringar}
translate W Spanish {Spanskt}
translate W SpanishExchange {Spanskt Avbytesvariant}
translate W SpanishOpen {pett Spanskt}
translate W SpanishClosed {Stngt Spanskt}
translate W FrenchDefence {Franskt Frsvar}
translate W FrenchAdvance {Fransk Avancemang}
translate W FrenchTarrasch {Fransk Tarrasch}
translate W FrenchWinawer {Fransk Winawer}
translate W FrenchExchange {Fransk Avbytesvariant}
translate W QueensPawn {Dambonde}
translate W Slav {Slav}
translate W QGA {Antagen Damgambit}
translate W QGD {Avbjd Damgambit}
translate W QGDExchange {Avbjd Damgambit Avbytesvariant}
translate W SemiSlav {Semi-Slav}
translate W QGDwithBg5 {Avbjd Damgambit med Bg5}
translate W QGDOrthodox {Avbjd Damgambit Ortodox}
translate W Grunfeld {Grnfeld}
translate W GrunfeldExchange {Grnfeld Avbytesvariant}
translate W GrunfeldRussian {Grnfeld Ryskt}
translate W Catalan {Catalan}
translate W CatalanOpen {ppen Catalan}
translate W CatalanClosed {Stngd Catalan}
translate W QueensIndian {Damindiskt}
translate W NimzoIndian {Nimzo-Indiskt}
translate W NimzoIndianClassical {Nimzo-Indiskt Klassiskt}
translate W NimzoIndianRubinstein {Nimzo-Indiskt Rubinstein}
translate W KingsIndian {Kungsindiskt}
translate W KingsIndianSamisch {Kungsindiskt Smisch}
translate W KingsIndianMainLine {Kungsindiskt Huvudvariation}

# FICS
translate W ConfigureFics {Konfigurera FICS}
translate W FICSGuest {Logga in som Gst}
translate W FICSServerPort {Server-port}
translate W FICSServerAddress {IP-adress}
translate W FICSRefresh {Uppdatera}
translate W FICSTimesealPort {Timeseal-port}
translate W FICSSilence {Tystnad}
translate W FICSOffers {Erbjuder}
translate W FICSConsole {Konsol}
translate W FICSGames {Partier}
translate W FICSUnobserve {Sluta observera parti}
translate W FICSProfile {Visa din historik och profil}
translate W FICSRelayedGames {terutsnda partier}
translate W FICSFindOpponent {Hitta motstndare}
translate W FICSTakeback {Ta tillbaka}
translate W FICSTakeback2 {Ta tillbaka 2}
translate W FICSInitTime {Initialtid (minuter)}
translate W FICSIncrement {Inkrementering (sekunder)}
translate W FICSRatedGame {Ratingparti}
translate W FICSAutoColour {automatisk}
translate W FICSManualConfirm {bekrfta manuellt}
translate W FICSFilterFormula {Filtrera med formel}
translate W FICSIssueSeek {Skfrga}
translate W FICSChallenge {Utmana}
translate W FICSAccept {acceptera}
translate W FICSDecline {avbj}
translate W FICSColour {frg}
translate W FICSSend {skicka}
translate W FICSConnect {Anslut}
translate W FICSdefaultuservars {Anvnd standardvariabler}
translate W FICSObserveconfirm {Vill du observera parti} 
translate W FICSpremove {Aktivera premove}
translate W FICSObserve {Observera}
translate W FICSRatedGames {Klassade spel}
translate W FICSUnratedGames {Oklassade spel}
translate W FICSRated {Betygsatt}
translate W FICSUnrated {Ej betygsatt}
translate W FICSRegisteredPlayer {Endast registrerade spelare}
translate W FICSFreePlayer {Endast gratis spelare}
translate W FICSNetError {Ntverksfel\Kan inte ansluta till}

# Game review
translate W GameReview {Partiversikt}
translate W GameReviewTimeExtended {Utkad tid}
translate W GameReviewMargin {Felmarginal}
translate W GameReviewAutoContinue {Fortstt automatiskt nr drag r korrekt}
translate W GameReviewReCalculate {Anvnd utkad tid}
translate W GameReviewAnalyzingMovePlayedDuringTheGame {Analysera drag spelat under partiet}
translate W GameReviewAnalyzingThePosition {Analysera positionen}
translate W GameReviewEnterYourMove {Ange ditt drag}
translate W GameReviewCheckingYourMove {Kontrollerar ditt drag}
translate W GameReviewYourMoveWasAnalyzed {Ditt drag analyserades}
translate W GameReviewYouPlayedSameMove {Du speladade samma drag som i partiet}
translate W GameReviewScoreOfYourMove {Vrdering av ditt drag}
translate W GameReviewGameMoveScore {Partidragets vrdering}
translate W GameReviewEngineScore {Schackmotorns vrdering}
translate W GameReviewYouPlayedLikeTheEngine {Du spelade som schackmotorn}
translate W GameReviewNotEngineMoveButGoodMove {Inte schackmotordraget, men det r ocks ett bra drag}
translate W GameReviewMoveNotGood {Detta drag r inte bra, vrderingen r}
translate W GameReviewMovesPlayedLike {Drag spelade som}
translate W GameReviewMovesPlayedEngine {Drag apelade som schackmotorn}

# Correspondence Chess Dialogs:
translate W CCDlgCGeneraloptions {Generella instllningar}
translate W CCDlgLoginName  {Inloggningsnamn:}
translate W CCDlgPassword   {Lsenord:}
translate W CCDlgShowPassword {Visa lsenord}

# Connect Hardware dialogs
translate W ExtHWConfigConnection {Konfigurera extern hrdvara}
translate W ExtHWPort {Port}
translate W ExtHWEngineCmd {Schackmotorkommando}
translate W ExtHWEngineParam {Schackmotorparameter}
translate W ExtHWShowButton {Visa knapp}
translate W ExtHWHardware {Hrdvara}
translate W ExtHWNovag {Novag Citrine}
translate W ExtHWInputEngine {Inmatningsschackmotor}
translate W ExtHWNoBoard {Inget brde}
translate W NovagReferee {Nedteckna bara dragen}

# Input Engine dialogs
translate W IEConsole {Inmatningsschackmotorkonsol}
translate W IESending {Drag skickade fr}
translate W IESynchronise {Synkronisera}
translate W IERotate  {Rotera}
translate W IEUnableToStart {Kunde inste starta Inmatningsschackmotor:}

# Calculation of Variations
translate W DoneWithPosition {Klar med position}

translate W Board {Brde}
translate W showGameInfo {Visa partiinformation}
translate W autoResizeBoard {ndra storleken p brdet automatiskt}
translate W DockTop {Drag verst}
translate W DockBottom {Drag nederst}
translate W DockLeft {Drag till vnster}
translate W DockRight {Drag till hger}
translate W Undock {Avdocka}

# Switcher window
translate W AboutDatabase {Om denna databas}
translate W ChangeIcon {ndra ikon...}
translate W NewGameListWindow {Nytt spellistafnster}
translate W LoadatStartup {Ladda vid start}

# Gamelist window
translate W ShowHideDB {Visa/dlj databaser}
translate W ChangeFilter {Byt filter}
translate W ChangeLayout {Ladda/Spara/ndra sorteringskriterier och kolumnlayout}
translate W ShowHideStatistic {Visa/dlj statistik}
translate W BoardFilter {Visa endast spel som matchar den aktuella brdpositionen}
translate W CopyGameTo {Kopiera spelet till}
translate W FindBar {Hitta Bar}
translate W FindCurrentGame {Hitta aktuellt spel}
translate W DeleteGame {Ta bort spelet}
translate W UndeleteGame {terstll spel}
translate W ResetSort {terstll sortering}

translate W ConvertNullMove {Konvertera null-drag till kommentarer}
translate W SetupBoard {Installationsbrda}
translate W Rotate {Rotera}
translate W SwitchColors {Byt frger}
translate W FlipBoard {Bldderbrda}
translate W ImportPGN {Importera PGN-spel}
translate W ImportingFiles {Importera PGN-filer till}
translate W ImportingFrom {Importerar frn}
translate W ImportingIn {Importera spel till}
translate W UseLastTag {Anvnd sista\nspelets taggar}
translate W Random {Slumpmssig}
translate W BackToMainline {G tillbaka till huvudlinjen}
translate W LeaveVariant {Lmna variant}
translate W Autoplay {Autouppspelning}
translate W ShowHideCoords {Visa/dlj koordinat.}
translate W ShowHideEvalBar {Visa/dlj utvrderingsfltet}
translate W ShowHideMaterial {Visa/dlj material}
translate W SelectMarker {Vlj Markr}
translate W FullScreen {Helskrm}
translate W FilterStatistic {Filtrera statistik}
translate W MakeCorrections {Gr korrigeringar}
translate W Surnames {Efternamn}
translate W Ambiguous {Tvetydig}

#Preferences Dialog
translate W OptionsToolbar "Verktygsflt"
translate W OptionsBoard "Brdet"
translate W OptionsBoardSize "Brdstorlek"
translate W OptionsBoardPieces "Pjsutseende"
translate W OptionsInternationalization "Internationalisering"
translate W OptionsTablebaseDir "Vlj upp till 4 tabellbasmappar:"

# Evaluation bar
translate W BestMoveArrow "Bsta flytta pilen"
translate W NewLocalEngine "+ Ny motor..."

# Batch Annotate
translate W BatchAnnotate {Batchkommentar}
translate W BatchEngineSelection {Motorval}
translate W BatchChessEngine {Schackmotor:}
translate W BatchNumberOfInstances {Antal instanser:}
translate W BatchGameReview {Spelrecension}
translate W BatchTimePerMove {Tid per drag (sek):}
translate W BatchAnnotateBlunders {Anteckna bara misstag}
translate W BatchBlunderThreshold {Blunder tröskel:}
translate W BatchVariationLength {Variationslängd (rörelser):}
translate W BatchOpeningBook {Öppningsbok}
translate W BatchUseBook {Använd bok}
translate W BatchAnnotateVariations {Anteckna varianter}
translate W BatchShortAnnotations {Korta anteckningar}
translate W BatchAddScoreToShort {Lägg till poäng till korta kommentarer}
translate W BatchClearOld {Rensa gamla kommentarer och varianter}
translate W BatchInitializingEngines {Initierar motorer...}
translate W BatchAnalyzingGames {Analyserar spel...}
translate W BatchProgress {Batch Annotera Framsteg}
translate W BatchComplete {Batch-anteckning klar!}
translate W BatchCancelled {Batch-anteckning avbröts}
}
# end of english.tcl
