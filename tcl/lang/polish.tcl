### Polish menus for Scid.
# Contributed by Michal Rudolf and Adam Umiastowski.

proc setLanguage_P {} {

# File menu:
menuText P File "Plik" 0
menuText P FileNew "Nowy..." 0 {Twrz nowa baz Scid}
menuText P FileOpen "Otwrz..." 0 {Otwrz istniejc baz Scid}
menuText P FileClose "Zamknij" 0 {Zamknij aktywn baz Scid}
menuText P FileFinder "Poszukiwacz plikw" 0 {Otwrz okno poszukiwacza plikw}
menuText P FileBookmarks "Zakadki" 2 {Menu zakadek (klawisz: Ctrl+B)}
menuText P FileBookmarksAdd "Dodaj zakadk" 0 \
  {Dodaj zakadk do aktualnej bazy i pozycji}
menuText P FileBookmarksFile "Wstaw zakadk" 0 \
  {Wstaw do wybranego katalogu zakadk do aktualnej bazy i pozycji}
menuText P FileBookmarksEdit "Edycja zakadek..." 0 \
  {Edytuj menu zakadek}
menuText P FileBookmarksList "Wywietlaj katalogi jako list" 0 \
  {Wywietlaj katalogi zakadek jako list, nie jako zagniedone menu}
menuText P FileBookmarksSub "Wywietl katalogi jako menu" 0 \
  {Wywietlaj katalogi zakadek jako zagniedone menu, nie jako list}
menuText P FileMaint "Obsuga" 1 {Narzdzia obsugi bazy Scid}
menuText P FileMaintWin "Obsuga" 0 \
  {Otwrz/zamknij obsug bazy Scid}
menuText P FileMaintCompact "Porzdkuj baz..." 0 \
  {Porzdkuj baz, usuwajc skasowane partie i nieuywane nazwiska}
menuText P FileMaintClass "Klasyfikacja debiutowa partii..." 0 \
  {Przelicz klasyfikacj debiutowa wszystkich partii}
menuText P FileMaintSort "Sortuj baz..." 0 \
  {Sortuj wszystkie partie w bazie}
menuText P FileMaintDelete "Usu podwjne partie..." 0 \
  {Szukaj podwjnych partii i oznacz je do skasowania}
menuText P FileMaintTwin "Wyszukiwanie podwjnych partii" 0 \
  {Otwrz/uaktualnij wyszukiwanie podwjnych partii}
menuText P FileMaintName "Pisownia" 0 \
  {Edycja nazw/nazwisk i kontrola pisowni}
menuText P FileMaintNameEditor "Edytor nazwisk" 0 \
  {Otwrz/zamknij edytor nazwisk}
menuText P FileMaintNamePlayer "Sprawd pisowni nazwisk..." 17 \
  {Sprawd pisowni nazwisk przy pomocy pliku nazwisk}
menuText P FileMaintNameEvent "Sprawd pisowni nazw zawodw..." 22 \
  {Sprawd pisowni nazw zawodw przy pomocy pliku turniejw}
menuText P FileMaintNameSite "Sprawd pisowni nazw miejscowoci..." 22 \
  {Sprawd pisowni nazw miejscowoci przy pomocy pliku miejscowoci}
menuText P FileMaintNameRound "Sprawd numery rund..." 15 \
  {Sprawd numery rund przy pomocy pliku}
menuText P FileReadOnly "Tylko do odczytu..." 0 \
  {Zabezpiecz baz przed zapisem}
menuText P FileSwitch "Przecz baz" 1 \
  {Przecz na inn otwart baz} 
menuText P FileOpenLichessTournament "Otwarty Turniej Liszw" 0 {Pobieraj i otwieraj na ywo transmisje z turniejw Lichess}
menuText P FileImportLichess "Zaimportuj moj Lichess" 0 {Importuj gry ze swojego konta Lichess}
menuText P FileImportChessCom "Zaimportuj moj stron chess.com" 0 {Importuj partie ze swojego konta chess.com}
menuText P FileExit "Koniec" 0 {Zamknij Scida}
menuText P FileMaintFixBase "Napraw uszkodzon szkod" 0 {Uszkodzona szkoda}

# Edit menu:
menuText P Edit "Edytuj" 0
menuText P EditAdd "Dodaj wariant" 0 {Dodaj wariant do ruchu w partii}
menuText P EditDelete "Usu wariant" 0 {Usu wariant dla tego posunicia}
menuText P EditFirst "Twrz pierwszy wariant" 0 \
  {Przesu wariant na pierwsze miejsce na licie}
menuText P EditMain "Zmie wariant na tekst partii" 0 \
   {Zamie wariant i tekst partii}
menuText P EditTrial "Sprawd wariant" 0 \
  {Wcz/wycz tryb sprawdzania wariantw}
menuText P EditStrip "Usu" 2 \
  {Usu komentatarze i warianty}
menuText P EditUndo "Anulowa" 0 {Cofnij ostatni decyzj gry}
menuText P EditRedo "Przerobi" 0 {Powtrz ostatnie zakoczenie w grze}
menuText P EditStripComments "Komentarze" 0 \
  {Usu wszystkie komentarze z aktualnej partii}
menuText P EditStripVars "Warianty" 0 \
  {Usu wszystkie warianty z aktualnej partii}
menuText P EditStripBegin "Poprzednie posunicia" 0 \
  {Usu wszystkie posunicia do biecej pozycji}
menuText P EditStripEnd "Nastpne posunicia" 0 \
  {Usu wszystkie posunicia od biecej pozycji do koca partii}
menuText P EditReset "Oprnij schowek" 0 \
  {Oprnij schowek bazy}
menuText P EditCopy "Kopiuj parti do schowka" 0 \
  {Kopiuj parti do schowka}
menuText P EditPaste "Wklej aktywn parti ze schowka" 0 \
  {Wklej aktywn parti ze schowka}
menuText P EditPastePGN "Paste Clipboard text as PGN game..." 10 \
  {Interpret the clipboard text as a game in PGN notation and paste it here} ;# ***
menuText P EditSetup "Ustaw pozycj pocztkow..." 6 \
  {Ustaw pozycj pocztkow partii}
menuText P EditCopyBoard "Kopiuj pozycj" 7 \
  {Kopiuj aktualn pozycj w notacji FEN do schowka}
menuText P EditPasteBoard "Ustaw pozycj ze schowka" 3 \
  {Ustaw pozycj ze schowka}
menuText P ConfigureScid "Preferencje..." 0 {Skonfiguruj wszystkie opcje dla SCID}

# Game menu:
menuText P Game "Partia" 1
menuText P GameNew "Opu parti" 0 \
  {Opu parti, rezygnujc z wszelkich zmian}
menuText P GameFirst "Pierwsza partia" 2 {Wczytaj pierwsz parti z filtra}
menuText P GamePrev "Poka poprzedni parti" 0 \
  {Wczytaj poprzedni wyszukan parti}
menuText P GameReload "Przeaduj aktualn parti"  10 \
  {Wczytaj parti ponownie, rezygnujc z wszelkich zmian}
menuText P GameNext "Nastpna partia" 0 \
  {Wczytaj nastpn wyszukan parti}
menuText P GameLast "Ostatnia partia" 5 {Wczytaj ostatni parti z filtra}
menuText P GameRandom "Losowa partia z filtra" 8 {Wczytaj losow parti z filtra}
menuText P GameNumber "Wczytaj parti numer..." 17 \
  {Wczytaj parti wprowadzajc jej numer}
menuText P GameReplace "Zapisz: zastp parti..." 3 \
  {Zapisz parti, zastp poprzedni wersj}
menuText P GameAdd "Zapisz: dodaj now parti..." 8 \
  {Zapisz t parti jako nowa parti w bazie}
menuText P GameDelete "Usuń grę" 0 {Przełącz opcję usunięcia flagi bieżącej gry}
menuText P GameDeepest "Rozpoznaj debiut" 0 \
  {Przejd do najduszego wariantu z ksiki debiutowej}
menuText P GameGotoMove "Przejd do posunicia nr..." 13 \
  {Przejd do posunicia o podanym numerze}
menuText P GameNovelty "Znajd nowink..." 7 \
  {Znajd pierwsze posunicie partii niegrane wczeniej}
menuText P PlayTournament "Zagraj w turnieju..." 0 \
    {Zagraj w turnieju silnikowym}

# Search Menu:
menuText P Search "Szukaj" 0
menuText P SearchReset "Resetuj filtr" 0 \
  {Wstaw wszystkie partie do filtra}
menuText P SearchNegate "Odwr filtr" 0 \
  {Zamie partie w filtrze i poza nim}
menuText P SearchCurrent "Aktualna pozycja..." 0 \
  {Szukaj aktualnej pozycji}
menuText P SearchHeader "Nagwek..." 0 \
  {Szukaj informacji o nagwkach (nazwiska, nazwy turnieju itp.)}
menuText P SearchMaterial "Materia/wzorzec..." 0 \
  {Szukaj wedug materiau lub wzorca}
menuText P SearchUsing "Stosuj plik poszukiwania..." 0 \
  {Szukaj stosujc plik z opcjami poszukiwania}

# Windows menu:
menuText P Windows "Okna" 1
menuText P WindowsComment "Edytor komentarzy" 0 \
  {Otwrz/zamknij edytor komentarzy}
menuText P WindowsGList "Lista partii" 0 {Otwrz/zamknij list partii}
menuText P WindowsPGN "Okno PGN" 0 {Otwrz/zamknij (zapis partii) PGN }
menuText P WindowsPList "Zawodnicy" 2 {Otwrz/zamknij przegldark zawodnikw}
menuText P WindowsTmt "Turnieje" 0 {Otwrz/zamknij przegldark turniejw}
menuText P WindowsSwitcher "Przecznik baz" 12 \
  {Otwrz/zamknij przecznik baz}
menuText P WindowsMaint "Zarzdzanie baz" 0 \
  {Otwrz/zamknij okno zarzdzania baz}
menuText P WindowsECO "Przegldarka kodw debiutowych" 0 \
  {Otwrz/zamknij przegldark kodw debiutowych}
menuText P WindowsStats "Statystyka" 0 \
  {Otwrz/zamknij statystyk}
menuText P WindowsTree "Drzewo wariantw" 0 {Otwrz/zamknij drzewo wariantw}
menuText P WindowsBook "Okno ksiki" 0 {Otwrz/zamknij Ksika okno}
menuText P WindowsCorrChess "Okno korespondencyjne" 0 {Otwrz/zamknij okno Korespondencja}
menuText P WindowsGraph "Analiza wykresu" 0 {Otwrz okno Chart z czasowego dziaania i oceny}

# Tools menu:
menuText P Tools "Narzdzia" 0
menuText P ToolsConfigureEngines "Skonfiguruj silniki" 10 {Zarzdzaj konfiguracj poredni}
menuText P ToolsAnalysis "Program analizujcy..." 8 \
  {Uruchom/zatrzymaj program analizujcy}
menuText P ToolsAnalysis2 "Program analizujcy 2..." 21 \
  {Uruchom/zatrzymaj program analizujcy}
menuText P ToolsCross "Tabela turniejowa" 0 \
  {Poka tabel turniejow dla aktualnej partii}
menuText P ToolsFilterGraph "Wykres filtra" 7 \
  {Otwrz/zamknij wykres filtra}
menuText P ToolsAbsFilterGraph "Abs. Filtr wykresu" 7 {Otwrz/zamknij okno wykresu filtru dla wartoci bezwzgldnych}
menuText P ToolsOpReport "Raport debiutowy" 0 \
  {Utwrz raport debiutowy dla aktualnej pozycji}
menuText P ToolsOpenBaseAsTree "Otwrz metod jako drzewo" 0   {Otwrz dalej i jej dalsze w oknie Drzewa}
menuText P ToolsOpenRecentBaseAsTree "Otwrz ostatnie rozwizanie jako drzewo" 0   {Otwrz pozostae i jej dalsze w oknie Drzewa}
menuText P ToolsTracker "ledzenie figur"  10 {Otwrz/zamknij okno ledzenia figur} 
menuText P ToolsTraining "Szkolenie"  0 {Narzdzia szkoleniowe (taktyka, debiuty,...)}
menuText P ToolsTacticalGame "Gra taktyczna"  0 {Zagraj w gr z taktyk}
menuText P ToolsSeriousGame "Powana gra"  0 {Zagraj w grze}
menuText P ToolsTrainOpenings "Otwory"  0 {Trenuj z repertuarem}
menuText P ToolsTrainReviewGame "Recenzja gry"  0 {Zgadnij odbywajce si w grze}
menuText P ToolsTrainTactics "Taktyka"  0 {Rozwi taktyk}
menuText P ToolsTrainCalvar "Obliczanie zmiany"  0 {Obliczanie zmian w treningu}
menuText P ToolsTrainFindBestMove "znajd najlepszy ruch"  0 {znajd najlepszy ruch}
menuText P ToolsTrainFics "Graj w internecie"  0 {Graj na freechess.org}
menuText P ToolsEngineTournament "Turniej silnikowy"  0 {Rozpocznij zawody pomidzy silnikami szachowymi}
menuText P ToolsTimeAnalysis "Analiza czasu" 0 {Poka wykres czasu zegarowego dla biecej gry}
menuText P ToolsBookTuning "Strojenie ksiki" 0 {Strojenie ksiki}
menuText P ToolsDownloadTWIC "Pobierz gry TWIC" 0 {Pobierz najnowsze partie The Week In Chess (TWIC).}
menuText P ToolsConnectHardware "Podcz sprzt" 0 {Podcz sprzt zewntrzny}
menuText P ToolsConnectHardwareConfigure "Skonfiguruj..." 0 {Skonfiguruj sprzt zewntrzny i poczenie}
menuText P ToolsConnectHardwareNovagCitrineConnect "Pocz Novag Cytryn" 0 {Pocz Novag Cytryn}
menuText P ToolsConnectHardwareInputEngineConnect "Podcz zasilanie" 0 {Podczenie zasilania (np. DGT)}

menuText P ToolsPInfo "Informacje o zawodniku"  0 \
  {Otwrz/odwie okno informacji o zawodniku}
menuText P ToolsPlayerReport "Raport o graczu..." 9 \
  {Utwrz raport o graczu} 
menuText P ToolsRating "Wykres rankingu" 0 \
  {Wykres historii rankingu grajcych parti}
menuText P ToolsExpCurrent "Eksportuj parti" 0 \
  {Zapisz parti do pliku tekstowego}
menuText P ToolsExpCurrentPGN "Do pliku PGN..." 9 \
  {Zapisz parti do pliku PGN}
menuText P ToolsExpCurrentHTML "Do pliku HTML..." 9 \
  {Zapisz parti do pliku HTML}
menuText P ToolsExpCurrentHTMLJS "Eksportuj gr do pliku HTML i JavaScript..." 15 {Zapisz gr do pliku HTML i JavaScript}  
menuText P ToolsExpFilter "Eksportuj wyszukane partie" 1 \
  {Zapisz wyszukane partie do pliku tekstowego}
menuText P ToolsExpFilterPGN "Do pliku PGN..." 9 \
  {Zapisz wyszukane partie do pliku PGN}
menuText P ToolsExpFilterHTML "Do pliku HTML..." 9 \
  {Zapisz wyszukane partie do pliku HTML}
menuText P ToolsExpFilterHTMLJS "Eksportuj filtr do pliku HTML i JavaScript..." 17 {Zapisz wszystkie przefiltrowane gry w pliku HTML i JavaScript}  
menuText P ToolsImportOne "Wklej parti w formacie PGN..." 0 \
  {Pobierz parti z pliku PGN}
menuText P ToolsImportFile "Importuj plik PGN..." 2 \
  {Pobierz partie z pliku PGN}
menuText P ToolsStartEngine1 "Uruchomiony silnik 1" 0  {Uruchomiony silnik 1}
menuText P ToolsStartEngine2 "Uruchomiony silnik 2" 0  {Uruchomiony silnik 2}
menuText P ToolsCaptureBoard "Przechwy biec tablic..." 0  {Zapis biecej tablicy jako obrazu.}

# Play menu
menuText P Play "Gra" 0
menuText P LichessPuzzles "Łamigłówki Lichess" 0 {Rozwiązuj interaktywne zagadki Lichess}

# --- Correspondence Chess
menuText P CCResign "Rezygnowa" 0 {Zrezygnuj (nie przez e-mail)}
menuText P CCClaimDraw "Zgoszenie losowania" 0 {Wylij ruch i postpuj si o losowanie (nie przez e-mail)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText P Options "Opcje" 0
menuText P OptionsBoardGraphics "Kwadraty..." 0 {Wybierz tekstury dla kwadratw}
translate P OptionsBGW {Wybierz tekstur kwadratw}
translate P OptionsBoardGraphicsText {Wybierz dokumenty graficzne dla biaych i czarnych kwadratw:}
menuText P OptionsBoardNames "Moje nazwiska" 0 {Modyfikuj list moich graczy}
menuText P OptionsExport "Eksport" 0 {Zmie opcje eksportu tekstu}
menuText P OptionsFonts "Czcionka" 0 {Zmie font}
menuText P OptionsFontsRegular "Podstawowa" 0 {Zmie podstawow czcionk}
menuText P OptionsFontsMenu "Menu" 0 {Zmie czcionk menu} 
menuText P OptionsFontsSmall "Maa" 0 {Zmie ma czcionk}
menuText P OptionsFontsTiny "Malutki" 0 {Zmie ma czcionk}
menuText P OptionsFontsFixed "Staa" 0 {Zmie czcionk staej szerokoci}
menuText P OptionsGInfo "Informacje o partii" 0 {Sposb wywietlania informacji o partii}
menuText P OptionsLanguage "Jzyk" 0 {Wybierz jzyk}
menuText P OptionsMovesTranslatePieces "Przetumacz kawaki" 0 {Przetumacz pierwsz liter kawakw}
menuText P OptionsMovesHighlightLastMove "Podkrel ostatni ruch" 0 {Podkrel ostatni ruch}
menuText P OptionsMovesHighlightLastMoveDisplay "Poka kwadrat" 0 {Wywietlanie ostatniego ruchu Podwietlenie}
menuText P OptionsMovesHighlightLastMoveWidth "Szeroko" 0 {Grubo linii}
menuText P OptionsMovesHighlightLastMoveColor "Kolor" 0 {Kolor linii}
menuText P OptionsMovesHighlightLastMoveArrow "Poka strzak" 0 {Poka strzak z podwietleniem}
menuText P OptionsMovesHighlightLastMoveNag "Poka symbole adnotacji" 0
menuText P OptionsMovesHighlightLastMoveEval "Poka symbole oceny" 0
menuText P OptionsMoves "Posunicia" 0 {Wprowadzanie posuni}
menuText P OptionsMovesAnimate "Szybko animacji" 1 \
  {Ustaw czas przeznaczony na animacj jednego posunicia} 
menuText P OptionsMovesDelay "Automatyczne przegldanie..." 0 \
  {Ustaw opnienie przy automatycznym przegldaniu partii}
menuText P OptionsMovesCoord "Posunicia w formacie \"g1f3\"" 0 \
  {Akceptuj posunicia wprowadzone w formacie "g1f3"}
menuText P OptionsMovesSuggest "Poka proponowane posunicia" 1 \
  {Wcz/wycz proponowanie posuni}
menuText P OptionsShowVarPopup "Poka okno odmiany" 0 {Wcz/wycz wywietlanie rnych opcji okien}  
menuText P OptionsMovesSpace "Dodaj spacje po numerze ruchu" 0 {Dodaj spacje po numerze ruchu}  
menuText P OptionsMovesLichess "Format Lichess/ChessBase dla adnotacji" 0 {Uyj formatu Lichess/ChessBase dla kwadratowych znacznikw i strzaek}
menuText P OptionsMovesKey "Automatyczne dopenianie posuni" 1 \
  {Wcz/wycz automatyczne dopenianie posuni wprowadzanych z klawiatury}
menuText P OptionsMovesShowVarArrows "Poka strzaki dla odmiany" 0 {Wcz/wycz napd elektryczny w odmianach}
menuText P OptionsMovesShowEngineVariationArrows "Poka strzaki dla wersji silnika" 0 {Wcz/wycz strzaki pokazujce linie zmian silnika w trybie multiPV}
menuText P OptionsMovesGlossOfDanger "Kolorowy rozwizanie zagroenia" 0 {Wcz/wycz oznaczony kolorami poysku}
translate P OptionsMovesTreeDepth {Domylna gboko przesuwania okna drzewa}
menuText P OptionsNumbers "Format zapisu liczb" 0 {Wybierz format zapisu liczb}
menuText P OptionsTheme "Temat" 0 {Zmie wygld interfejsu}
menuText P OptionsWindows "Okna" 0 {Opcje okien}
menuText P OptionsSounds "Sounds" 2 {Configure move announcement sounds} ;# ***
menuText P OptionsResources "Zasoby..." 0 {Wybierz pliki zasobw i folderw}
menuText P OptionsWindowsDock "Zadokuj okna" 0 {Zadokuj okna}
menuText P OptionsWindowsSaveLayout "Zapisz ukad" 0 {Zapisz ukad}
menuText P OptionsWindowsRestoreLayout "Przywr ukad" 0 {Przywr ukad}
menuText P OptionsWindowsShowGameInfo "Poka informacje o grze" 0 {Poka informacje o grze}
menuText P OptionsWindowsAutoLoadLayout "Automatyczne adowanie pierwszego ukadu" 0 {Automatyczne adowanie wstpne konfiguracji przy uruchomieniu}
menuText P OptionsECO "Wczytaj ksik debiutow" 16 \
  {Wczytaj plik z klasyfikacja debiutw}
menuText P OptionsSpell "Wczytaj plik sprawdzania pisowni..." 13 \
  {Wczytaj plik do sprawdzania pisowni nazwisk i nazw}
menuText P OptionsTable "Katalog z baz kocwek" 10 \
  {Wybierz baz kocwek; uyte zostan wszystkie bazy z tego katalogu}
menuText P OptionsRecent "Ostatnie pliki..." 0 \
  {Zmie liczb ostatnio otwartych plikw, wywietlanych w menu Plik} 
menuText P OptionsBooksDir "Katalog ksiek" 0 {Ustawia katalogw ksiek otwierajcych}
menuText P OptionsTacticsBasesDir "Baza katalogw" 0 {Ustawia katalogw baz taktycznych (szkoleniowych).}
menuText P OptionsPhotosDir "Katalog zdj" 0 {Ustawia katalog baz zdj}
menuText P OptionsThemeDir "Plik plikw"  0 {Zaaduj plik motywu GUI}
menuText P OptionsSave "Zapamitaj opcje" 0 \
  "Zapamitaj wszystkie ustawienia w pliku $::optionsFile"
menuText P OptionsAutoSave "Automatycznie zapisuj opcje" 0 \
  {Automatycznie zapisz opcje przy zamykaniu programu}

# Help menu:
menuText P Help "Pomoc" 2
menuText P HelpContents "Contents" 0 {Poka spis treci pomocy} 
menuText P HelpIndex "Spis treci" 0 {Poka indeks pomocy}
menuText P HelpGuide "Krtki przewodnik" 0 {Poka krtki przewodnik}
menuText P HelpHints "Podpowiedzi" 0 {Poka podpowiedzi}
menuText P HelpContact "Informacja o autorze" 0 \
  {Poka informacj o autorze i stronie Scid-a}
menuText P HelpTip "Porada dnia" 0 {Poka porad Scida}
menuText P HelpStartup "Okno powitalne" 2 {Pokazuj okno startowe}
menuText P HelpAbout "O programie" 0 {Informacje o programie Scid}

# Toolbar tooltips:
menuText P RotateBoard "Obr plansz" 0 {Obr plansz}

# Game info box popup menu:
menuText P GInfoHideNext "Ukryj nastpne posunicie" 0
menuText P GInfoMaterial "Poka materia" 0
menuText P GInfoFEN "Poka pozycj w formacie FEN" 16
menuText P GInfoMarks "Pokazuj kolorowe pola i strzaki" 5 
menuText P GInfoWrap "Zawijaj dugie linie" 0
menuText P GInfoFullComment "Poka cay komentarz" 6
menuText P GInfoPhotos "Poka zdjcia" 5
menuText P GInfoTBNothing "Tablica kocwek: nic" 0
menuText P GInfoTBResult "Tablica kocwek: tylko wynik" 18
menuText P GInfoTBAll "Tablica kocwek: wszystko" 18
menuText P GInfoDelete "Usu/przywr t parti" 0
menuText P GInfoMark "Wcz/wycz zaznaczenie tej partii" 0
menuText P GInfoInformant "Skonfiguruj wartoci informatora" 0

# General buttons:
translate P LichessOpenExplore {Lichess OpenExplore}
translate P LichessTitle {Eksplorator otwarcia Lichess}
translate P LichessApiTokenReq {Token API Lichess (wymagany):}
translate P LichessDatabase {Baza danych:}
translate P LichessMasters {Mistrzowie}
translate P LichessGames {Lichess Games}
translate P LichessPlayer {Odtwarzacz}
translate P LichessNumMoves {Liczba ruchów:}
translate P LichessTopGames {Najlepsze gry:}
translate P LichessRecentGames {Ostatnie gry:}
translate P LichessSinceYear {Od roku:}
translate P LichessUntilYear {Do roku:}
translate P LichessSinceMonth {Od (RRRR-MM):}
translate P LichessUntilMonth {Do (RRRR-MM):}
translate P LichessTimeControls {Kontrola czasu}
translate P LichessRatingGroups {Grupy ocen}
translate P LichessPlayerName {Nazwa użytkownika gracza:}
translate P LichessPlayerColor {Kolor gracza:}
translate P LichessWhite {Biały}
translate P LichessBlack {Czarny}
translate P LichessGameModes {Tryby gry}
translate P LichessRated {Oceniono}
translate P LichessCasual {Zwykły}
translate P LichessTokenRequired {Wymagany jest token API Lichess.\n\nOd marca 2026 r. Lichess wymaga tokenu API, aby uzyskać dostęp do Eksploratora otwierania. Wprowadź swój token w polu „Token API Lichess” powyżej.\n\nToken możesz utworzyć na stronie: https://lichess.org/account/oauth/token}
translate P LichessPlayerRequired {Proszę wprowadzić nazwę użytkownika Lichess do bazy danych Graczy.}
translate P LichessQuerying {Wysyłanie zapytania do Eksploratora otwierania Lichess...}
translate P LichessFailedQuery {Nie udało się wysłać zapytania do Eksploratora otwarcia Lichess:\n%s}
translate P LichessPositionNotFound {Nie znaleziono pozycji w bazie danych %s.\n\nAPI zwróciło:\n%s}
translate P LichessResultsTitle {Eksplorator otwierania Lichess - baza danych %s}
translate P LichessSummaryInfo {Razem: %s gier |  Białe wygrywają: %s (%s%%) |  Losowania: %s (%s%%) |  Czarne wygrywają: %s (%s%%)}
translate P LichessNoGamesFound {Nie znaleziono gier dla tej pozycji.}
translate P LichessMoves {Ruchy:}
translate P LichessColMove {Przenosić}
translate P LichessColWhite {Biały}
translate P LichessColDraws {Rysuje}
translate P LichessColBlack {Czarny}
translate P LichessColTotal {Całkowity}
translate P LichessColWinPct {Wygrać%}
translate P LichessColAvgRating {Średnia ocena}
translate P LichessColECO {EKO}
translate P LichessColOpening {Otwór}
translate P LichessTopGamesTitle {Najlepsze gry:}
translate P LichessRecentGamesTitle {Ostatnie gry:}
translate P LichessColWinner {Zwycięzca}
translate P LichessColWhiteRating {Ocena W}
translate P LichessColBlackRating {B. Ocena}
translate P LichessColDate {Data}
translate P LichessLoadGameConfirm {Załadować grę %s vs %s (ID: %s) do bazy klipów?}
translate P LichessLoadGameTitle {Załaduj grę}
translate P LichessFetchGameFailed {Nie udało się pobrać gry %s:\n%s}
translate P LichessGameNotFound {Nie znaleziono gry %s na Lichess.}
translate P LichessImportFailed {Nie udało się zaimportować gry:\n%s}
translate P LichessGameLoaded {Gra została pomyślnie załadowana do Clipbase.}

# Lichess Puzzles
translate P LichessPuzzlesTitle {Łamigłówki Lichess}
translate P LichessPuzzlesDailyTitle {Codzienna łamigłówka}
translate P LichessPuzzlesQuerying {Odpytywanie zagadek Lichess...}
translate P LichessPuzzlesFailed {Nie udało się zapytać o łamigłówki Lichess:\n%s}
translate P LichessPuzzlesParseError {Nie udało się przeanalizować danych puzzli}
translate P LichessPuzzlesLoadError {Nie udało się załadować pozycji układanki}
translate P LichessPuzzlesSolve {Twoja kolej! Znajdź najlepszy ruch.}
translate P LichessPuzzlesCorrect {Dobry ruch!}
translate P LichessPuzzlesWrong {To nie jest ten ruch — spróbuj czegoś innego.}
translate P LichessPuzzlesBestMove {Najlepszy ruch!  Kontynuować...}
translate P LichessPuzzlesSolved {Zagadka rozwiązana! Gratulacje!}
translate P LichessPuzzlesPlaying {Rozwiązywanie zagadek...}
translate P LichessPuzzlesStop {Zatrzymywać się}
translate P LichessPuzzlesNew {Nowa łamigłówka}
translate P LichessPuzzlesHint {Uzyskaj wskazówkę}
translate P LichessPuzzlesViewSolution {Zobacz rozwiązanie}
translate P LichessPuzzlesHintMsg {Spójrz na kawałek na %s.}
translate P LichessPuzzlesSolutionMsg {Rozwiązanie:\n%s}
translate P LichessPuzzlesDifficulty {Trudność:}
translate P LichessPuzzlesDiffEasiest {Najłatwiej}
translate P LichessPuzzlesDiffEasiestThenNormal {Najłatwiej, potem normalnie}
translate P LichessPuzzlesDiffNormal {Normalna}
translate P LichessPuzzlesDiffNormalThenHardest {Normalne, potem najtrudniejsze}
translate P LichessPuzzlesDiffHardest {Najtrudniejsze}
translate P LichessPuzzlesColor {Graj jako:}
translate P LichessPuzzlesNextColor {Następny kolor puzzli:}
translate P LichessPuzzlesSideToMove {Strona do poruszania się}
translate P LichessPuzzlesSolvedTitle {Zagadka rozwiązana!}
translate P LichessPuzzlesTheme {Temat:}
translate P LichessPuzzlesMix {Zdrowa mieszanka}
translate P LichessPuzzlesId {Identyfikator puzzli}
translate P LichessPuzzlesPlays {Rozgrywki}
translate P LichessPuzzlesThemes {Motywy}
translate P LichessPuzzlesPerf {Typ}
translate P LichessPuzzlesClock {Zegar}
translate P LichessPuzzlesRated {Oceniono}
translate P LichessPuzzlesGame {Gra}
translate P LichessPuzzlesNoNew {Nie znaleziono nowych łamigłówek dla tych ustawień.\n\nSpróbuj zmienić motyw, poziom trudności lub kolor łamigłówki.}

translate P Back {Z powrotem}
translate P Apply {Stosować}
translate P Browse {Przegldaj}
translate P Cancel {Anuluj}
translate P Continue {Kontynuowa}
translate P Clear {Wyczy}
translate P Close {Zamknij}
translate P Contents {Spis treci}
translate P Defaults {Domylne}
translate P InvertSearch {Odwr wyszukiwanie}
translate P Delete {Usu}
translate P Graph {Wykres}
translate P Help {Pomoc}
translate P Hide {Ukrywa}
translate P Import {Pobierz}
translate P Index {Indeks}
translate P LoadGame {Wczytaj parti}
translate P PgnOpenInViewer {Otwórz w przeglądarce PGN}
translate P MergeGame {Docz parti}
translate P MergeGames {Wcz gr}
translate P Preview {Podgld}
translate P Revert {Odwr}
translate P Rename {Przemianować}
translate P Save {Zapisz}
translate P Search {Szukaj}
translate P Stop {Stop}
translate P Store {Zapamitaj}
translate P Update {Uaktualnij}
translate P ChangeOrient {Zmie pooenie okna}
translate P ShowIcons {Show Icons} ;# ***
translate P None {Brak}
translate P First {Pierwsza}
translate P Current {Aktualn}
translate P Last {Ostatni}

# General messages:
translate P game {partia}
translate P games {partie}
translate P move {posunicie}
translate P moves {pos.}
translate P all {wszystkie}
translate P Yes {Tak}
translate P No {Nie}
translate P Both {Oba}
translate P King {Krl}
translate P Queen {Hetman}
translate P Rook {Wiea}
translate P Bishop {Goniec}
translate P Knight {Skoczek}
translate P Pawn {Pion}
translate P White {Biae}
translate P Black {Czarne}
translate P Player {Gracz}
translate P Rating {Ranking}
translate P RatingDiff {Rnica rankingw}
translate P AverageRating {redni ranking}
translate P Event {Turniej}
translate P Site {Miejsce}
translate P Country {Kraj}
translate P IgnoreColors {Ignoruj kolory}
translate P Date {Data}
translate P EventDate {Turniej data}
translate P Decade {Dekada} 
translate P Year {Rok}
translate P Month {Miesic}
translate P Months {Stycze Luty Marzec Kwiecie Maj Czerwiec Lipiec Sierpie Wrzesie Padziernik Listopad Grudzie}
translate P Days {N Pn Wt r Cz Pt So}
translate P YearToToday {Ostatni rok}
translate P YearToTodayTooltip {Ustaw dat od 1 roku wstecz do dzisiaj}
translate P Result {Wynik}
translate P Round {Runda}
translate P Length {Dugo}
translate P ECOCode {Kod ECO}
translate P ECO {ECO}
translate P Deleted {Usunita}
translate P SearchResults {Wyniki wyszukiwania}
translate P OpeningTheDatabase "Otwieranie bazy"
translate P Database {Bazy}
translate P Filter {Filtr}
translate P noGames {brak partii}
translate P allGames {wszystkie partie}
translate P empty {brak}
translate P clipbase {schowek}
translate P score {punkty}
translate P StartPos {Pozycja pocztkowa}
translate P Total {Razem}
translate P readonly {tylko do odczytu}

# Standard error messages:
translate P ErrNotOpen {To nie jest otwarta baza.} 
translate P ErrReadOnly {Ta baza jest tylko do odczytu; nie mona jej zmieni.}
translate P ErrSearchInterrupted {Wyszukiwanie zostao przerwane. Wyniki bd niepene.}
translate P ErrNoClockComments {W tej grze nie znaleziono komentarzy do zegara [%clk].    Dodaj czasy zegara za pomoc okna komentarzy (Ctrl+E), aby skorzysta z tej funkcji.}
translate P ErrFileInUse {Bd: plik jest ju uywany. Zamknij kad inn aplikacj korzystajc z tej bazy danych. Jeli program zosta nieoczekiwanie zamknity, moe by konieczne usunicie pliku .lock powizanego z baz danych.}




# Game information:
translate P twin {powtrzona}
translate P deleted {usunita}
translate P comment {komentarz}
translate P hidden {ukryte}
translate P LastMove {Poprzednie}
translate P NextMove {nastpne}
translate P GameStart {Pocztek partii}
translate P LineStart {Pocztek wariantu}
translate P GameEnd {Koniec partii}
translate P LineEnd {Koniec wariantu}

# Player information:
translate P PInfoAll {Wyniki - <b>wszystkie</b> partie}
translate P PInfoFilter {Wyniki - partie z <b>filtra</b>}
translate P PInfoAgainst {Wyniki - }
translate P PInfoMostWhite {Najczstsze debiuty biaymi}
translate P PInfoMostBlack {Najczstsze debiuty czarnymi}
translate P PInfoRating {Historia rankingu}
translate P PInfoBio {Biografia}
translate P PInfoEditRatings {Modyfikuj rankingi} 
translate P PInfoEloFile {Plik}

# Tablebase information:
translate P Draw {remis}
translate P with {po}
translate P only {tylko}
translate P lose {przegrywaj}
translate P loses {przegrywa}

# Tip of the day:
translate P Tip {Porada}
translate P TipAtStartup {Poka porad przy starcie}
translate P TipConvertPGN {Moesz uzyska produkt, konwertujc pliki PGN}

# Tree window menus:
menuText P TreeFile "Plik" 0
menuText P TreeFileFillWithBase "Wypenij pami podrczn baz" 0 {Wypenij plik pamici podrcznej, ktry dziaa grami w codziennej praktyce}
menuText P TreeFileFillWithGame "Wypenij pami podrczn gr" 0 {Wypenij plik pamici podrcznej biecej gry w regularnej grze}
menuText P TreeFileSetCacheSize "Rozmiar pamici podrcznej" 0 {Ustaw rozmiar pamici podrcznej}
menuText P TreeFileCacheInfo "Informacje o pamici podrcznej" 0 {Uzyskaj informacje o pamici podrcznej}
menuText P TreeFileSave "Zapisz bufor" 7 {Zapisz plik bufora (.stc)}
menuText P TreeFileFill "Twrz standardowy plik cache" 0 {Wstaw typowe pozycje debiutowe do bufora}
menuText P TreeFileBest "Najlepsze partie" 0 {Poka list najlepszych partii}
menuText P TreeFileGraph "Poka wykres" 0 {Poka wykres dla tej gazi drzewa}
menuText P TreeFileCopy "Kopiuj drzewo do schowka" 0 \
  {Skopiuj drzewo ze statystykami do schowka}
menuText P TreeFileClose "Zamknij" 0 {Zamknij okno drzewa}
menuText P TreeMask "Maska" 0
menuText P TreeMaskNew "Nowy" 0 {Nowa maska}
menuText P TreeMaskOpen "Otwrz" 0 {Otwrz mask}
menuText P TreeMaskOpenRecent "Otwrz ostatnio" 0 {Otwrz ostatni mask}
menuText P TreeMaskSave "Ratowa" 0 {Zapisz mask}
menuText P TreeMaskClose "Zamkn" 0 {Zamknij mask}
menuText P TreeMaskFillWithGame "Wypenij gr" 0 {Wypenij mask gry}
menuText P TreeMaskFillWithBase "Wypenij baz" 0 {Wypenij mask suplementami grami w cieczy}
menuText P TreeMaskInfo "Informacje" 0 {Poka statystyki dla masek biecych}
menuText P TreeMaskDisplay "Wywietl map maski" 0 {Poka dane maski w formie drzewa}
menuText P TreeMaskSearch "Szukaj" 0 {Szukaj w biecej masce}
menuText P TreeSort "Sortowanie" 0
menuText P TreeSortAlpha "Alfabetycznie" 0
menuText P TreeSortECO "Kod ECO" 0
menuText P TreeSortFreq "Czsto" 0
menuText P TreeSortScore "Punkty" 0
menuText P TreeOpt "Opcje" 0
menuText P TreeOptSlowmode "tryb powolny" 0 {Tryb powolnego aktualizacji (wysoka dodatkowa)}
menuText P TreeOptFastmode "Tryb szybki" 0 {Szybki tryb aktualizacji (bez transpozycji ruchu)}
menuText P TreeOptFastAndSlowmode "Tryb szybki i wolny" 0 {Tryb szybki, nastpnie tryb wolny w celu aktualizacji}
menuText P TreeOptStartStop "Automatyczne odwieanie" 0 {Wcza si automatycznie odwieanie okna}
menuText P TreeOptLock "Blokada" 0 {Zablokuj/odblokuj drzewo na aktualnej bazie}
menuText P TreeOptTraining "Trening" 0 {Wcz/wycz tryb treningowy}
menuText P TreeOptDepth "Przesu gboko" 0 {Liczba powek ruchw do wywietlenia w drzewie (1-4)}
menuText P TreeOptAutosave "Automatyczny zapis bufora" 0 \
  {Automatycznie zapisz plik bufora przy wyjciu}
menuText P TreeHelp "Pomoc" 2
menuText P TreeHelpTree "Drzewo" 0
menuText P TreeHelpIndex "Spis treci" 0
translate P SaveCache {Zapisz bufor}
translate P Training {Trening}
translate P LockTree {Blokada}
translate P TreeDepth {Gboko drzewa (poowa ruchw):}
translate P TreeLocked {zablokowane}
translate P TreeBest {Najlepsze}
translate P TreeBestGames {Najlepsze partie}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate P TreeTitleRow \
{Pos.                          ECO       Czsto     Wynik  Rav   Rperf Rok   %Remis   %Wygra}
translate P TreeTotal {RAZEM}
translate P DoYouWantToSaveFirst {Czy najpierw chcesz si zapisa?}
translate P AddToMask {Dodaj do maski}
translate P RemoveFromMask {Usu z maski}
translate P AddThisMoveToMask {Dodaj dziesi ruchu do Maski}
translate P SearchMask {Szukaj w masie}
translate P DisplayMask {Wywietl mask}
translate P Nag {Kod Naga}
translate P Marker {Znacznik}
translate P Include {Wcz}
translate P Exclude {Wykluczy}
translate P MainLine {Magistrala}
translate P Bookmark {Zakadka w ksice}
translate P NewLine {Nowa linia}
translate P ToBeVerified {Sprawd}
translate P ToTrain {Trenowa}
translate P Dubious {Wtpliwy}
translate P ToRemove {Aby usun}
translate P NoMarker {Brak znacznika}
translate P ColorMarker {Kolor}
translate P WhiteMark {Biay}
translate P GreenMark {Zielony}
translate P YellowMark {ty}
translate P BlueMark {Niebieski}
translate P RedMark {Czerwony}
translate P CommentMove {Komentarz ruchu}
translate P CommentPosition {Stanowisko komentarza}
translate P AddMoveToMaskFirst {Najpierw dodaj ruch do maski}
translate P OpenAMaskFileFirst {Najpierw otwrz plik maski}
translate P Positions {Pozycja}
translate P Moves {Porusza si}

# Finder window:
menuText P FinderFile "Plik" 0
menuText P FinderFileSubdirs "Przeszukuj podkatalogi" 0
menuText P FinderFileClose "Zamknij wyszukiwacza plikw" 0
menuText P FinderSort "Sortowanie" 0
menuText P FinderSortType "Typ" 0
menuText P FinderSortSize "Rozmiar" 0
menuText P FinderSortMod "Zmieniony" 0
menuText P FinderSortName "Nazwa" 0
menuText P FinderSortPath "cieka" 0
menuText P FinderTypes "Typy" 0
menuText P FinderTypesScid "Bazy Scid-a" 0
menuText P FinderTypesOld "Bazy Scid-a (stary format)" 1
menuText P FinderTypesPGN "Pliki PGN" 0
menuText P FinderTypesEPD "Ksiki debiutowe EPD" 0
menuText P FinderTypesRep "Pliki repertuaru debiutowego" 0
menuText P FinderHelp "Pomoc" 2
menuText P FinderHelpFinder "Pomoc poszukiwacza plikw" 1
menuText P FinderHelpIndex "Spis treci" 0
translate P FileFinder {Poszukiwacz plikw}
translate P FinderDir {Katalog}
translate P FinderDirs {Katalogi}
translate P FinderFiles {Pliki}
translate P FinderUpDir {wyej}
translate P FinderCtxOpen {Otwrz}
translate P FinderCtxBackup {Kopia zapasowa}
translate P FinderCtxCopy {Kopia}
translate P FinderCtxMove {Przenie}
translate P FinderCtxDelete {Usuwa}

# Player finder:
menuText P PListFile "Plik" 0
menuText P PListFileUpdate "Uaktualnij" 0
menuText P PListFileClose "Zamknij przegldark zawodnikw" 0
menuText P PListSort "Sortowanie" 0
menuText P PListSortName "Nazwisko" 0
menuText P PListSortElo "Elo" 0
menuText P PListSortGames "Partie" 0
menuText P PListSortOldest "Najstarsza" 0
menuText P PListSortNewest "Najnowsza" 0

# Tournament finder:
menuText P TmtFile "Plik" 0
menuText P TmtFileUpdate "Uaktualnij" 0
menuText P TmtFileClose "Zamknij turnieje" 0
menuText P TmtSort "Sortowanie" 0
menuText P TmtSortDate "Data" 0
menuText P TmtSortPlayers "Zawodnicy" 0
menuText P TmtSortGames "Partie" 0
menuText P TmtSortElo "Elo" 0
menuText P TmtSortSite "Miejsce" 0
menuText P TmtSortEvent "Turniej" 0
menuText P TmtSortWinner "Zwycizca" 0
translate P TmtLimit "Wielko listy"
translate P TmtMeanElo "Min. rednie ELO"
translate P TmtNone "Nie znaleziono turniejw."

# Graph windows:
menuText P GraphFile "Plik" 0
menuText P GraphFileColor "Zapisz jako kolorowy PostScript" 12
menuText P GraphFileGrey "Zapisz jako zwyky PostScript..." 0
menuText P GraphFileClose "Zamknij okno" 6
menuText P GraphOptions "Opcje" 0
menuText P GraphOptionsWhite "Biae" 0
menuText P GraphOptionsBlack "Czarne" 0
menuText P GraphOptionsBoth "Oba kolory" 1
menuText P GraphOptionsPInfo "Gracz z Informacji o graczu" 0
menuText P GraphOptionsEloFile "Elo z pliku oceny" 0
menuText P GraphOptionsEloDB "Elo z bazy danych" 0
translate P GraphFilterTitle "Wykres filtra: procent gier, ktre osigny pozycj"
translate P GraphAbsFilterTitle "Wykres filtr: szkoda gier"
translate P GraphWinPctTitle "Wykres filtra: % wygranych (1-0 i 0-1) na bie¿±cej pozycji wed³ug roku"
translate P ConfigureFilter {Skonfiguruj osie X dla roku, ocena i decyzja}
translate P FilterEstimate "Oszacowa"
translate P TitleFilterGraph "Scid: Filtr wykresw"
translate P WinPct "Wygraæ %"
translate P GraphLine "Wykres liniowy"
translate P GraphBar "Wykres słupkowy"
translate P GraphPopup "Wyskakująca tablica"
translate P PgnVarClose {Zamknij wszystkie warianty}
translate P PgnVarOpen {Otwórz wszystkie warianty}
translate P PgnEvaluate {Oceniać}
translate P PgnSaveEval {Zapisz ocenę}
translate P PgnOptShort "Krótki (3-liniowy) nagłówek"
translate P PgnOptSymbols "Symboliczne adnotacje"
translate P PgnOptIndentC "Wcięcie Komentarze"
translate P PgnOptIndentV "Odmiany wcięć"
translate P PgnOptColumn "Styl kolumnowy (jeden ruch na linię)"
translate P PgnOptSpace "Spacja po liczbach ruchu"
translate P PgnOptStripMarks "Usuń kody kolorowych kwadratów/strzałek"
translate P PgnOptBoldMainLine "Użyj pogrubionego tekstu dla ruchów linii głównej"

# Analysis window:
translate P AddVariation {Dodaj wariant}
translate P AddAllVariations {Dodaj wszystkie rozwizania}
translate P AddMove {Dodaj posunicie}
translate P Annotate {Komentuj}
translate P ShowAnalysisBoard {Poka tablic angielsk}
translate P ShowInfo {Poka informacje o silniku}
translate P FinishGame {Zakocz gr}
translate P FinishGameSlot2Warning {Gniazdo silnika 2 jest już używane przez otwarte okno analizy.\n\nZakończ grę korzysta z gniazd silnika 1 i 2 i może przejąć kontrolę nad tym silnikiem. Kontynuować?}
translate P StopEngine {Zatrzymaj silnik}
translate P StartEngine {Uruchomiony silnik}
translate P LockEngine {Zablokuj silnik w pozycjach biecych}
translate P AnalysisCommand {Program do analizy}
translate P PreviousChoices {Poprzednie programy}
translate P AnnotateTime {Czas midzy ruchami (w sekundach)}
translate P AnnotateWhich {Dodaj warianty}
translate P AnnotateAll {Dla obu stron}
translate P AnnotateAllMoves {Opisz wszystkie wystpy}
translate P AnnotateWhite {Dla biaych}
translate P AnnotateBlack {Dla czarnych}
translate P AnnotateBlundersOnly {Kiedy ruch w grze jest oczywistym wykluczeniem}
translate P AnnotateBlundersOnlyScoreChange {Analiza bdu i wyniku z/na:}
translate P BlundersThreshold {Wawka}
translate P ScoreAllMoves {Score all moves}
translate P LowPriority {Niski priorytet CPU} 
translate P ClickHereToSeeMoves {Kliknij tutaj, aby zobaczy wystp}
translate P ConfigureInformant {Skonfiguruj Informatora}
translate P Informant!? {Ciekawe polip}
translate P Informant? {Sabe posunicie}
translate P Informant?? {Pomyka}
translate P Informant?! {Wtpliwe polip}
translate P Informant+= {Biae wyposaenie dodatkowe}
translate P Informant+/- {Biae umiarkowanie stosowane}
translate P Informant+- {Biae maj zdecydowan wersj}
translate P Informant+-- {Biae maj miadce zastosowanie}
translate P AutoComment {Automatyczny komentarz}
translate P AutoCommentTooltip {Wygeneruj komentarz AI dla aktualnej pozycji}
translate P AnalysisAutoCommentTooltip {Generuj komentarz AI dla caej gry}
translate P GameComment {Komentarz do gry}
translate P GameCommentTooltip {Przeskanuj gr pod ktem ruchw z adnotacjami i wygeneruj podsumowanie AI}
translate P TimeMs {Czas (ms)}


# Book window
translate P Book {Ksika}
translate P OtherBookMoves {Ksika przeciwstawiajca si}
translate P OtherBookMovesTooltip {Ruchy, na ktre przeciwnik ma odpowied}

# Analysis Engine open dialog:
translate P EngineList {Programy szachowe}
translate P EngineName {Nazwa}
translate P EngineCmd {Polecenie}
translate P EngineArgs {Parametry} 
translate P EngineDir {Katalog}
translate P EngineElo {Elo}
translate P EngineTime {Data}
translate P EngineNew {Dodaj}
translate P EngineEdit {Edytuj}
translate P EngineRequired {Pola wytuszczone s konieczne; reszta opcjonalna} 
translate P EngineProtocol {Protok komunikacyjny}
translate P EngineNotation {Notacja zalena}
translate P EngineFlipEvaluation {Odwr perspektyw oceny}
translate P EngineShowLog {Poka dziennik komunikacji}
translate P EngineNetworkd {Akceptuj poczenie zdalne}
translate P EngineSelect {Wybierz poczenie silnika}
translate P EngineAddLocal {Dodaj silnik lokalny}
translate P EngineAddRemote {Dodaj odczalny silnik}
translate P EngineReload {Zaaduj ponownie rozruch}
translate P EngineClone {Utwrz baz gwn}
translate P EngineDelete {Usu uruchomienie silnika}
translate P EngineOpenAnalysis {Otwarta analiza}

# PGN window menus:
menuText P PgnFile "Plik" 0
menuText P PgnFileCopy "Kopiuj parti do schowka" 0
menuText P PgnFilePrint "Zapisz do pliku..." 7
menuText P PgnFileClose "Zamknij" 0
menuText P PgnOpt "Wygld" 0
menuText P PgnOptColor "Wywietlanie w kolorach" 0
menuText P PgnOptShort "Krtki (3-wierszowy) nagwek" 0
menuText P PgnOptSymbols "Symbole Informatora" 0
menuText P PgnOptIndentC "Wcinaj komentarze" 7
menuText P PgnOptIndentV "Wcinaj warianty" 7
menuText P PgnOptColumn "Kolumny (jedno posunicie w wierszu)" 0
menuText P PgnOptSpace "Spacja po numerze ruchu" 0
menuText P PgnOptStripMarks "Usu kody kolorowych pl i strzaek" 0
menuText P PgnOptBoldMainLine "Use Bold Text for Main Line Moves" 4 ;# ***
menuText P PgnColor "Kolory" 0
menuText P PgnColorHeader "Nagwek..." 0
menuText P PgnColorAnno "Uwagi..." 3
menuText P PgnColorComments "Komentarze..." 0
menuText P PgnColorVars "Warianty..." 0
menuText P PgnColorBackground "To..." 0
menuText P PgnColorMain "Magistrala..." 0
menuText P PgnColorCurrent "Biece to ruchu..." 1
menuText P PgnHelp "Pomoc" 2
menuText P PgnHelpPgn "PGN" 0
menuText P PgnHelpIndex "Spis treci" 0
translate P PgnWindowTitle {Game Notation - game %u} ;# ***

# Crosstable window menus:
menuText P CrosstabFile "Plik" 0
menuText P CrosstabFileText "Zapisz w pliku tekstowym..." 15
menuText P CrosstabFileHtml "Zapisz w pliku HTML..." 15
menuText P CrosstabFileClose "Zamknij" 0
menuText P CrosstabEdit "Edytuj" 0
menuText P CrosstabEditEvent "Turniej" 0
menuText P CrosstabEditSite "Miejsce" 0
menuText P CrosstabEditDate "Data" 0
menuText P CrosstabOpt "Wywietlanie" 0
menuText P CrosstabOptAll "Turniej koowy" 0
menuText P CrosstabOptSwiss "Szwajcar" 0
menuText P CrosstabOptKnockout "Knockout" 0
menuText P CrosstabOptAuto "Automatycznie" 0
menuText P CrosstabOptAges "Wiek" 0
menuText P CrosstabOptNats "Narodowo" 0
menuText P CrosstabOptRatings "Ranking" 0
menuText P CrosstabOptTitles "Tytu" 0
menuText P CrosstabOptBreaks "Punkty pomocnicze" 1
menuText P CrosstabOptDeleted "Uwzgldniaj usunite partie" 0
menuText P CrosstabOptColors "Kolory (tylko szwajcar)" 0
menuText P CrosstabOptColumnNumbers "Numerowane kolumny (tylko turniej koowy)" 0
menuText P CrosstabOptGroup "Grupuj po liczbie punktw" 0
menuText P CrosstabSort "Sortowanie" 0
menuText P CrosstabSortName "Nazwisko" 0
menuText P CrosstabSortRating "Ranking" 0
menuText P CrosstabSortScore "Punkty" 0
menuText P CrosstabColor "Kolor" 0
menuText P CrosstabColorPlain "Zwyky tekst" 0
menuText P CrosstabColorHyper "Hipertekst" 0
menuText P CrosstabHelp "Pomoc" 2
menuText P CrosstabHelpCross "Tabela turniejowa" 0
menuText P CrosstabHelpIndex "Spis treci" 0
translate P SetFilter {Ustaw filtr}
translate P AddToFilter {Dodaj do filtra}
translate P Swiss {Szwajcar}
translate P Category {Kategoria} 

# Opening report window menus:
menuText P OprepFile "Plik" 0
menuText P OprepFileText "Zapisz w pliku tekstowym..." 15
menuText P OprepFileHtml "Zapisz w pliku HTML..." 15
menuText P OprepFileOptions "Opcje" 2
menuText P OprepFileClose "Zamknij okno raportu" 0
menuText P OprepFavorites "Ulubione" 1 
menuText P OprepFavoritesAdd "Dodaj raport..." 0 
menuText P OprepFavoritesEdit "Modyfikuj ulubione..." 0
menuText P OprepFavoritesGenerate "Twrz raporty..." 0 
menuText P OprepHelp "Pomoc" 2
menuText P OprepHelpReport "Pomoc raportu debiutowego" 0
menuText P OprepHelpIndex "Spis treci" 0

# Header search:
translate P HeaderSearch {Wyszukiwanie wg nagwka}
translate P EndSideToMove {Side to move at end of game} ;# ***
translate P GamesWithNoECO {Partie bez ECO?}
translate P GameLength {Dugo}
translate P FindGamesWith {Znajd partie}
translate P StdStart {caa partia}
translate P Promotions {z promocj}
translate P Comments {Komentarze}
translate P Variations {Warianty}
translate P Annotations {Uwagi}
translate P DeleteFlag {Usuwanie}
translate P WhiteOpFlag {Debiut - biae}
translate P BlackOpFlag {Debiut - czarne}
translate P MiddlegameFlag {Gra rodkowa}
translate P EndgameFlag {Kocwka}
translate P NoveltyFlag {Nowinka}
translate P PawnFlag {Struktura pionowa}
translate P TacticsFlag {Taktyka}
translate P QsideFlag {Gra na skrzydle hetmaskim}
translate P KsideFlag {Gra na skrzydle krlewskim}
translate P BrilliancyFlag {Nagroda za pikno}
translate P BlunderFlag {Podstawka}
translate P UserFlag {Inne}
translate P PgnContains {PGN zawiera tekst}
translate P PgnTag {Etykietka}
translate P TagContains {zawiera}
translate P Variant {Wariant}
translate P Annotator {Adnotator}
translate P Cmnts {Tylko gry z adnotacjami}

# Game list window:
translate P GlistNumber {Numer}
translate P GlistWhite {Biae}
translate P GlistBlack {Czarne}
translate P GlistWElo {B-Elo}
translate P GlistBElo {C-Elo}
translate P GlistEvent {Turniej}
translate P GlistSite {Miejsce}
translate P GlistRound {Runda}
translate P GlistDate {Data}
translate P GlistYear {Rok}
translate P GlistEDate {Turniej-Data}
translate P GlistResult {Wynik}
translate P GlistLength {Dugo}
translate P GlistCountry {Kraj}
translate P GlistECO {ECO}
translate P GlistOpening {Debiut}
translate P GlistEndMaterial {Materia}
translate P GlistDeleted {Usunita}
translate P GlistFlags {Oznaczenie}
translate P GlistVars {Warianty}
translate P GlistComments {Komentarze}
translate P GlistAnnos {Uwagi}
translate P GlistStart {Pozycja pocztkowa}
translate P GlistGameNumber {Numer partii}
translate P GlistAverageElo {Przecitny Elo}
translate P GlistRating {Ocena}
translate P GlistFindText {Znajd tekst}
translate P GlistMoveField {Przesu}
translate P GlistEditField {Konfiguruj}
translate P GlistAddField {Dodaj}
translate P GlistDeleteField {Usu}
translate P GlistWidth {Szeroko}
translate P GlistAlign {Wyrwnanie}
translate P GlistAlignL {Wyrwnaj: w lewo}
translate P GlistAlignR {Wyrwnanie: prawda}
translate P GlistAlignC {Wyrwnaj: do rodka}
translate P GlistColor {Kolor}
translate P GlistSep {Separator}
translate P GlistCurrentSep {-- Aktualny --}
translate P GlistNewSort {Nowy}
translate P GlistAddToSort {Koniec}

# base sorting
translate P GsortSort {Sortowa...}
translate P GsortDate {Dane}
translate P GsortYear {Rok}
translate P GsortEvent {Wydarzenie}
translate P GsortSite {Strona}
translate P GsortRound {Okrge}
translate P GsortWhiteName {Biae imi}
translate P GsortBlackName {Czarne imi}
translate P GsortECO {EKO}
translate P GsortResult {Wynik}
translate P GsortMoveCount {Przenie miejsce}
translate P GsortAverageElo {Przecitny Elo}
translate P GsortCountry {Kraj}
translate P GsortDeleted {Usunito}
translate P GsortEventDate {Dane wydarzenia}
translate P GsortWhiteElo {Biae Elo}
translate P GsortBlackElo {Czarne Elo}
translate P GsortComments {Uwagi}
translate P GsortVariations {Wariacje}
translate P GsortNAGs {GDERA}
translate P GsortAscending {Rosnco}
translate P GsortDescending {Malejco}
translate P GsortAdd {Koniec}
translate P GsortStore {Sklep}
translate P GsortLoad {Obcienie}

# menu shown with right mouse button down on game list.
translate P GlistRemoveThisGameFromFilter  {Usu t gr z filtrem}
translate P GlistRemoveGameAndAboveFromFilter  {Usu gr (i wszystko nad ni) z filtrem}
translate P GlistRemoveGameAndBelowFromFilter  {Usu gr (i wszystko poniej) z filtrem}
translate P GlistDeleteGame {(Nie)Usu t gr} 
translate P GlistDeleteAllGames {Usu wszystkie gry z filtrem} 
translate P GlistUndeleteAllGames {Przywr wszystkie gry w filtrze} 
translate P GlistMergeGameInBase {Moliwo podczenia gry w innej postaci} 

# Maintenance window:
translate P DatabaseName {Nazwa bazy:}
translate P TypeIcon {Ikona:}
translate P NumOfGames {Liczba partii:}
translate P NumDeletedGames {Liczba usunitych partii:}
translate P NumFilterGames {Liczba partii w filtrze:}
translate P YearRange {Data:}
translate P RatingRange {Ranking:}
translate P Description {Opis} 
translate P Flag {Oznaczenie:}
translate P CustomFlags {Flagi prywatne}
translate P DeleteCurrent {Usu aktualn parti}
translate P DeleteFilter {Usu partie z filtra}
translate P DeleteAll {Usu wszystkie partie}
translate P UndeleteCurrent {Odzyskaj aktualn parti}
translate P UndeleteFilter {Odzyskaj partie z filtra}
translate P UndeleteAll {Odzyskaj wszystkie partie}
translate P DeleteTwins {Usu powtrzone partie}
translate P MarkCurrent {Zaznacz aktualn parti}
translate P MarkFilter {Zaznacz partie z filtra}
translate P MarkAll {Zaznacz wszystkie partie z filtra}
translate P UnmarkCurrent {Usu zaznaczenie aktualnej partii}
translate P UnmarkFilter {Usu zaznaczenie partii z filtra}
translate P UnmarkAll {Usu zaznaczenie wszystkich partii}
translate P Spellchecking {Pisownia}
translate P Players {Zawodnicy}
translate P Events {Turnieje}
translate P Sites {Miejsca}
translate P Rounds {Rundy}
translate P DatabaseOps {Operacje bazodanowe}
translate P ReclassifyGames {Klasyfikacja debiutowa}
translate P CompactDatabase {Uporzdkuj baz}
translate P SortDatabase {Sortuj baz}
translate P AddEloRatings {Dodaj rankingi ELO}
translate P AutoloadGame {Domylna partia}
translate P StripTags {Usu znaczniki PGN} 
translate P StripTag {Usu znacznik}
translate P Cleaner {Zestaw zada}
translate P CleanerHelp {
Zestaw zada pozwala wykona od razu kilka operacji porzdkowania bazy. Operacje wybrane z listy
zostan wykonane na aktualnej bazie.

Do klasyfikacji debiutowej i usuwania powtrzonych partii uyte zostan aktualne ustawienia.
}
translate P CleanerConfirm {
Kiedy wykonanie zestawu zada zostanie rozpoczte, nie bdzie mona ju go przerwa.

Na duej bazie moe to zaj duo czasu (zaley to rwnie od wybranego zestawu zada i ich
ustawie).

Na pewno wykona wybrane zadania?
}
# Twinchecker
translate P TwinCheckUndelete {odwrci; ty? przywrci oba)}
translate P TwinCheckprevPair {Poprzednia ust}
translate P TwinChecknextPair {Nastpna ust}
translate P TwinChecker {Scid: Kontroler gier bliniaczych}
translate P TwinCheckTournament {Gry w wykonaniu:}
translate P TwinCheckNoTwin {adnego bliniaka}
translate P TwinCheckNoTwinfound {W tej grze nie wykryto bliniakw.\nAby bliniaki w tym oknie, naley najpierw zwrci uwag na ?Usu gry bliniacze?.}
translate P TwinCheckTag {Udostpnij tagi...}
translate P TwinCheckFound1 {Scid bliniacze gry $result}
translate P TwinCheckFound2 {i ustaw ich flagi usunicia}
translate P TwinCheckNoDelete {W tej zawartoci danych nie ma gier do usunicia.}
translate P TwinCriteria1 {Twoje urzdzenia wyszukiwania bliniaczych mog by umieszczone, e gry inne ni bliniacze z urzdzeniami wyposaonymi w oznaczone jako bliniacze.}
translate P TwinCriteria2 {Zalecane jest, aby w przypadku wybrania opcji ?Nie? dla ?tych samodzielnie? wybierz ?Tak? dla zagroe, wydarzenia, miejsca, rundy, roku i miesica.\nCzy chcesz mimo to chcie i usun bliniaki?}
translate P TwinCriteria3 {Zalecane jest wybranie opcji ?Tak? dla dwch uytkownikw ?ta sama witryna?, ?ta sama runda? i ?ten sam rok?.\nCzy mimo to chcesz usun i usun bliniaki?}
translate P TwinCriteriaConfirm {Scid: Potwierd ustawienia bliniacze}
translate P TwinChangeTag "Zmie Zmie tagi gry:\n\n"
translate P AllocRatingDescription "Aby zastosowa kontrol sprawdzania pisowni, naley sprawdzi Elo do gier w tej danych. Jeli gracz nie ma aktualnej oceny, ale jego w momencie gry jest podana w pliku sprawdzania pisowni, ocena ta zostanie dodana."
translate P RatingOverride "Za uzupenienie niezerowe uwagi?"
translate P AddRatings "Dodaj ocen do:"
translate P AddedRatings {Scid dodai ranking Elo $r w grach za $g.}

#Bookmark editor
translate P NewSubmenu "Nowe podmenu"

# Comment editor:
translate P AnnotationSymbols  {Symbole:}
translate P Comment {Komentarz:}
translate P InsertMark {Wstaw znak}
translate P InsertMarkHelp {
Insert/remove mark: Select color, type, square.
Insert/remove arrow: Right-click two squares.
} ;# ***

# Nag buttons in comment editor:
translate P GoodMove {Good move} ;# ***
translate P PoorMove {Poor move} ;# ***
translate P ExcellentMove {Excellent move} ;# ***
translate P Blunder {Podstawka}
translate P InterestingMove {Interesting move} ;# ***
translate P DubiousMove {Dubious move} ;# ***
translate P WhiteDecisiveAdvantage {White has a decisive advantage} ;# ***
translate P BlackDecisiveAdvantage {Black has a decisive advantage} ;# ***
translate P WhiteClearAdvantage {White has a clear advantage} ;# ***
translate P BlackClearAdvantage {Black has a clear advantage} ;# ***
translate P WhiteSlightAdvantage {White has a slight advantage} ;# ***
translate P BlackSlightAdvantage {Black has a slight advantage} ;# ***
translate P WhiteCrushing {Biae maj miadce zastosowanie}
translate P BlackCrushing {Czarne maj miadce zastosowanie}
translate P Equality {Equality} ;# ***
translate P Unclear {Unclear} ;# ***
translate P Diagram {Diagram} ;# ***

# Board search:
translate P BoardSearch {Wyszukiwanie wg pozycji}
translate P FilterOperation {Operacje na aktualnym filtrze:}
translate P FilterAnd {I (ogranicz filtr)}
translate P FilterOr {LUB (dodaj do filtra)}
translate P FilterIgnore {NOWY (ignoruj poprzedni filtr)}
translate P SearchType {Typ wyszukiwania:}
translate P SearchBoardExact {Identyczna pozycja (bierki na tych samych polach)}
translate P SearchBoardPawns {Pionki (ten sam materia, pionki na tych samych polach)}
translate P SearchBoardFiles {Kolumny (ten sam materia, pionki na tych samych kolumnach)}
translate P SearchBoardAny {Materia (ten sam materia, pozycja dowolna)}
translate P SearchInRefDatabase {Szukaj w zawartoci}
translate P LookInVars {Przeszukuj warianty}

# Material search:
translate P MaterialSearch {Wyszukiwanie wg materiau}
translate P Material {Materia}
translate P Patterns {Wzorce}
translate P Zero {Brak}
translate P Any {Dowolny}
translate P CurrentBoard {Aktualna pozycja}
translate P CommonEndings {Typowe kocwki}
translate P CommonPatterns {Typowe wzorce}
translate P MaterialDiff {Przewaga materialna}
translate P squares {pola}
translate P SameColor {jednopolowe}
translate P OppColor {rnopolowe}
translate P Either {dowolne}
translate P MoveNumberRange {Zakres posuni}
translate P MatchForAtLeast {Pasuje min.}
translate P HalfMoves {pruchy}

# Common endings in material search:
translate P EndingPawns {Pawn endings} ;# ***
translate P EndingRookVsPawns {Rook vs. Pawn(s)} ;# ***
translate P EndingRookPawnVsRook {Rook and 1 Pawn vs. Rook} ;# ***
translate P EndingRookPawnsVsRook {Rook and Pawn(s) vs. Rook} ;# ***
translate P EndingRooks {Rook vs. Rook endings} ;# ***
translate P EndingRooksPassedA {Rook vs. Rook endings with a passed a-pawn} ;# ***
translate P EndingRooksDouble {Double Rook endings} ;# ***
translate P EndingBishops {Bishop vs. Bishop endings} ;# ***
translate P EndingBishopVsKnight {Bishop vs. Knight endings} ;# ***
translate P EndingKnights {Knight vs. Knight endings} ;# ***
translate P EndingQueens {Queen vs. Queen endings} ;# ***
translate P EndingQueenPawnVsQueen {Queen and 1 Pawn vs. Queen} ;# ***
translate P BishopPairVsKnightPair {Two Bishops vs. Two Knights middlegame} ;# ***

# Common patterns in material search:
translate P PatternWhiteIQP {White IQP} ;# ***
translate P PatternWhiteIQPBreakE6 {White IQP: d4-d5 break vs. e6} ;# ***
translate P PatternWhiteIQPBreakC6 {White IQP: d4-d5 break vs. c6} ;# ***
translate P PatternBlackIQP {Black IQP} ;# ***
translate P PatternWhiteBlackIQP {White IQP vs. Black IQP} ;# ***
translate P PatternCoupleC3D4 {White c3+d4 Isolated Pawn Couple} ;# ***
translate P PatternHangingC5D5 {Black Hanging Pawns on c5 and d5} ;# ***
translate P PatternMaroczy {Maroczy Center (with Pawns on c4 and e4)} ;# ***
translate P PatternRookSacC3 {Rook Sacrifice on c3} ;# ***
translate P PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)} ;# ***
translate P PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)} ;# ***
translate P PatternLightFian {Light-Square Fianchettos (Bishop-g2 vs. Bishop-b7)} ;# ***
translate P PatternDarkFian {Dark-Square Fianchettos (Bishop-b2 vs. Bishop-g7)} ;# ***
translate P PatternFourFian {Four Fianchettos (Bishops on b2,g2,b7,g7)} ;# ***

# Game saving:
translate P Today {Dzisiaj}
translate P ClassifyGame {Klasyfikacja debiutowa}

# Setup position:
translate P EmptyBoard {Pusta szachownica}
translate P InitialBoard {Pozycja pocztkowa}
translate P SideToMove {Na posuniciu}
translate P MoveNumber {Posunicie nr}
translate P Castling {Roszada}
translate P EnPassantFile {Bicie w przelocie}
translate P ClearFen {Kopiuj FEN}
translate P PasteFen {Wklej pozycj FEN}

translate P SaveAndContinue {Zapisz i pamitaj}
translate P DiscardChangesAndContinue {Odrzu zmian\i wczeniej}
translate P GoBack {Wracajc}

# Replace move dialog:
translate P ReplaceMove {Zmie posunicie}
translate P AddNewVar {Dodaj wariant}
translate P NewMainLine {Nowa linia gwna}
translate P ReplaceMoveMessage {Posunicie ju istnieje.

Moesz je zastpi, usuwajc dalszy cig partii lub doda nowy wariant.

(Mona wyczy to ostrzeenie, wyczajc opcj  "Zapytaj przed zastpieniem posuni" w menu
Opcje:Posunicia)}

# Make database read-only dialog:
translate P ReadOnlyDialog {Jeli zabezpieczysz t baz przed zapisem, zmiany bd zablokowane
adna partia nie bdzie zapisana ani zmodyfikowana, adne flagi nie bd zmienione.
Sortowanie i klasyfikacja debiutowa bd tylko tymczasowe.

eby usun zabezpieczenie przez zapisem, wystarczy zamkn baz i otworzy j ponownie.

Na pewno zabezpieczy baz przed zapisem?}

# Clear game dialog:
translate P ClearGameDialog {Partia zostaa zmieniona.

Na pewno kontynuowa, rezygnujc z wszelkich zmian?
}

# Exit dialog:
translate P ExitDialog {Na pewno zakoczy prac z programem?}
translate P ExitUnsaved {Nastpujce bazy zawieraj niezapisane zmiany. Jeli zamkniesz program teraz, zmiany zostan utracone.} 

# Import window:
translate P PasteCurrentGame {Wklej aktualn parti}
translate P ImportHelp1 {Wprowad lub wklej parti w formacie PGN w ponisz ramk.}
translate P ImportHelp2 {Tu bd wywietlane bdy przy importowaniu partii.}
translate P OverwriteExistingMoves {Zaprzesta kontynuowania?}

# ECO Browser:
translate P ECOAllSections {Wszystkie kody ECO}
translate P ECOSection {Cz ECO}
translate P ECOSummary {Podsumowanie dla}
translate P ECOFrequency {Czstoci kodw dla}

# Opening Report:
translate P OprepReportFor {Zgo dla}
translate P OprepTitle {Raport debiutowy}
translate P OprepReport {Raport}
translate P OprepGenerated {Utworzony przez}
translate P OprepStatsHist {Statystyka i historia}
translate P OprepStats {Statystyka}
translate P OprepStatAll {Wszystkie partie}
translate P OprepStatBoth {Obaj zawodnicy z Elo}
translate P OprepStatSince {Od}
translate P OprepOldest {Najdawniejsze partie}
translate P OprepNewest {Ostatnie partie}
translate P OprepPopular {Popularno}
translate P OprepFreqAll {Czsto w caej bazie:         }
translate P OprepFreq1   {W ostatnim roku:                }
translate P OprepFreq5   {W ostatnich piciu latach:      }
translate P OprepFreq10  {W ostatnich dziesiciu latach:  }
translate P OprepEvery {co %u partii}
translate P OprepUp {wicej o %u%s ni w caej bazie}
translate P OprepDown {mniej o %u%s ni w caej bazie}
translate P OprepSame {jak w caej bazie}
translate P OprepMostFrequent {Gracze najczciej stosujcy wariant}
translate P OprepMostFrequentOpponents {Przeciwnicy} 
translate P OprepRatingsPerf {Rankingi i wyniki}
translate P OprepAvgPerf {rednie rankingi i wyniki}
translate P OprepWRating {Ranking biaych}
translate P OprepBRating {Ranking czarnych}
translate P OprepWPerf {Wynik biaych}
translate P OprepBPerf {Wynik czarnych}
translate P OprepHighRating {Partie graczy o najwyszym rednim rankingu}
translate P OprepTrends {Wyniki}
translate P OprepResults {Dugo partii i czstoci}
translate P OprepLength {Dugo partii}
translate P OprepFrequency {Czsto}
translate P OprepWWins {Zwycistwa biaych:  }
translate P OprepBWins {Zwycistwa czarnych: }
translate P OprepDraws {Remisy:              }
translate P OprepWholeDB {caa baza}
translate P OprepShortest {Najkrtsze zwycistwa}
translate P OprepMovesThemes {Posunicia i motywy}
translate P OprepMoveOrders {Posunicia prowadzce do badanej pozycji}
translate P OprepMoveOrdersOne \
  {Badana pozycja powstawaa jedynie po posuniciach:}
translate P OprepMoveOrdersAll \
  {Badana pozycja powstawaa na %u sposobw:}
translate P OprepMoveOrdersMany \
  {Badana pozycja powstawaa na %u sposobw. Najczstsze %u to:}
translate P OprepMovesFrom {Posunicia w badanej pozycji}
translate P OprepMostFrequentEcoCodes {Najczstsze kody ECO} 
translate P OprepThemes {Motywy pozycyjne}
translate P OprepThemeDescription {Czsto motyww w pierwszych %u posuniciach partii} 
translate P OprepThemeSameCastling {Jednostronne roszady}
translate P OprepThemeOppCastling {Rnostronne roszady}
translate P OprepThemeNoCastling {Obie strony bez roszady}
translate P OprepThemeKPawnStorm {Atak pionowy na skrzydle krlewskim}
translate P OprepThemeQueenswap {Wymiana hetmanw}
translate P OprepThemeWIQP {Izolowany pion biaych} 
translate P OprepThemeBIQP {Izolowany pion czarnych}
translate P OprepThemeWP567 {Biay pion na 5/6/7 linii}
translate P OprepThemeBP234 {Czarny pion na 2/3/4 linii}
translate P OprepThemeOpenCDE {Otwarta kolumna c/d/e}
translate P OprepTheme1BishopPair {Jedna ze stron ma par gocw}
translate P OprepEndgames {Kocwki}
translate P OprepReportGames {Partie raportu}
translate P OprepAllGames {Wszystkie partie}
translate P OprepEndClass {Materia w pozycji kocowej}
translate P OprepTheoryTable {Teoria}
translate P OprepTableComment {Utworzono z %u partii o najwyszym rednim rankingu.}
translate P OprepExtraMoves {Dodatkowe posunicia w przypisach}
translate P OprepMaxGames {Maksymalna liczba partii w teorii}
translate P OprepMergeMoves {Przesu limit dla poczonych gier}
translate P OprepMergeUnique {cz tylko unikalne gry}
translate P OprepViewHTML {rdo HTML} 

# Player Report:
translate P PReportTitle {Raport o graczu}
translate P PReportColorWhite {with the White pieces} ;# ***
translate P PReportColorBlack {with the Black pieces} ;# ***
translate P PReportMoves {po %s}
translate P PReportOpenings {Debiuty}
translate P PReportClipbase {Wyczy schowek i skopiuj do niego wybrane partie}

# Piece Tracker window:
translate P TrackerSelectSingle {Lewy przycisk wybiera t figur.}
translate P TrackerSelectPair {Lewy przycisk wybiera t figur; prawy obie takie figury.}
translate P TrackerSelectPawn {Lewy przycisk wybiera tego piona; prawy wszystkie 8 pionw.}
translate P TrackerStat {Statystyka}
translate P TrackerGames {% partie z posuniciem na tym pole}
translate P TrackerTime {% czasu na tym polu}
translate P TrackerMoves {Posunicia}
translate P TrackerMovesStart {Podaj numer posunicia, od ktrego zacz ledzenie.}
translate P TrackerMovesStop {Podaj numer posunicia, na ktrym skoczy ledzenie.}

# Game selection dialogs:
translate P SelectAllGames {Wszystkie partie w bazie}
translate P SelectFilterGames {Partie w filtrze}
translate P SelectTournamentGames {Tylko partie z aktualnego turnieju}
translate P SelectOlderGames {Tylko wczeniejsze partie}

# Delete Twins window:
translate P TwinsNote {Partie zostan uznane za identyczne, jeli zostay rozegrane przez tych samych graczy i speniaj ustawione poniej kryteria. Krtsza z partii zostanie usunita. Uwaga: dobrze przez wyszukaniem powtrzonych partii sprawdzi pisowni nazwisk.}
translate P TwinsCriteria {Kryteria: co musi by jednakowe w obu partiach?}
translate P TwinsWhich {Przeszukiwane partie}
translate P TwinsColors {Kolory}
translate P TwinsEvent {Turniej:}
translate P TwinsSite {Miejsce:}
translate P TwinsRound {Runda:}
translate P TwinsYear {Rok:}
translate P TwinsMonth {Miesic:}
translate P TwinsDay {Dzie:}
translate P TwinsResult {Wynik:}
translate P TwinsECO {Kod ECO:}
translate P TwinsMoves {Posunicia:}
translate P TwinsPlayers {Porwnywanie nazwisk:}
translate P TwinsPlayersExact {Dokadne}
translate P TwinsPlayersPrefix {Tylko pierwsze 4 litery}
translate P TwinsWhen {Usuwanie znalezionych powtrzonych partii}
translate P TwinsSkipShort {Pomija partie krtsze ni 5 posuni?}
translate P TwinsUndelete {Odzyska wszystkie partie przed poszukiwaniem?}
translate P TwinsSetFilter {Wstawi wszystkie usunite partie do filtra?}
translate P TwinsComments {Zawsze zachowywa partie komentowane?}
translate P TwinsVars {Zawsze zachowywa partie z wariantami?}
translate P TwinsDeleteWhich {Ktr parti usun:} 
translate P TwinsDeleteShorter {Krtsz} 
translate P TwinsDeleteOlder {O niszym numerze}
translate P TwinsDeleteNewer {O wyszym numerze}
translate P TwinsDelete {Usu partie}

# Name editor window:
translate P NameEditType {Nazwa do wyboru}
translate P NameEditSelect {Partie do edycji}
translate P NameEditReplace {Zastp}
translate P NameEditWith {przez}
translate P NameEditMatches {Pasujce: Ctrl+1 do Ctrl+9 wybiera}

# Check games window:
translate P CheckGames {Sprawd gry}
translate P CheckGamesWhich {Sprawd gry}
translate P CheckAll {Wszystkie gry}
translate P CheckSelectFilterGames {Tylko gry w filtrze}

# Classify window:
translate P Classify {Przyporzdkowanie ECO}
translate P ClassifyWhich {Partie do przyporzdkowania ECO}
translate P ClassifyAll {Wszystkie partie (zmiana starych kodw ECO)}
translate P ClassifyYear {Wszystkie partie z ostatniego roku}
translate P ClassifyMonth {Wszystkie partie z ostatniego miesica}
translate P ClassifyNew {Tylko partie bez kodu ECO}
translate P ClassifyCodes {Kody ECO}
translate P ClassifyBasic {Tylko podstawowe ("B12", ...)}
translate P ClassifyExtended {Rozszerzone kody Scida ("B12j", ...)}
translate P ClassifyResult {Klasyfikacja ECO ukoczona: $result gry(y) zaktualizowane.}

# Compaction:
translate P NameFile {Plik nazw}
translate P GameFile {Plik z partiami}
translate P Names {Nazwy}
translate P Unused {Nieuywane}
translate P SizeKb {Rozmiar (kb)}
translate P CurrentState {Status}
translate P AfterCompaction {Po uporzdkowaniu}
translate P CompactNames {Uporzdkuj nazwy}
translate P CompactGames {Uporzdkuj partie}
translate P NoUnusedNames "Nie ma adnych nieuywanych nazw, wic plik nazwy jest ju w peni skompaktowany."
translate P NoUnusedGames "Plik gry jest ju w peni skompaktowany."
translate P GameFileCompacted {Plik gry dla bazy danych zosta skompaktowany.}

# Sorting:
translate P SortCriteria {Kryteria sortowania}
translate P AddCriteria {Dodaj kryteria}
translate P CommonSorts {Standardowe kryteria}
translate P Sort {Sortuj}

# Exporting:
translate P AddToExistingFile {Doda partie do pliku?}
translate P ExportComments {Eksportowa komentarze?}
translate P ExportVariations {Eksportowa warianty?}
translate P IndentComments {Wcinaj komentarze?}
translate P IndentVariations {Wcinaj warianty?}
translate P ExportColumnStyle {Kolumny (jedno posunicie w wierszu)?}
translate P ExportSymbolStyle {Styl znakw komentarza:}
translate P ExportStripMarks {Usuwa z komentarzy kody kolorowania pl/strzaek?} 

# Goto game/move dialogs:
translate P LoadGameNumber {Podaj numer partii do wczytania:}
translate P GotoMoveNumber {Id do posunicia nr:}

# Copy games dialog:
translate P CopyAllGames {Skopiuj wszystkie gry do}
translate P CopyGames {Kopiuj partie}
translate P CopyConfirm {
 Czy na pewno skopiowa
 [::utils::thousands $nGamesToCopy] partii z filtra
 w bazie "$fromName"
 do bazy "$targetName"?
}
translate P CopyErr {Nie mona skopiowa partii}
translate P CopyErrSource {baza rdowa}
translate P CopyErrTarget {baza docelowa}
translate P CopyErrNoGames {nie ma partii w filtrze}
translate P CopyErrReadOnly {jest tylko do odczytu}
translate P CopyErrNotOpen {nie jest otwarta}

# Colors:
translate P LightSquares {Jasne pola}
translate P DarkSquares {Ciemne pola}
translate P SelectedSquares {Wybrane pola}
translate P SuggestedSquares {Wybrane posunicie}
translate P WhitePieces {Biae figury}
translate P BlackPieces {Czarne figury}
translate P WhiteBorder {Kontur biaych figur}
translate P BlackBorder {Kontur czarnych figur}

# Novelty window:
translate P FindNovelty {Znajd nowink}
translate P Novelty {Nowinka}
translate P NoveltyInterrupt {Poszukiwanie nowinki przerwano}
translate P NoveltyNone {Nie znaleziono nowinki w partii}
translate P NoveltyHelp {
Scid znajdzie pierwsze posunicie w partii, po ktrym powstanie pozycja niewystpujca ani w bazie, ani w ksice debiutowej.
}

# Sounds configuration:
translate P SoundsFolder {Sound Files Folder} ;# ***
translate P SoundsFolderHelp {The folder should contain the files King.wav, a.wav, 1.wav, etc} ;# ***
translate P SoundsAnnounceOptions {Move Announcement Options} ;# ***
translate P SoundsAnnounceNew {Announce new moves as they are made} ;# ***
translate P SoundsMoveSoundOnly {Przenie tylko dwik (wycz powiadomienia)}
translate P SoundsAnnounceForward {Announce moves when moving forward one move} ;# ***
translate P SoundsAnnounceBack {Announce when retracting or moving back one move} ;# ***
translate P SoundsSoundDisabled {Scid nie mona pobra pakietu audio Snack podczas uruchamiania;\nDwik jest wyczony.}

# Upgrading databases:
translate P Upgrading {Konwersja}
translate P ConfirmOpenNew {
Ta baza jest zapisana w starym formacie (Scid 3) i nie moe zosta otwarta w nowszej wersji
Scid-a. Baza zostaa ju automatycznie przekonwertowana do nowego formatu.

Czy otworzy now wersj bazy?
}
translate P ConfirmUpgrade {
Ta baza jest zapisana w starym formacie (Scid 3) i nie moe zosta otwarta w nowszej wersji Scid-a. eby mc otworzy baz, trzeba przekonwertowa j do nowego formatu.

Konwersja utworzy now wersj bazy - stara wersja nie zostanie zmieniona ani usunita.

Moe to zaj troch czasu, ale jest to operacja jednorazowa. Moesz j przerwa, jeli potrwa za dugo.

Przekonwertowa baz?
}

# Recent files options:
translate P RecentFilesMenu {Liczba ostatnich plikw w menu Plik} 
translate P RecentFilesExtra {Liczba ostatnich plikw w dodatkowym podmenu} 

# My Player Names options:
translate P MyPlayerNamesDescription {Podaj list preferowanych nazwisk graczy, po jednym w wierszu. W nazwiskach mona stosowa znaki specjalne (np. "?" - dowolny znak, "*" - dowolna sekwencja znakw).
Wszystkie partie grane przez jednego z graczy z listy bd wywietlane z jego perspektywy.
}

# Computer Tournament:
translate P configComp {Skonfiguruj turniej}
translate P Tournament {Turniej}
translate P Available {Dostępny}
translate P Selected {Wybrany}
translate P RoundRobin {Okrągły Robin}
translate P Gauntlet {Rękawica}
translate P CompGameNext {Następna gra:}
translate P TimeperGame {Czas na\grę}
translate P TimeperMove {Czas na\Ruch}
translate P compStoreTime {Czas przechowywania:}
translate P Clock {Zegar}
translate P compConcurrent {Równoczesne gry:}
translate P compShowBoards {Pokaż tablice}
translate P compCarousel {System karuzelowy}
translate P compSaveEval {Zapisz ocenę}
translate P compCanceledGames {Gry anulowane lub przeterminowane:}
translate P Replay {Powtórna rozgrywka}
translate P compStart {Start}
translate P compSave {Zapisz po każdej grze}
translate P compStop {Zatrzymaj się po zakończeniu aktu. gra}
translate P compRunning {Turniej w toku}
translate P Restart {Uruchom ponownie}
translate P compFinished {Turniej zakończony}
translate P compStopped {Turniej zatrzymany}
translate P compForceDraw {Wymuś losowanie}
translate P compForceResign {Wymusić rezygnację}
translate P compAfterMove {Po ruchu:}
translate P compNumMoves {Liczba ruchów:}
translate P compScoreLess {Wynik <:}
translate P compScoreGreater {Wynik >:}
translate P compRepeatReverse {Powtórz w odwrotnej kolejności}

#Coach
translate P showblunderexists {zjawisko, e bd istnieje}
translate P showblundervalue {poka warto dodatkow}
translate P showscore {poka wynik}
translate P coachgame {gra trenerska}
translate P configurecoachgame {skonfiguruj gr trenersk}
translate P configuregame {Konfiguracja gry}
translate P Phalanxengine {Silnik Falangi}
translate P Coachengine {Silnik autokaru}
translate P difficulty {trudno}
translate P hard {twardy}
translate P easy {atwe}
translate P Playwith {Zagraj z}
translate P white {biay}
translate P black {czarny}
translate P both {Gdybym}
translate P Play {Gra}
translate P Noblunder {adnej pomyki}
translate P blunder {pomyka}
translate P Noinfo {-- Brak informacji --}
translate P PhalanxOrTogaMissing {Nie znaleziono falangi ani togi}
translate P moveblunderthreshold {ruch jest wikszy ni}
translate P limitanalysis {czas analizy silnika}
translate P seconds {towar drugiej jakoci}
translate P Abort {Poroni}
translate P Resume {Znawia}
translate P OutOfOpening {Poza otwarciem}
translate P NotFollowedLine {Nie zastosowae si do linii}
translate P DoYouWantContinue {Czy chcesz kontynuowa?}
translate P CoachIsWatching {Trener patrzy}
translate P Ponder {Cige mylenie}
translate P LimitELO {Ograniczona sia ELO}
translate P DubiousMovePlayedTakeBack {Wykonano wtpliwe postawienie, czy chcesz je zabi?}
translate P WeakMovePlayedTakeBack {Zagrano saby ruch, czy chcesz odpocz?}
translate P BadMovePlayedTakeBack {Wykonano zy ruch. Czy chcesz i do domu?}
translate P Iresign {zrezygnowa}
translate P yourmoveisnotgood {twoje posunicie nie jest dobre}
translate P EndOfVar {Konieczna trwao}
translate P Openingtrainer {Trener otwarcia}
translate P DisplayCM {Wywietl kandydata}
translate P DisplayCMValue {Wywietl warto kandydata na kandydata}
translate P DisplayOpeningStats {Poka statystyki}
translate P ShowReport {Poka raport}
translate P NumberOfGoodMovesPlayed {zagraniczne dobre zachowanie}
translate P NumberOfDubiousMovesPlayed {rozegrane wtpliwe}
translate P NumberOfMovesPlayedNotInRepertoire {wykona grane poza repertuarem}
translate P NumberOfTimesPositionEncountered {razy trudna pozycja}
translate P PlayerBestMove  {Zezwalaj tylko na najlepsze wykonanie}
translate P OpponentBestMove {Przeciwnik pozosta najlepszy}
translate P OnlyFlaggedLines {Tylko zaznaczona linia}
translate P resetStats {Zresetuj statystyki}
translate P Repertoiretrainingconfiguration {Konfiguracja treningu treningowego}
translate P Loadingrepertoire {adowanie repertuaru}
translate P Movesloaded {Ruchy prowadzce}
translate P Repertoirenotfound {Nie znaleziono}
translate P Openfirstrepertoirewithtype {Otwrz najpierw dane dostpne z ikon/typem podczonym do prawej strony}
translate P Movenotinrepertoire {Ruch nie w repertuarze}
translate P PositionsInRepertoire {Pozycje w repertuarze}
translate P PositionsNotPlayed {Pozycja nie grana}
translate P PositionsPlayed {Grane potrzebowa}
translate P Success {Sukces}
translate P DubiousMoves {Wtpliwe kontynuowa}
translate P OutOfRepertoire {Poza repertuarem}
translate P ConfigureTactics {Skonfiguruj taktyk}
translate P ResetScores {Resetuj wyniki}
translate P LoadingBase {Baza zaadunkowa}
translate P Tactics {Taktyka}
translate P ShowSolution {Poka rozwizanie}
translate P NextExercise {Nastpne pytanie}
translate P PrevExercise {poprzednie wiedziay}
translate P StopTraining {Przesta trenowa}
translate P Next {Nastpny}
translate P ResettingScore {Resetowanie wyniku}
translate P LoadingGame {adowanie gry}
translate P MateFound {Znaleziony kumpel}
translate P BestSolutionNotFound {NIE najlepsze rozwizania!}
translate P MateNotFound {Nie znaleziono partnera}
translate P ShorterMateExists {Posiadajcy partnera}
translate P ScorePlayed {Wynik rozegrany}
translate P Expected {oczekiwany}
translate P ChooseTrainingBase {Wybierz opcj szkoleniow}
translate P Thinking {Myslcy}
translate P AnalyzeDone {Analiza wykonana}
translate P WinWonGame {Wygrana wygrana gra}
translate P Lines {Kwestia}
translate P ConfigureUCIengine {Skonfiguruj silnik UCI}
translate P SpecificOpening {Konkretne otwarcie}
translate P StartNewGame {Rozpocznij now gr}
translate P FixedLevel {Stay poziom}
translate P Opening {Otwr}
translate P RandomLevel {Losowy poziom}
translate P StartFromCurrentPosition {Rozpocznij od aktualnych pozycji}
translate P FixedDepth {Staa inna}
translate P Nodes {Wzy} 
translate P Depth {Gboko}
translate P Time {Czas} 
translate P SecondsPerMove {Drugi ruch}
translate P Engine {Silnik}
translate P TimeMode {Tryb czasu}
translate P TimeBonus {Czas + premia}
translate P TimeMin {min}
translate P TimeSec {sek}
translate P AllExercisesDone {Wszystkie wykonania wykonane}
translate P MoveOutOfBook {Wyjd z ksiki}
translate P LastBookMove {Ostatni ruch ksikowy}
translate P AnnotateSeveralGames {Adnotuj kilka gier\od zainstalowanych do:}
translate P FindOpeningErrors {Rozwizanie otwiera bdynia}
translate P MarkTacticalExercises {Zaznacz wiczenia taktyczne}
translate P UseBook {Skorzystaj z ksiki}
translate P MultiPV {Wiele odmian}
translate P Hash {Pami haszujca}
translate P OwnBook {Skorzystaj z ksiki silnika}
translate P BookFile {Otwieranie ksiki}
translate P AnnotateVariations {Opis stosowania}
translate P ShortAnnotations {Krtkie adnotacje}
translate P addAnnotatorTag {Dodaj tag adnotatora}
translate P AddScoreToShortAnnotations {Dodaj ocen do redniej adnotacji}
translate P Export {Eksport}
translate P BookPartiallyLoaded {Ksika udostpniona}
translate P Calvar {Obliczanie zmiany}
translate P ConfigureCalvar {Konfiguracja}
# Opening names used in tacgame.tcl
translate P Reti {Reti}
translate P English {angielski}
translate P d4Nf6Miscellaneous {1.d4 Sf6 Rne}
translate P Trompowsky {Trompowskiego}
translate P Budapest {Budapeszt}
translate P OldIndian {Stary Indianin}
translate P BenkoGambit {Benko Gambit}
translate P ModernBenoni {Nowoczesnego Benoniego}
translate P DutchDefence {Holenderska obrona}
translate P Scandinavian {skandynawski}
translate P AlekhineDefence {Obrona Alechina}
translate P Pirc {Pirc}
translate P CaroKann {Caro-Kann}
translate P CaroKannAdvance {Postp Caro-Kanna}
translate P Sicilian {sycylijski}
translate P SicilianAlapin {Sycylijski Alapin}
translate P SicilianClosed {Sycylijski zamknity}
translate P SicilianRauzer {Sycylijski Rauzer}
translate P SicilianDragon {Sycylijski dym}
translate P SicilianScheveningen {Sycylijskie Scheveningen}
translate P SicilianNajdorf {Sycylijczyk Najdorf}
translate P OpenGame {Otwrz gr}
translate P Vienna {Wiede}
translate P KingsGambit {Krlewski chwyt}
translate P RussianGame {Rosyjska gra}
translate P ItalianTwoKnights {Woch/Dwch Rycerzy}
translate P Spanish {hiszpaski}
translate P SpanishExchange {Wymiana hiszpaska}
translate P SpanishOpen {Otwarte Hiszpaskie}
translate P SpanishClosed {Hiszpaski Zamknity}
translate P FrenchDefence {Obrona Francuska}
translate P FrenchAdvance {Awans francuski}
translate P FrenchTarrasch {Francuski Tarrasch}
translate P FrenchWinawer {Francuski Winawer}
translate P FrenchExchange {Wymiana francuska}
translate P QueensPawn {Pionek krlowej}
translate P Slav {sowiaski}
translate P QGA {QGA}
translate P QGD {QGD}
translate P QGDExchange {Wymie QGD}
translate P SemiSlav {Psowiaski}
translate P QGDwithBg5 {QGD z Bg5}
translate P QGDOrthodox {QGD ortodoksyjny}
translate P Grunfeld {Grunfelda}
translate P GrunfeldExchange {Grnfeld Exchange}
translate P GrunfeldRussian {Grunfelda Rosyjskiego}
translate P Catalan {kataloski}
translate P CatalanOpen {Kataloskiego Otwartego}
translate P CatalanClosed {Kataloski zamknity}
translate P QueensIndian {Indianin krlowej}
translate P NimzoIndian {Nimzo-Indianin}
translate P NimzoIndianClassical {Nimzo-indyjska klasyka}
translate P NimzoIndianRubinstein {Nimzo? Indianina Rubinsteina}
translate P KingsIndian {Krlewski Indianin}
translate P KingsIndianSamisch {Krlewski indyjski Smisch}
translate P KingsIndianMainLine {Gwna linia King's Indian}

# FICS
translate P ConfigureFics {Skonfiguruj FICS}
translate P FICSGuest {Zaloguj si jako go}
translate P FICSServerPort {Serwer portu}
translate P FICSServerAddress {Adres IP}
translate P FICSRefresh {Odwiey}
translate P FICSTimesealPort {Portowa piecz czasowa}
translate P FICSSilence {Cisza}
translate P FICSOffers {Oferty}
translate P FICSConsole {Konsola}
translate P FICSGames {Zawody sportowe}
translate P FICSUnobserve {Przesta gra}
translate P FICSProfile {Wywietl swoj histori i profil}
translate P FICSRelayedGames {Przekazywane gry}
translate P FICSFindOpponent {znale przeciwnika}
translate P FICSTakeback {Odbir}
translate P FICSTakeback2 {Odbir 2}
translate P FICSInitTime {Czas pocztkowy (min)}
translate P FICSIncrement {Przyrost (e)}
translate P FICSRatedGame {Oceniana gra}
translate P FICSAutoColour {automatyczny}
translate P FICSManualConfirm {potwierd}
translate P FICSFilterFormula {Filtruj za pomoc formu}
translate P FICSIssueSeek {Szukaj problemu}
translate P FICSChallenge {Wyzwanie}
translate P FICSAccept {uchwyt}
translate P FICSDecline {wynik}
translate P FICSColour {Kolor}
translate P FICSSend {poda}
translate P FICSConnect {czy}
translate P FICSdefaultuservars {uniwersalne, standardowe narzdzia}
translate P FICSObserveconfirm {Moesz zobaczy gr}
translate P FICSpremove {Wcz wstpne przesuwanie}
translate P FICSObserve {Przestrzega}
translate P FICSRatedGames {Ocenione gry}
translate P FICSUnratedGames {Gry bez oceny}
translate P FICSRated {Oceniono}
translate P FICSUnrated {Bez oceny}
translate P FICSRegisteredPlayer {Tylko zaangaowany gracz}
translate P FICSFreePlayer {Tylko darmowy gracz}
translate P FICSNetError {Bd sieci\Nie mona si poczy}
translate P OptionsFICS {FIKS}
translate P FICSTerminalColor {Kolor terminala}
translate P FICSTextColor {Kolor tekstu}

# Game review
translate P GameReview {Recenzja gry}
translate P GameReviewTimeExtended {Czas wolny}
translate P GameReviewMargin {Mare ewentualnie}
translate P GameReviewAutoContinue {Automatyczna kontynuacja, gdy ruch jest krytyczny}
translate P GameReviewReCalculate {dugiego czasu}
translate P GameReviewAnalyzingMovePlayedDuringTheGame {Analizowanie ruchu wykonanego w trakcie gry}
translate P GameReviewAnalyzingThePosition {Analiza pozycji}
translate P GameReviewEnterYourMove {Wpisz swj ruch}
translate P GameReviewCheckingYourMove {Sprawdzam Twj ruch}
translate P GameReviewYourMoveWasAnalyzed {Twj ruch zosta wyczony}
translate P GameReviewYouPlayedSameMove {Wykonae dziesi sam ruch, co w meczu}
translate P GameReviewScoreOfYourMove {Wynik Twojego ruchu}
translate P GameReviewGameMoveScore {Wynik ruchu w grze}
translate P GameReviewEngineScore {Wynik silnika}
translate P GameReviewYouPlayedLikeTheEngine {Grae jak silnik}
translate P GameReviewNotEngineMoveButGoodMove {Nie chodzi tu o ruch silnika, ale te jest to dobry ruch}
translate P GameReviewMoveNotGood {Ten ruch nie jest dobry, wynik jest}
translate P GameReviewMovesPlayedLike {Ruchy grane jak}
translate P GameReviewMovesPlayedEngine {Ruchy grane jak silnik}

# Correspondence Chess Dialogs:
translate P CCDlgCGeneraloptions {Opcje oglne}
translate P CCDlgLoginName  {Nazwa logowania:}
translate P CCDlgPassword   {Haso:}
translate P CCDlgShowPassword {Poka haso}

# Connect Hardware dialogs
translate P ExtHWConfigConnection {Skonfiguruj sprzt zewntrzny}
translate P ExtHWPort {Port}
translate P ExtHWEngineCmd {Polecenie silnika}
translate P ExtHWEngineParam {Parametry silnika}
translate P ExtHWShowButton {Poka przycisk}
translate P ExtHWHardware {Sprzt komputerowy}
translate P ExtHWNovag {Novag Cytryn}
translate P ExtHWInputEngine {Silnik zasilajcy}
translate P ExtHWNoBoard {Brak biurka}
translate P NovagReferee {Sdzia}

# Input Engine dialogs
translate P IEConsole {Konsola zasilajca}
translate P IESending {Wysano kontynuowa}
translate P IESynchronise {Synchronizuj}
translate P IERotate  {Obraca}
translate P IEUnableToStart {Nie mona uruchomi przepywu:}

# Calculation of Variations
translate P DoneWithPosition {Koniec z koniecznoci}

translate P Board {Tablica}
translate P showGameInfo {Poka informacje o grze}
translate P autoResizeBoard {Automatyczna zmiana dotyczca planuszy}
translate P DockTop {Przejd na gr}
translate P DockBottom {Przejd na d}
translate P DockLeft {Przejd w lewo}
translate P DockRight {Przejd w prawo}
translate P Undock {Oddokuj}

# Switcher window
translate P AboutDatabase {O tej formie danych}
translate P ChangeIcon {Zmie przecznik...}
translate P NewGameListWindow {Nowe okno listy gier}
translate P LoadatStartup {Zaaduj przy uruchomieniu}

# Gamelist window
translate P ShowHideDB {Poka/ukryj baz danych}
translate P ChangeFilter {Zmie filtr}
translate P ChangeLayout {Zaaduj/Zapisz/Zmie kryteria sortowania i ukad kolumnowy}
translate P ShowHideStatistic {Poka/ukryj statystyki}
translate P BoardFilter {Poka tylko wszystkie pozycje do aktualnych pozycji na planszy}
translate P CopyGameTo {Skopiuj gr do}
translate P FindBar {szukaj paska}
translate P FindCurrentGame {rdo biecej gry}
translate P DeleteGame {Usu gr}
translate P UndeleteGame {Przywr gr}
translate P ResetSort {Zresetuj sortowanie}
translate P LayoutExists {Układ '%s' już istnieje.}
translate P ConfirmDeleteLayout {Czy na pewno chcesz usunąć układ „%s”?}

translate P ConvertNullMove {Konwerstuj zerowe na komentarze}
translate P SetupBoard {Pyta konfiguracyjna}
translate P Rotate {Obraca}
translate P SwitchColors {Zmie kolor}
translate P FlipBoard {Odwie tablic}
translate P Board3D {Tablica 3D}
translate P Board3DReset {Nastawić}
translate P Board3DResetTip {Zresetuj kamerę do widoku domyślnego}
translate P Board3DZoomIn {Powiększ}
translate P Board3DZoomOut {Pomniejsz}
translate P Board3DDragToRotate {Przeciągnij, aby obrócić}
translate P Board3DScrollToZoom {Przewiń, aby powiększyć}
translate P ImportPGN {Importuj gr PGN}
translate P ImportingFiles {Importowanie plikw PGN w formacie PDF}
translate P ImportingFrom {Importowanie z}
translate P ImportingIn {Importuj gry do}
translate P UseLastTag {uyj tagw ostatniego gry}
translate P Random {Losowy}
translate P BackToMainline {Wr do sklepu pielgnowa}
translate P LeaveVariant {Opu wariant}
translate P Autoplay {Autoodtwarzanie}
translate P ShowHideCoords {Poka/Ukryj wsprzdne.}
translate P ShowHideEvalBar {Poka/ukryj pasek oceny}
translate P ShowHideMaterial {Poka/ukryj materiay}
translate P SelectMarker {Wybierz opcj Znacznik}
translate P FullScreen {Peny ekran}
translate P FilterStatistic {Statystyki filtrowane}
translate P MakeCorrections {Wprowad wprowadzone}
translate P Surnames {Nazwiska}
translate P Ambiguous {Dwuznaczny}

#Preferences Dialog
translate P OptionsToolbar "Pasek narzdziowy"
translate P OptionsBoard "Szachownica"
translate P OptionsBoardSize "Wielkoe"
translate P OptionsBoardPieces "Typ figur"
translate P OptionsInternationalization "Umidzynarodowienie"
translate P OptionsTablebaseDir "Wybierz maksymalnie 4 foldery bazowe tabeli:"

# Evaluation bar
translate P BestMoveArrow "Najlepsza strzaka ruchu"
translate P NewLocalEngine "+ Nowy silnik..."

# Batch Annotate
translate P BatchAnnotate {Adnotacja zbiorcza}
translate P BatchEngineSelection {Wybór silnika}
translate P BatchChessEngine {Silnik szachowy:}
translate P BatchNumberOfInstances {Liczba instancji:}
translate P BatchGameReview {Recenzja gry}
translate P BatchTimePerMove {Czas na ruch (s):}
translate P BatchAnnotateBlunders {Opisuj tylko b³êdy}
translate P BatchBlunderThreshold {Próg b³êdu:}
translate P BatchVariationLength {D³ugo¶æ zmiany (ruchy):}
translate P BatchOpeningBook {Otwarcie ksi±¿ki}
translate P BatchUseBook {U¿yj ksi±¿ki}
translate P BatchAnnotateVariations {Opisz odmiany}
translate P BatchShortAnnotations {Krótkie adnotacje}
translate P BatchAddScoreToShort {Dodaj ocenê do krótkich adnotacji}
translate P BatchClearOld {Usuñ stare komentarze i odmiany}
translate P BatchInitializingEngines {Inicjowanie silników...}
translate P BatchAnalyzingGames {Analizowanie gier...}
translate P BatchProgress {Wsadowe adnotowanie postêpu}
translate P BatchComplete {Adnotacja zbiorcza ukoñczona!}
translate P BatchCancelled {Anulowano adnotacjê zbiorcz±}
translate P BatchStart {Start}
translate P BatchCancel {Anulowaæ}
translate P BatchCompleted {zakoñczony}
translate P BatchGames {zawody sportowe}
translate P BatchProcessed {obrobiony}
translate P TablebaseWindow {Okno podstawy tabeli}
translate P TBWinMoves {--- Zwycięskie ruchy ---}
translate P TBDrawMoves {--- Rysowanie ruchów ---}
translate P TBLossMoves {--- Utrata ruchów ---}
translate P TBNoMoves {Nie znaleziono żadnych legalnych ruchów.}
translate P TBTooMany {Za dużo kawałków. Podstawa stołu Lichess obsługuje do 7 elementów.}
translate P TBQuerying {Wysyłam zapytanie do API Lichess...}
translate P TBError {Błąd podczas uruchamiania curl w celu wysłania zapytania do Lichess.}
translate P TBQueryError {Nieprawidłowa odpowiedź z interfejsu API bazy tabel.}
translate P TBNotFound {Nie znaleziono pozycji w bazie tabeli lub wystąpił błąd API.}
translate P TBCategory {Kategoria stanowiska:}
translate P TBTrainingHidden {(Tryb treningu; wyniki są ukryte)}
}
# end of english.tcl
