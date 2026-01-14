### deutsch.tcl:
#  German language support for Scid.
#  Contributors: Bernhard Bialas, J�rgen Clos et al.
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
menuText D FileOpen "�ffnen..." 0 {Existierende Scid-Datenbank �ffnen}
menuText D FileClose "Schlie�en" 0 {Aktive Scid-Datenbank schlie�en}
menuText D FileFinder "Dateisuche" 0 {Dateisuchfenster �ffnen}
menuText D FileBookmarks "Lesezeichen" 0 {Lesezeichenmen�}
menuText D FileBookmarksAdd "Lesezeichen zur Liste hinzuf�gen" 0 \
  {Lesezeichen f�r die aktuelle Partie und Datenbank}
menuText D FileBookmarksFile "Lesezeichen hinzuf�gen in Verzeichnis" 26 \
  {Lesezeichen f�r die aktuelle Stellung und Partie zum Verzeichnis hinzuf�gen}
menuText D FileBookmarksEdit "Lesezeichen editieren..." 12 \
  {Lesezeichen bearbeiten}
menuText D FileBookmarksList "Listenansicht" 1 \
  {Lesezeichen als Liste zeigen, ohne Unterverzeichnisse}
menuText D FileBookmarksSub "Verzeichnisansicht" 3 \
  {Lesezeichen in Verzeichnissen zeigen, nicht als Gesamtliste}
menuText D FileMaint "Wartung" 0 {Das Scid-Datenbankwartungsfenster}
menuText D FileMaintWin "Wartungfenster" 0 \
  {Datenbank-Wartungsfenster �ffnen/schlie�en}
menuText D FileMaintCompact "Datenbank komprimieren..." 10 \
  {Datenbank komprimieren, gel�schte Spiele und unbenutzte Namen entfernen}
menuText D FileMaintClass "Partien ECO-klassifizieren..." 8 \
{Neuklassifizierung aller Partien nach dem ECO-Code}
menuText D FileMaintSort "Sortieren..." 0 \
  {Alle Partien in der aktuellen Datenbank sortieren}
menuText D FileMaintDelete "Dubletten l�schen..." 0 \
  {Dubletten finden und L�schkennzeichen setzen}
menuText D FileMaintTwin "Dubletten pr�fen" 10 \
  {Dublettenfenster �ffnen/erneuern}
menuText D FileMaintName "Namen" 0 \
  {Namenseditor und Rechtschreibpr�fung}
menuText D FileMaintNameEditor "Namenseditor" 0 \
  {Namenseditorfenster �ffnen/schlie�en}
menuText D FileMaintNamePlayer "Schreibkorrektur Spieler..." 17 \
  {Schreibkorrektur der Spielernamen mit Hilfe der .ssp-Datei}
menuText D FileMaintNameEvent "Schreibkorrektur Ereignis..." 17 \
  {Schreibkorrektur der Ereignisse mit Hilfe der .ssp-Datei}
menuText D FileMaintNameSite "Schreibkorrektur Ort..." 17 \
  {Schreibkorrektur der Orte mit Hilfe der .ssp-Datei}
menuText D FileMaintNameRound "Schreibkorrektur Runde..." 17 \
  {Schreibkorrektur der Runden mit Hilfe der .ssp-Datei}
menuText D FileReadOnly "Schreibschutz..." 3 \
  {Datenbank als schreibgesch�tzt behandeln, �nderungen verhindern}
menuText D FileSwitch "Datenbank wechseln" 0 \
  {Zu einer anderen ge�ffneten Datenbank umschalten}
menuText D FileExit "Ende" 0 {Scid beenden}
menuText D FileMaintFixBase "Inkonsistenzen beseitigen" 0 {Versuche eine inkonsistente Datenbank zu reparieren}

# Edit menu:
menuText D Edit "Bearbeiten" 0
menuText D EditAdd "Variante hinzuf�gen" 0 \
  {F�ge zu diesem Zug eine Variante hinzu}
menuText D EditDelete "Variante l�schen" 9 \
  {L�sche eine Variante zu diesen Zug}
menuText D EditFirst "Als erste Variante setzen" 4 \
  {Variante an erste Stelle in der Liste setzten}
menuText D EditMain "Variante als Partiefortsetzung" 13 \
  {Variante zur Partiefolge machen (und umgekehrt)}
menuText D EditTrial "Variante testen" 9 \
  {Testmodus starten/stoppen, um eine Idee am Brett auszuprobieren}
menuText D EditStrip "Entfernen" 1 \
   {Kommentare oder Varianten aus der Partie entfernen}
menuText D EditUndo "R�ckg�ngig" 0 {Macht die letzte �nderung r�ckg�ngig}
menuText D EditRedo "Wiederherstellen" 0 {Redo last game change}
menuText D EditStripComments "Kommentare" 0 \
  {Alle Kommentare und Kommentarzeichen aus dieser Partie entfernen}
menuText D EditStripVars "Varianten" 0 \
  {Alle Varianten aus der Partie entfernen}
menuText D EditStripBegin "Z�ge ab Anfang" 8 \
  {Entferne Z�ge ab Partieanfang}
menuText D EditStripEnd "Z�ge bis Ende" 9 \
  {Entferne Z�ge bis Partieende}
menuText D EditReset "Ablage leeren" 0 \
   {Inhalt der Ablage-Datenbank l�schen}
menuText D EditCopy "Partie in Ablage kopieren" 17 \
  {Diese Partie in die Ablage-Datenbank kopieren}
menuText D EditPaste "Partie aus Ablage einf�gen" 19 \
  {Die aktuele Partie aus der Ablagedatenbank hier einf�gen}
menuText D EditPastePGN "PGN-Partie aus Ablage einf�gen..." 1 \
  {Interpretiere den Inhalt der Zwischenablage als PGN-Notation und f�ge ihn hier ein}
menuText D EditSetup "Stellungseingabe..." 0 \
  {Neue Stellung eingeben (FEN oder manuell)}
menuText D EditCopyBoard "Stellung kopieren" 10 \
  {Aktuelle Brettposition in die Zwischenablage kopieren (im FEN-Format)}
menuText D EditPasteBoard "Stellung einf�gen" 12 \
  {Stellung aus der Zwischenablage (im FEN-Format) einf�gen}
menuText D ConfigureScid "Einstellungen..." 0 {Alle Optionen f�r SCID einstellen}

# Game menu:
menuText D Game "Partie" 0
menuText D GameNew "Neue Partie" 5 {Neue Partie beginnen}
menuText D GameFirst "Erste Partie laden" 0 {Erste Partie im Filter laden}
menuText D GamePrev "Vorherige Partie laden" 0 \
  {Vorherige Partie im Filter laden}
menuText D GameReload "Partie wiederladen" 7 \
  {Diese Partie erneut laden, dabei alle �nderungen verwerfen}
menuText D GameNext "N�chste Partie laden" 0 {N�chste Partie im Filter laden}
menuText D GameLast "Letzte Partie laden" 0 {Letzte Partie im Filter laden}
menuText D GameRandom "Zuf�llige Partie laden" 1 \
  {Zuf�llig ausgew�hlte Partie im Filter laden}
menuText D GameNumber "Lade Partie Nummer..." 14 \
  {Partie durch Angabe der Nummer laden}
menuText D GameReplace "Partie ersetzen..." 8 \
  {Diese Partie sichern, dabei alte Version �berschreiben}
menuText D GameAdd "Partie speichern..." 7 \
  {Diese Partie als neue Partie in der Datenbank sichern}
menuText D GameDeepest "Er�ffnung identifizieren" 10 \
  {Zur Position der l�ngstm�glichen Zugfolge nach ECO-Klassifikation gehen}
menuText D GameGotoMove "Zugnummer..." 0 \
  {Zur angegebenen Zugnummer in der aktuellen Partie gehen}
menuText D GameNovelty "Finde Neuerung..." 0 \
  {Ersten Zug dieser Partie finden, der vorher noch nie gespielt wurde}

# Search menu:
menuText D Search "Suchen" 0
menuText D SearchReset "Filter zur�cksetzen" 0 \
  {Alle Partien in den Filter einschlie�en}
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
menuText D WindowsComment "Kommentareditor" 0 {Kommentareditor �ffnen/schlie�en}
menuText D WindowsGList "Partieliste" 6 {Partieliste �ffnen/schlie�en}
menuText D WindowsPGN "PGN-Fenster" 0 {PGN-Fenster (Partienotation) �ffnen/schlie�en}
menuText D WindowsPList "Spielersuche" 0 {Spielersuche �ffnen/schlie�en}
menuText D WindowsTmt "Turniersuche" 0 {Turniersuche �ffnen/schlie�en}
menuText D WindowsSwitcher "Datenbank-Umschalter" 0 \
  {Datenbank-Umschalter �ffnen/schlie�en}
menuText D WindowsMaint "Wartungsfenster" 0 {(Datenbank-)Wartungsfenster �ffnen/schlie�en}
menuText D WindowsECO "ECO-Auswertung" 0 {ECO-Auswertung �ffnen/schlie�en}
menuText D WindowsStats "Statistik" 4 {Filterstatistik �ffnen/schlie�en}
menuText D WindowsTree "Zugbaum" 0 {Zugbaum �ffnen/schlie�en}
menuText D WindowsBook "Buchfenster" 0 {Buchfenster �ffnen/schlie�en}
menuText D WindowsCorrChess "Fernschachfenster" 0 {�ffnet/schlie�t das Fernschachfenster}
# ====== TODO To be translated ======
menuText D WindowsGraph "Analysis Graph" 0 {Open the Graph window with moves' times and evaluations}

# Tools menu:
menuText D Tools "Werkzeuge" 0
menuText D ToolsConfigureEngines "Engine konfigurieren" 10 {Manage engines' configuration}
menuText D ToolsAnalysis "Analyse-Engine..." 0 \
  {Schachanalyse-Programm starten/beenden}
menuText D ToolsAnalysis2 "Analyse-Engine #2..." 16 \
  {Schachanalyse-Programm Nr.2 starten/beenden}
menuText D ToolsCross "Turniertabelle" 0 {Turniertabelle f�r diese Partie anzeigen}
menuText D ToolsFilterGraph "Rel. Filtergrafik" 0 \
  {Filtergrafik mit relativen Werten �ffnen/schlie�en}
menuText D ToolsAbsFilterGraph "Abs. Filtergrafik" 11 \
  {Filtergrafik mit absoluten Werten �ffnen/schlie�en}
menuText D ToolsOpReport "Er�ffnungsbericht" 0 \
  {Ausf�hrliche Er�ffnungs�bersicht f�r die aktuelle Position erstellen}
menuText D ToolsOpenBaseAsTree "�ffne DB als Baum" 0   {�ffne DB und verwende sie im Zugbaum-Fenster}
menuText D ToolsOpenRecentBaseAsTree "Letzte DB als Baum" 0   {�ffne zuletzt verwendete DB im Zugbaum-Fenster}
menuText D ToolsTracker "Figurenverteilung"  7 \
  {Figurenverteilungsfenster �ffnen}
menuText D ToolsTraining "Training"  0 {Trainingswerkzeuge (Taktik, Er�ffnungen,...) }
menuText D ToolsTacticalGame "Trainingspartie"  0 {Trainingspartie spielen}
menuText D ToolsSeriousGame "Ernste Partie"  0 {Ernste Partie spielen}
menuText D ToolsTrainOpenings "Er�ffnungen"  0 {Er�ffnungsrepertoire trainieren}
menuText D ToolsTrainReviewGame "Partie nachspielen"  0 {Finden von Z�gen wie in vorgegebener Partie}
menuText D ToolsTrainTactics "Taktik"  0 {Taktische Stellungen l�sen}
menuText D ToolsTrainCalvar "Varianten berechnen"  0 {Training zum Berechnen von Varianten}
menuText D ToolsTrainFindBestMove "Besten Zug finden"  0 {Find best move}
menuText D ToolsTrainFics "Internetpartie (FICS)"  0 {Internetpartie auf freechess.org}
menuText D ToolsEngineTournament "Engine Turnier"  0 {Start a tournament between chess engines}
menuText D ToolsBookTuning "Buch abstimmen" 0 {Buch abstimmen}
menuText D ToolsDownloadTWIC "TWIC-Spiele herunterladen" 0 {Die neuesten The Week In Chess (TWIC) Spiele herunterladen}
menuText D ToolsConnectHardware "Hardware verbinden" 0 {Externe Hardware mit Scid verbinden}
menuText D ToolsConnectHardwareConfigure "Konfigurieren..." 0 {Hardware und Verbindung konfigurieren}
menuText D ToolsConnectHardwareNovagCitrineConnect "Novag Citrine verbinden" 0 {Novag Citrine mit Scid verbinden}
menuText D ToolsConnectHardwareInputEngineConnect "Input Engine verbinden" 0 {Input Engine (z.B. DGT Brett) mit Scid verbinden}
menuText D ToolsPInfo "Spielerinformation"  0 \
  {Spielerinformation �ffnen/schlie�en}
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
menuText D ToolsExpCurrentLaTeX "Partie in LaTeX-Datei exportieren..." 10 \
  {Aktuelle Partie in eine LaTeX-Datei schreiben}
menuText D ToolsExpFilter "Alles im Filter exportieren" 16 \
  {Alle Partien im Filter in eine Textdatei schreiben}
menuText D ToolsExpFilterPGN "Filter in PGN-Datei exportieren..." 10 \
  {Alle Partien im Filter in eine PGN-Datei schreiben}
menuText D ToolsExpFilterHTML "Filter in HTML-Datei exportieren..." 10 \
  {Alle Partien im Filter in eine HTML-Datei schreiben}
menuText D ToolsExpFilterHTMLJS "Filter in HTML/JavaScript exportieren..." 17 {Alle Partien im Filter werden in eine HTML und JavaScript Datei exportiert.}  
menuText D ToolsExpFilterLaTeX "Filter in LaTeX-Datei exportieren..." 10 \
  {Alle Partien im Filter in eine LaTeX-Datei schreiben}
menuText D ToolsImportOne "Eine PGN-Partie importieren..." 16 \
  {Eine Partie im PGN-Format eingeben oder einf�gen}
menuText D ToolsImportFile "PGN-Partien importieren..." 0 \
  {Partien aus einer PGN-Datei lesen}
menuText D ToolsStartEngine1 "Starte Engine1" 0  {Starte Analyse von Analyse-Engine1}
menuText D ToolsStartEngine2 "Starte Engine2" 0  {Starte Analyse von Analyse-Engine2}
menuText D ToolsCaptureBoard "Brettfoto..." 0  {Aktuelles Brett als Bild speichern.}
#-----AW------
###  BC   GHIJKL  O Q  TUV XY 
menuText D Play "Spielen" 0 {Partien spielen}
menuText D CCResign "Aufgeben" 0 {Partie aufgeben (funktioniert nicht via eMail)}
menuText D CCClaimDraw "Remis erkl�ren" 1 {Zug senden und Partie Remis erkl�ren (funktioniert nicht via eMail)}
#-----AW------

# Options menu:
menuText D Options "Optionen" 0
menuText D OptionsBoardGraphics "Brettfelder..." 3 {Grafik f�r Brettfelder ausw�hlen}
translate D OptionsBGW {Grafikdatei f�r Felder ausw�hlen}
translate D OptionsBoardGraphicsText {Grafikdateien f�r helle und dunkle Felder ausw�hlen:}
menuText D OptionsBoardNames "Meine Spielernamen..." 0 {Editiere meine Spielernamen}
menuText D OptionsExport "Export" 1 {Textausgabeoptionen �ndern}
menuText D OptionsFonts "Schriftarten" 3 {Schriftarten ausw�hlen}
menuText D OptionsFontsRegular "Normal" 0 {Standardzeichensatz}
menuText D OptionsFontsMenu "Men�" 0 {Schriftart f�r Men�s}
menuText D OptionsFontsSmall "Klein" 0 {Kleine Zeichen}
menuText D OptionsFontsTiny "Winzig" 0 {Kleinster Font}
menuText D OptionsFontsFixed "Fest" 0 {Schriftart mit fester Breite (nicht-proportional)}
menuText D OptionsGInfo "Partieinformation" 0 {Optionen f�r Informationsbereich}
menuText D OptionsLanguage "Sprache" 0 {Sprache w�hlen}
menuText D OptionsMovesTranslatePieces "Figurennamen �bersetzen" 0 {�bersetze den ersten Buchstaben der Figurenbezeichnung}
menuText D OptionsMovesHighlightLastMove "Letzen Zug hervorheben" 0 {Rahmt Start- und Zielfeld des letzten Zuges farbig ein}
menuText D OptionsMovesHighlightLastMoveDisplay "Felder anzeigen" 0 {Hervorhebung des letzen Zuges anzeigen}
menuText D OptionsMovesHighlightLastMoveWidth "Dicke" 0 {Dicke der Linie}
menuText D OptionsMovesHighlightLastMoveColor "Farbe" 0 {Farbe der Linie}
menuText D OptionsMovesHighlightLastMoveArrow "Pfeil anzeigen" 0 {mit einem Pfeil hervorheben}
menuText D OptionsMovesHighlightLastMoveNag "Bewertungssymbole anzeigen" 0
menuText D OptionsMoves "Z�ge" 0 {Zugeingabeoptionen}
menuText D OptionsMovesAnimate "Animation" 0 \
  {Zeit f�r Zuganimation einstellen}
menuText D OptionsMovesDelay "Autom. Vorspielen..." 7 \
  {Zeit f�r automatisches Vorspielen einstellen}
menuText D OptionsMovesCoord "Tastatureingabe" 0 \
  {Zugeingabe �ber Koordinaten ("g1f3") akzeptieren}
menuText D OptionsMovesSuggest "Zugvorschlag zeigen" 0 \
  {Zugvorschlag ein-/ausschalten}
menuText D OptionsShowVarPopup "Variantenfenster zeigen" 0 { Anzeige des Variantenauswahlfensters ein/ausschalten}  
menuText E OptionsMovesLichess "Verwenden Sie das Lichess/Chessbase-Format für Anmerkungen" 0 {Verwenden Sie das Lichess/Chessbase-Format für Anmerkungen}
menuText D OptionsMovesSpace "Leerzeichen nach Zugnummer einf�gen" 0 {Leerzeichen nach Zugnummer einf�gen}  
menuText D OptionsMovesKey "Autom. Zugerg�nzung" 10 \
  {Automatische Zugerg�nzung ein-/ausschalten}
menuText D OptionsMovesShowVarArrows "Pfeile f�r Varianten anzeigen" 0 {Zeige Pfeile in Varianten an: ja/nein}
menuText D OptionsMovesGlossOfDanger "Bedrohte Figuren einf�rben" 0 {Markieren von gef�rdeten Figuren ein/ausschalten}
menuText D OptionsNumbers "Zahlenformat" 5 {Zahlenformat w�hlen}
menuText D OptionsTheme "Design" 0 {Ver�ndert das Aussehen der Oberfl�che}
menuText D OptionsWindows "Fenster" 6 {Fenster-Optionen}
menuText D OptionsSounds "Sprachausgabe" 0 {Sprachausgabe f�r Zugank�ndigung einstellen}
menuText D OptionsResources "Ressourcen..." 0 {Standard Dateien und Verzeichnisse einstellen}
menuText D OptionsWindowsDock "Fenster anheften" 0 {Fenster in der Hauptanwendung �ffnen}
menuText D OptionsWindowsSaveLayout "Layout speichern" 0 {Speichern des aktuellen Fensterlayout}
menuText D OptionsWindowsRestoreLayout "Layout laden" 0 {Gespeichertes Fensterlayout wieder herstellen}
menuText D OptionsWindowsShowGameInfo "Partieinformationen" 0 {Partieinformation anzeigen}
menuText D OptionsWindowsAutoLoadLayout "Automatisch laden: 1. Layout" 0 {L�dt das erste definierte Layout automatisch beim Programmstart}
menuText D OptionsECO "ECO-Datei" 0 {ECO-Klassifikationsdatei laden}
menuText D OptionsSpell "Schreibkorrekturdatei" 7 \
  {Datei f�r Scid-Rechtschreibpr�fung laden}
menuText D OptionsTable "Verzeichnisse der Endspieltabellen" 16 \
  {Eine Endspieltabellendatei w�hlen (und damit alle Tabellen in diesem Verzeichnis)}
menuText D OptionsRecent "Letzte Dateien" 9 \
   {Anzahl der aktuellen Dateien im Dateimen� �ndern}
menuText D OptionsBooksDir "Verzeichnis f�r Er�ffnungsb�cher" 0 {Er�ffnungsbuchverzeichnis einstellen}
menuText D OptionsTacticsBasesDir "Verzeichnis f�r Taktikdatenbanken" 0 {Verzeichnis f�r taktische Trainingsdatenbanken einstellen}
menuText D OptionsPhotosDir "Verzeichnis f�r Spielerbilder" 0 {Verzeichnis f�r Bilder einstellen}
menuText D OptionsThemeDir "Datei mit Design(s)"  0 { Packetdatei f�r GUI Design Themen einstellen }
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
menuText D HelpTip "Tagestip" 0 {Zeigt einen n�tzlichen Tip an}
menuText D HelpStartup "Startfenster" 0 {Startfenster zeigen}
menuText D HelpAbout "�ber Scid" 0 {Informationen zu Scid}

# Game info box popup menu:
menuText D GInfoHideNext "N�chsten Zug verbegen" 13
menuText D GInfoMaterial "Materialwerte zeigen" 0
menuText D GInfoFEN "FEN zeigen" 0
menuText D GInfoMarks "Gef�rbte Felder und Pfeile zeigen" 0
menuText D GInfoWrap "Umbruch bei langen Zeilen" 0
menuText D GInfoFullComment "Vollst�ndigen Kommentar zeigen" 14
menuText D GInfoPhotos "Fotos zeigen" 1
menuText D GInfoTBNothing "Endspieltabellen: nichts" 18
menuText D GInfoTBResult "Endspieltabellen: nur Ergebnis" 22
menuText D GInfoTBAll "Endspieltabellen: Ergebnis und bester Zug" 31
menuText D GInfoDelete "(Ent)L�sche diese Partie" 5
menuText D GInfoMark "(Un)Markiere diese Partie" 4
menuText D GInfoInformant "Informatorwerte konfigurieren" 0

# General buttons:
translate D Back {Zur�ck}
translate D Browse {Ausw�hlen}
translate D Cancel {Abbrechen}
translate D Continue {Weiter}
translate D Clear {Leeren}
translate D Close {Schlie�en}
translate D Contents {Inhalt}
translate D Defaults {Standard}
translate D Delete {L�sche}
translate D Graph {Grafik}
translate D Help {Hilfe}
translate D Hide {Verbergen}
translate D Import {Importieren}
translate D Index {Index}
translate D LoadGame {Partie laden}
translate D BrowseGame {Partie betrachten}
translate D MergeGame {Partie zusammenf�gen}
translate D MergeGames {Partien kombinieren}
translate D Preview {Vorschau} ;# Voransicht!? (KDE)
translate D Revert {Umkehren}
translate D Save {Speichern}
translate D Search {Suchen}
translate D Stop {Halt}
translate D Store {Speichern}
translate D Update {Aktualisieren}
translate D ChangeOrient {Fensterausrichtung �ndern}
translate D ShowIcons {Symbole anzeigen}
translate D None {Keine}
translate D First {Erste}
translate D Current {Aktuelle}
translate D Last {Letzte}

# General messages:
translate D game {Partie}
translate D games {Partien}
translate D move {Zug}
translate D moves {Z�ge}
translate D all {Alle}
translate D Yes {Ja}
translate D No {Nein}
translate D Both {Beide}
translate D King {K�nig}
translate D Queen {Dame}
translate D Rook {Turm}
translate D Bishop {L�ufer}
translate D Knight {Springer}
translate D Pawn {Bauer}
translate D White {Wei�}
translate D Black {Schwarz}
translate D Player {Spieler}
translate D Rating {Elo}
translate D RatingDiff {Elo-Differenz (Wei� - Schwarz)}
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
translate D Months {Januar Februar M�rz April Mai Juni Juli August September Oktober November Dezember}
translate D Days {Son Mon Die Mit Don Fre Sam}
translate D YearToToday {-1J}
translate D YearToTodayTooltip {Setze das Datum 1 Jahr zur�ck bis heute}
translate D Result {Ergebnis}
translate D Round {Runde}
translate D Length {L�nge}
translate D ECOCode {ECO-Code}
translate D ECO {ECO}
translate D Deleted {Gel�scht}
translate D SearchResults {Suchergebnisse}
translate D OpeningTheDatabase {Datenbank �ffnen}
translate D Database {Datenbank}
translate D Filter {Filter}
translate D noGames {keine Partien}
translate D allGames {alle Partien}
translate D empty {leer}
translate D clipbase {Ablage}
translate D score {Punkte}
translate D StartPos {Stellung}
translate D Total {Summe}
translate D readonly {schreibgesch�tzt}

# Standard error messages:
translate D ErrNotOpen {Dies ist keine ge�ffnete Datenbank.}
translate D ErrReadOnly \
  {Diese Datenbank ist schreibgesch�tzt; sie kann nicht ge�ndert werden.}
translate D ErrSearchInterrupted \
  {Suche wurde unterbrochen; Ergebnisse sind unvollst�ndig.}

# Game information:
translate D twin {Dublette}
translate D deleted {gel�scht}
translate D comment {Kommentar}
translate D hidden {versteckt}
translate D LastMove {letzter Zug}
translate D NextMove {n�chster Zug}
translate D GameStart {Partieanfang}
translate D LineStart {Beginn der Zugfolge}
translate D GameEnd {Partieende}
translate D LineEnd {Ende der Zugfolge}

# Player information:
translate D PInfoAll {Ergebnisse f�r <b>alle</b> Spiele}
translate D PInfoFilter {Ergebnisse f�r <b>Filter</b>-Spiele}
translate D PInfoAgainst {Ergebnisse gegen}
translate D PInfoMostWhite {H�ufigste Er�ffnungen als Wei�er}
translate D PInfoMostBlack {H�ufigste Er�ffnungen als Schwarzer}
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
translate D TipConvertPGN {Sie k�nnen eine bessere Leistung erreichen, wenn die PGN-Dateien konvertiert werden.}

# Tree window menus:
menuText D TreeFile "Datei" 0
menuText D TreeFileFillWithBase "Cache mit Datenbank f�llen" 0 {Die Cache-Datei wird mit allen Partien der aktuellen Datenbank bef�llt.}
menuText D TreeFileFillWithGame "Cache mit Partie f�llen" 0 {Die Cache-Datei wird mit der aktuellen Partien bef�llt.}
menuText D TreeFileSetCacheSize "Cache Gr��e" 0 {Cachegr��e ausw�hlen.}
menuText D TreeFileCacheInfo "Cache info" 0 {Info �ber Cachenutzung anzeigen.}
menuText D TreeFileSave "Cache-Datei sichern" 12 \
  {Speichere die Zugbaum-Cache-Datei (.stc)}
menuText D TreeFileFill "Cache-Datei f�llen" 12 \
  {F�lle die Cache-Datei mit h�ufigen Er�ffnungspositionen}
menuText D TreeFileBest "Beste Partien" 0 \
  {Zeige die Liste bester Partien im Baum}
menuText D TreeFileGraph "Grafikfenster" 0 \
  {Zeige die Grafik f�r diesen Ast}
menuText D TreeFileCopy "Kopiere Baumfenster in Zwischenablage" 0 \
  {Kopiere die Zugbaum-Statistik in die Zwischenablage}
menuText D TreeFileClose "Baumfenster schlie�en" 12 {Schlie�e Zugbaum}
menuText D TreeMask "Maskieren" 0
menuText D TreeMaskNew "Neu" 0 {Neue Maske anlegen}
menuText D TreeMaskOpen "�ffnen" 0 {Maske �ffnen}
menuText D TreeMaskOpenRecent "Aktuelle Masken" 0 {Zuletzt ge�ffnete Masken erneut laden}
menuText D TreeMaskSave "Speichern" 0 {Maske speichern}
menuText D TreeMaskClose "Schlie�en" 0 {Maske schlie�en}
menuText D TreeMaskFillWithGame "Mit aktueller Partie f�llen" 0 {Maske mit der aktuellen Partie f�llen}
menuText D TreeMaskFillWithBase "Mit Datenbank f�llen" 0 {Maske mit Datenbankpartien f�llen}
menuText D TreeMaskInfo "Info" 0 {Statistik f�r die aktuelle Maske anzeigen}
menuText D TreeMaskDisplay "Maske als Baum" 0 {Zeigt den Inhalt der aktuellen Maske als Zugbaum}
menuText D TreeMaskSearch "Suchen" 0 {Suchen innerhalb der aktuellen Maske}
menuText D TreeSort "Sortieren" 0
menuText D TreeSortAlpha "Alphabetisch" 0
menuText D TreeSortECO "ECO-Code" 0
menuText D TreeSortFreq "H�ufigkeit" 0
menuText D TreeSortScore "Punkte" 0
menuText D TreeOpt "Optionen" 0
menuText D TreeOptSlowmode "Gr�ndliche Suche" 0 {Update mit hoher Genauigkeit, langsamer}
menuText D TreeOptFastmode "Schneller Modus" 0 {Schnelles Update (ignoriert Zugumstellungen)}
menuText D TreeOptFastAndSlowmode "Gr�ndlicher und Schneller Modus" 0 {Zun�chst schneller Updatemodus, dann nacharbeit im gr�ndlichen Modus}
menuText D TreeOptStartStop "Automatisch aktualisieren" 0 {Schaltet das automatische aktualisieren ein/aus}
menuText D TreeOptLock "Anbinden" 0 \
  {Zugbaum an aktive Datenbank anbinden(/l�sen)}
menuText D TreeOptTraining "Training" 0 {Trainingsmodus ein-/ausschalten}
menuText D TreeOptAutosave "Autom. Cache-Datei sichern" 4 \
  {Beim Schlie�en des Zugbaums automatisch Cache-Datei sichern}
menuText D TreeHelp "Hilfe" 0
menuText D TreeHelpTree "Zugbaumhilfe" 0
menuText D TreeHelpIndex "Index" 0
translate D SaveCache {Cache sichern}
translate D Training {Training}
translate D LockTree {Anbinden}
translate D TreeLocked {angebunden}
translate D TreeBest {Beste}
translate D TreeBestGames {Beste Zugbaumpartien}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate D TreeTitleRow \
  {    Zug    ECO       H�ufigkeit    Pkte   Elo  Erflg Jahr %Remis}
translate D TreeTotal {SUMME}
translate D DoYouWantToSaveFirst {Soll zuerst gespeichert werden}
translate D AddToMask {Zur Maske hinzuf�gen}
translate D RemoveFromMask {Entferne von Maske}
translate D AddThisMoveToMask {Diesen Zug zur Maske hinzuf�gen}
translate D SearchMask {Suche in einer Maske}
translate D DisplayMask {Maske als Zugbaum}
translate D Nag {NAG Code}
translate D Marker {Marker}
translate D Include {Enthalten}
translate D Exclude {Ausgeschlossen}
translate D MainLine {Hauptvariante}
translate D Bookmark {Lesezeichen}
translate D NewLine {Neue Variante}
translate D ToBeVerified {�berpr�fen}
translate D ToTrain {Trainieren}
translate D Dubious {Zweifelhaft}
translate D ToRemove {Entfernen}
translate D NoMarker {Keine Kennzeichen}
translate D ColorMarker {Farbe}
translate D WhiteMark {Wei�}
translate D GreenMark {Gr�n}
translate D YellowMark {Gelb}
translate D BlueMark {Blau}
translate D RedMark {Rot}
translate D CommentMove {Zug kommentieren}
translate D CommentPosition {Position kommentieren}
translate D AddMoveToMaskFirst {Zug zuerst zur Maske hinzuf�ngen}
translate D OpenAMaskFileFirst {Zun�chst Maske �ffnen}
translate D Positions {Positionen}
translate D Moves {Z�ge}

# Finder window:
menuText D FinderFile "Datei" 0
menuText D FinderFileSubdirs "mit Unterverzeichnissen" 0
menuText D FinderFileClose "Dateisuche schlie�en" 0
menuText D FinderSort "Sortieren" 0
menuText D FinderSortType "Typ" 0
menuText D FinderSortSize "Gr��e" 0
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
menuText D FinderHelpFinder "Hilfe f�r Dateisuche" 0
menuText D FinderHelpIndex "Index" 0
translate D FileFinder {Dateisuche}
translate D FinderDir {Verzeichnis}
translate D FinderDirs {Verzeichnisse}
translate D FinderFiles {Dateien}
translate D FinderUpDir {hoch}
translate D FinderCtxOpen {�ffnen}
translate D FinderCtxBackup {Sicherungskopie}
translate D FinderCtxCopy {Kopieren}
translate D FinderCtxMove {Verschieben}
translate D FinderCtxDelete {L�schen}

# Player finder:
menuText D PListFile "Datei" 0
menuText D PListFileUpdate "Aktualisieren" 0
menuText D PListFileClose "Spielersuche schlie�en" 7
menuText D PListSort "Sortieren" 0
menuText D PListSortName "Name" 0
menuText D PListSortElo "Elo" 0
menuText D PListSortGames "Partien" 0
menuText D PListSortOldest "�lteste" 0
menuText D PListSortNewest "Neueste" 0

# Tournament finder:
menuText D TmtFile "Datei" 0
menuText D TmtFileUpdate "Aktualisieren" 0
menuText D TmtFileClose "Turniersuche schlie�en" 0
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
menuText D GraphFileClose "Fenster schlie�en" 0
menuText D GraphOptions "Optionen" 0
menuText D GraphOptionsWhite "Wei�" 0
menuText D GraphOptionsBlack "Schwarz" 0
menuText D GraphOptionsBoth "Beide" 0
menuText D GraphOptionsPInfo "Spielerinfo Spieler" 1
menuText D GraphOptionsEloFile "Elo von Rating-Datei" 0
menuText D GraphOptionsEloDB "Elo von Datenbank" 0
translate D GraphFilterTitle "Filtergrafik: H�ufigkeit pro 1000 Partien"
translate D GraphAbsFilterTitle "Filtergrafik: H�ufigkeit der Partien"
translate D ConfigureFilter "X-Achse f�r Jahr, Elo und Z�ge konfigurieren"
translate D FilterEstimate "Sch�tzen"
translate D TitleFilterGraph "Scid: Filtergrafik"

# Analysis window:
translate D AddVariation {Variante hinzuf�gen}
translate D AddAllVariations {Alle Varianten hinzuf�gen}
translate D AddMove {Zug hinzuf�gen}
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
translate D AnnotateWhich {Varianten hinzuf�gen}
translate D AnnotateAll {F�r Z�ge beider Seiten}
translate D AnnotateAllMoves {Alle Z�ge kommentieren}
translate D AnnotateWhite {Nur f�r Z�ge von Wei�}
translate D AnnotateBlack {Nur f�r Z�ge von Schwarz}
translate D AnnotateBlundersOnly {Wenn der Partiezug ein Fehler ist}
translate D AnnotateBlundersOnlyScoreChange {Analyse berichtet Fehler, Bewertungs�nderung von/nach: }
translate D BlundersThreshold {Schwelle}
translate D ScoreAllMoves {Alle Z�ge bewerten}
translate D LowPriority {Niedrige CPU-Priorit�t}
translate D ClickHereToSeeMoves {Hier klicken um Z�ge anzuzeigen}
translate D ConfigureInformant {Informatorwerte}
translate D Informant!? {Interessanter Zug}
translate D Informant? {Schwacher Zug}
translate D Informant?? {Fehler}
translate D Informant?! {Zweifelhafter Zug}
translate D Informant+= {Wei� hat leichten Vorteil}
translate D Informant+/- {Wei� hat klaren Vorteil}
translate D Informant+- {Wei� hat gro�en Vorteil}
translate D Informant+-- {Wei� hat erdr�ckenden Vorteil}
translate D Book {Buch}
translate D OtherBookMoves {Er�ffnungsbuch des Gegners}
translate D OtherBookMovesTooltip {Z�ge, f�r die der Gegner eine Antwort kennt}

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
# ====== TODO To be translated ======
translate D EngineProtocol {Communication protocol}
# ====== TODO To be translated ======
translate D EngineNotation {Notation of the moves}
# ====== TODO To be translated ======
translate D EngineFlipEvaluation {Flip evaluation perspective}
# ====== TODO To be translated ======
translate D EngineShowLog {Show communication log}
# ====== TODO To be translated ======
translate D EngineNetworkd {Accept remote connections}
# ====== TODO To be translated ======
translate D EngineSelect {Select the current engine}
# ====== TODO To be translated ======
translate D EngineAddLocal {Add a local engine}
# ====== TODO To be translated ======
translate D EngineAddRemote {Add a remote engine}
# ====== TODO To be translated ======
translate D EngineReload {Reload the current engine}
# ====== TODO To be translated ======
translate D EngineClone {Create a copy of the current engine}
# ====== TODO To be translated ======
translate D EngineDelete {Delete the current engine}

# PGN window menus:
menuText D PgnFile "Datei" 0
menuText D PgnFileCopy "Kopiere Spiel in Zwischenablage" 0
menuText D PgnFilePrint "Drucken in Datei..." 0
menuText D PgnFileClose "PGN-Fenster schlie�en" 0
menuText D PgnOpt "Ausgabe" 0
menuText D PgnOptColor "Farbige Darstellung" 0
menuText D PgnOptShort "Kurzer (3-Zeilen) Vorspann (Header)" 8
menuText D PgnOptSymbols "Symbolische Darstellung" 0
menuText D PgnOptIndentC "Kommentare einr�cken" 0
menuText D PgnOptIndentV "Varianten einr�cken" 0
menuText D PgnOptColumn "Tabellarisch (ein Zug pro Zeile)" 0
menuText D PgnOptSpace "Leerzeichen nach Zugnummer" 0
menuText D PgnOptStripMarks "Farbfelder-/Pfeile-Zeichen entfernen" 27
menuText D PgnOptBoldMainLine "Partiez�ge in Fettdruck" 0
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
menuText D CrosstabFileLaTeX "Ausgabe in LaTeX-Datei..." 11
menuText D CrosstabFileClose "Turniertabelle schlie�en" 0
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
menuText D CrosstabOptNats "Nationalit�t" 0
menuText D CrosstabOptRatings "Elo" 0
menuText D CrosstabOptTitles "Titel" 0
menuText D CrosstabOptBreaks "Stichkampfpunkte" 10
menuText D CrosstabOptDeleted "Inklusive gel�schte Partien" 10
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
translate D AddToFilter {Zum Filter hinzuf�gen}
translate D Swiss {Schweizer}
translate D Category {Kategorie}

# Opening report window menus:
menuText D OprepFile "Datei" 0
menuText D OprepFileText "Ausgabe in Textdatei..." 11
menuText D OprepFileHtml "Ausgabe in HTML-Datei..." 11
menuText D OprepFileLaTeX "Ausgabe in LaTeX-Datei..." 11
menuText D OprepFileOptions "Optionen..." 0
menuText D OprepFileClose "Berichtsfenster schlie�en" 0
menuText D OprepFavorites "Favoriten" 0
menuText D OprepFavoritesAdd "Bericht hinzuf�gen..." 8
menuText D OprepFavoritesEdit "Favoritenbericht editieren..." 0
menuText D OprepFavoritesGenerate "Berichte erzeugen..." 9

menuText D OprepHelp "Hilfe" 0
menuText D OprepHelpReport "Er�ffnungsbericht-Hilfe" 0
menuText D OprepHelpIndex "Index" 0

# Header search:
translate D HeaderSearch {Partiedaten suchen}
translate D EndSideToMove {Wer ist beim Partieende am Zug?}
translate D GamesWithNoECO {Partien ohne ECO}
translate D GameLength {Partiel�nge}
translate D FindGamesWith {Finde Partien mit Kennzeichen}
translate D StdStart {Grundstellung}
translate D Promotions {Umwandlung}
translate D Comments {Kommentare}
translate D Variations {Varianten}
translate D Annotations {Anmerkungen}
translate D DeleteFlag {L�schkennzeichen}
translate D WhiteOpFlag {Er�ffnung Wei�}
translate D BlackOpFlag {Er�ffnung Schwarz}
translate D MiddlegameFlag {Mittelspiel}
translate D EndgameFlag {Endspiel}
translate D NoveltyFlag {Neuerung}
translate D PawnFlag {Bauernstruktur}
translate D TacticsFlag {Taktik}
translate D QsideFlag {Damenfl�gel}
translate D KsideFlag {K�nigsfl�gel}
translate D BrilliancyFlag {Gl�nzend}
translate D BlunderFlag {Grober Fehler}
translate D UserFlag {Benutzer}
translate D PgnContains {PGN enth�lt Text}
# ====== TODO To be translated ======
translate D PgnTag {Tag}
# ====== TODO To be translated ======
translate D TagContains {contains}
# ====== TODO To be translated ======
translate D Variant {Variant}
translate D Annotator {Kommentator}
translate D Cmnts {Nur kommentierte Partien}

# Game list window:
translate D GlistNumber {Nummer}
translate D GlistWhite {Wei�}
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
translate D GlistLength {L�nge}
translate D GlistCountry {Land}
translate D GlistECO {ECO}
translate D GlistOpening {Er�ffnung}
translate D GlistEndMaterial {Endmaterial}
translate D GlistDeleted {Gel�scht}
translate D GlistFlags {Kennzeichen}
translate D GlistVars {Varianten}
translate D GlistComments {Kommentare}
translate D GlistAnnos {Anmerkungen}
translate D GlistStart {Stellung}
translate D GlistGameNumber {Partie Nummer}
translate D GlistAverageElo {ELO Durchschnitt}
translate D GlistRating {Wertungszahl}
translate D GlistFindText {Text finden}
translate D GlistMoveField {Z�ge}
translate D GlistEditField {Konfigurieren}
translate D GlistAddField {Hinzuf�gen}
translate D GlistDeleteField {L�schen}
translate D GlistWidth {Breite}
translate D GlistAlign {Ausrichtung}
translate D GlistAlignL {Ausrichtung: links}
translate D GlistAlignR {Ausrichtung: rechts}
translate D GlistAlignC {Ausrichtung: zentriert}
translate D GlistColor {Farbe}
translate D GlistSep {Trennlinie}
translate D GlistCurrentSep {-- Aktuell --}
translate D GlistNewSort {Neu}
translate D GlistAddToSort {Hinzuf�gen}

# base sorting
translate D GsortSort {Sortieren...}
translate D GsortDate {Datum}
translate D GsortYear {Jahr}
translate D GsortEvent {Event}
translate D GsortSite {Ort}
translate D GsortRound {Runde}
translate D GsortWhiteName {Name Wei�}
translate D GsortBlackName {Name Schwarz}
translate D GsortECO {ECO}
translate D GsortResult {Ergebnis}
translate D GsortMoveCount {Zahl der Z�ge}
translate D GsortAverageElo {Eloschnitt}
translate D GsortCountry {Land}
translate D GsortDeleted {Gel�scht}
translate D GsortEventDate {Event Datum}
translate D GsortWhiteElo {ELO Wei�}
translate D GsortBlackElo {ELO Schwarz}
translate D GsortComments {Kommentare}
translate D GsortVariations {Varianten}
translate D GsortNAGs {NAGs}
translate D GsortAscending {Aufsteigend}
translate D GsortDescending {Fallend}
translate D GsortAdd {Hinzuf�gen}
translate D GsortStore {Speichern}
translate D GsortLoad {Laden}

# menu shown with right mouse button down on game list.
translate D GlistRemoveThisGameFromFilter  {Partie aus Filter entfernen}
translate D GlistRemoveGameAndAboveFromFilter  {Partie (und alle oberhalb) aus Filter entfernen}
translate D GlistRemoveGameAndBelowFromFilter  {Partie (und alle darunter) aus Filter entfernen}
translate D GlistDeleteGame {(Ent)Loesche Partie}
translate D GlistDeleteAllGames {L�sche alle Partien im Filter} 
translate D GlistUndeleteAllGames {Alle Partien im Filter wiederherstellen}
translate D GlistMergeGameInBase {Mit Partie in anderer Datebank zusammenf�hren} 

# Maintenance window:
translate D DatabaseName {Datenbankname:}
translate D TypeIcon {Symbol:}
translate D NumOfGames {Partien:}
translate D NumDeletedGames {Gel�schte Partien:}
translate D NumFilterGames {Partien im Filter:}
translate D YearRange {Jahr-Spanne:}
translate D RatingRange {Elo-Spanne:}
translate D Description {Beschreibung}
translate D Flag {Kennzeichen}
translate D CustomFlags {Benutzerdefinierte Kennzeichen}
translate D DeleteCurrent {L�sche aktuelle Partie}
translate D DeleteFilter {L�sche Partien im Filter}
translate D DeleteAll {L�sche alle Partien}
translate D UndeleteCurrent {Aktuelle Partie wiederherstellen}
translate D UndeleteFilter {Partien im Filter wiederherstellen}
translate D UndeleteAll {Alle Partien wiederherstellen}
translate D DeleteTwins {L�sche Dubletten}
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
translate D AddEloRatings {ELO-Zahlen hinzuf�gen}
translate D AutoloadGame {Lade automatisch Partie Nr.}
translate D StripTags {PGN-Kennungen entfernen}
translate D StripTag {Kennungen entfernen}
translate D Cleaner {Bereiniger}
translate D CleanerHelp {
Der Scid-Bereiniger wird f�r die aktuelle Datenbank alle Wartungsarbeiten ausf�hren, welche aus der unten stehenden Liste ausgew�hlt werden.
Aktuelle Einstellungen in den Men�s "ECO-Klassifikation" und "Dubletten l�schen" werden bei Auswahl dieser Funktionen verwendet.}
translate D CleanerConfirm {
Ist der Bereiniger einmal gestartet, kann er nicht mehr unterbrochen werden!

Dies kann lange dauern, speziell bei gro�en Datenbanken, abh�ngig von den
ausgew�hlten Funktionen und deren Einstellungen.

Sind Sie sicher, dass Sie die ausgew�hlten Wartungsarbeiten starten m�chten?
}
# Twinchecker
translate D TwinCheckUndelete { umdrehen; "u" beide wiederherstellen)}
translate D TwinCheckprevPair {Vorheriges Paar}
translate D TwinChecknextPair {N�chstes Paar}
translate D TwinChecker {Scid: Dublettenpr�fer}
translate D TwinCheckTournament {Partien im Turnier:}
translate D TwinCheckNoTwin {Keine Dublette}
translate D TwinCheckNoTwinfound {Kein Dublette f�r diese Partie gefunden.

Um Dubletten anzuzeigen, bitte zuerst die Funktion "L�sche Dubletten" benutzen.}
translate D TwinCheckTag {Nutze Tag...}
translate D TwinCheckFound1 {Scid hat $result Dubletten gefunden}
translate D TwinCheckFound2 { und das Gel�scht-Flag gesetzt}
translate D TwinCheckNoDelete {In dieser Datenbank sind keine Partien zu l�schen.}
translate D TwinCriteria1 {Ihre Auswahlkriterien der Dublettensuche haben eine hohe Wahrscheinlichkeit auch Partien mit �hnlichen Z�gen als Dubletten zu erkennen.
}
translate D TwinCriteria2 {Es wird empfohlen, dass bei der Auswahl "Nein" f�r "gleiche Z�ge" die Auswahl "Ja" f�r Farbe, Ereignis, Ort, Runde, Jahr und Monat ausgew�hlt wird.

Wollen Sie fortsetzen und mit dieser Auswahl die Dubletten l�schen? }
translate D TwinCriteria3 {Es wird empfohlen, dass bei der Auswahl "Ja" f�r mindestens 2 der Parameter "gleicher Ort", "gleiche Runde" und "gleiches Jahr" gesetzt werden.
    
Wollen Sie fortsetzen und mit dieser Auswahl die Dubletten l�schen?}
translate D TwinCriteriaConfirm {Scid: Best�tigen der Dublettensuchparameter}
translate D TwinChangeTag "�ndern der folgenden Partie-Tags:\n\n"
translate D AllocRatingDescription "Es werden die ELO-Werte aus der Schreibkorrekturdatei den Partien hinzugef�gt, wenn der/die Spieler/in keinen aktuellen Wert in der Partie besitzt, aber in der Korrekturdatei ein Wert f�r den Zeitraum der Partie vorhanden ist."
translate D RatingOverride "Existierende ELO-Werte �berschreiben"
translate D AddRatings "Elo-Werte hinzuf�gen"
translate D AddedRatings {Scid hat $r Elo-Werte in $g Partien hinzugef�gt.}

#Bookmark editor
translate D NewSubmenu "Neues Untermen�"

# Comment editor:
translate D AnnotationSymbols  {Kommentarzeichen:}
translate D Comment {Kommentar:}
translate D InsertMark {Markierung einf�gen}
translate D InsertMarkHelp {
Markierung einf�gen/l�schen: Farbe, Typ, Feld w�hlen.
Pfeil einf�gen/l�schen: Rechtsklick auf zwei Felder.
}

# Nag buttons in comment editor:
translate D GoodMove {Guter Zug}
translate D PoorMove {Schwacher Zug}
translate D ExcellentMove {Ausgezeichneter Zug}
translate D Blunder {Grober Fehler}
translate D InterestingMove {Interessanter Zug}
translate D DubiousMove {Zweifelhafter Zug}
translate D WhiteDecisiveAdvantage {Wei� hat gro�en Vorteil}
translate D BlackDecisiveAdvantage {Schwarz hat gro�en Vorteil}
translate D WhiteClearAdvantage {Wei� hat klaren Vorteil}
translate D BlackClearAdvantage {Schwarz hat klaren Vorteil}
translate D WhiteSlightAdvantage {Wei� hat leichten Vorteil}
translate D BlackSlightAdvantage {Schwarz hat leichten Vorteil}
translate D WhiteCrushing {Wei� hat erdr�ckenden Vorteil}
translate D BlackCrushing {Schwarz hat erdr�ckenden Vorteil}
translate D Equality {Gleiche Chancen}
translate D Unclear {Unklar}
translate D Diagram {Diagramm}

# Board search:
translate D BoardSearch {Brettsuche}
translate D FilterOperation {Suche im aktuellen Filter:}
translate D FilterAnd {UND\nBeschr�nke Filter}
translate D FilterOr {ODER\nZum Filter hinzuf�gen}
translate D FilterIgnore {IGNORIEREN\nFilter zur�cksetzen}
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
translate D CommonPatterns {H�ufige Muster}
translate D MaterialDiff {Materialdifferenz}
translate D squares {Felder}
translate D SameColor {Gleichfarbige}
translate D OppColor {Ungleichfarbige}
translate D Either {Beides}
translate D MoveNumberRange {Zugnummernbereich}
translate D MatchForAtLeast {Zutreffend f�r mindestens}
translate D HalfMoves {Halbz�ge}

# Common endings in material search:
translate D EndingPawns {Bauernendspiele}
translate D EndingRookVsPawns {Turm gegen Bauer(n)}
translate D EndingRookPawnVsRook {Turm und 1 Bauer gegen Turm}
translate D EndingRookPawnsVsRook {Turm und Bauer(n) gegen Turm}
translate D EndingRooks {Turm gegen Turm}
translate D EndingRooksPassedA {Turm gegen Turm mit Freibauer}
translate D EndingRooksDouble {Doppelturm-Endspiele}
translate D EndingBishops {L�ufer gegen L�ufer}
translate D EndingBishopVsKnight {L�ufer gegen Springer}
translate D EndingKnights {Springer gegen Springer}
translate D EndingQueens {Dame gegen Dame} ;# *** Damenendspiele !?
translate D EndingQueenPawnVsQueen {Dame und 1 Bauer gegen Dame}
translate D BishopPairVsKnightPair {Zwei L�ufer gegen zwei Springer im Mittelspiel}

# Common patterns in material search:
translate D PatternWhiteIQP {Wei�er isolierter Damenbauer}
translate D PatternWhiteIQPBreakE6 {Wei�er Isolani: Durchbruch d4-d5 gegen e6}
translate D PatternWhiteIQPBreakC6 {Wei�er Isolani: Durchbruch d4-d5 gegen c6}
translate D PatternBlackIQP {Schwarzer isolierter Damenbauer}
translate D PatternWhiteBlackIQP {Wei�er gegen schwarzer Damenbauerisolani}
translate D PatternCoupleC3D4 {Isoliertes Bauernpaar c3+d4}
translate D PatternHangingC5D5 {H�ngende Bauern c5 und d5 von Schwarz}
translate D PatternMaroczy {Maroczy-Zentrum (mit Bauern auf c4 und e4)}
translate D PatternRookSacC3 {Turmopfer auf c3}
translate D PatternKc1Kg8 {0-0-0 gegen 0-0 (Kc1 gegen Kg8)}
translate D PatternKg1Kc8 {0-0 gegen 0-0-0 (Kg1 gegen Kc8)}
translate D PatternLightFian {Wei�feldrige Fianchettos (L�ufer g2 gegen L�ufer b7)}
translate D PatternDarkFian {Schwarzfeldrige Fianchettos (L�ufer b2 gegen L�ufer g7)}
translate D PatternFourFian {Beiderseitiges Doppelfianchetto (L�ufer auf b2,g2,b7,g7)}

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
translate D ClearFen {FEN l�schen}
translate D PasteFen {FEN einf�gen}
translate D SaveAndContinue {Speichern und weiter}
translate D DiscardChangesAndContinue {Verwerfen und weiter}
translate D GoBack {Zur�ck}

# Replace move dialog:
translate D ReplaceMove {Zug ersetzen}
translate D AddNewVar {Neue Variante}
translate D NewMainLine {Neue Hauptvariante}
translate D ReplaceMoveMessage {Hier existiert bereits ein Zug.

Sie k�nnen diesen Zug ersetzen - unter Verlust aller nachfolgender Z�ge - oder mit dem Zug eine neue Variante hinzuf�gen.

(Sie k�nnen diese Anzeige vermeiden, indem Sie die Option "Fragen vor Ersetzen" im Men� Optionen:Z�ge deaktivieren)}

# Make database read-only dialog:
translate D ReadOnlyDialog {Wenn Sie diese Datenbank mit Schreibschutz
versehen, sind keine �nderungen m�glich. Es k�nnen keine Partien gespeichert
oder ersetzt und keine L�schkennzeichen ge�ndert werden. Alle Sortierungen oder
ECO-Klassifikationsergebnisse sind nur tempor�r.

Sie k�nnen den Schreibschutz einfach entfernen, indem Sie die Datenbank
schlie�en und wieder �ffnen.
Wollen Sie diese Datenbank wirklich schreibsch�tzen?}

# Clear game dialog:
translate D ClearGameDialog {Diese Partie wurde ge�ndert.

Wollen Sie wirklich fortsetzen und die �nderungen verwerfen?
}

# Exit dialog:
translate D ExitDialog {M�chten Sie Scid beenden?}
translate D ExitUnsaved {Die folgenden Datenbanken haben ungesicherte Partie�nderungen. Wenn Sie jetzt beenden, gehen diese �nderungen verloren.}

# Import window:
translate D PasteCurrentGame {Aktuelle Partie einf�gen}
translate D ImportHelp1 {Eingeben oder Einf�gen einer Partie im PGN-Format in den oberen Rahmen.}
translate D ImportHelp2 {Hier werden Fehler beim Importieren angezeigt.}
translate D OverwriteExistingMoves {Bestehende Z�ge �berschreiben?}

# ECO Browser:
translate D ECOAllSections {alle ECO-Gruppen}
translate D ECOSection {ECO-Gruppe}
translate D ECOSummary {Zusammenfassung f�r}
translate D ECOFrequency {H�ufigkeit der Untercodes f�r}

# Opening Report:
translate D OprepTitle {Er�ffnungsbericht}
translate D OprepReport {Bericht}
translate D OprepGenerated {Erzeugt durch}
translate D OprepStatsHist {Statistiken und Geschichte}
translate D OprepStats {Statistiken}
translate D OprepStatAll {Alle Berichtspartien}
translate D OprepStatBoth {Beide Spieler}
translate D OprepStatSince {Nach}
translate D OprepOldest {�lteste Partien}
translate D OprepNewest {Neuste Partien}
translate D OprepPopular {Popularit�t}
translate D OprepFreqAll {H�ufigkeit in allen Jahren: }
translate D OprepFreq1   {im letzten Jahr:            }
translate D OprepFreq5   {der letzten  5 Jahre:       }
translate D OprepFreq10  {der letzten 10 Jahre:       }
translate D OprepEvery {Eine pro %u Partien}
translate D OprepUp {mehr als %u%s von allen Jahren}
translate D OprepDown {weniger als %u%s von allen Jahren}
translate D OprepSame {keine �nderung in allen Jahren}
translate D OprepMostFrequent {H�ufigste Spieler}
translate D OprepMostFrequentOpponents {H�ufigste Gegner}
translate D OprepRatingsPerf {ELO und Performance}
translate D OprepAvgPerf {Durchschnitts-ELO und Performance}
translate D OprepWRating {ELO Wei�}
translate D OprepBRating {ELO Schwarz}
translate D OprepWPerf {Performance Wei�}
translate D OprepBPerf {Performance Schwarz}
translate D OprepHighRating {Spiele mit h�chstem ELO-Durchschnitt}
translate D OprepTrends {Ergebnistrend}
translate D OprepResults {Ergebnis nach L�ngen und H�ufigkeiten}
translate D OprepLength {Partiel�nge}
translate D OprepFrequency {H�ufigkeit}
translate D OprepWWins {Wei�siege:    }
translate D OprepBWins {Schwarzsiege: }
translate D OprepDraws {Remis:        }
translate D OprepWholeDB {ganze Datenbank}
translate D OprepShortest {K�rzester Sieg}
translate D OprepMovesThemes {Z�ge und Themen}
translate D OprepMoveOrders {Zugfolgen zum Erreichen\nder Berichtsposition}
translate D OprepMoveOrdersOne \
  {Es gab nur eine Zugfolge zur erreichten Position:}
translate D OprepMoveOrdersAll \
  {Es gab %u Zugfolgen zur erreichten Position:}
translate D OprepMoveOrdersMany \
  {Es gab  %u Zugfolgen zur erreichten Position. Die ersten %u sind:}
translate D OprepMovesFrom {Z�ge ab der Berichtsposition}
translate D OprepMostFrequentEcoCodes {H�ufigste ECO-Codes}
translate D OprepThemes {Themen}
translate D OprepThemeDescription {H�ufigkeit der Themen in den ersten %u Z�gen jeder Partie}
translate D OprepThemeSameCastling {Gleichseitige Rochaden}
translate D OprepThemeOppCastling {Verschiedenseitige Rochaden}
translate D OprepThemeNoCastling {Beide Seiten unrochiert}
translate D OprepThemeKPawnStorm {Bauernsturm auf K�nig}
translate D OprepThemeQueenswap {Damen getauscht}
translate D OprepThemeWIQP {Wei�er isolierter Damenbauer}
translate D OprepThemeBIQP {Schwarzer isolierter Damenbauer}
translate D OprepThemeWP567 {Wei�er Bauer auf Reihe 5/6/7}
translate D OprepThemeBP234 {Schwarzer Bauer auf Reihe 2/3/4}
translate D OprepThemeOpenCDE {Offene c/d/e-Linie}
translate D OprepTheme1BishopPair {Eine Seite hat L�uferpaar}
translate D OprepEndgames {Endspiele}
translate D OprepReportGames {Berichtspartien}
translate D OprepAllGames {Alle Partien}
translate D OprepEndClass {Materialklassifikation von Endspielstellungen}
translate D OprepTheoryTable {Theorietabelle}
translate D OprepTableComment {Erzeugt aus %u Partien mit h�chster ELO-Zahl.}
translate D OprepExtraMoves {Zus�tzliche Z�ge in der Theorietabelle}
translate D OprepMaxGames {Maximale Partien in der Theorietabelle}
translate D OprepViewHTML {Zeige HTML}
translate D OprepViewLaTeX {Zeige LaTeX}

# Player Report:
translate D PReportTitle {Spielerbericht}
translate D PReportColorWhite {mit den wei�en Steinen}
translate D PReportColorBlack {mit den schwarzen Steinen}
translate D PReportMoves {nach %s}
translate D PReportOpenings {Er�ffnungen}
translate D PReportClipbase {Leere Zwischenablage und kopiere gefundene Spiele}

# Piece Tracker window:
translate D TrackerSelectSingle {Linke Maustaste w�hlt diese Figur.}
translate D TrackerSelectPair \
  {Linke Maustaste w�hlt diese Figur; rechte Maustaste w�hlt das Figurenpaar.}
translate D TrackerSelectPawn \
  {Linke Maustaste w�hlt diesen Bauern; rechte Maustaste w�hlt alle 8 Bauern.}
translate D TrackerStat {Statistik}
translate D TrackerGames {% der Partien mit Zug auf das Feld}
translate D TrackerTime {% der Zeit auf jedem Feld}
translate D TrackerMoves {Z�ge}
translate D TrackerMovesStart \
  {Zugnummer, ab der die Verteilungsberechnung beginnen soll.}
translate D TrackerMovesStop \
  {Zugnummer, wo die Verteilungsberechnung enden soll.}

# Game selection dialogs:
translate D SelectAllGames {Alle Partien in der Datenbank}
translate D SelectFilterGames {Nur Partien im Filter}
translate D SelectTournamentGames {Nur Partien des aktuellen Turniers}
translate D SelectOlderGames {Nur �ltere Partien}

# Delete Twins window:
translate D TwinsNote {Damit zwei Spiele Dubletten sind, m�ssen diese mindestens die beiden selben Spieler haben und die folgenden Kriterien, die Sie ausw�hlen k�nnen, erf�llen. Wenn zwei Dubletten gefunden werden, so wird die k�rzere der beiden Spiele gel�scht. Tip: am besten f�hrt man erst eine Schreibkorrektur durch, da dadurch das Finden von Dubletten verbessert wird.}
translate D TwinsCriteria {Kriterium: Dubletten m�ssen haben ...}
translate D TwinsWhich {�berpr�fe Partien}
translate D TwinsColors {gleiche Spielerfarbe}
translate D TwinsEvent {gleiches Ereignis}
translate D TwinsSite {gleichen Ort}
translate D TwinsRound {gleiche Runde}
translate D TwinsYear {gleiches Jahr}
translate D TwinsMonth {gleichen Monat}
translate D TwinsDay {gleichen Tag}
translate D TwinsResult {gleiches Ergebnis}
translate D TwinsECO {gleichen ECO-Code}
translate D TwinsMoves {gleiche Z�ge}
translate D TwinsPlayers {Vergleiche Spielernamen}
translate D TwinsPlayersExact {Exakte Treffer}
translate D TwinsPlayersPrefix {Nur erste 4 Buchstaben}
translate D TwinsWhen {Beim L�schen der Dubletten}
translate D TwinsSkipShort {Partien unter 5 Z�gen ignorieren}
translate D TwinsUndelete {Zuerst alle Partien entl�schen}
translate D TwinsSetFilter {Filter auf Dubletten setzen}
translate D TwinsComments {Spiele mit Kommentar immer behalten}
translate D TwinsVars {Spiele mit Varianten immer behalten}
translate D TwinsDeleteWhich {L�sche Partie}
translate D TwinsDeleteShorter {K�rzere Partie}
translate D TwinsDeleteOlder {Kleinere Partienummer}
translate D TwinsDeleteNewer {Gr��ere Partienummer}
translate D TwinsDelete {L�sche Spiele}

# Name editor window:
translate D NameEditType {Namen �ndern von}
translate D NameEditSelect {Welche Spiele sollen ge�ndert werden?}
translate D NameEditReplace {Ersetze}
translate D NameEditWith {durch}
translate D NameEditMatches {Vorschlag mit Strg+1 - Strg+9 ausw�hlen}
translate D CheckGames {Konsistenzpr�fung}
translate D CheckGamesWhich {Konsistenzpr�fung}
translate D CheckAll {Alle Partien}
translate D CheckSelectFilterGames {Partien im Filter}

# Classify window:
translate D Classify {Klassifiziere}
translate D ClassifyWhich {Partien ECO-klassifizieren}
translate D ClassifyAll {Alle Spiele (�berschreibe alte ECO-Codes)}
translate D ClassifyYear {Alle Spiele  aus dem letzten Jahr}
translate D ClassifyMonth {Alle Spiele aus dem letzten Monat}
translate D ClassifyNew {Nur Spiele ohne ECO-Code}
translate D ClassifyCodes {ECO-Codes verwenden}
translate D ClassifyBasic {Standard Codes ("B12", ...)}
translate D ClassifyExtended {mit Scid-Erweiterung ("B12j", ...)}

# Compaction:
translate D NameFile {Namendatenbank}
translate D GameFile {Partiendatenbank}
translate D Names {Namen}
translate D Unused {Unbenutzt}
translate D SizeKb {Gr��e (kB)}
translate D CurrentState {Momentaner Stand}
translate D AfterCompaction {nach Kompression}
translate D CompactNames {Komprimiere Namen}
translate D CompactGames {Komprimiere Partien}
translate D NoUnusedNames "Es gibt keine unbenutzen Namen, die Namensdatei ist vollst�ndig komprimiert."
translate D NoUnusedGames "Die Partiedatei ist vollst�ndig komprimiert."
translate D GameFileCompacted {Die Partiedatei der Datenbank wurde komprimiert.}

# Sorting:
translate D SortCriteria {Kriterium}
translate D AddCriteria {F�ge Sortierkriterium hinzu}
translate D CommonSorts {�bliche Sortierkriterien}
translate D Sort {Sortiere}

# Exporting:
translate D AddToExistingFile {Anh�ngen an eine bestehende Datei}
translate D ExportComments {Kommentare exportieren}
translate D ExportVariations {Varianten exportieren}
translate D IndentComments {Kommentare einr�cken}
translate D IndentVariations {Varianten einr�cken}
translate D ExportColumnStyle {Tabellarisch: ein Zug pro Zeile}
translate D ExportSymbolStyle {Symbolische Notation }
translate D ExportStripMarks \
  {Felder-/Pfeilemarkierzeichen\naus den Kommentaren entfernen}

# Goto game/move dialogs:
translate D LoadGameNumber {Geben Sie die zu ladende Spielnr. ein:}
translate D GotoMoveNumber {Gehe zu Zugnr.:}
translate D CopyAllGames {Kopiere alle Spiele nach}

# Copy games dialog:
translate D CopyGames {Kopiere Spiele}
translate D CopyConfirm {
 M�chten sie wirklich die [::utils::thousands $nGamesToCopy]
 Spiele aus dem Filter
 in der Datenbank "$fromName"
 in die Datenbank "$targetName"
 kopieren?
}
translate D CopyErr {Kann Spiele nicht kopieren}
translate D CopyErrSource {Die Quelldatenbank}
translate D CopyErrTarget {Die Zieldatenbank}
translate D CopyErrNoGames {hat keine Spiele im Filter}
translate D CopyErrReadOnly {ist schreibgesch�tzt}
translate D CopyErrNotOpen {ist nicht ge�ffnet}

# Colors:
translate D LightSquares {Helle Felder}
translate D DarkSquares {Dunkle Felder}
translate D SelectedSquares {Ausgew�hlte Felder}
translate D SuggestedSquares {Zugvorschlagsfelder}
translate D WhitePieces {Wei�e Steine}
translate D BlackPieces {Schwarze Steine}
translate D WhiteBorder {Wei�e Umrandung}
translate D BlackBorder {Schwarze Umrandung}

# Novelty window:
translate D FindNovelty {Finde Neuerung}
translate D Novelty {Neuerung}
translate D NoveltyInterrupt {Neuerungensuche abgebrochen}
translate D NoveltyNone {In dieser Partie wurde keine Neuerung gefunden}
translate D NoveltyHelp {Scid wird den ersten Zug aus der aktuellen Partie finden, welcher zu einer Position f�hrt, die nicht in der gew�hlten Datenbank oder in dem ECO-Er�ffnungsbuch enthalten ist.}

# Sounds configuration:
translate D SoundsFolder {Verzeichnis f�r Sprachausgabedateien}
translate D SoundsFolderHelp {Das Verzeichnis sollte enthalten: King.wav, a.wav, 1.wav etc.}
translate D SoundsAnnounceOptions {Optionen f�r Zugank�ndigung}
translate D SoundsAnnounceNew {K�ndige neue Z�ge an, wenn sie ausgef�hrt werden}
translate D SoundsAnnounceForward {K�nde Zug an beim Vorw�rtspielen}
translate D SoundsAnnounceBack {K�ndige Zug an beim Zur�ckgehen}
translate D SoundsSoundDisabled {Scid hat das Snack Audio Paket beim Start nicht gefunden.\nTon ist abgeschaltet.}

# Upgrading databases:
translate D Upgrading {Upgrading}
translate D ConfirmOpenNew {
Dies ist eine Datenbank im alten (Scid 3.x) Format, die nicht in Scid 4.x
ge�ffnet werden kann. Aber eine Version im neuen Format wurde schon erstellt.

Wollen Sie die Version der Datenbank im neuen Format �ffnen?
}
translate D ConfirmUpgrade {
Dies ist eine Datenbank im alten (Scid 3.x) Format. Vor der Verwendung in
Scid 4 mu� eine Version im neuen Format der Datenbank erstellt werden.

Beim Erstellen der neuen Version der Datenbank bleiben die Dateien der alten Version erhalten.

Dieser Vorgang kann eine Zeitlang dauern, mu� aber nur einmal durchgef�hrt
werden. Sie k�nnen jederzeit abbrechen, wenn es Ihnen zu lange dauert.

Soll das Erstellen der Datenbank im neuen Format jetzt durchgef�hrt werden?
}

# Recent files options:
translate D RecentFilesMenu {Anzahl letzter Dateien im Dateimen�}
translate D RecentFilesExtra {Anzahl letzter Dateien im Untermen�}

# My Player Names options:
translate D MyPlayerNamesDescription {
Geben Sie unten eine Liste der bevorzugten Spielernamen ein, ein Name pro Zeile. Platzhalterzeichen (z.B. "?" f�r ein beliebiges einzelnes Zeichen, "*" f�r jede beliebige Folge von Zeichen) sind erlaubt.

Jedesmal, wenn ein Spiel mit einem aufgelisteten Spielernamen geladen wird, wird das Schachbrett im Hauptfenster erforderlichenfalls gedreht, um das Spiel aus der Sicht des betreffenden Spielers zu zeigen.
}
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
translate D white {Wei�}
translate D black {Schwarz}
translate D both {beide}
translate D Play {Spielen}
translate D Noblunder {Kein Fehler}
translate D blunder {Fehler}
translate D Noinfo {-- Keine Info --}
translate D PhalanxOrTogaMissing {Phalanx oder Toga nicht gefunden!}
translate D moveblunderthreshold {fehlerhafter Zug, wenn Verlust gr��er als}
translate D limitanalysis {Analysezeit der Engine begrenzen}
translate D seconds {Sekunden}
translate D Abort {Abbrechen}
translate D Resume {Fortfahren}
translate D OutOfOpening {Ende der Er�ffnung}
translate D NotFollowedLine {You did not follow the line}
translate D DoYouWantContinue {M�chten sie fortfahren?}
translate D CoachIsWatching {Coach schaut zu}
translate D Ponder {Berechnen im Hintergrund}
translate D LimitELO {St�rke begrenzen (ELO)}
translate D DubiousMovePlayedTakeBack {Zweifelhafter Zug gespielt, wollen Sie ihn zur�cknehmen?}
translate D WeakMovePlayedTakeBack {Dies ist kein guter Zug, wollen Sie ihn zur�cknehmen?}
translate D BadMovePlayedTakeBack {Dies ist ein schlechter Zug, wollen Sie ihn zur�cknehmen?}
translate D Iresign {Ich gebe auf}
translate D yourmoveisnotgood {Ihr Zug ist nicht gut}
translate D EndOfVar {Variantenende}
translate D Openingtrainer {Er�ffnungstrainer}
translate D DisplayCM {Kandidatenz�ge anzeigen}
translate D DisplayCMValue {Wert der Kandidatenz�ge anzeigen}
translate D DisplayOpeningStats {Statistik anzeigen}
translate D ShowReport {Bericht anzeigen}
translate D NumberOfGoodMovesPlayed {gute Z�ge gespielt}
translate D NumberOfDubiousMovesPlayed {zweischneidige Z�ge gespielt}
translate D NumberOfMovesPlayedNotInRepertoire {Z�ge au�erhalb des Repertoirs gespielt}
translate D NumberOfTimesPositionEncountered {Wiederholungen der Position}
translate D PlayerBestMove  {Nur beste Z�ge erlauben}
translate D OpponentBestMove {Gegner spielt besten Zug}
translate D OnlyFlaggedLines {Nur markierte Linien}
translate D resetStats {Statistik zur�cksetzen}
translate D Repertoiretrainingconfiguration {Konfiguration Trainingsrepertoire}
translate D Loadingrepertoire {Lade Repertoire}
translate D Movesloaded {Z�ge geladen}
translate D Repertoirenotfound {Repertoire nicht gefunden}
translate D Openfirstrepertoirewithtype {Zuerst eine Er�ffnungsdatenbank mit entsprechendem Type/Icon �ffnen.}
translate D Movenotinrepertoire {Zug nicht im Repertoire}
translate D PositionsInRepertoire {Positionen im Repertoire}
translate D PositionsNotPlayed {nicht gespielte Positionen}
translate D PositionsPlayed {gespielte Positionen}
translate D Success {Erfolgreich}
translate D DubiousMoves {Zweifelhafte Z�ge}
translate D OutOfRepertoire {Nicht im Repertoire}
translate D ConfigureTactics {Taktik konfigurieren}
translate D ResetScores {"Gel�st" zur�cksetzten}
translate D LoadingBase {Lade Datenbank}
translate D Tactics {Taktik}
translate D ShowSolution {L�sung zeigen}
translate D NextExercise {N�chste Aufgabe}
translate D PrevExercise {Vorherige Aufgabe}
translate D StopTraining {Training beenden}
translate D Next {N�chste}
translate D ResettingScore {"Gel�st" zur�cksetzen}
translate D LoadingGame {Lade Partie}
translate D MateFound {Matt gefunden}
translate D BestSolutionNotFound {Beste L�sung NICHT gefunden!}
translate D MateNotFound {Matt nicht gefunden}
translate D ShorterMateExists {K�rzeres Matt existiert}
translate D ScorePlayed {Bewertung gepielt}
translate D Expected {erwarted}
translate D ChooseTrainingBase {Trainingsdatenbank ausw�hlen}
translate D Thinking {Denke...}
translate D AnalyzeDone {Analyse beendet}
translate D WinWonGame {Gewinne gewonnene Partie}
translate D Lines {Variantenzahl}
translate D ConfigureUCIengine {UCI Engine konfigurieren}
translate D SpecificOpening {Ausgew�hlte Er�ffnung}
translate D StartNewGame {Neue Partie}
translate D FixedLevel {Feste St�rke}
translate D Opening {Er�ffnung}
translate D RandomLevel {Zufallsst�rke}
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
translate D AllExercisesDone {Alle �bungen gemacht}
translate D MoveOutOfBook {Zug nicht mehr im Buch}
translate D LastBookMove {Letzter Buchzug}
translate D AnnotateSeveralGames {Von aktueller Partie bis Partie:}
translate D FindOpeningErrors {Er�ffnungsfehler finden}
translate D MarkTacticalExercises {Taktische �bungen markieren}
translate D UseBook {Buch benutzen}
translate D MultiPV {Multivariantenmodus}
translate D Hash {Hash Speicher}
translate D OwnBook {Engine Buch verwenden}
translate D BookFile {Er�ffnungsbuch}
translate D AnnotateVariations {Varianten kommentieren}
translate D ShortAnnotations {Kurze Kommentare}
translate D addAnnotatorTag {Kommentar Tag hinzuf�gen}
translate D AddScoreToShortAnnotations {Bewertung hinzuf�gen}
translate D Export {Export}
translate D BookPartiallyLoaded {Buch teilweise geladen}
translate D Calvar {Training: Variantenberechnung}
translate D ConfigureCalvar {Konfiguration}
translate D Reti {Reti}
translate D English {Englische Er�ffnung}
translate D d4Nf6Miscellaneous {1.d4 Nf6 Verschiedene}
translate D Trompowsky {Trompowsky}
translate D Budapest {Budapest}
translate D OldIndian {Altindische Verteidigung}
translate D BenkoGambit {Benko Gambit}
translate D ModernBenoni {Moderne/Benoni-Verteidigung}
translate D DutchDefence {Holl�ndische Verteidigung}
translate D Scandinavian {Skandinavische Verteidigung}
translate D AlekhineDefence {Aljechin Verteidigung}
translate D Pirc {Pirc-Verteidigung}
translate D CaroKann {Caro-Kann}
translate D CaroKannAdvance {Caro-Kann Vorsto�variante}
translate D Sicilian {Sizilianisch}
translate D SicilianAlapin {Sizilianisch, Alapin Variante}
translate D SicilianClosed {Geschlossene Sizilianische Verteidigung}
translate D SicilianRauzer {Sizilianisch, Rauzer Angriff}
translate D SicilianDragon {Sizilianisch, Drachenvariante}
translate D SicilianScheveningen {Sizilianisch, Scheveningen}
translate D SicilianNajdorf {Sizilianisch, Najdorf}
translate D OpenGame {Offene Spiele}
translate D Vienna {Wiener Verteidigung}
translate D KingsGambit {K�nigsgambit}
translate D RussianGame {Russische Verteidigung}
translate D ItalianTwoKnights {Italienische Er�ffnung}
translate D Spanish {Spanisch Partie}
translate D SpanishExchange {Spanisch, Abtauschvariante}
translate D SpanishOpen {Spanisch, offene Systeme}
translate D SpanishClosed {Spanisch, geschlossene Systeme}
translate D FrenchDefence {Franz�sische Verteidigung}
translate D FrenchAdvance {Franz�sisch, Vorsto�variante}
translate D FrenchTarrasch {Franz�sisch, Tarrasch}
translate D FrenchWinawer {Franz�sisch, Winawer}
translate D FrenchExchange {Franz�sisch, Abtauschvariante}
translate D QueensPawn {Damenbauernspiel}
translate D Slav {Slavisch}
translate D QGA {Angenommenes Damengambit}
translate D QGD {Abgelehntes Damengambit}
translate D QGDExchange {Abgelehntes Damengambit, Abtauschvariante}
translate D SemiSlav {Semi-Slawisch}
translate D QGDwithBg5 {Abgelehntes Damengambit mit Lg5}
translate D QGDOrthodox {Abgelehntes Damengambit, Orthodoxe Variante}
translate D Grunfeld {Gr�nfeld-Verteidigung}
translate D GrunfeldExchange {Gr�nfeld, Abtauschvariante}
translate D GrunfeldRussian {Gr�nfeld-Verteidigung, Russische Variante}
translate D Catalan {Katalanische Verteidigung}
translate D CatalanOpen {Katalanisch, offen}
translate D CatalanClosed {Katalanisch, geschlossen}
translate D QueensIndian {Dameninsche Verteidigung}
translate D NimzoIndian {Nimzoindische Verteidigung}
translate D NimzoIndianClassical {Nimzoindisch, Klassische Variante}
translate D NimzoIndianRubinstein {Nimzoinsisch, Rubinstein}
translate D KingsIndian {K�nigsindische Verteidigung}
translate D KingsIndianSamisch {K�nigsindisch, S�misch}
translate D KingsIndianMainLine {K�nigsindisch, Hauptvariante}
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
translate D FICSRelayedGames {�bertragene Partien}
translate D FICSFindOpponent {Gegner suchen}
translate D FICSTakeback {Zur�cknehmen}
translate D FICSTakeback2 {2 zur�cknehmen}
translate D FICSInitTime {Zeit (min)}
translate D FICSIncrement {Inkrement (s)}
translate D FICSRatedGame {Wertungspartie}
translate D FICSAutoColour {automatisch}
translate D FICSManualConfirm {manuell best�tigen}
translate D FICSFilterFormula {Filterformel anwenden}
translate D FICSIssueSeek {Partie anbieten}
translate D FICSChallenge {Herausfordern}
translate D FICSAccept {Nehmen Sie an?}
translate D FICSDecline {Ablehnen}
translate D FICSColour {Farbe ausw�hlen}
translate D FICSSend {senden}
translate D FICSConnect {Verbinden}
translate D FICSdefaultuservars {Standardvariablen verwenden}
translate D FICSObserveconfirm {Best�tige Beobachtung der Partie}
translate D FICSpremove {Premoves aktivieren}
translate D FICSObserve {Beobachten}
translate D FICSRatedGames {Bewertete Partien}
translate D FICSUnratedGames {Unbewertete Partien}
translate D FICSRated {Bewertet}
translate D FICSUnrated {Unbewertet}
translate D FICSRegisteredPlayer {Nur registrierte Spieler}
translate D FICSFreePlayer {Nur freie Spieler}
translate D FICSNetError {Netzwerkfehler\nKeine Verbindung zu }

translate D GameReview {Partieanalyse}
translate D GameReviewTimeExtended {Lange Bedenkzeit}
translate D GameReviewMargin {Fehlergrenze}
translate D GameReviewAutoContinue {Bei korrektem Zug automatisch weiter}
translate D GameReviewReCalculate {Verwende lange Bedenkzeit}
translate D GameReviewAnalyzingMovePlayedDuringTheGame {Analysiere den Partiezug}
translate D GameReviewAnalyzingThePosition {Analysiere Stellung}
translate D GameReviewEnterYourMove {Zug eingeben}
translate D GameReviewCheckingYourMove {�berpr�fe Antwort}
translate D GameReviewYourMoveWasAnalyzed {Antwort wurde analysiert}
translate D GameReviewYouPlayedSameMove {Gleicher Zug wie in der Partie}
translate D GameReviewScoreOfYourMove {BeWertung des Antwortzuges}
translate D GameReviewGameMoveScore {Bewertung des Partiezuges}
translate D GameReviewEngineScore {Bewertung der Engine}
translate D GameReviewYouPlayedLikeTheEngine {Gleicher Zug wie die Engine}
translate D GameReviewNotEngineMoveButGoodMove {Auch ein guter Zug}
translate D GameReviewMoveNotGood {Der Zug ist nicht gut}
translate D GameReviewMovesPlayedLike {Z�ge gespielt wie}
translate D GameReviewMovesPlayedEngine {Z�ge gespielt wie die Engine}

# Correspondence Chess Dialogs:
translate D CCDlgCGeneraloptions {Allgemeine Einstellungen}

translate D CCDlgLoginName  {Login Name:}
translate D CCDlgPassword   {Passwort:}
translate D CCDlgShowPassword {Passwort anzeigen}
translate D ExtHWConfigConnection {Hardware Konfigurieren}
translate D ExtHWPort {Schnittstelle}
translate D ExtHWEngineCmd {Engine Kommando}
translate D ExtHWEngineParam {Engine Parameter}
translate D ExtHWShowButton {Knopf in Werkzeugleiste anzeigen}
translate D ExtHWHardware {Hardware}
translate D ExtHWNovag {Novag Citrine}
translate D ExtHWInputEngine {Input Engine}
translate D ExtHWNoBoard {Kein Brett verbunden}
translate D NovagReferee {Nur Z�ge aufzeichnen}
translate D IEConsole {Input Engine Konsole}
translate D IESending {Sende Z�ge f�r}
translate D IESynchronise {Synchronisieren}
translate D IERotate  {Brett drehen}
translate D IEUnableToStart {Input Engine konnte nicht gestartet werden:}
translate D DoneWithPosition {Positionsbearbeitung beendet}
translate D Board {Brett}
translate D showGameInfo {Partieinformation anzeigen}
translate D autoResizeBoard {Brettgr��e automatisch berechnen}
translate D DockTop {Nach oben}
translate D DockBottom {Nach unten}
translate D DockLeft {Nach links}
translate D DockRight {Nach rechts}
translate D Undock {Fenster l�sen}
# ====== TODO To be translated ======
translate D AboutDatabase {About This Database}
#Gamelist
translate D ChangeIcon {Datenbank Icon �ndern...}
translate D NewGameListWindow {Neue Partieliste}
translate D LoadatStartup {Beim Starten laden}
translate D ShowHideDB {Datenbank anzeigen/verbergen}
translate D ChangeFilter {Filter �ndern}
translate D ChangeLayout {Sortierkriterien und Spaltenlayout laden/speichern/�ndern }
translate D ShowHideStatistic {Statistik anzeigen/verbergen}
translate D BoardFilter {Nur Partien, die gleich der aktuellen Brettstellung sind, anzeigen}
translate D CopyGameTo {Kopiere Partie nach}
translate D FindBar {Suchleiste}
translate D FindCurrentGame {Aktuelle Partie finden}
translate D DeleteGame {Partie l�schen}
translate D UndeleteGame {Partie wiederherstellen}
translate D ResetSort {Sortierung zur�cksetzten}

translate D ConvertNullMove {Null-Z�ge in Kommentare umwandeln}
translate D SetupBoard {Stellung eingeben}
translate D Rotate {Drehen}
translate D SwitchColors {Farbe wechseln}
translate D FlipBoard {Brett drehen}
translate D ImportPGN {Importiere PGN Partieen}
translate D ImportingFiles {Importiere PGN Dateien nach}
translate D ImportingFrom {Importiere von}
translate D ImportingIn {Importiere Partien nach}
translate D UseLastTag {Letzte Tags\nverwenden}
translate D Random {Zuf�llig}
translate D BackToMainline {Zur�ck zur Hauptvariante}
translate D LeaveVariant {Variante verlassen}
translate D Autoplay {Vorspielen}
translate D ShowHideCoords {Beschriftung ein/aus}
# ====== TODO To be translated ======
translate D ShowHideEvalBar {Show/Hide Evaluation Bar}
translate D ShowHideMaterial {Material ein/aus}
# ====== TODO To be translated ======
translate D SelectMarker {Select Marker}
translate D FullScreen {Vollbild}
translate D FilterStatistic {Filter Statistik}
translate D MakeCorrections {Korrigieren}
translate D Surnames {Nachnamen}
translate D Ambiguous {Mehrdeutig}
}
#Preferences Dialog
translate D OptionsToolbar "Werkzeugleiste"
translate D OptionsBoard "Schachbrett"
translate D OptionsBoardSize "Brettgr��e"
translate D OptionsBoardPieces "Figurensatz"
translate D OptionsInternationalization "Sprachumgebung"
translate D OptionsTablebaseDir "Bis zu 4 Verzeichnisse der Endspieltabellen ausw�hlen:"
translate D BestMoveArrow "Besten Zug anzeigen"
translate D NewLocalEngine "+ Neue Engine ..."

##########
#
# ECO Opening name translations:

translateECO D {
  Accelerated {, Beschleunigt}
  {: Accelerated} Beschleunigt
  Accepted {, Angenommen}
  {: Accepted} Angenommen
  Advance Vorsto�
  {as Black} {mit Schwarz}
  Attack Angriff
  Bishop L�ufer
  Bishop's L�ufer
  Classical Klassisch
  Closed Geschlossen
  {Closed System} {Geschlossenes System}
  Counterattack Gegenangriff
  Countergambit Gegengambit
  Declined {, Abgelehnt}
  Defence Verteidigung
  deferred verz�gert
  Deferred {, verz�gert}
  Early Fr�he
  Exchange Abtausch
  Game Partie
  Improved verbessert
  King's K�nigs
  Knight Springer
  Line Variante
  {Main Line} Hauptvariante
  Open Offen
  Opening Er�ffnung
  Queen's Damen
  Queenswap Damentausch
  Symmetrical Symmetrisch
  Variation Variante
  Wing Fl�gel
  with mit
  without ohne

  Alekhine Aljechin
  Averbakh Awerbach
  Botvinnik Botwinnik
  Chigorin Tschigorin
  Polugaevsky Polugajewski
  Rauzer Rauser
  Sveshnikov Sweschnikow

  Austrian �sterreichisch
  Berlin Berliner
  Bremen Bremer
  Catalan Katalanisch
  Czech Tschechisch
  Dutch Holl�ndisch
  English Englisch
  French Franz�sisch
  Hungarian Ungarisch
  Indian Indisch
  Italian Italienisch
  Latvian Lettisch
  Meran Meraner
  Moscow Moskau
  Polish Polnisch
  Prague Prager
  Russian Russisch
  Scandinavian Skandinavisch
  Scheveningen Scheveninger
  Scotch Schottisch
  Sicilian Sizilianisch
  Slav Slawisch
  Spanish Spanisch
  Swedish Schwedisch
  Swiss Schweizer
  Vienna Wiener
  Yugoslav Jugoslawisch

  {Accelerated Fianchetto} {Beschleunigtes Fianchetto}
  {Accelerated Pterodactyl} {Beschleunigter Pterodactylus}
  {Alekhine Defence} Aljechin-Verteidigung
  {Alekhine Variation} Aljechin-Variante
  {Alekhine: S�misch Attack} {Aljechin: Wiener System (S�misch-Angriff)}
  {Anderssen Opening} Anderssen-Er�ffnung
  {Anti-King's Indian} Anti-K�nigsindisch
  {Austrian Attack} {�sterreichischer Angriff}
  {Benko Gambit} Wolga-Gambit
  {Benko Opening} Benk�-Er�ffnung
  {Berlin Defence} {Berliner Verteidigung}
  Chameleon Cham�leon
  Chelyabinsk Tscheljabinsk
  {Classical Defence} {Klassische Verteidigung}
  {Spanish: Classical Defence} {Spanisch: Klassische (Cordel-) Verteidigung}
  {Classical Exchange} {Klassischer Abtausch}
  {Classical Variation} {Klassische Variante}
  {Closed Berlin} {Geschlossener Berliner}
  {Open Berlin} {Offener Berliner}
  {Bird's,} {Bird,}
  {Bird's Defence} Bird-Verteidigung
  {Bird's Deferred} {Verz�gerte Bird}
  {Bishop's Opening} L�uferspiel
  {Botvinnik System} Botwinnik-System
  {Central Variation} Zentralvariante
  {Centre Attack} Zentrumsangriff
  {Centre Game} Mittelgambit
  {Danish Gambit} {Nordisches Gambit}
  Dragon Drachen
  {Dutch Variation} {Holl�ndische Variante}
  {Early Exchange} {Fr�her Abtausch}
  {Early Queenswap} {Fr�her Damentausch}
  {English Attack} {Englischer Angriff}
  {English: King's} {Englisch: K�nigsbauer}
  {English Variation} {Englische Variante}
  {Englund Gambit} Englund-Gambit
  {Exchange Variation} Abtauschvariante
  {Fianchetto Variation} Fianchettovariante
  {Flohr Variation} Flohr-Variante
  {Four Knights} Vierspringer
  {Four Knights Game} Vierspringerspiel
  {Four Pawns} Vierbauern
  {Four Pawns Attack} Vierbauernangriff
  {French Variation} {Franz�sische Variante}
  {From Gambit} {Froms Gambit}
  {Goring Gambit} {G�ring-Gambit}
  {Grob Gambit} {Grobs Gambit}
  {Hungarian Defence} {Ungarische Verteidigung}
  {Indian Variation} {Indische Variante}
  {Italian Game} {Italienische Partie}
  KGD {Abgel. K�nigsgambit}
  {Classical KGD} {Klassisches abgelehntes K�nigsgambit}
  {Keres Variation} Keres-Variante
  KGA {Angen. K�nigsgambit}
  {KGA: Bishop's Gambit} K�nigsl�ufergambit
  {KGA: King's Knight Gambit} K�nigsspringergambit
  {King's Gambit} K�nigsgambit
  {King's Gambit Accepted} {Angen. K�nigsgambit}
  {King's Gambit Accepted (KGA)} {Angen. K�nigsgambit}
  {King's Indian} K�nigsindisch
  KIA {K�nigsindischer Angriff}
  {King's Knight Gambit} K�nigsspringergambit
  {King's Pawn} K�nigsbauer
  {Lasker Variation} {Lasker-Variante}
  {Latvian Gambit} {Lettisches Gambit}
  {Maroczy Bind} {Maroczy-Aufbau}
  {Marshall Variation} Marshall-Variante
  {Modern Attack} {Moderner Angriff}
  {Modern Steinitz} {Moderne Steinitz}
  {Modern Variation} {Moderne Variante}
  {Moscow Variation} {Moskauer Variante}
  Nimzo-Indian Nimzoindisch
  {Old Benoni} {Klassisches Benoni}
  {Old Indian} Altindisch
  {Old Indian Attack} {Altindisch i.A.}
  {Old Steinitz} Steinitz-Verteidigung
  {Open Game} {Offene Partie}
  {Poisoned Pawn} {Vergifteter Bauer}
  {Polish Variation} {Polnische Variante}
  {Polugaevsky Variation} {Polugajewski-Variante}
  {Queen's Gambit} Damengambit
  {Queen's Gambit Accepted} {Angen. Damengambit}
  QGA {Angen. Damengambit}
  {Queen's Gambit Accepted (QGA)} {Angenommenes Damengambit}
  {Reversed QGA} {Angen. Damengambit i.A.}
  QGD {Abgel. Damengambit}
  {Queen's Gambit Declined (QGD)} {Abgelehntes Damengambit}
  {Reversed QGD} {Abgel. Damengambit i.A.}
  {Queen's Indian} Damenindisch
  {Queen's Pawn} Damenbauer
  {Queen's Pawn Game} Damenbauerspiel
  {Reversed Slav} {Slawisch i.A.}
  {Rubinstein Variation} Rubinstein-Variante
  {Russian Game} {Russische Partie}
  {Russian Game (Petroff Defence)} {Russische Partie}
  {Russian-Three Knights Game} {Russisches Dreispringerspiel}
  {Scandinavian (Centre Counter)} Skandinavisch
  Schliemann J�nisch
  {Schliemann (J�nisch)} {J�nisch-Gambit (Schliemann)}
  {Scotch Opening} {Schottische Er�ffnung}
  {Sicilian Defence} {Sizilianische Verteidigung}
  {Sicilian Variation} {Sizilianische Variante}
  {Slav Defence} {Slawische Verteidigung}
  Smith-Morra Morra
  {Smith-Morra Accepted} {Angenommenes Morra-Gambit}
  {Smith-Morra Gambit} Morra-Gambit
  {Spanish (Ruy Lopez)} {Spanische Partie}
  {Start position} Ausgangsstellung
  {Steinitz Deferred} Rubinstein-Aufbau
  {Swedish Variation} {Schwedische Variante}
  {Swiss Variation} {Schweizer Variante}
  {Tarrasch's Gambit} {Tarrasch-Gambit}
  {Three Knights} Dreispringer
  {3 Knights} Dreispringer
  {Three Knights Game} Dreispringerspiel
  {Three Pawns Attack} Dreibauernangriff
  {Two Knights} Zweispringer
  {Two Knights Defence} Zweispringer-Verteidigung
  {Two Knights Variation} Zweispringer-Variante
  {Two Pawns} Zweibauern
  {Two Pawns Attack} Zweibauernangriff
  {Wing Gambit} Fl�gel-Gambit
  {Yugoslav Attack} {Jugoslawischer Angriff}
}


############################################################
#
# German help pages:


##########
# Contents
#
set helpTitle(D,Contents) "Inhaltsverzeichnis"
set helpText(D,Contents) {<h1>Inhaltsverzeichnis Scid-Hilfe</h1>


<h4>Start und allgemeine Hilfe</h4>
<ul>
<li><a Guide><b>Kurzanleitung</b> Benutzung von Scid</a> <red>(Zuerst lesen!)</red></li>
<li><a Hints><b>Hinweise</b> zum effizienteren Arbeiten mit Scid</a></li>
<li><a MainWindow>Das Scid-<b>Hauptfenster</b></a></li>
<li><a Menus>Die Scid-<b>Men�s</b></a></li>
<li><a Moves><b>Z�ge</b> eingeben</a></li>
<li><a Searches><b>Suchen</b> in Scid</a></li>
<li><a Clipbase>Die <b>Ablage</b>-Datenbank</a></li>
<li><a Annotating>Partien <b>kommentieren</b></a> </li>
</ul>

<h4>Andere Scid-Fenster</h4>
<ul>
<li><a Analysis><b>Analyse</b>-Fenster</a></li>
<li><a Reports><b>Berichte</b></a> </li>
<li><a Book><b>Buch</b>-Fenster</a></li>
<li><a Finder><b>Dateisuche</b>-Fenster</a></li>
<li><a Switcher><b>Datenbank-Umschalter</b></a></li>
<li><a PTracker><b>Figurenverteilung</b></a></li>
<li><a Graphs><b>Grafik</b>-Fenster</a></li>
<li><a Comment><b>Kommentareditor</b></a></li>
<li><a Crosstable><b>Turniertabellen</b>-Fenster</a></li>
<li><a GameList><b>Partieliste</b>-Fenster</a></li>
<li><a Import><b>Partie-Import</b>-Fenster</a></li>
<li><a PGN><b>PGN</b> (Partietext)-Fenster</a></li>
<li><a PList><b>Spielersuche</b></a></li>
<li><a PInfo><b>Spieler-Information</b></a></li>
<li><a TacticalGame><b>Trainingspartie</b>-Fenster</a></li>
<li><a SeriousGame><b>Ernste Partie</b></a></li>
<li><a CalVar><b>Training Varianten berechnen</b>-Fenster</a></li>
<li><a OpeningTrainer><b>Er�ffnungstrainer</b>-Fenster</a></li>
<li><a Tmt><b>Turniersuche</b></a></li>
<li><a Tree><b>Zugbaum</b>-Fenster</a></red></li>
</ul>

<h4>Weitere Hilfsprogramme und Informationen</h4>
<ul>
<li><a Maintenance><b>Datenbank-Wartung</b></a></li>
<li><a Sorting>Datenbank<b> sortieren</b></a></li>
<li><a Compact>Datenbank<b> komprimieren</b></a></li>
<li><a ECO><b>ECO</b>-Er�ffnungsklassifikation</a></li>
<li><a EPD><b>EPD</b>-Dateien</a></li>
<li><a Export>Partien in Textdateien <b>exportieren</b></a></li>
<li><a Cmdline><b>Kommandozeilen</b>-Optionen</a></li>
<li><a LaTeX>Scid und <b>LaTeX</b></a> </li>
<li><a Bookmarks><b>Lesezeichen</b></a></li>
<li><a Flags>Partie-<b>Kennzeichen</b> (Flags)</a></red></li>
<li><a Options><b>Optionen</b> und Pr�ferenzen</a></li>
<li><a Pgnscid><b>Pgnscid</b>: PGN-Dateien konvertieren</a></li>
<li><a NAGs><b>NAG</b>-Standard-Kommentarwerte</a></li>
<li><a Formats>Scids Datenbank-<b>Dateiformate</b></a></li>
<li><a Author>Kontakt-Information</a></li>
</ul>

<p><footer>(Aktualisiert: Scid 4.7, August 2018)</footer></p>
}


###############
### Topic Index

set helpTitle(D,Index) "Hilfe-Index"
set helpText(D,Index) {<h1>Scid: Hilfe-Index</h1>

<h3>A</h3>
<ul>
<li><a Clipbase>Ablage-Datenbank</a></li>
<li><a Analysis List>Analyse-Engines, Liste der</a></li>
<li><a Analysis>Analysefenster</a></li>
<li><a MainWindow Autoplay>Automatisches Vorspielen</a></li>
<li><a Author>Autor, Kontaktaufnahme</a></li>
</ul>

<h3>B</h3>
<ul>
<li><a Menus Edit>Bearbeiten-Men�</a></li>
<li><a Maintenance Cleaner>Bereiniger</a></li>
<li><a Tree Best>Beste Partien</a></li>
<li><a Graphs Rating>Bewertungsgraph</a></li>
<li><a GameList Browsing>Bl�ttern in Partien</a></li>
<li><a Searches Board>Brettsuche</a></li>
</ul>

<h3>D</h3>
<ul>
<li><a Finder>Dateisuche</a></li>
<li><a Formats>Dateiformate</a></li>
<li><a Menus File>Datei-Men�</a></li>
<li><a Formats>Datenbank-Dateiformate</a></li>
<li><a Compact>Datenbank-Komprimierung</a></li>
<li><a Sorting>Datenbank sortieren</a></li>
<li><a Switcher>Datenbank-Umschalter</a></li>
<li><a Maintenance>Datenbank-Wartung</a></li>
<li><a Maintenance Twins>Dubletten (doppelte Partien)</a></li>
</ul>

<h3>E</h3>
<ul>
<li><a ECO Browser>ECO-Auswertung</a></li>
<li><a ECO Codes>ECO-Codesystem</a></li>
<li><a ECO>ECO-Er�ffnungsklassifikation</a></li>
<li><a EPD>EPD-Dateien</a></li>
<li><a SeriousGame>Ernste Partie spielen</a></li>
<li><a Reports Opening>Er�ffnungsbericht</a></li>
<li><a ECO>Er�ffnungsklassifizierung (ECO)</a></li>
<li><a Repertoire>Er�ffnungsrepertoire</a></li>
<li><a Export>Exportieren, Partien in Textdateien</a></li>
</ul>

<h3>F</h3>
<ul>
<li><a Menus Windows>Fenster-Men�</a></li>
<li><a PTracker>Figurenverteilungs-Fenster</a></li>
<li><a Searches Filter>Filter</a></li>
<li><a Export>Filter, exportieren</a></li>
<li><a Graphs Filter>Filtergrafik</a></li>
</ul>

<h3>G</h3>
<ul>
<li><a Graphs>Grafikfenster</a></li>
</ul>

<h3>H</h3>
<ul>
<li><a MainWindow>Hauptfenster</a></li>
<li><a Menus Help>Hilfe-Men�</a></li>
<li><a Hints>Hinweise</a></li>
</ul>

<h3>I</h3>
<ul>
<li><a Import>Importieren</a></li>
<li><a Contents>Inhaltsverzeichnis</a></li>
</ul>

<h3>K</h3>
<ul>
<li><a Cmdline>Kommandozeilen-Optionen</a></li>
<li><a Comment>Kommentareditor</a></li>
<li><a NAGs>Kommentarzeichen</a></li>
<li><a Annotating>Kommentieren</a></li>
<li><a Compact>Komprimieren (Datenbank)</a></li>
<li><a Author>Kontaktinformation</a></li>
<li><a Crosstable>Turniertabellen</a></li>
<li><a Guide>Kurzanleitung f�r Scid</a></li>
</ul>

<h3>L</h3>
<ul>
<li><a LaTeX>LaTeX</a>-Ausgabeformat</li>
<li><a Bookmarks>Lesezeichen</a></li>
<li><a Maintenance Twins>L�schen, Dubletten</a></li>
</ul>

<h3>M</h3>
<ul>
<li><a Flags>Kennzeichen</a></li>
<li><a Searches Material>Material-/Muster-Suche</a></li>
<li><a Menus>Men�s</a></li>
</ul>

<h3>N</h3>
<ul>
<li><a NAGs>NAG-Kommentarwerte</a></li>
<li><a Maintenance Editing>Namen bearbeiten</a></li>
<li><a Maintenance Spellcheck>Namen, Schreibweisen</a></li>
<li><a Annotating Null>Nullz�ge</a></li>
</ul>

<h3>O</h3>
<ul>
<li><a Options>Optionen</a></li>
<li><a Appearance>Oberfl�che anpassen</a></li>
</ul>

<h3>P</h3>
<ul>
<li><a Searches Header>Partiedaten-Suche</a></li>
<li><a GameList>Partielisten</a></li>
<li><a Flags>Partie-Kennzeichen</a></li>
<li><a Menus Game>Partie-Men�</a></li>
<li><a PGN>PGN-Fenster</a></li>
<li><a Pgnscid>Pgnscid</a></li>
</ul>

<h3>R</h3>
<ul>
</ul>

<h3>S</h3>
<ul>
<li><a Moves>Schachz�ge eingeben</a></li>
<li><a Maintenance Spellcheck>Schreibkorrektur von Namen</a></li>
<li><a Sorting>Sortieren einer Datenbank</a></li>
<li><a Reports Player>Spielerbericht</a></li>
<li><a PInfo>Spielerinformation</a></li>
<li><a PList>Spielersuche</a></li>
<li><a Searches>Suchen</a></li>
<li><a Menus Search>Suchen-Men�</a></li>
<li><a Searches Filter>Such-Filter</a></li>
</ul>

<h3>T</h3>
<ul>
<li><a Tmt>Turniersuche</a></li>
<li>Training</li>
<ul>
<li><a OpeningTrainer>Er�ffnungstrainer</a></li>
<li><a CalVar>Varianten berechnen</a></li>
</ul>
</ul>

<h3>V</h3>
<ul>
<li><a Annotating Vars>Varianten</a></li>
</ul>

<h3>W</h3>
<ul>
<li><a Maintenance>Wartung</a></li>
<li><a Menus Tools>Werkzeug-Men�</a></li>
</ul>

<h3>X</h3>
<ul>
<li><a CCXfcc>Xfcc-Unterst�tzung</a></li>
</ul>

<h3>Z</h3>
<ul>
<li><a Options Fonts>Zeichens�tze</a></li>
<li><a Tree>Zugbaumfenster</a></li>
<li><a Moves>Z�ge eingeben</a></li>
<li><a GameList Browsing>Zusammenf�hren, Partien</a></li>
</ul>

<p><footer>(Aktualisiert: Scid 3.6.23, M�rz 2008)</footer></p>
}


###############
### Quick guide

set helpTitle(D,Guide) "Kurzanleitung zur Benutzung von Scid"
set helpText(D,Guide) {<h1>Kurzanleitung zur Benutzung von Scid</h1>
<p>
Scid ist eine Schachdatenbank, mit welcher man Partiesammlungen
nach einer Vielzahl von Kriterien durchsuchen kann, Partien editieren
und mit Hilfe von Winboard- und UCI-kompatiblen Schachprogrammen
analysieren kann.
</p>
<p>
Scid benutzt ein eigenes, spezielles Drei-Dateien-Datenbankformat,
welches sehr schnell und kompakt ist, aber es kann auch das PGN-
(Portable Game Notation) Format lesen und schreiben. Scids
<a PGN>PGN-Fenster</a> zeigt die Notation der aktuellen Partie im
PGN-Format.
</p>
<p>
Man kann in Scid Partien zur Datenbank hinzuf�gen, mit Hilfe
der Tastatur oder der Maus. Mehr Details unter der Hilfeseite f�r
<a Moves>Zugeingabe</a>.
</p>
<p>
Man kann mit Scid auch <a PGN>PGN</a> - Partiesammlungen bearbeiten:
durch Import der PGN-Datei in Scids - <a Import>Import</a> Fenster
oder direkt durch �ffnen von PGN-Dateien in Scid. Jedoch: PGN-Dateien
benn�tigen mehr Speicher und werden langsamer geladen. F�r gro�e PGN - Partiesammlungen
wird empfohlen, sie mit Hilfe des Scid-Programms <a Pgnscid>pgnscid</a>
in eine Scid-Datenbank umzuwandeln (dabei bleibt die PGN-Datei erhalten).
Die Bearbeitung von PGN-Datei ist eingeschr�nkt. Man kann Partien hinzuf�gen
und l�schen, aber keine Partien �berschreiben.
</p>
<p>
Das <a MainWindow>Hauptfenster</a> von Scid (mit dem grafischen
Schachbrett) zeigt Details der aktuellen Partie und Datenbank. Man
kann zu gleicher Zeit bis zu vier Datenbanken ge�ffnet haben (f�nf
inklusive der <a Clipbase>Ablage-Datenbank</a>), und jede hat eine
eigene aktuelle Partie. (Die Partie mit der Nr. 0 dient zu Eingabe
einer neuen Partie und ist nicht Bestandteil der Datenbank).
Man kann zwischen den offenen Datenbanken im
<a Menus File>Datei-Men�</a> umschalten.
</p>
<p>
F�r zus�tzliche Information lesen Sie bitte die anderen
Hilfe-Seiten, die im <a Index>Index</a> aufgef�hrt sind.
</p>
<p>
<a Author>Kontaktinformationen �ber den Autor von Scid</a> findet man in
der entsprechenden Hilfeseite.
</p>

<p><footer>(Aktualisiert: Scid 4.7, August 2018)</footer></p>
}


###############
### Hints page:

set helpTitle(D,Hints) "Scid Hinweise"
set helpText(D,Hints) {<h1>Scid Hinweise</h1>
<p>
Diese Seite enth�lt einige n�tzliche Hinweise in Form von Fragen und
Antworten, um Ihnen zu helfen, Scids F�higkeiten besser zu nutzen.
Wenn Sie das erste Mal mit Scid arbeiten, lesen Sie bitte zuerst die
<a Guide>Kurzanleitung</a> zur Benutzung von Scid.
Die meisten Informationen auf dieser Seite finden Sie detailliert auf
den anderen Hilfeseiten, die im <a Index>Hilfe-Index</a>
aufgef�hrt sind.
Falls Sie einen n�tzlichen Hinweis haben, der dieser Seite hinzugef�gt
werden sollte, senden Sie ihn bitte (in Englisch) an den
<a Author>Autor von Scid</a>.
</p>

<h4>Kann Scid eine Datenbank automatisch beim Start laden?</h4>
<p>
Ja, Sie k�nnen Datenbanken, PGN-Dateien oder <a EPD>EPD-Dateien</a>
in der Kommandozeile angeben. Beispiel:
<ul>
<li> <b>scid  datenbank  partien.pgn.gz</b></li>
</ul>
l�dt die Scid-Datenbank <b>datenbank</b> und gleichzeitig
die mit gzip komprimierte PGN-Datei <b>partien.pgn.gz</b>.
</p>

<h4>Gibt es eine leichtere M�glichkeit, die Brettgr��e
zu �ndern, als �ber das Optionen-Men�?</h4>
<p>
Ja, Sie k�nnen mit den Tastenkombinationen <b>Control+Shift+LeftArrow</b>
und <b>Control+Shift+RightArrow</b> das Brett verkleinern bzw. vergr��ern.
</p>

<h4>Wenn ich trainiere, indem ich eine Partie nachspiele, m�chte ich
nicht, dass Scid den n�chsten Zug im Informationsbereich anzeigt.
Kann ich ihn verstecken?</h4>
<p>
Sie k�nnen den n�chsten Zug verstecken, indem Sie die <b>rechte</b>
Maustaste im Informationsbereich dr�cken und im darauf erscheinenden
Men� <b>Verstecke n�chsten Zug</b> ausw�hlen.
</p>

<h4>Wie kann ich den ECO-Er�ffnungsschl�ssel der aktuellen Position
ermitteln?</h4>
<p>
Der ECO-Schl�ssel wird in der letzten Zeile des Informationsbereichs
angezeigt, unterhalb des Schachbretts im <a MainWindow>Hauptfenster</a>,
wenn Sie die ECO-Datei (<b>scid.eco</b>) geladen haben.<br>
Auf der <a ECO>ECO-Code</a> Hilfeseite wird erkl�rt, wie man die ECO-Datei
l�dt und die Optionen so einstellt, dass sie jedesmal beim Programmstart
geladen wird.
</p>

<h4>Beim Eingeben einer Partie bin ich gerade beim 30. Zug, als ich
bemerke, dass der 10. Zug falsch eingegeben wurde. Wie kann ich ihn
korrigieren und dabei alle nachfolgenden Z�ge erhalten?</h4>
<p>
Sie k�nnen das im <a Import>Import</a>-Fenster tun; siehe die Hilfeseite
<a Moves Mistakes>Zugeingabe</a> f�r weitere Informationen.
</p>

<h4>Wie kopiere ich Partien von einer Datenbank in die andere?</h4>
<p>
Im <a Switcher>Datenbank-Umschalterfenster</a>: kopieren Sie alle
Dateien im Datenbank-<a Searches Filter>Filter</a>, indem Sie sie mit
der Maus von einer Datenbank in die andere ziehen.
</p>

<h4>Jedesmal, wenn ich einen bereits vorhandenen Zug eingebe, erhalte
ich ein "Zug ersetzen?"-Dialogfenster. Wie kann ich das verhindern?</h4>
<p>
Schalten Sie es aus mit der Option <b>Fragen vor Ersetzen</b> im Men�
<menu>Optionen: Z�ge</menu>.
Oder gew�hnen Sie sich an, Z�ge mit der rechten Maustaste zur�ckzunehmen,
die jeweils den letzen Zug der Partie entfernt, wenn Sie sich
am Partiende befinden.
</p>

<h4>Wie �ndere ich die Spaltenbreite im Partielistenfenster?</h4>
<p>
Klicken Sie die jeweilige Spalten�berschrift mit der linken oder
rechten Maustaste an und w�hlen Sie <b>Konfigurieren</b>.
</p>

<h4>Wie kann ich das Zugbaumfenster statt f�r die ganze Datenbank nur
f�r eine Auswahl von Partien nutzen?</h4>
<p>
Nutzen Sie die <a Clipbase>Ablage-Datenbank</a>. W�hlen Sie den
Datenbank-Filter so, dass er die von Ihnen gew�nschten Partien enth�lt,
dann kopieren Sie diese �ber den <a Switcher>Datenbank-Umschalter</a>
in die Ablage-Datenbank. Danach brauchen Sie nur noch das Zugbaumfenster
in der Ablage-Datenbank zu �ffnen.
</p>

<h4>Der Zugbaum ist bei gro�en Datenbanken zu langsam. Wie kann ich
ihn beschleunigen?</h4>
<p>
Sichern Sie die Cache-Datei h�ufig, um die Zugbaum-Resultate zum
sp�teren Gebrauch zu bewahren. Zu den Details siehe den Abschnitt
<b>Caching</b> auf der <a Tree>Zugbaum</a>-Hilfeseite.
</p>

<h4>Wie kann ich direkt die PGN-Notation der Datei bearbeiten?</h4>
<p>
Im <a PGN>PGN</a>-Fenster k�nnen sie die aktuelle Partie nicht bearbeiten,
aber Sie k�nnen immer noch die PGN-Notation editieren, indem Sie das
Fenster <a Import>Partie importieren</a> verwenden.
�ffnen Sie es (mit <b>Control+Shift+I</b>) und w�hlen Sie
<b>Aktuelle Partie einf�gen</b>, dann bearbeiten Sie die Partie
und klicken danach <b>Importieren</b> an.

</p>

<h4>In meiner Datenbank sind einige Spielernamen unterschiedlich
geschrieben. Wie kann ich sie korrigieren?</h4>
<p>
Mit den Kommandos im Men� <menu>Datei: Wartung</menu> k�nnen Sie einzelne
Namen editieren oder auch Schreibweisen aller Namen �berpr�fen.
Siehe die Seite <a Maintenance Editing>Wartung</a>.
</p>

<h4>Ich habe zwei Datenbanken ge�ffnet: eine mit meinen eigenen Partien
und eine gro�e Datenbank mit Gro�meisterpartien. Wie kann ich eine
meiner Partien mit denen in der gro�en Datenbank vergleichen?</h4>
<p>
�ffnen Sie das <a Tree>Zugbaumfenster</a> in der gro�en Datenbank und
und wechseln Sie mit Hilfe des Datenbankwechslers in die zu
vergleichende Datenbank.
</p>

<p><footer>(Aktualisiert: Scid 3.6.28, August 2008)</footer></p>
}


###############
### Main window

set helpTitle(D,MainWindow) "Scid Hauptfenster"
set helpText(D,MainWindow) {<h1>Scid Hauptfenster</h1>
<p>
Das Hauptfenster in Scid zeigt die aktuelle Stellung der jeweiligen
Partie und Information �ber diese Partie und die Datenbank.
Separate Hilfeseiten beschreiben die <a Menus>Men�s</a> und die
<a Moves>Zugeingabe</a>.
</p>

<h3>Symbolleiste: Navigieren durch die Partie</h3>
<p>
Die direkt unter dem Schachbrett angebracht Symbole haben die
folgende Bedeutung (von links nach rechts):
<ul>
<li> <button tb_start> Gehe zum Beginn der Partie. </li>
<li> <button tb_prev> Gehe einen Zug zur�ck. </li>
<li> <button tb_next> Gehe einen Zug vor. </li>
<li> <button tb_end> Gehe zum Ende der Partie. </li>
</ul>

<h4><name Autoplay>Automatisches Vorspielen</name></h4>
<p>
Im diesem Modus spielt Scid automatisch die Z�ge in der
aktuellen Partie vor, bis zum Spielende. Die Zeit zwischen den Z�gen
kann im Men� <menu>Optionen: Z�ge</menu> eingestellt werden und wird
mit "Optionen speichern" gesichert.
</p>
<p>
Die Tastenkombination <b>Strg+Z</b> startet oder stoppt das autom.
Vorspielen, zus�tzlich kann das autom. Vorpielen auch durch
Dr�cken der <b>Esc</b>-Taste beendet werden.
</p>
<p>
Wenn der Modus "Automatisches Vorspielen" beim ge�ffneten
<a Analysis>Analysefenster</a> (Engine 1) gestartet wird, so wird
die von der Engine berechnte jeweilige Fortsetzung als Variante jedem Zug
hinzugef�gt <term>Autom. Kommentieren</term>. Siehe auch die
Hilfeseite zum <a Analysis>Analysefenster</a>.
</p>

<h3>Der Informationsbereich</h3>
<p>
Der Bereich unter dem Schachbrett, mit Informationen �ber die
Partie, wird <term>Informationsbereich</term> genannt. Die ersten 3
Zeilen zeigen Information zu den Spielern, Ergebnis, ECO-Code, Datum,
Ort und Ereignis. Die vierte Zeile zeigt die Informationen zur
aktuellen Stellung sowie den n�chsten Zug.
</p>
<p>
Die f�nfte Zeile zeigt den <a ECO>ECO-Code</a> der aktuelle Stellung,
falls enthalten in der gerade benutzen ECO-Datei.
</p>
<p>
Der Informationsbereich hat ein Men�, welches man mit der
rechten Maustaste aktivieren kann. Hier�ber kann man bestimmte
Informationen zum Spiel zeigen oder verstecken sowie Kennzeichen
f�r die aktuelle Partie setzten und l�schen. Man kann das
Men� auch �ber die <b>[F9]</b> Funktionstaste erreichen.
</p>

<h3>Die Statusanzeige</h3>
<p>
Die Statusanzeige zeigt Information �ber die aktuelle
Datenbank. Das erste Feld zeigt den Partiestatus an: <b>XX</b>
bedeutet, die Partie wurde ge�ndert, aber noch nicht
gespeichert, w�hrend <b>--</b> bedeutet, es gibt keine
�nderungen, und <b>%%</b> zeigt an, dass die Datenbank
schreibgesch�tzt ge�ffnet wurde.
</p>
<p>
Wenn man eine Datenbank immer schreibgesch�tzt �ffen will,
kann man auch die Rechte f�r die entsprechenden Scid-Dateien
setzen, oder zumindestens die der Indexdatei; z.B. (unter Linux) durch
den Befehl: <b>chmod a-w datenbank1.si3</b>.
Danach �ffnet Scid die entsprechende Datenbank immer
schreibgesch�tzt.
</p>
<p>
Die Statusanzeige zeigt auch, wieviel Spiele im aktuellen
<a Searches Filter>Filter</a>
sind.
</p>

<p><footer>(Aktualisiert: Scid 5.0.2, August 2023)</footer></p>
}


######################
### Menus help screen:

set helpTitle(D,Menus) "Men�s"
set helpText(D,Menus) {<h1>Die Scid-Men�s</h1>

<h3><name File>Datei</name></h3>
<ul>
<li><menu>Neu</menu>: Legt eine neue, leere Scid-Datenbank an.</li>
<li><menu>�ffnen</menu>: �ffnet eine existierende Scid-Datenbank.</li>
<li><menu>Schlie�en</menu>: Schlie�t die aktive Scid-Datenbank.</li>
<li><menu>Finder</menu>: �ffnet das <a Finder>Dateisuche</a>-Fenster.</li>
<li><menu>Lesezeichen</menu>: Das <a Bookmarks>Lesezeichen</a>-Men� mit
     einigen Lesezeichen-Funktionen.</li>
<li><menu>Wartung</menu>: Datenbank-<a Maintenance>Wartungs</a>-Funktionen.
    </li>
<ul>
  <li><menu>Wartungsfenster</menu>: �ffnet/schlie�t das
      Datenbank-Wartungsfenster.</li>
  <li><menu>Partien ECO-klassifizieren</menu>: Bestimmt den
      <a ECO>ECO-Code</a> f�r alle Partien der Datenbank neu.</li>
  <li><menu>Dubletten l�schen</menu>: Findet <a Maintenance Twins>Dubletten</a>
      in der Datenbank.</li>
  <li><menu>Namen</menu>: Ersetzt alle Vorkommen eines Spieler-,
      Ereignis-, Ort- oder Rundeneintrags.</li>
</ul>
<li><menu>Schreibschutz</menu>: Markiert die aktive Datenbank als schreibgesch�tzt.</li>
<li><menu>Datenbank 1/2/3/4/5</menu>: Mit diesen Kommandos k�nnen Sie
    zwischen den vier verf�gbaren Datenbanken und der
    <a Clipbase>Ablage-Datenbank</a> wechseln.</li>
<li><menu>Ende</menu>: Beendet Scid. </li>
</ul>

<h3><name Edit>Bearbeiten</name></h3>
<ul>
<li><menu>Variante hinzuf�gen</menu>: F�gt eine neue, leere Variante zum n�chsten
    Zug hinzu bzw. zum vorherigen, falls es noch keinen n�chsten Zug gibt.</li>
<li><menu>Variante l�schen</menu>: �ffnet ein Varianten-Untermen� f�r
    den aktuellen Zug, um eine Variante zu l�schen.</li>
<li><menu>Als erste Variante setzen</menu>: Macht eine Variante zur
    ersten Variante des aktuellen Zuges.</li>
<li><menu>Variante als Hauptvariante setzen</menu>: Tauscht eine Variante
    mit der Partiefolge aus.</li>
<li><menu>Entfernen</menu>: Entfernt alle Kommentare oder Varianten
    aus der aktuellen Partie.</li>
<br>
<li><menu>Ablage leeren</menu>: Leert die
    <a Clipbase>Ablage</a>-Datenbank.</li>
<li><menu>Partie in Ablage kopieren</menu>: Kopiert die aktuelle Partie
    in die <a Clipbase>Ablage</a>-Datenbank.</li>
<li><menu>Partie aus Ablage einf�gen</menu>: F�gt die aktive Partie der
    <a Clipbase>Ablage</a> als aktive Partie in die aktuelle Datenbank
    ein.</li>
<br>
<li><menu>Stellungseingabe</menu>: Legt die Ausgangsstellung f�r die
    aktuelle Partie fest.</li>
<li><menu>Stellung einf�gen</menu>: F�gt den markierten Text
    (Zwischenablage) als Ausgangsstellung ein.</li>
</ul>

<h3><name Game>Partie</name></h3>
<ul>
<li><menu>Neue Partie</menu>: Verwirft alle nicht gesicherten �nderungen
     und beginnt eine neue Partie ab der Grundstellung.</li>
<li><menu>Lade Erste/Vorherige/N�chste/Letzte Partie</menu>: Diese Men�punkte
    laden die erste, vorherige, n�chste bzw. letzte Partie im <a Searches Filter>Filter</a>.</li>
<li><menu>Partie wiederladen</menu>: L�dt die aktuelle Partie erneut, wobei
    alle bisherigen �nderungen verworfen werden.</li>
<li><menu>Lade Partie Nummer</menu>: L�dt die Partie mit der angegebenen
    Nummer in die aktuelle Datenbank.</li>
<br>
<li><menu>Partie ersetzen</menu>: Sichert die aktuelle Partie, wobei sie
    die Originalversion in der Datenbank ersetzt.</li>
<li><menu>Partie speichern</menu>: Sichert die aktuelle Partie als neue
    Partie, die ans Ende der Datenbank angeh�ngt wird.</li>
<br>
<li><menu>Er�ffnung identifizieren</menu>: Findet die letztm�gliche
    Position der aktuellen Partie in der ECO-Datei.</li>
<li><menu>Zugnummer</menu>: Geht zu der angegebenen Zugnummer in
    der aktuellen Partie.</li>
<li><menu>Finde Neuerung</menu>: Findet den ersten Zug der aktuellen Partie,
    der vorher noch nie gespielt wurde.</li>
</ul>

<h3><name Search>Suchen</name></h3>
<ul>
<li><menu>Filter zur�cksetzen</menu>: Setzt den <a Searches Filter>Filter</a>
    zur�ck, so dass er alle Partien enth�lt.</li>
<li><menu>Filter negieren</menu>: Invertiert den Filter, so dass er alle
    vorher ausgeschlossenen Partien enth�lt.</li>
<br>
<li><menu>Brett</menu>: Sucht die
    <a Searches Board>aktuelle Brettposition</a>.</li>
<li><menu>Partiedaten</menu>: Sucht nach <a Searches Header>Partiedaten</a>
    wie z.B. Spielernamen.</li>
<li><menu>Material/Muster</menu>: Sucht nach
    <a Searches Material>Material</a> oder Stellungsmustern</a>.</li>
<br>
<li><menu>Turniersuche</menu>: �ffnet/schlie�t den
    <a Tmt>Turniersuche</a>.</li>
<li><menu>Mit Suchoptionsdatei</menu>: Sucht mit Hilfe von
    <a Searches Settings>Einstellungen</a> aus einer Suchoptionsdatei.</li>
</ul>

<h3><name Windows>Fenster</name></h3>
<ul>
<li><menu>Kommentareditor</menu>: �ffnet/schlie�t das
    <a Comment>Kommentareditor</a>-Fenster.</li>
<li><menu>PGN-Fenster</menu>: �ffnet/schlie�t das
    <a PGN>PGN-Fenster</a>.</li>
<br>
<li><menu>Partieliste</menu>: �ffnet/schlie�t das
    <a GameList>Partielistenfenster</a>.</li>
<li><menu>Datenbank-Umschalter</menu>: �ffnet/schlie�t den
    <a Switcher>Datenbank-Umschalter</a>, mit dem man auf einfache Weise zu einer
    anderen Datenbank wechseln oder Partien zwischen Datenbanken kopieren kann.</li>
<li><menu>Turniertabelle</menu>: Erstellt eine
    Turnier-<a Crosstable>Turniertabelle</a> f�r die aktuelle Partie. </li>
<li><menu>ECO-Auswertung</menu>: �ffnet/schlie�t das Fenster
    <a ECO browser>ECO-Auswertung</a>.</li>
<li><menu>Statistik</menu>: �ffnet/schlie�t das
    <term>Filter-Statistikfenster</term>, welches eine Gewinn/Verlust-Zusammenstellung
    aller Partien im <a Searches Filter>Filter</a> liefert.</li>
<li><menu>Zugbaum</menu>: �ffnet/schlie�t das <a Tree>Zugbaumfenster</a>.</li>
</ul>

<h3><name Tools>Werkzeuge</name></h3>
<ul>
<li><menu>Analyse-Engine</menu>: Startet/beendet die "Schachanalyse-Engine",
    die die Auswertung der aktuellen Position
    im <a Analysis>Analysefenster</a> darstellt.</li>
<li><menu>Analyse-Engine #2</menu>: Startet/beendet eine zweite
    "Schachanlyse-Engine".</li>
<li><menu>E-Mail-Manager</menu>: �ffnet/schlie�t den <a Email>E-Mail-Manager</a>
    f�r Fernschachpartien.</li>
<br>
<li><menu>Rel. Filtergrafik</menu>: �ffnet das <a Graphs>Fenster f�r die Relative Filtergrafik</a></li>
<li><menu>Abs. Filtergrafik</menu>: �ffnet das <a Graphs>Fenster f�r die Absolute Filtergrafik</a></li>
<li><menu>Er�ffnungsbericht</menu>: Erstellt einen <a Reports Opening>Er�ffnungsbericht</a>
    zur aktuellen Position.</li>
<li><menu>Figurenverteilung</menu>: �ffnet das Fenster <a PTracker>Figurenverteilung</a>.
    </li>
<li><menu>Spieler-Information</menu>: Gibt <a PInfo>Spieler-Informationen</a>
    f�r einen Spieler der aktuellen Partie aus.</li>
<li><menu>ELO-Zahl-Verlauf</menu>: gibt den
    <a Graphs Rating>ELO-Zahl-Verlauf</a> aus.</li>
<li><menu>Partie-Bewertungsgraph</menu>: Gibt den
    <a Graphs Score>Partie-Bewertungsgraph</a> aus.</li>
<br>
<li><menu>Partie exportieren</menu>: Schreibt die aktuelle Partie in eine
    Textdatei im PGN-, HTML- oder LaTeX-Format. Siehe die
    <a Export>Export</a>-Hilfeseite.</li>
<li><menu>Alle Partien im Filter exportieren</menu>: Schreibt alle Partien
    im Such-<a Searches Filter>Filter</a> in eine Textdatei im PGN-, HTML-
    oder LaTeX-Format. Siehe die <a Export>Export</a>-Hilfeseite.</li>
<br>
<li><menu>Eine PGN-Partie importieren</menu>: �ffnet das <a Import>Importfenster</a>,
    um den Inhalt einer Partie im <a PGN>PGN-Format</a> direkt
    einzutippen oder einzuf�gen.</li>
<li><menu>Datei mit PGN-Partien importieren</menu>: Importiert eine ganze
    Datei mit Partien im PGN-Format in die aktuelle Datenbank.</li>
<br>    
<li><menu>Starte Engine1</menu>: Starte direkt die letzte ausgew�hlte Engine1 im Analysemodus</li>  
<li><menu>Starte Engine2</menu>: Starte direkt die letzte ausgew�hlte Engine2 im Analysemodus</li>  
</ul>

<h3><name Options>Optionen</name></h3>
<p>
Dieses Men� stellt einige Eintr�ge bereit, um die meisten konfigurierbaren
Optionen von Scid einzustellen.
Der Men�punkt <menu>Autom. speichern bei Beenden</menu> sichert die aktuellen
Optionen  in der Datei "<b>~/.scid/scidrc</b>" (bzw.
<b>scid.opt</b> im Verzeichnis des ausf�hrbaren Scid-Programms f�r Windows-User);
diese Datei wird bei jedem Programmstart von Scid geladen.
</p>

<h3>Hilfe</h3>
<p>
Dieses Men� enth�lt die Hilfe-Funktionen sowie Zugriff auf das
"Tip-des-Tages"-Fenster oder das Startfenster, welches Informationen
�ber die Dateien liefert, die Scid beim Programmstart geladen hat.
</p>

<p><footer>(Aktualisiert: Scid 3.6.21, Dezember 2007)</footer></p>
}


########################
### Entering moves help:

set helpTitle(D,Moves) "Z�ge eingeben"
set helpText(D,Moves) {<h1>Schachz�ge eingeben</h1>
<p>
In Scid k�nnen Sie die Partiez�ge mit der Maus oder �ber die
Tastatur eingeben. Wenn Sie den Mauszeiger auf ein Feld bewegen,
wird dieses und ein weiteres Feld seine Farbe �ndern, falls es
einen legalen Zug auf dieses bzw. von diesem Feld gibt. Das ist
der <term>Zugvorschlag</term>. Sie k�nnen diesen Zug einfach durch
Klicken der <term>linken</term> Maustaste ausf�hren. Falls Sie der
Zugvorschlag st�rt, k�nnen Sie ihn im Optionsmen� abschalten.
</p>
<p>
Um einen anderen als den vorgeschlagenen Zug auszuf�hren, k�nnen Sie
die <term>linke</term> Maustaste verwenden: Dr�cken Sie einfach die
Taste �ber einem Feld und lassen Sie sie �ber einem anderen Feld los.
</p>
<p>
Wenn Sie es vorziehen, Z�ge mit zwei Mausklicks auszuf�hren statt mit
gedr�ckter Maustaste, k�nnen Sie die <term>mittlere</term> Taste
verwenden: Klicken Sie erst das eine Feld an, danach das andere.
</p>

<h4>Einen Zug zur�cknehmen</h4>
<p>
Um einen Zug zur�ckzunehmen, dr�cken Sie die rechte Maustaste. Damit gehen
Sie einen Zug zur�ck; gleichzeitig l�schen Sie diesen Zug, falls es der
letzte Zug der Partie oder einer Variante war.
</p>

<h4>Alte Z�ge ersetzen</h4>
<p>
Wenn Sie einen Zug an einer Stelle in der Partie eingeben, wo bereits
ein Zug existiert, wird Scid Sie in einem Dialogfenster fragen, ob Sie
wirklich den alten Zug ersetzen wollen (der alte Zug und alle nachfolgenden
sind dann verloren) oder statt dessen den neuen Zug als Variante eingeben
wollen. Manche Leute m�gen dieses Dialogfenster als st�rend empfinden
und wollen alte Z�ge immer ersetzen. Sie k�nnen es daher im Men�
<menu>Optionen: Z�ge</menu> mit der Option "<i>Vor Ersetzen nachfragen</i>"
abschalten.
</p>

<h4><name Trial>Der Testmodus</name></h4>
<p>
Wenn Sie eine Partie nachspielen und eine Position erreichen, wo Sie
eine alternative Variante am Brett ausprobieren wollen, ohne die Partie
zu ver�ndern, w�hlen Sie <b>Variante testen</b> im Men� <menu>Bearbeiten</menu>,
um den Testmodus einzuschalten. In diesem Modus k�nnen Sie Z�ge eingeben
und die Partie zeitweilig ver�ndern; sobald Sie den Testmodus verlassen,
kehren Sie zur Ausgangsposition zur�ck.
</p>

<h3><name Mistakes>Fehler korrigieren</name></h3>
<p>
Wenn Sie eine Partie eingeben und pl�tzlich einige Z�ge vorher einen
falschen Zug bemerken, k�nnen Sie diesen korrigieren, ohne die
nachfolgenden Z�ge zu verlieren. Der einzige Weg besteht darin, die
PGN-Darstellung der Datei zu bearbeiten: �ffnen Sie das
<a Import>Import</a>-Fenster, w�hlen Sie "Aktuelle Partie einf�gen",
korrigieren Sie den falschen Zug, und w�hlen Sie dann "Importieren".
</p>

<h3>Zugeingabe �ber die Tastatur</h3>
<p>
Um Z�ge �ber die Tastatur einzugeben, dr�cken Sie einfach die jeweiligen
Buchstaben- und Zahlentasten. Die Z�ge sollten in <term>SAN-Notation</term>
<i>ohne</i> die Symbole f�r Schlagen (x) oder Umwandeln (=) eingegeben
werden. Gro�- und Kleinschreibung wird ignoriert, Sie k�nnen also
beispielsweise [n][f][3] anstelle von Nf3 eingeben  -- beachten Sie
aber die Anmerkung weiter unten zu den Konflikten bei Bauernz�gen.
</p>
<p>
Um sicherzustellen, dass kein Zug in einem anderen enthalten ist,
lautet die Eingabe f�r die kurze und lange Rochade [0][K] resp. [0][Q]
anstelle der �blichen Notation 0-0 bzw. 0-0-0.
</p>
<p>
Wenn Sie einen Zug eingeben, zeigt die Statusleiste die Liste der
m�glichen Z�ge an. Sie k�nnen jederzeit die [Leertaste] dr�cken, um
den ersten m�glichen Zug der Liste als Eingabe auszuw�hlen.
Um ein Zeichen zu l�schen, dr�cken Sie [R�ck] oder [Entf].
</p>
<p>
<b>Beachten</b> Sie, dass ein Kleinbuchstabe zuerst als Bauer
interpretiert wird; mit [b] kann also ein Bauer oder L�ufer ("Bishop")
gemeint sein, im Zweifelsfall m�ssen Sie daher ein gro�es [B] f�r den
L�ufer verwenden.
</p>

<h4>Automatische Zugerg�nzung</h4>
<p>
Im Options-Men� k�nnen Sie die <term>Automatische Zugerg�nzung</term>
ein- oder ausschalten.
Mit Zugerg�nzung wird ein Zug ausgef�hrt, sobald er durch Ihre Eingabe
von jedem anderen m�glichen Zug unterschieden werden kann. Beispielsweise
m��ten Sie mit automatischer Zugerg�nzung in der Ausgangsstellung nur
[n][f] statt <b>Nf3</b> eintippen.
</p>

<h3><name Null>Nullz�ge eingeben</name></h3>
<p>
<a Annotating Null>Null</a>- (leere) Z�ge k�nnen in Varianten n�tzlich
sein, wenn Sie den Zug einer Seite auslassen wollen. Sie k�nnen einen
Nullzug mit der Maus eingeben, indem Sie einen K�nig mit dem anderen
schlagen, oder mit der Tastatur, indem Sie "<b>--</b>" eingeben (d.h.
die Minustaste zweimal dr�cken).
</p>

<h3>Standard-Kommentarzeichen eingeben</h3>
<p>
Sie k�nnen die �blichen <a NAGs>Kommentarzeichen</a> im Hauptfenster auch
�ber die Tastatur ohne den <a Comment>Kommentar-Editor</a> hinzuf�gen.
Die folgende Liste zeigt Ihnen, welche Zeichen Sie mit welchen Tasten
eingeben k�nnen:
<ul>
<li> !  : [!][Eingabe] </li>
<li> ?  : [?][Eingabe] </li>
<li> !? : [!][?][Eingabe] </li>
<li> ?! : [?][!][Eingabe] </li>
<li> !! : [!][!][Eingabe] </li>
<li> ?? : [?][?][Eingabe] </li>
<li> </li>
<li> +- : [+][-] </li>
<li> +/-: [+][/] </li>
<li> += : [+][=] </li>
<li> =  : [=][Eingabe] </li>
<li> -+ : [-][+] </li>
<li> -/+: [-][/] </li>
<li> =+ : [=][+] </li>
</ul>

<p><footer>(Aktualisiert: Scid 3.4, Juli 2002)</footer></p>
}


#########################
### Searches help screen:

set helpTitle(D,Searches) "Suchen"
set helpText(D,Searches) {<h1>Suchen in Scid</h1>
<p>
Scid kann auf viele verschiedene Weisen in einer Datenbank suchen.
Die drei wichtigsten Arten zu suchen sind:
<ul>
<li><b>1)</b> nach der aktuellen Brettposition, </li>
<li><b>2)</b> nach angegebenem Material und Stellungsmustern, </li>
<li><b>3)</b> nach Partiedaten-Informationen wie Spieler, Ergebnis, Datum. </li>
</ul>
<p>
Au�erdem gibt es noch einen automatischen Suchmodus, den sog.
<a Tree>Zugbaum</a>, der an anderer Stelle erkl�rt wird.
</p>

<h3><name Filter>Der Such-Filter</name></h3>
<p>
Suchen basiert bei Scid auf dem Konzept eines <term>Filters</term>.
Der Filter repr�sentiert eine Teilmenge der aktuellen Datenbank;
eine Partie ist immer entweder im Filter enthalten oder vom
Filter ausgeschlossen.
</p>
<p>
Bei jeder Art der Suche k�nnen Sie w�hlen, den vorhandenen Filter
weiter einzugrenzen, zu diesem hinzuzuf�gen oder ihn zu ignorieren
und die gesamte Datenbank zu durchsuchen. Diese Auswahl erlaubt es,
komplexe Suchvorg�nge nacheinander aufzubauen.
</p>
<p>
Sie k�nnen auch mit dem <a Switcher>Datenbank-Umschalter</a> alle Partien
im Filter einer Datenbank in eine andere Datenbank kopieren.
</p>
<p>
Bei der Suche nach einer exakten Postion, der <a Tree>Zugbaum</a>- oder
Material/Muster-Suche wird die Zugnummer der ersten passenden Position
jeder passenden Partie gespeichert; wenn Sie also jede dieser Partien
laden, wird automatisch die passende Stellung angezeigt.
</p>
<p>
<b>Beachten</b> Sie, dass beim Suchen nur mit den Partiez�gen
verglichen wird, nicht mit den Z�gen der Varianten.
</p>

<h3><name Board>Suchen: Brett...</name></h3>
<p>
Hier finden Sie Partien, die die gerade dargestellte Position enthalten,
ohne Ber�cksichtigung der Rochade- und <i>en-passant</i>-Rechte.
</p>
<p>
Vier Suchtypen stehen zur Verf�gung. Alle vier verlangen von einer
passenden Stellung exakt gleiches Material und die gleiche Seite am Zug.
Die Typen sind:
<ul>
<li> [1] exakt (die beiden Stellungen m�ssen auf jedem Feld �bereinstimmen),
     </li>
<li> [2] Bauern (die Bauernstruktur mu� �bereinstimmen, aber andere Figuren
     k�nnen irgenwo stehen), </li>
<li> [3] Linien (die Anzahl wei�er und schwarzer Bauern auf jeder Linie mu�
     �bereinstimmen, aber andere Figuren k�nnen irgendwo stehen), and </li>
<li> [4] Material (Bauern und Figuren k�nnen irgendwo stehen). </li>
</ul>
<p>
Die Bauernsuche ist hilfreich, um Er�ffnungen nach Bauernstrukuren zu
studieren, und Linien- und Materialsuche helfen beim Auffinden �hnlicher
Endspielstellungen.
</p>
<p>
Um nach einer beliebigen Stellung zu suchen, k�nnen Sie zuerst
die Position aufbauen (im Men� <menu>Bearbeiten: Stellungseingabe</menu>)
und dann die Suche starten.
</p>
<p>
Sie k�nnen Varianten (statt nur die jeweiligen Partiez�ge) durchsuchen,
indem Sie den Schalter <b>Schaue in Varianten</b> w�hlen; das kann
aber die Suche stark verlangsamen, falls die Datenbank sehr gro� ist
und viele Partien mit Varianten enth�lt.
</p>

<h3><name Material>Suchen: Material/Muster</name></h3>
<p>
Diese Suche ist n�tzlich, um End- oder Mittelspielthemen zu finden. Sie
k�nnen eine minimale und maximale Anzahl von Figuren jeden Typs angeben,
und Sie k�nnen Stellungsmuster wie L�ufer auf f7 oder f-Bauer finden.
</p>
<p>
Eine Reihe von h�ufigen Materialkonstellationen und Stellungsmustern
sind schon bereitgestellt, wie etwa "Endspiel Turm gegen Bauern" oder
"isolierter Damenbauer".
</p>
<p>
<b>Hinweise:</b><br>
Die Geschwindigkeit der Suche nach Stellungsmustern kann stark variieren.
Sie k�nnen aber durch eine geschickte Wahl der Bedingungen die ben�tigte
Zeit reduzieren. Wenn Sie beispielsweise f�r ein Endspiel die Mindestzahl
von Z�gen auf 20 setzen, werden alle Partien, die vor dem 20. Zug enden,
�bersprungen.
</p>

<h3><name Header>Suchen: Partiedaten</name></h3>
<p>
Mit dieser Suche k�nnen Sie Partiedaten finden, die im Vorspann ("Header")
gespeichert sind (wie z.B. Datum, Ergebnis, Namen und Wertungszahlen),
es m�ssen daher keine Partiez�ge dekodiert werden.
</p>
<p>
Um bei der Suche nach Partiedaten eine passende Partie zu finden,
m�ssen <b>alle</b> von Ihnen angegebenen Felder �bereinstimmen.
</p>
<p>
Die Namensfelder (Wei�, Schwarz, Turnier, Ort und Runde) passen auf
jeden Text im Namen, ohne Ber�cksichtigung von Gro�- und Kleinschreibung
oder Leerzeichen.
</p>
<p>
Sie k�nnen f�r das Wei�-, Schwarz-, Turnier-, Ort- und Rundenfeld mit
Unterscheidung von Gro�- und Kleinschreibung und mit "Wildcards" suchen
(mit <b>?</b> f�r ein und <b>*</b> f�r null oder mehr Zeichen), indem
Sie den Suchtext in Anf�hrungszeichen setzen. Eine Suche mit der Ortsangabe
<b>USA</b> wird beispielsweise amerikanische St�dte finden, aber auch
<b>Lausanne SUI</b>, was vermutlich nicht von Ihnen beabsichtigt war! Eine
Suche mit dem Ort <b>"*USA"</b> (denken Sie an die Anf�hrungszeichen)
liefert dagegen nur St�dte in den USA.
</p>
<p>
Wenn Sie einen bestimmten Spieler (oder zwei bestimmte Kontrahenten) als
Wei� oder Schwarz suchen und die jeweilige Farbe keine Rolle spielt,
w�hlen Sie die Option <b>Farben ignorieren</b>.
</p>
<p>
Schlie�lich kann die Suche nach Partiedaten auch verwendet werden, um
irgendeinen Text (mit Ber�cksichtigung von Gro�- und Kleinschreibung,
ohne "Wildcards") in der PGN-Darstellung dieser Partie zu finden. Sie
k�nnen bis zu drei Textteile eingeben, und sie m�ssen alle in einer
passenden Partie vorkommen.
Diese Methode ist sehr hilfreich, um in den Kommentaren oder zus�tzlichen
Daten einer Partie zu suchen (wie <b>Zeit�berschreitung</b> oder
<b>Kommentator</b>), oder nach einer Zugfolge wie <b>Bxh7+</b> und
<b>Kxh7</b> f�r ein angenommenes L�uferopfer auf h7.
Allerdings kann diese Art zu suchen <i>sehr</i> langsam sein, da alle
Partien, auf die andere Kriterien zutreffen, dekodiert und auf diese
Texte durchsucht werden m�ssen.
Es ist daher eine gute Idee, diese Suchen so weit wie m�glich einzugrenzen.
Hier sind einige Beispiele:
Um Partien mit einer Unterverwandlung in einen Turm zu finden,
suchen Sie nach <b>=R</b> und setzen gleichzeitig die Kennung
<b>Umwandlung</b> auf Ja.
Wenn Sie nach Text in Kommentaren suchen, setzen Sie die Kennung
<b>Kommentare</b> auf Ja.
Falls Sie nach den Z�gen <b>Bxh7+</b> und <b>Kxh7</b> suchen, m�chten
Sie z.B. die Suche m�glicherweise auf Partien mit dem Ergebnis 1-0 und
mit mindestens 40 Halbz�gen beschr�nken, oder Sie suchen zuerst nach
Material oder Stellungsmustern, um Partien mit einem wei�en L�uferzug
nach h7 zu finden.
</p>

<h3><name Settings>Sucheinstellungen sichern</name></h3>
<p>
Die Suchfenster Material/Mustern und Partiedaten besitzen einen Schalter
zum <term>Speichern</term>. Das erm�glicht Ihnen, die aktuellen
Sucheinstellungen zur sp�teren Verwendung in einer
<term>Suchoptions</term>-Datei zu speichern (Endung .sso).
Um mit Hilfe einer vorher gespeicherten Suchoptionsdatei (.sso) zu
suchen, w�hlen Sie <menu>�ffnen</menu> im Men� <menu>Suchen</menu>.
</p>

<h3>Suchdauer und �bergangene Dateien</h3>
<p>
Die meisten Suchen liefern eine Nachricht, die die ben�tigte Zeit und
die Anzahl der <term>�bergangenen</term> Partien angibt. Eine �bergangene
Partie ist eine, die aufgrund der im Index gespeicherten Informationen
von der Suche ausgeschlossen werden kann, ohne dass ihre Z�ge dekodiert
werden m�ssen. Siehe die Hilfeseite �ber
<a Formats>Dateiformate</a> f�r weitergehende Informationen.
</p>

<p><footer>(Aktualisiert: Scid 3.0, November 2001)</footer></p>
}


############
### Clipbase

set helpTitle(D,Clipbase) "Die Ablage-Datenbank"
set helpText(D,Clipbase) {<h1>Die Ablage-Datenbank</h1>
<p>
Zus�tzlich zu den ge�ffneten Datenbanken stellt Scid eine
<term>Ablage-Datenbank</term> (als Datenbank 5) zur Verf�gung, welche
sich wie eine normale Datenbank verh�lt, mit der Ausnahme, dass sie
nur im RAM-Speicher existiert und keine Dateien zur Speicherung auf
der Festplatte besitzt.
</p>
<p>
Die Ablage-Datenbank (kurz: Ablage) ist n�tzlich als eine tempor�re
Datenbank, zum Zusammenf�hren von Suchergebnissen aus Suche in
mehreren Datenbanken oder zur Behandlung der Suchergebnisse als eine
eigenst�ndige Datenbank.
</p>
<p>
Angenommen, zum Beispiel, man will sich auf einen Gegner vorbereiten, und
hat eine Datenbank auf alle Partien des Gegners mit Wei� durchsucht,
so dass diese Partien im <a Searches Filter>Filter</a> sind.
Man kann nun diese Partien in die Ablage kopieren (durch Ziehen mit der
rechten Maustaste von der Originaldatenbank zur Ablage, im Fenster
<a Switcher>Datenbank-Umschalter</a>), danach im Datei-Men� die Ablage
als aktive Datenbank ausw�hlen, und dann kann man sich im
<a Tree>Zugbaumfenster</a> das Er�ffnungsrepertoire des Gegners
ansehen.
</p>
<p>
Sind 2 Datenbanken ge�ffnet, und hat man im Filter Partien, die man
von der einen Datenbank in die andere kopieren m�chte, kann man dies
direkt (ohne Umweg �ber die Ablage) tun. Dazu benutzt man wiederum das
Fenster <a Switcher>Datenbank-Umschalter</a>.
</p>
<p>
Die Ablage kann nicht geschlossen werden: mit dem Befehl
<menu>Ablage leeren</menu> aus dem Men� <menu>Bearbeiten</menu> wird
der Inhalt der Ablage gel�scht.
</p>
<p>
Die Ablage-Datenbank ist begrenzt auf 10.000 Partien zur gleichen Zeit,
da sie nur im Speicher existiert.
</p>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


#################################
### Variations and comments help:

set helpTitle(D,Annotating) "Partien kommentieren"
set helpText(D,Annotating) {<h1>Partien kommentieren</h1>
<p>
Mit Scid k�nnen Sie den Partien Anmerkungen hinzuf�gen. Es gibt
drei Arten von Anmerkungen, die Sie nach einem Zug eingeben k�nnen:
Symbole, ein Kommentar und Varianten.
</p>

<h3>Symbole und Kommentare</h3>
<p>
Symbole verwendet man, um eine Stellungsbeurteilung anzuzeigen
(etwa "+-" or "=") oder um auf gute ("!") und schlechte ("?")
Z�ge hinzuweisen, w�hrend ein Kommentar ein beliebiger Text sein
kann. Zur Eingabe von Symbolen und Kommentaren benutzen Sie den
<a Comment>Kommentar-Editor</a>. Es gibt auch eine Hilfeseite, in
der die <a NAGs>Standard-Symbolwerte</a> aufgelistet sind.
</p>
<p>
Beachten Sie, dass jeder Zug mehr als ein Anmerkungssymbol haben kann,
aber nur einen Kommentar. Ein Kommentar vor dem ersten Partiezug wird
als Text vor dem Beginn der Partie ausgegeben.
</p>

<h3><name Vars>Varianten</name></h3>
<p>
Eine <term>Variante</term> eines Zuges ist eine alternative Zugfolge
an einem bestimmten Punkt der Partie. Varianten k�nnen Kommentare
enthalten und sogar rekursiv Untervarianten. Mit den Schaltern oberhalb
des Schachbretts mit einem "<b>V</b>"-Symbol sowie den Kommandos im
Men� <menu>Bearbeiten</menu> kann man Varianten erstellen, editieren
und sich darin bewegen.
</p>

<h4>Tastatureingaben</h4>
<p>
Wenn es zu einem Zug Varianten gibt, werden sie im Informationsbereich
angezeigt. Die erste wird mit <b>v1</b> bezeichnet, die zweite mit
<b>v2</b> etc. Um in eine Variante zu gehen, k�nnen Sie sie anklicken
oder "<b>v</b>" gefolgt von der Variantennummer eingeben. (Falls es
nur eine Variante gibt, gen�gt die Eingabe von <b>v</b>.)
Mit der Taste "<b>z</b>" verlassen Sie die Variante wieder.
</p>

<h3><name Null>Nullz�ge</name></h3>
<p>
Gelegentlich kann es in einer Variante n�tzlich sein, den Zug einer
Seite auszulassen. Beispiel: Sie wollen den Zug 14.Ld3 als Variante
hinzuf�gen und m�chten darauf hinweisen, dass er 15.Lxh7+ Kxh7 16.Sg5+
mit Angriff droht. Das k�nnen Sie erreichen, indem Sie im obigen
Beispiel einen <term>Nullzug</term> zwischen 14.Ld3 und 15.Bxh7+
ausf�hren. Ein Nullzug wird als "<b>--</b>" dargestellt und kann
eingef�gt werden, indem Sie mit der Maus den illegalen Zug "K�nig
schl�gt K�nig" ausf�hren oder mit der Tastatur "<b>--</b>" (zwei
Minuszeichen) eingeben.
</p>
<p>
Beachten Sie, dass Nullz�ge nicht zum PGN-Standard geh�ren, wenn Sie
also Partien mit Nullz�gen in eine PGN-Datei exportieren, wird Scid
(neben einigen anderen Exportoptionen) eine Option anbieten,
Nullz�ge zu erhalten oder sie in Kommentare umzuwandeln, damit
Kompatibilit�t zu anderen Programmen gewahrt bleibt.
Siehe auch die <a Export>Export</a>-Hilfeseite.
</p>

<p><footer>(Aktualisiert: Scid 3.4, Juli 2002)</footer></p>
}


####################
### Analysis window:

set helpTitle(D,Analysis) "Analysefenster"
set helpText(D,Analysis) {<h1>Das Analysefenster</h1>
<p>
Scids Analysefenster zeigt die Analyse der aktuellen Brettstellung
durch ein Schachprogramm (eine sog. <term>Engine</term>).
Immer, wenn sich die Brettstellung �ndert, �bermittelt Scid die neue
Position an die Engine, und die zeigt ihre Einsch�tzung dieser Stellung.
</p>
<p>
Die Bewertung im Analysefenster erfolgt immer aus der Perspektive
von Wei�, eine negative Bewertung hei�t also, dass Schwarz besser steht.
Der untere Fensterbereich (mit dem Rollbalken) zeigt den Verlauf der
Auswertungen der aktuellen Stellung durch die Engine, Sie k�nnen also
sehen, wie sich die Einsch�tzung ver�ndert hat.
</p>
<p>
Um den von der Engine ausgew�hlten besten Zug als neuen Zug der
aktuellen Partie zu nehmen, klicken Sie einfach auf den Schalter
<b>Zug hinzuf�gen</b>.
</p>
<p>
Tip: �ber die Tasten F2 und F3 k�nnen direkt die letzten beiden Analyse-Engines gestartet werden, ohne dies nochmal ausw�hlen zu m�ssen.
</p>

<h3><name List>Die Liste der Analyse-Engines</name></h3>
<p>
Scid beh�lt eine Liste der von Ihnen benutzen Engines mit einer
gesch�tzten Elo-Zahl (wenn Sie eine Sch�tzung machen) und dem Datum
der letzten Benutzung. Sie k�nnen diese Liste nach Namen, Elo-Zahl
oder Datum sortieren.
W�hlen Sie <b>Neu</b> oder <b>Bearbeiten</b>, um eine neue Engine
zur Liste hinzuzuf�gen oder Details eines bestehenden Eintrags zu
bearbeiten.
</p>

<h3><name Start>Engine-Kommandos und Verzeichnisse</name></h3>
<p>
F�r jede Engine m�ssen Sie die aufzurufende Programmdatei angeben
und das Verzeichnis, in dem Scid sie starten soll.
</p>
<p>
Die h�ufigste Ursache von Problemen beim Start einer Engine ist die Wahl
des Verzeichnisses, in dem die Engine laufen soll. Einige Engines
ben�tigen eine Initialisierung oder eine Er�ffnungsbuchdatei in ihrem
Startverzeichnis, um ordnungsgem�� zu laufen.
Andere Engines (so wie Crafty) schreiben Logdateien in dem Verzeichnis,
in dem sie gestartet wurden, Sie m�ssen sie also in einem Verzeichnis
aufrufen, f�r das Sie Schreibrecht haben.
Wenn f�r das Verzeichnis einer Engine "." angegeben ist, wird Scid sie
einfach im aktuellen Verzeichnis starten.
</p>
<p>
Wenn also eine Engine, die in Scid laufen sollte, nicht startet,
versuchen Sie es mit anderen Verzeichniseinstellungen. Um zu vermeiden,
dass Engines Logdateien in vielen verschiedenen Verzeichnissen erstellen,
empfehle ich, Engines im Verzeichnis der Scid-Benutzerdateien zu starten
(da, wo sich die Datei <b>scid.exe</b> bei Windows befindet bzw.
<b>~/.scid/</b> bei Unix); in der Dialogbox f�r die Engine-Einstellungen
gibt es einen Schalter <b>scid.exe dir</b> f�r Windows bzw. <b>~/.scid</b>
f�r Unix, mit dem Sie die Engine in diesem Verzeichnis starten lassen
k�nnen.
</p>

<h3>Training</h3>
<p>
Mit dem Schalter <b>Training</b> k�nnen Sie gegen die Analyse-Engine
spielen. Die Bedenkzeit f�r jeden Zug ist fest vorgegeben und die
Analyse-Ergebnisse werden nicht angezeigt, wenn der Trainingsmodus
eingeschaltet ist.
</p>

<h3>Partie kommentieren</h3>
<p>
Der Schalter <b>Variante hinzuf�gen</b> im Analysefenster f�gt die
laufende Bewertung und beste Variante als neue Variante der Partie hinzu.
</p>
<p>
Man kann das f�r mehrere Z�ge mit dem Schalter <b>Kommentieren</b>
automatisieren. Sie werden zur Eingabe einiger Kommentar-Optionen
aufgefordert, dann wird in den Autoplay-Modus geschaltet.
Wenn der Autoplay-Modus aktiviert und das Analysefenster ge�ffnet ist,
wird die beste Variante mit Stellungsbewertung zu jeder Position
hinzugef�gt, da sich der Autoplay-Modus durch die Partie bewegt.
Nur Stellungen von der aktuellen Stellung bis zum Partieende (oder bis
zum Abbruch des Autoplay-Modus) werden kommentiert, so dass Sie Kommentare
zu Er�ffungsz�gen unterdr�cken k�nnen, indem Sie vor Aktivierung des
Autoplay-Modus zu einer Mittelspielstellung gehen.
</p>
<p>
Die automatische Kommentierung kann jederzeit durch Ausschalten des
Autoplayer-Modus abgebrochen werden, z.B. durch Dr�cken der
<b>Esc</b>-Taste im Hauptfenster.
</p>
<p>
Zur Vereinfachung steht der <b>Kommentar</b>-Schalter nur in dem Fenster
zur Verf�gung, das als erste Analyse-Engine ge�ffnet wurde. Wenn Sie
eine Engine als Analyse-Engine Nr.2 �ffnen, k�nnen Sie sie nicht zur
Partiekommentierung nutzen.
</p>

<h3>Das Analysebrett</h3>
<p>
Anklicken des Schachbrett-Icons in einem Analysefenster zeigt oder
versteckt das Analysebrett, welches die Position nach der aktuell
besten Variante der Engine zeigt. Das funktioniert f�r die meisten
Scid-kompatiblen Engines, aber nicht unbedingt f�r alle; es h�ngt
ganz davon ab, welche Zugnotation eine Engine verwendet.
</p>

<h3>Engine-Priorit�t</h3>
<p>
Falls eine Engine zu viel CPU-Zeit verbraucht und die Benutzung von
Scid oder anderen Applikationen beeintr�chtigt, kann das Einschalten
der Checkbox <b>Niedrige CPU-Priorit�t</b> helfen; es weist der
Engine eine geringe Priorit�t f�rs Proze�-Scheduling zu.
</p>

<h3>Schnittstellen-Details</h3>
<p>
F�r die Benutzung des Analysefensters ben�tigen Sie ein Schachprogramm,
welches das <term>UCI</term> oder <term>WinBoard/Xboard</term>-Protokoll unterst�tzt.
</p>
<p>
Bei Winboard-Engines sendet Scid beim Programmstart die Befehle <b>xboard</b>, <b>post</b> und
<b>protover 2</b> zur Engine, und nutzt die Befehle <b>setboard</b>
und <b>analyze</b> zur effizienteren Kommunikation, wenn die Engine in
ihrer Antwort anzeigt, dass sie diese unterst�tzt.
Wenn die Engine den Befehl <b>setboard</b> nicht unterst�tzt, wird sie
f�r Partien, die nicht mit der Standard-Ausgangsstellung beginnen, keine
Analysen liefern k�nnen.
</p>
<p>
Programmen, die den Befehl <b>analyze</b> nicht unterst�tzen, sendet
Scid nach jeder �nderung der Stellung folgende Kommandos: <b>new</b>
und <b>force</b>, dann die Partiez�ge zur aktuellen Position, danach
<b>go</b>.
</p>
<p>
Bob Hyatt's exzellentes frei verf�gbares Schachprogramm <term>Crafty</term>
benutze und empfehle ich zur Analyse mit Scid. Aber auch andere WinBoard-
oder XBoard-kompatible Programme sind erfolgreich getestet worden.
Ein paar Websites zum Herunterladen einiger Engines sind nachfolgend
aufgef�hrt.
</p>
<p>
Crafty:
<url ftp://ftp.cis.uab.edu/pub/hyatt/>ftp://ftp.cis.uab.edu/pub/hyatt/</url>
</p>
<p>
wbec-ridderkerk.nl (mit vielen Links auf aktuelle Schach-Engines):
<url http://wbec-ridderkerk.nl/html/lastupdates.htm>http://wbec-ridderkerk.nl/html/lastupdates.htm</url>
</p>
<p>
Gnuchess:
<url http://www.gnu.org/software/chess/chess.html>http://www.gnu.org/software/chess/chess.html</url>
</p>
<p>
The Crazy Bishop:
<url http://remi.coulom.free.fr/>http://remi.coulom.free.fr/</url>
</p>

<p><footer>(Aktualisiert: Scid 3.6.21, Dezember 2007)</footer></p>
}


###############################
### Comment editor window help:

set helpTitle(D,Comment) "Kommentareditor"
set helpText(D,Comment) {<h1>Der Kommentareditor</h1>
<p>
Mit dem Kommentareditor k�nnen Sie den Z�gen der aktuellen Partie
Kommentare und symbolische Kommentarzeichen hinzuf�gen.
</p>

<h3>Kommentarzeichen</h3>
<p>
Scid verwendet den <a Author Related>PGN-Standard</a> f�r
Kommentarzeichen und akzeptiert <a NAGs>NAG</a>-Werte f�r Anmerkungen
(NAG = numeric annotation glyph, "numerisches Anmerkungszeichen").
Einige der meistgebr�uchlichen Symbole (wie "!" oder "+-") werden als
solche ausgegeben und haben zur schnelleren Eingabe einen Schalter im
Kommentareditor. F�r andere Symbole k�nnen Sie den jeweiligen numerischen
NAG-Wert, eine Zahl von 1 bis 255, eingeben. Zum Beispiel bedeutet
der NAG-Wert 36 "Wei� besitzt die Initiative" und wird im
<a PGN>PGN-Text</a> der Partie als "$36" ausgegeben.
</p>
<p>
Zu den NAG-Werten, die durch den PGN-Standard definiert werden,
siehe auch die Hilfeseite <a NAGs>NAG-Werte</a>.
</p>
<p>
<b>Hinweis:</b> Sie k�nnen die �blichen Bewertungssymbole f�r Schachz�ge
(!, ?, !!, ??, !? und ?!) direkt im Haupfenster eingeben, ohne den
Kommentareditor zu verwenden, indem Sie das jeweilige Symbol gefolgt
von der [Eingabe]-Taste eintippen.
Das ist besonders n�tzlich beim <a Moves>Schachz�ge eingeben</a>
�ber die Tastatur.
</p>

<h3>Kommentare</h3>
<p>
Sie k�nnen Kommentare im bereitgestellten Textbereich editieren und
dabei die Leeren-, Umkehren- und Speichern-Schalter verwenden.
Sie brauchen den Schalter "Speichern" nicht anzuklicken, um einen Kommentar
zu aktualisieren; dies geschieht automatisch, wann immer Sie zu einer
anderen Partiestellung gehen.
</p>

<h3>Felder einf�rben</h3>
<p>
Sie k�nnen jedes Feld mit einer beliebigen Farbe einf�rben, indem Sie
ein besonderes, an irgendeiner Stelle im Kommentar eingebettetes
Kommando verwenden. Das Format dieses Kommandos ist:
</p>
<ul>
<li><b>[%mark feld farbe]</b> ,<li>
</ul>
<p>
wobei <b>feld</b> ein Feldname wie d4 ist und <b>farbe</b> irgendeine
bekannte Farbbezeichnung (wie etwa red, blue4, darkGreen,
lightSteelBlue, etc.) oder ein RGB-Code (ein <b>#</b> gefolgt von 6
Hexadezimalziffern, wie z.B. #a0b0c8). Die Standardfarbe,
falls die Farbangabe weggelassen wird, ist <red>Rot</red>.
</p>
<p>
Ein Kommentar kann eine beliebige Anzahl von Farbkommandos enthalten,
aber jedes mu� ein eigenes <b>[%mark ...]</b>-Tag-Feld haben.
Beispielsweise wird der Kommentartext</p>
<p>
  "Jetzt ist d6 [%mark d6] geschw�cht und kann vom Springer auf
  b5 [%mark b5 #000070] angegriffen werden."
</p>
<p>
das Feld d6 <red>rot</red> und das Feld b5 in der dunkelblauen Farbe
<darkblue>#000070</darkblue> einf�rben.
</p>

<h3>Pfeile einzeichnen</h3>
<p>
Sie k�nnen mit einem speziellen Kommentar-Kommando, �hnlich dem oben
beschriebenen zum F�rben von Feldern, einen Pfeil von einem Feld zum
anderen zeichnen.
Das Format ist:
</p>
<ul>
<li><b>[%arrow vonFeld nachFeld farbe]</b><li>
</ul>
<p>
wobei <b>vonFeld</b> und <b>nachFeld</b> Feldbezeichnungen wie d4
sind und <b>farbe</b> ein bekannter Farbname (wie z.B. red, blue4, etc.)
oder RGB-Code (wie #a0b0c0) ist.
Ohne Farbangabe wird standardm��ig <red>Rot</red> genommen.
</p>
<p>
Beispiel: Der Kommentartext
</p>
<p>
"Springer auf c3 und L�ufer auf c4 kontrollieren das schwache Feld d5.
 [%arrow c3 d5 red] [%arrow c4 d5 blue]"
</p>
<p>
zeichnet einen roten Pfeil von c3 nach d5 und einen blauen von c4 nach d5.
</p>

<p><footer>(Aktualisiert: Scid 3.2, Februar 2002)</footer></p>
}


###########################
### Crosstable window help:

set helpTitle(D,Crosstable) "Turniertabelle"
set helpText(D,Crosstable) {<h1>Das Turniertabellen-Fenster</h1>
<p>
Das Turniertabellen-Fenster zeigt die Turniertabelle zur aktuellen
Partie. Jedesmal, wenn sie das Fenster aktualisieren (indem Sie den
"Aktualisieren"-Schalter anklicken, im Turniertabellen-Fenster die
[Eingabe]-Taste dr�cken oder im <a MainWindow>Haupt</a>- oder
<a GameList>Partielisten</a>-Fenster die Tastenkombination
<b>[Strg]-[Umschalt]-X</b> bet�tigen), sucht Scid alle Partien
vom selben Turnier wie die aktuelle Partie.
</p>
<p>
Jede Partie, die bis zu <b>drei Monate vor oder nach</b> der aktuellen
Partie gespielt wurde und <b>exakt dieselben Turnier- und Ortsangaben</b>
enth�lt, wird als Partie dieses Turniers betrachtet.
</p>
<p>
Ein Einfachklick mit der linken Maustaste auf irgendein Ergebnis in der
Turniertabelle l�dt die entsprechende Partie.
Sie k�nnen alle Partien des Turniers mit dem Schalter
<b>Zum Filter addieren</b> des Turniertabellen-Fensters zum
<a Searches Filter>Filter</a> hinzuf�gen.
</p>

<h4>Men�s des Turniertabellen-Fensters</h4>
<p>
Im <menu>Datei</menu>-Men� k�nnen Sie die aktuelle Tabelle im Text-,
LaTeX- oder HTML-Format in eine Datei ausgeben.
</p>
<p>
Das <menu>Ausgabe</menu>-Men� erlaubt Ihnen, das Tabellenformat
auszuw�hlen: <b>Jeder gegen jeden</b>, <b>Schweizer System</b>,
<b>K.o.-System</b> oder <b>Automatisch</b>.
</p>
<p>
Das Format "Jeder gegen jeden" (f�r Rundenturniere) ist auf 30 Spieler
limitiert, aber "Schweizer System" (f�r Turniere mit vielen Spielern)
kann bis zu 200 Spieler und 20 Runden ausgeben. Die Standardeinstellung
ist <b>Automatisch</b>, was f�r jedes Turnier das beste Format ausw�hlt.
</p>
<p>
Beachten Sie, dass Scid den <b>Runden</b>-Eintrag jeder Partie verwendet,
um eine Turniertabelle nach Schweizer System zu erstellen, Sie werden daher
keine Partien in der Schweizer-System-Tabelle sehen, wenn sie keine
numerischen Runden-Angaben haben:  1, 2, 3, etc.
</p>
<p>
Im Ausgabe-Men� k�nnen Sie auch das Format der Datenausgabe nach Ihren
W�nschen einstellen, um Wertungszahlen, L�nder oder Titel ein- oder
auzublenden. Sie k�nnen auch w�hlen, ob beim Schweizer System die
Farbzuteilung angezeigt werden soll.
</p>
<p>
Die Option <b>Punktgruppen</b> wirkt sich nur dann auf das Aussehen der
Tabelle aus, wenn die Spieler nach Punkten sortiert werden: sie bewirkt
das Einf�gen einer Leerzeile zwischen Spielergruppen mit gleicher Punktzahl.
</p>
<p>
Das Men� <menu>Sortieren</menu> erlaubt es Ihnen, die Spieler nach
Namen, Elo-Zahlen oder Punkten zu sortieren; Standardeinstellung ist
nach Punkten.
</p>
<p>
Das <menu>Farben</menu>-Men� erm�glicht es Ihnen, Farbausgabe (Hypertext)
ein- oder auszuschalten. Da es sehr zeitaufwendig ist, gro�e Turniertabellen
in HTML zu formatieren und auszugeben, wird Ihnen die Option <b>Text</b>
bei gro�en Turnieren eine Menge Zeit einsparen.
Allerdings k�nnen Sie im Text-Modus keine Spieler oder Partien anklicken.
</p>

<h4>Dubletten in Turniertabellen</h4>
<p>
Um sinnvolle Resultate mit der Turniertabelle zu erzielen, sollten Sie
Dubletten zum L�schen markieren, und Ihre Partien sollten eine
einheitliche Schreibweise f�r Spieler-, Orts- und Turniernamen haben.
Zu Hilfen beim L�schen der Dubletten und Editieren (oder �berpr�fen
der Schreibweisen) von Spieler-, Turnier-, Ortsnamen siehe die Seite
<a Maintenance>Datenbank-Wartung</a>.
</p>

<p><footer>(Aktualisiert: Scid 4.7, Mai 2021)</footer></p>
}


###########################
### Database switcher help:

set helpTitle(D,Switcher) "Datenbank-Umschalter"
set helpText(D,Switcher) {<h1>Der Datenbank-Umschalter</h1>
<p>
Der Datenbank-Umschalter bietet eine Darstellung, die es besonders
einfach macht, zwischen Datenbanken zu wechseln oder Dateien zu kopieren.
Der Name, <a Searches Filter>Filter</a>-Status und Icon jeder Datenbank
werden angezeigt, und die aktive Datenbank ist durch einen gelben
Hintergrund hervorgehoben.
</p>
<p>
Sie k�nnen den Datenbank-Umschalter aus dem <menu>Fenster</menu>-Men�
starten oder durch die Tastenkombination <b>Strg+D</b>.
</p>
<p>
Um alle ausgew�hlten (gefilterten) Dateien einer Datenbank in eine andere
zu kopieren, ziehen Sie sie mit gedr�ckter linker Maustaste in das Zielfeld.
Sie sehen dann eine Nachfrage (falls die Zieldatenbank nicht die
<a Clipbase>Ablage</a> ist), ob die Dateien kopiert werden sollen, oder
eine Fehlermeldung, falls die Dateien nicht kopiert werden k�nnen
(z.B. wenn die gew�hlte Datenbank nicht ge�ffnet ist).
</p>
<p>
Dr�cken Sie die rechten Maustaste �ber einer Datenbank, erscheint ein
Kontextmen� zu dieser Datenbank, mit dem Sie das Datenbank-Icon �ndern oder
den <a Searches Filter>Filter</a> zur�cksetzen k�nnen.
In diesem Men� k�nnen Sie auch die Fensterausrichtung �ndern (um die
Datenbankfelder vertikal oder horizontal anzuordnen), was f�r kleinere
Bildschirme recht n�tzlich ist.
</p>

<p><footer>(Aktualisiert: Scid 3.1, Dezember 2001)</footer></p>
}

############################
### File Finder window help:

set helpTitle(D,Finder) "Dateisuche"
set helpText(D,Finder) {<h1>Die Dateisuche</h1>
<p>
Die <term>Dateisuche</term> hilft Ihnen, Dateien jedes von Scid
benutzten Typs zu finden:  Datenbanken, <a PGN>PGN</a>-Dateien,
<a EPD>EPD</a>-Dateien und <a Repertoire>Repertoire</a>-Dateien.
</p>
<p>
Die Dateisuche zeigt Ihnen n�tzliche Informationen zu jeder Datei, wie
etwa ihre Gr��e (siehe unten) und Datum der letzten Modifikation.
Sie k�nnen jede angezeigte Datei durch einen linken Mausklick �ffnen.
</p>

<h3>In Unterverzeichnissen nachsehen</h3>
<p>
Wenn Sie alle Dateien in allen Unterverzeichnissen des aktuellen
Verzeichnisses finden wollen, schalten Sie <b>Unterverzeichnisse
beachten</b> ein. Dann durchsucht Scid rekursiv jedes Unterverzeichnis
nach Dateien, die Scid �ffnen kann. Wenn viele Unterverzeichnisse
vorhanden sind, kann dies eine Weile dauern, Sie sollten das also
nicht f�r ein Verzeichnis nahe dem Hauptverzeichnis des Dateisystems
tun. Sie k�nnen die Dateisuche mit dem <b>Stop</b>-Schalter unterbrechen.
</p>

<h3>Dateigr��en</h3>
<p>
Die Bedeutung der angegebenen Dateigr��e h�ngt vom Typ der
Datei ab. F�r Scid-Datenbanken und -PGN-Dateien ist es die Anzahl der
Partien. F�r EPD-Dateien ist es die Anzahl der Positionen. F�r
Repertoiredateien ist es die Anzahl der (gew�hlten oder ausgeschlossenen)
Varianten.
</p>
<p>
F�r Scid-Datenbanken entspricht die Gr��e der Anzahl gespeicherter Partien.
F�r alle anderern Datenbanken (z.B. pgn-Dateien) wird die Dateigr��e angegeben.
</p>

<p><footer>(Aktualisiert: Scid 4.7, September 2018)</footer></p>
}


#########################
### GameList window help:

set helpTitle(D,GameList) "Partieliste"
set helpText(D,GameList) {<h1>Das Partielistenfenster</h1>
<p>
Das Partielistenfenster gibt eine einzeilige Zusammenfassung jeder
Partie im aktuellen <term>Filter</term> aus.
</p>

<h3>Navigation in der Partieliste</h3>
<p>
Sie k�nnen in der Partieliste mit dem Schieberegler oder den vier
Schaltern unterhalb der Liste bl�ttern.
Sie k�nnen auch die Tasten [Pos1], [End], [Bild auf], [Bild ab] sowie
die Cursortasten verwenden, um mit der Tastatur zu scrollen.
</p>
<p>
Sie k�nnen die n�chste Partie in der Liste, die einen bestimmten
Text im Wei�-, Schwarz-, Turnier- oder Ortsfeld enth�lt, mit dem
<b>Text finden</b>-Eingabefeld finden.
</p>

<h3>Aktionen mit Partien in der Liste</h3>
<p>
Um eine Datei aus der Liste zu laden, klicken Sie sie doppelt mit
der linken Maustaste an.
Ein Klick mit der mittleren Maustaste zeigt die Anfangsz�ge der Partie;
das ist n�tzlich, wenn man vor dem Laden einer Partie die Er�ffnung
nachsehen will.
</p>
<p>
Die rechte Maustaste produziert ein Men� f�r die ausgew�hlte Partie,
in dem Sie die Partie l�schen (oder "entl�schen") oder aus dem Filter
ausschlie�en k�nnen. Beachten Sie, dass das L�schen einer Datei lediglich
ihre L�schmarkierung setzt; sie verbleibt solange in der Datenbank,
bis Sie diese <a Compact>komprimieren</a>.
</p>

<h3>Die Partieliste konfigurieren</h3>
<p>
Um die Partieliste zu konfigurieren, klicken Sie mit der linken oder
rechten Maustaste auf eine Spalten�berschrift. Sie k�nnen die Breite
ver�ndern, Spalten hinzuf�gen oder entfernen und die Farbe jeder
Spalte ver�ndern.
</p>
<p>
Wenn Sie nur die Spaltenbreite �ndern wollen, daf�r gibt es eine
Tastenkombination: klicken Sie bei gedr�ckter <b>[Strg]</b>- (oder
<b>[Umschalt]</b>)-Taste mit der linken Maustaste auf die
Spalten�berschrift, wird die Spalte kleiner, mit der rechten
Maustaste, wird sie breiter.
</p>

<h3>Gr��e der Partieliste �ndern</h3>
<p>
Die Gr��e der Partieliste wird jedesmal in der Optionsdatei gespeichert,
wenn Sie Ihre Einstellungen sichern.
Wenn Sie also wollen, dass die Dateiliste standardm��ig 10 Partien anzeigt,
ver�ndern Sie einfach die Gr��e des Partielistenfensters und w�hlen
dann <b>Optionen speichern</b> im <menu>Optionen</menu>-Men�.
</p>

<h3><name Browsing>Partien betrachten und mischen</name></h3>
<p>
Das Kontextmen� der Partieliste (und einiger andere Fenster, wie etwa
des <a Reports Opening>Er�ffnungsbericht</a>-Fensters und der Liste der
<a Tree Best>beste(n) Partien</a> des <a Tree>Zugbaum</a>-Fensters)
erlauben die Auswahl, eine Partie zu laden, zu betrachten oder zu
mischen.
</p>
<p>
Wenn <term>Partie betrachten</term> ausgew�hlt wird, werden die Z�ge
der ausgew�hlten Partie (ohne Kommentare oder Varianten) in einem
separaten Fenster ausgegeben. Das ist eine n�tzliche Methode, um eine
andere Partie im voraus anzuschauen, ohne die aktuell geladene Partie
zu ber�hren.
</p>
<p>
Die Funktion <term>Partie mischen</term> erm�glicht es, die ausgew�hlte
Partie als Variante der aktuellen Partie einzuf�gen. Scid findet den
letztm�glichen Zeitpunkt, wo die gew�hlte Partie von der aktuellen
abweicht (unter Ber�cksichtigung von Zugumstellungen), und f�gt an
dieser Position eine Variante ein. Sie k�nnen die Zahl der angezeigten
Z�ge der gew�hlten Partie �ndern, je nachdem, ob Sie die ganze Partie
oder nur die Er�ffnungsphase hinzuf�gen wollen.
</p>

<p><footer>(Aktualisiert: Scid 3.2, Februar 2002)</footer></p>
}


#######################
### Import window help:

set helpTitle(D,Import) "Importfenster"
set helpText(D,Import) {<h1>Das Importfenster</h1>
<p>
Scids Importfenster erm�glicht es Ihnen, auf einfache Weise eine
Partie im <a PGN>PGN-Format</a> aus einer anderen Anwendung oder
einem anderen Fenster in Scid einzuf�gen.
</p>
<p>
In den gro�en Fensterbereich tippen oder f�gen Sie den Partietext im
PGN-Format ein, und im grauen Bereich darunter erscheinen
Fehlermeldungen oder Warnungen.
</p>

<h3>Die aktuelle Partie im Importfenster bearbeiten</h3>
<p>
Das Importfenster bietet auch eine weitere, bequeme M�glichkeit f�r
�nderungen an der aktuellen Partie: Sie k�nnen die aktuelle Partie in
das Importfenster einf�gen (mit dem Schalter <b>Aktuelle Partie
einf�gen</b>), den Text editieren und danach auf <b>Import</b> klicken.
</p>

<h3>PGN-Tags im Importfenster</h3>
<p>
Scid erwartet PGN-Eintr�ge ("header tags") wie
<ul>
<li> <b>[Result "*"]</b> </li>
</ul>
vor den Z�gen, aber Sie k�nnen auch ein Partiefragment wie
<ul>
<li> <b>1.e4 e5 2.Bc4 Bc5 3.Qh5?! Nf6?? 4.Qxf7# 1-0</b> </li>
</ul>
ohne PGN-Tags einf�gen, und Scid wird es importieren.
</p>

<h3>PGN-Dateien in Scid verwenden</h3>
<p>
Wenn Sie eine PGN-Datei in Scid verwenden wollen, ohne sie vorher mit
<a Pgnscid>pgnscid</a> zu konvertieren, gibt es zwei M�glichkeiten.
</p>
<p>
Zum einen k�nnen Sie die Partien der Datei mit der Men�-Option
<menu>Werkzeuge: Datei mit PGN-Partien importieren ...</menu> importieren.
</p>
<p>
Die Alternative w�re, die PGN-Datei direkt in Scid zu �ffnen. Allerdings
werden PGN-Dateien nur zum Lesen ge�ffnet und ben�tigen mehr Speicher als
eine vergleichbare Scid-Datenbank, diese M�glichkeit ist also nur f�r
relativ kleine PGN-Dateien zu empfehlen.
</p>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


########################
### Reports help:

set helpTitle(D,Reports) "Berichte"
set helpText(D,Reports) {<h1>Berichte</h1>
<p>
Bei Scid ist ein <term>Bericht</term> ein Dokument, das Informationen �ber
eine bestimmte Position und/oder einen bestimmten Spieler enth�lt. Scid
kann zwei Berichtstypen erstellen: Er�ffnungsberichte und Spielerberichte.
</p>

<h3><name Opening>Er�ffnungsberichte</name></h3>
<p>
Scid kann einen <term>Er�ffnungsbericht</term> erstellen, der interessante
Informationen �ber die aktuelle Er�ffnungsposition ausgibt. Um den
Er�ffnungsbericht zu erstellen, vergewissern Sie sich als erstes, dass die
dargestellte Position auch die ist, f�r die Sie den Bericht haben wollen,
dann w�hlen Sie <b>Er�ffnungsbericht</b> im Men� <menu>Werkzeuge</menu>.
</p>
<p>
Das <term>Er�ffnungsberichts</term>-Fenster gibt die Ergebnisse des von
Scid erstellten Berichts aus. Das <b>Datei</b>-Men� enth�lt Optionen,
um den Bericht in einer Datei zu speichern, im Text-, HTML- oder
<a LaTeX>LaTeX</a>-Format.
</p>
<p>
Die ersten Abschnitte des Berichts pr�sentieren Informationen zu den
Partien, die die Berichtsposition erreicht haben, und zu den Z�gen, die
in dieser Stellung gespielt wurden. Sie k�nnen erkennen, ob die Er�ffnung
popul�rer wird, ob sie zu vielen Kurzremisen f�hrt und mit welchen
Zugfolgen (Zugumstellungen) sie erreicht wird.
</p>
<p>
Der Abschnitt �ber positionelle Themen informiert �ber die H�ufigkeit
bestimmter typischer Themen der Berichtspartien. Zu diesem Zweck werden
die ersten 20 Z�ge (also die ersten 40 Positionen ab Ausgangsstellung)
jeder Partie untersucht. Um als eine Partie eingestuft zu werden, die
ein bestimmtes Thema enth�lt, mu� dieses Thema mindestens viermal
innerhalb der ersten 20 Z�ge der Partie vorkommen. Damit wird vermieden,
dass durch kurzzeitiges Auftreten eines Themas (wie etwa ein isolierter
Damenbauer, der sofort geschlagen wird) die Ergebnisse verf�lscht werden.
</p>
<p>
Der letzte und l�ngste Teil des Berichts ist die Theorie-Tabelle. Wenn Sie
den Bericht in einer Datei sichern, k�nnen Sie w�hlen, ob Sie nur die
Theorie-Tabelle, einen kompakten Bericht ohne die Theorie-Tabelle oder
den gesamten Bericht sichern wollen.
</p>
<p>
Fast alle Abschnitte des Berichts k�nnen mit den Er�ffnungsberichts-Optionen
eingestellt oder ein- und ausgeschaltet werden, Sie k�nnen also den
Bericht so anpassen, dass er nur die f�r Sie interesanten Informationen
enth�lt.
</p>
<p>
Bei den meisten Informationen im Berichtsfenster, die farbig dargestellt
sind, f�hrt ein linker Mausklick zu einer Aktion. Zum Beispiel k�nnen Sie
eine angef�hrte Partie durch Anklicken laden oder den Filter durch
Klicken auf ein Positionsthema so einstellen, dass er nur die
Berichtspartien mit diesem Thema enth�lt.
</p>

<h4>Favoriten</h4>
<p>
Mit dem <menu>Favoriten</menu>-Men� des Berichtsfensters haben Sie die
M�glichkeit, eine Liste bevorzugter Er�ffnungsbericht-Positionen zu
verwalten und sehr einfach Berichte f�r genau diese Positionen zu
erstellen. Wenn Sie "Bericht hinzuf�gen..." im Favoriten-Men�
w�hlen, wird die aktuelle Stellung als besondere Berichtsposition
aufgenommen. Sie werden aufgefordert, einen Namen anzugeben, der dann
als Dateiname verwendet wird, wenn Favoritenberichte erstellt werden.
</p>
<p>
W�hlen Sie "Berichte erzeugen..." im Favoriten-Men�, um einen Bericht
f�r jede Ihrer bevorzugten Positionen aus der aktuellen Datenbank zu
erstellen. In einem Dialogfenster k�nnen Sie dann Typ und Format der
Berichte angeben sowie ein Verzeichnis, wo die Berichtsdateien
gespeichert werden sollen. Die passende Dateiendung f�r das gew�hlte
Ausgabeformat wird dann automatisch erg�nzt (z.B. ".html" f�r das
HTML-Format).
</p>

<h3><name Player>Spielerberichte</name></h3>
<p>
Ein <term>Spielerbericht</term> �hnelt sehr stark einem Er�ffnungsbericht,
enth�lt aber Informationen �ber Partien eines einzelnen Spielers mit
Wei� oder mit Schwarz. Sie k�nnen einen Spielerbericht �ber das
Werkzeuge-Men� oder aus dem <a PInfo>Spielerinformations</a>-Fenster
heraus erzeugen.
</p>
<p>
Ein Spielerbericht kann entweder f�r alle Partien eines bestimmten Spielers
mit einer bestimmten Farbe erstellt werden oder nur f�r die Partien, die
die aktuelle Stellung des Hauptfenster-Bretts erreicht haben.
</p>

<h3>Beschr�nkungen</h3>
<p>
F�r die meisten Berichtsdaten gibt es eine Beschr�nkung auf 2000 Partien,
wenn die Berichtsposition also mehr als 2000 Partien enth�lt, k�nnen
einige Resultate etwas ungenau sein.
</p>
<p>
Au�erdem gibt es ein Limit von 500 Partien f�r die Theorie-Tabelle. Wenn
die Berichtsposition in mehr als 500 Partien vorkommt, werden zur
Erstellung der Theorie-Tabelle nur die 500 Partien mit den h�chsten
durchschnittlichen Elo-Zahlen herangezogen. Die Anzahl der Partien zum
Aufbau der Theorie-Tabelle ist einstellbar.
</p>

<p><footer>(Aktualisiert: Scid 3.5, Februar 2003)</footer></p>
}


####################
### PGN window help:

set helpTitle(D,PGN) "PGN-Fenster"
set helpText(D,PGN) {<h1>Das PGN-Fenster</h1>
<p>
Scids PGN-Fenster gibt den Inhalt der aktuellen Partie in der
Standard-PGN-Darstellung aus. Im Partietext erscheinen Kommentare in
{geschweiften} und Varianten in (runden) Klammern.
</p>

<h3>PGN-Format</h3>
<p>
PGN (Portable Game Notation) ist ein verbreiteter Standard zum Transfer
von Schachpartien zwischen Computerprogrammen. Eine PGN-Partie besteht
aus zwei Abschnitten.
Der erste Teil ist der Vorspann ("Header"), der Eintragungen ("tags") wie
z.B.
<b>[White "Kasparov, Gary"]</b>
und
<b>[Result "1/2-1/2"]</b> enth�lt.
</p>
<p>
Der zweite Abschnitt enth�lt die eigentlichen Partiez�ge in
algebraischer Standardnotation (SAN) zusammen mit eventuellen Varianten,
<a NAGs>Kommentarsymbolen</a> und <a Comment>Kommentaren</a>.
</p>

<h3>Aktionen im PGN-Fenster</h3>
<p>
Sie k�nnen mit dem PGN-Fenster innerhalb der Partie navigieren: Mit
einem Linksklick auf einen Zug gehen Sie zu diesem Zug, mit einem
Linksklick auf einen Kommentar k�nnen Sie diesen editieren.
Die Cursortasten (sowie die Tasten <b>v</b> und <b>z</b> f�r
Variante beginnen bzw. verlassen) funktionieren zum Navigieren in der
Partie genau wie im Hauptfenster.
</p>

<h3>Einstellungen f�r PGN-Ausgabe</h3>
<p>
Das Men� des PGN-Fensters enth�lt Optionen, die die Ausgabe des Fensters
betreffen. Scid kann die Partie farbig oder als reinen Text darstellen
-- siehe das <menu>Ausgabe</menu>-Men� im PGN-Fenster.
Die farbige Darstellung ist leichter zu lesen und erlaubt Ihnen, Z�ge und
Kommentare mit der Maus auszuw�hlen, aber sie ist viel langsamer zu
aktualisieren. F�r sehr lange Partien sollten Sie vielleicht die
einfache Textausgabe w�hlen.
</p>
<p>
Auch das Format der Kommentare und Varianten k�nnen Sie ver�ndern,
indem Sie sie zwecks besserer �bersichtlichkeit einger�ckt oder in
separaten Zeilen ausgeben lassen.
</p>
<p>
Die PGN-Ausgabe-Optionen und die Gr��e des PGN-Fensters werden, wann
immer Sie <b>Optionen speichern</b> im <menu>Optionen</menu>-Men� w�hlen,
in der Konfigurationsdatei gesichert.
</p>

<p><footer>(Aktualisiert: Scid 3.1, Dezember 2001)</footer></p>
}


#######################
### Piece Tracker help:

set helpTitle(D,PTracker) "Figurenverteilung"
set helpText(D,PTracker) {<h1>Das Figurenverteilungsfenster</h1>
<p>
Die <term>Figurenverteilung </term> bzw. das Figurenverteilungsfenster
ist ein Werkzeug, um die Bewegungen bestimmter Figuren in allen Partien
des aktuellen Filters nachzuvollziehen und ein Bewegungsmuster (eine
"Fu�spur") zu erstellen, das aufzeigt, wie oft jedes Feld von dieser
Figur besetzt wurde.
</p>
<p>
Um die Figurenverteilung zu benutzen, vergewissern Sie sich zuerst, dass
der Filter die Partien enth�lt, die Sie interessieren, z.B. Partien mit
einer bestimmten Er�ffnungsposition oder alle Wei�-Partien eines
bestimmten Spielers. Dann w�hlen Sie die Figur, deren Bewegung Sie
nachvollziehen wollen, und w�hlen die unten im Text erl�uterten Optionen.
Danach klicken Sie auf den Schalter <b>Aktualisieren</b>.
</p>
<p>
Die Information �ber die Figurenbewegungen wird auf zwei Arten dargestellt:
eine grafische "Fu�spur" und eine Liste mit einer Textzeile pro Feld.
</p>

<h3>Auswahl der Figur</h3>
<p>
Die Schachfiguren sind unterhalb der "Karte" f�r die "Fu�spur" gem�� der
Ausgangsstellung angeordnet. Eine einzelne Figur (wie etwa der wei�e
Springer b1 oder der schwarze Bauer d7) kann mit der linken Maustaste
ausgew�hlt werden, alle Figuren von gleichem Typ und gleicher Farbe
(wie z.B. alle wei�en Bauern oder beide schwarzen T�rme) mit der
rechten Maustaste.
</p>

<h3>Weitere Einstellungen</h3>
<p>
Der Zugnummer-Bereich kontrolliert, wann die Figurenverfolgung anfangen
und enden soll. Die Standardeinstellung 1-20 (d.h. die Verfolgung endet
nach dem 20. Zug von Schwarz) ist gut geeignet zur Untersuchung von
Er�ffnungsthemen, aber (z.B.) ein Bereich von 15-35 w�re besser, wenn
man Entwicklungen im Mittelspiel betrachten will.
</p>
<p>
Es k�nnen zwei Arten von Statistiken erstellt werden:
<ul>
<li> <b>% der Partien mit Zug auf das Feld</b>: zeigt, welcher Anteil
     an Filterpartien einen Zug der zu beobachtenden Figur auf jedes
     Feld enth�lt. Das ist die Standardeinstellung und normalerweise
     die beste Wahl.
<li> <b>% der Zeit auf jedem Feld</b>: zeigt den Anteil der
     Verweildauer der zu beobachtenden Figur auf jedem Feld.
</ul>
</p>

<h3>Hinweise</h3>
<p>
Es gibt (mindestens) drei gute Verwendungsm�glichkeiten f�r die
Figurenverteilung: Er�ffnungsvorbereitung, Mittelspielthemen und
Spielervorbereitung.
</p>
<p>
F�r die Er�ffnungsvorbereitung verwenden Sie die Figurenverteilung
zusammen mit dem <a Tree>Zugbaum</a>. Indem Sie die Bewegungen von
Figuren nachvollziehen, k�nnen Sie Entwicklungen in der aktuellen
Er�ffnung erkennen, beispielsweise �bliche Bauernvorst��e,
Springervorposten und die h�ufigsten L�uferplazierungen. Dabei ist es
hilfreich, den Zugbereich nach dem aktuellen Partiezug beginnen zu
lassen, so dass die Z�ge, die zur aktuellen Stellung f�hrten, nicht in
die Statistik einflie�en.
</p>
<p>
F�r Mittelspielthemen kann die Figurenverteilung n�tzlich sein, wenn
der Filter einen bestimmten Elo-Bereich enth�lt (mit der
<a Searches Header>Partiedaten-Suche</a>) oder vielleicht ein Muster
wie "Isolierter Damenbauer von Wei�"
(mit der <a Searches Material>Material/Muster-Suche</a>).
Stellen Sie den Zugbereich auf einen sinnvollen Wert ein (z.B. 20-40)
und verfolgen Sie Figuren, um beispielsweise Bauernvorst��e im sp�ten
Mittelspiel oder fr�hen Endspiel zu erkennen
</p>
<p>
Zur Spielervorbereitung verwenden Sie die
<a Searches Header>Partiedaten-Suche</a> oder die
<a PInfo>Spieler-Information</a>, um alle Partien einer Farbe eines
bestimmten Spielers zu finden. Die Figurenverteilung kann dann genutzt
werden um z.B. festzustellen, wie gern der Spieler L�ufer fianchettiert,
lang rochiert oder einen Bauernkeil bis d5 oder e5 treibt.
</p>

<p><footer>(Aktualisiert: Scid 3.3, April 2002)</footer></p>
}

#####################
### Player List help:

set helpTitle(D,PList) "Spielersuche"
set helpText(D,PList) {<h1>Die Spielersuche</h1>
<p>
Die <term>Spielersuche</term> gibt eine Namensliste von Spielern
aus der aktuellen Datenbank aus. Die Auswahl eines Spielers �ffnet
das <a PInfo>Spieler-Informations</a>-Fenster mit detaillierteren
Informationen �ber diesen Spieler.
</p>
<p>
Es werden 5 Spalten ausgegeben, die jeweils den Namen, die h�chste
Elo-Zahl, Anzahl der gespielten Partien sowie das Jahr der
�ltesten und neueste Partie anzeigen.
Ein Klick auf eine Spalten-�berschrift sortiert die Liste nach
dieser Spalte.
</p>
<p>
Die Kontrollschalter unterhalb der Liste erm�glichen Ihnen, den
Inhalt der Liste zu filtern. Sie k�nnen die maximale Listengr��e
�ndern, einen Spielernamen-Anfang eingeben (Gro�-/Kleinschreibung
wird ignoriert, z.B. sucht "ada" nach "Adams") sowie den
Elozahlen-Bereich oder die Anzahl der gespielten Partien eingrenzen.
</p>

<p><footer>(Aktualisiert: Scid 4.7, September 2018)</footer></p>
}

#####################
### Player Info help:

set helpTitle(D,PInfo) "Spielerinformation"
set helpText(D,PInfo) {<h1>Die Spieler-Information</h1>
<p>
Das Fenster <term>Spieler-Information</term> wird jedesmal aufgebaut
oder aktualisiert, wenn Sie im Informationsbereich (unterhalb des
Schachbretts) oder im <a Crosstable>Turniertabellen</a>-Fenster mit der
linken Maustaste auf einen Spielernamen klicken.
</p>
<p>
Es gibt n�tzliche Informationen �ber die Spieler aus,
einschlie�lich ihrer Erfolgsrate mit Wei� und Schwarz, ihrer bevorzugten
Er�ffnungen (nach <a ECO>ECO-Code</a>) und ihrer Elo-Entwicklung.<br>
Die Daten f�r den Elo-Verlauf k�nnen wahlweise aus der aktuellen Datenbank
oder aus der Schreibkorrekturdatei/Ratingdatei gelesen werden. Wenn Sie ein
gepflegte Rating-Datei verwenden, k�nnen auch die Zeitr�ume dargestellt werden,
f�r die in der Datenbank keine Spiele vorhanden sind.<br>
Eine Ratingdatei mit aktuellen ELO-Zahlen von �ber 300.000 registrierten
FIDE-Spieler kann unter <url https://sourceforge.net/projects/scid/files/Player Data/>
https://sourceforge.net/projects/scid/files/Player Data/</url> heruntergeladen werden.
</p>
<p>
Jede Prozentangabe ist das Ergebnis, das man aus Sicht des Spielers
erwartet (Erfolgsrate) -- d.h. ein h�herer Wert ist f�r die Spieler
immer besser, ob als Wei� oder Schwarz.
</p>
<p>
Sie k�nnen die ELO-Entwicklung des Spielers grafisch dargestellt
sehen, wenn Sie die Taste <a Graphs Rating>ELO-Zahl-Verlauf</a> anklicken.
</p>
<p>
Jede rot dargestellte Zahl k�nnen Sie mit der linken Maustaste anklicken,
um den <a Searches Filter>Filter</a> so einzustellen, dass er die
entsprechenden Partien enth�lt.
</p>

<p><footer>(Aktualisiert: Scid 4.7, November 2018)</footer></p>
}


##################################
### Tournament Finder window help:

set helpTitle(D,Tmt) "Turniersuche"
set helpText(D,Tmt) {<h1>Die Turniersuche</h1>
<p>
Die <term>Turniersuche</term> erm�glicht es, Turniere in der
aktuellen Datenbank zu finden. Es wird angenommen, dass
zwei Partien zum selben Turnier geh�ren, wenn sie denselben Turnier-
und Ortseintrag haben und innerhalb von drei Monaten gespielt wurden.
</p>
<p>
Sie k�nnen die Liste der Turniere durch die Anzahl der Spieler und
Partien, das Datum, die durchschnittliche Elo-Zahl und das Land
einschr�nken, wenn Sie die Felder unterhalb der Turnierliste ausf�llen
und dann auf <b>Aktualisieren</b> klicken.
</p>
<p>
Die ausgegebene Liste kann nach Datum, Spielerzahl, Partienzahl,
durchschnittliche Elo-Zahl, Ort, Turnier oder Nachname des Gewinners
sortiert werden. W�hlen Sie die Kategorie im
<menu>Sortieren</menu>-Men� oder klicken Sie auf die Spalten�berschrift,
um das Sortierkriterium zu �ndern.
</p>
<p>
Um die erste Partie eines der aufgef�hrten Turniere zu laden, klicken
Sie einfach mit der linken Maustaste, wenn die entsprechende Zeile
hervorgehoben ist. Damit wird auch das
<a Crosstable>Turniertabellen</a>-Fenster aktualisiert, falls es ge�ffnet
ist.
Wenn Sie statt dessen die rechte Maustaste dr�cken, wird die Partie
geladen und das Turniertabellen-Fenster ge�ffnet, auch wenn es vorher
geschlossen war.
</p>
<p>
Es ist eine gute Idee, zur Beschleunigung des Suchprozesses den
Datenbereich angemessen einzuschr�nken (z.B. h�chstens einige Jahre)
oder ein einzelnes Land auszuw�hlen (mit dem 3stelligen
Standard-L�ndercode). Damit wird die Zahl der Partien, die Scid bei
der Konstruktion von Turnieren aus den Partien ber�cksichtigen mu�,
au�erordentlich verringert.
</p>

<p><footer>(Aktualisiert: Scid 4.7, September 2018)</footer></p>
}


####################
### Tree window help:

set helpTitle(D,Tree) "Zugbaum"
set helpText(D,Tree) {<h1>Das Zugbaumfenster</h1>
<p>
Das <term>Zugbaum</term>-Fenster liefert Informationen �ber alle Z�ge,
die in der aktuellen Position in den Datenbankpartien gespielt wurden.
Im Zugbaum-Modus wird das Fenster automatisch aktualisiert, sowie sich
die Stellung im Hauptfenster �ndert. F�r gro�e Datenbanken ist das
evtl. etwas langsam.
</p>
<p>
Jedesmal, wenn das Zugbaumfenster aktualisiert wird, wird der
<a Searches Filter>Filter</a> zur�ckgesetzt, und nur die Partien, die
die die aktuelle Position enthalten, sind erfa�t.
</p>
<p>
Ein Klick mit der linken Maustaste auf einen Zug im Zugbaumfenster
f�gt diesen Zug der Partie hinzu.
</p>

<h3>Inhalt des Zugbaumfensters</h3>
<p>
Das Zugbaumfenster zeigt den <a ECO>ECO-Code</a> (falls vorhanden),
die H�ufigkeit (als Anzahl der Partien und in Prozent) und die
Punkte jedes Zuges an. Die <term>Punkte</term> werden immer aus
der Sicht von <b>Wei�</b> berechnet, 100% bedeutet also, alle
Wei�spieler gewinnen, und 0% hei�t nur Schwarzsiege.
</p>
<p>
Die Z�ge im Zugbaumfenster k�nnen nach Z�gen (alphabetisch), ECO-Code,
H�ufigkeit oder Punkten sortiert werden. Sie k�nnen die Sortiermethode
im Men� <menu>Sortieren</menu> �ndern.
</p>

<h3><name Best>Das Fenster "Beste Partien"</name></h3>
<p>
Das Zugbaumfenster besitzt ein Dateimen�-Kommando und einen Schalter,
um das Fenster <term>Beste Partien</term> zu �ffnen, welches eine Liste
der am h�chsten bewerteten Partien des aktuell gezeigten Astes ausgibt.
Die Partien sind nach durchschnittlicher Elo-Zahl sortiert, und Sie
k�nnen die Liste auf Partien mit einem bestimmten Ergebnis beschr�nken.
</p>

<h3><name Graph>Zugbaumgrafik</name></h3>
<p>
Das Zugbaumfenster enth�lt einen mit <term>Grafik</term> bezeichneten
Schalter, der eine grafische Darstellung der relativen Erfolgsrate
jedes Zuges in der aktuellen Stellung liefert.
Alle Z�ge, die in mindestens 1% der Partien und mindestens 5mal
gespielt wurden, werden dargestellt.
Die prozentualen Ergebnisse werden immer aus der Perspektive von
Wei� gesehen, auch wenn Schwarz am Zug ist.
</p>
<p>
In der Zugbaumgrafik ist eine rote Linie eingezeichnet, die den
Durchschnitt aller Partien in der aktuellen Position anzeigt, und der
Bereich zwischen 50 und 55% (wo der Erwartungswert der meisten
Standarder�ffnungen liegt) ist blau gef�rbt. In Meisterpartien erreicht
Wei� �blicherweise etwa 55%.
</p>

<h3><name Lock>Das Zugbaumfenster anbinden</name></h3>
<p>
Jedes Zugbaumfenster ist mit einer geladenen Datenbank verbunden, so
dass, sollten mehre Datenbanken ge�ffnet sein, auch mehrere
Zugbaumfenster parallel existieren k�nnen, je eines f�r jede
Datenbank.
Mit dem Schalter <term>Anbinden</term> im Zugbaumfenster kann man nun
erreichen, dass eine Datenbank automatisch geschlossen wird, sobald
das zugeh�rige Zugbaumfenster geschlossen wird. Weiterhin werden dann
auch alle anderen, mit dem Zugbaumfenster verbundenen Fenster "Beste
Partien" oder eine Zugbaumgrafik automatisch mit geschlossen.
</p>

<h3><name Training>Training</name></h3>
<p>
Wenn der <term>Trainings</term>-Schalter im Zugbaumfenster aktiviert
ist, wird Scid jedesmal, wenn Sie einen Zug in der Partie ausf�hren,
einen zuf�llig ausgew�hlten Zug erwidern. Der Zug, den Scid ausw�hlt,
h�ngt von der Datenbankstatistik ab, d.h. ein Zug, der in 80% der
Datenbankpartien gespielt wurde, wird von Scid mit 80%iger
Wahrscheinlichkeit ausgew�hlt. Diese Funktion einschalten und dann das
Zugbaumfenster verstecken (oder minimieren) und Er�ffnungen gegen eine
gro�e Datenbank spielen ist eine ausgezeichnete Methode, Ihre Kenntnisse
Ihres Er�ffnungsrepertoires zu testen.
</p>

<h3>Den Zugbaum in ge�ffneten EPD-Dateien verwenden</h3>
<p>
F�r jede ge�ffnete <a EPD>EPD-Datei</a> enth�lt das Zugbaumfenster
eine weitere Spalte, die f�r jede Position, die mit den angegebenen
Z�gen erreicht wird, eine kurze (f�nf Zeichen) Zusammenfassung des
Dateiinhalts anzeigt.
</p>
<p>
Die Zusammenfassung k�nnte eine Bewertung, ein Er�ffnungscode oder ein
Zugvorschlag sein; sie wird der Inhalt des ersten gefundenen EPD-Feldes
aus der folgenden Liste sein: <b>ce, eco, nic, pv, pm, bm, id</b>, oder
einfach des ersten EPD-Feldes, falls keines der obigen vorhanden ist.
</p>
<p>
F�r eine Beschreibung der EPD-Felder siehe die Hilfeseite
<a EPD>EPD-Dateien</a>. Wenn die Zusammenfassung das <b>ce</b>-Feld
ist, wird sie zur besseren Lesbarkeit als Bewertung in Bauern aus der
Sicht von Wei� angezeigt (anstatt als Bewertung in Hundertstel Bauern
aus der Sicht der am Zug befindlichen Seite, wie sie in der EPD-Datei
gespeichert ist).
</p>

<h3>Masken zur Konfiguration der Darstellung</h3>
<p>
Benutzerdefinierte Maskendateien (.stm) k�nnen angelegt werden, um die
Anzeige der Statistik im Zugabaumfenster zu erweitern. Hiermit k�nnen
einerseits farbige Symbole, NAG-Codes oder Kommentare f�r eine
bestimmte Stellung hinzugef�gt werden, um beispielsweise kritische
Positionen zu markieren.
</p>
<p>
Um Markierungen anzulegen bewegt man sich zun�chst in einer
bestehenden Partie zur entsprechenden Position und klickt dann mit der
Maus die entsprechene Variante mit der rechten Taste an. Sodann k�nnen
aus dem sich �ffnenden Kontextmenue entsprechende Markierungen
ausgew�hlt oder Kommentare eingegeben werden. Nach dem Hinzuf�gen
entsprechender Annotationen mu� die Maske mit dem Punkt
<term>Speichern</term> gesichert werden.
</p>
<p>
Masken k�nnen auch aus bestehenden Partien, welche Kommentare und
Varianten enthalten gef�llt werden. Hierzu dient der Punkt <term>Mit
aktueller Partie f�llen</term> bzw. <term>Mit Datenbank F�llen</term>
</p>

<h3>Schnellere Ergebnisse durch Zwischenspeichern</h3>
<p>
Scid nutzt f�r die am h�ufigsten vorkommenden Positionen einen
Cachespeicher f�r die Ergebnisse der Zugbaumsuche. Wenn Sie sich im
Zugbaum-Modus in einer Partie vorw�rts und r�ckw�rts bewegen, werden
Sie bemerken, dass das Zugbaumfenster praktisch sofort aktualisiert
wird, wenn die gesuchte Stellung im Cachespeicher ist.
</p>
<p>
Das Zugbaumfenster hat ein Dateimen�-Kommando <term>Cache-Datei
sichern</term>. Wenn Sie das ausw�hlen, wird der aktuelle Inhalt des
Zugbaum-Zwischenspeichers in eine Datei geschrieben (mit der Endung
<b>.stc</b>), um sp�tere Anwendungen des Zugbaum-Modus mit dieser
Datenbank zu beschleunigen.
</p>
<p>
Die Option <term>Cache-Datei f�llen</term> im Dateimen� des
Zugbaumfensters f�llt die Cache-Datei mit Daten f�r viele
Er�ffnungspositionen. Es werden etwa 100 der h�ufigsten
Er�ffnungsstellungen gesucht, dann wird die Cache-Datei geschrieben.
</p>
<p>
Das neue aufbauen des Zugbaumfensters kann erheblich beschleunigt
werden, wenn eine Datenbank nach ECO-Codes sortiert abgespeichert
wird. (Zum sortieren von Datenbanken siehe das <a
Maintenance>Wartungsfenster</a>.) Dieses Sortieren kann allerdings
viele Stunden in Anspruch nehmen. Danach kann durch einschalten der
Option <term>Schneller Modus</term> die Suche um bis zu einen Faktor
20 beschleunigt werden, wobei allerdings kleinere Ungenauigkeiten in
Kauf genommen werden m�ssen. Um eine schnelle Voranzeige der Statistik
zu erreichen aber trotzdem ein genaues ergenbis zu erziehlen dient die
Option <term>Schneller und Gr�ndlicher Modus</term>
</p>
<p>
Beachten Sie, dass eine Zugbaum-Cache-Datei (.stc) v�llig redundant ist;
Sie k�nnen sie ohne Auswirkungen auf die Datenbank l�schen, und
tats�chlich wird sie jedesmal von Scid gel�scht, wenn sie nach
irgendeiner Aktion veraltet sein k�nnte -- zum Beispiel nach Hinzuf�gen
oder Ersetzen einer Partie, oder nach Sortieren der Datenbank.
</p>

<p><footer>(Aktualisiert: Scid 3.6.26, Oktober 2008)</footer></p>
}


################
### Graphs help:

set helpTitle(D,Graphs) "Grafikfenster"
set helpText(D,Graphs) {<h1>Grafikfenster</h1>
<p>
Scid hat einige Fenster, die Informationen grafisch darstellen.
Diese werden im nachfolgenden erkl�rt.
</p>

<h3><name Filter>Relative und absolute Filtergrafik</name></h3>
<p>
Das Fenster <term>relative Filtergrafik</term> zeigt Entwicklungen nach Datum
oder Elo-Zahl f�r die aktuellen Filterpartien im Vergleich zur gesamten
Datenbank. Das ist beispielsweise im <a Tree>Zugbaum</a>-Fenster eine
n�tzliche Hilfe um zu zeigen, wie sich die Popularit�t der aktuellen
Er�ffnungsposition in den letzten Jahren oder Jahrzehnten ge�ndert hat
oder ob sie bei hochrangigen Spielern, etwa bei Gro�meistern, besonders
beliebt ist. Jeder Punkt in der Grafik repr�sentiert f�r ein bestimmtes
Datum oder einen bestimmten Elo-Bereich die Anzahl der Partien im Filter
pro 1000 Partien der gesamten Datenbank.
<br><br>
Neben der relative Filtergrafik gibt es eine <term>absolute Filtergrafik</term>, die die
Partien im Filter nach der absoluten Anzahl der Partien darstellt. Es kann nach
Jahr, Elo-Zahl und Zugzahl der Partie ausgewertet werden.<br>
Mit dem kleinen Grafik-Knopf kann ein Dialog ge�ffnet werden. Hier kann f�r jede der drei
Auswertungen der Bereich (von, bis) und die Intervallgr��e der X-Achse
eingestellt werden. Wird "Sch�tzen" ausgew�hlt, so wird der ELO-Wert
gesch�tzt (s.u.), ansonst wird ein fehlender ELO-Wert eines Spielers
mit 0 bewertet. "Sch�tzen aus" entspricht dabei der
min. Elo-Auswertung im Statistik-Fenster. Die Decaden sind fest eingestellt, bitte hier die Jahres-Option benutzen.
Mit dem "Aktualisieren"-Knopf kann man sofort eine neue Auswertung erstellen, ohne den Dialog verlassen zu m�ssen.
<br>
Bitte beachten: Bei kleinen Intervallen und gro�em Bereich, kann die Auswertung etwas l�nger dauern und die �bersichtlichkeit geht verloren.
</p>
<p>

Wenn die Filtergrafik nach Elo-Zahl ausgegeben wird, verwendet Scid
f�r jede Partie die durchschnittliche (mittlere) Wertung. Gesch�tzte
Elo-Zahlen (wie z.B. aus der Schreibkorrekturdatei) werden nicht verwendet.
Falls in einer Partie nur einer der beiden Spieler eine Elo-Zahl hat,
wird angenommen, dass der Gegner die gleiche Elo-Zahl besitzt bis zu
einer H�chstgrenze von 2200. Wenn also beispielsweise ein Spieler eine
Elo-Zahl von 2500 hat und sein Gegner keine Elo-Zahl, ist die mittlere
Wertungszahl (2500+2200)/2 = 2350.
</p>

<h3><name Rating>ELO-Zahl-Verlauf</name></h3>
<p>
Das Fenster <term>ELO-Zahl-Verlauf</term> zeigt die Entwicklung der
Elo-Zahl(en) eines Spieler oder beider Spieler der aktuellen Partie.
Sie k�nnen den Graphen f�r einen einzelnen Spieler mit dem Schalter
<term>ELO-Zahl-Verlauf</term> im Fenster <a PInfo>Spielerinformation</a>
erzeugen oder f�r beide Spieler der aktuellen Partie, indem Sie
<term>ELO-Zahl-Verlauf</term> im <menu>Werkzeuge</menu>-Men� ausw�hlen.
</p>

<h3><name Score>Partiebewertung</name></h3>
<p>
Das Fenster <term>Partiebewertung</term> zeigt die numerische
Bewertung (Stand) der aktuellen Partie, wie sie in den Kommentaren
gespeichert ist, als Grafik an.
Sie k�nnen mit der linken Maustaste irgendwo auf den Graphen klicken,
um zu der korrespondierenden Partiestellung zu gelangen.
</p>
  <p>
  Es werden zwei Arten von Bewertungskommentaren erkannt: 
  <ul>
  Alle Kommentare, die eine Vorzeichen behaftete Zahl enthalten, z.B. 
  <li><b>+1.23, -0.23</b></li>. Gibt es mehrere Zahlen im Kommentar wird nur die erste verwendet.
  </ul>
  <ul>
  Tags mit dem Namen [%eval .. ]
  <li><b>[%eval -6.64/23]</b></li>
  </ul>
  </p>
  <p>
    Einige Partien werden nur aus der Perspektive der Wei�en angezeigt. Sie k�nnen die Punktzahl f�r Wei� oder Schwarz invertieren.
    Um dies zu korrigieren k�nnen Sie im Optionsmen� die zu intertierende Seite ausw�hlen: <b>Wei�</b> und/oder <b>Schwarz</b>.
  </p>
  <p>
    In einem <term>Zeitdiagramm</term> kann die Zeit f�r den Zeitverbrauch pro Zug oder die verbleibende Zeit auf der Uhr kann ebenfalls dargestellt werden. F�r die Auswertung der Zeit m�ssen im Kommentar die Tags [%clk 0:01:19] und [%emt 0:00:19] enthalten sein.
    Die Werte werden immer in Minuten angezeigt.
    �ber das Men� k�nnen Sie ausw�hlen, welche Kombination der Diagramme angezeigt werden soll:
    <li><b>Beide:</b> Die Partiebewertung und die Zeit werden angezeigt.
    <li><b>Zeit:</b> Nur die Zeit wird angezeigt ("Beide" muss abgew�hlt werden!)</li>
    <li><b>Summe:</b> In der Zeitanzeige wird die Summe der verbrauchten Zeit angezeigt, wenn die Zeit als [%emt 00:12] zur Verf�gung steht.
  </p>
<h3><name Tree>Zugbaumgrafik</name></h3>
<p>
Das Fenster <term>Zugbaumgrafik</term> ist aus dem Zugbaumfenster
zu erreichen. Es zeigt die Erfolgsrate der h�ufigsten Z�ge in der
aktuellen Position. Weitere Informationen finden Sie auf der
<a Tree Graph>Zugbaum</a>-Hilfeseite.
</p>

<p><footer>(Aktualisiert: Scid 4.7, Juni 2018)</footer></p>
}


###################
### Bookmarks help:

set helpTitle(D,Bookmarks) "Lesezeichen"
set helpText(D,Bookmarks) {<h1>Lesezeichen</h1>
<p>
Scid erlaubt Ihnen, wichtige Partien f�r einen leichten sp�teren Zugriff
mit <term>Lesezeichen</term> zu markieren. Das Lesezeichen-Men� ist aus
dem <menu>Datei</menu>-Men�, der Werkzeugleiste oder mit der
Tastenkombination <B>Strg+B</b> zu erreichen.
</p>
<p>
Wenn Sie eine markierte Partie aus dem Lesezeichen-Men� w�hlen, �ffnet
Scid falls n�tig die Datenbank, findet die Partie und geht zu der
Partiestellung, die mit dem Lesezeichen versehen wurde.
</p>
<p>
Nur Partien in Datenbanken im Scid-Format (keine PGN-Datei, nicht die
Ablage-Datenbank) k�nnen mit einem Lesezeichen markiert werden.
</p>
<p>
Wenn die Datenbank einer markierten Partie sortiert oder komprimiert
wurde, sind die Lesezeichendaten m�glicherweise veraltet. Falls das
passiert, durchsucht Scid die Datenbank nach der passendsten Partie
(vergleicht Spielernamen, Ort etc.), wenn das Lesezeichen ausgew�hlt
wird, die markierte Datei sollte also immer noch geladen werden. Wenn
sich allerdings Daten der markierten Partie �ndern, ist es m�glich,
dass eine andere Partie besser auf die Lesezeichendaten pa�t und statt
dessen geladen wird. Es ist also eine gute Idee, eine Partie erneut zu
markieren, wenn Sie ihre Spieler-, Orts-, Ergebnis-, Runden- oder
Jahresdaten bearbeiten.
</p>

<h3>Lesezeichen bearbeiten</h3>
<p>
Mit dem Lesezeichen-Editor k�nnen Sie den f�r jede markierte Partie
ausgegebenen Men�text �ndern und Verzeichnisse erstellen, um die
Lesezeichen zu kategorisieren.
</p>

<h3>Hinweise</h3>
<p>
Sie k�nnen Lesezeichen zum schnellen Zugriff auf Datenbanken verwenden,
die Sie oft benutzen, indem Sie eine Partie jeder Datenbank markieren.
Eine weitere gute Verwendungsm�glichkeit f�r Lesezeichen ist es,
wichtige Partien hinzuzuf�gen, die Sie beim Studieren einer bestimmten
Schacher�ffnung finden.
</p>
<p>
Das Lesezeichen-Men� enth�lt einen Eintrag zur Kontrolle der
Verzeichnisdarstellung: sie k�nnen als Untermen�s angezeigt werden
(n�tzlich bei sehr vielen Lesezeichen) oder als einzelne Liste.
</p>

<p><footer>(Aktualisiert: Scid 3.0, November 2001)</footer></p>
}


##############################
### Command-line options help:

set helpTitle(D,Cmdline) "Kommandozeilen-Optionen"
set helpText(D,Cmdline) {<h1>Kommandozeilen-Optionen</h1>
<p>
Wenn Sie Scid von der Shell oder Konsole starten, k�nnen Sie
Kommandozeilen-Optionen spezifizieren. Datenbanken im Scid-Format (mit
oder ohne Dateiendung wie z.B. ".si3") und PGN-Dateien, die ge�ffnet
werden sollen, k�nnen angegeben werden. Beispiel:
<ul>
<li> <b> scid datenbank partien.pgn</b></li>
</ul>
startet Scid und und �ffnet die Scid-Datenbank "datenbank" und die
PGN-Datei "partien.pgn".
</p>
<p>
Au�erdem gibt es optionale Argumente, die kontrollieren, welche Dateien
Scid suchen und beim Start verwenden soll. Sie k�nnen das Laden der Datei zur
<a ECO>ECO-Er�ffnungsklassifikation</a> mit <b>-xeco</b> oder
<b>-xe</b> verhindern und mit <b>-xspell</b> oder <b>-xs</b> vermeiden,
dass die Datei zur <a Maintenance Spellcheck>Schreibkorrektur</a>
geladen wird. Die Option <b>-fast</b> oder <b>-f</b> bewirkt das in
einem, d.h. <b>scid -f</b> ist �quivalent zu
<b>scid -xeco -xspell -xtb</b>.
</p>

<p><footer>(Aktualisiert: Scid 5.0.2, August 2023)</footer></p>
}


####################
### Compaction help:

set helpTitle(D,Compact) "Datenbank komprimieren"
set helpText(D,Compact) {<h1>Datenbank komprimieren</h1>
<p>
Datenbank-<term>Komprimierung</term> ist ein besonderer Teil der
<a Maintenance>Wartung</a>, der die Datenbank so klein und effizient
wie m�glich h�lt.
Eine Datenbank komprimieren hei�t, jeden ungenutzten Bereich in ihren
Dateien zu l�schen.
Es gibt zwei Arten: Namens- und Partiendatenbank-Komprimierung.
</p>

<h3>Namendatenbank-Komprimierung</h3>
<p>
Nach einer gewissen Zeit werden Sie evtl. feststellen, dass die Datenbank
eine Reihe von Spieler-, Turnier- oder Rundennamen enth�lt, die in keiner
Partie mehr verwendet werden. Das wird regelm��ig nach Namenskorrekturen
der Fall sein. Die unbenutzten Namen verschwenden Speicherplatz in der
Namendatei und k�nnen die Suche nach Namen verlangsamen.
Namendatenbank-Komprimierung l�scht alle Namen, die nicht in irgendeiner
Partie verwendet werden.
</p>

<h3>Partiendatenbank-Komprimierung</h3>
<p>
Immer, wenn eine Partie ersetzt oder gel�scht wird, verbleibt
ungenutzter Platz in der Partiendatei (die gr��te der drei Dateien
einer Scid-Datenbank). Partiendatenbank-Komprimierung l�scht jeden
ungenutzten Speicher, keine gel�schte Datei bleibt in der Datenbank.
Beachten Sie, dass diese Operation unumkehrbar ist: nach der
Komprimierung sind die gel�schten Dateien f�r immer verschwunden!
</p>
<p>
Partiendatenbank-Komprimierung ist auch empfehlenswert nach dem
<a Sorting>Sortieren</a> einer Datenbank, um die Reihenfolge
innerhalb der Partiendatei mit der sortierten Indexdatei synchron
zu halten.
</p>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


####################################
### Database maintenance tools help:

set helpTitle(D,Maintenance) "Datenbank-Wartung"
set helpText(D,Maintenance) {<h1>Datenbank-Wartung</h1>
<p>
Scid stellt einige Funktionen zur Datenbank-Wartung zur Verf�gung,
die aus dem <a Menus File>Datei</a>-Men� zu erreichen sind. Die
Datenbank-<a Compact>Komprimierung</a> und -<a Sorting>Sortierung</a>
werden in separaten Hilfeseiten erkl�rt.
</p>

<h3>Das Wartungsfenster</h3>
<p>
Die meisten Datenbank-Wartungsarbeiten in Scid k�nnen aus dem
Wartungsfenster erledigt werden, welches man mit dem Men�
<menu>Datei: Wartungsfenster</menu> oder <menu>Fenster</menu>
oder der Tastenkombination <b>Strg+M</b> �ffnen kann.
</p>
<p>
Sie k�nnen in diesem Fenster <a Flags>Partie-Kennzeichen</a>
bearbeiten, Schreibkorrekturen durchf�hren, eine Datenbank
<a Compact>komprimieren</a> oder <a Sorting>sortieren</a>.
Alle Operationen, die f�r die aktuelle Datenbank nicht zur Verf�gung
stehen (z.B., weil sie schreibgesch�tzt oder eine PGN-Datei ist),
werden durch graue Schrift angezeigt.
</p>

<h3><name Twins>Dubletten l�schen</name></h3>
<p>
Das Men� <menu>Datei: Wartung</menu> hat ein Kommando <menu>Dubletten
l�schen...</menu>, um Kopien von Partien (Dubletten) in der Datenbank
zu entdecken. Dieses Kommando findet alle Paare von doppelten Partien
und markiert die k�rzere Partie als gel�scht, w�hrend die l�ngere Partie
erhalten bleibt. Zwei Partien werden als gleich angesehen, wenn ihre
Spieler (und alle anderen optionalen Partieeintr�ge) exakt �bereinstimmen.
</p>
<p>
Wenn Sie die Option "gleiche Z�ge" angeben, m�ssen zwei Partien die
gleichen Partiez�ge bis zur L�nge der k�rzeren Partie haben (oder bis
zum 60. Zug, je nachdem, was zuerst eintritt), um Dubletten zu sein.
</p>
<p>
Wenn Sie Dubletten gel�scht haben, ist es eine gute Idee zu �berpr�fen,
ob jede gel�schte Partie tats�chlich Kopie einer anderen Partie ist.
Das k�nnen Sie ganz einfach machen, wenn Sie die Option "<b>Filter auf
Dubletten setzen</b>" im Dialogfenster "Dubletten l�schen" gew�hlt
haben. Der Filter wird dann alle gel�schten Partien enthalten. Sie k�nnen
sie mit dem <term>Dublettenpr�fer</term> (erreichbar aus dem
Wartungsmen� oder mit der Tastenkombination <b>Strg+Umsch+T</b>)
betrachten (bl�ttern mit den Tasten <b>p</b> und <b>n</b>), um zu
verifizieren, dass jede Partie deshalb gel�scht wurde, weil sie
tats�chlich die Dublette einer anderen Partie ist.
</p>

<h3><name Editing>Spieler, Turniere, Orte und Runden editieren</name></h3>
<p>
Sie haben vielleicht falsch geschriebene Namen in Iher Datenbank und
wollen sie korrigieren. Sie k�nnen das in Scid mit dem
<term>Namenseditor</term> (Tastenkombination: <b>Strg+Umsch+N</b>), den
Sie aus dem Untermen� <menu>Datei: Wartung</menu> erreichen.
</p>
<p>
Jeder eindeutige Name ist nur einmal in der Namendatei gespeichert,
mit einer Namens�nderung werden daher tats�chlich alle Vorkommen
ge�ndert.
</p>

<h3><name Spellcheck>Schreibkorrektur</name></h3>
<p>
Zu Scid geh�rt eine <term>Schreibkorrektur</term>-Datei namens
<b>spelling.ssp</b>, um Namen von Spielern, Turnieren, Orten und Runden
zu korrigieren.
Scid versucht die Datei beim Programmstart zu laden; wenn Scid sie
nicht laden kann, k�nnen Sie sie aus dem <menu>Optionen</menu>-Men�
laden.
</p>
<p>
Wenn die Korrekturdatei erst einmal geladen ist, k�nnen Sie sie mit
den Schreibkorrektur-Befehlen im Men� <menu>Datei: Wartung</menu>  oder
aus dem Wartungsfenster auf eine Datenbank anwenden.
</p>
<p>
Wenn Sie f�r eine Datenbank eine Schreibkorrektur durchf�hren, erzeugt
Scid eine Liste mit Korrekturen, die Sie editieren k�nnen, bevor die
Korrekturen tats�chlich ausgef�hrt werden. Sie k�nnen also jede
nicht gewollte Korrektur l�schen.
</p>
<p>
Schreibkorrekturen sind insbesondere n�tzlich, um eine Datenbank zu
standardisieren, damit alle Vorkommen eines bestimmten Spielers gleich
geschrieben werden.
Beispielsweise w�rden mit der Standarddatei die Namen"Kramnik,V.",
"Vladimir Kramnik" und "V. Kramnik" alle zu "Kramnik, Vladimir"
berichtigt.
</p>
<p>
Die Schreibkorrekturdatei hat einen weiteren Nutzen: wenn sie geladen
ist, werden ihre Spielerdaten genutzt, um die Fenster
<a PInfo>Spielerinformation</a> und <a Crosstable>Turniertabelle</a>
zu erweitern: Sie sehen dann die FIDE-Titel (<b>gm</b> = Internationaler
Gro�meister, <b>im</b> = Internationaler Meister etc.) und
L�nderinformationen zu jedem Spieler, der in der Datei enthalten ist.
�ber 6500 starke Spieler der Vergangenheit und Gegenwart sind in der
zu Scid geh�renden Datei <b>spelling.ssp</b> enthalten.
</p>

<h3><name Ratings>Elo-Zahlen zu den Partien hinzuf�gen</name></h3>
<p>
Der Schalter "Elo-Zahlen hinzuf�gen..." im Wartungsfenster veranla�t
Scid, die aktuelle Datenbank nach Spielern, zu durchsuchen, die keine
Elo-Zahl haben, f�r die die Schreibkorrekturdatei aber eine Elo-Zahl
des jeweiligen Spielers zum Zeitpunkt der Partie enth�lt. Scid erg�nzt
alle diese Elo-Zahlen automatisch. Das ist sehr n�tzlich f�r eine
Datenbank mit Meisterpartien, die nur wenige Elo-Angaben enth�lt.
</p>
<p>
Die mit Scid gelieferte Datei "spelling.ssp" enth�lt die f�r diese
Funktion ben�tigten Elo-Zahlen nicht, aber eine gr��ere Version von
ihr namens "ratings.ssp" steht auf der  <a Author>Scid-Website</a>
zur Verf�gung.
</p>

<h3><name Cleaner>Der Bereiniger</name></h3>
<p>
Der <term>Bereiniger</term> von Scid (vom Wartungsfenster zu erreichen)
ist ein Werkzeug, um eine Reihe von Wartungsarbeiten f�r eine Datenbank
in einem durchzuf�hren. Sie k�nnen w�hlen, welche Aufgaben Sie erledigen
wollen, und Scid f�hrt sie f�r die Datenbank aus, ohne weitere Eingaben
des Benutzers zu ben�tigen. Das ist besonders bei der Wartung sehr
gro�er Datenbanken hilfreich.
</p>

<h3>Partien automatisch laden</h3>
<p>
Der <term>Automatische Lader</term> l�dt jedesmal, wenn Sie die
Datenbank �ffnen, eine Partie automatisch. Um die Partie, die geladen
wird, zu �ndern, w�hlen Sie den Schalter "Automatisch Partie Nr.
laden..." Wenn Sie jedesmal die letzte Partie der Datenbank ge�ffnet
haben wollen (unabh�ngig von der Anzahl der Partien in der Datenbank),
w�hlen Sie einfach eine besonders gro�e Zahl wie 9999999.
</p>

<p><footer>(Aktualisiert: Scid 3.1, Dezember 2001)</footer></p>
}


##############
### ECO guide:

set helpTitle(D,ECO) "ECO-F�hrer"
set helpText(D,ECO) {<h1>ECO-Er�ffnungsklassifikation</h1>
<p>
Scid kann Schachpartien gem�� der <b>ECO</b>- (Enzyklop�die der
Schacher�ffnungen) -Er�ffnungsklassifikation einordnen. Ein
Standard-ECO-Code besteht aus einem Buchstaben (A..E) gefolgt von
zwei Ziffern, so dass es 500 verschiedene Standard-ECO-Codes gibt.
</p>

<h3>Scids Erweiterung des ECO-Systems</h3>
<p>
Das ECO-System ist sehr limitiert und f�r moderne Partien nicht
ausreichend: einige der 500 Codes sieht man praktisch �berhaupt nicht
mehr, w�hrend einige andere sehr h�ufig vorkommen. Um diese Situation
zu verbessern, erlaubt Scid eine optionale Erweiterung der
ECO-Basiscodes: jeder Code kann um einen Buchstaben (a..z) erweitert
werden, wobei eine weitere Erg�nzung (noch eine Ziffer, 1..4) m�glich
ist, aber noch nicht in Scids Standard-ECO-Datei benutzt wird.
Ein erweiterter Scid-ECO-Code sieht also etwa aus wie "<b>A41e</b>"
oder "<b>E99b2</b>". Viele der in modernen Meisterpartien vorkommenden
�blichen ECO-Codes haben eine in Scids ECO-Datei definierte
Erweiterung.
</p>

<h3><name Browser>Die ECO-Auswertung</name></h3>
<p>
Das Fenster <term>ECO-Auswertung</term> zeigt Ihnen die Positionen,
die zur Klassifizierung jedes ECO-Codes verwendet werden, sowie die
H�ufigkeit und Erfolgsrate der ECO-Codes in der der aktuellen Datenbank.
</p>
<p>
Der obere Teil zeigt die H�ufigkeit jedes ECO-Codes in der aktuellen
Datenbank. Die Balken in der Grafik haben drei Bereiche: der unterste
(hellste Farbe) steht f�r die Anzahl der Wei�siege, der mittlere f�r
die Zahl der Remis und der oberste (dunkelste) f�r die Anzahl der
Schwarzsiege. Damit k�nnen Sie auf einen Blick die Charakteristik einer
Er�ffnung erkennen: z.B., ob Wei� sehr erfolgreich ist oder ob Remis
h�ufig vorkommen.
</p>
<p>
Um zu einem tieferen ECO-Niveau zu gehen, klicken Sie mit der linken
Maustaste auf einen Balken in der Grafik (oder tippen Sie den
korrespondierenden Buchstaben (bzw. Ziffer) ein). Um auf ein h�heres
Niveau zur�ckzugehen, klicken Sie mit der rechten Maustaste irgendwo
auf die Grafik oder dr�cken Sie die linke Cursortaste (oder [Entf]
oder [R�ck]).
</p>
<p>
Der untere Teil zeigt die Positionen, die ein bestimmter ECO-Code
enth�lt, und zwar entsprechend der von Ihnen geladenen ECO-Datei.
</p>

<h3>Die ECO-Datei laden</h3>
<p>
Die zu Scid geh�rende ECO-Datei hei�t <b>scid.eco</b>, und Scid
versucht sie beim Programmstart zu laden.
Falls Scid sie nicht findet, m�ssen Sie folgendes tun, um die
ECO-Klassifikation zu erm�glichen:
<ul>
<li>(a) Mit dem Men�punkt <menu>Optionen: ECO-Datei laden</menu>
        w�hlen Sie die Datei <b>scid.eco</b>. </li>
<li>(b) Speichern Sie die Optionen (im <menu>Optionen</menu>-Men�). </li>
</ul>
Nachdem Sie das getan haben, wird die ECO-Datei jedesmal geladen, wenn
Sie Scid starten.
</p>

<h3>Das ECO-Code-System</h3>
<p>
Die Basisstruktur des ECO-Systems ist folgende:
</p>
<p>
<b><blue><run ::windows::eco::Refresh A>A</run></blue></b>
    1.d4 Sf6 2...;  1.d4 ...;  1.c4;  1.Verschiedenes
<ul>
<li>  <b>A0</b>  1.<i>Verschiedenes</i>
      (<b>A02-A03</b> 1.f4: <i>Bird-Er�ffnung</i>,
      <b>A04-A09</b>  1.Sf3: <i>Reti, K�nigsindischer Angriff</i>) </li>
<li>  <b>A1</b>  1.c4 ...: <i>Englisch</i> </li>
<li>  <b>A2</b>  1.c4 e5: <i>Englisch, K�nigsbauer</i> </li>
<li>  <b>A3</b>  1.c4 c5: <i>Englisch, Symmetrisch</i> </li>
<li>  <b>A4</b>  1.d4 ...: <i>Damenbauer</i> </li>
<li>  <b>A5</b>  1.d4 Sf6 2.c4 ..: <i>Indische Verteidigung </i> </li>
<li>  <b>A6</b>  1.d4 Sf6 2.c4 c5 3.d5 e6: <i>Modernes Benoni </i> </li>
<li>  <b>A7</b>  A6 + 4.Sc3 exd5 5.cxd5 d6 6.e4 g6 7.Sf3 </li>
<li>  <b>A8</b>  1.d4 f5: <i>Holl�ndische Verteidigung</i> </li>
<li>  <b>A9</b>  1.d4 f5 2.c4 e6: <i>Holl�ndische Verteidigung</i> </li>
</ul>

<p>
<b><blue><run ::windows::eco::Refresh B>B</run></blue></b>   1.e4 c5;  1.e4 c6;  1.e4 d6;  1.e4 <i>Verschidenes</i>
<ul>
<li>  <b>B0</b>  1.e4 ...
      (<b>B02-B05</b>  1.e4 Sf6: <i>Aljechin-Verteidigung</i>;
      <b>B07-B09</b>  1.e4 d6: <i>Pirc</i>) </li>
<li>  <b>B1</b>  1.e4 c6: <i>Caro-Kann</i> </li>
<li>  <b>B2</b>  1.e4 c5: <i>Sizilianische Verteidigung</i> </li>
<li>  <b>B3</b>  1.e4 c5 2.Sf3 Nc6: <i>Sizilianisch</i> </li>
<li>  <b>B4</b>  1.e4 c5 2.Sf3 e6: <i>Sizilianisch</i> </li>
<li>  <b>B5</b>  1.e4 c5 2.Sf3 d6: <i>Sizilianisch</i> </li>
<li>  <b>B6</b>  B5 + 3.d4 cxd4 4.Sxd4 Sf6 5.Sc3 Sc6 </li>
<li>  <b>B7</b>  B5 + 4.Sxd4 Sf6 5.Sc3 g6: <i>Sizilianisch, Drachen</i> </li>
<li>  <b>B8</b>  B5 + 4.Sxd4 Sf6 5.Sc3 e6: <i>Sizilianisch, Scheveninger</i> </li>
<li>  <b>B9</b>  B5 + 4.Sxd4 Sf6 5.Sc3 a6: <i>Sizilianisch, Najdorf</i> </li>
</ul>

<p>
<b><blue><run ::windows::eco::Refresh C>C</run></blue></b>   1.e4 e5;  1.e4 e6
<ul>
<li>  <b>C0</b>  1.e4 e6: <i>Franz�sische Verteidigung</i> </li>
<li>  <b>C1</b>  1.e4 e6 2.d4 d5 3.Sc3: <i>Franz�sisch, Winawer/Klassisch</i> </li>
<li>  <b>C2</b>  1.e4 e5: <i>Offene Partie</i> </li>
<li>  <b>C3</b>  1.e4 e5 2.f4: <i>K�nigsgambit</i> </li>
<li>  <b>C4</b>  1.e4 e5 2.Sf3: <i>Offene Partie</i> </li>
<li>  <b>C5</b>  1.e4 e5 2.Sf3 Sc6 3.Lc4: <i>Italienisch; Zweispringerspiel</i> </li>
<li>  <b>C6</b>  1.e4 e5 2.Sf3 Sc6 3.Lb5: <i>Spanische Partie</i> </li>
<li>  <b>C7</b>  1.e4 e5 2.Sf3 Sc6 3.Lb5 a6 4.La4: <i>Spanisch</i> </li>
<li>  <b>C8</b>  C7 + 4...Sf6 5.0-0: <i>Spanisch, Geschlossen und Offen</i>
      (<b>C80-C83</b>  5.0-0 Sxe4: <i>Spanisch, Offenes System</i>;
      <b>C84-C89</b>  5.0-0 Le7: <i>Spanisch, Geschlossenes System</i>) </li>
<li>  <b>C9</b>  C8 + 5...Le7 6.Te1 b5 7.Lb3 d6: <i>Spanisch, Geschlossen</i> </li>
</ul>

<p>
<b><blue><run ::windows::eco::Refresh D>D</run></blue></b>   1.d4 d5; 1.d4 Sf6 2.c4 g6 with 3...d5
<ul>
<li>  <b>D0</b>   1.d4 d5: <i>Damenbauernspiele</i> </li>
<li>  <b>D1</b>   1.d4 d5 2.c4 c6: <i>Slawisch</i> </li>
<li>  <b>D2</b>  1.d4 d5 2.c4 dxc4: <i>Angenommenes Damengambit</i> </li>
<li>  <b>D3</b>  1.d4 d5 2.c4 e6: <i>Abgelehntes Damengambit</i> </li>
<li>  <b>D4</b>  D3 + 3.Sc3 Sf6 4.Sf3 c5/c6: <i>Semi-Tarrasch; Semi-Slawisch</i> </li>
<li>  <b>D5</b>  D3 + 3.Sc3 Sf6 4.Lg5: <i>Klassisches Damengambit</i> </li>
<li>  <b>D6</b>  D5 + 4...Le7 5.e3 0-0 6.Sf3 Sbd7: <i>Orthodoxes Damengambit</i> </li>
<li>  <b>D7</b>  1.d4 Sf6 2.c4 g6 with 3...d5: <i>Gr�nfeld-Indisch</i> </li>
<li>  <b>D8</b>  1.d4 Sf6 2.c4 g6 3.Sc3 d5: <i>Gr�nfeld-Indisch</i> </li>
<li>  <b>D9</b>  1.d4 Sf6 2.c4 g6 3.Sc3 d5 4.Sf3: <i>Gr�nfeld-Indisch</i> </li>
</ul>

<p>
<b><blue><run ::windows::eco::Refresh E>E</run></blue></b>   1.d4 Sf6 2.c4 e6; 1.d4 Sf6 2.c4 g6 </li>
<ul>
<li>  <b>E0</b>  1.d4 Sf6 2.c4 e6: <i>Katalanisch etc.</i> </li>
<li>  <b>E1</b>  1.d4 Sf6 2.c4 e6 3.Sf3 (b6): <i>Damenindisch etc.</i> </li>
<li>  <b>E2</b>  1.d4 Sf6 2.c4 e6 3.Sc3 (Lb4): <i>Nimzo-Indisch etc.</i> </li>
<li>  <b>E3</b>  E2 + 4.Lg5 or 4.Dc2: <i>Nimzo-Indisch</i> </li>
<li>  <b>E4</b>  E2 + 4.e3: <i>Nimzo-Indisch, Rubinstein</i> </li>
<li>  <b>E5</b>  E4 + 4...0-0 5.Sf3: <i>Nimzo-Indisch, Hauptvariante</i> </li>
<li>  <b>E6</b>  1.d4 Sf6 2.c4 g6: <i>K�nigsindisch</i> </li>
<li>  <b>E7</b>  1.d4 Sf6 2.c4 g6 3.Sc3 Lg7 4.e4: <i>K�nigsindisch</i> </li>
<li>  <b>E8</b>  E7 + 4...d6 5.f3: <i>K�nigsindisch, S�misch</i> </li>
<li>  <b>E9</b>  E7 + 4...d6 5.Sf3: <i>K�nigsindisch, Hauptvarianten</i> </li>
</ul>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}

####################
### Calvar window help:

set helpTitle(D,CalVar) "Varianten berechnen"
set helpText(D,CalVar) {<h1>Das Varianten-berechnen-Fenster</h1>
  <p>
Dieses Training ist auch als Stoyko-�bung bekannt. 
Das Ziel dieser �bung ist die Analyse einer komplexen Stellung und daraus so viele wie m�gliche plausible Varianten zu ermitteln. Jeder Variante wird mit einer Bewertung versehen. 
  </p> 
<p><h3>Konfiguration</h3></p>
Drei Parameter werden eingestellt:
<ul>
<li>Die zur Analyse der verschiedenen Varianten eingesetze UCI-Engine</li>
<li>Zeit, in Sekunden, die zur Analyse der Stellung von der Engine verwendet wird.</li>
<li>Zeit, in Sekunden, die zur Analyse der vom Anwender eingegebenen Variante durch die Engine verwendet wird.</li>
</ul>
<p><h3>Eingabe der Varianten</h3></p>
Die Zugeingabe erfolgt durch Mausklicks auf die Felder des Brettes, allerdings wird auf dem Brett nichts angezeigt. Die angeklickten Felder erscheinen im Varianten-berechnen-Fenster. Jeder Variante wird am Ende mit einer Bewertung abgeschlossen: Es wird einer der Kn�pfe mit den NAG-Codes gedr�ckt.
  <p><h3>Auswertung der Bewertung</h3></p>
Wurde eine Variante mit einer NAG-Code-Bewertung abgeschlossen, berechnet die Engine ihre Bewertung der Variante und h�ngt ihre Variante und Bewertung direkt an die Benutzer-Variante an. 
  <p><h3>Fertig mit der Stellung</h3></p>
Ist der Anwender der Meinung alle besten Varianten gefunden zu haben, dr�ckt er <b>Fertig mit Stellung</b>. Es werden dann noch alle Varianten (mit dem Kommentar <b>Fehlende Varianten</b>) mit einer h�heren Bewertung als die beste Variante des Anwenders hinzugef�gt. 
  
  <p><footer>(Aktualisiert: Scid 3.6.21, Dezember 2007)</footer></p>
}

####################
### EPD files help:

set helpTitle(D,EPD) "EPD-Dateien"
set helpText(D,EPD) {<h1>EPD-Dateien</h1>
<p>
Eine EPD-Datei (extended position description = erweiterte
Stellungsbeschreibung) ist eine Sammlung von Positionen, wobei jeder
Position ein Text zugeordnet ist. Wie <a PGN>PGN</a> ist EPD ein
verbreiteter Standard f�r Schachinformationen.
</p>
<p>
Eine EPD-Datei hat eine Reihe definierter "<term>Opcodes</term>"(-Felder),
die in der Datei durch Semikolons (<b>;</b>) getrennt gespeichert sind,
in einem EPD-Fenster von Scid aber in separaten Zeilen dargestellt
werden, um das Bearbeiten zu erleichtern. Ein Semikolon innerhalb eines
EPD-Feldes wird von Scid als "<b>\s</b>" gespeichert, um es von der
Feldende-Kennung zu unterscheiden.
Jede Position und ihre zugeh�riger Opcode wird in der EPD-Datei in
einer einzelnen Zeile gespeichert.
</p>
<p>
Standard-EPD-Opcodes sind u.a.:
<ul>
<li> <b>acd</b> Analyse-Z�hler: Suchtiefe.</li>
<li> <b>acn</b> Analyse-Z�hler: Anzahl der durchsuchten Knoten.</li>
<li> <b>acs</b> Analyse-Z�hler: Suchzeit in Sekunden.</li>
<li> <b>bm</b> Beste Z�ge: aus irgendeinem Grund als beste
eingestufte Z�ge.</li>
<li> <b>ce</b> Stellungsbeurteilung: Beurteilung in Hundertstel Bauern
[ce = "centipawn evaluation"] aus Sicht der <b>am Zug</b>
befindlichen Seite -- beachten Sie, dass sich dies vom Analysefenster
unterscheidet, welches die Einsch�tzung in Bauerneinheiten aus der
Sicht von Wei� zeigt. </li>
<li> <b>cX</b> Kommentar (wobei <b>X</b> eine Ziffer ist, 0-9).</li>
<li> <b>eco</b> Er�ffnungscode des <a ECO>ECO</a>-Systems.</li>
<li> <b>id</b> Eindeutige Identifizierung dieser Stellung.</li>
<li> <b>nic</b> Er�ffnungscode des <i>New-In-Chess</i>-Systems.</li>
<li> <b>pm</b> Vorhergesagter Zug: der erste Zug der PV.</li>
<li> <b>pv</b> Vorhergesagte Variante: die beste Variante.</li>
</ul>
</p>
<p>
EPD-Dateien haben einen vielfachen Nutzen: Scid verwendet EPD-Dateien,
um Partien nach dem System der <a ECO>Enzyklop�die der
Schacher�ffnungen</a> (ECO) zu klassifizieren, und Sie k�nnen eine
EPD-Datei f�r Ihr Er�ffnungsrepertoire erstellen, mit Kommentaren
zu Stellungen, die Sie regelm��ig auf dem Brett haben.
</p>
<p>
Mit den Optionen <menu>Neu</menu> und <menu>�ffnen</menu>
im <menu>Datei</menu>-Men� k�nnen Sie eine neue EPD-Datei erstellen
bzw. eine bestehende �ffnen. Maximal vier EPD-Dateien k�nnen
gleichzeitig ge�ffnet sein.
</p>

<h3>EPD-Fenster</h3>
<p>
F�r jede ge�ffnete EPD-Datei sehen Sie ein Fenster, welches den Text zur
aktuellen Stellung zeigt. Sie m�ssen nicht den Schalter "Speichern"
bet�tigen, um �nderungen des Textes zu sichern; der Text wird jedesmal
gespeichert, wenn Sie zu einer anderen Partiestellung gehen.
</p>

<h3>In EPD-Dateien navigieren</h3>
<p>
Um sich durch die Stellungen in einer EPD-Datei zu bewegen, verwenden
Sie die Kommandos <menu>N�chste Position</menu> und <menu>Vorherige
Position</menu> im <menu>Werkzeuge</menu>-Men� des EPD-Fensters oder
die Tastenkombinationen <b>Strg+Ab</b> and <b>Strg+Auf</b>.
Diese Befehle gehen zur n�chsten/vorherigen Position in der Datei,
wobei sie die aktuelle Partie l�schen und die Ausgangsposition
herstellen.
</p>

<h3>EPD-Felder entfernen</h3>
<p>
EPD-Dateien, die Sie im Internet finden, enthalten m�glicherweise
Felder, die Sie nicht interessieren und die eine Menge Speicherplatz
in der Datei verschwenden.
Beispielsweise k�nnte eine EPD-Datei mit Computerauswertungen die Felder
ce, acd, acn, pm, pv und id enthalten, Sie brauchen aber vielleicht
nur das ce- und pv-Feld.
</p>
<p>
Sie k�nnen einen EPD-Opcode mit dem Men�punkt <menu>EPD-Feld
entfernen</menu> im <menu>Werkzeuge</menu>-Men� des EPD-Fensters
aus allen Stellungen in der EPD-Datei entfernen.
</p>

<h3>Die Statusanzeige des EPD-Fensters</h3>
<p>
Die Statuszeile jedes EPD-Fensters zeigt:
<ul>
<li>- den Dateistatus (<b>--</b> hei�t unver�ndert, <b>XX</b> hei�t
      ver�ndert und <b>%%</b> hei�t schreibgesch�tzt); </li>
<li>- den Dateinamen; </li>
<li>- die Anzahl der Positionen in der Datei; </li>
<li>- zul�ssige Z�ge in der aktuellen Stellung, die eine andere
Stellung in der EPD-Datei erreichen .</li>
</ul>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


###################
### Exporting help:

set helpTitle(D,Export) "Partien exportieren"
set helpText(D,Export) {<h1>Partien exportieren</h1>
<p>
Sie k�nnen die Kommandos im <menu>Werkzeuge</menu>-Men� benutzen, um die
aktuelle Partie oder alle Partien im aktuellen Filter in eine Textdatei
zu exportieren.
</p>
<p>
Drei Textdatei-Formate stehen zur Verf�gung: <a PGN>PGN</a> (portable
game notation), HTML (f�r Webseiten) und LaTeX (ein popul�res
Textsatzsystem).
</p>
<p>
Beim Exportieren k�nnen Sie w�hlen, eine neue Datei zu erstellen
oder die Partien einer existierenden Partiendatei hinzuzuf�gen.
</p>

<h3>Diagramme</h3>
<p>
Wenn Sie im HTML- oder LaTeX-Format exportieren, f�gt Scid automatisch
�berall dort ein Diagramm ein, wo ein Diagramm-<a NAGs>NAG</a> ("D")
oder ein mit dem Zeichen "#" beginnender <a Comment>Kommentar</a>
in der Partie vorkommt.
</p>

<h3><name Null>Nullz�ge beim PGN-Export</name></h3>
<p>
Scid erlaubt es, in einer Partie <a Annotating Null>Null- (leere)
Z�ge</a> zu speichern, da diese beim Kommentieren mit Varianten
hilfreich sein k�nnen. Allerdings gibt es im PGN-Standard keine
Nullz�ge. Wenn Sie also Scid-Partien mit Nullz�gen in eine PGN-Datei
exportieren, werden andere Programme zum PGN-Lesen nicht in der Lage
sein, die Nullz�ge zu lesen.
</p>
<p>
Um dieses Problem zu l�sen, stellt Scid eine weitere Option bereit,
<b>Nullz�ge in Kommentare umwandeln</b>, wenn Partien in PGN-Format
exportiert werden. Wenn Sie eine PGN-Datei erstellen wollen, die von
anderer Software verwendet werden kann, schalten Sie diese Option ein,
und Varianten, die Nullz�ge enthalten, werden in Kommentare umgewandelt.
Wenn Sie jedoch eine PGN-Dateie erstellen wollen, die sp�ter wieder
unter Beibehaltung der Nullz�ge von Scid importiert werden kann,
lassen Sie diese Option aus.
</p>

<h3>HTML-Export</h3>
<p>
Scid kann Partien in eine HTML-Datei exportieren. Um Diagramme einzuf�gen,
m�ssen die Diagrammbilder (im Verzeichnis "<b>bitmaps/</b>" mitgeliefert)
in einem Unterverzeichnis "<b>bitmaps/</b>" unterhalb des Verzeichnisses
sein, wo sich die HTML-Datei befindet.
</p>

<h3>LaTeX-Export</h3>
<p>
Scid kann Partien in eine LaTeX-Datei exportieren. Partien werden in
zwei Spalten pro Seite gedruckt und Z�ge in figuriner algebraischer
Notation.
</p>
<p>
F�r weitere Informationen siehe die Hilfeseite <a LaTeX>Scid und LaTeX</a>.
</p>

<p><footer>(Aktualisiert: Scid 3.4, Juli 2002)</footer></p>
}


####################
### Flags help:

set helpTitle(D,Flags) "Partie-Kennzeichen"
set helpText(D,Flags) {<h1>Partie-Kennzeichen</h1>

<p>
Eine <term>Kennzeichen</term> ("flag") ist ein Kennzeichen irgendeiner
Schach-Charakteristik, die f�r jede Partie der Datenbank ein- oder
ausgeschaltet werden kann. Es gibt 13 vom Benutzer einstellbare
Kennzeichen, die Sie direkt f�r jede Partie setzen k�nnen. Von diesen
hat nur die L�sch-Kennzeichen eine besondere Bedeutung: Partien, bei
denen die L�sch-Kennzeichen eingeschaltet ist, sind zur L�schung
vorgemerkt und werden entfernt, wenn die Datenbank
<a Compact>komprimiert</a> wird.
</p>
<p>
Die anderen 12 vom Benutzer einstellbaren Kennzeichen und ihre
Symbole sind:
</p>

<ul>
<li>Er�ffnung Wei� (W)</li>
<li>Er�ffnung Schwarz (B)</li>
<li>Mittelspiel (M)</li>
<li>Endspiel (E)</li>
<li>Neuerung (N)</li>
<li>Bauernstruktur (P)</li>
<li>Taktik (T)</li>
<li>Spiel auf dem Damenfl�gel (Q)</li>
<li>Spiel auf dem K�ngsfl�gel (K)</li>
<li>Brilliant (!)</li>
<li>Patzer (?)</li>
<li>Benutzer-definiert (U)</li>
</ul>

<p>
Eine Kennzeichen kann f�r die aktuelle Partie, f�r alle Partien im
Filter oder f�r alle Partien der Datenbank im
<a Maintenance>Wartungs</a>-Fenster gesetzt werden.
</p>
<p>
Sie k�nnen die <a Searches Header>Suche nach Partiedaten</a> benutzen,
um alle Datenbankpartien zu finden, die ein bestimmtes Kennzeichen ein-
oder ausgeschaltet haben, oder die Kennzeichen als Teil einer
komplexeren Suche verwenden.
</p>
<p>
Da alle vom Benutzer einstellbaren Kennzeichen keine Bedeutung f�r
Scid haben (mit Ausnahme der L�sch-Kennzeichen), k�nnen Sie diese f�r
Ihre eigenen Bed�rfnisse  verwenden. Zum Beispiel k�nnten Sie die
Kennzeichen "Spiel auf dem K�ngsfl�gel" (K) f�r Bauernst�rme auf den
K�nig verwenden, f�r Figurenangriffe auf den K�nig oder auch f�r
Endspiele mit allen Bauern auf dem K�nigsfl�gel.
</p>

<p><footer>(Aktualisiert: Scid 4.7, Juni 2018)</footer></p>
}


###############
### LaTeX help:

set helpTitle(D,LaTeX) "Scid und LaTeX"
set helpText(D,LaTeX) {<h1>Scid und LaTeX</h1>
<p>
Scid kann Partien und Er�ffnungsberichte im LaTeX-Format in Dateien
sichern. LaTeX ist eine Erweiterung von TeX, einem popul�ren Textsatzsystem.
</p>
<p>
Um die von Scid erzeugten LaTeX-Dateien darzustellen, m�ssen Sie
(nat�rlich) LaTeX haben und das Schachzeichensatz-Paket "chess12"
installiert haben. Dieses Paket ist normalerweise nicht Teil der
LaTeX-Standardinstallation, d.h selbst wenn Sie LaTeX haben, haben
Sie vielleicht nicht den Schachzeichensatz.
</p>
<p>
Informationen zum Herunterladen und Installieren des
LaTeX-Schachzeichensatzes finden Sie auf der Seite
<url http://scid.sourceforge.net/latex.html>Using LaTeX with Scid</url>
der <url http://scid.sourceforge.net/>Scid-Website</url>.
</p>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


###########################
### Options and Fonts help:

set helpTitle(D,Options) "Options"
set helpText(D,Options) {<h1>Optionen und Pr�ferenzen</h1>
<p>
Viele Optionen und Pr�ferenzen in Scid (z.B. die Brettgr��e, Farben, Schachbrettmuster,
Zeichens�tze und Standardwerte) kann man im <menu>Optionen</menu>-Men�
ver�ndern. Alle diese (und mehr, wie etwa das letzte Verzeichnis, aus
dem Sie eine Datenbank gelesen haben, und die Gr��e einiger Fenster)
werden in einer Optionendatei gesichert, wenn Sie im Optionen-Men�
<b>Optionen speichern</b> w�hlen.
Jedesmal, wenn Sie Scid starten, wird die Optionendatei geladen.
</p>
<p>
Wenn Sie mit Windows arbeiten, ist die Optionendatei <b>options.dat</b>
im Unterverzeichnis "config" der Scids Programmdatei abgelegt. F�r Benutzer von
Unix-Betriebssystemen (wie Solaris oder Linux) ist die Datei
<b>~/.scid/scidrc</b>.
</p>

<h3><name MyPlayerNames>Ihre Spielernamen festlegen</name></h3>
<p>
Es kann sein, dass Sie f�r einen (oder mehrere) Spieler das Brett im
Haupfenster aus der Sicht dieses Spielers aufgestellt haben m�chten,
wenn eine seiner Partien geladen wird. Sie k�nnen eine Liste solcher
Namen mit <b>Meine Spielernamen...</b> im Men� <menu>Optionen/Schachbrett</menu>
anlegen. In dem Dialogfenster geben Sie dann einen Spielernamen pro Zeile
ein. Jokerzeichen ("<b>?</b>" f�r genau ein beliebiges Zeichen, "<b>*</b>"
f�r eine Zeichenkette von null oder mehr Zeichen) sind erlaubt.
</p>

<h3><name Fonts>Zeichens�tze einstellen</name></h3>
<p>
Scid hat drei Basis-Zeichens�tze, die in den meisten Fenstern verwendet
werden, und Sie k�nnen alle drei individuell anpassen. Sie hei�en
<b>normal</b>, <b>klein</b> und <b>fest</b>.
</p>
<p>
Der feste Zeichensatz sollte ein Zeichensatz mit fester Breite
(nicht-proportional) sein. Er wird f�r den <a Tree>Zugbaum</a> und die
<a Crosstable>Turniertabelle</a> verwendet.
</p>

<p><footer>(Aktualisiert: Scid 4.7, Mai 2021)</footer></p>
}


####################
### Pgnscid help:

set helpTitle(D,Pgnscid) "Pgnscid"
set helpText(D,Pgnscid) {<h1>Pgnscid</h1>
<p>
<term>Pgnscid</term> ist ein separates Program, das Sie zur
Konvertierung von PGN-Dateien ("portable game notation") nach
Scid-Datenbanken ben�tigen.
</p>
<p>
Um eine Datei namens <i>partien.pgn</i> umzuwandeln, tippen Sie
einfach
<ul>
<li> <b>pgnscid partien.pgn</b> </li>
</ul>
ein, und die Scid-Datenbank (bestehend aus den Dateien
<i>partien.si3</i>, <i>partien.sg3</i> und <i>partien.sn3</i>) wird
erstellt.
Fehlermeldungen oder Warnungen werden in die Datei <i>partien.err</i>
geschrieben.
</p>
<p>
Wenn Sie wollen, dass die Datenbank in einem anderen Verzeichnis oder
mit einem anderen Namen erstellt wird, k�nnen Sie den Datenbanknamen
in der Kommandozeile mit angeben, zum Beispiel erstellt
<ul>
<li> <b>pgnscid partien.pgn datenbank</b> </li>
</ul>
eine Datenbank bestehend aus den Dateien <i>datenbank.si3</i>,
<i>datenbank.sg3</i> und <i>datenbank.sn3</i>.
</p>
<p>
Beachten Sie, dass pgnscid (und auch scid) mit gzip komprimierte
PGN-Dateien (z.B. <b>datenbank.pgn.gz</b>) direkt lesen kann, wenn Sie
also eine gro�e PGN-Datei mit gzip komprimiert haben, um Speicherplatz
zu sparen, m�ssen Sie sie nicht zuerst dekomprimieren.
</p>

<h3>Optionen</h3>
<p>
Pgnscid akzeptiert zwei optionale Argumente vor dem Dateinamen:
<b>-f</b> und <b>-x</b>.
</p>
<p>
Die Option <b>-f</b> erzwingt das �berschreiben einer existierenden
Datenbank; standardm��ig wandelt pgnscid nicht in eine bereits
bestehende Datenbank um.
</p>
<p>
Die Option <b>-x</b> veranla�t pgnscid, Text zwischen den Partien zu
ignorieren. Gem�� Voreinstellung wird Text zwischen Partien als
Kommentar vor der folgenden Partie gespeichert. Diese Option betrifft
nur Text zwischen Partien; Standardkommentare innerhalb der Partien
werden weiterhin konvertiert und gespeichert.
</p>

<h3>Spielernamen formatieren</h3>
<p>
Um die Anzahl verschiedener Namensschreibweisen desselben Spielers
zu reduzieren, werden von pgnscid einige Grundformatierungen
durchgef�hrt. Zum Beispiel wird die Anzahl der Leerzeichen nach einem
Komma auf eins gesetzt, Leerzeichen am Anfang oder Ende eines Namens
werden ebenso wie ein Punkt am Namensende entfernt.
Holl�ndische Namenszus�tze wie "van den" und "Van Der" werden ebenfalls
normalisiert, so dass sie ein gro�es "V" und kleines "d" haben.
</p>
<p>
Sie k�nnen Spieler-, Turnier-, Orts- und Rundenbezeichnungen in Scid
bearbeiten (und sogar automatische Schreibkorrekturen durchf�hren);
zu den Details siehe die Hilfeseite <a Maintenance Editing>Wartung</a>.
</p>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


#################
### Sorting help:

set helpTitle(D,Sorting) "Datenbank sortieren"
set helpText(D,Sorting) {<h1>Eine Datenbank sortieren</h1>
<p>
Die <term>Sortier</term>-Funktionen sortieren alle Partien einer
Datenbank. Sie k�nnen mehrere Sortierkriterien ausw�hlen.
Wenn zwei Partien nach einem Kriterium gleichrangig sind, werden
sie nach dem zweiten Kriterium sortiert, und so weiter.
</p>

<h3>Sortierkriterien</h3>
<p>
Die verf�gbaren Sortierkriterien sind:
</p>
<ul>
<li> Datum (�lteste Partien zuerst)
<li> Jahr (wie Datum, aber nur das Jahr wird verwendet)
<li> Turnier (Ereignis)
<li> Ort
<li> Land (die letzten 3 Buchstaben des Ortes)
<li> Runde
<li> Wei�
<li> Elo-Zahl (Durchschnitt von Wei� und Schwarz, h�here zuerst)
<li> Schwarz
<li> Ergebnis (Wei� gewinnt, danach Remis, danach Schwarz gewinnt)
<li> L�nge (Anzahl ganzer Z�ge in der Partie)
<li> ECO (Code der <a ECO>Enzyklop�die der Schacher�ffnungen</a>)
</ul>

<h3>Sortierergebnis</h3>
<p>
Wenn Sie eine nicht schreibgesch�tzte Scid-Datenbank sortieren, wird das
Sortierergebnis gesichert, so dass die Reihenfolge der Datenbankpartien
dauerhaft ge�ndert ist. Falls Sie nur eine tempor�re Sortierung wollen,
sch�tzen Sie die Datenbank zuerst gegen �berschreiben mit dem Men�punkt
<menu>Datei: Schreibschutz</menu>.
</p>
<p>
Wenn Sie eine Datenbank sortieren, die schreibgesch�tzt ist oder aus
einer PGN-Datei besteht, kann das Sortierergebnis nicht gesichert werden,
so dass die sortierte Partiereihenfolge verloren geht, wenn die Datei
geschlossen wird.
</p>
<p>
Beachten Sie, dass das Sortieren einer Datenbank den
<a Searches Filter>Suchfilter</a> zur�cksetzt auf alle Partien.
</p>

<h3>Wichtiger Hinweis zum Datenbank sortieren:</h3>
<p>
Wenn eine Datenbank sortiert wurde, ist die Indexdatei ge�ndert, die
Partiendatei aber unver�ndert. Das hei�t, das Sortieren einer Datenbank
hinterl��t die Partiedatens�tze der Datei in einer zuf�lligen
Reihenfolge relativ zur Indexdatei. Das kann die <a Tree>Zugbaum</a>-,
Positions- und Material/Muster-<a Searches>Suche</a> merklich
<b>verlangsamen</b>, Sie sollten daher nach dem Datenbank sortieren
die Partiendatei durch <a Compact>Komprimieren</a> neuorganisieren,
um gute Suchleistungen zu erhalten.
</p>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


####################
### NAG values help:

set helpTitle(D,NAGs) "NAG-Werte"
set helpText(D,NAGs) {<h1>Standard-NAG-Werte</h1>
<p>
Standard-NAG-Werte (Numeric Annotation Glyph = "numerisches
Anmerkungszeichen"), im <a Author Related>PGN-Standard</a> definiert,
sind:
</p>
<cyan>
<ul>
<li>  1   Guter Zug (!) </li>
<li>  2   Schwacher Zug (?) </li>
<li>  3   Ausgezeichneter Zug (!!) </li>
<li>  4   Patzer / Grober Fehler (??) </li>
<li>  5   Interessanter Zug (!?) </li>
<li>  6   Zweifelhafter Zug (?!) </li>
<li>  7   Erzwungener Zug </li>
<li>  8   Der einzige Zug; keine vern�nftige Alternative </li>
<li>  9   Schlechtester Zug </li>
<li> 10   Ausgeglichene Position (=) </li>
<li> 11   Gleiche Chancen, ruhige Stellung (=) </li>
<li> 12   Gleiche Chancen, aktive Stellung (=) </li>
<li> 13   Unklare Stellung (~) </li>
<li> 14   Wei� hat leichten Vorteil, steht etwas besser (+=) </li>
<li> 15   Schwarz hat leichten Vorteil, steht etwas besser (=+) </li>
<li> 16   Wei� hat Vorteil, steht besser (+/-) </li>
<li> 17   Schwarz hat Vorteil, steht besser (-/+) </li>
<li> 18   Wei� hat entscheidenden Vorteil (+-) </li>
<li> 19   Schwarz hat entscheidenden Vorteil (-+) </li>
<li> 20   Wei� hat �berw�ltigenden Vorteil (+-) </li>
<li> 21   Schwarz hat �berw�ltigenden Vorteil (-+) </li>
<li> 22   Wei� ist in Zugzwang </li>
<li> 23   Schwarz ist in Zugzwang </li>
<li> 24   Wei� hat leichten Raumvorteil </li>
<li> 25   Schwarz hat leichten Raumvorteil </li>
<li> 26   Wei� hat Raumvorteil </li>
<li> 27   Schwarz hat Raumvorteil </li>
<li> 28   Wei� hat entscheidenden Raumvorteil </li>
<li> 29   Schwarz hat entscheidenden Raumvorteil </li>
<li> 30   Wei� hat leichten Zeit-(Entwicklungs)vorsprung </li>
<li> 31   Schwarz hat leichten Zeit-(Entwicklungs)vorsprung </li>
<li> 32   Wei� hat Zeit-(Entwicklungs)vorsprung </li>
<li> 33   Schwarz hat Zeit-(Entwicklungs)vorsprung </li>
<li> 34   Wei� hat entscheidenden Zeit-(Entwicklungs)vorsprung </li>
<li> 35   Schwarz hat entscheidenden Zeit-(Entwicklungs)vorsprung </li>
<li> 36   Wei� hat die Initiative </li>
<li> 37   Schwarz hat die Initiative </li>
<li> 38   Wei� hat andauernde Initiative </li>
<li> 39   Schwarz hat andauernde Initiative </li>
<li> 40   Wei� hat Angriff </li>
<li> 41   Schwarz hat Angriff </li>
<li> 42   Wei� hat keine ausreichende Kompensation f�r das Material </li>
<li> 43   Schwarz hat keine ausreichende Kompensation f�r das Material </li>
<li> 44   Wei� hat ausreichende Kompensation f�r das Material </li>
<li> 45   Schwarz hat ausreichende Kompensation f�r das Material </li>
<li> 46   Wei� hat mehr als ausreichende Kompensation f�r das Material </li>
<li> 47   Schwarz hat mehr als ausreichende Kompensation f�r das Material </li>
<li> 48   Wei� hat leichtes �bergewicht im Zentrum </li>
<li> 49   Schwarz hat leichtes �bergewicht im Zentrum </li>
<li> 50   Wei� hat �bergewicht im Zentrum </li>
<li> 51   Schwarz hat �bergewicht im Zentrum </li>
<li> 52   Wei� hat entscheidendes �bergewicht im Zentrum </li>
<li> 53   Schwarz hat entscheidendes �bergewicht im Zentrum </li>
<li> 54   Wei� hat leichtes �bergewicht am K�nigsfl�gel </li>
<li> 55   Schwarz hat leichtes �bergewicht am K�nigsfl�gel </li>
<li> 56   Wei� hat �bergewicht am K�nigsfl�gel </li>
<li> 57   Schwarz hat �bergewicht am K�nigsfl�gel </li>
<li> 58   Wei� hat entscheidendes �bergewicht am K�nigsfl�gel </li>
<li> 59   Schwarz hat entscheidendes �bergewicht am K�nigsfl�gel </li>
<li> 60   Wei� hat leichtes �bergewicht am Damenfl�gel </li>
<li> 61   Schwarz hat leichtes �bergewicht am Damenfl�gel </li>
<li> 62   Wei� hat �bergewicht am Damenfl�gel </li>
<li> 63   Schwarz hat �bergewicht am Damenfl�gel </li>
<li> 64   Wei� hat entscheidendes �bergewicht am Damenfl�gel </li>
<li> 65   Schwarz hat entscheidendes �bergewicht am Damenfl�gel </li>
<li> 66   Wei� hat eine schwache Grundreihe </li>
<li> 67   Schwarz hat eine schwache Grundreihe </li>
<li> 68   Wei� hat eine gut gesicherte Grundreihe </li>
<li> 69   Schwarz hat eine gut gesicherte Grundreihe </li>
<li> 70   Wei� hat einen schlecht gesicherten K�nig </li>
<li> 71   Schwarz hat einen schlecht gesicherten K�nig </li>
<li> 72   Wei� hat einen gut gesicherten K�nig </li>
<li> 73   Schwarz hat einen gut gesicherten K�nig </li>
<li> 74   Der wei�e K�nig steht schlecht </li>
<li> 75   Der schwarze K�nig steht schlecht </li>
<li> 76   Der wei�e K�nig steht gut </li>
<li> 77   Der schwarze K�nig steht gut </li>
<li> 78   Wei� hat eine sehr schwache Bauernstruktur </li>
<li> 79   Schwarz hat eine sehr schwache Bauernstruktur </li>
<li> 80   Wei� hat eine schwache Bauernstruktur </li>
<li> 81   Schwarz hat eine schwache Bauernstruktur </li>
<li> 82   Wei� hat eine starke Bauernstruktur </li>
<li> 83   Schwarz hat eine starke Bauernstruktur </li>
<li> 84   Wei� hat eine sehr starke Bauernstruktur </li>
<li> 85   Schwarz hat eine sehr starke Bauernstruktur </li>
<li> 86   Der wei�e Springer steht schlecht </li>
<li> 87   Der schwarze Springer steht schlecht </li>
<li> 88   Der wei�e Springer steht gut </li>
<li> 89   Der schwarze Springer steht gut </li>
<li> 90   Der wei�e L�ufer steht schlecht </li>
<li> 91   Der schwarze L�ufer steht schlecht </li>
<li> 92   Der wei�e L�ufer steht gut </li>
<li> 93   Der schwarze L�ufer steht gut </li>
<li> 94   Der wei�e Turm steht schlecht </li>
<li> 95   Der schwarze Turm steht schlecht </li>
<li> 96   Der wei�e Turm steht gut </li>
<li> 97   Der schwarze Turm steht gut </li>
<li> 98   Die wei�e Dame steht schlecht </li>
<li> 99   Die schwarze Dame steht schlecht </li>
<li>100   Die wei�e Dame steht gut </li>
<li>101   Die schwarze Dame steht gut </li>
<li>102   Die wei�en Figuren sind schlecht koordiniert </li>
<li>103   Die schwarzen Figuren sind schlecht koordiniert </li>
<li>104   Die wei�en Figuren sind gut koordiniert </li>
<li>105   Die schwarzen Figuren sind gut koordiniert </li>
<li>106   Wei� hat die Er�ffnung sehr schwach behandelt </li>
<li>107   Schwarz hat die Er�ffnung sehr schwach behandelt </li>
<li>108   Wei� hat die Er�ffnung schwach behandelt </li>
<li>109   Schwarz hat die Er�ffnung schwach behandelt </li>
<li>110   Wei� hat die Er�ffnung gut behandelt </li>
<li>111   Schwarz hat die Er�ffnung gut behandelt </li>
<li>112   Wei� hat die Er�ffnung sehr gut behandelt </li>
<li>113   Schwarz hat die Er�ffnung sehr gut behandelt </li>
<li>114   Wei� hat das Mittelspiel sehr schwach behandelt </li>
<li>115   Schwarz hat das Mittelspiel sehr schwach behandelt </li>
<li>116   Wei� hat das Mittelspiel schwach behandelt </li>
<li>117   Schwarz hat das Mittelspiel schwach behandelt </li>
<li>118   Wei� hat das Mittelspiel gut behandelt </li>
<li>119   Schwarz hat das Mittelspiel gut behandelt </li>
<li>120   Wei� hat das Mittelspiel sehr gut behandelt </li>
<li>121   Schwarz hat das Mittelspiel sehr gut behandelt </li>
<li>122   Wei� hat das Endspiel sehr schwach behandelt </li>
<li>123   Schwarz hat das Endspiel sehr schwach behandelt </li>
<li>124   Wei� hat das Endspiel schwach behandelt </li>
<li>125   Schwarz hat das Endspiel schwach behandelt </li>
<li>126   Wei� hat das Endspiel gut behandelt </li>
<li>127   Schwarz hat das Endspiel gut behandelt </li>
<li>128   Wei� hat das Endspiel sehr gut behandelt </li>
<li>129   Schwarz hat das Endspiel sehr gut behandelt </li>
<li>130   Wei� hat etwas Gegenspiel </li>
<li>131   Schwarz hat etwas Gegenspiel </li>
<li>132   Wei� hat Gegenspiel </li>
<li>133   Schwarz hat Gegenspiel </li>
<li>134   Wei� hat entscheidendes Gegenspiel </li>
<li>135   Schwarz hat entscheidendes Gegenspiel </li>
<li>136   Wei� ist in leichter Zeitnot </li>
<li>137   Schwarz ist in leichter Zeitnot </li>
<li>138   Wei� ist in erheblicher Zeitnot </li>
<li>139   Schwarz ist in erheblicher Zeitnot </li>
</ul>
</cyan>

<p>
Weitere vorgeschlagene NAG-Werte f�r Schachinformator-Symbole sind u.a.:
</p>
<cyan>
<ul>
<li>140   Mit der Idee ... </li>
<li>141   Gerichtet gegen ... </li>
<li>142   Besser ist </li>
<li>143   Schlechter ist </li>
<li>144   Gleichwertig ist </li>
<li>145   Anmerkung des Herausgebers ("RR") </li>
<li>146   Neuerung ("N") </li>
<li>147   Schwacher Punkt </li>
<li>148   Endspiel </li>
<li>149   Linie </li>
<li>150   Diagonale </li>
<li>151   Wei� hat das L�uferpaar </li>
<li>152   Schwarz hat das L�uferpaar </li>
<li>153   Verschiedenfarbige L�ufer </li>
<li>154   Gleichfarbige L�ufer </li>
</ul>
</cyan>

<p>
Andere Vorschl�ge sind:
</p>
<cyan>
<ul>
<li>190   Etc. </li>
<li>191   Doppelbauern </li>
<li>192   Isolierte Bauern </li>
<li>193   Verbundene Bauern </li>
<li>194   H�ngende Bauern </li>
<li>195   R�ckst�ndiger Bauer </li>
</ul>
</cyan>

<p>
Von Scid definierte Symbole zum internen Gebrauch:
</p>
<cyan>
<ul>
<li>201   Diagramm ("D", manchmal auch "#") </li>
</ul>
</cyan>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


######################
### File formats help:

set helpTitle(D,Formats) "Datei-Formate"
set helpText(D,Formats) {<h1>Scids Datei-Formate</h1>
<p>
Scid-Datenbanken bestehen aus drei essentiellen Dateien: eine
Indexdatei, eine Namendatei und eine Partiendatei. Alle haben eine
zweibuchstabige Dateiendung, beginnend mit "s": ".si" f�r Indexdateien,
".sn" f�r Namendateien und ".sg" f�r Partiendateien.
</p>

<h3>Die Indexdatei (.si)</h3>
<p>
Diese Datei enth�lt eine Beschreibung der Datenbank und f�r jede Partie
einen kleinen Eintrag fester L�nge. Die aktuelle Gr��e ist 41 Bytes
pro Partie. Von diesen sind 28 Bytes wesentliche Informationen wie
Ergebnis, Datum, Indizes f�r Spieler-, Turnier-, Ortsnamen (die
tats�chlichen Namen befinden sich in der Namendatei) etc.
</p>
<p>
Die verbleibenden 13 Bytes enthalten redundante, aber n�tzliche
Informationen zur Partie, die zur Beschleunigung der Positions-,
Material- und Mustersuche genutzt werden. Siehe den Abschnitt
<a Formats Fast>Schnelles Suchen</a> weiter unten f�r weitere
Informationen.
</p>

<h3>Die Namendatei (.sn)</h3>
<p>
Diese Datei enth�lt alle Spieler-, Turnier-, Orts- und Rundennamen, die
in der Datenbank verwendet werden. Jeder Name ist nur einmal gespeichert,
auch wenn er in vielen Partien vorkommt. Die Namendatei ist �blicherweise
die kleinste der drei essentiellen Datenbankdateien.
</p>

<h3>Die Partiendatei (.sg)</h3>
<p>
Diese Datei enth�lt die aktuellen Z�ge, Varianten und Kommentare jeder
Partie. Die Zugkodierung ist sehr kompakt: die meisten Z�ge ben�tigen
nur ein Byte.
</p>
<p>
Wenn eine Partie ersetzt wird, wird ihre neue Version am <i>Ende</i>
der Datei gespeichert, so dass sich �ber die Zeit nicht genutzter
Speicherplatz ansammelt. Sie k�nnen durch <a Compact>Komprimieren</a>
die minimale Gr��e einer Datenbank wiederherstellen.
</p>

<h3>Andere Scid-Dateien</h3>
<p>
Eine <a EPD>EPD</a>-Datei (Dateiendung: ".epd") enth�lt eine Reihe von
Schachpositionen, jede mit einem Textkommentar.
Das EDP-Dateiformat ist beim <a Author Related>PGN-Standard</a>
beschrieben.
</p>
<p>
Eine E-Mail-Datei (Dateiendung: ".sem") einer Datenbank speichert
Daten der Gegner, denen Sie E-Mails senden.
</p>
<p>
Eine Suchoptionsdatei (Dateiendung: ".sso") enth�lt Einstellungen f�r
eine <a Searches Header>Partiedaten</a>- oder
<a Searches Material>Material/Muster</a>-Suche.
</p>

<h3><name Fast>Schnelles Suchen in Scid</name></h3>
<p>
Wie oben erw�hnt, enth�lt die Indexdatei einige redundante, aber
n�tzliche Informationen �ber jede Partie, um Positions- oder
Materialsuchen zu beschleunigen.
</p>
<p>
Beispielsweise ist das Material der Schlu�stellung gespeichert. Wenn Sie
nach Turm- und Bauernendspielen suchen, werden alle Partien, die mit
einer Dame, einem L�ufer oder einem Springer auf dem Brett enden,
schnell �bergangen.
</p>
<p>
Eine andere n�tzliche Teilinformation ist in der Reihenfolge gespeichert,
in der Bauern ihre Ausgangsstellung verlassen haben (durch Ziehen oder
Geschlagenwerden). Dies wird zur Beschleunigung von Zugbaum- oder exakten
Suchen verwendet, insbesondere nach Er�ffnungspositionen. Beispielsweise
wird bei der Suche nach der Ausgangsstellung der Franz�sischen
Verteidigung (1.e4 e6) jede Partie, die mit 1.e4 c5 oder 1.d4 etc.
beginnt, ausgelassen, Partien, die mit 1.e4 e5 anfangen, m�ssen aber
immer noch durchsucht werden.
</p>

<p><footer>(Aktualisiert: Scid 2.5, Juni 2001)</footer></p>
}


################
### Contact info

set helpTitle(D,Author) "Kontakt-Information"
set helpText(D,Author) {<h1>Kontakt-Information</h1>
<p>
Die Scid Internet - Seite ist erreichbar unter: <br>
<b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>
</p>
<p>
Sie bietet Downloads der neuesten Versionen von Scid und einigen anderen
zus�tzlichen und n�tzlichen Dateien.
</p>
<p>
Bitte senden Sie Ihre Kommentare, Fragen, Vorschl�ge oder Fehlerberichte
an den Autor von Scid, Shane Hudson, an folgende E-Mail-Adresse: <br>
<b>scid-users@lists.sourceforge.net</b>
</p>

<h3><name Related>Links</name></h3>
<p>
Falls Sie Freude an Scid haben, k�nnten Sie die folgenden
Internetseiten interessieren:
</p>
<ul>
<li><url http://www.tim-mann.org/chess.html>http://www.tim_mann.org/chess.html</url> --
Homepage von Tim Mann's <b>xboard & winboard</b> Programm: eine grafische
Oberfl�che f�r Schachprogramme und Schnittstelle f�r Internet Schach
Server. Sie hat auch gute Informationen �ber Crafty, GNUchess und
andere Schachprogramme.</li>

<li><url http://theweekinchess.com/twic>http://theweekinchess.com/twic</url> --
TWIC (the week in chess), ein hervorragendes Wochenmagazin f�r
internationale Schachpartien, verf�gbar im PGN-Format. </li>

<li><url http://www.saremba.de/chessgml/standards/pgn/pgn-complete.htm>http://www.saremba.de/chessgml/standards/pgn/pgn-complete.htm</url> --
der <b>PGN-Standard</b>, geschaffen von Steven J. Edwards im Jahre 1994.
Die Seite erkl�rt das PGN- und EPD-Format im Detail.</li>
</ul>

<p><footer>(Aktualisiert: Scid 4.7, August 2018)</footer></p>
}

# Book window help
set helpTitle(D,Book) "Buch-Fenster"
set helpText(D,Book) {<h1>Buch-Fenster</h1>
  <p>
 Das Buch-Fenster zeigt eine Liste aller im Buch-Verzeichnis von Scid verf�gbaren Buch-Datenbanken an. Das Format der B�cher entspricht dem Format, welches von Polygot und den Engines Fruit und Toga verwendet wird.
  </p>
  <p>
 Das Buch-Fenster zeigt (aus dem ausgew�hlten Buch) f�r die aktuelle Position alle m�glichen Z�ge, die im Buch enthalten sind und deren relativen Gewichtungen in Prozent an. Bei jedem Zug wird das Buch-Fenster aktualisiert. Beim Anklicken eines Zuges im Buch-Fenster wird dieser Zug in die aktuelle Stellung �bernommen.
  </p>
  <p>
Zwischen den B�chern kann schnell gewechselt werden, in dem man in der oberen Liste ein anderes Buch ausw�hlt.
  </p>
  <p><footer>(Aktualisiert: Scid 3.6.21, Dezember 2007)</footer></p>
}

# Tactical game window help
set helpTitle(D,TacticalGame) "Trainingspartie-Fenster"
set helpText(D,TacticalGame) {<h1>Trainingspartie-Fenster</h1>
  <p>
  Hier kann eine Trainingspartie gegene eine Engine gespielt werden, die einen Gegner mit einer bestimmten ELO-Zahl simuliert.  
  Der Gegner wird von Phalanx gespielt, als Coach wird eine UCI-Engine eingesetzt. Diese Engines werden automatisch �ber ihre Namen ausgew�hlt und sollten korrekt konfiguriert sein. Standardm��ig werden diese Engines bei der Installation von Scid eingerichtet. 
  </p>
  <p>
  Folgende Parameter sind einzustellen:
  <ul>
  <li><term>Feste St�rke</term>: setzt eine feste Elo-Bewertung f�r den Gegner</li>.
  <li><term>Zufallsst�rke</term>: W�hlt eine zuf�llige St�rke zwischen der
  minimalen und maximalen St�rke, der durch den linken und rechten Schieberegler festgelegt wird, aus.
  </li>
  <li><term>Er�ffnung:</term>
  <ul>
     <li><term>Neue Partie</term>: startet ein neues Spiel mit einer zuf�lligen Er�ffnung.</li>
     <li><term>Von aktueller Position starten</term>: das Spiel bei der aktuellen Position fortsetzen.</li>
     <li><term>Ausgew�hlte Er�ffnung</term>: der Gegner spielt eine �ffnung, die aus der Liste ausgew�hlt werden kann. Das ist n�tzlich f�r das Er�ffnungstraining.</li>
  </ul>
  <li><term>Analysezeit der Engine begrenzen</term> erlaubt es, die vom Coach verwendete Zeit, um die Z�ge der Spieler auf Fehler zu �berpr�fen, zu begrenzen. Wenn dies nicht der Fall ist, darf der Coach im Hintergrund rechnen.</li><br>
  <p>Tipp: Schalten Sie die <a Graphs>Partiebewertung</a> ein, dann k�nnen Sie w�hrend der Partie den Verlauf der Zeit und die Bewertung der Stellung sehen.</p>
  <p>Eine �hnliche Funktion kann bei einer <a SeriousGame>Ernsten Partie</a> durch das limitieren der Spielst�rke einer UCI-Engine erreicht werden.</p>
  <p>Zum Starten der Partie "Spielen" dr�cken.</p> 
  <p><footer>(Aktualisiert: Scid 4.7, August 2018)</footer></p>
}

# Opening Trainer window help
set helpTitle(D,OpeningTrainer) "Er�ffnungstrainer"
set helpText(D,OpeningTrainer) {<h1>Er�ffnungstrainer</h1>
  <p>
   Eine SCID-Datenbank kann als Repertoire verwendet werden, wobei jedes Spiel eine Er�ffnungslinie darstellt. Die Spiele k�nnen Varianten enthalten. Auch NAG-Werte k�nnen angegeben werden, um so bevorzugte oder zweifelhafte Zeilen zu markieren. Eine Datenbank f�r den Er�ffnungstrainer muss auch vom richtigen Typ sein: Das hei�t, wenn �ffnungen f�r Wei� trainiert werden sollen, muss die Datenbank vom Typ �ffnungen f�r Wei� sein (�hnlich f�r Schwarz und beide Farben). Der Typ kann �ber das Fenster Wartung durch Auswahl des Symbols oder �ber das Kontextmen� des Datenbankumschalters eingestellt werden. 
  Eine Scid Datenbank kann als Repertoire genutzt werden, wenn sie mit dem entsprechenden Typ/Icon markiert wurde. Die Datenbank muss einer der folgenen Typen sein:
  <li>Openings for White</li>
  <li>Openings for Black</li>
  <li>Openings for either Color</li> <br>
  Der Typ muss mit der Auswahl "Konfiguration Trainingsrepertoire" (Wei�, Schwarz, Beide) �bereinstimmen. Jede Partie repr�sentiert eine Er�ffnungsvariante. 
  </p>
  
  <h3>Er�ffnungstrainer Statistik</h3>
  <p>
   Vier Zahlen zeigen die Statistik f�r die aktuelle Stellung:
  <ul>
  <li>Gr�n : Anzahl bereits korrekt gespielten Z�ge.</li>
  <li>Gelb : Anzahl zweifelhafter gespielter Z�ge im Repertoire</li>
  <li>Rot : Anzahl der Z�ge, die nicht im Repertoire enthalten sind.</li>
  <li>Wei� : H�ufigkeit der Stellung</li>
  </ul>
  </p>
  
  <h3>Der Bericht</h3>
  <p>
  Der Bericht zeigt f�r das ganze Repertoire Statistiken und gibt Informationen �ber das Wissen des Anwenders:  
  <ul>
  <li>Positionen im Repertoire: Anzahl der Positione im Repertoire (alle Varianten in der Datenbank)</li>
  <li>nicht gespielte Positionen : Anzahl der Stellungen, die bisher nie gespielt wurden</li>
  <li>gespielte Positionen : gespielte Stellungen und die Summe wie h�ufig sie ausgespielt wurden. Anmerkung: Diese Zahl repr�sentiert das Vorkommen der Stellung in allen Er�ffnungsvarianten: Diese Zahl kann f�r Stellungen nahe der Startaufstellung schnell sehr gro� werden.</li>
  <li>Erfolgreich : Anzahl der guten Z�ge durch den Spieler</li>
  <li>Zweifelhafte Z�ge : Anzahl der schwachen/schlechten Z�ge durch den Spieler</li>
  <li>Nicht im Repertoire : Anzahl der Z�ge des Spieler, die nicht im Repertoire enthalten sind.</li>
  </ul>
  </p> 
  <p><footer>(Aktualisiert: Scid 3.6.21, Dezember 2007)</footer></p>
}


############################################################
#
# German tip of the day

set tips(D) {
  {
    Scid hat mehr als 30 <a Index>Hilfeseiten</a> und in den meisten
    Scid-Fenstern liefert die <b>F1</b>-Taste die Hilfeseite zu diesem
    Fenster.
  }
  {
    Einige Scid-Fenster (z.B. Informationsbereich und
    Datenbank-<a Switcher>Umschalter</a>) haben ein Kontextmenu.
    Dr�cken Sie einfach die rechte Maustaste in jedem Fenster, um zu
    sehen, ob es ein Men� hat und welche Funktionen zur Verf�gung
    stehen.
  }
  {
    Scid bietet Ihnen mehr als eine M�glichkeit, Schachz�ge einzugeben,
    und l��t Ihnen die Wahl, welche Ihnen am meisten zusagt. Sie k�nnen
    die Maus verwenden (mit oder ohne Zugvorschlag) oder die Tastatur
    (mit oder ohne Zugerg�nzung). F�r Details lesen Sie die Hilfeseite
    <a Moves>Z�ge eingeben</a>.
  }
  {
    Wenn Sie einige Datenbanken h�ufig �ffnen, f�gen Sie zu jeder ein
    <a Bookmarks>Lesezeichen</a> hinzu, dann k�nnen Sie sie schneller
    mit dem Lesezeichen-Men� �ffnen.
  }
  {
    Sie k�nnen alle Z�ge einer Partie (mit allen Varianten und
    Kommentaren) mit dem <a PGN>PGN-Fenster</a> betrachten. Im
    PGN-Fenster k�nnen Sie zu jedem beliebigen Zug gehen, indem Sie
    ihn mit der linken Maustaste anklicken oder mit der mittleren
    Maustaste eine Voransicht dieser Stellung erhalten.
  }
  {
    Sie k�nnen Partien mit der linken Maustaste per "Drag & Drop" im
    <a Switcher>Datenbank-Umschalter</a> von einer Datenbank in eine
    andere kopieren.
  }
  {
    Scid kann PGN-Dateien selbst dann �ffnen, wenn sie mit Gzip
    komprimiert wurden (Dateiname mit Erweiterung .gz). PGN-Dateien
    werden schreibgesch�tzt ge�ffnet. Wenn Sie also eine PGN-Datei
    editieren wollen, erstellen Sie eine neue Scid-Datenbank und
    kopieren die PGN-Datei mit dem <a Switcher>Datenbank-Umschalter</a>
    dorthin.
  }
  {
    Wenn Sie eine gro�e Datenbank haben, die Sie oftmals mit dem
    <a Tree>Zugbaumfenster</a> nutzen, lohnt es sich,
    <b>Cache-Datei f�llen</b> im Dateimen� des Zugbaumfensters zu
    w�hlen. Damit merken Sie sich Zugbaum-Statistiken f�r viele
    h�ufige Er�ffnungspositionen und beschleunigen den Zugriff auf
    den Zugbaum f�r die Datenbank.
  }
  {
    Das <a Tree>Zugbaum</a>-Fenster kann Ihnen alle Z�ge zeigen, die
    in der aktuellen Position gespielt wurden, aber wenn Sie auch alle
    Zugfolgen sehen wollen, mit denen diese Stellung erreicht wurde,
    finden Sie diese, wenn Sie einen <a Reports Opening>Er�ffnungsbericht</a>
    erstellen.
  }
  {
    Klicken Sie mit der linken oder rechten Maustaste auf die �berschrift
    einer Spalte im <a GameList>Partieliste</a>-Fenster , um ihre
    Breite anzupassen.
  }
  {
    Mit dem Fenster <a PInfo>Spielerinformation</a> (um es zu �ffnen,
    klicken Sie einfach auf einen Spielernamen im Informationsbereich
    unter dem Hauptfenster-Schachbrett) k�nnen Sie auf einfache Weise
    den <a Searches Filter>Filter</a> so einstellen, dass er alle Partien
    eines bestimmten Spielers mit einem bestimmten Ergebnis enth�lt,
    indem Sie auf irgendeinen <red>in Rot</red> dargestellten Wert
    klicken.
  }
  {
    Beim Er�ffnungsstudium kann es sehr hilfreich sein, f�r eine wichtige
    Position eine <a Searches Board>Brettsuche</a> mit der <b>Bauern</b>-
    oder <b>Linien</b>-Option durchzuf�hren, was andere Er�ffnungen
    entdecken k�nnte, die zur selben Bauernstruktur f�hren.
  }
  {
    Im Informationsbereich (unterhalb des Schachbretts) k�nnen Sie mit
    der rechten Maustaste ein Men� zur Gestaltung der Ausgabe aktivieren.
    Zum Beispiel k�nnen Sie Scid veranlassen, den n�chsten Zug zu
    verstecken, was n�tzlich ist, wenn man zum Trainieren eine Partie
    nachspielt und die Z�ge zu erraten versucht.
  }
  {
    Wenn Sie f�r eine gro�e Datenbank oftmals eine umfangreiche
    Datenbank-<a Maintenance>Wartung</a> durchf�hren, k�nnen Sie
    mehrere Wartungsarbeiten gleichzeitig mit dem
    <a Maintenance Cleaner>Bereiniger</a> ausf�hren.
  }
  {
    Wenn Sie eine gro�e Datenbank haben, wo die meisten Partien einen
    Turniereintrag besitzen und Sie wollen die Partien nach Datum
    sortiert haben, erw�gen Sie ein <a Sorting>Sortieren</a> nach
    Turnierdatum und Turnier anstatt nach Datum und Turnier, da
    Ihnen das hilft, Partien desselben Turniers mit unterschiedlichen
    Daten zusammen zu halten (nat�rlich unter der Voraussetzung, dass
    sie alle dasselbe Turnierdatum haben).
  }
  {
    Es ist eine gute Idee, vor einem <a Maintenance Twins>Dubletten
    l�schen</a> eine <a Maintenance Spellcheck>Schreibkorrektur</a>
    Ihrer Datenbank durchzuf�hren, da es dies Scid erm�glicht, mehr
    Dubletten zu finden und zum L�schen vorzumerken.
  }
  {
    <a Flags>Kennzeichen</a> sind n�tzlich, um Datenbankpartien mit
    Charakteristiken zu versehen, nach denen Sie zu einem sp�teren
    Zeitpunkt vielleicht suchen wollen, wie etwa Bauernstruktur, Taktik
    etc. Sie k�nnen mit der <a Searches Header>Partiedaten-Suche</a>
    nach Kennzeichen suchen.
  }
  {
    Wenn Sie eine Partie nachspielen und einige Z�ge ausprobieren
    wollen, ohne die Partie zu ver�ndern, schalten Sie einfach den
    Testmodus ein (mit der Tastenkombination <b>Strg+Leerzeichen</b>
    oder mit dem Symbol aus der Werkzeugleiste), und wenn Sie fertig
    sind, schalten Sie ihn wieder aus, um zur urspr�nglichen Partie
    zur�ckzukommen.
  }
  {
    Um die prominentesten Partien (Spieler mit hohen Elo-Zahlen)
    zu finden, die eine bestimmte Position erreicht haben, �ffnen
    Sie das <a Tree>Zugbaum</a>-Fenster und dort die Liste der
    besten Partien. Sie k�nnen sogar die Liste der besten Partien
    auf Partien mit einem bestimmten Ergebnis begrenzen.
  }
  {
    Eine ausgezeichnete Methode, eine Er�ffnung mit Hilfe einer gro�en
    Datenbank zu studieren, ist, den Trainingsmodus im
    <a Tree>Zugbaum</a>-Fenster zu aktivieren und dann gegen die
    Datenbank zu spielen, um zu sehen, welche Z�ge h�ufig vorkommen.
  }
  {
    Wenn Sie zwei Datenbanken ge�ffnet haben und die
    <a Tree>Zugbaum</a>-Statistik der ersten Datenbank sehen wollen,
    w�hrend Sie eine Partie der zweiten Datenbank untersuchen, dr�cken
    Sie einfach den Schalter <b>Anbinden</b> im Zugbaumfenster, um die
    Partie an die erste Datenbank zu binden, und wechseln dann zur
    zweiten Datenbank.
  }
  {
    Die <a Tmt>Turniersuche</a> ist nicht nur zum Auffinden eines
    bestimmten Turniers n�tzlich, sondern auch um zu sehen, an welchen
    Turnieren ein bestimmter Spieler vor kurzem teilgenommen hat,
    oder um die Spitzenturniere in einem bestimmten Land anzuzeigen.
  }
  {
    Es gibt eine Reihe h�ufiger Stellungsmuster, die im Fenster
    <a Searches Material>Material/Muster</a>-Suche definiert sind und
    die Ihnen beim Er�ffnungs- oder Mittelspielstudium n�tzlich sein
    k�nnen.
  }
  {
    Wenn Sie im Fenster <a Searches Material>Material/Muster</a>-Suche
    nach einer bestimmten Materialkonstellation suchen, ist es oftmals
    hilfreich, die Suche auf Partien zu beschr�nken, die mindestens f�r
    einige Halbz�ge auf das Suchmuster passen, um Partien auszusondern,
    wo die gesuchte Konstellation nur kurz vorkam.
  }
  {
    Wenn Sie eine wichtige Datenbank haben, die Sie nicht versehentlich
    ver�ndern wollen, w�hlen Sie <b>Schreibschutz...</b> im
    <b>Datei</b>-Men�, nachdem Sie sie ge�ffnet haben, oder �ndern Sie
    ihre Dateizugriffsrechte auf "nur Lesen".
  }
  {
    Wenn Sie XBoard oder WinBoard benutzen (oder ein anderes
    Schachprogramm, das Schachpositionen in FEN-Standardnotation in die
    Zwischenablage kopieren kann) und wollen dessen aktuelle
    Schachposition nach Scid kopieren, ist der schnellste und einfachste
    Weg, <b>Position sichern</b> im Dateimen� von XBoard/Winboard zu
    w�hlen, danach <b>Stellung einf�gen</b> in Scids Men� "Bearbeiten".
  }
  {
    Die <a Searches Header>Partiedaten-Suche</a> ignoriert bei
    Spieler/Turnier/Ort/Runden-Namen Gro�- und Kleinschreibung.  Sie
    k�nnen sie aber ber�cksichtigen und gleichzeitig
    Platzhalterzeichen verwenden (mit "?" = irgendein einzelnes
    Zeichen und "*" = null oder mehr Zeichen), wenn Sie den Suchtext
    in Anf�hrungszeichen ("...")  eingeben. Beispielsweise geben Sie
    "*BEL" (mit den Anf�hrungszeichen) im Ortsfeld ein, um alle in
    Belgien, nicht aber in Belgrad gespielten Partien zu finden.
  }
  {
    Wenn Sie einen Partiezug korrigieren wollen, ohne die danach
    gespielten Z�ge zu verlieren, �ffnen Sie das
    <a Import>Import</a>-Fenster, klicken auf <b>Aktuelle Partie
    einf�gen</b>, editieren den falschen Zug und w�hlen dann
    <b>Importieren</b>.
  }
  {
    Wenn Sie eine ECO-Klassifikationsdatei geladen haben, k�nnen Sie
    zur am weitest klassifizierten Position der aktuellen Partie mit
    <b>Er�ffnung identifizieren</b> im <b>Partie</b>-Men� gehen
    (Tastenkombination: Strg+Umsch+D).
  }
  {
    Wenn Sie vor dem �ffnen einer Datei ihre Gr��e oder das Datum ihrer
    letzten Modifikation �berpr�fen wollen, �ffnen Sie sie mit der
    <a Finder>Dateisuche</a>.
  }
  {
    Eine <a Repertoire>Repertoire</a>-Datei ist eine ausgezeichnete
    Methode, Ihre favorisierten Er�ffnungsvarianten im Auge zu behalten
    und die Partien zu finden, wo diese Varianten gespielt wurden.
    Wenn Sie erst einmal Ihre Er�ffnungen in einer Repertoire-Datei
    gespeichert haben, k�nnen Sie jedesmal, wenn Sie eine neue Datei
    mit Partien haben, eine Repertoire-Suche durchf�hren und die Partien
    mit Ihren favorisierten Er�ffnungen betrachten.
  }
  {
    Mit einem <a Reports Opening>Er�ffnungsbericht</a> kann man sehr gut
    mehr �ber eine bestimmte Position lernen. Sie k�nnen die Erfolgsrate
    sehen, ob sie zu vielen Kurzremis f�hrt und die typischen
    positionellen Themen.
  }
  {
    Sie k�nnen die gebr�uchlichsten Kommentarsymbole (!, !?, += etc.)
    dem aktuellen Zug oder der aktuellen Stellung mit Tastenkombinationen
    hinzuf�gen, ohne den Kommentareditor benutzen zu m�ssen -- um
    beispielsweise ein "!" hinzuzuf�gen, tippen Sie "!" und danach die
    Eingabetaste. Zu den Details siehe die Hilfeseite <a Moves>Z�ge
    eingeben</a>.
  }
  {
    Wenn Sie Er�ffnungen in einer Datenbank mit dem <a Tree>Zugbaum</a>
    betrachten, k�nnen Sie eine n�tzlichen �bersicht erhalten, welche
    Erfolge mit der aktuellen Er�ffnung in der letzten Zeit und zwischen
    Spitzenspielern erzielt wurden, indem Sie das Statistikfenster
    �ffnen (Tastenkombination: Strg-I).
  }
  {
    Sie k�nnen die Gr��e des Hauptfensters �ndern, indem Sie die
    <b>Strg</b>-Taste gedr�ckt halten und dann die Cursortaste
    <b>Links</b> oder <b>Rechts</b> dr�cken.
  }
  {
    Nach einer <a Searches>Suche</a> k�nnen Sie leicht durch alle
    passenden Partien bl�ttern, indem Sie die <b>Strg</b>-Taste gedr�ckt
    halten und dann die Cursortaste <b>Auf</b> oder <b>Ab</b> dr�cken,
    um die vorherige bzw. n�chste Partie im <a Searches Filter>Filter</a>
    zu laden.
  }
  {
    �ber die Tasten <b>F2</b> und <b>F3</b> k�nnen direkt die letzten beiden Analyse-Engines gestartet werden, ohne dies nochmal ausw�hlen zu m�ssen. 
  }
}

set helpTitle(D,Appearance) "SCID-Oberfl�che anpassen"
set helpText(D,Appearance) {<h1>Scid-Oberfl�che anpassen</h1>
  <p>
  Scid hat einige Optionen um die Oberfl�che anzupassen.
  </p>
  <h3><name Themes>TTK-Designs konfigurieren</name></h3>
  <p>
    Ab Version 4.7 k�nnen neue Oberfl�chen-Designs installiert und ausgew�hlt
    werden. Mit den TTK-Designs k�nnen verschiedene Erscheinungsbilder der
    SCID-Oberfl�che realisiert werden.<br>
    Im Scid-Repository steht ein mehrfarbiges Set von Designs zur direkten Nutzung zur Verf�gung:
    <li><url https://sourceforge.net/projects/scid/files/Scid/Additional Files/>https://sourceforge.net/projects/scid/files/Scid/Additional Files</url> -- Home / Scid / Additional Files</li><br><br>
    Weitere Designs k�nnen auch unter folgenden Adressen heruntergeladen werden:
    <li><url https://wiki.tcl.tk/48689>https://wiki.tcl.tk/48689</url> -- wiki.tcl.tk List of ttk Themes</li>
    <li><url https://github.com/RedFantom/ttkthemes/tree/master/ttkthemes/themes>https://github.com/RedFantom/ttkthemes</url>
    -- RedFantom Sammlung von ttk-Themen</li><br><br>
    Zur Installation der Designs gehen Sie wie folgt vor:<br>
    <li>Entpacken Sie die scidthemes-Dateien in ein beliebiges Verzeichnis.</li>
    <li>Designs laden: �ber den Men�punkt <b>Optionen - Design - Design(s) laden</b> w�hlen Sie die Datei pkgIndex.tcl aus dem Verzeichnis,
    in dem die Designs abgelegt sind.</li>
    <li>Design ausw�hlen: �ber den Men�punkt <b>Optionen - Design - "Designname"</b>, z.b. scidblue scidmint scidpurple scidpurple scidsand scidpink,
    w�hlen Sie das zu verwendendte Design aus.</li>
    <li><b>Hinweis:</b> pkgIndex.tcl sind Dateien, die zus�tzlichen tcl-Pakete nachladen. Verwenden Sie nur pkgIndex.tcl Dateien, die auch TTK-Designs enthalten.</li>
    </p>
  <h3><name MenuColors>Farben der Men�s einstellen</name></h3>
  <p>
    TTK-Designs besitzen technischbedingt keine angepassten Eigenschaften und
    Farben f�r Men�s. Die Farben f�r Men�s m�ssen daher gesondert angepasst
    und auf die Farben von Designs abgestimmt werden.<br>
    Unter <b>Optionen - Men�farben einstellen</b> k�nnen die Farben f�r das Men� konfiguriert werden:<br>
    <li>Hintergrundfarbe des Hauptmen�s</li>
    <li>Vorder- und Hintergrundfarbe aller Men�s</li>
    <li>Vorder- und Hintergrundfarbe des ausgew�hlten Men�eintrages</li>
    <li>Farbe einer ausgew�hlten Option im Men�</li>
    <li><b>Hinweis:</b> Unter WINDOWS und MACOS wird f�r die Hauptmen�leiste die
    Systemeinstellungen verwendet und die konfigurierten Farben ignoriert.</li>
  </p>
  <p>
  Nach dem Konfigurieren des Design und der Men�farben die Einstellungen mit <b>Optionen - Optionen speichern</b> speichern.
  </p>
  <p><footer>(Erstellt: Scid 4.7, August 2018)</footer></p>
}

set helpTitle(D,SeriousGame) "Ernste Partie"
set helpText(D,SeriousGame) {<h1>Ernste Partie</h1>
  <p>
  Ernste Spiele k�nnen gegen jede <term>UCI</term> Engine gespielt werden.
  Eine Liste aller m�glichen Gegner ist im Fenster <term>Spiel konfigurieren</term> angegeben. Die
  Schaltfl�che <term>UCI-Engine konfigurieren</term> bietet zus�tzlich Zugriff auf
  die Motorparameter. Standardm��ig wird die Einstellungen der <a Analyseliste>Analyseliste</a> verwendet.
  </p>
  <p>
  Es kann das Er�ffnungsbuch und die Er�ffnung ausgew�hlt werden.
  Das Kontrollk�stchen <term>Buch benutzen</term> de/aktiviert die Verwendung eines Er�ffnungsbuchs.
  </p>
  <p>
  Die Sektion <term>Zeitmodus</term> erlaubt die Einstellung der Zeit f�r Spieler und Engine.
  Hier sind verschiedene Einstellungen m�glich:
  <ul>
     <li><term>Zeit + Bonus</term> gibt die Zeit f�r das gesamte Spiel an und eine m�gliche
     Bonuszeit pro Zug (Fisher-Uhr). Die
     Standardeinstellung ist 5 Minuten pro Spiel und 10 Sekunden Inkrement pro Spiel.
     Beachten Sie, dass die
     Zeiten f�r Schwarz und Wei� unabh�ngig voneinander eingestellen k�nnen. Dies erm�glicht
     eine kurze Zeitspanne f�r den Motor einzustellen und eine l�ngere
     Zeit des Denkens f�r den Spieler.
     </li>
     <li><term>Feste Tiefe</term> setzt die Zeit pro Spiel nicht, sondern
     die Tiefe, die der Motor in halben Z�gen berechnet. Da dies der Engine
     die M�glichkeit nimmt, bei Bedarf tiefer zu rechnen, wird der
     Computer bestimmte Kombinationen nicht sehen, der Motor
     kann schw�cher spielen und somit einen besseren Trainingspartner bieten.
     </li><p>
     <b>Tipp</b>: Einige, Engines bieten auch an
     ihre St�rke in Elo-Einheiten einzustellen. Dies ist h�chstwahrscheinlich ein
     geeigneterer Algorithmus als die Begrenzung der Suchtiefe.
     </p>
     <li><term>Knoten</term> ist eine �hnlich Einschr�nkung der Suchtiefe,
     aber hier stoppt der Motor nach der Auswertung eines bestimmten
     Anzahl der Positionen seine Berechnungen. (Die Vorgabe ist 10.000.)
     </li>
     <li><term>Sekunden pro Zug</term> erlaubt dem Motor, eine
     maximale Zeit f�r die Berechnung eines Zuges. Einige
     Engines ziehen unter bestimmten Umst�nden schneller, aber sie werden
     das hier eingestellte Zeitlimit nicht �berschreiten. Wie <Term>Feste Tiefe</Term>Term
     und <term>Knoten</term> schr�nkt auch dies die Spielst�rke der Engine ein.
     </li>
  </ul>
  </p>
  <p>
  Ernste Partien k�nnen ab der aktuellen Brettposition beginnen, wenn die Box
  <term>Von aktueller Position starten</term> aktiviert ist. Dies erm�glicht
  z.B. zum Ausspielen von definierten Mittelspielpositionen, die sich aus einer
  Er�ffnung ergeben haben.
  </p>
  <p>
  <term>Berechnung im Hintergrund</term> (manchmal auch Ponder genannt)
  erlaubt es der Engine, w�hrend der Spieler am Zug ist zu Rechnen. Wenn das Spiel
  auf eine feste Zeit pro Zug eingestellt ist, schw�cht das den
  Motor.
  </p>
  <p>
  <term>Coach schaut zu</term> �ffnet ein Dialogangebot, um
  einen Zug zur�ck, wenn der Spieler einen Fehler gemacht hat (aufgrund der Motoren
  Auswertung seines letzten Zuges).
  </p>
  <p>
  <term>Bewertung hinzuf�gen</term> f�gt im Kommentar der Partie f�r jeden Zug der Engine
  die Stellungsbewertung der Engine hinzu.
  </p>
  <p>
  F�r das Training von Er�ffnungen kann die Option <term>Ausgew�hlte Er�ffnung</term>
  verwendet werden. In der Liste kann man die zu spielende Er�ffnung ausw�hlen. Der
  Spieler sollte dann der gew�hlten Er�ffnung folgen, ansonsten fragt Scid
  ob der Zug zur�ckgenommen werden soll.
  </p>
  <p>
  Nach der Einstellung aller Parameter des Spiels und dem Dr�cken des Knopfes Spielen wird die Partie gestartet.
  Beachten Sie, dass es einige Zeit dauern kann, bis die Schachengine startet und richtig initialisiert ist.
  </p>
  <p><footer>(Erstellt: Scid 4.7, August 2018)</footer></p>
}
### End of file: deutsch.tcl
