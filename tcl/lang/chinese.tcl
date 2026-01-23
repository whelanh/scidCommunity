# chinese.tcl:
# Text for menu names and status bar help messages in Chinese (Standard Mandarin).
# Part of Scid (Shane's Chess Information Database).
# Chinese (Standard Mandarin) translation by Antigravity AI
# Encoding: UTF-8

addLanguage M 中文 0 utf-8 chinese.tcl
proc setLanguage_M {} {

# File menu:
menuText M File "文件" 0
menuText M FileNew "新建..." 0 {创建一个新的Scid数据库}
menuText M FileOpen "打开..." 0 {打开现有的Scid数据库}
menuText M FileClose "关闭" 0 {关闭活动的Scid数据库}
menuText M FileFinder "查找器" 0 {打开文件查找器窗口}
menuText M FileSaveImage "保存图像..." 0 {将棋盘保存为图像文件}
menuText M FileBookmarks "书签" 0 {书签菜单（快捷键：Ctrl+B）}
menuText M FileBookmarksAdd "添加书签" 0 {为当前数据库游戏和位置添加书签}
menuText M FileBookmarksFile "归档书签" 0 {为当前书签归档}
menuText M FileBookmarksEdit "编辑书签..." 0 {编辑书签菜单}
menuText M FileBookmarksList "显示文件夹为单层列表" 0 {显示书签文件夹为单层列表，而不是子菜单}
menuText M FileBookmarksSub "显示文件夹为子菜单" 0 {显示书签文件夹为子菜单，而不是单层列表}
menuText M FileReadOnly "只读..." 0 {将当前数据库视为只读，防止更改}
menuText M FileSwitch "切换数据库" 0 {切换到其他打开的数据库}
menuText M FileExit "退出" 0 {退出Scid}

# Edit menu:
menuText M Edit "编辑" 0
menuText M EditAdd "添加变化" 0 {为此棋步添加变化}
menuText M EditPasteVar "粘贴变化" 0
menuText M EditDelete "删除变化" 0 {删除此着法的变化}
menuText M EditFirst "提升为第一变化" 0 {将变化提升为列表中的第一个}
menuText M EditMain "将变化提升为主线" 0 {将变化提升为主线}
menuText M EditTrial "尝试变化" 0 {开始/停止尝试模式，用于在棋盘上测试想法}
menuText M EditStrip "删除" 0 {从此游戏中删除注释或变化}
menuText M EditUndo "撤销" 0 {撤销上次游戏更改}
menuText M EditRedo "重做" 0 {重做上次游戏更改}
menuText M EditStripComments "注释" 0 {从此游戏中删除所有注释和标注}
menuText M EditStripVars "变化" 0 {从此游戏中删除所有变化}
menuText M EditStripBegin "从开始到这里的着法" 0 {从开始到当前位置删除着法}
menuText M EditStripEnd "从这里到结束的着法" 0 {从当前位置到结束删除着法}
menuText M EditReset "清空剪贴板" 0 {将剪贴板完全清空}
menuText M EditCopy "复制此游戏到剪贴板" 0 {将此游戏复制到剪贴板数据库}
menuText M EditPaste "粘贴最后的剪贴板游戏" 0 {在此处粘贴活动的剪贴板游戏}
menuText M EditPastePGN "将剪贴板文本粘贴为PGN游戏..." 0 {将剪贴板文本解释为PGN记谱并在此处粘贴}
menuText M EditSetup "设置开始局面..." 0 {为此游戏设置开始局面}
menuText M EditCopyBoard "复制局面" 0 {以FEN记谱法将当前棋盘复制到剪贴板}
menuText M EditPasteBoard "粘贴开始局面" 0 {从剪贴板设置开始局面}
menuText M ConfigureScid "偏好设置..." 0 {配置SCID的所有选项}

# Game menu:
menuText M Game "游戏" 0
menuText M GameNew "新游戏" 0 {重置为空游戏}
menuText M GameFirst "加载第一局" 0 {加载第一个过滤的游戏}
menuText M GamePrev "加载上一局" 0 {加载上一个过滤的游戏}
menuText M GameReload "重新加载当前游戏" 0 {重新加载此游戏，放弃所做的更改}
menuText M GameNext "加载下一局" 0 {加载下一个过滤的游戏}
menuText M GameLast "加载最后一局" 0 {加载最后一个过滤的游戏}
menuText M GameRandom "加载随机游戏" 0 {随机加载一个过滤的游戏}
menuText M GameNumber "加载游戏编号..." 0 {通过输入编号加载游戏}
menuText M GameReplace "保存：替换游戏..." 0 {保存此游戏，替换旧版本}
menuText M GameAdd "保存：添加新游戏..." 0 {将此游戏保存为数据库中的新游戏}
menuText M GameDeepest "识别开局" 0 {转到ECO手册中列出的最深游戏位置}
menuText M GameGotoMove "转到着法编号..." 0 {转到当前游戏中的指定着法编号}
menuText M GameNovelty "查找新着..." 0 {查找此游戏中之前未下过的第一步棋}

# Search menu:
menuText M Search "搜索" 0
menuText M SearchReset "重置过滤器" 0 {重置过滤器以包含所有游戏}
menuText M SearchNegate "反转过滤器" 0 {反转过滤器，仅包含被排除的游戏}
menuText M SearchEnd "移动到过滤器的最后一局" 0
menuText M SearchCurrent "当前局面..." 0 {搜索当前局面}
menuText M SearchHeader "标头..." 0 {按标头（棋手、赛事等）搜索}
menuText M SearchMaterial "子力/局面..." 0 {按子力或局面模式搜索}
menuText M SearchMoves "着法" 0
menuText M SearchUsing "使用搜索选项文件..." 0 {使用SearchOptions文件搜索}

# Windows menu:
menuText M Windows "窗口" 0
menuText M WindowsGameList "游戏列表" 0 {显示/隐藏游戏列表窗口}
menuText M WindowsPGN "PGN窗口" 0 {显示/隐藏PGN（游戏记谱）窗口}
menuText M WindowsTree "棋局树" 0 {显示/隐藏棋局树窗口}
menuText M WindowsTB "终局库窗口" 0 {显示/隐藏终局库窗口}
menuText M WindowsComment "注释编辑器" 0 {显示/隐藏注释编辑器窗口}

# Tools menu:
menuText M Tools "工具" 0
menuText M ToolsAnalysis "分析引擎..." 0 {启动/停止国际象棋分析引擎}
menuText M ToolsEmail "电子邮件管理器" 0 {打开/关闭电子邮件管理器窗口}
menuText M ToolsFilterGraph "过滤器图表" 0 {打开/关闭相对值的过滤器图表窗口}
menuText M ToolsRating "评级图表" 0 {绘制这些游戏中棋手的评级图表}
menuText M ToolsScore "分数图表" 0 {显示分数图表窗口}
menuText M ToolsExpFilter "扩展过滤器" 0 {显示当前过滤器中的所有游戏}
menuText M ToolsExpCurrent "导出当前游戏" 0 {将当前游戏写入文件}
menuText M ToolsExpText "导出为文本文件" 0 {将当前数据库导出为文本文件}
menuText M ToolsExpHtml "导出为HTML" 0 {将当前数据库导出为HTML文件}
menuText M ToolsExpHtmlImg "导出为HTML（带图片）" 0 {将当前数据库导出为包含棋盘图片的HTML文件}
menuText M ToolsExpLaTeX "导出为LaTeX" 0 {将当前数据库导出为LaTeX文件}
menuText M ToolsBookTuning "调整开局库" 0
menuText M ToolsConnectHardware "连接硬件" 0
menuText M ToolsConnectHardwareConfigure "配置..." 0
menuText M ToolsConnectHardwareHelp "帮助..." 0
menuText M ToolsMaint "维护" 0 {Scid数据库维护工具}
menuText M ToolsMaintenanceWin "维护窗口" 0 {打开/关闭Scid维护窗口}
menuText M ToolsECO "ECO浏览器" 0 {打开ECO（开局分类）浏览器窗口}
menuText M ToolsRepertoire "开局库编辑器" 0 {打开开局库编辑器}
menuText M ToolsOpReport "开局报告" 0 {为当前局面生成开局报告}
menuText M ToolsOpenBaseAsTree "打开数据库到树窗口..." 0 {打开数据库并在树窗口中使用}
menuText M ToolsOpenRecentBaseAsTree "打开最近的数据库到树窗口" 0 {打开最近的数据库并在树窗口中使用}

# Help menu:
menuText M Help "帮助" 0
menuText M HelpContents "目录" 0 {显示帮助目录页面}
menuText M HelpIndex "索引" 0 {显示帮助索引页面}
menuText M HelpGuide "快速指南" 0 {显示快速指南帮助页面}
menuText M HelpHints "提示" 0 {显示提示帮助页面}
menuText M HelpContact "联系信息" 0 {显示联系信息帮助页面}
menuText M HelpTip "每日提示" 0 {显示有用的Scid提示}
menuText M HelpStartup "启动窗口" 0 {显示启动窗口}
menuText M HelpAbout "关于Scid" 0 {关于Scid的信息}

# Common buttons and labels
translate M Ok {确定}
translate M Cancel {取消}
translate M Apply {应用}
translate M Save {保存}
translate M Close {关闭}
translate M Yes {是}
translate M No {否}
translate M All {全部}
translate M None {无}
translate M White {白方}
translate M Black {黑方}
translate M Both {双方}
translate M King {王}
translate M Queen {后}
translate M Rook {车}
translate M Bishop {象}
translate M Knight {马}
translate M Pawn {兵}
translate M Player {棋手}
translate M Rating {等级分}
translate M Score {分数}
translate M Date {日期}
translate M Event {赛事}
translate M Site {地点}
translate M Round {轮次}
translate M Result {结果}
translate M ECO {ECO}
translate M Depth {深度}
translate M Databases {数据库}
translate M Database {数据库}
translate M Filter {过滤器}
translate M Search {搜索}
translate M Position {局面}
translate M GameNumber {游戏编号}
translate M Move {着法}
translate M MoveNumber {着法编号}
translate M FindBestMove {查找最佳着法}
translate M Training {训练}
translate M Analysis {分析}
translate M Engine {引擎}
translate M AnnotateGame {注释游戏}
translate M Email {电子邮件}
translate M Computer {电脑}
translate M Comment {注释}
translate M Comments {注释}
translate M Variation {变化}
translate M Variations {变化}
translate M Error {错误}
translate M FileName {文件名}
translate M Updating {更新中}
translate M Loading {加载中}
translate M Saving {保存中}

menuText M FileMaint "维护" 0 {Scid database maintenance tools}
menuText M FileMaintWin "维护窗口" 0 \
  {打开/关闭Scid数据库维护窗口}
menuText M FileMaintCompact "压缩数据库..." 0 \
  {Compact database files, removing deleted games and unused names}
menuText M FileMaintClass "ECO-Classify Games..." 2 \
  {Recompute the ECO code of all games}
menuText M FileMaintSort "Sort Database..." 0 \
  {Sort all games in the database}
menuText M FileMaintDelete "删除重复对局..." 0 \
  {Find twin games and set them to be deleted}
menuText M FileMaintTwin "Twin Checker Window" 0 \
  {Open/update the Twin checker window}
menuText M FileMaintName "Name Spelling" 0 {名称编辑和拼写检查工具}
menuText M FileMaintNameEditor "Name Editor" 0 \
  {Open/close the name editor window}
menuText M FileMaintNamePlayer "Spellcheck Player Names..." 11 \
  {Spellcheck player names using the spellcheck file}
menuText M FileMaintNameEvent "Spellcheck Event Names..." 11 \
  {Spellcheck event names using the spellcheck file}
menuText M FileMaintNameSite "Spellcheck Site Names..." 11 \
  {Spellcheck site names using the spellcheck file}
menuText M FileMaintNameRound "Spellcheck Round Names..." 11 \
  {Spellcheck round names using the spellcheck file}
menuText M FileOpenLichessTournament "Open Lichess Tournament" 0 {Download and open live Lichess tournament broadcast games}
menuText M FileImportLichess "Import my Lichess" 0 {Import games from your Lichess account}
menuText M FileImportChessCom "Import my chess.com" 0 {Import games from your chess.com account}
menuText M FileMaintFixBase "Repair base" 0 {Try to repair a corrupted base}
menuText M WindowsGList "对局列表" 0 {打开/关闭对局列表窗口}
menuText M WindowsPList "棋手查找" 2 {Open/close the player finder}
menuText M WindowsTmt "锦标赛查找器" 2 {打开/关闭锦标赛查找器}
menuText M WindowsSwitcher "数据库切换器" 0 \
  {打开/关闭数据库切换器窗口}
menuText M WindowsMaint "维护窗口" 0 \
  {打开/关闭维护窗口}
menuText M WindowsECO "ECO浏览器" 0 {打开/关闭ECO浏览器窗口}
menuText M WindowsStats "统计窗口" 0 \
  {打开/关闭筛选统计窗口}
menuText M WindowsBook "开局库窗口" 0 {打开/关闭开局库窗口}
menuText M WindowsCorrChess "通讯窗口" 0 {打开/关闭通讯窗口}
menuText M WindowsGraph "分析图表" 0 {打开显示着法时间和评估的图表窗口}
menuText M ToolsConfigureEngines "配置引擎" 10 {管理引擎配置}
menuText M ToolsAnalysis2 "分析引擎#2..." 17 \
  {启动/停止第二个国际象棋分析引擎}
menuText M ToolsCross "交叉表" 0 {显示此对局的锦标赛交叉表}
menuText M ToolsAbsFilterGraph "绝对筛选图" 7 {打开/关闭绝对值筛选图窗口}
menuText M ToolsTracker "棋子追踪器"  6 {打开棋子追踪器窗口}
menuText M ToolsTraining "训练"  0 {训练工具（战术、开局等）}
menuText M ToolsTacticalGame "战术对局"  0 {进行战术对局}
menuText M ToolsSeriousGame "认真对局"  0 {进行认真对局}
menuText M ToolsTrainOpenings "开局"  0 {使用开局谱训练}
menuText M ToolsTrainReviewGame "复盘"  0 {猜测对局中的着法}
menuText M ToolsTrainTactics "战术"  0 {解决战术问题}
menuText M ToolsTrainCalvar "变化计算"  0 {变化计算训练}
menuText M ToolsTrainFindBestMove "寻找最佳着法"  0 {寻找最佳着法}
menuText M ToolsTrainFics "在FICS上对弈"  0 {在freechess.org上对弈}
menuText M ToolsEngineTournament "引擎锦标赛"  0 {在国际象棋引擎之间开始锦标赛}
menuText M ToolsDownloadTWIC "下载TWIC对局" 0 {下载最新的《本周国际象棋》(TWIC)对局}
menuText M ToolsConnectHardwareNovagCitrineConnect "连接Novag Citrine" 8 {将Novag Citrine与Scid连接}
menuText M ToolsConnectHardwareInputEngineConnect "连接输入引擎" 8 {将输入引擎（例如DGT棋盘）与Scid连接}
menuText M ToolsPInfo "棋手信息"  0 \
  {打开/更新棋手信息窗口}
menuText M ToolsPlayerReport "棋手报告..." 3 \
  {生成棋手报告}
menuText M ToolsExpCurrentPGN "导出对局到PGN文件..." 15 \
  {将当前对局写入PGN文件}
menuText M ToolsExpCurrentHTML "导出对局到HTML文件..." 15 \
  {将当前对局写入HTML文件}
menuText M ToolsExpCurrentHTMLJS "导出对局到HTML和JavaScript文件..." 15 {将当前对局写入HTML和JavaScript文件}
menuText M ToolsExpCurrentLaTeX "导出对局到LaTeX文件..." 15 \
  {将当前对局写入LaTeX文件}
menuText M ToolsExpFilterPGN "导出筛选到PGN文件..." 17 \
  {将所有筛选的对局写入PGN文件}
menuText M ToolsExpFilterHTML "导出筛选到HTML文件..." 17 \
  {将所有筛选的对局写入HTML文件}
menuText M ToolsExpFilterHTMLJS "导出筛选到HTML和JavaScript文件..." 17 {将所有筛选的对局写入HTML和JavaScript文件}
menuText M ToolsExpFilterLaTeX "导出筛选到LaTeX文件..." 17 \
  {将所有筛选的对局写入LaTeX文件}
menuText M ToolsImportOne "导入一个PGN对局..." 0 \
  {从PGN文本导入对局}
menuText M ToolsImportFile "从PGN文件导入对局..." 7 {从PGN文件导入对局}
menuText M ToolsStartEngine1 "启动引擎1" 13  {启动引擎1}
menuText M ToolsStartEngine2 "启动引擎2" 13  {启动引擎2}
menuText M ToolsCaptureBoard "捕获当前棋盘..." 5  {将当前棋盘保存为图像。}
menuText M Play "Play" 0
menuText M CCResign "Resign" 1 {Resign (not via eMail)}
menuText M CCClaimDraw "Claim Draw" 6 {Send move and claim a draw (not via eMail)}
menuText M Options "选项" 0
menuText M OptionsBoardGraphics "格子..." 0 {选择格子纹理}
translate M OptionsBGW {选择格子纹理}
translate M OptionsBoardGraphicsText {为白色和黑色格子选择图形文件：}
menuText M OptionsBoardNames "我的棋手名称..." 0 {编辑我的棋手名称}
menuText M OptionsExport "导出" 0 {更改文本导出选项}
menuText M OptionsFonts "字体" 0 {更改字体}
menuText M OptionsFontsRegular "常规" 0 {更改常规字体}
menuText M OptionsFontsMenu "菜单" 0 {更改菜单字体}
menuText M OptionsFontsSmall "小" 0 {更改小字体}
menuText M OptionsFontsTiny "极小" 0 {更改极小字体}
menuText M OptionsFontsFixed "固定" 0 {更改等宽字体}
menuText M OptionsGInfo "对局信息" 0 {对局信息选项}
menuText M OptionsLanguage "语言" 0 {选择菜单语言}
menuText M OptionsMovesTranslatePieces "翻译棋子" 0 {翻译棋子的首字母}
menuText M OptionsMovesHighlightLastMove "高亮最后着法" 0 {高亮最后着法}
menuText M OptionsMovesHighlightLastMoveDisplay "显示格子" 0 {显示最后着法高亮}
menuText M OptionsMovesHighlightLastMoveWidth "宽度" 0 {线条粗细}
menuText M OptionsMovesHighlightLastMoveColor "Color" 0 {线条颜色}
menuText M OptionsMovesHighlightLastMoveArrow "显示箭头" 0 {显示带高亮的箭头}
menuText M OptionsMovesHighlightLastMoveNag "显示评估符号" 0
menuText M OptionsMoves "着法" 0 {着法输入选项}
menuText M OptionsMovesAnimate "动画时间" 1 \
  {设置用于动画着法的时间}
menuText M OptionsMovesDelay "自动播放延迟..." 1 \
  {设置自动播放模式的延迟时间}
menuText M OptionsMovesCoord "坐标着法输入" 0 \
  {接受坐标式着法输入（例如"g1f3"）}
menuText M OptionsMovesSuggest "显示建议着法" 0 \
  {开启/关闭着法建议}
menuText M OptionsShowVarPopup "显示变化窗口" 0 {开启/关闭变化窗口的显示}
menuText M OptionsMovesSpace "在着法编号后添加空格" 0 {在着法编号后添加空格}
menuText M OptionsMovesLichess "Lichess/ChessBase注释格式" 0 {使用Lichess/ChessBase格式的格子标记和箭头}
menuText M OptionsMovesKey "键盘自动完成" 0 \
  {开启/关闭键盘着法自动完成}
menuText M OptionsMovesShowVarArrows "显示变化箭头" 0 {开启/关闭显示变化中着法的箭头}
menuText M OptionsMovesShowEngineVariationArrows "显示引擎变化箭头" 0 {开启/关闭在多PV模式下显示引擎变化线的箭头}
menuText M OptionsMovesGlossOfDanger "危险等级颜色编码" 0 {开启/关闭危险等级颜色编码}
menuText M OptionsNumbers "数字格式" 0 {选择数字格式}
menuText M OptionsTheme "主题" 0 {更改界面外观}
menuText M OptionsWindows "窗口" 0 {窗口选项}
menuText M OptionsSounds "声音" 2 {配置着法提示音}
menuText M OptionsResources "资源..." 0 {选择资源文件和文件夹}
menuText M OptionsWindowsDock "停靠窗口" 0 {停靠窗口（需要重启）}
menuText M OptionsWindowsSaveLayout "保存布局" 0 {保存布局}
menuText M OptionsWindowsRestoreLayout "恢复布局" 0 {恢复布局}
menuText M OptionsWindowsShowGameInfo "显示对局信息" 0 {显示对局信息}
menuText M OptionsWindowsAutoLoadLayout "自动加载第一个布局" 0 {启动时自动加载第一个布局}
menuText M OptionsECO "ECO文件" 7 {加载ECO分类文件}
menuText M OptionsSpell "拼写检查文件" 11 \
  {加载Scid拼写检查文件}
menuText M OptionsTable "残局库目录" 10 \
  {选择残局库文件；将使用其目录中的所有残局库}
menuText M OptionsRecent "最近文件" 0 {更改文件菜单中显示的最近文件数量}
menuText M OptionsBooksDir "开局库目录" 0 {设置开局库目录}
menuText M OptionsTacticsBasesDir "数据库目录" 0 {设置战术（训练）数据库目录}
menuText M OptionsPhotosDir "照片目录" 0 {设置照片数据库目录}
menuText M OptionsThemeDir "主题文件"  0 {加载GUI主题包文件}
menuText M OptionsSave "保存选项" 0 "将所有可设置选项保存到文件$::optionsFile"
menuText M OptionsAutoSave "退出时自动保存选项" 0 \
  {退出Scid时自动保存所有选项}
menuText M GInfoHideNext "Hide Next Move" 0
menuText M GInfoMaterial "Show Material Values" 0
menuText M GInfoFEN "Show FEN" 5
menuText M GInfoMarks "Show Colored Squares and Arrows" 5
menuText M GInfoWrap "Wrap Long Lines" 0
menuText M GInfoFullComment "Show Full Comment" 10
menuText M GInfoPhotos "Show Photos" 5
menuText M GInfoTBNothing "Tablebases: Nothing" 12
menuText M GInfoTBResult "Tablebases: Result Only" 12
menuText M GInfoTBAll "Tablebases: Result and Best Moves" 19
menuText M GInfoDelete "(Un)Delete This Game" 4
menuText M GInfoMark "(Un)Mark This Game" 4
menuText M GInfoInformant "Configure informant values" 0
translate M Back {Back}
translate M Browse {浏览}
translate M Continue {Continue}
translate M Clear {清除}
translate M Contents {目录}
translate M Defaults {Defaults}
translate M Delete {删除}
translate M Graph {图表}
translate M Hide {隐藏}
translate M Import {导入}
translate M Index {索引}
translate M LoadGame {Load Game}
translate M BrowseGame {Browse Game}
translate M MergeGame {Merge Game}
translate M MergeGames {Merge Games}
translate M Preview {Preview}
translate M Revert {Revert}
translate M Stop {停止}
translate M Store {Store}
translate M Update {更新}
translate M ChangeOrient {Change window orientation}
translate M ShowIcons {Show Icons}
translate M First {第一个}
translate M Current {当前}
translate M Last {最后一个}
translate M game {对局}
translate M games {对局}
translate M move {着法}
translate M moves {着法}
translate M all {全部}
translate M RatingDiff {Rating difference (White - Black)}
translate M AverageRating {Average Rating}
translate M Country {Country}
translate M IgnoreColors {Ignore colors}
translate M EventDate {Event date}
translate M Decade {Decade}
translate M Year {年}
translate M Month {月}
translate M Months {January February March April May June July August September October November December}
translate M Days {Sun Mon Tue Wed Thu Fri Sat}
translate M YearToToday {-1Y}
translate M YearToTodayTooltip {Set date from 1 year back to today}
translate M Length {Length}
translate M ECOCode {ECO code}
translate M Deleted {Deleted}
translate M SearchResults {Search Results}
translate M OpeningTheDatabase {Opening database}
translate M noGames {no games}
translate M allGames {all games}
translate M empty {空}
translate M clipbase {剪贴板数据库}
translate M score {分数}
translate M StartPos {Start position}
translate M Total {总计}
translate M readonly {read-only}
translate M ErrNotOpen {This is not an open database.}
translate M ErrReadOnly {This database is read-only; it cannot be altered.}
translate M ErrSearchInterrupted {Search was interrupted; results are incomplete.}
translate M twin {重复}
translate M deleted {deleted}
translate M comment {注释}
translate M hidden {隐藏}
translate M LastMove {Last move}
translate M NextMove {下一个}
translate M GameStart {Start of game}
translate M LineStart {Start of line}
translate M GameEnd {End of game}
translate M LineEnd {End of line}
translate M PInfoAll {Results for <b>all</b> games}
translate M PInfoFilter {Results for <b>filter</b> games}
translate M PInfoAgainst {Results against}
translate M PInfoMostWhite {Most common openings as White}
translate M PInfoMostBlack {Most common openings as Black}
translate M PInfoRating {Rating history}
translate M PInfoBio {Biography}
translate M PInfoEditRatings {Edit Ratings}
translate M PInfoEloFile {直线}
translate M Draw {和棋}
translate M with {与}
translate M only {仅}
translate M lose {lose}
translate M loses {loses}
translate M Tip {提示}
translate M TipAtStartup {Tip at startup}
translate M TipConvertPGN {You can get better performance by converting PGN files}
menuText M TreeFile "直线" 0
menuText M TreeFileFillWithBase "Fill Cache with base" 0 {Fill the cache file with all games in current base}
menuText M TreeFileFillWithGame "Fill Cache with game" 0 {Fill the cache file with current game in current base}
menuText M TreeFileSetCacheSize "Cache size" 0 {Set the cache size}
menuText M TreeFileCacheInfo "Cache info" 0 {Get info on cache usage}
menuText M TreeFileSave "Save Cache File" 0 {Save the tree cache (.stc) file}
menuText M TreeFileFill "Fill Cache File" 0 \
  {Fill the cache file with common opening positions}
menuText M TreeFileBest "Best Games List" 0 {Show the best tree games list}
menuText M TreeFileGraph "Graph Window" 0 {Show the graph for this tree branch}
menuText M TreeFileCopy "Copy Tree Text to Clipboard" 1 \
  {Copy the tree statisctics to the clipboard}
menuText M TreeFileClose "Close Tree Window" 0 {Close the tree window}
menuText M TreeMask "Mask" 0
menuText M TreeMaskNew "新的" 0 {New mask}
menuText M TreeMaskOpen "打开" 0 {Open mask}
menuText M TreeMaskOpenRecent "Open recent" 0 {Open recent mask}
menuText M TreeMaskSave "保存" 0 {Save mask}
menuText M TreeMaskClose "关闭" 0 {Close mask}
menuText M TreeMaskFillWithGame "Fill with game" 0 {Fill mask with game}
menuText M TreeMaskFillWithBase "Fill with base" 0 {Fill mask with all games in base}
menuText M TreeMaskInfo "Info" 0 {Show statistics for current mask}
menuText M TreeMaskDisplay "Display mask map" 0 {Show mask data in a tree form}
menuText M TreeMaskSearch "搜索" 0 {Search in current mask}
menuText M TreeSort "排序" 0
menuText M TreeSortAlpha "Alphabetical" 0
menuText M TreeSortECO "ECO Code" 0
menuText M TreeSortFreq "频率" 0
menuText M TreeSortScore "分数" 0
menuText M TreeOpt "选项" 0
menuText M TreeOptSlowmode "slow mode" 0 {Slow mode for updates (high accuracy)}
menuText M TreeOptFastmode "Fast mode" 0 {Fast mode for updates (no move transposition)}
menuText M TreeOptFastAndSlowmode "Fast and slow mode" 0 {Fast mode then slow mode for updates}
menuText M TreeOptStartStop "Auto refreshing" 0 {Toggles automatic refreshing of the tree window}
menuText M TreeOptLock "锁定" 0 {Lock/unlock the tree to the current database}
menuText M TreeOptTraining "训练" 0 {Turn on/off tree training mode}
menuText M TreeOptAutosave "Auto-Save Cache File" 0 \
  {Auto-save the cache file when closing the tree window}
menuText M TreeHelp "帮助" 0
menuText M TreeHelpTree "Tree Help" 0
menuText M TreeHelpIndex "Help Index" 0
translate M SaveCache {Save Cache}
translate M LockTree {锁定}
translate M TreeLocked {locked}
translate M TreeBest {最佳}
translate M TreeBestGames {Best Tree Games}
translate M TreeTitleRow \
  {    Move   ECO       Frequency    Score  AvElo Perf AvYear %Draws}
translate M TreeTotal {总计}
translate M DoYouWantToSaveFirst {Do you want to save first}
translate M AddToMask {Add to Mask}
translate M RemoveFromMask {Remove from Mask}
translate M AddThisMoveToMask {Add this move to Mask}
translate M SearchMask {Search in Mask}
translate M DisplayMask {Display Mask}
translate M Nag {Nag code}
translate M Marker {Marker}
translate M Include {Include}
translate M Exclude {Exclude}
translate M MainLine {Main line}
translate M Bookmark {Bookmark}
translate M NewLine {New line}
translate M ToBeVerified {To be verified}
translate M ToTrain {To train}
translate M Dubious {可疑}
translate M ToRemove {To remove}
translate M NoMarker {No marker}
translate M ColorMarker {Color}
translate M WhiteMark {白方}
translate M GreenMark {Green}
translate M YellowMark {Yellow}
translate M BlueMark {Blue}
translate M RedMark {Red}
translate M CommentMove {Comment move}
translate M CommentPosition {Comment position}
translate M AddMoveToMaskFirst {Add move to mask first}
translate M OpenAMaskFileFirst {Open a mask file first}
translate M Positions {Positions}
translate M Moves {着法}
menuText M FinderFile "直线" 0
menuText M FinderFileSubdirs "Look in Subdirectories" 0
menuText M FinderFileClose "Close File Finder" 0
menuText M FinderSort "排序" 0
menuText M FinderSortType "Type" 0
menuText M FinderSortSize "Size" 0
menuText M FinderSortMod "Modified" 0
menuText M FinderSortName "名称" 0
menuText M FinderSortPath "Path" 0
menuText M FinderTypes "Types" 0
menuText M FinderTypesScid "Scid Databases" 0
menuText M FinderTypesOld "Old-Format Scid Databases" 0
menuText M FinderTypesPGN "PGN Files" 0
menuText M FinderTypesEPD "EPD Files" 0
menuText M FinderTypesRep "Repertoire Files" 0
menuText M FinderHelp "帮助" 0
menuText M FinderHelpFinder "File Finder Help" 0
menuText M FinderHelpIndex "Help Index" 0
translate M FinderDir {Directory}
translate M FinderDirs {Directories}
translate M FinderFiles {纵线}
translate M FinderUpDir {up}
translate M FinderCtxOpen {打开}
translate M FinderCtxBackup {Backup}
translate M FinderCtxCopy {复制}
translate M FinderCtxMove {着法}
translate M FinderCtxDelete {删除}
menuText M PListFile "直线" 0
menuText M PListFileUpdate "更新" 0
menuText M PListFileClose "Close Player Finder" 0
menuText M PListSort "排序" 0
menuText M PListSortName "名称" 0
menuText M PListSortElo "Elo" 0
menuText M PListSortGames "对局" 0
menuText M PListSortOldest "Oldest" 0
menuText M PListSortNewest "Newest" 2
menuText M TmtFile "直线" 0
menuText M TmtFileUpdate "更新" 0
menuText M TmtFileClose "Close Tournament Finder" 0
menuText M TmtSort "排序" 0
menuText M TmtSortDate "日期" 0
menuText M TmtSortPlayers "棋手" 0
menuText M TmtSortGames "对局" 0
menuText M TmtSortElo "Elo" 0
menuText M TmtSortSite "地点" 0
menuText M TmtSortEvent "赛事" 1
menuText M TmtSortWinner "Winner" 0
translate M TmtLimit "List Limit"
translate M TmtMeanElo "Mean Elo"
translate M TmtNone "No matching tournaments were found."
menuText M GraphFile "直线" 0
menuText M GraphFileColor "Save as Color PostScript..." 8
menuText M GraphFileGrey "Save as Greyscale PostScript..." 8
menuText M GraphFileClose "Close Window" 6
menuText M GraphOptions "选项" 0
menuText M GraphOptionsWhite "白方" 0
menuText M GraphOptionsBlack "黑方" 0
menuText M GraphOptionsBoth "Both" 1
menuText M GraphOptionsPInfo "Player Info player" 0
menuText M GraphOptionsEloFile "Elo from rating file" 0
menuText M GraphOptionsEloDB "Elo from database" 0
translate M GraphFilterTitle "Filter Graph: frequency per 1000 games"
translate M GraphAbsFilterTitle "Filter Graph: frequency of the games"
translate M ConfigureFilter "Configure X-Axes for Year, Rating and Moves"
translate M FilterEstimate "Estimate"
translate M TitleFilterGraph "Scid: Filter Graph"
translate M AddVariation {Add Variation}
translate M AddAllVariations {Add All Variations}
translate M AddMove {Add Move}
translate M Annotate {注释}
translate M ShowAnalysisBoard {Show analysis board}
translate M ShowInfo {Show engine info}
translate M FinishGame {Finish game}
translate M StopEngine {Stop engine}
translate M StartEngine {Start engine}
translate M LockEngine {Lock engine to current position}
translate M AnalysisCommand {Analysis Command}
translate M PreviousChoices {Previous Choices}
translate M AnnotateTime {Time per move in sec.}
translate M AnnotateWhich {Add variations}
translate M AnnotateAll {For moves by both sides}
translate M AnnotateAllMoves {Annotate all moves}
translate M AnnotateWhite {For White moves only}
translate M AnnotateBlack {For Black moves only}
translate M AnnotateBlundersOnly {When game move is a blunder}
translate M AnnotateBlundersOnlyScoreChange {Analysis reports blunder, with score change from/to: }
translate M BlundersThreshold {Threshold}
translate M ScoreAllMoves {Score all moves}
translate M LowPriority {Low CPU Priority}
translate M ClickHereToSeeMoves {Click here to see moves}
translate M ConfigureInformant {Informant values}
translate M Informant!? {Interesting move}
translate M Informant? {Poor move}
translate M Informant?? {严重失误}
translate M Informant?! {Dubious move}
translate M Informant+= {White has a slight advantage}
translate M Informant+/- {White has a clear advantage}
translate M Informant+- {White has a decisive advantage}
translate M Informant+-- {White has a crushing advantage}
translate M Book {开局库}
translate M OtherBookMoves {Opponent's book}
translate M OtherBookMovesTooltip {Moves to which the opponent has a reply}
translate M EngineList {Analysis Engine List}
translate M EngineName {名称}
translate M EngineCmd {Command}
translate M EngineArgs {Parameters}
translate M EngineDir {Directory}
translate M EngineElo {Elo}
translate M EngineTime {日期}
translate M EngineNew {新的}
translate M EngineEdit {编辑}
translate M EngineRequired {Fields in bold are required; others are optional}
translate M EngineProtocol {Communication protocol}
translate M EngineNotation {Notation of the moves}
translate M EngineFlipEvaluation {Flip evaluation perspective}
translate M EngineShowLog {Show communication log}
translate M EngineNetworkd {Accept remote connections}
translate M EngineSelect {Select the current engine}
translate M EngineAddLocal {Add a local engine}
translate M EngineAddRemote {Add a remote engine}
translate M EngineReload {Reload the current engine}
translate M EngineClone {Create a copy of the current engine}
translate M EngineDelete {Delete the current engine}
menuText M PgnFile "直线" 0
menuText M PgnFileCopy "Copy Game to Clipboard" 0
menuText M PgnFilePrint "Print to File..." 0
menuText M PgnFileClose "Close PGN Window" 10
menuText M PgnOpt "显示" 0
menuText M PgnOptColor "Color Display" 0
menuText M PgnOptShort "Short (3-line) Header" 0
menuText M PgnOptSymbols "Symbolic Annotations" 1
menuText M PgnOptIndentC "Indent Comments" 0
menuText M PgnOptIndentV "Indent Variations" 7
menuText M PgnOptColumn "Column Style (one move per line)" 1
menuText M PgnOptSpace "Space after Move Numbers" 1
menuText M PgnOptStripMarks "Strip out Colored Square/Arrow Codes" 1
menuText M PgnOptBoldMainLine "Use Bold Text for Main Line Moves" 4
menuText M PgnColor "颜色" 0
menuText M PgnColorHeader "表头..." 0
menuText M PgnColorAnno "注释..." 0
menuText M PgnColorComments "注释..." 0
menuText M PgnColorVars "变化..." 0
menuText M PgnColorBackground "Background..." 0
menuText M PgnColorMain "Main line..." 0
menuText M PgnColorCurrent "Current move background..." 1
menuText M PgnHelp "帮助" 0
menuText M PgnHelpPgn "PGN Help" 0
menuText M PgnHelpIndex "索引" 0
translate M PgnWindowTitle {Notation - game %u}
menuText M CrosstabFile "直线" 0
menuText M CrosstabFileText "Print to Text File..." 9
menuText M CrosstabFileHtml "Print to HTML File..." 9
menuText M CrosstabFileLaTeX "Print to LaTeX File..." 9
menuText M CrosstabFileClose "Close Crosstable Window" 0
menuText M CrosstabEdit "编辑" 0
menuText M CrosstabEditEvent "赛事" 0
menuText M CrosstabEditSite "地点" 0
menuText M CrosstabEditDate "日期" 0
menuText M CrosstabOpt "显示" 0
menuText M CrosstabOptAll "All-play-all" 0
menuText M CrosstabOptSwiss "Swiss" 0
menuText M CrosstabOptKnockout "Knockout" 0
menuText M CrosstabOptAuto "自动" 1
menuText M CrosstabOptAges "Ages in Years" 8
menuText M CrosstabOptNats "Nationalities" 0
menuText M CrosstabOptRatings "Ratings" 0
menuText M CrosstabOptTitles "Titles" 0
menuText M CrosstabOptBreaks "Tie-Break Scores" 4
menuText M CrosstabOptDeleted "Include Deleted Games" 8
menuText M CrosstabOptColors "Colors (Swiss table only)" 0
menuText M CrosstabOptColumnNumbers "Numbered Columns (All-play-all table only)" 2
menuText M CrosstabOptGroup "Group Scores" 0
menuText M CrosstabSort "排序" 0
menuText M CrosstabSortName "名称" 0
menuText M CrosstabSortRating "等级分" 0
menuText M CrosstabSortScore "分数" 0
menuText M CrosstabColor "Color" 0
menuText M CrosstabColorPlain "Plain Text" 0
menuText M CrosstabColorHyper "Hypertext" 0
menuText M CrosstabHelp "帮助" 0
menuText M CrosstabHelpCross "Crosstable Help" 0
menuText M CrosstabHelpIndex "Help Index" 0
translate M SetFilter {Set Filter}
translate M AddToFilter {Add to Filter}
translate M Swiss {Swiss}
translate M Category {Category}
menuText M OprepFile "直线" 0
menuText M OprepFileText "Print to Text File..." 9
menuText M OprepFileHtml "Print to HTML File..." 9
menuText M OprepFileLaTeX "Print to LaTeX File..." 9
menuText M OprepFileOptions "选项..." 0
menuText M OprepFileClose "Close Report Window" 0
menuText M OprepFavorites "Favorites" 1
menuText M OprepFavoritesAdd "Add Report..." 0
menuText M OprepFavoritesEdit "Edit Report Favorites..." 0
menuText M OprepFavoritesGenerate "Generate Reports..." 0
menuText M OprepHelp "帮助" 0
menuText M OprepHelpReport "Opening Report Help" 0
menuText M OprepHelpIndex "Help Index" 0
translate M HeaderSearch {Header Search}
translate M EndSideToMove {Side to move at end of game}
translate M GamesWithNoECO {Games with no ECO?}
translate M GameLength {Game length}
translate M FindGamesWith {Find games with flags}
translate M StdStart {Non-standard start}
translate M Promotions {Promotions}
translate M Annotations {注释}
translate M DeleteFlag {Delete flag}
translate M WhiteOpFlag {White opening}
translate M BlackOpFlag {Black opening}
translate M MiddlegameFlag {中局}

}
# end of chinese.tcl
