### deutsch.tcl:
#  German language support for Scid.
#  Contributors: Bernhard Bialas, Jrgen Clos, Frank Eschenauer  et al.
#  Untranslated messages are marked with a "***" comment.
#
#  Hinweis (aus tcl/lang/english.tcl):
#
# (4) [...]
#
#     A menu command has the format:
#         menuText L tag "Name..." underline {HelpMessage...}
#
#     [...]
#
#     where "L" is the language letter, "tag" is the name of the menu entry
#     or the button widget name, and "underline" is the index of the letter
#     to underline, counting from zero as the first letter. Two menu entries
#     that appear in the same menu should have a different underlined letter.

proc setLanguage_D {} {

# File menu:
menuText D File "Datei" 0
menuText D FileNew "Neu..." 0 {Neue Scid-Datenbank anlegen}
menuText D FileOpen "ffnen..." 0 {Existierende Scid-Datenbank ffnen}
menuText D FileClose "Schlieen" 0 {Aktive Scid-Datenbank schlieen}
menuText D FileFinder "Dateisuche" 0 {Dateisuchfenster ffnen}
menuText D FileBookmarks "Lesezeichen" 0 {Lesezeichenmen}
menuText D FileBookmarksAdd "Lesezeichen zur Liste hinzufgen" 0 \
  {Lesezeichen fr die aktuelle Partie und Datenbank}
menuText D FileBookmarksFile "Lesezeichen hinzufgen in Verzeichnis" 26 \
  {Lesezeichen fr die aktuelle Stellung und Partie zum Verzeichnis hinzufgen}
menuText D FileBookmarksEdit "Lesezeichen editieren..." 12 \
  {Lesezeichen bearbeiten}
menuText D FileBookmarksList "Listenansicht" 1 \
  {Lesezeichen als Liste zeigen, ohne Unterverzeichnisse}
menuText D FileBookmarksSub "Verzeichnisansicht" 3 \
  {Lesezeichen in Verzeichnissen zeigen, nicht als Gesamtliste}
menuText D FileMaint "Wartung" 0 {Das Scid-Datenbankwartungsfenster}
menuText D FileMaintWin "Wartungfenster" 0 \
  {Datenbank-Wartungsfenster ffnen/schlieen}
menuText D FileMaintCompact "Datenbank komprimieren..." 10 \
  {Datenbank komprimieren, gelschte Spiele und unbenutzte Namen entfernen}
menuText D FileMaintClass "Partien ECO-klassifizieren..." 8 \
{Neuklassifizierung aller Partien nach dem ECO-Code}
menuText D FileMaintSort "Sortieren..." 0 \
  {Alle Partien in der aktuellen Datenbank sortieren}
menuText D FileMaintDelete "Dubletten lschen..." 0 \
  {Dubletten finden und Lschkennzeichen setzen}
menuText D FileMaintTwin "Dubletten prfen" 10 \
  {Dublettenfenster ffnen/erneuern}
menuText D FileMaintName "Namen" 0 \
  {Namenseditor und Rechtschreibprfung}
menuText D FileMaintNameEditor "Namenseditor" 0 \
  {Namenseditorfenster ffnen/schlieen}
menuText D FileMaintNamePlayer "Schreibkorrektur Spieler..." 17 \
  {Schreibkorrektur der Spielernamen mit Hilfe der .ssp-Datei}
menuText D FileMaintNameEvent "Schreibkorrektur Ereignis..." 17 \
  {Schreibkorrektur der Ereignisse mit Hilfe der .ssp-Datei}
menuText D FileMaintNameSite "Schreibkorrektur Ort..." 17 \
  {Schreibkorrektur der Orte mit Hilfe der .ssp-Datei}
menuText D FileMaintNameRound "Schreibkorrektur Runde..." 17 \
  {Schreibkorrektur der Runden mit Hilfe der .ssp-Datei}
menuText D FileReadOnly "Schreibschutz..." 3 \
  {Datenbank als schreibgeschtzt behandeln, nderungen verhindern}
menuText D FileSwitch "Datenbank wechseln" 0 \
  {Zu einer anderen geffneten Datenbank umschalten}
menuText D FileOpenLichessTournament "Lichess-Turnier ffnen" 0 {Live-Partien eines Lichess-Turniers herunterladen und ffnen}
menuText D FileImportLichess "Meine Lichess-Partien importieren" 0 {Partien aus Ihrem Lichess-Konto importieren}
menuText D FileImportChessCom "Meine Chess.com-Partien importieren" 0 {Partien aus Ihrem Chess.com-Konto importieren}
menuText D FileExit "Ende" 0 {Scid beenden}
menuText D FileMaintFixBase "Inkonsistenzen beseitigen" 0 {Versuche eine inkonsistente Datenbank zu reparieren}

# Edit menu:
menuText D Edit "Bearbeiten" 0
menuText D EditAdd "Variante hinzufgen" 0 \
  {Fge zu diesem Zug eine Variante hinzu}
menuText D EditDelete "Variante lschen" 9 \
  {Lsche eine Variante zu diesen Zug}
menuText D EditFirst "Als erste Variante setzen" 4 \
  {Variante an erste Stelle in der Liste setzten}
menuText D EditMain "Variante als Partiefortsetzung" 13 \
  {Variante zur Partiefolge machen (und umgekehrt)}
menuText D EditTrial "Variante testen" 9 \
  {Testmodus starten/stoppen, um eine Idee am Brett auszuprobieren}
menuText D EditStrip "Entfernen" 1 \
   {Kommentare oder Varianten aus der Partie entfernen}
menuText D EditUndo "Rckgngig" 0 {Macht die letzte nderung rckgngig}
menuText D EditRedo "Wiederherstellen" 0 {Redo last game change}
menuText D EditStripComments "Kommentare" 0 \
  {Alle Kommentare und Kommentarzeichen aus dieser Partie entfernen}
menuText D EditStripVars "Varianten" 0 \
  {Alle Varianten aus der Partie entfernen}
menuText D EditStripBegin "Zge ab Anfang" 8 \
  {Entferne Zge ab Partieanfang}
menuText D EditStripEnd "Zge bis Ende" 9 \
  {Entferne Zge bis Partieende}
menuText D EditReset "Ablage leeren" 0 \
   {Inhalt der Ablage-Datenbank lschen}
menuText D EditCopy "Partie in Ablage kopieren" 17 \
  {Diese Partie in die Ablage-Datenbank kopieren}
menuText D EditPaste "Partie aus Ablage einfgen" 19 \
  {Die aktuele Partie aus der Ablagedatenbank hier einfgen}
menuText D EditPastePGN "PGN-Partie aus Ablage einfgen..." 1 \
  {Interpretiere den Inhalt der Zwischenablage als PGN-Notation und fge ihn hier ein}
menuText D EditSetup "Stellungseingabe..." 0 \
  {Neue Stellung eingeben (FEN oder manuell)}
menuText D EditCopyBoard "Stellung kopieren" 10 \
  {Aktuelle Brettposition in die Zwischenablage kopieren (im FEN-Format)}
menuText D EditPasteBoard "Stellung einfgen" 12 \
  {Stellung aus der Zwischenablage (im FEN-Format) einfgen}
menuText D ConfigureScid "Einstellungen..." 0 {Alle Optionen fr SCID einstellen}

# Game menu:
menuText D Game "Partie" 0
menuText D GameNew "Neue Partie" 5 {Neue Partie beginnen}
menuText D GameFirst "Erste Partie laden" 0 {Erste Partie im Filter laden}
menuText D GamePrev "Vorherige Partie laden" 0 \
  {Vorherige Partie im Filter laden}
menuText D GameReload "Partie wiederladen" 7 \
  {Diese Partie erneut laden, dabei alle nderungen verwerfen}
menuText D GameNext "Nchste Partie laden" 0 {Nchste Partie im Filter laden}
menuText D GameLast "Letzte Partie laden" 0 {Letzte Partie im Filter laden}
menuText D GameRandom "Zufllige Partie laden" 1 \
  {Zufllig ausgewhlte Partie im Filter laden}
menuText D GameNumber "Lade Partie Nummer..." 14 \
  {Partie durch Angabe der Nummer laden}
menuText D GameReplace "Partie ersetzen..." 8 \
  {Diese Partie sichern, dabei alte Version berschreiben}
menuText D GameAdd "Partie speichern..." 7 \
  {Diese Partie als neue Partie in der Datenbank sichern}
menuText D GameDeepest "Erffnung identifizieren" 10 \
  {Zur Position der lngstmglichen Zugfolge nach ECO-Klassifikation gehen}
menuText D GameGotoMove "Zugnummer..." 0 \
  {Zur angegebenen Zugnummer in der aktuellen Partie gehen}
menuText D GameNovelty "Finde Neuerung..." 0 \
  {Ersten Zug dieser Partie finden, der vorher noch nie gespielt wurde}

# Search Menu:
menuText D Search "Suchen" 0
menuText D SearchReset "Filter zurcksetzen" 0 \
  {Alle Partien in den Filter einschlieen}
menuText D SearchNegate "Filter invertieren" 7 \
  {Alle ausgeschlossenen Partien in den Filter nehmen}
menuText D SearchCurrent "Brett..." 0 \
  {Aktuelle Brettposition suchen}
menuText D SearchHeader "Partiedaten..." 0 \
  {Partiedaten (Spieler, Turnier etc.) suchen}
menuText D SearchMaterial "Material/Muster..." 0 \
  {Nach Material- oder Stellungsmustern suchen}
menuText D SearchUsing "Mit Suchoptionsdatei..." 4 \
  {Mit Suchoptionsdatei suchen}

# Windows menu:
menuText D Windows "Fenster" 0
menuText D WindowsComment "Kommentareditor" 0 {Kommentareditor ffnen/schlieen}
menuText D WindowsGList "Partieliste" 6 {Partieliste ffnen/schlieen}
menuText D WindowsPGN "PGN-Fenster" 0 {PGN-Fenster (Partienotation) ffnen/schlieen}
menuText D WindowsPList "Spielersuche" 0 {Spielersuche ffnen/schlieen}
menuText D WindowsTmt "Turniersuche" 0 {Turniersuche ffnen/schlieen}
menuText D WindowsSwitcher "Datenbank-Umschalter" 0 \
  {Datenbank-Umschalter ffnen/schlieen}
menuText D WindowsMaint "Wartungsfenster" 0 {(Datenbank-)Wartungsfenster ffnen/schlieen}
menuText D WindowsECO "ECO-Auswertung" 0 {ECO-Auswertung ffnen/schlieen}
menuText D WindowsStats "Statistik" 4 {Filterstatistik ffnen/schlieen}
menuText D WindowsTree "Zugbaum" 0 {Zugbaum ffnen/schlieen}
menuText D WindowsBook "Buchfenster" 0 {Buchfenster ffnen/schlieen}
menuText D WindowsCorrChess "Fernschachfenster" 0 {ffnet/schliet das Fernschachfenster}
menuText D WindowsGraph "Analysediagramm" 0 {ffnen Sie das Diagrammfenster mit den Zugzeiten und -bewertungen}

# Tools menu:
menuText D Tools "Werkzeuge" 0
menuText D ToolsConfigureEngines "Engine konfigurieren" 10 {Manage engines' configuration}
menuText D ToolsAnalysis "Analyse-Engine..." 0 \
  {Schachanalyse-Programm starten/beenden}
menuText D ToolsAnalysis2 "Analyse-Engine #2..." 16 \
  {Schachanalyse-Programm Nr.2 starten/beenden}
menuText D ToolsCross "Turniertabelle" 0 {Turniertabelle fr diese Partie anzeigen}
menuText D ToolsFilterGraph "Rel. Filtergrafik" 0 \
  {Filtergrafik mit relativen Werten ffnen/schlieen}
menuText D ToolsAbsFilterGraph "Abs. Filtergrafik" 11 \
  {Filtergrafik mit absoluten Werten ffnen/schlieen}
menuText D ToolsOpReport "Erffnungsbericht" 0 \
  {Ausfhrliche Erffnungsbersicht fr die aktuelle Position erstellen}
menuText D ToolsOpenBaseAsTree "ffne DB als Baum" 0   {ffne DB und verwende sie im Zugbaum-Fenster}
menuText D ToolsOpenRecentBaseAsTree "Letzte DB als Baum" 0   {ffne zuletzt verwendete DB im Zugbaum-Fenster}
menuText D ToolsTracker "Figurenverteilung"  7 \
  {Figurenverteilungsfenster ffnen}
menuText D ToolsTraining "Training"  0 {Trainingswerkzeuge (Taktik, Erffnungen,...) }
menuText D ToolsTacticalGame "Trainingspartie"  0 {Trainingspartie spielen}
menuText D ToolsSeriousGame "Ernste Partie"  0 {Ernste Partie spielen}
menuText D ToolsTrainOpenings "Erffnungen"  0 {Erffnungsrepertoire trainieren}
menuText D ToolsTrainReviewGame "Partie nachspielen"  0 {Finden von Zgen wie in vorgegebener Partie}
menuText D ToolsTrainTactics "Taktik"  0 {Taktische Stellungen lsen}
menuText D ToolsTrainCalvar "Varianten berechnen"  0 {Training zum Berechnen von Varianten}
menuText D ToolsTrainFindBestMove "Besten Zug finden"  0 {Find best move}
menuText D ToolsTrainFics "Internetpartie (FICS)"  0 {Internetpartie auf freechess.org}
menuText D ToolsEngineTournament "Engine Turnier"  0 {Start a tournament between chess engines}
menuText D ToolsTimeAnalysis "Zeitanalyse" 0 {Uhrzeitdiagramm fr das aktuelle Spiel anzeigen}
menuText D ToolsBookTuning "Buch abstimmen" 0 {Buch abstimmen}
menuText D ToolsDownloadTWIC "Laden Sie TWIC-Spiele herunter" 0 {Laden Sie die neuesten The Week In Chess (TWIC)-Spiele herunter}
menuText D ToolsConnectHardware "Hardware verbinden" 0 {Externe Hardware mit Scid verbinden}
menuText D ToolsConnectHardwareConfigure "Konfigurieren..." 0 {Hardware und Verbindung konfigurieren}
menuText D ToolsConnectHardwareNovagCitrineConnect "Novag Citrine verbinden" 0 {Novag Citrine mit Scid verbinden}
menuText D ToolsConnectHardwareInputEngineConnect "Input Engine verbinden" 0 {Input Engine (z.B. DGT Brett) mit Scid verbinden}

menuText D ToolsPInfo "Spielerinformation"  0 \
  {Spielerinformation ffnen/schlieen}
menuText D ToolsPlayerReport "Spielerbericht..." 7 \
  {Erzeuge einen Spielerbericht}
menuText D ToolsRating "ELO-Zahl-Verlauf" 4 \
  {Wertungsverlauf beider Spieler grafisch darstellen}
menuText D ToolsExpCurrent "Partie exportieren" 8 \
  {Aktuelle Partie in eine Textdatei schreiben}
menuText D ToolsExpCurrentPGN "Partie in PGN-Datei exportieren..." 10 \
  {Aktuelle Partie in eine PGN-Datei schreiben}
menuText D ToolsExpCurrentHTML "Partie in HTML-Datei exportieren..." 10 \
  {Aktuelle Partie in eine HTML-Datei schreiben}
menuText D ToolsExpCurrentHTMLJS "Partie in HTML/JavaScript-Datei exportieren..." 15 {Aktuelle Partie wird in eine HTML und JavaScript Datei exportiert.}  
menuText D ToolsExpFilter "Alles im Filter exportieren" 16 \
  {Alle Partien im Filter in eine Textdatei schreiben}
menuText D ToolsExpFilterPGN "Filter in PGN-Datei exportieren..." 10 \
  {Alle Partien im Filter in eine PGN-Datei schreiben}
menuText D ToolsExpFilterHTML "Filter in HTML-Datei exportieren..." 10 \
  {Alle Partien im Filter in eine HTML-Datei schreiben}
menuText D ToolsExpFilterHTMLJS "Filter in HTML/JavaScript exportieren..." 17 {Alle Partien im Filter werden in eine HTML und JavaScript Datei exportiert.}  
menuText D ToolsImportOne "Eine PGN-Partie importieren..." 16 \
  {Eine Partie im PGN-Format eingeben oder einfgen}
menuText D ToolsImportFile "PGN-Partien importieren..." 0 \
  {Partien aus einer PGN-Datei lesen}
menuText D ToolsStartEngine1 "Starte Engine1" 0  {Starte Analyse von Analyse-Engine1}
menuText D ToolsStartEngine2 "Starte Engine2" 0  {Starte Analyse von Analyse-Engine2}
menuText D ToolsCaptureBoard "Brettfoto..." 0  {Aktuelles Brett als Bild speichern.}

# Play menu
menuText D Play "Spielen" 0 {Partien spielen}

# --- Correspondence Chess
menuText D CCResign "Aufgeben" 0 {Partie aufgeben (funktioniert nicht via eMail)}
menuText D CCClaimDraw "Remis erklren" 1 {Zug senden und Partie Remis erklren (funktioniert nicht via eMail)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText D Options "Optionen" 0
menuText D OptionsBoardGraphics "Brettfelder..." 3 {Grafik fr Brettfelder auswhlen}
translate D OptionsBGW {Grafikdatei fr Felder auswhlen}
translate D OptionsBoardGraphicsText {Grafikdateien fr helle und dunkle Felder auswhlen:}
menuText D OptionsBoardNames "Meine Spielernamen..." 0 {Editiere meine Spielernamen}
menuText D OptionsExport "Export" 1 {Textausgabeoptionen ndern}
menuText D OptionsFonts "Schriftarten" 3 {Schriftarten auswhlen}
menuText D OptionsFontsRegular "Normal" 0 {Standardzeichensatz}
menuText D OptionsFontsMenu "Men" 0 {Schriftart fr Mens}
menuText D OptionsFontsSmall "Klein" 0 {Kleine Zeichen}
menuText D OptionsFontsTiny "Winzig" 0 {Kleinster Font}
menuText D OptionsFontsFixed "Fest" 0 {Schriftart mit fester Breite (nicht-proportional)}
menuText D OptionsGInfo "Partieinformation" 0 {Optionen fr Informationsbereich}
menuText D OptionsLanguage "Sprache" 0 {Sprache whlen}
menuText D OptionsMovesTranslatePieces "Figurennamen bersetzen" 0 {bersetze den ersten Buchstaben der Figurenbezeichnung}
menuText D OptionsMovesHighlightLastMove "Letzen Zug hervorheben" 0 {Rahmt Start- und Zielfeld des letzten Zuges farbig ein}
menuText D OptionsMovesHighlightLastMoveDisplay "Felder anzeigen" 0 {Hervorhebung des letzen Zuges anzeigen}
menuText D OptionsMovesHighlightLastMoveWidth "Dicke" 0 {Dicke der Linie}
menuText D OptionsMovesHighlightLastMoveColor "Farbe" 0 {Farbe der Linie}
menuText D OptionsMovesHighlightLastMoveArrow "Pfeil anzeigen" 0 {mit einem Pfeil hervorheben}
menuText D OptionsMovesHighlightLastMoveNag "Zugbewertung anzeigen" 0
menuText D OptionsMovesHighlightLastMoveEval "Stellungsbewertung anzeigen" 0
menuText D OptionsMoves "Zge" 0 {Zugeingabeoptionen}
menuText D OptionsMovesAnimate "Animation" 0 \
  {Zeit fr Zuganimation einstellen}
menuText D OptionsMovesDelay "Autom. Vorspielen..." 7 \
  {Zeit fr automatisches Vorspielen einstellen}
menuText D OptionsMovesCoord "Tastatureingabe" 0 \
  {Zugeingabe ber Koordinaten ("g1f3") akzeptieren}
menuText D OptionsMovesSuggest "Zugvorschlag zeigen" 0 \
  {Zugvorschlag ein-/ausschalten}
menuText D OptionsShowVarPopup "Variantenfenster zeigen" 0 { Anzeige des Variantenauswahlfensters ein/ausschalten}  
menuText D OptionsMovesSpace "Leerzeichen nach Zugnummer einfgen" 0 {Leerzeichen nach Zugnummer einfgen}  
menuText D OptionsMovesLichess "Lichess/ChessBase-Format fr Anmerkungen" 0 {Lichess/ChessBase-Format fr Anmerkungen}
menuText D OptionsMovesKey "Autom. Zugergnzung" 10 \
  {Automatische Zugergnzung ein-/ausschalten}
menuText D OptionsMovesShowVarArrows "Pfeile fr Varianten anzeigen" 0 {Zeige Pfeile in Varianten an: ja/nein}
menuText D OptionsMovesShowEngineVariationArrows "Engine-Varianten-Pfeile" 0 {Schaltet die mehrfarbigen drei Variantenpfeile im multiPV Modus aus}
menuText D OptionsMovesGlossOfDanger "Bedrohte Figuren einfrben" 0 {Markieren von gefrdeten Figuren ein/ausschalten}
translate D OptionsMovesTreeDepth {Standardmige Verschiebetiefe des Baumfensters}
menuText D OptionsNumbers "Zahlenformat" 5 {Zahlenformat whlen}
menuText D OptionsTheme "Design" 0 {Verndert das Aussehen der Oberflche}
menuText D OptionsWindows "Fenster" 6 {Fenster-Optionen}
menuText D OptionsSounds "Sprachausgabe" 0 {Sprachausgabe fr Zugankndigung einstellen}
menuText D OptionsResources "Ressourcen..." 0 {Standard Dateien und Verzeichnisse einstellen}
menuText D OptionsWindowsDock "Fenster anheften" 0 {Fenster in der Hauptanwendung ffnen}
menuText D OptionsWindowsSaveLayout "Layout speichern" 0 {Speichern des aktuellen Fensterlayout}
menuText D OptionsWindowsRestoreLayout "Layout laden" 0 {Gespeichertes Fensterlayout wieder herstellen}
menuText D OptionsWindowsShowGameInfo "Partieinformationen" 0 {Partieinformation anzeigen}
menuText D OptionsWindowsAutoLoadLayout "Automatisch laden: 1. Layout" 0 {Ldt das erste definierte Layout automatisch beim Programmstart}
menuText D OptionsECO "ECO-Datei" 0 {ECO-Klassifikationsdatei laden}
menuText D OptionsSpell "Schreibkorrekturdatei" 7 \
  {Datei fr Scid-Rechtschreibprfung laden}
menuText D OptionsTable "Verzeichnisse der Endspieltabellen" 16 \
  {Eine Endspieltabellendatei whlen (und damit alle Tabellen in diesem Verzeichnis)}
menuText D OptionsRecent "Letzte Dateien" 9 \
   {Anzahl der aktuellen Dateien im Dateimen ndern}
menuText D OptionsBooksDir "Verzeichnis fr Erffnungsbcher" 0 {Erffnungsbuchverzeichnis einstellen}
menuText D OptionsTacticsBasesDir "Verzeichnis fr Taktikdatenbanken" 0 {Verzeichnis fr taktische Trainingsdatenbanken einstellen}
menuText D OptionsPhotosDir "Verzeichnis fr Spielerbilder" 0 {Verzeichnis fr Bilder einstellen}
menuText D OptionsThemeDir "Datei mit Design(s)"  0 { Packetdatei fr GUI Design Themen einstellen }
menuText D OptionsSave "Optionen speichern" 0 \
  "Alle einstellbaren Optionen in der Datei $::optionsFile sichern"
menuText D OptionsAutoSave "Speichern beim Beenden" 0 \
  {Alle Optionen beim Beenden von Scid automatisch speichern}

# Help menu:
menuText D Help "Hilfe" 0
menuText D HelpContents "Inhalt" 0 {Gehe zum Inhaltsverzeichnis}
menuText D HelpIndex "Index" 4 {Gehe zum Hilfeindex}
menuText D HelpGuide "Kurzanleitung" 4 {Ein Scid-Schnelldurchgang}
menuText D HelpHints "Hinweise" 0 {Die Scid-Kurztips}
menuText D HelpContact "Kontaktinformation" 0 {Hilfe zur Kontaktinformation}
menuText D HelpTip "Tagestip" 0 {Zeigt einen ntzlichen Tip an}
menuText D HelpStartup "Startfenster" 0 {Startfenster zeigen}
menuText D HelpAbout "Über scidCommunity" 0 {Informationen zu scidCommunity}

# Toolbar tooltips:
menuText D RotateBoard "Brett drehen" 0 {Brett drehen}

# Game info box popup menu:
menuText D GInfoHideNext "Nchsten Zug verbegen" 13
menuText D GInfoMaterial "Materialwerte zeigen" 0
menuText D GInfoFEN "FEN zeigen" 0
menuText D GInfoMarks "Gefrbte Felder und Pfeile zeigen" 0
menuText D GInfoWrap "Umbruch bei langen Zeilen" 0
menuText D GInfoFullComment "Vollstndigen Kommentar zeigen" 14
menuText D GInfoPhotos "Fotos zeigen" 1
menuText D GInfoTBNothing "Endspieltabellen: nichts" 18
menuText D GInfoTBResult "Endspieltabellen: nur Ergebnis" 22
menuText D GInfoTBAll "Endspieltabellen: Ergebnis und bester Zug" 31
menuText D GInfoDelete "(Ent)Lsche diese Partie" 5
menuText D GInfoMark "(Un)Markiere diese Partie" 4
menuText D GInfoInformant "Informatorwerte konfigurieren" 0

# General buttons:
translate D Back {Zurck}
translate D Browse {Auswhlen}
translate D Cancel {Abbrechen}
translate D Continue {Weiter}
translate D Clear {Leeren}
translate D Close {Schlieen}
translate D Contents {Inhalt}
translate D Defaults {Standard}
translate D InvertSearch {Suche umkehren}
translate D Delete {Lsche}
translate D Graph {Grafik}
translate D Help {Hilfe}
translate D Hide {Verbergen}
translate D Import {Importieren}
translate D Index {Index}
translate D LoadGame {Partie laden}
translate D BrowseGame {Partie betrachten}
translate D MergeGame {Partie zusammenfgen}
translate D MergeGames {Partien kombinieren}
translate D Preview {Vorschau} ;# Voransicht!? (KDE)
translate D Revert {Umkehren}
translate D Save {Speichern}
translate D Search {Suchen}
translate D Stop {Halt}
translate D Store {Speichern}
translate D Update {Aktualisieren}
translate D ChangeOrient {Fensterausrichtung ndern}
translate D ShowIcons {Symbole anzeigen}
translate D None {Keine}
translate D First {Erste}
translate D Current {Aktuelle}
translate D Last {Letzte}

# General messages:
translate D game {Partie}
translate D games {Partien}
translate D move {Zug}
translate D moves {Zge}
translate D all {Alle}
translate D Yes {Ja}
translate D No {Nein}
translate D Both {Beide}
translate D King {Knig}
translate D Queen {Dame}
translate D Rook {Turm}
translate D Bishop {Lufer}
translate D Knight {Springer}
translate D Pawn {Bauer}
translate D White {Wei}
translate D Black {Schwarz}
translate D Player {Spieler}
translate D Rating {Elo}
translate D RatingDiff {Elo-Differenz (Wei - Schwarz)}
translate D AverageRating {Elo-Durchschnitt}
translate D Event {Turnier}
translate D Site {Ort}
translate D Country {Land}
translate D IgnoreColors {Farben ignorieren}
translate D Date {Datum}
translate D EventDate {Turnierdatum}
translate D Decade {Dekade}
translate D Year {Jahr}
translate D Month {Monat}
translate D Months {Januar Februar Mrz April Mai Juni Juli August September Oktober November Dezember}
translate D Days {Son Mon Die Mit Don Fre Sam}
translate D YearToToday {-1J}
translate D YearToTodayTooltip {Setze das Datum 1 Jahr zurck bis heute}
translate D Result {Ergebnis}
translate D Round {Runde}
translate D Length {Lnge}
translate D ECOCode {ECO-Code}
translate D ECO {ECO}
translate D Deleted {Gelscht}
translate D SearchResults {Suchergebnisse}
translate D OpeningTheDatabase {Datenbank ffnen}
translate D Database {Datenbank}
translate D Filter {Filter}
translate D noGames {keine Partien}
translate D allGames {alle Partien}
translate D empty {leer}
translate D clipbase {Ablage}
translate D score {Punkte}
translate D StartPos {Stellung}
translate D Total {Summe}
translate D readonly {schreibgeschtzt}

# Standard error messages:
translate D ErrNotOpen {Dies ist keine geffnete Datenbank.}
translate D ErrReadOnly \
  {Diese Datenbank ist schreibgeschtzt; sie kann nicht gendert werden.}
translate D ErrSearchInterrupted \
  {Suche wurde unterbrochen; Ergebnisse sind unvollstndig.}
translate D ErrNoClockComments {In diesem Spiel wurden keine [%clk] Uhrkommentare gefunden.    Fgen Sie Uhrzeiten ber das Kommentarfenster (Strg+E) hinzu, um diese Funktion zu nutzen.}
translate D ErrFileInUse {Fehler: Die Datei wird bereits verwendet. Bitte schlieen Sie alle anderen Anwendungen, die diese Datenbank verwenden. Wenn das Programm unerwartet geschlossen wurde, mssen Sie mglicherweise die mit der Datenbank verknpfte .lock-Datei lschen.}




# Game information:
translate D twin {Dublette}
translate D deleted {gelscht}
translate D comment {Kommentar}
translate D hidden {versteckt}
translate D LastMove {letzter Zug}
translate D NextMove {nchster Zug}
translate D GameStart {Partieanfang}
translate D LineStart {Beginn der Zugfolge}
translate D GameEnd {Partieende}
translate D LineEnd {Ende der Zugfolge}

# Player information:
translate D PInfoAll {Ergebnisse fr <b>alle</b> Spiele}
translate D PInfoFilter {Ergebnisse fr <b>Filter</b>-Spiele}
translate D PInfoAgainst {Ergebnisse gegen}
translate D PInfoMostWhite {Hufigste Erffnungen als Weier}
translate D PInfoMostBlack {Hufigste Erffnungen als Schwarzer}
translate D PInfoRating {ELO-Historie}
translate D PInfoBio {Biographie}
translate D PInfoEditRatings {Editiere Ratings}
translate D PInfoEloFile {Datei}

# Tablebase information:
translate D Draw {Remis}
translate D with {mit}
translate D only {nur}
translate D lose {verlieren}
translate D loses {verliert}

# Tip of the day:
translate D Tip {Tip}
translate D TipAtStartup {Tip beim Starten}
translate D TipConvertPGN {Sie knnen eine bessere Leistung erreichen, wenn die PGN-Dateien konvertiert werden.}

# Tree window menus:
menuText D TreeFile "Datei" 0
menuText D TreeFileFillWithBase "Cache mit Datenbank fllen" 0 {Die Cache-Datei wird mit allen Partien der aktuellen Datenbank befllt.}
menuText D TreeFileFillWithGame "Cache mit Partie fllen" 0 {Die Cache-Datei wird mit der aktuellen Partien befllt.}
menuText D TreeFileSetCacheSize "Cache Gre" 0 {Cachegre auswhlen.}
menuText D TreeFileCacheInfo "Cache info" 0 {Info ber Cachenutzung anzeigen.}
menuText D TreeFileSave "Cache-Datei sichern" 12 \
  {Speichere die Zugbaum-Cache-Datei (.stc)}
menuText D TreeFileFill "Cache-Datei fllen" 12 \
  {Flle die Cache-Datei mit hufigen Erffnungspositionen}
menuText D TreeFileBest "Beste Partien" 0 \
  {Zeige die Liste bester Partien im Baum}
menuText D TreeFileGraph "Grafikfenster" 0 \
  {Zeige die Grafik fr diesen Ast}
menuText D TreeFileCopy "Kopiere Baumfenster in Zwischenablage" 0 \
  {Kopiere die Zugbaum-Statistik in die Zwischenablage}
menuText D TreeFileClose "Baumfenster schlieen" 12 {Schliee Zugbaum}
menuText D TreeMask "Maskieren" 0
menuText D TreeMaskNew "Neu" 0 {Neue Maske anlegen}
menuText D TreeMaskOpen "ffnen" 0 {Maske ffnen}
menuText D TreeMaskOpenRecent "Aktuelle Masken" 0 {Zuletzt geffnete Masken erneut laden}
menuText D TreeMaskSave "Speichern" 0 {Maske speichern}
menuText D TreeMaskClose "Schlieen" 0 {Maske schlieen}
menuText D TreeMaskFillWithGame "Mit aktueller Partie fllen" 0 {Maske mit der aktuellen Partie fllen}
menuText D TreeMaskFillWithBase "Mit Datenbank fllen" 0 {Maske mit Datenbankpartien fllen}
menuText D TreeMaskInfo "Info" 0 {Statistik fr die aktuelle Maske anzeigen}
menuText D TreeMaskDisplay "Maske als Baum" 0 {Zeigt den Inhalt der aktuellen Maske als Zugbaum}
menuText D TreeMaskSearch "Suchen" 0 {Suchen innerhalb der aktuellen Maske}
menuText D TreeSort "Sortieren" 0
menuText D TreeSortAlpha "Alphabetisch" 0
menuText D TreeSortECO "ECO-Code" 0
menuText D TreeSortFreq "Hufigkeit" 0
menuText D TreeSortScore "Punkte" 0
menuText D TreeOpt "Optionen" 0
menuText D TreeOptSlowmode "Grndliche Suche" 0 {Update mit hoher Genauigkeit, langsamer}
menuText D TreeOptFastmode "Schneller Modus" 0 {Schnelles Update (ignoriert Zugumstellungen)}
menuText D TreeOptFastAndSlowmode "Grndlicher und Schneller Modus" 0 {Zunchst schneller Updatemodus, dann nacharbeit im grndlichen Modus}
menuText D TreeOptStartStop "Automatisch aktualisieren" 0 {Schaltet das automatische aktualisieren ein/aus}
menuText D TreeOptLock "Anbinden" 0 \
  {Zugbaum an aktive Datenbank anbinden(/lsen)}
menuText D TreeOptTraining "Training" 0 {Trainingsmodus ein-/ausschalten}
menuText D TreeOptDepth "Baumtiefe (Halbzge)" 0 {Anzahl der im Baum anzuzeigenden Halbzge (1-4)}
menuText D TreeOptAutosave "Autom. Cache-Datei sichern" 4 \
  {Beim Schlieen des Zugbaums automatisch Cache-Datei sichern}
menuText D TreeHelp "Hilfe" 0
menuText D TreeHelpTree "Zugbaumhilfe" 0
menuText D TreeHelpIndex "Index" 0
translate D SaveCache {Cache sichern}
translate D Training {Training}
translate D LockTree {Anbinden}
translate D TreeDepth {Baumtiefe (halbe Zge):}
translate D TreeLocked {angebunden}
translate D TreeBest {Beste}
translate D TreeBestGames {Beste Zugbaumpartien}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate D TreeTitleRow \
{Zug                           ECO       Hufigkeit    Pkte   Elo  Erflg Jahr %Remis  %Gewinnen}
translate D TreeTotal {SUMME}
translate D DoYouWantToSaveFirst {Soll zuerst gespeichert werden}
translate D AddToMask {Zur Maske hinzufgen}
translate D RemoveFromMask {Entferne von Maske}
translate D AddThisMoveToMask {Diesen Zug zur Maske hinzufgen}
translate D SearchMask {Suche in einer Maske}
translate D DisplayMask {Maske als Zugbaum}
translate D Nag {NAG Code}
translate D Marker {Marker}
translate D Include {Enthalten}
translate D Exclude {Ausgeschlossen}
translate D MainLine {Hauptvariante}
translate D Bookmark {Lesezeichen}
translate D NewLine {Neue Variante}
translate D ToBeVerified {berprfen}
translate D ToTrain {Trainieren}
translate D Dubious {Zweifelhaft}
translate D ToRemove {Entfernen}
translate D NoMarker {Keine Kennzeichen}
translate D ColorMarker {Farbe}
translate D WhiteMark {Wei}
translate D GreenMark {Grn}
translate D YellowMark {Gelb}
translate D BlueMark {Blau}
translate D RedMark {Rot}
translate D CommentMove {Zug kommentieren}
translate D CommentPosition {Position kommentieren}
translate D AddMoveToMaskFirst {Zug zuerst zur Maske hinzufngen}
translate D OpenAMaskFileFirst {Zunchst Maske ffnen}
translate D Positions {Positionen}
translate D Moves {Zge}

# Finder window:
menuText D FinderFile "Datei" 0
menuText D FinderFileSubdirs "mit Unterverzeichnissen" 0
menuText D FinderFileClose "Dateisuche schlieen" 0
menuText D FinderSort "Sortieren" 0
menuText D FinderSortType "Typ" 0
menuText D FinderSortSize "Gre" 0
menuText D FinderSortMod "Modifiziert" 0
menuText D FinderSortName "Namen" 0
menuText D FinderSortPath "Pfad" 0
menuText D FinderTypes "Typen" 0
menuText D FinderTypesScid "Scid-Datenbanken" 0
menuText D FinderTypesOld "Datenbanken im alten Format" 0
menuText D FinderTypesPGN "PGN-Dateien" 0
menuText D FinderTypesEPD "EPD-Dateien" 0
menuText D FinderTypesRep "Repertoire-Dateien" 0
menuText D FinderHelp "Hilfe" 0
menuText D FinderHelpFinder "Hilfe fr Dateisuche" 0
menuText D FinderHelpIndex "Index" 0
translate D FileFinder {Dateisuche}
translate D FinderDir {Verzeichnis}
translate D FinderDirs {Verzeichnisse}
translate D FinderFiles {Dateien}
translate D FinderUpDir {hoch}
translate D FinderCtxOpen {ffnen}
translate D FinderCtxBackup {Sicherungskopie}
translate D FinderCtxCopy {Kopieren}
translate D FinderCtxMove {Verschieben}
translate D FinderCtxDelete {Lschen}

# Player finder:
menuText D PListFile "Datei" 0
menuText D PListFileUpdate "Aktualisieren" 0
menuText D PListFileClose "Spielersuche schlieen" 7
menuText D PListSort "Sortieren" 0
menuText D PListSortName "Name" 0
menuText D PListSortElo "Elo" 0
menuText D PListSortGames "Partien" 0
menuText D PListSortOldest "lteste" 0
menuText D PListSortNewest "Neueste" 0

# Tournament finder:
menuText D TmtFile "Datei" 0
menuText D TmtFileUpdate "Aktualisieren" 0
menuText D TmtFileClose "Turniersuche schlieen" 0
menuText D TmtSort "Sortieren" 0
menuText D TmtSortDate "Datum" 0
menuText D TmtSortPlayers "Spieler" 0
menuText D TmtSortGames "Partien" 0
menuText D TmtSortElo "Elo" 0
menuText D TmtSortSite "Ort" 0
menuText D TmtSortEvent "Turnier" 1
menuText D TmtSortWinner "Gewinner" 0
translate D TmtLimit "Anzeigelimit"
translate D TmtMeanElo "Elo-Durchschnitt"
translate D TmtNone "Keine zutreffenden Turniere gefunden."

# Graph windows:
menuText D GraphFile "Datei" 0
menuText D GraphFileColor "Als Farb-Postscript speichern..." 4
menuText D GraphFileGrey "Als Graustufen-Postscript speichern..." 4
menuText D GraphFileClose "Fenster schlieen" 0
menuText D GraphOptions "Optionen" 0
menuText D GraphOptionsWhite "Wei" 0
menuText D GraphOptionsBlack "Schwarz" 0
menuText D GraphOptionsBoth "Beide" 0
menuText D GraphOptionsPInfo "Spielerinfo Spieler" 1
menuText D GraphOptionsEloFile "Elo von Rating-Datei" 0
menuText D GraphOptionsEloDB "Elo von Datenbank" 0
translate D GraphFilterTitle "Filterdiagramm: Prozentsatz der Spiele, die die Position erreichen"
translate D GraphAbsFilterTitle "Filtergrafik: Hufigkeit der Partien"
translate D GraphWinPctTitle "Filterdiagramm: Gewinn % (1-0 und 0-1) an der aktuellen Position pro Jahr"
translate D ConfigureFilter "X-Achse fr Jahr, Elo und Zge konfigurieren"
translate D FilterEstimate "Schtzen"
translate D TitleFilterGraph "Scid: Filtergrafik"
translate D WinPct "Gewinn %"

# Analysis window:
translate D AddVariation {Variante hinzufgen}
translate D AddAllVariations {Alle Varianten hinzufgen}
translate D AddMove {Zug hinzufgen}
translate D Annotate {Autom. kommentieren}
translate D ShowAnalysisBoard {Analysebrett anzeigen}
translate D ShowInfo {Engine-Information anzeigen}
translate D FinishGame {Partie beenden}
translate D StopEngine {Engine anhalten}
translate D StartEngine {Engine starten}
translate D LockEngine {Anbinden an aktuelle Position}
translate D AnalysisCommand {Analysebefehl}
translate D PreviousChoices {Vorherige Wahl}
translate D AnnotateTime {Zeit pro Zug in Sek.}
translate D AnnotateWhich {Varianten hinzufgen}
translate D AnnotateAll {Fr Zge beider Seiten}
translate D AnnotateAllMoves {Alle Zge kommentieren}
translate D AnnotateWhite {Nur fr Zge von Wei}
translate D AnnotateBlack {Nur fr Zge von Schwarz}
translate D AnnotateBlundersOnly {Wenn der Partiezug ein Fehler ist}
translate D AnnotateBlundersOnlyScoreChange {Analyse berichtet Fehler, Bewertungsnderung von/nach: }
translate D BlundersThreshold {Schwelle}
translate D ScoreAllMoves {Alle Zge bewerten}
translate D LowPriority {Niedrige CPU-Prioritt}
translate D ClickHereToSeeMoves {Hier klicken um Zge anzuzeigen}
translate D ConfigureInformant {Informatorwerte}
translate D Informant!? {Interessanter Zug}
translate D Informant? {Schwacher Zug}
translate D Informant?? {Fehler}
translate D Informant?! {Zweifelhafter Zug}
translate D Informant+= {Wei hat leichten Vorteil}
translate D Informant+/- {Wei hat klaren Vorteil}
translate D Informant+- {Wei hat groen Vorteil}
translate D Informant+-- {Wei hat erdrckenden Vorteil}
translate D AutoComment {Zug Kritik}
translate D AutoCommentTooltip {Generieren Sie einen KI-Kommentar fr die aktuelle Position}
translate D AnalysisAutoCommentTooltip {Generieren Sie KI-Kommentare fr das gesamte Spiel}
translate D GameComment {Partie Kritik}
translate D GameCommentTooltip {Partie nach kommentierten Zgen durchsuchen und KI-Zusammenfassung erstellen}
translate D TimeMs {Zeit (ms)}


# Book window
translate D Book {Buch}
translate D OtherBookMoves {Erffnungsbuch des Gegners}
translate D OtherBookMovesTooltip {Zge, fr die der Gegner eine Antwort kennt}

# Analysis Engine open dialog:
translate D EngineList {Analyse-Engines}
translate D EngineName {Name}
translate D EngineCmd {Befehl}
translate D EngineArgs {Parameter}
translate D EngineDir {Verzeichnis}
translate D EngineElo {Elo}
translate D EngineTime {Datum}
translate D EngineNew {Neu}
translate D EngineEdit {Bearbeiten}
translate D EngineRequired {Fettgedruckte Parameter obligatorisch, andere optional}
translate D EngineProtocol {Kommunikationsprotokoll}
translate D EngineNotation {Notation der Zge}
translate D EngineFlipEvaluation {Bewertungsperspektive umdrehen}
translate D EngineShowLog {Kommunikationsprotokoll anzeigen}
translate D EngineNetworkd {Akzeptieren Sie Remoteverbindungen}
translate D EngineSelect {Whlen Sie die aktuelle Engine aus}
translate D EngineAddLocal {Fgen Sie eine lokale Engine hinzu}
translate D EngineAddRemote {Fgen Sie eine Remote-Engine hinzu}
translate D EngineReload {Laden Sie die aktuelle Engine neu}
translate D EngineClone {Erstellen Sie eine Kopie der aktuellen Engine}
translate D EngineDelete {Lschen Sie die aktuelle Engine}

# PGN window menus:
menuText D PgnFile "Datei" 0
menuText D PgnFileCopy "Kopiere Spiel in Zwischenablage" 0
menuText D PgnFilePrint "Drucken in Datei..." 0
menuText D PgnFileClose "PGN-Fenster schlieen" 0
menuText D PgnOpt "Ausgabe" 0
menuText D PgnOptColor "Farbige Darstellung" 0
menuText D PgnOptShort "Kurzer (3-Zeilen) Vorspann (Header)" 8
menuText D PgnOptSymbols "Symbolische Darstellung" 0
menuText D PgnOptIndentC "Kommentare einrcken" 0
menuText D PgnOptIndentV "Varianten einrcken" 0
menuText D PgnOptColumn "Tabellarisch (ein Zug pro Zeile)" 0
menuText D PgnOptSpace "Leerzeichen nach Zugnummer" 0
menuText D PgnOptStripMarks "Farbfelder-/Pfeile-Zeichen entfernen" 27
menuText D PgnOptBoldMainLine "Partiezge in Fettdruck" 0
menuText D PgnColor "Farben" 0
menuText D PgnColorHeader "Vorspann..." 0
menuText D PgnColorAnno "Anmerkungen..." 0
menuText D PgnColorComments "Kommentare..." 0
menuText D PgnColorVars "Varianten..." 0
menuText D PgnColorBackground "Hintergrund..." 0
menuText D PgnColorMain "Partieverlauf..." 0
menuText D PgnColorCurrent "Hintergrund aktueller Zug..." 1
menuText D PgnHelp "Hilfe" 0
menuText D PgnHelpPgn "PGN-Hilfe" 0
menuText D PgnHelpIndex "Index" 0
translate D PgnWindowTitle {Partienotation - Partie %u}

# Crosstable window menus:
menuText D CrosstabFile "Datei" 0
menuText D CrosstabFileText "Ausgabe in Textdatei..." 11
menuText D CrosstabFileHtml "Ausgabe in HTML-Datei..." 11
menuText D CrosstabFileClose "Turniertabelle schlieen" 0
menuText D CrosstabEdit "Bearbeiten" 0
menuText D CrosstabEditEvent "Ereignis" 0
menuText D CrosstabEditSite "Ort" 0
menuText D CrosstabEditDate "Datum" 0
menuText D CrosstabOpt "Ausgabe" 0
menuText D CrosstabOptAll "Jeder gegen jeden" 0
menuText D CrosstabOptSwiss "Schweizer System" 0
menuText D CrosstabOptKnockout "K.o.-System" 0
menuText D CrosstabOptAuto "Automatisch" 1
menuText D CrosstabOptAges "Alter in Jahren" 0
menuText D CrosstabOptNats "Nationalitt" 0
menuText D CrosstabOptRatings "Elo" 0
menuText D CrosstabOptTitles "Titel" 0
menuText D CrosstabOptBreaks "Stichkampfpunkte" 10
menuText D CrosstabOptDeleted "Inklusive gelschte Partien" 10
menuText D CrosstabOptColors "Farben (nur Schweizer System)" 0
menuText D CrosstabOptColumnNumbers "Numerierte Spalten (Nur jeder-gegen-jeden-Tabelle)" 2
menuText D CrosstabOptGroup "Punktgruppen" 5
menuText D CrosstabSort "Sortieren" 0
menuText D CrosstabSortName "Name" 0
menuText D CrosstabSortRating "Elo" 0
menuText D CrosstabSortScore "Punkte" 0
menuText D CrosstabColor "Farben" 0
menuText D CrosstabColorPlain "Text" 0
menuText D CrosstabColorHyper "Hypertext" 0
menuText D CrosstabHelp "Hilfe" 0
menuText D CrosstabHelpCross "Turniertabelle-Hilfe" 0
menuText D CrosstabHelpIndex "Index" 0
translate D SetFilter {Filter setzen}
translate D AddToFilter {Zum Filter hinzufgen}
translate D Swiss {Schweizer}
translate D Category {Kategorie}

# Opening report window menus:
menuText D OprepFile "Datei" 0
menuText D OprepFileText "Ausgabe in Textdatei..." 11
menuText D OprepFileHtml "Ausgabe in HTML-Datei..." 11
menuText D OprepFileOptions "Optionen..." 0
menuText D OprepFileClose "Berichtsfenster schlieen" 0
menuText D OprepFavorites "Favoriten" 0
menuText D OprepFavoritesAdd "Bericht hinzufgen..." 8
menuText D OprepFavoritesEdit "Favoritenbericht editieren..." 0
menuText D OprepFavoritesGenerate "Berichte erzeugen..." 9
menuText D OprepHelp "Hilfe" 0
menuText D OprepHelpReport "Erffnungsbericht-Hilfe" 0
menuText D OprepHelpIndex "Index" 0

# Header search:
translate D HeaderSearch {Partiedaten suchen}
translate D EndSideToMove {Wer ist beim Partieende am Zug?}
translate D GamesWithNoECO {Partien ohne ECO}
translate D GameLength {Partielnge}
translate D FindGamesWith {Finde Partien mit Kennzeichen}
translate D StdStart {Grundstellung}
translate D Promotions {Umwandlung}
translate D Comments {Kommentare}
translate D Variations {Varianten}
translate D Annotations {Anmerkungen}
translate D DeleteFlag {Lschkennzeichen}
translate D WhiteOpFlag {Erffnung Wei}
translate D BlackOpFlag {Erffnung Schwarz}
translate D MiddlegameFlag {Mittelspiel}
translate D EndgameFlag {Endspiel}
translate D NoveltyFlag {Neuerung}
translate D PawnFlag {Bauernstruktur}
translate D TacticsFlag {Taktik}
translate D QsideFlag {Damenflgel}
translate D KsideFlag {Knigsflgel}
translate D BrilliancyFlag {Glnzend}
translate D BlunderFlag {Grober Fehler}
translate D UserFlag {Benutzer}
translate D PgnContains {PGN enthlt Text}
translate D PgnTag {Etikett}
translate D TagContains {enthlt}
translate D Variant {Variante}
translate D Annotator {Kommentator}
translate D Cmnts {Nur kommentierte Partien}

# Game list window:
translate D GlistNumber {Nummer}
translate D GlistWhite {Wei}
translate D GlistBlack {Schwarz}
translate D GlistWElo {W-Elo}
translate D GlistBElo {S-Elo}
translate D GlistEvent {Turnier}
translate D GlistSite {Ort}
translate D GlistRound {Runde}
translate D GlistDate {Datum}
translate D GlistYear {Jahr}
translate D GlistEDate {Turnierdatum}
translate D GlistResult {Ergebnis}
translate D GlistLength {Lnge}
translate D GlistCountry {Land}
translate D GlistECO {ECO}
translate D GlistOpening {Erffnung}
translate D GlistEndMaterial {Endmaterial}
translate D GlistDeleted {Gelscht}
translate D GlistFlags {Kennzeichen}
translate D GlistVars {Varianten}
translate D GlistComments {Kommentare}
translate D GlistAnnos {Anmerkungen}
translate D GlistStart {Stellung}
translate D GlistGameNumber {Partie Nummer}
translate D GlistAverageElo {ELO Durchschnitt}
translate D GlistRating {Wertungszahl}
translate D GlistFindText {Text finden}
translate D GlistMoveField {Zge}
translate D GlistEditField {Konfigurieren}
translate D GlistAddField {Hinzufgen}
translate D GlistDeleteField {Lschen}
translate D GlistWidth {Breite}
translate D GlistAlign {Ausrichtung}
translate D GlistAlignL {Ausrichtung: links}
translate D GlistAlignR {Ausrichtung: rechts}
translate D GlistAlignC {Ausrichtung: zentriert}
translate D GlistColor {Farbe}
translate D GlistSep {Trennlinie}
translate D GlistCurrentSep {-- Aktuell --}
translate D GlistNewSort {Neu}
translate D GlistAddToSort {Hinzufgen}

# base sorting
translate D GsortSort {Sortieren...}
translate D GsortDate {Datum}
translate D GsortYear {Jahr}
translate D GsortEvent {Event}
translate D GsortSite {Ort}
translate D GsortRound {Runde}
translate D GsortWhiteName {Name Wei}
translate D GsortBlackName {Name Schwarz}
translate D GsortECO {ECO}
translate D GsortResult {Ergebnis}
translate D GsortMoveCount {Zahl der Zge}
translate D GsortAverageElo {Eloschnitt}
translate D GsortCountry {Land}
translate D GsortDeleted {Gelscht}
translate D GsortEventDate {Event Datum}
translate D GsortWhiteElo {ELO Wei}
translate D GsortBlackElo {ELO Schwarz}
translate D GsortComments {Kommentare}
translate D GsortVariations {Varianten}
translate D GsortNAGs {NAGs}
translate D GsortAscending {Aufsteigend}
translate D GsortDescending {Fallend}
translate D GsortAdd {Hinzufgen}
translate D GsortStore {Speichern}
translate D GsortLoad {Laden}

# menu shown with right mouse button down on game list.
translate D GlistRemoveThisGameFromFilter  {Partie aus Filter entfernen}
translate D GlistRemoveGameAndAboveFromFilter  {Partie (und alle oberhalb) aus Filter entfernen}
translate D GlistRemoveGameAndBelowFromFilter  {Partie (und alle darunter) aus Filter entfernen}
translate D GlistDeleteGame {(Ent)Loesche Partie}
translate D GlistDeleteAllGames {Lsche alle Partien im Filter} 
translate D GlistUndeleteAllGames {Alle Partien im Filter wiederherstellen}
translate D GlistMergeGameInBase {Mit Partie in anderer Datebank zusammenfhren} 

# Maintenance window:
translate D DatabaseName {Datenbankname:}
translate D TypeIcon {Symbol:}
translate D NumOfGames {Partien:}
translate D NumDeletedGames {Gelschte Partien:}
translate D NumFilterGames {Partien im Filter:}
translate D YearRange {Jahr-Spanne:}
translate D RatingRange {Elo-Spanne:}
translate D Description {Beschreibung}
translate D Flag {Kennzeichen}
translate D CustomFlags {Benutzerdefinierte Kennzeichen}
translate D DeleteCurrent {Lsche aktuelle Partie}
translate D DeleteFilter {Lsche Partien im Filter}
translate D DeleteAll {Lsche alle Partien}
translate D UndeleteCurrent {Aktuelle Partie wiederherstellen}
translate D UndeleteFilter {Partien im Filter wiederherstellen}
translate D UndeleteAll {Alle Partien wiederherstellen}
translate D DeleteTwins {Lsche Dubletten}
translate D MarkCurrent {Markiere aktuelle Partie}
translate D MarkFilter {Markiere Partien im Filter}
translate D MarkAll {Markiere alle Partien}
translate D UnmarkCurrent {Entmarkiere aktuelle Partie}
translate D UnmarkFilter {Entmarkiere Partien im Filter}
translate D UnmarkAll {Entmarkiere alle Partien}
translate D Spellchecking {Schreibkorrektur}
translate D Players {Spieler}
translate D Events {Ereignis}
translate D Sites {Ort}
translate D Rounds {Runde}
translate D DatabaseOps {Datenbankoperationen}
translate D ReclassifyGames {Partien ECO-klassifizieren}
translate D CompactDatabase {Datenbank komprimieren}
translate D SortDatabase {Datenbank sortieren}
translate D AddEloRatings {ELO-Zahlen hinzufgen}
translate D AutoloadGame {Lade automatisch Partie Nr.}
translate D StripTags {PGN-Kennungen entfernen}
translate D StripTag {Kennungen entfernen}
translate D Cleaner {Bereiniger}
translate D CleanerHelp {
Der Scid-Bereiniger wird fr die aktuelle Datenbank alle Wartungsarbeiten ausfhren, welche aus der unten stehenden Liste ausgewhlt werden.
Aktuelle Einstellungen in den Mens "ECO-Klassifikation" und "Dubletten lschen" werden bei Auswahl dieser Funktionen verwendet.}
translate D CleanerConfirm {
Ist der Bereiniger einmal gestartet, kann er nicht mehr unterbrochen werden!

Dies kann lange dauern, speziell bei groen Datenbanken, abhngig von den
ausgewhlten Funktionen und deren Einstellungen.

Sind Sie sicher, dass Sie die ausgewhlten Wartungsarbeiten starten mchten?
}
# Twinchecker
translate D TwinCheckUndelete { umdrehen; "u" beide wiederherstellen)}
translate D TwinCheckprevPair {Vorheriges Paar}
translate D TwinChecknextPair {Nchstes Paar}
translate D TwinChecker {Scid: Dublettenprfer}
translate D TwinCheckTournament {Partien im Turnier:}
translate D TwinCheckNoTwin {Keine Dublette}
translate D TwinCheckNoTwinfound {Kein Dublette fr diese Partie gefunden.

Um Dubletten anzuzeigen, bitte zuerst die Funktion "Lsche Dubletten" benutzen.}
translate D TwinCheckTag {Nutze Tag...}
translate D TwinCheckFound1 {Scid hat $result Dubletten gefunden}
translate D TwinCheckFound2 { und das Gelscht-Flag gesetzt}
translate D TwinCheckNoDelete {In dieser Datenbank sind keine Partien zu lschen.}
translate D TwinCriteria1 {Ihre Auswahlkriterien der Dublettensuche haben eine hohe Wahrscheinlichkeit auch Partien mit hnlichen Zgen als Dubletten zu erkennen.
}
translate D TwinCriteria2 {Es wird empfohlen, dass bei der Auswahl "Nein" fr "gleiche Zge" die Auswahl "Ja" fr Farbe, Ereignis, Ort, Runde, Jahr und Monat ausgewhlt wird.

Wollen Sie fortsetzen und mit dieser Auswahl die Dubletten lschen? }
translate D TwinCriteria3 {Es wird empfohlen, dass bei der Auswahl "Ja" fr mindestens 2 der Parameter "gleicher Ort", "gleiche Runde" und "gleiches Jahr" gesetzt werden.
    
Wollen Sie fortsetzen und mit dieser Auswahl die Dubletten lschen?}
translate D TwinCriteriaConfirm {Scid: Besttigen der Dublettensuchparameter}
translate D TwinChangeTag "ndern der folgenden Partie-Tags:\n\n"
translate D AllocRatingDescription "Es werden die ELO-Werte aus der Schreibkorrekturdatei den Partien hinzugefgt, wenn der/die Spieler/in keinen aktuellen Wert in der Partie besitzt, aber in der Korrekturdatei ein Wert fr den Zeitraum der Partie vorhanden ist."
translate D RatingOverride "Existierende ELO-Werte berschreiben"
translate D AddRatings "Elo-Werte hinzufgen"
translate D AddedRatings {Scid hat $r Elo-Werte in $g Partien hinzugefgt.}

#Bookmark editor
translate D NewSubmenu "Neues Untermen"

# Comment editor:
translate D AnnotationSymbols  {Kommentarzeichen:}
translate D Comment {Kommentar:}
translate D InsertMark {Markierung einfgen}
translate D InsertMarkHelp {
Markierung einfgen/lschen: Farbe, Typ, Feld whlen.
Pfeil einfgen/lschen: Rechtsklick auf zwei Felder.
}

# Nag buttons in comment editor:
translate D GoodMove {Guter Zug}
translate D PoorMove {Schwacher Zug}
translate D ExcellentMove {Ausgezeichneter Zug}
translate D Blunder {Grober Fehler}
translate D InterestingMove {Interessanter Zug}
translate D DubiousMove {Zweifelhafter Zug}
translate D WhiteDecisiveAdvantage {Wei hat groen Vorteil}
translate D BlackDecisiveAdvantage {Schwarz hat groen Vorteil}
translate D WhiteClearAdvantage {Wei hat klaren Vorteil}
translate D BlackClearAdvantage {Schwarz hat klaren Vorteil}
translate D WhiteSlightAdvantage {Wei hat leichten Vorteil}
translate D BlackSlightAdvantage {Schwarz hat leichten Vorteil}
translate D WhiteCrushing {Wei hat erdrckenden Vorteil}
translate D BlackCrushing {Schwarz hat erdrckenden Vorteil}
translate D Equality {Gleiche Chancen}
translate D Unclear {Unklar}
translate D Diagram {Diagramm}

# Board search:
translate D BoardSearch {Brettsuche}
translate D FilterOperation {Suche im aktuellen Filter:}
translate D FilterAnd {UND\nBeschrnke Filter}
translate D FilterOr {ODER\nZum Filter hinzufgen}
translate D FilterIgnore {IGNORIEREN\nFilter zurcksetzen}
translate D SearchType {Suche nach Typ:}
translate D SearchBoardExact {Exakte Position (alle Steine auf gleichen Feldern)}
translate D SearchBoardPawns {Bauern (gleiche Figuren, alle Bauern auf gleichen Feldern)}
translate D SearchBoardFiles {Linien (gleiches Material, alle Bauern auf gleichen Linien)}
translate D SearchBoardAny {Material (gleiches Material, Bauern und Figuren beliebig)}
translate D SearchInRefDatabase { In folgender Datenbank suchen }
translate D LookInVars {Schaue in Varianten}

# Material search:
translate D MaterialSearch {Materialsuche}
translate D Material {Material}
translate D Patterns {Muster}
translate D Zero {Null}
translate D Any {Irgendeine}
translate D CurrentBoard {Aktuelle Stellung}
translate D CommonEndings {Endspiele}
translate D CommonPatterns {Hufige Muster}
translate D MaterialDiff {Materialdifferenz}
translate D squares {Felder}
translate D SameColor {Gleichfarbige}
translate D OppColor {Ungleichfarbige}
translate D Either {Beides}
translate D MoveNumberRange {Zugnummernbereich}
translate D MatchForAtLeast {Zutreffend fr mindestens}
translate D HalfMoves {Halbzge}

# Common endings in material search:
translate D EndingPawns {Bauernendspiele}
translate D EndingRookVsPawns {Turm gegen Bauer(n)}
translate D EndingRookPawnVsRook {Turm und 1 Bauer gegen Turm}
translate D EndingRookPawnsVsRook {Turm und Bauer(n) gegen Turm}
translate D EndingRooks {Turm gegen Turm}
translate D EndingRooksPassedA {Turm gegen Turm mit Freibauer}
translate D EndingRooksDouble {Doppelturm-Endspiele}
translate D EndingBishops {Lufer gegen Lufer}
translate D EndingBishopVsKnight {Lufer gegen Springer}
translate D EndingKnights {Springer gegen Springer}
translate D EndingQueens {Dame gegen Dame} ;# *** Damenendspiele !?
translate D EndingQueenPawnVsQueen {Dame und 1 Bauer gegen Dame}
translate D BishopPairVsKnightPair {Zwei Lufer gegen zwei Springer im Mittelspiel}

# Common patterns in material search:
translate D PatternWhiteIQP {Weier isolierter Damenbauer}
translate D PatternWhiteIQPBreakE6 {Weier Isolani: Durchbruch d4-d5 gegen e6}
translate D PatternWhiteIQPBreakC6 {Weier Isolani: Durchbruch d4-d5 gegen c6}
translate D PatternBlackIQP {Schwarzer isolierter Damenbauer}
translate D PatternWhiteBlackIQP {Weier gegen schwarzer Damenbauerisolani}
translate D PatternCoupleC3D4 {Isoliertes Bauernpaar c3+d4}
translate D PatternHangingC5D5 {Hngende Bauern c5 und d5 von Schwarz}
translate D PatternMaroczy {Maroczy-Zentrum (mit Bauern auf c4 und e4)}
translate D PatternRookSacC3 {Turmopfer auf c3}
translate D PatternKc1Kg8 {0-0-0 gegen 0-0 (Kc1 gegen Kg8)}
translate D PatternKg1Kc8 {0-0 gegen 0-0-0 (Kg1 gegen Kc8)}
translate D PatternLightFian {Weifeldrige Fianchettos (Lufer g2 gegen Lufer b7)}
translate D PatternDarkFian {Schwarzfeldrige Fianchettos (Lufer b2 gegen Lufer g7)}
translate D PatternFourFian {Beiderseitiges Doppelfianchetto (Lufer auf b2,g2,b7,g7)}

# Game saving:
translate D Today {Heute}
translate D ClassifyGame {Partie klassifizieren}

# Setup position:
translate D EmptyBoard {Brett leeren}
translate D InitialBoard {Initialisiere Brett}
translate D SideToMove {Zugrecht}
translate D MoveNumber {Zugnummer}
translate D Castling {Rochade}
translate D EnPassantFile {EnPassant-Linie}
translate D ClearFen {FEN lschen}
translate D PasteFen {FEN einfgen}

translate D SaveAndContinue {Speichern und weiter}
translate D DiscardChangesAndContinue {Verwerfen und weiter}
translate D GoBack {Zurck}

# Replace move dialog:
translate D ReplaceMove {Zug ersetzen}
translate D AddNewVar {Neue Variante}
translate D NewMainLine {Neue Hauptvariante}
translate D ReplaceMoveMessage {Hier existiert bereits ein Zug.

Sie knnen diesen Zug ersetzen - unter Verlust aller nachfolgender Zge - oder mit dem Zug eine neue Variante hinzufgen.

(Sie knnen diese Anzeige vermeiden, indem Sie die Option "Fragen vor Ersetzen" im Men Optionen:Zge deaktivieren)}

# Make database read-only dialog:
translate D ReadOnlyDialog {Wenn Sie diese Datenbank mit Schreibschutz
versehen, sind keine nderungen mglich. Es knnen keine Partien gespeichert
oder ersetzt und keine Lschkennzeichen gendert werden. Alle Sortierungen oder
ECO-Klassifikationsergebnisse sind nur temporr.

Sie knnen den Schreibschutz einfach entfernen, indem Sie die Datenbank
schlieen und wieder ffnen.
Wollen Sie diese Datenbank wirklich schreibschtzen?}

# Clear game dialog:
translate D ClearGameDialog {Diese Partie wurde gendert.

Wollen Sie wirklich fortsetzen und die nderungen verwerfen?
}

# Exit dialog:
translate D ExitDialog {Mchten Sie Scid beenden?}
translate D ExitUnsaved {Die folgenden Datenbanken haben ungesicherte Partienderungen. Wenn Sie jetzt beenden, gehen diese nderungen verloren.}

# Import window:
translate D PasteCurrentGame {Aktuelle Partie einfgen}
translate D ImportHelp1 {Eingeben oder Einfgen einer Partie im PGN-Format in den oberen Rahmen.}
translate D ImportHelp2 {Hier werden Fehler beim Importieren angezeigt.}
translate D OverwriteExistingMoves {Bestehende Zge berschreiben?}

# ECO Browser:
translate D ECOAllSections {alle ECO-Gruppen}
translate D ECOSection {ECO-Gruppe}
translate D ECOSummary {Zusammenfassung fr}
translate D ECOFrequency {Hufigkeit der Untercodes fr}

# Opening Report:
translate D OprepReportFor {Bericht fr}
translate D OprepTitle {Erffnungsbericht}
translate D OprepReport {Bericht}
translate D OprepGenerated {Erzeugt durch}
translate D OprepStatsHist {Statistiken und Geschichte}
translate D OprepStats {Statistiken}
translate D OprepStatAll {Alle Berichtspartien}
translate D OprepStatBoth {Beide Spieler}
translate D OprepStatSince {Nach}
translate D OprepOldest {lteste Partien}
translate D OprepNewest {Neuste Partien}
translate D OprepPopular {Popularitt}
translate D OprepFreqAll {Hufigkeit in allen Jahren: }
translate D OprepFreq1   {im letzten Jahr:            }
translate D OprepFreq5   {der letzten  5 Jahre:       }
translate D OprepFreq10  {der letzten 10 Jahre:       }
translate D OprepEvery {Eine pro %u Partien}
translate D OprepUp {mehr als %u%s von allen Jahren}
translate D OprepDown {weniger als %u%s von allen Jahren}
translate D OprepSame {keine nderung in allen Jahren}
translate D OprepMostFrequent {Hufigste Spieler}
translate D OprepMostFrequentOpponents {Hufigste Gegner}
translate D OprepRatingsPerf {ELO und Performance}
translate D OprepAvgPerf {Durchschnitts-ELO und Performance}
translate D OprepWRating {ELO Wei}
translate D OprepBRating {ELO Schwarz}
translate D OprepWPerf {Performance Wei}
translate D OprepBPerf {Performance Schwarz}
translate D OprepHighRating {Spiele mit hchstem ELO-Durchschnitt}
translate D OprepTrends {Ergebnistrend}
translate D OprepResults {Ergebnis nach Lngen und Hufigkeiten}
translate D OprepLength {Partielnge}
translate D OprepFrequency {Hufigkeit}
translate D OprepWWins {Weisiege:    }
translate D OprepBWins {Schwarzsiege: }
translate D OprepDraws {Remis:        }
translate D OprepWholeDB {ganze Datenbank}
translate D OprepShortest {Krzester Sieg}
translate D OprepMovesThemes {Zge und Themen}
translate D OprepMoveOrders {Zugfolgen zum Erreichen\nder Berichtsposition}
translate D OprepMoveOrdersOne \
  {Es gab nur eine Zugfolge zur erreichten Position:}
translate D OprepMoveOrdersAll \
  {Es gab %u Zugfolgen zur erreichten Position:}
translate D OprepMoveOrdersMany \
  {Es gab  %u Zugfolgen zur erreichten Position. Die ersten %u sind:}
translate D OprepMovesFrom {Zge ab der Berichtsposition}
translate D OprepMostFrequentEcoCodes {Hufigste ECO-Codes}
translate D OprepThemes {Themen}
translate D OprepThemeDescription {Hufigkeit der Themen in den ersten %u Zgen jeder Partie}
translate D OprepThemeSameCastling {Gleichseitige Rochaden}
translate D OprepThemeOppCastling {Verschiedenseitige Rochaden}
translate D OprepThemeNoCastling {Beide Seiten unrochiert}
translate D OprepThemeKPawnStorm {Bauernsturm auf Knig}
translate D OprepThemeQueenswap {Damen getauscht}
translate D OprepThemeWIQP {Weier isolierter Damenbauer}
translate D OprepThemeBIQP {Schwarzer isolierter Damenbauer}
translate D OprepThemeWP567 {Weier Bauer auf Reihe 5/6/7}
translate D OprepThemeBP234 {Schwarzer Bauer auf Reihe 2/3/4}
translate D OprepThemeOpenCDE {Offene c/d/e-Linie}
translate D OprepTheme1BishopPair {Eine Seite hat Luferpaar}
translate D OprepEndgames {Endspiele}
translate D OprepReportGames {Berichtspartien}
translate D OprepAllGames {Alle Partien}
translate D OprepEndClass {Materialklassifikation von Endspielstellungen}
translate D OprepTheoryTable {Theorietabelle}
translate D OprepTableComment {Erzeugt aus %u Partien mit hchster ELO-Zahl.}
translate D OprepExtraMoves {Zustzliche Zge in der Theorietabelle}
translate D OprepMaxGames {Maximale Partien in der Theorietabelle}
translate D OprepMergeMoves {Bewegungslimit fr zusammengefhrte Spiele}
translate D OprepMergeUnique {Fhren Sie nur einzigartige Spiele zusammen}
translate D OprepViewHTML {Zeige HTML}

# Player Report:
translate D PReportTitle {Spielerbericht}
translate D PReportColorWhite {mit den weien Steinen}
translate D PReportColorBlack {mit den schwarzen Steinen}
translate D PReportMoves {nach %s}
translate D PReportOpenings {Erffnungen}
translate D PReportClipbase {Leere Zwischenablage und kopiere gefundene Spiele}

# Piece Tracker window:
translate D TrackerSelectSingle {Linke Maustaste whlt diese Figur.}
translate D TrackerSelectPair \
  {Linke Maustaste whlt diese Figur; rechte Maustaste whlt das Figurenpaar.}
translate D TrackerSelectPawn \
  {Linke Maustaste whlt diesen Bauern; rechte Maustaste whlt alle 8 Bauern.}
translate D TrackerStat {Statistik}
translate D TrackerGames {% der Partien mit Zug auf das Feld}
translate D TrackerTime {% der Zeit auf jedem Feld}
translate D TrackerMoves {Zge}
translate D TrackerMovesStart \
  {Zugnummer, ab der die Verteilungsberechnung beginnen soll.}
translate D TrackerMovesStop \
  {Zugnummer, wo die Verteilungsberechnung enden soll.}

# Game selection dialogs:
translate D SelectAllGames {Alle Partien in der Datenbank}
translate D SelectFilterGames {Nur Partien im Filter}
translate D SelectTournamentGames {Nur Partien des aktuellen Turniers}
translate D SelectOlderGames {Nur ltere Partien}

# Delete Twins window:
translate D TwinsNote {Damit zwei Spiele Dubletten sind, mssen diese mindestens die beiden selben Spieler haben und die folgenden Kriterien, die Sie auswhlen knnen, erfllen. Wenn zwei Dubletten gefunden werden, so wird die krzere der beiden Spiele gelscht. Tip: am besten fhrt man erst eine Schreibkorrektur durch, da dadurch das Finden von Dubletten verbessert wird.}
translate D TwinsCriteria {Kriterium: Dubletten mssen haben ...}
translate D TwinsWhich {berprfe Partien}
translate D TwinsColors {gleiche Spielerfarbe}
translate D TwinsEvent {gleiches Ereignis}
translate D TwinsSite {gleichen Ort}
translate D TwinsRound {gleiche Runde}
translate D TwinsYear {gleiches Jahr}
translate D TwinsMonth {gleichen Monat}
translate D TwinsDay {gleichen Tag}
translate D TwinsResult {gleiches Ergebnis}
translate D TwinsECO {gleichen ECO-Code}
translate D TwinsMoves {gleiche Zge}
translate D TwinsPlayers {Vergleiche Spielernamen}
translate D TwinsPlayersExact {Exakte Treffer}
translate D TwinsPlayersPrefix {Nur erste 4 Buchstaben}
translate D TwinsWhen {Beim Lschen der Dubletten}
translate D TwinsSkipShort {Partien unter 5 Zgen ignorieren}
translate D TwinsUndelete {Zuerst alle Partien entlschen}
translate D TwinsSetFilter {Filter auf Dubletten setzen}
translate D TwinsComments {Spiele mit Kommentar immer behalten}
translate D TwinsVars {Spiele mit Varianten immer behalten}
translate D TwinsDeleteWhich {Lsche Partie}
translate D TwinsDeleteShorter {Krzere Partie}
translate D TwinsDeleteOlder {Kleinere Partienummer}
translate D TwinsDeleteNewer {Grere Partienummer}
translate D TwinsDelete {Lsche Spiele}

# Name editor window:
translate D NameEditType {Namen ndern von}
translate D NameEditSelect {Welche Spiele sollen gendert werden?}
translate D NameEditReplace {Ersetze}
translate D NameEditWith {durch}
translate D NameEditMatches {Vorschlag mit Strg+1 - Strg+9 auswhlen}

# Check games window:
translate D CheckGames {Konsistenzprfung}
translate D CheckGamesWhich {Konsistenzprfung}
translate D CheckAll {Alle Partien}
translate D CheckSelectFilterGames {Partien im Filter}

# Classify window:
translate D Classify {Klassifiziere}
translate D ClassifyWhich {Partien ECO-klassifizieren}
translate D ClassifyAll {Alle Spiele (berschreibe alte ECO-Codes)}
translate D ClassifyYear {Alle Spiele  aus dem letzten Jahr}
translate D ClassifyMonth {Alle Spiele aus dem letzten Monat}
translate D ClassifyNew {Nur Spiele ohne ECO-Code}
translate D ClassifyCodes {ECO-Codes verwenden}
translate D ClassifyBasic {Standard Codes ("B12", ...)}
translate D ClassifyExtended {mit Scid-Erweiterung ("B12j", ...)}
translate D ClassifyResult {ECO-Klassifizierung abgeschlossen: $result-Spiel(e) aktualisiert.}

# Compaction:
translate D NameFile {Namendatenbank}
translate D GameFile {Partiendatenbank}
translate D Names {Namen}
translate D Unused {Unbenutzt}
translate D SizeKb {Gre (kB)}
translate D CurrentState {Momentaner Stand}
translate D AfterCompaction {nach Kompression}
translate D CompactNames {Komprimiere Namen}
translate D CompactGames {Komprimiere Partien}
translate D NoUnusedNames "Es gibt keine unbenutzen Namen, die Namensdatei ist vollstndig komprimiert."
translate D NoUnusedGames "Die Partiedatei ist vollstndig komprimiert."
translate D GameFileCompacted {Die Partiedatei der Datenbank wurde komprimiert.}

# Sorting:
translate D SortCriteria {Kriterium}
translate D AddCriteria {Fge Sortierkriterium hinzu}
translate D CommonSorts {bliche Sortierkriterien}
translate D Sort {Sortiere}

# Exporting:
translate D AddToExistingFile {Anhngen an eine bestehende Datei}
translate D ExportComments {Kommentare exportieren}
translate D ExportVariations {Varianten exportieren}
translate D IndentComments {Kommentare einrcken}
translate D IndentVariations {Varianten einrcken}
translate D ExportColumnStyle {Tabellarisch: ein Zug pro Zeile}
translate D ExportSymbolStyle {Symbolische Notation }
translate D ExportStripMarks \
  {Felder-/Pfeilemarkierzeichen\naus den Kommentaren entfernen}

# Goto game/move dialogs:
translate D LoadGameNumber {Geben Sie die zu ladende Spielnr. ein:}
translate D GotoMoveNumber {Gehe zu Zugnr.:}

# Copy games dialog:
translate D CopyAllGames {Kopiere alle Spiele nach}
translate D CopyGames {Kopiere Spiele}
translate D CopyConfirm {
 Mchten sie wirklich die [::utils::thousands $nGamesToCopy]
 Spiele aus dem Filter
 in der Datenbank "$fromName"
 in die Datenbank "$targetName"
 kopieren?
}
translate D CopyErr {Kann Spiele nicht kopieren}
translate D CopyErrSource {Die Quelldatenbank}
translate D CopyErrTarget {Die Zieldatenbank}
translate D CopyErrNoGames {hat keine Spiele im Filter}
translate D CopyErrReadOnly {ist schreibgeschtzt}
translate D CopyErrNotOpen {ist nicht geffnet}

# Colors:
translate D LightSquares {Helle Felder}
translate D DarkSquares {Dunkle Felder}
translate D SelectedSquares {Ausgewhlte Felder}
translate D SuggestedSquares {Zugvorschlagsfelder}
translate D WhitePieces {Weie Steine}
translate D BlackPieces {Schwarze Steine}
translate D WhiteBorder {Weie Umrandung}
translate D BlackBorder {Schwarze Umrandung}

# Novelty window:
translate D FindNovelty {Finde Neuerung}
translate D Novelty {Neuerung}
translate D NoveltyInterrupt {Neuerungensuche abgebrochen}
translate D NoveltyNone {In dieser Partie wurde keine Neuerung gefunden}
translate D NoveltyHelp {Scid wird den ersten Zug aus der aktuellen Partie finden, welcher zu einer Position fhrt, die nicht in der gewhlten Datenbank oder in dem ECO-Erffnungsbuch enthalten ist.}

# Sounds configuration:
translate D SoundsFolder {Verzeichnis fr Sprachausgabedateien}
translate D SoundsFolderHelp {Das Verzeichnis sollte enthalten: King.wav, a.wav, 1.wav etc.}
translate D SoundsAnnounceOptions {Optionen fr Zugankndigung}
translate D SoundsAnnounceNew {Kndige neue Zge an, wenn sie ausgefhrt werden}
translate D SoundsMoveSoundOnly {Nur Ton bewegen (Ansagen deaktivieren)}
translate D SoundsAnnounceForward {Knde Zug an beim Vorwrtspielen}
translate D SoundsAnnounceBack {Kndige Zug an beim Zurckgehen}
translate D SoundsSoundDisabled {Scid hat das Snack Audio Paket beim Start nicht gefunden.\nTon ist abgeschaltet.}

# Upgrading databases:
translate D Upgrading {Upgrading}
translate D ConfirmOpenNew {
Dies ist eine Datenbank im alten (Scid 3.x) Format, die nicht in Scid 4.x
geffnet werden kann. Aber eine Version im neuen Format wurde schon erstellt.

Wollen Sie die Version der Datenbank im neuen Format ffnen?
}
translate D ConfirmUpgrade {
Dies ist eine Datenbank im alten (Scid 3.x) Format. Vor der Verwendung in
Scid 4 mu eine Version im neuen Format der Datenbank erstellt werden.

Beim Erstellen der neuen Version der Datenbank bleiben die Dateien der alten Version erhalten.

Dieser Vorgang kann eine Zeitlang dauern, mu aber nur einmal durchgefhrt
werden. Sie knnen jederzeit abbrechen, wenn es Ihnen zu lange dauert.

Soll das Erstellen der Datenbank im neuen Format jetzt durchgefhrt werden?
}

# Recent files options:
translate D RecentFilesMenu {Anzahl letzter Dateien im Dateimen}
translate D RecentFilesExtra {Anzahl letzter Dateien im Untermen}

# My Player Names options:
translate D MyPlayerNamesDescription {
Geben Sie unten eine Liste der bevorzugten Spielernamen ein, ein Name pro Zeile. Platzhalterzeichen (z.B. "?" fr ein beliebiges einzelnes Zeichen, "*" fr jede beliebige Folge von Zeichen) sind erlaubt.

Jedesmal, wenn ein Spiel mit einem aufgelisteten Spielernamen geladen wird, wird das Schachbrett im Hauptfenster erforderlichenfalls gedreht, um das Spiel aus der Sicht des betreffenden Spielers zu zeigen.
}

#Coach
translate D showblunderexists {Enginefehler anzeigen}
translate D showblundervalue {Fehlerbewertung anzeigen}
translate D showscore {Bewertung anzeigen}
translate D coachgame {Coach Partie}
translate D configurecoachgame {Trainingspartie konfigurieren}
translate D configuregame {Spiel konfigurieren}
translate D Phalanxengine {Phalanx engine}
translate D Coachengine {Coach Engine}
translate D difficulty {Schwierigkeit}
translate D hard {schwer}
translate D easy {leicht}
translate D Playwith {Spiel mit}
translate D white {Wei}
translate D black {Schwarz}
translate D both {beide}
translate D Play {Spielen}
translate D Noblunder {Kein Fehler}
translate D blunder {Fehler}
translate D Noinfo {-- Keine Info --}
translate D PhalanxOrTogaMissing {Phalanx oder Toga nicht gefunden!}
translate D moveblunderthreshold {fehlerhafter Zug, wenn Verlust grer als}
translate D limitanalysis {Analysezeit der Engine begrenzen}
translate D seconds {Sekunden}
translate D Abort {Abbrechen}
translate D Resume {Fortfahren}
translate D OutOfOpening {Ende der Erffnung}
translate D NotFollowedLine {You did not follow the line}
translate D DoYouWantContinue {Mchten sie fortfahren?}
translate D CoachIsWatching {Coach schaut zu}
translate D Ponder {Berechnen im Hintergrund}
translate D LimitELO {Strke begrenzen (ELO)}
translate D DubiousMovePlayedTakeBack {Zweifelhafter Zug gespielt, wollen Sie ihn zurcknehmen?}
translate D WeakMovePlayedTakeBack {Dies ist kein guter Zug, wollen Sie ihn zurcknehmen?}
translate D BadMovePlayedTakeBack {Dies ist ein schlechter Zug, wollen Sie ihn zurcknehmen?}
translate D Iresign {Ich gebe auf}
translate D yourmoveisnotgood {Ihr Zug ist nicht gut}
translate D EndOfVar {Variantenende}
translate D Openingtrainer {Erffnungstrainer}
translate D DisplayCM {Kandidatenzge anzeigen}
translate D DisplayCMValue {Wert der Kandidatenzge anzeigen}
translate D DisplayOpeningStats {Statistik anzeigen}
translate D ShowReport {Bericht anzeigen}
translate D NumberOfGoodMovesPlayed {gute Zge gespielt}
translate D NumberOfDubiousMovesPlayed {zweischneidige Zge gespielt}
translate D NumberOfMovesPlayedNotInRepertoire {Zge auerhalb des Repertoirs gespielt}
translate D NumberOfTimesPositionEncountered {Wiederholungen der Position}
translate D PlayerBestMove  {Nur beste Zge erlauben}
translate D OpponentBestMove {Gegner spielt besten Zug}
translate D OnlyFlaggedLines {Nur markierte Linien}
translate D resetStats {Statistik zurcksetzen}
translate D Repertoiretrainingconfiguration {Konfiguration Trainingsrepertoire}
translate D Loadingrepertoire {Lade Repertoire}
translate D Movesloaded {Zge geladen}
translate D Repertoirenotfound {Repertoire nicht gefunden}
translate D Openfirstrepertoirewithtype {Zuerst eine Erffnungsdatenbank mit entsprechendem Type/Icon ffnen.}
translate D Movenotinrepertoire {Zug nicht im Repertoire}
translate D PositionsInRepertoire {Positionen im Repertoire}
translate D PositionsNotPlayed {nicht gespielte Positionen}
translate D PositionsPlayed {gespielte Positionen}
translate D Success {Erfolgreich}
translate D DubiousMoves {Zweifelhafte Zge}
translate D OutOfRepertoire {Nicht im Repertoire}
translate D ConfigureTactics {Taktik konfigurieren}
translate D ResetScores {"Gelst" zurcksetzten}
translate D LoadingBase {Lade Datenbank}
translate D Tactics {Taktik}
translate D ShowSolution {Lsung zeigen}
translate D NextExercise {Nchste Aufgabe}
translate D PrevExercise {Vorherige Aufgabe}
translate D StopTraining {Training beenden}
translate D Next {Nchste}
translate D ResettingScore {"Gelst" zurcksetzen}
translate D LoadingGame {Lade Partie}
translate D MateFound {Matt gefunden}
translate D BestSolutionNotFound {Beste Lsung NICHT gefunden!}
translate D MateNotFound {Matt nicht gefunden}
translate D ShorterMateExists {Krzeres Matt existiert}
translate D ScorePlayed {Bewertung gepielt}
translate D Expected {erwarted}
translate D ChooseTrainingBase {Trainingsdatenbank auswhlen}
translate D Thinking {Denke...}
translate D AnalyzeDone {Analyse beendet}
translate D WinWonGame {Gewinne gewonnene Partie}
translate D Lines {Variantenzahl}
translate D ConfigureUCIengine {UCI Engine konfigurieren}
translate D SpecificOpening {Ausgewhlte Erffnung}
translate D StartNewGame {Neue Partie}
translate D FixedLevel {Feste Strke}
translate D Opening {Erffnung}
translate D RandomLevel {Zufallsstrke}
translate D StartFromCurrentPosition {Von aktueller Position starten}
translate D FixedDepth {Feste Tiefe}
translate D Nodes {Knoten} 
translate D Depth {Tiefe}
translate D Time {Zeit} 
translate D SecondsPerMove {Sekunden pro Zug}
translate D Engine {Engine}
translate D TimeMode {Zeitmodus}
translate D TimeBonus {Zeit+\nBonus}
translate D TimeMin {min}
translate D TimeSec {s}
translate D AllExercisesDone {Alle bungen gemacht}
translate D MoveOutOfBook {Zug nicht mehr im Buch}
translate D LastBookMove {Letzter Buchzug}
translate D AnnotateSeveralGames {Von aktueller Partie bis Partie:}
translate D FindOpeningErrors {Erffnungsfehler finden}
translate D MarkTacticalExercises {Taktische bungen markieren}
translate D UseBook {Buch benutzen}
translate D MultiPV {Multivariantenmodus}
translate D Hash {Hash Speicher}
translate D OwnBook {Engine Buch verwenden}
translate D BookFile {Erffnungsbuch}
translate D AnnotateVariations {Varianten kommentieren}
translate D ShortAnnotations {Kurze Kommentare}
translate D addAnnotatorTag {Kommentar Tag hinzufgen}
translate D AddScoreToShortAnnotations {Bewertung hinzufgen}
translate D Export {Export}
translate D BookPartiallyLoaded {Buch teilweise geladen}
translate D Calvar {Training: Variantenberechnung}
translate D ConfigureCalvar {Konfiguration}
# Opening names used in tacgame.tcl
translate D Reti {Reti}
translate D English {Englische Erffnung}
translate D d4Nf6Miscellaneous {1.d4 Nf6 Verschiedene}
translate D Trompowsky {Trompowsky}
translate D Budapest {Budapest}
translate D OldIndian {Altindische Verteidigung}
translate D BenkoGambit {Benko Gambit}
translate D ModernBenoni {Moderne/Benoni-Verteidigung}
translate D DutchDefence {Hollndische Verteidigung}
translate D Scandinavian {Skandinavische Verteidigung}
translate D AlekhineDefence {Aljechin Verteidigung}
translate D Pirc {Pirc-Verteidigung}
translate D CaroKann {Caro-Kann}
translate D CaroKannAdvance {Caro-Kann Vorstovariante}
translate D Sicilian {Sizilianisch}
translate D SicilianAlapin {Sizilianisch, Alapin Variante}
translate D SicilianClosed {Geschlossene Sizilianische Verteidigung}
translate D SicilianRauzer {Sizilianisch, Rauzer Angriff}
translate D SicilianDragon {Sizilianisch, Drachenvariante}
translate D SicilianScheveningen {Sizilianisch, Scheveningen}
translate D SicilianNajdorf {Sizilianisch, Najdorf}
translate D OpenGame {Offene Spiele}
translate D Vienna {Wiener Verteidigung}
translate D KingsGambit {Knigsgambit}
translate D RussianGame {Russische Verteidigung}
translate D ItalianTwoKnights {Italienische Erffnung}
translate D Spanish {Spanisch Partie}
translate D SpanishExchange {Spanisch, Abtauschvariante}
translate D SpanishOpen {Spanisch, offene Systeme}
translate D SpanishClosed {Spanisch, geschlossene Systeme}
translate D FrenchDefence {Franzsische Verteidigung}
translate D FrenchAdvance {Franzsisch, Vorstovariante}
translate D FrenchTarrasch {Franzsisch, Tarrasch}
translate D FrenchWinawer {Franzsisch, Winawer}
translate D FrenchExchange {Franzsisch, Abtauschvariante}
translate D QueensPawn {Damenbauernspiel}
translate D Slav {Slavisch}
translate D QGA {Angenommenes Damengambit}
translate D QGD {Abgelehntes Damengambit}
translate D QGDExchange {Abgelehntes Damengambit, Abtauschvariante}
translate D SemiSlav {Semi-Slawisch}
translate D QGDwithBg5 {Abgelehntes Damengambit mit Lg5}
translate D QGDOrthodox {Abgelehntes Damengambit, Orthodoxe Variante}
translate D Grunfeld {Grnfeld-Verteidigung}
translate D GrunfeldExchange {Grnfeld, Abtauschvariante}
translate D GrunfeldRussian {Grnfeld-Verteidigung, Russische Variante}
translate D Catalan {Katalanische Verteidigung}
translate D CatalanOpen {Katalanisch, offen}
translate D CatalanClosed {Katalanisch, geschlossen}
translate D QueensIndian {Dameninsche Verteidigung}
translate D NimzoIndian {Nimzoindische Verteidigung}
translate D NimzoIndianClassical {Nimzoindisch, Klassische Variante}
translate D NimzoIndianRubinstein {Nimzoinsisch, Rubinstein}
translate D KingsIndian {Knigsindische Verteidigung}
translate D KingsIndianSamisch {Knigsindisch, Smisch}
translate D KingsIndianMainLine {Knigsindisch, Hauptvariante}

# FICS
translate D ConfigureFics {FICS Konfigurieren}
translate D FICSGuest {Gastlogin}
translate D FICSServerPort {Serverport}
translate D FICSServerAddress {IP Adresse}
translate D FICSRefresh {Aktualisieren}
translate D FICSTimesealPort {Timeseal Port}
translate D FICSSilence {Konsolenfilter}
translate D FICSOffers {Herausforderungen}
translate D FICSConsole {Konsole}
translate D FICSGames {laufende Partien}
translate D FICSUnobserve {Beobachtung abbrechen}
translate D FICSProfile {Eigenes Profil ausgeben}
translate D FICSRelayedGames {bertragene Partien}
translate D FICSFindOpponent {Gegner suchen}
translate D FICSTakeback {Zurcknehmen}
translate D FICSTakeback2 {2 zurcknehmen}
translate D FICSInitTime {Zeit (min)}
translate D FICSIncrement {Inkrement (s)}
translate D FICSRatedGame {Wertungspartie}
translate D FICSAutoColour {automatisch}
translate D FICSManualConfirm {manuell besttigen}
translate D FICSFilterFormula {Filterformel anwenden}
translate D FICSIssueSeek {Partie anbieten}
translate D FICSChallenge {Herausfordern}
translate D FICSAccept {Nehmen Sie an?}
translate D FICSDecline {Ablehnen}
translate D FICSColour {Farbe auswhlen}
translate D FICSSend {senden}
translate D FICSConnect {Verbinden}
translate D FICSdefaultuservars {Standardvariablen verwenden}
translate D FICSObserveconfirm {Besttige Beobachtung der Partie}
translate D FICSpremove {Premoves aktivieren}
translate D FICSObserve {Beobachten}
translate D FICSRatedGames {Bewertete Partien}
translate D FICSUnratedGames {Unbewertete Partien}
translate D FICSRated {Bewertet}
translate D FICSUnrated {Unbewertet}
translate D FICSRegisteredPlayer {Nur registrierte Spieler}
translate D FICSFreePlayer {Nur freie Spieler}
translate D FICSNetError {Netzwerkfehler\nKeine Verbindung zu }

# Game review
translate D GameReview {Partieanalyse}
translate D GameReviewTimeExtended {Lange Bedenkzeit}
translate D GameReviewMargin {Fehlergrenze}
translate D GameReviewAutoContinue {Bei korrektem Zug automatisch weiter}
translate D GameReviewReCalculate {Verwende lange Bedenkzeit}
translate D GameReviewAnalyzingMovePlayedDuringTheGame {Analysiere den Partiezug}
translate D GameReviewAnalyzingThePosition {Analysiere Stellung}
translate D GameReviewEnterYourMove {Zug eingeben}
translate D GameReviewCheckingYourMove {berprfe Antwort}
translate D GameReviewYourMoveWasAnalyzed {Antwort wurde analysiert}
translate D GameReviewYouPlayedSameMove {Gleicher Zug wie in der Partie}
translate D GameReviewScoreOfYourMove {BeWertung des Antwortzuges}
translate D GameReviewGameMoveScore {Bewertung des Partiezuges}
translate D GameReviewEngineScore {Bewertung der Engine}
translate D GameReviewYouPlayedLikeTheEngine {Gleicher Zug wie die Engine}
translate D GameReviewNotEngineMoveButGoodMove {Auch ein guter Zug}
translate D GameReviewMoveNotGood {Der Zug ist nicht gut}
translate D GameReviewMovesPlayedLike {Zge gespielt wie}
translate D GameReviewMovesPlayedEngine {Zge gespielt wie die Engine}

# Correspondence Chess Dialogs:
translate D CCDlgCGeneraloptions {Allgemeine Einstellungen}
translate D CCDlgLoginName  {Login Name:}
translate D CCDlgPassword   {Passwort:}
translate D CCDlgShowPassword {Passwort anzeigen}

# Connect Hardware dialogs
translate D ExtHWConfigConnection {Hardware Konfigurieren}
translate D ExtHWPort {Schnittstelle}
translate D ExtHWEngineCmd {Engine Kommando}
translate D ExtHWEngineParam {Engine Parameter}
translate D ExtHWShowButton {Knopf in Werkzeugleiste anzeigen}
translate D ExtHWHardware {Hardware}
translate D ExtHWNovag {Novag Citrine}
translate D ExtHWInputEngine {Input Engine}
translate D ExtHWNoBoard {Kein Brett verbunden}
translate D NovagReferee {Nur Zge aufzeichnen}

# Input Engine dialogs
translate D IEConsole {Input Engine Konsole}
translate D IESending {Sende Zge fr}
translate D IESynchronise {Synchronisieren}
translate D IERotate  {Brett drehen}
translate D IEUnableToStart {Input Engine konnte nicht gestartet werden:}

# Calculation of Variations
translate D DoneWithPosition {Positionsbearbeitung beendet}

translate D Board {Brett}
translate D showGameInfo {Partieinformation anzeigen}
translate D autoResizeBoard {Brettgre automatisch berechnen}
translate D DockTop {Nach oben}
translate D DockBottom {Nach unten}
translate D DockLeft {Nach links}
translate D DockRight {Nach rechts}
translate D Undock {Fenster lsen}

# Switcher window
translate D AboutDatabase {ber diese Datenbank}
translate D ChangeIcon {Datenbank Icon ndern...}
translate D NewGameListWindow {Neue Partieliste}
translate D LoadatStartup {Beim Starten laden}

# Gamelist window
translate D ShowHideDB {Datenbank anzeigen/verbergen}
translate D ChangeFilter {Filter ndern}
translate D ChangeLayout {Sortierkriterien und Spaltenlayout laden/speichern/ndern }
translate D ShowHideStatistic {Statistik anzeigen/verbergen}
translate D BoardFilter {Nur Partien, die gleich der aktuellen Brettstellung sind, anzeigen}
translate D CopyGameTo {Kopiere Partie nach}
translate D FindBar {Suchleiste}
translate D FindCurrentGame {Aktuelle Partie finden}
translate D DeleteGame {Partie lschen}
translate D UndeleteGame {Partie wiederherstellen}
translate D ResetSort {Sortierung zurcksetzten}

translate D ConvertNullMove {Null-Zge in Kommentare umwandeln}
translate D SetupBoard {Stellung eingeben}
translate D Rotate {Drehen}
translate D SwitchColors {Farbe wechseln}
translate D FlipBoard {Brett drehen}
translate D ImportPGN {Importiere PGN Partieen}
translate D ImportingFiles {Importiere PGN Dateien nach}
translate D ImportingFrom {Importiere von}
translate D ImportingIn {Importiere Partien nach}
translate D UseLastTag {Letzte Tags\nverwenden}
translate D Random {Zufllig}
translate D BackToMainline {Zurck zur Hauptvariante}
translate D LeaveVariant {Variante verlassen}
translate D Autoplay {Vorspielen}
translate D ShowHideCoords {Beschriftung ein/aus}
translate D ShowHideEvalBar {Bewertungsleiste ein-/ausblenden}
translate D ShowHideMaterial {Material ein/aus}
translate D SelectMarker {Whlen Sie Markierung aus}
translate D FullScreen {Vollbild}
translate D FilterStatistic {Filter Statistik}
translate D MakeCorrections {Korrigieren}
translate D Surnames {Nachnamen}
translate D Ambiguous {Mehrdeutig}

#Preferences Dialog
translate D OptionsToolbar "Werkzeugleiste"
translate D OptionsBoard "Schachbrett"
translate D OptionsBoardSize "Brettgre"
translate D OptionsBoardPieces "Figurensatz"
translate D OptionsInternationalization "Sprachumgebung"
translate D OptionsTablebaseDir "Bis zu 4 Verzeichnisse der Endspieltabellen auswhlen:"

# Evaluation bar
translate D BestMoveArrow "Besten Zug anzeigen"
translate D NewLocalEngine "+ Neue Engine ..."

# Batch Annotate
translate D BatchAnnotate {Batch-Anmerkung}
translate D BatchEngineSelection {Motorauswahl}
translate D BatchChessEngine {Schach-Engine:}
translate D BatchNumberOfInstances {Anzahl der Instanzen:}
translate D BatchGameReview {Spielrezension}
translate D BatchTimePerMove {Zeit pro Zug (Sek.):}
translate D BatchAnnotateBlunders {Kommentieren Sie nur Fehler}
translate D BatchBlunderThreshold {Fehlerschwelle:}
translate D BatchVariationLength {Variationslänge (Züge):}
translate D BatchOpeningBook {Eröffnungsbuch}
translate D BatchUseBook {Verwenden Sie Buch}
translate D BatchAnnotateVariations {Kommentieren Sie Variationen}
translate D BatchShortAnnotations {Kurze Anmerkungen}
translate D BatchAddScoreToShort {Fügen Sie kurzen Anmerkungen eine Partitur hinzu}
translate D BatchClearOld {Löschen Sie alte Kommentare und Variationen}
translate D BatchInitializingEngines {Engines werden initialisiert...}
translate D BatchAnalyzingGames {Spiele analysieren...}
translate D BatchProgress {Batch-Kommentarfortschritt}
translate D BatchComplete {Stapelanmerkung abgeschlossen!}
translate D BatchCancelled {Stapelanmerkung abgebrochen}
translate D BatchStart {Start}
translate D BatchCancel {Stornieren}
translate D BatchCompleted {vollendet}
translate D BatchGames {Spiele}
translate D BatchProcessed {verarbeitet}
}
# end of english.tcl
