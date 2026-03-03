# Text for menu names and status bar help messages in Serbian Cyrillic.
# Part of Scid (Shane's Chess Information Database).
#
# Instructions for adding a new language:
#
# (1) Choose a letter code for the language. Currently assigned codes are:
#      E=English, D=Deutsch, F=Francais, S=Spanish, B=Brasil Portuguese,
#      P=Polish, N=Nederlands, W=Swedish, O=Norsk, C=Czech, H=Hungarian,
#      Y=Serbian, J=Serbian Cyrillic.
#
# (2) Edit the code below that has the lines "addLanguage ..." and add your
#     new language. The final digit in each line is the index of the
#     letter to underline in the menu, counting from 0 as the first letter.
#
# (3) Copy the section of English menu and help message details below (all
#     the commands that start "menuText E ..." or "helpMsg E ..." or
#     "translate E ...") and change all the "E" letters to the letter you
#     assigned for the new language.
#
# (4) Write the translations. This involves changing anything "in quotes"
#     or {in braces} for the menuText, helpMsg and translate commands.
#
#     A menu command has the format:
#         menuText L tag "Name..." underline {HelpMessage...}
#
#     A status bar help message for a button has the format:
#         helpMsg L tag {HelpMessage...}
#
#     A general word or message translation has the format:
#         translate L tag {message...}
#
#     where "L" is the language letter, "tag" is the name of the menu entry
#     or the button widget name, and "underline" is the index of the letter
#     to underline, counting from zero as the first letter. Two menu entries
#     that appear in the same menu should have a different underlined letter.
#     If in doubt, just make them all "0" and I'll assign sensible underlined
#     letters when your translations are incorporated into Scid.
#
# Additions, corrections? Email: sgh@users.sourceforge.net

proc setLanguage_L {} {

# File menu:
menuText L File "Fişier" 0
menuText L FileNew "Nou..." 0 {Creați o nouă bază de date Scid}
menuText L FileOpen "Deschide..." 0 {Deschideți o bază de date Scid existentă}
menuText L FileClose "Aproape" 0 {Închideți baza de date Scid activă}
menuText L FileFinder "Finder" 0 {Deschideți fereastra Căutare fișiere}
menuText L FileBookmarks "Marcaje" 0 {Meniul de marcaje}
menuText L FileBookmarksAdd "Adăugați marcaj" 0 \
  {Marcați jocul curent și poziția în baza de date}
menuText L FileBookmarksFile "Fișier marcaj" 0 \
  {Introduceți un marcaj pentru jocul și poziția curentă}
menuText L FileBookmarksEdit "Editați marcajele..." 0 \
  {Editați meniurile de marcaje}
menuText L FileBookmarksList "Afișează folderele ca o singură listă" 0 \
  {Afișați folderele cu marcaje ca o singură listă, nu submeniuri}
menuText L FileBookmarksSub "Afișează folderele ca submeniuri" 0 \
  {Afișează folderele cu marcaje ca submeniuri, nu o singură listă}
menuText L FileMaint "Întreţinere" 0 {Instrumente de întreținere a bazei de date Scid}
menuText L FileMaintWin "Fereastra de întreținere" 0 \
  {Deschideți/închideți fereastra de întreținere a bazei de date Scid}
menuText L FileMaintCompact "Baza de date compacta..." 0 \
  {Compactarea fișierelor bazei de date, eliminând jocurile șterse și numele neutilizate}
menuText L FileMaintClass "Jocuri ECO-Clasificare..." 2 \
  {Recalculați codul ECO al tuturor jocurilor}
menuText L FileMaintSort "Sortați baza de date..." 0 \
  {Sortați toate jocurile din baza de date}
menuText L FileMaintDelete "Șterge jocurile gemene..." 0 \
  {Găsiți jocuri gemene și setați-le să fie șterse}
menuText L FileMaintTwin "Fereastra Twin Checker" 0 \
  {Deschide/actualizează fereastra Twin Checker}
menuText L FileMaintName "Ortografia numelui" 0 {Instrumente de editare a numelor și ortografie}
menuText L FileMaintNameEditor "Editor de nume" 0 \
  {Deschide/închide fereastra editorului de nume}
menuText L FileMaintNamePlayer "Verificați ortografic numele jucătorilor..." 11 \
  {Verificați numele jucătorilor folosind fișierul de verificare ortografică}
menuText L FileMaintNameEvent "Verificați ortografic numele evenimentelor..." 11 \
  {Verificați numele evenimentelor folosind fișierul de verificare ortografică}
menuText L FileMaintNameSite "Verificați ortografic numele site-urilor..." 11 \
  {Verificați numele site-urilor folosind fișierul de verificare ortografică}
menuText L FileMaintNameRound "Nume runde de verificare ortografică..." 11 \
  {Verificați ortografic numele rotunde folosind fișierul de verificare ortografică}
menuText L FileReadOnly "Numai citire..." 0 \
  {Tratați baza de date curentă ca fiind doar în citire, prevenind modificările}
menuText L FileSwitch "Comutați la baza de date" 0 \
  {Comutați la o altă bază de date deschisă}
menuText L FileOpenLichessTournament "Turneu deschis Lichess" 0 {Descărcați și deschideți jocurile live ale turneului Lichess}
menuText L FileImportLichess "Importă-mi Lichess" 0 {Importă jocuri din contul tău Lichess}
menuText L FileImportChessCom "Importă-mi chess.com" 0 {Importă jocuri din contul tău chess.com}
menuText L FileExit "Ieșire" 1 {Ieși din Scid}
menuText L FileMaintFixBase "Baza de reparatii" 0 {Încercați să reparați o bază coruptă}

# Edit menu:
menuText L Edit "Edita" 0
menuText L EditAdd "Adăugați o variație" 0 {Adăugați o variație la această mișcare în joc}
menuText L EditDelete "Ștergeți varianta" 0 {Ștergeți o variantă pentru această mutare}
menuText L EditFirst "Faceți prima variație" 5 \
  {Promovați o variantă pentru a fi primul în listă}
menuText L EditMain "Promovați variația la linia principală" 21 \
  {Promovați o variație pentru a fi linia principală}
menuText L EditTrial "Încercați Variation" 0 \
  {Pornire/oprire modul de încercare, pentru testarea unei idei pe tablă}
menuText L EditStrip "Bandă" 3 {Eliminați comentariile sau variațiile din acest joc}
menuText L EditUndo "Anula" 0 {Anulați ultima modificare a jocului}
menuText L EditRedo "Reface" 0 {Reface ultima schimbare de joc}
menuText L EditStripComments "Comentarii" 0 \
  {Eliminați toate comentariile și adnotările din acest joc}
menuText L EditStripVars "Variante" 0 {Eliminați toate variantele din acest joc}
menuText L EditStripBegin "Se mișcă de la început" 1 \
  {Strip se mișcă de la începutul jocului}
menuText L EditStripEnd "Se mută până la capăt" 0 \
  {Strip se mută până la sfârșitul jocului}
menuText L EditReset "Clipbase gol" 0 \
  {Resetați baza de clip pentru a fi complet goală}
menuText L EditCopy "Copiați acest joc în Clipbase" 0 \
  {Copiați acest joc în baza de date Clipbase}
menuText L EditPaste "Paste Last Clipbase Game" 0 \
  {Lipiți aici jocul Clipbase activ}
menuText L EditPastePGN "Lipiți textul Clipboard ca joc PGN..." 18 \
  {Interpretați textul clipboard-ului ca un joc în notație PGN și inserați-l aici}
menuText L EditSetup "Configurați placa de pornire..." 0 \
  {Setați poziția de început pentru acest joc}
menuText L EditCopyBoard "Copiați poziția" 6 \
  {Copiați tabloul curent în notație FEN în selecția de text (clipboard)}
menuText L EditPasteBoard "Lipiți tabla de pornire" 12 \
  {Setați panoul de pornire din selecția curentă de text (clipboard)}
menuText L ConfigureScid "Preferințe..." 0 {Configurați toate opțiunile pentru SCID}

# Game menu:
menuText L Game "Joc" 0
menuText L GameNew "Joc nou" 0 {Resetați la un joc gol}
menuText L GameFirst "Încărcați primul joc" 5 {Încărcați primul joc filtrat}
menuText L GamePrev "Încărcați jocul anterior" 5 {Încărcați jocul filtrat anterior}
menuText L GameReload "Reîncărcați jocul curent" 3 \
  {Reîncărcați acest joc, eliminând orice modificări făcute}
menuText L GameNext "Încărcați următorul joc" 7 {Încărcați următorul joc filtrat}
menuText L GameLast "Încărcați ultimul joc" 8 {Încărcați ultimul joc filtrat}
menuText L GameRandom "Încărcați joc aleatoriu" 8 {Încărcați un joc filtrat aleatoriu}
menuText L GameNumber "Încărcați numărul jocului..." 5 \
  {Încărcați un joc introducând numărul acestuia}
menuText L GameReplace "Salvare: înlocuiți jocul..." 6 \
  {Salvați acest joc, înlocuind versiunea veche}
menuText L GameAdd "Salvare: Adăugați un joc nou..." 6 \
  {Salvați acest joc ca joc nou în baza de date}
menuText L GameDeepest "Identificați deschiderea" 0 \
  {Mergeți la cea mai profundă poziție de joc listată în cartea ECO}
menuText L GameGotoMove "Du-te la Mută ​​numărul..." 5 \
  {Accesați un număr de mutare specificat în jocul curent}
menuText L GameNovelty "Găsiți noutăți..." 7 \
  {Găsiți prima mișcare a acestui joc care nu a mai jucat înainte}

# Search Menu:
menuText L Search "Căutare" 0
menuText L SearchReset "Resetați filtrul" 0 {Resetați filtrul astfel încât toate jocurile să fie incluse}
menuText L SearchNegate "Negați filtrul" 0 {Anulați filtrul pentru a include numai jocurile excluse}
menuText L SearchCurrent "Consiliul actual..." 0 {Căutați poziția curentă a consiliului}
menuText L SearchHeader "Antet..." 0 {Căutați informații după antet (jucător, eveniment etc.).}
menuText L SearchMaterial "Material/Model..." 0 {Căutați materiale sau modele de tablă}
menuText L SearchUsing "Se utilizează fișierul de căutare..." 0 {Căutați folosind un fișier SearchOptions}

# Windows menu:
menuText L Windows "Windows" 0
menuText L WindowsComment "Editor de comentarii" 0 {Deschide/închide editorul de comentarii}
menuText L WindowsGList "Lista de jocuri" 0 {Deschide/închide fereastra cu lista de jocuri}
menuText L WindowsPGN "Fereastra PGN" 0 \
  {Deschide/închide fereastra PGN (notație de joc).}
menuText L WindowsPList "Căutare de jucători" 2 {Deschideți/închideți instrumentul de căutare de jucători}
menuText L WindowsTmt "Găsitor de turnee" 2 {Deschide/închide instrumentul de căutare a turneelor}
menuText L WindowsSwitcher "Comutator baze de date" 0 \
  {Deschideți/închideți fereastra de comutare baze de date}
menuText L WindowsMaint "Fereastra de întreținere" 0 \
  {Deschide/închide fereastra de întreținere}
menuText L WindowsECO "Browser ECO" 0 {Deschide/închide fereastra ECO Browser}
menuText L WindowsStats "Fereastra de statistici" 0 \
  {Deschide/închide fereastra cu statistici ale filtrului}
menuText L WindowsTree "Fereastra copacului" 0 {Deschide/închide fereastra Tree}
menuText L WindowsBook "Fereastra de carte" 0 {Deschide/închide fereastra Carte}
menuText L WindowsCorrChess "Fereastra de corespondență" 0 {Deschide/închide fereastra de corespondență}
menuText L WindowsGraph "Graficul de analiză" 0 {Deschideți fereastra Grafic cu timpii și evaluările mișcărilor}

# Tools menu:
menuText L Tools "Instrumente" 0
menuText L ToolsConfigureEngines "Configurați motoarele" 10 {Gestionați configurația motoarelor}
menuText L ToolsAnalysis "Motor de analiză..." 0 \
  {Porniți/opriți un motor de analiză a șahului}
menuText L ToolsAnalysis2 "Motorul de analiză #2..." 17 \
  {Porniți/opriți al 2-lea motor de analiză a șahului}
menuText L ToolsCross "Tabel încrucișat" 0 {Arată tabelul încrucișat al turneului pentru acest joc}
menuText L ToolsFilterGraph "rel. Filtru grafic" 12 {Deschideți/închideți fereastra graficului de filtrare pentru valori relative}
menuText L ToolsAbsFilterGraph "Abs. Filtru grafic" 7 {Deschideți/închideți fereastra graficului de filtrare pentru valori absolute}
menuText L ToolsOpReport "Raport de deschidere" 0 {Generați un raport de deschidere pentru poziția curentă}
menuText L ToolsOpenBaseAsTree "Baza deschisă ca un copac..." 0   {Deschideți o bază și utilizați-o în fereastra Tree}
menuText L ToolsOpenRecentBaseAsTree "Deschide baza recentă ca arbore" 0   {Deschideți o bază recentă și utilizați-o în fereastra Tree}
menuText L ToolsTracker "Piece Tracker"  6 {Deschideți fereastra Piece Tracker}
menuText L ToolsTraining "Antrenamentul"  0 {Instrumente de antrenament (tactici, deschideri,...)}
menuText L ToolsTacticalGame "Joc tactic"  0 {Joacă un joc cu tactică}
menuText L ToolsSeriousGame "Joc serios"  0 {Joacă un joc serios}
menuText L ToolsTrainOpenings "Deschideri"  0 {Antrenează-te cu un repertoriu}
menuText L ToolsTrainReviewGame "Joc de recenzie"  0 {Ghiciți mișcările jucate într-un joc}
menuText L ToolsTrainTactics "Tactici"  0 {Rezolvați tactici}
menuText L ToolsTrainCalvar "Calculul variațiilor"  0 {Calculul variațiilor antrenamentului}
menuText L ToolsTrainFindBestMove "Găsiți cea mai bună mișcare"  0 {Găsiți cea mai bună mișcare}
menuText L ToolsTrainFics "Joacă pe FICS"  0 {Joacă pe freechess.org}
menuText L ToolsEngineTournament "Turneu de motoare"  0 {Începeți un turneu între motoarele de șah}
menuText L ToolsBookTuning "Tuning de carte" 0 {Tuning de carte}
menuText L ToolsDownloadTWIC "Descărcați jocurile TWIC" 0 {Descărcați cele mai recente jocuri The Week In Chess (TWIC).}
menuText L ToolsConnectHardware "Conectați Hardware" 8 {Conectați hardware extern}
menuText L ToolsConnectHardwareConfigure "Configurați..." 0 {Configurați hardware-ul extern și conexiunea}
menuText L ToolsConnectHardwareNovagCitrineConnect "Conectați Novag Citrine" 8 {Conectați Novag Citrine cu Scid}
menuText L ToolsConnectHardwareInputEngineConnect "Conectați motorul de intrare" 8 {Conectați motorul de intrare (de exemplu, placa DGT) cu Scid}

menuText L ToolsPInfo "Informații despre jucător"  0 \
  {Deschide/actualizează fereastra Informații despre jucător}
menuText L ToolsPlayerReport "Raportul jucătorului..." 3 \
  {Generați un raport de jucător}
menuText L ToolsRating "Graficul de evaluare" 0 \
  {Reprezentați grafic istoricul de rating al jucătorilor actuali}
menuText L ToolsExpCurrent "Exportați jocul curent" 8 \
  {Scrieți jocul curent într-un fișier text}
menuText L ToolsExpCurrentPGN "Exportați jocul în fișierul PGN..." 15 \
  {Scrieți jocul curent într-un fișier PGN}
menuText L ToolsExpCurrentHTML "Exportați jocul în fișierul HTML..." 15 \
  {Scrieți jocul curent într-un fișier HTML}
menuText L ToolsExpCurrentHTMLJS "Exportați jocul în fișierul HTML și JavaScript..." 15 {Scrieți jocul curent într-un fișier HTML și JavaScript}
menuText L ToolsExpFilter "Exportați toate jocurile de filtrare" 1 \
  {Scrieți toate jocurile filtrate într-un fișier text}
menuText L ToolsExpFilterPGN "Exportați filtrul în fișierul PGN..." 17 \
  {Scrieți toate jocurile filtrate într-un fișier PGN}
menuText L ToolsExpFilterHTML "Exportați filtrul în fișierul HTML..." 17 \
  {Scrieți toate jocurile filtrate într-un fișier HTML}
menuText L ToolsExpFilterHTMLJS "Exportați filtrul în fișierul HTML și JavaScript..." 17 {Scrieți toate jocurile filtrate într-un fișier HTML și JavaScript}
menuText L ToolsImportOne "Importă un joc PGN..." 0 \
  {Importați un joc din text PGN}
menuText L ToolsImportFile "Importați jocuri din fișiere PGN..." 7 {Importați jocuri din fișiere PGN}
menuText L ToolsStartEngine1 "Porniți motorul 1" 13  {Porniți motorul 1}
menuText L ToolsStartEngine2 "Porniți motorul 2" 13  {Porniți motorul 2}
menuText L ToolsCaptureBoard "Capturați tabloul curent..." 5  {Salvați tabloul curent ca imagine.}

# Play menu
menuText L Play "Juca" 0

# --- Correspondence Chess
menuText L CCResign "Demisiona" 1 {Demisia (nu prin e-mail)}
menuText L CCClaimDraw "Reclama Retrage" 6 {Trimiteți mutarea și revendicați o remiză (nu prin e-mail)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText L Options "Opțiuni" 0
menuText L OptionsBoardGraphics "Patratele..." 0 {Selectați texturi pentru pătrate}
translate L OptionsBGW {Selectați textura pentru pătrate}
translate L OptionsBoardGraphicsText {Selectați fișierele grafice pentru pătratele albe și negre:}
menuText L OptionsBoardNames "Numele meu de jucător..." 0 {Editează-mi numele jucătorilor}
menuText L OptionsExport "Exportator" 0 {Modificați opțiunile de export de text}
menuText L OptionsFonts "Fonturi" 0 {Schimbați fonturile}
menuText L OptionsFontsRegular "Regulat" 0 {Schimbați fontul obișnuit}
menuText L OptionsFontsMenu "Meniu" 0 {Schimbați fontul meniului}
menuText L OptionsFontsSmall "Mic" 0 {Schimbați fontul mic}
menuText L OptionsFontsTiny "Micut" 0 {Schimbați fontul mic}
menuText L OptionsFontsFixed "Fix" 0 {Schimbați fontul cu lățime fixă}
menuText L OptionsGInfo "Informații despre joc" 0 {Opțiuni de informații despre joc}
menuText L OptionsLanguage "Limbă" 0 {Selectați limba meniului}
menuText L OptionsMovesTranslatePieces "Traduceți piese" 0 {Traduceți prima literă de bucăți}
menuText L OptionsMovesHighlightLastMove "Evidențiați ultima mișcare" 0 {Evidențiați ultima mișcare}
menuText L OptionsMovesHighlightLastMoveDisplay "Afișează Square" 0 {Afișează ultima mișcare Evidențiați}
menuText L OptionsMovesHighlightLastMoveWidth "Lăţime" 0 {Grosimea liniei}
menuText L OptionsMovesHighlightLastMoveColor "Culoare" 0 {Culoarea liniei}
menuText L OptionsMovesHighlightLastMoveArrow "Arată săgeata" 0 {Afișați o săgeată cu Evidențiere}
menuText L OptionsMovesHighlightLastMoveNag "Afișați simbolurile de evaluare" 0
menuText L OptionsMoves "Mișcări" 0 {Mutați opțiunile de intrare}
menuText L OptionsMovesAnimate "Timp de animație" 1 \
  {Setați durata de timp folosită pentru a anima mișcările}
menuText L OptionsMovesDelay "Întârziere redare automată..." 1 \
  {Setați întârzierea pentru modul de redare automată}
menuText L OptionsMovesCoord "Coordonate Mutare Intrare" 0 \
  {Acceptați intrarea de mutare în stilul de coordonate (de exemplu, „g1f3”)}
menuText L OptionsMovesSuggest "Afișați mișcările sugerate" 0 \
  {Activați/dezactivați sugestia de mutare}
menuText L OptionsShowVarPopup "Afișați fereastra de variante" 0 {Activați/dezactivați afișarea unei ferestre de variații}
menuText L OptionsMovesSpace "Adăugați spații după numărul de mutare" 0 {Adăugați spații după numărul de mutare}
menuText L OptionsMovesLichess "Format Lichess/ChessBase pentru adnotări" 0 {Utilizați formatul Lichess/ChessBase pentru marcajele pătrate și săgețile}
menuText L OptionsMovesKey "Finalizarea tastaturii" 0 \
  {Activați/dezactivați completarea automată a mutațiilor de la tastatură}
menuText L OptionsMovesShowVarArrows "Afișați săgețile pentru variații" 0 {Activați/dezactivați săgețile care arată mișcările în variații}
menuText L OptionsMovesShowEngineVariationArrows "Afișați săgețile pentru variațiile de motor" 0 {Porniți/opriți săgețile care arată liniile de variație ale motorului în modul multiPV}
menuText L OptionsMovesGlossOfDanger "Luciu de pericol cu ​​coduri de culoare" 0 {Activați/dezactivați luciul de pericol cu ​​coduri de culoare}
translate L OptionsMovesTreeDepth {Adâncimea de mutare a ferestrei arborelui implicit}
menuText L OptionsNumbers "Format de număr" 0 {Selectați formatul numărului}
menuText L OptionsTheme "Temă" 0 {Schimbați aspectul interfeței}
menuText L OptionsWindows "Windows" 0 {Opțiuni de fereastră}
menuText L OptionsSounds "Sunete" 2 {Configurați sunetele anunțului de mutare}
menuText L OptionsResources "Resurse..." 0 {Alegeți fișierele de resurse și folderele}
menuText L OptionsWindowsDock "Ferestre de andocare" 0 {Ferestre de andocare (trebuie repornită)}
menuText L OptionsWindowsSaveLayout "Salvați aspectul" 0 {Salvați aspectul}
menuText L OptionsWindowsRestoreLayout "Restaurați aspectul" 0 {Restaurați aspectul}
menuText L OptionsWindowsShowGameInfo "Afișează informații despre joc" 0 {Afișează informații despre joc}
menuText L OptionsWindowsAutoLoadLayout "Încărcați automat primul aspect" 0 {Încărcați automat primul aspect la pornire}
menuText L OptionsECO "Fișier ECO" 7 {Încărcați fișierul de clasificare ECO}
menuText L OptionsSpell "Fișier de verificare ortografică" 11 \
  {Încărcați fișierul de verificare ortografică Scid}
menuText L OptionsTable "Director de bază de tabele" 10 \
  {Selectați un fișier de bază de tabele; vor fi folosite toate bazele de tabele din directorul său}
menuText L OptionsRecent "Fișiere recente" 0 {Modificați numărul de fișiere recente afișate în meniul Fișier}
menuText L OptionsBooksDir "Directorul cărților" 0 {Setează directorul cărților de deschidere}
menuText L OptionsTacticsBasesDir "Directorul bazelor" 0 {Setează directorul bazelor de tactici (antrenament).}
menuText L OptionsPhotosDir "Director de fotografii" 0 {Setează directorul bazelor de fotografii}
menuText L OptionsThemeDir "Fișierul temei(e)."  0 {Încărcați un fișier de pachet temă GUI}
menuText L OptionsSave "Opțiuni de salvare" 0 "Save all settable options to the file $::optionsFile"
menuText L OptionsAutoSave "Opțiuni de salvare automată la ieșire" 0 \
  {Salvați automat toate opțiunile când ieșiți din Scid}

# Help menu:
menuText L Help "Ajutor" 0
menuText L HelpContents "Cuprins" 0 {Afișați pagina de conținut de ajutor}
menuText L HelpIndex "Index" 0 {Afișați pagina de index de ajutor}
menuText L HelpGuide "Ghid rapid" 0 {Afișați pagina de ajutor pentru ghidul rapid}
menuText L HelpHints "Sugestii" 0 {Afișați pagina de ajutor cu sugestii}
menuText L HelpContact "Informații de contact" 1 {Afișați pagina de ajutor cu informații de contact}
menuText L HelpTip "Sfatul zilei" 0 {Afișați un sfat util Scid}
menuText L HelpStartup "Fereastra de pornire" 0 {Afișați fereastra de pornire}
menuText L HelpAbout "Despre" 0 {Informații despre ScidCommunity}

# Game info box popup menu:
menuText L GInfoHideNext "Ascunde următoarea mișcare" 0
menuText L GInfoMaterial "Afișați valorile materiale" 0
menuText L GInfoFEN "Arată FEN" 5
menuText L GInfoMarks "Afișați pătrate și săgeți colorate" 5
menuText L GInfoWrap "Înfășurați linii lungi" 0
menuText L GInfoFullComment "Afișează comentariul complet" 10
menuText L GInfoPhotos "Afișați fotografii" 5
menuText L GInfoTBNothing "Baze de tabel: Nimic" 12
menuText L GInfoTBResult "Baze de tabele: numai rezultate" 12
menuText L GInfoTBAll "Baze de tabele: rezultat și cele mai bune mișcări" 19
menuText L GInfoDelete "(Anulați) ștergeți acest joc" 4
menuText L GInfoMark "(Anulați) marcați acest joc" 4
menuText L GInfoInformant "Configurați valorile informatorilor" 0

# General buttons:
translate L Back {Spate}
translate L Browse {Răsfoiește}
translate L Cancel {Anula}
translate L Continue {Continua}
translate L Clear {Clar}
translate L Close {Aproape}
translate L Contents {Cuprins}
translate L Defaults {Valori implicite}
translate L Delete {Şterge}
translate L Graph {Grafic}
translate L Help {Ajutor}
translate L Hide {Ascunde}
translate L Import {Import}
translate L Index {Index}
translate L LoadGame {Încărcați jocul}
translate L BrowseGame {Răsfoiește jocul}
translate L MergeGame {Merge Game}
translate L MergeGames {Jocuri de îmbinare}
translate L Preview {Previzualizare}
translate L Revert {Reveni}
translate L Save {Salva}
translate L Search {Căutare}
translate L Stop {Stop}
translate L Store {Magazin}
translate L Update {Actualizare}
translate L ChangeOrient {Schimbați orientarea ferestrei}
translate L ShowIcons {Afișați pictograme}
translate L None {Nici unul}
translate L First {Primul}
translate L Current {Actual}
translate L Last {Dura}

# General messages:
translate L game {joc}
translate L games {jocuri}
translate L move {mişcare}
translate L moves {miscari}
translate L all {toate}
translate L Yes {Da}
translate L No {Nu}
translate L Both {ambele}
translate L King {Rege}
translate L Queen {Regină}
translate L Rook {Rook}
translate L Bishop {Episcop}
translate L Knight {Cavaler}
translate L Pawn {Pion}
translate L White {Alb}
translate L Black {Negru}
translate L Player {Player}
translate L Rating {Evaluare}
translate L RatingDiff {Diferența de evaluare (alb - negru)}
translate L AverageRating {Evaluare medie}
translate L Event {Eveniment}
translate L Site {Site}
translate L Country {Ţară}
translate L IgnoreColors {Ignora culorile}
translate L Date {Data}
translate L EventDate {Data evenimentului}
translate L Decade {Deceniu}
translate L Year {An}
translate L Month {Lună}
translate L Months {ianuarie februarie martie aprilie mai iunie iulie august septembrie octombrie noiembrie decembrie}
translate L Days {Dumi Luni Mar Mier Joi Vin Sam}
translate L YearToToday {-1Y}
translate L YearToTodayTooltip {Setați data de la 1 an până astăzi}
translate L Result {Rezultat}
translate L Round {Rundă}
translate L Length {Lungime}
translate L ECOCode {Cod ECO}
translate L ECO {ECO}
translate L Deleted {Șters}
translate L SearchResults {Rezultatele căutării}
translate L OpeningTheDatabase {Deschiderea bazei de date}
translate L Database {Baza de date}
translate L Filter {Filtra}
translate L noGames {fara jocuri}
translate L allGames {toate jocurile}
translate L empty {gol}
translate L clipbase {clipbase}
translate L score {Scor}
translate L StartPos {Poziția de pornire}
translate L Total {Total}
translate L readonly {numai pentru citire}

# Standard error messages:
translate L ErrNotOpen {Aceasta nu este o bază de date deschisă.}
translate L ErrReadOnly {Această bază de date este doar pentru citire; nu poate fi alterat.}
translate L ErrSearchInterrupted {Căutarea a fost întreruptă; rezultatele sunt incomplete.}

# Game information:
translate L twin {geamăn}
translate L deleted {șters}
translate L comment {comentariu}
translate L hidden {ascuns}
translate L LastMove {Ultima mutare}
translate L NextMove {Următorul}
translate L GameStart {Începutul jocului}
translate L LineStart {Începutul liniei}
translate L GameEnd {Sfârșitul jocului}
translate L LineEnd {Sfârșitul liniei}

# Player information:
translate L PInfoAll {Rezultate pentru <b>toate</b> jocurile}
translate L PInfoFilter {Rezultate pentru jocurile <b>filtrează</b>}
translate L PInfoAgainst {Rezultate contra}
translate L PInfoMostWhite {Cele mai comune deschideri ca Alb}
translate L PInfoMostBlack {Cele mai comune deschideri ca negru}
translate L PInfoRating {Istoricul evaluărilor}
translate L PInfoBio {Biografie}
translate L PInfoEditRatings {Editați evaluările}
translate L PInfoEloFile {Fişier}

# Tablebase information:
translate L Draw {Remiză}
translate L with {cu}
translate L only {numai}
translate L lose {pierde}
translate L loses {pierde}

# Tip of the day:
translate L Tip {Sfat}
translate L TipAtStartup {Sfat la pornire}
translate L TipConvertPGN {Puteți obține performanțe mai bune prin conversia fișierelor PGN}

# Tree window menus:
menuText L TreeFile "Fişier" 0
menuText L TreeFileFillWithBase "Umpleți memoria cache cu bază" 0 {Completați fișierul cache cu toate jocurile din baza curentă}
menuText L TreeFileFillWithGame "Umpleți memoria cache cu jocul" 0 {Completați fișierul cache cu jocul curent în baza curentă}
menuText L TreeFileSetCacheSize "Dimensiunea memoriei cache" 0 {Setați dimensiunea cache-ului}
menuText L TreeFileCacheInfo "Informații din cache" 0 {Obțineți informații despre utilizarea memoriei cache}
menuText L TreeFileSave "Salvați fișierul cache" 0 {Salvați fișierul cache arbore (.stc).}
menuText L TreeFileFill "Umpleți fișierul cache" 0 \
  {Umpleți fișierul cache cu poziții de deschidere comune}
menuText L TreeFileBest "Lista celor mai bune jocuri" 0 {Afișați cea mai bună listă de jocuri cu copaci}
menuText L TreeFileGraph "Fereastra grafic" 0 {Arată graficul pentru această ramură de copac}
menuText L TreeFileCopy "Copiați textul arborelui în Clipboard" 1 \
  {Copiați statisticile arborelui în clipboard}
menuText L TreeFileClose "Închideți fereastra arborelui" 0 {Închide fereastra copacului}
menuText L TreeMask "Masca" 0
menuText L TreeMaskNew "Nou" 0 {Mască nouă}
menuText L TreeMaskOpen "Deschide" 0 {Deschide masca}
menuText L TreeMaskOpenRecent "Deschide recent" 0 {Deschide masca recenta}
menuText L TreeMaskSave "Salva" 0 {Salvați masca}
menuText L TreeMaskClose "Aproape" 0 {Închideți masca}
menuText L TreeMaskFillWithGame "Umpleți cu joc" 0 {Umpleți masca cu joc}
menuText L TreeMaskFillWithBase "Umpleți cu bază" 0 {Umpleți masca cu toate jocurile din bază}
menuText L TreeMaskInfo "Info" 0 {Afișați statisticile pentru masca curentă}
menuText L TreeMaskDisplay "Afișează harta măști" 0 {Afișați datele masca într-o formă de arbore}
menuText L TreeMaskSearch "Căutare" 0 {Căutați în masca curentă}
menuText L TreeSort "Sorta" 0
menuText L TreeSortAlpha "Alfabetic" 0
menuText L TreeSortECO "Cod ECO" 0
menuText L TreeSortFreq "Frecvenţă" 0
menuText L TreeSortScore "Scor" 0
menuText L TreeOpt "Opțiuni" 0
menuText L TreeOptSlowmode "modul lent" 0 {Mod lent pentru actualizări (precizie ridicată)}
menuText L TreeOptFastmode "Mod rapid" 0 {Mod rapid pentru actualizări (fără transpunere de mișcare)}
menuText L TreeOptFastAndSlowmode "Mod rapid și lent" 0 {Modul rapid apoi modul lent pentru actualizări}
menuText L TreeOptStartStop "Reîmprospătare automată" 0 {Comută reîmprospătarea automată a ferestrei arborelui}
menuText L TreeOptLock "Blocare" 0 {Blocați/deblocați arborele în baza de date curentă}
menuText L TreeOptTraining "Antrenamentul" 0 {Activați/dezactivați modul de antrenament arbore}
menuText L TreeOptDepth "Mutați adâncimea" 0 {Numărul de jumătăți de mișcări de afișat în arbore (1-4)}
menuText L TreeOptAutosave "Salvare automată a fișierului cache" 0 \
  {Salvați automat fișierul cache când închideți fereastra arborelui}
menuText L TreeHelp "Ajutor" 0
menuText L TreeHelpTree "Tree Help" 0
menuText L TreeHelpIndex "Index de ajutor" 0
translate L SaveCache {Salvați cache}
translate L Training {Antrenamentul}
translate L LockTree {Blocare}
translate L TreeDepth {Adâncimea copacului (jumătate de mișcări):}
translate L TreeLocked {încuiat}
translate L TreeBest {Cel mai bun}
translate L TreeBestGames {Cele mai bune jocuri cu copaci}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate L TreeTitleRow \
{Mutare Scor de frecvență      ECO AvElo Perf AvYear % Draws      %Câştiga}
translate L TreeTotal {TOTAL}
translate L DoYouWantToSaveFirst {Doriți să salvați mai întâi}
translate L AddToMask {Adaugă la mască}
translate L RemoveFromMask {Scoateți din mască}
translate L AddThisMoveToMask {Adăugați această mișcare la Mask}
translate L SearchMask {Caută în mască}
translate L DisplayMask {Masca de afișare}
translate L Nag {Cod nag}
translate L Marker {Marker}
translate L Include {Include}
translate L Exclude {Exclude}
translate L MainLine {Linia principală}
translate L Bookmark {Marcaj}
translate L NewLine {Linie nouă}
translate L ToBeVerified {De verificat}
translate L ToTrain {Să se antreneze}
translate L Dubious {Dubios}
translate L ToRemove {Pentru a elimina}
translate L NoMarker {Fără marker}
translate L ColorMarker {Culoare}
translate L WhiteMark {Alb}
translate L GreenMark {Verde}
translate L YellowMark {Galben}
translate L BlueMark {Albastru}
translate L RedMark {Roşu}
translate L CommentMove {Comentează mutarea}
translate L CommentPosition {Poziția comentariului}
translate L AddMoveToMaskFirst {Adăugați mai întâi mișcare la mască}
translate L OpenAMaskFileFirst {Deschideți mai întâi un fișier de mască}
translate L Positions {Poziții}
translate L Moves {Mișcări}

# Finder window:
menuText L FinderFile "Fişier" 0
menuText L FinderFileSubdirs "Căutați în subdirectoare" 0
menuText L FinderFileClose "Închideți File Finder" 0
menuText L FinderSort "Sorta" 0
menuText L FinderSortType "Tip" 0
menuText L FinderSortSize "Dimensiune" 0
menuText L FinderSortMod "Modificat" 0
menuText L FinderSortName "Nume" 0
menuText L FinderSortPath "Cale" 0
menuText L FinderTypes "Tipuri" 0
menuText L FinderTypesScid "Baze de date Scid" 0
menuText L FinderTypesOld "Baze de date Scid în format vechi" 0
menuText L FinderTypesPGN "Fișiere PGN" 0
menuText L FinderTypesEPD "Fișiere EPD" 0
menuText L FinderTypesRep "Fișiere de repertoriu" 0
menuText L FinderHelp "Ajutor" 0
menuText L FinderHelpFinder "Ajutor pentru căutarea fișierelor" 0
menuText L FinderHelpIndex "Index de ajutor" 0
translate L FileFinder {Căutare de fișiere}
translate L FinderDir {Director}
translate L FinderDirs {Directoare}
translate L FinderFiles {Fișiere}
translate L FinderUpDir {Sus}
translate L FinderCtxOpen {Deschide}
translate L FinderCtxBackup {Backup}
translate L FinderCtxCopy {Copie}
translate L FinderCtxMove {Mişcare}
translate L FinderCtxDelete {Şterge}

# Player finder:
menuText L PListFile "Fişier" 0
menuText L PListFileUpdate "Actualizare" 0
menuText L PListFileClose "Închideți Player Finder" 0
menuText L PListSort "Sorta" 0
menuText L PListSortName "Nume" 0
menuText L PListSortElo "Elo" 0
menuText L PListSortGames "Jocuri" 0
menuText L PListSortOldest "Cel mai vechi" 0
menuText L PListSortNewest "Cel mai nou" 2

# Tournament finder:
menuText L TmtFile "Fişier" 0
menuText L TmtFileUpdate "Actualizare" 0
menuText L TmtFileClose "Închideți Găsitorul de turnee" 0
menuText L TmtSort "Sorta" 0
menuText L TmtSortDate "Data" 0
menuText L TmtSortPlayers "Jucători" 0
menuText L TmtSortGames "Jocuri" 0
menuText L TmtSortElo "Elo" 0
menuText L TmtSortSite "Site" 0
menuText L TmtSortEvent "Eveniment" 1
menuText L TmtSortWinner "Câştigător" 0
translate L TmtLimit "Limită listă"
translate L TmtMeanElo "Elo rău"
translate L TmtNone "Nu au fost găsite turnee potrivite."

# Graph windows:
menuText L GraphFile "Fişier" 0
menuText L GraphFileColor "Salvați ca Color PostScript..." 8
menuText L GraphFileGrey "Salvați ca PostScript în tonuri de gri..." 8
menuText L GraphFileClose "Închide fereastra" 6
menuText L GraphOptions "Opțiuni" 0
menuText L GraphOptionsWhite "Alb" 0
menuText L GraphOptionsBlack "Negru" 0
menuText L GraphOptionsBoth "ambele" 1
menuText L GraphOptionsPInfo "Player Info player" 0
menuText L GraphOptionsEloFile "Elo din fișierul de evaluare" 0
menuText L GraphOptionsEloDB "Elo din baza de date" 0
translate L GraphFilterTitle "Filter Graph: frecvență la 1000 de jocuri"
translate L GraphAbsFilterTitle "Filter Graph: frecvența jocurilor"
translate L ConfigureFilter "Configurați axele X pentru an, evaluare și mișcări"
translate L FilterEstimate "Estima"
translate L TitleFilterGraph "Scid: Filter Graph"

# Analysis window:
translate L AddVariation {Adăugați o variație}
translate L AddAllVariations {Adăugați toate variantele}
translate L AddMove {Adăugați Mutare}
translate L Annotate {Adnota}
translate L ShowAnalysisBoard {Afișați panoul de analiză}
translate L ShowInfo {Afișați informații despre motor}
translate L FinishGame {Termină jocul}
translate L StopEngine {Opriți motorul}
translate L StartEngine {Porniți motorul}
translate L LockEngine {Blocați motorul în poziția curentă}
translate L AnalysisCommand {Comanda de analiză}
translate L PreviousChoices {Alegerile anterioare}
translate L AnnotateTime {Timp pe mișcare în sec.}
translate L AnnotateWhich {Adăugați variații}
translate L AnnotateAll {Pentru mișcări de ambele părți}
translate L AnnotateAllMoves {Adnotă toate mișcările}
translate L AnnotateWhite {Numai pentru mișcările albe}
translate L AnnotateBlack {Numai pentru mișcările negre}
translate L AnnotateBlundersOnly {Când mutarea jocului este o gafă}
translate L AnnotateBlundersOnlyScoreChange {Analiza raportează gafe, cu modificarea scorului de la/la:}
translate L BlundersThreshold {Prag}
translate L ScoreAllMoves {Punctează toate mișcările}
translate L LowPriority {Prioritate scăzută a procesorului}
translate L ClickHereToSeeMoves {Faceți clic aici pentru a vedea mișcările}
translate L ConfigureInformant {Valorile informatorilor}
translate L Informant!? {Interesanta miscare}
translate L Informant? {Slabă mișcare}
translate L Informant?? {Gafă}
translate L Informant?! {Mișcare dubioasă}
translate L Informant+= {Albul are un mic avantaj}
translate L Informant+/- {Albul are un avantaj clar}
translate L Informant+- {Albul are un avantaj decisiv}
translate L Informant+-- {Albul are un avantaj zdrobitor}
translate L AutoComment {Comentariu automat}
translate L AutoCommentTooltip {Generați comentarii AI pentru poziția curentă}
translate L AnalysisAutoCommentTooltip {Generați comentarii AI pentru întregul joc}

# Book window
translate L Book {Carte}
translate L OtherBookMoves {Cartea adversarului}
translate L OtherBookMovesTooltip {Mișcări la care adversarul are răspuns}

# Analysis Engine open dialog:
translate L EngineList {Lista motorului de analiză}
translate L EngineName {Nume}
translate L EngineCmd {Comanda}
translate L EngineArgs {Parametrii}
translate L EngineDir {Director}
translate L EngineElo {Elo}
translate L EngineTime {Data}
translate L EngineNew {Nou}
translate L EngineEdit {Edita}
translate L EngineRequired {Câmpurile cu caractere aldine sunt obligatorii; altele sunt optionale}
translate L EngineProtocol {Protocol de comunicare}
translate L EngineNotation {Notarea mișcărilor}
translate L EngineFlipEvaluation {Flip perspectiva de evaluare}
translate L EngineShowLog {Afișează jurnalul de comunicare}
translate L EngineNetworkd {Acceptați conexiuni la distanță}
translate L EngineSelect {Selectați motorul curent}
translate L EngineAddLocal {Adăugați un motor local}
translate L EngineAddRemote {Adăugați un motor de la distanță}
translate L EngineReload {Reîncărcați motorul actual}
translate L EngineClone {Creați o copie a motorului curent}
translate L EngineDelete {Ștergeți motorul actual}

# PGN window menus:
menuText L PgnFile "Fişier" 0
menuText L PgnFileCopy "Copiați jocul în Clipboard" 0
menuText L PgnFilePrint "Imprimați în fișier..." 0
menuText L PgnFileClose "Închideți fereastra PGN" 10
menuText L PgnOpt "Afişa" 0
menuText L PgnOptColor "Afișaj color" 0
menuText L PgnOptShort "Antet scurt (de 3 linii)." 0
menuText L PgnOptSymbols "Adnotări simbolice" 1
menuText L PgnOptIndentC "Indentarea comentariilor" 0
menuText L PgnOptIndentV "Variații de indentare" 7
menuText L PgnOptColumn "Stil coloană (o mișcare pe linie)" 1
menuText L PgnOptSpace "Spațiu după Mutare numere" 1
menuText L PgnOptStripMarks "Scoateți codurile pătrate/săgeți colorate" 1
menuText L PgnOptBoldMainLine "Folosiți textul aldine pentru mutarea liniei principale" 4
menuText L PgnColor "Culori" 0
menuText L PgnColorHeader "Antet..." 0
menuText L PgnColorAnno "Adnotări..." 0
menuText L PgnColorComments "Comentarii..." 0
menuText L PgnColorVars "Variante..." 0
menuText L PgnColorBackground "Fundal..." 0
menuText L PgnColorMain "Linia principala..." 0
menuText L PgnColorCurrent "Fundalul mișcării curente..." 1
menuText L PgnHelp "Ajutor" 0
menuText L PgnHelpPgn "Ajutor PGN" 0
menuText L PgnHelpIndex "Index" 0
translate L PgnWindowTitle {Notație - joc %u}

# Crosstable window menus:
menuText L CrosstabFile "Fişier" 0
menuText L CrosstabFileText "Imprimați în fișier text..." 9
menuText L CrosstabFileHtml "Imprimați în fișier HTML..." 9
menuText L CrosstabFileClose "Închideți fereastra Crosstable" 0
menuText L CrosstabEdit "Edita" 0
menuText L CrosstabEditEvent "Eveniment" 0
menuText L CrosstabEditSite "Site" 0
menuText L CrosstabEditDate "Data" 0
menuText L CrosstabOpt "Afişa" 0
menuText L CrosstabOptAll "Toate-joaca-toate" 0
menuText L CrosstabOptSwiss "elvețian" 0
menuText L CrosstabOptKnockout "Făcut praf" 0
menuText L CrosstabOptAuto "Auto" 1
menuText L CrosstabOptAges "Vârstele în ani" 8
menuText L CrosstabOptNats "Naționalități" 0
menuText L CrosstabOptRatings "Evaluări" 0
menuText L CrosstabOptTitles "Titluri" 0
menuText L CrosstabOptBreaks "Scoruri de departajare" 4
menuText L CrosstabOptDeleted "Includeți jocurile șterse" 8
menuText L CrosstabOptColors "Culori (numai masa elvețiană)" 0
menuText L CrosstabOptColumnNumbers "Coloane numerotate (numai tabelul All-play-all)" 2
menuText L CrosstabOptGroup "Scoruri de grup" 0
menuText L CrosstabSort "Sorta" 0
menuText L CrosstabSortName "Nume" 0
menuText L CrosstabSortRating "Evaluare" 0
menuText L CrosstabSortScore "Scor" 0
menuText L CrosstabColor "Culoare" 0
menuText L CrosstabColorPlain "Text simplu" 0
menuText L CrosstabColorHyper "Hipertext" 0
menuText L CrosstabHelp "Ajutor" 0
menuText L CrosstabHelpCross "Crosstable Help" 0
menuText L CrosstabHelpIndex "Index de ajutor" 0
translate L SetFilter {Setați filtrul}
translate L AddToFilter {Adăugați la Filtru}
translate L Swiss {elvețian}
translate L Category {Categorie}

# Opening report window menus:
menuText L OprepFile "Fişier" 0
menuText L OprepFileText "Imprimați în fișier text..." 9
menuText L OprepFileHtml "Imprimați în fișier HTML..." 9
menuText L OprepFileOptions "Opțiuni..." 0
menuText L OprepFileClose "Închideți fereastra de raportare" 0
menuText L OprepFavorites "Favorite" 1
menuText L OprepFavoritesAdd "Adăugați raport..." 0
menuText L OprepFavoritesEdit "Editați preferințele raportului..." 0
menuText L OprepFavoritesGenerate "Generați rapoarte..." 0
menuText L OprepHelp "Ajutor" 0
menuText L OprepHelpReport "Deschiderea Ajutor raport" 0
menuText L OprepHelpIndex "Index de ajutor" 0

# Header search:
translate L HeaderSearch {Căutare antet}
translate L EndSideToMove {Partea de mutat la sfârșitul jocului}
translate L GamesWithNoECO {Jocuri fără ECO?}
translate L GameLength {Durata jocului}
translate L FindGamesWith {Găsiți jocuri cu steaguri}
translate L StdStart {Pornire non-standard}
translate L Promotions {Promoții}
translate L Comments {Comentarii}
translate L Variations {Variante}
translate L Annotations {Adnotări}
translate L DeleteFlag {Ștergeți steag}
translate L WhiteOpFlag {Deschidere albă}
translate L BlackOpFlag {Deschidere neagră}
translate L MiddlegameFlag {Jocul de mijloc}
translate L EndgameFlag {Finalul jocului}
translate L NoveltyFlag {Noutate}
translate L PawnFlag {Structura pionului}
translate L TacticsFlag {Tactici}
translate L QsideFlag {Joc Queenside}
translate L KsideFlag {Joacă Kingside}
translate L BrilliancyFlag {Strălucire}
translate L BlunderFlag {Gafă}
translate L UserFlag {Utilizator}
translate L PgnContains {PGN conține text}
translate L PgnTag {Etichetă}
translate L TagContains {conţine}
translate L Variant {Variantă}
translate L Annotator {Adnotator}
translate L Cmnts {Doar jocuri adnotate}

# Game list window:
translate L GlistNumber {Număr}
translate L GlistWhite {Alb}
translate L GlistBlack {Negru}
translate L GlistWElo {W-Elo}
translate L GlistBElo {B-Elo}
translate L GlistEvent {Eveniment}
translate L GlistSite {Site}
translate L GlistRound {Rundă}
translate L GlistDate {Data}
translate L GlistYear {An}
translate L GlistEDate {EventDate}
translate L GlistResult {Rezultat}
translate L GlistLength {Lungime}
translate L GlistCountry {Ţară}
translate L GlistECO {ECO}
translate L GlistOpening {Deschidere}
translate L GlistEndMaterial {Material final}
translate L GlistDeleted {Șters}
translate L GlistFlags {Steaguri}
translate L GlistVars {Variante}
translate L GlistComments {Comentarii}
translate L GlistAnnos {Adnotări}
translate L GlistStart {Început}
translate L GlistGameNumber {Numărul jocului}
translate L GlistAverageElo {Elo mediu}
translate L GlistRating {Evaluare}
translate L GlistFindText {Găsiți text}
translate L GlistMoveField {Mişcare}
translate L GlistEditField {Configurați}
translate L GlistAddField {Adăuga}
translate L GlistDeleteField {Elimina}
translate L GlistWidth {Lăţime}
translate L GlistAlign {Alinia}
translate L GlistAlignL {Aliniere: stânga}
translate L GlistAlignR {Aliniere: dreapta}
translate L GlistAlignC {Aliniere: centru}
translate L GlistColor {Culoare}
translate L GlistSep {Separator}
translate L GlistCurrentSep {-- Curent --}
translate L GlistNewSort {Nou}
translate L GlistAddToSort {Adăuga}

# base sorting
translate L GsortSort {Sorta...}
translate L GsortDate {Data}
translate L GsortYear {An}
translate L GsortEvent {Eveniment}
translate L GsortSite {Site}
translate L GsortRound {Rundă}
translate L GsortWhiteName {Nume alb}
translate L GsortBlackName {Nume negru}
translate L GsortECO {ECO}
translate L GsortResult {Rezultat}
translate L GsortMoveCount {Contor de mutare}
translate L GsortAverageElo {Elo mediu}
translate L GsortCountry {Ţară}
translate L GsortDeleted {Șters}
translate L GsortEventDate {Data evenimentului}
translate L GsortWhiteElo {Elo alb}
translate L GsortBlackElo {Elo negru}
translate L GsortComments {Comentarii}
translate L GsortVariations {Variante}
translate L GsortNAGs {NAG-uri}
translate L GsortAscending {Ascendent}
translate L GsortDescending {Descendent}
translate L GsortAdd {Adăuga}
translate L GsortStore {Magazin}
translate L GsortLoad {Încărca}

# menu shown with right mouse button down on game list.
translate L GlistRemoveThisGameFromFilter  {Eliminați acest joc din Filtru}
translate L GlistRemoveGameAndAboveFromFilter  {Eliminați jocul (și toate de mai sus) din Filtru}
translate L GlistRemoveGameAndBelowFromFilter  {Eliminați jocul (și toate de sub el) din Filtru}
translate L GlistDeleteGame {(Un)Ștergeți acest joc}
translate L GlistDeleteAllGames {Șterge toate jocurile din filtru}
translate L GlistUndeleteAllGames {Anulați ștergerea tuturor jocurilor din filtru}
translate L GlistMergeGameInBase {Îmbina jocul în}

# Maintenance window:
translate L DatabaseName {Numele bazei de date:}
translate L TypeIcon {Pictograma tip:}
translate L NumOfGames {Jocuri:}
translate L NumDeletedGames {Jocuri șterse:}
translate L NumFilterGames {Jocuri în filtru:}
translate L YearRange {Interval de ani:}
translate L RatingRange {Interval de evaluare:}
translate L Description {Descriere}
translate L Flag {Pavilion}
translate L CustomFlags {Steaguri personalizate}
translate L DeleteCurrent {Șterge jocul curent}
translate L DeleteFilter {Ștergeți jocurile de filtrare}
translate L DeleteAll {Șterge toate jocurile}
translate L UndeleteCurrent {Anulați ștergerea jocului curent}
translate L UndeleteFilter {Anulați ștergerea filtrului de jocuri}
translate L UndeleteAll {Anulați ștergerea tuturor jocurilor}
translate L DeleteTwins {Șterge jocurile gemene}
translate L MarkCurrent {Marcați jocul curent}
translate L MarkFilter {Marcați jocurile cu filtre}
translate L MarkAll {Marcați toate jocurile}
translate L UnmarkCurrent {Demarcați jocul curent}
translate L UnmarkFilter {Demarcați jocurile cu filtre}
translate L UnmarkAll {Demarcați toate jocurile}
translate L Spellchecking {Verificarea ortografică}
translate L Players {Jucători}
translate L Events {Evenimente}
translate L Sites {Site-uri}
translate L Rounds {Runde}
translate L DatabaseOps {Operațiuni cu baze de date}
translate L ReclassifyGames {ECO-clasificare jocuri}
translate L CompactDatabase {Baza de date compacta}
translate L SortDatabase {Sortați baza de date}
translate L AddEloRatings {Adăugați evaluări Elo}
translate L AutoloadGame {Încărcați automat numărul jocului}
translate L StripTags {Eliminați etichetele PGN}
translate L StripTag {Eticheta bandă}
translate L Cleaner {Mai curat}
translate L CleanerHelp {Scid Cleaner va efectua toate acțiunile de întreținere pe care le selectați din lista de mai jos, pe baza de date curentă.
Setările curente din clasificarea ECO și casetele de dialog de ștergere dublă se vor aplica dacă selectați acele funcții.}
translate L CleanerConfirm {Odată ce întreținerea Cleaner este pornită, aceasta nu poate fi întreruptă!

Acest lucru poate dura mult timp pentru o bază de date mare, în funcție de funcțiile pe care le-ați selectat și de setările lor curente.

Sigur doriți să începeți funcțiile de întreținere pe care le-ați selectat?}
# Twinchecker
translate L TwinCheckUndelete {a răsturna; „u” le anulează pe ambele)}
translate L TwinCheckprevPair {Perechea anterioară}
translate L TwinChecknextPair {Următoarea pereche}
translate L TwinChecker {Scid: Verificator de joc dublu}
translate L TwinCheckTournament {Jocuri din turneu:}
translate L TwinCheckNoTwin {Nici un geamăn}
translate L TwinCheckNoTwinfound {Nu a fost detectat niciun geamăn pentru acest joc.\nNu arătați gemeni folosind această fereastră, trebuie mai întâi să utilizați funcția „Ștergeți jocurile gemene...”.}
translate L TwinCheckTag {Distribuie etichete...}
translate L TwinCheckFound1 {Scid a găsit jocuri duble $result}
translate L TwinCheckFound2 {și setați steagurile lor de ștergere}
translate L TwinCheckNoDelete {Nu există jocuri de șters în această bază de date.}
translate L TwinCriteria1 {Este posibil ca setările dvs. pentru găsirea de jocuri gemene să provoace ca jocurile non-gemeni cu mișcări similare să fie marcate ca gemeni.}
translate L TwinCriteria2 {Se recomandă ca dacă selectați „Nu” pentru „aceleași mișcări”, să selectați „Da” pentru setările de culori, eveniment, site, rundă, an și lună.\nDoriți să continuați și să ștergeți gemeni oricum?}
translate L TwinCriteria3 {Este recomandat să specificați „Da” pentru cel puțin două dintre setările „același site”, „aceeași rundă” și „același an”.\nDoriți să continuați și să ștergeți gemeni oricum?}
translate L TwinCriteriaConfirm {Scid: Confirmați setările duble}
translate L TwinChangeTag "Schimbați următoarele etichete de joc:\n\n"
translate L AllocRatingDescription "Această comandă va folosi fișierul de verificare ortografică curent pentru a adăuga evaluări Elo la jocurile din această bază de date. Oriunde un jucător nu are o evaluare curentă, dar ratingul său la momentul jocului este listat în fișierul de verificare ortografică, acel rating va fi adăugat."
translate L RatingOverride "Suprascrie evaluările existente diferite de zero"
translate L AddRatings "Adăugați evaluări la:"
translate L AddedRatings {Scid a adăugat $r evaluări Elo în $g jocuri.}

#Bookmark editor
translate L NewSubmenu "Submeniu nou"

# Comment editor:
translate L AnnotationSymbols  {Simboluri de adnotare:}
translate L Comment {Comentariu:}
translate L InsertMark {Introduceți marcajul}
translate L InsertMarkHelp {Inserare/eliminare marcaj: Selectați culoarea, tipul, pătratul.
Introduceți/eliminați săgeata: faceți clic dreapta pe două pătrate.}

# Nag buttons in comment editor:
translate L GoodMove {Bună mișcare}
translate L PoorMove {Slabă mișcare}
translate L ExcellentMove {Excelenta miscare}
translate L Blunder {Gafă}
translate L InterestingMove {Interesanta miscare}
translate L DubiousMove {Mișcare dubioasă}
translate L WhiteDecisiveAdvantage {Albul are un avantaj decisiv}
translate L BlackDecisiveAdvantage {Negrul are un avantaj decisiv}
translate L WhiteClearAdvantage {Albul are un avantaj clar}
translate L BlackClearAdvantage {Negrul are un avantaj clar}
translate L WhiteSlightAdvantage {Albul are un mic avantaj}
translate L BlackSlightAdvantage {Negrul are un mic avantaj}
translate L WhiteCrushing {Albul are un avantaj zdrobitor}
translate L BlackCrushing {Negrul are un avantaj zdrobitor}
translate L Equality {Egalitatea}
translate L Unclear {Neclar}
translate L Diagram {Diagramă}

# Board search:
translate L BoardSearch {Căutare de bord}
translate L FilterOperation {Funcționare pe filtrul curent:}
translate L FilterAnd {ȘI (filtru de restricționare)}
translate L FilterOr {SAU (Adaugă la filtru)}
translate L FilterIgnore {IGNORE (Resetați filtrul)}
translate L SearchType {Tip de căutare:}
translate L SearchBoardExact {Poziția exactă (toate piesele pe aceleași pătrate)}
translate L SearchBoardPawns {Pioni (același material, toți pionii pe aceleași pătrate)}
translate L SearchBoardFiles {Fișiere (același material, toți pionii pe aceleași fișiere)}
translate L SearchBoardAny {Oricare (același material, pioni și piese oriunde)}
translate L SearchInRefDatabase {Căutați în baza de date de referință}
translate L LookInVars {Uită-te în variații}

# Material search:
translate L MaterialSearch {Căutarea materialelor}
translate L Material {Material}
translate L Patterns {Modele}
translate L Zero {Zero}
translate L Any {Orice}
translate L CurrentBoard {Consiliul actual}
translate L CommonEndings {Terminații comune}
translate L CommonPatterns {Modele comune}
translate L MaterialDiff {Diferența materială}
translate L squares {pătrate}
translate L SameColor {Aceeași culoare}
translate L OppColor {Culoare opusa}
translate L Either {Oricum}
translate L MoveNumberRange {Mutați intervalul de numere}
translate L MatchForAtLeast {Se potrivește cel puțin}
translate L HalfMoves {jumătăţi de mişcări}

# Common endings in material search:
translate L EndingPawns {Terminații de pion}
translate L EndingRookVsPawns {Rook vs. Pion(i)}
translate L EndingRookPawnVsRook {Rook și 1 pion vs. Rook}
translate L EndingRookPawnsVsRook {Rook și Pion(i) vs. Rook}
translate L EndingRooks {Finalele Rook vs. Rook}
translate L EndingRooksPassedA {Rook vs. Rook se termină cu un pion A trecut}
translate L EndingRooksDouble {Terminații Double Rook}
translate L EndingBishops {Desinerile Bishop vs. Bishop}
translate L EndingBishopVsKnight {Finaluri Bishop vs Knight}
translate L EndingKnights {Finaluri Knight vs. Knight}
translate L EndingQueens {Finaluri Queen vs. Queen}
translate L EndingQueenPawnVsQueen {Regină și 1 pion împotriva reginei}
translate L BishopPairVsKnightPair {Doi episcopi vs. doi cavaleri}

# Common patterns in material search:
translate L PatternWhiteIQP {IQP alb}
translate L PatternWhiteIQPBreakE6 {IQP alb: d4-d5 break vs. e6}
translate L PatternWhiteIQPBreakC6 {IQP alb: d4-d5 break vs. c6}
translate L PatternBlackIQP {IQP negru}
translate L PatternWhiteBlackIQP {IQP alb vs. IQP negru}
translate L PatternCoupleC3D4 {Alb c3+d4 Cuplu de pion izolat}
translate L PatternHangingC5D5 {Pioni negri agățați pe c5 și d5}
translate L PatternMaroczy {Maroczy Center (cu pioni pe c4 și e4)}
translate L PatternRookSacC3 {Rook Sacrifice pe c3}
translate L PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)}
translate L PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)}
translate L PatternLightFian {Fianchettos pătrați lumini (Bishop-g2 vs. Bishop-b7)}
translate L PatternDarkFian {Fianchettos din pătrat întunecat (Bishop-b2 vs. Bishop-g7)}
translate L PatternFourFian {Patru Fianchettos (Episcopi pe b2,g2,b7,g7)}

# Game saving:
translate L Today {Astăzi}
translate L ClassifyGame {Clasifica jocul}

# Setup position:
translate L EmptyBoard {Tablă goală}
translate L InitialBoard {Tabla initiala}
translate L SideToMove {Partea de mișcare}
translate L MoveNumber {Mută ​​numărul}
translate L Castling {Rocare}
translate L EnPassantFile {En Passant file}
translate L ClearFen {Ștergeți FEN}
translate L PasteFen {Lipiți FEN}

translate L SaveAndContinue {Salvați și continuați}
translate L DiscardChangesAndContinue {Renunțați la modificări și continuați}
translate L GoBack {Întoarce-te}

# Replace move dialog:
translate L ReplaceMove {Înlocuiește mutarea}
translate L AddNewVar {Adăugați o nouă variantă}
translate L NewMainLine {Noua linie principală}
translate L ReplaceMoveMessage {O mutare există deja aici.

Puteți să-l înlocuiți, renunțând toate mișcările după el sau să adăugați mutarea dvs. ca o nouă variație.

(Puteți evita să vedeți acest mesaj în viitor dezactivând opțiunea „Întrebați înainte de a înlocui mișcările” din meniul Opțiuni: Mutări.)}

# Make database read-only dialog:
translate L ReadOnlyDialog {Dacă faceți această bază de date doar în citire, nu vor fi permise modificări.
Niciun joc nu poate fi salvat sau înlocuit și nicio steaguri de ștergere nu pot fi modificate.
Orice rezultate de sortare sau ECO-clasificare vor fi temporare.

Puteți face cu ușurință din nou baza de date inscriptabilă, prin închiderea și redeschiderea acesteia.

Chiar doriți să faceți această bază de date doar în citire?}

# Clear game dialog:
translate L ClearGameDialog {Acest joc a fost modificat.

Chiar doriți să continuați și să renunțați la modificările aduse?}

# Exit dialog:
translate L ExitDialog {Chiar vrei să ieși din Scid?}
translate L ExitUnsaved {Următoarele baze de date au modificări de joc nesalvate. Dacă ieșiți acum, aceste modificări se vor pierde.}

# Import window:
translate L PasteCurrentGame {Lipiți jocul curent}
translate L ImportHelp1 {Introduceți sau inserați un joc în format PGN în cadrul de mai sus.}
translate L ImportHelp2 {Orice erori la importul jocului vor fi afișate aici.}
translate L OverwriteExistingMoves {Suprascrieți mișcările existente?}

# ECO Browser:
translate L ECOAllSections {toate secțiunile ECO}
translate L ECOSection {Sectiunea ECO}
translate L ECOSummary {Rezumat pentru}
translate L ECOFrequency {Frecvența subcodurilor pentru}

# Opening Report:
translate L OprepTitle {Raport de deschidere}
translate L OprepReport {Raport}
translate L OprepGenerated {Generat de}
translate L OprepStatsHist {Statistică și istorie}
translate L OprepStats {Statistici}
translate L OprepStatAll {Toate jocurile de raportare}
translate L OprepStatBoth {Ambele evaluate}
translate L OprepStatSince {Din moment ce}
translate L OprepOldest {Cele mai vechi jocuri}
translate L OprepNewest {Cele mai noi jocuri}
translate L OprepPopular {Popularitatea actuală}
translate L OprepFreqAll {Frecvența în toți anii:}
translate L OprepFreq1   {În 1 an până astăzi:}
translate L OprepFreq5   {În 5 ani până astăzi:}
translate L OprepFreq10  {În 10 ani până astăzi:}
translate L OprepEvery {o dată la %u jocuri}
translate L OprepUp {în %u%s din toți anii}
translate L OprepDown {în scădere cu %u%s din toți anii}
translate L OprepSame {nicio schimbare din toți anii}
translate L OprepMostFrequent {Cei mai frecventi jucători}
translate L OprepMostFrequentOpponents {Cei mai frecventi adversari}
translate L OprepRatingsPerf {Evaluări și performanță}
translate L OprepAvgPerf {Evaluări și performanțe medii}
translate L OprepWRating {Evaluare albă}
translate L OprepBRating {Evaluare neagră}
translate L OprepWPerf {Performanță albă}
translate L OprepBPerf {Performanță neagră}
translate L OprepHighRating {Jocuri cu cel mai mare rating mediu}
translate L OprepTrends {Tendințe de rezultate}
translate L OprepResults {Lungimi și frecvențe rezultate}
translate L OprepLength {Durata jocului}
translate L OprepFrequency {Frecvenţă}
translate L OprepWWins {Albul câștigă:}
translate L OprepBWins {Negrul câștigă:}
translate L OprepDraws {Remiză:}
translate L OprepWholeDB {întreaga bază de date}
translate L OprepShortest {Cele mai scurte victorii}
translate L OprepMovesThemes {Mișcări și teme}
translate L OprepMoveOrders {Mutați comenzile care ajung în poziția raportului}
translate L OprepMoveOrdersOne \
  {A existat un singur ordin de mutare care a ajuns în această poziție:}
translate L OprepMoveOrdersAll \
  {Au fost %u comenzi de mutare care au ajuns în această poziție:}
translate L OprepMoveOrdersMany \
  {Au fost %u comenzi de mutare care au ajuns în această poziție. Primele %u sunt:}
translate L OprepMovesFrom {Se deplasează din poziția raportului}
translate L OprepMostFrequentEcoCodes {Cele mai frecvente coduri ECO}
translate L OprepThemes {Teme poziționale}
translate L OprepThemeDescription {Frecvența temelor în primele %u mișcări ale fiecărui joc}
translate L OprepThemeSameCastling {Roca pe aceeași parte}
translate L OprepThemeOppCastling {Vizavi de roca}
translate L OprepThemeNoCastling {Amândoi Regii dezrodați}
translate L OprepThemeKPawnStorm {Furtuna de pioni din partea regelui}
translate L OprepThemeQueenswap {S-au schimbat regine}
translate L OprepThemeWIQP {Pion alb al reginei izolat}
translate L OprepThemeBIQP {Pion Regina Izolat Negru}
translate L OprepThemeWP567 {Pion alb pe locul 5/6/7}
translate L OprepThemeBP234 {Pionul Negru pe locul 2/3/4}
translate L OprepThemeOpenCDE {Deschideți fișierul c/d/e}
translate L OprepTheme1BishopPair {Doar o parte are pereche Bishop}
translate L OprepEndgames {Endgames}
translate L OprepReportGames {Raportează jocuri}
translate L OprepAllGames    {Toate jocurile}
translate L OprepEndClass {Material la sfârșitul fiecărui joc}
translate L OprepTheoryTable {Tabel Teoretic}
translate L OprepTableComment {Generat din %u jocuri cu cele mai bune cote.}
translate L OprepExtraMoves {Mișcări suplimentare de note în tabelul teoretic}
translate L OprepMaxGames {Maxim de jocuri la masa teoretică}
translate L OprepViewHTML {Vizualizați HTML}

# Player Report:
translate L PReportTitle {Raportul jucătorului}
translate L PReportColorWhite {cu piesele Albe}
translate L PReportColorBlack {cu piesele negre}
translate L PReportMoves {după %s}
translate L PReportOpenings {Deschideri}
translate L PReportClipbase {Goliți baza de clipuri și copiați în ea jocurile potrivite}

# Piece Tracker window:
translate L TrackerSelectSingle {Butonul stâng al mouse-ului selectează această piesă.}
translate L TrackerSelectPair {Butonul stâng al mouse-ului selectează această piesă; butonul din dreapta își selectează și fratele.}
translate L TrackerSelectPawn {Butonul stâng al mouse-ului selectează acest pion; butonul din dreapta selectează toți cei 8 pioni.}
translate L TrackerStat {Statistică}
translate L TrackerGames {% jocuri cu mutare în pătrat}
translate L TrackerTime {% timp pe fiecare pătrat}
translate L TrackerMoves {Mișcări}
translate L TrackerMovesStart {Introduceți numărul de mișcare unde ar trebui să înceapă urmărirea.}
translate L TrackerMovesStop {Introduceți numărul de mișcare unde urmărirea ar trebui să se oprească.}

# Game selection dialogs:
translate L SelectAllGames {Toate jocurile din baza de date}
translate L SelectFilterGames {Doar jocuri în filtru}
translate L SelectTournamentGames {Doar jocurile din turneul actual}
translate L SelectOlderGames {Doar jocuri mai vechi}

# Delete Twins window:
translate L TwinsNote {Pentru a fi gemeni, două jocuri trebuie să aibă cel puțin aceiași doi jucători, iar criteriile pe care le puteți seta mai jos. Când se găsește o pereche de gemeni, jocul mai scurt este șters. Sugestie: cel mai bine este să verificați ortografic baza de date înainte de a șterge gemeni, deoarece îmbunătățește detectarea gemenilor.}
translate L TwinsCriteria {Criterii: Jocurile duble trebuie să aibă...}
translate L TwinsWhich {Examinați ce jocuri}
translate L TwinsColors {Aceleași culori ale jucătorilor}
translate L TwinsEvent {Același eveniment}
translate L TwinsSite {Același site}
translate L TwinsRound {Aceeași rundă}
translate L TwinsYear {Același an}
translate L TwinsMonth {Aceeași lună}
translate L TwinsDay {În aceeași zi}
translate L TwinsResult {Același rezultat}
translate L TwinsECO {Același cod ECO}
translate L TwinsMoves {Aceleași mișcări}
translate L TwinsPlayers {Compararea numelor jucătorilor}
translate L TwinsPlayersExact {Potrivire exactă}
translate L TwinsPlayersPrefix {Doar primele 4 litere}
translate L TwinsWhen {Când ștergeți jocurile gemene}
translate L TwinsSkipShort {Ignorați toate jocurile sub 5 mutări}
translate L TwinsUndelete {Mai întâi anulați ștergerea tuturor jocurilor}
translate L TwinsSetFilter {Setați filtrul pentru toate jocurile gemene șterse}
translate L TwinsComments {Păstrați întotdeauna jocurile cu comentarii}
translate L TwinsVars {Păstrați întotdeauna jocuri cu variații}
translate L TwinsDeleteWhich {Șterge jocul}
translate L TwinsDeleteShorter {Joc mai scurt}
translate L TwinsDeleteOlder {Număr de joc mai mic}
translate L TwinsDeleteNewer {Număr de joc mai mare}
translate L TwinsDelete {Șterge jocuri}

# Name editor window:
translate L NameEditType {Tip de nume de editat}
translate L NameEditSelect {Jocuri de editat}
translate L NameEditReplace {Înlocui}
translate L NameEditWith {cu}
translate L NameEditMatches {Potriviri: apăsați Ctrl+1 până la Ctrl+9 pentru a selecta}

# Check games window:
translate L CheckGames {Verificați jocurile}
translate L CheckGamesWhich {Verificați jocurile}
translate L CheckAll {Toate jocurile}
translate L CheckSelectFilterGames {Doar jocuri în filtru}

# Classify window:
translate L Classify {Clasifica}
translate L ClassifyWhich {ECO-Clasificați ce jocuri}
translate L ClassifyAll {Toate jocurile (suprascrieți vechile coduri ECO)}
translate L ClassifyYear {Toate jocurile jucate în ultimul an}
translate L ClassifyMonth {Toate jocurile jucate în ultima lună}
translate L ClassifyNew {Doar jocuri fără cod ECO încă}
translate L ClassifyCodes {Coduri ECO de utilizat}
translate L ClassifyBasic {Numai coduri de bază ("B12", ...)}
translate L ClassifyExtended {Extensii Scid ("B12j", ...)}

# Compaction:
translate L NameFile {Fișier cu nume}
translate L GameFile {Fișierul jocului}
translate L Names {Nume}
translate L Unused {Nefolosit}
translate L SizeKb {Dimensiune (kb)}
translate L CurrentState {Starea actuală}
translate L AfterCompaction {După compactare}
translate L CompactNames {Fișier cu nume compact}
translate L CompactGames {Fișier de joc compact}
translate L NoUnusedNames "Nu există nume neutilizate, așa că fișierul de nume este deja complet compactat."
translate L NoUnusedGames "Fișierul jocului este deja complet compactat."
translate L GameFileCompacted {Fișierul jocului pentru baza de date a fost compactat.}

# Sorting:
translate L SortCriteria {Criterii}
translate L AddCriteria {Adăugați criterii}
translate L CommonSorts {Soiuri comune}
translate L Sort {Sorta}

# Exporting:
translate L AddToExistingFile {Adăugați jocuri la un fișier existent}
translate L ExportComments {Exportați comentariile}
translate L ExportVariations {Exportați variații}
translate L IndentComments {Indentarea comentariilor}
translate L IndentVariations {Variații de indentare}
translate L ExportColumnStyle {Stil de coloană (o mișcare pe linie)}
translate L ExportSymbolStyle {Stilul de adnotare simbolică:}
translate L ExportStripMarks {Eliminați codurile pătrate/săgeți din comentarii}

# Goto game/move dialogs:
translate L LoadGameNumber {Introduceți numărul jocului de încărcat:}
translate L GotoMoveNumber {Treci la mutarea numărului:}

# Copy games dialog:
translate L CopyAllGames {Copiați toate jocurile în}
translate L CopyGames {Jocuri de copiere}
translate L CopyConfirm {Chiar vrei să copiezi
 jocurile filtrate [::utils::thousands $nGamesToCopy].
 în baza de date „$fromName”
 la baza de date „$targetName”?}
translate L CopyErr {Nu se pot copia jocuri}
translate L CopyErrSource {baza de date sursă}
translate L CopyErrTarget {baza de date țintă}
translate L CopyErrNoGames {nu are jocuri în filtrul său}
translate L CopyErrReadOnly {este doar pentru citire}
translate L CopyErrNotOpen {nu este deschis}

# Colors:
translate L LightSquares {Pătrate ușoare}
translate L DarkSquares {Pătrate întunecate}
translate L SelectedSquares {Pătrate selectate}
translate L SuggestedSquares {Patratele de mutare sugerate}
translate L WhitePieces {Bucăți albe}
translate L BlackPieces {Piese negre}
translate L WhiteBorder {Chenar alb}
translate L BlackBorder {Chenar negru}

# Novelty window:
translate L FindNovelty {Găsiți noutate}
translate L Novelty {Noutate}
translate L NoveltyInterrupt {Căutare de noutate întreruptă}
translate L NoveltyNone {Nu s-a găsit nicio noutate pentru acest joc}
translate L NoveltyHelp {Scid va găsi prima mișcare a jocului curent care ajunge într-o poziție negăsită în baza de date selectată sau în cartea de deschideri ECO.}

# Sounds configuration:
translate L SoundsFolder {Folder cu fișiere de sunet}
translate L SoundsFolderHelp {Dosarul ar trebui să conțină fișierele King.wav, a.wav, 1.wav etc}
translate L SoundsAnnounceOptions {Mutați opțiunile de anunț}
translate L SoundsAnnounceNew {Anunțați mișcări noi pe măsură ce sunt făcute}
translate L SoundsMoveSoundOnly {Mutați numai sunetul (dezactivați anunțurile)}
translate L SoundsAnnounceForward {Anunțați mișcări atunci când avansați cu o mișcare}
translate L SoundsAnnounceBack {Anunțați când vă retrageți sau vă întoarceți cu o mișcare}
translate L SoundsSoundDisabled {Scid nu a putut găsi pachetul audio Snack la pornire;\nSunetul este dezactivat.}

# Upgrading databases:
translate L Upgrading {Actualizare}
translate L ConfirmOpenNew {Aceasta este o bază de date în format vechi (Scid 3) care nu poate fi deschisă în Scid 4, dar o versiune în format nou (Scid 4) a fost deja creată.

Doriți să deschideți versiunea în format nou a bazei de date?}
translate L ConfirmUpgrade {Aceasta este o bază de date în format vechi (Scid 3). O versiune de nou format a bazei de date trebuie creată înainte de a putea fi utilizată în Scid 4.

Actualizarea va crea o nouă versiune a bazei de date și după aceea va elimina fișierele originale.

Acest lucru poate dura ceva timp, dar trebuie făcut o singură dată. Puteți anula dacă durează prea mult.

Doriți să actualizați această bază de date acum?}

# Recent files options:
translate L RecentFilesMenu {Numărul de fișiere recente din meniul Fișier}
translate L RecentFilesExtra {Numărul de fișiere recente în submeniul suplimentar}

# My Player Names options:
translate L MyPlayerNamesDescription {Introduceți mai jos o listă cu numele jucătorilor preferați, câte un nume pe linie. Caracterele metalice (de exemplu, „?” pentru orice caracter unic, „*” pentru orice secvență de caractere) sunt permise.

De fiecare dată când se încarcă un joc cu un jucător în listă, tabla de șah din fereastra principală va fi rotită dacă este necesar pentru a afișa jocul din perspectiva jucătorului respectiv.}

#Coach
translate L showblunderexists {arată că gafa există}
translate L showblundervalue {arata valoarea gafei}
translate L showscore {arată scorul}
translate L coachgame {joc antrenor}
translate L configurecoachgame {Configurați jocul tactic}
translate L configuregame {Configurarea jocului}
translate L Phalanxengine {Motor de falange}
translate L Coachengine {Motorul autocarului}
translate L difficulty {dificultate}
translate L hard {greu}
translate L easy {uşor}
translate L Playwith {Joacă-te cu}
translate L white {alb}
translate L black {negru}
translate L both {ambele}
translate L Play {Juca}
translate L Noblunder {Fără gafă}
translate L blunder {gafă}
translate L Noinfo {-- Fara informatii --}
translate L PhalanxOrTogaMissing {Falange sau Toga nu au fost găsite}
translate L moveblunderthreshold {mutarea este o gafă dacă pierderea este mai mare decât}
translate L limitanalysis {limitează timpul de analiză a motorului}
translate L seconds {secunde}
translate L Abort {Avorta}
translate L Resume {Relua}
translate L OutOfOpening {Din deschidere}
translate L NotFollowedLine {Nu ai urmat linia}
translate L DoYouWantContinue {Vrei să continui?}
translate L CoachIsWatching {Antrenorul urmărește}
translate L Ponder {Gândire permanentă}
translate L LimitELO {Limitați puterea ELO}
translate L DubiousMovePlayedTakeBack {Mișcare dubioasă a fost jucată, vrei să o luăm înapoi?}
translate L WeakMovePlayedTakeBack {S-a jucat o mișcare slabă, vrei să o luăm înapoi?}
translate L BadMovePlayedTakeBack {Mișcare proastă a fost jucată, vrei să o luăm înapoi?}
translate L Iresign {demisionez}
translate L yourmoveisnotgood {miscarea ta nu este buna}
translate L EndOfVar {Sfârșitul variației}
translate L Openingtrainer {Antrenor de deschidere}
translate L DisplayCM {Afișați mișcările candidatului}
translate L DisplayCMValue {Afișează valoarea mișcărilor candidatului}
translate L DisplayOpeningStats {Afișează statistici}
translate L ShowReport {Afișează raportul}
translate L NumberOfGoodMovesPlayed {mișcări bune jucate}
translate L NumberOfDubiousMovesPlayed {mișcări dubioase jucate}
translate L NumberOfMovesPlayedNotInRepertoire {mișcări jucate nu în repertoriu}
translate L NumberOfTimesPositionEncountered {ori poziția întâlnită}
translate L PlayerBestMove  {Permiteți numai cele mai bune mișcări}
translate L OpponentBestMove {Adversarul joacă cele mai bune mișcări}
translate L OnlyFlaggedLines {Doar linii marcate}
translate L resetStats {Resetați statisticile}
translate L Repertoiretrainingconfiguration {Configurarea antrenamentului în repertoriu}
translate L Loadingrepertoire {Se încarcă repertoriu}
translate L Movesloaded {Mișcările încărcate}
translate L Repertoirenotfound {Repertoriul nu a fost găsit}
translate L Openfirstrepertoirewithtype {Deschideți mai întâi o bază de date de repertoriu cu pictograma/tipul setat în partea dreaptă}
translate L Movenotinrepertoire {Nu mutați în repertoriu}
translate L PositionsInRepertoire {Poziții în repertoriu}
translate L PositionsNotPlayed {Poziții nejucate}
translate L PositionsPlayed {Pozițiile jucate}
translate L Success {Succes}
translate L DubiousMoves {Mișcări dubioase}
translate L OutOfRepertoire {OutOfRepertoire}
translate L ConfigureTactics {Configurați tacticile}
translate L ResetScores {Resetează scorurile}
translate L LoadingBase {Baza de încărcare}
translate L Tactics {Tactici}
translate L ShowSolution {Arată soluția}
translate L NextExercise {Următorul exercițiu}
translate L PrevExercise {Exercițiul anterior}
translate L StopTraining {Opriți antrenamentul}
translate L Next {Următorul}
translate L ResettingScore {Resetarea scorului}
translate L LoadingGame {Se încarcă jocul}
translate L MateFound {Mate găsit}
translate L BestSolutionNotFound {Cea mai bună soluție NU a fost găsită!}
translate L MateNotFound {Mate nu a fost găsit}
translate L ShorterMateExists {Perechea mai scundă există}
translate L ScorePlayed {Scor jucat}
translate L Expected {aşteptat}
translate L ChooseTrainingBase {Alegeți baza de antrenament}
translate L Thinking {Gândire}
translate L AnalyzeDone {Analiza gata}
translate L WinWonGame {Câștigă jocul câștigat}
translate L Lines {Linii}
translate L ConfigureUCIengine {Configurați motorul UCI}
translate L SpecificOpening {Deschidere specifica}
translate L StartNewGame {Începeți un nou joc}
translate L FixedLevel {Nivel fix}
translate L Opening {Deschidere}
translate L RandomLevel {Nivel aleatoriu}
translate L StartFromCurrentPosition {Începeți de la poziția curentă}
translate L FixedDepth {Adâncime fixă}
translate L Nodes {Noduri}
translate L Depth {Adâncime}
translate L Time {Timp}
translate L SecondsPerMove {Secunde pe mișcare}
translate L Engine {Motor}
translate L TimeMode {Modul de timp}
translate L TimeBonus {Timp + bonus}
translate L TimeMin {min}
translate L TimeSec {sec}
translate L AllExercisesDone {Toate exercițiile făcute}
translate L MoveOutOfBook {Mută-te din carte}
translate L LastBookMove {Ultima mutare de carte}
translate L AnnotateSeveralGames {De la joc real la joc:}
translate L FindOpeningErrors {Găsiți erori de deschidere}
translate L MarkTacticalExercises {Marcați exercițiile tactice}
translate L UseBook {Folosește cartea}
translate L MultiPV {Variații multiple}
translate L Hash {Memoria hash}
translate L OwnBook {Folosește cartea motorului}
translate L BookFile {Cartea de deschidere}
translate L AnnotateVariations {Adnotați variațiile}
translate L ShortAnnotations {Adnotări scurte}
translate L addAnnotatorTag {Adăugați etichetă de adnotator}
translate L AddScoreToShortAnnotations {Adăugați scor la adnotări}
translate L Export {Export}
translate L BookPartiallyLoaded {Cartea încărcată parțial}
translate L Calvar {Calculul variațiilor}
translate L ConfigureCalvar {Configurare}
# Opening names used in tacgame.tcl
translate L Reti {Reti}
translate L English {engleză}
translate L d4Nf6Miscellaneous {1.d4 Nf6 Diverse}
translate L Trompowsky {Trompowsky}
translate L Budapest {Budapesta}
translate L OldIndian {vechi indian}
translate L BenkoGambit {Benko Gambit}
translate L ModernBenoni {Benoni modern}
translate L DutchDefence {Apărarea olandeză}
translate L Scandinavian {scandinav}
translate L AlekhineDefence {Apărarea Alekhine}
translate L Pirc {Pirc}
translate L CaroKann {Caro-Kann}
translate L CaroKannAdvance {Caro-Kann Advance}
translate L Sicilian {sicilian}
translate L SicilianAlapin {Alapin sicilian}
translate L SicilianClosed {Sicilian închis}
translate L SicilianRauzer {Rauzer sicilian}
translate L SicilianDragon {Dragonul sicilian}
translate L SicilianScheveningen {Scheveningen sicilian}
translate L SicilianNajdorf {Najdorf siciliană}
translate L OpenGame {Joc deschis}
translate L Vienna {Viena}
translate L KingsGambit {Gambitul Regelui}
translate L RussianGame {Joc rusesc}
translate L ItalianTwoKnights {Italian/Doi Cavaleri}
translate L Spanish {spaniolă}
translate L SpanishExchange {Schimb spaniol}
translate L SpanishOpen {Openul Spaniei}
translate L SpanishClosed {Spaniolă închis}
translate L FrenchDefence {Apărarea franceză}
translate L FrenchAdvance {Avansul francez}
translate L FrenchTarrasch {Tarrasch francez}
translate L FrenchWinawer {Winawer francez}
translate L FrenchExchange {Schimbul francez}
translate L QueensPawn {Pionul Reginei}
translate L Slav {Slav}
translate L QGA {QGA}
translate L QGD {QGD}
translate L QGDExchange {Schimb QGD}
translate L SemiSlav {Semislav}
translate L QGDwithBg5 {QGD cu Bg5}
translate L QGDOrthodox {QGD ortodox}
translate L Grunfeld {Grünfeld}
translate L GrunfeldExchange {Bursa Grünfeld}
translate L GrunfeldRussian {Grünfeld rus}
translate L Catalan {catalan}
translate L CatalanOpen {Catalan Open}
translate L CatalanClosed {Catalan Închis}
translate L QueensIndian {Indianul Reginei}
translate L NimzoIndian {Nimzo-indian}
translate L NimzoIndianClassical {Clasic nimzo-indian}
translate L NimzoIndianRubinstein {Rubinstein nimzo-indian}
translate L KingsIndian {Indianul Regelui}
translate L KingsIndianSamisch {Sämisch indian al regelui}
translate L KingsIndianMainLine {King's Indian Main Line}

# FICS
translate L ConfigureFics {Configurați FICS}
translate L FICSGuest {Conectați-vă ca invitat}
translate L FICSServerPort {Port server}
translate L FICSServerAddress {Adresa IP}
translate L FICSRefresh {Reîmprospăta}
translate L FICSTimesealPort {Port Timeseal}
translate L FICSSilence {Filtru de consolă}
translate L FICSOffers {Oferte}
translate L FICSConsole {Consolă}
translate L FICSGames {Jocuri}
translate L FICSUnobserve {Nu mai observa jocul}
translate L FICSProfile {Afișați istoricul și profilul dvs}
translate L FICSRelayedGames {Jocuri transmise}
translate L FICSFindOpponent {Găsiți un adversar}
translate L FICSTakeback {Reluare}
translate L FICSTakeback2 {Reluare 2}
translate L FICSInitTime {Timp inițial (min)}
translate L FICSIncrement {Creștere (sec)}
translate L FICSRatedGame {Joc evaluat}
translate L FICSAutoColour {automat}
translate L FICSManualConfirm {confirma manual}
translate L FICSFilterFormula {Filtrați cu formula}
translate L FICSIssueSeek {Căutarea problemei}
translate L FICSChallenge {Provocare}
translate L FICSAccept {Acceptați?}
translate L FICSDecline {declin}
translate L FICSColour {Culoare}
translate L FICSSend {trimite}
translate L FICSConnect {Conectați-vă}
translate L FICSdefaultuservars {Utilizați variabile implicite}
translate L FICSObserveconfirm {Vrei să observi jocul}
translate L FICSpremove {Activați premove}
translate L FICSObserve {Observați}
translate L FICSRatedGames {Jocuri evaluate}
translate L FICSUnratedGames {Jocuri neevaluate}
translate L FICSRated {Evaluat}
translate L FICSUnrated {Neevaluat}
translate L FICSRegisteredPlayer {Doar jucător înregistrat}
translate L FICSFreePlayer {Doar jucător gratuit}
translate L FICSNetError {Eroare de rețea\Nu se poate conecta la}

# Game review
translate L GameReview {Revizuirea jocului}
translate L GameReviewTimeExtended {Timp prelungit}
translate L GameReviewMargin {Marja de eroare}
translate L GameReviewAutoContinue {Continuare automată când mutarea este corectă}
translate L GameReviewReCalculate {Utilizați timp prelungit}
translate L GameReviewAnalyzingMovePlayedDuringTheGame {Analizând mișcarea jucată în timpul jocului}
translate L GameReviewAnalyzingThePosition {Analizând poziţia}
translate L GameReviewEnterYourMove {Introduceți mutarea dvs}
translate L GameReviewCheckingYourMove {Îți verific mișcarea}
translate L GameReviewYourMoveWasAnalyzed {Mișcarea ta a fost analizată}
translate L GameReviewYouPlayedSameMove {Ai jucat aceeași mișcare ca în meci}
translate L GameReviewScoreOfYourMove {Scorul mișcării tale}
translate L GameReviewGameMoveScore {Scorul mutării jocului}
translate L GameReviewEngineScore {Scorul motorului}
translate L GameReviewYouPlayedLikeTheEngine {Ai jucat la fel de bine ca al motorului}
translate L GameReviewNotEngineMoveButGoodMove {Nu mișcarea motorului, dar este și o mișcare bună}
translate L GameReviewMoveNotGood {Această mișcare nu este bună, scorul este}
translate L GameReviewMovesPlayedLike {Mișcările jucate ca}
translate L GameReviewMovesPlayedEngine {Mișcările jucate ca un motor}

# Correspondence Chess Dialogs:
translate L CCDlgCGeneraloptions {Opțiuni generale}
translate L CCDlgLoginName  {Nume de conectare:}
translate L CCDlgPassword   {Parolă:}
translate L CCDlgShowPassword {Afișați parola}

# Connect Hardware dialogs
translate L ExtHWConfigConnection {Configurați hardware extern}
translate L ExtHWPort {Port}
translate L ExtHWEngineCmd {Comanda motorului}
translate L ExtHWEngineParam {Parametrul motorului}
translate L ExtHWShowButton {Afișează butonul}
translate L ExtHWHardware {Hardware}
translate L ExtHWNovag {Citrin Novag}
translate L ExtHWInputEngine {Motor de intrare}
translate L ExtHWNoBoard {Fara tabla}
translate L NovagReferee {Arbitru}

# Input Engine dialogs
translate L IEConsole {Consola motorului de intrare}
translate L IESending {Mișcări trimise pentru}
translate L IESynchronise {Sincroniza}
translate L IERotate  {Roti}
translate L IEUnableToStart {Imposibil de pornit Input Engine:}

# Calculation of Variations
translate L DoneWithPosition {Gata cu pozitia}

translate L Board {Bord}
translate L showGameInfo {Afișează informații despre joc}
translate L autoResizeBoard {Redimensionarea automată a plăcii}
translate L DockTop {Mutați sus}
translate L DockBottom {Mutați în jos}
translate L DockLeft {Deplasați la stânga}
translate L DockRight {Deplasați-vă la dreapta}
translate L Undock {Deconectați}

# Switcher window
translate L AboutDatabase {Despre această bază de date}
translate L ChangeIcon {Alege pictograma baza de date...}
translate L NewGameListWindow {Noua fereastră de listă de jocuri}
translate L LoadatStartup {Încărcați la pornire}

# Gamelist window
translate L ShowHideDB {Afișați/Ascundeți bazele de date}
translate L ChangeFilter {Schimbați filtrul}
translate L ChangeLayout {Încărcați/Salvați/Modificați criteriile de sortare și aspectul coloanei}
translate L ShowHideStatistic {Afișați/Ascundeți statisticile}
translate L BoardFilter {Afișați numai jocurile care se potrivesc cu poziția curentă pe tablă}
translate L CopyGameTo {Copiați jocul în}
translate L FindBar {Găsiți Bar}
translate L FindCurrentGame {Găsiți jocul curent}
translate L DeleteGame {Șterge jocul}
translate L UndeleteGame {Anulați ștergerea jocului}
translate L ResetSort {Resetează sortarea}

translate L ConvertNullMove {Convertiți mișcările nule în comentarii}
translate L SetupBoard {Placă de configurare}
translate L Rotate {Roti}
translate L SwitchColors {Schimbați culorile}
translate L FlipBoard {Flip Board}
translate L ImportPGN {Importați jocul PGN}
translate L ImportingFiles {Importul fișierelor PGN în}
translate L ImportingFrom {Import de la}
translate L ImportingIn {Importă jocuri în}
translate L UseLastTag {Folosiți etichetele ultimului\njoc}
translate L Random {Aleatoriu}
translate L BackToMainline {Reveniți la linia principală}
translate L LeaveVariant {Lasă varianta}
translate L Autoplay {Redare automată}
translate L ShowHideCoords {Afișare/Ascunde Coord.}
translate L ShowHideEvalBar {Afișați/Ascundeți bara de evaluare}
translate L ShowHideMaterial {Afișați/Ascundeți materialul}
translate L SelectMarker {Selectați Marker}
translate L FullScreen {Ecran complet}
translate L FilterStatistic {Filtru Statistici}
translate L MakeCorrections {Faceți corecții}
translate L Surnames {Nume de familie}
translate L Ambiguous {Ambiguu}

#Preferences Dialog
translate L OptionsToolbar "Bara de instrumente"
translate L OptionsBoard "Tablă de şah"
translate L OptionsBoardSize "Dimensiunea plăcii"
translate L OptionsBoardPieces "Stil Piesa"
translate L OptionsInternationalization "Internaționalizarea"
translate L OptionsTablebaseDir "Selectați până la 4 dosare de bază de tabel:"

# Evaluation bar
translate L BestMoveArrow "Cea mai bună săgeată de mișcare"
translate L NewLocalEngine "+ Motor nou..."
}
# end of english.tcl
