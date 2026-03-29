# czech.tcl: Czech menus and help for Scid.
# Contributed by Pavel Hanák, Vlastimil Babula and Milan Zamazal.
# Untranslated messages are marked with a "***" comment.

proc setLanguage_C {} {

# File menu:
menuText C File "Soubor" 0
menuText C FileNew "Nový..." 0 {Vytvoøit novou Scid databázi}
menuText C FileOpen "Otevøít..." 0 {Otevøít existující Scid databázi}
menuText C FileClose "Zavøít" 0 {Zavøít aktivní Scid databázi}
menuText C FileFinder "Vyhledávaè" 2 {Otevøít okno vyhledávaèe souborù}
menuText C FileBookmarks "Zálo¾ky" 2 {Menu zálo¾ek (klávesa: Ctrl+B)}
menuText C FileBookmarksAdd "Pøidat zálo¾ku" 0 \
  {Zálo¾ka aktuální pozice a partie z databáze}
menuText C FileBookmarksFile "Zaøadit zálo¾ku" 0 \
  {Zaøadit zálo¾ku pro aktuální partii a pozici}
menuText C FileBookmarksEdit "Editovat zálo¾ky..." 0 \
  {Editovat menu zálo¾ek}
menuText C FileBookmarksList "Zobrazit slo¾ky jako jediný seznam" 0 \
  {Zobrazit slo¾ky se zálo¾kami jako jediný seznam, bez podnabídek}
menuText C FileBookmarksSub "Zobrazit slo¾ky jako podnabídky" 9 \
  {Zobrazit zálo¾kové slo¾ky jako podnabídky, ne jako jediný seznam}
menuText C FileMaint "Údr¾ba" 2 {Nástroje pro údr¾bu databáze Scidu}
menuText C FileMaintWin "Okno údr¾by" 0 \
  {Otevøít/zavøít okno pro údr¾bu Scid databáze}
menuText C FileMaintCompact "Zhutnìní databáze..." 13 \
  {Zhutnìní databázových souborù, odstranìní vymazaných partií a nepou¾ívaných jmen}
menuText C FileMaintClass "ECO klasifikace partií..." 0 \
  {Pøepoèítání ECO kódù v¹ech partií}
menuText C FileMaintSort "Setøídit databázi..." 0 \
  {Setøídit v¹echny partie v databázi}
menuText C FileMaintDelete "Vymazání zdvojených partií..." 0 \
  {Hledat zdvojené partie a oznaèit je pro vymazání}
menuText C FileMaintTwin "Kontrola zdvojených partií" 0 \
  {Otevøít/aktualizovat okno pro kontrolu zdvojených partií}
menuText C FileMaintName "Jména" 0 {Editace jmen a kontrola pravopisu}
menuText C FileMaintNameEditor "Editor jmen" 0 \
  {Otevøít/zavøít editor jmen}
menuText C FileMaintNamePlayer "Kontrola pravopisu hráèù..." 19 \
  {Kontrola pravopisu jmen hráèù s vyu¾itím souboru pro kontrolu pravopisu}
menuText C FileMaintNameEvent "Kontrola pravopisu turnajù..." 19 \
  {Kontrola pravopisu názvù turnajù s vyu¾itím souboru pro kontrolu pravopisu}
menuText C FileMaintNameSite "Kontrola pravopisu míst..." 19 \
  {Kontrola pravopisu míst turnajù s vyu¾itím souboru pro kontrolu pravopisu}
menuText C FileMaintNameRound "Kontrola pravopisu kol..." 19 \
  {Kontrola pravopisu kol s vyu¾itím souboru pro kontrolu pravopisu}
menuText C FileReadOnly "Pouze pro ètení..." 0 \
  {Nastavit aktuální databázi jako jen ke ètení, a zabránit tak zmìnám}
menuText C FileSwitch "Pøepnout se do databáze" 15 \
  {Pøepnout se do jiné otevøené databáze}
menuText C FileOpenLichessTournament "Otevøený lichessový turnaj" 0 {Stáhnìte si a otevøete ¾ivé vysílané hry turnaje Lichess}
menuText C FileImportLichess "Importujte mùj Lichess" 0 {Importujte hry ze svého úètu Lichess}
menuText C FileImportChessCom "Importovat mùj chess.com" 0 {Importujte hry ze svého úètu chess.com}
menuText C FileExit "Ukonèit" 0 {Ukonèit Scid}
menuText C FileMaintFixBase "Opravit po¹kozenou databázi" 0 {Pokusit se opravit po¹kozenou databázi}

# Edit menu:
menuText C Edit "Editace" 0
menuText C EditAdd "Pøidat variantu" 0 {Pøidat variantu k tomuto tahu v partii}
menuText C EditDelete "Vymazat variantu" 0 {Vymazat variantu k tomuto tahu}
menuText C EditFirst "Zaøadit jako první variantu" 0 \
  {Zaøadit variantu na první místo v seznamu variant}
menuText C EditMain "Pový¹it stávající variantu na hlavní" 30 \
  {Pový¹it stávající variantu na hlavní variantu}
menuText C EditTrial "Zkusit variantu" 1 \
    {Spustit/Ukonèit zku¹ební mód pro testování my¹lenky na ¹achovnici}
menuText C EditStrip "Odstranit" 0 {Odstranit komentáøe nebo varianty z této partie}
menuText C EditUndo "Vzít zpìt" 0 {Vzít zpìt poslední zmìnu v partii}
menuText C EditRedo "Pøedìlat" 0 {Opakujte poslední zmìnu hry}
menuText C EditStripComments "Komentáøe" 0 \
  {Odstranit v¹echny poznámky a anotace z této partie}
menuText C EditStripVars "Varianty" 0 {Odstranit v¹echny varianty z této partie}
menuText C EditStripBegin "Tahy ze zaèátku" 5 \
  {Odstranit tahy ze zaèátku partie}
menuText C EditStripEnd "Tahy do konce" 5 \
  {Odstranit tahy do konce partie}
menuText C EditReset "Vyprázdnit schránku" 11 \
  {Kompletní vyprázdnìní databáze schránka}
menuText C EditCopy "Zkopírovat tuto partii do schránky" 23 \
  {Zkopírovat tuto partií do databáze schránka}
menuText C EditPaste "Vlo¾it poslední partii ze schránky" 24 \
  {Vlo¾it aktivní partii z databáze schránka}
menuText C EditPastePGN "Vlo¾it text ze schránky jako PGN..." 10 \
  {Interpretovat text schránky jako partii v PGN notaci a vlo¾it ji sem}
menuText C EditSetup "Nastavit výchozí pozici..." 0 \
  {Nastavit výchozí pozici pro tuto partii}
menuText C EditCopyBoard "Kopírovat pozici" 4 \
  {Kopírovat aktuální pozici ve FEN notaci do textového výbìru (do clipboardu)}
menuText C EditPasteBoard "Vlo¾it poèáteèní pozici" 1 \
  {Nastavit poèáteèní pozici z aktuálního textového výbìru (z clipboardu)}
menuText C ConfigureScid "Pøedvolby..." 0 {Nakonfigurujte v¹echny mo¾nosti pro SCID}

# Game menu:
menuText C Game "Partie" 0
menuText C GameNew "Nová partie" 0 \
  {Nastavit novou partii, v¹echny provedené zmìny budou ztraceny}
menuText C GameFirst "Natáhnout první partii" 10 {Natáhnout první partii z filtrovaných partií}
menuText C GamePrev "Natáhnout pøedchozí partii" 13 {Natáhnout pøedchozí partii z filtrovaných partií}
menuText C GameReload "Znovunatáhnout aktuální partii" 0 \
  {Znovunata¾ení aktuální partie, v¹echny doposud provedené zmìny budou ztraceny}
menuText C GameNext "Natáhnout následující partii" 14 {Natáhnout následující partii z filtrovaných partií}
menuText C GameLast "Natáhnout poslední partii" 11 {Natáhnout poslední partii z filtrovaných partií}
menuText C GameRandom "Natáhnout partii náhodnì" 1 {Natáhnout náhodnì vybranou partii z filtru}
menuText C GameNumber "Natáhnout partii èíslo..." 19 \
  {Natáhnout partii èíslo...}
menuText C GameReplace "Ulo¾it: pøepsání partie..." 0 \
  {Ulo¾it tuto partii - pøepí¹e pùvodní verzi}
menuText C GameAdd "Ulo¾it: pøidání nové partie..." 1 \
  {Ulo¾it tuto partii jako novou partii v databázi}
menuText C GameDeepest "Identifikace zahájení" 0 \
  {Pøejít na koncovou pozici z ECO knihovny, která odpovídá zvolenému zahájení}
menuText C GameGotoMove "Pøejít na tah èíslo..." 10 \
  {Pøejít v aktuální partii do pozice udané èíslem tahu}
menuText C GameNovelty "Hledat novinku..." 0 \
  {Hledat první tah této partie, který doposud nebyl hrán}

# Search Menu:
menuText C Search "Hledat" 0
menuText C SearchReset "Vyèistit filtr" 0 {Vyèistit filtr - vybrány budou v¹echny partie}
menuText C SearchNegate "Negace filtru" 0 {Negace filtru -  vybrány budou pouze partie vyòaté pøedcházejícím filtrem}
menuText C SearchCurrent "Aktuální pozice..." 0 {Hledat aktuální pozici}
menuText C SearchHeader "Hlavièka..." 0 {Hledat podle hlavièky partie (hráè, turnaj apod.)}
menuText C SearchMaterial "Materiál/Vzor..." 0 {Hledat podle materiálu nebo podle vzoru}
menuText C SearchUsing "Hledat pomocí souboru voleb..." 14 {Hledat s pou¾itím voleb zapsaných v souboru}

# Windows menu:
menuText C Windows "Okna" 0
menuText C WindowsComment "Editor komentáøù" 0 {Otevøít/zavøít editor komentáøù}
menuText C WindowsGList "Seznam partií" 2 {Otevøít/zavøít okno se seznamem partií}
menuText C WindowsPGN "Okno PGN" 5 {Otevøít/zavøít okno PGN}
menuText C WindowsPList "Vyhledávaè hráèù" 11 {Otevøít/zavøít okno vyhledávaèe hráèù}
menuText C WindowsTmt "Vyhledávaè turnajù" 11 {Otevøít/zavøít okno vyhledávaèe turnajù}
menuText C WindowsSwitcher "Výbìr databáze" 0 {Otevøít/zavøít okno pro výbìr databází}
menuText C WindowsMaint "Okno údr¾by" 6 {Otevøít/zavøít okno údr¾by}
menuText C WindowsECO "ECO prohlí¾eè" 1 {Otevøít/zavøít okno ECO prohlí¾eèe}
menuText C WindowsStats "Statistické okno" 0 {Otevøít/zavøít statistické okno filtru}
menuText C WindowsTree "Stromové okno" 4 {Otevøít/zavøít stromové okno}
menuText C WindowsBook "Okno knihovny zahájení" 0 {Otevøít/zavøít okno knihovny zahájení}
menuText C WindowsCorrChess "Korespondenèní okno" 0 {Otevøít/zavøít okno knihovny zahájení}
menuText C WindowsGraph "Analýza Graf" 0 {Otevøete okno Graf s èasy tahù a vyhodnocením}

# Tools menu:
menuText C Tools "Nástroje" 3
menuText C ToolsConfigureEngines "Konfigurace motorù" 10 {Správa konfigurace motorù}
menuText C ToolsAnalysis "Program pro analýzu..." 0 \
  {Spustit/zastavit ¹achový program pro analýzu pozice}
menuText C ToolsAnalysis2 "Program pro analýzu #2..." 20 \
  {Spustit/zastavit druhý ¹achový program pro analýzu pozice}
menuText C ToolsCross "Turnajová tabulka" 0 {Ukázat turnajovou tabulku pro tuto partii}
menuText C ToolsFilterGraph "Graf filtru" 0 \
  {Otevøít/zavøít okno grafu filtru}
menuText C ToolsAbsFilterGraph "Abs. graf filtru" 7 {Otevøít/zavøít okno grafu filtru s absolutními hodnotami}
menuText C ToolsOpReport "Profil zahájení" 7 \
  {Generovat profil zahájení pro aktuální pozicí}
menuText C ToolsOpenBaseAsTree "Otevøít databázi jako strom" 0   {Otevøít databázi a pou¾ít ji ve stromovém oknì}
menuText C ToolsOpenRecentBaseAsTree "Otevøít nedávnou databázi jako strom" 0   {Otevøít nedávnou databázi a pou¾ít ji ve stromovém oknì}
menuText C ToolsTracker "Stopaø figur"  0 {Otevøít okno stopaøe figur}
menuText C ToolsTraining "Trénink"  0 {Tréninkové nástroje (taktika, zahájení,...) }
menuText C ToolsTacticalGame "Taktická partie"  0 {Hrát partii s taktickým zamìøením}
menuText C ToolsSeriousGame "Vá¾ná partie"  0 {Hrát vá¾nou partii}
menuText C ToolsTrainOpenings "Zahájení"  0 {Trénovat s repertoárem zahájení}
menuText C ToolsTrainReviewGame "Projít partii"  0 {Hádat tahy sehrané v partii}
menuText C ToolsTrainTactics "Taktika"  0 {Øe¹it taktické úkoly}
menuText C ToolsTrainCalvar "Propoèet variant"  0 {Trénink propoètu variant}
menuText C ToolsTrainFindBestMove "Nalézt nejlep¹í tah"  0 {Nalézt nejlep¹í tah}
menuText C ToolsTrainFics "Hrát na internetu"  0 {Hrát na freechess.org}
menuText C ToolsEngineTournament "Motorový turnaj"  0 {Zaènìte turnaj mezi ¹achovými motory}
menuText C ToolsTimeAnalysis "Èasová analýza" 0 {Zobrazit graf hodin pro aktuální hru}
menuText C ToolsBookTuning "Ladìní knihovny zahájení" 0 {Ladìní knihovny zahájení}
menuText C ToolsDownloadTWIC "Stáhnìte si hry TWIC" 0 {Stáhnìte si nejnovìj¹í hry The Week In Chess (TWIC).}
menuText C ToolsConnectHardware "Pøipojit hardware" 0 {Pøipojit externí hardware}
menuText C ToolsConnectHardwareConfigure "Konfigurovat..." 0 {Konfigurovat externí hardware a pøipojení}
menuText C ToolsConnectHardwareNovagCitrineConnect "Pøipojit Novag Citrine" 0 {Pøipojit Novag Citrine}
menuText C ToolsConnectHardwareInputEngineConnect "Pøipojit vstupní pøístroj" 0 {Pøipojit vstupní pøístroj (napø. DGT)}

menuText C ToolsPInfo "Informace o hráèích"  0 \
  {Otevøít/aktualizovat okno s informacemi o hráèích}
menuText C ToolsPlayerReport "Profil hráèe..." 7 \
  {Generovat profil hráèe}
menuText C ToolsRating "Graf ratingu" 5 \
  {Zobrazit graf vývoje ratingu hráèù aktuální partie}
menuText C ToolsExpCurrent "Export aktuální partie" 7 \
  {Zapsat aktuální partii do textového souboru}
menuText C ToolsExpCurrentPGN "Export partie do PGN souboru..." 17 \
  {Zapsat aktuální partii do PGN souboru}
menuText C ToolsExpCurrentHTML "Export partie do HTML souboru..." 17 \
  {Zapsat aktuální partii do HTML souboru}
menuText C ToolsExpCurrentHTMLJS "Exportovat partii do souboru HTML s JavaScriptem..." 15 {Ulo¾it aktuální partii do souboru s HTML a JavaScriptem}  
menuText C ToolsExpFilter "Export filtrovaných partií" 7 \
  {Zapsat v¹echny filtrované partie do textového souboru}
menuText C ToolsExpFilterPGN "Export filtrovaných partií do PGN souboru..." 30 \
  {Zapsat v¹echny filtrované partie do PGN souboru}
menuText C ToolsExpFilterHTML "Export filtrovaných partií do HTML souboru..." 30 \
  {Zapsat v¹echny filtrované partie do HTML souboru}
menuText C ToolsExpFilterHTMLJS "Exportovat filtr do souboru HTML s JavaScriptem..." 17 {Ulo¾it v¹echny vyfiltrované partie do souboru HTML s JavaScriptem}  
menuText C ToolsImportOne "Import jedné PGN partie..." 7 \
  {Importovat partii z PGN zápisu}
menuText C ToolsImportFile "Import souboru PGN partií..." 10 \
  {Importovat partie z PGN souboru}
menuText C ToolsStartEngine1 "Spustit herní program 1" 0  {Spustit herní program 1}
menuText C ToolsStartEngine2 "Spustit herní program 2" 0  {Spustit herní program 2}
menuText C ToolsCaptureBoard "Ulo¾it aktuální ¹achovnici..." 0  {Ulo¾it aktuální ¹achovnici jako obrázek.}

# Play menu
menuText C Play "Hra" 0

# --- Correspondence Chess
menuText C CCResign "Vzdát" 0 {Vzdát (nikoliv prostøednictvím e-mailu)}
menuText C CCClaimDraw "Reklamovat remízu" 0 {Poslat tah a reklamovat remízu (nikoliv prostøednictvím e-mailu)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText C Options "Volby" 0
menuText C OptionsBoardGraphics "Pole..." 0 {Vybrat vzorek pro pole}
translate C OptionsBGW {Vybrat vzorek pro pole}
translate C OptionsBoardGraphicsText {Vybrat grafické soubory pro bílá a èerná pole:}
menuText C OptionsBoardNames "Jména mých hráèù..." 0 {Editovat jména mých hráèù}
menuText C OptionsExport "Volby exportu" 7 {Zmìnit volby pro textový export}
menuText C OptionsFonts "Fonty" 2 {Zmìnit fonty}
menuText C OptionsFontsRegular "Základní" 0 {Zmìnit základní font}
menuText C OptionsFontsMenu "Menu" 1 {Zmìnit font pro menu}
menuText C OptionsFontsSmall "Malé" 0 {Zmìnit malý font}
menuText C OptionsFontsTiny "Malièký" 0 {Zmìòte malé písmo}
menuText C OptionsFontsFixed "Fixní" 0 {Zmìnit font fixní ¹íøky}
menuText C OptionsGInfo "Informace o partii" 0 {Volby pro informace o partii}
menuText C OptionsLanguage "Jazyk" 0 {Vybrat jazyk menu}
menuText C OptionsMovesTranslatePieces "Pøekládat figury" 0 {Pøekládat první písmena figur}
menuText C OptionsMovesHighlightLastMove "Zvýrazòovat poslední tah" 0 {Zvýrazòovat poslední tah}
menuText C OptionsMovesHighlightLastMoveDisplay "Ukázat" 0 {Zobrazit zvýraznìný poslední tah}
menuText C OptionsMovesHighlightLastMoveWidth "©íøka" 0 {Tlou¹»ka èáry}
menuText C OptionsMovesHighlightLastMoveColor "Barva" 0 {Barva èáry}
menuText C OptionsMovesHighlightLastMoveArrow "vèetnì Arrow" 0 {Zahrnout ¹ipku se zvýraznìním}
menuText C OptionsMovesHighlightLastMoveNag "Zobrazit symboly hodnocení" 0
menuText C OptionsMovesHighlightLastMoveEval "Zobrazit symboly hodnocení" 0
menuText C OptionsMoves "Tahy" 0 {Volby pro zadávání tahù}
menuText C OptionsMovesAnimate "Èas animace" 4 \
  {Nastavit èas pou¾itý na animaci tahù}
menuText C OptionsMovesDelay "Prodleva pøi automatickém pøehrávání..." 1 \
  {Nastavit èasovou prodlevu pøi automatickém pøehrávání}
menuText C OptionsMovesCoord "Souøadnicové zadávání tahù" 0 \
  {Povolit zadávání tahù pomocí souøadnic (napø. "g1f3")}
menuText C OptionsMovesSuggest "Ukázat navrhované tahy" 0 \
  {Zapnout/vypnout zobrazování navrhovaných tahù}
menuText C OptionsShowVarPopup "Zobrazit okno variant" 0 {Zapnout/vypnout zobrazení okna variant}  
menuText C OptionsMovesSpace "Pøidat mezeru za èíslo tahu" 0 {Pøidat mezeru za èíslo tahu}  
menuText C OptionsMovesLichess "Formát Lichess/ChessBase pro poznámky" 0 {Pro ètvercové znaèky a ¹ipky pou¾ijte formát Lichess/ChessBase}
menuText C OptionsMovesKey "Klávesnicové doplòování" 13 \
  {Zapnout/vypnout automatické doplòování tahù zadávaných klávesnicí}
menuText C OptionsMovesShowVarArrows "Zobrazit ¹ipky pro varianty" 0 {Zapnout/vypnout zobrazování ¹ipek ukazujících tahy variant}
menuText C OptionsMovesShowEngineVariationArrows "Zobrazit ¹ipky pro varianty motoru" 0 {Zapnìte/vypnìte ¹ipky ukazující èáry variace motoru v re¾imu multiPV}
menuText C OptionsMovesGlossOfDanger "Barevnì kódovaný lesk nebezpeèí" 0 {Zapnout/vypnout barevnì oznaèený lesk nebezpeèí}
translate C OptionsMovesTreeDepth {Výchozí Hloubka pohybu okna stromu}
menuText C OptionsNumbers "Formát èísel" 0 {Zvolit formát èísel}
menuText C OptionsTheme "Téma" 0 {Zmìnit vzhled u¾ivatelského rozhraní}
menuText C OptionsWindows "Okna" 0 {Volby oken}
menuText C OptionsSounds "Zvuky" 2 {Konfigurovat zvuky oznamující tah}
menuText C OptionsResources "Zdroje..." 0 {Vyberte zdrojové soubory a slo¾ky}
menuText C OptionsWindowsDock "Zaparkovat okna" 0 {Zaparkovat okna}
menuText C OptionsWindowsSaveLayout "Ulo¾it rozlo¾ení" 0 {Ulo¾it rozlo¾ení}
menuText C OptionsWindowsRestoreLayout "Obnovit rozlo¾ení" 0 {Obnovit rozlo¾ení}
menuText C OptionsWindowsShowGameInfo "Ukázat informace o partii" 0 {Ukázat informace o partii}
menuText C OptionsWindowsAutoLoadLayout "Automaticky natáhnout první rozlo¾ení" 0 {Automaticky na zaèátku natáhnout první rozlo¾ení}
menuText C OptionsECO "Natáhnout ECO soubor" 10 {Natáhnout soubor s klasifikací ECO}
menuText C OptionsSpell "Natáhnout soubor pro kontrolu pravopisu" 21 \
  {Natáhnout soubor Scidu pro kontrolu pravopisu}
menuText C OptionsTable "Adresáø pro tabulky koncovek" 14 \
  {Vybrat soubor s tabulkami koncovek; v¹echny tabulky koncovek v jeho adresáøi budou pou¾ity}
menuText C OptionsRecent "Nedávné soubory..." 0 \
  {Zmìnit poèet nedávných souborù zobrazovaných v menu Soubor}
menuText C OptionsBooksDir "Adresáø knihoven zahájení" 0 {Nastavení adresáøe knihoven zahájení}
menuText C OptionsTacticsBasesDir "Adresáø databází" 0 {Nastavení adresáøù taktických (tréninkových) databází}
menuText C OptionsPhotosDir "Adresáø fotografií" 0 {Nastaví adresáø fotografií}
menuText C OptionsThemeDir "Soubor motivù:"  0 {Naètìte soubor balíèku motivu GUI}
menuText C OptionsSave "Ulo¾it volby" 0 \
  "Ulo¾it v¹echny nastavitelné volby do souboru $::optionsFile"
menuText C OptionsAutoSave "Automaticky ukládat volby pøi ukonèení" 20 \
  {Automaticky ukládat v¹echny volby pøi ukonèení Scidu}

# Help menu:
menuText C Help "Nápovìda" 0
menuText C HelpContents "Obsah" 0 {Zobrazit stránku nápovìdy s obsahem}
menuText C HelpIndex "Index" 0 {Zobrazit stránku nápovìdy s indexem}
menuText C HelpGuide "Rychlý prùvodce" 7 {Zobrazit stránku nápovìdy s rychlým prùvodcem}
menuText C HelpHints "Rady" 0 {Zobrazit stránku nápovìdy s radami}
menuText C HelpContact "Kontakt" 0 {Zobrazit stránku nápovìdy s kontaktními informacemi}
menuText C HelpTip "Tip dne" 4 {Zobrazit u¾iteèný tip Scidu}
menuText C HelpStartup "Startovací okno" 0 {Zobrazit startovací okno}
menuText C HelpAbout "O aplikaci Scid" 2 {Informace o aplikaci Scid}

# Toolbar tooltips:
menuText C RotateBoard "Otoète desku" 0 {Otoète desku}

# Game info box popup menu:
menuText C GInfoHideNext "Skrýt následující tah" 0
menuText C GInfoMaterial "Ukázat hodnoty materiálu" 15
menuText C GInfoFEN "Ukázat FEN" 7
menuText C GInfoMarks "Zobrazovat barevná pole a ¹ipky" 11
menuText C GInfoWrap "Zalamovat dlouhé øádky" 0
menuText C GInfoFullComment "Zobrazit úplný komentáø" 15
menuText C GInfoPhotos "Zobrazit fotky" 10
menuText C GInfoTBNothing "Tabulky koncovek: nic" 19
menuText C GInfoTBResult "Tabulky koncovek: jen výsledek" 23
menuText C GInfoTBAll "Tabulky koncovek: výsledek a nejlep¹í tahy" 39
menuText C GInfoDelete "Vymazat/Nemazat tuto partii" 0
menuText C GInfoMark "Oznaèit/Odznaèit tuto partii" 0
menuText C GInfoInformant "Konfigurovat informátorové hodnoty" 0

# General buttons:
translate C Back {Zpìt}
translate C Browse {Prohlí¾et}
translate C Cancel {Zru¹it}
translate C Continue {Pokraèovat}
translate C Clear {Vyèistit}
translate C Close {Zavøít}
translate C Contents {Obsah}
translate C Defaults {Pøedvolené}
translate C InvertSearch {Invertovat vyhledávání}
translate C Delete {Vymazat}
translate C Graph {Graf}
translate C Help {Nápovìda}
translate C Hide {Skrýt}
translate C Import {Import}
translate C Index {Index}
translate C LoadGame {Natáhnout partii}
translate C BrowseGame {Prohlédnout partii}
translate C MergeGame {Pøipojit partii}
translate C MergeGames {Pøipojit partie}
translate C Preview {Náhled}
translate C Revert {Vrátit se}
translate C Save {Ulo¾it}
translate C Search {Hledat}
translate C Stop {Stop}
translate C Store {Uschovat}
translate C Update {Aktualizovat}
translate C ChangeOrient {Zmìnit orientaci okna}
translate C ShowIcons {Zobrazit ikony}
translate C None {Nic}
translate C First {První}
translate C Current {Aktuální}
translate C Last {Poslední}

# General messages:
translate C game {partie}
translate C games {partie}
translate C move {tah}
translate C moves {tahy}
translate C all {v¹e}
translate C Yes {Ano}
translate C No {Ne}
translate C Both {Oba}
translate C King {Král}
translate C Queen {Dáma}
translate C Rook {Vì¾}
translate C Bishop {Støelec}
translate C Knight {Jezdec}
translate C Pawn {Pì¹ec}
translate C White {Bílý}
translate C Black {Èerný}
translate C Player {Hráè}
translate C Rating {Rating}
translate C RatingDiff {Rozdíl v ratingu (Bílý - Èerný)}
translate C AverageRating {Prùmìrný rating}
translate C Event {Turnaj}
translate C Site {Místo}
translate C Country {Zemì}
translate C IgnoreColors {Ignorovat barvy}
translate C Date {Datum}
translate C EventDate {Datum turnaje}
translate C Decade {Dekáda}
translate C Year {Rok}
translate C Month {Mìsíc}
translate C Months {Leden Únor Bøezen Duben Kvìten Èerven Èervenec Srpen Záøí Øíjen Listopad Prosinec}
translate C Days {Ned Pon Úte Stø Ètv Pát Sob}
translate C YearToToday {Rok zpìt}
translate C YearToTodayTooltip {Nastavte datum od 1 roku zpìt do dne¹ka}
translate C Result {Výsledek}
translate C Round {Kolo}
translate C Length {Délka}
translate C ECOCode {ECO kód}
translate C ECO {ECO}
translate C Deleted {Vymazán(a)}
translate C SearchResults {Hledat výsledky}
translate C OpeningTheDatabase {Databáze zahájení}
translate C Database {Databáze}
translate C Filter {Filtr}
translate C noGames {¾ádné partie}
translate C allGames {v¹echny partie}
translate C empty {prázdná}
translate C clipbase {schránka}
translate C score {skóre}
translate C StartPos {Poèáteèní pozice}
translate C Total {Celkem}
translate C readonly {jen ke ètení}

# Standard error messages:
translate C ErrNotOpen {To není otevøená databáze.}
translate C ErrReadOnly {Tato databáze je jen ke ètení; nemù¾e být zmìnìna.}
translate C ErrSearchInterrupted {Hledání bylo pøeru¹eno; výsledky nejsou kompletní.}
translate C ErrEnginesOpen {Nelze pokraèovat, kdy¾ jsou ¹achové motory otevøené.\nZavøete prosím v¹echna okna a zkuste to znovu.}
translate C ErrNoClockComments {V této høe nebyly nalezeny ¾ádné komentáøe hodin [%clk].    Chcete-li pou¾ít tuto funkci, pøidejte hodiny prostøednictvím okna Komentáøe (Ctrl+E).}
translate C ErrFileInUse {Chyba: soubor se ji¾ pou¾ívá. Zavøete v¹echny ostatní aplikace pou¾ívající tuto databázi. Pokud byl program neoèekávanì ukonèen, mù¾e být nutné odstranit soubor .lock spojený s databází.}




# Game information:
translate C twin {zdvojená}
translate C deleted {vymazaná}
translate C comment {komentáø}
translate C hidden {skrytá}
translate C LastMove {Poslední tah}
translate C NextMove {Následující tah}
translate C GameStart {Zaèátek partie}
translate C LineStart {Zaèátek série tahù}
translate C GameEnd {Konec partie}
translate C LineEnd {Konec série tahù}

# Player information:
translate C PInfoAll {Výsledky <b>v¹ech</b> partií}
translate C PInfoFilter {Výsledky <b>filtrovaných</b> partií}
translate C PInfoAgainst {Výsledky proti}
translate C PInfoMostWhite {Nejèastìj¹í zahájení za bílé}
translate C PInfoMostBlack {Nejèastìj¹í zahájení za èerné}
translate C PInfoRating {Historie ratingu}
translate C PInfoBio {Biografie}
translate C PInfoEditRatings {Editovat ratingy}
translate C PInfoEloFile {Soubor}

# Tablebase information:
translate C Draw {Remíza}
translate C with {s}
translate C only {jen}
translate C lose {prohrát}
translate C loses {prohrává}

# Tip of the day:
translate C Tip {Tip}
translate C TipAtStartup {Tip pøi spu¹tìní}
translate C TipConvertPGN {Lep¹í výkon mù¾ete dosáhnout pøevodem souborù PGN}

# Tree window menus:
menuText C TreeFile "Soubor" 0
menuText C TreeFileFillWithBase "Naplnit cache z databáze" 0 {Naplnit cachovací soubor v¹emi partiemi z aktuální databáze}
menuText C TreeFileFillWithGame "Naplnit cache partií" 0 {Naplnit cachovací soubor aktuální partií z aktuální databáze}
menuText C TreeFileSetCacheSize "Velikost cache" 0 {Nastavit velikost cache}
menuText C TreeFileCacheInfo "Informace o cache" 0 {Získat informaci o vyu¾ití cache}
menuText C TreeFileSave "Ulo¾it cache soubor" 0 \
  {Ulo¾it stromový cache (.stc) soubor}
menuText C TreeFileFill "Naplnit cache soubor" 0 \
  {Naplnit cache soubor nejbì¾nìj¹ími pozicemi zahájení}
menuText C TreeFileBest "Seznam nejlep¹ích partií" 0 {Zobrazit seznam nejlep¹ích partií  stromu}
menuText C TreeFileGraph "Okno grafu" 0 {Zobrazit graf pro tuto vìtev stromu}
menuText C TreeFileCopy "Kopírovat text stromu do clipboardu" 0 \
  {Kopírovat stromové statistiky do textového výbìru}
menuText C TreeFileClose "Zavøít stromové okno" 0 {Zavøít stromové okno}
menuText C TreeMask "Maska" 0
menuText C TreeMaskNew "Nová" 0 {Nová maska}
menuText C TreeMaskOpen "Otevøít" 0 {Otevøít masku}
menuText C TreeMaskOpenRecent "Otevøít nedávnou" 0 {Otevøít nedávnou masku}
menuText C TreeMaskSave "Ulo¾it" 0 {Ulo¾it masku}
menuText C TreeMaskClose "Zavøít" 0 {Uzavøít masku}
menuText C TreeMaskFillWithGame "Naplnit partií" 0 {Naplnit masku partií}
menuText C TreeMaskFillWithBase "Naplnit databází" 0 {Naplnit masku v¹emi partiemi z databáze}
menuText C TreeMaskInfo "Informace" 0 {Ukázat statistiku aktuální masky}
menuText C TreeMaskDisplay "Ukázat mapu masky" 0 {Ukázat data masky ve formì stromu}
menuText C TreeMaskSearch "Hledat" 0 {Hledat v aktuální masce}
menuText C TreeSort "Øadit" 2
menuText C TreeSortAlpha "Abecednì" 0
menuText C TreeSortECO "ECO kód" 0
menuText C TreeSortFreq "Frekvence" 0
menuText C TreeSortScore "Skóre" 0
menuText C TreeOpt "Volby" 0
menuText C TreeOptSlowmode "Pomalý re¾im" 0 {Pomalý re¾im aktualizace (vysoká pøesnost)}
menuText C TreeOptFastmode "Rychlý re¾im" 0 {Rychlý re¾im aktualizace (beze zmìny poøadí tahù)}
menuText C TreeOptFastAndSlowmode "Rychlý a pomalý re¾im" 0 {Rychlý re¾im a potom pomalý re¾im aktualizace}
menuText C TreeOptStartStop "Automatické aktualizace" 0 {Pøepnout automatické aktualizace stromového okna}
menuText C TreeOptLock "Zamknout" 0 {Zamknout/Odemknout strom k aktuální databázi}
menuText C TreeOptTraining "Trénink" 0 {Zapnout/Vypnout stromový tréninkový mód}
menuText C TreeOptDepth "Hloubka pohybu" 0 {Poèet polovièních tahù k zobrazení ve stromu (1-4)}
menuText C TreeOptAutosave "Automatické ukládání cache souboru" 0 \
  {Automatické ukládání cache souboru pøi uzavøení stromového okna}
menuText C TreeHelp "Nápovìda" 0
menuText C TreeHelpTree "Nápovìda - Strom" 11
menuText C TreeHelpIndex "Index nápovìdy" 0
translate C SaveCache {Ulo¾it cache}
translate C Training {Trénink}
translate C LockTree {Zamknout}
translate C TreeDepth {Hloubka stromu (pùl tahu):}
translate C TreeLocked {Zamknuto}
translate C TreeBest {Nejlep¹í}
translate C TreeBestGames {Nejlep¹í partie stromu}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate C TreeTitleRow \
{Tah                           ECO       Frekvence    Skóre  PrElo Perf  PrRok %remíz   %Vyhrát}
translate C TreeTotal {CELKEM}
translate C DoYouWantToSaveFirst {Chcete nejprve ulo¾it}
translate C AddToMask {Pøidat do masky}
translate C RemoveFromMask {Odstranit z masky}
translate C AddThisMoveToMask {Pøidat tento tah do masky}
translate C SearchMask {Hledat v masce}
translate C DisplayMask {Zobrazit masku}
translate C Nag {Nag kód}
translate C Marker {Znaèka}
translate C Include {Zahrnout}
translate C Exclude {Vylouèit}
translate C MainLine {Hlavní varianta}
translate C Bookmark {Zálo¾ka}
translate C NewLine {Nová varianta}
translate C ToBeVerified {K provìøení}
translate C ToTrain {Trénovat}
translate C Dubious {Pochybné}
translate C ToRemove {Odstranit}
translate C NoMarker {®ádná znaèka}
translate C ColorMarker {Barva}
translate C WhiteMark {Bílá}
translate C GreenMark {Zelená}
translate C YellowMark {®lutá}
translate C BlueMark {Modrá}
translate C RedMark {Èervená}
translate C CommentMove {Okomentovat tah}
translate C CommentPosition {Okomentovat pozici}
translate C AddMoveToMaskFirst {Nejprve pøidejte tah do masky}
translate C OpenAMaskFileFirst {Nejprve otevøete soubor masky}
translate C Positions {Pozice}
translate C Moves {Tahy}

# Finder window:
menuText C FinderFile "Soubor" 0
menuText C FinderFileSubdirs "Hledat v podadresáøích" 0
menuText C FinderFileClose "Zavøít vyhledávaè souborù" 0
menuText C FinderSort "Øadit" 2
menuText C FinderSortType "Typ" 0
menuText C FinderSortSize "Velikost" 0
menuText C FinderSortMod "Zmìnìno" 0
menuText C FinderSortName "Jméno" 0
menuText C FinderSortPath "Cesta" 0
menuText C FinderTypes "Typy" 0
menuText C FinderTypesScid "Databáze Scidu" 0
menuText C FinderTypesOld "Databáze Scidu starého formátu" 15
menuText C FinderTypesPGN "PGN soubory" 0
menuText C FinderTypesEPD "EPD soubory" 0
menuText C FinderTypesRep "Repertoárové soubory" 0
menuText C FinderHelp "Nápovìda" 0
menuText C FinderHelpFinder "Nápovìda - Vyhledávaè souborù" 11
menuText C FinderHelpIndex "Index nápovìdy" 0
translate C FileFinder {Vyhledávaè souborù}
translate C FinderDir {Adresáø}
translate C FinderDirs {Adresáøe}
translate C FinderFiles {Soubory}
translate C FinderUpDir {nahoru}
translate C FinderCtxOpen {Otevøít}
translate C FinderCtxBackup {Zálohovat}
translate C FinderCtxCopy {Kopírovat}
translate C FinderCtxMove {Pøesunout}
translate C FinderCtxDelete {Smazat}

# Player finder:
menuText C PListFile "Soubor" 0
menuText C PListFileUpdate "Aktualizovat" 0
menuText C PListFileClose "Zavøít vyhledávaè hráèù" 0
menuText C PListSort "Øadit" 2
menuText C PListSortName "Jméno" 0
menuText C PListSortElo "ELO" 0
menuText C PListSortGames "Partie" 0
menuText C PListSortOldest "Nejstar¹í" 3
menuText C PListSortNewest "Nejnovìj¹í" 3

# Tournament finder:
menuText C TmtFile "Soubor" 0
menuText C TmtFileUpdate "Aktualizovat" 0
menuText C TmtFileClose "Zavøít vyhledávaè souborù" 0
menuText C TmtSort "Øadit" 2
menuText C TmtSortDate "Datum" 0
menuText C TmtSortPlayers "Hráèi" 0
menuText C TmtSortGames "Partie" 0
menuText C TmtSortElo "ELO" 0
menuText C TmtSortSite "Místo" 0
menuText C TmtSortEvent "Turnaj" 0
menuText C TmtSortWinner "Vítìz" 0
translate C TmtLimit "Limit seznamu"
translate C TmtMeanElo "Prùmìrné ELO"
translate C TmtNone "®ádné odpovídající turnaje nebyly nalezeny."

# Graph windows:
menuText C GraphFile "Soubor" 0
menuText C GraphFileColor "Ulo¾it jako barevný Postscript..." 12
menuText C GraphFileGrey "Ulo¾it jako èernobílý Postscript..." 13
menuText C GraphFileClose "Zavøít okno" 0
menuText C GraphOptions "Volby" 0
menuText C GraphOptionsWhite "Bílý" 0
menuText C GraphOptionsBlack "Èerný" 1
menuText C GraphOptionsBoth "Oba" 0
menuText C GraphOptionsPInfo "Informace o hráèi" 0
menuText C GraphOptionsEloFile "Elo ze souboru hodnocení" 0
menuText C GraphOptionsEloDB "Elo z databáze" 0
translate C GraphFilterTitle "Graf filtru: èetnost na 1000 partií"
translate C GraphAbsFilterTitle "Graf filtru: èetnost partií"
translate C ConfigureFilter {Konfigurovat x-souøadnici pro rok, rating a tahy}
translate C FilterEstimate "Odhadnout"
translate C TitleFilterGraph "Scid: Graf filtru"

# Analysis window:
translate C AddVariation {Pøidat variantu}
translate C AddAllVariations {Pøidat v¹echny varianty}
translate C AddMove {Pøidat tah}
translate C Annotate {Anotace}
translate C ShowAnalysisBoard {Ukázat ¹achovnici analýzy}
translate C ShowInfo {Ukázat informaci o herním programu}
translate C FinishGame {Ukonèit partii}
translate C StopEngine {Zastavit herní program}
translate C StartEngine {Spustit herní program}
translate C LockEngine {Uzamèít herní program v aktuální pozici}
translate C AnalysisCommand {Program pro analýzu}
translate C PreviousChoices {Pøedchozí vybrané programy}
translate C AnnotateTime {Nastavit èas mezi tahy v sekundách}
translate C AnnotateWhich {Pøidat varianty}
translate C AnnotateAll {Pro tahy obou stran}
translate C AnnotateAllMoves {Anotovat v¹echny tahy}
translate C AnnotateWhite {Pouze pro tahy bílého}
translate C AnnotateBlack {Pouze pro tahy èerného}
translate C AnnotateBlundersOnly {Jestli¾e tah v partii je evidentní hrubá chyba}
translate C AnnotateBlundersOnlyScoreChange {Analýza ukazuje hrubou chybu, jestli¾e se skóre zmìní z/na: }
translate C BlundersThreshold {Hranice}
translate C ScoreAllMoves {Score all moves}
translate C LowPriority {Nízká priorita procesoru}
translate C ClickHereToSeeMoves {Kliknìte sem pro zobrazení tahù}
translate C ConfigureInformant {Informátor}
translate C Informant!? {Zajímavý tah}
translate C Informant? {Slabý tah}
translate C Informant?? {Hrubá chyba}
translate C Informant?! {Pochybný tah}
translate C Informant+= {Bílý má malou výhodu}
translate C Informant+/- {Bílý má støední výhodu}
translate C Informant+- {Bílý má rozhodující výhodu}
translate C Informant+-- {Partie je pova¾ována za vyhranou}
translate C AutoComment {Automatický komentáø}
translate C AutoCommentTooltip {Generujte AI komentáø pro aktuální pozici}
translate C AnalysisAutoCommentTooltip {Generujte AI komentáø pro celou hru}

# Book window
translate C Book {Knihovna zahájení}
translate C OtherBookMoves {Soupeøova knihovna zahájení}
translate C OtherBookMovesTooltip {Tahy, na které má soupeø odpovìï}

# Analysis Engine open dialog:
translate C EngineList {Seznam herních programù pro analýzu}
translate C EngineName {Jméno}
translate C EngineCmd {Pøíkaz}
translate C EngineArgs {Parametry}
translate C EngineDir {Adresáø}
translate C EngineElo {ELO}
translate C EngineTime {Datum}
translate C EngineNew {Nový}
translate C EngineEdit {Editace}
translate C EngineRequired {Tuènì vyznaèené polo¾ky jsou povinné; ostatní jsou volitelné}
translate C EngineProtocol {Komunikaèní protokol}
translate C EngineNotation {Zápis tahù}
translate C EngineFlipEvaluation {Flip hodnocení perspektivy}
translate C EngineShowLog {Zobrazit protokol komunikace}
translate C EngineNetworkd {Pøijmìte vzdálená pøipojení}
translate C EngineSelect {Vyberte aktuální motor}
translate C EngineAddLocal {Pøidejte místní motor}
translate C EngineAddRemote {Pøidejte vzdálený motor}
translate C EngineReload {Znovu naètìte aktuální motor}
translate C EngineClone {Vytvoøte kopii aktuálního motoru}
translate C EngineDelete {Smazat aktuální motor}

# PGN window menus:
menuText C PgnFile "Soubor" 0
menuText C PgnFileCopy "Kopírovat partii do clipboardu" 0
menuText C PgnFilePrint "Vytisknout do souboru..." 0
menuText C PgnFileClose "Zavøít okno PGN" 0
menuText C PgnOpt "Zobrazit" 0
menuText C PgnOptColor "Barevné zobrazení" 0
menuText C PgnOptShort "Krátká (tøíøádková) hlavièka" 20
menuText C PgnOptSymbols "Symbolické anotace" 0
menuText C PgnOptIndentC "Odsazovat komentáøe" 10
menuText C PgnOptIndentV "Odsazovat varianty" 10
menuText C PgnOptColumn "Sloupcový styl (jeden tah na øádek)" 1
menuText C PgnOptSpace "Mezera za èíslem tahu" 0
menuText C PgnOptStripMarks "Odstranit kódy barevných polí a ¹ipek" 0
menuText C PgnOptBoldMainLine "Pou¾ít tuèný text pro tahy hlavní varianty" 4
menuText C PgnColor "Barvy" 0
menuText C PgnColorHeader "Hlavièka..." 0
menuText C PgnColorAnno "Anotace..." 0
menuText C PgnColorComments "Komentáøe..." 0
menuText C PgnColorVars "Varianty..." 0
menuText C PgnColorBackground "Pozadí..." 0
menuText C PgnColorMain "Hlavní varianta..." 0
menuText C PgnColorCurrent "Pozadí aktuálního tahu..." 1
menuText C PgnHelp "Nápovìda" 0
menuText C PgnHelpPgn "Nápovìda - Okno PGN " 16
menuText C PgnHelpIndex "Index nápovìdy" 0
translate C PgnWindowTitle {Zápis partie - partie %u}

# Crosstable window menus:
menuText C CrosstabFile "Soubor" 0
menuText C CrosstabFileText "Vytisknout do textového souboru..." 14
menuText C CrosstabFileHtml "Vytisknout do HTML souboru..." 14
menuText C CrosstabFileClose "Zavøít okno turnajové tabulky" 0
menuText C CrosstabEdit "Editovat" 0
menuText C CrosstabEditEvent "Turnaj" 0
menuText C CrosstabEditSite "Místo" 0
menuText C CrosstabEditDate "Datum" 0
menuText C CrosstabOpt "Zobrazit" 0
menuText C CrosstabOptAll "Ka¾dý s ka¾dým" 0
menuText C CrosstabOptSwiss "©výcarský systém" 3
menuText C CrosstabOptKnockout "Vyøazovací" 4
menuText C CrosstabOptAuto "Auto" 0
menuText C CrosstabOptAges "Vìk" 0
menuText C CrosstabOptNats "Národnost" 0
menuText C CrosstabOptRatings "Rating" 0
menuText C CrosstabOptTitles "Titul" 0
menuText C CrosstabOptBreaks "Výsledky tie-breaku" 10
menuText C CrosstabOptDeleted "Vèetnì vymazaných partií" 9
menuText C CrosstabOptColors "Barvy (jen pro ¹výcarský systém)" 0
menuText C CrosstabOptColumnNumbers "Èíslované sloupce (jen v tabulkách 'ka¾dý s ka¾dým')" 3
menuText C CrosstabOptGroup "Skupiny podle skóre" 0
menuText C CrosstabSort "Øadit" 2
menuText C CrosstabSortName "Jméno" 0
menuText C CrosstabSortRating "Rating" 0
menuText C CrosstabSortScore "Skóre" 0
menuText C CrosstabColor "Barvy" 0
menuText C CrosstabColorPlain "Prostý text" 0
menuText C CrosstabColorHyper "Hypertext" 0
menuText C CrosstabHelp "Nápovìda" 0
menuText C CrosstabHelpCross "Nápovìda - Turnajovou tabulku" 11
menuText C CrosstabHelpIndex "Index nápovìdy" 0
translate C SetFilter {Nastavit filtr}
translate C AddToFilter {Pøidat do filtru}
translate C Swiss {©výcarský systém}
translate C Category {Kategorie}

# Opening report window menus:
menuText C OprepFile "Soubor" 0
menuText C OprepFileText "Vytisknout do textového souboru..." 14
menuText C OprepFileHtml "Vytisknout do HTML souboru..." 14
menuText C OprepFileOptions "Volby" 0
menuText C OprepFileClose "Zavøít okno s profilem" 0
menuText C OprepFavorites "Oblíbené" 0
menuText C OprepFavoritesAdd "Pøidat profil..." 0
menuText C OprepFavoritesEdit "Editovat oblíbené profily..." 0
menuText C OprepFavoritesGenerate "Generovat profil..." 0
menuText C OprepHelp "Nápovìda" 0
menuText C OprepHelpReport "Nápovìda - Profil zahájení" 11
menuText C OprepHelpIndex "Index nápovìdy" 11

# Header search:
translate C HeaderSearch {Hledat podle hlavièky}
translate C EndSideToMove {Strana na tahu na konci hry}
translate C GamesWithNoECO {Partie bez ECO?}
translate C GameLength {Délka Partie}
translate C FindGamesWith {Najít partie s pøíznaky}
translate C StdStart {Nestandardní start}
translate C Promotions {Promìny}
translate C Comments {Komentáøe}
translate C Variations {Varianty}
translate C Annotations {Anotace}
translate C DeleteFlag {Mazací pøíznak}
translate C WhiteOpFlag {Zahájení bílého}
translate C BlackOpFlag {Zahájení èerného}
translate C MiddlegameFlag {Støední hra}
translate C EndgameFlag {Koncovka}
translate C NoveltyFlag {Novinka}
translate C PawnFlag {Pì¹cová struktura}
translate C TacticsFlag {Taktika}
translate C QsideFlag {Hra na dámském køídle}
translate C KsideFlag {Hra na královském køídle}
translate C BrilliancyFlag {Velmi silný tah}
translate C BlunderFlag {Hrubá chyba}
translate C UserFlag {U¾ivatel}
translate C PgnContains {PGN obsahuje text}
translate C PgnTag {©títek}
translate C TagContains {obsahuje}
translate C Variant {Varianta}
translate C Annotator {Anotátor}
translate C Cmnts {Pouze komentované hry}

# Game list window:
translate C GlistNumber {Èíslo}
translate C GlistWhite {Bílý}
translate C GlistBlack {Èerný}
translate C GlistWElo {B-ELO}
translate C GlistBElo {È-ELO}
translate C GlistEvent {Turnaj}
translate C GlistSite {Místo}
translate C GlistRound {Kolo}
translate C GlistDate {Datum}
translate C GlistYear {Rok}
translate C GlistEDate {Datum turnaje}
translate C GlistResult {Výsledek}
translate C GlistLength {Délka}
translate C GlistCountry {Zemì}
translate C GlistECO {ECO}
translate C GlistOpening {Zahájení}
translate C GlistEndMaterial {Materiál na konci}
translate C GlistDeleted {Vymazán(a)}
translate C GlistFlags {Pøíznak}
translate C GlistVars {Varianty}
translate C GlistComments {Komentáøe}
translate C GlistAnnos {Anotace}
translate C GlistStart {Poèáteèní pozice}
translate C GlistGameNumber {Èíslo partie}
translate C GlistAverageElo {Prùmìrné Elo}
translate C GlistRating {Hodnocení}
translate C GlistFindText {Hledat text}
translate C GlistMoveField {Pøesunout}
translate C GlistEditField {Konfigurovat}
translate C GlistAddField {Pøidat}
translate C GlistDeleteField {Odebrat}
translate C GlistWidth {©íøka}
translate C GlistAlign {Zarovnat}
translate C GlistAlignL {Zarovnat: vlevo}
translate C GlistAlignR {Zarovnat: vpravo}
translate C GlistAlignC {Zarovnat: na støed}
translate C GlistColor {Barva}
translate C GlistSep {Oddìlovaè}
translate C GlistCurrentSep {-- Aktuální --}
translate C GlistNewSort {Nový}
translate C GlistAddToSort {Pøidat}

# base sorting
translate C GsortSort {Seøadit...}
translate C GsortDate {Datum}
translate C GsortYear {Rok}
translate C GsortEvent {Událost}
translate C GsortSite {místo}
translate C GsortRound {Kolo}
translate C GsortWhiteName {Bílé jméno}
translate C GsortBlackName {Èerné jméno}
translate C GsortECO {EKO}
translate C GsortResult {Výsledek}
translate C GsortMoveCount {Pøesunout poèet}
translate C GsortAverageElo {Prùmìrné Elo}
translate C GsortCountry {Zemì}
translate C GsortDeleted {Smazáno}
translate C GsortEventDate {Datum události}
translate C GsortWhiteElo {Bílé Elo}
translate C GsortBlackElo {Èerné Elo}
translate C GsortComments {Komentáøe}
translate C GsortVariations {Variace}
translate C GsortNAGs {NAGs}
translate C GsortAscending {Vzestupnì}
translate C GsortDescending {Klesající}
translate C GsortAdd {Pøidat}
translate C GsortStore {Obchod}
translate C GsortLoad {Zatí¾ení}

# menu shown with right mouse button down on game list.
translate C GlistRemoveThisGameFromFilter  {Odstranit tuto partii z filtru}
translate C GlistRemoveGameAndAboveFromFilter  {Odstranit partii (a v¹echny nad ní) z filtru}
translate C GlistRemoveGameAndBelowFromFilter  {Odstranit partii (a v¹echny pod ní) z filtru}
translate C GlistDeleteGame {Smazat/obnovit tuto partii} 
translate C GlistDeleteAllGames {Smazat v¹echny partii obsa¾ené ve filtru} 
translate C GlistUndeleteAllGames {Obnovit v¹echny smazané partie obsa¾ené ve filtru} 
translate C GlistMergeGameInBase {Pøipojit partii z jiné databáze} 

# Maintenance window:
translate C DatabaseName {Jméno databáze:}
translate C TypeIcon {Symbol:}
translate C NumOfGames {Partie:}
translate C NumDeletedGames {Vymazané partie:}
translate C NumFilterGames {Partie ve filtru:}
translate C YearRange {Rozsah rokù:}
translate C RatingRange {Rozsah ratingu:}
translate C Description {Popis}
translate C Flag {Pøíznak}
translate C CustomFlags {U¾ivatelské pøíznaky}
translate C DeleteCurrent {Vymazat aktuální partii}
translate C DeleteFilter {Vymazat filtrované partie}
translate C DeleteAll {Vymazat v¹echny partie}
translate C UndeleteCurrent {Obnovit aktuální partie po vymazání}
translate C UndeleteFilter {Obnovit filtrované partie po vymazání}
translate C UndeleteAll {Obnovit v¹echny partie po vymazání}
translate C DeleteTwins {Vymazat zdvojené partie}
translate C MarkCurrent {Oznaèit aktivní partii}
translate C MarkFilter {Oznaèit filtrované partie}
translate C MarkAll {Oznaèit v¹echny partie}
translate C UnmarkCurrent {Odznaèit aktuální partii}
translate C UnmarkFilter {Odznaèit filtrované partie}
translate C UnmarkAll {Odznaèit v¹echny partie}
translate C Spellchecking {Kontrola pravopisu}
translate C Players {Hráèi}
translate C Events {Turnaje}
translate C Sites {Místa}
translate C Rounds {Kola}
translate C DatabaseOps {Databázové operace}
translate C ReclassifyGames {ECO klasifikace partií}
translate C CompactDatabase {Zhutnit databázi}
translate C SortDatabase {Øadit databázi}
translate C AddEloRatings {Pøidat ELO rating}
translate C AutoloadGame {Automaticky otevírat partii è.}
translate C StripTags {Odstranit PGN znaèky}
translate C StripTag {Odstranit znaèku}
translate C Cleaner {Èi¹tìní databáze}
translate C CleanerHelp {
    Èi¹tìním databáze Scid provede u aktuální databáze v¹echny údr¾báøské akce, které zvolíte v seznamu.

    Pokud zvolíte ECO klasifikaci a mazání zdvojených partií pou¾ijí se aktuální nastavení z pøíslu¹ných dialogù.
}
translate C CleanerConfirm {
Jakmile je èi¹tìní jednou spu¹tìno, nemù¾e ji¾ být pøeru¹eno!

Tato akce mù¾e pro velké databáze trvat dlouhou dobu v závislosti na funkcích, které jste zvolili, a v závislosti na jejich stávajícím nastavení.

Jste si jisti, ¾e chcete zaèít s údr¾báøskými funkcemi, které jste zvolili?
}
# Twinchecker
translate C TwinCheckUndelete {pøevrátit; "u" obnoví obì)}
translate C TwinCheckprevPair {Pøedchozí dvojice}
translate C TwinChecknextPair {Následující dvojice}
translate C TwinChecker {Scid: Kontrola zdvojených partií}
translate C TwinCheckTournament {Partie turnaje:}
translate C TwinCheckNoTwin {®ádná duplicita  }
translate C TwinCheckNoTwinfound {Pro tuto partii nebyla nalezena ¾ádná zdvojená partie.\nPro zobrazení zdvojených partií v tomto oknì musíte nejprve pou¾ít funkci "Smazat zdvojené partie...". }
translate C TwinCheckTag {Sdílet znaèky...}
translate C TwinCheckFound1 {Scid na¹el $result zdvojených partií}
translate C TwinCheckFound2 { a nastavil jim pøíznak smazání}
translate C TwinCheckNoDelete {V této databázi nejsou ¾ádné partie ke smazání.}
translate C TwinCriteria1 { Va¹e nastavení pro hledání zdvojených partií mohou zpùsobit oznaèení\nnezdvojených partií s podobnými tahy jako zdvojené partie.}
translate C TwinCriteria2 {Pokud pro "stejné tahy" uvedete "Ne", doporuèuje se uvést "Ano" pro barvu, událost, místo, kolo, rok a mìsíc.\Chcete pøesto pokraèovat a smazat zdvojené partie? }
translate C TwinCriteria3 {Doporuèuje se uvést "Ano" pro alespoò dvì z nastavení "stejné místo", "stejné kolo" a "stejný rok".\nChcete pøesto pokraèovat a smazat zdvojené partie?}
translate C TwinCriteriaConfirm {Scid: Potvrdit nastavení dvojic}
translate C TwinChangeTag "Zmìnit následující tagy partie:\n\n"
translate C AllocRatingDescription "Tento pøíkaz pou¾ije aktuální soubor kontroly pøeklepù pro pøidání Elo ratingù do partií v této databázi. Pokud nìjaký hráè nemá aktuální rating, ale jeho rating z doby sehrání partie je uveden v souboru kontroly pøeklepù, bude tento jeho rating pøidán."
translate C RatingOverride "Pøepsat stávající nenulové ratingy?"
translate C AddRatings "Pøidat ratingy do:"
translate C AddedRatings {Scid pøidal $r Elo ratingù v $g partiích.}

#Bookmark editor
translate C NewSubmenu "Nové podmenu"

# Comment editor:
translate C AnnotationSymbols  {Anotaèní symboly:}
translate C Comment {Komentáø:}
translate C InsertMark {Vlo¾it znaèku}
translate C InsertMarkHelp {
Vlo¾it/odstranit znaèky: Vyberte barvu, typ, pole.
Vlo¾it/odstranit ¹ipku: Kliknìte pravým tlaèítkem na dvì pole.
}

# Nag buttons in comment editor:
translate C GoodMove {Dobrý tah}
translate C PoorMove {Slabý tah}
translate C ExcellentMove {Výborný tah}
translate C Blunder {Hrubá chyba}
translate C InterestingMove {Zajímavý tah}
translate C DubiousMove {Pochybný tah}
translate C WhiteDecisiveAdvantage {Bílý má rozhodující výhodu}
translate C BlackDecisiveAdvantage {Èerný má rozhodující výhodu}
translate C WhiteClearAdvantage {Bílý má jasnou výhodu}
translate C BlackClearAdvantage {Èerný má jasnou výhodu}
translate C WhiteSlightAdvantage {Bílý má malou výhodu}
translate C BlackSlightAdvantage {Èerný má malou výhodu}
translate C WhiteCrushing {Bílá má drtivou výhodu}
translate C BlackCrushing {Èerná má drtivou výhodu}
translate C Equality {Rovné ¹ance}
translate C Unclear {Nejasná pozice}
translate C Diagram {Diagram}

# Board search:
translate C BoardSearch {Hledat pozici}
translate C FilterOperation {Operace s aktuálním filtrem:}
translate C FilterAnd {A (Omezit filtr)}
translate C FilterOr {NEBO (Pøidat k filtru)}
translate C FilterIgnore {IGNOROVAT (Ignoruj filtr)}
translate C SearchType {Typ hledání:}
translate C SearchBoardExact {Pøesná pozice (v¹echny figury na stejných polích)}
translate C SearchBoardPawns {Pì¹ci (tentý¾ materiál, v¹ichni pì¹ci na stejných polích)}
translate C SearchBoardFiles {Sloupce (tentý¾ materiál, v¹ichni pì¹ci na stejných sloupcích)}
translate C SearchBoardAny {Jakákoliv (tentý¾ materiál, pì¹ci a figury kdekoliv)}
translate C SearchInRefDatabase { Hledat v databázi }
translate C LookInVars {Dívat se do variant}

# Material search:
translate C MaterialSearch {Hledat materiál}
translate C Material {Materiál}
translate C Patterns {Vzory}
translate C Zero {Nic}
translate C Any {Cokoliv}
translate C CurrentBoard {Aktuální pozice}
translate C CommonEndings {Typické koncovky}
translate C CommonPatterns {Typické vzory}
translate C MaterialDiff {Rozdíl v materiálu}
translate C squares {pole}
translate C SameColor {Stejnobarevné}
translate C OppColor {Nestejnobarevné}
translate C Either {Obojí}
translate C MoveNumberRange {Rozsah tahù}
translate C MatchForAtLeast {Shoda pro minimálnì}
translate C HalfMoves {pùltahù}

# Common endings in material search:
translate C EndingPawns {Pì¹cové koncovky}
translate C EndingRookVsPawns {Vì¾ proti pì¹cùm}
translate C EndingRookPawnVsRook {Vì¾ a 1 pì¹ec proti vì¾i}
translate C EndingRookPawnsVsRook {Vì¾ a pì¹ci proti vì¾i}
translate C EndingRooks {Vì¾ové koncovky}
translate C EndingRooksPassedA {Vì¾ové koncovky s volným a-pì¹cem}
translate C EndingRooksDouble {Ètyøvì¾ové koncovky}
translate C EndingBishops {Støelcové koncovky}
translate C EndingBishopVsKnight {Koncovky støelce proti jezdci}
translate C EndingKnights {Jezdcové koncovky}
translate C EndingQueens {Dámské koncovky}
translate C EndingQueenPawnVsQueen {Dáma a 1 pì¹ec proti dámì}
translate C BishopPairVsKnightPair {Dvojice støelcù proti dvojici jezdcù ve støední høe}

# Common patterns in material search:
translate C PatternWhiteIQP {Bílý dámský izolovaný pì¹ec}
translate C PatternWhiteIQPBreakE6 {Bílý dámský izolovaný pì¹ec: prùlom d4-d5 proti e6}
translate C PatternWhiteIQPBreakC6 {Bílý dámský izolovaný pì¹ec: prùlom d4-d5 proti c6}
translate C PatternBlackIQP {Èerný dámský izolovaný pì¹ec}
translate C PatternWhiteBlackIQP {Bílý dámský izolovaný pì¹ec proti èernému dámskému izolovanému pì¹ci}
translate C PatternCoupleC3D4 {Pár bílých izolovaných pì¹cù c3+d4}
translate C PatternHangingC5D5 {Èerní visící pì¹ci na c5 a d5}
translate C PatternMaroczy {Maroczyho centrum (s pì¹ci na c4 a e4)}
translate C PatternRookSacC3 {Obì» vì¾e na c3}
translate C PatternKc1Kg8 {O-O-O proti O-O (Kc1 proti Kg8)}
translate C PatternKg1Kc8 {O-O proti O-O-O (Kg1 proti Kc8)}
translate C PatternLightFian {Fianchetta na bílých polích (støelec g2 proti støelci b7)}
translate C PatternDarkFian {Fianchetta na èerných polích (støelec b2 proti støelci g7)}
translate C PatternFourFian {Ètyøi fianchetta (støelci na b2,g2,b7,g7)}

# Game saving:
translate C Today {Dnes}
translate C ClassifyGame {Klasifikovat partii}

# Setup position:
translate C EmptyBoard {Vyprázdnit ¹achovnici}
translate C InitialBoard {Výchozí pozice}
translate C SideToMove {Na tahu je}
translate C MoveNumber {Èíslo tahu}
translate C Castling {Ro¹áda}
translate C EnPassantFile {En Passant sloupec}
translate C ClearFen {Vyèistit FEN}
translate C PasteFen {Vlo¾it FEN}

translate C SaveAndContinue {Ulo¾it a pokraèovat}
translate C DiscardChangesAndContinue {Zru¹it zmìny\na pokraèovat}
translate C GoBack {Jít zpìt}

# Replace move dialog:
translate C ReplaceMove {Nahradit tah}
translate C AddNewVar {Pøidat novou variantu}
translate C NewMainLine {Nová hlavní varianta}
translate C ReplaceMoveMessage {Zde ji¾ existuje tah.

Mù¾ete ho nahradit, a zru¹it tak i v¹echny následující tahy, nebo mù¾ete vá¹ tah pøidat jako novou variantu.

(Zobrazení této zprávy mù¾ete v budoucnu potlaèit pøepnutím volby "Ptát se pøed nahrazením tahù" v menu Volby:Tahy.)}

# Make database read-only dialog:
translate C ReadOnlyDialog {Pokud databázi nastavíte jako jen ke ètení, nebudou povoleny ¾ádné zmìny.
®ádné partie nebude mo¾no ulo¾it ani pøepsat a ¾ádný mazací pøíznak nebude mo¾no zmìnit.
V¹echny výsledky operace øazení èi ECO klasifikace budou pouze doèasné.

Databázi mù¾ete uèinit opìt zapisovatelnou pomocí jejího zavøení a opìtovného otevøení.

Pøejete si skuteènì nastavit tuto databázi jako jen ke ètení?}

# Clear game dialog:
translate C ClearGameDialog {Tato partie byla zmìnìna.

Skuteènì chcete pokraèovat a zru¹it zmìny, které jste v ní uèinili?
}

# Exit dialog:
translate C ExitDialog {Opravdu si pøejete ukonèit Scid?}
translate C ExitUnsaved {Následující databáze obsahují partie s neulo¾enými zmìnami. Pokud nyní skonèíte, budou tyto zmìny ztraceny.}

# Import window:
translate C PasteCurrentGame {Vlo¾it aktuální partii}
translate C ImportHelp1 {Zapsat nebo vlo¾it partii ve formátu PGN do rámce nahoøe.}
translate C ImportHelp2 {Jakékoli chyby pøi importu partie budou zobrazeny zde.}
translate C OverwriteExistingMoves {Pøepsat stávající tahy?}

# ECO Browser:
translate C ECOAllSections {v¹echny ECO sekce}
translate C ECOSection {ECO sekce}
translate C ECOSummary {Souhrn pro}
translate C ECOFrequency {Frekvence subkódù pro}

# Opening Report:
translate C OprepTitle {Profil zahájení}
translate C OprepReport {Profil}
translate C OprepGenerated {Generován}
translate C OprepStatsHist {Statistika a historie}
translate C OprepStats {Statistika}
translate C OprepStatAll {V¹echny partie profilu}
translate C OprepStatBoth {Oba ratingovaní}
translate C OprepStatSince {Od}
translate C OprepOldest {Nejstar¹í partie}
translate C OprepNewest {Nejnovìj¹í partie}
translate C OprepPopular {Stávající popularita}
translate C OprepFreqAll {Frekvence za v¹echny roky: }
translate C OprepFreq1   {Bìhem posledního roku:     }
translate C OprepFreq5   {Bìhem posledních 5 let:    }
translate C OprepFreq10  {Bìhem posledních 10 let:   }
translate C OprepEvery {jednou z %u partií}
translate C OprepUp {více o %u%s v porovnání se v¹emi roky}
translate C OprepDown {ménì o %u%s v porovnání se v¹emi roky}
translate C OprepSame {¾ádná zmìna pøi porovnání se v¹emi roky}
translate C OprepMostFrequent {Nejèastìj¹í hráèi}
translate C OprepMostFrequentOpponents {Nejèastìj¹í soupeøi}
translate C OprepRatingsPerf {Ratingy a performance}
translate C OprepAvgPerf {Prùmìrné ratingy a performance}
translate C OprepWRating {Rating bílý}
translate C OprepBRating {Rating èerný}
translate C OprepWPerf {Performance bílý}
translate C OprepBPerf {Performance èerný}
translate C OprepHighRating {Partie s nejvy¹¹ím prùmìrným ratingem}
translate C OprepTrends {Výsledkový trend}
translate C OprepResults {Délka partií a frekvence}
translate C OprepLength {Délka partií}
translate C OprepFrequency {Frekvence}
translate C OprepWWins {Výhry bílý: }
translate C OprepBWins {Výhry èerný: }
translate C OprepDraws {Remízy:      }
translate C OprepWholeDB {celá databáze}
translate C OprepShortest {Nejkrat¹í výhry}
translate C OprepMovesThemes {Tahy a témata}
translate C OprepMoveOrders {Posloupnosti tahù vedoucí k profilované pozici}
translate C OprepMoveOrdersOne \
  {Nalezena pouze jedna posloupnost tahù vedoucích k této pozici:}
translate C OprepMoveOrdersAll \
  {Nalezeno %u posloupností tahù vedoucích k této pozici:}
translate C OprepMoveOrdersMany \
  {Nalezeno %u posloupností tahù vedoucích k této pozici. Prvních %u jsou:}
translate C OprepMovesFrom {Tahy z profilované pozice}
translate C OprepMostFrequentEcoCodes {Nejèastìj¹í ECO kódy}
translate C OprepThemes {Pozièní témata}
translate C OprepThemeDescription {Frekvence témat v prvních %u tazích ka¾dé partie}
translate C OprepThemeSameCastling {Ro¹ády na stejnou stranu}
translate C OprepThemeOppCastling {Ro¹ády na rùzné strany}
translate C OprepThemeNoCastling {Obì strany bez ro¹ády}
translate C OprepThemeKPawnStorm {Pì¹cový útok na královském køídle}
translate C OprepThemeQueenswap {Vymìnìné dámy}
translate C OprepThemeWIQP {Bílý izolovaný dámský pì¹ec}
translate C OprepThemeBIQP {Èerný izolovaný dámský pì¹ec}
translate C OprepThemeWP567 {Bílý pì¹ec na 5., 6. nebo 7. øadì}
translate C OprepThemeBP234 {Èerný pì¹ec na 2., 3. nebo 4. øadì}
translate C OprepThemeOpenCDE {Otevøený sloupec C, D nebo E}
translate C OprepTheme1BishopPair {Jedna strana má dvojici støelcù}
translate C OprepEndgames {Koncovky}
translate C OprepReportGames {Profilované partie}
translate C OprepAllGames {V¹echny partie}
translate C OprepEndClass {Materiálu na konci ka¾dé partie}
translate C OprepTheoryTable {Tabulka teorie}
translate C OprepTableComment {Generováno z %u partií s nejvy¹¹ím prùmìrným ratingem.}
translate C OprepExtraMoves {Extra poznámkové tahy v tabulce teorie}
translate C OprepMaxGames {Maximum tahù v tabulce teorie}
translate C OprepMergeMoves {Pøesunout limit pro slouèené hry}
translate C OprepMergeUnique {Sluèujte pouze jedineèné hry}
translate C OprepViewHTML {Zobrazit HTML}

# Player Report:
translate C PReportTitle {Profil hráèe}
translate C PReportColorWhite {bílými figurami}
translate C PReportColorBlack {èernými figurami}
translate C PReportMoves {po %s}
translate C PReportOpenings {Zahájení}
translate C PReportClipbase {Vyprázdnit schránku a zkopírovat do ní odpovídající partie}

# Piece Tracker window:
translate C TrackerSelectSingle {Levým tlaèítkem my¹i se tato figura vybere.}
translate C TrackerSelectPair {Levým tlaèítkem se tato figura vybere; pravým se vyberou obì stejné figury.}
translate C TrackerSelectPawn {Levým tlaèítkem se vybere tento pì¹ec; pravým se vybere v¹ech 8 pì¹cù.}
translate C TrackerStat {Statistika}
translate C TrackerGames {% partií s tahem na pole}
translate C TrackerTime {% èasu na ka¾dém poli}
translate C TrackerMoves {Tahy}
translate C TrackerMovesStart {Vlo¾te èíslo tahu, kterým má stopování zaèít.}
translate C TrackerMovesStop {Vlo¾te èíslo tahu, kterým má stopování skonèit.}

# Game selection dialogs:
translate C SelectAllGames {V¹echny partie v databázi}
translate C SelectFilterGames {Jen filtrované partie}
translate C SelectTournamentGames {Jen partie z aktuálního turnaje}
translate C SelectOlderGames {Jen star¹í partie}

# Delete Twins window:
translate C TwinsNote {Aby byly dvì partie vyhodnoceny jako zdvojené, musí být hrány tými¾ dvìma hráèi a dále musí splòovat kritéria, která nastavíte ní¾e. Pokud jsou nalezeny zdvojené partie, pak je krat¹í z nich vymazána. Rada: je vhodné provést pøed vymazáním zdvojených partií kontrolu pravopisu, nebo» to zdokonalí detekci zdvojených partií.}
translate C TwinsCriteria {Kritéria: Zdvojené partie musí mít...}
translate C TwinsWhich {Jaké partie prozkoumat}
translate C TwinsColors {Tyté¾ barvy u hráèù?}
translate C TwinsEvent {Tentý¾ turnaj?}
translate C TwinsSite {Toté¾ místo?}
translate C TwinsRound {Toté¾ kolo?}
translate C TwinsYear {Tentý¾ rok?}
translate C TwinsMonth {Tentý¾ mìsíc?}
translate C TwinsDay {Tentý¾ den?}
translate C TwinsResult {Tentý¾ výsledek?}
translate C TwinsECO {Tentý¾ ECO kód?}
translate C TwinsMoves {Tyté¾ tahy?}
translate C TwinsPlayers {Porovnání jmen:}
translate C TwinsPlayersExact {Pøesná shoda}
translate C TwinsPlayersPrefix {Jen první 4 znaky}
translate C TwinsWhen {Pokud se budou mazat zdvojené partie}
translate C TwinsSkipShort {Ignorovat v¹echny partie krat¹í ne¾ 5 tahù?}
translate C TwinsUndelete {Obnovit nejprve v¹echny partie?}
translate C TwinsSetFilter {Nastavit filtr na v¹echny vymazané zdvojené partie?}
translate C TwinsComments {V¾dy zachovat partie s komentáøi?}
translate C TwinsVars {V¾dy zachovat partie s variantami?}
translate C TwinsDeleteWhich {Kterou partii vymazat:}
translate C TwinsDeleteShorter {Krat¹í partii}
translate C TwinsDeleteOlder {Partii s ni¾¹ím èíslem}
translate C TwinsDeleteNewer {Partii s vy¹¹ím èíslem}
translate C TwinsDelete {Vymazat partie}

# Name editor window:
translate C NameEditType {Typ jména pro editaci}
translate C NameEditSelect {Partie k editaci}
translate C NameEditReplace {Nahradit}
translate C NameEditWith {}
translate C NameEditMatches {Shoduje se: Stiskni Ctrl+1 a¾ Ctrl+9 pro výbìr}

# Check games window:
translate C CheckGames {Zkontrolujte hry}
translate C CheckGamesWhich {Zkontrolujte hry}
translate C CheckAll {V¹echny hry}
translate C CheckSelectFilterGames {Pouze hry ve filtru}

# Classify window:
translate C Classify {Klasifikace}
translate C ClassifyWhich {ECO klasifikace kterých partií}
translate C ClassifyAll {V¹echny partie (pøepsat staré ECO kódy)}
translate C ClassifyYear {V¹echny partie hrané za poslední rok}
translate C ClassifyMonth {V¹echny partie hrané za poslední mìsíc}
translate C ClassifyNew {Jen partie, které jsou zatím bez ECO kódu}
translate C ClassifyCodes {Pou¾ít tyto ECO kódy}
translate C ClassifyBasic {Jen základní kódy ("B12", ...)}
translate C ClassifyExtended {Roz¹íøení Scidu  ("B12j", ...)}

# Compaction:
translate C NameFile {Jmenný soubor}
translate C GameFile {Partiový soubor}
translate C Names {Jména}
translate C Unused {Nepou¾ito}
translate C SizeKb {Velikost (kb)}
translate C CurrentState {Aktuální stav}
translate C AfterCompaction {Po zhu¹tìní}
translate C CompactNames {Zhustit jmenný soubor}
translate C CompactGames {Zhustit partiový soubor}
translate C NoUnusedNames "Nejsou ¾ádná nevyu¾itá jména, tak¾e jmenný soubor je ji¾ plnì zhu¹tìn."
translate C NoUnusedGames "Partiový soubor je ji¾ plnì zhu¹tìn."
translate C GameFileCompacted {Partiový soubor pro databázi byl zhu¹tìn.}

# Sorting:
translate C SortCriteria {Kritéria}
translate C AddCriteria {Pøidat kritéria}
translate C CommonSorts {Bì¾ná øazení}
translate C Sort {Setøídit}

# Exporting:
translate C AddToExistingFile {Pøidat partie do existujícího souboru?}
translate C ExportComments {Exportovat komentáøe?}
translate C ExportVariations {Exportovat varianty?}
translate C IndentComments {Odsazovat komentáøe?}
translate C IndentVariations {Odsazovat varianty?}
translate C ExportColumnStyle {Sloupcový styl (jeden tah na øádek)?}
translate C ExportSymbolStyle {Styl pro symbolické anotace:}
translate C ExportStripMarks {Odstranit kódové znaèky polí/¹ipek z komentáøù?}

# Goto game/move dialogs:
translate C LoadGameNumber {Vlo¾te èíslo partie:}
translate C GotoMoveNumber {Pøejít na tah èíslo:}

# Copy games dialog:
translate C CopyAllGames {Zkopírujte v¹echny hry do}
translate C CopyGames {Kopírovat partie}
translate C CopyConfirm {
 Skuteènì chcete kopírovat
 [::utils::thousands $nGamesToCopy] filtrovaných partií
 z databáze "$fromName"
 do databáze "$targetName"?
}
translate C CopyErr {Nelze zkopírovat partie}
translate C CopyErrSource {zdrojová databáze}
translate C CopyErrTarget {cílová databáze}
translate C CopyErrNoGames {nemá ¾ádné partie ve filtru}
translate C CopyErrReadOnly {je pouze ke ètení}
translate C CopyErrNotOpen {není otevøena}

# Colors:
translate C LightSquares {Bílá pole}
translate C DarkSquares {Èerná pole}
translate C SelectedSquares {Vybraná pole}
translate C SuggestedSquares {Pole navrhovaných tahù}
translate C WhitePieces {Bílé figury}
translate C BlackPieces {Èerné figury}
translate C WhiteBorder {Obrys bílých figur}
translate C BlackBorder {Obrys èerných figur}

# Novelty window:
translate C FindNovelty {Hledat novinku}
translate C Novelty {Novinka}
translate C NoveltyInterrupt {Hledání novinky pøeru¹eno}
translate C NoveltyNone {V této partii nebyla nalezena ¾ádná novinka}
translate C NoveltyHelp {
Scid bude hledat první tah aktuální partie, který dosáhne pozice, která se nevyskytla ve vybrané databázi ani v knihovnì zahájení ECO.
}

# Sounds configuration:
translate C SoundsFolder {Adresáø se zvukovými soubory}
translate C SoundsFolderHelp {Adresáø by mìl obsahovat soubory King.wav, a.wav, 1.wav, atd.}
translate C SoundsAnnounceOptions {Volby oznamování tahu}
translate C SoundsAnnounceNew {Oznamovat tahy pøi jejich provedení}
translate C SoundsMoveSoundOnly {Pouze zvuk pøesunout (vypnout oznámení)}
translate C SoundsAnnounceForward {Oznamovat tahy pøi posunu o tah vpøed}
translate C SoundsAnnounceBack {Oznamovat pøi vzetí tahu zpìt nebo posunu o tah zpìt}
translate C SoundsSoundDisabled {Scid nemohl najít zvukový balíèek Snack pøi spu¹tìní;\nZvuk je vypnutý.}

# Upgrading databases:
translate C Upgrading {Upgrade}
translate C ConfirmOpenNew {
Toto je starý formát (Scid 3) databáze, jen¾ není mo¾no otevøít ve Scidu 4. Verze s novým formátem (Scid 4) pøitom ji¾ byla vytvoøena.

Chcete otevøít verzi s novým formátem datábáze?
}
translate C ConfirmUpgrade {
Toto je starý formát (Scid 3) databáze. K otevøení ve Scidu 4 je nutno databázi nejprve zkonvertovat do nového formátu.

Upgrade vytvoøí novou verzi databáze.

Tento úkon mù¾e zabrat trochu èasu, ale je tøeba jej provést pouze jednou. Mù¾ete ho pøeru¹it, pokud bude trvat pøíli¹ dlouho.

Chcete tuto databázi upgradovat nyní?
}

# Recent files options:
translate C RecentFilesMenu {Poèet nedávných souborù v menu Soubor}
translate C RecentFilesExtra {Poèet nedávných souborù v extra podmenu}

# My Player Names options:
translate C MyPlayerNamesDescription {
Otevøe seznam se jmény preferovaných hráèù, ka¾dé jméno na jeden øádek. Zástupné znaky (tj. "?" pro jakýkoliv jeden znak, "*" pro jakoukoliv sekvenci znakù) jsou povoleny.

V¾dy, kdy¾ se natáhne partie hráèe uvedeného v seznamu, ¹achovnice v hlavním oknì se otoèí, jestli¾e je to nutné k zobrazení partie z perspektivy tohoto hráèe.
}

#Coach
translate C showblunderexists {ukázat pøítomnost hrubé chyby}
translate C showblundervalue {ukázat hodnotu hrubé chyby}
translate C showscore {ukázat skóre}
translate C coachgame {kouèovací partie}
translate C configurecoachgame {konfigurovat kouèovací partii}
translate C configuregame {Konfigurace partie}
translate C Phalanxengine {Herní program phalanx}
translate C Coachengine {Kouèovací herní program}
translate C difficulty {obtí¾nost}
translate C hard {nároèná}
translate C easy {snadná}
translate C Playwith {Hrát s}
translate C white {bílý}
translate C black {èerný}
translate C both {oba}
translate C Play {Hrát}
translate C Noblunder {®ádná hrubá chyba}
translate C blunder {hrubá chyba}
translate C Noinfo {-- ®ádné informace --}
translate C PhalanxOrTogaMissing {Phalanx nebo Toga nenalezen}
translate C moveblunderthreshold {chyba je hrubá, jestli¾e ztráta je vìt¹í ne¾}
translate C limitanalysis {omezit èas analýzy herního programu}
translate C seconds {sekund}
translate C Abort {Pøeru¹it}
translate C Resume {Pokraèovat}
translate C OutOfOpening {Mimo otevøení}
translate C NotFollowedLine {Nenásledoval jste variantu}
translate C DoYouWantContinue {Chcete pokraèovat?}
translate C CoachIsWatching {Kouè sleduje}
translate C Ponder {Neustálé pøemý¹lení}
translate C LimitELO {Omezit sílu ELO}
translate C DubiousMovePlayedTakeBack {Byl zahrán pochybný tah, chcete ho vrátit?}
translate C WeakMovePlayedTakeBack {Byl zahrán slabý tah, chcete ho vrátit?}
translate C BadMovePlayedTakeBack {Byl zahrán ¹patný tah, chcete ho vrátit?}
translate C Iresign {Vzdávám}
translate C yourmoveisnotgood {vá¹ tah není dobrý}
translate C EndOfVar {Konec varianty}
translate C Openingtrainer {Trenér zahájení}
translate C DisplayCM {Zobrazit mo¾né vhodné tahy}
translate C DisplayCMValue {Zobrazit hodnut mo¾ných vhodných tahù}
translate C DisplayOpeningStats {Ukázat statistiku}
translate C ShowReport {Ukázat report}
translate C NumberOfGoodMovesPlayed {dobrých odehraných tahù}
translate C NumberOfDubiousMovesPlayed {pochybných odehraných tahù}
translate C NumberOfMovesPlayedNotInRepertoire {odehraných tahù, které nejsou v repertoáru}
translate C NumberOfTimesPositionEncountered {výskytù pozice}
translate C PlayerBestMove  {Dovolit pouze nejlep¹í tahy}
translate C OpponentBestMove {Soupeø hraje nejlep¹í tahy}
translate C OnlyFlaggedLines {Pouze oznaèené varianty}
translate C resetStats {Smazat statistiku}
translate C Repertoiretrainingconfiguration {Konfigurace tréninku repertoáru}
translate C Loadingrepertoire {Natahuji repertoár}
translate C Movesloaded {Tahy nata¾eny}
translate C Repertoirenotfound {Repertoár nenalezen}
translate C Openfirstrepertoirewithtype {Otevøít první databázi repertoáru s ikonou/typem nastavenou pro správnou stranu}
translate C Movenotinrepertoire {Tah není v repertoáru}
translate C PositionsInRepertoire {Pozice v repertoáru}
translate C PositionsNotPlayed {Nehrané pozice}
translate C PositionsPlayed {Hrané pozice}
translate C Success {Úspìch}
translate C DubiousMoves {Pochybné tahy}
translate C OutOfRepertoire {Mimo repertoár}
translate C ConfigureTactics {Konfigurovat taktiku}
translate C ResetScores {Smazat skóre}
translate C LoadingBase {Natahuji databázi}
translate C Tactics {Taktika}
translate C ShowSolution {Ukázat øe¹ení}
translate C NextExercise {Dal¹í cvièení}
translate C PrevExercise {pøedchozí cvièení}
translate C StopTraining {Ukonèit trénink}
translate C Next {Dal¹í}
translate C ResettingScore {Ma¾u skóre}
translate C LoadingGame {Natahuji partii}
translate C MateFound {Mat nalezen}
translate C BestSolutionNotFound {Nejlep¹í øe¹ení nenalezeno!}
translate C MateNotFound {Mat nenalezen}
translate C ShorterMateExists {Existuje rychlej¹í mat}
translate C ScorePlayed {Odehrané skóre}
translate C Expected {oèekávaný}
translate C ChooseTrainingBase {Vybrat tréninkovou databázi}
translate C Thinking {Pøemý¹lím}
translate C AnalyzeDone {Analýza hotova}
translate C WinWonGame {Vyhrát vyhranou partii}
translate C Lines {Varianty}
translate C ConfigureUCIengine {Konfigurovat nástroj UCI}
translate C SpecificOpening {Vybrané zahájení}
translate C StartNewGame {Zaèít novou hru}
translate C FixedLevel {Pevná úroveò}
translate C Opening {Zahájení}
translate C RandomLevel {Náhodná úroveò}
translate C StartFromCurrentPosition {Zaèít z aktuální pozice}
translate C FixedDepth {Pevná hloubka}
translate C Nodes {Uzly} 
translate C Depth {Hloubka}
translate C Time {Èas} 
translate C SecondsPerMove {Sekund na tah}
translate C Engine {Herní program}
translate C TimeMode {Re¾im èasu}
translate C TimeBonus {Èas + bonus}
translate C TimeMin {min}
translate C TimeSec {s}
translate C AllExercisesDone {V¹echna cvièení hotova}
translate C MoveOutOfBook {Tah mimo knihovnu zahájení}
translate C LastBookMove {Poslední tah z knihovny zahájení}
translate C AnnotateSeveralGames {Anotovat nìkolik partií\od aktuální do:}
translate C FindOpeningErrors {Najít chyby v zahájení}
translate C MarkTacticalExercises {Oznaèit taktická cvièení}
translate C UseBook {Pou¾ívat knihovnu zahájení}
translate C MultiPV {Nìkolik variant}
translate C Hash {Hashovací pamì»}
translate C OwnBook {Pou¾ít knihovnu zahájení herního programu}
translate C BookFile {Knihovna zahájení}
translate C AnnotateVariations {Anotovat varianty}
translate C ShortAnnotations {Krátké anotace}
translate C addAnnotatorTag {Pøidat znaèku anotátora}
translate C AddScoreToShortAnnotations {Pøidat skóre ke krátkým anotacím}
translate C Export {Export}
translate C BookPartiallyLoaded {Knihovna zahájení èásteènì nata¾ena}
translate C Calvar {Propoèet variant}
translate C ConfigureCalvar {Konfigurace}
# Opening names used in tacgame.tcl
translate C Reti {Rétiho}
translate C English {Anglická}
translate C d4Nf6Miscellaneous {1.d4 Nf6 rùzné}
translate C Trompowsky {Opoèenského hra}
translate C Budapest {Budape¹»ský gambit}
translate C OldIndian {Staroindická}
translate C BenkoGambit {Vol¾ský gambit}
translate C ModernBenoni {Moderní Benoni}
translate C DutchDefence {Holandská}
translate C Scandinavian {Skandinávská}
translate C AlekhineDefence {Aljechinova}
translate C Pirc {Pircova}
translate C CaroKann {Caro-Kann}
translate C CaroKannAdvance {Caro-Kann, zavøený systém}
translate C Sicilian {Sicilská}
translate C SicilianAlapin {Sicilská, Alapinova varianta}
translate C SicilianClosed {Zavøená sicilská}
translate C SicilianRauzer {Sicilská, Rauzerùv útok}
translate C SicilianDragon {Sicilská, draèí varianta}
translate C SicilianScheveningen {Sicilská, scheveningská varianta}
translate C SicilianNajdorf {Sicilská, Najdorfova varianta}
translate C OpenGame {Otevøená hra}
translate C Vienna {Vídeòská}
translate C KingsGambit {Královský gambit}
translate C RussianGame {Ruská}
translate C ItalianTwoKnights {Italská/Hra dvou jezdcù v obranì}
translate C Spanish {©panìlská}
translate C SpanishExchange {Výmìnná ¹panìlská}
translate C SpanishOpen {Otevøená ¹panìlská}
translate C SpanishClosed {Zavøená ¹panìlská}
translate C FrenchDefence {Francouzská}
translate C FrenchAdvance {Francouzská, Steinitzùv systém}
translate C FrenchTarrasch {Francouzská, Tarraschùv systém}
translate C FrenchWinawer {Francouzská, Nimcovièùv systém}
translate C FrenchExchange {Francouzská, výmìnná varianta}
translate C QueensPawn {Dámským pì¹cem}
translate C Slav {Slovanská}
translate C QGA {Pøijatý dámský gambit}
translate C QGD {Odmítnutý dámský gambit}
translate C QGDExchange {Výmìnný dámský gambit}
translate C SemiSlav {Poloslovanská}
translate C QGDwithBg5 {Dámský gambit se Sg5}
translate C QGDOrthodox {Ortodoxní dámský gambit}
translate C Grunfeld {Grünfeldova indická}
translate C GrunfeldExchange {Grünfeldova burza}
translate C GrunfeldRussian {Grünfeld Rus}
translate C Catalan {Katalánská}
translate C CatalanOpen {Catalan Open}
translate C CatalanClosed {Katalán¹tina zavøeno}
translate C QueensIndian {Dámská indická}
translate C NimzoIndian {Nimcovièova indická}
translate C NimzoIndianClassical {Nimcovièova indická, klasický systém}
translate C NimzoIndianRubinstein {Nimcovièova indická, Rubinsteinùv systém}
translate C KingsIndian {Královská indická}
translate C KingsIndianSamisch {Královská indická, Sämischùv útok}
translate C KingsIndianMainLine {Královská indická, hlavní varianta}

# FICS
translate C ConfigureFics {Konfigurovat FICS}
translate C FICSGuest {Pøihlásit jako host}
translate C FICSServerPort {Port serveru}
translate C FICSServerAddress {IP adresa}
translate C FICSRefresh {Obnovit}
translate C FICSTimesealPort {Port timesealu}
translate C FICSSilence {Ticho}
translate C FICSOffers {Nabídky}
translate C FICSConsole {Konzola}
translate C FICSGames {Hry}
translate C FICSUnobserve {Ukonèit sledování partie}
translate C FICSProfile {Zobrazit va¹i historii a profil}
translate C FICSRelayedGames {©tafetové hry}
translate C FICSFindOpponent {Najít soupeøe}
translate C FICSTakeback {Vrátit tah}
translate C FICSTakeback2 {Vrátit tah 2}
translate C FICSInitTime {Poèáteèní èas (min)}
translate C FICSIncrement {Inkrement (s)}
translate C FICSRatedGame {Partie zapoèítaná do ratingu}
translate C FICSAutoColour {automatické}
translate C FICSManualConfirm {potvrdit ruènì}
translate C FICSFilterFormula {Filtrovat formulí}
translate C FICSIssueSeek {Hledání problému}
translate C FICSChallenge {Výzva}
translate C FICSAccept {pøijmout}
translate C FICSDecline {pokles}
translate C FICSColour {Barva}
translate C FICSSend {poslat}
translate C FICSConnect {Pøipojit}
translate C FICSdefaultuservars {Pou¾ít výchozí promìnné}
translate C FICSObserveconfirm {Chcete sledovat partii}
translate C FICSpremove {Povolit pøedbì¾né pøesunutí}
translate C FICSObserve {Pozorovat}
translate C FICSRatedGames {Ohodnocené hry}
translate C FICSUnratedGames {Nehodnocené hry}
translate C FICSRated {Ohodnoceno}
translate C FICSUnrated {Nehodnoceno}
translate C FICSRegisteredPlayer {Pouze registrovaný hráè}
translate C FICSFreePlayer {Pouze bezplatný hráè}
translate C FICSNetError {Chyba sítì\Nelze se pøipojit}

# Game review
translate C GameReview {Prohlí¾ení partie}
translate C GameReviewTimeExtended {Èas prodlou¾en}
translate C GameReviewMargin {Okraj chyby}
translate C GameReviewAutoContinue {Automaticky pokraèovat, je-li tah správný}
translate C GameReviewReCalculate {Pou¾ijte del¹í dobu}
translate C GameReviewAnalyzingMovePlayedDuringTheGame {Analyzuji tahy sehrané v partii}
translate C GameReviewAnalyzingThePosition {Analyzuji pozici}
translate C GameReviewEnterYourMove {Zadejte vá¹ tah}
translate C GameReviewCheckingYourMove {Kontroluji vá¹ tah}
translate C GameReviewYourMoveWasAnalyzed {Vá¹ tah by zanalyzován}
translate C GameReviewYouPlayedSameMove {Hrál jste ten samý tah jako v partii}
translate C GameReviewScoreOfYourMove {Skóre va¹ho tahu}
translate C GameReviewGameMoveScore {Skóre tahu v partii}
translate C GameReviewEngineScore {Skóre herního programu}
translate C GameReviewYouPlayedLikeTheEngine {Hrál jste jako herní program}
translate C GameReviewNotEngineMoveButGoodMove {Není to tah herního programu, ale je to také dobrý tah}
translate C GameReviewMoveNotGood {Tento tah není dobrý, skóre je}
translate C GameReviewMovesPlayedLike {Tahy hrané jako}
translate C GameReviewMovesPlayedEngine {Tahy hrané jako herním programem}

# Correspondence Chess Dialogs:
translate C CCDlgCGeneraloptions {Obecná nastavení}
translate C CCDlgLoginName  {Pøihla¹ovací jméno:}
translate C CCDlgPassword   {Heslo:}
translate C CCDlgShowPassword {Zobrazit heslo}

# Connect Hardware dialogs
translate C ExtHWConfigConnection {Konfigurovat externí hardware}
translate C ExtHWPort {Port}
translate C ExtHWEngineCmd {Pøíkaz herního programu}
translate C ExtHWEngineParam {Parametr herního programu}
translate C ExtHWShowButton {Ukázat tlaèítko}
translate C ExtHWHardware {Hardware}
translate C ExtHWNovag {Novag Citrine}
translate C ExtHWInputEngine {Vstupní pøístroj}
translate C ExtHWNoBoard {®ádná ¹achovnice}
translate C NovagReferee {Rozhodèí}

# Input Engine dialogs
translate C IEConsole {Konzola vstupního pøístroje}
translate C IESending {Tahy odeslané pro}
translate C IESynchronise {Synchronizovat}
translate C IERotate  {Otoèit}
translate C IEUnableToStart {Nemohu spustit vstupní pøístroj:}

# Calculation of Variations
translate C DoneWithPosition {Hotovo s pozicí}

translate C Board {©achovnice}
translate C showGameInfo {Ukázat informace o partii}
translate C autoResizeBoard {Automatická zmìna velikosti ¹achovnice}
translate C DockTop {Pøesunout nahoru}
translate C DockBottom {Pøesunout dolù}
translate C DockLeft {Pøesunout doleva}
translate C DockRight {Pøesunout doprava}
translate C Undock {Odpojit}

# Switcher window
translate C AboutDatabase {O této databázi}
translate C ChangeIcon {Zmìnit ikonu...}
translate C NewGameListWindow {Nové okno se seznamem her}
translate C LoadatStartup {Naèíst pøi spu¹tìní}

# Gamelist window
translate C ShowHideDB {Zobrazit/skrýt databáze}
translate C ChangeFilter {Vymìòte filtr}
translate C ChangeLayout {Naèíst/Ulo¾it/Zmìnit kritéria øazení a rozlo¾ení sloupcù}
translate C ShowHideStatistic {Zobrazit/Skrýt statistiky}
translate C BoardFilter {Zobrazit pouze hry, které odpovídají aktuální pozici na desce}
translate C CopyGameTo {Kopírovat hru do}
translate C FindBar {Najít Bar}
translate C FindCurrentGame {Najít aktuální hru}
translate C DeleteGame {Smazat hru}
translate C UndeleteGame {Obnovit hru}
translate C ResetSort {Obnovit øazení}

translate C ConvertNullMove {Pøevést nulové pohyby na komentáøe}
translate C SetupBoard {Instalaèní deska}
translate C Rotate {Støídat}
translate C SwitchColors {Pøepnout barvy}
translate C FlipBoard {Flip Board}
translate C ImportPGN {Importujte hru PGN}
translate C ImportingFiles {Import souborù PGN do}
translate C ImportingFrom {Import z}
translate C ImportingIn {Importovat hry do}
translate C UseLastTag {Pou¾ijte ¹títky z poslední hry}
translate C Random {Náhodný}
translate C BackToMainline {Vra»te se na hlavní øadu}
translate C LeaveVariant {Ponechat variantu}
translate C Autoplay {Automatické pøehrávání}
translate C ShowHideCoords {Zobrazit/skrýt Coord.}
translate C ShowHideEvalBar {Zobrazit/skrýt panel hodnocení}
translate C ShowHideMaterial {Zobrazit/skrýt materiál}
translate C SelectMarker {Vyberte Marker}
translate C FullScreen {Celá obrazovka}
translate C FilterStatistic {Filtrovat statistiky}
translate C MakeCorrections {Proveïte opravy}
translate C Surnames {Pøíjmení}
translate C Ambiguous {Dvojznaèný}

#Preferences Dialog
translate C OptionsToolbar "Nástrojová li¨ta"
translate C OptionsBoard "©achovnice"
translate C OptionsBoardSize "Velikost ¹achovnice"
translate C OptionsBoardPieces "Styl figur"
translate C OptionsInternationalization "Internacionalizace"
translate C OptionsTablebaseDir "Vyberte a¾ 4 základní slo¾ky tabulky:"

# Evaluation bar
translate C BestMoveArrow "Nejlep¹í pohybová ¹ipka"
translate C NewLocalEngine "+ nový motor..."
}
# end of english.tcl
