### Polish menus for Scid.
# Contributed by Michal Rudolf and Adam Umiastowski.

proc setLanguage_P {} {

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
menuText P FileExit "Koniec" 0 {Zamknij Scida}
# ====== TODO To be translated ======
menuText P FileMaintFixBase "Napraw uszkodzon± bazê" 0 {Spróbuj naprawiæ uszkodzon± bazê}


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
# ====== TODO To be translated ======
menuText P EditUndo "Anulowaæ" 0 {Cofnij ostatni± zmianê gry}

# ====== TODO To be translated ======
menuText P EditRedo "Przerobiæ" 0 {Powtórz ostatni± zmianê w grze}

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
# ====== TODO To be translated ======
menuText P ConfigureScid "Preferencje..." 0 {Skonfiguruj wszystkie opcje dla SCID}


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
# ====== TODO To be translated ======
menuText P WindowsBook "Okno ksi±¿ki" 0 {Otwórz/zamknij okno Ksi±¿ka}

# ====== TODO To be translated ======
menuText P WindowsCorrChess "Okno korespondencyjne" 0 {Otwórz/zamknij okno Korespondencja}

# ====== TODO To be translated ======
menuText P WindowsGraph "Wykres analizy" 0 {Otwórz okno Wykres z czasami ruchów i ocenami}


menuText P Tools "Narzêdzia" 0
# ====== TODO To be translated ======
menuText P ToolsConfigureEngines "Skonfiguruj silniki" 10 {Zarz±dzaj konfiguracj± silników}

menuText P ToolsAnalysis "Program analizuj±cy..." 8 \
  {Uruchom/zatrzymaj program analizuj±cy}
menuText P ToolsAnalysis2 "Program analizuj±cy 2..." 21 \
  {Uruchom/zatrzymaj program analizuj±cy}
menuText P ToolsCross "Tabela turniejowa" 0 \
  {Poka¿ tabelê turniejow± dla aktualnej partii}
menuText P ToolsFilterGraph "Wykres filtra" 7 \
  {Otwórz/zamknij wykres filtra}
# ====== TODO To be translated ======
menuText P ToolsAbsFilterGraph "Abs. Wykres filtra" 7 {Otwórz/zamknij okno wykresu filtra dla warto¶ci bezwzglêdnych}

menuText P ToolsOpReport "Raport debiutowy" 0 \
  {Utwórz raport debiutowy dla aktualnej pozycji}
# ====== TODO To be translated ======
menuText P ToolsOpenBaseAsTree "Otwórz bazê jako drzewo" 0   {Otwórz bazê i u¿yj jej w oknie Drzewa}

# ====== TODO To be translated ======
menuText P ToolsOpenRecentBaseAsTree "Otwórz ostatni± bazê jako drzewo" 0   {Otwórz najnowsz± bazê i u¿yj jej w oknie Drzewa}

menuText P ToolsTracker "¦ledzenie figur"  10 {Otwórz/zamknij okno ¶ledzenia figur} 
# ====== TODO To be translated ======
menuText P ToolsTraining "Szkolenie"  0 {Narzêdzia szkoleniowe (taktyka, debiuty,...)}

# ====== TODO To be translated ======
menuText P ToolsTacticalGame "Gra taktyczna"  0 {Zagraj w grê z taktyk±}

# ====== TODO To be translated ======
menuText P ToolsSeriousGame "Powa¿na gra"  0 {Zagraj w powa¿n± grê}

# ====== TODO To be translated ======
menuText P ToolsTrainOpenings "Otwory"  0 {Trenuj z repertuarem}

# ====== TODO To be translated ======
menuText P ToolsTrainReviewGame "Recenzja gry"  0 {Zgadnij ruchy rozgrywane w grze}

# ====== TODO To be translated ======
menuText P ToolsTrainTactics "Taktyka"  0 {Rozwi±¿ taktykê}

# ====== TODO To be translated ======
menuText P ToolsTrainCalvar "Obliczanie zmian"  0 {Obliczanie zmian w treningu}

# ====== TODO To be translated ======
menuText P ToolsTrainFindBestMove "Znajd¼ najlepszy ruch"  0 {Znajd¼ najlepszy ruch}

# ====== TODO To be translated ======
menuText P ToolsTrainFics "Graj w internecie"  0 {Graj na freechess.org}

# ====== TODO To be translated ======
menuText P ToolsEngineTournament "Turniej silnikowy"  0 {Rozpocznij turniej pomiêdzy silnikami szachowymi}

# ====== TODO To be translated ======
menuText P ToolsBookTuning "Strojenie ksi±¿ki" 0 {Strojenie ksi±¿ki}

# ====== TODO To be translated ======
menuText P ToolsConnectHardware "Pod³±cz sprzêt" 0 {Pod³±cz sprzêt zewnêtrzny}

# ====== TODO To be translated ======
menuText P ToolsConnectHardwareConfigure "Skonfiguruj..." 0 {Skonfiguruj sprzêt zewnêtrzny i po³±czenie}

# ====== TODO To be translated ======
menuText P ToolsConnectHardwareNovagCitrineConnect "Po³±cz Novag Citrine" 0 {Po³±cz Novag Citrine}

# ====== TODO To be translated ======
menuText P ToolsConnectHardwareInputEngineConnect "Pod³±cz silnik wej¶ciowy" 0 {Pod³±cz silnik wej¶ciowy (np. DGT)}

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
# ====== TODO To be translated ======
menuText P ToolsExpCurrentHTMLJS "Eksportuj grê do pliku HTML i JavaScript..." 15 {Zapisz bie¿±c± grê do pliku HTML i JavaScript}  

menuText P ToolsExpCurrentLaTeX "Do pliku LaTeX-a..." 9 \
  {Zapisz partiê do pliku LaTeX-a}
menuText P ToolsExpFilter "Eksportuj wyszukane partie" 1 \
  {Zapisz wyszukane partie do pliku tekstowego}
menuText P ToolsExpFilterPGN "Do pliku PGN..." 9 \
  {Zapisz wyszukane partie do pliku PGN}
menuText P ToolsExpFilterHTML "Do pliku HTML..." 9 \
  {Zapisz wyszukane partie do pliku HTML}
# ====== TODO To be translated ======
menuText P ToolsExpFilterHTMLJS "Eksportuj filtr do pliku HTML i JavaScript..." 17 {Zapisz wszystkie przefiltrowane gry w pliku HTML i JavaScript}  

menuText P ToolsExpFilterLaTeX "Do pliku LaTeX..." 9 \
  {Zapisz wyszukane partie do pliku LaTeX}
menuText P ToolsImportOne "Wklej partiê w formacie PGN..." 0 \
  {Pobierz partiê z pliku PGN}
menuText P ToolsImportFile "Importuj plik PGN..." 2 \
  {Pobierz partie z pliku PGN}
# ====== TODO To be translated ======
menuText P ToolsStartEngine1 "Uruchom silnik 1" 0  {Uruchom silnik 1}

# ====== TODO To be translated ======
menuText P ToolsStartEngine2 "Uruchom silnik 2" 0  {Uruchom silnik 2}

# ====== TODO To be translated ======
menuText P ToolsCaptureBoard "Przechwyæ bie¿±c± tablicê..." 0  {Zapisz bie¿±c± tablicê jako obraz.}

# ====== TODO To be translated ======
menuText P Play "Graæ" 0
# ====== TODO To be translated ======
menuText P CCResign "Rezygnowaæ" 0 {Zrezygnuj (nie przez e-mail)}

# ====== TODO To be translated ======
menuText P CCClaimDraw "Zg³oszenie losowania" 0 {Wy¶lij ruch i ubiegaj siê o losowanie (nie przez e-mail)}

# ====== TODO To be translated ======

menuText P Options "Opcje" 0
# ====== TODO To be translated ======
menuText P OptionsBoardGraphics "Kwadraty..." 0 {Wybierz tekstury dla kwadratów}

# ====== TODO To be translated ======
translate P OptionsBGW {Wybierz teksturê kwadratów}

# ====== TODO To be translated ======
translate P OptionsBoardGraphicsText {Wybierz pliki graficzne dla bia³ych i czarnych kwadratów:}

menuText P OptionsBoardNames "Moje nazwiska" 0 {Modyfikuj listê moich graczy}
menuText P OptionsExport "Eksport" 0 {Zmieñ opcje eksportu tekstu}
menuText P OptionsFonts "Czcionka" 0 {Zmieñ font}
menuText P OptionsFontsRegular "Podstawowa" 0 {Zmieñ podstawow± czcionkê}
menuText P OptionsFontsMenu "Menu" 0 {Zmieñ czcionkê menu} 
menuText P OptionsFontsSmall "Ma³a" 0 {Zmieñ ma³± czcionkê}
# ====== TODO To be translated ======
menuText P OptionsFontsTiny "Malutki" 0 {Zmieñ ma³± czcionkê}

menuText P OptionsFontsFixed "Sta³a" 0 {Zmieñ czcionkê sta³ej szeroko¶ci}
menuText P OptionsGInfo "Informacje o partii" 0 {Sposób wy¶wietlania informacji o partii}
menuText P OptionsLanguage "Jêzyk" 0 {Wybierz jêzyk}
# ====== TODO To be translated ======
menuText P OptionsMovesTranslatePieces "Przet³umacz kawa³ki" 0 {Przet³umacz pierwsz± literê kawa³ków}

# ====== TODO To be translated ======
menuText P OptionsMovesHighlightLastMove "Podkre¶l ostatni ruch" 0 {Podkre¶l ostatni ruch}

# ====== TODO To be translated ======
menuText P OptionsMovesHighlightLastMoveDisplay "Poka¿ kwadrat" 0 {Wy¶wietl ostatni ruch Pod¶wietlenie}

# ====== TODO To be translated ======
menuText P OptionsMovesHighlightLastMoveWidth "Szeroko¶æ" 0 {Grubo¶æ linii}

# ====== TODO To be translated ======
menuText P OptionsMovesHighlightLastMoveColor "Kolor" 0 {Kolor linii}

# ====== TODO To be translated ======
menuText P OptionsMovesHighlightLastMoveArrow "Poka¿ strza³kê" 0 {Poka¿ strza³kê z pod¶wietleniem}

# ====== TODO To be translated ======
menuText P OptionsMovesHighlightLastMoveNag "Poka¿ symbole oceny" 0
menuText P OptionsMoves "Posuniêcia" 0 {Wprowadzanie posuniêæ}
menuText P OptionsMovesAnimate "Szybko¶æ animacji" 1 \
  {Ustaw czas przeznaczony na animacjê jednego posuniêcia} 
menuText P OptionsMovesDelay "Automatyczne przegl±danie..." 0 \
  {Ustaw opó¼nienie przy automatycznym przegl±daniu partii}
menuText P OptionsMovesCoord "Posuniêcia w formacie \"g1f3\"" 0 \
  {Akceptuj posuniêcia wprowadzone w formacie "g1f3"}
menuText P OptionsMovesSuggest "Poka¿ proponowane posuniêcia" 1 \
  {W³±cz/wy³±cz proponowanie posuniêæ}
# ====== TODO To be translated ======
menuText P OptionsShowVarPopup "Poka¿ okno odmian" 0 {W³±cz/wy³±cz wy¶wietlanie okna odmian}  

# ====== TODO To be translated ======
menuText P OptionsMovesSpace "Dodaj spacje po numerze ruchu" 0 {Dodaj spacje po numerze ruchu}  

menuText P OptionsMovesKey "Automatyczne dope³nianie posuniêæ" 1 \
  {W³±cz/wy³±cz automatyczne dope³nianie posuniêæ wprowadzanych z klawiatury}
# ====== TODO To be translated ======
menuText P OptionsMovesShowVarArrows "Poka¿ strza³ki dla odmian" 0 {W³±cz/wy³±cz strza³ki pokazuj±ce ruchy w odmianach}

# ====== TODO To be translated ======
menuText P OptionsMovesGlossOfDanger "Kolorowy po³ysk zagro¿enia" 0 {W³±cz/wy³±cz oznaczony kolorami po³ysk niebezpieczeñstwa}

menuText P OptionsNumbers "Format zapisu liczb" 0 {Wybierz format zapisu liczb}
# ====== TODO To be translated ======
menuText P OptionsTheme "Temat" 0 {Zmieñ wygl±d interfejsu}

menuText P OptionsWindows "Okna" 0 {Opcje okien}
menuText P OptionsSounds "Sounds" 2 {Configure move announcement sounds} ;# ***
# ====== TODO To be translated ======
menuText P OptionsResources "Zasoby..." 0 {Wybierz pliki zasobów i foldery}

# ====== TODO To be translated ======
menuText P OptionsWindowsDock "Zadokuj okna" 0 {Zadokuj okna}

# ====== TODO To be translated ======
menuText P OptionsWindowsSaveLayout "Zapisz uk³ad" 0 {Zapisz uk³ad}

# ====== TODO To be translated ======
menuText P OptionsWindowsRestoreLayout "Przywróæ uk³ad" 0 {Przywróæ uk³ad}

# ====== TODO To be translated ======
menuText P OptionsWindowsShowGameInfo "Poka¿ informacje o grze" 0 {Poka¿ informacje o grze}

# ====== TODO To be translated ======
menuText P OptionsWindowsAutoLoadLayout "Automatyczne ³adowanie pierwszego uk³adu" 0 {Automatyczne ³adowanie pierwszego uk³adu przy uruchomieniu}

menuText P OptionsECO "Wczytaj ksi±¿kê debiutow±" 16 \
  {Wczytaj plik z klasyfikacja debiutów}
menuText P OptionsSpell "Wczytaj plik sprawdzania pisowni..." 13 \
  {Wczytaj plik do sprawdzania pisowni nazwisk i nazw}
menuText P OptionsTable "Katalog z baz± koñcówek" 10 \
  {Wybierz bazê koñcówek; u¿yte zostan± wszystkie bazy z tego katalogu}
menuText P OptionsRecent "Ostatnie pliki..." 0 \
  {Zmieñ liczbê ostatnio otwartych plików, wy¶wietlanych w menu Plik} 
# ====== TODO To be translated ======
menuText P OptionsBooksDir "Katalog ksi±¿ek" 0 {Ustawia katalog ksi±¿ek otwieraj±cych}

# ====== TODO To be translated ======
menuText P OptionsTacticsBasesDir "Katalog baz" 0 {Ustawia katalog baz taktycznych (szkoleniowych).}

# ====== TODO To be translated ======
menuText P OptionsPhotosDir "Katalog zdjêæ" 0 {Ustawia katalog baz zdjêæ}

# ====== TODO To be translated ======
menuText P OptionsThemeDir "Plik motywów"  0 {Za³aduj plik pakietu motywu GUI}

menuText P OptionsSave "Zapamiêtaj opcje" 0 \
  "Zapamiêtaj wszystkie ustawienia w pliku $::optionsFile"
menuText P OptionsAutoSave "Automatycznie zapisuj opcje" 0 \
  {Automatycznie zapisz opcje przy zamykaniu programu}

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
# ====== TODO To be translated ======
menuText P GInfoInformant "Skonfiguruj warto¶ci informatora" 0

# General buttons:
translate P Back {Z powrotem}
translate P Browse {Przegl±daj}
translate P Cancel {Anuluj}
# ====== TODO To be translated ======
translate P Continue {Kontynuowaæ}

translate P Clear {Wyczy¶æ}
translate P Close {Zamknij}
translate P Contents {Spis tre¶ci}
translate P Defaults {Domy¶lne}
translate P Delete {Usuñ}
translate P Graph {Wykres}
translate P Help {Pomoc}
# ====== TODO To be translated ======
translate P Hide {Ukrywaæ}

translate P Import {Pobierz}
translate P Index {Indeks}
translate P LoadGame {Wczytaj partiê}
translate P BrowseGame {Przegl±daj partiê}
translate P MergeGame {Do³±cz partiê}
# ====== TODO To be translated ======
translate P MergeGames {Po³±cz gry}

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
# ====== TODO To be translated ======
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
# ====== TODO To be translated ======
translate P PInfoEloFile {Plik}


# Tablebase information:
translate P Draw {remis}
translate P with {po}
translate P only {tylko}
translate P lose {przegrywaj±}
translate P loses {przegrywa}
# ====== TODO To be translated ======

# Tip of the day:
translate P Tip {Porada}
translate P TipAtStartup {Poka¿ poradê przy starcie}
# ====== TODO To be translated ======
translate P TipConvertPGN {Mo¿esz uzyskaæ lepsz± wydajno¶æ, konwertuj±c pliki PGN}


# Tree window menus:
menuText P TreeFile "Plik" 0
# ====== TODO To be translated ======
menuText P TreeFileFillWithBase "Wype³nij pamiêæ podrêczn± baz±" 0 {Wype³nij plik pamiêci podrêcznej wszystkimi grami w bie¿±cej bazie}

# ====== TODO To be translated ======
menuText P TreeFileFillWithGame "Wype³nij pamiêæ podrêczn± gr±" 0 {Wype³nij plik pamiêci podrêcznej bie¿±c± gr± w bie¿±cej bazie}

# ====== TODO To be translated ======
menuText P TreeFileSetCacheSize "Rozmiar pamiêci podrêcznej" 0 {Ustaw rozmiar pamiêci podrêcznej}

# ====== TODO To be translated ======
menuText P TreeFileCacheInfo "Informacje o pamiêci podrêcznej" 0 {Uzyskaj informacje o wykorzystaniu pamiêci podrêcznej}

menuText P TreeFileSave "Zapisz bufor" 7 {Zapisz plik bufora (.stc)}
menuText P TreeFileFill "Twórz standardowy plik cache" 0 {Wstaw typowe pozycje debiutowe do bufora}
menuText P TreeFileBest "Najlepsze partie" 0 {Poka¿ listê najlepszych partii}
menuText P TreeFileGraph "Poka¿ wykres" 0 {Poka¿ wykres dla tej ga³êzi drzewa}
menuText P TreeFileCopy "Kopiuj drzewo do schowka" 0 \
  {Skopiuj drzewo ze statystykami do schowka}
menuText P TreeFileClose "Zamknij" 0 {Zamknij okno drzewa}
# ====== TODO To be translated ======
menuText P TreeMask "Maska" 0
# ====== TODO To be translated ======
menuText P TreeMaskNew "Nowy" 0 {Nowa maska}

# ====== TODO To be translated ======
menuText P TreeMaskOpen "Otwarte" 0 {Otwórz maskê}

# ====== TODO To be translated ======
menuText P TreeMaskOpenRecent "Otwórz ostatnio" 0 {Otwórz ostatni± maskê}

# ====== TODO To be translated ======
menuText P TreeMaskSave "Ratowaæ" 0 {Zapisz maskê}

# ====== TODO To be translated ======
menuText P TreeMaskClose "Zamkn±æ" 0 {Zamknij maskê}

# ====== TODO To be translated ======
menuText P TreeMaskFillWithGame "Wype³nij gr±" 0 {Wype³nij maskê gr±}

# ====== TODO To be translated ======
menuText P TreeMaskFillWithBase "Wype³nij baz±" 0 {Wype³nij maskê wszystkimi grami w bazie}

# ====== TODO To be translated ======
menuText P TreeMaskInfo "Informacje" 0 {Poka¿ statystyki dla bie¿±cej maski}

# ====== TODO To be translated ======
menuText P TreeMaskDisplay "Wy¶wietl mapê maski" 0 {Poka¿ dane maski w formie drzewa}

# ====== TODO To be translated ======
menuText P TreeMaskSearch "Szukaj" 0 {Szukaj w bie¿±cej masce}

menuText P TreeSort "Sortowanie" 0
menuText P TreeSortAlpha "Alfabetycznie" 0
menuText P TreeSortECO "Kod ECO" 0
menuText P TreeSortFreq "Czêsto¶æ" 0
menuText P TreeSortScore "Punkty" 0
menuText P TreeOpt "Opcje" 0
# ====== TODO To be translated ======
menuText P TreeOptSlowmode "tryb powolny" 0 {Tryb powolny aktualizacji (wysoka dok³adno¶æ)}

# ====== TODO To be translated ======
menuText P TreeOptFastmode "Tryb szybki" 0 {Szybki tryb aktualizacji (bez transpozycji ruchu)}

# ====== TODO To be translated ======
menuText P TreeOptFastAndSlowmode "Tryb szybki i wolny" 0 {Tryb szybki, a nastêpnie tryb wolny w celu aktualizacji}

# ====== TODO To be translated ======
menuText P TreeOptStartStop "Automatyczne od¶wie¿anie" 0 {W³±cza automatyczne od¶wie¿anie okna drzewa}

menuText P TreeOptLock "Blokada" 0 {Zablokuj/odblokuj drzewo na aktualnej bazie}
menuText P TreeOptTraining "Trening" 0 {W³±cz/wy³±cz tryb treningowy}
menuText P TreeOptAutosave "Automatyczny zapis bufora" 0 \
  {Automatycznie zapisz plik bufora przy wyj¶ciu}
menuText P TreeHelp "Pomoc" 2
menuText P TreeHelpTree "Drzewo" 0
menuText P TreeHelpIndex "Spis tre¶ci" 0
translate P SaveCache {Zapisz bufor}
translate P Training {Trening}
translate P LockTree {Blokada}
translate P TreeLocked {zablokowane}
translate P TreeBest {Najlepsze}
translate P TreeBestGames {Najlepsze partie}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate P TreeTitleRow \
  {    Pos.   ECO       Czêsto¶æ     Wynik  Rav   Rperf Rok   %Remis}
# {    Move   ECO       Frequency    Score  AvElo Perf AvYear %Draws}
translate P TreeTotal {RAZEM}
# ====== TODO To be translated ======
translate P DoYouWantToSaveFirst {Czy chcesz najpierw zapisaæ?}

# ====== TODO To be translated ======
translate P AddToMask {Dodaj do maski}

# ====== TODO To be translated ======
translate P RemoveFromMask {Usuñ z maski}

# ====== TODO To be translated ======
translate P AddThisMoveToMask {Dodaj ten ruch do Maski}

# ====== TODO To be translated ======
translate P SearchMask {Szukaj w masce}

# ====== TODO To be translated ======
translate P DisplayMask {Wy¶wietl maskê}

# ====== TODO To be translated ======
translate P Nag {Kod Naga}

# ====== TODO To be translated ======
translate P Marker {Znacznik}

# ====== TODO To be translated ======
translate P Include {W³±czaæ}

# ====== TODO To be translated ======
translate P Exclude {Wykluczaæ}

# ====== TODO To be translated ======
translate P MainLine {Magistrala}

# ====== TODO To be translated ======
translate P Bookmark {Zak³adka w ksi±¿ce}

# ====== TODO To be translated ======
translate P NewLine {Nowa linia}

# ====== TODO To be translated ======
translate P ToBeVerified {Do sprawdzenia}

# ====== TODO To be translated ======
translate P ToTrain {Trenowaæ}

# ====== TODO To be translated ======
translate P Dubious {W±tpliwy}

# ====== TODO To be translated ======
translate P ToRemove {Aby usun±æ}

# ====== TODO To be translated ======
translate P NoMarker {Brak znacznika}

# ====== TODO To be translated ======
translate P ColorMarker {Kolor}

# ====== TODO To be translated ======
translate P WhiteMark {Bia³y}

# ====== TODO To be translated ======
translate P GreenMark {Zielony}

# ====== TODO To be translated ======
translate P YellowMark {¯ó³ty}

# ====== TODO To be translated ======
translate P BlueMark {Niebieski}

# ====== TODO To be translated ======
translate P RedMark {Czerwony}

# ====== TODO To be translated ======
translate P CommentMove {Komentarz ruchu}

# ====== TODO To be translated ======
translate P CommentPosition {Stanowisko komentarza}

# ====== TODO To be translated ======
translate P AddMoveToMaskFirst {Najpierw dodaj ruch do maski}

# ====== TODO To be translated ======
translate P OpenAMaskFileFirst {Najpierw otwórz plik maski}

# ====== TODO To be translated ======
translate P Positions {Pozycje}

# ====== TODO To be translated ======
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
# ====== TODO To be translated ======
translate P FinderCtxOpen {Otwarte}

# ====== TODO To be translated ======
translate P FinderCtxBackup {Kopia zapasowa}

# ====== TODO To be translated ======
translate P FinderCtxCopy {Kopia}

# ====== TODO To be translated ======
translate P FinderCtxMove {Przenosiæ}

# ====== TODO To be translated ======
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
# ====== TODO To be translated ======
menuText P GraphOptionsEloFile "Elo z pliku oceny" 0
# ====== TODO To be translated ======
menuText P GraphOptionsEloDB "Elo z bazy danych" 0
translate P GraphFilterTitle "Filtr: czêsto¶æ na 1000 partii" 
# ====== TODO To be translated ======
translate P GraphAbsFilterTitle "Wykres filtra: czêstotliwo¶æ gier"

# ====== TODO To be translated ======
translate P ConfigureFilter {Skonfiguruj osie X dla roku, oceny i ruchów}

# ====== TODO To be translated ======
translate P FilterEstimate "Oszacowaæ"

# ====== TODO To be translated ======
translate P TitleFilterGraph "Scid: Wykres filtra"


# Analysis window:
translate P AddVariation {Dodaj wariant}
# ====== TODO To be translated ======
translate P AddAllVariations {Dodaj wszystkie odmiany}

translate P AddMove {Dodaj posuniêcie}
translate P Annotate {Komentuj}
# ====== TODO To be translated ======
translate P ShowAnalysisBoard {Poka¿ tablicê analityczn±}

# ====== TODO To be translated ======
translate P ShowInfo {Poka¿ informacje o silniku}

# ====== TODO To be translated ======
translate P FinishGame {Zakoñcz grê}

# ====== TODO To be translated ======
translate P StopEngine {Zatrzymaj silnik}

# ====== TODO To be translated ======
translate P StartEngine {Uruchom silnik}

# ====== TODO To be translated ======
translate P LockEngine {Zablokuj silnik w bie¿±cej pozycji}

translate P AnalysisCommand {Program do analizy}
translate P PreviousChoices {Poprzednie programy}
translate P AnnotateTime {Czas miêdzy ruchami (w sekundach)}
translate P AnnotateWhich {Dodaj warianty}
translate P AnnotateAll {Dla obu stron}
# ====== TODO To be translated ======
translate P AnnotateAllMoves {Opisz wszystkie ruchy}

translate P AnnotateWhite {Dla bia³ych}
translate P AnnotateBlack {Dla czarnych}
# ====== TODO To be translated ======
translate P AnnotateBlundersOnly {Kiedy ruch w grze jest oczywistym b³êdem}

# ====== TODO To be translated ======
translate P AnnotateBlundersOnlyScoreChange {Analiza zg³asza b³±d i zmianê wyniku z/na:}

# ====== TODO To be translated ======
translate P BlundersThreshold {Próg}

# TODO: Translate
translate P ScoreAllMoves {Score all moves}
translate P LowPriority {Niski priorytet CPU} 
# ====== TODO To be translated ======
translate P ClickHereToSeeMoves {Kliknij tutaj, aby zobaczyæ ruchy}

# ====== TODO To be translated ======
translate P ConfigureInformant {Skonfiguruj Informatora}

# ====== TODO To be translated ======
translate P Informant!? {Ciekawe posuniêcie}

# ====== TODO To be translated ======
translate P Informant? {S³abe posuniêcie}

# ====== TODO To be translated ======
translate P Informant?? {Pomy³ka}

# ====== TODO To be translated ======
translate P Informant?! {W±tpliwe posuniêcie}

# ====== TODO To be translated ======
translate P Informant+= {Bia³e maj± niewielk± przewagê}

# ====== TODO To be translated ======
translate P Informant+/- {Bia³e maj± umiarkowan± przewagê}

# ====== TODO To be translated ======
translate P Informant+- {Bia³e maj± zdecydowan± przewagê}

# ====== TODO To be translated ======
translate P Informant+-- {Bia³e maj± mia¿d¿±c± przewagê}

# ====== TODO To be translated ======
translate P Book {Ksi±¿ka}

# ====== TODO To be translated ======
translate P OtherBookMoves {Ksi±¿ka przeciwnika}

# ====== TODO To be translated ======
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
# ====== TODO To be translated ======
translate P EngineProtocol {Protokó³ komunikacyjny}

# ====== TODO To be translated ======
translate P EngineNotation {Notacja ruchów}

# ====== TODO To be translated ======
translate P EngineFlipEvaluation {Odwróæ perspektywê oceny}

# ====== TODO To be translated ======
translate P EngineShowLog {Poka¿ dziennik komunikacji}

# ====== TODO To be translated ======
translate P EngineNetworkd {Akceptuj po³±czenia zdalne}

# ====== TODO To be translated ======
translate P EngineSelect {Wybierz bie¿±cy silnik}

# ====== TODO To be translated ======
translate P EngineAddLocal {Dodaj silnik lokalny}

# ====== TODO To be translated ======
translate P EngineAddRemote {Dodaj zdalny silnik}

# ====== TODO To be translated ======
translate P EngineReload {Za³aduj ponownie bie¿±cy silnik}

# ====== TODO To be translated ======
translate P EngineClone {Utwórz kopiê bie¿±cego silnika}

# ====== TODO To be translated ======
translate P EngineDelete {Usuñ bie¿±cy silnik}


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
# ====== TODO To be translated ======
menuText P PgnColorMain "Magistrala..." 0
# ====== TODO To be translated ======
menuText P PgnColorCurrent "Bie¿±ce t³o ruchu..." 1
menuText P PgnHelp "Pomoc" 2
menuText P PgnHelpPgn "PGN" 0
menuText P PgnHelpIndex "Spis tre¶ci" 0
translate P PgnWindowTitle {Game Notation - game %u} ;# ***

# Crosstable window menus:
menuText P CrosstabFile "Plik" 0
menuText P CrosstabFileText "Zapisz w pliku tekstowym..." 15
menuText P CrosstabFileHtml "Zapisz w pliku HTML..." 15
menuText P CrosstabFileLaTeX "Zapisz w pliku LaTeX-a..." 15
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
menuText P OprepFileLaTeX "Zapisz w pliku LaTeX-a..." 15
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
# ====== TODO To be translated ======
translate P PgnTag {Etykietka}

# ====== TODO To be translated ======
translate P TagContains {zawiera}

# ====== TODO To be translated ======
translate P Variant {Wariant}

# ====== TODO To be translated ======
translate P Annotator {Adnotator}

# ====== TODO To be translated ======
translate P Cmnts {Tylko gry z adnotacjami}

# ====== TODO To be translated ======
translate P Presets {Ustawienia wstêpne}

# ====== TODO To be translated ======
translate P PresetLoadSave {Za³aduj/Zapisz bie¿±ce ustawienia jako ustawienie wstêpne}


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
# ====== TODO To be translated ======
translate P GlistAverageElo {Przeciêtny Elo}

# ====== TODO To be translated ======
translate P GlistRating {Ocena}

translate P GlistFindText {Znajd¼ tekst}
translate P GlistMoveField {Przesuñ}
translate P GlistEditField {Konfiguruj}
translate P GlistAddField {Dodaj}
translate P GlistDeleteField {Usuñ}
translate P GlistWidth {Szeroko¶æ}
translate P GlistAlign {Wyrównanie}
# ====== TODO To be translated ======
translate P GlistAlignL {Wyrównaj: w lewo}

# ====== TODO To be translated ======
translate P GlistAlignR {Wyrównanie: prawda}

# ====== TODO To be translated ======
translate P GlistAlignC {Wyrównaj: do ¶rodka}

translate P GlistColor {Kolor}
translate P GlistSep {Separator}
# ====== TODO To be translated ======
translate P GlistCurrentSep {-- Aktualny --}

# ====== TODO To be translated ======
translate P GlistNewSort {Nowy}

# ====== TODO To be translated ======
translate P GlistAddToSort {Dodaæ}

# ====== TODO To be translated ======
translate P GsortSort {Sortowaæ...}

# ====== TODO To be translated ======
translate P GsortDate {Data}

# ====== TODO To be translated ======
translate P GsortYear {Rok}

# ====== TODO To be translated ======
translate P GsortEvent {Wydarzenie}

# ====== TODO To be translated ======
translate P GsortSite {Strona}

# ====== TODO To be translated ======
translate P GsortRound {Okr±g³y}

# ====== TODO To be translated ======
translate P GsortWhiteName {Bia³e imiê}

# ====== TODO To be translated ======
translate P GsortBlackName {Czarne imiê}

# ====== TODO To be translated ======
translate P GsortECO {EKO}

# ====== TODO To be translated ======
translate P GsortResult {Wynik}

# ====== TODO To be translated ======
translate P GsortMoveCount {Przenie¶ liczbê}

# ====== TODO To be translated ======
translate P GsortAverageElo {Przeciêtny Elo}

# ====== TODO To be translated ======
translate P GsortCountry {Kraj}

# ====== TODO To be translated ======
translate P GsortDeleted {Usuniêto}

# ====== TODO To be translated ======
translate P GsortEventDate {Data wydarzenia}

# ====== TODO To be translated ======
translate P GsortWhiteElo {Bia³e Elo}

# ====== TODO To be translated ======
translate P GsortBlackElo {Czarne Elo}

# ====== TODO To be translated ======
translate P GsortComments {Uwagi}

# ====== TODO To be translated ======
translate P GsortVariations {Wariacje}

# ====== TODO To be translated ======
translate P GsortNAGs {NAG}

# ====== TODO To be translated ======
translate P GsortAscending {Rosn±co}

# ====== TODO To be translated ======
translate P GsortDescending {Malej±co}

# ====== TODO To be translated ======
translate P GsortAdd {Dodaæ}

# ====== TODO To be translated ======
translate P GsortStore {Sklep}

# ====== TODO To be translated ======
translate P GsortLoad {Obci±¿enie}

# ====== TODO To be translated ======
translate P GlistRemoveThisGameFromFilter  {Usuñ tê grê z filtra}

# ====== TODO To be translated ======
translate P GlistRemoveGameAndAboveFromFilter  {Usuñ grê (i wszystko nad ni±) z filtra}

# ====== TODO To be translated ======
translate P GlistRemoveGameAndBelowFromFilter  {Usuñ grê (i wszystko poni¿ej) z filtra}

# ====== TODO To be translated ======
translate P GlistDeleteGame {(Nie)Usuñ tê grê} 

# ====== TODO To be translated ======
translate P GlistDeleteAllGames {Usuñ wszystkie gry z filtra} 

# ====== TODO To be translated ======
translate P GlistUndeleteAllGames {Przywróæ wszystkie gry w filtrze} 

# ====== TODO To be translated ======
translate P GlistMergeGameInBase {Po³±cz grê w innej bazie} 


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
# ====== TODO To be translated ======
translate P CustomFlags {Flagi niestandardowe}

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
# ====== TODO To be translated ======
translate P TwinCheckUndelete {odwracaæ; ?u? przywraca oba)}

# ====== TODO To be translated ======
translate P TwinCheckprevPair {Poprzednia para}

# ====== TODO To be translated ======
translate P TwinChecknextPair {Nastêpna para}

# ====== TODO To be translated ======
translate P TwinChecker {Scid: Kontroler gier bli¼niaczych}

# ====== TODO To be translated ======
translate P TwinCheckTournament {Gry w turnieju:}

# ====== TODO To be translated ======
translate P TwinCheckNoTwin {¯adnego bli¼niaka}

# ====== TODO To be translated ======
translate P TwinCheckNoTwinfound {W tej grze nie wykryto bli¼niaków.\nAby wy¶wietliæ bli¼niaki w tym oknie, musisz najpierw skorzystaæ z funkcji ?Usuñ gry bli¼niacze??.}

# ====== TODO To be translated ======
translate P TwinCheckTag {Udostêpnij tagi...}

# ====== TODO To be translated ======
translate P TwinCheckFound1 {Scid znalaz³ bli¼niacze gry $result}

# ====== TODO To be translated ======
translate P TwinCheckFound2 {i ustaw ich flagi usuwania}

# ====== TODO To be translated ======
translate P TwinCheckNoDelete {W tej bazie danych nie ma gier do usuniêcia.}

# ====== TODO To be translated ======
translate P TwinCriteria1 {Twoje ustawienia wyszukiwania gier bli¼niaczych mog± potencjalnie spowodowaæ, ¿e gry inne ni¿ bli¼niacze z podobnymi ruchami bêd± oznaczone jako bli¼niacze.}

# ====== TODO To be translated ======
translate P TwinCriteria2 {Zaleca siê, aby w przypadku wybrania opcji ?Nie? dla ?tych samych ruchów? wybraæ ?Tak? dla ustawieñ kolorów, wydarzenia, miejsca, rundy, roku i miesi±ca.\nCzy mimo to chcesz kontynuowaæ i usun±æ bli¼niaki?}

# ====== TODO To be translated ======
translate P TwinCriteria3 {Zaleca siê wybranie opcji ?Tak? dla co najmniej dwóch ustawieñ ?ta sama witryna?, ?ta sama runda? i ?ten sam rok?.\nCzy mimo to chcesz kontynuowaæ i usun±æ bli¼niaki?}

# ====== TODO To be translated ======
translate P TwinCriteriaConfirm {Scid: Potwierd¼ ustawienia bli¼niacze}

# ====== TODO To be translated ======
translate P TwinChangeTag "Zmieñ nastêpuj±ce tagi gry:\n\n"

# ====== TODO To be translated ======
translate P AllocRatingDescription "To polecenie u¿yje bie¿±cego pliku sprawdzania pisowni, aby dodaæ oceny Elo do gier w tej bazie danych. Je¶li gracz nie ma aktualnej oceny, ale jego ocena w momencie gry jest podana w pliku sprawdzania pisowni, ocena ta zostanie dodana."

# ====== TODO To be translated ======
translate P RatingOverride "Zast±piæ istniej±ce niezerowe oceny?"

# ====== TODO To be translated ======
translate P AddRatings "Dodaj oceny do:"

# ====== TODO To be translated ======
translate P AddedRatings {Scid doda³ rankingi Elo $r w grach za $g.}

# ====== TODO To be translated ======
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
# ====== TODO To be translated ======
translate P WhiteCrushing {Bia³e maj± mia¿d¿±c± przewagê}

# ====== TODO To be translated ======
translate P BlackCrushing {Czarne maj± mia¿d¿±c± przewagê}

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
# ====== TODO To be translated ======
translate P SearchInRefDatabase {Szukaj w bazie}

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
# ====== TODO To be translated ======
translate P SaveAndContinue {Zapisz i kontynuuj}

# ====== TODO To be translated ======
translate P DiscardChangesAndContinue {Odrzuæ zmiany\i kontynuuj}

# ====== TODO To be translated ======
translate P GoBack {Wracaæ}


# Replace move dialog:
translate P ReplaceMove {Zmieñ posuniêcie}
translate P AddNewVar {Dodaj wariant}
# ====== TODO To be translated ======
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
# ====== TODO To be translated ======
translate P OverwriteExistingMoves {Zast±piæ istniej±ce ruchy?}


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
translate P OprepViewHTML {¬ród³o HTML} 
translate P OprepViewLaTeX {¬ród³o LaTeX} 

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
# ====== TODO To be translated ======
translate P CheckGames {Sprawd¼ gry}

# ====== TODO To be translated ======
translate P CheckGamesWhich {Sprawd¼ gry}

# ====== TODO To be translated ======
translate P CheckAll {Wszystkie gry}

# ====== TODO To be translated ======
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
# ====== TODO To be translated ======
translate P NoUnusedNames "Nie ma ¿adnych nieu¿ywanych nazw, wiêc plik nazw jest ju¿ w pe³ni skompaktowany."

# ====== TODO To be translated ======
translate P NoUnusedGames "Plik gry jest ju¿ w pe³ni skompaktowany."

# ====== TODO To be translated ======
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
# ====== TODO To be translated ======
translate P CopyAllGames {Skopiuj wszystkie gry do}


# Copy games dialog:
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
translate P SoundsAnnounceForward {Announce moves when moving forward one move} ;# ***
translate P SoundsAnnounceBack {Announce when retracting or moving back one move} ;# ***
# ====== TODO To be translated ======
translate P SoundsSoundDisabled {Scid nie móg³ znale¼æ pakietu audio Snack podczas uruchamiania;\nD¼wiêk jest wy³±czony.}


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
# ====== TODO To be translated ======
translate P showblunderexists {pokazaæ, ¿e b³±d istnieje}

# ====== TODO To be translated ======
translate P showblundervalue {poka¿ warto¶æ b³êdu}

# ====== TODO To be translated ======
translate P showscore {poka¿ wynik}

# ====== TODO To be translated ======
translate P coachgame {gra trenerska}

# ====== TODO To be translated ======
translate P configurecoachgame {skonfiguruj grê trenersk±}

# ====== TODO To be translated ======
translate P configuregame {Konfiguracja gry}

# ====== TODO To be translated ======
translate P Phalanxengine {Silnik Falangi}

# ====== TODO To be translated ======
translate P Coachengine {Silnik autokaru}

# ====== TODO To be translated ======
translate P difficulty {trudno¶æ}

# ====== TODO To be translated ======
translate P hard {twardy}

# ====== TODO To be translated ======
translate P easy {³atwy}

# ====== TODO To be translated ======
translate P Playwith {Zagraj z}

# ====== TODO To be translated ======
translate P white {bia³y}

# ====== TODO To be translated ======
translate P black {czarny}

# ====== TODO To be translated ======
translate P both {Zarówno}

# ====== TODO To be translated ======
translate P Play {Graæ}

# ====== TODO To be translated ======
translate P Noblunder {¯adnej pomy³ki}

# ====== TODO To be translated ======
translate P blunder {pomy³ka}

# ====== TODO To be translated ======
translate P Noinfo {-- Brak informacji --}

# ====== TODO To be translated ======
translate P PhalanxOrTogaMissing {Nie znaleziono falangi ani togi}

# ====== TODO To be translated ======
translate P moveblunderthreshold {ruch jest b³êdem, je¶li strata jest wiêksza ni¿}

# ====== TODO To be translated ======
translate P limitanalysis {ograniczyæ czas analizy silnika}

# ====== TODO To be translated ======
translate P seconds {towary drugiej jako¶ci}

# ====== TODO To be translated ======
translate P Abort {Poroniæ}

# ====== TODO To be translated ======
translate P Resume {Wznawiaæ}

# ====== TODO To be translated ======
translate P OutOfOpening {Poza otwarciem}

# ====== TODO To be translated ======
translate P NotFollowedLine {Nie zastosowa³e¶ siê do linii}

# ====== TODO To be translated ======
translate P DoYouWantContinue {Czy chcesz kontynuowaæ?}

# ====== TODO To be translated ======
translate P CoachIsWatching {Trener patrzy}

# ====== TODO To be translated ======
translate P Ponder {Ci±g³e my¶lenie}

# ====== TODO To be translated ======
translate P LimitELO {Ogranicz si³ê ELO}

# ====== TODO To be translated ======
translate P DubiousMovePlayedTakeBack {Wykonano w±tpliwe posuniêcie, czy chcesz je cofn±æ?}

# ====== TODO To be translated ======
translate P WeakMovePlayedTakeBack {Zagrano s³aby ruch, czy chcesz cofn±æ?}

# ====== TODO To be translated ======
translate P BadMovePlayedTakeBack {Wykonano z³y ruch. Czy chcesz go cofn±æ?}

# ====== TODO To be translated ======
translate P Iresign {rezygnujê}

# ====== TODO To be translated ======
translate P yourmoveisnotgood {twoje posuniêcie nie jest dobre}

# ====== TODO To be translated ======
translate P EndOfVar {Koniec zmienno¶ci}

# ====== TODO To be translated ======
translate P Openingtrainer {Trener otwarcia}

# ====== TODO To be translated ======
translate P DisplayCM {Wy¶wietl ruchy kandydatów}

# ====== TODO To be translated ======
translate P DisplayCMValue {Wy¶wietl warto¶æ ruchów kandydata}

# ====== TODO To be translated ======
translate P DisplayOpeningStats {Poka¿ statystyki}

# ====== TODO To be translated ======
translate P ShowReport {Poka¿ raport}

# ====== TODO To be translated ======
translate P NumberOfGoodMovesPlayed {zagrane dobre ruchy}

# ====== TODO To be translated ======
translate P NumberOfDubiousMovesPlayed {rozegrane w±tpliwe ruchy}

# ====== TODO To be translated ======
translate P NumberOfMovesPlayedNotInRepertoire {ruchy grane poza repertuarem}

# ====== TODO To be translated ======
translate P NumberOfTimesPositionEncountered {razy napotkana pozycja}

# ====== TODO To be translated ======
translate P PlayerBestMove  {Zezwalaj tylko na najlepsze ruchy}

# ====== TODO To be translated ======
translate P OpponentBestMove {Przeciwnik wykonuje najlepsze ruchy}

# ====== TODO To be translated ======
translate P OnlyFlaggedLines {Tylko oznaczone linie}

# ====== TODO To be translated ======
translate P resetStats {Zresetuj statystyki}

# ====== TODO To be translated ======
translate P Repertoiretrainingconfiguration {Konfiguracja treningu repertuarowego}

# ====== TODO To be translated ======
translate P Loadingrepertoire {£adowanie repertuaru}

# ====== TODO To be translated ======
translate P Movesloaded {Ruchy za³adowane}

# ====== TODO To be translated ======
translate P Repertoirenotfound {Nie znaleziono repertuaru}

# ====== TODO To be translated ======
translate P Openfirstrepertoirewithtype {Otwórz najpierw bazê danych repertuaru z ikon±/typem ustawionym po prawej stronie}

# ====== TODO To be translated ======
translate P Movenotinrepertoire {Ruch nie w repertuarze}

# ====== TODO To be translated ======
translate P PositionsInRepertoire {Pozycje w repertuarze}

# ====== TODO To be translated ======
translate P PositionsNotPlayed {Pozycje nie grane}

# ====== TODO To be translated ======
translate P PositionsPlayed {Grane pozycje}

# ====== TODO To be translated ======
translate P Success {Sukces}

# ====== TODO To be translated ======
translate P DubiousMoves {W±tpliwe ruchy}

# ====== TODO To be translated ======
translate P OutOfRepertoire {Poza repertuarem}

# ====== TODO To be translated ======
translate P ConfigureTactics {Skonfiguruj taktykê}

# ====== TODO To be translated ======
translate P ResetScores {Resetuj wyniki}

# ====== TODO To be translated ======
translate P LoadingBase {Baza za³adunkowa}

# ====== TODO To be translated ======
translate P Tactics {Taktyka}

# ====== TODO To be translated ======
translate P ShowSolution {Poka¿ rozwi±zanie}

# ====== TODO To be translated ======
translate P NextExercise {Nastêpne æwiczenie}

# ====== TODO To be translated ======
translate P PrevExercise {poprzednie æwiczenie}

# ====== TODO To be translated ======
translate P StopTraining {Przestañ trenowaæ}

# ====== TODO To be translated ======
translate P Next {Nastêpny}

# ====== TODO To be translated ======
translate P ResettingScore {Resetowanie wyniku}

# ====== TODO To be translated ======
translate P LoadingGame {£adowanie gry}

# ====== TODO To be translated ======
translate P MateFound {Znaleziony kumpel}

# ====== TODO To be translated ======
translate P BestSolutionNotFound {NIE znaleziono najlepszego rozwi±zania!}

# ====== TODO To be translated ======
translate P MateNotFound {Nie znaleziono partnera}

# ====== TODO To be translated ======
translate P ShorterMateExists {Istnieje krótszy partner}

# ====== TODO To be translated ======
translate P ScorePlayed {Wynik rozegrany}

# ====== TODO To be translated ======
translate P Expected {oczekiwany}

# ====== TODO To be translated ======
translate P ChooseTrainingBase {Wybierz bazê szkoleniow±}

# ====== TODO To be translated ======
translate P Thinking {My¶l±cy}

# ====== TODO To be translated ======
translate P AnalyzeDone {Analiza wykonana}

# ====== TODO To be translated ======
translate P WinWonGame {Wygrana wygrana gra}

# ====== TODO To be translated ======
translate P Lines {Kwestia}

# ====== TODO To be translated ======
translate P ConfigureUCIengine {Skonfiguruj silnik UCI}

# ====== TODO To be translated ======
translate P SpecificOpening {Konkretne otwarcie}

# ====== TODO To be translated ======
translate P StartNewGame {Rozpocznij now± grê}

# ====== TODO To be translated ======
translate P FixedLevel {Sta³y poziom}

# ====== TODO To be translated ======
translate P Opening {Otwór}

# ====== TODO To be translated ======
translate P RandomLevel {Losowy poziom}

# ====== TODO To be translated ======
translate P StartFromCurrentPosition {Zacznij od aktualnej pozycji}

# ====== TODO To be translated ======
translate P FixedDepth {Sta³a g³êboko¶æ}

# ====== TODO To be translated ======
translate P Nodes {Wêz³y} 

# ====== TODO To be translated ======
translate P Depth {G³êboko¶æ}

# ====== TODO To be translated ======
translate P Time {Czas} 

# ====== TODO To be translated ======
translate P SecondsPerMove {Sekundy na ruch}

# ====== TODO To be translated ======
translate P Engine {Silnik}

# ====== TODO To be translated ======
translate P TimeMode {Tryb czasu}

# ====== TODO To be translated ======
translate P TimeBonus {Czas + premia}

# ====== TODO To be translated ======
translate P TimeMin {min}

# ====== TODO To be translated ======
translate P TimeSec {sek}

# ====== TODO To be translated ======
translate P AllExercisesDone {Wszystkie æwiczenia wykonane}

# ====== TODO To be translated ======
translate P MoveOutOfBook {Wyjd¼ z ksi±¿ki}

# ====== TODO To be translated ======
translate P LastBookMove {Ostatni ruch ksi±¿kowy}

# ====== TODO To be translated ======
translate P AnnotateSeveralGames {Adnotuj kilka gier\od bie¿±cego do:}

# ====== TODO To be translated ======
translate P FindOpeningErrors {Znajd¼ b³êdy otwierania}

# ====== TODO To be translated ======
translate P MarkTacticalExercises {Zaznacz æwiczenia taktyczne}

# ====== TODO To be translated ======
translate P UseBook {Skorzystaj z ksi±¿ki}

# ====== TODO To be translated ======
translate P MultiPV {Wiele odmian}

# ====== TODO To be translated ======
translate P Hash {Pamiêæ haszuj±ca}

# ====== TODO To be translated ======
translate P OwnBook {Skorzystaj z ksi±¿ki silnika}

# ====== TODO To be translated ======
translate P BookFile {Otwieranie ksi±¿ki}

# ====== TODO To be translated ======
translate P AnnotateVariations {Opisz odmiany}

# ====== TODO To be translated ======
translate P ShortAnnotations {Krótkie adnotacje}

# ====== TODO To be translated ======
translate P addAnnotatorTag {Dodaj tag adnotatora}

# ====== TODO To be translated ======
translate P AddScoreToShortAnnotations {Dodaj ocenê do krótkich adnotacji}

# ====== TODO To be translated ======
translate P Export {Eksport}

# ====== TODO To be translated ======
translate P BookPartiallyLoaded {Ksi±¿ka czê¶ciowo za³adowana}

# ====== TODO To be translated ======
translate P Calvar {Obliczanie zmian}

# ====== TODO To be translated ======
translate P ConfigureCalvar {Konfiguracja}

# ====== TODO To be translated ======
translate P Reti {Reti}

# ====== TODO To be translated ======
translate P English {angielski}

# ====== TODO To be translated ======
translate P d4Nf6Miscellaneous {1.d4 Sf6 Ró¿ne}

# ====== TODO To be translated ======
translate P Trompowsky {Trompowskiego}

# ====== TODO To be translated ======
translate P Budapest {Budapeszt}

# ====== TODO To be translated ======
translate P OldIndian {Stary Indianin}

# ====== TODO To be translated ======
translate P BenkoGambit {Benko Gambit}

# ====== TODO To be translated ======
translate P ModernBenoni {Nowoczesne Benoniego}

# ====== TODO To be translated ======
translate P DutchDefence {Holenderska obrona}

# ====== TODO To be translated ======
translate P Scandinavian {skandynawski}

# ====== TODO To be translated ======
translate P AlekhineDefence {Obrona Alechina}

# ====== TODO To be translated ======
translate P Pirc {Pirc}

# ====== TODO To be translated ======
translate P CaroKann {Caro-Kann}

# ====== TODO To be translated ======
translate P CaroKannAdvance {Postêp Caro-Kanna}

# ====== TODO To be translated ======
translate P Sicilian {sycylijski}

# ====== TODO To be translated ======
translate P SicilianAlapin {Sycylijski Alapin}

# ====== TODO To be translated ======
translate P SicilianClosed {Sycylijski zamkniêty}

# ====== TODO To be translated ======
translate P SicilianRauzer {Sycylijski Rauzer}

# ====== TODO To be translated ======
translate P SicilianDragon {Sycylijski smok}

# ====== TODO To be translated ======
translate P SicilianScheveningen {Sycylijskie Scheveningen}

# ====== TODO To be translated ======
translate P SicilianNajdorf {Sycylijczyk Najdorf}

# ====== TODO To be translated ======
translate P OpenGame {Otwórz grê}

# ====== TODO To be translated ======
translate P Vienna {Wiedeñ}

# ====== TODO To be translated ======
translate P KingsGambit {Królewski gambit}

# ====== TODO To be translated ======
translate P RussianGame {Rosyjska gra}

# ====== TODO To be translated ======
translate P ItalianTwoKnights {W³och/Dwóch Rycerzy}

# ====== TODO To be translated ======
translate P Spanish {hiszpañski}

# ====== TODO To be translated ======
translate P SpanishExchange {Wymiana hiszpañska}

# ====== TODO To be translated ======
translate P SpanishOpen {Otwarte Hiszpañskie}

# ====== TODO To be translated ======
translate P SpanishClosed {Hiszpañski Zamkniêty}

# ====== TODO To be translated ======
translate P FrenchDefence {Obrona francuska}

# ====== TODO To be translated ======
translate P FrenchAdvance {Awans francuski}

# ====== TODO To be translated ======
translate P FrenchTarrasch {Francuski Tarrasch}

# ====== TODO To be translated ======
translate P FrenchWinawer {Francuski Winawer}

# ====== TODO To be translated ======
translate P FrenchExchange {Wymiana francuska}

# ====== TODO To be translated ======
translate P QueensPawn {Pionek królowej}

# ====== TODO To be translated ======
translate P Slav {s³owiañski}

# ====== TODO To be translated ======
translate P QGA {QGA}

# ====== TODO To be translated ======
translate P QGD {QGD}

# ====== TODO To be translated ======
translate P QGDExchange {Wymiana QGD}

# ====== TODO To be translated ======
translate P SemiSlav {Pó³-s³owiañski}

# ====== TODO To be translated ======
translate P QGDwithBg5 {QGD z Bg5}

# ====== TODO To be translated ======
translate P QGDOrthodox {QGD ortodoksyjny}

# ====== TODO To be translated ======
translate P Grunfeld {Grunfeld}

# ====== TODO To be translated ======
translate P GrunfeldExchange {Grünfeld Exchange}

# ====== TODO To be translated ======
translate P GrunfeldRussian {Grunfeld Rosyjski}

# ====== TODO To be translated ======
translate P Catalan {kataloñski}

# ====== TODO To be translated ======
translate P CatalanOpen {Kataloñski Otwarty}

# ====== TODO To be translated ======
translate P CatalanClosed {Kataloñski zamkniêty}

# ====== TODO To be translated ======
translate P QueensIndian {Indianin królowej}

# ====== TODO To be translated ======
translate P NimzoIndian {Nimzo-Indianin}

# ====== TODO To be translated ======
translate P NimzoIndianClassical {Nimzo-indyjska klasyka}

# ====== TODO To be translated ======
translate P NimzoIndianRubinstein {Nimzo ? Indianin Rubinstein}

# ====== TODO To be translated ======
translate P KingsIndian {Królewski Indianin}

# ====== TODO To be translated ======
translate P KingsIndianSamisch {Królewski indyjski Sämisch}

# ====== TODO To be translated ======
translate P KingsIndianMainLine {G³ówna linia King's Indian}

# ====== TODO To be translated ======
translate P ConfigureFics {Skonfiguruj FICS}

# ====== TODO To be translated ======
translate P FICSGuest {Zaloguj siê jako go¶æ}

# ====== TODO To be translated ======
translate P FICSServerPort {Port serwera}

# ====== TODO To be translated ======
translate P FICSServerAddress {Adres IP}

# ====== TODO To be translated ======
translate P FICSRefresh {Od¶wie¿aæ}

# ====== TODO To be translated ======
translate P FICSTimesealPort {Port Timeseal}

# ====== TODO To be translated ======
translate P FICSSilence {Cisza}

# ====== TODO To be translated ======
translate P FICSOffers {Oferty}

# ====== TODO To be translated ======
translate P FICSConsole {Konsola}

# ====== TODO To be translated ======
translate P FICSGames {Zawody sportowe}

# ====== TODO To be translated ======
translate P FICSUnobserve {Przestañ obserwowaæ grê}

# ====== TODO To be translated ======
translate P FICSProfile {Wy¶wietl swoj± historiê i profil}

# ====== TODO To be translated ======
translate P FICSRelayedGames {Przekazywane gry}

# ====== TODO To be translated ======
translate P FICSFindOpponent {Znajd¼ przeciwnika}

# ====== TODO To be translated ======
translate P FICSTakeback {Odbiór}

# ====== TODO To be translated ======
translate P FICSTakeback2 {Odbiór 2}

# ====== TODO To be translated ======
translate P FICSInitTime {Czas pocz±tkowy (min)}

# ====== TODO To be translated ======
translate P FICSIncrement {Przyrost (s)}

# ====== TODO To be translated ======
translate P FICSRatedGame {Oceniana gra}

# ====== TODO To be translated ======
translate P FICSAutoColour {automatyczny}

# ====== TODO To be translated ======
translate P FICSManualConfirm {potwierd¼ rêcznie}

# ====== TODO To be translated ======
translate P FICSFilterFormula {Filtruj za pomoc± formu³y}

# ====== TODO To be translated ======
translate P FICSIssueSeek {Szukaj problemu}

# ====== TODO To be translated ======
translate P FICSChallenge {Wyzwanie}

# ====== TODO To be translated ======
translate P FICSAccept {przyj±æ}

# ====== TODO To be translated ======
translate P FICSDecline {spadek}

# ====== TODO To be translated ======
translate P FICSColour {Kolor}

# ====== TODO To be translated ======
translate P FICSSend {wys³aæ}

# ====== TODO To be translated ======
translate P FICSConnect {£±czyæ}

# ====== TODO To be translated ======
translate P FICSdefaultuservars {U¿yj zmiennych domy¶lnych}

# ====== TODO To be translated ======
translate P FICSObserveconfirm {Chcesz obserwowaæ grê}

# ====== TODO To be translated ======
translate P FICSpremove {W³±cz wstêpne przesuwanie}

# ====== TODO To be translated ======
translate P FICSObserve {Przestrzegaæ}

# ====== TODO To be translated ======
translate P FICSRatedGames {Ocenione gry}

# ====== TODO To be translated ======
translate P FICSUnratedGames {Gry bez oceny}

# ====== TODO To be translated ======
translate P FICSRated {Oceniono}

# ====== TODO To be translated ======
translate P FICSUnrated {Bez oceny}

# ====== TODO To be translated ======
translate P FICSRegisteredPlayer {Tylko zarejestrowany gracz}

# ====== TODO To be translated ======
translate P FICSFreePlayer {Tylko darmowy gracz}

# ====== TODO To be translated ======
translate P FICSNetError {B³±d sieci\Nie mo¿na siê po³±czyæ}

# ====== TODO To be translated ======
translate P GameReview {Recenzja gry}

# ====== TODO To be translated ======
translate P GameReviewTimeExtended {Czas wyd³u¿ony}

# ====== TODO To be translated ======
translate P GameReviewMargin {Margines b³êdu}

# ====== TODO To be translated ======
translate P GameReviewAutoContinue {Automatyczna kontynuacja, gdy ruch jest prawid³owy}

# ====== TODO To be translated ======
translate P GameReviewReCalculate {U¿yj wyd³u¿onego czasu}

# ====== TODO To be translated ======
translate P GameReviewAnalyzingMovePlayedDuringTheGame {Analizowanie ruchu wykonanego w trakcie gry}

# ====== TODO To be translated ======
translate P GameReviewAnalyzingThePosition {Analiza pozycji}

# ====== TODO To be translated ======
translate P GameReviewEnterYourMove {Wpisz swój ruch}

# ====== TODO To be translated ======
translate P GameReviewCheckingYourMove {Sprawdzam Twój ruch}

# ====== TODO To be translated ======
translate P GameReviewYourMoveWasAnalyzed {Twój ruch zosta³ przeanalizowany}

# ====== TODO To be translated ======
translate P GameReviewYouPlayedSameMove {Wykona³e¶ ten sam ruch, co w meczu}

# ====== TODO To be translated ======
translate P GameReviewScoreOfYourMove {Wynik Twojego ruchu}

# ====== TODO To be translated ======
translate P GameReviewGameMoveScore {Wynik ruchu w grze}

# ====== TODO To be translated ======
translate P GameReviewEngineScore {Wynik silnika}

# ====== TODO To be translated ======
translate P GameReviewYouPlayedLikeTheEngine {Gra³e¶ jak silnik}

# ====== TODO To be translated ======
translate P GameReviewNotEngineMoveButGoodMove {Nie chodzi tu o ruch silnika, ale te¿ jest to dobry ruch}

# ====== TODO To be translated ======
translate P GameReviewMoveNotGood {Ten ruch nie jest dobry, wynik jest}

# ====== TODO To be translated ======
translate P GameReviewMovesPlayedLike {Ruchy grane jak}

# ====== TODO To be translated ======
translate P GameReviewMovesPlayedEngine {Ruchy grane jak silnik}

# ====== TODO To be translated ======
translate P CCDlgCGeneraloptions {Opcje ogólne}

# ====== TODO To be translated ======
translate P CCDlgLoginName  {Nazwa logowania:}

# ====== TODO To be translated ======
translate P CCDlgPassword   {Has³o:}

# ====== TODO To be translated ======
translate P CCDlgShowPassword {Poka¿ has³o}

# ====== TODO To be translated ======
translate P ExtHWConfigConnection {Skonfiguruj sprzêt zewnêtrzny}

# ====== TODO To be translated ======
translate P ExtHWPort {Port}

# ====== TODO To be translated ======
translate P ExtHWEngineCmd {Polecenie silnika}

# ====== TODO To be translated ======
translate P ExtHWEngineParam {Parametr silnika}

# ====== TODO To be translated ======
translate P ExtHWShowButton {Poka¿ przycisk}

# ====== TODO To be translated ======
translate P ExtHWHardware {Sprzêt komputerowy}

# ====== TODO To be translated ======
translate P ExtHWNovag {Novag Cytryn}

# ====== TODO To be translated ======
translate P ExtHWInputEngine {Silnik wej¶ciowy}

# ====== TODO To be translated ======
translate P ExtHWNoBoard {Brak deski}

# ====== TODO To be translated ======
translate P NovagReferee {Sêdzia}

# ====== TODO To be translated ======
translate P IEConsole {Konsola silnika wej¶ciowego}

# ====== TODO To be translated ======
translate P IESending {Wys³ano ruchy}

# ====== TODO To be translated ======
translate P IESynchronise {Synchronizowaæ}

# ====== TODO To be translated ======
translate P IERotate  {Obracaæ}

# ====== TODO To be translated ======
translate P IEUnableToStart {Nie mo¿na uruchomiæ mechanizmu wej¶ciowego:}

# ====== TODO To be translated ======
translate P DoneWithPosition {Koniec z pozycj±}

# ====== TODO To be translated ======
translate P Board {Tablica}

# ====== TODO To be translated ======
translate P showGameInfo {Poka¿ informacje o grze}

# ====== TODO To be translated ======
translate P autoResizeBoard {Automatyczna zmiana rozmiaru planszy}

# ====== TODO To be translated ======
translate P DockTop {Przejd¼ na górê}

# ====== TODO To be translated ======
translate P DockBottom {Przejd¼ na dó³}

# ====== TODO To be translated ======
translate P DockLeft {Przejd¼ w lewo}

# ====== TODO To be translated ======
translate P DockRight {Przejd¼ w prawo}

# ====== TODO To be translated ======
translate P Undock {Oddokuj}

# ====== TODO To be translated ======
translate P AboutDatabase {O tej bazie danych}

# ====== TODO To be translated ======
translate P ChangeIcon {Zmieñ ikonê...}

# ====== TODO To be translated ======
translate P NewGameListWindow {Nowe okno listy gier}

# ====== TODO To be translated ======
translate P LoadatStartup {Za³aduj przy uruchomieniu}

# ====== TODO To be translated ======
translate P ShowHideDB {Poka¿/ukryj bazy danych}

# ====== TODO To be translated ======
translate P ChangeFilter {Zmieñ filtr}

# ====== TODO To be translated ======
translate P ChangeLayout {Za³aduj/Zapisz/Zmieñ kryteria sortowania i uk³ad kolumn}

# ====== TODO To be translated ======
translate P ShowHideStatistic {Poka¿/ukryj statystyki}

# ====== TODO To be translated ======
translate P BoardFilter {Poka¿ tylko gry pasuj±ce do aktualnej pozycji na planszy}

# ====== TODO To be translated ======
translate P CopyGameTo {Skopiuj grê do}

# ====== TODO To be translated ======
translate P FindBar {Znajd¼ pasek}

# ====== TODO To be translated ======
translate P FindCurrentGame {Znajd¼ bie¿±c± grê}

# ====== TODO To be translated ======
translate P DeleteGame {Usuñ grê}

# ====== TODO To be translated ======
translate P UndeleteGame {Przywróæ grê}

# ====== TODO To be translated ======
translate P ResetSort {Zresetuj sortowanie}

# ====== TODO To be translated ======
translate P ConvertNullMove {Konwertuj ruchy zerowe na komentarze}

# ====== TODO To be translated ======
translate P SetupBoard {P³yta konfiguracyjna}

# ====== TODO To be translated ======
translate P Rotate {Obracaæ}

# ====== TODO To be translated ======
translate P SwitchColors {Zmieñ kolory}

# ====== TODO To be translated ======
translate P FlipBoard {Odwróæ tablicê}

# ====== TODO To be translated ======
translate P ImportPGN {Importuj grê PGN}

# ====== TODO To be translated ======
translate P ImportingFiles {Importowanie plików PGN w formacie}

# ====== TODO To be translated ======
translate P ImportingFrom {Importowanie z}

# ====== TODO To be translated ======
translate P ImportingIn {Importuj gry do}

# ====== TODO To be translated ======
translate P UseLastTag {U¿yj tagów ostatniej gry}

# ====== TODO To be translated ======
translate P Random {Losowy}

# ====== TODO To be translated ======
translate P BackToMainline {Wróæ do g³ównego nurtu}

# ====== TODO To be translated ======
translate P LeaveVariant {Opu¶æ wariant}

# ====== TODO To be translated ======
translate P Autoplay {Autoodtwarzanie}

# ====== TODO To be translated ======
translate P ShowHideCoords {Poka¿/Ukryj wspó³rzêdne.}

# ====== TODO To be translated ======
translate P ShowHideEvalBar {Poka¿/ukryj pasek oceny}

# ====== TODO To be translated ======
translate P ShowHideMaterial {Poka¿/ukryj materia³}

# ====== TODO To be translated ======
translate P SelectMarker {Wybierz opcjê Znacznik}

# ====== TODO To be translated ======
translate P FullScreen {Pe³ny ekran}

# ====== TODO To be translated ======
translate P FilterStatistic {Statystyki filtrów}

# ====== TODO To be translated ======
translate P MakeCorrections {Wprowad¼ poprawki}

# ====== TODO To be translated ======
translate P Surnames {Nazwiska}

# ====== TODO To be translated ======
translate P Ambiguous {Dwuznaczny}

translate P OptionsToolbar "Pasek narzêdziowy"
translate P OptionsBoard "Szachownica"
translate P OptionsBoardSize "Wielko¶æe"
translate P OptionsBoardPieces "Typ figur"
# ====== TODO To be translated ======
translate P OptionsInternationalization "Umiêdzynarodowienie"

# ====== TODO To be translated ======
translate P OptionsTablebaseDir "Wybierz maksymalnie 4 foldery bazowe tabeli:"

# ====== TODO To be translated ======
translate P BestMoveArrow "Najlepsza strza³ka ruchu"

# ====== TODO To be translated ======
translate P NewLocalEngine "+ Nowy silnik..."

}

### Tips of the day in Polish:

set tips(P) {
  {
    Scid ma ponad 30 <a Index>stron pomocy</a> i w wiêkszo¶ci okien Scida
    naci¶niêcie klawisza <b>F1</b> spowoduje wy¶wietlenie odpowiedniej
    strony.
  }
  {
    Niektóre okna Scida (np. informacje pod szachownic±,
    <a Switcher>prze³±cznik baz</a>) maj± menu przywo³ywane prawym przyciskiem
    myszy. Spróbuj nacisn±æ prawy przycisk myszy w ka¿dym oknie, by
    sprawdziæ, czy menu jest dostêpne i jakie funkcje zawiera.
  }
  {
    Scid pozwala wprowadzaæ posuniêcia na kilka ró¿nych sposobów.
    Mo¿esz u¿yæ myszy (z wy¶wietlaniem mo¿liwych posuniêæ lub bez)
    albo klawiatury (z opcjonalnym automatycznym dope³nianiem).
    Wiêcej informacji mo¿na znale¼æ na stronie pomocy
    <a Moves>Wprowadzenie posuniêæ</a>.
  }
  {
    Je¶li masz kilka baz, które otwierasz czêsto, dodaj
    <a Bookmarks>zak³adkê</a> dla ka¿dej z nich. Umo¿liwi to ³atwe
    otwieranie baz z menu.
  }
  {
    Mo¿esz obejrzeæ wszystkie posuniêcia w aktualnej partii
    (z wariantami i komentarzami lub bez) w <a PGN>Oknie PGN</a>.
    W oknie PGN mo¿esz przej¶æ do dowolnego posuniêcia, klikaj±c
    na nim lewym przyciskiem myszy oraz u¿yæ ¶rodkowego lub prawego
    przycisku myszy do obejrzenia aktualnej pozycji.
  }
  {
    Mo¿esz kopiowaæ partie z bazy do bazy przeci±gaj±c je lewym
    przyciskiem myszy w oknie <a Switcher>Prze³±cznika baz</a>.
  }
  {
    Scid mo¿e otwieraæ pliki PGN, nawet je¶li s± one skompresowane
    Gzip-em (z rozszerzeniem .gz). Pliki PGN mog± byæ jedynie
    czytane, wiêc je¶li chcesz co¶ zmieniæ, utwórz now± bazê Scida
    i skopiuj do niej partie z pliku PGN.
  }
  {
    Je¶li masz du¿± bazê i czêsto u¿ywasz okna <a Tree>Drzewa wariantów</a>,
    warto wybraæ polecenie <b>Twórz standardowy plik cache/b>
    z menu Plik okna Drzewo wariantów. Statystyki dla najpopularniejszych
    pozycji debiutowych zostan± zapamiêtane w pliku, co przyspieszy
    dzia³anie drzewa.
  }
  {
    <a Tree>Drzewo wariantów</a> mo¿e pokazaæ wszystkie posuniêcia
    z aktualnej pozycji, ale je¶li chcesz zobaczyæ wszystkie kolejno¶ci
    posuniêæ prowadz±ce do aktualnej pozycji, mo¿esz u¿yæ
    <a OpReport>Raportu debiutowego</a>.
  }
  {
    W <a GameList>li¶cie partii</a> kliknij lewym lub prawym przyciskiem
    myszy na nag³ówku wybranej kolumny, by zmieniæ jej szeroko¶æ.
  }
  {
    W oknie <a PInfo>Informacja o graczu</a> (kliknij na nazwisku gracza
    w polu pod szachownic±, by je otworzyæ) mo¿esz ³atwo ustawiæ
    <a Searches Filter>filtr</a> zawieraj±cy wszystkie partie danego
    gracza zakoñczeone wybranym wynikiem, klikaj±c na dowolnej warto¶ci
    wy¶wietlanej na <red>czerowono</red>.
  }
  {
    Podczas pracy nad debiutem warto u¿yæ funkcji
    <a Searches Board>wyszukiwania pozycji</a> z opcj± <b>Pionki</b> lub
    <b>Kolumny</b>. Pozowli to znale¼æ inne warianty debiutowe z t±
    sam± struktur± pionow±.
  }
  {
    W polu informacji o partii (pod szachownic±) mo¿na u¿yæ prawego
    przycisku myszy, by wy¶wietliæ menu konfiguracji pola. Mo¿na
    np. ukryæ nastêpne posuniêcie, co jest przydatne przy rozwi±zywaniu
    zadañ.
  }
  {
    Je¶li czêsto u¿ywasz funkcji <a Maintenance>obs³ugi</a> na du¿ej
    bazie, mo¿esz u¿yæ okna <a Maintenance Cleaner>Zestaw zadañ</a>
    do wykonania kilka funkcji naraz.
  }
  {
    Je¶li masz du¿± bazê, w której wiêkszo¶æ partii ma ustawiony
    znacznik EventDate, mo¿esz <a Sorting>posortowaæ</a> j±
    wg tego znacznika (zamiast Daty). Dziêki temu wszystkie partie
    z jednego turnieju znajd± siê ko³o siebie.
  }
  {
    Przed u¿yciem funkcji <a Maintenance Twins>usuwania podwójnych partii</a>
    dobrze jest <a Maintenance Spellcheck>sprawdziæ pisowniê</a>
    nazwisk w bazie, co usprawni wyszukiwanie powtórzeñ.
  }
  {
    <a Flags>Flagi</a> s± przydatne do oznaczania partii, które
    zawieraj± wa¿ne motywy taktyczne, strkutury pionowe, nowinki itd.
    Potem mo¿esz znale¼æ takie partie
    <a Searches Header>wyszukiwaniem wg nag³ówka</a>.
  }
  {
    Je¶li przegl±dasz partiê i chcesz sprawdziæ jaki¶ wariant nie
    zmieniaj±c partii, mo¿esz w³±czyæ tryb testowania wariantu
    (klawisz <b>Ctrl+spacja</b> lub ikona na pasku narzêdziowym).
    Po wy³±czeniu trybu testowania powrócisz do pozycji z partii.
  }
  {
    ¯eby znale¼æ najwa¿niejsze partie (z najsilniejszymi przeciwnikami),
    w których powsta³a aktualna pozycja, otwórz <a Tree>Drzewo wariantów</a>
    i wybierz listê najlepszych partii. Mo¿esz nawet wybraæ tylko
    partie zakoñczone konkretnym wynikiem.
  }
  {
    Dobr± metod± na naukê debiutu przy u¿yciu du¿ej bazy jest
    w³±czenie trybu treningu w <a Tree>Drzewie wariantów</a>
    i gra z programem. Pozwala to sprawdziæ, które posuniêcia s±
    grane najczê¶ciej.
  }
  {
    Je¶li masz otwarte dwie bazy i chcesz obejrzeæ
    <a Tree>Drzewo wariantów</a> dla pierwszej bazy, przegl±daj±c
    partiê z drugiej, kliknij przycisk <b>Blokada</b> na drzewie,
    by zablokowaæ je na pierwszej bazie, a nastêpnie prze³±cz siê
    do drugiej bazy.
  }
  {
    Okno <a Tmt>Turnieje</a> jest przydatne nie tylko do znajdowania
    turniejów, ale pozwala tak¿e sprawdziæ, w jakich turniejach gra³
    ostatnio dany zawodnik i jakie turnieje s± rozgrywane w wybranym
    kraju.
  }
  {
    Mo¿esz u¿yæ jednego z wielu typowych wzorców w oknie
    <a Searches Material>Wyszukiwania wg materia³u</a> do znalezienia
    partii do studiowania debiutów lub gry ¶rodkowej.
  }
  {
    W oknie <a Searches Material>Wyszukiwanie wg materia³u</a>, mo¿esz
    ograniczyæ liczbê znajdowanych partii przez warunek, by
    podany stosunek materia³u utrzymywa³ siê przynajmniej przez
    kilka pó³ruchów.
  }
  {
    Je¶li masz wa¿n± bazê, której nie chcesz przez przypadek zmieniæ,
    w³±cz <b>Tylko do odczytu...</b> w menu <b>Plik</b> po jej otwarciu
    (albo zmieñ prawa dostêpu do pliku).
  }
  {
    Je¶li u¿ywasz XBoard-a lub WinBoard-a (albo programu szachowego,
    który pozwala na skopiowania pozycji w notacji FEN do schowka)
    i chcesz skopiowaæ aktualn± pozycjê do Scid-a, wybierz
    <b>Copy position</b> w menu File programu XBoard/Winboard, a potem
    <b>Wklej aktywn± partiê ze schowka</b> z menu Edycja Scid-a.
  }
  {
    W oknie <a Searches Header>Wyszukiwanie wg nag³ówka</a>,
    szukane nazwy graczy/turnieju/miejsca/rundy s± znajdowane niezale¿nie
    od wielko¶ci liter i równie¿ wewn±trz nazw.
    Zamiast tego mo¿esz u¿yæ poszukiwania z symbolami wieloznacznymi
    (gdzie "?" oznacza dowolny znak, za¶ "*" - 0 lub wiêcej znaków),
    wpisuj±c szukany tekst w cudzys³owie. Wielko¶æ liter zostanie
    uwzglêdniona. Na przyk³ad "*BEL" znajdzie wszystkie turnieje grane
    w Belgii (ale nie w Belgradzie).
  }
  {
    Je¶li chcesz poprawiæ posuniêcie nie zmieniaj±c nastêpnych,
    otwórz okno <a Import>Pobierz partiê</a>, wci¶nij
    <b>Wklej aktualn± partiê</b>, zmieñ b³êdne posuniêcie i wci¶nij
    <b>Pobierz</b>.
  }
  {
    Je¶li plik klasyfikacji debiutowej ECO jest wczytany, mo¿esz przej¶æ
    do ostatniej sklasyfikowanej pozycji w partii za pomoc± polecenia
    <b>Rozpoznaj debiut</b> w menu <b>Partia</b> (klawisz Ctrl+Shift+D).
  }
  {
    Je¶li chcesz sprawdziæ wielko¶æ lub datê modyfikacji pliku
    przed jego otwarciem, u¿yj okna <a Finder>Poszukiwacza plików</a>.
  }
  {
    Plik<a Repertoire>repertuaru debiutowego</a> pozwala na ¶ledzenie
    partii w ulubionych wariantach. Kiedy dodasz grane przez siebie
    debiuty do pliku repertuaru debiutowego, bêdziesz móg³ ³atwo
    znajdowaæ je w nowych partiach.
  }
  {
    <a OpReport>Raport debiutowy</a> pozwala dowiedzieæ siê wiêcej
    o konkretnej pozycji. Mo¿esz zobaczyæ wyniki, nazwiska najczê¶ciej
    graj±cych j± zawodników, typowe motywy pozycyjne itd.
  }
  {
    Mo¿esz dodaæ wiêkszo¶æ typowych symboli (!, !?, += itd.) do
    aktualnego posuniêcia lub pozycji za pomoc± skrótów klawiszowych,
    bez potrzeby otwierania okna <a Comment>Edytora komentarzy</a>
    -- np. wci¶niêcie "!" i Enter spowoduje dodanie symbolu "!".
    Na stronie <a Moves>Wprowadzanie posuniêæ</a> mo¿na znale¼æ
    wiêcej informacji.
  }
  {
    Mo¿esz ³atwo przegl±daæ debiuty w bazie w oknie
    <a Tree>Drzewo wariantów</a>. W oknie Statystyka (klawisz Ctrl+I)
    mo¿na znale¼æ informacje o ostatnich wynikach w wariancie oraz
    o partiach granych przez silnych graczy.
  }
  {
    Mo¿esz zmieniæ wielko¶æ szachownicy, naciskaj±c <b>lewo</b> lub <b>prawo</b>
    przy wci¶niêtych klawiszach <b>Ctrl</b> i <b>Shift</b>.
  }
  {
    Po <a Searches>wyszukiwaniu</a> mo¿esz ³atwo przegl±daæ wszystkie
    znalezione partie, naciskaj±c klawisz <b>góra</b> lub <b>dó³</b>
    przy wci¶niêtym <b>Ctrl</b> by obejrzeæ poprzedni±/nastêpn± partiê
    w filtrze.
  }
}

# end of polish.tcl
