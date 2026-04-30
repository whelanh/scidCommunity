# hungary.tcl:
# Hungarian text for menu names and status bar help messages for SCID
# Translated by: Gbor Szts

proc setLanguage_H {} {

# File menu:
menuText H File "Fjl" 0
menuText H FileNew "j..." 0 {j SCID-adatbzis ltrehozsa}
menuText H FileOpen "Megnyit..." 3 {Meglv SCID-adatbzis megnyitsa}
menuText H FileClose "Bezr" 2 {Az aktv SCID-adatbzis bezrsa}
menuText H FileFinder "Fjlkeres" 0 {Kinyitja a Fjlkeres ablakot.}
menuText H FileBookmarks "Knyvjelzk" 0 {Knyvjelzmen (gyorsbillenty: Ctrl+B)}
menuText H FileBookmarksAdd "j knyvjelz" 0 \
  {Megjelli az aktulis jtszmt s llst.}
menuText H FileBookmarksFile "Knyvjelz mentse" 11 \
  {Az llshoz tartoz knyvjelzt kln knyvtrba teszi.}
menuText H FileBookmarksEdit "Knyvjelzk szerkesztse..." 13 \
  {Knyvjelzk szerkesztse}
menuText H FileBookmarksList "Megjelents listaknt" 13 \
  {A knyvjelzk knyvtrai nem almenknt, hanem listaknt jelennek meg.}
menuText H FileBookmarksSub "Megjelents almenknt" 13 \
  {A knyvjelzk knyvtrai nem listaknt, hanem almenknt jelennek meg.}
menuText H FileMaint "Gondozs" 0 {SCID adatbzisgondoz eszkzk}
menuText H FileMaintWin "Adatbzisgondoz ablak" 0 \
  {Kinyitja/becsukja az SCID adatbzisgondoz ablakot.}
menuText H FileMaintCompact "Adatbzis tmrtse..." 10 \
  {Eltvoltja az adatbzisbl a trlt jtszmkat s a hasznlaton kvl ll neveket.}
menuText H FileMaintClass "Osztlyba sorols..." 0 \
  {jra kiszmtja az sszes jtszma ECO-kdjt.}
menuText H FileMaintSort "Rendezs..." 0 \
  {Rendezi az adatbzis sszes jtszmjt.}
menuText H FileMaintDelete "Ikerjtszmk trlse..." 0 \
  {Megkeresi az ikerjtszmkat, s megjelli ket trlsre.}
menuText H FileMaintTwin "Ikerkeres ablak" 4 \
  {Kinyitja/becsukja az ikerkeres ablakot.}
menuText H FileMaintName "Nevek helyesrsa" 0 {Nvszerkeszt s helyesrsi eszkzk}
menuText H FileMaintNameEditor "Nvszerkeszt" 0 \
  {Kinyitja/becsukja a nvszerkeszt ablakot.}
menuText H FileMaintNamePlayer "Jtkosnevek ellenrzse..." 0 \
  {A helyesrs-ellenrz fjl segtsgvel ellenrzi a jtkosok nevt.}
menuText H FileMaintNameEvent "Esemnynevek ellenrzse..." 0 \
  {A helyesrs-ellenrz fjl segtsgvel ellenrzi esemnyek nevt.}
menuText H FileMaintNameSite "Helynevek ellenrzse..." 0 \
  {A helyesrs-ellenrz fjl segtsgvel ellenrzi a helysznek nevt.}
menuText H FileMaintNameRound "Fordulnevek ellenrzse..." 0 \
  {A helyesrs-ellenrz fjl segtsgvel ellenrzi a fordulk nevt.}
menuText H FileReadOnly "rsvdelem..." 0 \
  {Az aktulis adatbzist csak olvashatv teszi, nehogy meg lehessen vltoztatni.}
menuText H FileSwitch "Adatbzisvlts" 0 \
  {tvlt egy msik megnyitott adatbzisra.}
menuText H FileOpenLichessTournament "Nylt Lichess torna" 0 {Tltse le s nyissa meg az l Lichess verseny kzvettett jtkait}
menuText H FileImportLichess "Importlja a Lichess-emet" 0 {Importljon jtkokat Lichess-fikjbl}
menuText H FileImportChessCom "Importlja a chess.com-omat" 0 {Importljon jtkokat a chess.com fikjbl}
menuText H FileExit "Kilp" 2 {Kilp SCID-bl.}
menuText H FileMaintFixBase "Megrongldott adatbzis javtsa" 25 {Megprblja megjavtani a megrongldott adatbzist.}

# Edit menu:
menuText H Edit "Szerkeszts" 1
menuText H EditAdd "j vltozat" 0 {Ennl a lpsnl j vltozatot szr be a jtszmba.}
menuText H EditDelete "Vltozat trlse" 9 {Trl egy vltozatot ennl a lpsnl.}
menuText H EditFirst "Els vltozatt tesz" 0 \
  {Els helyre teszi a vltozatot a listn.}
menuText H EditMain "Fvltozatt tesz" 0 \
  {A vltozatot fvltozatt lpteti el.}
menuText H EditTrial "Vltozat kiprblsa" 0 \
  {Elindtja/meglltja a prbazemmdot, amellyel egy elgondolst lehet a tbln kiprblni.}
menuText H EditStrip "Lecsupaszt" 2 {Eltvoltja a megjegyzseket vagy a vltozatokat ebbl a jtszmbl.}
menuText H EditUndo "Visszavons" 0 {Az utols jtkmdosts visszavonsa}
menuText H EditRedo "jra" 0 {Hajtsa vgre a legutbbi jtkmdostst}
menuText H EditStripComments "Megjegyzsek" 0 \
  {Eltvoltja az sszes megjegyzst s elemzst ebbl a jtszmbl.}
menuText H EditStripVars "Vltozatok" 0 {Eltvoltja az sszes vltozatot ebbl a jtszmbl.}
menuText H EditStripBegin "Az elejtl" 3 \
  {Levgja a jtszma elejt}
menuText H EditStripEnd "A vgig" 2 \
  {Levgja a jtszma vgt}
menuText H EditReset "Kirti a Vgasztalt" 2 \
  {Alaphelyzetbe hozza a Vgasztalt, hogy az teljesen res legyen.}
menuText H EditCopy "A Vgasztalra msolja ezt a jtszmt." 15 \
  {Ezt a jtszmt tmsolja a Vgasztal adatbzisba.}
menuText H EditPaste "Beilleszti az utols jtszmt a Vgasztalrl." 0 \
  {A Vgasztal aktv jtszmjt beilleszti ide.}
menuText H EditPastePGN "A vglap tartalmt PGN-jtszmaknt beilleszti" 20 \
  {A vglap tartalmt PGN-jells jtszmnak tekinti, s idemsolja.}
menuText H EditSetup "Kezdlls fellltsa..." 14 \
  {Fellltja a kezdllst ehhez a jtszmhoz.}
menuText H EditCopyBoard "lls msolsa FEN-knt" 17 \
  {Az aktulis llst FEN-jellssel a vglapra msolja.}
menuText H EditPasteBoard "Kezdlls beillesztse" 13 \
  {Fellltja a kezdllst kijellt szveg (vglap) alapjn.}
menuText H ConfigureScid "Belltsok..." 0 {Konfigurlja az SCID sszes belltst}

# Game menu:
menuText H Game "Jtszma" 0
menuText H GameNew "j jtszma" 0 \
  {j jtszmt kezd; a vltoztatsokat elveti.}
menuText H GameFirst "Betlti az els jtszmt." 11 {Betlti az els szrt jtszmt.}
menuText H GamePrev "Betlti az elz jtszmt." 12 {Betlti az elz szrt jtszmt.}
menuText H GameReload "Ismt betlti az aktulis jtszmt." 0 \
  {jra betlti ezt a jtszmt; elvet minden vltoztatst.}
menuText H GameNext "Betlti a kvetkez jtszmt." 10 {Betlti a kvetkez szrt jtszmt.}
menuText H GameLast "Betlti az utols jtszmt." 11 {Betlti az utols szrt jtszmt.}
menuText H GameRandom "Vletlenszeren betlt egy jtszmt." 0 {Vletlenszeren betlt egy szrt jtszmt.}
menuText H GameNumber "Megadott sorszm jtszma betltse..." 9 \
  {Betlti a sorszmmal megadott jtszmt.}
menuText H GameReplace "Ments cservel..." 7 \
  {Elmenti ezt a jtszmt; fellrja a rgi vltozatot.}
menuText H GameAdd "Ments j jtszmaknt..." 0 \
  {Elmenti ezt a jtszmt; j jtszmt hoz ltre az adatbzisban.}
menuText H GameDeepest "Megnyits azonostsa" 10 \
  {Az ECO-knyvben szerepl legnagyobb mlysgig megy bele a jtszmba.}
menuText H GameGotoMove "Ugrs megadott sorszm lpshez..." 1 \
  {Megadott sorszm lpshez ugrik az aktulis jtszmban.}
menuText H GameNovelty "jts keresse..." 1 \
  {Megkeresi ebben a jtszmban az els olyan lpst, amely korbban nem fordult el.}

# Search Menu:
menuText H Search "Keress" 0
menuText H SearchReset "Szr trlse" 6 {Alaphelyzetbe hozza a szrt, hogy az sszes jtszma benne legyen.}
menuText H SearchNegate "Szr neglsa" 6 {Neglja a szrt, hogy csak a kizrt jtszmk legyenek benne.}
menuText H SearchCurrent "Aktulis lls..." 0 {A tbln lv llst keresi.}
menuText H SearchHeader "Fejlc..." 0 {Keress fejlc (jtkos, esemny, stb.) alapjn}
menuText H SearchMaterial "Anyag/szerkezet..." 6 {Keress anyag vagy llsszerkezet alapjn}
menuText H SearchUsing "Keresfjl hasznlata..." 0 {Keress SearchOptions fjl hasznlatval}

# Windows menu:
menuText H Windows "Ablakok" 0
menuText H WindowsComment "Megjegyzsszerkeszt" 0 {Megnyitja/bezrja a megjegyzsszerkesztt.}
menuText H WindowsGList "Jtszmk listja" 9 {Kinyitja/becsukja a jtszmk listjt mutat ablakot.}
menuText H WindowsPGN "PGN" 0 \
  {Kinyitja/becsukja a PGN-(jtszmajegyzs)-ablakot.}
menuText H WindowsPList "Jtkoskeres" 0 {Kinyitja/becsukja a jtkoskerest.}
menuText H WindowsTmt "Versenykeres" 0 {Kinyitja/becsukja a versenykerest.}
menuText H WindowsSwitcher "Adatbzisvlt" 0 \
  {Kinyitja/becsukja az adatbzisvlt ablakot.}
menuText H WindowsMaint "Adatbzisgondoz" 9 \
  {Kinyitja/becsukja az adatbzisgondoz ablakot.}
menuText H WindowsECO "ECO-bngsz" 0 {Kinyitja/becsukja az ECO-bngsz ablakot.}
menuText H WindowsStats "Statisztika" 0 \
  {Kinyitja/becsukja a szrsi statisztika ablakt.}
menuText H WindowsTree "Faszerkezet" 0 {Kinyitja/becsukja a faszerkezet-ablakot.}
menuText H WindowsBook "Megnyitstrablak" 3 {Kinyitja/becsukja a megnyitstrablakot.}
menuText H WindowsCorrChess "Levelezsi sakk" 14 {Open/close the Correspondence window}
menuText H WindowsGraph "Elemzsi grafikon" 0 {Nyissa meg a Grafikon ablakot a lpsek idejvel s rtkelsvel}

# Tools menu:
menuText H Tools "Eszkzk" 0
menuText H ToolsConfigureEngines "Motorok konfigurlsa" 10 {A motorok konfigurcijnak kezelse}
menuText H ToolsAnalysis "Elemz motor..." 0 \
  {Elindt/lellt egy sakkelemz programot.}
menuText H ToolsAnalysis2 "Msodik elemz motor..." 1 \
  {Elindtja/lelltja a 2. sakkelemz programot.}
menuText H ToolsCross "Versenytblzat" 0 {Megmutatja az ehhez a jtszmhoz tartoz verseny tblzatt.}
menuText H ToolsFilterGraph "Szrgrafikon" 0 \
  {Kinyitja/becsukja a szrgrafikont mutat ablakot.}
menuText H ToolsAbsFilterGraph "Abszolt szrgrafikon" 0 {Kinyitja/becsukja az abszolt rtkeket mutat szrgrafikon-ablakot}
menuText H ToolsOpReport "Megnyitsi sszefoglal" 0 \
  {Ismertett kszt az aktulis llshoz tartoz megnyitsrl.}
menuText H ToolsOpenBaseAsTree "Adatbzis megnyitsa faknt" 10   {Faszerkezet-ablakban megnyit egy adatbzist.}
menuText H ToolsOpenRecentBaseAsTree "Nemrg hasznlt adatbzis megnyitsa faknt" 7   {Faszerkezet-ablakban megnyit egy nemrg hasznlt adatbzist.}
menuText H ToolsTracker "Figurakvet"  0 {Kinyitja/becsukja a figurakvet ablakot.}
menuText H ToolsTraining "Edzs"  0 {Segdeszkzk edzshez (taktika, megnyits,...) }
menuText H ToolsTacticalGame "Taktikai jtszma"  0 {Taktikai jelleg jtszma kezdse}
menuText H ToolsSeriousGame "Komoly jtszma"  0 {Komoly jtszma kezdse}
menuText H ToolsTrainOpenings "Megnyits"  0 {Edzs repertorral}
menuText H ToolsTrainReviewGame "Jtk ttekintse"  0 {Talld meg a jtkban jtszott mozdulatokat}
menuText H ToolsTrainTactics "Taktika"  0 {Feladvnyok megfejtse}
menuText H ToolsTrainCalvar "Vltozatszmts"  0 {Vltozatszmts gyakorlsa}
menuText H ToolsTrainFindBestMove "Legjobb lps"  0 {A legjobb lps megkeresse}
menuText H ToolsTrainFics "Internetes jtszma"  0 {Jtk a freechess.org szerveren}
menuText H ToolsEngineTournament "Motorverseny"  0 {Indtson versenyt a sakkmotorok kztt}
menuText H ToolsTimeAnalysis "Idelemzs" 0 {Az aktulis jtk ra-ideje grafikonjnak megjelentse}
menuText H ToolsBookTuning "Megnyitstr-hangols" 13 {Megnyitstr-hangols}
menuText H ToolsDownloadTWIC "TWIC jtkok letltse" 0 {Tltse le a legjabb The Week In Chess (TWIC) jtkokat}
menuText H ToolsConnectHardware "Hardver csatlakoztatsa" 8 {Kls hardver csatlakoztatsa}
menuText H ToolsConnectHardwareConfigure "Bellts" 0 {Kls hardver s kapcsolat belltsa}
menuText H ToolsConnectHardwareNovagCitrineConnect "Novag Citrine csatlakoztatsa" 0 {Novag Citrine csatlakoztatsa}
menuText H ToolsConnectHardwareInputEngineConnect "Bejv motor csatlakoztatsa" 7 {Bejv motor (pl. DGT) csatlakoztatsa}

menuText H ToolsPInfo "Jtkosinformci"  0 \
  {Kinyitja/frissti a jtkos adatait tartalmaz ablakot.}
menuText H ToolsPlayerReport "sszefoglal jtkosrl..." 0 \
    {sszefoglalt kszt a jtkosrl}
menuText H ToolsRating "rtkszm alakulsa" 0\
  {Grafikusan brzolja, hogyan alakult az aktulis jtszma rsztvevinek rtkszma.}
menuText H ToolsExpCurrent "Az aktulis jtszma exportlsa" 21 \
  {Szvegfjlba rja az aktulis jtszmt.}
menuText H ToolsExpCurrentPGN "Exportls PGN-fjlba..." 11 \
  {PGN-fjlba rja az aktulis jtszmt.}
menuText H ToolsExpCurrentHTML "Exportls HTML-fjlba..." 11 \
  {HTML-fjlba rja az aktulis jtszmt.}
menuText H ToolsExpCurrentHTMLJS "Jtszma exportlsa HTML s JavaScript fjlba" 28 {Az aktulis jtszmt HTML s JavaScript fjlba rja.}  
menuText H ToolsExpFilter "Az sszes szrt jtszma exportlsa" 11 \
  {Szvegfjlba rja az sszes szrt jtszmt.}
menuText H ToolsExpFilterPGN "Szr exportlsa PGN-fjlba..." 18 \
  {PGN-fjlba rja az sszes szrt jtszmt.}
menuText H ToolsExpFilterHTML "Szr exportlsa HTML-fjlba..." 18 \
  {HTML-fjlba rja az sszes szrt jtszmt.}
menuText H ToolsExpFilterHTMLJS "Szr exportlsa HTML s JavaScript fjlba" 30 {Az sszes kiszrt jtszmt HTML s JavaScript fjlba rja.}  
menuText H ToolsImportOne "PGN-jtszma importlsa..." 0 \
  {PGN-formtum jtszma importlsa}
menuText H ToolsImportFile "PGN-fjl importlsa..." 2 \
  {PGN-fjl sszes jtszmjnak importlsa}
menuText H ToolsStartEngine1 "Az 1. motor elindtsa" 3  {Elindtja az 1. motort.}
menuText H ToolsStartEngine2 "A 2. motor elindtsa" 2  {Elindtja a 2. motort.}
menuText H ToolsCaptureBoard "Az aktulis tbla rgztse..." 0  {Mentse el az aktulis tblt kpknt.}

# Play menu
menuText H Play "Jtk" 0

# --- Correspondence Chess
menuText H CCResign "Felads" 0 {Felads (nem eMail tjn)}
menuText H CCClaimDraw "Dntetlen ignylse" 10 {Lps elkldse s dntetlen ignylse (nem eMail tjn)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText H Options "Belltsok" 0
menuText H OptionsBoardGraphics "Mezk..." 0 {A mezk rajzolatnak megvltoztatsa}
translate H OptionsBGW {A mezk rajzolatnak kivlasztsa}
translate H OptionsBoardGraphicsText {A vilgos s stt mezk grafikus fjljai:}
menuText H OptionsBoardNames "Jtkosnevek..." 0 {Jtkosnevek tszerkesztse}
menuText H OptionsExport "Exportls" 1 {Exportlsi belltsok vltoztatsa}
menuText H OptionsFonts "Karakterkszlet" 0 {Karakterkszlet vltoztatsa}
menuText H OptionsFontsRegular "Szoksos" 0 {A szoksos karakterkszlet vltoztatsa}
menuText H OptionsFontsMenu "Men" 0 {A menk karakterkszletnek a vltoztatsa}
menuText H OptionsFontsSmall "Kisbets" 0 {A kisbets karakterkszlet vltoztatsa}
menuText H OptionsFontsTiny "Apr" 0 {Vltoztassa meg az apr bettpust}
menuText H OptionsFontsFixed "Rgztett" 0 {A rgztett szlessg karakterkszlet vltoztatsa}
menuText H OptionsGInfo "Jtszmainformci" 0 {Jtszmainformci vltoztatsa}
menuText H OptionsLanguage "Nyelv" 0 {A men nyelvnek kivlasztsa}
menuText H OptionsMovesTranslatePieces "Figurk nevnek lefordtsa" 0 {Lefordtja a figurk nevnek els betjt.}
menuText H OptionsMovesHighlightLastMove "Az utols lps kiemelse" 0 {Az utols lps kiemelse}
menuText H OptionsMovesHighlightLastMoveDisplay "Show Square" 0 {Utols lps megjelentse Kiemels}
menuText H OptionsMovesHighlightLastMoveWidth "Szlessg" 0 {A vonal vastagsga}
menuText H OptionsMovesHighlightLastMoveColor "Szn" 0 {A vonal szne}
menuText H OptionsMovesHighlightLastMoveArrow "Nyl megjelentse" 0 {Tartalmazza a nyilat a kiemelssel}
menuText H OptionsMovesHighlightLastMoveNag "rtkelsi szimblumok megjelentse" 0
menuText H OptionsMovesHighlightLastMoveEval "Az rtkelsi szimblumok megjelentse" 0
menuText H OptionsMoves "Lpsek" 0 {Lpsek bevitelnek belltsai}
menuText H OptionsMovesAnimate "Megelevents ideje" 0 \
  {Belltja az idt lpsek megeleventshez.}
menuText H OptionsMovesDelay "Automatikus visszajtszs ksleltetse..." 0 \
  {Belltja a ksleltetst automatikus visszajtszshoz.}
menuText H OptionsMovesCoord "Lps megadsa koordintkkal" 15 \
  {Koordintkkal megadott lpst ("g1f3") is elfogad.}
menuText H OptionsMovesSuggest "Javaslat" 0 \
  {Be/kikapcsolja a lpsjavaslatot.}
menuText H OptionsShowVarPopup "Vltozatok ablaka" 0 {Be- vagy kikapcsolja a vltozatokat megjelent ablakot.}  
menuText H OptionsMovesSpace "Szkzk a lps sorszma utn" 0 {Szkzkkel egszti ki a lps sorszmt.}  
menuText H OptionsMovesLichess "Lichess/ChessBase formtum megjegyzsekhez" 0 {Hasznlja a Lichess/ChessBase formtumot ngyzetes jellkhz s nyilakhoz}
menuText H OptionsMovesKey "Billenty-kiegszts" 0 \
  {Be/kikapcsolja a billentyzettel rszlegesen bevitt lpsek automatikus kiegsztst.}
menuText H OptionsMovesShowVarArrows "Nyilak megjelentse a varicikhoz" 0 {Kapcsolja be/ki a nyilakat, amelyek klnbz vltozatokban mutatjk a mozgsokat}
menuText H OptionsMovesShowEngineVariationArrows "Nyilak megjelentse a motorvltozatokhoz" 0 {Kapcsolja be/ki a nyilakat, amelyek a motor vltozsi vonalait mutatjk tbbPV mdban}
menuText H OptionsMovesGlossOfDanger "Sznkdolt Gloss of Danger" 0 {Kapcsolja be/ki a veszly sznkdolt fnyt}
translate H OptionsMovesTreeDepth {Alaprtelmezett fa ablak mozgsi mlysg}
menuText H OptionsNumbers "Szmformtum" 1 {Szmformtum kivlasztsa}
menuText H OptionsTheme "Tma" 0 {A program megjelensnek megvltoztatsa}
menuText H OptionsWindows "Ablakok" 0 {Ablakbelltsok}
menuText H OptionsSounds "Hangok" 3 {Lpseket bejelent hangok definilsa}
menuText H OptionsResources "Erforrs..." 0 {Vlasszon erforrsfjlokat s mappkat}
menuText H OptionsWindowsDock "Ablakok helyhez rgztse" 8 {Dock windows}
menuText H OptionsWindowsSaveLayout "Elrendezs mentse" 11 {Ablakelrendezs mentse}
menuText H OptionsWindowsRestoreLayout "Elrendezs visszalltsa" 11 {Ablakelrendezs visszalltsa}
menuText H OptionsWindowsShowGameInfo "Jtszmainformci" 0 {Jtszma adatainak megjelentse ablakban}
menuText H OptionsWindowsAutoLoadLayout "Az els elrendezs automatikus betltse" 19 {Indulskor automatikusan betlti az els ablakelrendezst.}
menuText H OptionsECO "ECO-fjl betltse" 2 {Betlti az ECO-osztlyoz fjlt.}
menuText H OptionsSpell "Helyesrs-ellenrz fjl betltse" 0 \
  {Betlti a helyesrs-ellenrz fjlt.}
menuText H OptionsTable "Vgjtktblzatok knyvtra" 0 \
  {Vgjtktblzat-fjl kivlasztsa; a knyvtrban lev sszes vgjtktblzatot hasznlatba veszi.}
menuText H OptionsRecent "Aktulis fjlok..." 3 \
  {A Fjl menben megjelentett aktulis fjlok szmnak megvltoztatsa}
menuText H OptionsBooksDir "A megnyitstr knyvtra" 6 {Kijelli a megnyitstr knyvtrt.}
menuText H OptionsTacticsBasesDir "Az adatbzisok knyvtra" 4 {Kijelli a taktikai (edzs) adatbzisok knyvtrt.}
menuText H OptionsPhotosDir "Fotk knyvtr" 0 {Belltja a fnykpek alapknyvtrt}
menuText H OptionsThemeDir "Tma(k) Fjl:"  0 {Tltsn be egy GUI-tmacsomag fjlt}
menuText H OptionsSave "Belltsok mentse" 12 \
  "Minden bellthat rtket elment a $::optionsFile fjlba."
menuText H OptionsAutoSave "Belltsok automatikus mentse kilpskor." 0 \
  {Automatikusan elment minden belltst, amikor kilpsz SCID-bl.}

# Help menu:
menuText H Help "Segtsg" 0
menuText H HelpContents "Tartalomjegyzk" 0 {Megjelenti a tartalomjegyzket}
menuText H HelpIndex "Trgymutat" 1 {Megjelenti a trgymutatt}
menuText H HelpGuide "Rvid ismertet" 0 {Rvid ismertett nyjt a program hasznlatrl.}
menuText H HelpHints "Krds-felelet" 0 {Nhny hasznos tancs}
menuText H HelpContact "Cmek" 0 {Fontosabb internetcmek}
menuText H HelpTip "A nap tippje" 2 {Hasznos tipp SCID hasznlathoz}
menuText H HelpStartup "Indul ablak" 0 {A program indtsakor megjelen ablak}
menuText H HelpAbout "SCID-rl" 0 {Tjkoztats SCID-rl}

# Toolbar tooltips:
menuText H RotateBoard "Forgassa a tblt" 0 {Forgassa a tblt}

# Game info box popup menu:
menuText H GInfoHideNext "Elrejti a kvetkez lpst." 0
menuText H GInfoMaterial "Anyagi helyzetet." 0
menuText H GInfoFEN "FEN-formtum" 0
menuText H GInfoMarks "Mutatja a sznes mezket s nyilakat." 10
menuText H GInfoWrap "Hossz sorok trdelse" 0
menuText H GInfoFullComment "Teljes kommentr" 7
menuText H GInfoPhotos "Fnykpek" 1
menuText H GInfoTBNothing "Vgjtktblzatok: nincs informci" 20
menuText H GInfoTBResult "Vgjtktblzatok: csak eredmny" 20
menuText H GInfoTBAll "Vgjtktblzatok: eredmny s a legjobb lpsek" 42
menuText H GInfoDelete "Trli/helyrelltja ezt a jtszmt." 0
menuText H GInfoMark "Megjelli ezt a jtszmt/megsznteti a jellst." 0
menuText H GInfoInformant "Tjkoztat rtkek hatrainak belltsa" 0

# General buttons:
translate H Back {Vissza}
translate H Browse {Tallz}
translate H Cancel {Mgse}
translate H Continue {Tovbb}
translate H Clear {Trl}
translate H Close {Bezr}
translate H Contents {Tartalom}
translate H Defaults {Alaprtkek}
translate H InvertSearch {Invert Search}
translate H Delete {Trl}
translate H Graph {Grafikon}
translate H Help {Segtsg}
translate H Hide {Elrejt}
translate H Import {Import}
translate H Index {Trgymutat}
translate H LoadGame {Jtszma betltse}
translate H BrowseGame {Jtszma nzegetse}
translate H MergeGame {Jtszma beolvasztsa}
translate H MergeGames {Jtszmk beolvasztsa}
translate H Preview {Elnzet}
translate H Revert {Elvet}
translate H Save {Ment}
translate H Search {Keres}
translate H Stop {llj}
translate H Store {Trol}
translate H Update {Frisst}
translate H ChangeOrient {Ablak elhelyezkedsnek vltoztatsa}
translate H ShowIcons {Ikonok megjelentse} ;# ***
translate H None {Nincs}
translate H First {Els}
translate H Current {Aktulis}
translate H Last {Utols}

# General messages:
translate H game {jtszma}
translate H games {jtszma}
translate H move {lps}
translate H moves {lps}
translate H all {mind}
translate H Yes {Igen}
translate H No {Nem}
translate H Both {Mindkett}
translate H King {Kirly}
translate H Queen {Vezr}
translate H Rook {Bstya}
translate H Bishop {Fut}
translate H Knight {Huszr}
translate H Pawn {Gyalog}
translate H White {Vilgos}
translate H Black {Stt}
translate H Player {Jtkos}
translate H Rating {rtkszm}
translate H RatingDiff {rtkszmklnbsg (vilgos - stt)}
translate H AverageRating {tlagos rtkszm}
translate H Event {Esemny}
translate H Site {Helyszn}
translate H Country {Orszg}
translate H IgnoreColors {A szn kzmbs}
translate H Date {Dtum}
translate H EventDate {Az esemny dtuma}
translate H Decade {vtized}
translate H Year {v}
translate H Month {Hnap}
translate H Months {janur februr mrcius prilis mjus jnius jlius augusztus szeptember oktber november december}
translate H Days {vasrnap htf kedd szerda cstrtk pntek szombat}
translate H YearToToday {Az utols egy vben}
translate H YearToTodayTooltip {Dtum belltsa 1 vtl a mai napig}
translate H Result {Eredmny}
translate H Round {Fordul}
translate H Length {Hossz}
translate H ECOCode {ECO-kd}
translate H ECO {ECO}
translate H Deleted {trlt}
translate H SearchResults {A keress eredmnye}
translate H OpeningTheDatabase {Adatbzis megnyitsa}
translate H Database {Adatbzis}
translate H Filter {Szr}
translate H noGames {Nincs tallat}
translate H allGames {sszes jtszma}
translate H empty {res}
translate H clipbase {vgasztal}
translate H score {Eredmny}
translate H StartPos {Kezdlls}
translate H Total {sszesen}
translate H readonly {read-only} ;# ***

# Standard error messages:
translate H ErrNotOpen {Ez az adatbzis nincs megnyitva.}
translate H ErrReadOnly {Ez az adatbzis csak olvashat; nem lehet megvltoztatni.}
translate H ErrSearchInterrupted {Keress megszaktva; az eredmnyek hinyosak.}
translate H ErrNoClockComments {Ebben a jtkban nem tallhatk [%clk] rra vonatkoz megjegyzsek.    A funkci hasznlathoz adja hozz az raidt a Megjegyzs ablakon keresztl (Ctrl+E).}
translate H ErrFileInUse {Hiba: a fjl mr hasznlatban van. Krjk, zrjon be minden ms alkalmazst, amely ezt az adatbzist hasznlja. Ha a program vratlanul bezrult, elfordulhat, hogy trlnie kell az adatbzishoz trstott .lock fjlt.}




# Game information:
translate H twin {iker}
translate H deleted {trlt}
translate H comment {megjegyzs}
translate H hidden {rejtett}
translate H LastMove {Utols lps}
translate H NextMove {Kvetkez}
translate H GameStart {Jtszma eleje}
translate H LineStart {Elgazs eleje}
translate H GameEnd {Jtszma vge}
translate H LineEnd {Elgazs vge}

# Player information:
translate H PInfoAll {Eredmnyek az <b>sszes</b> jtszma alapjn}
translate H PInfoFilter {Eredmnyek a <b>szrt</b> jtszmk alapjn}
translate H PInfoAgainst {Eredmnyek, ha az ellenfl}
translate H PInfoMostWhite {Leggyakoribb megnyitsok vilgosknt}
translate H PInfoMostBlack {Leggyakoribb megnyitsok sttknt}
translate H PInfoRating {rtkszm alakulsa}
translate H PInfoBio {letrajz}
translate H PInfoEditRatings {rtkszmok tszerkesztse}
translate H PInfoEloFile {Fjl}

# Tablebase information:
translate H Draw {Dntetlen}
translate H with {with}
translate H only {csak}
translate H lose {vesztenek}
translate H loses {veszt}

# Tip of the day:
translate H Tip {Tipp}
translate H TipAtStartup {Tipp indulskor}
translate H TipConvertPGN {PGN fjlok konvertlsval jobb teljestmnyt rhet el}

# Tree window menus:
menuText H TreeFile "Fjl" 0
menuText H TreeFileFillWithBase "Adatbzis betltse a gyorsttrba" 0 {Betlti a gyorsttrba a megnyitott adatbzis sszes jtszmjt.}
menuText H TreeFileFillWithGame "Jtszma betltse a gyorsttrba" 0 {Betlti a gyorsttrba a megnyitott adatbzis aktulis jtszmjt.}
menuText H TreeFileSetCacheSize "A gyorsttr mrete" 14 {Belltja a gyorsttr mrett.}
menuText H TreeFileCacheInfo "Gyorsttr-hasznlat" 12 {Tjkoztat a gyorsttr hasznlatrl}
menuText H TreeFileSave "Cache-fjl mentse" 11 {Elmenti a faszerkezet-cache-fjlt (.stc)}
menuText H TreeFileFill "Cache-fjl feltltse" 14 \
  {Feltlti a cache-fjlt gyakori megnyitsokkal.}
menuText H TreeFileBest "Legjobb jtszmk listja" 0 {Megmutatja a legjobb jtszmkat a frl.}
menuText H TreeFileGraph "Grafikon" 0 {Megmutatja ennek a fagnak a grafikonjt.}
menuText H TreeFileCopy "Szveg msolsa a vglapra" 0 \
  {A kirt statisztikai adatokat a vglapra msolja.}
menuText H TreeFileClose "Faablak bezrsa" 10 {Bezrja a faszerkezet-ablakot.}
menuText H TreeMask "Maszk" 0
menuText H TreeMaskNew "j" 0 {j maszk}
menuText H TreeMaskOpen "Megnyits" 0 {Maszk megnyitsa}
menuText H TreeMaskOpenRecent "Nyissa meg a legutbbi lehetsget" 0 {Nyissa meg a legutbbi maszkot}
menuText H TreeMaskSave "Ments" 5 {Maszk mentse}
menuText H TreeMaskClose "Bezrs" 0 {Maszk bezrsa}
menuText H TreeMaskFillWithGame "Feltlts jtszmval" 1 {Maszk feltltse jtszmval}
menuText H TreeMaskFillWithBase "Feltlts adatbzissal" 2 {Maszk feltltse az adatbzis sszes jtszmjval}
menuText H TreeMaskInfo "Informci" 0 {Az aktulis maszk fbb adatai}
menuText H TreeMaskDisplay "Maszk trkp megjelentse" 0 {Maszkadatok megjelentse fa formban}
menuText H TreeMaskSearch "Keress" 0 {Keress az aktulis maszkban}
menuText H TreeSort "Rendezs" 0
menuText H TreeSortAlpha "ABC" 0
menuText H TreeSortECO "ECO-kd" 0
menuText H TreeSortFreq "Gyakorisg" 0
menuText H TreeSortScore "Pontszm" 0
menuText H TreeOpt "Belltsok" 0
menuText H TreeOptSlowmode "Lass zemmd" 0 {Lass frissts (nagy pontossg)}
menuText H TreeOptFastmode "Gyors zemmd" 0 {Gyors frissts (nincsenek lpscserk)}
menuText H TreeOptFastAndSlowmode "Gyors s lass zemmd" 1 {Gyors majd lass frissts}
menuText H TreeOptStartStop "Automatikus frissts" 0 {tvltja a faszerkezet-ablak automatikus frisstst.}
menuText H TreeOptLock "Rgzts" 0 {A ft az aktulis adatbzishoz kti ill. a ktst feloldja.}
menuText H TreeOptTraining "Edzs" 0 {Edzszemmd be- vagy kikapcsolsa}
menuText H TreeOptDepth "Mozgassa a mlysget" 0 {A fban megjelentend fllpsek szma (1-4)}
menuText H TreeOptAutosave "Cache-fjl automatikus mentse" 11 \
  {A faablak bezrsakor automatikusan elmenti a cache-fjlt.}
menuText H TreeHelp "Segtsg" 0
menuText H TreeHelpTree "Segtsg a fhoz" 0
menuText H TreeHelpIndex "Tartalom" 0
translate H SaveCache {Cache mentse}
translate H Training {Edzs}
translate H LockTree {Rgzts}
translate H TreeDepth {Fa mlysge (fl mozgs):}
translate H TreeLocked {rgztve}
translate H TreeBest {Legjobb}
translate H TreeBestGames {A fa legjobb jtszmi}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate H TreeTitleRow \
{Lps                         ECO       Gyakorisg  Eredm. tll Telj. tl.v      %Gyzelem}
translate H TreeTotal {SSZESEN}
translate H DoYouWantToSaveFirst {Akarod elbb menteni?}
translate H AddToMask {Add hozz a maszkhoz}
translate H RemoveFromMask {Vedd ki a maszkbl}
translate H AddThisMoveToMask {Add hozz ezt a lpst a maszkhoz}
translate H SearchMask {Keress a Maszkban}
translate H DisplayMask {Kijelz maszk}
translate H Nag {NAG-kd}
translate H Marker {Jells}
translate H Include {Belevesz}
translate H Exclude {Kizr}
translate H MainLine {Fvltozat}
translate H Bookmark {Knyvjelz}
translate H NewLine {Soremels}
translate H ToBeVerified {Ellenrizni kell}
translate H ToTrain {Gyakorolni kell}
translate H Dubious {Ktes}
translate H ToRemove {Trlni kell}
translate H NoMarker {Nincs jells}
translate H ColorMarker {Szn}
translate H WhiteMark {Fehr}
translate H GreenMark {Zld}
translate H YellowMark {Srga}
translate H BlueMark {Kk}
translate H RedMark {Piros}
translate H CommentMove {Lps kommentlsa}
translate H CommentPosition {lls kommentlsa}
translate H AddMoveToMaskFirst {Elbb add hozz a lpst a maszkhoz}
translate H OpenAMaskFileFirst {Elbb nyiss meg egy maszkfjlt}
translate H Positions {llsok}
translate H Moves {Lpsek}

# Finder window:
menuText H FinderFile "Fjl" 0
menuText H FinderFileSubdirs "Keress az alknyvtrakban" 0
menuText H FinderFileClose "A fjlkeres bezrsa" 15
menuText H FinderSort "Rendezs" 0
menuText H FinderSortType "Tpus" 0
menuText H FinderSortSize "Mret" 0
menuText H FinderSortMod "Id" 0
menuText H FinderSortName "Nv" 0
menuText H FinderSortPath "tvonal" 0
menuText H FinderTypes "Tpusok" 0
menuText H FinderTypesScid "SCID-adatbzisok" 0
menuText H FinderTypesOld "Rgi formtum SCID-adatbzisok" 5
menuText H FinderTypesPGN "PGN-fjlok" 0
menuText H FinderTypesEPD "EPD-fjlok" 0
menuText H FinderTypesRep "Repertorfjlok" 0
menuText H FinderHelp "Segtsg" 0
menuText H FinderHelpFinder "Segtsg a fjlkereshz" 0
menuText H FinderHelpIndex "Tartalom" 0
translate H FileFinder {Fjlkeres}
translate H FinderDir {Knyvtr}
translate H FinderDirs {Knyvtrak}
translate H FinderFiles {Fjlok}
translate H FinderUpDir {fel}
translate H FinderCtxOpen {Megnyit}
translate H FinderCtxBackup {Biztonsgi msolat}
translate H FinderCtxCopy {Msol}
translate H FinderCtxMove {thelyez}
translate H FinderCtxDelete {Trl}

# Player finder:
menuText H PListFile "Fjl" 0
menuText H PListFileUpdate "Frisst" 0
menuText H PListFileClose "Jtkoskeres bezrsa" 16
menuText H PListSort "Rendezs" 0
menuText H PListSortName "Nv" 0
menuText H PListSortElo "l" 0
menuText H PListSortGames "Jtszmk" 0
menuText H PListSortOldest "Legrgibb" 0
menuText H PListSortNewest "Legjabb" 3

# Tournament finder:
menuText H TmtFile "Fjl" 0
menuText H TmtFileUpdate "Frisst" 0
menuText H TmtFileClose "A versenykeres bezrsa" 18
menuText H TmtSort "Rendezs" 0
menuText H TmtSortDate "Dtum" 0
menuText H TmtSortPlayers "Jtkosok" 0
menuText H TmtSortGames "Jtszmk" 1
menuText H TmtSortElo "l" 0
menuText H TmtSortSite "Helyszn" 0
menuText H TmtSortEvent "Esemny" 0
menuText H TmtSortWinner "Gyztes" 0
translate H TmtLimit "Lista hossza"
translate H TmtMeanElo "Legkisebb tlagos l"
translate H TmtNone "Nem talltam hozz versenyt."

# Graph windows:
menuText H GraphFile "Fjl" 0
menuText H GraphFileColor "Ments Color PostScript-knt..." 7
menuText H GraphFileGrey "Ments Greyscale PostScript-knt..." 7
menuText H GraphFileClose "Ablak bezrsa" 8
menuText H GraphOptions "Belltsok" 0
menuText H GraphOptionsWhite "Vilgos" 0
menuText H GraphOptionsBlack "Stt" 0
menuText H GraphOptionsBoth "Mindkett" 1
menuText H GraphOptionsPInfo "A jtkosinformci jtkosa" 0
menuText H GraphOptionsEloFile "Elo az rtkelsi fjlbl" 0
menuText H GraphOptionsEloDB "Elo adatbzisbl" 0
translate H GraphFilterTitle "Szrsi grafikon: a pozcit elr jtkok szzalkos arnya"
translate H GraphAbsFilterTitle "Szrgrafikon: jtszmk gyakorisga"
translate H GraphWinPctTitle "Szûrési grafikon: Nyerési % (1-0 és 0-1) az aktuális pozíciónál évenként"
translate H ConfigureFilter {lltsd be az X tengelyt vre, rtkszmra vagy lpsre}
translate H FilterEstimate "Becsls"
translate H TitleFilterGraph "Scid: Szrgrafikon"
translate H WinPct "Nyerés %"

# Analysis window:
translate H AddVariation {Vltozat beszrsa}
translate H AddAllVariations {Add hozz az sszes vltozatot}
translate H AddMove {Lps beszrsa}
translate H Annotate {Lsd el rtkel jelekkel}
translate H ShowAnalysisBoard {Mutasd az elemztblt}
translate H ShowInfo {Mutasd a motor kirsait}
translate H FinishGame {Fejezd be a jtszmt}
translate H StopEngine {lltsd le a motort}
translate H StartEngine {Indtsd el a motort}
translate H LockEngine {Tartsd a motort ennl az llsnl}
translate H AnalysisCommand {Elemzsparancs}
translate H PreviousChoices {Korbbi vlasztsok}
translate H AnnotateTime {Kt lps kztti id msodpercben}
translate H AnnotateWhich {Vltozatok hozzadsa}
translate H AnnotateAll {Mindkt fl lpseihez}
translate H AnnotateAllMoves {rtkeld az sszes lpst}
translate H AnnotateWhite {Csak vilgos lpseihez}
translate H AnnotateBlack {Csak stt lpseihez}
translate H AnnotateBlundersOnly {Ha a tett lps nyilvnvalan durva hiba}
translate H AnnotateBlundersOnlyScoreChange {Az elemzs durva hibnak tekinti a lpst, ha az rtkels megvltozsa: }
translate H BlundersThreshold {Kszb}
translate H ScoreAllMoves {Score all moves}
translate H LowPriority {Alacsony CPU-priorits}
translate H ClickHereToSeeMoves {Kattints ide, hogy lsd a lpseket}
translate H ConfigureInformant {rtkel jelek definilsa}
translate H Informant!? {rdekes lps}
translate H Informant? {Gyatra lps}
translate H Informant?? {Durva hiba}
translate H Informant?! {Ktes lps}
translate H Informant+= {Vilgosnak nmi elnye van}
translate H Informant+/- {Vilgosnak jelents elnye van}
translate H Informant+- {Vilgosnak dnt elnye van}
translate H Informant+-- {A jtszma eldlt}
translate H AutoComment {Automatikus megjegyzs}
translate H AutoCommentTooltip {AI kommentr ltrehozsa az aktulis pozcihoz}
translate H AnalysisAutoCommentTooltip {Generlj mestersges intelligencia kommentrt az egsz jtkhoz}
translate H GameComment {Jtk megjegyzs}
translate H GameCommentTooltip {Keresse meg a jtkot megjegyzsekkel elltott mozdulatok utn, s ksztsen AI-sszefoglalt}
translate H TimeMs {Id (ms)}


# Book window
translate H Book {Megnyitstr}
translate H OtherBookMoves {Az ellenfl megnyitstra}
translate H OtherBookMovesTooltip {Azok a lpsek, amelyekre az ellenflnek van vlasza}

# Analysis Engine open dialog:
translate H EngineList {Elemz motorok listja}
translate H EngineName {Nv}
translate H EngineCmd {Parancssor}
translate H EngineArgs {Paramterek}
translate H EngineDir {Knyvtr}
translate H EngineElo {l}
translate H EngineTime {Dtum}
translate H EngineNew {j}
translate H EngineEdit {Szerkeszts}
translate H EngineRequired {A vastagbets mezk szksgesek, a tbbiek kihagyhatk.}
translate H EngineProtocol {Kommunikcis protokoll}
translate H EngineNotation {A mozdulatok jellse}
translate H EngineFlipEvaluation {Fordtsa meg az rtkelsi perspektvt}
translate H EngineShowLog {Kommunikcis napl megjelentse}
translate H EngineNetworkd {Tvoli kapcsolatok elfogadsa}
translate H EngineSelect {Vlassza ki az aktulis motort}
translate H EngineAddLocal {Adjon hozz egy helyi motort}
translate H EngineAddRemote {Adjon hozz egy tvoli motort}
translate H EngineReload {Tltse be jra az aktulis motort}
translate H EngineClone {Ksztsen msolatot az aktulis motorrl}
translate H EngineDelete {Trlje az aktulis motort}

# PGN window menus:
menuText H PgnFile "Fjl" 0
menuText H PgnFileCopy "A vglapra msolja a jtszmt" 2
menuText H PgnFilePrint "Nyomtats fjlba..." 0
menuText H PgnFileClose "PGN-ablak bezrsa" 12
menuText H PgnOpt "Megjelents" 0
menuText H PgnOptColor "Sznes szveg" 0
menuText H PgnOptShort "Rvid (3-soros) fejlc" 0
menuText H PgnOptSymbols "Szimblumok hasznlata" 1
menuText H PgnOptIndentC "Megjegyzsek behzsa" 0
menuText H PgnOptIndentV "Vltozatok behzsa" 0
menuText H PgnOptColumn "Oszlopok stlusa (soronknt egy lps)" 0
menuText H PgnOptSpace "Szkz a lps sorszma utn" 3
menuText H PgnOptStripMarks "Sznes mezk s nyilak kifejtse" 2
menuText H PgnOptBoldMainLine "A fvltozat lpsei vastag betvel" 21
menuText H PgnColor "Sznek" 1
menuText H PgnColorHeader "Fejlc..." 0
menuText H PgnColorAnno "rtkel jelek..." 0
menuText H PgnColorComments "Megjegyzsek..." 0
menuText H PgnColorVars "Vltozatok..." 0
menuText H PgnColorBackground "Httr..." 0
menuText H PgnColorMain "Fvltozat..." 1
menuText H PgnColorCurrent "Az aktulis lps httrszne..." 3
menuText H PgnHelp "Segtsg" 0
menuText H PgnHelpPgn "Segtsg PGN-hez" 9
menuText H PgnHelpIndex "Tartalom" 0
translate H PgnWindowTitle {Jtszmajegyzs - %u. jtszma}

# Crosstable window menus:
menuText H CrosstabFile "Fjl" 0
menuText H CrosstabFileText "Nyomtats szvegfjlba..." 10
menuText H CrosstabFileHtml "Nyomtats HTML-fjlba..." 10
menuText H CrosstabFileClose "Ablak bezrsa" 8
menuText H CrosstabEdit "Szerkeszts" 1
menuText H CrosstabEditEvent "Esemny" 0
menuText H CrosstabEditSite "Helyszn" 0
menuText H CrosstabEditDate "Dtum" 0
menuText H CrosstabOpt "Megjelents" 0
menuText H CrosstabOptAll "Krmrkzs" 0
menuText H CrosstabOptSwiss "Svjci" 0
menuText H CrosstabOptKnockout "Kiesses" 1
menuText H CrosstabOptAuto "Talld ki!" 0
menuText H CrosstabOptAges "letkor vben" 0
menuText H CrosstabOptNats "Nemzetisg" 0
menuText H CrosstabOptRatings "rtkszmok" 1
menuText H CrosstabOptTitles "Cmek" 0
menuText H CrosstabOptBreaks "Pontszm holtverseny eldntshez" 0
menuText H CrosstabOptDeleted "Trlt jtszmkkal egytt" 0
menuText H CrosstabOptColors "Sznek (csak svjci rendszer esetn)" 2
menuText H CrosstabOptColumnNumbers "Szmozott oszlopok (csak krmrkzshez)" 2
menuText H CrosstabOptGroup "Pontcsoportok" 1
menuText H CrosstabSort "Rendezs" 0
menuText H CrosstabSortName "Nv" 0
menuText H CrosstabSortRating "rtkszm" 0
menuText H CrosstabSortScore "Pontszm" 0
menuText H CrosstabColor "Szn" 2
menuText H CrosstabColorPlain "Kznsges szveg" 0
menuText H CrosstabColorHyper "Hypertext" 0
menuText H CrosstabHelp "Segtsg" 0
menuText H CrosstabHelpCross "Segtsg versenytblzathoz" 0
menuText H CrosstabHelpIndex "Tartalom" 0
translate H SetFilter {Szr belltsa}
translate H AddToFilter {Hozzadja a szrhz}
translate H Swiss {Svjci}
translate H Category {Kategria}

# Opening report window menus:
menuText H OprepFile "Fjl" 0
menuText H OprepFileText "Nyomtats szvegfjlba..." 10
menuText H OprepFileHtml "Nyomtats HTML-fjlba..." 10
menuText H OprepFileOptions "Belltsok..." 0
menuText H OprepFileClose "Ablak bezrsa" 8
menuText H OprepFavorites "Kedvencek" 0
menuText H OprepFavoritesAdd "sszefoglal hozzadsa..." 0
menuText H OprepFavoritesEdit "Kedvencek tszerkesztse..." 0
menuText H OprepFavoritesGenerate "sszefoglal ksztse..." 0
menuText H OprepHelp "Segtsg" 0
menuText H OprepHelpReport "Segtsg a megnyitsi sszefoglalhoz" 0
menuText H OprepHelpIndex "Trgymutat" 0

# Header search:
translate H HeaderSearch {Keress fejlc alapjn}
translate H EndSideToMove {Aki a jtszma vgn lpsre kvetkezik}
translate H GamesWithNoECO {Jtszmk ECO nlkl?}
translate H GameLength {Jtszmahossz}
translate H FindGamesWith {Megjellt jtszmk}
translate H StdStart {Klnleges kezds}
translate H Promotions {Gyalogtvltozsok}
translate H Comments {Megjegyzsek}
translate H Variations {Vltozatok}
translate H Annotations {rtkel jelek}
translate H DeleteFlag {Megjells trlse}
translate H WhiteOpFlag {Megnyits vilgossal}
translate H BlackOpFlag {Megnyits stttel}
translate H MiddlegameFlag {Kzpjtk}
translate H EndgameFlag {Vgjtk}
translate H NoveltyFlag {jts}
translate H PawnFlag {Gyalogszerkezet}
translate H TacticsFlag {Taktika}
translate H QsideFlag {Vezrszrnyi jtk}
translate H KsideFlag {Kirlyszrnyi jtk}
translate H BrilliancyFlag {Csillogs}
translate H BlunderFlag {Elnzs}
translate H UserFlag {Felhasznl}
translate H PgnContains {Szveg a PGN-ben}
translate H PgnTag {Cmke}
translate H TagContains {tartalmaz}
translate H Variant {Vltozat}
translate H Annotator {Annottor}
translate H Cmnts {Csak megjegyzsekkel elltott jtkok}

# Game list window:
translate H GlistNumber {Szm}
translate H GlistWhite {Vilgos}
translate H GlistBlack {Stt}
translate H GlistWElo {Vilgos lje}
translate H GlistBElo {Stt lje}
translate H GlistEvent {Esemny}
translate H GlistSite {Helyszn}
translate H GlistRound {Fordul}
translate H GlistDate {Dtum}
translate H GlistYear {v}
translate H GlistEDate {Az esemny dtuma}
translate H GlistResult {Eredmny}
translate H GlistLength {Hossz}
translate H GlistCountry {Orszg}
translate H GlistECO {ECO}
translate H GlistOpening {Megnyits}
translate H GlistEndMaterial {Vgs anyagi helyzet}
translate H GlistDeleted {Trlt}
translate H GlistFlags {Megjellsek}
translate H GlistVars {Variations}
translate H GlistComments {Megjegyzsek}
translate H GlistAnnos {rtkel jelek}
translate H GlistStart {Kezdet}
translate H GlistGameNumber {A jtszma sorszma}
translate H GlistAverageElo {tlagos Elo}
translate H GlistRating {rtkels}
translate H GlistFindText {Szveg keresse}
translate H GlistMoveField {Lps}
translate H GlistEditField {Konfigurls}
translate H GlistAddField {Hozzad}
translate H GlistDeleteField {Eltvolt}
translate H GlistWidth {Szlessg}
translate H GlistAlign {Igazt}
translate H GlistAlignL {Igazts: balra}
translate H GlistAlignR {Igazts: jobbra}
translate H GlistAlignC {Igazts: kzpre}
translate H GlistColor {Szn}
translate H GlistSep {Elvlaszt}
translate H GlistCurrentSep {-- Jelenlegi --}
translate H GlistNewSort {j}
translate H GlistAddToSort {Hozzads}

# base sorting
translate H GsortSort {Fajta...}
translate H GsortDate {Dtum}
translate H GsortYear {v}
translate H GsortEvent {Esemny}
translate H GsortSite {Telek}
translate H GsortRound {Kerek}
translate H GsortWhiteName {Fehr nv}
translate H GsortBlackName {Fekete nv}
translate H GsortECO {ECO}
translate H GsortResult {Eredmny}
translate H GsortMoveCount {Mozgsszm}
translate H GsortAverageElo {tlagos Elo}
translate H GsortCountry {Orszg}
translate H GsortDeleted {Trlve}
translate H GsortEventDate {Esemny dtuma}
translate H GsortWhiteElo {Fehr Elo}
translate H GsortBlackElo {Fekete Elo}
translate H GsortComments {Megjegyzsek}
translate H GsortVariations {Varicik}
translate H GsortNAGs {NAG-ok}
translate H GsortAscending {Emelked}
translate H GsortDescending {Cskken}
translate H GsortAdd {Hozzads}
translate H GsortStore {Bolt}
translate H GsortLoad {Terhels}

# menu shown with right mouse button down on game list.
translate H GlistRemoveThisGameFromFilter  {Vedd ki ezt a jtszmt a szrbl}
translate H GlistRemoveGameAndAboveFromFilter  {Vedd ki a jtszmt s az sszes fltte lvt a szrbl}
translate H GlistRemoveGameAndBelowFromFilter  {Vedd ki a jtszmt s az sszes alatta lvt a szrbl}
translate H GlistDeleteGame {Trld/lltsd helyre ezt a jtszmt} 
translate H GlistDeleteAllGames {Trld a szr sszes jtszmjt} 
translate H GlistUndeleteAllGames {lltsd helyre a szr sszes jtszmjt} 
translate H GlistMergeGameInBase {Merge Game msik bzis} 

# Maintenance window:
translate H DatabaseName {Az adatbzis neve:}
translate H TypeIcon {Tpusikon:}
translate H NumOfGames {Jtszmk:}
translate H NumDeletedGames {Trlt jtszmk:}
translate H NumFilterGames {Szrt jtszmk:}
translate H YearRange {vtartomny:}
translate H RatingRange {rtkszmtartomny:}
translate H Description {Lers}
translate H Flag {Megjells}
translate H CustomFlags {Egyedi zszlk}
translate H DeleteCurrent {Trli az aktulis jtszmt.}
translate H DeleteFilter {Trli a szrt jtszmkat.}
translate H DeleteAll {Minden jtszmt trl.}
translate H UndeleteCurrent {Helyrelltja az aktulis jtszmt.}
translate H UndeleteFilter {Helyrelltja a szrt jtszmkat.}
translate H UndeleteAll {Minden jtszmt helyrellt.}
translate H DeleteTwins {Trli az ikerjtszmkat.}
translate H MarkCurrent {Megjelli az aktulis jtszmt.}
translate H MarkFilter {Megjelli a szrt jtszmkat.}
translate H MarkAll {Minden jtszmt megjell.}
translate H UnmarkCurrent {Eltvoltja az aktulis jtszma megjellst.}
translate H UnmarkFilter {Eltvoltja a szrt jtszmk megjellst.}
translate H UnmarkAll {Minden jtszma megjellst eltvoltja.}
translate H Spellchecking {Helyesrs-ellenrzs}
translate H Players {Jtkosok}
translate H Events {Esemnyek}
translate H Sites {Helysznek}
translate H Rounds {Fordulk}
translate H DatabaseOps {Adatbzismveletek}
translate H ReclassifyGames {ECO alapjn osztlyozza a jtszmkat.}
translate H CompactDatabase {Adatbzis tmrtse}
translate H SortDatabase {Adatbzis rendezse}
translate H AddEloRatings {l-rtkszmok hozzadsa}
translate H AutoloadGame {Jtszmasorszm automatikus betltse}
translate H StripTags {PGN-cmkk eltntetse}
translate H StripTag {Cmke eltntetse}
translate H Cleaner {Takart}
translate H CleanerHelp {
SCID Takartja el fogja vgezni az aktulis adatbzison az sszes olyan gondozsi feladatot, amelyet az albbi listrl kijellsz.

Az ECO-osztlyozsra s az ikertrlsre vonatkoz jelenlegi belltsok akkor jutnak rvnyre, ha ezeket a feladatokat is kijelld.
}
translate H CleanerConfirm {
Ha a Takart mr elindult, tbb nem lehet meglltani!

Nagy adatbzison a kivlasztott feladatoktl s aktulis belltsaiktl fggen a mvelet sokig eltarthat.

Biztos, hogy neki akarsz ltni a kijellt gondozsi feladatoknak?
}
# Twinchecker
translate H TwinCheckUndelete {vlts; "u" mindkettt helyrelltja)}
translate H TwinCheckprevPair {Elz pr}
translate H TwinChecknextPair {Kvetkez pr}
translate H TwinChecker {Scid: Ikerjtszma-ellenrzs}
translate H TwinCheckTournament {E verseny jtszmi:}
translate H TwinCheckNoTwin {Nem ikrek  }
translate H TwinCheckNoTwinfound {Ennek a jtszmnak nincs ikertestvre.\nEbben az ablakban akkor lehet megjelenteni az ikreket, ha elbb az "Ikerjtszmk trlse..." funkcit hasznlod. }
translate H TwinCheckTag {Cmkk ellenrzse...}
translate H TwinCheckFound1 {Scid $result ikerjtszmt tallt,}
translate H TwinCheckFound2 { s megjellte ket trlsre.}
translate H TwinCheckNoDelete {Ebben az adatbzisban nincsenek trlend jtszmk.}
translate H TwinCriteria1 {Ikerjtszmk megtallst clz belltsaid azzal a veszllyel jrnak,\nhogy hasonl lpseket tartalmaz (nem-iker) jtszmkat is megjellk trlsre..}
translate H TwinCriteria2 {Ha "azonos lpsek"-nl "Nem"-et vlasztottad, akkor clszer "Igen"-t vlasztani a sznek, az esemny, a helyszn, a fordul, az v s a hnap belltsainl.\nAkarod folytatni, s mindenkppen trlni az ikreket?}
translate H TwinCriteria3 {Ajnlatos "azonos helyszn", "azonos fordul" s "azonos v" belltsai kzl legalbb kettt "Igen"-nek vlasztani.\nAkarod folytatni, s mindenkppen trlni az ikreket?}
translate H TwinCriteriaConfirm {Scid: Erstsd meg az ikerbelltsokat}
translate H TwinChangeTag "Vltoztasd meg a kvetkez jtszmacmkket:\n\n"
translate H AllocRatingDescription "Ez a parancs a jelenlegi helyesrsellenrz fjl felhasznlsval l-pontokkal ltja el az adatbzis jtszmit. Ha egy jtkosnak jelenleg nincs lje, de a jtszma idejn rvnyes lje benne van a helyesrsellenrz fjlban, azt az lt fogja kapni."
translate H RatingOverride "Fellrjam a meglv 0-tl klnbz lket?"
translate H AddRatings "Adj lket ehhez:"
translate H AddedRatings {Scid $r l-rtkszmot adott $g jtszmhoz.}

#Bookmark editor
translate H NewSubmenu "j almen"

# Comment editor:
translate H AnnotationSymbols  {rtkel szimblumok:}
translate H Comment {Megjegyzs:}
translate H InsertMark {Megjells beszrsa}
translate H InsertMarkHelp {
Megjells beszrsa/trlse: szn, tpus, mez kivlasztsa.
Nyl beszrsa/trlse: Kattints a jobb gombbal kt mezn.
}

# Nag buttons in comment editor:
translate H GoodMove {J lps}
translate H PoorMove {Rossz lps}
translate H ExcellentMove {Kitn lps}
translate H Blunder {Elnzs}
translate H InterestingMove {rdekes lps}
translate H DubiousMove {Ktes rtk lps}
translate H WhiteDecisiveAdvantage {Vilgosnak dnt elnye van.}
translate H BlackDecisiveAdvantage {Sttnek dnt elnye van.}
translate H WhiteClearAdvantage {Vilgos elnye nyilvnval.}
translate H BlackClearAdvantage {Stt elnye nyilvnval.}
translate H WhiteSlightAdvantage {Vilgos valamivel jobban ll.}
translate H BlackSlightAdvantage {Stt valamivel jobban ll.}
translate H WhiteCrushing {A fehrnek zzs elnye van}
translate H BlackCrushing {A feketnek zzs elnye van}
translate H Equality {Egyenl lls}
translate H Unclear {Tisztzatlan lls}
translate H Diagram {Diagram}

# Board search:
translate H BoardSearch {lls keresse}
translate H FilterOperation {Elvgzend mvelet az aktulis szrn:}
translate H FilterAnd {S (Szr szktse)}
translate H FilterOr {VAGY (Szr bvtse)}
translate H FilterIgnore {SEMMI (Szr trlse)}
translate H SearchType {A keress fajtja:}
translate H SearchBoardExact {Pontos lls (minden figura azonos mezn)}
translate H SearchBoardPawns {Gyalogok (azonos anyag, minden gyalog azonos mezn)}
translate H SearchBoardFiles {Vonalak (azonos anyag, minden gyalog azonos vonalon)}
translate H SearchBoardAny {Brmi (azonos anyag, gyalogok s figurk brhol)}
translate H SearchInRefDatabase {Keress az alapban}
translate H LookInVars {Vltozatokban is keres.}

# Material search:
translate H MaterialSearch {Keress anyagra}
translate H Material {Anyag}
translate H Patterns {Alakzatok}
translate H Zero {Nullzs}
translate H Any {Brmi}
translate H CurrentBoard {Aktulis lls}
translate H CommonEndings {Gyakori vgjtkok}
translate H CommonPatterns {Gyakori alakzatok}
translate H MaterialDiff {Anyagklnbsg}
translate H squares {mezk}
translate H SameColor {Azonos szn}
translate H OppColor {Ellenkez szn}
translate H Either {Brmelyik}
translate H MoveNumberRange {Lpstartomny}
translate H MatchForAtLeast {Egyezzen legalbb}
translate H HalfMoves {fl lpsig.}

# Common endings in material search:
translate H EndingPawns {Gyalogvgjtkok}
translate H EndingRookVsPawns {Bstya gyalog(ok) ellen}
translate H EndingRookPawnVsRook {Bstya s 1 gyalog bstya ellen}
translate H EndingRookPawnsVsRook {Bstya s gyalogok bstya ellen}
translate H EndingRooks {Bstyavgjtkok}
translate H EndingRooksPassedA {Bstyavgjtkok szabad a-gyaloggal}
translate H EndingRooksDouble {Ketts bstyavgjtkok}
translate H EndingBishops {Futvgjtkok}
translate H EndingBishopVsKnight {Fut huszr ellen}
translate H EndingKnights {Huszrvgjtkok}
translate H EndingQueens {Vezrvgjtkok}
translate H EndingQueenPawnVsQueen {Vezr s 1 gyalog vezr ellen}
translate H BishopPairVsKnightPair {Futpr huszrpr ellen a kzpjtkban}

# Common patterns in material search:
translate H PatternWhiteIQP {Izollt vilgos vezrgyalog}
translate H PatternWhiteIQPBreakE6 {d4-d5 ttrs e6 ellen}
translate H PatternWhiteIQPBreakC6 {d4-d5 ttrs c6 ellen}
translate H PatternBlackIQP {Izollt stt vezrgyalog}
translate H PatternWhiteBlackIQP {Izollt vilgos d-gyalog izollt stt d-gyalog ellen}
translate H PatternCoupleC3D4 {Izollt vilgos c3-d4 gyalogpr}
translate H PatternHangingC5D5 {Lg stt gyalogok c5-n s d5-n}
translate H PatternMaroczy {Marczy-centrum (gyalogok c4-en s e4-en)}
translate H PatternRookSacC3 {Bstyaldozat c3-on}
translate H PatternKc1Kg8 {O-O-O O-O ellen (Kc1 s Kg8)}
translate H PatternKg1Kc8 {O-O O-O-O ellen (Kg1 s Kc8)}
translate H PatternLightFian {Vilgos mezej fianchetto (g2 fut b7 fut ellen)}
translate H PatternDarkFian {Stt mezej fianchetto (b2 fut g7 fut ellen)}
translate H PatternFourFian {Ngyes fianchetto (futk b2-n, g2-n, b7-en s g7-en)}

# Game saving:
translate H Today {Ma}
translate H ClassifyGame {Jtszma osztlyozsa}

# Setup position:
translate H EmptyBoard {Tbla letakartsa}
translate H InitialBoard {Alaplls}
translate H SideToMove {Ki lp?}
translate H MoveNumber {Lps szma}
translate H Castling {Sncols}
translate H EnPassantFile {"en passant"-vonal}
translate H ClearFen {FEN trlse}
translate H PasteFen {FEN beillesztse}

translate H SaveAndContinue {Ments s folytats}
translate H DiscardChangesAndContinue {Vltoztatsok elvetse\ns folytats}
translate H GoBack {Vissza}

# Replace move dialog:
translate H ReplaceMove {Lps cserje}
translate H AddNewVar {j vltozat beszrsa}
translate H NewMainLine {j fvltozat}
translate H ReplaceMoveMessage {Itt mr van lps.

Kicserlheted, miltal az sszes t kvet lps elvsz, vagy lpsedet beszrhatod j vltozatknt.

(Ha a jvben nem akarod ltni ezt az zenetet, kapcsold ki a Belltsok:Lpsek menben a "Lps cserje eltt rkrdez." belltst.)}

# Make database read-only dialog:
translate H ReadOnlyDialog {Ha ezt az adatbzist kizrlag olvashatv teszed, nem lehet vltoztatsokat vgezni rajta. Nem lehet jtszmkat elmenteni vagy kicserlni, sem a trlskijellseket megvltoztatni. Minden rendezs vagy ECO-osztlyozs csak tmeneti lesz.

Knnyen jra rhatv teheted az adatbzist, ha bezrod, majd jbl megnyitod.

Tnyleg kizrlag olvashatv akarod tenni ezt az adatbzist?}

# Clear game dialog:
translate H ClearGameDialog {Ez a jtszma megvltozott.

Tnyleg folytatni akarod, s elvetni a ltrehozott vltoztatsokat?
}

# Exit dialog:
translate H ExitDialog {Tnyleg ki akarsz lpni SCID-bl?}
translate H ExitUnsaved {A kvetkez adatbzisokban elmentetlen jtszmavltoztatsok vannak. Ha most kilpsz, ezek a vltoztatsok elvesznek.}

# Import window:
translate H PasteCurrentGame {Beilleszti az aktulis jtszmt.}
translate H ImportHelp1 {Bevisz vagy beilleszt egy PGN-formtum jtszmt a fenti keretbe.}
translate H ImportHelp2 {Itt jelennek meg az importls kzben fellp hibk.}
translate H OverwriteExistingMoves {Fellrjam a meglv lpseket?}

# ECO Browser:
translate H ECOAllSections {sszes ECO-osztly}
translate H ECOSection {ECO-osztly}
translate H ECOSummary {sszefoglals:}
translate H ECOFrequency {Alkdok gyakorisga:}

# Opening Report:
translate H OprepReportFor {Jelents a szmra}
translate H OprepTitle {Megnyitsi sszefoglal}
translate H OprepReport {sszefoglal}
translate H OprepGenerated {Ksztette:}
translate H OprepStatsHist {Statisztika s trtnet}
translate H OprepStats {Statisztika}
translate H OprepStatAll {Az sszefoglal sszes jtszmja}
translate H OprepStatBoth {Mindkett}
translate H OprepStatSince {Idszak kezdete:}
translate H OprepOldest {A legrgibb jtszmk}
translate H OprepNewest {A legjabb jtszmk}
translate H OprepPopular {Jelenlegi npszersg}
translate H OprepFreqAll {Gyakorisg a teljes idszakban:   }
translate H OprepFreq1   {Az utbbi 1 vben: }
translate H OprepFreq5   {Az utbbi 5 vben: }
translate H OprepFreq10  {Az utbbi 10 vben: }
translate H OprepEvery {minden %u jtszmban egyszer}
translate H OprepUp {%u%s nvekeds az vek sorn}
translate H OprepDown {%u%s cskkens az vek sorn}
translate H OprepSame {nincs vltozs az vek sorn}
translate H OprepMostFrequent {Leggyakoribb jtkosok}
translate H OprepMostFrequentOpponents {Leggyakoribb ellenfelek}
translate H OprepRatingsPerf {rtkszm s teljestmny}
translate H OprepAvgPerf {tlagos rtkszm s teljestmny}
translate H OprepWRating {Vilgos rtkszma}
translate H OprepBRating {Stt rtkszma}
translate H OprepWPerf {Vilgos teljestmnye}
translate H OprepBPerf {Stt teljestmnye}
translate H OprepHighRating {A legnagyobb tlagrtkszm jtszmk}
translate H OprepTrends {Tendencik}
translate H OprepResults {Eredmny hosszsg s gyakorisg szerint}
translate H OprepLength {Jtszmahossz}
translate H OprepFrequency {Gyakorisg}
translate H OprepWWins {Vilgos nyer: }
translate H OprepBWins {Stt nyer:   }
translate H OprepDraws {Dntetlen:    }
translate H OprepWholeDB {teljes adatbzis}
translate H OprepShortest {A legrvidebb gyzelmek}
translate H OprepMovesThemes {Lpsek s tmk}
translate H OprepMoveOrders {A vizsglt llshoz vezet lpssorrendek}
translate H OprepMoveOrdersOne \
  {Csak egy lpssorrend vezetett ehhez az llshoz:}
translate H OprepMoveOrdersAll \
  {%u lpssorrend vezetett ehhez az llshoz:}
translate H OprepMoveOrdersMany \
  {%u lpssorrend vezetett ehhez az llshoz. Az els %u:}
translate H OprepMovesFrom {A vizsglt llsban tett lpsek}
translate H OprepMostFrequentEcoCodes {Leggyakoribb ECO-kdok}
translate H OprepThemes {Pozcis tmk}
translate H OprepThemeDescription {Tmk gyakorisga az egyes jtszmk els %u lpsben}
translate H OprepThemeSameCastling {Sncols azonos oldalra}
translate H OprepThemeOppCastling {Sncols ellenkez oldalra}
translate H OprepThemeNoCastling {Egyik kirly sem sncolt.}
translate H OprepThemeKPawnStorm {Kirlyszrnyi gyalogroham}
translate H OprepThemeQueenswap {Vezrcsere}
translate H OprepThemeWIQP {Elszigetelt vilgos vezrgyalog}
translate H OprepThemeBIQP {Elszigetelt stt vezrgyalog}
translate H OprepThemeWP567 {Vilgos gyalog az 5./6./7. soron}
translate H OprepThemeBP234 {Stt gyalog a 4./3./2. soron}
translate H OprepThemeOpenCDE {Nylt c/d/e-vonal}
translate H OprepTheme1BishopPair {Csak az egyik flnek van futprja.}
translate H OprepEndgames {Vgjtkok}
translate H OprepReportGames {Az sszefoglal jtszmi}
translate H OprepAllGames    {sszes jtszma}
translate H OprepEndClass {Anyagi viszonyok az egyes jtszmk vgn}
translate H OprepTheoryTable {Elmlettblzat}
translate H OprepTableComment {a legnagyobb rtkszm %u jtszma alapjn}
translate H OprepExtraMoves {A kln megjegyzssel elltott lpsek szma az elmlettblzatban}
translate H OprepMaxGames {Az elmlettblzat ltrehozshoz felhasznlhat jtszmk maximlis szma}
translate H OprepMergeMoves {Az egyestett jtkok thelyezsi korltja}
translate H OprepMergeUnique {Csak egyedi jtkokat egyestsen}
translate H OprepViewHTML {HTML megtekintse}

# Player Report:
translate H PReportTitle {sszefoglal jtkosrl}
translate H PReportColorWhite {vilgossal}
translate H PReportColorBlack {stttel}
translate H PReportMoves {%s utn}
translate H PReportOpenings {Megnyitsok}
translate H PReportClipbase {Kirti a vglapot, s odamsolja a felttelnek megfelel jtszmkat}

# Piece Tracker window:
translate H TrackerSelectSingle {A bal egrgomb kivlasztja ezt a figurt.}
translate H TrackerSelectPair {A bal egrgomb kivlasztja ezt a figurt; a jobb egrgomb a prjt is kivlasztja.}
translate H TrackerSelectPawn {A bal egrgomb kivlasztja ezt a gyalogot; a jobb egrgomb az sszes gyalogot kivlasztja.}
translate H TrackerStat {Statisztika}
translate H TrackerGames {Jtszmk %-a, amelyekben erre a mezre lpett}
translate H TrackerTime {Id %-a, amelyet az egyes mezkn tlttt}
translate H TrackerMoves {Lpsek}
translate H TrackerMovesStart {Add meg a lps szmt, amelynl a nyomkvetsnek el kell kezddnie.}
translate H TrackerMovesStop {Add meg a lps szmt, amelynl a nyomkvetsnek be kell fejezdnie.}

# Game selection dialogs:
translate H SelectAllGames {Az adatbzis sszes jtszmja}
translate H SelectFilterGames {Csak a szrt jtszmk}
translate H SelectTournamentGames {Csak az aktulis verseny jtszmi}
translate H SelectOlderGames {Csak rgebbi jtszmk}

# Delete Twins window:
translate H TwinsNote {Kt jtszma akkor iker, ha ugyanazok jtsszk ket, s megfelelnek az alant meghatrozhat kritriumoknak. Az ikerprbl a rvidebb jtszma trldik. Javaslat: ikrek trlse eltt rdemes helyesrs-ellenrzst vgezni az adatbzison, mert az javtja az ikerfeldertst.}
translate H TwinsCriteria {Kritriumok: Az ikerjtszmk kzs tulajdonsgai...}
translate H TwinsWhich {A megvizsgland jtszmk}
translate H TwinsColors {Azonos szn?}
translate H TwinsEvent {Ugyanaz az esemny?}
translate H TwinsSite {Azonos helyszn?}
translate H TwinsRound {Ugyanaz a fordul?}
translate H TwinsYear {Azonos v?}
translate H TwinsMonth {Azonos hnap?}
translate H TwinsDay {Ugyanaz a nap?}
translate H TwinsResult {Azonos eredmny?}
translate H TwinsECO {Azonos ECO-kd?}
translate H TwinsMoves {Azonos lpsek?}
translate H TwinsPlayers {A jtkosok nevnek sszehasonltsakor:}
translate H TwinsPlayersExact {Teljes egyezs kell.}
translate H TwinsPlayersPrefix {Elg az els 4 betnek egyeznie.}
translate H TwinsWhen {Ikerjtszmk trlsekor}
translate H TwinsSkipShort {Hagyjuk figyelmen kvl az 5 lpsnl rvidebb jtszmkat?}
translate H TwinsUndelete {Elszr lltsuk helyre az sszes jtszmt?}
translate H TwinsSetFilter {A szrt lltsuk az sszes trlt ikerjtszmra?}
translate H TwinsComments {A megjegyzsekkel elltott jtszmkat mindig tartsuk meg?}
translate H TwinsVars {A vltozatokat tartalmaz jtszmkat mindig tartsuk meg?}
translate H TwinsDeleteWhich {Melyik jtszmt trljem?}
translate H TwinsDeleteShorter {A rvidebbet}
translate H TwinsDeleteOlder {A kisebb sorszmt}
translate H TwinsDeleteNewer {A nagyobb sorszmt}
translate H TwinsDelete {Jtszmk trlse}

# Name editor window:
translate H NameEditType {Szerkesztend nvtpus}
translate H NameEditSelect {Szerkesztend jtszmk}
translate H NameEditReplace {Cserl}
translate H NameEditWith {Erre}
translate H NameEditMatches {Egyezsek: Ctrl+1...Ctrl+9 vlaszt.}

# Check games window:
translate H CheckGames {Ellenrizze a jtkokat}
translate H CheckGamesWhich {Ellenrizze a jtkokat}
translate H CheckAll {Minden jtk}
translate H CheckSelectFilterGames {Csak jtkok a szrben}

# Classify window:
translate H Classify {Osztlyoz}
translate H ClassifyWhich {Mely jtszmk essenek t ECO-osztlyozson?}
translate H ClassifyAll {Az sszes (rja fell a rgi ECO-kdokat)}
translate H ClassifyYear {Az utbbi vben jtszott jtszmk}
translate H ClassifyMonth {Az utbbi hnapban jtszott jtszmk}
translate H ClassifyNew {Csak az eddig mg nem osztlyozott jtszmk}
translate H ClassifyCodes {Hasznland ECO-kdok}
translate H ClassifyBasic {Csak az alapkdok ("B12", ...)}
translate H ClassifyExtended {Kiterjesztett SCID-kdok ("B12j", ...)}
translate H ClassifyResult {ECO besorols ksz: $eredmny jtk(ok) frisstve.}

# Compaction:
translate H NameFile {Nvfjl}
translate H GameFile {Jtszmafjl}
translate H Names {Nevek}
translate H Unused {Hasznlaton kvl}
translate H SizeKb {Mret (kB)}
translate H CurrentState {Jelenlegi llapot}
translate H AfterCompaction {Tmrts utn}
translate H CompactNames {Nvfjl tmrtse}
translate H CompactGames {Jtszmafjl tmrtse}
translate H NoUnusedNames "Nincsenek nem hasznlt nevek, gyhogy a nvfjl mr teljesen tmr."
translate H NoUnusedGames "A nvfjl mr teljesen tmr."
translate H GameFileCompacted {Az adatbzis jtszmafjlja tmrtve van.}

# Sorting:
translate H SortCriteria {Kritriumok}
translate H AddCriteria {Kritriumok hozzadsa}
translate H CommonSorts {Szoksos rendezsek}
translate H Sort {Rendezs}

# Exporting:
translate H AddToExistingFile {Jtszmk hozzadsa ltez fjlhoz?}
translate H ExportComments {Megjegyzsek exportlsa?}
translate H ExportVariations {Vltozatok exportlsa?}
translate H IndentComments {Megjegyzsek igaztsa?}
translate H IndentVariations {Vltozatok igaztsa?}
translate H ExportColumnStyle {Oszlop stlusa (soronknt egy lps)?}
translate H ExportSymbolStyle {Szimblumok stlusa:}
translate H ExportStripMarks {Kivegye a megjegyzsekbl a mez- s nylmegjellseket?}

# Goto game/move dialogs:
translate H LoadGameNumber {A betltend jtszma sorszma:}
translate H GotoMoveNumber {Ugrs a kvetkez lpshez:}

# Copy games dialog:
translate H CopyAllGames {Minden jtk msolsa ide}
translate H CopyGames {Jtszmk msolsa}
translate H CopyConfirm {
 Tnyleg t akarod msolni
 a [::utils::thousands $nGamesToCopy] szrt jtszmt
 a "$fromName" adatbzisbl
 a "$targetName" adatbzisba?
}
translate H CopyErr {Nem tudom tmsolni a jtszmkat.}
translate H CopyErrSource {forrs}
translate H CopyErrTarget {cl}
translate H CopyErrNoGames {szrjben nincsenek jtszmk.}
translate H CopyErrReadOnly {kizrlag olvashat.}
translate H CopyErrNotOpen {nincs megnyitva.}

# Colors:
translate H LightSquares {Vilgos mezk}
translate H DarkSquares {Stt mezk}
translate H SelectedSquares {Kivlasztott mezk}
translate H SuggestedSquares {Javasolt lpsek mezi}
translate H WhitePieces {Vilgos figurk}
translate H BlackPieces {Stt figurk}
translate H WhiteBorder {Vilgos krvonal}
translate H BlackBorder {Stt krvonal}

# Novelty window:
translate H FindNovelty {jts keresse}
translate H Novelty {jts}
translate H NoveltyInterrupt {jtskeress lelltva}
translate H NoveltyNone {Ebben a jtszmban nem talltam jtst.}
translate H NoveltyHelp {
SCID megkeresi az aktulis jtszma els olyan lpst, amely nem szerepel sem a kivlasztott adatbzisban, sem az ECO megnyitstrban.
}

# Sounds configuration:
translate H SoundsFolder {Hangfjlok knyvtra}
translate H SoundsFolderHelp {A knyvtrban a King.wav, a.wav, 1.wav, s..t. fjloknak kell szerepelnik.}
translate H SoundsAnnounceOptions {Lpsbemondsok belltsai}
translate H SoundsAnnounceNew {j lps bemondsa amint megtesszk}
translate H SoundsMoveSoundOnly {Csak mozgatsi hang (bejelentsek letiltsa)}
translate H SoundsAnnounceForward {Lps bemondsa amikor egy lpst elre lpnk}
translate H SoundsAnnounceBack {Lps bemondsa amikor visszavesznk vagy egy lpst htra lpnk}
translate H SoundsSoundDisabled {A Scid nem tallta a Snack audiocsomagot indtskor;\nA hang le van tiltva.}

# Upgrading databases:
translate H Upgrading {Feljts}
translate H ConfirmOpenNew {
Ez rgi formtum (SCID 3) adatbzis, amelyet SCID 4 nem tud megnyitni, de mr ltrehozott egy j formtum (SCID 4) verzit.

Szeretnd megnyitni az adatbzis j formtum verzijt?
}
translate H ConfirmUpgrade {
Ez rgi formtum (SCID 3) adatbzis. j formtum verzit kell ltrehozni belle, hogy SCID 4 hasznlni tudja.

A feljts j verzit hoz ltre az adatbzisbl. Az eredeti fjlok srtetlenl megmaradnak.

Az eljrs eltarthat egy darabig, de csak egyszer kell elvgezni. Megszakthatod, ha tl sokig tart.

Szeretnd most feljtani ezt az adatbzist?
}

# Recent files options:
translate H RecentFilesMenu {Az aktulis fjlok szma a Fjl menben}
translate H RecentFilesExtra {Az aktulis fjlok szma a kiegszt almenben}

# My Player Names options:
translate H MyPlayerNamesDescription {
Add meg az ltalad kedvelt jtkosok nevt, soronknt egyet. Helyettest karaktereket (pl. "?" tetszleges karakter helyett, "*" tetszleges karaktersorozat helyett) is hasznlhatsz.

Amikor betltd egy a listn szerepl jtkos jtszmjt, a fablak sakktblja szksg esetn elfordul, hogy a jtszmt annak a jtkosnak a szemszgbl mutassa.
}

#Coach
translate H showblunderexists {Jelezd a durva hibt}
translate H showblundervalue {Mutasd a durva hiba mrtkt}
translate H showscore {Mutasd az rtkelst}
translate H coachgame {Edz bekapcsolsa}
translate H configurecoachgame {Edzs zemmd belltsai}
translate H configuregame {Jtszmabelltsok}
translate H Phalanxengine {Phalanx}
translate H Coachengine {Edzmotor}
translate H difficulty {Nehzsg}
translate H hard {nehz}
translate H easy {knny}
translate H Playwith {Szned}
translate H white {vilgos}
translate H black {stt}
translate H both {mindkett}
translate H Play {Jtk}
translate H Noblunder {Nincs durva hiba}
translate H blunder {durva hiba}
translate H Noinfo {-- Nincs adat --}
translate H PhalanxOrTogaMissing {Phalanx vagy Toga nincs meg}
translate H moveblunderthreshold {egy lps durva hiba, ha a vesztesg nagyobb mint}
translate H limitanalysis {A motor ennyi ideig elemezhet}
translate H seconds {msodperc}
translate H Abort {Elg}
translate H Resume {Folytasd}
translate H OutOfOpening {Vge a megnyitstrnak}
translate H NotFollowedLine {Eltrtl a vltozattl}
translate H DoYouWantContinue {Akarod folytatni?}
translate H CoachIsWatching {Az edz figyel}
translate H Ponder {Folyamatos gondolkods}
translate H LimitELO {l korltozsa}
translate H DubiousMovePlayedTakeBack {Ktes lps, visszaveszed?}
translate H WeakMovePlayedTakeBack {Gyenge lps, visszaveszed?}
translate H BadMovePlayedTakeBack {Rossz lps, visszaveszed?}
translate H Iresign {Feladom.}
translate H yourmoveisnotgood {Ez nem j lps.}
translate H EndOfVar {A vltozatnak vge.}
translate H Openingtrainer {Megnyitsgyakorls}
translate H DisplayCM {Mutasd a szba jv lpseket}
translate H DisplayCMValue {Mutasd a szba jv lpsek rtkelst}
translate H DisplayOpeningStats {Mutasd a statisztikt}
translate H ShowReport {Mutasd a jelentst}
translate H NumberOfGoodMovesPlayed {a j lpsek szma}
translate H NumberOfDubiousMovesPlayed {a ktes lpsek szma}
translate H NumberOfMovesPlayedNotInRepertoire {a repertorban nem szerepl lpsek szma}
translate H NumberOfTimesPositionEncountered {az lls elfordulsainak a szma}
translate H PlayerBestMove  {Csak a legjobb lpseket engedlyezi}
translate H OpponentBestMove {Az ellenfl a legjobbakat lpi}
translate H OnlyFlaggedLines {Csak megjellt vltozatokat jtszhatsz meg}
translate H resetStats {Statisztika trlse}
translate H Repertoiretrainingconfiguration {Repertorgyakorls belltsai}
translate H Loadingrepertoire {Repertor betltse}
translate H Movesloaded {Betlttt lpsek}
translate H Repertoirenotfound {A repertor nincs meg.}
translate H Openfirstrepertoirewithtype {Elbb nyiss meg egy repertor-adatbzist a jobb oldali ikon segtsgvel.}
translate H Movenotinrepertoire {A lps nincs a repertorban.}
translate H PositionsInRepertoire {A repertorban szerepl llsok}
translate H PositionsNotPlayed {A nem jtszott llsok}
translate H PositionsPlayed {A megjtszott llsok}
translate H Success {Siker}
translate H DubiousMoves {Ktes lpsek}
translate H OutOfRepertoire {A repertor kimerlt.}
translate H ConfigureTactics {Taktika belltsai}
translate H ResetScores {Eredmnyek trlse}
translate H LoadingBase {Adatbzis betltse}
translate H Tactics {Taktika}
translate H ShowSolution {Mutasd meg a megfejtst.}
translate H NextExercise {Kvetkez gyakorlat}
translate H PrevExercise {elz gyakorlat}
translate H StopTraining {Hagyja abba az edzst}
translate H Next {Kvetkez}
translate H ResettingScore {Eredmnyek trlse}
translate H LoadingGame {Jtszma betltse}
translate H MateFound {Megvan a matt.}
translate H BestSolutionNotFound {Nincs meg a legjobb megolds!}
translate H MateNotFound {Nincs meg a matt.}
translate H ShorterMateExists {Van rvidebb matt.}
translate H ScorePlayed {A megtett lps rtkelse}
translate H Expected {vrt}
translate H ChooseTrainingBase {Vlaszd ki az edzsadatbzist.}
translate H Thinking {Gondolkodom...}
translate H AnalyzeDone {Az elemzs ksz.}
translate H WinWonGame {Nyert jtszma megnyerse}
translate H Lines {Vltozatok}
translate H ConfigureUCIengine {UCI-motor belltsa}
translate H SpecificOpening {Meghatrozott megnyits}
translate H StartNewGame {j jtszma}
translate H FixedLevel {Megadott szint}
translate H Opening {Megnyits}
translate H RandomLevel {Vletlen szint}
translate H StartFromCurrentPosition {Ez legyen a kezdlls}
translate H FixedDepth {Adott mlysg}
translate H Nodes {Csompont} 
translate H Depth {Mlysg}
translate H Time {Id} 
translate H SecondsPerMove {Msodperc lpsenknt}
translate H Engine {Motor}
translate H TimeMode {Idbeoszts}
translate H TimeBonus {Idalap + nvekmny}
translate H TimeMin {perc}
translate H TimeSec {msodperc}
translate H AllExercisesDone {Minden gyakorlat ksz.}
translate H MoveOutOfBook {A lps nem szerepel a megnyitstrban.}
translate H LastBookMove {Utols lps a megnyitstrban}
translate H AnnotateSeveralGames {Tbb jtszma kommentlsa\na jelenlegitl eddig:}
translate H FindOpeningErrors {Megnyitsi hibk keresse}
translate H MarkTacticalExercises {Taktikai gyakorlatok megjellse}
translate H UseBook {Megnyitstr-hasznlat}
translate H MultiPV {Tbb vltozat}
translate H Hash {Hesmemria}
translate H OwnBook {A motor megnyitstrnak hasznlata}
translate H BookFile {Megnyitstr}
translate H AnnotateVariations {Vltozatok kommentlsa}
translate H ShortAnnotations {Rvid kommentr}
translate H addAnnotatorTag {rtkel jel hozzadsa}
translate H AddScoreToShortAnnotations {Rvid kommentr kiegsztse rtkelssel}
translate H Export {Export}
translate H BookPartiallyLoaded {Megnyitstr rszlegesen betltve}
translate H Calvar {Vltozatok szmtsa}
translate H ConfigureCalvar {Bellts}
# Opening names used in tacgame.tcl
translate H Reti {Rti}
translate H English {Angol}
translate H d4Nf6Miscellaneous {1.d4 Nf6 vegyes}
translate H Trompowsky {Trompowsky}
translate H Budapest {Budapest}
translate H OldIndian {indiai}
translate H BenkoGambit {Benk-csel}
translate H ModernBenoni {Modern Benoni}
translate H DutchDefence {Holland vdelem}
translate H Scandinavian {Skandinv}
translate H AlekhineDefence {Aljechin-vdelem}
translate H Pirc {Pirc}
translate H CaroKann {Caro-Kann}
translate H CaroKannAdvance {Betols Caro-Kann}
translate H Sicilian {Szicliai}
translate H SicilianAlapin {Szicliai Alapin}
translate H SicilianClosed {Zrt szicliai}
translate H SicilianRauzer {Szicliai Rauzer}
translate H SicilianDragon {Szicliai srkny}
translate H SicilianScheveningen {Szicliai Scheveningen}
translate H SicilianNajdorf {Szicliai Najdorf}
translate H OpenGame {Nylt megnyitsok}
translate H Vienna {Bcsi jtk}
translate H KingsGambit {Kirlycsel}
translate H RussianGame {Orosz vdelem}
translate H ItalianTwoKnights {Olasz megnyits/Ketts huszrjtk}
translate H Spanish {Spanyol}
translate H SpanishExchange {Cserespanyol}
translate H SpanishOpen {Nylt spanyol}
translate H SpanishClosed {Zrt spanyol}
translate H FrenchDefence {Francia vdelem}
translate H FrenchAdvance {Betols francia}
translate H FrenchTarrasch {Francia Tarrasch}
translate H FrenchWinawer {Francia Winawer}
translate H FrenchExchange {Cserefrancia}
translate H QueensPawn {Vezrgyalog megnyits}
translate H Slav {Szlv}
translate H QGA {Elfogadott vezrcsel}
translate H QGD {Elhrtott vezrcsel}
translate H QGDExchange {Elhrtott vezrcsel - cserevltozat}
translate H SemiSlav {Flszlv}
translate H QGDwithBg5 {Elhrtott vezrcsel Fg5-tel}
translate H QGDOrthodox {Orthodox vezrcsel}
translate H Grunfeld {Grnfeld}
translate H GrunfeldExchange {Grnfeld - cserevltozat}
translate H GrunfeldRussian {Grnfeld - orosz vltozat}
translate H Catalan {Kataln}
translate H CatalanOpen {Nylt kataln}
translate H CatalanClosed {Zrt kataln}
translate H QueensIndian {Vezrindiai}
translate H NimzoIndian {Nimzo-indiai}
translate H NimzoIndianClassical {Klasszikus Nimzo-indiai}
translate H NimzoIndianRubinstein {Nimzo-indiai - Rubinstein}
translate H KingsIndian {Kirlyindiai}
translate H KingsIndianSamisch {Kirlyindiai - Smisch}
translate H KingsIndianMainLine {Kirlyindiai - fvltozat}

# FICS
translate H ConfigureFics {FICS belltsa}
translate H FICSGuest {Belps vendgknt}
translate H FICSServerPort {Szerverport}
translate H FICSServerAddress {IP-cm}
translate H FICSRefresh {Frissts}
translate H FICSTimesealPort {Idblyegport}
translate H FICSSilence {Csend}
translate H FICSOffers {Ajnlatok}
translate H FICSConsole {Konzol}
translate H FICSGames {Jtszmk}
translate H FICSUnobserve {Hagyd abba a jtk megfigyelst}
translate H FICSProfile {Jelentse meg elzmnyeit s profiljt}
translate H FICSRelayedGames {Kzvettett jtkok}
translate H FICSFindOpponent {Ellenflkeres}
translate H FICSTakeback {Visszavtel}
translate H FICSTakeback2 {Visszavtel 2}
translate H FICSInitTime {Kezdeti id (perc)}
translate H FICSIncrement {Nvekmny (msodperc)}
translate H FICSRatedGame {les jtszma}
translate H FICSAutoColour {automatikus}
translate H FICSManualConfirm {kzi megersts}
translate H FICSFilterFormula {Szrformula}
translate H FICSIssueSeek {Keress}
translate H FICSChallenge {Kihvs}
translate H FICSAccept {elfogad}
translate H FICSDecline {elutast}
translate H FICSColour {Szn}
translate H FICSSend {kld}
translate H FICSConnect {Csatlakozs}
translate H FICSdefaultuservars {Hasznljon alaprtelmezett vltozkat}
translate H FICSObserveconfirm {Szeretnd megfigyelni a jtkot}
translate H FICSpremove {Elmozgats engedlyezse}
translate H FICSObserve {Figyeld meg}
translate H FICSRatedGames {rtkelt jtkok}
translate H FICSUnratedGames {Besorolatlan jtkok}
translate H FICSRated {Nvleges}
translate H FICSUnrated {Nem minstett}
translate H FICSRegisteredPlayer {Csak regisztrlt jtkos}
translate H FICSFreePlayer {Csak ingyenes jtkos}
translate H FICSNetError {Hlzati hiba\Nem lehet csatlakozni}

# Game review
translate H GameReview {Jtk ismertet}
translate H GameReviewTimeExtended {Id meghosszabbtva}
translate H GameReviewMargin {Hibamarg}
translate H GameReviewAutoContinue {Automatikus folytats, ha a mozgs megfelel}
translate H GameReviewReCalculate {Hasznljon hosszabb idt}
translate H GameReviewAnalyzingMovePlayedDuringTheGame {A jtk sorn megtett lpsek elemzse}
translate H GameReviewAnalyzingThePosition {A pozci elemzse}
translate H GameReviewEnterYourMove {Adja meg lpst}
translate H GameReviewCheckingYourMove {Mozgsod ellenrzse}
translate H GameReviewYourMoveWasAnalyzed {A lpsedet kielemeztk}
translate H GameReviewYouPlayedSameMove {Ugyanazt a lpst jtszottad, mint a meccsen}
translate H GameReviewScoreOfYourMove {A lpsed pontszma}
translate H GameReviewGameMoveScore {A jtk lpsnek eredmnye}
translate H GameReviewEngineScore {A motor pontszma}
translate H GameReviewYouPlayedLikeTheEngine {gy jtszottl, mint a motor}
translate H GameReviewNotEngineMoveButGoodMove {Nem a motor mozgsa, de az is j lps}
translate H GameReviewMoveNotGood {Ez a lps nem j, a pontszm az}
translate H GameReviewMovesPlayedLike {Mozgs jtszott, mint}
translate H GameReviewMovesPlayedEngine {Mozdulatok jtszottak, mint a motor}

# Correspondence Chess Dialogs:
translate H CCDlgCGeneraloptions {ltalnos lehetsgek}
translate H CCDlgLoginName  {Bejelentkez nv:}
translate H CCDlgPassword   {Jelsz:}
translate H CCDlgShowPassword {Jelsz megjelentse}

# Connect Hardware dialogs
translate H ExtHWConfigConnection {Kls hardver bellts}
translate H ExtHWPort {Port}
translate H ExtHWEngineCmd {Motorparancs}
translate H ExtHWEngineParam {Motorparamter}
translate H ExtHWShowButton {Mutasd meg a nyomgombot.}
translate H ExtHWHardware {Hardver}
translate H ExtHWNovag {Novag Citrine}
translate H ExtHWInputEngine {Bemeneti motor}
translate H ExtHWNoBoard {Nincs sakktbla}
translate H NovagReferee {Jtkvezet}

# Input Engine dialogs
translate H IEConsole {Bemeneti motor kezelszerve}
translate H IESending {Lpsek bekrve}
translate H IESynchronise {Szinkronizls}
translate H IERotate  {Forgats}
translate H IEUnableToStart {Nem tudom elindtani ezt a bemeneti motort:}

# Calculation of Variations
translate H DoneWithPosition {lls ksz}

translate H Board {Sakktbla}
translate H showGameInfo {A jtszma adatai}
translate H autoResizeBoard {A sakktbla automatikus tmretezse}
translate H DockTop {Mozgats fellre}
translate H DockBottom {Mozgats alulra}
translate H DockLeft {Mozgats balra}
translate H DockRight {Mozgats jobbra}
translate H Undock {Felolds}

# Switcher window
translate H AboutDatabase {Errl az adatbzisrl}
translate H ChangeIcon {Ikon mdostsa...}
translate H NewGameListWindow {j jtklista ablak}
translate H LoadatStartup {Betlts indtskor}

# Gamelist window
translate H ShowHideDB {Adatbzisok megjelentse/elrejtse}
translate H ChangeFilter {Cserlje ki a szrt}
translate H ChangeLayout {Rendezsi felttelek s oszlopelrendezs betltse/mentse/mdostsa}
translate H ShowHideStatistic {Statisztikk megjelentse/elrejtse}
translate H BoardFilter {Csak azokat a jtkokat jelentse meg, amelyek megfelelnek az aktulis tblapozcinak}
translate H CopyGameTo {Jtk msolsa ide}
translate H FindBar {Keresse meg a brt}
translate H FindCurrentGame {Keresse meg az aktulis jtkot}
translate H DeleteGame {Jtk trlse}
translate H UndeleteGame {Jtk trlsnek visszavonsa}
translate H ResetSort {Rendezs visszalltsa}

translate H ConvertNullMove {Konvertlja a null mozgsokat megjegyzsekk}
translate H SetupBoard {Belltsi tbla}
translate H Rotate {Forog}
translate H SwitchColors {Vlts szneket}
translate H FlipBoard {Flip Board}
translate H ImportPGN {PGN jtk importlsa}
translate H ImportingFiles {PGN fjlok importlsa}
translate H ImportingFrom {Importls innen}
translate H ImportingIn {Jtkok importlsa}
translate H UseLastTag {Hasznlja az utols\ngame cmkit}
translate H Random {Vletlen}
translate H BackToMainline {Menjen vissza a fvonalra}
translate H LeaveVariant {Vltozat elhagysa}
translate H Autoplay {Automatikus lejtszs}
translate H ShowHideCoords {Koordinci megjelentse/elrejtse.}
translate H ShowHideEvalBar {rtkelsv megjelentse/elrejtse}
translate H ShowHideMaterial {Anyag megjelentse/elrejtse}
translate H SelectMarker {Vlassza a Jellt}
translate H FullScreen {Teljes kperny}
translate H FilterStatistic {Statisztika szrse}
translate H MakeCorrections {Javtsokat vgezzen}
translate H Surnames {Vezetknevek}
translate H Ambiguous {Ktrtelm}

#Preferences Dialog
translate H OptionsToolbar "Eszkztr"
translate H OptionsBoard "Sakktbla"
translate H OptionsBoardSize "Tblamret"
translate H OptionsBoardPieces "Figurk stlusa"
translate H OptionsInternationalization "Nemzetkziv vls"
translate H OptionsTablebaseDir "Vlasszon ki legfeljebb 4 tblzatbzis mappt:"

# Evaluation bar
translate H BestMoveArrow "Legjobb mozgs nyl"
translate H NewLocalEngine "+ j motor..."

# Batch Annotate
translate H BatchAnnotate {Batch Annotate}
translate H BatchEngineSelection {Motor kiválasztása}
translate H BatchChessEngine {Sakkmotor:}
translate H BatchNumberOfInstances {Példányok száma:}
translate H BatchGameReview {Játék áttekintése}
translate H BatchTimePerMove {Lépésenkénti idõ (mp):}
translate H BatchAnnotateBlunders {Csak a hibákat jegyezze fel}
translate H BatchBlunderThreshold {Tévedés küszöbe:}
translate H BatchVariationLength {Változat hossza (mozgások):}
translate H BatchOpeningBook {Nyitókönyv}
translate H BatchUseBook {Használja a Könyvet}
translate H BatchAnnotateVariations {Annotálja a variációkat}
translate H BatchShortAnnotations {Rövid megjegyzések}
translate H BatchAddScoreToShort {Pontozás hozzáadása a rövid megjegyzésekhez}
translate H BatchClearOld {Törölje a régi megjegyzéseket és változatokat}
translate H BatchInitializingEngines {Motorok inicializálása...}
translate H BatchAnalyzingGames {Játékok elemzése...}
translate H BatchProgress {Batch Annotate Progress}
translate H BatchComplete {A kötegelt megjegyzés kész!}
translate H BatchCancelled {Kötegelt megjegyzés megszakítva}
translate H BatchStart {Indul}
translate H BatchCancel {Mégse}
translate H BatchCompleted {elkészült}
translate H BatchGames {játékok}
translate H BatchProcessed {feldolgozott}
}
# end of english.tcl
