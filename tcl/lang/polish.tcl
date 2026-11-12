
### Polskie menu i komunikaty dla ScidCommunity.

# Contributed by Michal Rudolf and Adam Umiastowski.(Scid)
# Aktualizacja ScidCommunity v5.1.4.62  by Szustan 

# addLanguage P Polish 0 utf-8
# Tekst nazw menu i komunikatów pomocy na pasku stanu w języku polskim.
# Część programu Scid (Shane's Chess Information Database).
# Instrukcje dotyczące dodawania nowego języka:
# (1) Wybierz kod literowy dla języka. Obecnie przypisane kody to:
#      E=angielski, D=niemiecki, F=francuski, S=hiszpański, B=portugalski brazylijski,
#      P=polski, N=holenderski, W=szwedzki, O=norweski, C=czeski, H=węgierski,
#      Y=serbski.
# (2) Edytuj poniższy kod zawierający wiersze „addLanguage ...” i dodaj swój
#     nowy język. Ostatnia cyfra w każdym wierszu to indeks
#     litery, którą należy podkreślić w menu, licząc od 0 jako pierwszej litery.
#
# (3) Skopiuj poniższą sekcję zawierającą szczegóły angielskiego menu i komunikatów pomocy (wszystkie
#     polecenia zaczynające się od „menuText E ...”, „helpMsg E ...” lub
#     „translate E ...”) i zamień wszystkie litery „E” na literę, którą
#     przypisałeś nowemu językowi.
#
# (4) Napisz tłumaczenia. Wymaga to zmiany wszystkiego, co znajduje się „w cudzysłowie”
#     lub {w nawiasach klamrowych} w poleceniach menuText, helpMsg i translate.
#     Polecenie menu ma format:
#         menuText L tag „Nazwa...” podkreślenie {Komunikat pomocy...}
#
#     Komunikat pomocy na pasku stanu dla przycisku ma format:
#         helpMsg L tag {Komunikat pomocy...}
#
#     Ogólne tłumaczenie słowa lub komunikatu ma format:
#         translate L tag {komunikat...}
#     gdzie „L” to litera języka, „tag” to nazwa pozycji menu
#     lub nazwa widżetu przycisku, a „podkreślenie” to indeks litery,
#     którą należy podkreślić, licząc od zera jako pierwszej litery. Dwie pozycje menu
#     pojawiające się w tym samym menu powinny mieć różne litery z podkreśleniem.
#     W razie wątpliwości wystarczy ustawić je wszystkie na „0”, a ja przypiszę sensowne litery z podkreśleniem,
#     gdy wasze tłumaczenia zostaną włączone do Scid.
#
# Uzupełnienia, poprawki? E-mail: sgh@users.sourceforge.net

proc setLanguage_P {} {

# File menu:
menuText P File "Plik" 0
menuText P FileNew "Nowy..." 0 {Utwórz nową bazę danych Scid}
menuText P FileOpen "Otwórz..." 0 {Otwórz istniejącą bazę danych Scid}
menuText P FileClose "Zamknij" 0 {Zamknij aktywną bazę danych Scid}
menuText P FileFinder "Wyszukiwarka plików" 0 {Otwórz okno wyszukiwania plików}
menuText P FileBookmarks "Zakładki" 0 {Menu zakładek}
menuText P FileBookmarksAdd "Dodaj zakładkę" 0 \
  {Dodaj zakładkę do bieżącej partii i pozycji w bazie danych}
menuText P FileBookmarksFile "Zapisz zakładkę" 0 \
  {Zapisz zakładkę do bieżącej partii i pozycji}
menuText P FileBookmarksEdit "Edytuj zakładki..." 0 \
  {Edytuj menu zakładek}
menuText P FileBookmarksList "Wyświetl katalogi jako jedną listę" 0 \
  {Wyświetl katalogi zakładek jako jedną listę, a nie podmenu}
menuText P FileBookmarksSub "Wyświetl katalogi jako podmenu" 0 \
  {Wyświetl katalogi zakładek jako podmenu, a nie jedną listę}
menuText P FileMaint "Narzędzia bazy danych" 0 {Narzędzia bazy danych Scid}
menuText P FileMaintWin "Okno narzędzi bazy danych" 0 \
  {Otwórz lub zamknij okno narzędzi bazy danych Scid}
menuText P FileMaintCompact "Kompaktuj bazę danych..." 0 \
  {Kompaktuj pliki bazy danych, usuwając oznaczone do usunięcia partie i nieużywane nazwy}
menuText P FileMaintClass "Przypisz kody ECO..." 2 \
  {Ponownie oblicz kody ECO wszystkich partii}
menuText P FileMaintSort "Sortuj bazę danych..." 0 \
  {Sortuj wszystkie partie w bazie danych}
menuText P FileMaintDelete "Usuń duplikaty partii..." 0 \
  {Znajdź identyczne partie i oznacz je do usunięcia}
menuText P FileMaintTwin "Okno wyszukiwania duplikatów" 0 \
  {Otwórz/zaktualizuj okno wyszukiwania duplikatów}
menuText P FileMaintName "Pisownia nazw" 0 {Narzędzia do edycji i sprawdzania pisowni nazw}
menuText P FileMaintNameEditor "Edytor nazw" 0 \
  {Otwórz lub zamknij okno edytora nazw}
menuText P FileMaintNamePlayer "Sprawdź pisownię nazwisk graczy..." 11 \
  {Sprawdź pisownię nazwisk graczy za pomocą pliku pliku sprawdzania pisowni}
menuText P FileMaintNameEvent "Sprawdź pisownię nazw turniejów..." 11 \
  {Sprawdź pisownię nazw turniejów za pomocą pliku pliku sprawdzania pisowni}
menuText P FileMaintNameSite "Sprawdź pisownię nazw miejsc..." 11 \
  {Sprawdź pisownię nazw miejsc za pomocą pliku pliku sprawdzania pisowni}
menuText P FileMaintNameRound "Sprawdź pisownię nazw rund..." 11 \
  {Sprawdź pisownię nazw rund za pomocą pliku pliku sprawdzania pisowni}
menuText P FileReadOnly "Tylko do odczytu..." 0 \
  {Ustaw bieżącą bazę danych jako tylko do odczytu, aby zapobiec wprowadzaniu zmian}
menuText P FileSwitch "Przełącz bazę danych" 0 \
  {Przełącz na inną otwartą bazę danych}
menuText P FileOpenLichessTournament "Otwórz turniej Lichess" 0 {Pobierz i otwórz partie z transmisji na żywo turnieju Lichess}
menuText P FileImportLichess "Importuj moje partie z Lichess" 0 {Importuj partie ze swojego konta Lichess}
menuText P FileImportChessCom "Importuj moje partie z chess.com" 0 {Importuj partie ze swojego konta chess.com}
menuText P FileExit "Zakończ" 1 {Zamknij Scid}
menuText P FileMaintFixBase "Napraw bazę danych" 0 {Spróbuj naprawić uszkodzoną bazę danych}

# Edit menu:
menuText P Edit "Edycja" 0
menuText P EditAdd "Dodaj wariant" 0 {Dodaj wariant w tym miejscu partii}
menuText P EditDelete "Usuń wariant" 0 {Usuń wariant dla tego posunięcia}
menuText P EditFirst "Ustaw wariant jako pierwszy" 5 \
  {Przenieś wariant na pierwsze miejsce na liście}
menuText P EditMain "Ustaw wariant jako główną linię" 21 \
  {Ustaw wariant jako główną linię}
menuText P EditTrial "Wypróbuj wariant" 0 \
  {Włącz lub wyłącz tryb próbny, aby sprawdzić pomysł na szachownicy}
menuText P EditStrip "Usuń" 3 {Usuń komentarze lub warianty z tej partii}
menuText P EditUndo "Cofnij" 0 {Cofnij ostatnią zmianę w partii}
menuText P EditRedo "Ponów" 0 {Ponów ostatnią zmianę w partii}
menuText P EditStripComments "Komentarze" 0 \
  {Usuń wszystkie komentarze i adnotacje z tej partii}
menuText P EditStripCommentsNotAnnos "Komentarze, bez adnotacji NAG" 14 \
  {Usuń komentarze, zachowując adnotacje (NAG) w tej partii}
menuText P EditStripVars "Warianty" 0 {Usuń wszystkie warianty z tej partii}
menuText P EditStripAll "Komentarze i warianty" 0 \
  {Usuń wszystkie komentarze, adnotacje i warianty z tej partii}
menuText P EditStripBegin "Posunięcia od początku" 1 \
  {Usuń posunięcia od początku partii}
menuText P EditStripEnd "Posunięcia do końca" 0 \
  {Usuń posunięcia do końca partii}
menuText P EditReset "Usuń wszystkie partie ze schowka" 0 \
  {Całkowicie wyczyść schowek}
menuText P EditCopy "Kopiuj partię do schowka" 0 \
  {Skopiuj tę partię do bazy danych schowka}
menuText P EditPaste "Wklej partię ze schowka" 0 \
  {Wklej tutaj aktywną partię ze schowka}
menuText P EditPastePGN "Wklej tekst ze schowka jako partię PGN..." 18 \
  {Odczytaj tekst ze schowka jako partię w formacie PGN i wklej ją tutaj}
menuText P EditNullMove "Posunięcie zerowe" 0 {Wstaw posunięcie zerowe (pomiń posunięcie) }
menuText P EditSetup "Ustaw pozycję..." 0 \
  {Ustaw pozycję początkową tej partii}
menuText P EditCopyBoard "Kopiuj pozycję jako FEN" 6 \
  {Skopiuj bieżącą pozycję w formacie FEN do zaznaczenia tekstu (schowka)}
menuText P EditPasteBoard "Wklej pozycję jako FEN" 12 \
  {Ustaw pozycję początkową na podstawie zaznaczonego tekstu (schowka)}
menuText P ConfigureScid "Preferencje..." 0 {Skonfiguruj wszystkie opcje SCID}

# Game menu:
menuText P Game "Partia" 0
menuText P GameNew "Nowa partia" 0 {Rozpocznij pustą partię}
menuText P GameFirst "Wczytaj pierwszą partię" 5 {Wczytaj pierwszą partię z przefiltrowanej listy}
menuText P GamePrev "Wczytaj poprzednią partię" 5 {Wczytaj poprzednią partię z przefiltrowanej listy}
menuText P GameReload "Wczytaj partię ponownie" 3 \
  {Wczytaj ponownie tę partię, odrzucając wszystkie wprowadzone zmiany}
menuText P GameNext "Wczytaj następną partię" 7 {Wczytaj następną partię z przefiltrowanej listy}
menuText P GameLast "Wczytaj ostatnią partię" 8 {Wczytaj ostatnią partię z przefiltrowanej listy}
menuText P GameRandom "Wczytaj losową partię" 8 {Wczytaj losową partię z przefiltrowanej listy}
menuText P GameNumber "Wczytaj partię nr..." 5 \
  {Wczytaj partię, podając jej numer}
menuText P GameReplace "Zapisz: zastąp partię..." 6 \
  {Zapisz tę partię, zastępując jej poprzednią wersję}
menuText P GameAdd "Zapisz: dodaj nową partię..." 6 \
  {Zapisz tę partię jako nową w bazie danych}
menuText P GameDelete "Usuń partię" 0 {Zmień znacznik usunięcia bieżącej partii}
menuText P GameDeepest "Rozpoznaj debiut" 0 \
  {Przejdź do najdalszej pozycji partii wymienionej w podręczniku ECO}
menuText P GameGotoMove "Przejdź do posunięcia nr..." 5 \
  {Przejdź do wskazanego numeru posunięcia w bieżącej partii}
menuText P GameNovelty "Znajdź nowinkę..." 7 \
  {Znajdź pierwsze posunięcie tej partii, które nie było wcześniej grane}
menuText P PlayTournament "Rozegraj turniej silników..." 0 \
    {Rozegraj turniej silników}

# Search Menu:
menuText P Search "Szukaj" 0
menuText P SearchReset "Wyczyść filtr" 0 {Wyczyść filtr, aby uwzględnić wszystkie partie}
menuText P SearchNegate "Odwróć filtr" 0 {Odwróć filtr, aby uwzględnić tylko wykluczone partie}
menuText P SearchCurrent "Bieżąca pozycja..." 0 {Wyszukaj bieżącą pozycję na szachownicy}
menuText P SearchHeader "Nagłówek..." 0 {Wyszukaj według informacji z nagłówka partii (gracz, turniej itp.)}
menuText P SearchMaterial "Materiał/wzorce..." 0 {Wyszukaj według materiału lub układu figur na szachownicy}
menuText P SearchComments "Szukaj w komentarzach..." 0 {Przeszukaj komentarze w partiach bieżącego filtra}
menuText P SearchUsing "Użyj pliku wyszukiwania..." 0 {Wyszukaj według ustawień z pliku SearchOptions}

# Windows menu:
menuText P Windows "Okna" 0
menuText P WindowsComment "Edytor komentarzy" 0 {Otwórz lub zamknij edytor komentarzy}
menuText P WindowsGList "Lista partii" 0 {Otwórz lub zamknij okno listy partii}
menuText P WindowsPGN "Okno PGN" 0 \
  {Otwórz lub zamknij okno PGN (zapis partii)}
menuText P WindowsPList "Wyszukiwarka graczy" 2 {Otwórz lub zamknij wyszukiwarkę graczy}
menuText P WindowsTmt "Wyszukiwarka turniejów" 2 {Otwórz lub zamknij wyszukiwarkę turniejów}
menuText P WindowsSwitcher "Przełącznik baz danych" 0 \
  {Otwórz lub zamknij okno przełączania baz danych}
menuText P WindowsMaint "Okno narzędzi bazy danych" 0 \
  {Otwórz lub zamknij okno narzędzi bazy danych}
menuText P WindowsECO "Przeglądarka ECO" 0 {Otwórz lub zamknij okno przeglądarki ECO}
menuText P WindowsStats "Okno statystyk" 0 \
  {Otwórz lub zamknij okno statystyk filtra}
menuText P WindowsTree "Okno drzewa wariantów" 0 {Otwórz lub zamknij okno drzewa wariantów}
menuText P WindowsBook "Okno książki debiutowej" 0 {Otwórz lub zamknij okno książki}
menuText P WindowsCorrChess "Okno gry korespondencyjnej" 0 {Otwórz lub zamknij okno szachów korespondencyjnych}
menuText P WindowsGraph "Wykres analizy" 0 {Otwórz okno wykresu z czasami posunięć i ocenami}
menuText P WindowsPresentationBoard "Szachownica prezentacyjna" 0 {Otwórz lub zamknij osobne okno z szachownicą, która odzwierciedla główną szachownicę; przeznaczone do wyświetlania na projektorze lub drugim ekranie}
menuText P WindowsPresentationFreeze "Zatrzymaj/wznów szachownicę prezentacyjną" 0 {Zatrzymaj lub wznów aktualizowanie szachownicy prezentacyjnej, aby można było przeglądać partię bez pokazywania tego publiczności}
translate P PresentationFrozen {Prezentacja wstrzymana — plansza nie jest aktualizowana}

menuText P WindowsEPD "Okno EPD..." 0 {Otwórz okno edytora plików EPD (plików pozycji)}

# EPD window:
translate P EpdPasteAnal {Wklej analizę}
translate P EpdSortOpcodes {Sortuj kody operacyjne}
translate P EpdAddPosition {Dodaj pozycję}
translate P EpdFindPos {Znajdź pozycję w partii}
translate P EpdAnalPosition {Analizuj pozycje...}
translate P EpdStripOpcodes {Usuń kody operacyjne...}
translate P EpdAnnotateTime {Sekund na pozycję}
translate P EpdCountBestMoves {Zlicz najlepsze posunięcia}
translate P EpdSaveLog {Zapisz wyniki do pliku}
# EPD headless analysis: status text and the reasons the session reports.
# The EpdEngine* strings are fragments shown after the "%s" above them.
translate P EpdAnalysisTitle {Analiza EPD}
translate P EpdAnalysisRunning {Inna analiza EPD jest już uruchomiona.}
translate P EpdAnalysisMinTime {Czas analizy musi wynosić co najmniej 1 sekundę.}
translate P EpdAnalysisStartFailed {Nie udało się uruchomić silnika analizy: %s}
translate P EpdAnalysisError {Błąd analizy EPD: %s}
translate P EpdAnalysisStopped {Analiza zatrzymana.}
translate P EpdAnalysisStopping {Zatrzymywanie...}
translate P EpdEngineNotStarted {silnik nie rozpoczął wyszukiwania}
translate P EpdEngineNoResult {silnik nie zwrócił wyniku}
translate P EpdSearchAlreadyRunning {wyszukiwanie jest już uruchomione}
translate P EpdNoEngineConfigured {nie skonfigurowano żadnego silnika}
translate P EpdOnlyUci {Obsługiwane są tylko silniki UCI}
translate P EpdEngineDisconnected {silnik został rozłączony}
translate P EpdEngineNoAnswer {silnik nie odpowiedział}
translate P EpdDontSave {Nie zapisuj}
translate P EpdReadOnly {tylko do odczytu}
translate P EpdAltered {zmieniony}
translate P EpdNoMoves {brak posunięć}
translate P positions {pozycje}
translate P EpdDeleteRow {Usuń rekord}
translate P EpdCloseWarning {Ten plik EPD został zmieniony.\nCzy chcesz go zapisać?}
translate P EpdDeletePosition {Usuń pozycję}
translate P EpdCopyRecord {Kopiuj rekord}
translate P EpdPasteRecord {Wklej rekord}

# Tools menu:
menuText P Tools "Narzędzia" 0
menuText P ToolsConfigureEngines "Konfiguruj silniki" 10 {Zarządzaj konfiguracją silników}
menuText P ToolsEngineWindow "Okno silnika..." 0 {Otwórz okno silnika szachowego}
menuText P ToolsCross "Tabela turniejowa" 0 {Pokaż tabelę turniejową dla tej partii}
menuText P ToolsFilterGraph "Wykres filtra (wzgl.)" 12 {Otwórz lub zamknij okno wykresu względnych wartości filtra}
menuText P ToolsAbsFilterGraph "Wykres filtra (bezwzgl.)" 7 {Otwórz lub zamknij okno wykresu bezwzględnych wartości filtra}
menuText P ToolsOpReport "Raport debiutowy" 0 {Utwórz raport debiutowy dla bieżącej pozycji}
menuText P ToolsOpenBaseAsTree "Otwórz bazę jako drzewo wariantów..." 0   {Otwórz bazę i użyj jej w oknie drzewa wariantów}
menuText P ToolsOpenRecentBaseAsTree "Otwórz ostatnią bazę jako drzewo wariantów" 0   {Otwórz ostatnio używaną bazę i użyj jej w oknie drzewa wariantów}
menuText P ToolsTracker "Śledzenie figur"  6 {Otwórz okno śledzenia figur}
menuText P ToolsTraining "Trening"  0 {Narzędzia treningowe (taktyka, debiuty...)}
menuText P ToolsPlayVsEngine "Gra z silnikiem"  0 {Rozegraj partię z silnikiem szachowym}
menuText P ToolsTrainOpenings "Debiuty"  0 {Trenuj z repertuarem debiutowym}
menuText P ToolsTrainTactics "Taktyka"  0 {Rozwiązuj zadania taktyczne}
menuText P ToolsTrainFindBestMove "Znajdź najlepsze posunięcie"  0 {Znajdź najlepsze posunięcie}
menuText P ToolsTrainFics "Graj na FICS"  0 {Graj na freechess.org}
menuText P ToolsEngineTournament "Turniej silników"  0 {Rozpocznij turniej między silnikami szachowymi}
menuText P ToolsTimeAnalysis "Analiza czasu" 0 {Pokaż wykres czasu na zegarze dla bieżącej partii}
menuText P ToolsBookTuning "Dostrajanie książki debiutowej" 0 {Dostrajanie książki debiutowej}
menuText P ToolsRapidAnnotate "Adnotacje z wykresu analizy silnika" 0 {Zapisz oceny i adnotacje z wykresu analizy silnika w bieżącej partii (Ctrl+Shift+A)}
menuText P ToolsDownloadTWIC "Pobierz partie TWIC" 0 {Pobierz najnowsze partie z The Week In Chess (TWIC)}
menuText P ToolsConnectHardware "Podłącz urządzenie" 8 {Podłącz urządzenie zewnętrzne}
menuText P ToolsConnectHardwareConfigure "Konfiguruj..." 0 {Skonfiguruj urządzenie zewnętrzne i połączenie}
menuText P ToolsConnectHardwareNovagCitrineConnect "Połącz z Novag Citrine" 8 {Połącz Novag Citrine z programem Scid}
menuText P ToolsConnectHardwareInputEngineConnect "Podłącz urządzenie wejściowe" 8 {Połącz urządzenie wejściowe (np. szachownicę DGT) z programem Scid}

menuText P ToolsPInfo "Informacje o graczu"  0 \
  {Otwórz lub odśwież okno informacji o graczu}
menuText P ToolsPlayerReport "Raport o graczu..." 3 \
  {Utwórz raport o graczu}
menuText P ToolsRating "Wykres rankingu" 0 \
  {Pokaż historię rankingów graczy z bieżącej partii}
menuText P ToolsExpCurrent "Eksportuj bieżącą partię" 8 \
  {Zapisz bieżącą partię w pliku tekstowym}
menuText P ToolsExpCurrentPGN "Eksportuj partię do pliku PGN..." 15 \
  {Zapisz bieżącą partię w pliku PGN}
menuText P ToolsExpCurrentHTML "Eksportuj partię do pliku HTML..." 15 \
  {Zapisz bieżącą partię w pliku HTML}
menuText P ToolsExpCurrentHTMLJS "Eksportuj partię do pliku HTML i JavaScript..." 15 {Zapisz bieżącą partię w pliku HTML i JavaScript}
menuText P ToolsExpCurrentRTF "Eksportuj partię do pliku RTF..." 15 \
  {Zapisz bieżącą partię w pliku RTF, zachowując formatowanie komentarzy}
menuText P ToolsExpFilter "Eksportuj wszystkie partie z filtra" 1 \
  {Zapisz wszystkie partie z filtra w pliku tekstowym}
menuText P ToolsExpFilterPGN "Eksportuj filtr do pliku PGN..." 17 \
  {Zapisz wszystkie partie z filtra w pliku PGN}
menuText P ToolsExpFilterHTML "Eksportuj filtr do pliku HTML..." 17 \
  {Zapisz wszystkie partie z filtra w pliku HTML}
menuText P ToolsExpFilterHTMLJS "Eksportuj filtr do pliku HTML i JavaScript..." 17 {Zapisz wszystkie partie z filtra w pliku HTML i JavaScript}
menuText P ToolsExpFilterRTF "Eksportuj filtr do pliku RTF..." 17 \
  {Zapisz wszystkie partie z filtra w pliku RTF, zachowując formatowanie komentarzy}
menuText P ToolsImportOne "Importuj partię PGN..." 0 \
  {Importuj partię z tekstu w formacie PGN}
menuText P ToolsImportFile "Importuj partie z pliku PGN..." 7 {Importuj partie z pliku lub plików PGN}
menuText P FileImportRTF "Importuj partię RTF..." 0 \
  {Importuj partię z pliku RTF utworzonego przez scidCommunity}
menuText P ToolsStartEngine1 "Uruchom silnik 1" 13  {Uruchom silnik 1}
menuText P ToolsStartEngine2 "Uruchom silnik 2" 13  {Uruchom silnik 2}
menuText P ToolsCaptureBoard "Zapisz aktualną pozycję jako obraz..." 5  {Zapisz bieżącą szachownicę jako obraz.}

# Play menu
menuText P Play "Graj" 0
menuText P LichessPuzzles "Zadania Lichess" 0 {Rozwiązuj interaktywnie zadania taktyczne z Lichess}

# --- Correspondence Chess
menuText P CCResign "Poddaj partię" 1 {Poddaj partię (nie przez e-mail)}
menuText P CCClaimDraw "Zaproponuj remis" 6 {Wyślij posunięcie i zgłoś remis (nie przez e-mail)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText P Options "Opcje" 0
menuText P OptionsBoardGraphics "Pola szachownicy..." 0 {Wybierz tekstury pól szachownicy}
translate P OptionsBGW {Wybierz teksturę pól szachownicy}
translate P OptionsBoardGraphicsText {Wybierz pliki graficzne dla białych i czarnych pól:}
menuText P OptionsBoardNames "Moje nazwiska graczy..." 0 {Edytuj własne nazwiska graczy}
menuText P OptionsExport "Eksport" 0 {Zmień opcje eksportu tekstu}
menuText P OptionsFonts "Czcionki" 0 {Zmień czcionki}
menuText P OptionsFontsRegular "Zwykła" 0 {Zmień zwykłą czcionkę}
menuText P OptionsFontsMenu "Menu" 0 {Zmień czcionkę menu}
menuText P OptionsFontsSmall "Mała" 0 {Zmień małą czcionkę}
menuText P OptionsFontsTiny "Bardzo mała" 0 {Zmień bardzo małą czcionkę}
menuText P OptionsFontsFixed "Stałej szerokości" 0 {Zmień czcionkę o stałej szerokości}
menuText P OptionsGInfo "Informacje o partii" 0 {Opcje informacji o partii}
menuText P OptionsLanguage "Język" 0 {Wybierz język menu}
menuText P OptionsMovesTranslatePieces "Tłumacz nazwy figur" 0 {Tłumacz pierwsze litery nazw figur}
menuText P OptionsMovesHighlightLastMove "Podświetl ostatnie posunięcie" 0 {Podświetl ostatnie posunięcie}
menuText P OptionsMovesHighlightLastMoveDisplay "Pokaż pole" 0 {Wyświetl podświetlenie ostatniego posunięcia}
menuText P OptionsMovesHighlightLastMoveWidth "Szerokość" 0 {Grubość linii}
menuText P OptionsMovesHighlightLastMoveColor "Kolor" 0 {Kolor linii}
menuText P OptionsMovesHighlightLastMoveArrow "Pokaż strzałkę" 0 {Pokaż strzałkę wraz z podświetleniem}
menuText P OptionsMovesHighlightLastMoveNag "Pokaż symbole adnotacji" 0
menuText P OptionsMovesHighlightLastMoveEval "Pokaż symbole oceny" 0
menuText P OptionsMoves "Posunięcia" 0 {Opcje wprowadzania posunięć}
menuText P OptionsGamelist "Lista partii" 0 {Opcje listy partii}
menuText P OptionsMovesAnimate "Czas animacji" 1 \
  {Ustaw czas wyświetlania animacji posunięć}
menuText P OptionsMovesDelay "Opóźnienie automatycznego odtwarzania..." 1 \
  {Ustaw opóźnienie w trybie automatycznego odtwarzania}
menuText P OptionsMovesCoord "Wprowadzanie posunięć współrzędnymi" 0 \
  {Akceptuj posunięcia zapisywane współrzędnymi (np. "g1f3")}
menuText P OptionsMovesSuggest "Pokaż sugerowane posunięcia" 0 \
   {Włącz lub wyłącz podświetlanie pól po najechaniu kursorem na figurę}
menuText P OptionsShowVarPopup "Pokaż okno wariantów" 0 {Włącz lub wyłącz wyświetlanie okna wariantów}
menuText P OptionsRepetitionAlert "Informowanie o powtórzeniach" 0 {Sposób informowania o powtórzeniu pozycji}
menuText P OptionsRepetitionOff "Wyłączone" 0 {Nie informuj o powtórzeniach}
menuText P OptionsRepetitionBanner "Powiadomienie" 0 {Wyświetl nieblokujące powiadomienie, które znika automatycznie}
menuText P OptionsRepetitionDialog "Okno dialogowe" 0 {Wyświetl okno dialogowe, które trzeba zamknąć}
translate P RepetitionTwice {Powtórzenie pozycji po raz drugi}
translate P RepetitionThreefold {Remis — trzykrotne powtórzenie pozycji}
menuText P OptionsMovesSpace "Dodaj spacje po nr posunięcia" 0 {Dodaj odstępy po numerze posunięcia}
menuText P OptionsMovesLichess "Format adnotacji Lichess/ChessBase" 0 {Używaj formatu Lichess/ChessBase dla znaczników pól i strzałek}
menuText P OptionsMovesKey "Uzupełnianie z klawiatury" 0 \
  {Włącz lub wyłącz automatyczne uzupełnianie posunięć z klawiatury}
menuText P OptionsMovesShowVarArrows "Pokaż strzałki wariantów partii" 0 {Włącz lub wyłącz strzałki pokazujące posunięcia w wariantach}
menuText P OptionsMovesShowEngineVariationArrows "Pokaż strzałki wariantów silnika" 0 {Włącz lub wyłącz strzałki pokazujące warianty silnika w trybie MultiPV}
menuText P OptionsMovesGlossOfDanger "Kolorowe oznaczenia zagrożeń" 0 {Włącz lub wyłącz kolorowe oznaczenia zagrożeń}
translate P OptionsGlistWheelRows {Liczba wierszy przewijanych kółkiem myszy}
translate P OptionsMovesTreeDepth {Domyślna liczba półposunięć w oknie drzewa wariantów}
translate P OptionsMovesEnginePvLength {Długość wyświetlanych linii PV silnika}
menuText P OptionsNumbers "Format liczb" 0 {Wybierz format liczb}
menuText P OptionsTheme "Motyw" 0 {Zmień wygląd interfejsu}
menuText P OptionsWindows "Okna" 0 {Opcje okien}
menuText P OptionsSounds "Dźwięki" 2 {Skonfiguruj dźwięki sygnalizujące posunięcia}
menuText P OptionsResources "Zasoby..." 0 {Wybierz pliki i foldery zasobów}
menuText P OptionsWindowsDock "Dokuj okna" 0 {Dokuj okna (wymaga ponownego uruchomienia)}
menuText P OptionsWindowsSaveLayout "Zapisz układ" 0 {Zapisz układ}
menuText P OptionsWindowsRestoreLayout "Przywróć układ" 0 {Przywróć układ}
menuText P OptionsWindowsShowGameInfo "Pokaż informacje o partii" 0 {Pokaż informacje o partii}
menuText P OptionsWindowsAutoLoadLayout "Automatycznie wczytaj pierwszy układ" 0 {Automatycznie wczytaj pierwszy układ przy uruchamianiu}
menuText P OptionsECO "Plik ECO" 7 {Wczytaj plik klasyfikacji ECO}
menuText P OptionsSpell "Plik sprawdzania pisowni" 11 \
  {Wczytaj plik sprawdzania pisowni Scid}
menuText P OptionsTable "Katalog baz końcówek" 10 \
  {Wybierz plik bazy końcówek; zostaną użyte wszystkie bazy z jego katalogu}
menuText P OptionsRecent "Ostatnie pliki" 0 {Zmień liczbę ostatnio używanych plików wyświetlanych w menu Plik}
menuText P OptionsBooksDir "Katalog książek debiutowych" 0 {Ustaw folder książek debiutowych}
menuText P OptionsTacticsBasesDir "Katalog baz" 0 {Ustaw folder baz z zadaniami taktycznymi}
menuText P OptionsPhotosDir "Katalog zdjęć" 0 {Ustaw folder baz ze zdjęciami}
menuText P OptionsThemeDir "Plik motywu"  0 {Wczytaj pakiet motywu interfejsu}
translate P OptionsThemeOmarchy {Dopasuj do motywu Omarchy}
menuText P OptionsSave "Zapisz opcje" 0 "Zapisz wszystkie ustawienia do pliku $::optionsFile"
menuText P OptionsAutoSave "Zapisz opcje przy zamykaniu" 0 \
  {Automatycznie zapisuj wszystkie opcje przy zamykaniu Scid}

# Help menu:
menuText P Help "Pomoc" 0
menuText P HelpContents "Spis treści" 0 {Pokaż stronę ze spisem treści pomocy}
menuText P HelpIndex "Indeks" 0 {Pokaż stronę indeksu pomocy}
menuText P HelpGuide "Skrócony przewodnik" 0 {Pokaż stronę krótkiego przewodnika}
menuText P HelpHints "Wskazówki" 0 {Pokaż stronę ze wskazówkami}
menuText P HelpContact "Dane kontaktowe" 1 {Pokaż stronę z danymi kontaktowymi}
menuText P HelpTip "Porada dnia" 0 {Pokaż przydatną poradę dotyczącą Scid}
menuText P HelpStartup "Okno startowe" 0 {Pokaż okno startowe}
menuText P HelpAbout "O programie" 0 {Informacje o ScidCommunity}
menuText P UpdateCheck "Sprawdź dostępność aktualizacji" 0 {Sprawdź, czy jest dostępna nowa wersja scidCommunity}
translate P UpdateChecking "Sprawdzanie dostępności aktualizacji..."
translate P UpdateUpToDate "Masz najnowszą wersję scidCommunity (%s)."
translate P UpdateAvailable "Dostępna jest nowa wersja scidCommunity: %s\n\nObecnie używasz wersji %s."
translate P UpdateDownloadInstall "Pobierz i zainstaluj"
translate P UpdateViewRelease "Zobacz informacje o wydaniu"
translate P UpdateNotNow "Nie teraz"
translate P UpdateCheckFailed "Nie udało się sprawdzić dostępności aktualizacji scidCommunity. Sprawdź połączenie z internetem i spróbuj ponownie."
translate P UpdateInstallConfirm "Wersja scidCommunity %s zostanie pobrana i zainstalowana.\n\nPo zakończeniu pobierania program scidCommunity zostanie zamknięty, a następnie uruchomi się instalator."
translate P UpdateDownloading "Pobieranie scidCommunity %s..."
translate P UpdateDownloaded "Pobrano %s"
translate P UpdateDownloadFailed "Nie udało się pobrać aktualizacji. Spróbuj ponownie później."

# Toolbar tooltips:
menuText P RotateBoard "Obróć szachownicę" 0 {Obróć szachownicę}

# Game info box popup menu:
menuText P GInfoHideNext "Ukryj następne posunięcie" 0
menuText P GInfoMaterial "Pokaż wartości materialne" 0
menuText P GInfoFEN "Pokaż FEN" 5
menuText P GInfoMarks "Pokaż kolorowe pola i strzałki" 5
menuText P GInfoWrap "Zawijaj długie wiersze" 0
menuText P GInfoFullComment "Pokaż cały komentarz" 10
menuText P GInfoPhotos "Pokaż zdjęcia" 5
menuText P GInfoTBNothing "Bazy końcówek: nie pokazuj" 12
menuText P GInfoTBResult "Bazy końcówek: tylko wynik" 12
menuText P GInfoTBAll "Bazy końcówek: wynik i najlepsze posunięcia" 19
menuText P GInfoDelete "Oznacz/odznacz partię do usunięcia" 4
menuText P GInfoMark "Oznacz/odznacz partię" 4
menuText P GInfoInformant "Skonfiguruj symbole informatora" 0

# General buttons:
translate P LichessOpenExplore {Otwórz eksplorator debiutów Lichess}
translate P LichessTitle {Eksplorator debiutów Lichess}
translate P LichessApiTokenReq {Token API Lichess (wymagany):}
translate P LichessDatabase {Baza danych:}
translate P LichessMasters {Mistrzowie}
translate P LichessGames {Partie Lichess}
translate P LichessPlayer {Gracz}
translate P LichessNumMoves {Liczba posunięć:}
translate P LichessTopGames {Najlepsze partie:}
translate P LichessRecentGames {Najnowsze partie:}
translate P LichessSinceYear {Od roku:}
translate P LichessUntilYear {Do roku:}
translate P LichessSinceMonth {Od (RRRR-MM):}
translate P LichessUntilMonth {Do (RRRR-MM):}
translate P LichessTimeControls {Tempo gry}
translate P LichessRatingGroups {Grupy rankingowe}
translate P LichessPlayerName {Nazwa użytkownika:}
translate P LichessPlayerColor {Kolor gracza:}
translate P LichessWhite {Białe}
translate P LichessBlack {Czarne}
translate P LichessGameModes {Tryby gry}
translate P LichessRated {Rankingowe}
translate P LichessCasual {Towarzyskie}
translate P LichessTokenRequired {Wymagany jest token API Lichess.\n\nOd marca 2026 r. Lichess wymaga tokenu API, aby korzystać z eksploratora debiutów. Wpisz token w powyższym polu „Token API Lichess”.\n\nMożesz utworzyć token na stronie: https://lichess.org/account/oauth/token}
translate P LichessPlayerRequired {Wpisz nazwę użytkownika Lichess dla bazy danych gracza.}
translate P LichessQuerying {Pobieranie danych z eksploratora debiutów Lichess...}
translate P LichessFailedQuery {Nie udało się pobrać danych z eksploratora debiutów Lichess:\n%s}
translate P LichessPositionNotFound {Nie znaleziono pozycji w bazie danych %s.\n\nOdpowiedź API:\n%s}
translate P LichessResultsTitle {Eksplorator debiutów Lichess — baza danych %s}
translate P LichessSummaryInfo {RAZEM: %s partii  |  Wygrane białych: %s (%s%%)  |  Remisy: %s (%s%%)  |  Wygrane czarnych: %s (%s%%)}
translate P LichessNoGamesFound {Nie znaleziono partii dla tej pozycji.}
translate P LichessMoves {Posunięcia:}
translate P LichessColMove {Posunięcie}
translate P LichessColWhite {Białe}
translate P LichessColDraws {Remisy}
translate P LichessColBlack {Czarne}
translate P LichessColTotal {Razem}
translate P LichessColWinPct {Wygrane %}
translate P LichessColAvgRating {Śr. ranking}
translate P LichessColECO {ECO}
translate P LichessColOpening {Debiut}
translate P LichessTopGamesTitle {Najlepsze partie:}
translate P LichessRecentGamesTitle {Najnowsze partie:}
translate P LichessColWinner {Zwycięzca}
translate P LichessColWhiteRating {Ranking białych}
translate P LichessColBlackRating {Ranking czarnych}
translate P LichessColDate {Data}
translate P LichessLoadGameConfirm {Wczytać partię %s vs %s (ID: %s) do schowka?}
translate P LichessLoadGameTitle {Wczytaj partię}
translate P LichessFetchGameFailed {Nie udało się pobrać partii %s:\n%s}
translate P LichessGameNotFound {Nie znaleziono partii %s na Lichess.}
translate P LichessImportFailed {Nie udało się zaimportować partii:\n%s}
translate P LichessGameLoaded {Partia została pomyślnie wczytana do schowka.}

# Lichess Puzzles
translate P LichessPuzzlesTitle {Zadania Lichess}
translate P LichessPuzzlesDailyTitle {Zadanie dnia}
translate P LichessPuzzlesQuerying {Pobieranie zadań z Lichess...}
translate P LichessPuzzlesFailed {Nie udało się pobrać zadań z Lichess:\n%s}
translate P LichessPuzzlesParseError {Nie udało się odczytać danych zadania}
translate P LichessPuzzlesLoadError {Nie udało się wczytać pozycji zadania}
translate P LichessPuzzlesSolve {Twoja kolej! Znajdź najlepsze posunięcie.}
translate P LichessPuzzlesCorrect {Dobre posunięcie!}
translate P LichessPuzzlesWrong {To nie jest właściwe posunięcie — spróbuj inaczej.}
translate P LichessPuzzlesBestMove {Najlepsze posunięcie! Graj dalej...}
translate P LichessPuzzlesSolved {Zadanie rozwiązane! Gratulacje!}
translate P LichessPuzzlesPlaying {Rozwiązywanie zadania...}
translate P LichessPuzzlesStop {Zatrzymaj}
translate P LichessPuzzlesNew {Nowe zadanie}
translate P LichessPuzzlesHint {Podpowiedź}
translate P LichessPuzzlesViewSolution {Pokaż rozwiązanie}
translate P LichessPuzzlesHintMsg {Przyjrzyj się figurze na polu %s.}
translate P LichessPuzzlesSolutionMsg {Rozwiązanie:\n%s}
translate P LichessPuzzlesDifficulty {Poziom trudności:}
translate P LichessPuzzlesDiffEasiest {Najłatwiejsze}
translate P LichessPuzzlesDiffEasiestThenNormal {Najłatwiejsze, potem normalne}
translate P LichessPuzzlesDiffNormal {Normalne}
translate P LichessPuzzlesDiffNormalThenHardest {Normalne, potem najtrudniejsze}
translate P LichessPuzzlesDiffHardest {Najtrudniejsze}
translate P LichessPuzzlesColor {Graj jako:}
translate P LichessPuzzlesNextColor {Kolor w następnym zadaniu:}
translate P LichessPuzzlesSideToMove {Strona na posunięciu}
translate P LichessPuzzlesSolvedTitle {Zadanie rozwiązane!}
translate P LichessPuzzlesTheme {Motyw:}
translate P LichessPuzzlesMix {Różnorodne}
translate P LichessPuzzlesId {ID zadania}
translate P LichessPuzzlesPlays {Rozgrywki}
translate P LichessPuzzlesThemes {Motywy}
translate P LichessPuzzlesPerf {Rodzaj}
translate P LichessPuzzlesClock {Zegar}
translate P LichessPuzzlesRated {Rankingowe}
translate P LichessPuzzlesGame {Partia}
translate P LichessPuzzlesNoNew {Nie znaleziono nowych zadań dla tych ustawień.\n\nSpróbuj zmienić motyw, poziom trudności lub kolor figur.}

# Lichess study publishing
# Publish database games as chapters of a Lichess study.
# Designed by TBergh98 (https://github.com/TBergh98).
menuText P ToolsPublishLichessStudy "Opublikuj bieżącą partię w opracowaniu Lichess..." 0 \
  {Opublikuj bieżącą partię jako nowy rozdział jednego ze swoich opracowań Lichess}
translate P LichessStudyTitle {Publikowanie w opracowaniu Lichess}
translate P LichessStudyToPublish {Do opublikowania: %s (jeden rozdział na partię)}
translate P LichessStudyToken {Token Lichess:}
translate P LichessStudyCreateToken {Utwórz token (uprawnienia study:read i study:write)}
translate P LichessStudySearch {Szukaj opracowania:}
translate P LichessStudyChapterSettings {Ustawienia rozdziału}
translate P LichessStudyOrientation {Orientacja:}
translate P LichessStudyOrientationAuto {Automatyczna}
translate P LichessStudyAnalysisMode {Tryb analizy:}
translate P LichessStudyModeNormal {Zwykła analiza}
translate P LichessStudyModeConceal {Ukryj następne posunięcia}
translate P LichessStudyModePractice {Trening z komputerem}
translate P LichessStudyModeGamebook {Interaktywna lekcja}
translate P LichessStudyCreateNew {Lub utwórz nowe opracowanie}
translate P LichessStudyName {Nazwa:}
translate P LichessStudyVisibility {Widoczność:}
translate P LichessStudyVisPrivate {Prywatne}
translate P LichessStudyVisUnlisted {Niepubliczne}
translate P LichessStudyVisPublic {Publiczne}
translate P LichessStudyCreateAndPublish {Utwórz i opublikuj}
translate P LichessStudyAddByLink {Opracowanie, do którego chcesz dodać partię (link):}
translate P LichessStudyUnnamed {Opracowanie %s}
translate P LichessStudyAddButton {Dodaj}
translate P LichessStudyReload {Odśwież listę}
translate P LichessStudyPublishButton {Opublikuj}
translate P LichessStudyPublishGames {Opublikuj w opracowaniu Lichess (%s)...}
translate P LichessStudyAddedByLink {dodane za pomocą linku}

translate P LichessStudyNeedToken {Wklej token Lichess i naciśnij „Zapisz”.}
translate P LichessStudyLoading {Wczytywanie opracowań...}
translate P LichessStudyAccountStatus {Konto %s: %s opracowań. Wybierz jedno i naciśnij „Opublikuj”.}
translate P LichessStudyTokenInvalid {Token zawiera nieprawidłowe znaki. Skopiuj go ponownie z Lichess.}
translate P LichessStudySaveTokenFirst {Najpierw zapisz token Lichess.}
translate P LichessStudyChecking {Sprawdzanie opracowania %s...}
translate P LichessStudyPickStudy {Najpierw wybierz opracowanie z listy.}
translate P LichessStudyAddLinkPrompt {Wklej link do opracowania, np. https://lichess.org/study/AbCd1234}
translate P LichessStudyNameLength {Nazwa opracowania musi mieć od 2 do 100 znaków.}
translate P LichessStudyCreating {Tworzenie opracowania „%s”...}
translate P LichessStudyCreateFailed {Nie udało się utworzyć opracowania „%s”: %s\n\nNic nie zostało opublikowane.}
translate P LichessStudyDbClosed {Baza danych nie jest już otwarta.}
translate P LichessStudyTooManyGames {Wybrano %s partii, ale opracowanie Lichess może zawierać maksymalnie %s rozdziałów.}
translate P LichessStudyNoGame {Na szachownicy nie ma partii.\n\nAby opublikować partie z bazy danych, zaznacz je na liście partii i użyj menu podręcznego dostępnego po kliknięciu prawym przyciskiem myszy.}
translate P LichessStudyNoUsername {Nie można odczytać nazwy użytkownika z odpowiedzi Lichess.}
translate P LichessStudyCurlNotFound {Nie znaleziono programu curl, który jest potrzebny do komunikacji z Lichess.}
translate P LichessStudyGameNotFound {Nie znaleziono partii %s w bazie danych.}
translate P LichessStudyCannotRead {Nie można odczytać partii %s: %s}

translate P LichessStudyFull {Opracowanie jest pełne. Opracowanie Lichess może zawierać maksymalnie %s rozdziałów.}
translate P LichessStudyNoAnswer {Brak odpowiedzi z Lichess. Sprawdź połączenie z internetem.}
translate P LichessStudy401 {Nieprawidłowy lub wygasły token (401).}
translate P LichessStudy403 {Brak uprawnień (403). Token nie ma uprawnień study:read/study:write lub nie możesz dodawać treści do tego opracowania.}
translate P LichessStudy404 {Nie znaleziono opracowania (404) lub jest ono prywatne i nie jesteś jego członkiem.}
translate P LichessStudy429 {Zbyt wiele żądań do Lichess (429). Odczekaj minutę i spróbuj ponownie.}
translate P LichessStudyHttpError {Lichess (HTTP %s): %s}
translate P LichessStudyUnexpected {Nieoczekiwana odpowiedź z Lichess (HTTP %s). %s}
translate P LichessStudyNetworkError {Błąd sieci: %s}

translate P LichessStudyOvfFree {Opracowanie „%s” ma tylko %s wolnych rozdziałów z maksymalnie %s, ale chcesz opublikować %s partii.}
translate P LichessStudyOvfFull {Opracowanie „%s” jest pełne. Może zawierać maksymalnie %s rozdziałów.}
translate P LichessStudyOvfQuestion {%s\n\nCo chcesz zrobić?}
translate P LichessStudyOvfFirst {Opublikuj tutaj tylko pierwsze %s partii (pozostałe %s nie zostaną opublikowane)}
translate P LichessStudyOvfSplit {Opublikuj tutaj pierwsze %s partii, a pozostałe %s w nowym opracowaniu}
translate P LichessStudyOvfAllNew {Opublikuj wszystkie %s partii w nowym opracowaniu}
translate P LichessStudyOvfName {Nazwa nowego opracowania:}

translate P LichessStudyCancelled {Publikowanie anulowane. Nic nie zostało opublikowane.}
translate P LichessStudyCheckingFree {Sprawdzanie liczby wolnych rozdziałów w opracowaniu „%s”...}
translate P LichessStudyPublishing {Publikowanie %s partii w opracowaniu „%s”...}
translate P LichessStudyGamesNotPublished {Nie opublikowano partii z powodu braku wolnych rozdziałów w opracowaniu: %s.}
translate P LichessStudyEmptyNew {Utworzono nowe opracowanie „%s”, ale nie dodano do niego żadnej partii (%s).}
translate P LichessStudyNothingPublished {Nic nie zostało opublikowane.%s}
translate P LichessStudyReport {Utworzono %s z %s rozdziałów (%s).%s\n\nCzy otworzyć opracowanie w przeglądarce?}
translate P LichessStudyReportItem {%s w opracowaniu „%s”}
translate P LichessStudyNoChapters {Nie utworzono żadnego rozdziału.%s}
translate P LichessStudyReports {Raporty Lichess: %s}

translate P About {O programie}
translate P Back {Wstecz}
translate P Apply {Zastosuj}
translate P Browse {Przeglądaj}
translate P Cancel {Anuluj}
translate P Continue {Kontynuuj}
translate P Clear {Wyczyść}
translate P Close {Zamknij}
translate P Contents {Spis treści}
translate P Defaults {Domyślne}
translate P InvertSearch {Odwróć wyszukiwanie}
translate P Delete {Usuń}
translate P Graph {Wykres}
translate P Help {Pomoc}
translate P Hide {Ukryj}
translate P Import {Importuj}
translate P Index {Indeks}
translate P LoadGame {Wczytaj partię}
translate P PgnOpenInViewer {Otwórz w przeglądarce PGN}
translate P MergeGame {Scal partię}
translate P MergeGames {Scal partie}
translate P Preview {Podgląd}
translate P Revert {Przywróć}
translate P Rename {Zmień nazwę}
translate P Save {Zapisz}
translate P Search {Szukaj}
translate P Stop {Zatrzymaj}
translate P Store {Zapisz}
translate P Update {Aktualizuj}
translate P ChangeOrient {Zmień orientację okna}
translate P ShowIcons {Pokaż ikony}
translate P None {Brak}
translate P First {Pierwszy}
translate P Current {Bieżący}
translate P Last {Ostatni}

# General messages:
translate P game {partia}
translate P games {partie}
translate P move {posunięcie}
translate P moves {posunięcia}
translate P all {wszystkie}
translate P Yes {Tak}
translate P No {Nie}
translate P Both {Oba}
translate P King {Król}
translate P Queen {Hetman}
translate P Rook {Wieża}
translate P Bishop {Goniec}
translate P Knight {Skoczek}
translate P Pawn {Pion}
translate P White {Białe}
translate P Black {Czarne}
translate P Player {Gracz}
translate P Rating {Ranking}
translate P RatingDiff {Różnica rankingów (białe - czarne)}
translate P AverageRating {Średni ranking}
translate P Event {Turniej}
translate P Site {Miejsce}
translate P Country {Kraj}
translate P IgnoreColors {Ignoruj kolory}
translate P Date {Data}
translate P EventDate {Data turnieju}
translate P Decade {Dekada}
translate P Year {Rok}
translate P Month {Miesiąc}
translate P Months {Styczeń Luty Marzec Kwiecień Maj Czerwiec Lipiec Sierpień Wrzesień Październik Listopad Grudzień}
translate P Days {Nie Pon Wt Śr Czw Pt Sob}
translate P YearToToday {Ostatni rok}
translate P YearToTodayTooltip {Ustaw datę od roku wstecz do dziś}
translate P Result {Wynik}
translate P Round {Runda}
translate P Length {Długość}
translate P ECOCode {Kod ECO}
translate P ECO {ECO}
translate P Deleted {Usunięte}
translate P SearchResults {Wyniki wyszukiwania}
translate P OpeningTheDatabase {Otwieranie bazy danych}
translate P Database {Baza danych}
translate P Filter {Filtr}
translate P noGames {brak partii}
translate P allGames {wszystkie partie}
translate P empty {puste}
translate P clipbase {schowek}
translate P score {ocena}
translate P StartPos {Pozycja początkowa}
translate P Total {Razem}
translate P readonly {tylko do odczytu}

# Import games (skip duplicates):
translate P ImportInto {Importuj do:}
translate P ImportStripComments {Usuń komentarze z importowanych partii}
translate P Clipbase {Schowek}
translate P NoWritableDatabases {Nie ma otwartej bazy danych z możliwością zapisu. Najpierw otwórz lub utwórz bazę danych.}
translate P Imported {Zaimportowano}
translate P Into {do}
translate P Skipped {Pominięto}
translate P DuplicateGame {duplikat partii}
translate P DuplicateGames {duplikaty partii}
translate P PgnErrorsWarnings {Błędy/ostrzeżenia PGN:}
translate P NoPgnErrorsWarnings {bez błędów i ostrzeżeń PGN.}

# Standard error messages:
translate P ErrNotOpen {To nie jest otwarta baza danych.}
translate P ErrReadOnly {Ta baza danych jest tylko do odczytu i nie można jej modyfikować.}
translate P ErrSearchInterrupted {Wyszukiwanie zostało przerwane — wyniki są niekompletne.}
translate P ErrNoClockComments {W tej partii nie znaleziono komentarzy z czasem [%clk]. Aby korzystać z tej funkcji, dodaj czasy za pomocą okna komentarzy (Ctrl+E).}
translate P ErrFileInUse {Błąd: plik jest już używany. Zamknij inne aplikacje korzystające z tej bazy danych.}

# Drag and drop
translate P DndCannotOpenUri {Nie można otworzyć adresu URI}
translate P DndInvalidUri {Nieprawidłowy adres URI}
translate P DndUriRejected {Odrzucono adres URI}
translate P DndUriRejectedDetail {Bazy danych SCID (.si5, .si4, .si3) lub pliki PGN/EPD.}
translate P DndEmptyUriList {Na liście adresów URI nie znaleziono żadnych plików}
translate P DndOwnerDidntRespond {Nie udało się upuścić pliku: właściciel zaznaczenia nie odpowiedział}




# Game information:
translate P twin {duplikat}
translate P deleted {usunięta}
translate P comment {komentarz}
translate P hidden {ukryta}
translate P LastMove {Ostatnie posunięcie}
translate P NextMove {Dalej}
translate P GameStart {Początek partii}
translate P LineStart {Początek wariantu}
translate P GameEnd {Koniec partii}
translate P LineEnd {Koniec wariantu}

# Player information:
translate P PInfoAll {Wyniki dla <b>wszystkich</b> partii}
translate P PInfoFilter {Wyniki dla partii z <b>filtra</b>}
translate P PInfoAgainst {Wyniki przeciwko}
translate P PInfoMostWhite {Najczęstsze debiuty białymi}
translate P PInfoMostBlack {Najczęstsze debiuty czarnymi}
translate P PInfoRating {Historia rankingu}
translate P PInfoBio {Biografia}
translate P PInfoEditRatings {Edytuj rankingi}
translate P PInfoEloFile {Plik}

# Tablebase information:
translate P Draw {Remis}
translate P with {z}
translate P only {tylko}
translate P lose {przegrywa}
translate P loses {przegrywa}

# Tip of the day:
translate P Tip {Porada}
translate P TipAtStartup {Pokazuj poradę przy uruchamianiu}
translate P TipConvertPGN {Możesz zwiększyć wydajność, konwertując pliki PGN}

# Tree window menus:
menuText P TreeFile "Plik" 0
menuText P TreeFileFillWithBase "Wypełnij pamięć podręczną bazą" 0 {Wypełnij plik pamięci podręcznej wszystkimi partiami z bieżącej bazy}
menuText P TreeFileFillWithGame "Wypełnij pamięć podręczną partią" 0 {Wypełnij plik pamięci podręcznej bieżącą partią z bieżącej bazy}
menuText P TreeFileSetCacheSize "Rozmiar pamięci podręcznej" 0 {Ustaw rozmiar pamięci podręcznej}
menuText P TreeFileCacheInfo "Informacje o pamięci podręcznej" 0 {Wyświetl informacje o wykorzystaniu pamięci podręcznej}
menuText P TreeFileSave "Zapisz plik pamięci podręcznej" 0 {Zapisz plik pamięci podręcznej drzewa wariantów (.stc)}
menuText P TreeFileFill "Wypełnij plik pamięci podręcznej" 0 \
  {Wypełnij plik pamięci podręcznej najczęściej występującymi pozycjami debiutowymi}
menuText P TreeFileBest "Lista najlepszych partii" 0 {Pokaż listę najlepszych partii z drzewa wariantów}
menuText P TreeFileGraph "Okno wykresu" 0 {Pokaż wykres dla tej gałęzi drzewa wariantów}
menuText P TreeFileCopy "Kopiuj tekst drzewa wariantów do schowka" 1 \
  {Kopiuj statystyki drzewa wariantów do schowka}
menuText P TreeFileClose "Zamknij okno drzewa wariantów" 0 {Zamknij okno drzewa wariantów}
menuText P TreeMask "Maska" 0
menuText P TreeMaskNew "Nowa" 0 {Utwórz nową maskę}
menuText P TreeMaskOpen "Otwórz" 0 {Otwórz maskę}
menuText P TreeMaskOpenRecent "Otwórz ostatnią" 0 {Otwórz ostatnio używaną maskę}
menuText P TreeMaskSave "Zapisz" 0 {Zapisz maskę}
menuText P TreeMaskClose "Zamknij" 0 {Zamknij maskę}
menuText P TreeMaskFillWithGame "Wypełnij partią" 0 {Wypełnij maskę partią}
menuText P TreeMaskFillWithBase "Wypełnij bazą" 0 {Wypełnij maskę wszystkimi partiami z bazy}
menuText P TreeMaskInfo "Informacje" 0 {Pokaż statystyki bieżącej maski}
menuText P TreeMaskDisplay "Pokaż mapę maski" 0 {Pokaż dane maski w postaci drzewa wariantów}
menuText P TreeMaskSearch "Szukaj" 0 {Szukaj w bieżącej masce}
menuText P TreeSort "Sortuj" 0
menuText P TreeSortAlpha "Alfabetycznie" 0
menuText P TreeSortECO "Kod ECO" 0
menuText P TreeSortFreq "Częstotliwość" 0
menuText P TreeSortScore "Wynik" 0
menuText P TreeOpt "Opcje" 0
menuText P TreeOptSlowmode "Tryb dokładny" 0 {Dokładny tryb aktualizacji (większa dokładność)}
menuText P TreeOptFastmode "Tryb szybki" 0 {Szybki tryb aktualizacji (bez uwzględniania transpozycji posunięć)}
menuText P TreeOptFastAndSlowmode "Tryb szybki i dokładny" 0 {Najpierw szybki, potem dokładny tryb aktualizacji}
menuText P TreeOptStartStop "Automatyczne odświeżanie" 0 {Włącz lub wyłącz automatyczne odświeżanie okna drzewa wariantów}
menuText P TreeOptLock "Zablokuj" 0 {Przypnij lub odłącz drzewo wariantów od bieżącej bazy danych}
menuText P TreeOptTraining "Trening" 0 {Włącz lub wyłącz tryb treningowy drzewa wariantów}
menuText P TreeOptDepth "Półposunięcia" 0 {Liczba półposunięć wyświetlanych w drzewie wariantów (1–4)}
menuText P TreeOptAutosave "Automatycznie zapisuj pamięć podręczną" 0 \
  {Automatycznie zapisuj plik pamięci podręcznej przy zamykaniu okna drzewa wariantów}
menuText P TreeHelp "Pomoc" 0
menuText P TreeHelpTree "Pomoc — okno drzewa wariantów" 0
menuText P TreeHelpIndex "Indeks pomocy" 0
menuText P TreeFindGames "Znajdź partie z adnotacją" 0 {Utwórz listę partii, w których wykonano to posunięcie z adnotacją}
translate P SaveCache {Zapisz pamięć podręczną}
translate P Training {Trening}
translate P PlayFromHere {Graj od tego miejsca}
translate P PlayFromHereHelp {Silnik odpowiada po osiągnięciu limitu czasu lub głębokości analizy — zależnie od tego, co nastąpi wcześniej. Wartość zero oznacza brak limitu dla danego parametru.}
translate P PlayFromHereLimit {Ustaw limit czasu i głębokości analizy}
translate P PlayFromHereBusy {Najpierw zakończ bieżącą analizę lub wybierz „Zakończ partię”.}
translate P TreeTrainingEndOfLine {Osiągnięto koniec wariantu.}
translate P TreeTrainingMoveNotInBase {Tego posunięcia nie ma w bazie danych.}
translate P LockTree {Zablokuj}
translate P TreeDepth {Półposunięcia:}
translate P TreeLocked {zablokowane}
translate P TreeBest {Najlepsze}
translate P TreeBestGames {Najlepsze partie z drzewa wariantów}
translate P TreeFindAnyAnn {dowolna adnotacja}
translate P TreeFindStalePos {Bieżąca pozycja nie odpowiada już pozycji drzewa wariantów z adnotacją.\nWróć do niej i spróbuj ponownie.}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate P TreeTitleRow \
  {   Posunięcie(a)              ECO    Częstotliwość  Wynik  ŚrElo Forma  ŚrDł ŚrRok %remisów  % wygr.}
translate P TreeTotal {RAZEM}
translate P DoYouWantToSaveFirst {Czy chcesz najpierw zapisać?}
translate P AddToMask {Dodaj do maski}
translate P RemoveFromMask {Usuń z maski}
translate P AddThisMoveToMask {Dodaj to posunięcie do maski}
translate P SearchMask {Szukaj w masce}
translate P DisplayMask {Wyświetl maskę}
translate P Nag {Kod NAG}
translate P Marker {Znacznik}
translate P Include {Uwzględnij}
translate P Exclude {Wyklucz}
translate P MainLine {Wariant główny}
translate P Bookmark {Zakładka}
translate P NewLine {Nowy wariant}
translate P ToBeVerified {Do sprawdzenia}
translate P ToTrain {Do treningu}
translate P Dubious {Wątpliwe}
translate P ToRemove {Do usunięcia}
translate P NoMarker {Bez znacznika}
translate P ColorMarker {Kolor}
translate P WhiteMark {Biały}
translate P GreenMark {Zielony}
translate P YellowMark {Żółty}
translate P BlueMark {Niebieski}
translate P RedMark {Czerwony}
translate P CommentMove {Skomentuj posunięcie}
translate P CommentPosition {Skomentuj pozycję}
translate P AddMoveToMaskFirst {Najpierw dodaj posunięcie do maski}
translate P OpenAMaskFileFirst {Najpierw otwórz plik maski}
translate P Positions {Pozycje}
translate P Moves {Posunięcia}

# Finder window:
menuText P FinderFile "Plik" 0
menuText P FinderFileSubdirs "Szukaj w podkatalogach" 0
menuText P FinderFileClose "Zamknij wyszukiwarkę plików" 0
menuText P FinderSort "Sortuj" 0
menuText P FinderSortType "Typ" 0
menuText P FinderSortSize "Rozmiar" 0
menuText P FinderSortMod "Data modyfikacji" 0
menuText P FinderSortName "Nazwa" 0
menuText P FinderSortPath "Ścieżka" 0
menuText P FinderTypes "Typy" 0
menuText P FinderTypesScid "Bazy danych SCID" 0
menuText P FinderTypesOld "Bazy danych SCID w starym formacie" 0
menuText P FinderTypesPGN "Pliki PGN" 0
menuText P FinderTypesEPD "Pliki EPD" 0
menuText P FinderTypesRep "Pliki repertuaru debiutowego" 0
menuText P FinderHelp "Pomoc" 0
menuText P FinderHelpFinder "Pomoc wyszukiwarki plików" 0
menuText P FinderHelpIndex "Indeks pomocy" 0
translate P FileFinder {Wyszukiwarka plików}
translate P FinderDir {Katalog}
translate P FinderDirs {Katalogi}
translate P FinderFiles {Pliki}
translate P FinderUpDir {wyżej}
translate P FinderCtxOpen {Otwórz}
translate P FinderCtxBackup {Utwórz kopię zapasową}
translate P FinderCtxCopy {Kopiuj}
translate P FinderCtxMove {Przenieś}
translate P FinderCtxDelete {Usuń}

# Player finder:
menuText P PListFile "Plik" 0
menuText P PListFileUpdate "Aktualizuj" 0
menuText P PListFileClose "Zamknij wyszukiwarkę graczy" 0
menuText P PListSort "Sortuj" 0
menuText P PListSortName "Nazwisko" 0
menuText P PListSortElo "Ranking Elo" 0
menuText P PListSortGames "Liczba partii" 0
menuText P PListSortOldest "Najstarsze" 0
menuText P PListSortNewest "Najnowsze" 2

# Tournament finder:
menuText P TmtFile "Plik" 0
menuText P TmtFileUpdate "Aktualizuj" 0
menuText P TmtFileClose "Zamknij wyszukiwarkę turniejów" 0
menuText P TmtSort "Sortuj" 0
menuText P TmtSortDate "Data" 0
menuText P TmtSortPlayers "Liczba graczy" 0
menuText P TmtSortGames "Liczba partii" 0
menuText P TmtSortElo "Ranking Elo" 0
menuText P TmtSortSite "Miejsce" 0
menuText P TmtSortEvent "Turniej" 1
menuText P TmtSortWinner "Zwycięzca" 0
translate P TmtLimit "Limit wyników"
translate P TmtMeanElo "Średni ranking Elo"
translate P TmtNone "Nie znaleziono pasujących turniejów."

# Graph windows:
menuText P GraphFile "Plik" 0
menuText P GraphFileColor "Zapisz jako kolorowy PostScript..." 8
menuText P GraphFileGrey "Zapisz jako czarno-biały PostScript..." 8
menuText P GraphFileClose "Zamknij okno" 6
menuText P GraphOptions "Opcje" 0
menuText P GraphOptionsWhite "Białe" 0
menuText P GraphOptionsBlack "Czarne" 0
menuText P GraphOptionsBoth "Obie strony" 1
menuText P GraphOptionsPInfo "Dane gracza z jego profilu" 0
menuText P GraphOptionsEloFile "Ranking Elo z pliku" 0
menuText P GraphOptionsEloDB "Ranking Elo z bazy danych" 0
translate P GraphFilterTitle "Wykres filtra: odsetek partii, w których osiągnięto daną pozycję"
translate P GraphAbsFilterTitle "Wykres filtra: częstotliwość występowania pozycji w partiach"
translate P GraphWinPctTitle "Wykres filtra: procent wygranych (1-0 i 0-1) w danej pozycji według roku"
translate P ConfigureFilter "Ustaw osie X dla roku, rankingu i liczby posunięć"
translate P FilterEstimate "Szacunkowo"
translate P TitleFilterGraph "scidCommunity: Wykres filtra"
translate P WinPct "Procent wygranych"
translate P GraphLine "Wykres liniowy"
translate P GraphBar "Wykres słupkowy"
translate P GraphPopup "Otwórz szachownicę w osobnym oknie"
translate P PgnVarClose {Zamknij wszystkie warianty}
translate P PgnVarOpen {Otwórz wszystkie warianty}
translate P PgnEvaluate {Oceń}
translate P PgnSaveEval {Zapisz ocenę}
translate P PgnOptShort "Krótki nagłówek (3 wiersze)"
translate P PgnOptSymbols "Adnotacje symboliczne"
translate P PgnOptIndentC "Wcięcia komentarzy"
translate P PgnOptIndentV "Wcięcia wariantów"
translate P PgnOptColumn "Układ kolumnowy (jedno posunięcie w wierszu)"
translate P PgnOptSpace "Spacja po nr posunięcia"
translate P PgnOptStripMarks "Usuń kody kolorowych pól i strzałek"
translate P PgnOptBoldMainLine "Pogrubiaj posunięcia wariantu głównego"

# Analysis window:
translate P AddVariation {Dodaj wariant}
translate P AddAllVariations {Dodaj wszystkie warianty}
translate P AddMove {Dodaj posunięcie}
translate P Annotate {Adnotuj}
translate P ShowAnalysisBoard {Pokaż szachownicę analizy}
translate P ShowInfo {Pokaż informacje o silniku}
translate P FinishGame {Dokończ partię}
translate P FinishGameSlot2Warning {Silnik w drugim oknie jest już używany przez otwarte okno analizy.\n\nFunkcja Dokończ partię korzysta z silników z okien 1 i 2 i może przejąć kontrolę nad tym silnikiem. Czy kontynuować?}
translate P StopEngine {Zatrzymaj silnik}
translate P StartEngine {Start/Stop}
translate P LockEngine {Zablokuj silnik}
translate P AnalysisCommand {Polecenie analizy}
translate P PreviousChoices {Poprzednie wybory}
translate P AnnotateTime {Czas na posunięcie w sekundach}
translate P AnnotateWhich {Dodaj warianty}
translate P AnnotateAll {Dla posunięć obu stron}
translate P AnnotateAllMoves {Adnotuj wszystkie posunięcia}
translate P AnnotateWhite {Tylko posunięcia białych}
translate P AnnotateBlack {Tylko posunięcia czarnych}
translate P AnnotateBlundersOnly {Gdy posunięcie w partii jest poważnym błędem}
translate P AnnotateBlundersOnlyScoreChange {Gdy analiza wykryje poważny błąd, ze zmianą oceny z/do: }
translate P BlundersThreshold {Próg}
translate P ScoreAllMoves {Oceń wszystkie posunięcia}
translate P LowPriority {Niski priorytet procesora}
translate P ClickHereToSeeMoves {Kliknij tutaj, aby zobaczyć posunięcia}
translate P ConfigureInformant {Oceny informatora}
translate P Informant!? {Ciekawe posunięcie}
translate P Informant? {Słabe posunięcie}
translate P Informant?? {Poważny błąd}
translate P Informant?! {Wątpliwe posunięcie}
translate P Informant+= {Białe mają niewielką przewagę}
translate P Informant+/- {Białe mają wyraźną przewagę}
translate P Informant+- {Białe mają decydującą przewagę}
translate P Informant+-- {Białe mają przytłaczającą przewagę}
translate P AutoComment {Komentarz automatyczny}
translate P AutoCommentTooltip {Wygeneruj komentarz AI do bieżącej pozycji}
translate P AnalysisAutoCommentTooltip {Wygeneruj komentarz AI do całej partii}
translate P MoveLabelBest {Najlepsze}
translate P MoveLabelExcellent {Znakomite}
translate P MoveLabelGood {Dobre}
translate P MoveLabelInaccuracy {Niedokładność}
translate P MoveLabelMistake {Błąd}
translate P MoveLabelBlunder {Poważny błąd}
translate P MoveLabelBrilliant {Błyskotliwe}
translate P MoveLabelGreat {Świetne}
translate P MoveLabelMiss {Przeoczona szansa}
translate P MoveLabelForced {Wymuszone}
translate P MoveLabelBook {Teoria debiutowa}
translate P GameComment {Komentarz do partii}
translate P GameCommentTooltip {Wyszukaj w partii posunięcia z adnotacjami i wygeneruj podsumowanie AI}
translate P ReviewGameButton {Analiza partii}
translate P ReviewGameButtonTooltip {Przeanalizuj każde posunięcie wariantu głównego i przypisz mu ocenę}
translate P ReviewMoveButton {Komentarz do posunięcia}
translate P ReviewMoveButtonTooltip {Oceń podświetlone posunięcie i zapisz ocenę w partii}
translate P ReviewSettings {Ustawienia analizy}
translate P ReviewSettingsTooltip {Ustaw parametry analizy}
translate P ToolsWhatThreat {Jakie jest zagrożenie?}
translate P ToolsWhatThreatTooltip {Zapytaj silnik, jakie zagrożenie stwarza strona będąca na posunięciu.}
translate P WhatThreatRunning {Analiza zagrożenia jest już uruchomiona.}
translate P WhatThreatNoEngine {Nie skonfigurowano żadnego silnika. Wybierz go w menu Narzędzia -> Konfiguruj silniki lub najpierw otwórz okno silnika.}
translate P WhatThreatNoPosition {Brak pozycji do analizy.}
translate P WhatThreatNoMove {Nie ma tu posunięcia do skomentowania. Najpierw przejdź do posunięcia w partii.}
translate P WhatThreatFailed {Nie udało się przeprowadzić analizy zagrożenia: %s}
translate P WhatThreatNothingForcing {%s nie ma tu żadnego wymuszającego posunięcia: żadne nie wygrywa materiału ani nie daje szacha.}
translate P ReviewVerifier {Silnik weryfikujący}
translate P ReviewVerifierOff {Wyłączony (bez weryfikacji)}
translate P ReviewVarLines {Warianty do zapisania}
translate P ReviewVarCp {Różnica ocen wariantów (cp)}
translate P ReviewMoveWait {Czekaj na osiągnięcie zadanej głębokości analizy}
translate P ReviewMovetime {Limit czasu (ms)}
translate P ReviewOpeningMoves {Posunięcia w debiucie}
translate P StopNow {Zatrzymaj teraz}
translate P StopAfterThisGame {Zatrzymaj po tej partii}
translate P ReviewFromPreset {%s (z ustawień silnika)}
translate P ReviewProgress {Analiza pozycji %s z %s}
translate P ReviewWaitForDepth {Oczekiwanie na głębokość %s}
translate P ReviewFailed {Analiza nie powiodła się: %s}
translate P ReviewCoach {Komentarz trenera}
translate P ReviewCoachProgress {ocena %s z %s · komentarze %s z %s}
translate P ReviewWriting {Tworzenie analizy...}
translate P ReviewCoachSettings {Ustawienia trenera...}
translate P ReviewCoachNoModel {Komentarze trenera są włączone, ale nie skonfigurowano modelu. Wybierz dostawcę i model w ustawieniach trenera dostępnych w oknie Ustawienia analizy.}
translate P ReviewCoachKept {Analiza anulowana. Zachowano %s z %s komentarzy trenera.}
translate P ReviewCoachDiscarded {Analiza została zakończona, ale komentarze trenera nie zostały zachowane, ponieważ podczas ich tworzenia otwarto inną partię.}
translate P ReviewCoachSummaryLabel {Podsumowanie}
translate P ReviewCoachLevelLabel {Poziom}
translate P ReviewCoachOpeningLabel {Debiut}
translate P ReviewCoachPhase {posunięcia %d-%d — dokładność Białych %.1f%%, Czarnych %.1f%%, ACPL Białych %d, Czarnych %d.}
translate P ReviewReportMarker {Analiza partii}
translate P ReviewReportSide {%s: dokładność %.1f%%, ACPL %d, szacowany ranking Elo %d}
translate P ReviewReportLabels {Oceny %s: %s}
translate P ReviewReportKeyMoments {Kluczowe momenty: %s}
translate P ReviewReportPhases {Fazy partii: %s}
translate P ReviewReportPhase {%s, posunięcia %d-%d (%s %.1f / %s %.1f)}
translate P ReviewReportOpening {debiut}
translate P ReviewReportMiddlegame {gra środkowa}
translate P ReviewReportEndgame {końcówka}
translate P TimeMs {Czas (ms)}


# Book window
translate P Book {Książka debiutowa}
translate P OtherBookMoves {Książka przeciwnika}
translate P OtherBookMovesTooltip {Posunięcia, na które przeciwnik ma odpowiedź w swojej książce debiutowej}
translate P Alphabetical {Alfabetycznie}
translate P BookCount {Książki debiutowe}

# Configure Engines dialog:
translate P EngineList {Konfiguruj silniki}
translate P EngineName {Nazwa}
translate P EngineCmd {Polecenie}
translate P EngineArgs {Parametry}
translate P EngineDir {Katalog}
translate P EngineElo {Ranking Elo}
translate P EngineTime {Data}
translate P EngineNew {Nowy}
translate P EngineEdit {Edytuj}
translate P EngineRequired {Pola pogrubione są wymagane, pozostałe są opcjonalne}
translate P EngineNameInUse {Silnik o nazwie %s już istnieje. Czy zapisać ten silnik pod nazwą %s?}
translate P EngineProtocol {Protokół komunikacji}
translate P EngineNotation {Zapis posunięć}
translate P EngineFlipEvaluation {Odwróć perspektywę oceny}
translate P EngineShowLog {Pokaż dziennik komunikacji}
translate P EngineNetworkd {Zezwalaj na połączenia zdalne}
translate P EngineSelect {Wybierz bieżący silnik}
translate P EngineAddLocal {Dodaj silnik lokalny}
translate P EngineAddRemote {Dodaj silnik zdalny}
translate P EngineReload {Ponownie wczytaj bieżący silnik}
translate P EngineClone {Utwórz kopię bieżącego silnika}
translate P EngineDuplicate {Powiel}
translate P EngineDelete {Usuń bieżący silnik}
translate P EngineOpenWindow {Otwórz okno silnika}

# PGN window menus:
menuText P PgnFile "Plik" 0
menuText P PgnFileCopy "Kopiuj partię do schowka" 0
menuText P PgnFilePrint "Zapisz do pliku..." 0
menuText P PgnFileClose "Zamknij okno PGN" 10
menuText P PgnOpt "Wyświetlanie" 0
menuText P PgnOptColor "Wyświetlaj kolory" 0
menuText P PgnOptShort "Krótki nagłówek (3 wiersze)" 0
menuText P PgnOptSymbols "Adnotacje symboliczne" 1
menuText P PgnOptIndentC "Wcięcia komentarzy" 0
menuText P PgnOptIndentV "Wcięcia wariantów" 7
menuText P PgnOptColumn "Układ kolumnowy (jedno posunięcie w wierszu)" 1
menuText P PgnOptSpace "Spacja po nr posunięcia" 1
menuText P PgnOptStripMarks "Usuń kody kolorowych pól i strzałek" 1
menuText P PgnOptBoldMainLine "Pogrubiaj posunięcia wariantu głównego" 4
menuText P PgnColor "Kolory" 0
menuText P PgnColorHeader "Nagłówek..." 0
menuText P PgnColorAnno "Adnotacje..." 0
menuText P PgnColorComments "Komentarze..." 0
menuText P PgnColorVars "Warianty..." 0
menuText P PgnColorBackground "Tło..." 0
menuText P PgnColorMain "Wariant główny..." 0
menuText P PgnColorCurrent "Tło bieżącego posunięcia..." 1
menuText P PgnHelp "Pomoc" 0
menuText P PgnHelpPgn "Pomoc — okno PGN" 0
menuText P PgnHelpIndex "Indeks" 0
translate P PgnWindowTitle {Zapis partii — partia %u}

# Notation pane (PGN window) button tooltips:
translate P TBLookupTooltip {Sprawdź pozycję w bazie końcówek Lichess}
translate P LichessEvalTooltip {Analiza bieżącej pozycji w chmurze Lichess}
translate P LichessUploadTooltip {Prześlij partię do Lichess.org}
translate P ChessComTooltip {Otwórz partię na szachownicy analizy Chess.com}
translate P ChessDBTooltip {Otwórz bieżącą pozycję w ChessDB.cn}
translate P LichessOpenExTooltip {Eksplorator debiutów Lichess dla bieżącej pozycji}
translate P LichessMonitorTooltip {Wstrzymaj lub wznów aktualizacje na żywo}
translate P LucasChessNoMacOS {Silniki Lucas Chess nie są dostępne w systemie macOS}

# Crosstable window menus:
menuText P CrosstabFile "Plik" 0
menuText P CrosstabFileText "Zapisz do pliku tekstowego..." 9
menuText P CrosstabFileHtml "Zapisz do pliku HTML..." 9
menuText P CrosstabFileClose "Zamknij tabelę turniejową" 0
menuText P CrosstabEdit "Edycja" 0
menuText P CrosstabEditEvent "Turniej" 0
menuText P CrosstabEditSite "Miejsce" 0
menuText P CrosstabEditDate "Data" 0
menuText P CrosstabOpt "Wyświetlanie" 0
menuText P CrosstabOptAll "System kołowy" 0
menuText P CrosstabOptSwiss "System szwajcarski" 0
menuText P CrosstabOptKnockout "System pucharowy" 0
menuText P CrosstabOptAuto "Automatycznie" 1
menuText P CrosstabOptAges "Wiek w latach" 8
menuText P CrosstabOptNats "Narodowości" 0
menuText P CrosstabOptRatings "Rankingi" 0
menuText P CrosstabOptTitles "Tytuły" 0
menuText P CrosstabOptBreaks "Punktacja pomocnicza" 4
menuText P CrosstabOptDeleted "Uwzględnij usunięte partie" 8
menuText P CrosstabOptColors "Kolory (tylko tabela systemu szwajcarskiego)" 0
menuText P CrosstabOptColumnNumbers "Numeruj kolumny (tylko tabela systemu kołowego)" 2
menuText P CrosstabOptGroup "Grupuj wyniki" 0
menuText P CrosstabSort "Sortuj" 0
menuText P CrosstabSortName "Nazwisko" 0
menuText P CrosstabSortRating "Ranking" 0
menuText P CrosstabSortScore "Wynik" 0
menuText P CrosstabColor "Kolor" 0
menuText P CrosstabColorPlain "Zwykły tekst" 0
menuText P CrosstabColorHyper "Hipertekst" 0
menuText P CrosstabHelp "Pomoc" 0
menuText P CrosstabHelpCross "Pomoc — tabela turniejowa" 0
menuText P CrosstabHelpIndex "Indeks pomocy" 0
translate P SetFilter {Ustaw filtr}
translate P AddToFilter {Dodaj do filtra}
translate P Swiss {System szwajcarski}
translate P Category {Kategoria}

# Opening report window menus:
menuText P OprepFile "Plik" 0
menuText P OprepFileText "Zapisz do pliku tekstowego..." 9
menuText P OprepFileHtml "Zapisz do pliku HTML..." 9
menuText P OprepFileOptions "Opcje..." 0
menuText P OprepFileClose "Zamknij okno raportu" 0
menuText P OprepFavorites "Ulubione" 1
menuText P OprepFavoritesAdd "Dodaj raport..." 0
menuText P OprepFavoritesEdit "Edytuj ulubione raporty..." 0
menuText P OprepFavoritesGenerate "Generuj raporty..." 0
menuText P OprepHelp "Pomoc" 0
menuText P OprepHelpReport "Pomoc — raport debiutowy" 0
menuText P OprepHelpIndex "Indeks pomocy" 0

# Header search:
translate P HeaderSearch {Wyszukiwanie wg nagłówka}
translate P EndSideToMove {Strona na posunięciu na końcu partii}
translate P GamesWithNoECO {Partie bez kodu ECO?}
translate P GameLength {Długość partii}
translate P FindGamesWith {Znajdź partie z flagami}
translate P StdStart {Niestandardowa pozycja początkowa}
translate P Promotions {Promocje pionków}
translate P Comments {Komentarze}
translate P Variations {Warianty}
translate P Annotations {Adnotacje}
translate P DeleteFlag {Flaga usunięcia}
translate P WhiteOpFlag {Debiut białych}
translate P BlackOpFlag {Debiut czarnych}
translate P MiddlegameFlag {Gra środkowa}
translate P EndgameFlag {Końcówka}
translate P NoveltyFlag {Nowinka}
translate P PawnFlag {Struktura pionowa}
translate P TacticsFlag {Taktyka}
translate P QsideFlag {Gra na skrzydle hetmańskim}
translate P KsideFlag {Gra na skrzydle królewskim}
translate P BrilliancyFlag {Błyskotliwa kombinacja}
translate P BlunderFlag {Poważny błąd}
translate P UserFlag {Użytkownik}
translate P PgnContains {PGN zawiera tekst}
translate P PgnTag {Znacznik}
translate P TagContains {zawiera}
translate P Variant {Wariant}
translate P Annotator {Komentator}
translate P Cmnts {Tylko partie z adnotacjami}

# Game list window:
translate P GlistNumber {Numer}
translate P GlistWhite {Białe}
translate P GlistBlack {Czarne}
translate P GlistWElo {Ranking białych}
translate P GlistBElo {Ranking czarnych}
translate P GlistEvent {Turniej}
translate P GlistSite {Miejsce}
translate P GlistRound {Runda}
translate P GlistDate {Data}
translate P GlistYear {Rok}
translate P GlistEDate {Data turnieju}
translate P GlistResult {Wynik}
translate P GlistLength {Długość}
translate P GlistCountry {Kraj}
translate P GlistECO {ECO}
translate P GlistOpening {Debiut}
translate P GlistEndMaterial {Materiał na końcu partii}
translate P GlistDeleted {Usunięta}
translate P GlistFlags {Flagi}
translate P GlistVars {Warianty}
translate P GlistComments {Komentarze}
translate P GlistAnnos {Adnotacje}
translate P GlistStart {Początek}
translate P GlistGameNumber {Nr partii}
translate P GlistAverageElo {Średni ranking Elo}
translate P GlistRating {Ranking}
translate P GlistFindText {Znajdź tekst}
translate P GlistMoveField {Przesuń}
translate P GlistEditField {Konfiguruj}
translate P GlistAddField {Dodaj}
translate P GlistDeleteField {Usuń}
translate P GlistWidth {Szerokość}
translate P GlistAlign {Wyrównanie}
translate P GlistAlignL {Wyrównanie: do lewej}
translate P GlistAlignR {Wyrównanie: do prawej}
translate P GlistAlignC {Wyrównanie: do środka}
translate P GlistColor {Kolor}
translate P GlistSep {Separator}
translate P GlistCurrentSep {-- Bieżący --}
translate P GlistNewSort {Nowy}
translate P GlistAddToSort {Dodaj}

# base sorting
translate P GsortSort {Sortuj...}
translate P GsortDate {Data}
translate P GsortYear {Rok}
translate P GsortEvent {Turniej}
translate P GsortSite {Miejsce}
translate P GsortRound {Runda}
translate P GsortWhiteName {Nazwisko białych}
translate P GsortBlackName {Nazwisko czarnych}
translate P GsortECO {ECO}
translate P GsortResult {Wynik}
translate P GsortMoveCount {Liczba posunięć}
translate P GsortAverageElo {Średni ranking Elo}
translate P GsortCountry {Kraj}
translate P GsortDeleted {Usunięte}
translate P GsortEventDate {Data turnieju}
translate P GsortWhiteElo {Ranking białych}
translate P GsortBlackElo {Ranking czarnych}
translate P GsortComments {Komentarze}
translate P GsortVariations {Warianty}
translate P GsortNAGs {Kody NAG}
translate P GsortAscending {Rosnąco}
translate P GsortDescending {Malejąco}
translate P GsortAdd {Dodaj}
translate P GsortStore {Zapisz}
translate P GsortLoad {Wczytaj}

# menu shown with right mouse button down on game list.
translate P GlistRemoveThisGameFromFilter {Usuń tę partię z filtra}
translate P GlistRemoveGameAndAboveFromFilter {Usuń tę partię i wszystkie powyżej z filtra}
translate P GlistRemoveGameAndBelowFromFilter {Usuń tę partię i wszystkie poniżej z filtra}
translate P GlistDeleteGame {Usuń tę partię lub przywróć ją}
translate P GlistDeleteAllGames {Usuń wszystkie partie z filtra}
translate P GlistUndeleteAllGames {Przywróć wszystkie partie z filtra}
translate P GlistMergeGameInBase {Scal partię z}

# Maintenance window:
translate P DatabaseName {Nazwa bazy danych:}
translate P TypeIcon {Ikona typu:}
translate P NumOfGames {Partie:}
translate P NumDeletedGames {Usunięte partie:}
translate P NumFilterGames {Partie w filtrze:}
translate P YearRange {Zakres lat:}
translate P RatingRange {Zakres rankingów:}
translate P Description {Opis}
translate P Flag {Flaga}
translate P CustomFlags {Własne flagi}
translate P DeleteCurrent {Usuń bieżącą partię}
translate P DeleteFilter {Usuń partie z filtra}
translate P DeleteAll {Usuń wszystkie partie}
translate P UndeleteCurrent {Przywróć bieżącą partię}
translate P UndeleteFilter {Przywróć partie z filtra}
translate P UndeleteAll {Przywróć wszystkie partie}
translate P DeleteTwins {Usuń duplikaty partii}
translate P MarkCurrent {Oznacz bieżącą partię}
translate P MarkFilter {Oznacz partie z filtra}
translate P MarkAll {Oznacz wszystkie partie}
translate P UnmarkCurrent {Usuń oznaczenie bieżącej partii}
translate P UnmarkFilter {Usuń oznaczenia partii z filtra}
translate P UnmarkAll {Usuń oznaczenia wszystkich partii}
translate P Spellchecking {Sprawdzanie pisowni}
translate P Players {Gracze}
translate P Events {Turnieje}
translate P Sites {Miejsca}
translate P Rounds {Rundy}
translate P DatabaseOps {Operacje na bazie danych}
translate P ReclassifyGames {Przypisz partiom kody ECO}
translate P CompactDatabase {Kompaktuj bazę danych...}
translate P SortDatabase {Sortuj bazę danych}
translate P AddEloRatings {Dodaj rankingi Elo}
translate P AutoloadGame {Automatycznie wczytaj partię nr}
translate P StripTags {Usuń znaczniki PGN}
translate P StripTag {Usuń znacznik}
translate P Cleaner {Porządkowanie...}
translate P CleanerHelp {
Funkcja Porządkowanie w SCID wykona w bieżącej bazie danych wszystkie wybrane poniżej czynności.
Jeśli wybierzesz klasyfikację ECO lub usuwanie duplikatów partii, zostaną zastosowane bieżące ustawienia tych okien dialogowych.
}
translate P CleanerConfirm {
Po rozpoczęciu porządkowania nie można go przerwać!

W dużej bazie danych operacja może potrwać długo, zależnie od wybranych czynności i ich bieżących ustawień.

Czy na pewno chcesz rozpocząć porządkowanie?
}
# Twinchecker
translate P TwinCheckUndelete {aby zmienić; "u" przywraca obie partie)}
translate P TwinCheckprevPair {Poprzednia para}
translate P TwinChecknextPair {Następna para}
translate P TwinChecker {scidCommunity: Wyszukiwanie duplikatów partii}
translate P TwinCheckTournament {Partie w turnieju:}
translate P TwinCheckNoTwin {Brak duplikatów partii}
translate P TwinCheckNoTwinfound {Nie znaleziono duplikatów partii.\nAby wyświetlić duplikat partii w tym oknie, najpierw użyj funkcji „Usuń duplikaty partii...”.}
translate P TwinCheckTag {Wspólne znaczniki...}
translate P TwinCheckFound1 {SCID znalazł $result duplikatów partii}
translate P TwinCheckFound2 { i oznaczył je do usunięcia}
translate P TwinCheckNoDelete {W tej bazie danych nie ma partii do usunięcia.}
translate P TwinCriteria1 { Twoje ustawienia wyszukiwania duplikatów partii mogą spowodować,\nże partie, które nie są identyczne, ale mają podobne posunięcia, zostaną uznane za duplikaty.}
translate P TwinCriteria2 {Jeśli wybierzesz „Nie” dla opcji „te same posunięcia”, zaleca się wybranie „Tak” dla kolorów, turnieju, miejsca, rundy, roku i miesiąca.\nCzy mimo to chcesz kontynuować i usunąć duplikaty partii?}
translate P TwinCriteria3 {Zaleca się wybranie „Tak” dla co najmniej dwóch ustawień: „to samo miejsce”, „ta sama runda” i „ten sam rok”.\nCzy mimo to chcesz kontynuować i usunąć duplikaty partii?}
translate P TwinCriteriaConfirm {scidCommunity: Potwierdź ustawienia wyszukiwania duplikatów partii}
translate P TwinChangeTag "Zmień następujące znaczniki partii:\n\n"
translate P AllocRatingDescription "To polecenie użyje bieżącego pliku sprawdzania pisowni, aby dodać rankingi Elo do partii w tej bazie danych. Jeśli gracz nie ma bieżącego rankingu, ale w pliku sprawdzania pisowni znajduje się jego ranking z daty partii, zostanie on dodany."
translate P RatingOverride "Zastąp istniejące niezerowe rankingi"
translate P AddRatings "Dodaj rankingi dla:"
translate P AddedRatings {SCID dodał $r rankingów Elo w $g partiach.}

#Bookmark editor
translate P NewSubmenu "Nowe podmenu"

# Comment editor:
translate P AnnotationSymbols {Symbole adnotacji:}
translate P Comment {Komentarz:}
translate P Format {Formatowanie}
translate P Bold {Pogrubienie}
translate P Italic {Kursywa}
translate P Underline {Podkreślenie}
translate P TextColor {Kolor tekstu...}
translate P CommentDefaultColor {Domyślny kolor komentarza...}
translate P CommentFont {Czcionka...}
translate P RemoveFormatting {Usuń formatowanie}
translate P Family {Krój czcionki}
translate P Size {Rozmiar}
translate P FontSizeWarning {Rozmiar czcionki musi być dodatnią liczbą całkowitą.}
translate P Green {Zielony}
translate P Blue {Niebieski}
translate P Red {Czerwony}
translate P Brown {Brązowy}
translate P CustomColor {Kolor niestandardowy...}
translate P InsertMark {Wstaw znacznik}
translate P InsertMarkHelp {
Wstawianie/usuwanie znacznika: wybierz kolor, typ i pole.
Wstawianie/usuwanie strzałki: kliknij prawym przyciskiem dwa pola.
}

# Nag buttons in comment editor:
translate P GoodMove {Dobre posunięcie}
translate P PoorMove {Słabe posunięcie}
translate P ExcellentMove {Znakomite posunięcie}
translate P Blunder {Poważny błąd}
translate P InterestingMove {Ciekawe posunięcie}
translate P DubiousMove {Wątpliwe posunięcie}
translate P WhiteDecisiveAdvantage {Białe mają decydującą przewagę}
translate P BlackDecisiveAdvantage {Czarne mają decydującą przewagę}
translate P WhiteClearAdvantage {Białe mają wyraźną przewagę}
translate P BlackClearAdvantage {Czarne mają wyraźną przewagę}
translate P WhiteSlightAdvantage {Białe mają niewielką przewagę}
translate P BlackSlightAdvantage {Czarne mają niewielką przewagę}
translate P WhiteCrushing {Białe mają przytłaczającą przewagę}
translate P BlackCrushing {Czarne mają przytłaczającą przewagę}
translate P Equality {Równa pozycja}
translate P Unclear {Niejasna pozycja}
translate P Diagram {Diagram}

# Board search:
translate P BoardSearch {Wyszukiwanie pozycji}
translate P FilterOperation {Działanie na bieżącym filtrze:}
translate P FilterAnd {I (Ogranicz filtr)}
translate P FilterOr {LUB (Dodaj do filtra)}
translate P FilterIgnore {IGNORUJ (Wyczyść filtr)}
translate P SearchType {Rodzaj wyszukiwania:}
translate P SearchBoardExact {Dokładna pozycja (wszystkie figury na tych samych polach)}
translate P SearchBoardPawns {Piony (ten sam materiał, wszystkie piony na tych samych polach)}
translate P SearchBoardFiles {Kolumny (ten sam materiał, wszystkie piony na tych samych kolumnach)}
translate P SearchBoardAny {Dowolna (ten sam materiał, piony i figury na dowolnych polach)}
translate P SearchInRefDatabase {Szukaj w bazie referencyjnej}
translate P LookInVars {Szukaj w wariantach}

# Material search:
translate P MaterialSearch {Wyszukiwanie wg materiału}
translate P Material {Materiał}
translate P Patterns {Wzorce}
translate P Zero {Zero}
translate P Any {Dowolny}
translate P CurrentBoard {Bieżąca pozycja}
translate P CommonEndings {Typowe końcówki}
translate P CommonPatterns {Typowe wzorce}
translate P MaterialDiff {Różnica materialna}
translate P squares {pola}
translate P SameColor {Ten sam kolor}
translate P OppColor {Przeciwny kolor}
translate P Either {Dowolny}
translate P MoveNumberRange {Zakres numerów posunięć}
translate P MatchForAtLeast {Dopasuj co najmniej}
translate P HalfMoves {półposunięć}

# Common endings in material search:
translate P EndingPawns {Końcówki pionowe}
translate P EndingRookVsPawns {Wieża przeciwko pionowi lub pionom}
translate P EndingRookPawnVsRook {Wieża i pion przeciwko wieży}
translate P EndingRookPawnsVsRook {Wieża i piony przeciwko wieży}
translate P EndingRooks {Końcówki wieżowe}
translate P EndingRooksPassedA {Końcówki wieżowe z wolnym pionem a}
translate P EndingRooksDouble {Końcówki z dwiema wieżami}
translate P EndingBishops {Końcówki gońcowe}
translate P EndingBishopVsKnight {Końcówki: goniec przeciwko skoczkowi}
translate P EndingKnights {Końcówki skoczkowe}
translate P EndingQueens {Końcówki hetmańskie}
translate P EndingQueenPawnVsQueen {Hetman i pion przeciwko hetmanowi}
translate P BishopPairVsKnightPair {Gra środkowa: para gońców przeciwko parze skoczków}

# Common patterns in material search:
translate P PatternWhiteIQP {Biały izolowany pion hetmański}
translate P PatternWhiteIQPBreakE6 {Biały izolowany pion hetmański: przełom d4-d5 przeciwko e6}
translate P PatternWhiteIQPBreakC6 {Biały izolowany pion hetmański: przełom d4-d5 przeciwko c6}
translate P PatternBlackIQP {Czarny izolowany pion hetmański}
translate P PatternWhiteBlackIQP {Biały izolowany pion hetmański przeciwko czarnemu izolowanemu pionowi hetmańskiemu}
translate P PatternCoupleC3D4 {Białe: izolowane piony c3 i d4}
translate P PatternHangingC5D5 {Czarne: wiszące piony na c5 i d5}
translate P PatternMaroczy {Centrum Maroczego (piony na c4 i e4)}
translate P PatternRookSacC3 {Poświęcenie wieży na c3}
translate P PatternKc1Kg8 {Roszada długa przeciwko krótkiej (król na c1 przeciwko królowi na g8)}
translate P PatternKg1Kc8 {Roszada krótka przeciwko długiej (król na g1 przeciwko królowi na c8)}
translate P PatternLightFian {Fiancetto na jasnych polach (gońce na g2 i b7)}
translate P PatternDarkFian {Fiancetto na ciemnych polach (gońce na b2 i g7)}
translate P PatternFourFian {Cztery fiancetta (gońce na b2, g2, b7 i g7)}

# Game saving:
translate P Today {Dzisiaj}
translate P ClassifyGame {Przypisz kod ECO partii}

# Setup position:
translate P EmptyBoard {Pusta szachownica}
translate P InitialBoard {Pozycja początkowa}
translate P SideToMove {Strona na posunięciu}
translate P MoveNumber {Nr posunięcia}
translate P Castling {Prawo do roszady}
translate P EnPassantFile {Kolumna bicia w przelocie}
translate P ClearFen {Wyczyść FEN}
translate P PasteFen {Wklej FEN}

translate P SaveAndContinue {Zapisz i kontynuuj}
translate P DiscardChangesAndContinue {Odrzuć zmiany i kontynuuj}
translate P GoBack {Wróć}

# Replace move dialog:
translate P ReplaceMove {Zastąp posunięcie}
translate P AddNewVar {Dodaj nowy wariant}
translate P NewMainLine {Nowy wariant główny}
translate P ReplaceMoveMessage {W tym miejscu istnieje już posunięcie.

Możesz je zastąpić, usuwając wszystkie kolejne posunięcia, albo dodać swoje posunięcie jako nowy wariant.

(Aby w przyszłości nie wyświetlać tego komunikatu, wyłącz opcję „Pytaj przed zastąpieniem posunięć” w menu Opcje:Posunięcia.)}

# Make database read-only dialog:
translate P ReadOnlyDialog {Po ustawieniu bazy danych jako tylko do odczytu nie będzie można wprowadzać żadnych zmian.
Nie będzie można zapisywać ani zastępować partii ani zmieniać ich flag usunięcia.
Wyniki sortowania i klasyfikacji ECO będą tymczasowe.

Aby ponownie umożliwić wprowadzanie zmian, wystarczy zamknąć i ponownie otworzyć bazę danych.

Czy na pewno chcesz ustawić tę bazę danych jako tylko do odczytu?}

# Clear game dialog:
translate P ClearGameDialog {Partia została zmieniona.

Czy na pewno chcesz kontynuować i odrzucić wprowadzone zmiany?
}

# Exit dialog:
translate P ExitDialog {Czy na pewno chcesz zamknąć SCID?}
translate P ExitUnsaved {W następujących bazach danych znajdują się niezapisane zmiany w partiach. Jeśli teraz zamkniesz program, zmiany te zostaną utracone.}

# Import window:
translate P PasteCurrentGame {Wklej bieżącą partię}
translate P ImportHelp1 {Wpisz lub wklej partię w formacie PGN w powyższym polu.}
translate P ImportHelp2 {Tutaj zostaną wyświetlone błędy podczas importowania partii.}
translate P OverwriteExistingMoves {Zastąpić istniejące posunięcia?}

# ECO Browser:
translate P ECOAllSections {wszystkie kody ECO}
translate P ECOSection { ECO}
translate P ECOSummary {Podsumowanie dla}
translate P ECOFrequency {Częstotliwość kodów dla}

# Opening Report:
translate P OprepReportFor {Raport dla}
translate P OprepTitle {Raport debiutowy}
translate P OprepReport {Raport}
translate P OprepGenerated {Wygenerowano przez}
translate P OprepStatsHist {Statystyki i historia}
translate P OprepStats {Statystyki}
translate P OprepStatAll {Wszystkie partie w raporcie}
translate P OprepStatBoth {Obaj gracze z rankingiem}
translate P OprepStatSince {Od}
translate P OprepOldest {Najstarsze partie}
translate P OprepNewest {Najnowsze partie}
translate P OprepPopular {Obecna popularność}
translate P OprepFreqAll {Częstotliwość we w latach:   }
translate P OprepFreq1   {W ciągu ostatniego   roku: }
translate P OprepFreq5   {W ciągu ostatnich   5 lat: }
translate P OprepFreq10  {W ciągu ostatnich  10 lat: }
translate P OprepEvery {raz na %u partii}
translate P OprepUp {wzrost o %u%s w porównaniu ze wszystkimi latami}
translate P OprepDown {spadek o %u%s w porównaniu ze wszystkimi latami}
translate P OprepSame {bez zmian w porównaniu ze wszystkimi latami}
translate P OprepMostFrequent {Najczęściej występujący gracze}
translate P OprepMostFrequentOpponents {Najczęstsi przeciwnicy}
translate P OprepRatingsPerf {Rankingi i wyniki}
translate P OprepAvgPerf {Średnie rankingi i wyniki}
translate P OprepWRating {Ranking białych}
translate P OprepBRating {Ranking czarnych}
translate P OprepWPerf {Wynik rankingowy białych}
translate P OprepBPerf {Wynik rankingowy czarnych}
translate P OprepHighRating {Partie z najwyższym średnim rankingiem}
translate P OprepTrends {Trendy wyników}
translate P OprepResults {Długość i częstotliwość wyników}
translate P OprepLength {Długość partii}
translate P OprepFrequency {Częstotliwość}
translate P OprepWWins {Wygrane  białych: }
translate P OprepBWins {Wygrane czarnych: }
translate P OprepDraws {Remisy:           }
translate P OprepWholeDB {cała baza danych}
translate P OprepShortest {Najkrótsze wygrane}
translate P OprepMovesThemes {Posunięcia i motywy}
translate P OprepMoveOrders {Kolejności posunięć prowadzące do pozycji z raportu}
translate P OprepMoveOrdersOne \
  {Do tej pozycji prowadzi tylko jedna kolejność posunięć:}
translate P OprepMoveOrdersAll \
  {Do tej pozycji prowadzą %u kolejności posunięć:}
translate P OprepMoveOrdersMany \
  {Do tej pozycji prowadzą %u kolejności posunięć. Oto %u najczęstszych:}
translate P OprepMovesFrom {Posunięcia z pozycji raportu}
translate P OprepMostFrequentEcoCodes {Najczęstsze kody ECO}
translate P OprepThemes {Motywy pozycyjne}
translate P OprepThemeDescription {Częstotliwość występowania motywów w pierwszych %u posunięciach każdej partii}
translate P OprepThemeSameCastling {Roszada po tej samej stronie}
translate P OprepThemeOppCastling {Roszada po przeciwnych stronach}
translate P OprepThemeNoCastling {Oba króle bez roszady}
translate P OprepThemeKPawnStorm {Szturm pionów na skrzydle królewskim}
translate P OprepThemeQueenswap {Wymiana hetmanów}
translate P OprepThemeWIQP {Biały izolowany pion hetmański}
translate P OprepThemeBIQP {Czarny izolowany pion hetmański}
translate P OprepThemeWP567 {Biały pion na 5., 6. lub 7. linii}
translate P OprepThemeBP234 {Czarny pion na 2., 3. lub 4. linii}
translate P OprepThemeOpenCDE {Otwarta linia c, d lub e}
translate P OprepTheme1BishopPair {Tylko jedna strona ma parę gońców}
translate P OprepEndgames {Końcówki}
translate P OprepReportGames {Partie w raporcie}
translate P OprepAllGames    {Wszystkie partie}
translate P OprepEndClass {Materiał na końcu każdej partii}
translate P OprepTheoryTable {Tabela teorii}
translate P OprepTableComment {Wygenerowano na podstawie %u partii z najwyższym rankingiem.}
translate P OprepExtraMoves {Dodatkowe posunięcia w uwagach tabeli teorii}
translate P OprepMaxGames {Maksymalna liczba partii w tabeli teorii}
translate P OprepMergeMoves {Limit posunięć przy scalaniu partii}
translate P OprepMergeUnique {Scalaj tylko unikatowe partie}
translate P OprepViewHTML {Wyświetl HTML}

# Player Report:
translate P PReportTitle {Raport o graczu}
translate P PReportColorWhite {grając białymi}
translate P PReportColorBlack {grając czarnymi}
translate P PReportMoves {po %s}
translate P PReportOpenings {Debiuty}
translate P PReportClipbase {Wyczyść schowek i skopiuj do niego pasujące partie}

# Piece Tracker window:
translate P TrackerSelectSingle {Kliknij lewym przyciskiem myszy, aby wybrać tę figurę.}
translate P TrackerSelectPair {Kliknij lewym przyciskiem myszy, aby wybrać tę figurę; prawym przyciskiem wybierzesz także jej odpowiednik.}
translate P TrackerSelectPawn {Kliknij lewym przyciskiem myszy, aby wybrać tego pionka; prawym przyciskiem wybierzesz wszystkie 8 pionków.}
translate P TrackerStat {Statystyka}
translate P TrackerGames {% partii z posunięciem na dane pole}
translate P TrackerTime {% czasu spędzonego na każdym polu}
translate P TrackerMoves {Posunięcia}
translate P TrackerMovesStart {Podaj nr posunięcia, od którego śledzenie ma się rozpocząć.}
translate P TrackerMovesStop {Podaj nr posunięcia, na którym śledzenie ma się zakończyć.}

# Game selection dialogs:
translate P SelectAllGames {Wszystkie partie w bazie danych}
translate P SelectFilterGames {Tylko partie z filtra}
translate P SelectTournamentGames {Tylko partie z bieżącego turnieju}
translate P SelectOlderGames {Tylko starsze partie}

# Delete Twins window:
translate P TwinsNote {Aby dwie partie zostały uznane za duplikaty, muszą mieć tych samych dwóch graczy oraz spełniać wybrane poniżej kryteria. Po znalezieniu pary duplikatów partii krótsza z nich zostanie usunięta. Wskazówka: przed wyszukiwaniem duplikatów partii warto sprawdzić pisownię w bazie danych, ponieważ poprawia to skuteczność wyszukiwania.}
translate P TwinsCriteria {Kryteria: duplikaty partii muszą mieć...}
translate P TwinsWhich {Sprawdzane partie}
translate P TwinsColors {Te same kolory graczy}
translate P TwinsEvent {Ten sam turniej}
translate P TwinsSite {To samo miejsce}
translate P TwinsRound {Ta sama runda}
translate P TwinsYear {Ten sam rok}
translate P TwinsMonth {Ten sam miesiąc}
translate P TwinsDay {Ten sam dzień}
translate P TwinsResult {Ten sam wynik}
translate P TwinsECO {Ten sam kod ECO}
translate P TwinsMoves {Te same posunięcia}
translate P TwinsPlayers {Porównywanie nazwisk graczy}
translate P TwinsPlayersExact {Dokładna zgodność}
translate P TwinsPlayersPrefix {Tylko pierwsze 4 litery}
translate P TwinsWhen {Podczas usuwania duplikatów partii}
translate P TwinsSkipShort {Pomiń wszystkie partie krótsze niż 5 posunięć}
translate P TwinsUndelete {Najpierw przywróć wszystkie partie}
translate P TwinsSetFilter {Ustaw filtr na wszystkie usunięte duplikaty}
translate P TwinsComments {Zawsze zachowuj partie z komentarzami}
translate P TwinsVars {Zawsze zachowuj partie z wariantami}
translate P TwinsDeleteWhich {Usuń partię}
translate P TwinsDeleteShorter {Krótsza partia}
translate P TwinsDeleteOlder {Partia o niższym numerze}
translate P TwinsDeleteNewer {Partia o wyższym numerze}
translate P TwinsDelete {Usuń partie}

# Name editor window:
translate P NameEditType {Rodzaj nazwy do edycji}
translate P NameEditSelect {Partie do edycji}
translate P NameEditReplace {Zamień}
translate P NameEditWith {na}
translate P NameEditMatches {Dopasowania: naciśnij Ctrl+1 do Ctrl+9, aby wybrać}

# Check games window:
translate P CheckGames {Sprawdź partie}
translate P CheckGamesWhich {Sprawdzane partie}
translate P CheckAll {Wszystkie partie}
translate P CheckSelectFilterGames {Tylko partie z filtra}

# Classify window:
translate P Classify {Klasyfikuj}
translate P ClassifyWhich {Które partie klasyfikować według ECO}
translate P ClassifyAll {Wszystkie partie (zastąp dotychczasowe kody ECO)}
translate P ClassifyYear {Wszystkie partie rozegrane w ciągu ostatniego roku}
translate P ClassifyMonth {Wszystkie partie rozegrane w ciągu ostatniego miesiąca}
translate P ClassifyNew {Tylko partie bez kodu ECO}
translate P ClassifyCodes {Używane kody ECO}
translate P ClassifyBasic {Tylko podstawowe kody (np. „B12”)}
translate P ClassifyExtended {Rozszerzenia SCID (np. „B12j”)}
translate P ClassifyResult {Klasyfikacja ECO zakończona: zaktualizowano $result partii.}

# Compaction:
translate P NameFile {Plik nazw}
translate P GameFile {Plik partii}
translate P Names {Nazwy}
translate P Unused {Nieużywane}
translate P SizeKb {Rozmiar (kB)}
translate P CurrentState {Obecny stan}
translate P AfterCompaction {Po kompaktowaniu}
translate P CompactNames {Kompaktuj plik nazw}
translate P CompactGames {Kompaktuj plik partii}
translate P NoUnusedNames "Brak nieużywanych nazw. Plik nazw jest już w pełni skompaktowany."
translate P NoUnusedGames "Plik partii jest już w pełni skompaktowany."
translate P GameFileCompacted {Plik partii w bazie danych został skompaktowany.}

# Sorting:
translate P SortCriteria {Kryteria}
translate P AddCriteria {Dodaj kryterium}
translate P CommonSorts {Typowe sortowania}
translate P Sort {Sortuj}

# Exporting:
translate P AddToExistingFile {Dodaj partie do istniejącego pliku}
translate P ExportComments {Eksportuj komentarze}
translate P ExportVariations {Eksportuj warianty}
translate P IndentComments {Wcięcia komentarzy}
translate P IndentVariations {Wcięcia wariantów}
translate P ExportColumnStyle {Układ kolumnowy (jedno posunięcie w wierszu)}
translate P ExportSymbolStyle {Styl adnotacji symbolicznych:}
translate P ExportStripMarks {Usuń z komentarzy kody kolorowych pól i strzałek}
translate P OptionsExportEol {Zakończenia linii:}
translate P OptionsExportEolNative {Rodzinny}
translate P OptionsPGNExport {Eksport PGN}
translate P OptionsTagOrderIntro {Kolejność pozostałych tagów PGN podczas pisania gry. Lista Seven Tag Roster jest zawsze pisana jako pierwsza, zgodnie ze standardem PGN.}
translate P OptionsTagOrderStr {Lista siedmiu tagów (stała): wydarzenie, miejsce, data, runda, biały, czarny, wynik}
translate P OptionsTagOrderWhite {Ocena biała}
translate P OptionsTagOrderBlack {Czarna ocena}
translate P OptionsTagOrderOthers {Inne tagi}
translate P OptionsTagOrderSort {Sortuj pozostałe tagi alfabetycznie (w przeciwnym razie oryginalna kolejność)}
translate P Up {W górę}
translate P Down {W dół}

# Goto game/move dialogs:
translate P LoadGameNumber {Podaj nr partii do wczytania:}
translate P GotoMoveNumber {Przejdź do posunięcia nr:}

# Copy games dialog:
translate P CopyAllGames {Kopiuj wszystkie partie do}
translate P CopyGames {Kopiuj partie}
translate P CopyConfirm {
 Czy na pewno chcesz skopiować
 [::utils::thousands $nGamesToCopy] partii z filtra
 z bazy danych "$fromName"
 do bazy danych "$targetName"?
}
translate P CopyErr {Nie można skopiować partii}
translate P CopyErrSource {baza źródłowa}
translate P CopyErrTarget {baza docelowa}
translate P CopyErrNoGames {nie zawiera partii w filtrze}
translate P CopyErrReadOnly {jest tylko do odczytu}
translate P CopyErrNotOpen {nie jest otwarta}

# Colors:
translate P LightSquares {Jasne pola}
translate P DarkSquares {Ciemne pola}
translate P PickColorFromScreen {Pobierz kolor z ekranu}
translate P SaveCurrentColors {Zapisz bieżące kolory}
translate P SaveCurrentColorsHint {Dodaj bieżące kolory szachownicy do listy zestawów}
translate P RemoveSavedColor {Usuń ten zapisany zestaw kolorów}
translate P ColorPresetExists {Te kolory są już zapisane jako zestaw %d}
translate P SelectedSquares {Zaznaczone pola}
translate P SuggestedSquares {Pola sugerowanego posunięcia}
translate P WhitePieces {Białe figury}
translate P BlackPieces {Czarne figury}
translate P WhiteBorder {Biała ramka}
translate P BlackBorder {Czarna ramka}

# Novelty window:
translate P FindNovelty {Znajdź nowinkę}
translate P Novelty {Nowinka}
translate P NoveltyInterrupt {Wyszukiwanie nowinki przerwane}
translate P NoveltyNone {Nie znaleziono nowinki w tej partii}
translate P NoveltyHelp {SCID znajdzie pierwsze posunięcie w bieżącej partii, które prowadzi do pozycji nieobecnej w wybranej bazie danych ani w książce debiutowej ECO.}

# Sounds configuration:
translate P SoundsFolder {Katalog z plikami dźwiękowymi}
translate P SoundsFolderHelp {Katalog powinien zawierać pliki King.wav, a.wav, 1.wav itd.}
translate P SoundsTheme {Motyw dźwiękowy}
translate P SoundsThemeDefault {Domyślny (Scid)}
translate P SoundsThemeHelp {Dźwięki posunięć i zdarzeń pochodzą z wybranego motywu. Aby dodać własny motyw, skopiuj folder z własnymi dźwiękami do katalogu themes.}
translate P SoundsAnnounceOptions {Opcje zapowiadania posunięć}
translate P SoundsAnnounceNew {Zapowiadaj nowe posunięcia w chwili ich wykonywania}
translate P SoundsMoveSoundOnly {Tylko dźwięk posunięcia (bez zapowiedzi)}
translate P SoundsAnnounceForward {Zapowiadaj posunięcia przy przechodzeniu o jedno posunięcie do przodu}
translate P SoundsAnnounceBack {Zapowiadaj posunięcia przy cofnięciu lub przechodzeniu o jedno posunięcie wstecz}
translate P SoundsSoundDisabled {Podczas uruchamiania SCID nie znaleziono pakietu audio Snack;\nDźwięk jest wyłączony.}

# Upgrading databases:
translate P Upgrading {Aktualizacja}
translate P ConfirmOpenNew {
To baza danych w starym formacie (Scid 3), którego nie można otworzyć w Scid 4. Utworzono już jednak jej wersję w nowym formacie.

Czy chcesz otworzyć bazę danych w nowym formacie?
}
translate P ConfirmUpgrade {
To baza danych w starym formacie (Scid 3). Przed użyciem jej w Scid 4 trzeba utworzyć wersję w nowym formacie.

Aktualizacja utworzy nową wersję bazy danych, a następnie usunie oryginalne pliki.

Może to potrwać, ale wystarczy wykonać tę operację tylko raz. Jeśli potrwa zbyt długo, możesz ją anulować.

Czy chcesz teraz zaktualizować tę bazę danych?
}

# Recent files options:
translate P RecentFilesMenu {Liczba ostatnio używanych plików w menu Plik}
translate P RecentFilesExtra {Liczba ostatnio używanych plików w dodatkowym podmenu}

# My Player Names options:
translate P MyPlayerNamesDescription {Wpisz poniżej listę preferowanych nazwisk graczy, po jednym w każdym wierszu. Można używać symboli wieloznacznych (np. "?” oznacza dowolny pojedynczy znak, a "*” — dowolny ciąg znaków).
Za każdym razem, gdy zostanie wczytana partia z graczem znajdującym się na liście, szachownica w głównym oknie zostanie w razie potrzeby obrócona, aby pokazać partię z perspektywy tego gracza.
}

# Computer Tournament:
translate P configComp {Konfiguracja turnieju}
translate P Tournament {Turniej}
translate P Available {Dostępne}
translate P Selected {Wybrane}
translate P RoundRobin {System kołowy}
translate P Gauntlet {System każdy z każdym}
translate P CompGameNext {Następna partia:}
translate P TimeperGame {Czas na\npartię}
translate P TimeperMove {Czas na\nposunięcie}
translate P compStoreTime {Zapisz czas: }
translate P Clock {Zegar}
translate P compConcurrent {Partie rozgrywane jednocześnie: }
translate P compShowBoards {Pokaż szachownice}
translate P compCarousel {System karuzelowy}
translate P compSaveEval {Zapisuj oceny}
translate P compCanceledGames {Partie anulowane lub zakończone przekroczeniem czasu:}
translate P Replay {Odtwórz ponownie}
translate P compStart {Start}
translate P compSave {Zapisuj po każdej partii}
translate P compStop {Zatrzymaj po zakończeniu\nbieżącej partii}
translate P compRunning {Turniej w trakcie}
translate P Restart {Uruchom ponownie}
translate P compFinished {Turniej zakończony}
translate P compStopped {Turniej zatrzymany}
translate P compForceDraw {Wymuś remis}
translate P compForceResign {Wymuś poddanie}
translate P compAfterMove {Po posunięciu:}
translate P compNumMoves {Liczba posunięć:}
translate P compScoreLess {Ocena <:}
translate P compScoreGreater {Ocena >:}
translate P compRepeatReverse {Powtórz w odwrotnej kolejności}

#Coach
translate P showblunderexists {Pokaż wystąpienie poważnego błędu}
translate P showblundervalue {Pokaż wartość poważnego błędu}
translate P showscore {Pokaż ocenę}
translate P coachgame {Partia z trenerem}
translate P white {Białe}
translate P black {Czarne}
translate P both {Obie strony}
translate P configurePlayEngine {Gra z silnikiem}
translate P UseChessClock {Użyj zegara szachowego}
translate P Play {Graj}
translate P Noblunder {Bez poważnego błędu}
translate P blunder {Poważny błąd}
translate P Noinfo {-- Brak informacji --}
translate P moveblunderthreshold {posunięcie jest poważnym błędem, jeśli strata przekracza}
translate P limitanalysis {Ogranicz czas analizy silnika}
translate P seconds {sekundy}
translate P Abort {Przerwij}
translate P Resume {Wznów}
translate P OutOfOpening {Poza teorią debiutów}
translate P NotFollowedLine {Nie trzymasz się wariantu}
translate P DoYouWantContinue {Czy chcesz kontynuować?}
translate P CoachIsWatching {Trener obserwuje}
translate P Ponder {Stałe myślenie}
translate P LimitELO {Ogranicz siłę gry do rankingu Elo}
translate P DubiousMovePlayedTakeBack {Wykonano wątpliwe posunięcie. Czy chcesz je cofnąć?}
translate P WeakMovePlayedTakeBack {Wykonano słabe posunięcie. Czy chcesz je cofnąć?}
translate P BadMovePlayedTakeBack {Wykonano złe posunięcie. Czy chcesz je cofnąć?}
translate P Iresign {Poddaję się}
translate P ResultSaved {Wynik zapisany}
translate P yourmoveisnotgood {Twoje posunięcie nie jest dobre}
translate P EndOfVar {Koniec wariantu}
translate P Openingtrainer {Trening debiutowy}
translate P DisplayCM {Pokaż posunięcia kandydackie}
translate P DisplayCMValue {Pokaż oceny posunięć kandydackich}
translate P DisplayOpeningStats {Pokaż statystyki}
translate P ShowReport {Pokaż raport}
translate P NumberOfGoodMovesPlayed {dobre posunięcia}
translate P NumberOfDubiousMovesPlayed {wątpliwe posunięcia}
translate P NumberOfMovesPlayedNotInRepertoire {posunięcia spoza repertuaru}
translate P NumberOfTimesPositionEncountered {liczba wystąpień pozycji}
translate P PlayerBestMove {Dozwolone tylko najlepsze posunięcia}
translate P OpponentBestMove {Przeciwnik wykonuje najlepsze posunięcia}
translate P OnlyFlaggedLines {Tylko oznaczone warianty}
translate P resetStats {Wyzeruj statystyki}
translate P Repertoiretrainingconfiguration {Konfiguracja treningu repertuaru}
translate P Loadingrepertoire {Wczytywanie repertuaru}
translate P Movesloaded {Wczytane posunięcia}
translate P Repertoirenotfound {Nie znaleziono repertuaru}
translate P Openfirstrepertoirewithtype {Najpierw otwórz bazę repertuaru z ikoną/typem ustawionym na odpowiednią stronę}
translate P Movenotinrepertoire {Posunięcia nie ma w repertuarze}
translate P PositionsInRepertoire {Pozycje w repertuarze}
translate P PositionsNotPlayed {Pozycje nierozgrywane}
translate P PositionsPlayed {Pozycje rozegrane}
translate P Success {Sukces}
translate P DubiousMoves {Wątpliwe posunięcia}
translate P OutOfRepertoire {Poza repertuarem}
translate P ConfigureTactics {Konfiguracja taktyki}
translate P ResetScores {Wyzeruj wyniki}
translate P LoadingBase {Wczytywanie bazy danych}
translate P Tactics {Taktyka}
translate P ShowSolution {Pokaż rozwiązanie}
translate P NextExercise {Następne zadanie}
translate P PrevExercise {Poprzednie zadanie}
translate P StopTraining {Zatrzymaj trening}
translate P Next {Dalej}
translate P ResettingScore {Zerowanie wyniku}
translate P LoadingGame {Wczytywanie partii}
translate P MateFound {Znaleziono mata}
translate P BestSolutionNotFound {Nie znaleziono najlepszego rozwiązania!}
translate P MateNotFound {Nie znaleziono mata}
translate P ShorterMateExists {Istnieje krótszy mat}
translate P ScorePlayed {Ocena rozegranego posunięcia}
translate P Expected {oczekiwano}
translate P ChooseTrainingBase {Wybierz bazę treningową}
translate P Thinking {Myślenie}
translate P AnalyzeDone {Analiza zakończona}
translate P WinWonGame {Wygraj wygraną partię}
translate P Lines {Warianty}
translate P ConfigureUCIengine {Konfiguracja silnika UCI}
translate P SpecificOpening {Wybrany debiut}
translate P StartNewGame {Rozpocznij nową partię}
translate P Opening {Debiut}
translate P StartFromCurrentPosition {Rozpocznij od bieżącej pozycji}
translate P FixedDepth {Stała głębokość}
translate P Nodes {Węzły}
translate P Depth {Głębokość}
translate P Time {Czas}
translate P SecondsPerMove {Sekundy na pos.}
translate P Engine {Silnik}
translate P TimeMode {Tryb czasu}
translate P TimeBonus {Czas + dodatek}
translate P TimeMin {min}
translate P TimeSec {sek}
translate P AllExercisesDone {Wszystkie zadania wykonane}
translate P MoveOutOfBook {Posunięcie poza książką}
translate P LastBookMove {Ostatnie posunięcie z książki}
translate P AnnotateSeveralGames {Od partii do partii:}
translate P FindOpeningErrors {Znajdź błędy debiutowe}
translate P MarkTacticalExercises {Oznacz zadania taktyczne}
translate P UseBook {Użyj książki debiutowej}
translate P MultiPV {Wiele wariantów}
translate P Hash {Pamięć Hash}
translate P OwnBook {Użyj książki silnika}
translate P BookFile {Plik książki debiutowej}
translate P AnnotateVariations {Adnotuj warianty}
translate P AnnotateVariationsMainLineOnly {Warianty: tylko wariant główny (tryb analizy)}
translate P ShortAnnotations {Krótkie adnotacje}
translate P addAnnotatorTag {Dodaj znacznik komentatora}
translate P AddScoreToShortAnnotations {Dodaj ocenę do adnotacji}
translate P AddScoreToAllMoves {Dodaj ocenę do wszystkich posunięć}
translate P Export {Eksportuj}
translate P BookPartiallyLoaded {Książka wczytana częściowo}
# Opening names used in tacgame.tcl
translate P Reti {Réti}
translate P English {Debiut angielski}
translate P d4Nf6Miscellaneous {1.d4 Sf6 — różne}
translate P Trompowsky {Atak Trompowsky’ego}
translate P Budapest {Gambit budapeszteński}
translate P OldIndian {Stary indyj­ski}
translate P BenkoGambit {Gambit Benko}
translate P ModernBenoni {Nowoczesna obrona Benoni}
translate P DutchDefence {Obrona holenderska}
translate P Scandinavian {Obrona skandynawska}
translate P AlekhineDefence {Obrona Alechina}
translate P Pirc {Obrona Pirca}
translate P CaroKann {Obrona Caro-Kann}
translate P CaroKannAdvance {Wariant posunięcia e5 w obronie Caro-Kann}
translate P Sicilian {Obrona sycylijska}
translate P SicilianAlapin {Wariant Alapina}
translate P SicilianClosed {Zamknięta obrona sycylijska}
translate P SicilianRauzer {Wariant Rauzera}
translate P SicilianDragon {Wariant smoczy}
translate P SicilianScheveningen {Wariant Scheveningen}
translate P SicilianNajdorf {Wariant Najdorfa}
translate P OpenGame {Gra otwarta}
translate P Vienna {Gra wiedeńska}
translate P KingsGambit {Gambit królewski}
translate P RussianGame {Partia rosyjska}
translate P ItalianTwoKnights {Partia włoska / obrona dwóch skoczków}
translate P Spanish {Partia hiszpańska}
translate P SpanishExchange {Wariant wymienny}
translate P SpanishOpen {Wariant otwarty}
translate P SpanishClosed {Wariant zamknięty}
translate P FrenchDefence {Obrona francuska}
translate P FrenchAdvance {Wariant posunięcia e5 w obronie francuskiej}
translate P FrenchTarrasch {Wariant Tarrascha}
translate P FrenchWinawer {Wariant Winawera}
translate P FrenchExchange {Wariant wymienny}
translate P QueensPawn {Debiut hetmański}
translate P Slav {Obrona słowiańska}
translate P QGA {Gambit hetmański przyjęty}
translate P QGD {Gambit hetmański odrzucony}
translate P QGDExchange {Wariant wymienny gambitu hetmańskiego}
translate P SemiSlav {Obrona półsłowiańska}
translate P QGDwithBg5 {Gambit hetmański odrzucony z Gg5}
translate P QGDOrthodox {Wariant ortodoksyjny gambitu hetmańskiego}
translate P Grunfeld {Obrona Grünfelda}
translate P GrunfeldExchange {Wariant wymienny obrony Grünfelda}
translate P GrunfeldRussian {Wariant rosyjski obrony Grünfelda}
translate P Catalan {Partia katalońska}
translate P CatalanOpen {Wariant otwarty partii katalońskiej}
translate P CatalanClosed {Wariant zamknięty partii katalońskiej}
translate P QueensIndian {Obrona hetmańsko-indyjska}
translate P NimzoIndian {Obrona Nimzowitscha}
translate P NimzoIndianClassical {Wariant klasyczny obrony Nimzowitscha}
translate P NimzoIndianRubinstein {Wariant Rubinsteina obrony Nimzowitscha}
translate P KingsIndian {Obrona królewsko-indyjska}
translate P KingsIndianSamisch {Wariant Sämischa obrony królewsko-indyjskiej}
translate P KingsIndianMainLine {Główny wariant obrony królewsko-indyjskiej}

# FICS
translate P ConfigureFics {Konfiguracja FICS}
translate P FICSGuest {Zaloguj jako gość}
translate P FICSServerPort {Port serwera}
translate P FICSServerAddress {Adres IP}
translate P FICSRefresh {Odśwież}
translate P FICSTimesealPort {Port Timeseal}
translate P FICSSilence {Filtr konsoli}
translate P FICSOffers {Oferty}
translate P FICSConsole {Konsola}
translate P FICSGames {Partie}
translate P FICSUnobserve {Zakończ obserwowanie partii}
translate P FICSProfile {Wyświetl historię i profil}
translate P FICSRelayedGames {Partie przekazywane}
translate P FICSFindOpponent {Znajdź przeciwnika}
translate P FICSTakeback {Cofnij posunięcie}
translate P FICSTakeback2 {Cofnij dwa posunięcia}
translate P FICSInitTime {Czas początkowy (min)}
translate P FICSIncrement {Dodatek (sek)}
translate P FICSRatedGame {Partia rankingowa}
translate P FICSAutoColour {automatycznie}
translate P FICSManualConfirm {potwierdź ręcznie}
translate P FICSFilterFormula {Filtruj według formuły}
translate P FICSIssueSeek {Wyślij zaproszenie do gry}
translate P FICSChallenge {Wyzwanie}
translate P FICSAccept {Czy akceptujesz?}
translate P FICSDecline {Odrzuć}
translate P FICSColour {Kolor}
translate P FICSSend {Wyślij}
translate P FICSConnect {Połącz}
translate P FICSdefaultuservars {Użyj domyślnych zmiennych}
translate P FICSObserveconfirm {Czy chcesz obserwować partię?}
translate P FICSpremove {Włącz ruch wyprzedzający}
translate P FICSObserve {Obserwuj}
translate P FICSRatedGames {Partie rankingowe}
translate P FICSUnratedGames {Partie nierankingowe}
translate P FICSRated {Rankingowa}
translate P FICSUnrated {Nierankingowa}
translate P FICSRegisteredPlayer {Tylko zarejestrowani gracze}
translate P FICSFreePlayer {Tylko gracze niezarejestrowani}
translate P FICSNetError {Błąd sieci\nNie można połączyć się z }
translate P OptionsFICS {FICS}
translate P FICSTerminalColor {Kolor terminala}
translate P FICSTextColor {Kolor tekstu}

# Game review
translate P GameReview {Analiza partii}

# Correspondence Chess Dialogs:
translate P CCDlgCGeneraloptions {Opcje ogólne}
translate P CCDlgLoginName  {Login:}
translate P CCDlgPassword   {Hasło:}
translate P CCDlgShowPassword {Pokaż hasło}

# Connect Hardware dialogs
translate P ExtHWConfigConnection {Konfiguracja urządzenia zewnętrznego}
translate P ExtHWPort {Port}
translate P ExtHWEngineCmd {Polecenie silnika}
translate P ExtHWEngineParam {Parametr silnika}
translate P ExtHWShowButton {Pokaż przycisk}
translate P ExtHWHardware {Urządzenie}
translate P ExtHWNovag {Novag Citrine}
translate P ExtHWInputEngine {Silnik wejściowy}
translate P ExtHWNoBoard {Brak szachownicy}
translate P NovagReferee {Sędzia}

# Input Engine dialogs
translate P IEConsole {Konsola silnika wejściowego}
translate P IESending {Posunięcia wysłane do}
translate P IESynchronise {Synchronizuj}
translate P IERotate  {Obróć}
translate P IEUnableToStart {Nie można uruchomić silnika wejściowego:}

translate P Board {Szachownica}
translate P showGameInfo {Pokaż informacje o partii}
translate P autoResizeBoard {Automatycznie zmieniaj rozmiar szachownicy}
translate P DockTop {Przenieś na górę}
translate P DockBottom {Przenieś na dół}
translate P DockLeft {Przenieś w lewo}
translate P DockRight {Przenieś w prawo}
translate P Undock {Odłącz}
translate P Dock {Zadokuj}

# Switcher window
translate P AboutDatabase {Informacje o bazie danych}
translate P ChangeIcon {Wybierz ikonę bazy danych...}
translate P NewGameListWindow {Nowe okno listy partii}
translate P LoadatStartup {Wczytaj przy uruchomieniu}

# Gamelist window
translate P ShowHideDB {Pokaż/ukryj bazy danych}
translate P ChangeFilter {Zmień filtr}
translate P ChangeLayout {Wczytaj, zapisz lub zmień kryteria sortowania i układ kolumn}
translate P ShowHideStatistic {Pokaż/ukryj statystyki}
translate P BoardFilter {Pokaż tylko partie pasujące do bieżącej pozycji}
translate P CopyGameTo {Kopiuj partię do}
translate P FindBar {Pasek wyszukiwania}
translate P FindCurrentGame {Znajdź bieżącą partię}
translate P DeleteGame {Usuń partię}
translate P UndeleteGame {Przywróć partię}
translate P ResetSort {Zresetuj sortowanie}
translate P LayoutExists {Układ '%s' już istnieje.}
translate P ConfirmDeleteLayout {Czy na pewno chcesz usunąć układ '%s'?}
translate P ConfirmStripGames {Usunąć adnotacje z %d wybranych partii?}

translate P ConvertNullMove {Zamień posunięcia zerowe na komentarze}
translate P SetupBoard {Ustaw pozycję}
translate P Rotate {Obróć}
translate P SwitchColors {Zamień kolory}
translate P FlipBoard {Odwróć szachownicę}
translate P Board3D {Szachownica 3D}
translate P Board3DReset {Przywróć ustawienia}
translate P Board3DResetTip {Przywróć domyślne ustawienie kamery}
translate P Board3DZoomIn {Przybliż}
translate P Board3DZoomOut {Oddal}
translate P Board3DDragToRotate {Przeciągnij, aby obrócić}
translate P Board3DScrollToZoom {Przewijaj, aby przybliżać lub oddalać}
translate P ImportPGN {Importuj partię PGN}
translate P ImportingFiles {Importowanie plików PGN w}
translate P ImportingFrom {Importowanie z}
translate P ImportingIn {Importowanie partii do}
translate P UseLastTag {Użyj znaczników\nostatniej partii}
translate P Random {Losowo}
translate P BackToMainline {Wróć do wariantu głównego}
translate P LeaveVariant {Opuść wariant}
translate P Autoplay {Odtwarzaj automatycznie}
translate P ShowHideCoords {Pokaż/ukryj współrzędne}
translate P ShowHideEvalBar {Pokaż/ukryj pasek oceny}
translate P ShowHideMaterial {Pokaż/ukryj materiał}
translate P SelectMarker {Wybierz znacznik}
translate P FullScreen {Pełny ekran}
translate P FilterStatistic {Statystyki filtra}
translate P MakeCorrections {Wprowadź poprawki}
translate P Surnames {Nazwiska}
translate P Ambiguous {Niejednoznaczne}

#Preferences Dialog
translate P OptionsToolbar "Pasek narzędzi"
translate P OptionsBoard "Szachownica"
translate P OptionsBoardSize "Rozmiar szachownicy"
translate P OptionsBoardPieces "Styl figur"
translate P OptionsInternationalization "Ustawienia językowe"
translate P OptionsTablebaseDir "Wybierz maksymalnie 4 katalogi z bazami końcówek:"

# Evaluation bar
translate P BestMoveArrow "Strzałka najlepszego posunięcia"
translate P NewLocalEngine "+ Nowy silnik ..."

# Batch Annotate
translate P BatchAnnotate {Adnotacja zbiorcza}
translate P BatchEngineSelection {Wybór silnika}
translate P BatchChessEngine {Silnik szachowy:}
translate P BatchNumberOfInstances {Liczba instancji:}
translate P BatchTimePerMove {Czas na posunięcie (sek):}
translate P BatchAnnotateBlunders {Adnotuj tylko poważne błędy}
translate P BatchBlunderThreshold {Próg poważnego błędu:}
translate P BatchVariationLength {Długość wariantu (posunięcia):}
translate P BatchOpeningBook {Książka debiutowa}
translate P BatchUseBook {Użyj książki debiutowej}
translate P BatchAnnotateVariations {Adnotuj warianty}
translate P BatchShortAnnotations {Krótkie adnotacje}
translate P BatchAddScoreToShort {Dodaj ocenę do krótkich adnotacji}
translate P BatchClearOld {Usuń stare komentarze i warianty}
translate P BatchInitializingEngines {Inicjowanie silników...}
translate P BatchAnalyzingGames {Analizowanie partii...}
translate P BatchProgress {Postęp adnotacji zbiorczej}
translate P BatchComplete {Adnotacja zbiorcza zakończona!}
translate P BatchCancelled {Anulowano adnotację zbiorczą}
translate P BatchStart {Rozpocznij}
translate P BatchCancel {Anuluj}
translate P BatchCompleted {zakończono}
translate P BatchGames {partii}
translate P BatchProcessed {przetworzono}
translate P BatchUnscoredPlies {półposunięcia bez oceny: %s}
translate P TablebaseWindow {Okno baz końcówek}
translate P TBWinMoves {--- Posunięcia wygrywające ---}
translate P TBDrawMoves {--- Posunięcia remisujące ---}
translate P TBLossMoves {--- Posunięcia przegrywające ---}
translate P TBNoMoves {Nie znaleziono dozwolonych posunięć.}
translate P TBTooMany {Za dużo figur. Baza końcówek Lichess obsługuje pozycje z maksymalnie 7 figurami.}
translate P TBQuerying {Wysyłanie zapytania do API Lichess...}
translate P TBError {Błąd uruchamiania curl podczas wysyłania zapytania do Lichess.}
translate P TBQueryError {Nieprawidłowa odpowiedź API bazy końcówek.}
translate P TBNotFound {Nie znaleziono pozycji w bazie końcówek lub wystąpił błąd API.}
translate P TBCategory {Kategoria pozycji:}
translate P TBTrainingHidden {(Tryb treningowy; wyniki są ukryte)}

# ICCF (International Correspondence Chess Federation)
menuText P ToolsTrainICCF "Graj na ICCF" 0 {Graj na ICCF}
translate P ICCFTitle {Gra na ICCF}
translate P ICCFLogin {Nazwa użytkownika}
translate P ICCFPassword {Hasło}
translate P ICCFConnect {Połącz}
translate P ICCFClose {Zamknij}
translate P ICCFUpdateGames {Aktualizuj partie}
translate P ICCFSendMoves {Wyślij posunięcia}
translate P ICCFYourMessage {Twoja wiadomość}
translate P ICCFGameID {Partia}
translate P ICCFOpponent {Przeciwnik}
translate P ICCFEvent {Turniej}
translate P ICCFLastMove {Ostatnie posunięcie}
translate P ICCFSent {Wysłano}
translate P ICCFYourMove {Twoje posunięcie}
translate P ICCFOfferDraw {Zaproponuj remis}
translate P ICCFResign {Poddaj partię}
translate P ICCFWaiting {Oczekiwanie}
translate P ICCFYourTurn {Twoja kolej}
translate P ICCFCredentialsNeeded {Wpisz nazwę użytkownika i hasło do ICCF.}
translate P ICCFUpdating {Pobieranie partii z serwera ICCF...}
translate P ICCFGamesUpdated {Partie: dodano %s, zaktualizowano %s posunięć, %s aktualnych}
translate P ICCFSendingMoves {Wysyłanie posunięć do serwera ICCF...}
translate P ICCFMovesSent {Wysłane posunięcia: %s pomyślnie, %s nie powiodło się}
translate P ICCFNoGamesFound {Nie znaleziono partii.}
translate P ICCFFilterError {Błąd filtra.}
translate P ICCFConnectionFailed {Nie udało się połączyć z serwerem ICCF. Sprawdź połączenie z siecią.}
translate P ICCFAuthFailed {Uwierzytelnianie nie powiodło się. Sprawdź nazwę użytkownika i hasło.}
translate P ICCFNeedUpdate {Najpierw kliknij „Aktualizuj partie”, aby pobrać bieżące dane partii z serwera.}
translate P ICCFNoDatabase {Nie otwarto żadnej bazy danych. Najpierw otwórz bazę.}
translate P ICCFMyTime {Mój zegar}
translate P ICCFOppTime {Zegar przeciwnika}
translate P ICCFDrawOffered {Zaproponowano remis}
# LSS (Lechenicher SchachServer)
menuText P ToolsTrainLSS "Graj na LSS" 0 {Graj na Lechenicher SchachServer}
translate P LSSTitle {Graj na LSS — Lechenicher SchachServer}
translate P LSSConfigure {Konfiguracja LSS}
translate P LSSServer {Serwer LSS}
translate P LSSLogin {Nazwa użytkownika}
translate P LSSPassword {Hasło}
translate P LSSConnect {Połącz}
translate P LSSClose {Zamknij}
translate P LSSUpdateGames {Aktualizuj partie}
translate P LSSSendMoves {Wyślij posunięcia}
translate P LSSGamesList {Lista partii}
translate P LSSOpponentMessage {Wiadomość od przeciwnika}
translate P LSSYourMessage {Twoja wiadomość}
translate P LSSGameID {Partia}
translate P LSSOpponent {Przeciwnik}
translate P LSSTime {Czas}
translate P LSSWhiteElo {Ranking białych}
translate P LSSBlackElo {Ranking czarnych}
translate P LSSEvent {Turniej}
translate P LSSLastMove {Ostatnie posunięcie}
translate P LSSSent {Wysłano}
translate P LSSYourMove {Twoje posunięcie}
translate P LSSOfferDraw {Zaproponuj remis}
translate P LSSResign {Poddaj partię}
translate P LSSWaiting {Oczekiwanie}
translate P LSSYourTurn {Twoja kolej}
translate P LSSCredentialsNeeded {Wpisz nazwę użytkownika i hasło do LSS.}
translate P LSSUpdating {Pobieranie partii z serwera LSS...}
translate P LSSGamesUpdated {Partie: dodano %s, zaktualizowano %s posunięć, %s aktualnych}
translate P LSSSendingMoves {Wysyłanie posunięć do serwera LSS...}
translate P LSSMovesSent {Wysłane posunięcia: %s pomyślnie, %s nie powiodło się}
translate P LSSNoGamesFound {Nie znaleziono partii.}
translate P LSSFilterError {Błąd filtra.}
translate P LSSConnectionFailed {Nie udało się połączyć z serwerem LSS. Sprawdź połączenie z siecią.}
translate P LSSAuthFailed {Uwierzytelnianie nie powiodło się. Sprawdź nazwę użytkownika i hasło.}
translate P LSSNeedUpdate {Najpierw kliknij „Aktualizuj partie”, aby pobrać bieżące dane partii z serwera.}
translate P LSSNoDatabase {Nie otwarto żadnej bazy danych. Najpierw otwórz bazę.}
translate P LSSGameNumber {LSS}
translate P LSSMyTime {Mój zegar}
translate P LSSOppTime {Zegar przeciwnika}
translate P LSSDrawOffered {Zaproponowano remis}

# RTF Export and Import
translate P RtfExportTitle {Eksport do pliku RTF}
translate P RtfExportError {Błąd eksportu do formatu RTF}
translate P RtfImportTitle {Import pliku RTF}
translate P RtfImportError {Błąd importu pliku RTF}
translate P RtfNotScidFile {Ten plik nie został wyeksportowany przez scidCommunity z zachowaniem formatowania komentarzy lub jest uszkodzony.}
translate P RtfImportSuccess {Pomyślnie zaimportowano partię do schowka.}
translate P RtfImportSuccessMulti {Pomyślnie zaimportowano %d partii do schowka.}
}
# end of english.tcl

# Review progress pane (#422 item 3).
translate P ReviewProgressTitle {Postęp analizy}
translate P ReviewProgressIdle {Analiza nie jest uruchomiona}
translate P ReviewProgressGameOf {partia %s z %s}
translate P ReviewProgressEngineWindow {Okno silnika %s}
translate P ReviewProgressAnalysisPane {Panel analizy %s}
translate P ReviewProgressRapid {Szybka adnotacja}
translate P FinishGameGameChanged {partia zmieniła się podczas działania funkcji „Zakończ partię”; nic nie zostało zapisane}
translate P FinishGameAtEnd {Funkcja „Zakończ partię” rozpoczyna działanie od końca głównej linii. Najpierw przejdź na koniec partii}


############################################################
#
# Polish tip of the day
# Aktualizacja tip of the day ScidCommunity v.5.1.4.48  by Szustan 

set tips(P) {
  {
    scidCommunity zawiera ponad 40 <a Index>stron pomocy</a>. W większości okien
    programu scidCommunity naciśnięcie klawisza <b>F1</b> wyświetli stronę pomocy dotyczącą
	danego okna.
  }
  {
    Niektóre okna programu scidCommunity (np. obszar informacji o partii, 
    <a Switcher>przełącznik baz danych</a>) mają menu kontekstowe dostępne
    po kliknięciu prawym przyciskiem myszy. Kliknij prawym przyciskiem myszy
    w różnych oknach, aby sprawdzić, czy mają takie menu i jakie funkcje są w nim dostępne.
  }
  {
    Program scidCommunity umożliwia wprowadzanie posunięć szachowych na kilka sposobów, 
    dzięki czemu możesz wybrać ten, który najbardziej ci odpowiada. Możesz używać myszy
    (z podpowiadaniem posunięć lub bez niego) albo klawiatury 
    (z automatycznym uzupełnianiem posunięć lub bez niego). Szczegóły znajdziesz na stronie pomocy 
    <a Moves>wprowadzanie posunięć szachowych</a>.
  }
  {
    Jeśli często otwierasz kilka baz danych, dodaj do każdej z nich
    <a Bookmarks>zakładkę</a>. Dzięki temu będziesz mógł szybciej
    otwierać te bazy za pomocą menu zakładek.
  }
  {
    Możesz śledzić na żywo przebieg najważniejszych turniejów szachowych, korzystając z funkcji <b>Otwórz turniej Lichess</b> w menu <b>Plik</b>.Program scidCommunity będzie automatycznie śledził i aktualizował partie rozgrywane na żywo.
  }
  {
    Wszystkie posunięcia bieżącej partii (wraz z wariantami i komentarzami)
    możesz zobaczyć w <a PGN>oknie PGN</a>.
    W tym oknie możesz przejść do dowolnego posunięcia, klikając je
    lewym przyciskiem myszy. Środkowy lub prawy przycisk myszy pozwala
    wyświetlić podgląd danej pozycji.
  }
  {
    Możesz kopiować partie między bazami danych, przeciągając je
    lewym przyciskiem myszy w oknie <a Switcher>przełącznika baz danych</a>.
  }
  {
    scidCommunity może otwierać pliki PGN, nawet jeśli są skompresowane
    za pomocą Gzip (z rozszerzeniem .gz). Pliki PGN są otwierane tylko do odczytu.
    Jeśli chcesz edytować plik PGN w programie scidCommunity, utwórz nową bazę danych
    scidCommunity i skopiuj do niej partie z pliku PGN za pomocą okna
    <a Switcher>przełącznika baz danych</a>.
  }
  {
    Okno <a Tree>drzewa wariantów</a> pokazuje wszystkie posunięcia wykonane
    z bieżącej pozycji. Jeśli chcesz zobaczyć również wszystkie kolejności
    posunięć, które doprowadziły do tej pozycji, wygeneruj
    <a Reports Opening>raport debiutowy</a>.
  }
  {
    Aby szybko zaimportować własne partie z serwisów internetowych, wybierz w menu <b>Plik</b> opcję <b>Importuj moje partie z Lichess</b> lub <b>Importuj moje partie z chess.com</b>. Wystarczy wpisać nazwę użytkownika i datę początkową, aby pobrać partie wraz z pełnymi danymi.
  }
  {
    W oknie <a GameList>listy partii</a> kliknij lewym lub prawym przyciskiem
    myszy nagłówek kolumny, aby zmienić jej szerokość.
  }
  {
    Za pomocą okna <a PInfo>informacji o graczu</a> (otworzysz je, klikając
    nazwisko jednego z graczy w obszarze informacji o partii pod główną szachownicą)
    możesz łatwo ustawić <a Searches Filter>filtr</a>, aby zawierał wszystkie
    partie danego gracza z określonym wynikiem. Wystarczy kliknąć dowolną wartość
    wyświetloną <red>czerwonym tekstem</red>.
  }
  {
    Podczas nauki debiutu warto wykonać <a Searches Board>wyszukiwanie
	wg pozycji</a> z opcją <b>Piony</b> lub <b>Kolumny</b> dla ważnej
	pozycji debiutowej. Może to ujawnić inne debiuty prowadzące do takiej 
	samej struktury pionowej.
  }
  {
    W oknie informacji o partii (pod szachownicą) kliknij prawym
    przyciskiem myszy, aby otworzyć menu ustawień. Możesz na przykład
    ukryć następne posunięcie, co przydaje się podczas treningu polegającego
    na odtwarzaniu partii i odgadywaniu kolejnych posunięć.
  }
  {
    Jeśli często wykonujesz wiele czynności związanych z <a Maintenance>porządkowaniem bazy danych</a>,
    możesz przeprowadzić kilka z nich jednocześnie za pomocą funkcji
    <a Maintenance Cleaner>Porządkowanie</a>.
  }
  {
    Okno <a PGN>PGN</a> zawiera przyciski szybkiego dostępu, które umożliwiają  przesłanie bieżącej partii do serwisu <b>Lichess.org</b> lub <b>Chess.com</b>. Dzięki temu możesz od razu korzystać z zaawansowanej analizy silnikowej  w chmurze oraz funkcji udostępniania partii.
  }
  {
    Jeśli masz dużą bazę danych, w której większość partii ma określoną datę
    turnieju (EventDate), i chcesz uporządkować partie chronologicznie,
    rozważ <a Sorting>sortowanie</a> według pól EventDate, a następnie Event,
    zamiast Date i Event. Dzięki temu partie z tego samego turnieju, rozgrywane
    w różne dni, będą wyświetlane razem (oczywiście pod warunkiem, że mają tę samą datę turnieju).
  }
  {
    Przed <a Maintenance Twins>usunięciem duplikatów partii</a> warto
    <a Maintenance Spellcheck>sprawdzić pisownię</a> w bazie danych.
    Dzięki temu scidCommunity będzie mógł znaleźć więcej duplikatów i oznaczyć je do usunięcia.
  }
  {
    <a Flags>Flagi</a> ułatwiają oznaczanie partii w bazie według cech,
    które mogą przydać się podczas późniejszego wyszukiwania, takich jak
    struktura pionowa, motywy taktyczne itp. Partie oznaczone flagami
    można wyszukiwać za pomocą <a Searches Header>wyszukiwania wg nagłówka</a>.
  }
  {
    Aby znaleźć najważniejsze partie (z udziałem wysoko notowanych przeciwników),
    w których wystąpiła określona pozycja, otwórz okno <a Tree>drzewa wariantów</a>,
    a następnie wyświetl listę najlepszych partii. Możesz też ograniczyć tę listę
    do partii zakończonych określonym wynikiem.
  }
  {
    Użyj przycisku <b>Otwórz bieżącą pozycję w ChessDB</b> w <a PGN>oknie PGN</a>, aby skorzystać z baz danych w chmurze serwisu <b>ChessDB.cn</b>. Zawiera ona miliardy wcześniej przeanalizowanych pozycji i ocen silnikowych dla niemal każdego debiutu.
  }
  {
    Dobrym sposobem na naukę debiutu z wykorzystaniem dużej bazy partii
    jest włączenie trybu treningowego w oknie <a Tree>drzewa wariantów</a>,
    a następnie rozgrywanie partii z bazą, aby sprawdzić, które warianty są najczęściej spotykane.
  }
  {
    Jeśli masz otwarte dwie bazy danych i chcesz wyświetlać statystyki
    <a Tree>drzewa wariantów</a> z pierwszej bazy podczas przeglądania
    partii z drugiej, kliknij przycisk <b>Zablokuj</b> w oknie drzewa wariantów,
    aby przypisać je do pierwszej bazy, a następnie przełącz się
	na drugą bazę.
  }
  {
    <a Tmt>wyszukiwarka turniejów</a> służy nie tylko do znajdowania konkretnych
	turniejów. Można jej również użyć, aby sprawdzić, w jakich turniejach dany
	gracz ostatnio uczestniczył, lub przejrzeć najważniejsze turnieje rozgrywane
	w wybranym kraju.
  }
  {
    W oknie wyszukiwania <a Searches Material>Materiał/Wzorce</a>
    zdefiniowano wiele typowych układów, które mogą być przydatne
    podczas nauki debiutów i gry środkowej.
  }
  {
    Podczas wyszukiwania określonego układu bierek w oknie
    <a Searches Material>Materiał/Wzorce</a> warto często ograniczyć
    wyniki do partii, w których dany układ występował przez co najmniej
    kilka półposunięć. Pozwala to wyeliminować partie, w których pojawił się
    on tylko na krótko.
  }
  {
    Jeśli w partii dojdziesz do końcówki z 7 lub mniejszą liczbą bierek, kliknij przycisk <b>Sprawdź pozycję w bazie koncówek Lichess</b> w <a PGN>oknie PGN</a>, aby uzyskać dokładną analizę z baz końcówek Lichess.
  }
  {
    Jeśli masz ważną bazę danych, której nie chcesz przypadkowo zmodyfikować,
    po jej otwarciu wybierz z menu <b>Plik</b> opcję <b>Tylko do odczytu...</b>
    lub zmień uprawnienia pliku, aby był dostępny tylko do odczytu.
  }
  {
    Jeśli używasz programu XBoard lub WinBoard (albo innego programu szachowego,
    który potrafi skopiować bieżącą pozycję w standardowym formacie FEN do schowka)
    i chcesz przenieść ją do scidCommunity, najłatwiej i najszybciej wybierz
    w programie XBoard/WinBoard opcję <b>Kopiuj pozycję</b> z menu <b>Plik</b>,
    a następnie w scidCommunity opcję <b>Wklej pozycję jako FEN</b>
    z menu <b>Edycja</b>.
  }
  {
    Wyszukiwanie wg <a Searches Header>nagłówka</a> nie rozróżnia wielkości liter
	i znajduje wpisane nazwy graczy, turniejów, miejsc i rund niezależnie od ich
	położenia w tekście. Możesz też wybrać wyszukiwanie z uwzględnieniem wielkości liter
	i symboli wieloznacznych (gdzie "?" oznacza dowolny pojedynczy znak, a "*" — zero lub
	więcej znaków), wpisując tekst wyszukiwania	w cudzysłowie. Na przykład wpisz
	"*BEL" (razem z cudzysłowami) w polu miejsca, aby znaleźć wszystkie partie
	rozegrane w Belgii, ale nie w Belgradzie.
  }
  {
    Jeśli chcesz poprawić posunięcie w partii bez utraty kolejnych posunięć,
    otwórz okno <b>Wklej tekst ze schowka...</b> w menu <b>Edycja</b>, naciśnij przycisk
    <b>Wklej bieżącą partię</b>, popraw błędne posunięcie, a następnie
    naciśnij <a Import>Importuj</a>.
  }
  {
    Jeśli masz wczytany plik klasyfikacji ECO, możesz przejść do
    najgłębszej sklasyfikowanej pozycji w bieżącej partii, wybierając
    z menu <b>Partia</b> opcję <b>Rozpoznaj debiut</b>
    (skrót: Ctrl+Shift+D).
  }
  {
    Bądź na bieżąco z najnowszymi partiami z całego świata. Wybierz z menu <b>Narzędzia</b> opcję <b>Pobierz partie TWIC</b>. Program automatycznie pobierze i otworzy najnowszy cotygodniowy plik PGN z serwisu <b>The Week In Chess</b>.
  }
  {
    Jeśli przed otwarciem pliku chcesz sprawdzić jego rozmiar lub datę
    ostatniej modyfikacji, użyj <a Finder>wyszukiwarki plików</a>.
  }
  {
    <a Reports Opening>Raport debiutowy</a> to przydatne narzędzie do poznawania
    określonej pozycji. Możesz sprawdzić, jak często prowadzi ona do wygranej,
    czy często kończy się krótkimi remisami oraz jakie typowe motywy pozycyjne w niej występują.
  }
  {
    Najczęstsze symbole oceny posunięć (!, !?, += itp.) możesz dodawać
    do bieżącego posunięcia lub pozycji za pomocą skrótów klawiaturowych,
    bez otwierania <a Comment>edytora komentarzy</a>. Na przykład wpisz
    „!” i naciśnij Enter, aby dodać symbol „!”. Więcej informacji
    znajdziesz na stronie pomocy <a Moves>Wprowadzanie posunięć szachowych</a>.
  }
  {
    Przeglądając debiuty w bazie danych za pomocą <a Tree>drzewa wariantów</a>,
    możesz sprawdzić, jakie wyniki przynosi dany debiut w ostatnim czasie
    oraz w partiach graczy z wysokim rankingiem. W tym celu otwórz okno
    statystyk (skrót: Ctrl+I).
  }
  {
    Po wykonaniu <a Searches>wyszukiwania</a> możesz łatwo przeglądać
    wszystkie znalezione partie. Przytrzymaj klawisz <b>Ctrl</b>
    i naciskaj <b>strzałkę w górę</b> lub <b>strzałkę w dół</b>,
    aby wczytać poprzednią lub następną partię z <a Searches Filter>listy wyników wyszukiwania</a>.
  }
  {
    Okna można dokować, zaznaczając odpowiednią opcję w menu.
    Karty można przeciągać między panelami, a ich układ zmieniać
    za pomocą prawego przycisku myszy.
  }
}
