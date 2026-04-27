# norsk.tcl
# Text for menu names and status bar help messages in Norwegian.
# First created for Scid 3.2.beta2 by morten.skarstad@sapphire.no.
# Edited for Scid 3.2.beta4
# Thanks to Martin Skjldebrand, swedish.tcl was of great help to me.

proc setLanguage_O {} {

# File menu:
menuText O File "Fil" 0
menuText O FileNew "Ny..." 0 {Lag en ny Scid-database}
menuText O FileOpen "pne..." 0 {pne en Scid-database}
menuText O FileClose "Lukk" 0 {Lukk aktiv Scid-database}
menuText O FileFinder "Sk" 0 {pne skevinduet}
menuText O FileBookmarks "Bokmerker" 0 {Bokmerkemeny (snarvei: Ctrl+B)}
menuText O FileBookmarksAdd "Legg til bokmerke" 0 \
  {Sett bokmerke til nvrende database, parti og stilling}
menuText O FileBookmarksFile "Lagre bokmerke" 0 \
  {Lagre et bokmerke for nvrende database, parti og stilling}
menuText O FileBookmarksEdit "Ordne bokmerker" 0 \
  {Vedlikehold av bokmerkene}
menuText O FileBookmarksList "Vis kataloger som enkel liste" 24 \
  {Vis bokmerker som liste, ikke undermenyer}
menuText O FileBookmarksSub "Vis kataloger som undermenyer" 18 \
  {Vis bokmerke-katalogene som undermenyer, ikke liste}
menuText O FileMaint "Vedlikehold" 0 {Verkty for  vedlikeholde Scid-databasen}
menuText O FileMaintWin "Vedlikeholdsvindu" 0 \
  {pne/lukk Scids vedlikeholdsvindu}
menuText O FileMaintCompact "Komprimer database..." 0 \
  {Sletter ubrukte partier og navn}
menuText O FileMaintClass "ECO-klassifiser partier..." 0 \
  {Regn om ECO-koden for alle partier}
menuText O FileMaintSort "Sorter database..." 0 \
  {Sorter alle partier i databasen}
menuText O FileMaintDelete "Slett duplikater..." 6 \
  {Finner like partier og merker en av dem for sletting}
menuText O FileMaintTwin "Duplikatsjekkvindu" 1 \
  {pne/oppdatere duplikatsjekkvinduet}
menuText O FileMaintName "Navnestaving" 0 {Redigering og stavekontroll av navn}
menuText O FileMaintNameEditor "Navneredigering" 5 \
  {pne/lukk vinduet for navneredigering}
menuText O FileMaintNamePlayer "Kontroller navn..." 0 \
  {Sammenlign navn med stavekontroll-filen}
menuText O FileMaintNameEvent "Kontroller anledninger..." 11 \
  {Sammenlign anledninger med stavekontroll-filen}
menuText O FileMaintNameSite "Kontroller stedsnavn..." 12 \
  {Sammenlign stedsnavn med stavekontroll-filen}
menuText O FileMaintNameRound "Kontroller runde-navn..." 11 \
  {Sammenlign rundenavn med stavekontroll-filen}
menuText O FileReadOnly "Skrivebeskytt..." 6 \
  {Hindrer endringer p databasen}
menuText O FileSwitch "Switch to database" 0 \
  {Switch to a different opened database} ;# ***
menuText O FileOpenLichessTournament "pen Lichess-turnering" 0 {Last ned og pne live kringkastingsspill for Lichess-turneringer}
menuText O FileImportLichess "Importer min Lichess" 0 {Importer spill fra Lichess-kontoen din}
menuText O FileImportChessCom "Importer min chess.com" 0 {Importer spill fra chess.com-kontoen din}
menuText O FileExit "Avslutt" 0 {Avslutt Scid}
menuText O FileMaintFixBase "Reparer delagt base" 0 {Prv  fikse en delagt base}

# Edit menu:
menuText O Edit "Rediger" 0
menuText O EditAdd "Legg til variasjon" 0 {Legg til en variasjon av dette trekket i partiet}
menuText O EditDelete "Slett variasjon" 0 {Slett en variasjon av dette trekket}
menuText O EditFirst "Flytt variasjon verst" 0 \
  {Gjr variasjonen til den verste p listen}
menuText O EditMain "Gjr variasjon til hovedlinje" 0 \
  {Gjr variasjon til hovedlinje}
menuText O EditTrial "Prv variasjon" 0 \
  {Start/avslutt prvemodus, for  teste ut en ide p brettet}
menuText O EditStrip "Fjern" 0 {Fjern kommentarer eller variasjoner fra partiet}
menuText O EditUndo "Angre" 0 {Angre siste spillendring}
menuText O EditRedo "Gjenta" 0 {Gjenta siste spillendring}
menuText O EditStripComments "Kommentarer" 0 \
  {Fjern alle kommentarer og annotasjoner fra dette partiet}
menuText O EditStripVars "Variasjoner" 0 {Fjern alle variasjoner fra dette partiet}
menuText O EditStripBegin "Moves from the beginning" 1 \
  {Strip moves from the beginning of the game} ;# ***
menuText O EditStripEnd "Moves to the end" 0 \
  {Strip moves to the end of the game} ;# ***
menuText O EditReset "Rensk utklippsbase" 0 \
  {Tmmer utklippsbasen fullstendig}
menuText O EditCopy "Kopier partiet til utklippsbasen" 0 \
  {Kopier dette partiet til utklippsbasen}
menuText O EditPaste "Lim inn siste parti fra utklippsbasen" 0 \
  {Limer inn gjeldende parti fra utklippsbasen her}
menuText O EditPastePGN "Paste Clipboard text as PGN game..." 10 \
  {Interpret the clipboard text as a game in PGN notation and paste it here} ;# ***
menuText O EditSetup "Still opp stilling..." 0 \
  {Lag en startstilling for dette partiet}
menuText O EditCopyBoard "Copy position" 6 \
  {Copy the current board in FEN notation to the text selection (clipboard)} ;# ***
menuText O EditPasteBoard "Lim inn stilling" 0 \
  {Lag en startstilling fra gjeldende utvalg (utklippstavle)}
menuText O ConfigureScid "Innstillinger..." 0 {Konfigurer alle alternativer for SCID}

# Game menu:
menuText O Game "Parti" 0
menuText O GameNew "Nytt parti" 0 \
  {Sletter alle trekk og starter et nytt parti}
menuText O GameFirst "Hent frste parti" 0 {Henter frste parti fra filteret}
menuText O GamePrev "Hent forrige parti" 0 {Henter forrige parti fra filteret}
menuText O GameReload "Hent dette partiet" 0 \
  {Henter dette partiet p nytt og fjerner alle endringer}
menuText O GameNext "Hent neste parti" 0 {Henter neste parti fra filteret}
menuText O GameLast "Hent siste parti" 0 {Henter siste parti fra filteret}
menuText O GameRandom "Hent tilfeldig parti" 8 {Hent tilfeldig parti fra filteret}
menuText O GameNumber "Hent parti nummer..." 0 \
  {Finn et parti ved  angi nummeret}
menuText O GameReplace "Lagre: Erstatt parti..." 0 \
  {Lagre og overskriv dette partiet}
menuText O GameAdd "Lagre som nytt parti..." 0 \
  {Lagre dette partiet som et nytt parti}
menuText O GameDeepest "Identifiser pning" 0 \
  {G til dypeste posisjon i dette partiet listet i ECO-boken}
menuText O GameGotoMove "G til trekk..." 0 \
  {G til et angitt trekk i dette partiet}
menuText O GameNovelty "Finn avvik..." 0 \
  {Finn det frste trekket i dette partiet som ikke har blitt spilt tidligere}

# Search Menu:
menuText O Search "Sk" 0
menuText O SearchReset "Nullstill filter" 0 {Nullstill filteret til  inneholde alle partier}
menuText O SearchNegate "Snu filter" 0 {Reverserer filteret til  kun inneholde eksluderte partier}
menuText O SearchCurrent "Stilling..." 0 {Sk etter denne stillingen}
menuText O SearchHeader "Header..." 0 {Sk etter Header (partier, turnering etc) informasjon}
menuText O SearchMaterial "Kvalitet/stilling..." 0 {Sk p kvalitet eller stilling}
menuText O SearchUsing "Bruk skefil..." 0 {Sk vha lagrede skevilkr}

# Windows menu:
menuText O Windows "Vinduer" 0
menuText O WindowsComment "Kommentarer" 0 {pne/lukk kommentarvinduet}
menuText O WindowsGList "Partioversikt" 0 {pne/lukk partioversikten}
menuText O WindowsPGN "PGN-vindu" 0 \
  {pne/lukk PGN-vinduet}
menuText O WindowsPList "Player Finder" 2 {Open/close the player finder} ;# ***
menuText O WindowsTmt "Turneringsker" 0 {pne/lukk turneringsskeren}
menuText O WindowsSwitcher "Databasebytter" 0 \
  {pne/lukk databasebytteren}
menuText O WindowsMaint "Vedlikeholdsvindu" 0 \
  {pne/lukk vedlikeholdsvinduet}
menuText O WindowsECO "ECO-oversikt" 0 {pne/lukk ECO-oversikten}
menuText O WindowsStats "Statistikkvindu" 0 \
  {pne/lukk statistikk for filteret}
menuText O WindowsTree "Trevindu" 0 {pne/lukk trevinduet}
menuText O WindowsBook "Bokvindu" 0 {pne/lukk bokvinduet}
menuText O WindowsCorrChess "Korrespondansevindu" 0 {pne/lukk korrespondansevinduet}
menuText O WindowsGraph "Analysegraf" 0 {pne grafvinduet med trekktider og evalueringer}

# Tools menu:
menuText O Tools "Verkty" 0
menuText O ToolsConfigureEngines "Konfigurer motorer" 10 {Administrer motorens konfigurasjon}
menuText O ToolsAnalysis "Analysemotor..." 0 \
  {Start/stopp en sjakkanalysemotor}
menuText O ToolsAnalysis2 "Analysemotor #2..." 0 \
  {Start/stopp enda en sjakkanalysemotor}
menuText O ToolsCross "Krysstabell" 0 {Vis turnerigskrystabellen for dette partiet}
menuText O ToolsFilterGraph "Filtergraf" 7 \
  {pne/lukk filtergrafvinduet}
menuText O ToolsAbsFilterGraph "Abs. Filtergraf" 7 {pne/lukk filtergrafvinduet for absolutte verdier}
menuText O ToolsOpReport "pningsrapport" 0 \
  {Lager en pningsrapport for denne stillingen}
menuText O ToolsOpenBaseAsTree "pen base som tre" 0   {pne en base og bruk den i trevinduet}
menuText O ToolsOpenRecentBaseAsTree "pne nylig base som tre" 0   {pne en nylig base og bruk den i trevinduet}
menuText O ToolsTracker "Brikkesporing"  0 {pne brikkesporingsvinduet}
menuText O ToolsTraining "Opplring"  0 {Treningsverkty (taktikk, pninger,...)}
menuText O ToolsTacticalGame "Taktisk spill"  0 {Spill et spill med taktikk}
menuText O ToolsSeriousGame "Serist spill"  0 {Spill et serist spill}
menuText O ToolsTrainOpenings "pninger"  0 {Tren med repertoar}
menuText O ToolsTrainReviewGame "Gjennomg spillet"  0 {Gjett trekk som spilles i et spill}
menuText O ToolsTrainTactics "Taktikk"  0 {Ls taktikk}
menuText O ToolsTrainCalvar "Beregning av variasjoner"  0 {Beregning av variasjoner trening}
menuText O ToolsTrainFindBestMove "Finn det beste trekket"  0 {Finn det beste trekket}
menuText O ToolsTrainFics "Spill p internett"  0 {Spill p freechess.org}
menuText O ToolsEngineTournament "Motorturnering"  0 {Start en turnering mellom sjakkmotorer}
menuText O ToolsTimeAnalysis "Tidsanalyse" 0 {Vis klokketidsgraf for gjeldende spill}
menuText O ToolsBookTuning "Boktuning" 0 {Boktuning}
menuText O ToolsDownloadTWIC "Last ned TWIC-partier" 0 {Last ned de siste The Week In Chess (TWIC)-partiene}
menuText O ToolsConnectHardware "Koble til maskinvare" 0 {Koble til ekstern maskinvare}
menuText O ToolsConnectHardwareConfigure "Konfigurer..." 0 {Konfigurer ekstern maskinvare og tilkobling}
menuText O ToolsConnectHardwareNovagCitrineConnect "Koble til Novag Citrine" 0 {Koble til Novag Citrine}
menuText O ToolsConnectHardwareInputEngineConnect "Koble til inngangsmotor" 0 {Koble til inngangsmotor (f.eks. DGT)}

menuText O ToolsPInfo "Spillerinformasjon"  0 \
  {pne/oppdater informasjonsvinduet for denne spilleren}
menuText O ToolsPlayerReport "Player Report..." 3 \
  {Generate a player report} ;# ***
menuText O ToolsRating "Ratinggraf" 0 \
  {Tegner ratingen til disse spillerene over tid}
menuText O ToolsExpCurrent "Eksporter parti" 0 \
  {Skriv dette partiet til en tekstfil}
menuText O ToolsExpCurrentPGN "Eksporter parti til PGN-fil..." 0 \
  {Skriv dette partiet til en PGN-fil}
menuText O ToolsExpCurrentHTML "Eksporter parti til HTML fil..." 0 \
  {Skriv dette partiet til en HTML-fil}
menuText O ToolsExpCurrentHTMLJS "Eksporter spillet til HTML- og JavaScript-fil..." 15 {Skriv gjeldende spill til en HTML- og JavaScript-fil}  
menuText O ToolsExpFilter "Eksporter alle partier i filteret" 0 \
  {Skriv alle partier i filteret til en tekstfil}
menuText O ToolsExpFilterPGN "Eksporter filter til PGN-fil..." 0 \
  {Skriv alle partier i filteret til en PGN-fil}
menuText O ToolsExpFilterHTML "Eksporter filter til HTML-fil..." 0 \
  {Skriv alle partier i filteret til en HTML-fil}
menuText O ToolsExpFilterHTMLJS "Eksporter filter til HTML- og JavaScript-fil..." 17 {Skriv alle filtrerte spill til en HTML- og JavaScript-fil}  
menuText O ToolsImportOne "Importer ett PGN-parti..." 0 \
  {Importer ett parti fra en PGN-fil}
menuText O ToolsImportFile "Importer fil med PGN-partier..." 0 \
  {Importer partier fra en PGN-fil}
menuText O ToolsStartEngine1 "Start motoren 1" 0  {Start motoren 1}
menuText O ToolsStartEngine2 "Start motor 2" 0  {Start motor 2}
menuText O ToolsCaptureBoard "Ta opp gjeldende tavle..." 0  {Lagre gjeldende tavle som et bilde.}

# Play menu
menuText O Play "Spille" 0

# --- Correspondence Chess
menuText O CCResign "Si opp" 0 {Si opp (ikke via e-post)}
menuText O CCClaimDraw "Krev trekning" 0 {Send trekk og krev uavgjort (ikke via e-post)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText O Options "Innstillinger" 0
menuText O OptionsBoardGraphics "Firkanter..." 0 {Velg teksturer for ruter}
translate O OptionsBGW {Velg tekstur for ruter}
translate O OptionsBoardGraphicsText {Velg grafikkfiler for hvite og svarte firkanter:}
menuText O OptionsBoardNames "My Player Names..." 0 {Edit my player names} ;# ***
menuText O OptionsExport "Eksport" 0 {Endre innstillinger for eksport av tekst}
menuText O OptionsFonts "Skrifttyper" 0 {Endre skrifttyper}
menuText O OptionsFontsRegular "Vanlig" 0 {Endre den vanlige skrifttypen}
menuText O OptionsFontsMenu "Menu" 0 {Change the menu font} ;# ***
menuText O OptionsFontsSmall "Liten" 0 {Endre den lille skrifttypen}
menuText O OptionsFontsTiny "Tiny" 0 {Endre den lille skriften}
menuText O OptionsFontsFixed "Fastbredde" 0 {Endre fastbreddeskrifttypen}
menuText O OptionsGInfo "Partiinformasjon" 0 {Informasjonsinnstillinger}
menuText O OptionsLanguage "Sprk" 0 {Velg menysprk}
menuText O OptionsMovesTranslatePieces "Oversett stykker" 0 {Oversett frste bokstav i stykker}
menuText O OptionsMovesHighlightLastMove "Marker siste trekk" 0 {Marker siste trekk}
menuText O OptionsMovesHighlightLastMoveDisplay "Vis Square" 0 {Vis siste trekk Marker}
menuText O OptionsMovesHighlightLastMoveWidth "Bredde" 0 {Tykkelse p linjen}
menuText O OptionsMovesHighlightLastMoveColor "Farge" 0 {Farge p linjen}
menuText O OptionsMovesHighlightLastMoveArrow "Vis pil" 0 {Vis pil med utheving}
menuText O OptionsMovesHighlightLastMoveNag "Vis evalueringssymboler" 0
menuText O OptionsMovesHighlightLastMoveEval "Vis evalueringssymboler" 0
menuText O OptionsMoves "Trekk" 0 {Innstillinger for hvordan trekk angis}
menuText O OptionsMovesAnimate "Animation time" 1 \
  {Set the amount of time used to animate moves} ;# ***
menuText O OptionsMovesDelay "Autospillforsinkelse..." 0 \
  {Sett forsinkelsen ved automatisk gjennomgang av partiet}
menuText O OptionsMovesCoord "Koordinater" 0 \
  {Tillat angivelse av koordinater ("g1f3")}
menuText O OptionsMovesSuggest "Vis foresltte trekk" 0 \
  {Sl av/p forslag til trekk}
menuText O OptionsShowVarPopup "Vis varianter-vinduet" 0 {Sl p/av visningen av et variasjonsvindu}  
menuText O OptionsMovesSpace "Legg til mellomrom etter trekknummer" 0 {Legg til mellomrom etter trekknummer}  
menuText O OptionsMovesLichess "Lichess/ChessBase-format for merknader" 0 {Bruk formatet Lichess/ChessBase for firkantede markrer og piler}
menuText O OptionsMovesKey "Autofullfr" 0 \
  {Sl av/p autofullfriring av tastaturtrekk}
menuText O OptionsMovesShowVarArrows "Vis piler for varianter" 0 {Sl p/av piler som viser bevegelser i varianter}
menuText O OptionsMovesShowEngineVariationArrows "Vis piler for motorvariasjoner" 0 {Sl p/av-piler som viser motorvariasjonslinjer i multiPV-modus}
menuText O OptionsMovesGlossOfDanger "Fargekodet Gloss of Danger" 0 {Sl p/av fargekodet gloss of fare}
translate O OptionsMovesTreeDepth {Standard trevindu flyttedybde}
menuText O OptionsNumbers "Tallformat" 0 {Angi tallformat}
menuText O OptionsTheme "Tema" 0 {Endre utseendet p grensesnittet}
menuText O OptionsWindows "Vinduer" 0 {Vindusinnstillinger}
menuText O OptionsSounds "Sounds" 2 {Configure move announcement sounds} ;# ***
menuText O OptionsResources "Ressurser..." 0 {Velg ressursfiler og mapper}
menuText O OptionsWindowsDock "Dock vinduer" 0 {Dock vinduer}
menuText O OptionsWindowsSaveLayout "Lagre layout" 0 {Lagre layout}
menuText O OptionsWindowsRestoreLayout "Gjenopprett layout" 0 {Gjenopprett layout}
menuText O OptionsWindowsShowGameInfo "Vis spillinformasjon" 0 {Vis spillinformasjon}
menuText O OptionsWindowsAutoLoadLayout "Last inn frste layout automatisk" 0 {Last inn frste layout automatisk ved oppstart}
menuText O OptionsECO "Hent ECO-fil" 0 {Henter filen med ECO-klassifiseringer}
menuText O OptionsSpell "Hent stavekontrollfil" 0 \
  {Henter filen med stavekontrollen til Scid}
menuText O OptionsTable "Tabellbasekatalog" 0 \
  {Velg en tabellbase; Alle tabellbaser i katalogen vil bli brukt}
menuText O OptionsRecent "Recent files..." 0 \
  {Change the number of recent files displayed in the File menu} ;# ***
menuText O OptionsBooksDir "Bker katalog" 0 {Angir pningsbokkatalogen}
menuText O OptionsTacticsBasesDir "Baser katalog" 0 {Angir taktikk (trening) basekatalogen}
menuText O OptionsPhotosDir "Fotokatalog" 0 {Stiller inn fotobasekatalogen}
menuText O OptionsThemeDir "Temafil:"  0 {Last inn en GUI-temapakkefil}
menuText O OptionsSave "Lagre innstillinger" 0 \
  "Lagre alle instillinger til $::optionsFile"
menuText O OptionsAutoSave "Autolagre innstillinger ved avslutning" 0 \
  {Autolagre alle innstillinger nr Scid avsluttes}

# Help menu:
menuText O Help "Hjelp" 0
menuText O HelpContents "Contents" 0 {Show the help contents page} ;# ***
menuText O HelpIndex "Innhold" 0 {Hjelpesystemets innhold}
menuText O HelpGuide "Lynguide" 0 {Vis lynguiden}
menuText O HelpHints "Hint" 0 {Vis hint}
menuText O HelpContact "Kontaktinformasjon" 0 {Vis kontaktinformasjon}
menuText O HelpTip "Dagens tips" 0 {Vis et nyttig Scid-tips}
menuText O HelpStartup "Oppstartsvindu" 0 {Vis oppstartsvindu}
menuText O HelpAbout "Om Scid" 0 {Informasjon om Scid}

# Toolbar tooltips:
menuText O RotateBoard "Roter brettet" 0 {Roter brettet}

# Game info box popup menu:
menuText O GInfoHideNext "Skjul neste trekk" 0
menuText O GInfoMaterial "Vis kvalitet" 0
menuText O GInfoFEN "Vis FEN" 0
menuText O GInfoMarks "Vis fargede ruter og piler" 0
menuText O GInfoWrap "Tekstbryting" 0
menuText O GInfoFullComment "Vis full kommentar" 0
menuText O GInfoPhotos "Show Photos" 5 ;# ***
menuText O GInfoTBNothing "Tabellbaser: ingenting" 0
menuText O GInfoTBResult "Tabellbaser: kun resultater" 0
menuText O GInfoTBAll "Tabellbaser: resultater og beste trekk" 0
menuText O GInfoDelete "Slett/gjenopprett dette partiet" 0
menuText O GInfoMark "(Av)Merk dette partiet" 0
menuText O GInfoInformant "Konfigurer informantverdier" 0

# General buttons:
translate O Back {Tilbake}
translate O Browse {Browse} ;# ***
translate O Cancel {Avbryt}
translate O Continue {Fortsette}
translate O Clear {Slett}
translate O Close {Lukk}
translate O Contents {Contents} ;# ***
translate O Defaults {Standard}
translate O InvertSearch {Inverter sk}
translate O Delete {Slett}
translate O Graph {Graf}
translate O Help {Hjelp}
translate O Hide {Gjemme}
translate O Import {Importer}
translate O Index {Innhold}
translate O LoadGame {Hent parti}
translate O BrowseGame {Bla gjennom parti}
translate O MergeGame {Smelt parti}
translate O MergeGames {Sl sammen spill}
translate O Preview {Forhndsvis}
translate O Revert {Gjr om}
translate O Save {Lagre}
translate O Search {Sk}
translate O Stop {Stopp}
translate O Store {Lagre}
translate O Update {Oppdater}
translate O ChangeOrient {Vend vindu}
translate O ShowIcons {Show Icons} ;# ***
translate O None {Ingen}
translate O First {Frste}
translate O Current {Gjeldende}
translate O Last {Siste}

# General messages:
translate O game {parti}
translate O games {partier}
translate O move {trekk}
translate O moves {trekk}
translate O all {alle}
translate O Yes {Ja}
translate O No {Nei}
translate O Both {Begge}
translate O King {Konge}
translate O Queen {Dronning}
translate O Rook {Trn}
translate O Bishop {Lper}
translate O Knight {Springer}
translate O Pawn {Bonde}
translate O White {Hvit}
translate O Black {Sort}
translate O Player {Spiller}
translate O Rating {Rating}
translate O RatingDiff {Ratingforskjell (Hvit - Sort)}
translate O AverageRating {Average Rating} ;# ***
translate O Event {Anledning}
translate O Site {Sted}
translate O Country {Land}
translate O IgnoreColors {Overse farger}
translate O Date {Dato}
translate O EventDate {Anledningsdato}
translate O Decade {Decade} ;# ***
translate O Year {r}
translate O Month {Mned}
translate O Months {Januar Februar Mars April Mai Juni Juli August September Oktober November Desember}
translate O Days {Sn Man Tir Ons Tor Fre Lr}
translate O YearToToday {r til i dag}
translate O YearToTodayTooltip {Sett dato fra 1 r tilbake til i dag}
translate O Result {Utfall}
translate O Round {Runde}
translate O Length {Lengde}
translate O ECOCode {ECO-kode}
translate O ECO {ECO}
translate O Deleted {Slettet}
translate O SearchResults {Sk i resultater}
translate O OpeningTheDatabase {pningsdatabase}
translate O Database {Database}
translate O Filter {Filter}
translate O noGames {ingen partier}
translate O allGames {alle partier}
translate O empty {tom}
translate O clipbase {utklippsbase}
translate O score {poeng}
translate O StartPos {Utgangsstilling}
translate O Total {Sammenlagt}
translate O readonly {skrivebeskyttet}

# Standard error messages:
translate O ErrNotOpen {This is not an open database.} ;# ***
translate O ErrReadOnly {This database is read-only; it cannot be altered.} ;# ***
translate O ErrSearchInterrupted {Search was interrupted; results are incomplete.} ;# ***
translate O ErrNoClockComments {Ingen [%clk] klokkekommentarer ble funnet i dette spillet.    Legg til klokketider via kommentarvinduet (Ctrl+E) for  bruke denne funksjonen.}
translate O ErrFileInUse {Feil: filen er allerede i bruk. Lukk alle andre programmer som bruker denne databasen. Hvis programmet ble avsluttet uventet, m du kanskje slette .lock-filen knyttet til databasen.}




# Game information:
translate O twin {duplikat}
translate O deleted {slettet}
translate O comment {kommentar}
translate O hidden {skjult}
translate O LastMove {Siste trekk}
translate O NextMove {Neste}
translate O GameStart {Begynnelse p parti}
translate O LineStart {Begynnelse p linje}
translate O GameEnd {Slutt p parti}
translate O LineEnd {Slutt p linje}

# Player information:
translate O PInfoAll {Resultater for <b>alle</b> partier}
translate O PInfoFilter {Resultater for partier i <b>filteret</b>}
translate O PInfoAgainst {Resultater mot}
translate O PInfoMostWhite {Hyppigste pning som hvit}
translate O PInfoMostBlack {Hyppigste pning som sort}
translate O PInfoRating {Historisk rating}
translate O PInfoBio {Biografi}
translate O PInfoEditRatings {Edit Ratings} ;# ***
translate O PInfoEloFile {Fil}

# Tablebase information:
translate O Draw {Uavgjort}
translate O with {med}
translate O only {kun}
translate O lose {taper} ;# tap?
translate O loses {taper}

# Tip of the day:
translate O Tip {Tips}
translate O TipAtStartup {Tips ved oppstart}
translate O TipConvertPGN {Du kan f bedre ytelse ved  konvertere PGN-filer}

# Tree window menus:
menuText O TreeFile "Fil" 0
menuText O TreeFileFillWithBase "Fyll cachen med base" 0 {Fyll cache-filen med alle spillene i gjeldende base}
menuText O TreeFileFillWithGame "Fyll cachen med spill" 0 {Fyll cache-filen med gjeldende spill i gjeldende base}
menuText O TreeFileSetCacheSize "Bufferstrrelse" 0 {Angi cache-strrelsen}
menuText O TreeFileCacheInfo "Bufferinformasjon" 0 {F informasjon om cachebruk}
menuText O TreeFileSave "Lagre hurtigbuffer" 0 {Lagrer hurtigbufferfilen (.stc)}
menuText O TreeFileFill "Fyll hurtigbuffer" 0 \
  {Fyller hurtigbufferet med de hyppigste pningsstillingene}
menuText O TreeFileBest "Idealparti" 0 {Show the best tree games list}
menuText O TreeFileGraph "Grafikk" 0 {Vis grafen for denne grenen av treet}
menuText O TreeFileCopy "Kopier treet til utklippstavlen" 0 \
  {Kopier statistikken for treet til utklippstavlen}
menuText O TreeFileClose "Lukk trevindu" 0 {Lukker trevinduet}
menuText O TreeMask "Maske" 0
menuText O TreeMaskNew "Ny" 0 {Ny maske}
menuText O TreeMaskOpen "pne" 0 {pen maske}
menuText O TreeMaskOpenRecent "pne nylig" 0 {pne nylig maske}
menuText O TreeMaskSave "Spare" 0 {Lagre maske}
menuText O TreeMaskClose "Lukke" 0 {Lukk maske}
menuText O TreeMaskFillWithGame "Fyll med spill" 0 {Fyll masken med vilt}
menuText O TreeMaskFillWithBase "Fyll med base" 0 {Fyll maske med alle spillene i basen}
menuText O TreeMaskInfo "Info" 0 {Vis statistikk for gjeldende maske}
menuText O TreeMaskDisplay "Vis maskekart" 0 {Vis maskedata i et treskjema}
menuText O TreeMaskSearch "Sk" 0 {Sk i gjeldende maske}
menuText O TreeSort "Sorter" 0
menuText O TreeSortAlpha "Alfabetisk" 0
menuText O TreeSortECO "ECO-kode" 0
menuText O TreeSortFreq "Hyppighet" 0
menuText O TreeSortScore "Poeng" 0
menuText O TreeOpt "Innstillinger" 0
menuText O TreeOptSlowmode "sakte modus" 0 {Sakte modus for oppdateringer (hy nyaktighet)}
menuText O TreeOptFastmode "Rask modus" 0 {Rask modus for oppdateringer (ingen flytting-transponering)}
menuText O TreeOptFastAndSlowmode "Rask og sakte modus" 0 {Rask modus og deretter sakte modus for oppdateringer}
menuText O TreeOptStartStop "Automatisk forfriskende" 0 {Slr p automatisk oppdatering av trevinduet}
menuText O TreeOptLock "Ls" 0 {Lser treet til nvrende database}
menuText O TreeOptTraining "Trening" 0 {Slr av/p treningsmodus}
menuText O TreeOptDepth "Flytte dybde" 0 {Antall halve trekk som skal vises i treet (1-4)}
menuText O TreeOptAutosave "Autolagre hurtigbuffer" 0 \
  {Autolagrer hurtigbufferet nr vinduet lukkes}
menuText O TreeHelp "Hjelp" 0
menuText O TreeHelpTree "Tre hjelp" 0
menuText O TreeHelpIndex "Innholdsfortegnelse" 0
translate O SaveCache {Lagre hurtigbuffer}
translate O Training {Trening}
translate O LockTree {Ls}
translate O TreeDepth {Tredybde (halve bevegelser):}
translate O TreeLocked {lst}
translate O TreeBest {Beste}
translate O TreeBestGames {Idealtrepartier}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate O TreeTitleRow \
{Move                          ECO       Frequency    Score  AvElo Perf AvYear %Draws     %Vinne} ;# ***
translate O TreeTotal {SAMMENLAGT}
translate O DoYouWantToSaveFirst {Vil du spare frst}
translate O AddToMask {Legg til maske}
translate O RemoveFromMask {Fjern fra masken}
translate O AddThisMoveToMask {Legg til dette trekket til Mask}
translate O SearchMask {Sk i Mask}
translate O DisplayMask {Vis maske}
translate O Nag {Nag kode}
translate O Marker {Markr}
translate O Include {Inkludere}
translate O Exclude {Utelukke}
translate O MainLine {Hovedlinje}
translate O Bookmark {Bokmerke}
translate O NewLine {Ny linje}
translate O ToBeVerified {Skal verifiseres}
translate O ToTrain { trene}
translate O Dubious {Tvilsomt}
translate O ToRemove {For  fjerne}
translate O NoMarker {Ingen markr}
translate O ColorMarker {Farge}
translate O WhiteMark {Hvit}
translate O GreenMark {Grnn}
translate O YellowMark {Gul}
translate O BlueMark {Bl}
translate O RedMark {Rd}
translate O CommentMove {Kommentar flytte}
translate O CommentPosition {Kommentarposisjon}
translate O AddMoveToMaskFirst {Legg frst trekk til masken}
translate O OpenAMaskFileFirst {pne en maskefil frst}
translate O Positions {Stillinger}
translate O Moves {Beveger seg}

# Finder window:
menuText O FinderFile "Fil" 0
menuText O FinderFileSubdirs "Let i underkataloger" 0
menuText O FinderFileClose "Lukk skevindu" 0
menuText O FinderSort "Sorter" 0
menuText O FinderSortType "Type" 0
menuText O FinderSortSize "Strrelse" 0
menuText O FinderSortMod "Endret" 0
menuText O FinderSortName "Navn" 0
menuText O FinderSortPath "Sti" 0
menuText O FinderTypes "Typer" 0
menuText O FinderTypesScid "Scid-databaser" 0
menuText O FinderTypesOld "Scid-databaser i gammelt format" 0
menuText O FinderTypesPGN "PGN-filer" 0
menuText O FinderTypesEPD "EPD-filer" 0
menuText O FinderTypesRep "Repertoire-filer" 0
menuText O FinderHelp "Hjelp" 0
menuText O FinderHelpFinder "Skehjelp" 0
menuText O FinderHelpIndex "Innholdsfortegnelse" 0
translate O FileFinder {Skeverkty}
translate O FinderDir {Katalog}
translate O FinderDirs {Kataloger}
translate O FinderFiles {Filer}
translate O FinderUpDir {opp}
translate O FinderCtxOpen {pne}
translate O FinderCtxBackup {Sikkerhetskopiering}
translate O FinderCtxCopy {Kopiere}
translate O FinderCtxMove {Flytte}
translate O FinderCtxDelete {Slett}

# Player finder:
menuText O PListFile "Fil" 0
menuText O PListFileUpdate "Oppdater" 0
menuText O PListFileClose "Close Player Finder" 0 ;# ***
menuText O PListSort "Sorter" 0
menuText O PListSortName "Name" 0 ;# ***
menuText O PListSortElo "Elo" 0
menuText O PListSortGames "Partier" 0
menuText O PListSortOldest "Oldest" 0 ;# ***
menuText O PListSortNewest "Newest" 0 ;# ***

# Tournament finder:
menuText O TmtFile "Fil" 0
menuText O TmtFileUpdate "Oppdater" 0
menuText O TmtFileClose "Lukk turneringssker" 0
menuText O TmtSort "Sorter" 0
menuText O TmtSortDate "Dato" 0
menuText O TmtSortPlayers "Players" 0
menuText O TmtSortGames "Partier" 0
menuText O TmtSortElo "Elo" 0
menuText O TmtSortSite "Sted" 0
menuText O TmtSortEvent "Anledning" 1
menuText O TmtSortWinner "Vinner" 0
translate O TmtLimit "Listegrense"
translate O TmtMeanElo "Laveste middel-ELO"
translate O TmtNone "Ingen passende turneringer funnet."

# Graph windows:
menuText O GraphFile "Fil" 0
menuText O GraphFileColor "Lagre som farget PostScript..." 0
menuText O GraphFileGrey "Lagre som grtonet PostScript..." 0
menuText O GraphFileClose "Lukk vindu" 0
menuText O GraphOptions "Innstillinger" 0
menuText O GraphOptionsWhite "Hvit" 0
menuText O GraphOptionsBlack "Sort" 0
menuText O GraphOptionsBoth "Begge" 0
menuText O GraphOptionsPInfo "Spiller Info spiller" 0
menuText O GraphOptionsEloFile "Elo fra vurderingsfil" 0
menuText O GraphOptionsEloDB "Elo fra databasen" 0
translate O GraphFilterTitle "Filtergraf: prosentandel av spill som nr posisjon"
translate O GraphAbsFilterTitle "Filter Graph: frekvens av spillene"
translate O ConfigureFilter {Konfigurer X-akser for r, vurdering og trekk}
translate O FilterEstimate "Beregne"
translate O TitleFilterGraph "Scid: Filter Graph"

# Analysis window:
translate O AddVariation {Legg til variasjon}
translate O AddAllVariations {Legg til alle varianter}
translate O AddMove {Legg til trekk}
translate O Annotate {Annoter}
translate O ShowAnalysisBoard {Vis analysetavle}
translate O ShowInfo {Vis motorinfo}
translate O FinishGame {Fullfr spillet}
translate O StopEngine {Stopp motoren}
translate O StartEngine {Start motoren}
translate O LockEngine {Ls motoren til gjeldende posisjon}
translate O AnalysisCommand {Analysekommando}
translate O PreviousChoices {Tidligere valg}
translate O AnnotateTime {Tid mellom trekk i sekunder}
translate O AnnotateWhich {Legg til variasjoner}
translate O AnnotateAll {For trekk av begge sider}
translate O AnnotateAllMoves {Merk alle trekk}
translate O AnnotateWhite {Kun for hvite trekk}
translate O AnnotateBlack {Kun for sorte trekk}
translate O AnnotateBlundersOnly {Nr game move er en penbar tabbe}
translate O AnnotateBlundersOnlyScoreChange {Analyse rapporterer feil, med poengsendringer fra/til:}
translate O BlundersThreshold {Terskel}
translate O ScoreAllMoves {Score all moves}
translate O LowPriority {Low CPU priority} ;# ***
translate O ClickHereToSeeMoves {Klikk her for  se trekk}
translate O ConfigureInformant {Informant}
translate O Informant!? {Interessant trekk}
translate O Informant? {Drlig trekk}
translate O Informant?? {Bommert}
translate O Informant?! {Tvilsomt trekk}
translate O Informant+= {Hvit har en liten fordel}
translate O Informant+/- {Hvit har en moderat fordel}
translate O Informant+- {Hvit har en avgjrende fordel}
translate O Informant+-- {Hvit har en knusende fordel}
translate O AutoComment {Automatisk kommentar}
translate O AutoCommentTooltip {Generer AI-kommentarer for gjeldende stilling}
translate O AnalysisAutoCommentTooltip {Generer AI-kommentarer for hele spillet}
translate O GameComment {Spillkommentar}
translate O GameCommentTooltip {Skann spillet for kommenterte trekk og generer AI-sammendrag}
translate O TimeMs {Tid (ms)}


# Book window
translate O Book {Bok}
translate O OtherBookMoves {Motstanderens bok}
translate O OtherBookMovesTooltip {Trekk som motstanderen har et svar p}

# Analysis Engine open dialog:
translate O EngineList {Liste over analysemotorer}
translate O EngineName {Navn}
translate O EngineCmd {Kommandolinje}
translate O EngineArgs {Parametre}
translate O EngineDir {Katalog}
translate O EngineElo {Elo}
translate O EngineTime {Dato}
translate O EngineNew {Ny}
translate O EngineEdit {Rediger}
translate O EngineRequired {Fete felter er ndvendige, de vrige er valgfrie}
translate O EngineProtocol {Kommunikasjonsprotokoll}
translate O EngineNotation {Notasjon av trekkene}
translate O EngineFlipEvaluation {Flip evalueringsperspektiv}
translate O EngineShowLog {Vis kommunikasjonslogg}
translate O EngineNetworkd {Godta eksterne tilkoblinger}
translate O EngineSelect {Velg gjeldende motor}
translate O EngineAddLocal {Legg til en lokal motor}
translate O EngineAddRemote {Legg til en ekstern motor}
translate O EngineReload {Last inn gjeldende motor p nytt}
translate O EngineClone {Lag en kopi av gjeldende motor}
translate O EngineDelete {Slett gjeldende motor}

# PGN window menus:
menuText O PgnFile "Fil" 0
menuText O PgnFileCopy "Copy Game to Clipboard" 0 ;# ***
menuText O PgnFilePrint "Skriv til fil..." 0
menuText O PgnFileClose "Lukk PGN-vindu" 0
menuText O PgnOpt "Vis" 0
menuText O PgnOptColor "Vis farger" 0
menuText O PgnOptShort "Kort (3 linjer) header" 0
menuText O PgnOptSymbols "Symbolnotasjon" 0
menuText O PgnOptIndentC "Rykk inn kommentarer" 0
menuText O PgnOptIndentV "Rykk inn variasjoner" 0
menuText O PgnOptColumn "Bruk kolonner (ett trekk per linje)" 0
menuText O PgnOptSpace "Mellomrom etter trekknummer" 0
menuText O PgnOptStripMarks "Fjern fargekoder" 0
menuText O PgnOptBoldMainLine "Use Bold Text for Main Line Moves" 4 ;# ***
menuText O PgnColor "Farger" 0
menuText O PgnColorHeader "Header..." 0
menuText O PgnColorAnno "Annotasjoner..." 0
menuText O PgnColorComments "Kommentarer..." 0
menuText O PgnColorVars "Variasjoner..." 0
menuText O PgnColorBackground "Bakgrunn..." 0
menuText O PgnColorMain "Hovedlinje..." 0
menuText O PgnColorCurrent "Gjeldende flyttbakgrunn..." 1
menuText O PgnHelp "Hjelp" 0
menuText O PgnHelpPgn "PGN-hjelp" 0
menuText O PgnHelpIndex "Innholdsfortegnelse" 0
translate O PgnWindowTitle {Game Notation - game %u} ;# ***

# Crosstable window menus:
menuText O CrosstabFile "Fil" 0
menuText O CrosstabFileText "Skriv til tekstfil..." 0
menuText O CrosstabFileHtml "Skriv til HTML-fil..." 0
menuText O CrosstabFileClose "Lukk krysstabellvindu" 0
menuText O CrosstabEdit "Rediger" 0
menuText O CrosstabEditEvent "Anledning" 0
menuText O CrosstabEditSite "Sted" 0
menuText O CrosstabEditDate "Dato" 0
menuText O CrosstabOpt "Vis" 0
menuText O CrosstabOptAll "Alle-mot-alle" 0
menuText O CrosstabOptSwiss "Sveitsisk" 0
menuText O CrosstabOptKnockout "Kun vinnere" 0
menuText O CrosstabOptAuto "Auto" 0
menuText O CrosstabOptAges "Aldre i r" 0
menuText O CrosstabOptNats "Nasjonaliteter" 0
menuText O CrosstabOptRatings "Ratinger" 0
menuText O CrosstabOptTitles "Titler" 0
menuText O CrosstabOptBreaks "Poengfordel" 0
menuText O CrosstabOptDeleted "Include deleted games" 8 ;# ***
menuText O CrosstabOptColors "Farger (kun sveitsisk)" 0
menuText O CrosstabOptColumnNumbers "Nummererte kolonner (kun alle-mot-alle-tabeller)" 0
menuText O CrosstabOptGroup "Gruppepoeng" 0
menuText O CrosstabSort "Sorter" 0
menuText O CrosstabSortName "Navn" 0
menuText O CrosstabSortRating "Rating" 0
menuText O CrosstabSortScore "Poeng" 0
menuText O CrosstabColor "Farge" 0
menuText O CrosstabColorPlain "Ren tekst" 0
menuText O CrosstabColorHyper "Hypertekst" 0
menuText O CrosstabHelp "Hjelp" 0
menuText O CrosstabHelpCross "Krysstabell hjelp" 0
menuText O CrosstabHelpIndex "Innholdsfortegnelse" 0
translate O SetFilter {Sett filter}
translate O AddToFilter {Legg til i filter}
translate O Swiss {Sveitsisk}
translate O Category {Category} ;# ***

# Opening report window menus:
menuText O OprepFile "Fil" 0
menuText O OprepFileText "Skriv til tekstfil..." 0
menuText O OprepFileHtml "Skriv til HTML-fil..." 0
menuText O OprepFileOptions "Innstillinger..." 0
menuText O OprepFileClose "Lukk rapport-vindu" 0
menuText O OprepFavorites "Favorites" 1 ;# ***
menuText O OprepFavoritesAdd "Add Report..." 0 ;# ***
menuText O OprepFavoritesEdit "Edit Report Favorites..." 0 ;# ***
menuText O OprepFavoritesGenerate "Generate Reports..." 0 ;# ***
menuText O OprepHelp "Hjelp" 0
menuText O OprepHelpReport "pningsrapport hjelp" 0
menuText O OprepHelpIndex "Innholdsfortegnelse" 0

# Header search:
translate O HeaderSearch {Headersk}
translate O EndSideToMove {Side to move at end of game} ;# ***
translate O GamesWithNoECO {Partier uten ECO?}
translate O GameLength {Partilengde}
translate O FindGamesWith {Finn partier merket med...}
translate O StdStart {Vanlig utgangsstilling}
translate O Promotions {Forfremmelser}
translate O Comments {Kommentarer}
translate O Variations {Variasjoner}
translate O Annotations {Annotasjoner}
translate O DeleteFlag {Slettet}
translate O WhiteOpFlag {Hvit pning}
translate O BlackOpFlag {Sort pning}
translate O MiddlegameFlag {Midtspill}
translate O EndgameFlag {Sluttspill}
translate O NoveltyFlag {Avvik}
translate O PawnFlag {Bondestruktur}
translate O TacticsFlag {Taktikk}
translate O QsideFlag {Spill p dronningsiden}
translate O KsideFlag {Spill p kongesiden}
translate O BrilliancyFlag {Brillians}
translate O BlunderFlag {Tabbe}
translate O UserFlag {Bruker}
translate O PgnContains {PGN inneholder tekst}
translate O PgnTag {Tag}
translate O TagContains {inneholder}
translate O Variant {Variant}
translate O Annotator {Annotator}
translate O Cmnts {Kun kommenterte spill}

# Game list window:
translate O GlistNumber {Nummer}
translate O GlistWhite {Hvit}
translate O GlistBlack {Sort}
translate O GlistWElo {H-Elo}
translate O GlistBElo {S-Elo}
translate O GlistEvent {Anledning}
translate O GlistSite {Sted}
translate O GlistRound {Runde}
translate O GlistDate {Dato}
translate O GlistYear {r}
translate O GlistEDate {AnledningDato}
translate O GlistResult {Resultat}
translate O GlistLength {Lengde}
translate O GlistCountry {Land}
translate O GlistECO {ECO}
translate O GlistOpening {pning}
translate O GlistEndMaterial {Slutt-kvalitet}
translate O GlistDeleted {Slettet}
translate O GlistFlags {Flagg}
translate O GlistVars {Variasjoner}
translate O GlistComments {Kommentarer}
translate O GlistAnnos {Annotasjoner}
translate O GlistStart {Start}
translate O GlistGameNumber {Parti nummer}
translate O GlistAverageElo {Gjennomsnittlig Elo}
translate O GlistRating {Vurdering}
translate O GlistFindText {Finn tekst}
translate O GlistMoveField {Trekk}
translate O GlistEditField {Still inn}
translate O GlistAddField {Legg til}
translate O GlistDeleteField {Fjern}
translate O GlistWidth {Bredde}
translate O GlistAlign {Justering}
translate O GlistAlignL {Juster: venstre}
translate O GlistAlignR {Juster: hyre}
translate O GlistAlignC {Juster: senter}
translate O GlistColor {Farge}
translate O GlistSep {Skilletegn}
translate O GlistCurrentSep {-- Nvrende --}
translate O GlistNewSort {Ny}
translate O GlistAddToSort {Legge til}

# base sorting
translate O GsortSort {Sortere...}
translate O GsortDate {Dato}
translate O GsortYear {r}
translate O GsortEvent {Hendelse}
translate O GsortSite {nettsted}
translate O GsortRound {Rund}
translate O GsortWhiteName {Hvitt navn}
translate O GsortBlackName {Svart navn}
translate O GsortECO {KO}
translate O GsortResult {Resultat}
translate O GsortMoveCount {Flytt Count}
translate O GsortAverageElo {Gjennomsnittlig Elo}
translate O GsortCountry {Land}
translate O GsortDeleted {Slettet}
translate O GsortEventDate {Hendelsesdato}
translate O GsortWhiteElo {Hvit Elo}
translate O GsortBlackElo {Svart Elo}
translate O GsortComments {Kommentarer}
translate O GsortVariations {Variasjoner}
translate O GsortNAGs {NAGs}
translate O GsortAscending {Stigende}
translate O GsortDescending {Synkende}
translate O GsortAdd {Legge til}
translate O GsortStore {Lager}
translate O GsortLoad {Laste}

# menu shown with right mouse button down on game list.
translate O GlistRemoveThisGameFromFilter  {Fjern dette spillet fra Filter}
translate O GlistRemoveGameAndAboveFromFilter  {Fjern spillet (og alt over det) fra Filter}
translate O GlistRemoveGameAndBelowFromFilter  {Fjern spillet (og alt under det) fra Filter}
translate O GlistDeleteGame {(Av) Slett dette spillet} 
translate O GlistDeleteAllGames {Slett alle spill i filteret} 
translate O GlistUndeleteAllGames {Angre sletting av alle spill i filteret} 
translate O GlistMergeGameInBase {Sl sammen spillet i en annen base} 

# Maintenance window:
translate O DatabaseName {Databasenavn:}
translate O TypeIcon {Ikon:}
translate O NumOfGames {Partier:}
translate O NumDeletedGames {Slettede partier:}
translate O NumFilterGames {Partier i filter:}
translate O YearRange {Til/fra r:}
translate O RatingRange {Til/fra rating:}
translate O Description {Description} ;# ***
translate O Flag {Flagg}
translate O CustomFlags {Egendefinerte flagg}
translate O DeleteCurrent {Slett gjeldende parti}
translate O DeleteFilter {Slett filtrerte partier}
translate O DeleteAll {Slett alle partier}
translate O UndeleteCurrent {Gjenopprett gjeldende parti}
translate O UndeleteFilter {Gjenopprett filtrerte partier}
translate O UndeleteAll {Gjenopprett alle partier}
translate O DeleteTwins {Slett duplikatpartier}
translate O MarkCurrent {Merk gjeldende parti}
translate O MarkFilter {Merk filtrerte partier}
translate O MarkAll {Merk alle partier}
translate O UnmarkCurrent {Fjern merking p gjeldende parti}
translate O UnmarkFilter {Fjern merking p filtrerte partier}
translate O UnmarkAll {Fjern merking p alle partier}
translate O Spellchecking {Stavekontroll}
translate O Players {Spillere}
translate O Events {Anledninger}
translate O Sites {Steder}
translate O Rounds {Runder}
translate O DatabaseOps {Databasebehandling}
translate O ReclassifyGames {ECO-klassifiser partier}
translate O CompactDatabase {Komprimer database}
translate O SortDatabase {Sorter database}
translate O AddEloRatings {Legg til ELO-ratinger}
translate O AutoloadGame {Start med parti nummer}
translate O StripTags {Fjern PGN-merker}
translate O StripTag {Fjern merke}
translate O Cleaner {Opprydding}
translate O CleanerHelp {
Scid-opprydding vil utfre alle handlinger du velger fra listen under p gjeldende database.

Gjeldende innstillinger i ECO-klassifiseringen og duplikatslettingdialogene vil virke inn om du velger disse funksjonene.
}
translate O CleanerConfirm {
Nr oppryddingen er i gang kan den ikke avbrytes!

Dette kan ta lang tid p en stor databse, avhengig av funksjonene du har valgt og disses gjeldende innstillinger.

Er du sikker p at du vil starte vedlikeholdsfunksjonene du har valgt?
}
# Twinchecker
translate O TwinCheckUndelete { snu; "u" angre sletting av begge)}
translate O TwinCheckprevPair {Forrige par}
translate O TwinChecknextPair {Neste par}
translate O TwinChecker {Scid: Tvillingspillsjekker}
translate O TwinCheckTournament {Spill i turneringen:}
translate O TwinCheckNoTwin {Ingen tvilling}
translate O TwinCheckNoTwinfound {Ingen tvilling ble oppdaget for dette spillet.\nIkke vis tvillinger med dette vinduet, du m frst bruke funksjonen "Slett tvillingspill...".}
translate O TwinCheckTag {Del tagger...}
translate O TwinCheckFound1 {Scid fant $result tvillingspill}
translate O TwinCheckFound2 {og sett sletteflaggene deres}
translate O TwinCheckNoDelete {Det er ingen spill i denne databasen  slette.}
translate O TwinCriteria1 {Innstillingene dine for  finne tvillingspill vil sannsynligvis fre til at ikke-tvillingspill med lignende trekk blir merket som tvillinger.}
translate O TwinCriteria2 {Det anbefales at hvis du velger "Nei" for "samme trekk", br du velge "Ja" for innstillingene for farger, hendelse, side, runde, r og mned.\nVil du fortsette og slette tvillinger likevel?}
translate O TwinCriteria3 {Det anbefales at du spesifiserer "Ja" for minst to av innstillingene "samme side", "samme runde" og "samme r".\nVil du fortsette og slette tvillinger likevel?}
translate O TwinCriteriaConfirm {Scid: Bekreft tvillinginnstillinger}
translate O TwinChangeTag "Endre flgende spillkoder:\n\n"
translate O AllocRatingDescription "Denne kommandoen vil bruke gjeldende stavekontrollfil for  legge til Elo-vurderinger til spill i denne databasen. Uansett hvor en spiller ikke har noen nvrende vurdering, men hans/hennes vurdering p tidspunktet for spillet er oppfrt i stavekontrollfilen, vil denne vurderingen bli lagt til."
translate O RatingOverride "Vil du overskrive eksisterende vurderinger som ikke er null?"
translate O AddRatings "Legg til vurderinger til:"
translate O AddedRatings {Scid la til $r Elo-rangeringer i $g-spill.}

#Bookmark editor
translate O NewSubmenu "Ny undermeny"

# Comment editor:
translate O AnnotationSymbols  {Notasjonssymboler:}
translate O Comment {Kommentar:}
translate O InsertMark {Insert mark} ;# ***
translate O InsertMarkHelp {
Insert/remove mark: Select color, type, square.
Insert/remove arrow: Right-click two squares.
} ;# ***

# Nag buttons in comment editor:
translate O GoodMove {Good move} ;# ***
translate O PoorMove {Poor move} ;# ***
translate O ExcellentMove {Excellent move} ;# ***
translate O Blunder {Tabbe}
translate O InterestingMove {Interesting move} ;# ***
translate O DubiousMove {Dubious move} ;# ***
translate O WhiteDecisiveAdvantage {White has a decisive advantage} ;# ***
translate O BlackDecisiveAdvantage {Black has a decisive advantage} ;# ***
translate O WhiteClearAdvantage {White has a clear advantage} ;# ***
translate O BlackClearAdvantage {Black has a clear advantage} ;# ***
translate O WhiteSlightAdvantage {White has a slight advantage} ;# ***
translate O BlackSlightAdvantage {Black has a slight advantage} ;# ***
translate O WhiteCrushing {Hvit har en knusende fordel}
translate O BlackCrushing {Svart har en knusende fordel}
translate O Equality {Equality} ;# ***
translate O Unclear {Unclear} ;# ***
translate O Diagram {Diagram} ;# ***

# Board search:
translate O BoardSearch {Stillingsk}
translate O FilterOperation {Operasjoner p gjeldende filter:}
translate O FilterAnd {AND (Kun p filter)}
translate O FilterOr {OR (Legg til filter)}
translate O FilterIgnore {IGNORE (Nullstill filter)}
translate O SearchType {Sketype:}
translate O SearchBoardExact {Nyaktig stilling (alle brikker p samme felt)}
translate O SearchBoardPawns {Bnder (samme kvalitet, alle bnder p samme felt)}
translate O SearchBoardFiles {Kolonner (samme kvalitet, alle bnder p samme kolonner)}
translate O SearchBoardAny {Alle (samme kvalitet, bnder og brikker hvor som helst)}
translate O SearchInRefDatabase {Sk i basen}
translate O LookInVars {Sk i variasjoner}

# Material search:
translate O MaterialSearch {Kvalitetssk}
translate O Material {Kvalitet}
translate O Patterns {Mnstre}
translate O Zero {Null}
translate O Any {Hvilke som helst}
translate O CurrentBoard {Gjeldende stilling}
translate O CommonEndings {Vanlige sluttspill}
translate O CommonPatterns {Vanlige mnstre}
translate O MaterialDiff {Kvalitetsforskjell}
translate O squares {felt}
translate O SameColor {Samme farge}
translate O OppColor {Motsatt farge}
translate O Either {Begge}
translate O MoveNumberRange {Fra/til trekk nummer}
translate O MatchForAtLeast {Treff i minst}
translate O HalfMoves {halvtrekk}

# Common endings in material search:
translate O EndingPawns {Pawn endings} ;# ***
translate O EndingRookVsPawns {Rook vs. Pawn(s)} ;# ***
translate O EndingRookPawnVsRook {Rook and 1 Pawn vs. Rook} ;# ***
translate O EndingRookPawnsVsRook {Rook and Pawn(s) vs. Rook} ;# ***
translate O EndingRooks {Rook vs. Rook endings} ;# ***
translate O EndingRooksPassedA {Rook vs. Rook endings with a passed a-pawn} ;# ***
translate O EndingRooksDouble {Double Rook endings} ;# ***
translate O EndingBishops {Bishop vs. Bishop endings} ;# ***
translate O EndingBishopVsKnight {Bishop vs. Knight endings} ;# ***
translate O EndingKnights {Knight vs. Knight endings} ;# ***
translate O EndingQueens {Queen vs. Queen endings} ;# ***
translate O EndingQueenPawnVsQueen {Queen and 1 Pawn vs. Queen} ;# ***
translate O BishopPairVsKnightPair {Two Bishops vs. Two Knights middlegame} ;# ***

# Common patterns in material search:
translate O PatternWhiteIQP {White IQP} ;# ***
translate O PatternWhiteIQPBreakE6 {White IQP: d4-d5 break vs. e6} ;# ***
translate O PatternWhiteIQPBreakC6 {White IQP: d4-d5 break vs. c6} ;# ***
translate O PatternBlackIQP {Black IQP} ;# ***
translate O PatternWhiteBlackIQP {White IQP vs. Black IQP} ;# ***
translate O PatternCoupleC3D4 {White c3+d4 Isolated Pawn Couple} ;# ***
translate O PatternHangingC5D5 {Black Hanging Pawns on c5 and d5} ;# ***
translate O PatternMaroczy {Maroczy Center (with Pawns on c4 and e4)} ;# ***
translate O PatternRookSacC3 {Rook Sacrifice on c3} ;# ***
translate O PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)} ;# ***
translate O PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)} ;# ***
translate O PatternLightFian {Light-Square Fianchettos (Bishop-g2 vs. Bishop-b7)} ;# ***
translate O PatternDarkFian {Dark-Square Fianchettos (Bishop-b2 vs. Bishop-g7)} ;# ***
translate O PatternFourFian {Four Fianchettos (Bishops on b2,g2,b7,g7)} ;# ***

# Game saving:
translate O Today {I dag}
translate O ClassifyGame {Klassifiser parti}

# Setup position:
translate O EmptyBoard {Tm brett}
translate O InitialBoard {Utgangsstilling}
translate O SideToMove {Side i trekk}
translate O MoveNumber {Trekk nummer}
translate O Castling {Rokkade}
translate O EnPassantFile {En Passant-kolonne}
translate O ClearFen {Slett FEN}
translate O PasteFen {Lim inn FEN}

translate O SaveAndContinue {Lagre og fortsett}
translate O DiscardChangesAndContinue {Forkast endringer\og fortsett}
translate O GoBack {G tilbake}

# Replace move dialog:
translate O ReplaceMove {Erstatt trekk}
translate O AddNewVar {Legg til ny variasjon}
translate O NewMainLine {Ny hovedlinje}
translate O ReplaceMoveMessage {Et trekk eksisterer allerede her.

Du kan erstatte det og slette alle flgende trekk, eller du kan legge det til som en variasjon.

(Du kan unng denne meldingen i fremtiden ved  sl av Spr fr trekk erstattes-innstillingen i Innstillinger:Trekk-menyen.)}

# Make database read-only dialog:
translate O ReadOnlyDialog {Hvis du skrivebeskytter denne databasen tillates ikke lenger endringer p den. Ingen partier kan lagres eller erstattes, og ingen sletteflagg kan endres. All sortering eller ECO-klassifisering vil vre midlertidig.

Du kan enkelt sl av skrivebeskyttelsen p databasen ved  lukke og gjenpne den.

Vil du virkelig skrivebeskytte denne databasen?}

# Clear game dialog:
translate O ClearGameDialog {Dette partiet har blitt endret.

Vil du virkelig forkaste endringene som er gjort?
}

# Exit dialog:
translate O ExitDialog {Vil du virkelig avslutte Scid?}
translate O ExitUnsaved {Flgende baser har ulagrede endringer i partier. Hvis du avslutter n vil disse endringene g tapt.}

# Import window:
translate O PasteCurrentGame {Lim inn gjeldende parti}
translate O ImportHelp1 {Skriv eller lim inn et PGN-parti i feltet over.}
translate O ImportHelp2 {Feil i importen vil vises her.}
translate O OverwriteExistingMoves {Overskrive eksisterende trekk?}

# ECO Browser:
translate O ECOAllSections {alle ECO-deler}
translate O ECOSection {ECO-del}
translate O ECOSummary {Sammendrag for}
translate O ECOFrequency {Hyppighet eller underkoder for}

# Opening Report:
translate O OprepReportFor {Rapporter for}
translate O OprepTitle {pningsrapport}
translate O OprepReport {Rapport}
translate O OprepGenerated {Generert av}
translate O OprepStatsHist {Statistikk og historie}
translate O OprepStats {Statistikk}
translate O OprepStatAll {Alle rapporterte partier}
translate O OprepStatBoth {Begge med rating}
translate O OprepStatSince {Siden}
translate O OprepOldest {Eldste partier}
translate O OprepNewest {Nyeste partier}
translate O OprepPopular {Trend}
translate O OprepFreqAll {Frekvens i r:   }
translate O OprepFreq1   {Det siste ret: }
translate O OprepFreq5   {De siste 5 rene: }
translate O OprepFreq10  {De siste 10 rene: }
translate O OprepEvery {hvert %u parti}
translate O OprepUp {opp %u%s fra alle r}
translate O OprepDown {ned %u%s fra alle r}
translate O OprepSame {ingen endring fra alle r}
translate O OprepMostFrequent {Hyppigste spillere}
translate O OprepMostFrequentOpponents {Most frequent opponents} ;# ***
translate O OprepRatingsPerf {Ratinger og resultater}
translate O OprepAvgPerf {Middelratinger og -resultater}
translate O OprepWRating {Hvit rating}
translate O OprepBRating {Sort rating}
translate O OprepWPerf {Hvite resultater}
translate O OprepBPerf {Sorte resultater}
translate O OprepHighRating {Parti med hyeste gjennomsnittsrating}
translate O OprepTrends {Resultattrend}
translate O OprepResults {Resultatlengde og -hyppighet}
translate O OprepLength {Partilengde}
translate O OprepFrequency {Hyppighet}
translate O OprepWWins {Hvit vinner: }
translate O OprepBWins {Sort vinner: }
translate O OprepDraws {Uavgjort:      }
translate O OprepWholeDB {hele databasen}
translate O OprepShortest {Korteste seire}
translate O OprepMovesThemes {Trekk og temaer}
translate O OprepMoveOrders {Trekkrekkeflger til rapportert stilling}
translate O OprepMoveOrdersOne \
  {Det var kun en trekkrekkeflge som frte til denne stillingen:}
translate O OprepMoveOrdersAll \
  {Det var %u trekkrekkeflger som frte til denne stillingen:}
translate O OprepMoveOrdersMany \
  {There were %u move orders reaching this position. The top %u are:}
translate O OprepMovesFrom {Trekk fra rapportert stilling}
translate O OprepMostFrequentEcoCodes {Most frequent ECO codes} ;# ***
translate O OprepThemes {Stillingstemaer}
translate O OprepThemeDescription {Frequency of themes in the first %u moves of each game} ;# ***
translate O OprepThemeSameCastling {Rokkade til samme side}
translate O OprepThemeOppCastling {Rokkade til motsatt side}
translate O OprepThemeNoCastling {Ingen konger rokert}
translate O OprepThemeKPawnStorm {Bondestorm p kongesiden}
translate O OprepThemeQueenswap {Byttede dronninger}
translate O OprepThemeWIQP {White Isolated Queen Pawn} ;# ***
translate O OprepThemeBIQP {Black Isolated Queen Pawn} ;# ***
translate O OprepThemeWP567 {Hvit bonde p rekke 5/6/7}
translate O OprepThemeBP234 {Sort bonde p rekke 2/3/4}
translate O OprepThemeOpenCDE {pen c/d/e-kolonne}
translate O OprepTheme1BishopPair {Kun en side har to lpere}
translate O OprepEndgames {Sluttspill}
translate O OprepReportGames {Rapporterte partier}
translate O OprepAllGames    {Alle partier}
translate O OprepEndClass {Materiale i sluttspillet}
translate O OprepTheoryTable {Teoritabell}
translate O OprepTableComment {Generert fra de %u hyest ratede partiene.}
translate O OprepExtraMoves {Ytterligere trekk notert i teoritabellen}
translate O OprepMaxGames {Maksimalt antall partier i teoritabellen}
translate O OprepMergeMoves {Flyttegrense for sammensltte spill}
translate O OprepMergeUnique {Sl bare sammen unike spill}
translate O OprepViewHTML {View HTML} ;# ***

# Player Report:
translate O PReportTitle {Player Report} ;# ***
translate O PReportColorWhite {with the White pieces} ;# ***
translate O PReportColorBlack {with the Black pieces} ;# ***
translate O PReportMoves {after %s} ;# ***
translate O PReportOpenings {Openings} ;# ***
translate O PReportClipbase {Empty clipbase and copy matching games to it} ;# ***

# Piece Tracker window:
translate O TrackerSelectSingle {Venstre museknapp merker denne brikken}
translate O TrackerSelectPair {Venstre museknapp merker denne brikken; hyre merker alle brikker av denne typen.}
translate O TrackerSelectPawn {Venstre museknapp merker denne brikken; hyre merker alle brikker av denne typen.}
translate O TrackerStat {Statistikk}
translate O TrackerGames {% partier med trekk til felt}
translate O TrackerTime {% tid p hvert felt}
translate O TrackerMoves {Trekk}
translate O TrackerMovesStart {Oppgi trekket hvor sporingen skal begynne.}
translate O TrackerMovesStop {Oppgi trekket hvor sporingen skal stoppe.}

# Game selection dialogs:
translate O SelectAllGames {Alle partier i databasen}
translate O SelectFilterGames {Kun partier i filteret}
translate O SelectTournamentGames {Kun partier i gjeldende turnering}
translate O SelectOlderGames {Kun eldre partier}

# Delete Twins window:
translate O TwinsNote {For  vre duplikater m to partier minst ha de samme to spillerene, og kriterier du kan angi under. Nr to duplikater finnes blir det korteste partiet slettet. Tips: Det er best  kjre en stavekontroll fr duplikatsjekken, da det forbedrer sket.}
translate O TwinsCriteria {Kriterier: Duplikater m ha...}
translate O TwinsWhich {Undersk hvilke partier}
translate O TwinsColors {Spillere samme farge?}
translate O TwinsEvent {Samme anledning?}
translate O TwinsSite {Samme sted?}
translate O TwinsRound {Samme runde?}
translate O TwinsYear {Samme r?}
translate O TwinsMonth {Samme mned?}
translate O TwinsDay {Samme dag?}
translate O TwinsResult {Samme utfall?}
translate O TwinsECO {Samme ECO-kode?}
translate O TwinsMoves {Samme trekk?}
translate O TwinsPlayers {Sammenlign spillernavn:}
translate O TwinsPlayersExact {Nyaktig like}
translate O TwinsPlayersPrefix {Kun frste 4 bokstaver}
translate O TwinsWhen {Nr duplikatpartier slettes}
translate O TwinsSkipShort {Overse alle partier kortere enn 5 trekk?}
translate O TwinsUndelete {Gjenopprett alle partier frst?}
translate O TwinsSetFilter {Sett filter til alle slettede duplikatpartier?}
translate O TwinsComments {Behold alltid partier med kommentarer?}
translate O TwinsVars {Behold alltid partier med variasjoner?}
translate O TwinsDeleteWhich {Slett hvilket parti:}
translate O TwinsDeleteShorter {Korteste parti}
translate O TwinsDeleteOlder {Laveste partinummer}
translate O TwinsDeleteNewer {Hyeste partinummer}
translate O TwinsDelete {Slett partier}

# Name editor window:
translate O NameEditType {Navnetype som skal redigeres}
translate O NameEditSelect {Partier som skal redigeres}
translate O NameEditReplace {Erstatt}
translate O NameEditWith {med}
translate O NameEditMatches {Treff: Trykk Ctrl+1 til Ctrl+9 for  velge}

# Check games window:
translate O CheckGames {Sjekk spill}
translate O CheckGamesWhich {Sjekk spill}
translate O CheckAll {Alle spill}
translate O CheckSelectFilterGames {Bare spill i filter}

# Classify window:
translate O Classify {Klassifiser}
translate O ClassifyWhich {ECO-klassifiser hvilke partier}
translate O ClassifyAll {Alle partier (overskriv gamle ECO-koder)}
translate O ClassifyYear {Aller partier det siste ret}
translate O ClassifyMonth {Alle partier den siste mneden}
translate O ClassifyNew {Kun partier uten ECO-kode}
translate O ClassifyCodes {ECO-koder som skal brukes}
translate O ClassifyBasic {Kun standardkoder ("B12", ...)}
translate O ClassifyExtended {Scid-utvidet ("B12j", ...)}
translate O ClassifyResult {ECO-klassifisering fullfrt: $resultatspill(er) oppdatert.}

# Compaction:
translate O NameFile {Navnefil}
translate O GameFile {Partifil}
translate O Names {Navn}
translate O Unused {Ubrukte}
translate O SizeKb {Strrelse (kb)}
translate O CurrentState {Nvrende}
translate O AfterCompaction {Etter komprimering}
translate O CompactNames {Komrimer navnefil}
translate O CompactGames {Komprimer partifil}
translate O NoUnusedNames "Det er ingen ubrukte navn, s navnefilen er allerede fullstendig komprimert."
translate O NoUnusedGames "Spillfilen er allerede fullstendig komprimert."
translate O GameFileCompacted {Spillfilen for databasen ble komprimert.}

# Sorting:
translate O SortCriteria {Kriterier}
translate O AddCriteria {Legg til kriterie}
translate O CommonSorts {Vanlige sorteringer}
translate O Sort {Sorter}

# Exporting:
translate O AddToExistingFile {Legg partier til en eksisterende fil}
translate O ExportComments {Eksporter kommentarer}
translate O ExportVariations {Eksporter variasjoner}
translate O IndentComments {Rykk inn kommentarer}
translate O IndentVariations {Rykk inn variasjoner}
translate O ExportColumnStyle {Bruk kolonner (ett trekk per linje)}
translate O ExportSymbolStyle {Symbolnotasjoner}
translate O ExportStripMarks {Fjern alle fargekoder og piler fra kommentarer?}

# Goto game/move dialogs:
translate O LoadGameNumber {Angi partinummer som skal lastes inn:}
translate O GotoMoveNumber {G til trekk nummer:}

# Copy games dialog:
translate O CopyAllGames {Kopier alle spill til}
translate O CopyGames {Kopier partier}
translate O CopyConfirm {
Vil du virkelig kopiere de [::utils::thousands $nGamesToCopy] filtrerte partiene fra "$fromName"
 til databasen "$targetName"?
}
translate O CopyErr {Kan ikke kopiere partiene}
translate O CopyErrSource {kildedatabasen}
translate O CopyErrTarget {mldatabasen}
translate O CopyErrNoGames {har ingen partier i sitt filter}
translate O CopyErrReadOnly {er skrivebeskyttet}
translate O CopyErrNotOpen {er ikke pnet}

# Colors:
translate O LightSquares {Lyse felt}
translate O DarkSquares {Mrke felt}
translate O SelectedSquares {Merkede felt}
translate O SuggestedSquares {Foresltte trekkfelt}
translate O WhitePieces {Hvite brikker}
translate O BlackPieces {Sorte brikker}
translate O WhiteBorder {Hvit ramme}
translate O BlackBorder {Sort ramme}

# Novelty window:
translate O FindNovelty {Finn avvik}
translate O Novelty {Avvik}
translate O NoveltyInterrupt {Avvikssk avbrutt}
translate O NoveltyNone {Ingen avvik ble funnet i dette partiet}
translate O NoveltyHelp {
Scid vil finne det frste trekket i det gjeldende partiet som frer til en stilling som ikke finnes i den valgte databasen eller i ECO-pningsboken.}

# Sounds configuration:
translate O SoundsFolder {Sound Files Folder} ;# ***
translate O SoundsFolderHelp {The folder should contain the files King.wav, a.wav, 1.wav, etc} ;# ***
translate O SoundsAnnounceOptions {Move Announcement Options} ;# ***
translate O SoundsAnnounceNew {Announce new moves as they are made} ;# ***
translate O SoundsMoveSoundOnly {Bare flytt lyd (deaktiver kunngjringer)}
translate O SoundsAnnounceForward {Announce moves when moving forward one move} ;# ***
translate O SoundsAnnounceBack {Announce when retracting or moving back one move} ;# ***
translate O SoundsSoundDisabled {Scid kunne ikke finne Snack-lydpakken ved oppstart;\nLyden er deaktivert.}

# Upgrading databases:
translate O Upgrading {Oppgraderer}
translate O ConfirmOpenNew {
Dette er en database i gammelt format (Scid 3) som ikke kan pnes i Scid 4, men en ny versjon (Scid 4) har allerede blitt opprettet.

Vil du pne versjonen som er i det nye formatet?
}
translate O ConfirmUpgrade {
Dette er en database i gammelt format (Scid3). En versjon i nytt format m opprettes fr den kan brukes i Scid 4.

Oppgradering vil opprette en ny versjon av databasen.

Dette kan ta en stund, men det trenger kun  gjres en gang. Du kan avbryte om det tar for lang tid.

nsker du  oppgradere databasen n?
}

# Recent files options:
translate O RecentFilesMenu {Number of recent files in File menu} ;# ***
translate O RecentFilesExtra {Number of recent files in extra submenu} ;# ***

# My Player Names options:
translate O MyPlayerNamesDescription {
Enter a list of preferred player names below, one name per line. Wildcards (e.g. "?" for any single character, "*" for any sequence of characters) are permitted.

Every time a game with a player in the list is loaded, the main window chessboard will be rotated if necessary to show the game from that players perspective.
} ;# ***

#Coach
translate O showblunderexists {Vis at feil eksisterer}
translate O showblundervalue {vise feilverdi}
translate O showscore {vis poengsum}
translate O coachgame {trenerspill}
translate O configurecoachgame {konfigurere trenerspill}
translate O configuregame {Spillkonfigurasjon}
translate O Phalanxengine {Phalanx motor}
translate O Coachengine {Bussmotor}
translate O difficulty {vanskelighet}
translate O hard {hard}
translate O easy {lett}
translate O Playwith {Lek med}
translate O white {hvit}
translate O black {svart}
translate O both {bde}
translate O Play {Spille}
translate O Noblunder {Ingen tabbe}
translate O blunder {tabbe}
translate O Noinfo {-- Ingen info --}
translate O PhalanxOrTogaMissing {Phalanx eller Toga ikke funnet}
translate O moveblunderthreshold {flytting er en tabbe hvis tapet er strre enn}
translate O limitanalysis {begrense motoranalysetiden}
translate O seconds {sekunder}
translate O Abort {Avbryt}
translate O Resume {Gjenoppta}
translate O OutOfOpening {Ute av pning}
translate O NotFollowedLine {Du fulgte ikke linjen}
translate O DoYouWantContinue {Vil du fortsette?}
translate O CoachIsWatching {Treneren ser p}
translate O Ponder {Permanent tenkning}
translate O LimitELO {Begrens ELO-styrken}
translate O DubiousMovePlayedTakeBack {Tvilsomt trekk spilt, vil du ta tilbake?}
translate O WeakMovePlayedTakeBack {Svak trekk spilt, vil du ta tilbake?}
translate O BadMovePlayedTakeBack {Drlig trekk spilt, vil du ta tilbake?}
translate O Iresign {Jeg sier opp}
translate O yourmoveisnotgood {trekket ditt er ikke bra}
translate O EndOfVar {Slutt p variasjon}
translate O Openingtrainer {pningstrener}
translate O DisplayCM {Vis kandidattrekk}
translate O DisplayCMValue {Visningskandidat flytter verdi}
translate O DisplayOpeningStats {Vis statistikk}
translate O ShowReport {Vis rapport}
translate O NumberOfGoodMovesPlayed {gode trekk spilt}
translate O NumberOfDubiousMovesPlayed {tvilsomme trekk spilt}
translate O NumberOfMovesPlayedNotInRepertoire {trekk spilt ikke p repertoar}
translate O NumberOfTimesPositionEncountered {ganger posisjon ptruffet}
translate O PlayerBestMove  {Tillat bare de beste trekk}
translate O OpponentBestMove {Motstanderen spiller de beste trekkene}
translate O OnlyFlaggedLines {Kun flaggede linjer}
translate O resetStats {Tilbakestill statistikk}
translate O Repertoiretrainingconfiguration {Repertoartreningskonfigurasjon}
translate O Loadingrepertoire {Laster repertoar}
translate O Movesloaded {Trekk lastet}
translate O Repertoirenotfound {Repertoar ikke funnet}
translate O Openfirstrepertoirewithtype {pne frst en repertoardatabase med ikon/type satt til hyre side}
translate O Movenotinrepertoire {Beveg deg ikke i repertoaret}
translate O PositionsInRepertoire {Posisjoner p repertoar}
translate O PositionsNotPlayed {Stillinger ikke spilt}
translate O PositionsPlayed {Stillinger spilt}
translate O Success {Suksess}
translate O DubiousMoves {Tvilsomme trekk}
translate O OutOfRepertoire {OutOfRepertoar}
translate O ConfigureTactics {Konfigurer taktikk}
translate O ResetScores {Tilbakestill score}
translate O LoadingBase {Lastebase}
translate O Tactics {Taktikk}
translate O ShowSolution {Vis lsning}
translate O NextExercise {Neste velse}
translate O PrevExercise {forrige velse}
translate O StopTraining {Slutt  trene}
translate O Next {Neste}
translate O ResettingScore {Tilbakestiller poengsummen}
translate O LoadingGame {Laster spillet}
translate O MateFound {Kompis funnet}
translate O BestSolutionNotFound {Beste lsningen ble IKKE funnet!}
translate O MateNotFound {Kompis ikke funnet}
translate O ShorterMateExists {Kortere kompis finnes}
translate O ScorePlayed {Score spilt}
translate O Expected {forventet}
translate O ChooseTrainingBase {Velg treningsgrunnlag}
translate O Thinking {Tenker}
translate O AnalyzeDone {Analysen er utfrt}
translate O WinWonGame {Vinn vunnet spill}
translate O Lines {Linjer}
translate O ConfigureUCIengine {Konfigurer UCI-motoren}
translate O SpecificOpening {Spesifikk pning}
translate O StartNewGame {Start nytt spill}
translate O FixedLevel {Fast niv}
translate O Opening {pning}
translate O RandomLevel {Tilfeldig niv}
translate O StartFromCurrentPosition {Start fra nvrende posisjon}
translate O FixedDepth {Fast dybde}
translate O Nodes {Noder} 
translate O Depth {Dybde}
translate O Time {Tid} 
translate O SecondsPerMove {Sekunder per trekk}
translate O Engine {Motor}
translate O TimeMode {Tidsmodus}
translate O TimeBonus {Tid + bonus}
translate O TimeMin {min}
translate O TimeSec {sek}
translate O AllExercisesDone {Alle velser utfrt}
translate O MoveOutOfBook {Flytt ut av boken}
translate O LastBookMove {Siste boktrekk}
translate O AnnotateSeveralGames {Kommenter flere spill\fra gjeldende til:}
translate O FindOpeningErrors {Finn pningsfeil}
translate O MarkTacticalExercises {Merk taktiske velser}
translate O UseBook {Bruk bok}
translate O MultiPV {Flere varianter}
translate O Hash {Hash-minne}
translate O OwnBook {Bruk motorbok}
translate O BookFile {pningsbok}
translate O AnnotateVariations {Kommenter varianter}
translate O ShortAnnotations {Korte merknader}
translate O addAnnotatorTag {Legg til annotator-tag}
translate O AddScoreToShortAnnotations {Legg poengsum til korte merknader}
translate O Export {Eksport}
translate O BookPartiallyLoaded {Boken er delvis lastet}
translate O Calvar {Beregning av variasjoner}
translate O ConfigureCalvar {Konfigurasjon}
# Opening names used in tacgame.tcl
translate O Reti {Reti}
translate O English {engelsk}
translate O d4Nf6Miscellaneous {1.d4 Nf6 Diverse}
translate O Trompowsky {Trompowsky}
translate O Budapest {Budapest}
translate O OldIndian {Gammel indisk}
translate O BenkoGambit {Benko Gambit}
translate O ModernBenoni {Moderne Benoni}
translate O DutchDefence {nederlandsk forsvar}
translate O Scandinavian {skandinavisk}
translate O AlekhineDefence {Alekhines forsvar}
translate O Pirc {Pirc}
translate O CaroKann {Caro-Kann}
translate O CaroKannAdvance {Caro-Kann Advance}
translate O Sicilian {siciliansk}
translate O SicilianAlapin {Siciliansk Alapin}
translate O SicilianClosed {Siciliansk stengt}
translate O SicilianRauzer {Siciliansk Rauzer}
translate O SicilianDragon {Siciliansk drage}
translate O SicilianScheveningen {Sicilianske Scheveningen}
translate O SicilianNajdorf {sicilianske Najdorf}
translate O OpenGame {pne spill}
translate O Vienna {Wien}
translate O KingsGambit {Kongens Gambit}
translate O RussianGame {Russisk spill}
translate O ItalianTwoKnights {Italiensk/To riddere}
translate O Spanish {spansk}
translate O SpanishExchange {Spansk utveksling}
translate O SpanishOpen {Spansk Open}
translate O SpanishClosed {Spansk stengt}
translate O FrenchDefence {Fransk forsvar}
translate O FrenchAdvance {French Advance}
translate O FrenchTarrasch {Fransk Tarrasch}
translate O FrenchWinawer {Fransk Winawer}
translate O FrenchExchange {fransk utveksling}
translate O QueensPawn {Dronningens bonde}
translate O Slav {slavisk}
translate O QGA {QGA}
translate O QGD {QGD}
translate O QGDExchange {QGD Exchange}
translate O SemiSlav {Semi-slavisk}
translate O QGDwithBg5 {QGD med Bg5}
translate O QGDOrthodox {QGD ortodoks}
translate O Grunfeld {Grnfeld}
translate O GrunfeldExchange {Grnfeld Exchange}
translate O GrunfeldRussian {Grnfeld russisk}
translate O Catalan {katalansk}
translate O CatalanOpen {Catalan Open}
translate O CatalanClosed {Katalansk stengt}
translate O QueensIndian {Queen's Indian}
translate O NimzoIndian {Nimzo-indisk}
translate O NimzoIndianClassical {Nimzo-indisk klassisk}
translate O NimzoIndianRubinstein {Nimzo-indiske Rubinstein}
translate O KingsIndian {King's Indian}
translate O KingsIndianSamisch {King's Indian Smisch}
translate O KingsIndianMainLine {King's Indian Main Line}

# FICS
translate O ConfigureFics {Konfigurer FICS}
translate O FICSGuest {Logg inn som gjest}
translate O FICSServerPort {Serverport}
translate O FICSServerAddress {IP-adresse}
translate O FICSRefresh {Forfriske}
translate O FICSTimesealPort {Tidsegl havn}
translate O FICSSilence {Stillhet}
translate O FICSOffers {Tilbud}
translate O FICSConsole {Konsoll}
translate O FICSGames {Spill}
translate O FICSUnobserve {Slutt  observere spillet}
translate O FICSProfile {Vis historikken og profilen din}
translate O FICSRelayedGames {Relspill}
translate O FICSFindOpponent {Finn motstander}
translate O FICSTakeback {Tilbaketak}
translate O FICSTakeback2 {Tilbaketak 2}
translate O FICSInitTime {Starttid (min)}
translate O FICSIncrement {k (sek)}
translate O FICSRatedGame {Vurdert spill}
translate O FICSAutoColour {automatisk}
translate O FICSManualConfirm {bekrefte manuelt}
translate O FICSFilterFormula {Filtrer med formel}
translate O FICSIssueSeek {Problemsk}
translate O FICSChallenge {Utfordring}
translate O FICSAccept {akseptere}
translate O FICSDecline {avsl}
translate O FICSColour {Farge}
translate O FICSSend {sende}
translate O FICSConnect {Koble til}
translate O FICSdefaultuservars {Bruk standardvariabler}
translate O FICSObserveconfirm {Vil du observere vilt}
translate O FICSpremove {Aktiver premove}
translate O FICSObserve {Observere}
translate O FICSRatedGames {Vurderte spill}
translate O FICSUnratedGames {Uvurderte spill}
translate O FICSRated {Vurdert}
translate O FICSUnrated {Ikke vurdert}
translate O FICSRegisteredPlayer {Kun registrerte spillere}
translate O FICSFreePlayer {Kun gratis spiller}
translate O FICSNetError {Nettverksfeil\Kan ikke koble til}

# Game review
translate O GameReview {Spillanmeldelse}
translate O GameReviewTimeExtended {Tid forlenget}
translate O GameReviewMargin {Feilmargin}
translate O GameReviewAutoContinue {Autofortsett nr bevegelsen er riktig}
translate O GameReviewReCalculate {Bruk forlenget tid}
translate O GameReviewAnalyzingMovePlayedDuringTheGame {Analyserer trekk som er spilt i lpet av spillet}
translate O GameReviewAnalyzingThePosition {Analyserer posisjonen}
translate O GameReviewEnterYourMove {Skriv inn ditt trekk}
translate O GameReviewCheckingYourMove {Sjekker flyttingen din}
translate O GameReviewYourMoveWasAnalyzed {Trekningen din ble analysert}
translate O GameReviewYouPlayedSameMove {Du spilte samme trekk som i kampen}
translate O GameReviewScoreOfYourMove {Poengsummen for trekket ditt}
translate O GameReviewGameMoveScore {Spillbevegelsens poengsum}
translate O GameReviewEngineScore {Motorens poengsum}
translate O GameReviewYouPlayedLikeTheEngine {Du spilte som motoren}
translate O GameReviewNotEngineMoveButGoodMove {Ikke motorbevegelsen, men er ogs et godt trekk}
translate O GameReviewMoveNotGood {Dette trekket er ikke bra, poengsum er}
translate O GameReviewMovesPlayedLike {Bevegelser spilt som}
translate O GameReviewMovesPlayedEngine {Bevegelser spilt som motor}

# Correspondence Chess Dialogs:
translate O CCDlgCGeneraloptions {Generelle alternativer}
translate O CCDlgLoginName  {Ploggingsnavn:}
translate O CCDlgPassword   {Passord:}
translate O CCDlgShowPassword {Vis passord}

# Connect Hardware dialogs
translate O ExtHWConfigConnection {Konfigurer ekstern maskinvare}
translate O ExtHWPort {Havn}
translate O ExtHWEngineCmd {Motorkommando}
translate O ExtHWEngineParam {Motorparameter}
translate O ExtHWShowButton {Vis knapp}
translate O ExtHWHardware {Maskinvare}
translate O ExtHWNovag {Novag Citrine}
translate O ExtHWInputEngine {Inndatamotor}
translate O ExtHWNoBoard {Ingen brett}
translate O NovagReferee {Dommer}

# Input Engine dialogs
translate O IEConsole {Inndatamotorkonsoll}
translate O IESending {Flytt sendt for}
translate O IESynchronise {Synkroniser}
translate O IERotate  {Rotere}
translate O IEUnableToStart {Kan ikke starte Input Engine:}

# Calculation of Variations
translate O DoneWithPosition {Ferdig med posisjon}

translate O Board {Borde}
translate O showGameInfo {Vis spillinformasjon}
translate O autoResizeBoard {Automatisk endring av strrelse p brett}
translate O DockTop {Flytt til toppen}
translate O DockBottom {Flytt til bunnen}
translate O DockLeft {Flytt til venstre}
translate O DockRight {Flytt til hyre}
translate O Undock {Koble fra}

# Switcher window
translate O AboutDatabase {Om denne databasen}
translate O ChangeIcon {Endre ikon...}
translate O NewGameListWindow {Nytt spilllistevindu}
translate O LoadatStartup {Last ved oppstart}

# Gamelist window
translate O ShowHideDB {Vis/skjul databaser}
translate O ChangeFilter {Bytt filter}
translate O ChangeLayout {Last inn/Lagre/Endre sorteringskriterier og kolonneoppsett}
translate O ShowHideStatistic {Vis/skjul statistikk}
translate O BoardFilter {Vis kun spill som samsvarer med gjeldende brettposisjon}
translate O CopyGameTo {Kopier spillet til}
translate O FindBar {Finn Bar}
translate O FindCurrentGame {Finn gjeldende spill}
translate O DeleteGame {Slett spillet}
translate O UndeleteGame {Angre sletting av spill}
translate O ResetSort {Tilbakestill sortering}

translate O ConvertNullMove {Konverter null-trekk til kommentarer}
translate O SetupBoard {Oppsettbrett}
translate O Rotate {Rotere}
translate O SwitchColors {Bytt farger}
translate O FlipBoard {Flipbrett}
translate O ImportPGN {Importer PGN-spill}
translate O ImportingFiles {Importerer PGN-filer inn}
translate O ImportingFrom {Importerer fra}
translate O ImportingIn {Importer spill inn}
translate O UseLastTag {Bruk siste\nspillets tagger}
translate O Random {Tilfeldig}
translate O BackToMainline {G tilbake til hovedlinjen}
translate O LeaveVariant {La variant}
translate O Autoplay {Automatisk avspilling}
translate O ShowHideCoords {Vis/skjul koordinering.}
translate O ShowHideEvalBar {Vis/skjul evalueringslinje}
translate O ShowHideMaterial {Vis/skjul materiale}
translate O SelectMarker {Velg Marker}
translate O FullScreen {Fullskjerm}
translate O FilterStatistic {Filtrer statistikk}
translate O MakeCorrections {Foreta rettelser}
translate O Surnames {Etternavn}
translate O Ambiguous {Tvetydig}

#Preferences Dialog
translate O OptionsToolbar "Verktylinje i hovedvindu"
translate O OptionsBoard "Brett"
translate O OptionsBoardSize "Brettstrrelse"
translate O OptionsBoardPieces "Brikkeutseende"
translate O OptionsInternationalization "Internasjonalisering"
translate O OptionsTablebaseDir "Velg opptil 4 tabellgrunnmapper:"

# Evaluation bar
translate O BestMoveArrow "Beste flyttepil"
translate O NewLocalEngine "+ Ny motor..."

# Batch Annotate
translate O BatchAnnotate {Batch-kommentarer}
translate O BatchEngineSelection {Motorvalg}
translate O BatchChessEngine {Sjakkmotor:}
translate O BatchNumberOfInstances {Antall forekomster:}
translate O BatchGameReview {Spillanmeldelse}
translate O BatchTimePerMove {Tid per trekk (sek):}
translate O BatchAnnotateBlunders {Merk kun feil}
translate O BatchBlunderThreshold {Bommertsgrense:}
translate O BatchVariationLength {Variasjonslengde (bevegelser):}
translate O BatchOpeningBook {Åpningsbok}
translate O BatchUseBook {Bruk bok}
translate O BatchAnnotateVariations {Kommenter varianter}
translate O BatchShortAnnotations {Korte merknader}
translate O BatchAddScoreToShort {Legg poengsum til korte merknader}
translate O BatchClearOld {Fjern gamle kommentarer og varianter}
translate O BatchInitializingEngines {Initialiserer motorer...}
translate O BatchAnalyzingGames {Analyserer spill...}
translate O BatchProgress {Batchkommentarfremgang}
translate O BatchComplete {Batch-annotering fullført!}
translate O BatchCancelled {Batch-anmerkning kansellert}
translate O BatchStart {Start}
translate O BatchCancel {Kansellere}
translate O BatchCompleted {fullført}
translate O BatchGames {spill}
translate O BatchProcessed {behandlet}
}
# end of english.tcl
