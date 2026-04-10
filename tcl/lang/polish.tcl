### Polish menus for Scid.
# Contributed by Michal Rudolf and Adam Umiastowski.

proc setLanguage_P {} {

# File menu:
menuText P File "Plik" 0
menuText P FileNew "Nowy..." 0 {Twórz nowa bazê Scid}
menuText P FileOpen "Otwórz..." 0 {Otwórz istniej±c± bazê Scid}
menuText P FileClose "Zamknij" 0 {Zamknij aktywn± bazê Scid}
menuText P FileFinder "Poszukiwacz plików" 0 {Otwórz okno poszukiwacza plików}
menuText P FileBookmarks "Zak³adki" 2 {Menu zak³adek (klawisz: Ctrl+B)}
menuText P FileBookmarksAdd "Dodaj zak³adkê" 0 \
  {Dodaj zak³adkê do aktualnej bazy i pozycji}
menuText P FileBookmarksFile "Wstaw zak³adkê" 0 \
  {Wstaw do wybranego katalogu zak³adkê do aktualnej bazy i pozycji}
menuText P FileBookmarksEdit "Edycja zak³adek..." 0 \
  {Edytuj menu zak³adek}
menuText P FileBookmarksList "Wy¶wietlaj katalogi jako listê" 0 \
  {Wy¶wietlaj katalogi zak³adek jako listê, nie jako zagnie¿d¿one menu}
menuText P FileBookmarksSub "Wy¶wietl katalogi jako menu" 0 \
  {Wy¶wietlaj katalogi zak³adek jako zagnie¿d¿one menu, nie jako listê}
menuText P FileMaint "Obs³uga" 1 {Narzêdzia obs³ugi bazy Scid}
menuText P FileMaintWin "Obs³uga" 0 \
  {Otwórz/zamknij obs³ugê bazy Scid}
menuText P FileMaintCompact "Porz±dkuj bazê..." 0 \
  {Porz±dkuj bazê, usuwaj±c skasowane partie i nieu¿ywane nazwiska}
menuText P FileMaintClass "Klasyfikacja debiutowa partii..." 0 \
  {Przelicz klasyfikacjê debiutowa wszystkich partii}
menuText P FileMaintSort "Sortuj bazê..." 0 \
  {Sortuj wszystkie partie w bazie}
menuText P FileMaintDelete "Usuñ podwójne partie..." 0 \
  {Szukaj podwójnych partii i oznacz je do skasowania}
menuText P FileMaintTwin "Wyszukiwanie podwójnych partii" 0 \
  {Otwórz/uaktualnij wyszukiwanie podwójnych partii}
menuText P FileMaintName "Pisownia" 0 \
  {Edycja nazw/nazwisk i kontrola pisowni}
menuText P FileMaintNameEditor "Edytor nazwisk" 0 \
  {Otwórz/zamknij edytor nazwisk}
menuText P FileMaintNamePlayer "Sprawd¼ pisowniê nazwisk..." 17 \
  {Sprawd¼ pisowniê nazwisk przy pomocy pliku nazwisk}
menuText P FileMaintNameEvent "Sprawd¼ pisowniê nazw zawodów..." 22 \
  {Sprawd¼ pisowniê nazw zawodów przy pomocy pliku turniejów}
menuText P FileMaintNameSite "Sprawd¼ pisowniê nazw miejscowo¶ci..." 22 \
  {Sprawd¼ pisowniê nazw miejscowo¶ci przy pomocy pliku miejscowo¶ci}
menuText P FileMaintNameRound "Sprawd¼ numery rund..." 15 \
  {Sprawd¼ numery rund przy pomocy pliku}
menuText P FileReadOnly "Tylko do odczytu..." 0 \
  {Zabezpiecz bazê przed zapisem}
menuText P FileSwitch "Prze³±cz bazê" 1 \
  {Prze³±cz na inn± otwart± bazê} 
menuText P FileOpenLichessTournament "Otwarty Turniej Liszów" 0 {Pobieraj i otwieraj na ¿ywo transmisje z turniejów Lichess}
menuText P FileImportLichess "Zaimportuj moj± Lichess" 0 {Importuj gry ze swojego konta Lichess}
menuText P FileImportChessCom "Zaimportuj moj± stronê chess.com" 0 {Importuj partie ze swojego konta chess.com}
menuText P FileExit "Koniec" 0 {Zamknij Scida}
menuText P FileMaintFixBase "Napraw uszkodzon± szkodê" 0 {Uszkodzona szkoda}

# Edit menu:
menuText P Edit "Edytuj" 0
menuText P EditAdd "Dodaj wariant" 0 {Dodaj wariant do ruchu w partii}
menuText P EditDelete "Usuñ wariant" 0 {Usuñ wariant dla tego posuniêcia}
menuText P EditFirst "Twórz pierwszy wariant" 0 \
  {Przesuñ wariant na pierwsze miejsce na li¶cie}
menuText P EditMain "Zmieñ wariant na tekst partii" 0 \
   {Zamieñ wariant i tekst partii}
menuText P EditTrial "Sprawd¼ wariant" 0 \
  {W³±cz/wy³±cz tryb sprawdzania wariantów}
menuText P EditStrip "Usuñ" 2 \
  {Usuñ komentatarze i warianty}
menuText P EditUndo "Anulowaæ" 0 {Cofnij ostatni± decyzjê gry}
menuText P EditRedo "Przerobiæ" 0 {Powtórz ostatnie zakoñczenie w grze}
menuText P EditStripComments "Komentarze" 0 \
  {Usuñ wszystkie komentarze z aktualnej partii}
menuText P EditStripVars "Warianty" 0 \
  {Usuñ wszystkie warianty z aktualnej partii}
menuText P EditStripBegin "Poprzednie posuniêcia" 0 \
  {Usuñ wszystkie posuniêcia do bie¿±cej pozycji}
menuText P EditStripEnd "Nastêpne posuniêcia" 0 \
  {Usuñ wszystkie posuniêcia od bie¿±cej pozycji do koñca partii}
menuText P EditReset "Opró¿nij schowek" 0 \
  {Opró¿nij schowek bazy}
menuText P EditCopy "Kopiuj partiê do schowka" 0 \
  {Kopiuj partiê do schowka}
menuText P EditPaste "Wklej aktywn± partiê ze schowka" 0 \
  {Wklej aktywn± partiê ze schowka}
menuText P EditPastePGN "Paste Clipboard text as PGN game..." 10 \
  {Interpret the clipboard text as a game in PGN notation and paste it here} ;# ***
menuText P EditSetup "Ustaw pozycjê pocz±tkow±..." 6 \
  {Ustaw pozycjê pocz±tkow± partii}
menuText P EditCopyBoard "Kopiuj pozycjê" 7 \
  {Kopiuj aktualn± pozycjê w notacji FEN do schowka}
menuText P EditPasteBoard "Ustaw pozycjê ze schowka" 3 \
  {Ustaw pozycjê ze schowka}
menuText P ConfigureScid "Preferencje..." 0 {Skonfiguruj wszystkie opcje dla SCID}

# Game menu:
menuText P Game "Partia" 1
menuText P GameNew "Opu¶æ partiê" 0 \
  {Opu¶æ partiê, rezygnuj±c z wszelkich zmian}
menuText P GameFirst "Pierwsza partia" 2 {Wczytaj pierwsz± partiê z filtra}
menuText P GamePrev "Poka¿ poprzedni± partiê" 0 \
  {Wczytaj poprzedni± wyszukan± partiê}
menuText P GameReload "Prze³aduj aktualn± partiê"  10 \
  {Wczytaj partiê ponownie, rezygnuj±c z wszelkich zmian}
menuText P GameNext "Nastêpna partia" 0 \
  {Wczytaj nastêpn± wyszukan± partiê}
menuText P GameLast "Ostatnia partia" 5 {Wczytaj ostatni± partiê z filtra}
menuText P GameRandom "Losowa partia z filtra" 8 {Wczytaj losow± partiê z filtra}
menuText P GameNumber "Wczytaj partiê numer..." 17 \
  {Wczytaj partiê wprowadzaj±c jej numer}
menuText P GameReplace "Zapisz: zast±p partiê..." 3 \
  {Zapisz partiê, zast±p poprzedni± wersjê}
menuText P GameAdd "Zapisz: dodaj now± partiê..." 8 \
  {Zapisz tê partiê jako nowa partiê w bazie}
menuText P GameDeepest "Rozpoznaj debiut" 0 \
  {Przejd¼ do najd³u¿szego wariantu z ksi±¿ki debiutowej}
menuText P GameGotoMove "Przejd¼ do posuniêcia nr..." 13 \
  {Przejd¼ do posuniêcia o podanym numerze}
menuText P GameNovelty "Znajd¼ nowinkê..." 7 \
  {Znajd¼ pierwsze posuniêcie partii niegrane wcze¶niej}

# Search Menu:
menuText P Search "Szukaj" 0
menuText P SearchReset "Resetuj filtr" 0 \
  {Wstaw wszystkie partie do filtra}
menuText P SearchNegate "Odwróæ filtr" 0 \
  {Zamieñ partie w filtrze i poza nim}
menuText P SearchCurrent "Aktualna pozycja..." 0 \
  {Szukaj aktualnej pozycji}
menuText P SearchHeader "Nag³ówek..." 0 \
  {Szukaj informacji o nag³ówkach (nazwiska, nazwy turnieju itp.)}
menuText P SearchMaterial "Materia³/wzorzec..." 0 \
  {Szukaj wed³ug materia³u lub wzorca}
menuText P SearchUsing "Stosuj plik poszukiwania..." 0 \
  {Szukaj stosuj±c plik z opcjami poszukiwania}

# Windows menu:
menuText P Windows "Okna" 1
menuText P WindowsComment "Edytor komentarzy" 0 \
  {Otwórz/zamknij edytor komentarzy}
menuText P WindowsGList "Lista partii" 0 {Otwórz/zamknij listê partii}
menuText P WindowsPGN "Okno PGN" 0 {Otwórz/zamknij (zapis partii) PGN }
menuText P WindowsPList "Zawodnicy" 2 {Otwórz/zamknij przegl±darkê zawodników}
menuText P WindowsTmt "Turnieje" 0 {Otwórz/zamknij przegl±darkê turniejów}
menuText P WindowsSwitcher "Prze³±cznik baz" 12 \
  {Otwórz/zamknij prze³±cznik baz}
menuText P WindowsMaint "Zarz±dzanie baz±" 0 \
  {Otwórz/zamknij okno zarz±dzania baz±}
menuText P WindowsECO "Przegl±darka kodów debiutowych" 0 \
  {Otwórz/zamknij przegl±darkê kodów debiutowych}
menuText P WindowsStats "Statystyka" 0 \
  {Otwórz/zamknij statystykê}
menuText P WindowsTree "Drzewo wariantów" 0 {Otwórz/zamknij drzewo wariantów}
menuText P WindowsBook "Okno ksi±¿ki" 0 {Otwórz/zamknij Ksi±¿ka okno}
menuText P WindowsCorrChess "Okno korespondencyjne" 0 {Otwórz/zamknij okno Korespondencja}
menuText P WindowsGraph "Analiza wykresu" 0 {Otwórz okno Chart z czasowego dzia³ania i oceny}

# Tools menu:
menuText P Tools "Narzêdzia" 0
menuText P ToolsConfigureEngines "Skonfiguruj silniki" 10 {Zarz±dzaj konfiguracj± po¶redni±}
menuText P ToolsAnalysis "Program analizuj±cy..." 8 \
  {Uruchom/zatrzymaj program analizuj±cy}
menuText P ToolsAnalysis2 "Program analizuj±cy 2..." 21 \
  {Uruchom/zatrzymaj program analizuj±cy}
menuText P ToolsCross "Tabela turniejowa" 0 \
  {Poka¿ tabelê turniejow± dla aktualnej partii}
menuText P ToolsFilterGraph "Wykres filtra" 7 \
  {Otwórz/zamknij wykres filtra}
menuText P ToolsAbsFilterGraph "Abs. Filtr wykresu" 7 {Otwórz/zamknij okno wykresu filtru dla warto¶ci bezwzglêdnych}
menuText P ToolsOpReport "Raport debiutowy" 0 \
  {Utwórz raport debiutowy dla aktualnej pozycji}
menuText P ToolsOpenBaseAsTree "Otwórz metodê jako drzewo" 0   {Otwórz dalej i jej dalsze w oknie Drzewa}
menuText P ToolsOpenRecentBaseAsTree "Otwórz ostatnie rozwi±zanie jako drzewo" 0   {Otwórz pozosta³e i jej dalsze w oknie Drzewa}
menuText P ToolsTracker "¦ledzenie figur"  10 {Otwórz/zamknij okno ¶ledzenia figur} 
menuText P ToolsTraining "Szkolenie"  0 {Narzêdzia szkoleniowe (taktyka, debiuty,...)}
menuText P ToolsTacticalGame "Gra taktyczna"  0 {Zagraj w grê z taktyk±}
menuText P ToolsSeriousGame "Powa¿na gra"  0 {Zagraj w grze}
menuText P ToolsTrainOpenings "Otwory"  0 {Trenuj z repertuarem}
menuText P ToolsTrainReviewGame "Recenzja gry"  0 {Zgadnij odbywaj±ce siê w grze}
menuText P ToolsTrainTactics "Taktyka"  0 {Rozwi±¿ taktykê}
menuText P ToolsTrainCalvar "Obliczanie zmiany"  0 {Obliczanie zmian w treningu}
menuText P ToolsTrainFindBestMove "znajd¼ najlepszy ruch"  0 {znajd¼ najlepszy ruch}
menuText P ToolsTrainFics "Graj w internecie"  0 {Graj na freechess.org}
menuText P ToolsEngineTournament "Turniej silnikowy"  0 {Rozpocznij zawody pomiêdzy silnikami szachowymi}
menuText P ToolsTimeAnalysis "Analiza czasu" 0 {Poka¿ wykres czasu zegarowego dla bie¿±cej gry}
menuText P ToolsBookTuning "Strojenie ksi±¿ki" 0 {Strojenie ksi±¿ki}
menuText P ToolsDownloadTWIC "Pobierz gry TWIC" 0 {Pobierz najnowsze partie The Week In Chess (TWIC).}
menuText P ToolsConnectHardware "Pod³±cz sprzêt" 0 {Pod³±cz sprzêt zewnêtrzny}
menuText P ToolsConnectHardwareConfigure "Skonfiguruj..." 0 {Skonfiguruj sprzêt zewnêtrzny i po³±czenie}
menuText P ToolsConnectHardwareNovagCitrineConnect "Po³±cz Novag Cytryn" 0 {Po³±cz Novag Cytryn}
menuText P ToolsConnectHardwareInputEngineConnect "Pod³±cz zasilanie" 0 {Pod³±czenie zasilania (np. DGT)}

menuText P ToolsPInfo "Informacje o zawodniku"  0 \
  {Otwórz/od¶wie¿ okno informacji o zawodniku}
menuText P ToolsPlayerReport "Raport o graczu..." 9 \
  {Utwórz raport o graczu} 
menuText P ToolsRating "Wykres rankingu" 0 \
  {Wykres historii rankingu graj±cych partiê}
menuText P ToolsExpCurrent "Eksportuj partiê" 0 \
  {Zapisz partiê do pliku tekstowego}
menuText P ToolsExpCurrentPGN "Do pliku PGN..." 9 \
  {Zapisz partiê do pliku PGN}
menuText P ToolsExpCurrentHTML "Do pliku HTML..." 9 \
  {Zapisz partiê do pliku HTML}
menuText P ToolsExpCurrentHTMLJS "Eksportuj grê do pliku HTML i JavaScript..." 15 {Zapisz grê do pliku HTML i JavaScript}  
menuText P ToolsExpFilter "Eksportuj wyszukane partie" 1 \
  {Zapisz wyszukane partie do pliku tekstowego}
menuText P ToolsExpFilterPGN "Do pliku PGN..." 9 \
  {Zapisz wyszukane partie do pliku PGN}
menuText P ToolsExpFilterHTML "Do pliku HTML..." 9 \
  {Zapisz wyszukane partie do pliku HTML}
menuText P ToolsExpFilterHTMLJS "Eksportuj filtr do pliku HTML i JavaScript..." 17 {Zapisz wszystkie przefiltrowane gry w pliku HTML i JavaScript}  
menuText P ToolsImportOne "Wklej partiê w formacie PGN..." 0 \
  {Pobierz partiê z pliku PGN}
menuText P ToolsImportFile "Importuj plik PGN..." 2 \
  {Pobierz partie z pliku PGN}
menuText P ToolsStartEngine1 "Uruchomiony silnik 1" 0  {Uruchomiony silnik 1}
menuText P ToolsStartEngine2 "Uruchomiony silnik 2" 0  {Uruchomiony silnik 2}
menuText P ToolsCaptureBoard "Przechwyæ bie¿±c± tablicê..." 0  {Zapis bie¿±cej tablicy jako obrazu.}

# Play menu
menuText P Play "Graæ" 0

# --- Correspondence Chess
menuText P CCResign "Rezygnowaæ" 0 {Zrezygnuj (nie przez e-mail)}
menuText P CCClaimDraw "Zg³oszenie losowania" 0 {Wy¶lij ruch i postêpuj siê o losowanie (nie przez e-mail)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText P Options "Opcje" 0
menuText P OptionsBoardGraphics "Kwadraty..." 0 {Wybierz tekstury dla kwadratów}
translate P OptionsBGW {Wybierz teksturê kwadratów}
translate P OptionsBoardGraphicsText {Wybierz dokumenty graficzne dla bia³ych i czarnych kwadratów:}
menuText P OptionsBoardNames "Moje nazwiska" 0 {Modyfikuj listê moich graczy}
menuText P OptionsExport "Eksport" 0 {Zmieñ opcje eksportu tekstu}
menuText P OptionsFonts "Czcionka" 0 {Zmieñ font}
menuText P OptionsFontsRegular "Podstawowa" 0 {Zmieñ podstawow± czcionkê}
menuText P OptionsFontsMenu "Menu" 0 {Zmieñ czcionkê menu} 
menuText P OptionsFontsSmall "Ma³a" 0 {Zmieñ ma³± czcionkê}
menuText P OptionsFontsTiny "Malutki" 0 {Zmieñ ma³± czcionkê}
menuText P OptionsFontsFixed "Sta³a" 0 {Zmieñ czcionkê sta³ej szeroko¶ci}
menuText P OptionsGInfo "Informacje o partii" 0 {Sposób wy¶wietlania informacji o partii}
menuText P OptionsLanguage "Jêzyk" 0 {Wybierz jêzyk}
menuText P OptionsMovesTranslatePieces "Przet³umacz kawa³ki" 0 {Przet³umacz pierwsz± literê kawa³ków}
menuText P OptionsMovesHighlightLastMove "Podkre¶l ostatni ruch" 0 {Podkre¶l ostatni ruch}
menuText P OptionsMovesHighlightLastMoveDisplay "Poka¿ kwadrat" 0 {Wy¶wietlanie ostatniego ruchu Pod¶wietlenie}
menuText P OptionsMovesHighlightLastMoveWidth "Szeroko¶æ" 0 {Grubo¶æ linii}
menuText P OptionsMovesHighlightLastMoveColor "Kolor" 0 {Kolor linii}
menuText P OptionsMovesHighlightLastMoveArrow "Poka¿ strza³kê" 0 {Poka¿ strza³kê z pod¶wietleniem}
menuText P OptionsMovesHighlightLastMoveNag "Poka¿ symbol oceny" 0
menuText P OptionsMovesHighlightLastMoveEval "Poka¿ symbole oceny" 0
menuText P OptionsMoves "Posuniêcia" 0 {Wprowadzanie posuniêæ}
menuText P OptionsMovesAnimate "Szybko¶æ animacji" 1 \
  {Ustaw czas przeznaczony na animacjê jednego posuniêcia} 
menuText P OptionsMovesDelay "Automatyczne przegl±danie..." 0 \
  {Ustaw opó¼nienie przy automatycznym przegl±daniu partii}
menuText P OptionsMovesCoord "Posuniêcia w formacie \"g1f3\"" 0 \
  {Akceptuj posuniêcia wprowadzone w formacie "g1f3"}
menuText P OptionsMovesSuggest "Poka¿ proponowane posuniêcia" 1 \
  {W³±cz/wy³±cz proponowanie posuniêæ}
menuText P OptionsShowVarPopup "Poka¿ okno odmiany" 0 {W³±cz/wy³±cz wy¶wietlanie ró¿nych opcji okien}  
menuText P OptionsMovesSpace "Dodaj spacje po numerze ruchu" 0 {Dodaj spacje po numerze ruchu}  
menuText P OptionsMovesLichess "Format Lichess/ChessBase dla adnotacji" 0 {U¿yj formatu Lichess/ChessBase dla kwadratowych znaczników i strza³ek}
menuText P OptionsMovesKey "Automatyczne dope³nianie posuniêæ" 1 \
  {W³±cz/wy³±cz automatyczne dope³nianie posuniêæ wprowadzanych z klawiatury}
menuText P OptionsMovesShowVarArrows "Poka¿ strza³ki dla odmiany" 0 {W³±cz/wy³±cz napêd elektryczny w odmianach}
menuText P OptionsMovesShowEngineVariationArrows "Poka¿ strza³ki dla wersji silnika" 0 {W³±cz/wy³±cz strza³ki pokazuj±ce linie zmian silnika w trybie multiPV}
menuText P OptionsMovesGlossOfDanger "Kolorowy rozwi±zanie zagro¿enia" 0 {W³±cz/wy³±cz oznaczony kolorami po³ysku}
translate P OptionsMovesTreeDepth {Domy¶lna g³êboko¶æ przesuwania okna drzewa}
menuText P OptionsNumbers "Format zapisu liczb" 0 {Wybierz format zapisu liczb}
menuText P OptionsTheme "Temat" 0 {Zmieñ wygl±d interfejsu}
menuText P OptionsWindows "Okna" 0 {Opcje okien}
menuText P OptionsSounds "Sounds" 2 {Configure move announcement sounds} ;# ***
menuText P OptionsResources "Zasoby..." 0 {Wybierz pliki zasobów i folderów}
menuText P OptionsWindowsDock "Zadokuj okna" 0 {Zadokuj okna}
menuText P OptionsWindowsSaveLayout "Zapisz uk³ad" 0 {Zapisz uk³ad}
menuText P OptionsWindowsRestoreLayout "Przywróæ uk³ad" 0 {Przywróæ uk³ad}
menuText P OptionsWindowsShowGameInfo "Poka¿ informacje o grze" 0 {Poka¿ informacje o grze}
menuText P OptionsWindowsAutoLoadLayout "Automatyczne ³adowanie pierwszego uk³adu" 0 {Automatyczne ³adowanie wstêpne konfiguracji przy uruchomieniu}
menuText P OptionsECO "Wczytaj ksi±¿kê debiutow±" 16 \
  {Wczytaj plik z klasyfikacja debiutów}
menuText P OptionsSpell "Wczytaj plik sprawdzania pisowni..." 13 \
  {Wczytaj plik do sprawdzania pisowni nazwisk i nazw}
menuText P OptionsTable "Katalog z baz± koñcówek" 10 \
  {Wybierz bazê koñcówek; u¿yte zostan± wszystkie bazy z tego katalogu}
menuText P OptionsRecent "Ostatnie pliki..." 0 \
  {Zmieñ liczbê ostatnio otwartych plików, wy¶wietlanych w menu Plik} 
menuText P OptionsBooksDir "Katalog ksi±¿ek" 0 {Ustawia katalogów ksi±¿ek otwieraj±cych}
menuText P OptionsTacticsBasesDir "Baza katalogów" 0 {Ustawia katalogów baz taktycznych (szkoleniowych).}
menuText P OptionsPhotosDir "Katalog zdjêæ" 0 {Ustawia katalog baz zdjêæ}
menuText P OptionsThemeDir "Plik plików"  0 {Za³aduj plik motywu GUI}
menuText P OptionsSave "Zapamiêtaj opcje" 0 \
  "Zapamiêtaj wszystkie ustawienia w pliku $::optionsFile"
menuText P OptionsAutoSave "Automatycznie zapisuj opcje" 0 \
  {Automatycznie zapisz opcje przy zamykaniu programu}

# Help menu:
menuText P Help "Pomoc" 2
menuText P HelpContents "Contents" 0 {Poka¿ spis tre¶ci pomocy} 
menuText P HelpIndex "Spis tre¶ci" 0 {Poka¿ indeks pomocy}
menuText P HelpGuide "Krótki przewodnik" 0 {Poka¿ krótki przewodnik}
menuText P HelpHints "Podpowiedzi" 0 {Poka¿ podpowiedzi}
menuText P HelpContact "Informacja o autorze" 0 \
  {Poka¿ informacjê o autorze i stronie Scid-a}
menuText P HelpTip "Porada dnia" 0 {Poka¿ poradê Scida}
menuText P HelpStartup "Okno powitalne" 2 {Pokazuj okno startowe}
menuText P HelpAbout "O programie" 0 {Informacje o programie Scid}

# Toolbar tooltips:
menuText P RotateBoard "Obróæ planszê" 0 {Obróæ planszê}

# Game info box popup menu:
menuText P GInfoHideNext "Ukryj nastêpne posuniêcie" 0
menuText P GInfoMaterial "Poka¿ materia³" 0
menuText P GInfoFEN "Poka¿ pozycjê w formacie FEN" 16
menuText P GInfoMarks "Pokazuj kolorowe pola i strza³ki" 5 
menuText P GInfoWrap "Zawijaj d³ugie linie" 0
menuText P GInfoFullComment "Poka¿ ca³y komentarz" 6
menuText P GInfoPhotos "Poka¿ zdjêcia" 5
menuText P GInfoTBNothing "Tablica koñcówek: nic" 0
menuText P GInfoTBResult "Tablica koñcówek: tylko wynik" 18
menuText P GInfoTBAll "Tablica koñcówek: wszystko" 18
menuText P GInfoDelete "Usuñ/przywróæ tê partiê" 0
menuText P GInfoMark "W³±cz/wy³±cz zaznaczenie tej partii" 0
menuText P GInfoInformant "Skonfiguruj warto¶ci informatora" 0

# General buttons:
translate P Back {Z powrotem}
translate P Browse {Przegl±daj}
translate P Cancel {Anuluj}
translate P Continue {Kontynuowaæ}
translate P Clear {Wyczy¶æ}
translate P Close {Zamknij}
translate P Contents {Spis tre¶ci}
translate P Defaults {Domy¶lne}
translate P InvertSearch {Odwróæ wyszukiwanie}
translate P Delete {Usuñ}
translate P Graph {Wykres}
translate P Help {Pomoc}
translate P Hide {Ukrywaæ}
translate P Import {Pobierz}
translate P Index {Indeks}
translate P LoadGame {Wczytaj partiê}
translate P BrowseGame {Przegl±daj partiê}
translate P MergeGame {Do³±cz partiê}
translate P MergeGames {W³±cz grê}
translate P Preview {Podgl±d}
translate P Revert {Odwróæ}
translate P Save {Zapisz}
translate P Search {Szukaj}
translate P Stop {Stop}
translate P Store {Zapamiêtaj}
translate P Update {Uaktualnij}
translate P ChangeOrient {Zmieñ po³o¿enie okna}
translate P ShowIcons {Show Icons} ;# ***
translate P None {Brak}
translate P First {Pierwsza}
translate P Current {Aktualn±}
translate P Last {Ostatni±}

# General messages:
translate P game {partia}
translate P games {partie}
translate P move {posuniêcie}
translate P moves {pos.}
translate P all {wszystkie}
translate P Yes {Tak}
translate P No {Nie}
translate P Both {Oba}
translate P King {Król}
translate P Queen {Hetman}
translate P Rook {Wie¿a}
translate P Bishop {Goniec}
translate P Knight {Skoczek}
translate P Pawn {Pion}
translate P White {Bia³e}
translate P Black {Czarne}
translate P Player {Gracz}
translate P Rating {Ranking}
translate P RatingDiff {Ró¿nica rankingów}
translate P AverageRating {¦redni ranking}
translate P Event {Turniej}
translate P Site {Miejsce}
translate P Country {Kraj}
translate P IgnoreColors {Ignoruj kolory}
translate P Date {Data}
translate P EventDate {Turniej data}
translate P Decade {Dekada} 
translate P Year {Rok}
translate P Month {Miesi±c}
translate P Months {Styczeñ Luty Marzec Kwiecieñ Maj Czerwiec Lipiec Sierpieñ Wrzesieñ Pa¼dziernik Listopad Grudzieñ}
translate P Days {N Pn Wt ¦r Cz Pt So}
translate P YearToToday {Ostatni rok}
translate P YearToTodayTooltip {Ustaw datê od 1 roku wstecz do dzisiaj}
translate P Result {Wynik}
translate P Round {Runda}
translate P Length {D³ugo¶æ}
translate P ECOCode {Kod ECO}
translate P ECO {ECO}
translate P Deleted {Usuniêta}
translate P SearchResults {Wyniki wyszukiwania}
translate P OpeningTheDatabase "Otwieranie bazy"
translate P Database {Bazy}
translate P Filter {Filtr}
translate P noGames {brak partii}
translate P allGames {wszystkie partie}
translate P empty {brak}
translate P clipbase {schowek}
translate P score {punkty}
translate P StartPos {Pozycja pocz±tkowa}
translate P Total {Razem}
translate P readonly {tylko do odczytu}

# Standard error messages:
translate P ErrNotOpen {To nie jest otwarta baza.} 
translate P ErrReadOnly {Ta baza jest tylko do odczytu; nie mo¿na jej zmieniæ.}
translate P ErrSearchInterrupted {Wyszukiwanie zosta³o przerwane. Wyniki bêd± niepe³ne.}
translate P ErrNoClockComments {W tej grze nie znaleziono komentarzy do zegara [%clk].    Dodaj czasy zegara za pomoc± okna komentarzy (Ctrl+E), aby skorzystaæ z tej funkcji.}
translate P ErrFileInUse {B³±d: plik jest ju¿ u¿ywany. Zamknij ka¿d± inn± aplikacjê korzystaj±c± z tej bazy danych. Je¶li program zosta³ nieoczekiwanie zamkniêty, mo¿e byæ konieczne usuniêcie pliku .lock powi±zanego z baz± danych.}




# Game information:
translate P twin {powtórzona}
translate P deleted {usuniêta}
translate P comment {komentarz}
translate P hidden {ukryte}
translate P LastMove {Poprzednie}
translate P NextMove {nastêpne}
translate P GameStart {Pocz±tek partii}
translate P LineStart {Pocz±tek wariantu}
translate P GameEnd {Koniec partii}
translate P LineEnd {Koniec wariantu}

# Player information:
translate P PInfoAll {Wyniki - <b>wszystkie</b> partie}
translate P PInfoFilter {Wyniki - partie z <b>filtra</b>}
translate P PInfoAgainst {Wyniki - }
translate P PInfoMostWhite {Najczêstsze debiuty bia³ymi}
translate P PInfoMostBlack {Najczêstsze debiuty czarnymi}
translate P PInfoRating {Historia rankingu}
translate P PInfoBio {Biografia}
translate P PInfoEditRatings {Modyfikuj rankingi} 
translate P PInfoEloFile {Plik}

# Tablebase information:
translate P Draw {remis}
translate P with {po}
translate P only {tylko}
translate P lose {przegrywaj±}
translate P loses {przegrywa}

# Tip of the day:
translate P Tip {Porada}
translate P TipAtStartup {Poka¿ poradê przy starcie}
translate P TipConvertPGN {Mo¿esz uzyskaæ produkt, konwertuj±c pliki PGN}

# Tree window menus:
menuText P TreeFile "Plik" 0
menuText P TreeFileFillWithBase "Wype³nij pamiêæ podrêczn± baz±" 0 {Wype³nij plik pamiêci podrêcznej, który dzia³a grami w codziennej praktyce}
menuText P TreeFileFillWithGame "Wype³nij pamiêæ podrêczn± gr±" 0 {Wype³nij plik pamiêci podrêcznej bie¿±cej gry w regularnej grze}
menuText P TreeFileSetCacheSize "Rozmiar pamiêci podrêcznej" 0 {Ustaw rozmiar pamiêci podrêcznej}
menuText P TreeFileCacheInfo "Informacje o pamiêci podrêcznej" 0 {Uzyskaj informacje o pamiêci podrêcznej}
menuText P TreeFileSave "Zapisz bufor" 7 {Zapisz plik bufora (.stc)}
menuText P TreeFileFill "Twórz standardowy plik cache" 0 {Wstaw typowe pozycje debiutowe do bufora}
menuText P TreeFileBest "Najlepsze partie" 0 {Poka¿ listê najlepszych partii}
menuText P TreeFileGraph "Poka¿ wykres" 0 {Poka¿ wykres dla tej ga³êzi drzewa}
menuText P TreeFileCopy "Kopiuj drzewo do schowka" 0 \
  {Skopiuj drzewo ze statystykami do schowka}
menuText P TreeFileClose "Zamknij" 0 {Zamknij okno drzewa}
menuText P TreeMask "Maska" 0
menuText P TreeMaskNew "Nowy" 0 {Nowa maska}
menuText P TreeMaskOpen "Otwórz" 0 {Otwórz maskê}
menuText P TreeMaskOpenRecent "Otwórz ostatnio" 0 {Otwórz ostatni± maskê}
menuText P TreeMaskSave "Ratowaæ" 0 {Zapisz maskê}
menuText P TreeMaskClose "Zamkn±æ" 0 {Zamknij maskê}
menuText P TreeMaskFillWithGame "Wype³nij grê" 0 {Wype³nij maskê gry}
menuText P TreeMaskFillWithBase "Wype³nij bazê" 0 {Wype³nij maskê suplementami grami w cieczy}
menuText P TreeMaskInfo "Informacje" 0 {Poka¿ statystyki dla masek bie¿±cych}
menuText P TreeMaskDisplay "Wy¶wietl mapê maski" 0 {Poka¿ dane maski w formie drzewa}
menuText P TreeMaskSearch "Szukaj" 0 {Szukaj w bie¿±cej masce}
menuText P TreeSort "Sortowanie" 0
menuText P TreeSortAlpha "Alfabetycznie" 0
menuText P TreeSortECO "Kod ECO" 0
menuText P TreeSortFreq "Czêsto¶æ" 0
menuText P TreeSortScore "Punkty" 0
menuText P TreeOpt "Opcje" 0
menuText P TreeOptSlowmode "tryb powolny" 0 {Tryb powolnego aktualizacji (wysoka dodatkowa)}
menuText P TreeOptFastmode "Tryb szybki" 0 {Szybki tryb aktualizacji (bez transpozycji ruchu)}
menuText P TreeOptFastAndSlowmode "Tryb szybki i wolny" 0 {Tryb szybki, nastêpnie tryb wolny w celu aktualizacji}
menuText P TreeOptStartStop "Automatyczne od¶wie¿anie" 0 {W³±cza siê automatycznie od¶wie¿anie okna}
menuText P TreeOptLock "Blokada" 0 {Zablokuj/odblokuj drzewo na aktualnej bazie}
menuText P TreeOptTraining "Trening" 0 {W³±cz/wy³±cz tryb treningowy}
menuText P TreeOptDepth "Przesuñ g³êboko¶æ" 0 {Liczba po³ówek ruchów do wy¶wietlenia w drzewie (1-4)}
menuText P TreeOptAutosave "Automatyczny zapis bufora" 0 \
  {Automatycznie zapisz plik bufora przy wyj¶ciu}
menuText P TreeHelp "Pomoc" 2
menuText P TreeHelpTree "Drzewo" 0
menuText P TreeHelpIndex "Spis tre¶ci" 0
translate P SaveCache {Zapisz bufor}
translate P Training {Trening}
translate P LockTree {Blokada}
translate P TreeDepth {G³êboko¶æ drzewa (po³owa ruchów):}
translate P TreeLocked {zablokowane}
translate P TreeBest {Najlepsze}
translate P TreeBestGames {Najlepsze partie}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate P TreeTitleRow \
{Pos.                          ECO       Czêsto¶æ     Wynik  Rav   Rperf Rok   %Remis   %Wygraæ}
translate P TreeTotal {RAZEM}
translate P DoYouWantToSaveFirst {Czy najpierw chcesz siê zapisaæ?}
translate P AddToMask {Dodaj do maski}
translate P RemoveFromMask {Usuñ z maski}
translate P AddThisMoveToMask {Dodaj dziesiêæ ruchu do Maski}
translate P SearchMask {Szukaj w masie}
translate P DisplayMask {Wy¶wietl maskê}
translate P Nag {Kod Naga}
translate P Marker {Znacznik}
translate P Include {W³±cz}
translate P Exclude {Wykluczyæ}
translate P MainLine {Magistrala}
translate P Bookmark {Zak³adka w ksi±¿ce}
translate P NewLine {Nowa linia}
translate P ToBeVerified {Sprawd¼}
translate P ToTrain {Trenowaæ}
translate P Dubious {W±tpliwy}
translate P ToRemove {Aby usun±æ}
translate P NoMarker {Brak znacznika}
translate P ColorMarker {Kolor}
translate P WhiteMark {Bia³y}
translate P GreenMark {Zielony}
translate P YellowMark {¯ó³ty}
translate P BlueMark {Niebieski}
translate P RedMark {Czerwony}
translate P CommentMove {Komentarz ruchu}
translate P CommentPosition {Stanowisko komentarza}
translate P AddMoveToMaskFirst {Najpierw dodaj ruch do maski}
translate P OpenAMaskFileFirst {Najpierw otwórz plik maski}
translate P Positions {Pozycja}
translate P Moves {Porusza siê}

# Finder window:
menuText P FinderFile "Plik" 0
menuText P FinderFileSubdirs "Przeszukuj podkatalogi" 0
menuText P FinderFileClose "Zamknij wyszukiwacza plików" 0
menuText P FinderSort "Sortowanie" 0
menuText P FinderSortType "Typ" 0
menuText P FinderSortSize "Rozmiar" 0
menuText P FinderSortMod "Zmieniony" 0
menuText P FinderSortName "Nazwa" 0
menuText P FinderSortPath "¦cie¿ka" 0
menuText P FinderTypes "Typy" 0
menuText P FinderTypesScid "Bazy Scid-a" 0
menuText P FinderTypesOld "Bazy Scid-a (stary format)" 1
menuText P FinderTypesPGN "Pliki PGN" 0
menuText P FinderTypesEPD "Ksi±¿ki debiutowe EPD" 0
menuText P FinderTypesRep "Pliki repertuaru debiutowego" 0
menuText P FinderHelp "Pomoc" 2
menuText P FinderHelpFinder "Pomoc poszukiwacza plików" 1
menuText P FinderHelpIndex "Spis tre¶ci" 0
translate P FileFinder {Poszukiwacz plików}
translate P FinderDir {Katalog}
translate P FinderDirs {Katalogi}
translate P FinderFiles {Pliki}
translate P FinderUpDir {wy¿ej}
translate P FinderCtxOpen {Otwórz}
translate P FinderCtxBackup {Kopia zapasowa}
translate P FinderCtxCopy {Kopia}
translate P FinderCtxMove {Przenie¶æ}
translate P FinderCtxDelete {Usuwaæ}

# Player finder:
menuText P PListFile "Plik" 0
menuText P PListFileUpdate "Uaktualnij" 0
menuText P PListFileClose "Zamknij przegl±darkê zawodników" 0
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
menuText P TmtSortWinner "Zwyciêzca" 0
translate P TmtLimit "Wielko¶æ listy"
translate P TmtMeanElo "Min. ¶rednie ELO"
translate P TmtNone "Nie znaleziono turniejów."

# Graph windows:
menuText P GraphFile "Plik" 0
menuText P GraphFileColor "Zapisz jako kolorowy PostScript" 12
menuText P GraphFileGrey "Zapisz jako zwyk³y PostScript..." 0
menuText P GraphFileClose "Zamknij okno" 6
menuText P GraphOptions "Opcje" 0
menuText P GraphOptionsWhite "Bia³e" 0
menuText P GraphOptionsBlack "Czarne" 0
menuText P GraphOptionsBoth "Oba kolory" 1
menuText P GraphOptionsPInfo "Gracz z Informacji o graczu" 0
menuText P GraphOptionsEloFile "Elo z pliku oceny" 0
menuText P GraphOptionsEloDB "Elo z bazy danych" 0
translate P GraphFilterTitle "Filtr: czêsto¶æ na 1000 partii" 
translate P GraphAbsFilterTitle "Wykres filtr: szkoda gier"
translate P ConfigureFilter {Skonfiguruj osie X dla roku, ocena i decyzja}
translate P FilterEstimate "Oszacowaæ"
translate P TitleFilterGraph "Scid: Filtr wykresów"

# Analysis window:
translate P AddVariation {Dodaj wariant}
translate P AddAllVariations {Dodaj wszystkie rozwi±zania}
translate P AddMove {Dodaj posuniêcie}
translate P Annotate {Komentuj}
translate P ShowAnalysisBoard {Poka¿ tablicê angielsk±}
translate P ShowInfo {Poka¿ informacje o silniku}
translate P FinishGame {Zakoñcz grê}
translate P StopEngine {Zatrzymaj silnik}
translate P StartEngine {Uruchomiony silnik}
translate P LockEngine {Zablokuj silnik w pozycjach bie¿±cych}
translate P AnalysisCommand {Program do analizy}
translate P PreviousChoices {Poprzednie programy}
translate P AnnotateTime {Czas miêdzy ruchami (w sekundach)}
translate P AnnotateWhich {Dodaj warianty}
translate P AnnotateAll {Dla obu stron}
translate P AnnotateAllMoves {Opisz wszystkie wystêpy}
translate P AnnotateWhite {Dla bia³ych}
translate P AnnotateBlack {Dla czarnych}
translate P AnnotateBlundersOnly {Kiedy ruch w grze jest oczywistym wykluczeniem}
translate P AnnotateBlundersOnlyScoreChange {Analiza b³êdu i wyniku z/na:}
translate P BlundersThreshold {Wa³ówka}
translate P ScoreAllMoves {Score all moves}
translate P LowPriority {Niski priorytet CPU} 
translate P ClickHereToSeeMoves {Kliknij tutaj, aby zobaczyæ wystêp}
translate P ConfigureInformant {Skonfiguruj Informatora}
translate P Informant!? {Ciekawe polip}
translate P Informant? {S³abe posuniêcie}
translate P Informant?? {Pomy³ka}
translate P Informant?! {W±tpliwe polip}
translate P Informant+= {Bia³e wyposa¿enie dodatkowe}
translate P Informant+/- {Bia³e umiarkowanie stosowane}
translate P Informant+- {Bia³e maj± zdecydowan± wersjê}
translate P Informant+-- {Bia³e maj± mia¿d¿±ce zastosowanie}
translate P AutoComment {Automatyczny komentarz}
translate P AutoCommentTooltip {Wygeneruj komentarz AI dla aktualnej pozycji}
translate P AnalysisAutoCommentTooltip {Generuj komentarz AI dla ca³ej gry}
translate P GameComment {Komentarz do gry}
translate P TimeMs {Czas (ms)}

# Book window
translate P Book {Ksi±¿ka}
translate P OtherBookMoves {Ksi±¿ka przeciwstawiaj±ca siê}
translate P OtherBookMovesTooltip {Ruchy, na które przeciwnik ma odpowied¼}

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
translate P EngineRequired {Pola wyt³uszczone s± konieczne; reszta opcjonalna} 
translate P EngineProtocol {Protokó³ komunikacyjny}
translate P EngineNotation {Notacja zale¿na}
translate P EngineFlipEvaluation {Odwróæ perspektywê oceny}
translate P EngineShowLog {Poka¿ dziennik komunikacji}
translate P EngineNetworkd {Akceptuj po³±czenie zdalne}
translate P EngineSelect {Wybierz po³±czenie silnika}
translate P EngineAddLocal {Dodaj silnik lokalny}
translate P EngineAddRemote {Dodaj od³±czalny silnik}
translate P EngineReload {Za³aduj ponownie rozruch}
translate P EngineClone {Utwórz bazê g³ówn±}
translate P EngineDelete {Usuñ uruchomienie silnika}

# PGN window menus:
menuText P PgnFile "Plik" 0
menuText P PgnFileCopy "Kopiuj partiê do schowka" 0
menuText P PgnFilePrint "Zapisz do pliku..." 7
menuText P PgnFileClose "Zamknij" 0
menuText P PgnOpt "Wygl±d" 0
menuText P PgnOptColor "Wy¶wietlanie w kolorach" 0
menuText P PgnOptShort "Krótki (3-wierszowy) nag³ówek" 0
menuText P PgnOptSymbols "Symbole Informatora" 0
menuText P PgnOptIndentC "Wcinaj komentarze" 7
menuText P PgnOptIndentV "Wcinaj warianty" 7
menuText P PgnOptColumn "Kolumny (jedno posuniêcie w wierszu)" 0
menuText P PgnOptSpace "Spacja po numerze ruchu" 0
menuText P PgnOptStripMarks "Usuñ kody kolorowych pól i strza³ek" 0
menuText P PgnOptBoldMainLine "Use Bold Text for Main Line Moves" 4 ;# ***
menuText P PgnColor "Kolory" 0
menuText P PgnColorHeader "Nag³ówek..." 0
menuText P PgnColorAnno "Uwagi..." 3
menuText P PgnColorComments "Komentarze..." 0
menuText P PgnColorVars "Warianty..." 0
menuText P PgnColorBackground "T³o..." 0
menuText P PgnColorMain "Magistrala..." 0
menuText P PgnColorCurrent "Bie¿±ce t³o ruchu..." 1
menuText P PgnHelp "Pomoc" 2
menuText P PgnHelpPgn "PGN" 0
menuText P PgnHelpIndex "Spis tre¶ci" 0
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
menuText P CrosstabOpt "Wy¶wietlanie" 0
menuText P CrosstabOptAll "Turniej ko³owy" 0
menuText P CrosstabOptSwiss "Szwajcar" 0
menuText P CrosstabOptKnockout "Knockout" 0
menuText P CrosstabOptAuto "Automatycznie" 0
menuText P CrosstabOptAges "Wiek" 0
menuText P CrosstabOptNats "Narodowo¶æ" 0
menuText P CrosstabOptRatings "Ranking" 0
menuText P CrosstabOptTitles "Tytu³" 0
menuText P CrosstabOptBreaks "Punkty pomocnicze" 1
menuText P CrosstabOptDeleted "Uwzglêdniaj usuniête partie" 0
menuText P CrosstabOptColors "Kolory (tylko szwajcar)" 0
menuText P CrosstabOptColumnNumbers "Numerowane kolumny (tylko turniej ko³owy)" 0
menuText P CrosstabOptGroup "Grupuj po liczbie punktów" 0
menuText P CrosstabSort "Sortowanie" 0
menuText P CrosstabSortName "Nazwisko" 0
menuText P CrosstabSortRating "Ranking" 0
menuText P CrosstabSortScore "Punkty" 0
menuText P CrosstabColor "Kolor" 0
menuText P CrosstabColorPlain "Zwyk³y tekst" 0
menuText P CrosstabColorHyper "Hipertekst" 0
menuText P CrosstabHelp "Pomoc" 2
menuText P CrosstabHelpCross "Tabela turniejowa" 0
menuText P CrosstabHelpIndex "Spis tre¶ci" 0
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
menuText P OprepFavoritesGenerate "Twórz raporty..." 0 
menuText P OprepHelp "Pomoc" 2
menuText P OprepHelpReport "Pomoc raportu debiutowego" 0
menuText P OprepHelpIndex "Spis tre¶ci" 0

# Header search:
translate P HeaderSearch {Wyszukiwanie wg nag³ówka}
translate P EndSideToMove {Side to move at end of game} ;# ***
translate P GamesWithNoECO {Partie bez ECO?}
translate P GameLength {D³ugo¶æ}
translate P FindGamesWith {Znajd¼ partie}
translate P StdStart {ca³a partia}
translate P Promotions {z promocj±}
translate P Comments {Komentarze}
translate P Variations {Warianty}
translate P Annotations {Uwagi}
translate P DeleteFlag {Usuwanie}
translate P WhiteOpFlag {Debiut - bia³e}
translate P BlackOpFlag {Debiut - czarne}
translate P MiddlegameFlag {Gra ¶rodkowa}
translate P EndgameFlag {Koñcówka}
translate P NoveltyFlag {Nowinka}
translate P PawnFlag {Struktura pionowa}
translate P TacticsFlag {Taktyka}
translate P QsideFlag {Gra na skrzydle hetmañskim}
translate P KsideFlag {Gra na skrzydle królewskim}
translate P BrilliancyFlag {Nagroda za piêkno¶æ}
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
translate P GlistWhite {Bia³e}
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
translate P GlistLength {D³ugo¶æ}
translate P GlistCountry {Kraj}
translate P GlistECO {ECO}
translate P GlistOpening {Debiut}
translate P GlistEndMaterial {Materia³}
translate P GlistDeleted {Usuniêta}
translate P GlistFlags {Oznaczenie}
translate P GlistVars {Warianty}
translate P GlistComments {Komentarze}
translate P GlistAnnos {Uwagi}
translate P GlistStart {Pozycja pocz±tkowa}
translate P GlistGameNumber {Numer partii}
translate P GlistAverageElo {Przeciêtny Elo}
translate P GlistRating {Ocena}
translate P GlistFindText {Znajd¼ tekst}
translate P GlistMoveField {Przesuñ}
translate P GlistEditField {Konfiguruj}
translate P GlistAddField {Dodaj}
translate P GlistDeleteField {Usuñ}
translate P GlistWidth {Szeroko¶æ}
translate P GlistAlign {Wyrównanie}
translate P GlistAlignL {Wyrównaj: w lewo}
translate P GlistAlignR {Wyrównanie: prawda}
translate P GlistAlignC {Wyrównaj: do ¶rodka}
translate P GlistColor {Kolor}
translate P GlistSep {Separator}
translate P GlistCurrentSep {-- Aktualny --}
translate P GlistNewSort {Nowy}
translate P GlistAddToSort {Koniec}

# base sorting
translate P GsortSort {Sortowaæ...}
translate P GsortDate {Dane}
translate P GsortYear {Rok}
translate P GsortEvent {Wydarzenie}
translate P GsortSite {Strona}
translate P GsortRound {Okr±g³e}
translate P GsortWhiteName {Bia³e imiê}
translate P GsortBlackName {Czarne imiê}
translate P GsortECO {EKO}
translate P GsortResult {Wynik}
translate P GsortMoveCount {Przenie¶ miejsce}
translate P GsortAverageElo {Przeciêtny Elo}
translate P GsortCountry {Kraj}
translate P GsortDeleted {Usuniêto}
translate P GsortEventDate {Dane wydarzenia}
translate P GsortWhiteElo {Bia³e Elo}
translate P GsortBlackElo {Czarne Elo}
translate P GsortComments {Uwagi}
translate P GsortVariations {Wariacje}
translate P GsortNAGs {GDERAÆ}
translate P GsortAscending {Rosn±co}
translate P GsortDescending {Malej±co}
translate P GsortAdd {Koniec}
translate P GsortStore {Sklep}
translate P GsortLoad {Obci±¿enie}

# menu shown with right mouse button down on game list.
translate P GlistRemoveThisGameFromFilter  {Usuñ tê grê z filtrem}
translate P GlistRemoveGameAndAboveFromFilter  {Usuñ grê (i wszystko nad ni±) z filtrem}
translate P GlistRemoveGameAndBelowFromFilter  {Usuñ grê (i wszystko poni¿ej) z filtrem}
translate P GlistDeleteGame {(Nie)Usuñ tê grê} 
translate P GlistDeleteAllGames {Usuñ wszystkie gry z filtrem} 
translate P GlistUndeleteAllGames {Przywróæ wszystkie gry w filtrze} 
translate P GlistMergeGameInBase {Mo¿liwo¶æ pod³±czenia gry w innej postaci} 

# Maintenance window:
translate P DatabaseName {Nazwa bazy:}
translate P TypeIcon {Ikona:}
translate P NumOfGames {Liczba partii:}
translate P NumDeletedGames {Liczba usuniêtych partii:}
translate P NumFilterGames {Liczba partii w filtrze:}
translate P YearRange {Data:}
translate P RatingRange {Ranking:}
translate P Description {Opis} 
translate P Flag {Oznaczenie:}
translate P CustomFlags {Flagi prywatne}
translate P DeleteCurrent {Usuñ aktualn± partiê}
translate P DeleteFilter {Usuñ partie z filtra}
translate P DeleteAll {Usuñ wszystkie partie}
translate P UndeleteCurrent {Odzyskaj aktualn± partiê}
translate P UndeleteFilter {Odzyskaj partie z filtra}
translate P UndeleteAll {Odzyskaj wszystkie partie}
translate P DeleteTwins {Usuñ powtórzone partie}
translate P MarkCurrent {Zaznacz aktualn± partiê}
translate P MarkFilter {Zaznacz partie z filtra}
translate P MarkAll {Zaznacz wszystkie partie z filtra}
translate P UnmarkCurrent {Usuñ zaznaczenie aktualnej partii}
translate P UnmarkFilter {Usuñ zaznaczenie partii z filtra}
translate P UnmarkAll {Usuñ zaznaczenie wszystkich partii}
translate P Spellchecking {Pisownia}
translate P Players {Zawodnicy}
translate P Events {Turnieje}
translate P Sites {Miejsca}
translate P Rounds {Rundy}
translate P DatabaseOps {Operacje bazodanowe}
translate P ReclassifyGames {Klasyfikacja debiutowa}
translate P CompactDatabase {Uporz±dkuj bazê}
translate P SortDatabase {Sortuj bazê}
translate P AddEloRatings {Dodaj rankingi ELO}
translate P AutoloadGame {Domy¶lna partia}
translate P StripTags {Usuñ znaczniki PGN} 
translate P StripTag {Usuñ znacznik}
translate P Cleaner {Zestaw zadañ}
translate P CleanerHelp {
Zestaw zadañ pozwala wykonaæ od razu kilka operacji porz±dkowania bazy. Operacje wybrane z listy
zostan± wykonane na aktualnej bazie.

Do klasyfikacji debiutowej i usuwania powtórzonych partii u¿yte zostan± aktualne ustawienia.
}
translate P CleanerConfirm {
Kiedy wykonanie zestawu zadañ zostanie rozpoczête, nie bêdzie mo¿na ju¿ go przerwaæ.

Na du¿ej bazie mo¿e to zaj±æ du¿o czasu (zale¿y to równie¿ od wybranego zestawu zadañ i ich
ustawieñ).

Na pewno wykonaæ wybrane zadania?
}
# Twinchecker
translate P TwinCheckUndelete {odwróciæ; ty? przywróciæ oba)}
translate P TwinCheckprevPair {Poprzednia ust}
translate P TwinChecknextPair {Nastêpna ust}
translate P TwinChecker {Scid: Kontroler gier bli¼niaczych}
translate P TwinCheckTournament {Gry w wykonaniu:}
translate P TwinCheckNoTwin {¯adnego bli¼niaka}
translate P TwinCheckNoTwinfound {W tej grze nie wykryto bli¼niaków.\nAby bli¼niaki w tym oknie, nale¿y najpierw zwróciæ uwagê na ?Usuñ gry bli¼niacze?.}
translate P TwinCheckTag {Udostêpnij tagi...}
translate P TwinCheckFound1 {Scid bli¼niacze gry $result}
translate P TwinCheckFound2 {i ustaw ich flagi usuniêcia}
translate P TwinCheckNoDelete {W tej zawarto¶ci danych nie ma gier do usuniêcia.}
translate P TwinCriteria1 {Twoje urz±dzenia wyszukiwania bli¼niaczych mog± byæ umieszczone, ¿e gry inne ni¿ bli¼niacze z urz±dzeniami wyposa¿onymi w oznaczone jako bli¼niacze.}
translate P TwinCriteria2 {Zalecane jest, aby w przypadku wybrania opcji ?Nie? dla ?tych samodzielnie? wybierz ?Tak? dla zagro¿eñ, wydarzenia, miejsca, rundy, roku i miesi±ca.\nCzy chcesz mimo to chcieæ i usun±æ bli¼niaki?}
translate P TwinCriteria3 {Zalecane jest wybranie opcji ?Tak? dla dwóch u¿ytkowników ?ta sama witryna?, ?ta sama runda? i ?ten sam rok?.\nCzy mimo to chcesz usun±æ i usun±æ bli¼niaki?}
translate P TwinCriteriaConfirm {Scid: Potwierd¼ ustawienia bli¼niacze}
translate P TwinChangeTag "Zmieñ Zmieñ tagi gry:\n\n"
translate P AllocRatingDescription "Aby zastosowaæ kontrolê sprawdzania pisowni, nale¿y sprawdziæ Elo do gier w tej danych. Je¶li gracz nie ma aktualnej oceny, ale jego w momencie gry jest podana w pliku sprawdzania pisowni, ocena ta zostanie dodana."
translate P RatingOverride "Za uzupe³nienie niezerowe uwagi?"
translate P AddRatings "Dodaj ocenê do:"
translate P AddedRatings {Scid doda³i ranking Elo $r w grach za $g.}

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
translate P WhiteCrushing {Bia³e maj± mia¿d¿±ce zastosowanie}
translate P BlackCrushing {Czarne maj± mia¿d¿±ce zastosowanie}
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
translate P SearchBoardPawns {Pionki (ten sam materia³, pionki na tych samych polach)}
translate P SearchBoardFiles {Kolumny (ten sam materia³, pionki na tych samych kolumnach)}
translate P SearchBoardAny {Materia³ (ten sam materia³, pozycja dowolna)}
translate P SearchInRefDatabase {Szukaj w zawarto¶ci}
translate P LookInVars {Przeszukuj warianty}

# Material search:
translate P MaterialSearch {Wyszukiwanie wg materia³u}
translate P Material {Materia³}
translate P Patterns {Wzorce}
translate P Zero {Brak}
translate P Any {Dowolny}
translate P CurrentBoard {Aktualna pozycja}
translate P CommonEndings {Typowe koñcówki}
translate P CommonPatterns {Typowe wzorce}
translate P MaterialDiff {Przewaga materialna}
translate P squares {pola}
translate P SameColor {jednopolowe}
translate P OppColor {ró¿nopolowe}
translate P Either {dowolne}
translate P MoveNumberRange {Zakres posuniêæ}
translate P MatchForAtLeast {Pasuje min.}
translate P HalfMoves {pó³ruchy}

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
translate P InitialBoard {Pozycja pocz±tkowa}
translate P SideToMove {Na posuniêciu}
translate P MoveNumber {Posuniêcie nr}
translate P Castling {Roszada}
translate P EnPassantFile {Bicie w przelocie}
translate P ClearFen {Kopiuj FEN}
translate P PasteFen {Wklej pozycjê FEN}

translate P SaveAndContinue {Zapisz i pamiêtaj}
translate P DiscardChangesAndContinue {Odrzuæ zmianê\i wcze¶niej}
translate P GoBack {Wracaj±c}

# Replace move dialog:
translate P ReplaceMove {Zmieñ posuniêcie}
translate P AddNewVar {Dodaj wariant}
translate P NewMainLine {Nowa linia g³ówna}
translate P ReplaceMoveMessage {Posuniêcie ju¿ istnieje.

Mo¿esz je zast±piæ, usuwaj±c dalszy ci±g partii lub dodaæ nowy wariant.

(Mo¿na wy³±czyæ to ostrze¿enie, wy³±czaj±c opcjê  "Zapytaj przed zast±pieniem posuniêæ" w menu
Opcje:Posuniêcia)}

# Make database read-only dialog:
translate P ReadOnlyDialog {Je¶li zabezpieczysz tê bazê przed zapisem, zmiany bêd± zablokowane
¯adna partia nie bêdzie zapisana ani zmodyfikowana, ¿adne flagi nie bêd± zmienione.
Sortowanie i klasyfikacja debiutowa bêd± tylko tymczasowe.

¯eby usun±æ zabezpieczenie przez zapisem, wystarczy zamkn±æ bazê i otworzyæ j± ponownie.

Na pewno zabezpieczyæ bazê przed zapisem?}

# Clear game dialog:
translate P ClearGameDialog {Partia zosta³a zmieniona.

Na pewno kontynuowaæ, rezygnuj±c z wszelkich zmian?
}

# Exit dialog:
translate P ExitDialog {Na pewno zakoñczyæ pracê z programem?}
translate P ExitUnsaved {Nastêpuj±ce bazy zawieraj± niezapisane zmiany. Je¶li zamkniesz program teraz, zmiany zostan± utracone.} 

# Import window:
translate P PasteCurrentGame {Wklej aktualn± partiê}
translate P ImportHelp1 {Wprowad¼ lub wklej partiê w formacie PGN w poni¿sz± ramkê.}
translate P ImportHelp2 {Tu bêd± wy¶wietlane b³êdy przy importowaniu partii.}
translate P OverwriteExistingMoves {Zaprzestaæ kontynuowania?}

# ECO Browser:
translate P ECOAllSections {Wszystkie kody ECO}
translate P ECOSection {Czê¶æ ECO}
translate P ECOSummary {Podsumowanie dla}
translate P ECOFrequency {Czêsto¶ci kodów dla}

# Opening Report:
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
translate P OprepPopular {Popularno¶æ}
translate P OprepFreqAll {Czêsto¶æ w ca³ej bazie:         }
translate P OprepFreq1   {W ostatnim roku:                }
translate P OprepFreq5   {W ostatnich piêciu latach:      }
translate P OprepFreq10  {W ostatnich dziesiêciu latach:  }
translate P OprepEvery {co %u partii}
translate P OprepUp {wiêcej o %u%s ni¿ w ca³ej bazie}
translate P OprepDown {mniej o %u%s ni¿ w ca³ej bazie}
translate P OprepSame {jak w ca³ej bazie}
translate P OprepMostFrequent {Gracze najczê¶ciej stosuj±cy wariant}
translate P OprepMostFrequentOpponents {Przeciwnicy} 
translate P OprepRatingsPerf {Rankingi i wyniki}
translate P OprepAvgPerf {¦rednie rankingi i wyniki}
translate P OprepWRating {Ranking bia³ych}
translate P OprepBRating {Ranking czarnych}
translate P OprepWPerf {Wynik bia³ych}
translate P OprepBPerf {Wynik czarnych}
translate P OprepHighRating {Partie graczy o najwy¿szym ¶rednim rankingu}
translate P OprepTrends {Wyniki}
translate P OprepResults {D³ugo¶æ partii i czêsto¶ci}
translate P OprepLength {D³ugo¶æ partii}
translate P OprepFrequency {Czêsto¶æ}
translate P OprepWWins {Zwyciêstwa bia³ych:  }
translate P OprepBWins {Zwyciêstwa czarnych: }
translate P OprepDraws {Remisy:              }
translate P OprepWholeDB {ca³a baza}
translate P OprepShortest {Najkrótsze zwyciêstwa}
translate P OprepMovesThemes {Posuniêcia i motywy}
translate P OprepMoveOrders {Posuniêcia prowadz±ce do badanej pozycji}
translate P OprepMoveOrdersOne \
  {Badana pozycja powstawa³a jedynie po posuniêciach:}
translate P OprepMoveOrdersAll \
  {Badana pozycja powstawa³a na %u sposobów:}
translate P OprepMoveOrdersMany \
  {Badana pozycja powstawa³a na %u sposobów. Najczêstsze %u to:}
translate P OprepMovesFrom {Posuniêcia w badanej pozycji}
translate P OprepMostFrequentEcoCodes {Najczêstsze kody ECO} 
translate P OprepThemes {Motywy pozycyjne}
translate P OprepThemeDescription {Czêsto¶æ motywów w pierwszych %u posuniêciach partii} 
translate P OprepThemeSameCastling {Jednostronne roszady}
translate P OprepThemeOppCastling {Ró¿nostronne roszady}
translate P OprepThemeNoCastling {Obie strony bez roszady}
translate P OprepThemeKPawnStorm {Atak pionowy na skrzydle królewskim}
translate P OprepThemeQueenswap {Wymiana hetmanów}
translate P OprepThemeWIQP {Izolowany pion bia³ych} 
translate P OprepThemeBIQP {Izolowany pion czarnych}
translate P OprepThemeWP567 {Bia³y pion na 5/6/7 linii}
translate P OprepThemeBP234 {Czarny pion na 2/3/4 linii}
translate P OprepThemeOpenCDE {Otwarta kolumna c/d/e}
translate P OprepTheme1BishopPair {Jedna ze stron ma parê goñców}
translate P OprepEndgames {Koñcówki}
translate P OprepReportGames {Partie raportu}
translate P OprepAllGames {Wszystkie partie}
translate P OprepEndClass {Materia³ w pozycji koñcowej}
translate P OprepTheoryTable {Teoria}
translate P OprepTableComment {Utworzono z %u partii o najwy¿szym ¶rednim rankingu.}
translate P OprepExtraMoves {Dodatkowe posuniêcia w przypisach}
translate P OprepMaxGames {Maksymalna liczba partii w teorii}
translate P OprepMergeMoves {Przesuñ limit dla po³±czonych gier}
translate P OprepMergeUnique {£±cz tylko unikalne gry}
translate P OprepViewHTML {¬ród³o HTML} 

# Player Report:
translate P PReportTitle {Raport o graczu}
translate P PReportColorWhite {with the White pieces} ;# ***
translate P PReportColorBlack {with the Black pieces} ;# ***
translate P PReportMoves {po %s}
translate P PReportOpenings {Debiuty}
translate P PReportClipbase {Wyczy¶æ schowek i skopiuj do niego wybrane partie}

# Piece Tracker window:
translate P TrackerSelectSingle {Lewy przycisk wybiera tê figurê.}
translate P TrackerSelectPair {Lewy przycisk wybiera tê figurê; prawy obie takie figury.}
translate P TrackerSelectPawn {Lewy przycisk wybiera tego piona; prawy wszystkie 8 pionów.}
translate P TrackerStat {Statystyka}
translate P TrackerGames {% partie z posuniêciem na tym pole}
translate P TrackerTime {% czasu na tym polu}
translate P TrackerMoves {Posuniêcia}
translate P TrackerMovesStart {Podaj numer posuniêcia, od którego zacz±æ ¶ledzenie.}
translate P TrackerMovesStop {Podaj numer posuniêcia, na którym skoñczyæ ¶ledzenie.}

# Game selection dialogs:
translate P SelectAllGames {Wszystkie partie w bazie}
translate P SelectFilterGames {Partie w filtrze}
translate P SelectTournamentGames {Tylko partie z aktualnego turnieju}
translate P SelectOlderGames {Tylko wcze¶niejsze partie}

# Delete Twins window:
translate P TwinsNote {Partie zostan± uznane za identyczne, je¶li zosta³y rozegrane przez tych samych graczy i spe³niaj± ustawione poni¿ej kryteria. Krótsza z partii zostanie usuniêta. Uwaga: dobrze przez wyszukaniem powtórzonych partii sprawdziæ pisowniê nazwisk.}
translate P TwinsCriteria {Kryteria: co musi byæ jednakowe w obu partiach?}
translate P TwinsWhich {Przeszukiwane partie}
translate P TwinsColors {Kolory}
translate P TwinsEvent {Turniej:}
translate P TwinsSite {Miejsce:}
translate P TwinsRound {Runda:}
translate P TwinsYear {Rok:}
translate P TwinsMonth {Miesi±c:}
translate P TwinsDay {Dzieñ:}
translate P TwinsResult {Wynik:}
translate P TwinsECO {Kod ECO:}
translate P TwinsMoves {Posuniêcia:}
translate P TwinsPlayers {Porównywanie nazwisk:}
translate P TwinsPlayersExact {Dok³adne}
translate P TwinsPlayersPrefix {Tylko pierwsze 4 litery}
translate P TwinsWhen {Usuwanie znalezionych powtórzonych partii}
translate P TwinsSkipShort {Pomijaæ partie krótsze ni¿ 5 posuniêæ?}
translate P TwinsUndelete {Odzyskaæ wszystkie partie przed poszukiwaniem?}
translate P TwinsSetFilter {Wstawiæ wszystkie usuniête partie do filtra?}
translate P TwinsComments {Zawsze zachowywaæ partie komentowane?}
translate P TwinsVars {Zawsze zachowywaæ partie z wariantami?}
translate P TwinsDeleteWhich {Któr± partiê usun±æ:} 
translate P TwinsDeleteShorter {Krótsz±} 
translate P TwinsDeleteOlder {O ni¿szym numerze}
translate P TwinsDeleteNewer {O wy¿szym numerze}
translate P TwinsDelete {Usuñ partie}

# Name editor window:
translate P NameEditType {Nazwa do wyboru}
translate P NameEditSelect {Partie do edycji}
translate P NameEditReplace {Zast±p}
translate P NameEditWith {przez}
translate P NameEditMatches {Pasuj±ce: Ctrl+1 do Ctrl+9 wybiera}

# Check games window:
translate P CheckGames {Sprawd¼ gry}
translate P CheckGamesWhich {Sprawd¼ gry}
translate P CheckAll {Wszystkie gry}
translate P CheckSelectFilterGames {Tylko gry w filtrze}

# Classify window:
translate P Classify {Przyporz±dkowanie ECO}
translate P ClassifyWhich {Partie do przyporz±dkowania ECO}
translate P ClassifyAll {Wszystkie partie (zmiana starych kodów ECO)}
translate P ClassifyYear {Wszystkie partie z ostatniego roku}
translate P ClassifyMonth {Wszystkie partie z ostatniego miesi±ca}
translate P ClassifyNew {Tylko partie bez kodu ECO}
translate P ClassifyCodes {Kody ECO}
translate P ClassifyBasic {Tylko podstawowe ("B12", ...)}
translate P ClassifyExtended {Rozszerzone kody Scida ("B12j", ...)}
translate P ClassifyResult {Klasyfikacja ECO ukoñczona: $result gry(y) zaktualizowane.}

# Compaction:
translate P NameFile {Plik nazw}
translate P GameFile {Plik z partiami}
translate P Names {Nazwy}
translate P Unused {Nieu¿ywane}
translate P SizeKb {Rozmiar (kb)}
translate P CurrentState {Status}
translate P AfterCompaction {Po uporz±dkowaniu}
translate P CompactNames {Uporz±dkuj nazwy}
translate P CompactGames {Uporz±dkuj partie}
translate P NoUnusedNames "Nie ma ¿adnych nieu¿ywanych nazw, wiêc plik nazwy jest ju¿ w pe³ni skompaktowany."
translate P NoUnusedGames "Plik gry jest ju¿ w pe³ni skompaktowany."
translate P GameFileCompacted {Plik gry dla bazy danych zosta³ skompaktowany.}

# Sorting:
translate P SortCriteria {Kryteria sortowania}
translate P AddCriteria {Dodaj kryteria}
translate P CommonSorts {Standardowe kryteria}
translate P Sort {Sortuj}

# Exporting:
translate P AddToExistingFile {Dodaæ partie do pliku?}
translate P ExportComments {Eksportowaæ komentarze?}
translate P ExportVariations {Eksportowaæ warianty?}
translate P IndentComments {Wcinaj komentarze?}
translate P IndentVariations {Wcinaj warianty?}
translate P ExportColumnStyle {Kolumny (jedno posuniêcie w wierszu)?}
translate P ExportSymbolStyle {Styl znaków komentarza:}
translate P ExportStripMarks {Usuwaæ z komentarzy kody kolorowania pól/strza³ek?} 

# Goto game/move dialogs:
translate P LoadGameNumber {Podaj numer partii do wczytania:}
translate P GotoMoveNumber {Id¼ do posuniêcia nr:}

# Copy games dialog:
translate P CopyAllGames {Skopiuj wszystkie gry do}
translate P CopyGames {Kopiuj partie}
translate P CopyConfirm {
 Czy na pewno skopiowaæ
 [::utils::thousands $nGamesToCopy] partii z filtra
 w bazie "$fromName"
 do bazy "$targetName"?
}
translate P CopyErr {Nie mo¿na skopiowaæ partii}
translate P CopyErrSource {baza ¼ród³owa}
translate P CopyErrTarget {baza docelowa}
translate P CopyErrNoGames {nie ma partii w filtrze}
translate P CopyErrReadOnly {jest tylko do odczytu}
translate P CopyErrNotOpen {nie jest otwarta}

# Colors:
translate P LightSquares {Jasne pola}
translate P DarkSquares {Ciemne pola}
translate P SelectedSquares {Wybrane pola}
translate P SuggestedSquares {Wybrane posuniêcie}
translate P WhitePieces {Bia³e figury}
translate P BlackPieces {Czarne figury}
translate P WhiteBorder {Kontur bia³ych figur}
translate P BlackBorder {Kontur czarnych figur}

# Novelty window:
translate P FindNovelty {Znajd¼ nowinkê}
translate P Novelty {Nowinka}
translate P NoveltyInterrupt {Poszukiwanie nowinki przerwano}
translate P NoveltyNone {Nie znaleziono nowinki w partii}
translate P NoveltyHelp {
Scid znajdzie pierwsze posuniêcie w partii, po którym powstanie pozycja niewystêpuj±ca ani w bazie, ani w ksi±¿ce debiutowej.
}

# Sounds configuration:
translate P SoundsFolder {Sound Files Folder} ;# ***
translate P SoundsFolderHelp {The folder should contain the files King.wav, a.wav, 1.wav, etc} ;# ***
translate P SoundsAnnounceOptions {Move Announcement Options} ;# ***
translate P SoundsAnnounceNew {Announce new moves as they are made} ;# ***
translate P SoundsMoveSoundOnly {Przenie¶ tylko d¼wiêk (wy³±cz powiadomienia)}
translate P SoundsAnnounceForward {Announce moves when moving forward one move} ;# ***
translate P SoundsAnnounceBack {Announce when retracting or moving back one move} ;# ***
translate P SoundsSoundDisabled {Scid nie mo¿na pobraæ pakietu audio Snack podczas uruchamiania;\nD¼wiêk jest wy³±czony.}

# Upgrading databases:
translate P Upgrading {Konwersja}
translate P ConfirmOpenNew {
Ta baza jest zapisana w starym formacie (Scid 3) i nie mo¿e zostaæ otwarta w nowszej wersji
Scid-a. Baza zosta³a ju¿ automatycznie przekonwertowana do nowego formatu.

Czy otworzyæ now± wersjê bazy?
}
translate P ConfirmUpgrade {
Ta baza jest zapisana w starym formacie (Scid 3) i nie mo¿e zostaæ otwarta w nowszej wersji Scid-a. ¯eby móc otworzyæ bazê, trzeba przekonwertowaæ j± do nowego formatu.

Konwersja utworzy now± wersjê bazy - stara wersja nie zostanie zmieniona ani usuniêta.

Mo¿e to zaj±æ trochê czasu, ale jest to operacja jednorazowa. Mo¿esz j± przerwaæ, je¶li potrwa za d³ugo.

Przekonwertowaæ bazê?
}

# Recent files options:
translate P RecentFilesMenu {Liczba ostatnich plików w menu Plik} 
translate P RecentFilesExtra {Liczba ostatnich plików w dodatkowym podmenu} 

# My Player Names options:
translate P MyPlayerNamesDescription {
Podaj listê preferowanych nazwisk graczy, po jednym w wierszu. W nazwiskach mo¿na stosowaæ znaki specjalne (np. "?" - dowolny znak, "*" - dowolna sekwencja znaków).

Wszystkie partie grane przez jednego z graczy z listy bêd± wy¶wietlane z jego perspektywy.
}

#Coach
translate P showblunderexists {zjawisko, ¿e b³±d istnieje}
translate P showblundervalue {poka¿ warto¶æ dodatkow±}
translate P showscore {poka¿ wynik}
translate P coachgame {gra trenerska}
translate P configurecoachgame {skonfiguruj grê trenersk±}
translate P configuregame {Konfiguracja gry}
translate P Phalanxengine {Silnik Falangi}
translate P Coachengine {Silnik autokaru}
translate P difficulty {trudno¶æ}
translate P hard {twardy}
translate P easy {³atwe}
translate P Playwith {Zagraj z}
translate P white {bia³y}
translate P black {czarny}
translate P both {Gdybym}
translate P Play {Graæ}
translate P Noblunder {¯adnej pomy³ki}
translate P blunder {pomy³ka}
translate P Noinfo {-- Brak informacji --}
translate P PhalanxOrTogaMissing {Nie znaleziono falangi ani togi}
translate P moveblunderthreshold {ruch jest wiêkszy ni¿}
translate P limitanalysis {czas analizy silnika}
translate P seconds {towar drugiej jako¶ci}
translate P Abort {Poroniæ}
translate P Resume {Znawiaæ}
translate P OutOfOpening {Poza otwarciem}
translate P NotFollowedLine {Nie zastosowa³e¶ siê do linii}
translate P DoYouWantContinue {Czy chcesz kontynuowaæ?}
translate P CoachIsWatching {Trener patrzy³}
translate P Ponder {Ci±g³e my¶lenie}
translate P LimitELO {Ograniczona si³a ELO}
translate P DubiousMovePlayedTakeBack {Wykonano w±tpliwe postawienie, czy chcesz je zabiæ?}
translate P WeakMovePlayedTakeBack {Zagrano s³aby ruch, czy chcesz odpocz±æ?}
translate P BadMovePlayedTakeBack {Wykonano z³y ruch. Czy chcesz i¶æ do domu?}
translate P Iresign {zrezygnowaæ}
translate P yourmoveisnotgood {twoje posuniêcie nie jest dobre}
translate P EndOfVar {Konieczna trwa³o¶æ}
translate P Openingtrainer {Trener otwarcia}
translate P DisplayCM {Wy¶wietl kandydata}
translate P DisplayCMValue {Wy¶wietl warto¶æ kandydata na kandydata}
translate P DisplayOpeningStats {Poka¿ statystyki}
translate P ShowReport {Poka¿ raport}
translate P NumberOfGoodMovesPlayed {zagraniczne dobre zachowanie}
translate P NumberOfDubiousMovesPlayed {rozegrane w±tpliwe}
translate P NumberOfMovesPlayedNotInRepertoire {wykonaæ grane poza repertuarem}
translate P NumberOfTimesPositionEncountered {razy trudna pozycja}
translate P PlayerBestMove  {Zezwalaj tylko na najlepsze wykonanie}
translate P OpponentBestMove {Przeciwnik pozosta³ najlepszy}
translate P OnlyFlaggedLines {Tylko zaznaczona linia}
translate P resetStats {Zresetuj statystyki}
translate P Repertoiretrainingconfiguration {Konfiguracja treningu treningowego}
translate P Loadingrepertoire {£adowanie repertuaru}
translate P Movesloaded {Ruchy prowadz±ce}
translate P Repertoirenotfound {Nie znaleziono}
translate P Openfirstrepertoirewithtype {Otwórz najpierw dane dostêpne z ikon±/typem pod³±czonym do prawej strony}
translate P Movenotinrepertoire {Ruch nie w repertuarze}
translate P PositionsInRepertoire {Pozycje w repertuarze}
translate P PositionsNotPlayed {Pozycja nie grana}
translate P PositionsPlayed {Grane potrzebowa³}
translate P Success {Sukces}
translate P DubiousMoves {W±tpliwe kontynuowaæ}
translate P OutOfRepertoire {Poza repertuarem}
translate P ConfigureTactics {Skonfiguruj taktykê}
translate P ResetScores {Resetuj wyniki}
translate P LoadingBase {Baza za³adunkowa}
translate P Tactics {Taktyka}
translate P ShowSolution {Poka¿ rozwi±zanie}
translate P NextExercise {Nastêpne pytanie}
translate P PrevExercise {poprzednie wiedzia³y}
translate P StopTraining {Przestañ trenowaæ}
translate P Next {Nastêpny}
translate P ResettingScore {Resetowanie wyniku}
translate P LoadingGame {£adowanie gry}
translate P MateFound {Znaleziony kumpel}
translate P BestSolutionNotFound {NIE najlepsze rozwi±zania!}
translate P MateNotFound {Nie znaleziono partnera}
translate P ShorterMateExists {Posiadaj±cy partnera}
translate P ScorePlayed {Wynik rozegrany}
translate P Expected {oczekiwany}
translate P ChooseTrainingBase {Wybierz opcjê szkoleniow±}
translate P Thinking {Mysl±cy}
translate P AnalyzeDone {Analiza wykonana}
translate P WinWonGame {Wygrana wygrana gra}
translate P Lines {Kwestia}
translate P ConfigureUCIengine {Skonfiguruj silnik UCI}
translate P SpecificOpening {Konkretne otwarcie}
translate P StartNewGame {Rozpocznij now± grê}
translate P FixedLevel {Sta³y poziom}
translate P Opening {Otwór}
translate P RandomLevel {Losowy poziom}
translate P StartFromCurrentPosition {Rozpocznij od aktualnych pozycji}
translate P FixedDepth {Sta³a inna}
translate P Nodes {Wêz³y} 
translate P Depth {G³êboko¶æ}
translate P Time {Czas} 
translate P SecondsPerMove {Drugi ruch}
translate P Engine {Silnik}
translate P TimeMode {Tryb czasu}
translate P TimeBonus {Czas + premia}
translate P TimeMin {min}
translate P TimeSec {sek}
translate P AllExercisesDone {Wszystkie wykonania wykonane}
translate P MoveOutOfBook {Wyjd¼ z ksi±¿ki}
translate P LastBookMove {Ostatni ruch ksi±¿kowy}
translate P AnnotateSeveralGames {Adnotuj kilka gier\od zainstalowanych do:}
translate P FindOpeningErrors {Rozwi±zanie otwiera b³êdynia}
translate P MarkTacticalExercises {Zaznacz æwiczenia taktyczne}
translate P UseBook {Skorzystaj z ksi±¿ki}
translate P MultiPV {Wiele odmian}
translate P Hash {Pamiêæ haszuj±ca}
translate P OwnBook {Skorzystaj z ksi±¿ki silnika}
translate P BookFile {Otwieranie ksi±¿ki}
translate P AnnotateVariations {Opis stosowania}
translate P ShortAnnotations {Krótkie adnotacje}
translate P addAnnotatorTag {Dodaj tag adnotatora}
translate P AddScoreToShortAnnotations {Dodaj ocenê do ¶redniej adnotacji}
translate P Export {Eksport}
translate P BookPartiallyLoaded {Ksi±¿ka udostêpniona}
translate P Calvar {Obliczanie zmiany}
translate P ConfigureCalvar {Konfiguracja}
# Opening names used in tacgame.tcl
translate P Reti {Reti}
translate P English {angielski}
translate P d4Nf6Miscellaneous {1.d4 Sf6 Ró¿ne}
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
translate P CaroKannAdvance {Postêp Caro-Kanna}
translate P Sicilian {sycylijski}
translate P SicilianAlapin {Sycylijski Alapin}
translate P SicilianClosed {Sycylijski zamkniêty}
translate P SicilianRauzer {Sycylijski Rauzer}
translate P SicilianDragon {Sycylijski dym}
translate P SicilianScheveningen {Sycylijskie Scheveningen}
translate P SicilianNajdorf {Sycylijczyk Najdorf}
translate P OpenGame {Otwórz grê}
translate P Vienna {Wiedeñ}
translate P KingsGambit {Królewski chwyt}
translate P RussianGame {Rosyjska gra}
translate P ItalianTwoKnights {W³och/Dwóch Rycerzy}
translate P Spanish {hiszpañski}
translate P SpanishExchange {Wymiana hiszpañska}
translate P SpanishOpen {Otwarte Hiszpañskie}
translate P SpanishClosed {Hiszpañski Zamkniêty}
translate P FrenchDefence {Obrona Francuska}
translate P FrenchAdvance {Awans francuski}
translate P FrenchTarrasch {Francuski Tarrasch}
translate P FrenchWinawer {Francuski Winawer}
translate P FrenchExchange {Wymiana francuska}
translate P QueensPawn {Pionek królowej}
translate P Slav {s³owiañski}
translate P QGA {QGA}
translate P QGD {QGD}
translate P QGDExchange {Wymieñ QGD}
translate P SemiSlav {Pó³s³owiañski}
translate P QGDwithBg5 {QGD z Bg5}
translate P QGDOrthodox {QGD ortodoksyjny}
translate P Grunfeld {Grunfelda}
translate P GrunfeldExchange {Grünfeld Exchange}
translate P GrunfeldRussian {Grunfelda Rosyjskiego}
translate P Catalan {kataloñski}
translate P CatalanOpen {Kataloñskiego Otwartego}
translate P CatalanClosed {Kataloñski zamkniêty}
translate P QueensIndian {Indianin królowej}
translate P NimzoIndian {Nimzo-Indianin}
translate P NimzoIndianClassical {Nimzo-indyjska klasyka}
translate P NimzoIndianRubinstein {Nimzo? Indianina Rubinsteina}
translate P KingsIndian {Królewski Indianin}
translate P KingsIndianSamisch {Królewski indyjski Sämisch}
translate P KingsIndianMainLine {G³ówna linia King's Indian}

# FICS
translate P ConfigureFics {Skonfiguruj FICS}
translate P FICSGuest {Zaloguj siê jako go¶æ}
translate P FICSServerPort {Serwer portu}
translate P FICSServerAddress {Adres IP}
translate P FICSRefresh {Od¶wie¿yæ}
translate P FICSTimesealPort {Portowa pieczêæ czasowa}
translate P FICSSilence {Cisza}
translate P FICSOffers {Oferty}
translate P FICSConsole {Konsola}
translate P FICSGames {Zawody sportowe}
translate P FICSUnobserve {Przestañ graæ}
translate P FICSProfile {Wy¶wietl swoj± historiê i profil}
translate P FICSRelayedGames {Przekazywane gry}
translate P FICSFindOpponent {znale¼æ przeciwnika}
translate P FICSTakeback {Odbiór}
translate P FICSTakeback2 {Odbiór 2}
translate P FICSInitTime {Czas pocz±tkowy (min)}
translate P FICSIncrement {Przyrost (e)}
translate P FICSRatedGame {Oceniana gra}
translate P FICSAutoColour {automatyczny}
translate P FICSManualConfirm {potwierd¼}
translate P FICSFilterFormula {Filtruj za pomoc± formu³}
translate P FICSIssueSeek {Szukaj problemu}
translate P FICSChallenge {Wyzwanie}
translate P FICSAccept {uchwyt}
translate P FICSDecline {wynik}
translate P FICSColour {Kolor}
translate P FICSSend {podaæ}
translate P FICSConnect {£±czyæ}
translate P FICSdefaultuservars {uniwersalne, standardowe narzêdzia}
translate P FICSObserveconfirm {Mo¿esz zobaczyæ grê}
translate P FICSpremove {W³±cz wstêpne przesuwanie}
translate P FICSObserve {Przestrzegaæ}
translate P FICSRatedGames {Ocenione gry}
translate P FICSUnratedGames {Gry bez oceny}
translate P FICSRated {Oceniono}
translate P FICSUnrated {Bez oceny}
translate P FICSRegisteredPlayer {Tylko zaanga¿owany gracz}
translate P FICSFreePlayer {Tylko darmowy gracz}
translate P FICSNetError {B³±d sieci\Nie mo¿na siê po³±czyæ}

# Game review
translate P GameReview {Recenzja gry}
translate P GameReviewTimeExtended {Czas wolny}
translate P GameReviewMargin {Mar¿e ewentualnie}
translate P GameReviewAutoContinue {Automatyczna kontynuacja, gdy ruch jest krytyczny}
translate P GameReviewReCalculate {d³ugiego czasu}
translate P GameReviewAnalyzingMovePlayedDuringTheGame {Analizowanie ruchu wykonanego w trakcie gry}
translate P GameReviewAnalyzingThePosition {Analiza pozycji}
translate P GameReviewEnterYourMove {Wpisz swój ruch}
translate P GameReviewCheckingYourMove {Sprawdzam Twój ruch}
translate P GameReviewYourMoveWasAnalyzed {Twój ruch zosta³ wy³±czony}
translate P GameReviewYouPlayedSameMove {Wykona³e¶ dziesiêæ sam ruch, co w meczu}
translate P GameReviewScoreOfYourMove {Wynik Twojego ruchu}
translate P GameReviewGameMoveScore {Wynik ruchu w grze}
translate P GameReviewEngineScore {Wynik silnika}
translate P GameReviewYouPlayedLikeTheEngine {Gra³e¶ jak silnik}
translate P GameReviewNotEngineMoveButGoodMove {Nie chodzi tu o ruch silnika, ale te¿ jest to dobry ruch}
translate P GameReviewMoveNotGood {Ten ruch nie jest dobry, wynik jest}
translate P GameReviewMovesPlayedLike {Ruchy grane jak}
translate P GameReviewMovesPlayedEngine {Ruchy grane jak silnik}

# Correspondence Chess Dialogs:
translate P CCDlgCGeneraloptions {Opcje ogólne}
translate P CCDlgLoginName  {Nazwa logowania:}
translate P CCDlgPassword   {Has³o:}
translate P CCDlgShowPassword {Poka¿ has³o}

# Connect Hardware dialogs
translate P ExtHWConfigConnection {Skonfiguruj sprzêt zewnêtrzny}
translate P ExtHWPort {Port}
translate P ExtHWEngineCmd {Polecenie silnika}
translate P ExtHWEngineParam {Parametry silnika}
translate P ExtHWShowButton {Poka¿ przycisk}
translate P ExtHWHardware {Sprzêt komputerowy}
translate P ExtHWNovag {Novag Cytryn}
translate P ExtHWInputEngine {Silnik zasilaj±cy}
translate P ExtHWNoBoard {Brak biurka}
translate P NovagReferee {Sêdzia}

# Input Engine dialogs
translate P IEConsole {Konsola zasilaj±ca}
translate P IESending {Wys³ano kontynuowaæ}
translate P IESynchronise {Synchronizuj}
translate P IERotate  {Obracaæ}
translate P IEUnableToStart {Nie mo¿na uruchomiæ przep³ywu:}

# Calculation of Variations
translate P DoneWithPosition {Koniec z konieczno¶ci±}

translate P Board {Tablica}
translate P showGameInfo {Poka¿ informacje o grze}
translate P autoResizeBoard {Automatyczna zmiana dotycz±ca planuszy}
translate P DockTop {Przejd¼ na górê}
translate P DockBottom {Przejd¼ na dó³}
translate P DockLeft {Przejd¼ w lewo}
translate P DockRight {Przejd¼ w prawo}
translate P Undock {Oddokuj}

# Switcher window
translate P AboutDatabase {O tej formie danych}
translate P ChangeIcon {Zmieñ prze³±cznik...}
translate P NewGameListWindow {Nowe okno listy gier}
translate P LoadatStartup {Za³aduj przy uruchomieniu}

# Gamelist window
translate P ShowHideDB {Poka¿/ukryj bazê danych}
translate P ChangeFilter {Zmieñ filtr}
translate P ChangeLayout {Za³aduj/Zapisz/Zmieñ kryteria sortowania i uk³ad kolumnowy}
translate P ShowHideStatistic {Poka¿/ukryj statystyki}
translate P BoardFilter {Poka¿ tylko wszystkie pozycje do aktualnych pozycji na planszy}
translate P CopyGameTo {Skopiuj grê do}
translate P FindBar {szukaj paska}
translate P FindCurrentGame {¼ród³o bie¿±cej gry}
translate P DeleteGame {Usuñ grê}
translate P UndeleteGame {Przywróæ grê}
translate P ResetSort {Zresetuj sortowanie}

translate P ConvertNullMove {Konwerstuj zerowe na komentarze}
translate P SetupBoard {P³yta konfiguracyjna}
translate P Rotate {Obracaæ}
translate P SwitchColors {Zmieñ kolor}
translate P FlipBoard {Od¶wie¿ tablicê}
translate P ImportPGN {Importuj grê PGN}
translate P ImportingFiles {Importowanie plików PGN w formacie PDF}
translate P ImportingFrom {Importowanie z}
translate P ImportingIn {Importuj gry do}
translate P UseLastTag {u¿yj tagów ostatniego gry}
translate P Random {Losowy}
translate P BackToMainline {Wróæ do sklepu pielêgnowaæ}
translate P LeaveVariant {Opu¶æ wariant}
translate P Autoplay {Autoodtwarzanie}
translate P ShowHideCoords {Poka¿/Ukryj wspó³rzêdne.}
translate P ShowHideEvalBar {Poka¿/ukryj pasek oceny}
translate P ShowHideMaterial {Poka¿/ukryj materia³y}
translate P SelectMarker {Wybierz opcjê Znacznik}
translate P FullScreen {Pe³ny ekran}
translate P FilterStatistic {Statystyki filtrowane}
translate P MakeCorrections {Wprowad¼ wprowadzone}
translate P Surnames {Nazwiska}
translate P Ambiguous {Dwuznaczny}

#Preferences Dialog
translate P OptionsToolbar "Pasek narzêdziowy"
translate P OptionsBoard "Szachownica"
translate P OptionsBoardSize "Wielko¶æe"
translate P OptionsBoardPieces "Typ figur"
translate P OptionsInternationalization "Umiêdzynarodowienie"
translate P OptionsTablebaseDir "Wybierz maksymalnie 4 foldery bazowe tabeli:"

# Evaluation bar
translate P BestMoveArrow "Najlepsza strza³ka ruchu"
translate P NewLocalEngine "+ Nowy silnik..."
}
# end of english.tcl
