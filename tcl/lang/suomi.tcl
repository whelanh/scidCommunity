# Text for menu names and status bar help messages in English.
# Part of Scid (Shane's Chess Information Database).
#
# Instructions for adding a new language:
#
# (1) Choose a letter code for the language. Currently assigned codes are:
#      E=English, D=Deutsch, F=Francais, S=Spanish, B=Brasil Portuguese,
#      P=Polish, N=Nederlands, W=Swedish, O=Norsk, C=Czech, H=Hungarian,
#      Y=Serbian.
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

proc setLanguage_U {} {

# File menu:
menuText U File "Tiedosto" 0
menuText U FileNew "Uusi..." 0 {Luo uusi Scid-tietokanta}
menuText U FileOpen "Avaa..." 0 {Avaa olemassaoleva Scid-tietokanta}
menuText U FileClose "Sulje" 0 {Sulje Scid-tietokanta}
menuText U FileFinder "Etsi" 0 {Avaa tiedostonhakuikkuna}
menuText U FileBookmarks "Kirjanmerkit" 0 {Kirjanmerkit-valikko (pikanppin: Ctrl+K)}
menuText U FileBookmarksAdd "Lis kirjanmerkki" 7 \
  {Lis kirjanmerkki nykyiseen peliin ja asemaan tietokannassa}
menuText U FileBookmarksFile "Tallenna kirjanmerkki" 5 \
  {Tallenna kirjanmerkki nykyisest pelist ja asemasta}
menuText U FileBookmarksEdit "Muokkaa kirjanmerkkej..." 0 \
  {Muokkaa kirjanmerkkivalikkoja}
menuText U FileBookmarksList "Nyt kansiot yhdess listassa" 0 \
  {Nyt kirjanmerkit yhdess listassa, ei alivalikoissa}
menuText U FileBookmarksSub "Nyt kansiot alivalikoina" 0 \
  {Nyt kirjanmerkkikansiot alivalikkoina, ei yhdess listassa}
menuText U FileMaint "Yllpito" 0 {Yllpitotykalut Scid-tietokannoille}
menuText U FileMaintWin "Yllpitoikkuna" 0 \
  {Avaa/sulje yllpitoikkuna}
menuText U FileMaintCompact "Tiivist tietokanta..." 0 \
  {Tiivist tietokannan, tuhoaa poistetuksi merkityt pelit ja kyttmttmt nimet}
menuText U FileMaintClass "ECO-luokittelu..." 2 \
  {Tarkista kaikkien pelien ECO-koodi}
menuText U FileMaintSort "Lajittele tietokanta..." 0 \
  {Lajittele tietokannan pelit}
menuText U FileMaintDelete "Poista kaksoiskappaleet..." 0 \
  {Etsii pelien kaksoiskappaleet ja merkitsee ne poistettaviksi}
menuText U FileMaintTwin "Kaksoiskappaleet" 0 \
  {Avaa/pivit kaksoiskappaleet-ikkuna}
menuText U FileMaintName "Nimet ja oikeinkirjoitus" 0 {Nimien muokkaus- ja oikeinkirjoitustykalut}
menuText U FileMaintNameEditor "Nimet" 0 \
  {Avaa/sulje nimien muokkausikkuna}
menuText U FileMaintNamePlayer "Pelaajien nimet..." 0 \
  {Tarkista pelaajien nimien oikeinkirjoitus}
menuText U FileMaintNameEvent "Tapahtumien nimet..." 0 \
  {Tarkista tapahtumien nimien oikeinkirjoitus}
menuText U FileMaintNameSite "Paikannimet..." 1 \
  {Tarkista paikannimien oikeinkirjoitus}
menuText U FileMaintNameRound "Kierrosten nimet..." 0 \
  {Tarkista kierrosten nimien oikeinkirjoitus}
menuText U FileReadOnly "Vain luku..." 0 \
  {Est muutokset nykyiseen tietokantaan}
menuText U FileSwitch "Vaihda tietokanta" 3 \
  {Vaihda toiseen avattuun tietokantaan}
menuText U FileOpenLichessTournament "Avaa Lichess-turnaus" 0 {Lataa ja avaa live-Lichess-turnauslhetyspelej}
menuText U FileImportLichess "Tuo Lichessini" 0 {Tuo pelej Lichess-tililtsi}
menuText U FileImportChessCom "Tuo minun chess.com" 0 {Tuo pelej chess.com-tililtsi}
menuText U FileExit "Lopeta" 0 {Lopeta ja sulje Scid}
menuText U FileMaintFixBase "Korjaa tietokanta" 0 {Yrit korjata vaurioitunut tietokanta}

# Edit menu:
menuText U Edit "Muokkaa" 0
menuText U EditAdd "Lis muunnelma" 0 {Lis muunnelma tmn siirron kohdalle}
menuText U EditDelete "Poista muunnelma" 0 {Poista tmn siirron kohdalla oleva muunnelma}
menuText U EditFirst "Ensimmiseksi" 0 \
  {Ylenn muunnelma ensimmiseksi sivumuunnelmaksi}
menuText U EditMain "Plinjaksi" 1 \
  {Ylenn muuunnelma plinjaksi}
menuText U EditTrial "Kokeile muunnelmaa" 0 \
  {Aloita/lopeta tila, jossa voit testata muunnelmiasi laudalla}
menuText U EditStrip "Poista" 2 {Poista siirtoja, kommentteja tai muunnelmia}
menuText U EditUndo "Kumoa" 1 {Peruuta viimeisin muutos}
menuText U EditRedo "Tee uudelleen" 0 {Tee uudelleen viimeisin muutos}
menuText U EditStripComments "Kommentit" 1 \
  {Poista kaikki kommentit ja arvioinnit pelist}
menuText U EditStripVars "Muunnelmat" 3 {Poista kaikki muunnelmat pelist}
menuText U EditStripBegin "Siirtoja alusta" 1 \
  {Poista siirtoja pelin alusta}
menuText U EditStripEnd "Siirtoja lopusta" 3 \
  {Poista siirtoja lopusta}
menuText U EditReset "Tyhjenn leikekanta" 0 \
  {Poista kaikki pelit leiketietokannasta}
menuText U EditCopy "Kopioi peli leikekantaan" 0 \
  {Kopioi nykyinen peli leiketietokantaan}
menuText U EditPaste "Liit leikekannasta" 0 \
  {Liit leiketietokannan aktiivinen peli thn}
menuText U EditPastePGN "Liit leikepydn teksti PGN-pelin..." 12 \
  {Tulkitse leikepydll oleva teksti PGN-muotoiseksi peliksi ja liit thn}
menuText U EditSetup "Uusi asema..." 0 \
  {Luo uusi alkuasema pelille}
menuText U EditCopyBoard "Kopioi asema" 0 \
  {Kopioi nykyinen asema leikepydlle FEN-muodossa}
menuText U EditPasteBoard "Liit asema" 0 \
  {Liit leikepydll oleva FEN-teksti alkuasemaksi}
menuText U ConfigureScid "Asetukset..." 0 {Mrit kaikki SCID-asetukset}

# Game menu:
menuText U Game "Peli" 0
menuText U GameNew "Uusi peli" 0 \
  {Aloita uusi peli, poista kaikki vanhat siirrot}
menuText U GameFirst "Lataa ensimminen" 6 {Lataa ensimminen suodatetuista peleist}
menuText U GamePrev "Lataa edellinen" 7 {Lataa edellinen peli suodatetuista}
menuText U GameReload "Lataa uudelleen" 1 \
  {Lataa nykyinen peli uudelleen, poista tehdyt muutokset}
menuText U GameNext "Lataa seuraava" 6 {Lataa seuraava peli suodatetuista}
menuText U GameLast "Lataa viimeinen" 6 {Lataa viimeinen suodatetuista peleist}
menuText U GameRandom "Lataa satunnainen" 2 {Lataa sattumanvaraisesti valittu peli suodatetuista}
menuText U GameNumber "Lataa numero..." 8 \
  {Lataa peli, jonka numeron annat avautuvassa ikkunassa}
menuText U GameReplace "Tallenna: Korvaa..." 8 \
  {Tallenna nykyinen peli korvaten vanha versio uusilla tiedoilla}
menuText U GameAdd "Tallenna: Lis uusi..." 13 \
  {Tallenna nykyinen peli tietokantaan uudeksi peliksi}
menuText U GameDeepest "Tunnista avaus" 0 \
  {Tunnista avauksen ECO-koodi avauskirjaa kytten}
menuText U GameGotoMove "Siirry siirtoon..." 5 \
  {Siirry mritetyn siirron kohdalle nykyisess peliss}
menuText U GameNovelty "Etsi uutuus..." 0 \
  {Etsi pelin ensimminen ennen pelaamaton siirto}

# Search Menu:
menuText U Search "Etsi" 0
menuText U SearchReset "Alusta suodatin" 0 {Nyt kaikki pelit, nollaa suodatin}
menuText U SearchNegate "Knteinen suodatin" 0 {Suodatin nytt aiemmin poissuodatetut pelit}
menuText U SearchCurrent "Nykyinen asema..." 0 {Etsi nykyist asemaa tietokannasta}
menuText U SearchHeader "Otsikko..." 0 {Etsi otsikkotiedon perusteella (pelaaja, tapahtuma jne.)}
menuText U SearchMaterial "Materiaali/asema..." 0 {Etsi materiaalin tai aseman tunnusmerkkien perusteella}
menuText U SearchUsing "Haku tiedostolla..." 0 {Etsi kytten apuna erillist hakutiedostoa}

# Windows menu:
menuText U Windows "Ikkunat" 0
menuText U WindowsComment "Kommentit" 0 {Avaa/sulje kommenttimuokkain}
menuText U WindowsGList "Peliluettelo" 0 {Avaa/sulje peliluettelo}
menuText U WindowsPGN "PGN-listaus" 1 \
  {Avaa/sulje  PGN-listaus (pelinotaatio)}
menuText U WindowsPList "Pelaajahaku" 1 {Avaa/sulje pelaajahaku}
menuText U WindowsTmt "Turnaushaku" 1 {Avaa/sulje turnaushaku}
menuText U WindowsSwitcher "Tietokannan vaihto" 0 \
  {Avaa/sulje Tietokannan vaihtoikkuna}
menuText U WindowsMaint "Yllpito" 0 \
  {Avaa/sulje yllpitoikkuna}
menuText U WindowsECO "ECO-selain" 1 {Avaa/sulje ECO-avauskirjaston selain}
menuText U WindowsStats "Tilastot" 6 \
  {Avaa/sulje tilastoikkuna}
menuText U WindowsTree "Puunkym" 3 {Avaa/sulje puunkym}
menuText U WindowsBook "Avauskirja" 8 {Avaa/sulje avauskirja}
menuText U WindowsCorrChess "Kirjeshakki" 6 {Avaa/sulje kirjeshakki-ikkuna}
menuText U WindowsGraph "Analyysikaavio" 0 {Avaa Graafi-ikkuna, jossa on siirtoajat ja arvioinnit}

# Tools menu:
menuText U Tools "Tykalut" 1
menuText U ToolsConfigureEngines "Konfiguroi moottorit" 10 {Hallitse moottoreiden kokoonpanoa}
menuText U ToolsAnalysis "Analyysimoottori #1..." 18 \
  {Kynnist/pysyt analyysimoottori}
menuText U ToolsAnalysis2 "Analyysimoottori #2..." 18 \
  {Kynnist/pysyt toinen analyysimoottori}
menuText U ToolsCross "Ristitaulukko" 0 {Nyt turnauksen ristitaulukko tlle pelille}
menuText U ToolsFilterGraph "Suhteellinen graafi" 13 {Avaa/sulje suodatingraafi suhteellisilla arvoilla}
menuText U ToolsAbsFilterGraph "Absoluuttinen graafi" 17 {Avaa/sulje suodatingraafi absoluuttisilla arvoilla}
menuText U ToolsOpReport "Avausraportti" 0 {Luo nykyisest asemasta avausraportti}
menuText U ToolsOpenBaseAsTree "Avaa kanta puuna..." 0   {Avaa tietokanta ja ksittele sit puurakenteena}
menuText U ToolsOpenRecentBaseAsTree "Avaa viimeaikainen kanta puuna" 1   {Avaa viimeaikainen tietokanta ja ksittele sit puurakenteena}
menuText U ToolsTracker "Nappuloiden liikkuminen"  0 {Avaa ikkuna, jossa seuraat napppuloiden sijaintia ja liikkumista laudalla}
menuText U ToolsTraining "Valmennus"  2 {Tykaluja valmennukseen (taktiikka, avaukset...) }
menuText U ToolsTacticalGame "Taktinen peli"  2 {Pelaa taktisesti painottunut peli}
menuText U ToolsSeriousGame "Virallinen peli"  7 {Pelaa virallinen peli}
menuText U ToolsTrainOpenings "Avaukset"  5 {Harjoittele repertuaariasi}
menuText U ToolsTrainReviewGame "Arvaa siirto"  11 {Arvaa pelin seuraava siirto}
menuText U ToolsTrainTactics "Taktiikkaharjoitukset"  9 {Ratko taktiikoita}
menuText U ToolsTrainCalvar "Muunnelmien laskeminen"  0 {Harjoittele muunnelmien laskemista}
menuText U ToolsTrainFindBestMove "Etsi paras siirto"  5 {Etsi aseman paras siirto}
menuText U ToolsTrainFics "FICS"  0 {Pelaa palvelimella freechess.org}
menuText U ToolsEngineTournament "Shakkimoottoriturnaus"  0 {Turnaus shakkimoottorien kesken}
menuText U ToolsTimeAnalysis "Aika-analyysi" 0 {Nyt nykyisen pelin kelloaikakaavio}
menuText U ToolsBookTuning "Virit avaukset" 0 {Muokkaa avauskirjastoasi}
menuText U ToolsDownloadTWIC "Lataa TWIC-pelej" 0 {Lataa uusimmat The Week In Chess (TWIC) -pelit}
menuText U ToolsConnectHardware "Liit syttlaite" 8 {Liit ulkoinen syttlaite (elektroninen lauta tms.)}
menuText U ToolsConnectHardwareConfigure "Asetukset..." 0 {Sd ulkoisen syttlaitteen asetuksia}
menuText U ToolsConnectHardwareNovagCitrineConnect "Liit Novag Citrine" 0 {Liit Novag Citrine shakkitietokone}
menuText U ToolsConnectHardwareInputEngineConnect "Liit muu syttlaite" 0 {Esimerkiksi elektroninen DGT-lauta}

menuText U ToolsPInfo "Pelaajatiedot"  0 \
  {Avaa/pivit pelaajatiedot-ikkuna}
menuText U ToolsPlayerReport "Pelaajaraportti..." 1 \
  {Luo pelaajaraportti}
menuText U ToolsRating "Vahvuusluvut" 0 \
  {Kaavio pelaajien vahvuuslukuhistoriasta}
menuText U ToolsExpCurrent "Vie tekstitiedostoon" 1 \
  {Kirjoita nykyinen peli tekstitiedostoon}
menuText U ToolsExpCurrentPGN "Vie PGN-tiedostoon" 6 \
  {Kirjoita nykyinen peli PGN-tiedostoon}
menuText U ToolsExpCurrentHTML "Vie HTML-tiedostoon" 4 \
  {Kirjoita nykyinen peli HTML-tiedostoon}
menuText U ToolsExpCurrentHTMLJS "Vie HTML- ja JavaScript-tiedostoihin" 6 {Kirjoita nykyinen peli HTML- ja JavaScript-tiedostoihin}  
menuText U ToolsExpFilter "Vie suodatetut pelit tekstitiedostoon" 0 \
  {Kirjoita kaikki suodatetut pelit tekstitiedostoon}
menuText U ToolsExpFilterPGN "Vie suodatetut pelit PGN-tiedostoon" 0 \
  {Kirjoita kaikki suodatetut pelit PGN-tiedostoon}
menuText U ToolsExpFilterHTML "Vie suodatetut pelit HTML-tiedostoon" 0 \
  {Kirjoita kaikki suodatetut pelit HTML-tiedostoon}
menuText U ToolsExpFilterHTMLJS "Vie suodatetut pelit HTML- ja JavaScript-tiedostoihin" 0 {Kirjoita kaikki suodatetut pelit HTML- ja JavaScript-tiedostoihin}  
menuText U ToolsImportOne "Tuo yksi PGN-peli" 0 \
  {Tuo yksittinen peli PGN-tekstist}
menuText U ToolsImportFile "Tuo PGN pelitiedosto" 0 {Tuo yksi tai useampia pelej sisltv PGN-tiedosto}
menuText U ToolsStartEngine1 "Kynnist moottori 1" 19  {Kynnist moottori 1}
menuText U ToolsStartEngine2 "Kynnist moottori 2" 19  {Kynnist moottori 2}
menuText U ToolsCaptureBoard "Kuvakaappaus asemasta..." 1  {Tallenna asema kuvana.}

# Play menu
menuText U Play "Pelaa" 0

# --- Correspondence Chess
menuText U CCResign "Luovuta" 0 {Luovuta (ei shkposti)}
menuText U CCClaimDraw "Vaadi tasapeli" 0 {Lhet siirto ja vaadi tasapeli (ei shkposti)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText U Options "Asetukset" 0
menuText U OptionsBoardGraphics "Ruudut" 0 {Valitse ruuduissa kytettv tekstuuri}
translate U OptionsBGW {Valitse ruuduissa kytettv tekstuuri}
translate U OptionsBoardGraphicsText {Valitse ruuduissa kytettv grafiikkatiedosto:}
menuText U OptionsBoardNames "Omat nimet" 0 {Lis ja muokkaa kyttmisi pelaajanimi}
menuText U OptionsExport "Vientiasetukset" 0 {Muuta eri tekstimuotojen vientiin liittyvi asetuksia}
menuText U OptionsFonts "Fontit" 0 {Muuta fontteja}
menuText U OptionsFontsRegular "Oletusfontti" 0 {Vaihda oletusfontti}
menuText U OptionsFontsMenu "Valikko" 0 {Vaihda valikoissa kytetty fontti}
menuText U OptionsFontsSmall "Pieni" 0 {Vaihda pieni fontti}
menuText U OptionsFontsTiny "Hyvin pieni" 0 {CVaihda hyvin pieni fontti}
menuText U OptionsFontsFixed "Tasalevyinen" 0 {Vaihda tasalevyinen fontti}
menuText U OptionsGInfo "Pelitiedot" 0 {Pelitietoihin liittyvt asetukset}
menuText U OptionsLanguage "Kieli" 0 {Valitse valikoissa kytettv kieli}
menuText U OptionsMovesTranslatePieces "Knnkset" 0 {Knn nappuloiden ensimmiset kirjaimet}
menuText U OptionsMovesHighlightLastMove "Korosta viimeisin siirto" 0 {Korosta viimeisin siirto}
menuText U OptionsMovesHighlightLastMoveDisplay "Nyt" 0 {Nyt viimeisin siirto korostettuna}
menuText U OptionsMovesHighlightLastMoveWidth "Viiva" 0 {Laudalla nytettvn viivan paksuus}
menuText U OptionsMovesHighlightLastMoveColor "Vri" 0 {Laudalla nytettvn viivan vri}
menuText U OptionsMovesHighlightLastMoveArrow "Sis. nuoli" 0 {Korostettuun siirtoon sisllytetn nuoli}
menuText U OptionsMovesHighlightLastMoveNag "Nyt arviointisymbolit" 0
menuText U OptionsMovesHighlightLastMoveEval "Nyt arviointisymbolit" 0
menuText U OptionsMoves "Siirrot" 0 {Siirtojen syttmiseen liittyvt asetukset}
menuText U OptionsMovesAnimate "Animaation nopeus" 1 \
  {Siirtojen animoinnin nopeus}
menuText U OptionsMovesDelay "Toiston siirtonopeus" 1 \
  {Automaattisesti toistetun pelin siirtonopeus}
menuText U OptionsMovesCoord "Siirrot koordinaatteina" 0 \
  {Hyvksy nppimistlt annetut siirtokoordinaatit (esim "g1f3")}
menuText U OptionsMovesSuggest "Nyt suositetut siirrot" 0 \
  {Siirtosuositukset plle/plt}
menuText U OptionsShowVarPopup "Nyt muunnelmaikkuna" 0 {Nyt/sulje muunnelmaikkuna}  
menuText U OptionsMovesSpace "Vlilynti siirtoihin" 0 {Lis vlilynti siirron numeron pern}  
menuText U OptionsMovesLichess "Lichess/ChessBase-muoto huomautuksia varten" 0 {Kyt Lichess/ChessBase-muotoa nelimerkit ja nuolet}
menuText U OptionsMovesKey "Automaattinen tydennys" 0 \
  {Kytek siirtojen automaattinen tydennys plle/plt}
menuText U OptionsMovesShowVarArrows "Muunnelmat nuolin" 0 {Nyt/l nyt muunnelmia nuolilla laudalla}
menuText U OptionsMovesShowEngineVariationArrows "Nyt nuolet moottorin muunnelmia varten" 0 {Kytke plle/pois nuolet, jotka nyttvt moottorin vaihteluviivoja moniPV-tilassa}
menuText U OptionsMovesGlossOfDanger "Vrikoodattu Gloss of Danger" 0 {Kytke plle/pois plt vrikoodattu vaaran kiilto}
translate U OptionsMovesTreeDepth {Oletuspuuikkunan siirtosyvyys}
menuText U OptionsNumbers "Numerointi" 0 {Numeroformaatit, 1-3 desimaalipisteell, 4-6 -pilkulla}
menuText U OptionsTheme "Teema" 0 {Valitse kyttliittymn teema}
menuText U OptionsWindows "Ikkunat" 0 {Ikkunoiden asetukset}
menuText U OptionsSounds "net" 0 {Muokaa siirtoilmoitusni}
menuText U OptionsResources "Resurssit..." 0 {Valitse resurssitiedostot ja kansiot}
menuText U OptionsWindowsDock "Telakoi ikkunat" 0 {Telakoi irti olevat ikkunat (vaatii uudelleenkynnistyksen)}
menuText U OptionsWindowsSaveLayout "Tallenna layout" 0 {Tallenna nimelle ikkunoiden ja tykalupalkkien sijainti}
menuText U OptionsWindowsRestoreLayout "Palauta layout" 0 {Palauta tallennettu layout}
menuText U OptionsWindowsShowGameInfo "Pelin tiedot" 0 {Nyt/piilota pelin tiedot (pelaajanimet, turnaus...)}
menuText U OptionsWindowsAutoLoadLayout "Ensimminen layout automaattisesti" 0 {Lataa ensimminen tallennettu layout automaattisesti}
menuText U OptionsECO "Lataa ECO-tiedosto" 7 {Lataa ECO avausluokittelu tiedostosta}
menuText U OptionsSpell "Lataa oikeinkirjoitustiedosto" 0 \
  {Lataa Scidin oikeinkirjoitustiedosto}
menuText U OptionsTable "Loppupelitietokannat" 0 \
  {Valitse hakemisto, jossa kannat sijaitsevat. Kaikki kannat otetaan kyttn}
menuText U OptionsRecent "Viimeaikaiset tiedostot" 0 {Kuinka monta tiedostoa nytetn Tiedosto-valikon viimeaikaisten listassa}
menuText U OptionsBooksDir "Avauskirjat" 0 {Hakemisto, jossa avauskirjat sijaitsevat}
menuText U OptionsTacticsBasesDir "Taktiikkakannat" 0 {Hakemisto, jossa taktiikka (harjoitus) tietokannat sijaitsevat}
menuText U OptionsPhotosDir "Valokuvahakemisto" 0 {Asettaa valokuvien perushakemiston}
menuText U OptionsThemeDir "Teema(t) Tiedosto:"  0 {Lataa GUI-teeman pakettitiedosto}
menuText U OptionsSave "Tallenna asetukset" 0 "Tallenna kaikki asetukset tiedostoon $::optionsFile"
menuText U OptionsAutoSave "Automaattinen asetusten tallennus" 0 \
  {Tallenna asetukset automaattisesti ohjelmasta poistuttaessa}

# Help menu:
menuText U Help "Ohje" 0
menuText U HelpContents "Sisllysluettelo" 0 {Nyt ohjeen sisllysluettelo}
menuText U HelpIndex "Hakemisto" 0 {Nyt ohjeen aakkosellinen luettelo}
menuText U HelpGuide "Pikaopas" 0 {Nyt Scidin pikaopas}
menuText U HelpHints "Vinkit" 0 {Nyt sivu, jolla Scidin kytt helpottavia vihjeit}
menuText U HelpContact "Yhteystietoja" 0 {Nyt yhteystiedot}
menuText U HelpTip "Pivn vinkki" 1 {Nyt vihje}
menuText U HelpStartup "Kynnistys-popup" 2 {Nyt ohjelman kynnistys-popup}
menuText U HelpAbout "Tietoja Scidist" 9 {Tietoja ohjelmasta}

# Toolbar tooltips:
menuText U RotateBoard "Pyrit lautaa" 0 {Pyrit lautaa}

# Game info box popup menu:
menuText U GInfoHideNext "Piilota seuraava siirto" 0
menuText U GInfoMaterial "Nyt materiaaliarvot" 0
menuText U GInfoFEN "Nyt FEN" 6
menuText U GInfoMarks "Nyt vriruudut ja nuolet" 6
menuText U GInfoWrap "Rivit automaattisesti" 0
menuText U GInfoFullComment "Nyt koko kommentti" 6
menuText U GInfoPhotos "Nyt valokuvat" 7
menuText U GInfoTBNothing "Loppupelikannat: ei mitn" 0
menuText U GInfoTBResult "Loppupelikannat: vain tulos" 1
menuText U GInfoTBAll "Loppupelikannat: tulos ja parhaat siirrot" 4
menuText U GInfoDelete "Poista peli (kumoa)" 3
menuText U GInfoMark "Merkitse peli (kumoa)" 3
menuText U GInfoInformant "Informant-asetukset" 5

# General buttons:
translate U Back {Palaa}
translate U Browse {Selaa}
translate U Cancel {Peruuta}
translate U Continue {Jatka}
translate U Clear {Tyhjenn}
translate U Close {Sulje}
translate U Contents {Sisllys}
translate U Defaults {Oletukset}
translate U InvertSearch {Knteinen haku}
translate U Delete {Poista}
translate U Graph {Graafi}
translate U Help {Ohje}
translate U Hide {Piilottaa}
translate U Import {Tuo}
translate U Index {Hakemisto}
translate U LoadGame {Lataa peli}
translate U BrowseGame {Selaa peli}
translate U MergeGame {Yhdist peli}
translate U MergeGames {Yhdist pelit}
translate U Preview {Esikatselu}
translate U Revert {Palauta}
translate U Save {Tallenna}
translate U Search {Etsi}
translate U Stop {Seis}
translate U Store {Talleta}
translate U Update {Pivit}
translate U ChangeOrient {Muuta ikkunan muotoa}
translate U ShowIcons {Nyt kuvakkeet}
translate U None {Tyhj}
translate U First {Ensimminen}
translate U Current {Nykyinen}
translate U Last {Viimeinen}

# General messages:
translate U game {peli}
translate U games {pelit}
translate U move {siirto}
translate U moves {siirrot}
translate U all {kaikki}
translate U Yes {Kyll}
translate U No {Ei}
translate U Both {Molemmat}
translate U King {Kuningas}
translate U Queen {Kuningatar}
translate U Rook {Torni}
translate U Bishop {Lhetti}
translate U Knight {Ratsu}
translate U Pawn {Sotilas}
translate U White {Valkea}
translate U Black {Musta}
translate U Player {Pelaaja}
translate U Rating {Vahvuusluku}
translate U RatingDiff {Vahvuuksien ero (Valkea - Musta)}
translate U AverageRating {Keskivahvuus}
translate U Event {Tapahtuma}
translate U Site {Paikka}
translate U Country {Maa}
translate U IgnoreColors {l huomioi vrej}
translate U Date {Pvm.}
translate U EventDate {Tapahtuman pvm.}
translate U Decade {Vuosikymmen}
translate U Year {Vuosi}
translate U Month {Kuukausi}
translate U Months {Tammikuu Helmikuu Maaliskuu Huhtikuu Toukokuu Keskuu Heinkuu Elokuu Syyskuu Lokakuu Marraskuu Joulukuu}
translate U Days {Su Ma Ti Ke To Pe La}
translate U YearToToday {Vuoden alusta}
translate U YearToTodayTooltip {Aseta pivmr 1 vuoden takaa thn pivn}
translate U Result {Tulos}
translate U Round {Kierros}
translate U Length {Pituus}
translate U ECOCode {ECO-koodi}
translate U ECO {ECO}
translate U Deleted {Poistettu}
translate U SearchResults {Haun tulokset}
translate U OpeningTheDatabase {Avaustietokanta}
translate U Database {Tietokanta}
translate U Filter {Suodatin}
translate U noGames {ei pelej}
translate U allGames {kaikki pelit}
translate U empty {tyhj}
translate U clipbase {leikekanta}
translate U score {tulos}
translate U StartPos {Alkuasema}
translate U Total {Yhteens}
translate U readonly {vain luku}

# Standard error messages:
translate U ErrNotOpen {Tm ei ole avoin tietokanta.}
translate U ErrReadOnly {Tm tietokanta on vain luku -moodissa; sit ei voi muokata.}
translate U ErrSearchInterrupted {Haku keskeytyi; tulokset ovat vaillinaiset.}
translate U ErrNoClockComments {Tst pelist ei lytynyt [%clk] kellon kommentteja.    Lis kelloajat kommenttiikkunan kautta (Ctrl+E) kyttksesi tt ominaisuutta.}
translate U ErrFileInUse {Virhe: tiedosto on jo kytss. Sulje kaikki muut tt tietokantaa kyttvt sovellukset. Jos ohjelma suljettiin odottamatta, saatat joutua poistamaan tietokantaan liittyvn .lock-tiedoston.}




# Game information:
translate U twin {tupla}
translate U deleted {poistettu}
translate U comment {kommentti}
translate U hidden {piilotettu}
translate U LastMove {Viimeinen siirto}
translate U NextMove {Seuraava}
translate U GameStart {Pelin alku}
translate U LineStart {Rivin alku}
translate U GameEnd {Pelin loppu}
translate U LineEnd {Rivin loppu}

# Player information:
translate U PInfoAll {<b>Kaikki</b> tulokset}
translate U PInfoFilter {<b>Suodatetut</b> tulokset}
translate U PInfoAgainst {Tulokset vastaan}
translate U PInfoMostWhite {Yleisimmt avaukset: Valkea}
translate U PInfoMostBlack {Yleisimmt avaukset: Musta}
translate U PInfoRating {Vahvuuslukuhistoria}
translate U PInfoBio {Biografia}
translate U PInfoEditRatings {Muokkaa vahvuuslukuja}
translate U PInfoEloFile {Tiedosto}

# Tablebase information:
translate U Draw {Tasapeli}
translate U with {kanssa}
translate U only {vain}
translate U lose {hvi}
translate U loses {hvi}

# Tip of the day:
translate U Tip {Vihje}
translate U TipAtStartup {Kynnistysvihje}
translate U TipConvertPGN {Saat paremman suorituskyvyn muuntamalla PGN-tiedostoja}

# Tree window menus:
menuText U TreeFile "Tiedosto" 0
menuText U TreeFileFillWithBase "Kanta vlimuistiin" 0 {Tyt vlimuisti nykyisen tietokannan peleill}
menuText U TreeFileFillWithGame "Peli vlimuistiin" 0 {Siirr nykyisen kannan aktiivinen peli vlimuistiin}
menuText U TreeFileSetCacheSize "Vlimuistin koko" 0 {Aseta vlimuistin koko}
menuText U TreeFileCacheInfo "Tietoja vlimuistista" 1 {Nyt tiedot vlimuistista ja sen kytst}
menuText U TreeFileSave "Tallenna vlimuisti" 2 {Tallenna vlimuisti (.stc) tiedostoksi}
menuText U TreeFileFill "Tyt vlimuisti" 1 \
  {Tyt vlimuisti yleisill asemilla}
menuText U TreeFileBest "Parhaat pelit" 2 {Nyt parhaat pelit}
menuText U TreeFileGraph "Graafi-ikkuna" 0 {Nyt puun haara graafina}
menuText U TreeFileCopy "Puu leikepydlle" 1 \
  {Kopioi puun tilastot leikepydlle}
menuText U TreeFileClose "Sulje puu" 2 {Sulje ikkuna}
menuText U TreeMask "Maski" 0
menuText U TreeMaskNew "Uusi" 2 {Uusi maski}
menuText U TreeMaskOpen "Avaa" 0 {Avaa maski}
menuText U TreeMaskOpenRecent "Avaa viimeaikainen" 0 {Avaa viimeaikainen maski}
menuText U TreeMaskSave "Tallenna" 0 {Tallenna maski}
menuText U TreeMaskClose "Close" 0 {Sulje maski}
menuText U TreeMaskFillWithGame "Tyt pelill" 0 {Tyt maski pelill}
menuText U TreeMaskFillWithBase "Tyt kannalla" 0 {Tyt maski kannan kaikilla peleill}
menuText U TreeMaskInfo "Tiedot" 0 {Nyt nykyisen maskin tilastot}
menuText U TreeMaskDisplay "Nyt maski" 0 {Nyt maski puumuodossa}
menuText U TreeMaskSearch "Etsi" 0 {Etsi nykyisest maskista}
menuText U TreeSort "Lajittele" 0
menuText U TreeSortAlpha "Aakkosta" 0
menuText U TreeSortECO "ECO-koodi" 0
menuText U TreeSortFreq "Yleisyys" 0
menuText U TreeSortScore "Tulos" 0
menuText U TreeOpt "Asetukset" 0
menuText U TreeOptSlowmode "Hidas moodi" 0 {Pivit asemat hitaasti (suurempi tarkkuus)}
menuText U TreeOptFastmode "Nopea moodi" 0 {Pivit nopeati (Ei lyd siirtovaihtoja)}
menuText U TreeOptFastAndSlowmode "Hidas ja nopea" 0 {Pivit ensin nopeasti, sitten tarkasti}
menuText U TreeOptStartStop "Automaattinen pivitys" 0 {Ikkunan automaattinen pivitys plle/plt}
menuText U TreeOptLock "Lukitse" 0 {Lukitse/vapauta puu nykyiseen tietokantaan}
menuText U TreeOptTraining "Valmennus" 0 {Puun valmennusmoodii plle/plt}
menuText U TreeOptDepth "Siirr syvyytt" 0 {Puolikkaan liikkeiden mr puussa nytettvksi (1-4)}
menuText U TreeOptAutosave "Tallenna vlimuisti automaattisesti" 0 \
  {Tallenna vlimuisti tiedostoon automaattisesti, kun puu-ikkuna suljetaan}
menuText U TreeHelp "Ohje" 0
menuText U TreeHelpTree "Puun ohje" 0
menuText U TreeHelpIndex "Aakkosellinen ohje" 0
translate U SaveCache {Tallenna vlimuisti}
translate U Training {Valmennus}
translate U LockTree {Lukitse}
translate U TreeDepth {Puun syvyys (puolet liikkeet):}
translate U TreeLocked {lukittu}
translate U TreeBest {Paras}
translate U TreeBestGames {Parhaat pelit}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate U TreeTitleRow \
{Siirto                        ECO       Yleisyys     Tulos  AvElo Perf AvYear %Draws     %Voittaa}
translate U TreeTotal {TOTAL}
translate U DoYouWantToSaveFirst {Haluatko tallentaa ensin}
translate U AddToMask {Lis maskiin}
translate U RemoveFromMask {Poista maskista}
translate U AddThisMoveToMask {Lis siirto maskiin}
translate U SearchMask {Etsi maskista}
translate U DisplayMask {Nyt maski}
translate U Nag {Nag-koodi}
translate U Marker {Merkki}
translate U Include {Sisllyt}
translate U Exclude {l sisllyt}
translate U MainLine {Pmuunnelma}
translate U Bookmark {Kirjanmerkki}
translate U NewLine {Uusi rivi}
translate U ToBeVerified {Varmennetaan}
translate U ToTrain {Harjoiteltavaksi}
translate U Dubious {Arveluttava}
translate U ToRemove {Poistettavaksi}
translate U NoMarker {Ei merkki}
translate U ColorMarker {Vri}
translate U WhiteMark {Valkea}
translate U GreenMark {Vihre}
translate U YellowMark {Keltainen}
translate U BlueMark {Sininen}
translate U RedMark {Punainen}
translate U CommentMove {Kommentoi siirto}
translate U CommentPosition {Komentoi asema}
translate U AddMoveToMaskFirst {Lis siirto ensin maskiin}
translate U OpenAMaskFileFirst {Avaa maski-tiedosto ensin}
translate U Positions {Asemat}
translate U Moves {Siirrot}

# Finder window:
menuText U FinderFile "Tiedosto" 0
menuText U FinderFileSubdirs "Etsi alihakemistoista" 0
menuText U FinderFileClose "Sulje haku" 0
menuText U FinderSort "Lajittele" 0
menuText U FinderSortType "Tyyppi" 0
menuText U FinderSortSize "Koko" 0
menuText U FinderSortMod "Muokattu" 0
menuText U FinderSortName "Nimi" 0
menuText U FinderSortPath "Polku" 0
menuText U FinderTypes "Tyypit" 0
menuText U FinderTypesScid "Scid-tietokannat" 0
menuText U FinderTypesOld "Vanhat Scid-kannat" 0
menuText U FinderTypesPGN "PGN-tiedostot" 0
menuText U FinderTypesEPD "EPD-tiedostot" 0
menuText U FinderTypesRep "Repertuaari-tiedostot" 0
menuText U FinderHelp "Ohje" 0
menuText U FinderHelpFinder "Tiedostohaun ohje" 0
menuText U FinderHelpIndex "Aakkosellinen ohje" 0
translate U FileFinder {Tiedostohaku}
translate U FinderDir {Hakemisto}
translate U FinderDirs {Hakemistot}
translate U FinderFiles {Tiedostot}
translate U FinderUpDir {yls}
translate U FinderCtxOpen {Avaa}
translate U FinderCtxBackup {Varmista}
translate U FinderCtxCopy {Kopioi}
translate U FinderCtxMove {Siirr}
translate U FinderCtxDelete {Poista}

# Player finder:
menuText U PListFile "Tiedosto" 0
menuText U PListFileUpdate "Pivit" 0
menuText U PListFileClose "Sulje pelaajahaku" 0
menuText U PListSort "Lajittele" 0
menuText U PListSortName "Nimi" 0
menuText U PListSortElo "Elo" 0
menuText U PListSortGames "Pelit" 3
menuText U PListSortOldest "Vanhin" 0
menuText U PListSortNewest "Uusin" 0

# Tournament finder:
menuText U TmtFile "Tiedosto" 0
menuText U TmtFileUpdate "Pivit" 0
menuText U TmtFileClose "Sulje kilpailuhaku" 0
menuText U TmtSort "Lajittele" 0
menuText U TmtSortDate "Pivmr" 1
menuText U TmtSortPlayers "Pelaajar" 1
menuText U TmtSortGames "Pelit" 2
menuText U TmtSortElo "Elo" 2
menuText U TmtSortSite "Paikka" 3
menuText U TmtSortEvent "Tapahtuma" 4
menuText U TmtSortWinner "Voittaja" 0
translate U TmtLimit "Luettelon raja"
translate U TmtMeanElo "Keski-Elo"
translate U TmtNone "Turnauksia ei lytynyt."

# Graph windows:
menuText U GraphFile "Tiedosto" 0
menuText U GraphFileColor "Tallenna Color PostScript..." 9
menuText U GraphFileGrey "Tallenna Greyscale PostScript..." 9
menuText U GraphFileClose "Sulje ikkuna" 0
menuText U GraphOptions "Asetukset" 0
menuText U GraphOptionsWhite "Valkea" 0
menuText U GraphOptionsBlack "Musta" 0
menuText U GraphOptionsBoth "Molemmat" 1
menuText U GraphOptionsPInfo "Pelaaja Info pelaaja" 0
menuText U GraphOptionsEloFile "Elo luokitustiedostosta" 0
menuText U GraphOptionsEloDB "Elo tietokannasta" 0
translate U GraphFilterTitle "Suodatuskaavio: prosenttiosuus peleist, jotka saavuttavat sijoituksen"
translate U GraphAbsFilterTitle "graafi: pelien yleisyys"
translate U ConfigureFilter "Muokkaa X-akseli; vuosi, vahvuus, siirrot"
translate U FilterEstimate "Arvioi"
translate U TitleFilterGraph "Scid: graafi"

# Analysis window:
translate U AddVariation {Lis muunnelma}
translate U AddAllVariations {Lis kaikki muunnelmat}
translate U AddMove {Lis siirto}
translate U Annotate {Kommentoi}
translate U ShowAnalysisBoard {Nyt analyysilauta}
translate U ShowInfo {Nyt tiedot moottorista}
translate U FinishGame {Lopeta peli}
translate U StopEngine {Pysyt moottori}
translate U StartEngine {Kynnist moottori}
translate U LockEngine {Lukitse moottori nykyiseen asemaan}
translate U AnalysisCommand {Analyysi-komento}
translate U PreviousChoices {Aikaisemmat vaihtoehdot}
translate U AnnotateTime {Siirtojen vlinen aika sekunteina}
translate U AnnotateWhich {Lis muunnelmat}
translate U AnnotateAll {molemmille osapuolille}
translate U AnnotateAllMoves {Kommentoi kaikki siirrot}
translate U AnnotateWhite {Vain valkealle}
translate U AnnotateBlack {Vain mustalle}
translate U AnnotateBlundersOnly {Kun pelisiirto on virhe (blunder)}
translate U AnnotateBlundersOnlyScoreChange {Analyysi raportoi virheet, muuuttaen pisteytyksen: }
translate U BlundersThreshold {Virhekynnys}
translate U ScoreAllMoves {Pisteyt kaikki siirrot}
translate U LowPriority {Matala CPUn kyttaste}
translate U ClickHereToSeeMoves {Klikkaa nhdksesi siirrot}
translate U ConfigureInformant {Informant-asetukset}
translate U Informant!? {Mielenkiintoinen siirto}
translate U Informant? {Heikko siirto}
translate U Informant?? {Virhe}
translate U Informant?! {Epilyttv siirto}
translate U Informant+= {Valkean pieni etu}
translate U Informant+/- {Valkean etu}
translate U Informant+- {Valkean ratkaiseva etu}
translate U Informant+-- {Voittoasema}
translate U AutoComment {Automaattinen kommentti}
translate U AutoCommentTooltip {Luo tekolykommentti nykyiselle sijainnille}
translate U AnalysisAutoCommentTooltip {Luo tekolykommentteja koko pelille}
translate U GameComment {Pelin kommentti}
translate U GameCommentTooltip {Etsi pelist selostettuja liikkeit ja luo tekolyyhteenveto}
translate U TimeMs {Aika (ms)}


# Book window
translate U Book {Kirja}
translate U OtherBookMoves {Vastustajan kirja}
translate U OtherBookMovesTooltip {Siirrot, joihin vastustajalla on vastaus}

# Analysis Engine open dialog:
translate U EngineList {Analyysimoottorilista}
translate U EngineName {Nimi}
translate U EngineCmd {Komento}
translate U EngineArgs {Parametrit}
translate U EngineDir {Hakemisto}
translate U EngineElo {Elo}
translate U EngineTime {Pvm}
translate U EngineNew {Uusi}
translate U EngineEdit {Muokkaa}
translate U EngineRequired {Lihavoidut kentt ovat pakollisia}
translate U EngineProtocol {Viestintprotokolla}
translate U EngineNotation {Merkint liikkeist}
translate U EngineFlipEvaluation {Knn arvioinnin nkkulma}
translate U EngineShowLog {Nyt viestintloki}
translate U EngineNetworkd {Hyvksy etyhteydet}
translate U EngineSelect {Valitse nykyinen moottori}
translate U EngineAddLocal {Lis paikallinen moottori}
translate U EngineAddRemote {Lis etmoottori}
translate U EngineReload {Lataa nykyinen moottori uudelleen}
translate U EngineClone {Luo kopio nykyisest moottorista}
translate U EngineDelete {Poista nykyinen moottori}

# PGN window menus:
menuText U PgnFile "Tiedosto" 0
menuText U PgnFileCopy "Kopioi peli leikepydlle" 0
menuText U PgnFilePrint "Tulosta tiedostoon..." 1
menuText U PgnFileClose "Sulje PGN-ikkuna" 6
menuText U PgnOpt "Nytt" 0
menuText U PgnOptColor "Vrit" 0
menuText U PgnOptShort "Lyhyet otsikkotiedot (3-rivinen)" 0
menuText U PgnOptSymbols "Merkinnt symboleina" 1
menuText U PgnOptIndentC "Sisenn kommentit" 0
menuText U PgnOptIndentV "Sisenn muunnelmat" 1
menuText U PgnOptColumn "Sarakkeina (siirto per rivi)" 1
menuText U PgnOptSpace "Vlilynti siirtonumeron jlkeen" 1
menuText U PgnOptStripMarks "Poista vri-/nuolikoodit" 1
menuText U PgnOptBoldMainLine "Lihavoi pmuunnelma" 2
menuText U PgnColor "Vrit" 2
menuText U PgnColorHeader "Otsikko..." 0
menuText U PgnColorAnno "Merkinnt..." 0
menuText U PgnColorComments "Kommentit..." 0
menuText U PgnColorVars "Muunnelmat..." 0
menuText U PgnColorBackground "Tausta..." 0
menuText U PgnColorMain "Pmuunnelma..." 0
menuText U PgnColorCurrent "Nykyisen siirron tausta..." 0
menuText U PgnHelp "Ohje" 0
menuText U PgnHelpPgn "PGN-ohje" 0
menuText U PgnHelpIndex "Aakkosellinen" 0
translate U PgnWindowTitle {Siirrot - peli %u}

# Crosstable window menus:
menuText U CrosstabFile "Tiedosto" 0
menuText U CrosstabFileText "Tulosta tekstitiedostoon..." 9
menuText U CrosstabFileHtml "Tulosta HTML-tiedostoon..." 8
menuText U CrosstabFileClose "Sulje ristitaulukko" 0
menuText U CrosstabEdit "Muokkaa" 0
menuText U CrosstabEditEvent "Tapahtuma" 0
menuText U CrosstabEditSite "Paikka" 0
menuText U CrosstabEditDate "Pvm" 0
menuText U CrosstabOpt "Nytt" 0
menuText U CrosstabOptAll "Tyskierroskilpailu" 0
menuText U CrosstabOptSwiss "Swiss" 0
menuText U CrosstabOptKnockout "Cup-kilpailu" 0
menuText U CrosstabOptAuto "Auto" 0
menuText U CrosstabOptAges "Ik" 0
menuText U CrosstabOptNats "Kansallisuudet" 0
menuText U CrosstabOptRatings "Vahvuusluvuut" 0
menuText U CrosstabOptTitles "Tittelit" 0
menuText U CrosstabOptBreaks "Tie-Break" 4
menuText U CrosstabOptDeleted "Huomioi poistetut pelit" 0
menuText U CrosstabOptColors "Vrit (vain Swiss)" 0
menuText U CrosstabOptColumnNumbers "Numeroidut sarakkeet (vain tyskierroskilpailu)" 0
menuText U CrosstabOptGroup "Ryhmtulokset" 0
menuText U CrosstabSort "Lajittele" 0
menuText U CrosstabSortName "Nimi" 0
menuText U CrosstabSortRating "Vahvuusluku" 0
menuText U CrosstabSortScore "Tulos" 0
menuText U CrosstabColor "Vri" 0
menuText U CrosstabColorPlain "Teksti" 0
menuText U CrosstabColorHyper "Hyperteksti" 0
menuText U CrosstabHelp "Ohje" 0
menuText U CrosstabHelpCross "Ristitaulukon ohje" 0
menuText U CrosstabHelpIndex "Aakkosellinen ohje" 0
translate U SetFilter {Aseta suodatin}
translate U AddToFilter {Lis suodattimeen}
translate U Swiss {Swiss}
translate U Category {Kategoria}

# Opening report window menus:
menuText U OprepFile "Tiedosto" 0
menuText U OprepFileText "Tulosta tekstitiedostoon..." 1
menuText U OprepFileHtml "Tulosta HTML-tiedostoon..." 8
menuText U OprepFileOptions "Asetukset..." 0
menuText U OprepFileClose "Sulje raportti-ikkuna" 0
menuText U OprepFavorites "Suosikit" 2
menuText U OprepFavoritesAdd "Lis raportti..." 3
menuText U OprepFavoritesEdit "Muokkaa raportin suosikkeja..." 0
menuText U OprepFavoritesGenerate "Luo raportteja..." 4
menuText U OprepHelp "Ohje" 2
menuText U OprepHelpReport "Avausraportin ohje" 0
menuText U OprepHelpIndex "Aakkosellinen ohje" 0

# Header search:
translate U HeaderSearch {Haku otsikkotiedoista}
translate U EndSideToMove {Siirtovuoro pelin lopussa}
translate U GamesWithNoECO {Ei ECO-koodia}
translate U GameLength {Pelin pituus}
translate U FindGamesWith {Merkityt pelit}
translate U StdStart {Ei-standardi alku}
translate U Promotions {Korotukset}
translate U Comments {Kommentit}
translate U Variations {Muunnelmat}
translate U Annotations {Annotaatiot}
translate U DeleteFlag {Poistomerkki}
translate U WhiteOpFlag {Valkean avaus}
translate U BlackOpFlag {Mustan avaus}
translate U MiddlegameFlag {Keskipeli}
translate U EndgameFlag {Loppupeli}
translate U NoveltyFlag {Uutuus}
translate U PawnFlag {Sotilasasema}
translate U TacticsFlag {Taktiikka}
translate U QsideFlag {Kuningatarsivustan peli}
translate U KsideFlag {Kuningassivustan peli}
translate U BrilliancyFlag {Loistosiirto}
translate U BlunderFlag {Virhe (Blunder)}
translate U UserFlag {Kyttj}
translate U PgnContains {PGN sislt teksti}
translate U PgnTag {Tag}
translate U TagContains {sislt}
translate U Variant {Variantti}
translate U Annotator {Annotoija}
translate U Cmnts {Vain annotoidut pelit}

# Game list window:
translate U GlistNumber {Numero}
translate U GlistWhite {Valkea}
translate U GlistBlack {Musta}
translate U GlistWElo {V-Elo}
translate U GlistBElo {M-Elo}
translate U GlistEvent {Tapahtuma}
translate U GlistSite {Paikka}
translate U GlistRound {Kierros}
translate U GlistDate {Pvm}
translate U GlistYear {Vuosi}
translate U GlistEDate {Tapahtuman pvm}
translate U GlistResult {Tulos}
translate U GlistLength {Pituus}
translate U GlistCountry {Maa}
translate U GlistECO {ECO}
translate U GlistOpening {Avaus}
translate U GlistEndMaterial {Loppumateriaali}
translate U GlistDeleted {Poistettu}
translate U GlistFlags {Merkit}
translate U GlistVars {Muunnelmat}
translate U GlistComments {Kommentit}
translate U GlistAnnos {Annotaatiot}
translate U GlistStart {Alk}
translate U GlistGameNumber {Peli nro}
translate U GlistAverageElo {Keskim. Elo}
translate U GlistRating {Vahvuusluku}
translate U GlistFindText {Etsi teksti}
translate U GlistMoveField {Siirto}
translate U GlistEditField {Asetukset}
translate U GlistAddField {Lis}
translate U GlistDeleteField {Poista}
translate U GlistWidth {Leveys}
translate U GlistAlign {Tasaus}
translate U GlistAlignL {Tasaa vasen}
translate U GlistAlignR {Tasaa oikea}
translate U GlistAlignC {Keskit}
translate U GlistColor {Vri}
translate U GlistSep {Erotin}
translate U GlistCurrentSep {-- Nykyinen --}
translate U GlistNewSort {Uusi}
translate U GlistAddToSort {Lis}

# base sorting
translate U GsortSort {Lajittele...}
translate U GsortDate {Pvm.}
translate U GsortYear {Vuosi}
translate U GsortEvent {Tapahtuma}
translate U GsortSite {Paikka}
translate U GsortRound {Kierros}
translate U GsortWhiteName {Valkea nimi}
translate U GsortBlackName {Musta nimi}
translate U GsortECO {ECO}
translate U GsortResult {Tulos}
translate U GsortMoveCount {Siirtolkm.}
translate U GsortAverageElo {Keskim. Elo}
translate U GsortCountry {Maa}
translate U GsortDeleted {Poistettu}
translate U GsortEventDate {Tapahtuman pvm.}
translate U GsortWhiteElo {Valkea Elo}
translate U GsortBlackElo {Musta Elo}
translate U GsortComments {Kommentit}
translate U GsortVariations {Muunnelmat}
translate U GsortNAGs {NAG}
translate U GsortAscending {Nouseva}
translate U GsortDescending {Laskeva}
translate U GsortAdd {Lis}
translate U GsortStore {Varastoi}
translate U GsortLoad {Lataa}

# menu shown with right mouse button down on game list.
translate U GlistRemoveThisGameFromFilter  {Tm peli pois suodattimesta}
translate U GlistRemoveGameAndAboveFromFilter  {Tm ja kaikki edeltvt pois suodattimesta}
translate U GlistRemoveGameAndBelowFromFilter  {Tm ja kaikki seuraavat pois suodattimesta}
translate U GlistDeleteGame {Poista tm peli (kumoa)} 
translate U GlistDeleteAllGames {Poista kaikki suodatetut pelit} 
translate U GlistUndeleteAllGames {Kumoa kaikkien suodatettujen pelien poisto}  
translate U GlistMergeGameInBase {Yhdist peli toiseen kantaan}

# Maintenance window:
translate U DatabaseName {Tietokannan nimi:}
translate U TypeIcon {Tyyppi:}
translate U NumOfGames {Pelit:}
translate U NumDeletedGames {Poistetut pelit:}
translate U NumFilterGames {Suodatetut pelit:}
translate U YearRange {Vuodet:}
translate U RatingRange {Vahvuusluvut:}
translate U Description {Kuvaus}
translate U Flag {Merkit}
translate U CustomFlags {Omat merkit}
translate U DeleteCurrent {Poista nykyinen peli}
translate U DeleteFilter {Poista suodatetut pelit}
translate U DeleteAll {Poista kaikki pelit}
translate U UndeleteCurrent {Kumoa nykyisen poisto}
translate U UndeleteFilter {Kumoa suodatettujen poisto}
translate U UndeleteAll {Kumoa kaikkien poisto}
translate U DeleteTwins {Poista tuplat}
translate U MarkCurrent {Merkitse nykyinen peli}
translate U MarkFilter {Merkitse suodatetut pelit}
translate U MarkAll {Merkite kaikki pelit}
translate U UnmarkCurrent {Poista merkint nykyisest}
translate U UnmarkFilter {Poista merkint suodatetuista}
translate U UnmarkAll {Poista merkint kaikista}
translate U Spellchecking {Oikeinkirjoitus}
translate U Players {Pelaajat}
translate U Events {Tapahtumat}
translate U Sites {Paikat}
translate U Rounds {Kierrokset}
translate U DatabaseOps {Tietokantaoperaatiot}
translate U ReclassifyGames {ECO-luokittele pelit}
translate U CompactDatabase {Tiivist kanta}
translate U SortDatabase {Lajittele kanta}
translate U AddEloRatings {Lis Elo-luvut}
translate U AutoloadGame {Lataa automaattisesti peli nro}
translate U StripTags {Poista PGN-merkinnt}
translate U StripTag {Poista merkint}
translate U Cleaner {Puhdistaja}
translate U CleanerHelp {
Scidin Puhdistaja tekee nykyiselle tietokannalle alla olevasta listasta valitsemasi yllpitotoimet.

Voit valita kytettviksi mys nykyiset ECO- ja tuplien poistoasetukset.
}
translate U CleanerConfirm {
Puhdistajaa ei voi pysytt!

Suurilla tietokannoilla puhdistusajo voi kest todella kauan, riippuen valitsemistasi asetuksista.

Oletko varma, ett haluat ajaa puhdistusajon?
}
# Twinchecker
translate U TwinCheckUndelete {Vaihda valinta; "u" peruu poiston}
translate U TwinCheckprevPair {Edellinen pari}
translate U TwinChecknextPair {Seuraava pari}
translate U TwinChecker {Scid: Tuplien poisto}
translate U TwinCheckTournament {Pelit turnauksessa:}
translate U TwinCheckNoTwin {Ei tupla}
translate U TwinCheckNoTwinfound {Pelille ei lytynyt tuplaa.\nNhdksesi tuplat tss ikkunassa valitse "Poista tuplat..." -toiminto.}
translate U TwinCheckTag {Yhteiset merkinnt...}
translate U TwinCheckFound1 {Scid lysi $result tuplaa}
translate U TwinCheckFound2 { ja asetti niille poistomerkinnn}
translate U TwinCheckNoDelete {Ei poistettavia pelej tietokannassa.}
translate U TwinCriteria1 { Asetuksillasi lytyy todennkisesti valetuplia,\neli pelej joissa on samat siirrot, mutta jotka eivt ole tuplia.}
translate U TwinCriteria2 {Mikli valitset "Ei" samoille siirroille, sinun pitisi valita "Kyll" vreille, tapahtumalle, kierrokselle, vuodelle ja kuukaudelle.\nHaluatko silti jatkaa? }
translate U TwinCriteria3 {Kannattaa valita "Kyll" ainakin kahdelle seuraavista "sama paikka", "sama kierros" ja "sama vuosi".\nHaluatko silti jatkaa?}
translate U TwinCriteriaConfirm {Scid: Vahvista tupla-asetukset}
translate U TwinChangeTag "Muuta seuraavat merkinnt:\n\n"
translate U AllocRatingDescription "Tm komento kytt oikeinkirjoitustiedostoa mrittkseen Elo-luvut tietokannan peleille. Mikli pelaajalla ei ole voimassa olevaa lukua, kytetn oikeinkirjoitustiedostossa olevaa lukua peliajankohtana - mikli sellainen on olemassa."
translate U RatingOverride "Kirjoita yli olemassaolevat luvut?"
translate U AddRatings "Lis vahvuusluvut:"
translate U AddedRatings {Scid lissi $r Elo-lukua $g peliin.}

#Bookmark editor
translate U NewSubmenu "Uusi alivalikko"

# Comment editor:
translate U AnnotationSymbols  {Annotaatiosymbolit:}
translate U Comment {Kommentti:}
translate U InsertMark {Lis merkint}
translate U InsertMarkHelp {
Lis/poista merkint: Valitse vri, tyyppi, ruutu.
Lis/poista nuoli: Hiiren kakkosnapilla kaksi ruutua.
}

# Nag buttons in comment editor:
translate U GoodMove {Hyv siirto}
translate U PoorMove {Huono siirto}
translate U ExcellentMove {Erinomainen siirto}
translate U Blunder {Virhe (Blunder)}
translate U InterestingMove {Mielenkiintoinen siirto}
translate U DubiousMove {Epilyttv siirto}
translate U WhiteDecisiveAdvantage {Valkealla on ratkaiseva etu}
translate U BlackDecisiveAdvantage {Mustalla on ratkaiseva etu}
translate U WhiteClearAdvantage {Valkealla on selv etu}
translate U BlackClearAdvantage {Mustalla on selv etu}
translate U WhiteSlightAdvantage {Valkealla on hieman etua}
translate U BlackSlightAdvantage {Mustalla on hieman etua}
translate U WhiteCrushing {Valkoisella on murskausetu}
translate U BlackCrushing {Mustalla on murskaava etu}
translate U Equality {Tasa-asema}
translate U Unclear {Epselv}
translate U Diagram {Kaavio}

# Board search:
translate U BoardSearch {Asemahaku}
translate U FilterOperation {Operaatio nykyiselle suodattimelle:}
translate U FilterAnd {AND (rajoita suodatinta)}
translate U FilterOr {OR (Lis suodattimeen)}
translate U FilterIgnore {IGNORE (Alusta suodatin)}
translate U SearchType {Hakutapa:}
translate U SearchBoardExact {Tsmllinen (kaikki nappulat samoissa ruuduissa)}
translate U SearchBoardPawns {Sotilaat (sama materiaali, sotilaat samoissa ruuduissa)}
translate U SearchBoardFiles {Rivit (sama materiaali, sotilaat samoilla riveill)}
translate U SearchBoardAny {Kaikki (sama materiaali, sotilaat ja upseerit miss tahansa)}
translate U SearchInRefDatabase { Etsi referenssikannasta }
translate U LookInVars {Etsi mys muunnelmista}

# Material search:
translate U MaterialSearch {Materiaalhaku}
translate U Material {Materiaali}
translate U Patterns {Tunnusmerkit}
translate U Zero {Nolla}
translate U Any {Kaikki}
translate U CurrentBoard {Nykyinen lauta}
translate U CommonEndings {Yleiset loppupelit}
translate U CommonPatterns {Yleiset tunnusmerkit}
translate U MaterialDiff {Materiaaliero}
translate U squares {ruudut}
translate U SameColor {Sama vri}
translate U OppColor {Vastavri}
translate U Either {Molemmat}
translate U MoveNumberRange {Siirtonumerot}
translate U MatchForAtLeast {Yhteisen vhintn}
translate U HalfMoves {puolisiirtoa}

# Common endings in material search:
translate U EndingPawns {Sotilasloppupelit}
translate U EndingRookVsPawns {Torni vs. sotilas(-aat)}
translate U EndingRookPawnVsRook {Torni ja 1 sotilas vs. torni}
translate U EndingRookPawnsVsRook {Torni ja sotilaita vs. torni}
translate U EndingRooks {Torni vs. torni}
translate U EndingRooksPassedA {Torni vs. torni ja a-vapaasotilas}
translate U EndingRooksDouble {Nelitorniloppupelit}
translate U EndingBishops {Lhetti vs. lhetti}
translate U EndingBishopVsKnight {Lhetti vs. ratsu}
translate U EndingKnights {Ratsu vs. ratsu}
translate U EndingQueens {Kuningatar vs. kuningatar}
translate U EndingQueenPawnVsQueen {Kuningatar ja 1 sotilas vs. kuningatar}
translate U BishopPairVsKnightPair {Kaksi lhetti vs. kaksi ratsua keskipeliss}

# Common patterns in material search:
translate U PatternWhiteIQP {Valkea IQP}
translate U PatternWhiteIQPBreakE6 {Valkea IQP: d4-d5 murto vs. e6}
translate U PatternWhiteIQPBreakC6 {Valkea IQP: d4-d5 murto vs. c6}
translate U PatternBlackIQP {Musta IQP}
translate U PatternWhiteBlackIQP {Valkea IQP vs. musta IQP}
translate U PatternCoupleC3D4 {Valkea c3+d4 eristetty sotilaspari}
translate U PatternHangingC5D5 {Musta riippuvat sotilaat c5 ja d5}
translate U PatternMaroczy {Maroczy-keskusta (sotilaat c4 ja e4)}
translate U PatternRookSacC3 {Tornin uhraus c3:een}
translate U PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)}
translate U PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)}
translate U PatternLightFian {Vaalearuutuiset sivustoinnit (lhetti g2 vs. lhetti b7)}
translate U PatternDarkFian {Tummaruutuiset sivustoinnit (lhetti b2 vs. lhetti g7)}
translate U PatternFourFian {Nelj sivustointia (Lhetit b2,g2,b7,g7)}

# Game saving:
translate U Today {Tnn}
translate U ClassifyGame {Luokittele peli}

# Setup position:
translate U EmptyBoard {Tyhj lauta}
translate U InitialBoard {Alkuasema}
translate U SideToMove {Siirtovuorossa}
translate U MoveNumber {Siirto nro}
translate U Castling {Linnoitus}
translate U EnPassantFile {Ohestalynti}
translate U ClearFen {Tyhjenn FEN}
translate U PasteFen {Liit FEN}

translate U SaveAndContinue {Tallenna ja jatka}
translate U DiscardChangesAndContinue {Hylk mutokset\nja jatka}
translate U GoBack {Takaisin}

# Replace move dialog:
translate U ReplaceMove {Korvaa siirto}
translate U AddNewVar {Lis uusi muunnelma}
translate U NewMainLine {Uusi pmuunnelma}
translate U ReplaceMoveMessage {Siirto on jo olemassa.

Voit korvata sen ja poistaa samalla kaiki seuraavat siirrot tai list siirtosi uutena muunnelmana.

(Jos et halua nhd tt varoitusta jatkossa, muuta toiminto "Kysy ennen korvaamista" valikosta.)}

# Make database read-only dialog:
translate U ReadOnlyDialog {Jos muutat tmn kannan vain luku -moodiin, mitn muutoksia ei sallita.
Pelej ei voi tallentaa tai korvata, eik poistomerkintj muuttaa.
Kaikki tekemsi ECO-luokitukset ja lajittelut ovat tilapisi.

Voit helposti muuttaa kannan takaisin kirjoitusmoodiin sulkemalla ja avaamalla sen uudestaan.

Haluatko varmasti muuttaa kannan vain luku -moodiin?}

# Clear game dialog:
translate U ClearGameDialog {Tt peli on muutettu.

Haluatko jatkaa ja hylt kaikki tehdyt muutokset?
}

# Exit dialog:
translate U ExitDialog {Haluatko todella sulkea Scidin?}
translate U ExitUnsaved {Seuraavissa kannoissa on tallentamattomia muutoksia. Jos lopetat, muutokset menetetn.}

# Import window:
translate U PasteCurrentGame {Liit nykyinen peli}
translate U ImportHelp1 {Syt tai liit peli yllolevaan kehykseen PGN-muodossa.}
translate U ImportHelp2 {Pelin tuonnissa ilmenneet virheet nytetn tss.}
translate U OverwriteExistingMoves {Kirjoitetaanko vanhojen siirtojen plle?}

# ECO Browser:
translate U ECOAllSections {Kaikki ECO-osiot}
translate U ECOSection {ECO-osio}
translate U ECOSummary {Yhteenveto:}
translate U ECOFrequency {Alikoodien yleisyys:}

# Opening Report:
translate U OprepReportFor {Raportti for}
translate U OprepTitle {Avausraportti}
translate U OprepReport {Raportti}
translate U OprepGenerated {Luonut:}
translate U OprepStatsHist {Tilastot ja historia}
translate U OprepStats {Tilastot}
translate U OprepStatAll {Kaikki raportin pelit}
translate U OprepStatBoth {Molemmilla vahvuusluku}
translate U OprepStatSince {alkaen}
translate U OprepOldest {Vanhimmat pelit}
translate U OprepNewest {Uusimmat pelit}
translate U OprepPopular {Nykyinen suosio}
translate U OprepFreqAll {Yleisyys kaikkina vuosina:   }
translate U OprepFreq1   {Viimeisimpn vuotena: }
translate U OprepFreq5   {Viimeisimpin 5 vuotena thn pivn: }
translate U OprepFreq10  {Viimeisimpin 10 vuotena thn pivn: }
translate U OprepEvery {kerran joka %u peliss}
translate U OprepUp {yls %u%s kaikista vuosista}
translate U OprepDown {alas %u%s kaikista vuosista}
translate U OprepSame {ei muutosta kaikista vuosista}
translate U OprepMostFrequent {Yleisimmt pelaajat}
translate U OprepMostFrequentOpponents {Yleisimmt vastustajat}
translate U OprepRatingsPerf {Vahvuusluvut ja suoritusluvut}
translate U OprepAvgPerf {Keskivahvuudet ja -suoritusluvut}
translate U OprepWRating {Valkean vahvuusluku}
translate U OprepBRating {Mustan vahvuusluku}
translate U OprepWPerf {Valkean suoritusluku}
translate U OprepBPerf {Mustan suoritusluku}
translate U OprepHighRating {Pelit, joilla korkein keskivahvuus}
translate U OprepTrends {Tulostrendit}
translate U OprepResults {Tulosten pituudet ja yleisyys}
translate U OprepLength {Pelin pituus}
translate U OprepFrequency {Yleisyys}
translate U OprepWWins {Valkea voittaa: }
translate U OprepBWins {Musta voittaa: }
translate U OprepDraws {Tasapeli:      }
translate U OprepWholeDB {koko tietokanta}
translate U OprepShortest {Lyhimmt voitot}
translate U OprepMovesThemes {Siirrot ja teemat}
translate U OprepMoveOrders {Siirtojrjestykset raportin asemaan}
translate U OprepMoveOrdersOne \
  {Vain yksi siirtojrjestys, jolla thn asemaan on pdytty:}
translate U OprepMoveOrdersAll \
  { %u siirtojrjestyst johti thn asemaan:}
translate U OprepMoveOrdersMany \
  {%u siirtojrjestyst johti thn asemaan. Yleisimmt %u ovat:}
translate U OprepMovesFrom {Siirrot raportin asemasta}
translate U OprepMostFrequentEcoCodes {Yleisimmt ECO-koodit}
translate U OprepThemes {Asemalliset teemat}
translate U OprepThemeDescription {Teemojen yleisyys ensimmisiss %u siirrossa}
translate U OprepThemeSameCastling {Linnoitukset samalle puolelle}
translate U OprepThemeOppCastling {Linnoitukset vastakkaisille puolille}
translate U OprepThemeNoCastling {Kumpikaan ei linnoita}
translate U OprepThemeKPawnStorm {Kuningassivustan sotilasvyry}
translate U OprepThemeQueenswap {Kuningatarten vaihto}
translate U OprepThemeWIQP {Valkean eristetty kuningatarsotilas}
translate U OprepThemeBIQP {Mustan eristetty kuningatarsotilas}
translate U OprepThemeWP567 {Valkean sotilas 5./6./7. rivill}
translate U OprepThemeBP234 {Mustan sotilas 2./3./4. rivill}
translate U OprepThemeOpenCDE {Avoin c/d/e-linja}
translate U OprepTheme1BishopPair {Lhettipari vain toisella}
translate U OprepEndgames {Loppupelit}
translate U OprepReportGames {Raportin pelit}
translate U OprepAllGames    {Kaikki pelit}
translate U OprepEndClass {Materiaali pelin lopussa}
translate U OprepTheoryTable {Teoriataulukko}
translate U OprepTableComment {Luotu %u korkeimmalle rankatusta pelist.}
translate U OprepExtraMoves {Erikoisesti huomioitavat siirrot teoriataulukossa}
translate U OprepMaxGames {Maksimimr pelej teoriataulukossa}
translate U OprepMergeMoves {Yhdistettyjen pelien siirtoraja}
translate U OprepMergeUnique {Yhdist vain ainutlaatuisia pelej}
translate U OprepViewHTML {Nyt HTML}

# Player Report:
translate U PReportTitle {Pelaajaraportti}
translate U PReportColorWhite {valkeilla}
translate U PReportColorBlack {mustilla}
translate U PReportMoves { %s jlkeen}
translate U PReportOpenings {Avaukset}
translate U PReportClipbase {Tyhjenn leikekanta ja kopioi suodatetut pelit siihen}

# Piece Tracker window:
translate U TrackerSelectSingle {Hiiren ykksnappi valitsee tmn nappulan.}
translate U TrackerSelectPair {Hiiren ykksnappi valitsee tmn nappulan; kakkosnappi valitsee mys toisen samanlaisen.}
translate U TrackerSelectPawn {Hiiren ykksnappi valitsee tmn sotilaan; kakkosnappi valitsee kaikki 8 sotilasta.}
translate U TrackerStat {Tilastot}
translate U TrackerGames {% peleist, joissa siirto ruutuun}
translate U TrackerTime {% ajasta kussakin ruudussa}
translate U TrackerMoves {Siirrot}
translate U TrackerMovesStart {Seuranta alkaa siirrosta:}
translate U TrackerMovesStop {Seuranta loppuu siirtoon:}

# Game selection dialogs:
translate U SelectAllGames {Kaikki tietokannan pelit}
translate U SelectFilterGames {Vain suodatetut pelit}
translate U SelectTournamentGames {Vain nykyisen turnauksen pelit}
translate U SelectOlderGames {Vain vanhemmat pelit}

# Delete Twins window:
translate U TwinsNote {Peli on tupla jonkin toisen pelin kanssa: Peleill on samat pelaajat ja lisksi alla mritetyt kriteerit tyttyvt. Kun tuplapari lytyy, lyhyempi peleist poistetaan. Vihje: Kannattaa tarkistaa kannan oikeinkirjoitus ennen tuplien poistoa, koska monien pelaajien nimist on useita kirjoitustapoja. }
translate U TwinsCriteria {Kriteerit: Tuplissa tytyy olla...}
translate U TwinsWhich {Mit pelej tarkastellaan}
translate U TwinsColors {Samat pelaajien vrit?}
translate U TwinsEvent {Sama tapahtuma (turnaus)?}
translate U TwinsSite {Sama paikka?}
translate U TwinsRound {Sama kierros?}
translate U TwinsYear {Sama vuosi?}
translate U TwinsMonth {Sama kuukausi?}
translate U TwinsDay {Sama piv?}
translate U TwinsResult {Sama tulos?}
translate U TwinsECO {Sama ECO-koodi?}
translate U TwinsMoves {Samat siirrot?}
translate U TwinsPlayers {Verrataan pelaajien nimi:}
translate U TwinsPlayersExact {Tsmlleen samat}
translate U TwinsPlayersPrefix {Ensimmiset 4 kirjainta}
translate U TwinsWhen {Tuplia poistettaessa:}
translate U TwinsSkipShort {Ohita kaikki alle 5 siirron pelit?}
translate U TwinsUndelete {Ensin kumoa kaikkien pelien poisto?}
translate U TwinsSetFilter {Aseta suodatin nyttmn kaikki poistetut tuplat?}
translate U TwinsComments {Silyt aina pelit, joissa on kommentteja?}
translate U TwinsVars {Silyt aina pelit, joissa on muunnelmia?}
translate U TwinsDeleteWhich {Mik peli poistetaan:}
translate U TwinsDeleteShorter {Lyhyempi}
translate U TwinsDeleteOlder {Pienempi numero pelilistauksessa}
translate U TwinsDeleteNewer {Suurempi numero pelilistauksessa}
translate U TwinsDelete {Poista pelit}

# Name editor window:
translate U NameEditType {Muokattavan nimen tyyppi}
translate U NameEditSelect {Muokattavat pelit}
translate U NameEditReplace {Korvaa}
translate U NameEditWith {kanssa}
translate U NameEditMatches {Osumat: Tee valinta painamalla Ctrl+1 - Ctrl+9}

# Check games window:
translate U CheckGames {Tarkista pelit}
translate U CheckGamesWhich {Tarkista pelit}
translate U CheckAll {Kaikki pelit}
translate U CheckSelectFilterGames {Vain suodattimen pelit}

# Classify window:
translate U Classify {Luokittele}
translate U ClassifyWhich {Mitk pelit ECO-luokitellaan}
translate U ClassifyAll {Kaikki pelit (kirjoita yli vanhat ECO-koodit)}
translate U ClassifyYear {Viimeisimmn vuoden aikana pelatut}
translate U ClassifyMonth {Viimeisimmn kuukauden aikana pelatut}
translate U ClassifyNew {Vain pelit, joilla ei ole ECO-koodia entuudestaan}
translate U ClassifyCodes {Kytettvt ECO-koodit}
translate U ClassifyBasic {Vain standardit ECO-koodit ("B12", ...)}
translate U ClassifyExtended {Scid-laajennukset ("B12j", ...)}
translate U ClassifyResult {ECO-luokitus valmis: $result game(s) pivitetty.}

# Compaction:
translate U NameFile {Nimitiedosto}
translate U GameFile {Pelitiedosto}
translate U Names {Nimet}
translate U Unused {Kyttmtn}
translate U SizeKb {Koko (kb)}
translate U CurrentState {Nykyinen status}
translate U AfterCompaction {Tiivistmisen jlkeen}
translate U CompactNames {Tiivist nimitiedosto}
translate U CompactGames {Tiivist pelitiedosto}
translate U NoUnusedNames "Ei kyttmttmi nimi, nimitiedosto on valmiiksi tysin tiivistetty."
translate U NoUnusedGames "Pelitiedosto on valmiiksi tysin tiivistetty."
translate U GameFileCompacted {Pelitiedosto tietokannalle on tiivistetty.}

# Sorting:
translate U SortCriteria {Kriteerit}
translate U AddCriteria {Lis kriteeri}
translate U CommonSorts {Yleiset lajittelut}
translate U Sort {Lajittele}

# Exporting:
translate U AddToExistingFile {Lis pelit olemassaolevaan tiedostoon?}
translate U ExportComments {Vie kommentit?}
translate U ExportVariations {Vie muunnelmat?}
translate U IndentComments {Sisenn kommentit?}
translate U IndentVariations {Sisenn muunnelmat?}
translate U ExportColumnStyle {Saraketyyli (siirto per rivi)?}
translate U ExportSymbolStyle {Symboolit annotaatioissa:}
translate U ExportStripMarks {Poista ruutu-/nuolimerkit kommenteista?}

# Goto game/move dialogs:
translate U LoadGameNumber {Ladattavan pelin numero:}
translate U GotoMoveNumber {Siirry siirtoon nro:}

# Copy games dialog:
translate U CopyAllGames {Kopioi kaikki pelit kohteeseen}
translate U CopyGames {Kopioi pelit}
translate U CopyConfirm {
 Haluatko varmasti kopioida suodattimen [::utils::thousands $nGamesToCopy] pelit
 tietokannasta "$fromName"
 tietokantaan "$targetName"?
}
translate U CopyErr {Ei voi kopioida}
translate U CopyErrSource {lhdekanta}
translate U CopyErrTarget {kohdekanta}
translate U CopyErrNoGames {ei sisll pelej suodattimessa}
translate U CopyErrReadOnly {on vain-luku}
translate U CopyErrNotOpen {ei ole auki}

# Colors:
translate U LightSquares {Vaaleat ruudut}
translate U DarkSquares {Tummat ruudut}
translate U SelectedSquares {Valitut ruudut}
translate U SuggestedSquares {Siirtoehdotusten ruudut}
translate U WhitePieces {Valkeat nappulat}
translate U BlackPieces {Mustat nappulat}
translate U WhiteBorder {Valkea reuna}
translate U BlackBorder {Musta reuna}

# Novelty window:
translate U FindNovelty {Etsi uutuus}
translate U Novelty {Uutuus}
translate U NoveltyInterrupt {Uutuuksien etsint keskeytetty}
translate U NoveltyNone {Ei uutuuksia}
translate U NoveltyHelp {
Scid lyt pelin ensimmisen siirron, joka johtaa sellaiseen asemaan, jota ei lydy valitusta tietokannasta tai ECO-avauskirjasta.
}

# Sounds configuration:
translate U SoundsFolder {nitiedostojen hakemisto}
translate U SoundsFolderHelp {Hakemistosta pit lyty tiedostot King.wav, a.wav, 1.wav, jne}
translate U SoundsAnnounceOptions {Siirtoilmoitusasetukset}
translate U SoundsAnnounceNew {Ilmoita uudet siirrot}
translate U SoundsMoveSoundOnly {Vain siirtoni (poista ilmoitukset kytst)}
translate U SoundsAnnounceForward {Ilmoita, kun siirrytn eteenpin yksi siirto}
translate U SoundsAnnounceBack {Ilmoita, kun siirrytn taaksepin yksi siirto}
translate U SoundsSoundDisabled {Scid ei lytnyt Snack-nipakettia kynnistyksen yhteydess;\nni on poistettu kytst.}

# Upgrading databases:
translate U Upgrading {Pivitys}
translate U ConfirmOpenNew {
Tm on vanhaa muotoa (Scid 3) oleva tietokanta, jota ei voi avata Scid 4:ss. Uusi (Scid 4) versio on jo luotu, haluatko avata sen?
}
translate U ConfirmUpgrade {
Tm on vanhaa muotoa (Scid 3) oleva tietokanta. Uuden muotoinen kanta tytyy luoda ennen kuin voit kytt sit Scid 4:ss.

Pivitys luo uuden version tietokannasta ja poistaa sen jlkeen alkuperisen.

Pivitys voi kest jonkin aikaa, mutta se tytyy tehd vain kerran. Mikli pivitys kest liian pitkn, voit keskeytt sen.

Haluatko pivitt tmn tietokannan nyt?
}

# Recent files options:
translate U RecentFilesMenu {Viimeaikaisten tiedostojen lkm Tiedosto-valikossa}
translate U RecentFilesExtra {Viimeaikaisten tiedostojen lkm extra-alivalikossa}

# My Player Names options:
translate U MyPlayerNamesDescription {
Lis alle kyttmsi pelaajanimet, yksi nimi per rivi. Voit kytt villikortteja (esim. "?" korvaa yksittisen merkin, "*" korvaa kuinka monta perkkist merkki hyvns).

Aina kun Scid lataa pelin, jossa on kyttmsi pelaajanimi, peli nytetn pelaajan nkkulmasta. Tarvittaessa lauta knnetn niin, ett musta pelaa alhaalta yls.
}

#Coach
translate U showblunderexists {nyt virheet}
translate U showblundervalue {nyt virheen pistearvo}
translate U showscore {nyt tulos}
translate U coachgame {valmennus}
translate U configurecoachgame {Taktisen pelin asetukset}
translate U configuregame {Peliasetukset}
translate U Phalanxengine {Phalanx-moottori}
translate U Coachengine {Valmennusmoottori}
translate U difficulty {vaikeusaste}
translate U hard {vaikea}
translate U easy {helppo}
translate U Playwith {Pelaa}
translate U white {valeilla}
translate U black {mustilla}
translate U both {molemmilla}
translate U Play {Pelaa}
translate U Noblunder {Ei virhe}
translate U blunder {virhe}
translate U Noinfo {-- Ei info --}
translate U PhalanxOrTogaMissing {Phalanx tai Toga ei lydy}
translate U moveblunderthreshold {sirto on virhe, jos tappio on enemmn kuin}
translate U limitanalysis {rajoita koneanalyysin aikaa}
translate U seconds {sekuntia}
translate U Abort {Keskeyt}
translate U Resume {Jatka}
translate U OutOfOpening {Ei avauskirjastossa}
translate U NotFollowedLine {Et seurannut avauslinjaa}
translate U DoYouWantContinue {Haluatko jatkaa?}
translate U CoachIsWatching {Valmentaja seuraa}
translate U Ponder {Jatkuva analyysi}
translate U LimitELO {Rajoita ELO-vahvuus}
translate U DubiousMovePlayedTakeBack {Epilyttv siirto, haluatko peruuttaa sen?}
translate U WeakMovePlayedTakeBack {Heikko siirto, haluatko peruuttaa sen?}
translate U BadMovePlayedTakeBack {Huono siirto, haluatko peruuttaa sen?}
translate U Iresign {Luovutan}
translate U yourmoveisnotgood {siirtosi ei ole hyv}
translate U EndOfVar {Muunnelman loppu}
translate U Openingtrainer {Avausvalmentaja}
translate U DisplayCM {Nyt ehdokassiirrot}
translate U DisplayCMValue {Nyt ehdokassiirtojen arvot}
translate U DisplayOpeningStats {Nyt tilastot}
translate U ShowReport {Nyt raportti}
translate U NumberOfGoodMovesPlayed {hyvi siirtoja}
translate U NumberOfDubiousMovesPlayed {epilyttvi siirtoja}
translate U NumberOfMovesPlayedNotInRepertoire {siirtoja, jotka eivt ole repertuaarissa}
translate U NumberOfTimesPositionEncountered {kerta asemassa}
translate U PlayerBestMove  {Salli vain parhaat siirrot}
translate U OpponentBestMove {Vastustaja pelaa parhaita siirtoja}
translate U OnlyFlaggedLines {Vain merkityt muunnelmat}
translate U resetStats {Nollaa tilastot}
translate U Repertoiretrainingconfiguration {Repertuaarivalmennuksen asetukset}
translate U Loadingrepertoire {Lataa repertuaari}
translate U Movesloaded {Siirrot ladattu}
translate U Repertoirenotfound {Repertuaaria ei lydy}
translate U Openfirstrepertoirewithtype {Avaa ensimminen repertuaari, jonka kuvake/tyyppi on oikealla}
translate U Movenotinrepertoire {Siirtoa ei lydy repertuaarista}
translate U PositionsInRepertoire {Asemat repertuaarissa}
translate U PositionsNotPlayed {Asemat, joita ei pelattu}
translate U PositionsPlayed {Pelatut asemat}
translate U Success {Onnistuminen}
translate U DubiousMoves {Epilyttvt siirrot}
translate U OutOfRepertoire {Ei repertuaarissa}
translate U ConfigureTactics {Taktiikka-asetukset}
translate U ResetScores {Nollaa tulokset}
translate U LoadingBase {Ladataan kantaa}
translate U Tactics {Taktiikat}
translate U ShowSolution {Nyt ratkaisu}
translate U NextExercise {Seuraava harjoitus}
translate U PrevExercise {Edellinen harjoitus}
translate U StopTraining {Lopeta harjoittelu}
translate U Next {Seuraava}
translate U ResettingScore {Nollataan tulokset}
translate U LoadingGame {Ladataan peli}
translate U MateFound {Matti lytyi}
translate U BestSolutionNotFound {Paras ratkaisu ei lytynyt!}
translate U MateNotFound {Matti ei lytynyt}
translate U ShorterMateExists {On lyhyempikin matti}
translate U ScorePlayed {Tulos}
translate U Expected {odotustulos}
translate U ChooseTrainingBase {Valitse harjoituskanta}
translate U Thinking {Thinking}
translate U AnalyzeDone {Analyysi valmis}
translate U WinWonGame {Voita voittoasema}
translate U Lines {Muunnelmat}
translate U ConfigureUCIengine {UCI-moottorin asetukset}
translate U SpecificOpening {Tietty avaus}
translate U StartNewGame {Aloita uusi peli}
translate U FixedLevel {Kiinte taso}
translate U Opening {Avaus}
translate U RandomLevel {Satunnainen taso}
translate U StartFromCurrentPosition {Aloita tmnhetkisest asemasta}
translate U FixedDepth {Kiinte syvyys}
translate U Nodes {Noodit}
translate U Depth {Syvyys}
translate U Time {Aika} 
translate U SecondsPerMove {sekuntia per siirto}
translate U Engine {Moottori}
translate U TimeMode {Aikamoodi}
translate U TimeBonus {Aika + bonus}
translate U TimeMin {min}
translate U TimeSec {s}
translate U AllExercisesDone {Kaikki harjoitukset tehty}
translate U MoveOutOfBook {Siirtoa ei lydy avauskirjasta}
translate U LastBookMove {Viimeinen kirjasiirto}
translate U AnnotateSeveralGames {Annotoi useita pelej\nalkaen nykyisest, ptten:}
translate U FindOpeningErrors {Etsi avausvirheet}
translate U MarkTacticalExercises {Merkitse taktiset harjoitukset}
translate U UseBook {Kyt avauskirjaa}
translate U MultiPV {Monia muunnelmia}
translate U Hash {Vlimuisti}
translate U OwnBook {Kyt moottorin avauskirjaa}
translate U BookFile {Avauskirja}
translate U AnnotateVariations {Annotoi muunnelmat}
translate U ShortAnnotations {Lyhyet annotaatiot}
translate U addAnnotatorTag {Lis merkint annotaattorista}
translate U AddScoreToShortAnnotations {Lis tulos annotaatioihin}
translate U Export {Vie}
translate U BookPartiallyLoaded {Kirja osittain ladattu}
translate U Calvar {Muunnelmien laskenta}
translate U ConfigureCalvar {Asetukset}
# Opening names used in tacgame.tcl
translate U Reti {Reti}
translate U English {English}
translate U d4Nf6Miscellaneous {1.d4 Nf6 Miscellaneous}
translate U Trompowsky {Trompowsky}
translate U Budapest {Budapest}
translate U OldIndian {Old Indian}
translate U BenkoGambit {Benko Gambit}
translate U ModernBenoni {Modern Benoni}
translate U DutchDefence {Dutch Defence}
translate U Scandinavian {Scandinavian}
translate U AlekhineDefence {Alekhine Defence}
translate U Pirc {Pirc}
translate U CaroKann {Caro-Kann}
translate U CaroKannAdvance {Caro-Kann Advance}
translate U Sicilian {Sicilian}
translate U SicilianAlapin {Sicilian Alapin}
translate U SicilianClosed {Sicilian Closed}
translate U SicilianRauzer {Sicilian Rauzer}
translate U SicilianDragon {Sicilian Dragon}
translate U SicilianScheveningen {Sicilian Scheveningen}
translate U SicilianNajdorf {Sicilian Najdorf}
translate U OpenGame {Open Game}
translate U Vienna {Vienna}
translate U KingsGambit {King's Gambit}
translate U RussianGame {Russian Game}
translate U ItalianTwoKnights {Italian/Two Knights}
translate U Spanish {Spanish}
translate U SpanishExchange {Spanish Exchange}
translate U SpanishOpen {Spanish Open}
translate U SpanishClosed {Spanish Closed}
translate U FrenchDefence {French Defence}
translate U FrenchAdvance {French Advance}
translate U FrenchTarrasch {French Tarrasch}
translate U FrenchWinawer {French Winawer}
translate U FrenchExchange {French Exchange}
translate U QueensPawn {Queen's Pawn}
translate U Slav {Slav}
translate U QGA {QGA}
translate U QGD {QGD}
translate U QGDExchange {QGD Exchange}
translate U SemiSlav {Semi-Slav}
translate U QGDwithBg5 {QGD with Bg5}
translate U QGDOrthodox {QGD Orthodox}
translate U Grunfeld {Grnfeld}
translate U GrunfeldExchange {Grnfeld Exchange}
translate U GrunfeldRussian {Grnfeld Russian}
translate U Catalan {Catalan}
translate U CatalanOpen {Catalan Open}
translate U CatalanClosed {Catalan Closed}
translate U QueensIndian {Queen's Indian}
translate U NimzoIndian {Nimzo-Indian}
translate U NimzoIndianClassical {Nimzo-Indian Classical}
translate U NimzoIndianRubinstein {Nimzo-Indian Rubinstein}
translate U KingsIndian {King's Indian}
translate U KingsIndianSamisch {King's Indian Smisch}
translate U KingsIndianMainLine {King's Indian Main Line}

# FICS
translate U ConfigureFics {FICS-asetukset}
translate U FICSGuest {Kirjaudu vierailijana (Guest)}
translate U FICSServerPort {Serveriportti}
translate U FICSServerAddress {IP-osoite}
translate U FICSRefresh {Pivit}
translate U FICSTimesealPort {Timeseal portti}
translate U FICSSilence {Konsolisuodatin}
translate U FICSOffers {Tarjoukset}
translate U FICSConsole {Konsoli}
translate U FICSGames {Pelit}
translate U FICSUnobserve {Lopeta seuraaminen}
translate U FICSProfile {Nyt historia ja profiili}
translate U FICSRelayedGames {Seurattavat pelit (Relay)}
translate U FICSFindOpponent {Etsi vastustaja}
translate U FICSTakeback {Peruuta siirto}
translate U FICSTakeback2 {Peruuta 2}
translate U FICSInitTime {Alkuaika (min)}
translate U FICSIncrement {lis per siirto (s)}
translate U FICSRatedGame {Vahvuuslaskentaan}
translate U FICSAutoColour {automaattisesti}
translate U FICSManualConfirm {vahvista}
translate U FICSFilterFormula {Suodatin kaavalla}
translate U FICSIssueSeek {Tee haku}
translate U FICSChallenge {Haasta}
translate U FICSAccept {hyvksy}
translate U FICSDecline {hylk}
translate U FICSColour {Vri}
translate U FICSSend {lhet}
translate U FICSConnect {yhdist}
translate U FICSdefaultuservars {Kyt oletusmuuttujia}
translate U FICSObserveconfirm {Haluatko seurata peli}
translate U FICSpremove {Ennakkosiirto plle}
translate U FICSObserve {Tarkkailla}
translate U FICSRatedGames {Arvioidut pelit}
translate U FICSUnratedGames {Luokittelemattomat pelit}
translate U FICSRated {Arvioitu}
translate U FICSUnrated {Luokittelematon}
translate U FICSRegisteredPlayer {Vain rekisteritynyt pelaaja}
translate U FICSFreePlayer {Vain ilmainen pelaaja}
translate U FICSNetError {Verkkovirhe\Ei voi muodostaa yhteytt}

# Game review
translate U GameReview {Pelin arvioiminen}
translate U GameReviewTimeExtended {Lisaika}
translate U GameReviewMargin {Virhemarginaali}
translate U GameReviewAutoContinue {Jatka automaattisesti, kun siirto on oikein}
translate U GameReviewReCalculate {Kyt lisaikaa}
translate U GameReviewAnalyzingMovePlayedDuringTheGame {Analysoidaan pelattua siirtoa}
translate U GameReviewAnalyzingThePosition {Analysoidaan asemaa}
translate U GameReviewEnterYourMove {Syt siirtosi}
translate U GameReviewCheckingYourMove {Tarkistetaan siirtoa}
translate U GameReviewYourMoveWasAnalyzed {Siirtosi on analysoitu}
translate U GameReviewYouPlayedSameMove {Pelasit saman siirron kuin peliss}
translate U GameReviewScoreOfYourMove {Siirtosi arvo}
translate U GameReviewGameMoveScore {Pelisiirron arvo}
translate U GameReviewEngineScore {Moottorin arvo}
translate U GameReviewYouPlayedLikeTheEngine {Pelasit yht hyvin kuin moottori}
translate U GameReviewNotEngineMoveButGoodMove {Eri siirto kuin moottorilla, mutta silti hyv}
translate U GameReviewMoveNotGood {Tm ei ole hyv siirto, arvio: }
translate U GameReviewMovesPlayedLike {Siirrot kuin}
translate U GameReviewMovesPlayedEngine {Siirrot kuin moottorilla}

# Correspondence Chess Dialogs:
translate U CCDlgCGeneraloptions {Yleiset}
translate U CCDlgLoginName  {Kyttjtunnus:}
translate U CCDlgPassword   {Salasana:}
translate U CCDlgShowPassword {Nyt salasana}

# Connect Hardware dialogs
translate U ExtHWConfigConnection {Ulkoisten laitteiden asetukset}
translate U ExtHWPort {Portti}
translate U ExtHWEngineCmd {Moottorin komento}
translate U ExtHWEngineParam {Moottorin parametri}
translate U ExtHWShowButton {Nyt painike}
translate U ExtHWHardware {Hardware}
translate U ExtHWNovag {Novag Citrine}
translate U ExtHWInputEngine {Input Engine}
translate U ExtHWNoBoard {Ei lautaa}
translate U NovagReferee {Referee}

# Input Engine dialogs
translate U IEConsole {Input Engine Console}
translate U IESending {Siirrot lhetetn}
translate U IESynchronise {Synkronoi}
translate U IERotate  {Knn}
translate U IEUnableToStart {Input Engine ei voi kynnisty:}

# Calculation of Variations
translate U DoneWithPosition {Asema valmis}

translate U Board {Lauta}
translate U showGameInfo {Nyt pelin tiedot}
translate U autoResizeBoard {Sd laudan koko automaattisesti}
translate U DockTop {Siirr ylimmksi}
translate U DockBottom {Siirr alimmaksi}
translate U DockLeft {Siirr vasemmalle}
translate U DockRight {Siirr oikealle}
translate U Undock {Vapauta lukitus}

# Switcher window
translate U AboutDatabase {Tietoja tst tietokannasta}
translate U ChangeIcon {Vaihda kuvake...}
translate U NewGameListWindow {Uusi peliluettelo-ikkuna}
translate U LoadatStartup {Lataa kynnistyksen yhteydess}

# Gamelist window
translate U ShowHideDB {Nyt/piilota tietokannat}
translate U ChangeFilter {Vaihda suodatin}
translate U ChangeLayout {Lataa/Tallenna/Muuta lajitteluehtoja ja sarakkeiden asettelua}
translate U ShowHideStatistic {Nyt/piilota tilastot}
translate U BoardFilter {Nyt vain pelit, jotka vastaavat nykyist laudan sijaintia}
translate U CopyGameTo {Kopioi peli kohteeseen}
translate U FindBar {Etsi Baari}
translate U FindCurrentGame {Etsi nykyinen peli}
translate U DeleteGame {Poista peli}
translate U UndeleteGame {Peru pelin poisto}
translate U ResetSort {Nollaa lajittelu}

translate U ConvertNullMove {Muunna nollasiirrot kommenteiksi}
translate U SetupBoard {Asennustaulu}
translate U Rotate {Kiert}
translate U SwitchColors {Vaihda vrej}
translate U FlipBoard {Flip Board}
translate U ImportPGN {Tuo PGN-peli}
translate U ImportingFiles {PGN-tiedostojen tuonti sisn}
translate U ImportingFrom {Tuodaan kohteesta}
translate U ImportingIn {Tuo pelit sisn}
translate U UseLastTag {Kyt viimeisen pelin tunnisteita}
translate U Random {Satunnainen}
translate U BackToMainline {Palaa plinjaan}
translate U LeaveVariant {Jt variantti}
translate U Autoplay {Automaattinen toisto}
translate U ShowHideCoords {Nyt/piilota Coord.}
translate U ShowHideEvalBar {Nyt/piilota arviointipalkki}
translate U ShowHideMaterial {Nyt/piilota materiaali}
translate U SelectMarker {Valitse Merkki}
translate U FullScreen {Koko nytt}
translate U FilterStatistic {Suodata tilastot}
translate U MakeCorrections {Tee korjauksia}
translate U Surnames {Sukunimet}
translate U Ambiguous {Epselv}

#Preferences Dialog
translate U OptionsToolbar "Tykalupalkki"
translate U OptionsBoard "Shakkilauta"
translate U OptionsBoardSize "Koko"
translate U OptionsBoardPieces "Nappulat"
translate U OptionsInternationalization "Kansainvlistyminen"
translate U OptionsTablebaseDir "Valitse enintn 4 taulukkokantakansiota:"

# Evaluation bar
translate U BestMoveArrow "Paras liikkuva nuoli"
translate U NewLocalEngine "+ Uusi moottori..."

# Batch Annotate
translate U BatchAnnotate {Er‰ Annotate}
translate U BatchEngineSelection {Moottorin valinta}
translate U BatchChessEngine {Shakkimoottori:}
translate U BatchNumberOfInstances {Tapausten m‰‰r‰:}
translate U BatchGameReview {Pelin arvostelu}
translate U BatchTimePerMove {Aika per liike (s):}
translate U BatchAnnotateBlunders {Merkitse vain virheit‰}
translate U BatchBlunderThreshold {Virheen kynnys:}
translate U BatchVariationLength {Vaihtelun pituus (liikkeet):}
translate U BatchOpeningBook {Avauskirja}
translate U BatchUseBook {K‰yt‰ kirjaa}
translate U BatchAnnotateVariations {Merkitse muunnelmia}
translate U BatchShortAnnotations {Lyhyet huomautukset}
translate U BatchAddScoreToShort {Lis‰‰ pisteit‰ lyhyisiin huomautuksiin}
translate U BatchClearOld {Poista vanhat kommentit ja muunnelmat}
translate U BatchInitializingEngines {Moottoreita alustetaan...}
translate U BatchAnalyzingGames {Analysoidaan pelej‰...}
translate U BatchProgress {Er‰merkinn‰n edistyminen}
translate U BatchComplete {Er‰merkint‰ valmis!}
translate U BatchCancelled {Er‰n huomautus peruutettu}
translate U BatchStart {Aloita}
translate U BatchCancel {Peruuttaa}
translate U BatchCompleted {valmiiksi}
translate U BatchGames {pelej‰}
translate U BatchProcessed {k‰sitelty}
}
# end of english.tcl
