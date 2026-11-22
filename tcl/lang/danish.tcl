# Danish interface translations. Follow the entry order in english.tcl.
proc setLanguage_d {} {

# File menu:
menuText d File "Fil" 0
menuText d FileNew "Ny..." 0 {Opret en ny Scid-database}
menuText d FileOpen "Åbn..." 0 {Åbn en eksisterende Scid-database}
menuText d FileClose "Luk" 0 {Luk den aktive database}
menuText d FileFinder "Find filer" 0 {Find databaser og partifiler}
menuText d FileBookmarks "Bogmærker" 0 {Vis bogmærker}
menuText d FileBookmarksAdd "Tilføj bogmærke" 0 {Gem et bogmærke til partiet og den aktuelle stilling}
menuText d FileBookmarksFile "Placér bogmærke" 0 {Gem et bogmærke til partiet og stillingen i en mappe}
menuText d FileBookmarksEdit "Rediger bogmærker..." 0 {Rediger bogmærker og mapper}
menuText d FileBookmarksList "Vis mapper som en liste" 4 {Vis bogmærkemapperne samlet i én liste}
menuText d FileBookmarksSub "Vis mapper som undermenuer" 15 {Vis hver bogmærkemappe som en undermenu}
menuText d FileMaint "Vedligeholdelse" 0 {Vedligehold Scid-databasen}
menuText d FileMaintWin "Vedligeholdelsesvindue" 0 {Åbn eller luk vinduet til databasevedligeholdelse}
menuText d FileMaintCompact "Komprimer database..." 0 {Fjern slettede partier og ubrugte navne fra databasefilerne}
menuText d FileMaintClass "ECO-klassificer partier..." 0 {Beregn ECO-koden for hvert parti i databasen}
menuText d FileMaintSort {Sorter database...} 0 {Sorter alle partier i databasen}
menuText d FileMaintDelete "Markér dubletter til sletning..." 0 {Find partier, der optræder flere gange, og markér dubletterne til sletning}
menuText d FileMaintTwin "Kontrollér dubletter" 11 {Åbn eller opdater vinduet til sammenligning af dubletter}
menuText d FileMaintName "Navnekontrol" 0 {Rediger navne og kontrollér stavningen}
menuText d FileMaintNameEditor "Rediger navne" 8 {Åbn eller luk vinduet til redigering af navne}
menuText d FileMaintNamePlayer "Kontrollér spillernavne..." 11 {Kontrollér spillernavne ved hjælp af navnelisten}
menuText d FileMaintNameEvent "Kontrollér turneringsnavne..." 0 {Kontrollér turneringsnavne ved hjælp af navnelisten}
menuText d FileMaintNameSite "Kontrollér spillesteder..." 1 {Kontrollér navnene på spillesteder ved hjælp af navnelisten}
menuText d FileMaintNameRound "Kontrollér rundenavne..." 11 {Kontrollér rundenavne ved hjælp af navnelisten}
menuText d FileReadOnly "Skrivebeskyttelse..." 0 {Beskyt den aktive database mod ændringer}
menuText d FileSwitch "Skift database" 1 {Skift til en anden åben database}
menuText d FileOpenLichessTournament "Åbn Lichess-turnering" 4 {Hent og åbn partier fra en direkte udsendelse på Lichess}
menuText d FileImportLichess "Importer fra Lichess" 0 {Importer partier fra din Lichess-konto}
menuText d FileImportChessCom "Importer fra Chess.com" 13 {Importer partier fra din Chess.com-konto}
menuText d FileExit "Afslut" 0 {Afslut Scid}
menuText d FileMaintFixBase {Reparer database} 0 {Forsøg at reparere en beskadiget database}

# Edit menu:
menuText d Edit "Rediger" 0
menuText d EditAdd {Tilføj variant} 8 {Tilføj en variant ved dette træk}
menuText d EditDelete "Slet variant" 0 {Slet en variant ved dette træk}
menuText d EditFirst {Gør til første variant} 8 {Flyt varianten øverst på listen}
menuText d EditMain {Gør variant til hovedvariant} 0 {Brug varianten som hovedvariant}
menuText d EditTrial {Afprøv variant} 13 {Slå prøvetilstand til eller fra for at afprøve en idé på brættet}
menuText d EditStrip "Fjern fra partiet" 1 {Fjern kommentarer, varianter eller træk fra partiet}
menuText d EditUndo "Fortryd" 0 {Fortryd den seneste ændring i partiet}
menuText d EditRedo "Gentag" 0 {Gentag den senest fortrudte ændring}
menuText d EditStripComments "Kommentarer" 0 {Fjern alle kommentarer og træksymboler fra partiet}
menuText d EditStripCommentsNotAnnos "Fjern kommentarer, behold træksymboler" 6 {Fjern kommentarerne, men behold partiets træksymboler}
menuText d EditStripVars "Varianter" 0 {Fjern alle varianter fra partiet}
menuText d EditStripAll "Kommentarer og varianter" 15 {Fjern alle kommentarer, træksymboler og varianter fra partiet}
menuText d EditStripBegin "Træk fra begyndelsen" 0 {Fjern trækkene før den aktuelle stilling}
menuText d EditStripEnd "Træk til slutningen" 9 {Fjern de resterende træk fra den aktuelle stilling}
menuText d EditReset "Tøm udklipsdatabasen" 4 {Fjern alle partier fra udklipsdatabasen}
menuText d EditCopy "Kopiér partiet til udklipsdatabasen" 4 {Gem en kopi af partiet i udklipsdatabasen}
menuText d EditPaste "Indsæt parti fra udklipsdatabasen" 2 {Indsæt det aktive parti fra udklipsdatabasen her}
menuText d EditPastePGN "Indsæt tekst som PGN-parti..." 7 {Indsæt teksten fra udklipsholderen som et parti i PGN-format}
menuText d EditNullMove "Nultræk" 0 {Spring et træk over ved at indsætte et nultræk}
menuText d EditSetup "Opstil startstilling..." 0 {Vælg partiets startstilling}
menuText d EditCopyBoard "Kopiér stilling" 0 {Kopiér den aktuelle stilling til udklipsholderen i FEN-format}
menuText d EditPasteBoard "Indsæt startstilling" 0 {Brug stillingen fra udklipsholderen som partiets startstilling}
menuText d ConfigureScid "Indstillinger..." 0 {Tilpas Scid}

# Game menu:
menuText d Game "Parti" 0
menuText d GameNew "Nyt parti" 0 {Begynd på et tomt parti}
menuText d GameFirst "Hent første parti" 5 {Hent det første parti i filteret}
menuText d GamePrev "Hent forrige parti" 7 {Hent det forrige parti i filteret}
menuText d GameReload "Genindlæs partiet" 0 {Hent partiet igen, og kassér ændringerne}
menuText d GameNext "Hent næste parti" 6 {Hent det næste parti i filteret}
menuText d GameLast "Hent sidste parti" 5 {Hent det sidste parti i filteret}
menuText d GameRandom "Hent tilfældigt parti" 5 {Hent et tilfældigt parti i filteret}
menuText d GameNumber "Hent parti efter nummer..." 5 {Indtast nummeret på det parti, du vil hente}
menuText d GameReplace "Gem ændringer..." 4 {Erstat den gemte udgave af partiet}
menuText d GameAdd "Gem som nyt parti..." 1 {Gem partiet som et nyt parti i databasen}
menuText d GameDelete "Skift slettemarkering" 1 {Tilføj eller fjern partiets slettemarkering}
menuText d GameDeepest "Identificer åbning" 0 {Gå til den sidste stilling i partiet, der findes i ECO-bogen}
menuText d GameGotoMove "Gå til træknummer..." 1 {Gå til et bestemt træk i partiet}
menuText d GameNovelty "Find nyhed..." 6 {Find det første træk i partiet, der ikke er spillet før}
menuText d PlayTournament "Spil motorturnering..." 5 {Lad skakmotorer spille en turnering}

# Search Menu:
menuText d Search "Søg" 0
menuText d SearchReset "Nulstil filter" 0 {Vis alle partier igen}
menuText d SearchNegate "Vend filteret om" 0 {Vis de partier, som filteret hidtil har udeladt}
menuText d SearchCurrent "Aktuel stilling..." 0 {Søg efter den aktuelle brætstilling}
menuText d SearchHeader "Partioplysninger..." 0 {Søg efter spillere, turnering, dato og andre partioplysninger}
menuText d SearchMaterial "Materiale eller mønster..." 0 {Søg efter materiale eller mønstre på brættet}
menuText d SearchMoves "Træk..." 0 {Søg efter en trækfølge i hovedvarianten}
menuText d SearchCQL "CQL-søgning..." 0 {Søg med en forespørgsel i Chess Query Language}
menuText d SearchComments "Søg i kommentarer..." 0 {Søg i kommentarerne til partierne i filteret}
menuText d SearchUsing {Brug søgefil...} 2 {Søg med en fil med søgeindstillinger}

# Windows menu:
menuText d Windows "Vinduer" 0
menuText d WindowsComment "Rediger kommentarer" 0 {Åbn eller luk vinduet til redigering af kommentarer}
menuText d WindowsGList "Partiliste" 0 {Åbn eller luk partilisten}
menuText d WindowsPGN "PGN-vindue" 1 {Åbn eller luk vinduet med partinotationen}
menuText d WindowsPList "Find spiller" 0 {Åbn eller luk spillersøgningen}
menuText d WindowsTmt "Find turnering" 5 {Åbn eller luk turneringssøgningen}
menuText d WindowsSwitcher "Databaseskifter" 0 {Åbn eller luk databaseskifteren}
menuText d WindowsMaint {Vedligeholdelsesvindue} 0 {Åbn eller luk vedligeholdelsesvinduet}
menuText d WindowsECO "ECO-oversigt" 0 {Åbn eller luk oversigten over ECO-åbningskoder}
menuText d WindowsStats "Filterstatistik" 0 {Åbn eller luk statistikken for partierne i filteret}
menuText d WindowsTree "Åbningstræ" 0 {Åbn eller luk åbningstræet}
menuText d WindowsBook "Åbningsbog" 1 {Åbn eller luk vinduet med åbningsbogen}
menuText d WindowsCorrChess {Korrespondanceskak} 12 {Åbn eller luk vinduet til korrespondanceskak}
menuText d WindowsGraph "Analysegraf" 1 {Vis tidsforbrug og vurdering for hvert træk}
menuText d WindowsPresentationBoard "Demonstrationsbræt" 2 {Vis brættet i et separat vindue til en projektor eller en ekstra skærm}
menuText d WindowsPresentationFreeze "Frys demonstrationsbrættet" 2 {Sæt visningen på pause, eller lad den følge hovedbrættet igen}
translate d PresentationFrozen {Fastlåst – demonstrationsbrættet følger ikke med}

menuText d WindowsEPD "EPD-vindue..." 5 {Åbn et vindue til redigering af stillinger i EPD-format}

# EPD window:
translate d EpdPasteAnal {Indsæt analyse}
translate d EpdSortOpcodes {Sorter operationskoder}
translate d EpdAddPosition {Tilføj stilling}
translate d EpdFindPos {Find stilling i partiet}
translate d EpdAnalPosition {Analysér stillinger...}
translate d EpdStripOpcodes {Fjern operationskoder...}
translate d EpdAnnotateTime {Sekunder pr. stilling}
translate d EpdCountBestMoves {Tæl bedste træk}
translate d EpdSaveLog {Gem resultater i fil}
# EPD headless analysis: status text and the reasons the session reports.
# The EpdEngine* strings are fragments shown after the "%s" above them.
translate d EpdAnalysisTitle {EPD-analyse}
translate d EpdAnalysisRunning {En anden EPD-analyse kører allerede.}
translate d EpdAnalysisMinTime {Analysetiden skal være mindst ét sekund.}
translate d EpdAnalysisStartFailed {Kunne ikke starte skakmotoren: %s}
translate d EpdAnalysisError {Fejl i EPD-analyse: %s}
translate d EpdAnalysisStopped {Analysen er stoppet.}
translate d EpdAnalysisStopping {Stopper...}
translate d EpdEngineNotStarted {motoren startede ikke søgningen}
translate d EpdEngineNoResult {motoren returnerede intet resultat}
translate d EpdSearchAlreadyRunning {en søgning kører allerede}
translate d EpdNoEngineConfigured {ingen skakmotor er konfigureret}
translate d EpdOnlyUci {Kun UCI-motorer understøttes}
translate d EpdEngineDisconnected {forbindelsen til motoren blev afbrudt}
translate d EpdEngineNoAnswer {motoren svarede ikke}
translate d EpdDontSave {Gem ikke}
translate d EpdReadOnly {skrivebeskyttet}
translate d EpdAltered {ændret}
translate d EpdNoMoves {ingen træk}
translate d positions {stillinger}
translate d EpdDeleteRow {Slet række}
translate d EpdCloseWarning {EPD-filen er ændret.\nVil du gemme den?}
translate d EpdDeletePosition {Slet stilling}
translate d EpdCopyRecord {Kopiér post}
translate d EpdPasteRecord {Indsæt post}

# Tools menu:
menuText d Tools "Værktøjer" 1
menuText d ToolsConfigureEngines "Indstil skakmotorer" 0 {Rediger indstillingerne for skakmotorerne}
menuText d ToolsEngineWindow {Motorvindue...} 10 {Åbn et vindue med en skakmotor}
menuText d ToolsCross "Krydstabel" 0 {Vis krydstabellen for partiets turnering}
menuText d ToolsFilterGraph "Filtergraf med relative værdier" 0 {Åbn eller luk filtergrafen med relative værdier}
menuText d ToolsAbsFilterGraph "Filtergraf med absolutte værdier" 15 {Åbn eller luk filtergrafen med absolutte værdier}
menuText d ToolsOpReport "Åbningsrapport" 0 {Lav en åbningsrapport for den aktuelle stilling}
menuText d ToolsOpenBaseAsTree "Åbn database som åbningstræ..." 4 {Brug en database som åbningstræ}
menuText d ToolsOpenRecentBaseAsTree "Åbn seneste database som åbningstræ" 4 {Brug en nyligt åbnet database som åbningstræ}
menuText d ToolsTracker "Spor brikker" 1 {Se, hvilke felter en brik har stået på}
menuText d ToolsTraining "Træning" 1 {Træn taktik og åbninger}
menuText d ToolsPlayVsEngine "Spil mod en skakmotor" 5 {Spil et parti mod en skakmotor}
menuText d ToolsTrainOpenings "Åbninger" 0 {Træn med et åbningsrepertoire}
menuText d ToolsTrainTactics "Taktik" 0 {Løs taktikopgaver}
menuText d ToolsTrainFindBestMove {Find bedste træk} 0 {Find bedste træk}
menuText d ToolsTrainFics "Spil på FICS" 5 {Spil skak på freechess.org}
menuText d ToolsEngineTournament {Motorturnering} 9 {Start en turnering mellem skakmotorer}
menuText d ToolsTimeAnalysis {Tidsanalyse} 0 {Vis en graf over tidsforbruget i partiet}
menuText d ToolsBookTuning "Rediger åbningsbog" 0 {Rediger trækkene i åbningsbogen}
menuText d ToolsCtgConvert "Konvertér CTG til OBR..." 0 {Konvertér en ChessBase-åbningsbog i CTG-format til OpenBook Rich (.obr)}
menuText d ToolsRapidAnnotate "Kommentér ud fra vurderingsgrafen" 2 {Føj motorens vurderinger og træksymboler fra grafen til partiet (Ctrl+Shift+A)}
menuText d ToolsDownloadTWIC "Hent partier fra TWIC" 0 {Hent de nyeste partier fra The Week in Chess (TWIC)}
menuText d ToolsConnectHardware "Tilslut udstyr" 0 {Tilslut eksternt udstyr}
menuText d ToolsConnectHardwareConfigure "Indstillinger..." 0 {Indstil det eksterne udstyr og forbindelsen til det}
menuText d ToolsConnectHardwareNovagCitrineConnect "Tilslut Novag Citrine" 8 {Forbind Novag Citrine med Scid}
menuText d ToolsConnectHardwareInputEngineConnect "Tilslut inputmotor" 0 {Forbind en inputmotor til f.eks. et DGT-bræt med Scid}

menuText d ToolsPInfo "Spilleroplysninger" 0 {Åbn eller opdater oplysninger om spilleren}
menuText d ToolsPlayerReport "Spillerrapport..." 5 {Lav en rapport om en spiller}
menuText d ToolsRating "Ratingudvikling" 6 {Vis ratingudviklingen for begge spillere i partiet}
menuText d ToolsExpCurrent "Eksporter det aktuelle parti" 10 {Skriv det aktuelle parti til en tekstfil}
menuText d ToolsExpCurrentPGN "Eksporter som PGN..." 14 {Gem partiet i PGN-format}
menuText d ToolsExpCurrentHTML "Eksporter som HTML..." 0 {Gem partiet som en HTML-fil}
menuText d ToolsExpCurrentHTMLJS "Eksporter som HTML med JavaScript..." 23 {Gem partiet som en interaktiv HTML-fil med JavaScript}
menuText d ToolsExpCurrentRTF "Eksporter som RTF..." 10 {Gem partiet i RTF-format med formaterede kommentarer}
menuText d ToolsExpFilter "Eksporter alle partier i filteret" 0 {Skriv alle partier i filteret til en tekstfil}
menuText d ToolsExpFilterPGN "Eksporter som PGN..." 14 {Gem partierne i filteret i PGN-format}
menuText d ToolsExpFilterHTML "Eksporter som HTML..." 0 {Gem partierne i filteret som en HTML-fil}
menuText d ToolsExpFilterHTMLJS "Eksporter som HTML med JavaScript..." 23 {Gem partierne i filteret som en interaktiv HTML-fil med JavaScript}
menuText d ToolsExpFilterRTF "Eksporter som RTF..." 10 {Gem partierne i filteret i RTF-format med formaterede kommentarer}
menuText d ToolsImportOne {Importer ét PGN-parti...} 0 {Importer et parti fra PGN-tekst}
menuText d ToolsImportFile "Importer partier fra PGN-filer..." 0 {Vælg en database til partierne fra en eller flere PGN-filer}
menuText d FileImportRTF "Importer RTF-parti..." 9 {Importer et parti fra en RTF-fil oprettet med Scid}
menuText d ToolsStartEngine1 "Start motor 1" 12 {Start den første skakmotor}
menuText d ToolsStartEngine2 "Start motor 2" 12 {Start den anden skakmotor}
menuText d ToolsCaptureBoard {Tag billede af brættet...} 16 {Gem den aktuelle brætstilling som et billede.}

# Play menu
menuText d Play "Spil" 2
menuText d LichessPuzzles "Taktikopgaver fra Lichess" 0 {Løs taktikopgaver fra Lichess ved at spille trækkene på brættet}
menuText d Woodpecker "Spættemetoden" 0 {Løs de samme taktikopgaver i flere omgange, hurtigere hver gang}

# --- Correspondence Chess
menuText d CCResign {Opgiv} 0 {Opgiv partiet (undtagen via e-mail)}
menuText d CCClaimDraw {Kræv remis} 0 {Send træk, og kræv remis (undtagen via e-mail)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText d Options "Indstillinger" 1
menuText d OptionsBoardGraphics {Felter...} 0 {Vælg teksturer til felterne}
translate d OptionsBGW {Vælg tekstur til felterne}
translate d OptionsBoardGraphicsText {Vælg billedfiler til de lyse og mørke felter:}
menuText d OptionsBoardNames "Mine spillernavne..." 0 {Rediger de navne, du spiller under}
menuText d OptionsExport "Eksport" 0 {Vælg den tekst, der skal med ved eksport}
menuText d OptionsExportPGNText "Tekst i PGN-filer" 8
menuText d OptionsExportHTMLText "Tekst i HTML-filer" 8
menuText d OptionsFonts {Skrifttyper} 4 {Skift skrifttyper}
menuText d OptionsFontsRegular {Normal} 2 {Skift den normale skrifttype}
menuText d OptionsFontsMenu {Menu} 0 {Skift menuernes skrifttype}
menuText d OptionsFontsSmall {Lille} 0 {Skift den lille skrifttype}
menuText d OptionsFontsTiny {Meget lille} 4 {Skift den mindste skrifttype}
menuText d OptionsFontsFixed {Fast bredde} 0 {Skift skrifttypen med fast tegnbredde}
menuText d OptionsGInfo {Partioplysninger} 13 {Indstillinger for partioplysninger}
menuText d OptionsLanguage "Sprog" 0 {Vælg sproget i brugerfladen}
menuText d OptionsMovesTranslatePieces {Oversæt brikbogstaver} 6 {Brug lokale bogstaver for brikkerne}
menuText d OptionsMovesHighlightLastMove {Fremhæv seneste træk} 4 {Fremhæv seneste træk}
menuText d OptionsMovesHighlightLastMoveDisplay {Markér felt} 0 {Fremhæv felterne for det seneste træk}
menuText d OptionsMovesHighlightLastMoveWidth {Bredde} 0 {Stregtykkelse}
menuText d OptionsMovesHighlightLastMoveColor {Farve} 0 {Stregfarve}
menuText d OptionsMovesHighlightLastMoveArrow {Vis pil} 2 {Vis en pil ved fremhævning}
menuText d OptionsMovesHighlightLastMoveNag {Vis kommentarsymboler} 2
menuText d OptionsMovesHighlightLastMoveEval {Vis vurderingssymboler} 2
menuText d OptionsMoves {Træk} 0 {Indstillinger for trækindtastning}
menuText d OptionsGamelist {Partiliste} 0 {Indstillinger for partilisten}
menuText d OptionsMovesAnimate {Animationsvarighed} 1 {Angiv, hvor længe et træk animeres}
menuText d OptionsMovesDelay {Pause ved gennemspilning...} 2 {Angiv pausen mellem trækkene ved automatisk gennemspilning}
menuText d OptionsMovesCoord {Indtast træk med koordinater} 0 {Tillad trækindtastning med koordinater (f.eks. "g1f3")}
menuText d OptionsMovesSuggest {Vis mulige træk} 2 {Fremhæv mulige målfelter, når markøren er over en brik}
menuText d OptionsShowVarPopup {Vis variantvindue} 2 {Slå visning af variantvinduet til eller fra}
menuText d OptionsRepetitionAlert {Besked om stillingsgentagelse} 0 {Vælg, hvordan gentagne stillinger vises}
menuText d OptionsRepetitionOff {Fra} 0 {Giv ingen besked ved gentagelser}
menuText d OptionsRepetitionBanner {Banner} 0 {Vis et banner, som forsvinder af sig selv}
menuText d OptionsRepetitionDialog {Dialogboks} 0 {Vis en dialogboks, som skal lukkes}
translate d RepetitionTwice {Anden forekomst af stillingen}
translate d RepetitionThreefold {Remis ved tre gange samme stilling}
menuText d OptionsMovesSpace {Tilføj mellemrum efter træknummeret} 0 {Tilføj mellemrum efter træknummeret}
menuText d OptionsMovesLichess {Brug Lichess-/ChessBase-format til kommentarer} 5 {Brug Lichess-/ChessBase-format til feltmarkeringer og pile}
menuText d OptionsMovesKey {Fuldfør træk ved indtastning} 11 {Slå automatisk fuldførelse af indtastede træk til eller fra}
menuText d OptionsMovesShowVarArrows {Vis pile for partiets varianter} 2 {Slå pile for varianttræk til eller fra}
menuText d OptionsMovesShowEngineVariationArrows {Vis motorpile for flere varianter} 2 {Vis pile for motorens varianter i MultiPV-tilstand}
menuText d OptionsMovesGlossOfDanger {Farvemarkér trusler} 0 {Slå farvemarkering af trusler til eller fra}
translate d OptionsGlistWheelRows {Rækker pr. hak på musehjulet}
translate d OptionsMovesTreeDepth {Antal halvtræk i trævinduet som standard}
translate d OptionsMovesEnginePvLength {Længde af viste motorvarianter}
translate d OptionsMovesEngineHistory {Vis motorens søgehistorik}
menuText d OptionsNumbers {Talformat} 0 {Vælg talformat}
menuText d OptionsTheme "Tema" 0 {Skift brugerfladens udseende}
menuText d OptionsWindows {Vinduer} 0 {Vinduesindstillinger}
menuText d OptionsSounds {Lyde} 0 {Indstil lyde til oplæsning af træk}
menuText d OptionsResources "Ressourcer..." 0 {Vælg ressourcefiler og mapper}
menuText d OptionsWindowsDock "Fastgør vinduer" 5 {Fastgør vinduer i hovedvinduet (kræver genstart)}
menuText d OptionsWindowsSaveLayout "Gem vindueslayout" 4 {Gem den aktuelle placering af vinduerne}
menuText d OptionsWindowsRestoreLayout "Gendan vindueslayout" 2 {Gendan en gemt placering af vinduerne}
menuText d OptionsLayoutDefault "1 (standard)" 0
menuText d OptionsWindowsShowGameInfo "Vis partioplysninger" 0 {Vis oplysninger om det aktuelle parti}
menuText d OptionsWindowsAutoLoadLayout {Indlæs automatisk første layout} 7 {Indlæs automatisk første layout ved opstart}
menuText d OptionsECO {ECO-fil} 0 {Indlæs filen med ECO-klassifikationer}
menuText d OptionsSpell {Navnefil} 5 {Indlæs Scids fil til navnekontrol}
menuText d OptionsTable {Mappe med slutspilsdatabaser} 8 {Vælg en slutspilsdatabasefil. Alle slutspilsdatabaser i mappen bruges}
menuText d OptionsRecent {Seneste filer} 12 {Vælg, hvor mange seneste filer der vises i menuen Fil}
menuText d OptionsBooksDir {Mappe med åbningsbøger} 11 {Vælg mappen med åbningsbøger}
menuText d OptionsTacticsBasesDir {Mappe med træningsdatabaser} 22 {Vælg mappen med databaser til taktiktræning}
menuText d OptionsPhotosDir {Billedmappe} 8 {Vælg mappen med spillerbilleder}
menuText d OptionsThemeDir {Temafil} 0 {Indlæs en fil med temaer til brugerfladen}
translate d OptionsThemeOmarchy {Følg Omarchys tema}
menuText d OptionsSave "Gem indstillinger" 0 "Gem indstillingerne i filen $::optionsFile"
menuText d OptionsAutoSave "Gem indstillinger automatisk ved afslutning" 18 {Gem indstillingerne, når Scid afsluttes}

# Help menu:
menuText d Help "Hjælp" 0
menuText d HelpContents "Indhold" 0 {Vis indholdsfortegnelsen for hjælpen}
menuText d HelpIndex "Stikordsregister" 0 {Slå op i hjælpens stikordsregister}
menuText d HelpGuide "Kom godt i gang" 0 {Åbn den korte vejledning til Scid}
menuText d HelpHints "Gode råd" 0 {Vis gode råd om brugen af Scid}
menuText d HelpContact "Kontaktoplysninger" 1 {Vis kontaktoplysninger}
menuText d HelpTip "Dagens tip" 0 {Vis et tip om Scid}
menuText d HelpStartup {Startvindue} 0 {Vis startvinduet}
menuText d HelpAbout "Om Scid Community" 8 {Vis oplysninger om Scid Community}
menuText d UpdateCheck "Søg efter opdateringer" 4 {Undersøg, om der findes en nyere version af Scid Community}
translate d UpdateChecking {Søger efter opdateringer...}
translate d UpdateUpToDate {Du bruger den nyeste version af scidCommunity (%s).}
translate d UpdateAvailable {En ny version af scidCommunity er tilgængelig: %s

Du bruger i øjeblikket %s.}
translate d UpdateDownloadInstall {Hent og installer}
translate d UpdateViewRelease {Vis versionsnoter}
translate d UpdateNotNow {Ikke nu}
translate d UpdateCheckFailed {scidCommunity kunne ikke søge efter opdateringer. Kontrollér internetforbindelsen, og prøv igen.}
translate d UpdateInstallConfirm {scidCommunity %s bliver hentet og installeret.

Når filen er hentet, lukker scidCommunity og starter installationsprogrammet.}
translate d UpdateDownloading {Henter scidCommunity %s...}
translate d UpdateDownloaded {Hentet: %s}
translate d UpdateDownloadFailed {Kunne ikke hente opdateringen. Prøv igen senere.}

# Toolbar tooltips:
menuText d RotateBoard "Vend brættet" 0 {Se brættet fra den anden side}

# Game info box popup menu:
menuText d GInfoHideNext {Skjul næste træk} 0
menuText d GInfoMaterial {Vis materialeværdier} 2
menuText d GInfoFEN {Vis FEN} 4
menuText d GInfoMarks {Vis farvede felter og pile} 0
menuText d GInfoWrap {Ombryd lange linjer} 0
menuText d GInfoFullComment {Vis hele kommentaren} 0
menuText d GInfoPhotos {Vis billeder} 0
menuText d GInfoTBNothing {Slutspilsdatabaser: Vis intet} 25
menuText d GInfoTBResult {Slutspilsdatabaser: Vis kun resultat} 17
menuText d GInfoTBAll {Slutspilsdatabaser: Vis resultat og bedste træk} 10
menuText d GInfoDelete {Skift slettemarkering for partiet} 0
menuText d GInfoMark {Skift markering for partiet} 6
menuText d GInfoInformant {Indstil grænser for vurderingssymboler} 0

# General buttons:
translate d LichessOpenExplore {Lichess-åbningstræ}
translate d LichessTitle {Lichess' åbningsdatabase}
translate d LichessApiTokenReq {Lichess-API-token (påkrævet):}
translate d LichessDatabase {Database:}
translate d LichessMasters {Mesterpartier}
translate d LichessGames {Lichess-partier}
translate d LichessPlayer {Spiller}
translate d LichessNumMoves {Antal træk:}
translate d LichessTopGames {Toppartier:}
translate d LichessRecentGames {Seneste partier:}
translate d LichessSinceYear {Fra år:}
translate d LichessUntilYear {Til år:}
translate d LichessSinceMonth {Fra (ÅÅÅÅ-MM):}
translate d LichessUntilMonth {Til (ÅÅÅÅ-MM):}
translate d LichessTimeControls {Betænkningstider}
translate d LichessRatingGroups {Ratinggrupper}
translate d LichessPlayerName {Spillerens brugernavn:}
translate d LichessPlayerColor {Spillerens farve:}
translate d LichessWhite {Hvid}
translate d LichessBlack {Sort}
translate d LichessGameModes {Partityper}
translate d LichessRated {Ratet}
translate d LichessCasual {Uratet}
translate d LichessTokenRequired {Der kræves et Lichess-API-token.\n\nSiden marts 2026 kræver Lichess et API-token for adgang til åbningsdatabasen. Indtast det i feltet "Lichess-API-token" ovenfor.\n\nDu kan oprette et token her: https://lichess.org/account/oauth/token}
translate d LichessPlayerRequired {Indtast et Lichess-brugernavn til spillerdatabasen.}
translate d LichessQuerying {Søger i Lichess' åbningsdatabase...}
translate d LichessFailedQuery {Kunne ikke søge i Lichess' åbningsdatabase:\n%s}
translate d LichessPositionNotFound {Stillingen findes ikke i databasen %s.\n\nAPI-svar:\n%s}
translate d LichessResultsTitle {Lichess' åbningsdatabase – %s}
translate d LichessSummaryInfo {I alt: %s partier  |  Hvide sejre: %s (%s%%)  |  Remiser: %s (%s%%)  |  Sorte sejre: %s (%s%%)}
translate d LichessNoGamesFound {Der blev ikke fundet partier med denne stilling.}
translate d LichessMoves {Træk:}
translate d LichessColMove {Træk}
translate d LichessColWhite {Hvid}
translate d LichessColDraws {Remiser}
translate d LichessColBlack {Sort}
translate d LichessColTotal {I alt}
translate d LichessColWinPct {Sejre i %}
translate d LichessColAvgRating {Gns. rating}
translate d LichessColECO {ECO}
translate d LichessColOpening {Åbning}
translate d LichessTopGamesTitle {Toppartier:}
translate d LichessRecentGamesTitle {Seneste partier:}
translate d LichessColWinner {Vinder}
translate d LichessColWhiteRating {Hvids rating}
translate d LichessColBlackRating {Sorts rating}
translate d LichessColDate {Dato}
translate d LichessLoadGameConfirm {Indlæs partiet %s mod %s (ID: %s) i udklipsdatabasen?}
translate d LichessLoadGameTitle {Hent parti}
translate d LichessFetchGameFailed {Kunne ikke hente parti %s:\n%s}
translate d LichessGameNotFound {Parti %s blev ikke fundet på Lichess.}
translate d LichessImportFailed {Kunne ikke importere partiet:\n%s}
translate d LichessGameLoaded {Partiet er indlæst i udklipsdatabasen.}

# Lichess Puzzles
translate d LichessPuzzlesTitle {Taktikopgaver fra Lichess}
translate d LichessPuzzlesDailyTitle {Dagens opgave}
translate d LichessPuzzlesQuerying {Henter opgaver fra Lichess...}
translate d LichessPuzzlesFailed {Kunne ikke hente opgaver fra Lichess:\n%s}
translate d LichessPuzzlesParseError {Kunne ikke læse opgavedata}
translate d LichessPuzzlesLoadError {Kunne ikke indlæse opgavestillingen}
translate d LichessPuzzlesSolve {Dit træk! Find det bedste træk.}
translate d LichessPuzzlesCorrect {Godt træk!}
translate d LichessPuzzlesWrong {Prøv et andet træk.}
translate d LichessPuzzlesBestMove {Bedste træk! Fortsæt...}
translate d LichessPuzzlesSolved {Du løste opgaven! Tillykke!}
translate d LichessPuzzlesPlaying {Løser opgaven...}
translate d LichessPuzzlesStop {Stop}
translate d LichessPuzzlesNew {Ny opgave}
translate d LichessPuzzlesHint {Få et tip}
translate d LichessPuzzlesViewSolution {Vis løsning}
translate d LichessPuzzlesHintMsg {Se på brikken på %s.}
translate d LichessPuzzlesSolutionMsg {Løsning:\n%s}
translate d LichessPuzzlesDifficulty {Sværhedsgrad:}
translate d LichessPuzzlesDiffEasiest {Lettest}
translate d LichessPuzzlesDiffEasier {Lettere}
translate d LichessPuzzlesDiffNormal {Normal}
translate d LichessPuzzlesDiffHarder {Sværere}
translate d LichessPuzzlesDiffHardest {Sværest}
translate d LichessPuzzlesColor {Spil som:}
translate d LichessPuzzlesNextColor {Farve i næste opgave:}
translate d LichessPuzzlesSideToMove {Siden i trækket}
translate d LichessPuzzlesSolvedTitle {Opgaven er løst!}
translate d LichessPuzzlesTheme {Tema:}
translate d LichessPuzzlesMix {Blandede temaer}
translate d LichessPuzzlesId {Opgave-ID}
translate d LichessPuzzlesPlays {Antal forsøg}
translate d LichessPuzzlesThemes {Temaer}
translate d LichessPuzzlesPerf {Type}
translate d LichessPuzzlesClock {Ur}
translate d LichessPuzzlesRated {Ratet}
translate d LichessPuzzlesGame {Parti}
translate d LichessPuzzlesNoNew {Der er ingen nye opgaver med disse indstillinger.\n\nPrøv et andet tema, en anden sværhedsgrad eller en anden farve.}
# Woodpecker Method trainer (tcl/tools/woodpecker_ui.tcl)
translate d WoodpeckerTitle {Spættemetoden}
translate d WoodpeckerColName {Sæt}
translate d WoodpeckerColExercises {Opgaver}
translate d WoodpeckerColCycle {Runde}
translate d WoodpeckerColProgress {Denne runde}
translate d WoodpeckerColLast {Seneste træning}
translate d WoodpeckerColDays {Dage}
translate d WoodpeckerColTime {Løsningstid}
translate d WoodpeckerColResults {løst/fejlet}
translate d WoodpeckerColPct {Resultat}
translate d WoodpeckerColDate {Dato}
translate d WoodpeckerColDuration {Varighed}
translate d WoodpeckerColPoints {Point}
translate d WoodpeckerNew {Nyt sæt...}
translate d WoodpeckerTrain {Træn}
translate d WoodpeckerEvaluate {Vurder...}
translate d WoodpeckerStats {Statistik}
translate d WoodpeckerDelete {Slet}
translate d WoodpeckerContinue {Fortsæt (Enter)}
translate d WoodpeckerPause {Pause}
translate d WoodpeckerResume {Genoptag}
translate d WoodpeckerEnd {Afslut træning}
translate d WoodpeckerNoSets {Tryk på Nyt sæt for at bruge opgaverne fra Scid, hente flere fra Lichess eller bruge en PGN-bog.}
translate d WoodpeckerUnrated {%d af %d opgaver mangler ! eller !!. Vurder sættet for at få bonus for disse træk. Tidligere træninger får også beregnet nye point.}
translate d WoodpeckerCycleOver {Runde %d er afsluttet. Hold pause til %s. Derefter begynder næste runde med halvt så mange dage.}
translate d WoodpeckerCycleLine {Runde %d: %d/%d gennemført, %d dage planlagt, frist %s.}
translate d WoodpeckerQuotaLine {I dag: %d af %d opgaver.}
translate d WoodpeckerQuotaRaised {Du er lidt bagud. Dagens mål er %d i stedet for %d.}
translate d WoodpeckerDeadlineMoved {Efter pausen er fristen rykket %d dage til %s. Det daglige mål er %d.}
translate d WoodpeckerOverStretch {Runden har nu varet dobbelt så længe som planlagt. Fristen er stadig %s, og det daglige mål er %d.}
translate d WoodpeckerDeleteAsk {Slet sættet "%s" med tilhørende database og statistik?}
translate d WoodpeckerNewTitle {Nyt sæt til Spættemetoden}
translate d WoodpeckerName {Navn}
translate d WoodpeckerFromLichess {Opgaver fra Lichess}
translate d WoodpeckerFromPuzzles {Opgaver fra Scid (niveauinddelte Lichess-opgaver)}
translate d WoodpeckerAdvanced {Avanceret}
translate d WoodpeckerUseLichess {Hent opgaver fra Lichess i stedet for at bruge de medfølgende sæt}
translate d WoodpeckerPicking {Vælger opgaver...}
translate d WoodpeckerShortAsk {Af de ønskede opgaver er der kun %d ud af %d tilbage på dit niveau i Scid.

Vil du hente de sidste %d fra Lichess?

Vælg Nej for at oprette sættet med de fundne opgaver.}
translate d WoodpeckerNoPuzzles {Der er ingen opgaver tilbage med dette niveau, tema og farve.}
translate d WoodpeckerCount {Opgaver}
translate d WoodpeckerDifficulty {Sværhedsgrad}
translate d WoodpeckerTheme {Tema}
translate d WoodpeckerThemeMix {Blandet (anbefales)}
translate d WoodpeckerColor {Farve}
translate d WoodpeckerColor_both {Begge}
translate d WoodpeckerColor_white {Hvid}
translate d WoodpeckerColor_black {Sort}
translate d WoodpeckerToken {Lichess-token}
translate d WoodpeckerFromFile {PGN- eller Scid-database (f.eks. en bog)}
translate d WoodpeckerFileHelp {Hvert parti med en opstillet startstilling bliver en opgave. Hovedvarianten er løsningen. Sidevarianter springes over. Forfatterens ! og !! bevares.}
translate d WoodpeckerDays1 {Første runde (dage)}
translate d WoodpeckerRestDays {Pause mellem runder (dage)}
translate d WoodpeckerDaysHelp {Hver runde varer halvt så mange dage som den foregående. Målet er at halvere løsningstiden hver gang.}
translate d WoodpeckerCreate {Opret}
translate d WoodpeckerBadNumber {Ugyldigt tal: %s}
translate d WoodpeckerNoDifficulty {Vælg mindst én sværhedsgrad, og angiv antal opgaver.}
translate d WoodpeckerDownloading {Henter opgaver fra Lichess...}
translate d WoodpeckerBuilding {Opretter sættets database...}
translate d WoodpeckerCreateFailed {Kunne ikke oprette sættet:
%s}
translate d WoodpeckerCreated {Sættet er oprettet med %d opgaver.}
translate d WoodpeckerFewer {Lichess leverede %d af de %d ønskede opgaver.}
translate d WoodpeckerNoFile {Kan ikke læse %s}
translate d WoodpeckerSkipped {Sprang %d partier over, da de mangler startstilling eller træk.}
translate d WoodpeckerMarksIncluded {Nøgletrækkene er allerede markeret med ! og !!, så du kan begynde. Du kan stadig vælge at vurdere sættet med din egen motor i menuen.}
translate d WoodpeckerEvalRecommended {Vil du analysere sættet nu? Det anbefales, da analysen markerer nøgletræk med ! og !!, som giver bonuspoint. Det tager cirka et sekund pr. opgave og kan også gøres senere.}
translate d WoodpeckerLevel_easiest {Lettest}
translate d WoodpeckerLevel_easier {Lettere}
translate d WoodpeckerLevel_normal {Normal}
translate d WoodpeckerLevel_harder {Sværere}
translate d WoodpeckerLevel_hardest {Sværest}
translate d WoodpeckerEvalBusy {En vurdering er allerede i gang.}
translate d WoodpeckerSomeAnnotated {%d af %d opgaver har allerede kommentarer. Vil du analysere resten eller overskrive alle kommentarer?}
translate d WoodpeckerComplete {Analysér resten}
translate d WoodpeckerOverwrite {Overskriv med analysen}
translate d WoodpeckerAllAnnotated {Alle %d opgaver har kommentarer. Vil du overskrive forfatterens markeringer med analysens?}
translate d WoodpeckerKeep {Behold kommentarerne}
translate d WoodpeckerEvaluating {Vurderer sættet...}
translate d WoodpeckerEvalPhase_deep {Analyse: søger efter løsningerne}
translate d WoodpeckerEvalPhase_shallow {Analyse: finder de oplagte træk}
translate d WoodpeckerEvalPhase_write {Gemmer markeringerne}
translate d WoodpeckerEvalDone {Vurdering færdig: %d opgaver. %d træk fik ! og %d fik !! ud af %d træk, der skal findes.}
translate d WoodpeckerNoEngine {Der er ikke konfigureret nogen UCI-motor (Værktøjer > Skakmotorer).}
translate d WoodpeckerEvalAsk {Vurder %d opgaver med denne motor:}
translate d WoodpeckerOtherMode {Brættet bruges allerede til træning eller spil.}
translate d WoodpeckerNoSlot {Der er ingen ledig databaseplads til træningen. Luk en database og prøv igen.
(%s)}
translate d WoodpeckerRestAsk {Pausen slutter %s. Start runde %d alligevel?}
translate d WoodpeckerUnratedShort {%d opgaver mangler vurdering. Her tæller kun den rigtige trækfølge.}
translate d WoodpeckerRes1 {løst}
translate d WoodpeckerRes2 {fejlet}
translate d WoodpeckerPacePer {pr. opgave}
translate d WoodpeckerPaceTarget {mål: %s s}
translate d WoodpeckerCardStreak {Stime}
translate d WoodpeckerCardPoints {Point}
translate d WoodpeckerCardDeadline {Frist}
translate d WoodpeckerStreakSub {fejlfrie i træk}
translate d WoodpeckerPointsSub {af de mulige}
translate d WoodpeckerDaysLeft {dage tilbage}
translate d WoodpeckerExercise {Opgave %d af %d}
translate d WoodpeckerWhiteToMove {Hvid i trækket}
translate d WoodpeckerBlackToMove {Sort i trækket}
translate d WoodpeckerYourMove {Dit træk.}
translate d WoodpeckerSolved {Løst!}
translate d WoodpeckerFailed {Fejlet.}
translate d WoodpeckerPoints {+%s / %s}
translate d WoodpeckerNoMarks {(endnu ikke vurderet: ingen bonus for ! eller !!)}
translate d WoodpeckerQuotaDone {Du har nået dagens mål! Fortsæt eller afslut træningen.}
translate d WoodpeckerSolutionShown {Gennemgå løsningen på brættet eller kortet, og tryk på Enter.}
translate d WoodpeckerPaused {På pause.}
translate d WoodpeckerAutoPaused {På pause efter to minutter uden træk. Pausen tæller ikke med.}
translate d WoodpeckerSessionOver {Træningen er slut}
translate d WoodpeckerCycleComplete {Runde %d gennemført!}
translate d WoodpeckerSumDate {Dato}
translate d WoodpeckerSumDuration {Varighed}
translate d WoodpeckerSumExercises {Gennemførte opgaver}
translate d WoodpeckerSumPoints {%s af %s point}
translate d WoodpeckerSumAvg {Gennemsnit pr. opgave}
translate d WoodpeckerSumQuota {Dagens mål}
translate d WoodpeckerSumCompare {Siden sidste runde: %d hurtigere, %d langsommere, %d rettede fejl, %d nye fejl.}
translate d WoodpeckerSumReview {Til gennemgang: opgave %s}
translate d WoodpeckerCyclesTitle {Runder}
translate d WoodpeckerSessionsTitle {Træninger}
translate d WoodpeckerStatsNote {Point beregnes med markeringerne fra vurdering %d. Tidligere træninger genberegnes med de samme markeringer, så runderne kan sammenlignes.}
translate d WoodpeckerNoData {Ingen runde endnu}
translate d WoodpeckerChartLegend {Søjler: løsningstid   Stiplet linje: mål (halvdelen af sidste rundes tid)}
translate d WoodpeckerTagline {Løs det samme sæt flere gange, hurtigere for hver runde.}
translate d WoodpeckerExit {Afslut træningen}
translate d WoodpeckerMore {Flere opgaver}
translate d WoodpeckerToday {I dag}
translate d WoodpeckerCycleShort {Runde %d}
translate d WoodpeckerDaysPlanned {%d dage planlagt}
translate d WoodpeckerExercisesShort {opgaver}
translate d WoodpeckerDeadline {frist %s}
translate d WoodpeckerHidden {Løsningen vises her.}
translate d WoodpeckerSumCycle {Runde}
translate d WoodpeckerTokenSave {Gem og kontrollér}
translate d WoodpeckerTokenCreate {Opret et token (rettighed: puzzle:read)}
translate d WoodpeckerTokenOk {✓ Token virker: %s.}
translate d WoodpeckerTokenRating {Opgaverating: %s.}
translate d WoodpeckerTokenNoScope {Dette token mangler rettigheden puzzle:read. Opret et nyt via linket ovenfor.}
translate d WoodpeckerTokenInvalid {Lichess genkender ikke dette token.}
translate d WoodpeckerTokenUnchecked {Kunne ikke kontrollere dit token. Det kan skyldes forbindelsen. Det bruges som indtastet.}
translate d WoodpeckerTokenChecking {Kontrollerer token...}
translate d WoodpeckerTokenMissing {Uden token kan du indtaste din opgaverating fra din Lichess-profil ovenfor. Det tager længere tid at hente opgaver, og du kan få opgaver, du allerede har løst på Lichess.}
translate d WoodpeckerPreset_automatic {Automatisk (lettere)}
translate d WoodpeckerPreset_standard {Standard (anbefales)}
translate d WoodpeckerPreset_challenge {Udfordrende}
translate d WoodpeckerPreset_tough {Svær (mest over dit niveau)}
translate d WoodpeckerPreset_custom {Tilpasset...}
translate d WoodpeckerPresetHelp_automatic {Mest enkel taktik, så du straks genkender mønstrene. Det er bogens første mål.}
translate d WoodpeckerPresetHelp_standard {En fjerdedel lettere, de fleste på dit niveau og nogle få sværere, som i bogens lette og mellemsvære afsnit.}
translate d WoodpeckerPresetHelp_challenge {På og over dit niveau, beregnet til stærke spillere som i bogens avancerede afsnit.}
translate d WoodpeckerPresetHelp_tough {Mest et godt stykke over dit niveau, til stærke spillere, der ønsker en udfordring.}
translate d WoodpeckerPresetHelp_custom {Vælg selv andelen af opgaver på hvert Lichess-niveau.}
translate d WoodpeckerPresetRating {Niveauerne afhænger af din opgaverating på Lichess (%s).}
translate d WoodpeckerPresetNoRating {Niveauerne afhænger af din opgaverating på Lichess.}
translate d WoodpeckerRatingAsk {Din opgaverating på Lichess}
translate d WoodpeckerBadRating {Indtast din opgaverating på Lichess (400–3200). Den står under opgaver på din Lichess-profil.}
translate d WoodpeckerPresetStated {Niveauerne afhænger af den rating, du har indtastet (%s).}
translate d WoodpeckerDataDir {Datamappe til Spættemetoden (tom: brug Scids egen)}
translate d WoodpeckerNoDataDir {Kan ikke finde datamappen til Spættemetoden:\n%s\n\nEr drevet tilsluttet? Mappen vælges under Indstillinger > Ressourcer.}
translate d WoodpeckerDataDirMove {Der er %d opgavesæt til Spættemetoden i den tidligere datamappe:\n%s\n\nVil du flytte dem til den nye mappe?\n%s\n\nVælg Nej for at starte med en tom mappe og beholde sættene, hvor de er.}
translate d WoodpeckerDataDirHasSets {Den nye datamappe indeholder allerede %d sæt (måske synkroniseret fra en anden computer):\n%s\n\nScid bruger disse sæt. Sættene i den tidligere mappe bliver i:\n%s}

# Board screenshot
menuText d ToolsScreenshot "Gem billede af brættet" 0 {Gem den aktuelle brætstilling som et PNG-billede}
translate d ScreenshotTitle {Gem billede af brættet}
translate d ScreenshotFileType {PNG-billeder}
translate d ScreenshotOverwrite {Der findes allerede en fil med dette navn. Vil du overskrive den?}
translate d ScreenshotError {Kunne ikke gemme skærmbilledet.}
translate d ScreenshotSaved {Brætbilledet er gemt:}

# Lichess study publishing
# Publish database games as chapters of a Lichess study.
# Designed by TBergh98 (https://github.com/TBergh98).
menuText d ToolsPublishLichessStudy "Udgiv partiet i et Lichess-studie..." 21 {Udgiv det aktuelle parti som et nyt kapitel i et af dine Lichess-studier}
translate d LichessStudyTitle {Udgiv i et Lichess-studie}
translate d LichessStudyToPublish {Til udgivelse: %s (ét kapitel pr. parti)}
translate d LichessStudyToken {Lichess-token:}
translate d LichessStudyCreateToken {Opret et token (rettigheder: study:read og study:write)}
translate d LichessStudySearch {Søg efter studie:}
translate d LichessStudyChapterSettings {Kapitelindstillinger}
translate d LichessStudyOrientation {Brættets retning:}
translate d LichessStudyOrientationAuto {Automatisk}
translate d LichessStudyAnalysisMode {Analysetilstand:}
translate d LichessStudyModeNormal {Normal analyse}
translate d LichessStudyModeConceal {Skjul de næste træk}
translate d LichessStudyModePractice {Træn med computeren}
translate d LichessStudyModeGamebook {Interaktiv lektion}
translate d LichessStudyCreateNew {Eller opret et nyt studie}
translate d LichessStudyName {Navn:}
translate d LichessStudyVisibility {Synlighed:}
translate d LichessStudyVisPrivate {Privat}
translate d LichessStudyVisUnlisted {Skjult fra lister}
translate d LichessStudyVisPublic {Offentligt}
translate d LichessStudyCreateAndPublish {Opret og udgiv}
translate d LichessStudyAddByLink {Studie, du bidrager til (link):}
translate d LichessStudyUnnamed {Studie %s}
translate d LichessStudyAddButton {Tilføj}
translate d LichessStudyReload {Genindlæs listen}
translate d LichessStudyPublishButton {Udgiv}
translate d LichessStudyPublishGames {Udgiv i et Lichess-studie (%s)...}
translate d LichessStudyAddedByLink {tilføjet via link}

translate d LichessStudyNeedToken {Indsæt dit Lichess-token, og tryk på "Gem".}
translate d LichessStudyLoading {Indlæser dine studier...}
translate d LichessStudyAccountStatus {Konto %s: %s studier. Vælg et, og tryk på "Udgiv".}
translate d LichessStudyTokenInvalid {Dit token indeholder ugyldige tegn. Kopiér det igen fra Lichess.}
translate d LichessStudySaveTokenFirst {Gem først dit Lichess-token.}
translate d LichessStudyChecking {Kontrollerer studie %s...}
translate d LichessStudyPickStudy {Vælg først et studie på listen.}
translate d LichessStudyAddLinkPrompt {Indsæt linket til et studie, f.eks. https://lichess.org/study/AbCd1234}
translate d LichessStudyNameLength {Studiets navn skal være på 2 til 100 tegn.}
translate d LichessStudyCreating {Opretter studiet "%s"...}
translate d LichessStudyCreateFailed {Kunne ikke oprette studiet "%s": %s\n\nIntet blev udgivet.}
translate d LichessStudyDbClosed {Databasen er lukket.}
translate d LichessStudyTooManyGames {Du har valgt %s partier, men et Lichess-studie kan højst indeholde %s kapitler.}
translate d LichessStudyNoGame {Der er intet parti på brættet.\n\nDu kan udgive partier fra en database ved at markere dem i partilisten og bruge højrekliksmenuen.}
translate d LichessStudyNoUsername {Kan ikke læse brugernavnet i svaret fra Lichess.}
translate d LichessStudyCurlNotFound {Kan ikke finde curl, som bruges til at kontakte Lichess.}
translate d LichessStudyGameNotFound {Parti %s blev ikke fundet i databasen.}
translate d LichessStudyCannotRead {Kan ikke læse parti %s: %s}

translate d LichessStudyFull {studiet er fuldt. Et Lichess-studie kan højst indeholde %s kapitler.}
translate d LichessStudyNoAnswer {Intet svar fra Lichess. Kontrollér internetforbindelsen.}
translate d LichessStudy401 {Ugyldigt eller udløbet token (401).}
translate d LichessStudy403 {Adgang nægtet (403). Dit token mangler rettighederne study:read/study:write, eller du mangler skriveadgang til studiet.}
translate d LichessStudy404 {Studiet blev ikke fundet (404), eller det er privat, og du er ikke medlem.}
translate d LichessStudy429 {For mange forespørgsler til Lichess (429). Vent et minut, og prøv igen.}
translate d LichessStudyHttpError {Lichess (HTTP %s): %s}
translate d LichessStudyUnexpected {Uventet svar fra Lichess (HTTP %s). %s}
translate d LichessStudyNetworkError {Netværksfejl: %s}

translate d LichessStudyOvfFree {"%s" har kun %s ledige kapitler ud af %s (grænsen på Lichess), og du vil udgive %s partier.}
translate d LichessStudyOvfFull {"%s" er fuldt. Et Lichess-studie kan højst indeholde %s kapitler.}
translate d LichessStudyOvfQuestion {%s\n\nHvad vil du gøre?}
translate d LichessStudyOvfFirst {Udgiv kun de første %s partier her (%s bliver ikke udgivet)}
translate d LichessStudyOvfSplit {Udgiv de første %s partier her og de øvrige %s i et nyt studie}
translate d LichessStudyOvfAllNew {Udgiv alle %s partier i et nyt studie}
translate d LichessStudyOvfName {Navn på nyt studie:}

translate d LichessStudyCancelled {Udgivelsen er annulleret. Intet blev udgivet.}
translate d LichessStudyCheckingFree {Kontrollerer ledige kapitler i "%s"...}
translate d LichessStudyPublishing {Udgiver %s parti(er) i "%s"...}
translate d LichessStudyGamesNotPublished {Partier, der ikke blev udgivet, fordi studiet er fuldt: %s.}
translate d LichessStudyEmptyNew {Det nye studie "%s" er oprettet, men indeholder ingen af partierne (%s).}
translate d LichessStudyNothingPublished {Intet blev udgivet.%s}
translate d LichessStudyReport {Oprettede %s af %s kapitler (%s).%s\n\nVil du åbne studiet i browseren?}
translate d LichessStudyReportItem {%s i "%s"}
translate d LichessStudyNoChapters {Der blev ikke oprettet nogen kapitler.%s}
translate d LichessStudyReports {Lichess melder: %s}

translate d About {Om Scid Community}
translate d Back {Tilbage}
translate d Apply {Anvend}
translate d Browse {Gennemse}
translate d Cancel {Annuller}
translate d Continue {Fortsæt}
translate d Clear {Ryd}
translate d Close {Luk}
translate d Contents {Indhold}
translate d Defaults {Standardindstillinger}
translate d InvertSearch {Vend søgeresultatet om}
translate d Delete {Slet}
translate d Graph {Graf}
translate d Help {Hjælp}
translate d Hide {Skjul}
translate d Import {Importer}
translate d Index {Stikordsregister}
translate d LoadGame {Hent parti}
translate d PgnOpenInViewer {Åbn i PGN-viseren}
translate d MergeGame {Flet parti}
translate d MergeGames {Flet partier}
translate d Preview {Forhåndsvisning}
translate d Revert {Gendan}
translate d Rename {Omdøb}
translate d Save {Gem}
translate d Presets {Forudindstillinger}
translate d SavePreset {Gem søgeindstillinger}
translate d PresetName {Navn på forudindstilling:}
translate d Search {Søg}
translate d Stop {Stop}
translate d Store {Gem}
translate d Update {Opdater}
translate d ChangeOrient {Skift vinduets retning}
translate d ShowIcons {Vis ikoner}
translate d None {Ingen}
translate d First {Første}
translate d Current {Aktuel}
translate d Last {Sidste}

# General messages:
translate d game {parti}
translate d games {partier}
translate d move {træk}
translate d moves {træk}
translate d all {alle}
translate d Yes {Ja}
translate d No {Nej}
translate d Both {Begge}
translate d King {Konge}
translate d Queen {Dronning}
translate d Rook {Tårn}
translate d Bishop {Løber}
translate d Knight {Springer}
translate d Pawn {Bonde}
translate d White {Hvid}
translate d Black {Sort}
translate d Player {Spiller}
translate d Rating {Rating}
translate d RatingDiff {Ratingforskel (hvid minus sort)}
translate d AverageRating {Gennemsnitlig rating}
translate d Event {Turnering}
translate d Site {Spillested}
translate d Country {Land}
translate d IgnoreColors {Se bort fra farver}
translate d Date {Dato}
translate d EventDate {Turneringsdato}
translate d Decade {Årti}
translate d Year {År}
translate d Month {Måned}
translate d Months {januar februar marts april maj juni juli august september oktober november december}
translate d Days {søn man tir ons tor fre lør}
translate d YearToToday {-1 år}
translate d YearToTodayTooltip {Vælg perioden fra for et år siden til i dag}
translate d Result {Resultat}
translate d Round {Runde}
translate d Length {Længde}
translate d ECOCode {ECO-kode}
translate d ECO {ECO}
translate d Deleted {Slettet}
translate d SearchResults {Søgeresultater}
translate d OpeningTheDatabase {Åbner databasen}
translate d Database {Database}
translate d MenuDatabaseSlot {Database %d: %s}
translate d MenuImportIntoSlot {Til database %d: %s}
translate d Filter {Filter}
translate d noGames {ingen partier}
translate d allGames {alle partier}
translate d empty {tom}
translate d clipbase {udklipsdatabase}
translate d score {score}
translate d StartPos {Startstilling}
translate d Total {I alt}
translate d readonly {skrivebeskyttet}

# Import games (skip duplicates):
translate d ImportInto {Importer til:}
translate d ImportStripComments {Fjern kommentarer fra importerede partier}
translate d Clipbase {Udklipsdatabase}
translate d NoWritableDatabases {Der er ingen åbne databaser med skriveadgang. Åbn eller opret først en database.}
translate d Imported {Importeret}
translate d Updated {Opdateret}
translate d Into {til}
translate d Skipped {Sprang over:}
translate d DuplicateGame {dublet}
translate d DuplicateGames {dubletter}
translate d PgnErrorsWarnings {PGN-fejl og -advarsler:}
translate d NoPgnErrorsWarnings {uden PGN-fejl eller -advarsler.}

# Standard error messages:
translate d ErrNotOpen {Databasen er ikke åben.}
translate d ErrReadOnly {Databasen er skrivebeskyttet og kan ikke ændres.}
translate d ErrSearchInterrupted {Søgningen blev afbrudt. Resultaterne er ufuldstændige.}
translate d ErrNoClockComments {Partiet indeholder ingen tidsangivelser af typen [%clk]. Tilføj klokkeslæt i kommentarvinduet (Ctrl+E) for at bruge denne funktion.}
translate d ErrFileInUse {Fejl: Filen er allerede i brug. Luk andre programmer, der bruger databasen.}

# Drag and drop
translate d DndCannotOpenUri {Kan ikke åbne URI}
translate d DndInvalidUri {Ugyldig URI}
translate d DndUriRejected {URI afvist}
translate d DndUriRejectedDetail {Scid-databaser (.si5, .si4, .si3) eller PGN-/EPD-filer.}
translate d DndEmptyUriList {Der blev ikke fundet filer blandt de angivne URI'er}
translate d DndOwnerDidntRespond {Kunne ikke indsætte det trukne indhold. Kildeprogrammet svarede ikke}




# Game information:
translate d twin {dublet}
translate d deleted {slettet}
translate d comment {kommentar}
translate d hidden {skjult}
translate d LastMove {Seneste træk}
translate d NextMove {Næste}
translate d GameStart {Partiets begyndelse}
translate d LineStart {Variantens begyndelse}
translate d GameEnd {Partiets afslutning}
translate d LineEnd {Variantens afslutning}

# Player information:
translate d PInfoAll {Resultater for <b>alle</b> partier}
translate d PInfoFilter {Resultater for partier i <b>filteret</b>}
translate d PInfoAgainst {Resultater mod}
translate d PInfoMostWhite {Hyppigste åbninger med hvid}
translate d PInfoMostBlack {Hyppigste åbninger med sort}
translate d PInfoRating {Ratingudvikling}
translate d PInfoBio {Biografi}
translate d PInfoEditRatings {Rediger ratingtal}
translate d PInfoEloFile {Fil}

# Tablebase information:
translate d Draw {Remis}
translate d with {med}
translate d only {kun}
translate d lose {tabe}
translate d loses {taber}

# Tip of the day:
translate d Tip {Tip}
translate d TipAtStartup {Vis tip ved opstart}
translate d TipConvertPGN {Konverter PGN-filerne for at gøre søgninger hurtigere}

# Tree window menus:
menuText d TreeFile {Fil} 0
menuText d TreeFileFillWithBase {Fyld cachen fra databasen} 0 {Fyld cachefilen med alle partier i den aktive database}
menuText d TreeFileFillWithGame {Fyld cachen med partiet} 0 {Fyld cachefilen med det aktuelle parti i databasen}
menuText d TreeFileSetCacheSize {Cachestørrelse} 0 {Angiv cachens størrelse}
menuText d TreeFileCacheInfo {Cacheoplysninger} 0 {Vis oplysninger om brug af cachen}
menuText d TreeFileSave {Gem cachefil} 0 {Gem træets cachefil (.stc)}
menuText d TreeFileFill {Fyld cachefil} 0 {Fyld cachefilen med almindelige åbningsstillinger}
menuText d TreeFileBest {Liste over bedste partier} 11 {Vis listen over de bedste partier i træet}
menuText d TreeFileGraph {Grafvindue} 0 {Vis grafen for denne gren af træet}
menuText d TreeFileCopy {Kopiér træets tekst til udklipsholderen} 1 {Kopiér træstatistikken til udklipsholderen}
menuText d TreeFileClose {Luk trævinduet} 0 {Luk trævinduet}
menuText d TreeMask {Maske} 0
menuText d TreeMaskNew {Ny} 0 {Ny maske}
menuText d TreeMaskOpen {Åbn} 0 {Åbn maske}
menuText d TreeMaskOpenRecent {Åbn seneste} 0 {Åbn en nyligt brugt maske}
menuText d TreeMaskSave {Gem} 0 {Gem maske}
menuText d TreeMaskClose {Luk} 0 {Luk maske}
menuText d TreeMaskFillWithGame {Fyld med parti} 0 {Føj partiet til masken}
menuText d TreeMaskFillWithBase {Fyld fra database} 0 {Føj alle partier i databasen til masken}
menuText d TreeMaskInfo {Oplysninger} 6 {Vis statistik for den aktuelle maske}
menuText d TreeMaskDisplay {Vis maskeoversigt} 0 {Vis maskens indhold som et træ}
menuText d TreeMaskSearch {Søg} 0 {Søg i den aktuelle maske}
menuText d TreeSort {Sortering} 0
menuText d TreeSortAlpha {Alfabetisk} 0
menuText d TreeSortECO {ECO-kode} 0
menuText d TreeSortFreq {Hyppighed} 0
menuText d TreeSortScore {Resultat} 2
menuText d TreeOpt {Indstillinger} 0
menuText d TreeOptSlowmode {Langsom tilstand} 4 {Langsom opdatering (høj nøjagtighed)}
menuText d TreeOptFastmode {Hurtig tilstand} 0 {Hurtig opdatering (uden trækomstillinger)}
menuText d TreeOptFastAndSlowmode {Hurtig og langsom tilstand} 0 {Opdater først hurtigt og derefter nøjagtigt}
menuText d TreeOptStartStop {Automatisk opdatering} 0 {Slå automatisk opdatering af trævinduet til eller fra}
menuText d TreeOptLock {Lås} 0 {Lås træet til den aktuelle database, eller lås det op}
menuText d TreeOptAutoLoadMask {Indlæs seneste maske automatisk} 16 {Åbn den senest brugte maske automatisk, når et trævindue åbnes}
menuText d TreeOptTraining {Træning} 0 {Slå træning med åbningstræet til eller fra}
menuText d TreeOptDepth {Halvtræk} 0 {Antal halvtræk, der vises i træet (1–4)}
menuText d TreeOptAutosave {Gem cachefil automatisk} 5 {Gem cachefilen automatisk, når trævinduet lukkes}
menuText d TreeHelp {Hjælp} 0
menuText d TreeHelpTree {Hjælp til trævinduet} 6
menuText d TreeHelpIndex {Hjælpeindeks} 0
menuText d TreeFindGames {Find partier med kommentarer} 0 {Vis de partier, hvor trækket har en kommentar}
translate d SaveCache {Gem cache}
translate d Training {Træning}
translate d PlayFromHere {Spil herfra}
translate d PlayFromHereHelp {Motoren svarer, når enten tidsgrænsen eller dybdegrænsen nås. Nul betyder, at den pågældende grænse er slået fra.}
translate d PlayFromHereLimit {Angiv tids- og dybdegrænse}
translate d PlayFromHereBusy {Afslut først den igangværende partigennemgang eller funktionen Spil partiet færdigt.}
translate d TreeTrainingEndOfLine {Varianten er slut.}
translate d TreeTrainingMoveNotInBase {Trækket findes ikke i databasen.}
translate d LockTree {Lås}
translate d TreeDepth {Halvtræk:}
translate d TreeLocked {låst}
translate d TreeTimingSearch {søgning}
translate d TreeTimingStats {statistik}
translate d TreeBest {Bedste}
translate d TreeBestGames {Træets bedste partier}
translate d TreeFindAnyAnn {enhver kommentar}
translate d TreeFindStalePos {Brætstillingen svarer ikke længere til den kommenterede stilling i træet.\nGå tilbage til den, og prøv igen.}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate d TreeTitleRow {    Træk                      ECO       Hyppighed    Score GnsElo Præst Længde GnsÅr %Remis   %Sejre}
translate d TreeTotal {I ALT}
translate d DoYouWantToSaveFirst {Vil du gemme først}
translate d AddToMask {Føj til maske}
translate d RemoveFromMask {Fjern fra maske}
translate d AddThisMoveToMask {Føj dette træk til masken}
translate d SearchMask {Søg i maske}
translate d DisplayMask {Vis maske}
translate d Nag {NAG-kode}
translate d Marker {Markør}
translate d Include {Medtag}
translate d Exclude {Udelad}
translate d MainLine {Hovedvariant}
translate d Bookmark {Bogmærke}
translate d NewLine {Ny variant}
translate d ToBeVerified {Skal kontrolleres}
translate d ToTrain {Til træning}
translate d Dubious {Tvivlsomt}
translate d ToRemove {Skal fjernes}
translate d NoMarker {Ingen markør}
translate d ColorMarker {Farve}
translate d WhiteMark {Hvid}
translate d GreenMark {Grøn}
translate d YellowMark {Gul}
translate d BlueMark {Blå}
translate d RedMark {Rød}
translate d CommentMove {Kommenter træk}
translate d CommentPosition {Kommenter stilling}
translate d AddMoveToMaskFirst {Føj først trækket til masken}
translate d OpenAMaskFileFirst {Åbn først en maskefil}
translate d Positions {Stillinger}
translate d Moves {Træk}

# Finder window:
menuText d FinderFile "Fil" 0
menuText d FinderFileSubdirs "Søg i undermapper" 0
menuText d FinderFileClose "Luk filsøgning" 0
menuText d FinderSort "Sortering" 0
menuText d FinderSortType "Type" 0
menuText d FinderSortSize "Størrelse" 1
menuText d FinderSortMod "Ændret" 0
menuText d FinderSortName "Navn" 0
menuText d FinderSortPath "Sti" 0
menuText d FinderTypes "Filtyper" 3
menuText d FinderTypesScid "Scid-databaser" 0
menuText d FinderTypesOld "Scid-databaser i ældre format" 17
menuText d FinderTypesPGN "PGN-filer" 0
menuText d FinderTypesEPD "EPD-filer" 0
menuText d FinderTypesRep "Repertoirefiler" 0
menuText d FinderHelp "Hjælp" 0
menuText d FinderHelpFinder "Hjælp til filsøgning" 0
menuText d FinderHelpIndex "Hjælpeindeks" 5
translate d FileFinder {Find filer}
translate d FinderDir {Mappe}
translate d FinderDirs {Mapper}
translate d FinderFiles {Filer}
translate d FinderUpDir {op}
translate d FinderCtxOpen {Åbn}
translate d FinderCtxBackup {Sikkerhedskopiér}
translate d FinderCtxCopy {Kopiér}
translate d FinderCtxMove {Flyt}
translate d FinderCtxDelete {Slet}

# Player finder:
menuText d PListFile {Fil} 0
menuText d PListFileUpdate {Opdater} 0
menuText d PListFileClose {Luk spillersøgning} 0
menuText d PListSort {Sortering} 0
menuText d PListSortName {Navn} 0
menuText d PListSortElo {Elo} 0
menuText d PListSortGames {Partier} 0
menuText d PListSortOldest {Ældste} 0
menuText d PListSortNewest {Nyeste} 0

# Tournament finder:
menuText d TmtFile {Fil} 0
menuText d TmtFileUpdate {Opdater} 0
menuText d TmtFileClose {Luk turneringssøgning} 0
menuText d TmtSort {Sortering} 0
menuText d TmtSortDate {Dato} 0
menuText d TmtSortPlayers {Spillere} 1
menuText d TmtSortGames {Partier} 0
menuText d TmtSortElo {Elo} 0
menuText d TmtSortSite {Spillested} 0
menuText d TmtSortEvent {Turnering} 0
menuText d TmtSortWinner {Vinder} 0
translate d TmtLimit {Maks. antal på listen}
translate d TmtMeanElo {Gennemsnitlig Elo}
translate d TmtNone {Ingen turneringer matchede søgningen.}

# Graph windows:
menuText d GraphFile {Fil} 0
menuText d GraphFileColor {Gem som PostScript i farver...} 13
menuText d GraphFileGrey {Gem som PostScript i gråtoner...} 0
menuText d GraphFileClose {Luk vindue} 0
menuText d GraphOptions {Indstillinger} 0
menuText d GraphOptionsWhite "Hvid" 0
menuText d GraphOptionsBlack "Sort" 0
menuText d GraphOptionsBoth {Begge} 0
menuText d GraphOptionsPInfo {Spiller fra spilleroplysninger} 1
menuText d GraphOptionsEloFile {Elo fra ratingfil} 0
menuText d GraphOptionsEloDB {Elo fra database} 0
translate d GraphFilterTitle {Filtergraf: procentdel af partier, der når stillingen}
translate d GraphAbsFilterTitle {Filtergraf: partiernes hyppighed}
translate d GraphWinPctTitle {Filtergraf: andel sejre (1-0 og 0-1) i stillingen pr. år}
translate d ConfigureFilter {Indstil x-akser for år, rating og træk}
translate d FilterEstimate {Skøn}
translate d TitleFilterGraph {scidCommunity: Filtergraf}
translate d WinPct {Sejre i %}
translate d GraphLine {Kurvediagram}
translate d GraphBar {Søjlediagram}
translate d GraphPopup {Vis bræt i separat vindue}
translate d PgnVarClose {Luk alle varianter}
translate d PgnVarOpen {Åbn alle varianter}
translate d PgnEvaluate {Vurder}
translate d PgnSaveEval {Gem vurdering}
translate d PgnOptShort {Kort overskrift (3 linjer)}
translate d PgnOptSymbols {Kommentarsymboler}
translate d PgnOptIndentC {Indryk kommentarer}
translate d PgnOptIndentV {Indryk varianter}
translate d PgnOptColumn {Kolonnevisning (ét træk pr. linje)}
translate d PgnOptSpace {Mellemrum efter træknumre}
translate d PgnOptStripMarks {Fjern koder for farvede felter og pile}
translate d PgnOptBoldMainLine {Brug fed skrift til hovedvariantens træk}
translate d PgnOptCenter {Centrer det aktuelle træk}

# Analysis window:
translate d AddAllVariations {Tilføj alle varianter}
translate d AddMove {Tilføj træk}
translate d RemoveMove {Fjern træk}
translate d Annotate {Kommenter}
translate d FinishGame {Spil partiet færdigt}
translate d StartEngine {Start skakmotor}
translate d LockEngine {Lås motoren til den aktuelle stilling}
translate d AnalysisCommand {Analysekommando}
translate d PreviousChoices {Tidligere valg}
translate d AnnotateTime {Sekunder pr. træk}
translate d AnnotateAll {For begge farvers træk}
translate d AnnotateWhite {Kun for hvids træk}
translate d AnnotateBlack {Kun for sorts træk}
translate d AnnotateBlundersOnlyScoreChange {Analysen fandt en grov fejl. Vurdering før/efter: }
translate d LowPriority {Lav CPU-prioritet}
translate d ConfigureInformant {Grænser for vurderingssymboler}
translate d Informant!? {Interessant træk}
translate d Informant? {Svagt træk}
translate d Informant?? {Grov fejl}
translate d Informant?! {Tvivlsomt træk}
translate d Informant+= {Hvid står lidt bedre}
translate d Informant+/- {Hvid har klar fordel}
translate d Informant+- {Hvid har afgørende fordel}
translate d Informant+-- {Hvid har overvældende fordel}
translate d AnalysisAutoCommentTooltip {Generer AI-kommentarer til hele partiet}
translate d MoveLabelBest {Bedste}
translate d MoveLabelExcellent {Fremragende}
translate d MoveLabelGood {Godt}
translate d MoveLabelInaccuracy {Unøjagtighed}
translate d MoveLabelMistake {Fejl}
translate d MoveLabelBlunder {Grov fejl}
translate d MoveLabelBrilliant {Brillant}
translate d MoveLabelGreat {Stærkt}
translate d MoveLabelMiss {Forpasset chance}
translate d MoveLabelForced {Tvunget}
translate d MoveLabelBook {Bogtræk}
translate d GameComment {Partikommentar}
translate d GameCommentTooltip {Gennemgå partiets kommenterede træk, og generer et AI-resumé}
translate d ReviewGameButton {Partigennemgang}
translate d ReviewGameButtonTooltip {Gennemgå og bedøm hvert træk i den aktuelle variant}
translate d ReviewMoveButton {Trækkommentar}
translate d ReviewMoveButtonTooltip {Bedøm det fremhævede træk, og indsæt kommentaren}
translate d ReviewSettings {Indstillinger for gennemgang}
translate d ReviewSettingsTooltip {Tilpas indstillingerne for partigennemgangen}
translate d ToolsWhatThreat {Hvad er truslen?}
translate d ToolsWhatThreatTooltip {Spørg motoren, hvad den spiller, der er i trækket, truer med}
translate d WhatThreatRunning {En trusselsanalyse er allerede i gang.}
translate d WhatThreatNoEngine {Der er ikke valgt en skakmotor. Vælg en under Værktøjer > Skakmotorer, eller åbn først et motorvindue.}
translate d WhatThreatNoPosition {Der er ingen stilling at analysere.}
translate d WhatThreatNoMove {Der er intet træk at kommentere her. Gå først til et træk i partiet.}
translate d WhatThreatFailed {Trusselsanalysen kunne ikke køres: %s}
translate d WhatThreatNothingForcing {%s har ingen forcerende træk her. Intet træk vinder materiale eller giver skak.}
translate d ReviewVerifier {Kontrolmotor}
translate d ReviewVerifierOff {Fra (ingen kontrol)}
translate d ReviewVarLines {Varianter, der skal indsættes}
translate d ReviewVarCp {Variantmargin (centibønder)}
translate d ReviewMoveWait {Vent, til analysedybden er nået}
translate d ReviewMovetime {Tidsgrænse (ms)}
translate d ReviewCloudEval {Indledende analyse i skyen}
translate d ReviewEstimatedRating {præstationsrating (i dette parti)}
translate d ReviewOpeningMoves {Åbningstræk}
translate d ReviewFromPreset {%s (fra motorens forudindstilling)}
translate d ReviewProgress {Gennemgår stilling %s af %s}
translate d ReviewWaitForDepth {Venter på dybde %s}
translate d ReviewFailed {Gennemgangen mislykkedes: %s}
translate d ReviewCoach {Trænerkommentarer}
translate d ReviewCoachProgress {kommenterer %s af %s · trænerkommentar %s af %s}
translate d ReviewWriting {Gemmer gennemgangen...}
translate d ReviewCoachSettings {Trænerindstillinger...}
translate d ReviewCoachNoModel {Trænerkommentarer er slået til. Vælg udbyder og model under Trænerindstillinger i indstillingerne for gennemgang.}
translate d ReviewCoachKept {Gennemgangen blev afbrudt. %s af %s trænerkommentarer blev bevaret.}
translate d ReviewCoachDiscarded {Gennemgangen er færdig. Trænerkommentarerne blev kasseret, fordi et andet parti blev åbnet, mens modellen skrev.}
translate d ReviewCoachSummaryLabel {Resumé}
translate d ReviewCoachLevelLabel {Niveau}
translate d ReviewCoachOpeningLabel {Åbning}
translate d ReviewCoachPhase {træk %d–%d – nøjagtighed: hvid %.1f%%, sort %.1f%%. Gns. tab i centibønder: hvid %d, sort %d.}
translate d ReviewReportMarker {Partigennemgang}
translate d ReviewReportSide {%s: %s%% nøjagtighed, gns. tab i centibønder %d}
translate d ReviewReportLabels {Bedømmelser for %s: %s}
translate d ReviewReportKeyMoments {Afgørende øjeblikke: %s}
translate d ReviewReportPhases {Faser: %s}
translate d ReviewReportPhase {%s, træk %d–%d (%s %.1f / %s %.1f)}
translate d ReviewReportOpening {åbning}
translate d ReviewReportMiddlegame {midtspil}
translate d ReviewReportEndgame {slutspil}
translate d TimeMs {Tid (ms)}


# Book window
translate d Book {Bogtræk}
translate d OtherBookMoves {Modstanderens bog}
translate d OtherBookMovesTooltip {Træk, som modstanderen har et svar på}
translate d Alphabetical {Alfabetisk}
translate d BookCount {Bøger}

# OpenBook Rich (.obr) book columns, shown in the Book window for a .obr book.
translate d ObrBookMove {Træk}
translate d ObrBookGames {Partier}
translate d ObrBookFrequency {Hyppighed}
translate d ObrBookScore {Resultat}
translate d ObrBookWDB {H/R/S %}
translate d ObrBookElo {Elo}
translate d ObrBookPerf {Præst.}
translate d ObrBookNoStats {(ingen statistik)}
translate d ObrBookDetail {%s  %d partier (hyppighed %.1f%%): +%d =%d -%d (hvid/remis/sort)  score %.1f%%  Elo %s  præst. %s  farve %s  flag 0x%02X}
translate d ObrColourRed {rød}
translate d ObrColourBlue {blå}
translate d ObrColourGreen {grøn}
# Tools > Convert CTG book: ChessBase CTG book to OpenBook Rich (.obr)
translate d CtgChooseSource {Vælg CTG-bogen (.ctg). Dens .cto- og .ctb-filer skal ligge i samme mappe}
translate d CtgChooseDest {Vælg, hvor OBR-bogen (.obr) skal gemmes}
translate d CtgConverting {Konverterer}
translate d CtgConvertDone {Bogen er gemt:}

# Configure Engines dialog:
translate d EngineList {Indstil skakmotorer}
translate d EngineName {Navn}
translate d EngineCmd {Kommando}
translate d EngineArgs {Parametre}
translate d EngineDir {Mappe}
translate d EngineElo {Elo}
translate d EngineTime {Dato}
translate d EngineNew {Ny}
translate d EngineEdit {Rediger}
translate d EngineRequired {Felter med fed skrift skal udfyldes. De øvrige er valgfrie}
translate d EngineNameInUse {Der findes allerede en motor med navnet %s. Vil du gemme denne som %s?}
translate d EngineProtocol {Kommunikationsprotokol}
translate d EngineNotation {Træknotation}
translate d EngineFlipEvaluation {Vend vurderingens fortegn}
translate d EngineShowLog {Vis kommunikationslog}
translate d EngineNetworkd {Tillad fjernforbindelser}
translate d EngineSelect {Vælg den aktuelle motor}
translate d EngineAddLocal {Tilføj en lokal motor}
translate d EngineAddRemote {Tilføj en fjernmotor}
translate d EngineReload {Genindlæs den aktuelle motor}
translate d EngineClone {Opret en kopi af den aktuelle motor}
translate d EngineDuplicate {Dupliker}
translate d EngineDelete {Slet den aktuelle motor}
translate d EngineOpenWindow {Åbn motorvindue}
translate d EngineShortcut {Genvej}
translate d EngineShortcutNone {Ingen}
translate d EngineShortcutWindow {Vindue %s (%s)}
translate d EngineShortcutKeys {Genvejstaster}
translate d EngineShortcutKeysHelp {Vælg den tast, der starter hvert motorvindue. Tryk på Skift..., og tryk derefter på den ønskede tastekombination. En tast, der allerede bruges af en anden kommando, afvises.}
translate d EngineShortcutChange {Skift...}
translate d EngineShortcutReset {Nulstil til F2 og F3}
translate d EngineShortcutPress {Tryk på den nye tastekombination til motorvindue %s.\nEscape annullerer.}
translate d EngineShortcutInUse {Tasten %s bruges allerede af en anden kommando. Vælg en anden.}
translate d EngineShortcutUnsafe {Vælg en funktionstast eller en tastekombination med Ctrl, Alt eller Command.}
translate d EngineShortcutReserved {Tasten er reserveret af styresystemet eller af tekstredigering. Vælg en anden.}

# PGN window menus:
menuText d PgnFile {Fil} 0
menuText d PgnFileCopy "Kopiér parti til udklipsholderen" 7
menuText d PgnFilePrint {Udskriv til fil...} 0
menuText d PgnFileClose {Luk PGN-vinduet} 0
menuText d PgnOpt {Visning} 0
menuText d PgnOptColor {Vis farver} 0
menuText d PgnOptShort {Kort overskrift (3 linjer)} 9
menuText d PgnOptSymbols {Kommentarsymboler} 10
menuText d PgnOptIndentC {Indryk kommentarer} 0
menuText d PgnOptIndentV {Indryk varianter} 7
menuText d PgnOptColumn {Kolonnevisning (ét træk pr. linje)} 1
menuText d PgnOptSpace {Mellemrum efter træknumre} 0
menuText d PgnOptStripMarks {Fjern koder for farvede felter og pile} 27
menuText d PgnOptBoldMainLine {Brug fed skrift til hovedvariantens træk} 0
menuText d PgnOptCenter {Centrer det aktuelle træk} 0
menuText d PgnColor {Farver} 0
menuText d PgnColorHeader {Partioplysninger...} 0
menuText d PgnColorAnno {Træksymboler...} 0
menuText d PgnColorComments {Kommentarer...} 0
menuText d PgnColorVars {Varianter...} 0
menuText d PgnColorBackground {Baggrund...} 0
menuText d PgnColorMain {Hovedvariant...} 0
menuText d PgnColorCurrent {Baggrund for aktuelt træk...} 5
menuText d PgnHelp {Hjælp} 0
menuText d PgnHelpPgn {Hjælp til PGN} 4
menuText d PgnHelpIndex {Stikordsregister} 2
translate d PgnWindowTitle {Notation – parti %u}

# Notation pane (PGN window) button tooltips:
translate d TBLookupTooltip {Slå op i Lichess' slutspilsdatabase}
translate d LichessEvalTooltip {Hent vurdering af stillingen fra Lichess' sky}
translate d LichessUploadTooltip {Upload partiet til Lichess.org}
translate d ChessComTooltip {Åbn partiet på analysebrættet på Chess.com}
translate d ChessDBTooltip {Åbn stillingen på ChessDB.cn}
translate d LichessOpenExTooltip {Slå stillingen op i Lichess' åbningsdatabase}
translate d LichessMonitorTooltip {Sæt direkte opdateringer på pause eller genoptag dem}
translate d LucasChessNoMacOS {Lucas Chess-motorerne er ikke tilgængelige på macOS}

# Crosstable window menus:
menuText d CrosstabFile {Fil} 0
menuText d CrosstabFileText "Skriv til tekstfil..." 10
menuText d CrosstabFileHtml {Udskriv til HTML-fil...} 12
menuText d CrosstabFileClose {Luk krydstabelvinduet} 0
menuText d CrosstabEdit {Rediger} 1
menuText d CrosstabEditEvent {Turnering} 4
menuText d CrosstabEditSite {Spillested} 0
menuText d CrosstabEditDate {Dato} 0
menuText d CrosstabOpt {Visning} 0
menuText d CrosstabOptAll {Alle mod alle} 0
menuText d CrosstabOptSwiss {Schweizersystem} 0
menuText d CrosstabOptKnockout {Knockout} 0
menuText d CrosstabOptAuto {Automatisk} 1
menuText d CrosstabOptAges {Alder i år} 0
menuText d CrosstabOptNats {Nationaliteter} 0
menuText d CrosstabOptRatings {Ratingtal} 0
menuText d CrosstabOptTitles {Titler} 0
menuText d CrosstabOptBreaks {Korrektionstal} 0
menuText d CrosstabOptDeleted {Medtag slettede partier} 2
menuText d CrosstabOptColors {Farver (kun schweizertabel)} 13
menuText d CrosstabOptColumnNumbers {Nummererede kolonner (kun alle mod alle)} 2
menuText d CrosstabOptGroup {Gruppér efter point} 0
menuText d CrosstabSort {Sortering} 0
menuText d CrosstabSortName {Navn} 0
menuText d CrosstabSortRating {Rating} 0
menuText d CrosstabSortScore {Resultat} 2
menuText d CrosstabColor {Farve} 0
menuText d CrosstabColorPlain {Almindelig tekst} 0
menuText d CrosstabColorHyper {Hypertekst} 0
menuText d CrosstabHelp {Hjælp} 0
menuText d CrosstabHelpCross {Hjælp til krydstabel} 0
menuText d CrosstabHelpIndex {Hjælpeindeks} 0
translate d SetFilter {Sæt filter}
translate d AddToFilter {Føj til filter}
translate d Swiss {Schweizersystem}
translate d Category {Kategori}

# Opening report window menus:
menuText d OprepFile {Fil} 0
menuText d OprepFileText "Skriv til tekstfil..." 10
menuText d OprepFileHtml {Udskriv til HTML-fil...} 12
menuText d OprepFileOptions {Indstillinger...} 0
menuText d OprepFileClose {Luk rapportvinduet} 0
menuText d OprepFavorites {Favoritter} 1
menuText d OprepFavoritesAdd {Tilføj rapport...} 8
menuText d OprepFavoritesEdit {Rediger favoritrapporter...} 1
menuText d OprepFavoritesGenerate {Opret rapporter...} 0
menuText d OprepHelp {Hjælp} 0
menuText d OprepHelpReport {Hjælp til åbningsrapport} 21
menuText d OprepHelpIndex {Hjælpeindeks} 0

# Header search:
translate d HeaderSearch {Søg i partioplysninger}
translate d EndSideToMove {Hvem er i trækket ved partiets afslutning?}
translate d GamesWithNoECO {Partier uden ECO-kode?}
translate d GameLength {Partilængde}
translate d FindGamesWith {Find partier med markeringer}
translate d StdStart {Anden startstilling}
translate d Promotions {Bondeforvandlinger}
translate d Variations {Varianter}
translate d Annotations {Træksymboler}
translate d DeleteFlag {Slettemarkering}
translate d WhiteOpFlag {Hvids åbning}
translate d BlackOpFlag {Sorts åbning}
translate d MiddlegameFlag {Midtspil}
translate d EndgameFlag {Slutspil}
translate d NoveltyFlag {Nyhed}
translate d PawnFlag {Bondestruktur}
translate d TacticsFlag {Taktik}
translate d QsideFlag {Spil på dronningefløjen}
translate d KsideFlag {Spil på kongefløjen}
translate d BrilliancyFlag {Glansparti}
translate d BlunderFlag {Grov fejl}
translate d UserFlag {Bruger}
translate d PgnContains {PGN indeholder teksten}
translate d PgnTag {PGN-felt}
translate d TagContains {indeholder}
translate d Variant {Variant}
translate d Annotator {Kommentator}
translate d Cmnts {Kun kommenterede partier}

# Game list window:
translate d GlistNumber {Nummer}
translate d GlistWhite {Hvid}
translate d GlistBlack {Sort}
translate d GlistWElo {H-Elo}
translate d GlistBElo {S-Elo}
translate d GlistEvent {Turnering}
translate d GlistSite {Spillested}
translate d GlistRound {Runde}
translate d GlistDate {Dato}
translate d GlistYear {År}
translate d GlistEDate {Turneringsdato}
translate d GlistResult {Resultat}
translate d GlistLength {Længde}
translate d GlistCountry {Land}
translate d GlistECO {ECO}
translate d GlistOpening {Åbning}
translate d GlistEndMaterial {Slutmateriale}
translate d GlistDeleted {Slettet}
translate d GlistFlags {Markeringer}
translate d GlistVars {Varianter}
translate d GlistComments {Kommentarer}
translate d GlistAnnos {Træksymboler}
translate d GlistStart {Start}
translate d GlistGameNumber {Partinummer}
translate d GlistAverageElo {Elo-gennemsnit}
translate d GlistRating {Rating}
translate d GlistFindText {Find tekst}
translate d GlistMoveField {Træk}
translate d GlistEditField {Tilpas}
translate d GlistAddField {Tilføj}
translate d GlistDeleteField {Fjern}
translate d GlistWidth {Bredde}
translate d GlistAlign {Justering}
translate d GlistAlignL {Venstrejusteret}
translate d GlistAlignR {Højrejusteret}
translate d GlistAlignC {Centreret}
translate d GlistColor {Farve}
translate d GlistSep {Skilletegn}
translate d GlistCurrentSep {-- Aktuel --}
translate d GlistNewSort {Ny}
translate d GlistAddToSort {Tilføj}

# base sorting
translate d GsortSort {Sorter...}
translate d GsortDate {Dato}
translate d GsortYear {År}
translate d GsortEvent {Turnering}
translate d GsortSite {Spillested}
translate d GsortRound {Runde}
translate d GsortWhiteName {Hvids navn}
translate d GsortBlackName {Sorts navn}
translate d GsortECO {ECO}
translate d GsortResult {Resultat}
translate d GsortMoveCount {Antal træk}
translate d GsortAverageElo {Elo-gennemsnit}
translate d GsortCountry {Land}
translate d GsortDeleted {Slettet}
translate d GsortEventDate {Turneringsdato}
translate d GsortWhiteElo {Hvids Elo}
translate d GsortBlackElo {Sorts Elo}
translate d GsortComments {Kommentarer}
translate d GsortVariations {Varianter}
translate d GsortNAGs {NAG-symboler}
translate d GsortAscending {Stigende}
translate d GsortDescending {Faldende}
translate d GsortAdd {Tilføj}
translate d GsortStore {Gem}
translate d GsortLoad {Indlæs}

# menu shown with right mouse button down on game list.
translate d GlistRemoveSelectedFromFilter {Fjern de valgte partier fra filteret}
translate d GlistExportSelected {Eksporter valgte partier...}
translate d GlistRemoveThisGameFromFilter {Fjern dette parti fra filteret}
translate d GlistRemoveGameAndAboveFromFilter {Fjern dette parti og alle ovenfor fra filteret}
translate d GlistRemoveGameAndBelowFromFilter {Fjern dette parti og alle nedenfor fra filteret}
translate d GlistDeleteGame {Skift slettemarkering for dette parti}
translate d GlistDeleteAllGames {Markér alle partier i filteret til sletning}
translate d GlistUndeleteAllGames {Fjern slettemarkeringen fra alle partier i filteret}
translate d GlistMergeGameInBase {Flet parti i database}

# Maintenance window:
translate d DatabaseName {Databasenavn:}
translate d TypeIcon {Typeikon:}
translate d NumOfGames {Partier:}
translate d NumDeletedGames {Slettede partier:}
translate d NumFilterGames {Partier i filteret:}
translate d YearRange {Årstal:}
translate d RatingRange {Ratinginterval:}
translate d Description {Beskrivelse}
translate d Flag {Markering}
translate d CustomFlags {Egne markeringer}
translate d DeleteCurrent {Markér aktuelt parti til sletning}
translate d DeleteFilter {Markér partier i filteret til sletning}
translate d DeleteAll {Markér alle partier til sletning}
translate d UndeleteCurrent {Fjern slettemarkering fra aktuelt parti}
translate d UndeleteFilter {Fjern slettemarkering fra partier i filteret}
translate d UndeleteAll {Fjern slettemarkering fra alle partier}
translate d DeleteTwins {Markér dubletter til sletning}
translate d MarkCurrent {Markér aktuelt parti}
translate d MarkFilter {Markér partier i filteret}
translate d MarkAll {Markér alle partier}
translate d UnmarkCurrent {Fjern markering fra aktuelt parti}
translate d UnmarkFilter {Fjern markering fra partier i filteret}
translate d UnmarkAll {Fjern markering fra alle partier}
translate d Spellchecking {Navnekontrol}
translate d Players {Spillere}
translate d Events {Turneringer}
translate d Sites {Spillesteder}
translate d Rounds {Runder}
translate d DatabaseOps {Databaseværktøjer}
translate d ReclassifyGames {ECO-klassificer partier}
translate d CompactDatabase {Komprimer database}
translate d SortDatabase {Sorter database}
translate d AddEloRatings {Tilføj Elo-tal}
translate d AutoloadGame {Indlæs automatisk parti nr.}
translate d StripTags {Fjern PGN-felter}
translate d StripTag {Fjern PGN-felt}
translate d Cleaner {Ryd op i databasen}
translate d CleanerHelp {
Scid udfører de vedligeholdelsesopgaver, du vælger nedenfor, på den aktive database.
Hvis du vælger ECO-klassificering eller sletning af dubletter, bruges de aktuelle indstillinger for disse funktioner.
}
translate d CleanerConfirm {
Vedligeholdelsen kan ikke afbrydes, når den er startet!

Det kan tage lang tid for en stor database, afhængigt af valgte funktioner og indstillinger.

Vil du starte de valgte vedligeholdelsesopgaver?
}
# Twinchecker
translate d TwinCheckUndelete { for at bytte om. "u" fjerner begge slettemarkeringer)}
translate d TwinCheckprevPair {Forrige par}
translate d TwinChecknextPair {Næste par}
translate d TwinChecker {scidCommunity: Dubletkontrol}
translate d TwinCheckTournament {Partier i turneringen:}
translate d TwinCheckNoTwin {Ingen dublet  }
translate d TwinCheckNoTwinfound {Der blev ikke fundet en dublet til dette parti.\nBrug først funktionen "Markér dubletter til sletning..." for at se dubletter her. }
translate d TwinCheckTag {Del PGN-felter...}
translate d TwinCheckFound1 {Scid fandt $result dubletter}
translate d TwinCheckFound2 { og markerede dem til sletning}
translate d TwinCheckNoDelete {Der er ingen partier at slette i databasen.}
translate d TwinCriteria1 { De valgte indstillinger kan medføre, at forskellige partier\nmed lignende træk bliver markeret som dubletter.}
translate d TwinCriteria2 {Hvis du vælger "Nej" til "samme træk", anbefales "Ja" for farver, turnering, spillested, runde, år og måned.\nVil du alligevel fortsætte og slette dubletter? }
translate d TwinCriteria3 {Vælg helst "Ja" til mindst to af indstillingerne "samme spillested", "samme runde" og "samme år".\nVil du alligevel fortsætte og slette dubletter?}
translate d TwinCriteriaConfirm {scidCommunity: Bekræft dubletindstillinger}
translate d TwinChangeTag {Rediger følgende PGN-felter:

}
translate d AllocRatingDescription {Denne funktion føjer Elo-tal til partier i databasen ud fra den aktuelle navnefil. Hvis en spiller mangler rating, og navnefilen indeholder spillerens rating på partitidspunktet, indsættes den.}
translate d RatingOverride {Overskriv eksisterende ratingtal over nul}
translate d AddRatings {Føj ratingtal til:}
translate d AddedRatings {Scid tilføjede $r Elo-tal i $g partier.}

#Bookmark editor
translate d NewSubmenu {Ny undermenu}

# Comment editor:
translate d AnnotationSymbols {Kommentarsymboler:}
translate d Comment {Kommentar:}
translate d Format {Format}
translate d Bold {Fed}
translate d Italic {Kursiv}
translate d Underline {Understreget}
translate d TextColor {Tekstfarve...}
translate d CommentDefaultColor {Standardfarve til kommentarer...}
translate d CommentFont {Skrifttype...}
translate d RemoveFormatting {Fjern formatering}
translate d Family {Skriftfamilie}
translate d Size {Størrelse}
translate d FontSizeWarning {Skriftstørrelsen skal være et positivt heltal.}
translate d Green {Grøn}
translate d Blue {Blå}
translate d Red {Rød}
translate d Brown {Brun}
translate d CustomColor {Brugerdefineret farve...}
translate d InsertMark {Indsæt markering}
translate d InsertMarkHelp {
Tilføj eller fjern en markering: Vælg farve, type og felt.
Tilføj eller fjern en pil: Højreklik på to felter.
}

# Nag buttons in comment editor:
translate d GoodMove {Godt træk}
translate d PoorMove {Svagt træk}
translate d ExcellentMove {Fremragende træk}
translate d Blunder {Grov fejl}
translate d InterestingMove {Interessant træk}
translate d DubiousMove {Tvivlsomt træk}
translate d WhiteDecisiveAdvantage {Hvid har afgørende fordel}
translate d BlackDecisiveAdvantage {Sort har afgørende fordel}
translate d WhiteClearAdvantage {Hvid har klar fordel}
translate d BlackClearAdvantage {Sort har klar fordel}
translate d WhiteSlightAdvantage {Hvid står lidt bedre}
translate d BlackSlightAdvantage {Sort står lidt bedre}
translate d WhiteCrushing {Hvid har overvældende fordel}
translate d BlackCrushing {Sort har overvældende fordel}
translate d Equality {Lige spil}
translate d Unclear {Uklart}
translate d Diagram {Diagram}

# Board search:
translate d BoardSearch {Stillingssøgning}
translate d FilterOperation {Ændring af det aktuelle filter:}
translate d FilterAnd {OG (indskrænk filteret)}
translate d FilterOr {ELLER (udvid filteret)}
translate d FilterIgnore {IGNORER (nulstil filteret)}
translate d SearchType {Søgetype:}
translate d SearchBoardExact {Nøjagtig stilling (alle brikker på samme felter)}
translate d SearchBoardPawns {Bønder (samme materiale og samme bondestilling)}
translate d SearchBoardFiles {Linjer (samme materiale og bønder på samme linjer)}
translate d SearchBoardAny {Vilkårlig (samme materiale, uanset placering)}
translate d SearchInRefDatabase { Søg i referencedatabasen }
translate d LookInVars {Søg i varianter}

# Moves search:
translate d MovesSearchHint {Træk i rækkefølge i SAN-notation, f.eks. e4 e5 Nf3. "?" matcher ét vilkårligt træk.}
translate d LastMoveIsMate {Sidste træk sætter mat}

# Material search:
translate d MaterialSearch {Materialesøgning}
translate d Material {Materiale}
translate d Patterns {Mønstre}
translate d Zero {Nul}
translate d Any {Vilkårlig}
translate d CurrentBoard {Aktuel brætstilling}
translate d CommonEndings {Typiske slutspil}
translate d CommonPatterns {Typiske mønstre}
translate d MaterialDiff {Materialeforskel}
translate d squares {felter}
translate d SameColor {Samme farve}
translate d OppColor {Modsat farve}
translate d Either {Begge muligheder}
translate d MoveNumberRange {Interval for træknumre}
translate d MatchForAtLeast {Stillingen skal vare mindst}
translate d HalfMoves {halvtræk}

# Common endings in material search:
translate d EndingPawns {Bondeslutspil}
translate d EndingRookVsPawns {Tårn mod en eller flere bønder}
translate d EndingRookPawnVsRook {Tårn og én bonde mod tårn}
translate d EndingRookPawnsVsRook {Tårn og en eller flere bønder mod tårn}
translate d EndingRooks {Tårnslutspil}
translate d EndingRooksPassedA {Tårnslutspil med en a-fribonde}
translate d EndingRooksDouble {Dobbelttårnslutspil}
translate d EndingBishops {Løber mod løber}
translate d EndingBishopVsKnight {Løber mod springer}
translate d EndingKnights {Springer mod springer}
translate d EndingQueens {Dronning mod dronning}
translate d EndingQueenPawnVsQueen {Dronning og én bonde mod dronning}
translate d BishopPairVsKnightPair {Midtspil med to løbere mod to springere}

# Common patterns in material search:
translate d PatternWhiteIQP {Hvid isoleret d-bonde}
translate d PatternWhiteIQPBreakE6 {Hvid isoleret d-bonde: fremstødet d4-d5 mod e6}
translate d PatternWhiteIQPBreakC6 {Hvid isoleret d-bonde: fremstødet d4-d5 mod c6}
translate d PatternBlackIQP {Sort isoleret d-bonde}
translate d PatternWhiteBlackIQP {Hvid isoleret d-bonde mod sort isoleret d-bonde}
translate d PatternCoupleC3D4 {Hvidt isoleret bondepar på c3 og d4}
translate d PatternHangingC5D5 {Sorte hængebønder på c5 og d5}
translate d PatternMaroczy {Maróczy-centrum (bønder på c4 og e4)}
translate d PatternRookSacC3 {Tårnoffer på c3}
translate d PatternKc1Kg8 {O-O-O mod O-O (Kc1 mod Kg8)}
translate d PatternKg1Kc8 {O-O mod O-O-O (Kg1 mod Kc8)}
translate d PatternLightFian {Fianchetto på lyse felter (Lg2 mod Lb7)}
translate d PatternDarkFian {Fianchetto på mørke felter (Lb2 mod Lg7)}
translate d PatternFourFian {Fire fianchetterede løbere (b2, g2, b7 og g7)}

# Game saving:
translate d SaveExtraTagsHint {Ekstra PGN-felter (eksempel: Annotator "Anand, V")}
translate d Today {I dag}
translate d ClassifyGame {Klassificer partiet}

# Setup position:
translate d EmptyBoard {Tomt bræt}
translate d InitialBoard {Udgangsstilling}
translate d SideToMove {Siden i trækket}
translate d MoveNumber {Træknummer}
translate d Castling {Rokade}
translate d EnPassantFile {En passant-linje}
translate d ClearFen {Ryd FEN}
translate d PasteFen {Indsæt FEN}

translate d SaveAndContinue {Gem og fortsæt}
translate d DiscardChangesAndContinue {Kassér ændringer og fortsæt}
translate d GoBack {Gå tilbage}

# Replace move dialog:
translate d ReplaceMove {Erstat træk}
translate d AddNewVar {Tilføj ny variant}
translate d NewMainLine {Ny hovedvariant}
translate d ReplaceMoveMessage {Der er allerede et træk her.

Du kan erstatte trækket og kassere alle efterfølgende træk, eller du kan tilføje dit træk som en ny variant.

Du kan undgå denne besked ved at slå "Spørg før træk erstattes" fra under Indstillinger > Træk.}

# Make database read-only dialog:
translate d ReadOnlyDialog {Hvis du skrivebeskytter databasen, kan du ikke gemme eller erstatte partier eller ændre slettemarkeringer.
Resultater af sortering og ECO-klassificering vil være midlertidige.

Du kan få skriveadgang igen ved at lukke databasen og åbne den på ny.

Vil du skrivebeskytte databasen?}

# Clear game dialog:
translate d ClearGameDialog {Partiet er ændret.

Vil du fortsætte og kassere ændringerne?
}

# Exit dialog:
translate d ExitDialog {Vil du afslutte Scid?}
translate d ExitUnsaved {Der er ugemte partiændringer i følgende databaser. Afslutter du nu, går ændringerne tabt.}

# Import window:
translate d PasteCurrentGame {Indsæt det aktuelle parti}
translate d ImportHelp1 {Indtast eller indsæt et parti i PGN-format i feltet ovenfor.}
translate d ImportHelp2 {Eventuelle fejl ved import af partiet vises her.}
translate d OverwriteExistingMoves {Overskriv de eksisterende træk?}

# ECO Browser:
translate d ECOAllSections {alle ECO-afsnit}
translate d ECOSection {ECO-afsnit}
translate d ECOSummary {Oversigt for}
translate d ECOFrequency {Underkodernes hyppighed for}

# Opening Report:
translate d OprepReportFor {Rapport for}
translate d OprepTitle {Åbningsrapport}
translate d OprepReport {Rapport}
translate d OprepGenerated {Oprettet af}
translate d OprepStatsHist {Statistik og historik}
translate d OprepStats {Statistik}
translate d OprepStatAll {Alle partier i rapporten}
translate d OprepStatBoth {Begge har rating}
translate d OprepStatSince {Siden}
translate d OprepOldest {Ældste partier}
translate d OprepNewest {Nyeste partier}
translate d OprepPopular {Aktuel popularitet}
translate d OprepFreqAll {Hyppighed for alle år:    }
translate d OprepFreq1 {I det seneste år:         }
translate d OprepFreq5 {I de seneste 5 år:        }
translate d OprepFreq10 {I de seneste 10 år:       }
translate d OprepEvery {én gang for hver %u partier}
translate d OprepUp {%u%s højere end for alle år}
translate d OprepDown {%u%s lavere end for alle år}
translate d OprepSame {uændret i forhold til alle år}
translate d OprepMostFrequent {Hyppigste spillere}
translate d OprepMostFrequentOpponents {Hyppigste modstandere}
translate d OprepRatingsPerf {Rating og præstation}
translate d OprepAvgPerf {Gennemsnitlig rating og præstation}
translate d OprepWRating {Hvids rating}
translate d OprepBRating {Sorts rating}
translate d OprepWPerf {Hvids præstation}
translate d OprepBPerf {Sorts præstation}
translate d OprepHighRating {Partier med højest gennemsnitlig rating}
translate d OprepTrends {Udvikling i resultater}
translate d OprepResults {Partilængder og resultaternes hyppighed}
translate d OprepLength {Partilængde}
translate d OprepFrequency {Hyppighed}
translate d OprepWWins {Hvide sejre: }
translate d OprepBWins {Sorte sejre: }
translate d OprepDraws {Remiser:     }
translate d OprepWholeDB {hele databasen}
translate d OprepShortest {Korteste gevinstpartier}
translate d OprepMovesThemes {Træk og temaer}
translate d OprepMoveOrders {Trækfølger, der fører til rapportstillingen}
translate d OprepMoveOrdersOne {Kun én trækfølge førte til stillingen:}
translate d OprepMoveOrdersAll {%u trækfølger førte til stillingen:}
translate d OprepMoveOrdersMany {%u trækfølger førte til stillingen. De %u hyppigste er:}
translate d OprepMovesFrom {Træk fra rapportstillingen}
translate d OprepMostFrequentEcoCodes {Hyppigste ECO-koder}
translate d OprepThemes {Positionelle temaer}
translate d OprepThemeDescription {Temaernes hyppighed i de første %u træk af hvert parti}
translate d OprepThemeSameCastling {Rokade til samme side}
translate d OprepThemeOppCastling {Rokade til hver sin side}
translate d OprepThemeNoCastling {Ingen af kongerne har rokeret}
translate d OprepThemeKPawnStorm {Bondestorm på kongefløjen}
translate d OprepThemeQueenswap {Dronningerne er byttet af}
translate d OprepThemeWIQP {Hvid isoleret d-bonde}
translate d OprepThemeBIQP {Sort isoleret d-bonde}
translate d OprepThemeWP567 {Hvid bonde på 5., 6. eller 7. række}
translate d OprepThemeBP234 {Sort bonde på 2., 3. eller 4. række}
translate d OprepThemeOpenCDE {Åben c-, d- eller e-linje}
translate d OprepTheme1BishopPair {Kun én side har løberparret}
translate d OprepEndgames {Slutspil}
translate d OprepReportGames {Partier i rapporten}
translate d OprepAllGames {Alle partier}
translate d OprepEndClass {Materiale ved partiets afslutning}
translate d OprepTheoryTable {Teoritabel}
translate d OprepTableComment {Baseret på de %u partier med højest rating.}
translate d OprepExtraMoves {Ekstra træk i teoritabellens noter}
translate d OprepMaxGames {Maks. antal partier i teoritabellen}
translate d OprepMergeMoves {Trækgrænse for flettede partier}
translate d OprepMergeUnique {Flet kun forskellige partier}
translate d OprepViewHTML {Vis HTML}

# Player Report:
translate d PReportTitle {Spillerrapport}
translate d PReportColorWhite {med de hvide brikker}
translate d PReportColorBlack {med de sorte brikker}
translate d PReportMoves {efter %s}
translate d PReportOpenings {Åbninger}
translate d PReportClipbase {Tøm udklipsdatabasen, og kopiér de matchende partier til den}

# Piece Tracker window:
translate d TrackerSelectSingle {Venstreklik for at vælge brikken.}
translate d TrackerSelectPair {Venstreklik vælger brikken. Højreklik vælger også den anden brik af samme type.}
translate d TrackerSelectPawn {Venstreklik vælger bonden. Højreklik vælger alle otte bønder.}
translate d TrackerStat {Statistik}
translate d TrackerGames {% partier med træk til feltet}
translate d TrackerTime {% af tiden på hvert felt}
translate d TrackerMoves {Træk}
translate d TrackerMovesStart {Indtast det træknummer, hvor sporingen skal begynde.}
translate d TrackerMovesStop {Indtast det træknummer, hvor sporingen skal slutte.}

# Game selection dialogs:
translate d SelectAllGames {Alle partier i databasen}
translate d SelectFilterGames {Kun partier i filteret}
translate d SelectTournamentGames {Kun partier i den aktuelle turnering}
translate d SelectOlderGames {Kun ældre partier}

# Delete Twins window:
translate d TwinsNote {To partier kan kun være dubletter, hvis de har de samme to spillere og opfylder kriterierne nedenfor. Når der findes et par, markeres det korteste parti til sletning. Kontrollér gerne navnene i databasen først, så flere dubletter bliver fundet. }
translate d TwinsCriteria {Dubletter skal have...}
translate d TwinsWhich {Hvilke partier skal undersøges?}
translate d TwinsColors {Samme spillerfarver}
translate d TwinsEvent {Samme turnering}
translate d TwinsSite {Samme spillested}
translate d TwinsRound {Samme runde}
translate d TwinsYear {Samme år}
translate d TwinsMonth {Samme måned}
translate d TwinsDay {Samme dag}
translate d TwinsResult {Samme resultat}
translate d TwinsECO {Samme ECO-kode}
translate d TwinsMoves {Samme træk}
translate d TwinsPlayers {Sammenligning af spillernavne}
translate d TwinsPlayersExact {Nøjagtigt sammenfald}
translate d TwinsPlayersPrefix {Kun de første fire bogstaver}
translate d TwinsWhen {Ved sletning af dubletter}
translate d TwinsSkipShort {Ignorer alle partier på under fem træk}
translate d TwinsUndelete {Fjern først alle slettemarkeringer}
translate d TwinsSetFilter {Sæt filteret til alle slettemarkerede dubletter}
translate d TwinsComments {Behold altid partier med kommentarer}
translate d TwinsVars {Behold altid partier med varianter}
translate d TwinsDeleteWhich {Markér parti til sletning}
translate d TwinsDeleteShorter {Partiet med færrest træk}
translate d TwinsDeleteOlder {Laveste partinummer}
translate d TwinsDeleteNewer {Højeste partinummer}
translate d TwinsDelete {Slet partier}

# Name editor window:
translate d NameEditType {Navnetype, der skal redigeres}
translate d NameEditSelect {Partier, der skal redigeres}
translate d NameEditReplace {Erstat}
translate d NameEditWith {med}
translate d NameEditMatches {Forslag: Vælg med Ctrl+1 til Ctrl+9}
translate d NameEditWildcard {Jokertegn i navne: * står for vilkårlige tegn (1* begynder med 1, *Whelan slutter på Whelan)}

# Check games window:
translate d CheckGames {Kontrollér partier}
translate d CheckGamesWhich {Kontrollér partier}
translate d CheckAll {Alle partier}
translate d CheckSelectFilterGames {Kun partier i filteret}

# Classify window:
translate d Classify {Klassificer}
translate d ClassifyWhich {Hvilke partier skal ECO-klassificeres?}
translate d ClassifyAll {Alle partier (overskriv gamle ECO-koder)}
translate d ClassifyYear {Alle partier spillet det seneste år}
translate d ClassifyMonth {Alle partier spillet den seneste måned}
translate d ClassifyNew {Kun partier uden ECO-kode}
translate d ClassifyCodes {ECO-koder, der skal bruges}
translate d ClassifyBasic {Kun grundkoder ("B12", ...)}
translate d ClassifyExtended {Scid-udvidelser ("B12j", ...)}
translate d ClassifyResult {ECO-klassificeringen er færdig: $result parti(er) opdateret.}

# Compaction:
translate d NameFile {Navnefil}
translate d GameFile {Partifil}
translate d Names {Navne}
translate d Unused {Ubrugte}
translate d SizeKb {Størrelse (kB)}
translate d CurrentState {Nuværende tilstand}
translate d AfterCompaction {Efter komprimering}
translate d CompactNames {Komprimer navnefil}
translate d CompactGames {Komprimer partifil}
translate d NoUnusedNames {Alle navne er i brug. Navnefilen kan ikke komprimeres yderligere.}
translate d NoUnusedGames {Partifilen kan ikke komprimeres yderligere.}
translate d GameFileCompacted {Databasens partifil er komprimeret.}

# Sorting:
translate d SortCriteria {Kriterier}
translate d AddCriteria {Tilføj kriterier}
translate d CommonSorts {Almindelige sorteringer}
translate d Sort {Sortering}

# Exporting:
translate d AddToExistingFile {Føj partier til en eksisterende fil}
translate d ExportComments {Eksporter kommentarer}
translate d ExportVariations {Eksporter varianter}
translate d IndentComments {Indryk kommentarer}
translate d IndentVariations {Indryk varianter}
translate d ExportColumnStyle {Kolonnevisning (ét træk pr. linje)}
translate d ExportSymbolStyle {Format for kommentarsymboler:}
translate d ExportStripMarks {Fjern koder for felter og pile\nfra kommentarer}
translate d OptionsExportEol {Linjeskift:}
translate d OptionsExportEolNative {Systemets standard}
translate d OptionsPGNExport {PGN-eksport}
translate d OptionsTagOrderIntro {Rækkefølgen af de øvrige PGN-felter, når et parti gemmes. De syv obligatoriske felter skrives altid først efter PGN-standarden.}
translate d OptionsTagOrderStr {De syv faste felter: Event, Site, Date, Round, White, Black, Result}
translate d OptionsTagOrderWhite {Hvids rating}
translate d OptionsTagOrderBlack {Sorts rating}
translate d OptionsTagOrderOthers {Øvrige felter}
translate d OptionsTagOrderSort {Sorter øvrige felter alfabetisk (ellers beholdes den oprindelige rækkefølge)}
translate d Up {Op}
translate d Down {Ned}

# Goto game/move dialogs:
translate d LoadGameNumber {Indtast nummeret på det parti, du vil hente:}
translate d GotoMoveNumber {Gå til træknummer:}

# Copy games dialog:
translate d CopyAllGames {Kopiér alle partier til}
translate d CopyGames {Kopiér partier}
translate d CopyConfirm {
 Vil du kopiere de [::utils::thousands $nGamesToCopy] partier
 i filteret i databasen "$fromName"
 til databasen "$targetName"?
}
translate d CopyErr {Kan ikke kopiere partier}
translate d CopyErrSource {kildedatabasen}
translate d CopyErrTarget {måldatabasen}
translate d CopyErrNoGames {har ingen partier i filteret}
translate d CopyErrReadOnly {er skrivebeskyttet}
translate d CopyErrNotOpen {er ikke åben}

# Colors:
translate d LightSquares {Lyse felter}
translate d DarkSquares {Mørke felter}
translate d PickColorFromScreen {Vælg farve fra skærmen}
translate d SaveCurrentColors {Gem de aktuelle farver}
translate d SaveCurrentColorsHint {Føj de aktuelle brætfarver til listen over farvesæt}
translate d RemoveSavedColor {Fjern dette gemte farvesæt}
translate d ColorPresetExists {Disse farver er allerede gemt som farvesæt %d}
translate d SelectedSquares {Valgte felter}
translate d SuggestedSquares {Foreslåede målfelter}
translate d WhitePieces {Hvide brikker}
translate d BlackPieces {Sorte brikker}
translate d WhiteBorder {Hvid kant}
translate d BlackBorder {Sort kant}

# Novelty window:
translate d FindNovelty {Find nyhed}
translate d Novelty {Nyhed}
translate d NoveltyInterrupt {Nyhedssøgningen blev afbrudt}
translate d NoveltyNone {Der blev ikke fundet nogen nyhed i partiet}
translate d NoveltyHelp {Scid finder det første træk i partiet, som fører til en stilling, der hverken findes i den valgte database eller i ECO-åbningsbogen.}

# Sounds configuration:
translate d SoundsFolder {Mappe med lydfiler}
translate d SoundsFolderHelp {Mappen skal indeholde filerne King.wav, a.wav, 1.wav osv.}
translate d SoundsTheme {Lydtema}
translate d SoundsThemeDefault {Standard (Scid)}
translate d SoundsThemeHelp {Lyde for træk og hændelser kommer fra det valgte tema. Tilføj dit eget tema ved at kopiere en mappe med lydfiler til temamappen.}
translate d SoundsAnnounceOptions {Indstillinger for trækoplæsning}
translate d SoundsAnnounceNew {Læs nye træk op, når de udføres}
translate d SoundsMoveSoundOnly {Afspil kun træklyd (ingen oplæsning)}
translate d SoundsAnnounceForward {Læs trækket op, når der gås ét træk frem}
translate d SoundsAnnounceBack {Giv besked, når et træk tages tilbage, eller der gås ét træk tilbage}
translate d SoundsSoundDisabled {Scid kunne ikke finde lydpakken Snack ved opstart.\nLyden er slået fra.}

# Upgrading databases:
translate d Upgrading {Opgraderer}
translate d ConfirmOpenNew {
Dette er en database i det gamle Scid 3-format. Den kan ikke åbnes i Scid 4, men der findes allerede en kopi i Scid 4-format.

Vil du åbne databasen i det nye format?
}
translate d ConfirmUpgrade {
Databasen er i det gamle Scid 3-format. For at bruge den i Scid 4 skal den konverteres.

Opgraderingen opretter en ny version af databasen og fjerner derefter de oprindelige filer.

Det kan tage et stykke tid, men skal kun gøres én gang. Du kan annullere, hvis det tager for lang tid.

Vil du opgradere databasen nu?
}

# Recent files options:
translate d RecentFilesMenu {Antal seneste filer i menuen Fil}
translate d RecentFilesExtra {Antal seneste filer i den ekstra undermenu}

# My Player Names options:
translate d MyPlayerNamesDescription {Indtast dine foretrukne spillernavne nedenfor, ét pr. linje. Du kan bruge jokertegn: "?" for ét tegn og "*" for et vilkårligt antal tegn.
Når du indlæser et parti med en spiller på listen, vendes brættet om nødvendigt, så du ser det fra spillerens side.
}

# Computer Tournament:
translate d configComp {Indstil turnering}
translate d Tournament {Turnering}
translate d Available {Tilgængelige}
translate d Selected {Valgte}
translate d RoundRobin {Alle mod alle}
translate d Gauntlet {Én mod alle}
translate d CompGameNext {Næste parti:}
translate d TimeperGame {Tid pr.\nparti}
translate d TimeperMove {Tid pr.\ntræk}
translate d compStoreTime {Gem tid: }
translate d Clock {Ur}
translate d compConcurrent {Samtidige partier: }
translate d compShowBoards {Vis brætter}
translate d compCarousel {Karruselsystem}
translate d compSaveEval {Gem vurdering}
translate d compCanceledGames {Afbrudte partier eller tidsoverskridelser:}
translate d Replay {Spil igen}
translate d compStart {Start}
translate d compSave {Gem efter hvert parti}
translate d compStop {Stop efter det\naktuelle parti}
translate d compRunning {Turneringen er i gang}
translate d Restart {Start igen}
translate d compFinished {Turneringen er afsluttet}
translate d compStopped {Turneringen er stoppet}
translate d compForceDraw {Fremtving remis}
translate d compForceResign {Fremtving opgivelse}
translate d compAfterMove {Efter træk:}
translate d compNumMoves {Antal træk:}
translate d compScoreLess {Vurdering under:}
translate d compScoreGreater {Vurdering over:}
translate d compRepeatReverse {Gentag med ombyttede farver}

#Coach
translate d showblunderexists {vis, om der er en grov fejl}
translate d showblundervalue {vis tabet ved den grove fejl}
translate d showscore {vis vurdering}
translate d coachgame {parti med træner}
translate d white {hvid}
translate d black {sort}
translate d both {begge}
translate d configurePlayEngine {Spil mod en skakmotor}
translate d UseChessClock {Brug skakur}
translate d Play {Spil}
translate d Noblunder {Ingen grov fejl}
translate d blunder {grov fejl}
translate d Noinfo {-- Ingen oplysninger --}
translate d moveblunderthreshold {trækket er en grov fejl, hvis tabet overstiger}
translate d limitanalysis {begræns motorens analysetid}
translate d seconds {sekunder}
translate d Abort {Afbryd}
translate d Resume {Genoptag}
translate d OutOfOpening {Ude af åbningen}
translate d NotFollowedLine {Du fulgte ikke varianten}
translate d DoYouWantContinue {Vil du fortsætte?}
translate d CoachIsWatching {Træneren følger med}
translate d Ponder {Tænk i modstanderens tid}
translate d LimitELO {Begræns spillestyrke (Elo)}
translate d DubiousMovePlayedTakeBack {Du spillede et tvivlsomt træk. Vil du tage det tilbage?}
translate d WeakMovePlayedTakeBack {Du spillede et svagt træk. Vil du tage det tilbage?}
translate d BadMovePlayedTakeBack {Du spillede et dårligt træk. Vil du tage det tilbage?}
translate d Iresign {Jeg opgiver}
translate d ResultSaved {Resultatet er gemt}
translate d yourmoveisnotgood {Dit træk er ikke godt}
translate d EndOfVar {Varianten er slut}
translate d Openingtrainer {Åbningstræner}
translate d DisplayCM {Vis kandidattræk}
translate d DisplayCMValue {Vis vurdering af kandidattræk}
translate d DisplayOpeningStats {Vis statistik}
translate d ShowReport {Vis rapport}
translate d NumberOfGoodMovesPlayed {gode træk spillet}
translate d NumberOfDubiousMovesPlayed {tvivlsomme træk spillet}
translate d NumberOfMovesPlayedNotInRepertoire {spillede træk uden for repertoiret}
translate d NumberOfTimesPositionEncountered {gange stillingen er forekommet}
translate d PlayerBestMove {Tillad kun de bedste træk}
translate d OpponentBestMove {Modstanderen spiller de bedste træk}
translate d OnlyFlaggedLines {Kun markerede varianter}
translate d resetStats {Nulstil statistik}
translate d Repertoiretrainingconfiguration {Indstillinger for repertoiretræning}
translate d Loadingrepertoire {Indlæser repertoire}
translate d Movesloaded {Træk indlæst}
translate d Repertoirenotfound {Repertoiret blev ikke fundet}
translate d Openfirstrepertoirewithtype {Åbn først en repertoiredatabase med ikon/type sat til den ønskede farve}
translate d Movenotinrepertoire {Trækket findes ikke i repertoiret}
translate d PositionsInRepertoire {Stillinger i repertoiret}
translate d PositionsNotPlayed {Stillinger, der ikke er spillet}
translate d PositionsPlayed {Spillede stillinger}
translate d Success {Succes}
translate d DubiousMoves {Tvivlsomme træk}
translate d OutOfRepertoire {Uden for repertoiret}
translate d ConfigureTactics {Indstil taktiktræning}
translate d ResetScores {Nulstil point}
translate d LoadingBase {Indlæser database}
translate d Tactics {Taktik}
translate d ShowSolution {Vis løsning}
translate d NextExercise {Næste opgave}
translate d PrevExercise {Forrige opgave}
translate d StopTraining {Stop træning}
translate d Next {Næste}
translate d ResettingScore {Nulstiller point}
translate d LoadingGame {Indlæser parti}
translate d MateFound {Mat fundet}
translate d BestSolutionNotFound {Den bedste løsning blev ikke fundet!}
translate d MateNotFound {Mat blev ikke fundet}
translate d ShorterMateExists {Der findes en kortere matføring}
translate d ScorePlayed {Vurdering af det spillede træk}
translate d Expected {forventet}
translate d ChooseTrainingBase {Vælg træningsdatabase}
translate d Thinking {Tænker}
translate d AnalyzeDone {Analysen er færdig}
translate d WinWonGame {Vind en vundet stilling}
translate d TacticsEngineStartFail {Kunne ikke starte taktikmotoren: %s}
translate d TacticsEngineGone {Taktikmotoren stoppede: %s}
translate d TacticsNoAssessment {Motoren gav ingen vurdering af stillingen}
translate d Lines {Varianter}
translate d ConfigureUCIengine {Indstil UCI-motor}
translate d SpecificOpening {Bestemt åbning}
translate d StartNewGame {Start nyt parti}
translate d Opening {Åbning}
translate d StartFromCurrentPosition {Start fra den aktuelle stilling}
translate d ShowDigitalClock {Vis digitalur}
translate d ClockFromGame {Start med tiderne fra partiet}
translate d ClocksContinued {Urene fortsætter fra partiets tider}
translate d ClocksRestarted {Urene er startet forfra}
translate d FixedDepth {Fast dybde}
translate d Nodes {Knuder}
translate d Depth {Dybde}
translate d Time {Tid}
translate d SecondsPerMove {Sekunder pr. træk}
translate d Engine {Skakmotor}
translate d TimeMode {Tidskontrol}
translate d TimeBonus {Tid + tillæg}
translate d TimeMin {min.}
translate d TimeSec {sek.}
translate d AllExercisesDone {Alle opgaver er gennemført}
translate d FindOpeningErrors {Find åbningsfejl}
translate d MarkTacticalExercises {Markér taktikopgaver}
translate d UseBook {Brug bog}
translate d MultiPV {Flere varianter}
translate d Hash {Hashhukommelse}
translate d OwnBook {Brug motorens bog}
translate d BookFile {Åbningsbog}
translate d AddScoreToShortAnnotations {Føj vurdering til kommentarer}
translate d AddScoreToAllMoves {Føj vurdering til alle træk}
translate d Export {Eksporter}
translate d BookPartiallyLoaded {Bogen er delvist indlæst}
# Opening names used in tacgame.tcl
translate d Reti {Rétis åbning}
translate d English {Engelsk åbning}
translate d d4Nf6Miscellaneous {1.d4 Sf6, diverse}
translate d Trompowsky {Trompowsky}
translate d Budapest {Budapestgambit}
translate d OldIndian {Gammelindisk}
translate d BenkoGambit {Benkő-gambit}
translate d ModernBenoni {Moderne Benoni}
translate d DutchDefence {Hollandsk}
translate d Scandinavian {Skandinavisk}
translate d AlekhineDefence {Aljechins forsvar}
translate d Pirc {Pirc}
translate d CaroKann {Caro-Kann}
translate d CaroKannAdvance {Caro-Kann, fremstødsvarianten}
translate d Sicilian {Siciliansk}
translate d SicilianAlapin {Siciliansk, Alapin-varianten}
translate d SicilianClosed {Lukket siciliansk}
translate d SicilianRauzer {Siciliansk, Rauzer-varianten}
translate d SicilianDragon {Siciliansk, dragevarianten}
translate d SicilianScheveningen {Siciliansk, Scheveningen-varianten}
translate d SicilianNajdorf {Siciliansk, Najdorf-varianten}
translate d OpenGame {Åbent spil}
translate d Vienna {Wienerparti}
translate d KingsGambit {Kongegambit}
translate d RussianGame {Russisk}
translate d ItalianTwoKnights {Italiensk/tospringerspil}
translate d Spanish {Spansk}
translate d SpanishExchange {Spansk, afbytningsvarianten}
translate d SpanishOpen {Åbent spansk}
translate d SpanishClosed {Lukket spansk}
translate d FrenchDefence {Fransk}
translate d FrenchAdvance {Fransk, fremstødsvarianten}
translate d FrenchTarrasch {Fransk, Tarrasch-varianten}
translate d FrenchWinawer {Fransk, Winawer-varianten}
translate d FrenchExchange {Fransk, afbytningsvarianten}
translate d QueensPawn {Dronningebondespil}
translate d Slav {Slavisk}
translate d QGA {Modtaget dronningegambit}
translate d QGD {Afslået dronningegambit}
translate d QGDExchange {Afslået dronningegambit, afbytningsvarianten}
translate d SemiSlav {Halvslavisk}
translate d QGDwithBg5 {Afslået dronningegambit med Lg5}
translate d QGDOrthodox {Ortodokst dronningegambit}
translate d Grunfeld {Grünfeldindisk}
translate d GrunfeldExchange {Grünfeldindisk, afbytningsvarianten}
translate d GrunfeldRussian {Grünfeldindisk, den russiske variant}
translate d Catalan {Catalansk}
translate d CatalanOpen {Åben catalansk}
translate d CatalanClosed {Lukket catalansk}
translate d QueensIndian {Dronningindisk}
translate d NimzoIndian {Nimzoindisk}
translate d NimzoIndianClassical {Nimzoindisk, den klassiske variant}
translate d NimzoIndianRubinstein {Nimzoindisk, Rubinstein-varianten}
translate d KingsIndian {Kongeindisk}
translate d KingsIndianSamisch {Kongeindisk, Sämisch-varianten}
translate d KingsIndianMainLine {Kongeindisk, hovedvarianten}

# FICS
translate d ConfigureFics {Indstil FICS}
translate d FICSGuest {Log ind som gæst}
translate d FICSServerPort {Serverport}
translate d FICSServerAddress {IP-adresse}
translate d FICSRefresh {Opdater}
translate d FICSTimesealPort {Timeseal-port}
translate d FICSSilence {Konsolfilter}
translate d FICSOffers {Tilbud}
translate d FICSConsole {Konsol}
translate d FICSGames {Partier}
translate d FICSUnobserve {Stop med at følge partiet}
translate d FICSProfile {Vis din historik og profil}
translate d FICSRelayedGames {Videresendte partier}
translate d FICSFindOpponent {Find modstander}
translate d FICSTakeback {Tag træk tilbage}
translate d FICSTakeback2 {Tag to halvtræk tilbage}
translate d FICSInitTime {Starttid (min.)}
translate d FICSIncrement {Tidstillæg (sek.)}
translate d FICSRatedGame {Ratet parti}
translate d FICSAutoColour {automatisk}
translate d FICSManualConfirm {bekræft manuelt}
translate d FICSFilterFormula {Filtrer med formel}
translate d FICSIssueSeek {Søg modstander}
translate d FICSChallenge {Udfordring}
translate d FICSAccept {Accepterer du?}
translate d FICSDecline {afslå}
translate d FICSColour {Farve}
translate d FICSSend {send}
translate d FICSConnect {Opret forbindelse}
translate d FICSdefaultuservars {Brug standardvariabler}
translate d FICSObserveconfirm {Vil du følge partiet}
translate d FICSpremove {Tillad forhåndstræk}
translate d FICSObserve {Følg}
translate d FICSRatedGames {Ratede partier}
translate d FICSUnratedGames {Uratede partier}
translate d FICSRated {Ratet}
translate d FICSUnrated {Uratet}
translate d FICSRegisteredPlayer {Kun registrerede spillere}
translate d FICSFreePlayer {Kun ledige spillere}
translate d FICSNetError {Netværksfejl\nKan ikke oprette forbindelse til }
translate d OptionsFICS {FICS}
translate d FICSTerminalColor {Terminalfarve}
translate d FICSTextColor {Tekstfarve}

# Game review

# Correspondence Chess Dialogs:
translate d CCDlgCGeneraloptions {Generelle indstillinger}
translate d CCDlgLoginName {Brugernavn:}
translate d CCDlgPassword {Adgangskode:}
translate d CCDlgShowPassword {Vis adgangskode}

# Connect Hardware dialogs
translate d ExtHWConfigConnection {Indstil eksternt udstyr}
translate d ExtHWPort {Port}
translate d ExtHWEngineCmd {Motorkommando}
translate d ExtHWEngineParam {Motorparameter}
translate d ExtHWShowButton {Vis knap}
translate d ExtHWHardware {Udstyr}
translate d ExtHWNovag {Novag Citrine}
translate d ExtHWInputEngine {Indlæsningsmotor}
translate d ExtHWNoBoard {Intet bræt}
translate d NovagReferee {Dommer}

# Input Engine dialogs
translate d IEConsole {Konsol til indlæsningsmotor}
translate d IESending {Træk sendt for}
translate d IESynchronise {Synkroniser}
translate d IERotate {Drej}
translate d IEUnableToStart {Kunne ikke starte indlæsningsmotoren:}

translate d Board {Bræt}
translate d showGameInfo {Vis partioplysninger}
translate d autoResizeBoard {Tilpas automatisk brættets størrelse}
translate d DockTop {Flyt øverst}
translate d DockBottom {Flyt nederst}
translate d DockLeft {Flyt til venstre}
translate d DockRight {Flyt til højre}
translate d Undock {Frigør vindue}
translate d Dock {Fastgør vindue}

# Switcher window
translate d AboutDatabase {Om denne database}
translate d ChangeIcon {Vælg databaseikon...}
translate d NewGameListWindow {Nyt vindue med partiliste}
translate d LoadatStartup {Åbn ved opstart}

# Gamelist window
translate d ShowHideDB {Vis eller skjul databaser}
translate d ChangeFilter {Skift filter}
translate d ChangeLayout {Indlæs, gem eller rediger sortering og kolonner}
translate d ShowHideStatistic {Vis eller skjul statistik}
translate d BoardFilter {Vis kun partier med den aktuelle brætstilling}
translate d CopyGameTo {Kopiér parti til}
translate d FindBar {Søgelinje}
translate d FindCurrentGame {Find det aktuelle parti}
translate d DeleteGame {Markér parti til sletning}
translate d UndeleteGame {Fjern slettemarkering}
translate d ResetSort {Nulstil sortering}
translate d LayoutExists {Layoutet '%s' findes allerede.}
translate d ConfirmDeleteLayout {Vil du slette layoutet '%s'?}
translate d ConfirmStripGames {Fjern kommentarer og træksymboler fra %d valgte parti(er)?}

translate d ConvertNullMove {Konverter nultræk til kommentarer}
translate d SetupBoard {Opstil bræt}
translate d Rotate {Drej}
translate d SwitchColors {Byt farver}
translate d FlipBoard {Vend brættet}
translate d Board3D {3D-bræt}
translate d Board3DReset {Nulstil}
translate d Board3DResetTip {Gendan kameraets standardvisning}
translate d Board3DZoomIn {Zoom ind}
translate d Board3DZoomOut {Zoom ud}
translate d Board3DDragToRotate {Træk for at dreje}
translate d Board3DScrollToZoom {Rul for at zoome}
translate d ImportPGN {Importer PGN-parti}
translate d ImportingFiles {Importerer PGN-filer til}
translate d ImportingFrom {Importerer fra}
translate d ImportingIn {Importer partier til}
translate d UseLastTag {Brug felter fra\nseneste parti}
translate d Random {Tilfældig}
translate d BackToMainline {Tilbage til hovedvarianten}
translate d LeaveVariant {Forlad varianten}
translate d Autoplay {Automatisk gennemspilning}
translate d ShowHideCoords {Vis eller skjul koordinater}
translate d ShowHideEvalBar {Vis eller skjul vurderingsbjælke}
translate d ShowHideMaterial {Vis eller skjul materiale}
translate d SelectMarker {Vælg markør}
translate d FullScreen {Fuld skærm}
translate d FilterStatistic {Filterstatistik}
translate d MakeCorrections {Udfør rettelser}
translate d Surnames {Efternavne}
translate d Ambiguous {Tvetydige}

#Preferences Dialog
translate d OptionsToolbar {Værktøjslinje}
translate d OptionsBoard {Skakbræt}
translate d OptionsBoardSize {Brætstørrelse}
translate d OptionsBoardPieces {Brikstil}
translate d OptionsInternationalization {Sprog og lokal tilpasning}
translate d OptionsTablebaseDir {Vælg op til fire mapper med slutspilsdatabaser:}

# Evaluation bar
translate d BestMoveArrow {Pil for bedste træk}
translate d NewLocalEngine {+ Ny motor...}

# Batch Annotate
translate d BatchAnnotate {Kommentér valgte partier}
translate d BatchEngineSelection {Motorvalg}
translate d BatchChessEngine {Skakmotor:}
translate d BatchNumberOfInstances {Antal motorinstanser:}
translate d BatchTimePerMove {Tid pr. træk (sek.):}
translate d BatchAnnotateBlunders {Kommenter kun grove fejl}
translate d BatchBlunderThreshold {Grænse for grov fejl:}
translate d BatchVariationLength {Variantlængde (træk):}
translate d BatchOpeningBook {Åbningsbog}
translate d BatchUseBook {Brug bog}
translate d BatchAnnotateVariations {Kommenter varianter}
translate d BatchShortAnnotations {Korte kommentarer}
translate d BatchAddScoreToShort {Føj vurdering til korte kommentarer}
translate d BatchClearOld {Fjern tidligere kommentarer og varianter}
translate d BatchInitializingEngines {Starter skakmotorer...}
translate d BatchAnalyzingGames {Analyserer partier...}
translate d BatchProgress {Status for kommentering af valgte partier}
translate d BatchComplete {Kommentering af valgte partier er færdig!}
translate d BatchCancelled {Kommentering af valgte partier blev afbrudt}
translate d BatchStart {Start}
translate d BatchCancel {Annuller}
translate d BatchCompleted {gennemført}
translate d BatchGames {partier}
translate d BatchProcessed {behandlet}
translate d BatchUnscoredPlies {halvtræk uden vurdering: %s}
translate d TablebaseWindow {Slutspilsdatabase}
translate d TBWinMoves {--- Gevinsttræk ---}
translate d TBDrawMoves {--- Remistræk ---}
translate d TBLossMoves {--- Tabstræk ---}
translate d TBNoMoves {Ingen lovlige træk fundet.}
translate d TBTooMany {For mange brikker. Lichess' slutspilsdatabase understøtter højst syv brikker.}
translate d TBQuerying {Sender forespørgsel til Lichess' API...}
translate d TBError {Kunne ikke starte curl for at kontakte Lichess.}
translate d TBQueryError {Ugyldigt svar fra slutspilsdatabasens API.}
translate d TBNotFound {Stillingen findes ikke i slutspilsdatabasen, eller der opstod en API-fejl.}
translate d TBCategory {Stillingskategori:}
translate d TBTrainingHidden {(Træningstilstand: Resultaterne er skjult)}

# ICCF (International Correspondence Chess Federation)
menuText d ToolsTrainICCF "Spil på ICCF" 8 {Spil korrespondanceskak på ICCF}
translate d ICCFTitle {Spil på ICCF}
translate d ICCFLogin {Brugernavn}
translate d ICCFPassword {Adgangskode}
translate d ICCFConnect {Opret forbindelse}
translate d ICCFClose {Luk}
translate d ICCFUpdateGames {Opdater partier}
translate d ICCFSendMoves {Send træk}
translate d ICCFYourMessage {Din besked}
translate d ICCFGameID {Parti}
translate d ICCFOpponent {Modstander}
translate d ICCFEvent {Turnering}
translate d ICCFLastMove {Seneste træk}
translate d ICCFSent {Sendt}
translate d ICCFYourMove {Dit træk}
translate d ICCFOfferDraw {Tilbyd remis}
translate d ICCFResign {Opgiv}
translate d ICCFWaiting {Venter}
translate d ICCFYourTurn {Din tur}
translate d ICCFCredentialsNeeded {Indtast dit ICCF-brugernavn og din adgangskode.}
translate d ICCFUpdating {Henter partier fra ICCF-serveren...}
translate d ICCFGamesUpdated {Partier: %s tilføjet, %s træk opdateret, %s ajour}
translate d ICCFSendingMoves {Sender træk til ICCF-serveren...}
translate d ICCFMovesSent {Sendte træk: %s lykkedes, %s mislykkedes}
translate d ICCFNoGamesFound {Ingen partier fundet.}
translate d ICCFFilterError {Fejl i filteret.}
translate d ICCFConnectionFailed {Kunne ikke oprette forbindelse til ICCF-serveren. Kontrollér netværksforbindelsen.}
translate d ICCFAuthFailed {Login mislykkedes. Kontrollér brugernavn og adgangskode.}
translate d ICCFNeedUpdate {Tryk først på "Opdater partier" for at hente de aktuelle partier fra serveren.}
translate d ICCFNoDatabase {Åbn først en database.}
translate d ICCFMyTime {Mit ur}
translate d ICCFOppTime {Modstanderens ur}
translate d ICCFDrawOffered {Remis tilbudt}
# LSS (Lechenicher SchachServer)
menuText d ToolsTrainLSS "Spil på LSS" 8 {Spil korrespondanceskak på Lechenicher SchachServer}
translate d LSSTitle {Spil på LSS – Lechenicher SchachServer}
translate d LSSConfigure {Indstil LSS}
translate d LSSServer {LSS-server}
translate d LSSLogin {Brugernavn}
translate d LSSPassword {Adgangskode}
translate d LSSConnect {Opret forbindelse}
translate d LSSClose {Luk}
translate d LSSUpdateGames {Opdater partier}
translate d LSSSendMoves {Send træk}
translate d LSSGamesList {Partiliste}
translate d LSSOpponentMessage {Modstanderens besked}
translate d LSSYourMessage {Din besked}
translate d LSSGameID {Parti}
translate d LSSOpponent {Modstander}
translate d LSSTime {Tid}
translate d LSSWhiteElo {Hvids Elo}
translate d LSSBlackElo {Sorts Elo}
translate d LSSEvent {Turnering}
translate d LSSLastMove {Seneste træk}
translate d LSSSent {Sendt}
translate d LSSYourMove {Dit træk}
translate d LSSOfferDraw {Tilbyd remis}
translate d LSSResign {Opgiv}
translate d LSSWaiting {Venter}
translate d LSSYourTurn {Din tur}
translate d LSSCredentialsNeeded {Indtast dit LSS-brugernavn og din adgangskode.}
translate d LSSUpdating {Henter partier fra LSS-serveren...}
translate d LSSGamesUpdated {Partier: %s tilføjet, %s træk opdateret, %s ajour}
translate d LSSSendingMoves {Sender træk til LSS-serveren...}
translate d LSSMovesSent {Sendte træk: %s lykkedes, %s mislykkedes}
translate d LSSNoGamesFound {Ingen partier fundet.}
translate d LSSFilterError {Fejl i filteret.}
translate d LSSConnectionFailed {Kunne ikke oprette forbindelse til LSS-serveren. Kontrollér netværksforbindelsen.}
translate d LSSAuthFailed {Login mislykkedes. Kontrollér brugernavn og adgangskode.}
translate d LSSNeedUpdate {Tryk først på "Opdater partier" for at hente de aktuelle partier fra serveren.}
translate d LSSNoDatabase {Åbn først en database.}
translate d LSSGameNumber {LSS}
translate d LSSMyTime {Mit ur}
translate d LSSOppTime {Modstanderens ur}
translate d LSSDrawOffered {Remis tilbudt}

# RTF Export and Import
translate d RtfExportTitle {Eksporter til RTF-fil}
translate d RtfExportError {Fejl ved eksport til RTF}
translate d RtfImportTitle {Importer RTF-fil}
translate d RtfImportError {Fejl ved import af RTF-fil}
translate d RtfNotScidFile {Filen er beskadiget eller blev ikke eksporteret fra scidCommunity med kommentarformatering.}
translate d RtfImportSuccess {Partiet er importeret til udklipsdatabasen.}
translate d RtfImportSuccessMulti {%d partier er importeret til udklipsdatabasen.}

# Review progress pane (#422 item 3).
# Keep this block before the CQL entries: the language files carry it there,
# and tcl/lang/propagatelang.tcl compares entry positions.
translate d ReviewProgressTitle {Analyseforløb}
translate d ReviewProgressIdle {Ingen gennemgang i gang}
translate d ReviewProgressGameOf {parti %s af %s}
translate d ReviewProgressEngineWindow {Motorvindue %s}
translate d ReviewProgressRapid {Hurtig kommentering}
translate d FinishGameGameChanged {partiet blev ændret under færdigspilningen. Der blev ikke gemt noget}
translate d FinishGameAtEnd {Gå først til hovedvariantens sidste træk for at spille partiet færdigt}
# CQL search:
translate d CQLQuery {CQL-forespørgsel}
translate d CQLQueryHint {CQL-forespørgsel, f.eks. cql() mate eller cql(:gamenumber 1 10) K. Søg med Ctrl+Enter.}
translate d CQLQueryEmpty {Indtast en CQL-forespørgsel før søgningen.}
translate d CQLSearchFailed {CQL-søgningen mislykkedes:}
translate d CQLUnreadableGames {%d parti(er) kunne ikke læses}
}
