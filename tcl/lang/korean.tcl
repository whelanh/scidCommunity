# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

# Text for menu names and status bar help messages in Japanese.
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

proc setLanguage_k {} {

# File menu:
menuText k File "파일" 0
menuText k FileNew "새로..." 0 {새 Scid 데이터베이스 생성}
menuText k FileOpen "맛있는..." 0 {기존 Scid 데이터베이스}
menuText k FileClose "뭐" 0 {활성 Scid 데이터베이스를 닫습니다.}
menuText k FileFinder "찾기" 0 {파일 찾기 창구}
menuText k FileBookmarks "북마크" 0 {북마크 메뉴}
menuText k FileBookmarksAdd "북마크 추가" 0 \
  {현재 데이터베이스 게임 및 위치를 북마크에 추가하세요.}
menuText k FileBookmarksFile "파일북마크" 0 \
  {현재 게임 및 위치에 대한 북마크 파일}
menuText k FileBookmarksEdit "북마크 편집..." 0 \
  {북마크 메뉴 편집}
menuText k FileBookmarksList "폴더를 목록으로 표시" 0 \
  {북마크 폴더를 하위 메뉴가 아닌 단일 목록으로 표시합니다.}
menuText k FileBookmarksSub "폴더 하위 메뉴 표시" 0 \
  {북마크 폴더를 단일 목록이 아닌 하위 메뉴로 표시}
menuText k FileMaint "유지" 0 {Scid 데이터베이스 유지 관리 도구}
menuText k FileMaintWin "유지기간 관리" 0 \
  {Scid 데이터베이스 유지 관리 창구/닫기}
menuText k FileMaintCompact "단위 데이터베이스..." 0 \
  {데이터베이스 파일, 삭제된 게임 및 사용하지 않는 이름 제거}
menuText k FileMaintClass "ECO 특별한 게임..." 2 \
  {모든 게임의 ECO 코드를 다시 계산합니다.}
menuText k FileMaintSort "데이터베이스 대신..." 0 \
  {데이터베이스의 모든 게임 대신}
menuText k FileMaintDelete "트윈 게임 삭제..." 0 \
  {쌍둥이 게임을 찾아 삭제하도록 설정하세요.}
menuText k FileMaintTwin "트윈 체커 창" 0 \
  {트윈 체커 창구/업데이트}
menuText k FileMaintName "이름 철자법" 0 {이름 편집 및 철자 도구}
menuText k FileMaintNameEditor "이름 편집자" 0 \
  {이름 편집자 창구/닫기}
menuText k FileMaintNamePlayer "맞춤법 관리자 이름..." 11 \
  {맞춤법 검사 파일을 사용하는 맞춤법 검사 플레이어 이름}
menuText k FileMaintNameEvent "맞춤법 검사 사건 이름..." 11 \
  {맞춤법 검사 파일을 사용하여 맞춤법 검사 이벤트 이름}
menuText k FileMaintNameSite "맞춤법 검사 사이트 이름..." 11 \
  {맞춤법 검사 파일을 사용하는 맞춤법 검사 사이트 이름}
menuText k FileMaintNameRound "맞춤법 검사관 이름..." 11 \
  {맞춤법 검사 파일을 사용하는 맞춤법 검사 이름}
menuText k FileReadOnly "알고보니..." 0 \
  {현재 데이터베이스를 정렬하여 처리하는 것을 방지합니다.}
menuText k FileSwitch "데이터베이스로 전환" 0 \
  {다른 데이터베이스로 전환됩니다}
menuText k FileOpenLichessTournament "오픈형 리치" 0 {라이브 Lichess 토너먼트 게임을 다운로드하고 열어보세요.}
menuText k FileImportLichess "내 리치를 가져오세요" 0 {Lichess 계정에서 게임 가져오기}
menuText k FileImportChessCom "내 chess.com을 가져오세요" 0 {chess.com 계정에서 게임을 가져오기}
menuText k FileExit "종료" 1 {Scid 종료}
menuText k FileMaintFixBase "수리 장소" 0 {대신에 수리해 보세요}

# Edit menu:
menuText k Edit "편집" 0
menuText k EditAdd "변형 추가" 0 {게임에서 동작에 변형을 추가하세요.}
menuText k EditDelete "변형 삭제" 0 {이 변형의 변형 삭제}
menuText k EditFirst "첫 번째 변형 만들기" 5 \
  {변형을 목록의 첫 번째 항목으로 승격}
menuText k EditMain "변형을 메인 라인으로 승격" 21 \
  {변형을 메인 라인으로 승격}
menuText k EditTrial "변형을 실시한다" 0 \
  {보드에서 아이디어를 테스트하기 평가판 모드 시작/중지}
menuText k EditStrip "조각" 3 {이 게임의 댓글이나 변형을 제거하세요.}
menuText k EditUndo "실행 취소" 0 {현재 변경 취소}
menuText k EditRedo "다시 실행" 0 {마지막 게임 변경 다시 실행}
menuText k EditStripComments "댓글" 0 \
  {이 게임의 모든 댓글과 설명을 제거합니다.}
menuText k EditStripVars "변형" 0 {이 게임의 모든 변형 제거}
menuText k EditStripBegin "처음부터 포맷인다" 1 \
  {게임시작부터 Strip입니다.}
menuText k EditStripEnd "끝으로 이동합니다" 0 \
  {Strip은 게임이 끝날 때까지 이동합니다.}
menuText k EditReset "빈 클립베이스" 0 \
  {Clip베이스를 완전히 비우도록 포함됩니다.}
menuText k EditCopy "이 게임을 Clipbase에 복사" 0 \
  {이 게임을 Clipbase 데이터베이스에 복사하세요}
menuText k EditPaste "마지막 Clipbase 게임 코팅 삽입기" 0 \
  {여기 적극적으로 Clipbase 게임을 도입하시기 바랍니다.}
menuText k EditPastePGN "클립보드 텍스트를 PGN 게임으로 코팅..." 18 \
  {PGN 이름표법으로 클립보드 텍스트를 게임으로 해석해서 여기에 포인트를 넣으세요}
menuText k EditSetup "보드 설정 시작..." 0 \
  {이 게임의 시작 위치를 설정하세요}
menuText k EditCopyBoard "위치 복사" 6 \
  {FEN 표지법으로 현재 보드를 텍스트 항목(클립보드)으로 복사합니다.}
menuText k EditPasteBoard "스타트 보드 헤드폰 배치기" 12 \
  {현재 선택 텍스트(클립보드)에서 시작 보드 설정}
menuText k ConfigureScid "환경 설정..." 0 {SCID에 대한 모든 옵션 구성}

# Game menu:
menuText k Game "게임" 0
menuText k GameNew "새로운 게임" 0 {온 게임으로 회원}
menuText k GameFirst "첫 번째 게임 로드" 5 {첫 번째 섹션이 시작되었습니다.}
menuText k GamePrev "이전 게임로드" 5 {기존의 이전 게임 로드}
menuText k GameReload "현재 게임 다시 로드" 3 \
  {이 게임을 다시 로드하고 변경된 점을 모두 취소합니다.}
menuText k GameNext "다음 게임 로드" 7 {부품화된 다음 게임 로드}
menuText k GameLast "마지막 게임 로드" 8 {마지막으로 게임 로드}
menuText k GameRandom "게임로드" 8 {사용자로 등록된 게임 로드}
menuText k GameNumber "게임 코드 로드..." 5 \
  {해당번호를 입력하여 게임을 다운로드하세요.}
menuText k GameReplace "저장: 게임 교체..." 6 \
  {이 게임을 생성하고 이전 버전을 교체하세요.}
menuText k GameAdd "저장: 새 게임 추가..." 6 \
  {이 게임을 데이터베이스에 새 게임으로 저장하세요.}
menuText k GameDeepest "정의" 0 \
  {ECO Book에 가장 깊은 게임 위치로 이동}
menuText k GameGotoMove "이동번호로 이동..." 5 \
  {현재 게임에서 이동번호로 이동}
menuText k GameNovelty "참신함을 찾아보세요..." 7 \
  {이전에 플레이한 적이 없는 이 게임의 첫 번째 수를 찾아보세요.}

# Search Menu:
menuText k Search "찾다" 0
menuText k SearchReset "필터 부분" 0 {모든 게임이 포함되어 있는지 확인하세요.}
menuText k SearchNegate "낚시 분야" 0 {제외된 게임만을 포함하여 낚시를 재개하세요.}
menuText k SearchCurrent "현재 보드..." 0 {현재 보드 위치 검색}
menuText k SearchHeader "헤더..." 0 {헤더(플레이어, 이벤트 등) 정보로 검색}
menuText k SearchMaterial "있다/패턴..." 0 {재료 또는 보드 검색}
menuText k SearchUsing "파일 검색 사용 중..." 0 {SearchOptions 파일을 사용하여 검색}

# Windows menu:
menuText k Windows "다루다" 0
menuText k WindowsComment "댓글 편집자" 0 {댓글 편집자/닫기}
menuText k WindowsGList "게임 목록" 0 {게임 목록 창구/닫기}
menuText k WindowsPGN "PGN 창" 0 \
  {PGN(게임 표기법) 창찾기/닫기}
menuText k WindowsPList "플레이어 찾기" 2 {플레이어 찾기/닫기}
menuText k WindowsTmt "반대의 경우" 2 {대안 찾기/닫기}
menuText k WindowsSwitcher "데이터베이스 전환기" 0 \
  {데이터베이스 전환기 창으로/닫기}
menuText k WindowsMaint "유지기간 관리" 0 \
  {유지 관리 창구/닫기}
menuText k WindowsECO "친환경 검색" 0 {ECO 브라우저 창구/닫기}
menuText k WindowsStats "통계 창" 0 \
  {낚시 측정 창구/닫기}
menuText k WindowsTree "트리창" 0 {트리 창가/닫기}
menuText k WindowsBook "책 창" 0 {책 창구/닫기}
menuText k WindowsCorrChess "대응창구" 0 {서신창고/닫기}
menuText k WindowsGraph "분석 그래프" 0 {이동 시간 및 평가가 포함된 그래프 창 비교}

# Tools menu:
menuText k Tools "도구" 0
menuText k ToolsConfigureEngines "엔진 구성" 10 {엔진 구성 관리}
menuText k ToolsAnalysis "분석엔진..." 0 \
  {체스 분석 엔진 시작/중지}
menuText k ToolsAnalysis2 "분석 엔진 #2..." 17 \
  {두 번째 체스 분석 엔진 시작/중지}
menuText k ToolsCross "크로스테이블" 0 {이 게임의 크로스테이블 표시}
menuText k ToolsFilterGraph "반대. 파이핑 그래프" 12 {상대값에 대한 분석 그래프 창 비교/닫기}
menuText k ToolsAbsFilterGraph "절대. 파이핑 그래프" 7 {절대값에 대한 그래프 그래프 창 비교/닫기}
menuText k ToolsOpReport "가격" 0 {현재 위치에 대한 내용을 작성하세요}
menuText k ToolsOpenBaseAsTree "나무처럼 리본..." 0   {팝을 열어 트리창에서 사용하기}
menuText k ToolsOpenRecentBaseAsTree "앞으로는 트리로" 0   {기지를 유지하는 나무 창에서 사용하세요}
menuText k ToolsTracker "조각 추적기"  6 {조각 추적기 창구}
menuText k ToolsTraining "훈련"  0 {훈련도구(전술, 부활,...)}
menuText k ToolsTacticalGame "게임 전술"  0 {가지고 있는 전술적 게임을 활동해보세요}
menuText k ToolsSeriousGame "통제하는 활동"  0 {활동적인 활동을 수행합니다.}
menuText k ToolsTrainOpenings "재개"  0 {레퍼토리로 훈련하기}
menuText k ToolsTrainReviewGame "게임평론"  0 {게임에서 동작하는 동작을 취하기}
menuText k ToolsTrainTactics "전술"  0 {문제 해결 전술}
menuText k ToolsTrainCalvar "변형작업"  0 {변형훈련}
menuText k ToolsTrainFindBestMove "최선의 운동 찾기"  0 {최선의 운동 찾기}
menuText k ToolsTrainFics "FICS에서 플레이"  0 {freechess.org에서 플레이하세요}
menuText k ToolsEngineTournament "엔진으로"  0 {체스 엔진 간 토너먼트 시작}
menuText k ToolsTimeAnalysis "시간분석" 0 {현재 게임의 시계 시간 그래프 표시}
menuText k ToolsBookTuning "책은" 0 {책은}
menuText k ToolsDownloadTWIC "TWIC 다운로드" 0 {최신 The Week In Chess(TWIC) 게임을 다운로드하세요.}
menuText k ToolsConnectHardware "하드웨어 연결" 8 {외부 하드웨어 연결}
menuText k ToolsConnectHardwareConfigure "구성..." 0 {외부 하드웨어 및 연결 구성}
menuText k ToolsConnectHardwareNovagCitrineConnect "Novag 시트린 연결" 8 {Novag Citrine을 Scid와 연결}
menuText k ToolsConnectHardwareInputEngineConnect "입력 엔진 연결" 8 {입력 엔진(예: DGT 보드)을 Scid와 연결}

menuText k ToolsPInfo "플레이어 정보"  0 \
  {플레이어 정보 창구/업데이트}
menuText k ToolsPlayerReport "플레이어 지정..." 3 \
  {플레이어 의견 생성}
menuText k ToolsRating "평가 그래프" 0 \
  {현재 게임 플레이어의 평가 내 역을 그래프로 표시}
menuText k ToolsExpCurrent "현재 게임 목록" 8 \
  {현재 게임을 텍스트 파일에 입력}
menuText k ToolsExpCurrentPGN "PGN 파일로 게임을..." 15 \
  {현재 게임을 PGN 파일에 쓰기}
menuText k ToolsExpCurrentHTML "게임을 HTML 파일로 사용할 수 있습니다..." 15 \
  {현재 게임을 HTML 파일에 쓰기}
menuText k ToolsExpCurrentHTMLJS "HTML 및 JavaScript 파일로 게임할 수 있는..." 15 {현재 게임을 HTML 및 JavaScript 파일에 작성했습니다.}
menuText k ToolsExpFilter "모든 것이 가능합니다." 1 \
  {모든 게임을 문자 파일에 입력했습니다.}
menuText k ToolsExpFilterPGN "필터를 PGN 파일로 위치..." 17 \
  {모든 게임을 PGN 파일에 작성했습니다.}
menuText k ToolsExpFilterHTML "HTML 파일로 검색..." 17 \
  {모든 게임을 HTML 파일에 작성했습니다.}
menuText k ToolsExpFilterHTMLJS "필터링을 HTML 및 JavaScript 파일로 포함..." 17 {모든 게임을 HTML 및 JavaScript 파일에 작성했습니다.}
menuText k ToolsImportOne "하나의 PGN 게임 가져오기..." 0 \
  {PGN 텍스트에서 게임을 가져오기}
menuText k ToolsImportFile "PGN 파일을 가져오려면..." 7 {PGN 파일을 가져오기}
menuText k ToolsStartEngine1 "엔진 1 시동" 13  {엔진 1}
menuText k ToolsStartEngine2 "엔진 2 시동" 13  {엔진 2}
menuText k ToolsCaptureBoard "현재 캡처 중..." 5  {현재 보드를 이미지로 생성합니다.}

# Play menu
menuText k Play "플레이" 0

# --- Correspondence Chess
menuText k CCResign "기권" 1 {사임(이메일을 통하지 않음)}
menuText k CCClaimDraw "심사위원" 6 {무브를 충전하고 요청하세요(이메일을 통하지 않으세요)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText k Options "옵션" 0
menuText k OptionsBoardGraphics "사각형..." 0 {키보드의 컨트롤러 선택}
translate k OptionsBGW {키보드의 컨트롤러 선택}
translate k OptionsBoardGraphicsText {및 검은색 사각형에 대한 흰색 파일을 선택합니다.}
menuText k OptionsBoardNames "내 플레이어 이름..." 0 {내 플레이어 이름 편집}
menuText k OptionsExport "." 0 {대응 옵션 변경}
menuText k OptionsFonts "에" 0 {변경되었습니다}
menuText k OptionsFontsRegular "행동인" 0 {일반 변경}
menuText k OptionsFontsMenu "메뉴" 0 {메뉴 변경}
menuText k OptionsFontsSmall "작은" 0 {약간 변경됨}
menuText k OptionsFontsTiny "매우 작은" 0 {약간 변경됨}
menuText k OptionsFontsFixed "결정된" 0 {고정폭이 변경되었습니다.}
menuText k OptionsGInfo "게임정보" 0 {경기정보옵션}
menuText k OptionsLanguage "언어" 0 {메뉴 언어 선택}
menuText k OptionsMovesTranslatePieces "특정 예" 0 {조각의 첫 번째 문자}
menuText k OptionsMovesHighlightLastMove "마지막 이동 강조" 0 {마지막 이동 강조}
menuText k OptionsMovesHighlightLastMoveDisplay "쇼 쇼 쇼" 0 {마지막 이동 알림 표시}
menuText k OptionsMovesHighlightLastMoveWidth "나는" 0 {선의 크기}
menuText k OptionsMovesHighlightLastMoveColor "색상" 0 {선의 색상}
menuText k OptionsMovesHighlightLastMoveArrow "화살표 표시" 0 {강조표시가 있는 화살표 표시}
menuText k OptionsMovesHighlightLastMoveNag "기호 표시" 0
menuText k OptionsMovesHighlightLastMoveEval "평가 표시" 0
menuText k OptionsMoves "이동" 0 {항목 이동 옵션}
menuText k OptionsMovesAnimate "애니메이션 시간" 1 \
  {움직임을 애니메이션하는 데 사용되는 시간 설정}
menuText k OptionsMovesDelay "복구속도 지연..." 1 \
  {자동 게임 모드의 시간 지연 설정}
menuText k OptionsMovesCoord "학문이동 항목" 0 \
  {냄비 스타일 이동 항목 허용(예: "g1f3")}
menuText k OptionsMovesSuggest "제안된 기능 표시" 0 \
  {이동에 포인트기/끄기}
menuText k OptionsShowVarPopup "변형 창표시" 0 {변형 창표시기/끄기}
menuText k OptionsMovesSpace "이동 뒤에 공백 추가" 0 {이동 뒤에 공백 추가}
menuText k OptionsMovesLichess "Lichess/ChessBase 형식을 사용하여" 0 {마커 및 화살표에 Lichess/ChessBase 형식 사용}
menuText k OptionsMovesKey "키보드 완성" 0 \
  {키보드 이동 자동 완성 장치/끄기}
menuText k OptionsMovesShowVarArrows "변형에 대한 화살표 표시" 0 {변형된 동작을 나타내는 방향기/끄기}
menuText k OptionsMovesShowEngineVariationArrows "엔진 변형에 대한 화살표 표시" 0 {다중 PV 모드에서 엔진 변형 라인을 표시하는 화살기/끄기}
menuText k OptionsMovesGlossOfDanger "색상으로 구분된 위험의 점" 0 {색상으로 구분된 위험 조명기/끄기}
translate k OptionsMovesTreeDepth {기본적으로 트리 창 이동 범위}
menuText k OptionsNumbers "숫자 형식" 0 {숫자 형식 선택}
menuText k OptionsTheme "주제" 0 {인터페이스 변경 모양}
menuText k OptionsWindows "다루다" 0 {창옵션}
menuText k OptionsSounds "소리" 2 {이동 알림음 구성}
menuText k OptionsResources "됐습니다..." 0 {파일 및 폴더 선택}
menuText k OptionsWindowsDock "우창" 0 {Dock Window(다시 시작해야 함)}
menuText k OptionsWindowsSaveLayout "저장하여" 0 {저장하여}
menuText k OptionsWindowsRestoreLayout "대체" 0 {대체}
menuText k OptionsWindowsShowGameInfo "게임 정보 표시" 0 {게임 정보 표시}
menuText k OptionsWindowsAutoLoadLayout "첫 번째 페이지 자동 로드" 0 {시작 시 첫 번째 항목 자동 로드}
menuText k OptionsECO "친환경 파일" 7 {ECO 분류 파일 로드}
menuText k OptionsSpell "맞춤법 검사 파일" 11 \
  {Scid 맞춤법 검사 파일 로드}
menuText k OptionsTable "테이블베이스" 10 \
  {테이블 베이스 파일을 선택하십시오. 해당 분기의 모든 테이블을 기반으로 합니다.}
menuText k OptionsRecent "최근 파일" 0 {파일 메뉴에 표시되는 최근 파일 수 변경}
menuText k OptionsBooksDir "책장" 0 {여는 책을 설정합니다}
menuText k OptionsTacticsBasesDir "키예프" 0 {훈련소에서 훈련을 시작합니다.}
menuText k OptionsPhotosDir "사진의" 0 {기본적으로 사용자를 설정합니다.}
menuText k OptionsThemeDir "주제 파일"  0 {GUI 테마 패키지 파일 로드}
menuText k OptionsSave "저장 옵션" 0 "Save all settable options to the file $::optionsFile"
menuText k OptionsAutoSave "종료 시 자동 절약 옵션" 0 \
  {Scid 종료 시 모든 옵션 자동 저장}

# Help menu:
menuText k Help "돕다" 0
menuText k HelpContents "소모" 0 {도움말 목차 페이지 표시}
menuText k HelpIndex "색깔" 0 {도움말 색인 페이지 표시}
menuText k HelpGuide "빠른 가이드" 0 {빠른 가이드 도움말 페이지 표시}
menuText k HelpHints "힌트" 0 {도움말 도움말 페이지 표시}
menuText k HelpContact "문의사항" 1 {고객님의 정보안내 페이지표시}
menuText k HelpTip "오늘의 팁" 0 {유용한 Scid 팁 보기}
menuText k HelpStartup "시작 창" 0 {시작 창 표시}
menuText k HelpAbout "에 대한" 0 {ScidCommunity에 대한 정보}

# Toolbar tooltips:
menuText k RotateBoard "회전하다" 0 {회전하다}

# Game info box popup menu:
menuText k GInfoHideNext "다음 이동 숨기기" 0
menuText k GInfoMaterial "재료 값 표시" 0
menuText k GInfoFEN "펜 표시주기" 5
menuText k GInfoMarks "컬러 세트 및 화살표 표시" 5
menuText k GInfoWrap "긴 줄 감싸기" 0
menuText k GInfoFullComment "전체 댓글 표시" 10
menuText k GInfoPhotos "사진 표시" 5
menuText k GInfoTBNothing "테이블 베이스: 없음" 12
menuText k GInfoTBResult "테이블 베이스: 결과만" 12
menuText k GInfoTBAll "베이스: 결과 및 최고 수 테이블" 19
menuText k GInfoDelete "(Un) 이 게임 삭제" 4
menuText k GInfoMark "(Un)이 게임을 표시하세요" 4
menuText k GInfoInformant "제보자 값 구성" 0

# General buttons:
translate k LichessOpenExplore {Lichess Open탐색}
translate k LichessTitle {Lichess 오프닝 탐색기}
translate k LichessApiTokenReq {Lichess API 토큰(필수):}
translate k LichessDatabase {데이터 베이스:}
translate k LichessMasters {석사}
translate k LichessGames {리치 게임}
translate k LichessPlayer {플레이어}
translate k LichessNumMoves {이동 횟수:}
translate k LichessTopGames {인기 게임:}
translate k LichessRecentGames {최근 게임:}
translate k LichessSinceYear {이후 연도:}
translate k LichessUntilYear {연도까지:}
translate k LichessSinceMonth {이후(YYYY-MM):}
translate k LichessUntilMonth {종료일(YYYY-MM):}
translate k LichessTimeControls {시간 제어}
translate k LichessRatingGroups {평가 그룹}
translate k LichessPlayerName {플레이어 사용자 이름:}
translate k LichessPlayerColor {플레이어 색상:}
translate k LichessWhite {하얀색}
translate k LichessBlack {검은색}
translate k LichessGameModes {게임 모드}
translate k LichessRated {정격}
translate k LichessCasual {평상복}
translate k LichessTokenRequired {Lichess API 토큰이 필요합니다.\n\n2026년 3월부터 Lichess가 오프닝 탐색기에 액세스하려면 API 토큰이 필요합니다. 위의 "Lichess API 토큰" 필드에 토큰을 입력하세요.\n\nhttps://lichess.org/account/oauth/token에서 토큰을 생성할 수 있습니다.}
translate k LichessPlayerRequired {플레이어 데이터베이스의 Lichess 사용자 이름을 입력하세요.}
translate k LichessQuerying {Lichess가 탐색기를 여는 중입니다...}
translate k LichessFailedQuery {Lichess 오프닝 탐색기를 쿼리하지 못했습니다:\n%s}
translate k LichessPositionNotFound {%s 데이터베이스에서 위치를 찾을 수 없습니다.\n\n반환된 API:\n%s}
translate k LichessResultsTitle {Lichess 여는 탐색기 - %s 데이터베이스}
translate k LichessSummaryInfo {전체: %s개의 게임 |  백 승리: %s (%s%%) |  무승부: %s(%s%%) |  흑의 승리: %s(%s%%)}
translate k LichessNoGamesFound {이 포지션에 해당하는 게임을 찾을 수 없습니다.}
translate k LichessMoves {이동:}
translate k LichessColMove {이동하다}
translate k LichessColWhite {하얀색}
translate k LichessColDraws {무승부}
translate k LichessColBlack {검은색}
translate k LichessColTotal {총}
translate k LichessColWinPct {이기다%}
translate k LichessColAvgRating {평균 평점}
translate k LichessColECO {에코}
translate k LichessColOpening {열기}
translate k LichessTopGamesTitle {인기 게임:}
translate k LichessRecentGamesTitle {최근 게임:}
translate k LichessColWinner {우승자}
translate k LichessColWhiteRating {W.등급}
translate k LichessColBlackRating {B.등급}
translate k LichessColDate {날짜}
translate k LichessLoadGameConfirm {게임 %s 대 %s(ID: %s)을 클립베이스에 로드하시겠습니까?}
translate k LichessLoadGameTitle {게임 로드}
translate k LichessFetchGameFailed {%s 게임을 가져오지 못했습니다:\n%s}
translate k LichessGameNotFound {Lichess에서 %s 게임을 찾을 수 없습니다.}
translate k LichessImportFailed {게임을 가져오지 못했습니다:\n%s}
translate k LichessGameLoaded {게임이 클립베이스에 성공적으로 로드되었습니다.}
translate k Back {뒤로}
translate k Apply {적용하다}
translate k Browse {찾아보기}
translate k Cancel {취소}
translate k Continue {계속하다}
translate k Clear {지우기}
translate k Close {뭐}
translate k Contents {소모}
translate k Defaults {그랬어요}
translate k InvertSearch {검색 반전}
translate k Delete {삭제}
translate k Graph {그래프}
translate k Help {돕다}
translate k Hide {숨다}
translate k Import {가져오다}
translate k Index {색깔}
translate k LoadGame {게임로드}
translate k BrowseGame {게임 찾아보기}
translate k MergeGame {긴급 경기}
translate k MergeGames {긴급 경기}
translate k Preview {미리보기}
translate k Revert {되돌리기}
translate k Rename {이름이}
translate k Save {저장}
translate k Search {찾다}
translate k Stop {정지}
translate k Store {저장}
translate k Update {업데이트}
translate k ChangeOrient {창 변경}
translate k ShowIcons {아이콘 표시}
translate k None {없음}
translate k First {첫 번째}
translate k Current {현재의}
translate k Last {마지막}

# General messages:
translate k game {게임}
translate k games {게임}
translate k move {이동하다}
translate k moves {운동}
translate k all {모두}
translate k Yes {예}
translate k No {아니요}
translate k Both {둘 다}
translate k King {킹}
translate k Queen {퀸}
translate k Rook {룩}
translate k Bishop {비숍}
translate k Knight {나이트}
translate k Pawn {전화}
translate k White {백}
translate k Black {흑}
translate k Player {플레이어}
translate k Rating {평가}
translate k RatingDiff {등급 차이(백색 - 흑색)}
translate k AverageRating {평균적으로}
translate k Event {이벤트}
translate k Site {장소}
translate k Country {국가}
translate k IgnoreColors {색상을 무시하세요}
translate k Date {데이트}
translate k EventDate {행사 날짜}
translate k Decade {10년}
translate k Year {년도}
translate k Month {월}
translate k Months {1월 2월 3월 4월 5월 6월 7월 8월 9월 10월 11월 12월}
translate k Days {일월 화 수 목 금 토}
translate k YearToToday {-1년}
translate k YearToTodayTooltip {1년 전 오늘부터 데이트를 설정하세요.}
translate k Result {결과}
translate k Round {라운드}
translate k Length {길이}
translate k ECOCode {에코코드}
translate k ECO {에코}
translate k Deleted {삭제됨}
translate k SearchResults {검색결과}
translate k OpeningTheDatabase {데이터베이스}
translate k Database {변수}
translate k Filter {핀}
translate k noGames {게임 없음}
translate k allGames {모든 게임}
translate k empty {없어}
translate k clipbase {클립베이스}
translate k score {점수}
translate k StartPos {시작 위치}
translate k Total {총}
translate k readonly {인구의 승리}

# Standard error messages:
translate k ErrNotOpen {이는 공개 데이터베이스가 아닙니다.}
translate k ErrReadOnly {이 데이터베이스는 선두입니다. 대응할 수 없습니다.}
translate k ErrSearchInterrupted {중단되었습니다. 결과가 잘못되었습니다.}
translate k ErrNoClockComments {이 게임에는 [%clk] 시계 댓글이 없습니다.  이 기능을 사용하려면 설명 창(Ctrl+E)을 통해 감시 시간을 추가하세요.}
translate k ErrFileInUse {오류: 파일이 이미 사용 중입니다. 이 데이터베이스를 사용하는 다른 응용 프로그램을 따르세요. 프로그램이 종료되는 경우 데이터베이스와 연결된 .lock 파일을 삭제해야 할 수도 있습니다.}




# Game information:
translate k twin {예비}
translate k deleted {삭제됨}
translate k comment {평}
translate k hidden {숨겨진}
translate k LastMove {마지막 움직임}
translate k NextMove {다음}
translate k GameStart {게임 시작}
translate k LineStart {줄의 시작}
translate k GameEnd {게임 종료}
translate k LineEnd {줄 끝}

# Player information:
translate k PInfoAll {<b>모든</b> 게임에 대한 결과}
translate k PInfoFilter {<b>필터</b> 게임에 대한 결과}
translate k PInfoAgainst {향후 결과}
translate k PInfoMostWhite {흰색으로 재개 일반}
translate k PInfoMostBlack {블랙으로 가장 일반적인}
translate k PInfoRating {내역을 평가해}
translate k PInfoBio {전기}
translate k PInfoEditRatings {편집하다}
translate k PInfoEloFile {파일}

# Tablebase information:
translate k Draw {무승부}
translate k with {~와 함께}
translate k only {리니}
translate k lose {옷장}
translate k loses {옷장}

# Tip of the day:
translate k Tip {팁}
translate k TipAtStartup {시작 시 팁}
translate k TipConvertPGN {PGN 파일을 변환하면 더 나은 성능을 얻을 수 있습니다.}

# Tree window menus:
menuText k TreeFile "파일" 0
menuText k TreeFileFillWithBase "코스프레를 기록해 보세요." 0 {현재 원하는 모든 게임으로 캐시 파일을 채울 수 있습니다.}
menuText k TreeFileFillWithGame "게임으로 기록" 0 {현재 현재 게임으로 캐시 파일을 채집하고 있습니다.}
menuText k TreeFileSetCacheSize "사진 크기" 0 {캐시설정}
menuText k TreeFileCacheInfo "쿠키정보" 0 {센세이션에 대한 정보}
menuText k TreeFileSave "멕시코 파일 생성" 0 {트리멕시코(.stc) 파일 저장}
menuText k TreeFileFill "캐시 파일 기록" 0 \
  {세션 시작 위치로 기록 파일 기록}
menuText k TreeFileBest "최고의 게임 목록" 0 {최고의 나무 게임 목록표시}
menuText k TreeFileGraph "그래프 창" 0 {이 트리 분기에 대한 그래프 표시}
menuText k TreeFileCopy "트리를 클립보드로 복사" 1 \
  {트리 통계를 클립보드에 복사}
menuText k TreeFileClose "트리 창 닫기" 0 {트리 창 닫기}
menuText k TreeMask "마스크" 0
menuText k TreeMaskNew "새로운" 0 {새로운 마스크}
menuText k TreeMaskOpen "레스토랑이 있어요" 0 {마스크를 찾아오다}
menuText k TreeMaskOpenRecent "최근" 0 {최근 마스크}
menuText k TreeMaskSave "구하다" 0 {마스크 저장}
menuText k TreeMaskClose "뭐" 0 {마스크 닫기}
menuText k TreeMaskFillWithGame "게임으로 표시다" 0 {마스크를 게임으로 기록}
menuText k TreeMaskFillWithBase "사과로 기록" 0 {녹음에 있는 모든 게임에 기록을 남겨두세요}
menuText k TreeMaskInfo "정보" 0 {현재 마스크에 대한 통계 표시}
menuText k TreeMaskDisplay "마스크 마커 표시" 0 {마스크 데이터를 트리밍하여 표시}
menuText k TreeMaskSearch "찾다" 0 {현재 마스크에서 검색}
menuText k TreeSort "종류" 0
menuText k TreeSortAlpha "숫자순" 0
menuText k TreeSortECO "에코코드" 0
menuText k TreeSortFreq "그들" 0
menuText k TreeSortScore "점수" 0
menuText k TreeOpt "옵션" 0
menuText k TreeOptSlowmode "저속 모드" 0 {업데이트를 강화하는 방식(높은 자세)}
menuText k TreeOptFastmode "빠른 모드" 0 {업데이트를 빠른 편집할 수 있는 모드(이동 전치 없음)}
menuText k TreeOptFastAndSlowmode "빠른 속도감 있는 모드" 0 {빠른 모드, 업데이트를 수축하는 모드}
menuText k TreeOptStartStop "자동 새로고침" 0 {Tree Window의 자동 새로 고침을 전환합니다.}
menuText k TreeOptLock "잠그다" 0 {현재 데이터베이스에 대한 트리 잠금/잠금 해제}
menuText k TreeOptTraining "훈련" 0 {트리 훈련 모드기/끄기}
menuText k TreeOptDepth "치수 이동" 0 {트리에 표시할 반 이동 전화(1-4)}
menuText k TreeOptAutosave "자동 저장 파일" 0 \
  {나무 창을 닫을 때 XML 파일 자동 저장}
menuText k TreeHelp "돕다" 0
menuText k TreeHelpTree "나무 도움말" 0
menuText k TreeHelpIndex "도움말 색인" 0
translate k SaveCache {쿠키 저장}
translate k Training {훈련}
translate k LockTree {잠그다}
translate k TreeDepth {트리(반쯤 이동):}
translate k TreeLocked {잠긴}
translate k TreeBest {의}
translate k TreeBestGames {최고의 나무 게임}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate k TreeTitleRow \
  {이동 ECO 체력 AvElo Perf AvYear %무승부 %승리}
translate k TreeTotal {총}
translate k DoYouWantToSaveFirst {먼저 입력하시겠습니까?}
translate k AddToMask {마스크에 추가}
translate k RemoveFromMask {마스크에서 제거}
translate k AddThisMoveToMask {이 동작을 마스크에 추가하세요}
translate k SearchMask {마스크에서 검색}
translate k DisplayMask {경찰 마스크}
translate k Nag {잔소리 코드}
translate k Marker {채점자}
translate k Include {포함하다}
translate k Exclude {괜히 방해가 되네}
translate k MainLine {본선}
translate k Bookmark {서표}
translate k NewLine {새로운 라인}
translate k ToBeVerified {확인하기}
translate k ToTrain {훈련하다}
translate k Dubious {모호한}
translate k ToRemove {제거하려면}
translate k NoMarker {마커 없음}
translate k ColorMarker {색상}
translate k WhiteMark {하얀색}
translate k GreenMark {녹색}
translate k YellowMark {노란색}
translate k BlueMark {v}
translate k RedMark {옳다}
translate k CommentMove {댓글 이동}
translate k CommentPosition {댓글 위치}
translate k AddMoveToMaskFirst {먼저 마스크에 이동 추가}
translate k OpenAMaskFileFirst {먼저 마스크 파일을 시험해 보세요.}
translate k Positions {직위}
translate k Moves {이동}

# Finder window:
menuText k FinderFile "파일" 0
menuText k FinderFileSubdirs "하위권에서 보기" 0
menuText k FinderFileClose "파일 찾기" 0
menuText k FinderSort "종류" 0
menuText k FinderSortType "에" 0
menuText k FinderSortSize "크기" 0
menuText k FinderSortMod "수정됨" 0
menuText k FinderSortName "이름" 0
menuText k FinderSortPath "길" 0
menuText k FinderTypes "에" 0
menuText k FinderTypesScid "Scid 데이터베이스" 0
menuText k FinderTypesOld "이전 형식 Scid 데이터베이스" 0
menuText k FinderTypesPGN "PGN 파일" 0
menuText k FinderTypesEPD "EPD 파일" 0
menuText k FinderTypesRep "레퍼토리 파일" 0
menuText k FinderHelp "돕다" 0
menuText k FinderHelpFinder "파일 찾기 도움말" 0
menuText k FinderHelpIndex "도움말 색인" 0
translate k FileFinder {파일 찾기}
translate k FinderDir {가려서 규제하다}
translate k FinderDirs {의 출발}
translate k FinderFiles {파일}
translate k FinderUpDir {위로}
translate k FinderCtxOpen {레스토랑이 있어요}
translate k FinderCtxBackup {지원}
translate k FinderCtxCopy {복사}
translate k FinderCtxMove {이동하다}
translate k FinderCtxDelete {삭제}

# Player finder:
menuText k PListFile "파일" 0
menuText k PListFileUpdate "업데이트" 0
menuText k PListFileClose "플레이어 찾기" 0
menuText k PListSort "종류" 0
menuText k PListSortName "이름" 0
menuText k PListSortElo "엘로" 0
menuText k PListSortGames "계략" 0
menuText k PListSortOldest "가장 오래된" 0
menuText k PListSortNewest "최신" 2

# Tournament finder:
menuText k TmtFile "파일" 0
menuText k TmtFileUpdate "업데이트" 0
menuText k TmtFileClose "반대하다 찾기" 0
menuText k TmtSort "종류" 0
menuText k TmtSortDate "데이트" 0
menuText k TmtSortPlayers "플레이어" 0
menuText k TmtSortGames "계략" 0
menuText k TmtSortElo "엘로" 0
menuText k TmtSortSite "대지" 0
menuText k TmtSortEvent "이벤트" 1
menuText k TmtSortWinner "근로자" 0
translate k TmtLimit "목록 제한"
translate k TmtMeanElo "비열한 엘로"
translate k TmtNone "일치하는 것은 없습니다."

# Graph windows:
menuText k GraphFile "파일" 0
menuText k GraphFileColor "컬러 포스트후기 저장..." 8
menuText k GraphFileGrey "그레이스케일 포스트기록 저장..." 8
menuText k GraphFileClose "창 닫기" 6
menuText k GraphOptions "옵션" 0
menuText k GraphOptionsWhite "하얀색" 0
menuText k GraphOptionsBlack "검은색" 0
menuText k GraphOptionsBoth "둘 다" 1
menuText k GraphOptionsPInfo "플레이어 정보플레이어" 0
menuText k GraphOptionsEloFile "평가 파일의 Elo" 0
menuText k GraphOptionsEloDB "데이터베이스의 Elo" 0
translate k GraphFilterTitle "분석 그래프: 순위에 따른 게임의 형태"
translate k GraphAbsFilterTitle "필터 그래프: 게임용"
translate k GraphWinPctTitle "분석 그래프: 연도별 현재 위치에서 승률(1-0 및 0-1)"
translate k ConfigureFilter "연도, 등급 및 이동에 대한 X축 구성"
translate k FilterEstimate "최종"
translate k TitleFilterGraph "Scid: 그래프 분석"
translate k WinPct "기다립니다 %"

# Analysis window:
translate k AddVariation {변형 추가}
translate k AddAllVariations {모든 변형}
translate k AddMove {이동 추가}
translate k Annotate {달기}
translate k ShowAnalysisBoard {분석판표시}
translate k ShowInfo {엔진 정보 표시}
translate k FinishGame {게임 종료}
translate k StopEngine {엔진 정지}
translate k StartEngine {엔진의 변화}
translate k LockEngine {엔진을 현재 위치로 고정}
translate k AnalysisCommand {분석}
translate k PreviousChoices {이전 선택}
translate k AnnotateTime {이동당시간(초)}
translate k AnnotateWhich {변형 추가}
translate k AnnotateAll {측면으로 이동하는 경우}
translate k AnnotateAllMoves {모든 움직임에 대한 설명}
translate k AnnotateWhite {흰색 이동에만 해당}
translate k AnnotateBlack {검정색 이동에만 해당}
translate k AnnotateBlundersOnly {게임 이동이 연결된 경우}
translate k AnnotateBlundersOnlyScoreChange {설문조사에 오류가 발생하여 다음과 같이 변경되었습니다.}
translate k BlundersThreshold {경계점}
translate k ScoreAllMoves {모든 운동에 점수를 매기세요}
translate k LowPriority {CPU 우선순위}
translate k ClickHereToSeeMoves {동작을 실시간으로 여기를 클릭하세요}
translate k ConfigureInformant {제보자 가치}
translate k Informant!? {특히 운동}
translate k Informant? {운동하는}
translate k Informant?? {빅데이터}
translate k Informant?! {모호한 움직임}
translate k Informant+= {흰색이 유리함}
translate k Informant+/- {사실은 확실한 장점이 있습니다}
translate k Informant+- {이 결정적인 이점을 가지고 있습니다.}
translate k Informant+-- {유니폼에는 장점이 있습니다.}
translate k AutoComment {자동댓글}
translate k AutoCommentTooltip {현재 위치에 대한 AI 설명 생성}
translate k AnalysisAutoCommentTooltip {전체 게임에 대한 AI 설명 생성}
translate k GameComment {게임 코멘트}
translate k GameCommentTooltip {이를 찾기 위해 게임을 검사하고 AI 요약을 생성합니다.}
translate k TimeMs {시간(ms)}


# Book window
translate k Book {책}
translate k OtherBookMoves {반대의 책}
translate k OtherBookMovesTooltip {상대방이 대답장을 한 동작}

# Analysis Engine open dialog:
translate k EngineList {분석 엔진 목록}
translate k EngineName {이름}
translate k EngineCmd {컴파운드}
translate k EngineArgs {다양하게}
translate k EngineDir {가려서 규제하다}
translate k EngineElo {엘로}
translate k EngineTime {데이트}
translate k EngineNew {새로운}
translate k EngineEdit {편집하다}
translate k EngineRequired {항구의 필드는 필수입니다. 다른 것들은 선택 사항입니다}
translate k EngineProtocol {통신사}
translate k EngineNotation {운동의 표기}
translate k EngineFlipEvaluation {평가를 뒤집다}
translate k EngineShowLog {통신 로그인 표시}
translate k EngineNetworkd {원격 연결 제조업}
translate k EngineSelect {현재 엔진을 선택하세요}
translate k EngineAddLocal {위치 엔진 추가}
translate k EngineAddRemote {원격 엔진 추가}
translate k EngineReload {현재 엔진을 다시 로드합니다.}
translate k EngineClone {현재 엔진의 활동을 참여합니다.}
translate k EngineDelete {현재 엔진 삭제}

# PGN window menus:
menuText k PgnFile "파일" 0
menuText k PgnFileCopy "게임을 클립보드에 복사" 0
menuText k PgnFilePrint "파일로인쇄..." 0
menuText k PgnFileClose "PGN 창 닫기" 10
menuText k PgnOpt "표시하다" 0
menuText k PgnOptColor "컬러 디스플레이" 0
menuText k PgnOptShort "간략한(3줄) 헤더" 0
menuText k PgnOptSymbols "칙칙하다" 1
menuText k PgnOptIndentC "프레스 인쇄" 0
menuText k PgnOptIndentV "성형 변형" 7
menuText k PgnOptColumn "열 스타일(한 라인에 한 쪽으로 이동)" 1
menuText k PgnOptSpace "이동번호 뒤의 공백" 1
menuText k PgnOptStripMarks "컬러 바코드/화살표 코드 제거" 1
menuText k PgnOptBoldMainLine "메인 라인 이동에 대한 내용" 4
menuText k PgnColor "그림 물감" 0
menuText k PgnColorHeader "헤더..." 0
menuText k PgnColorAnno "이해가 안가..." 0
menuText k PgnColorComments "댓글..." 0
menuText k PgnColorVars "변형..." 0
menuText k PgnColorBackground "배경..." 0
menuText k PgnColorMain "메인라인..." 0
menuText k PgnColorCurrent "현재 이동 배경..." 1
menuText k PgnHelp "돕다" 0
menuText k PgnHelpPgn "PGN 도움말" 0
menuText k PgnHelpIndex "색깔" 0
translate k PgnWindowTitle {표법 - 게임%u}

# Crosstable window menus:
menuText k CrosstabFile "파일" 0
menuText k CrosstabFileText "텍스트 파일로 인쇄..." 9
menuText k CrosstabFileHtml "HTML 파일로인쇄..." 9
menuText k CrosstabFileClose "크로스테이블 창 닫기" 0
menuText k CrosstabEdit "편집하다" 0
menuText k CrosstabEditEvent "이벤트" 0
menuText k CrosstabEditSite "대지" 0
menuText k CrosstabEditDate "데이트" 0
menuText k CrosstabOpt "표시하다" 0
menuText k CrosstabOptAll "올 플레이 올" 0
menuText k CrosstabOptSwiss "스위스" 0
menuText k CrosstabOptKnockout "녹아웃" 0
menuText k CrosstabOptAuto "자동" 1
menuText k CrosstabOptAges "연도" 8
menuText k CrosstabOptNats "색채" 0
menuText k CrosstabOptRatings "평가" 0
menuText k CrosstabOptTitles "제목" 0
menuText k CrosstabOptBreaks "트리브레이크 점수" 4
menuText k CrosstabOptDeleted "삭제된 게임 포함" 8
menuText k CrosstabOptColors "색상(스위스테이블만 해당)" 0
menuText k CrosstabOptColumnNumbers "숫자가 매겨진 열(올 플레이 올테이블만 해당)" 2
menuText k CrosstabOptGroup "그룹 점수" 0
menuText k CrosstabSort "종류" 0
menuText k CrosstabSortName "이름" 0
menuText k CrosstabSortRating "평가" 0
menuText k CrosstabSortScore "점수" 0
menuText k CrosstabColor "색상" 0
menuText k CrosstabColorPlain "일반 내용" 0
menuText k CrosstabColorHyper "하이퍼텍스트" 0
menuText k CrosstabHelp "돕다" 0
menuText k CrosstabHelpCross "크로스테이블 도움말" 0
menuText k CrosstabHelpIndex "도움말 색인" 0
translate k SetFilter {필터 설정}
translate k AddToFilter {핀에 추가}
translate k Swiss {스위스}
translate k Category {유형}

# Opening report window menus:
menuText k OprepFile "파일" 0
menuText k OprepFileText "텍스트 파일로 인쇄..." 9
menuText k OprepFileHtml "HTML 파일로인쇄..." 9
menuText k OprepFileOptions "옵션..." 0
menuText k OprepFileClose "보상 창 닫기" 0
menuText k OprepFavorites "즐겨 찾기" 1
menuText k OprepFavoritesAdd "추가 답변..." 0
menuText k OprepFavoritesEdit "즐겨찾는 편집..." 0
menuText k OprepFavoritesGenerate "보상 생성..." 0
menuText k OprepHelp "돕다" 0
menuText k OprepHelpReport "견적상담" 0
menuText k OprepHelpIndex "도움말 색인" 0

# Header search:
translate k HeaderSearch {헤더검색}
translate k EndSideToMove {게임이 관련되는 쪽}
translate k GamesWithNoECO {ECO가 없는 게임?}
translate k GameLength {게임 길이}
translate k FindGamesWith {플래그가 있는 게임 찾기}
translate k StdStart {비표준 시작}
translate k Promotions {프로모션}
translate k Comments {댓글}
translate k Variations {변형}
translate k Annotations {해석하다}
translate k DeleteFlag {명령어 삭제}
translate k WhiteOpFlag {흰색으로 재개}
translate k BlackOpFlag {블랙 형식}
translate k MiddlegameFlag {간략한 게임}
translate k EndgameFlag {최종 결정}
translate k NoveltyFlag {징기함}
translate k PawnFlag {전화구조}
translate k TacticsFlag {전술}
translate k QsideFlag {퀸사이드 플레이}
translate k KsideFlag {킹사이드 플레이}
translate k BrilliancyFlag {광휘}
translate k BlunderFlag {빅데이터}
translate k UserFlag {사용자}
translate k PgnContains {PGN에 텍스트가 포함되어 있습니다.}
translate k PgnTag {꼬리표}
translate k TagContains {포함}
translate k Variant {변종}
translate k Annotator {자}
translate k Cmnts {해당 사건 관련 내용}

# Game list window:
translate k GlistNumber {숫자}
translate k GlistWhite {하얀색}
translate k GlistBlack {검은색}
translate k GlistWElo {W-엘로}
translate k GlistBElo {B-엘로}
translate k GlistEvent {이벤트}
translate k GlistSite {대지}
translate k GlistRound {탑}
translate k GlistDate {데이트}
translate k GlistYear {년도}
translate k GlistEDate {행사 날짜}
translate k GlistResult {결과}
translate k GlistLength {길이}
translate k GlistCountry {국가}
translate k GlistECO {에코}
translate k GlistOpening {당신에게}
translate k GlistEndMaterial {재료 최종 결정}
translate k GlistDeleted {삭제됨}
translate k GlistFlags {명칭}
translate k GlistVars {변형}
translate k GlistComments {댓글}
translate k GlistAnnos {해석하다}
translate k GlistStart {시작}
translate k GlistGameNumber {게임번호}
translate k GlistAverageElo {평균 엘로}
translate k GlistRating {평가}
translate k GlistFindText {찾기}
translate k GlistMoveField {이동하다}
translate k GlistEditField {구성}
translate k GlistAddField {추가하다}
translate k GlistDeleteField {제거하다}
translate k GlistWidth {나는}
translate k GlistAlign {맞추다}
translate k GlistAlignL {대신: 왼쪽}
translate k GlistAlignR {반대: 오른쪽}
translate k GlistAlignC {반대: 가운데}
translate k GlistColor {색상}
translate k GlistSep {구분}
translate k GlistCurrentSep {-- 현재의 --}
translate k GlistNewSort {새로운}
translate k GlistAddToSort {추가하다}

# base sorting
translate k GsortSort {일종의...}
translate k GsortDate {데이트}
translate k GsortYear {년도}
translate k GsortEvent {이벤트}
translate k GsortSite {대지}
translate k GsortRound {탑}
translate k GsortWhiteName {이름 흰색}
translate k GsortBlackName {블랙네임}
translate k GsortECO {에코}
translate k GsortResult {결과}
translate k GsortMoveCount {이동이 불편해요}
translate k GsortAverageElo {평균 엘로}
translate k GsortCountry {국가}
translate k GsortDeleted {삭제됨}
translate k GsortEventDate {행사 날짜}
translate k GsortWhiteElo {하얀 엘로}
translate k GsortBlackElo {블랙 엘로}
translate k GsortComments {댓글}
translate k GsortVariations {변형}
translate k GsortNAGs {잔소리}
translate k GsortAscending {오름차순}
translate k GsortDescending {내림차순}
translate k GsortAdd {추가하다}
translate k GsortStore {가게}
translate k GsortLoad {잼}

# menu shown with right mouse button down on game list.
translate k GlistRemoveThisGameFromFilter  {이 게임을 제거하세요}
translate k GlistRemoveGameAndAboveFromFilter  {게임에서(및 그 밖의 모든 것)를 제거합니다.}
translate k GlistRemoveGameAndBelowFromFilter  {게임(그리고 그 아래의 모든 항목)을 제거합니다.}
translate k GlistDeleteGame {(Un) 이 게임을 삭제하세요}
translate k GlistDeleteAllGames {필터에 있는 모든 게임 삭제}
translate k GlistUndeleteAllGames {핀의 모든 게임 삭제 취소}
translate k GlistMergeGameInBase {경기용 밸브}

# Maintenance window:
translate k DatabaseName {데이터베이스 이름:}
translate k TypeIcon {유형 아이콘:}
translate k NumOfGames {계략:}
translate k NumDeletedGames {삭제된 게임:}
translate k NumFilterGames {필터에 포함된 게임:}
translate k YearRange {연도 범위:}
translate k RatingRange {평가범위:}
translate k Description {설명}
translate k Flag {다음}
translate k CustomFlags {맞춤 표기}
translate k DeleteCurrent {현재 게임 삭제}
translate k DeleteFilter {핀 게임 삭제}
translate k DeleteAll {모든 게임 삭제}
translate k UndeleteCurrent {현재 게임 삭제 취소}
translate k UndeleteFilter {핀 게임 삭제 취소}
translate k UndeleteAll {모든 게임 삭제 취소}
translate k DeleteTwins {트윈 게임 삭제}
translate k MarkCurrent {현재 게임표시}
translate k MarkFilter {마크 핀 게임}
translate k MarkAll {모든 게임 표시}
translate k UnmarkCurrent {현재 게임플레이}
translate k UnmarkFilter {게임플레이를 떠나}
translate k UnmarkAll {모든 게임을 떠나세요}
translate k Spellchecking {맞춤법검사}
translate k Players {플레이어}
translate k Events {이벤트}
translate k Sites {사이트}
translate k Rounds {라운드}
translate k DatabaseOps {데이터베이스 작업}
translate k ReclassifyGames {ECO를 특별하게}
translate k CompactDatabase {기능성 데이터베이스}
translate k SortDatabase {데이터베이스 대신}
translate k AddEloRatings {Elo 추가 등급}
translate k AutoloadGame {게임번호 자동로드}
translate k StripTags {PGN 태그 제거}
translate k StripTag {스트립 태그}
translate k Cleaner {정원}
translate k CleanerHelp {Scid Cleaner는 현재 데이터베이스에 대해 아래 목록에서 제외됩니다. 모든 유지 관리 작업을 수행합니다.
해당 항목을 선택하면 ECO 분류 및 쌍둥이 삭제 대화 상자의 현재 기능 설정이 적용됩니다.}
translate k CleanerConfirm {Cleaner 유지 관리는 한 번만 시작하면 중단할 수 없습니다!

예외와 현재 설정에 따라 데이터베이스에서는 시간이 오래 걸릴 수 있습니다.

대신 유지 관리 기능을 시작하시겠습니까?}
# Twinchecker
translate k TwinCheckUndelete {뒤집다; "u"는 둘 다 삭제 취소합니다)}
translate k TwinCheckprevPair {이전 예비}
translate k TwinChecknextPair {다음다음}
translate k TwinChecker {Scid: 트윈 게임 체커}
translate k TwinCheckTournament {반대 게임:}
translate k TwinCheckNoTwin {트윈 없음}
translate k TwinCheckNoTwinfound {이 게임에서는 트윈 게임이 존재하지 않았습니다.\n이 창을 사용하여 트윈을 표시하지 않으면 먼저 "트윈 게임 삭제..." 기능을 전달했습니다.}
translate k TwinCheckTag {태그 공유...}
translate k TwinCheckFound1 {Scid가 $result 트윈 게임을 찾았습니다.}
translate k TwinCheckFound2 {삭제 등록을 설정합니다.}
translate k TwinCheckNoDelete {이 데이터베이스에는 중복 게임이 없습니다.}
translate k TwinCriteria1 {게임을 찾기 설정으로 인해 비슷한 동작을 하는 쌍둥이가 아닌 게임이 쌍둥이로 연결될 가능성이 높습니다.}
translate k TwinCriteria2 {"같은 동작"에 "아니오"를 선택했다면 색상, 이벤트, 사이트, 순환, 연도 및 월 설정에 "예"를 선택하는 것이었죠.\n계속해서 트윈을 삭제하여 Enter?}
translate k TwinCriteria3 {"동일 사이트", "동일 라운드" 및 "동일 연도" 설정 중 최소 2개에 대해 "예"를 경고하는 것이 좋습니다.\n그래도 계속해서 보안을 삭제하시겠습니까?}
translate k TwinCriteriaConfirm {Scid: 트윈 설정 확인}
translate k TwinChangeTag "다음 게임 태그를 변경하시기 바랍니다:\n\n"
translate k AllocRatingDescription "이 복합은 현재 맞춤법 검사 파일을 사용하여 이 데이터베이스의 게임에 Elo 등급을 추가합니다. 플레이어에게 현재 등급이 있는 경우에는 게임 등급이 맞춤법 검사 파일에 포함되는 경우 해당 등급이 추가됩니다."
translate k RatingOverride "0이 아닌 고유 등급 쓰기"
translate k AddRatings "향후 평가를 추가하세요:"
translate k AddedRatings {Scid는 $g 게임에 $r Elo 등급을 추가했습니다.}

#Bookmark editor
translate k NewSubmenu "새 하위 메뉴"

# Comment editor:
translate k AnnotationSymbols  {기호:}
translate k Comment {평:}
translate k InsertMark {삽입 마크}
translate k InsertMarkHelp {표시 삽입/제거: 색상, 표시, 사각형을 선택합니다.
삽입/제거 화살표: 두 개의 사각형을 마우스 오른쪽 버튼으로 클릭했습니다.}

# Nag buttons in comment editor:
translate k GoodMove {소나무}
translate k PoorMove {운동하는}
translate k ExcellentMove {훌륭한 움직임}
translate k Blunder {빅데이터}
translate k InterestingMove {특히 운동}
translate k DubiousMove {모호한 움직임}
translate k WhiteDecisiveAdvantage {이 결정적인 이점을 가지고 있습니다.}
translate k BlackDecisiveAdvantage {흑이 결정적인 우월성을 갖는다}
translate k WhiteClearAdvantage {사실은 확실한 장점이 있습니다}
translate k BlackClearAdvantage {검정색이 확실히 유리해요}
translate k WhiteSlightAdvantage {흰색이 유리함}
translate k BlackSlightAdvantage {검정색이 약간 유리함}
translate k WhiteCrushing {유니폼에는 장점이 있습니다.}
translate k BlackCrushing {검은색이 악마는 점하고 존재하지 않습니다}
translate k Equality {부품}
translate k Unclear {불명확}
translate k Diagram {그렇지}

# Board search:
translate k BoardSearch {보드 검색}
translate k FilterOperation {현재 핀에 대한 작업:}
translate k FilterAnd {AND(필터 제한)}
translate k FilterOr {또는(필터에 추가)}
translate k FilterIgnore {무시(필터링)}
translate k SearchType {검색방법:}
translate k SearchBoardExact {그렇지 않으면(모든 조각이 같은 자리에 있음)}
translate k SearchBoardPawns {휴대폰(동일한 재질, 일치하는 모든 휴대폰)}
translate k SearchBoardFiles {파일(동일한 자료, 동일한 파일의 모든 전화)}
translate k SearchBoardAny {모두(동일한 재질, 휴대폰 및 부품 어디에서나 가능)}
translate k SearchInRefDatabase {참고자료 데이터베이스에서 검색}
translate k LookInVars {다양한 변형 보기}

# Material search:
translate k MaterialSearch {자료검색}
translate k Material {재료}
translate k Patterns {패턴}
translate k Zero {영}
translate k Any {어느}
translate k CurrentBoard {현재 보드}
translate k CommonEndings {두 번째 끝}
translate k CommonPatterns {일반적인 패턴}
translate k MaterialDiff {위치 비교}
translate k squares {광장}
translate k SameColor {같은 색}
translate k OppColor {반대색}
translate k Either {어느 하나}
translate k MoveNumberRange {숫자 범위 이동}
translate k MatchForAtLeast {소소한 일치}
translate k HalfMoves {반만 외계인}

# Common endings in material search:
translate k EndingPawns {전화 끝}
translate k EndingRookVsPawns {루크대폰(들)}
translate k EndingRookPawnVsRook {루크와 전화 1개 대 루크}
translate k EndingRookPawnsVsRook {루크와 전화(들) 대 루크}
translate k EndingRooks {루크 대 루크 결말}
translate k EndingRooksPassedA {루크 대 루크는 휴대전화를 건네주고 끝이 났습니다.}
translate k EndingRooksDouble {더블 루크 결말}
translate k EndingBishops {비숍 대 비숍 결론}
translate k EndingBishopVsKnight {비숍 대댓글}
translate k EndingKnights {기사 대 기사 결론}
translate k EndingQueens {퀸 대 퀸 끝}
translate k EndingQueenPawnVsQueen {퀸과폰 1개 대 퀸}
translate k BishopPairVsKnightPair {비숍(Two Bishops) 대 투 나이츠(Two Knights) 미들게임}

# Common patterns in material search:
translate k PatternWhiteIQP {화이트 IQP}
translate k PatternWhiteIQPBreakE6 {화이트 IQP: d4-d5 브레이크 대 e6}
translate k PatternWhiteIQPBreakC6 {백색 IQP: d4-d5 중단 대 c6}
translate k PatternBlackIQP {블랙 IQP}
translate k PatternWhiteBlackIQP {화이트 IQP 대 블랙 IQP}
translate k PatternCoupleC3D4 {c3+d4 고립된 백인전화}
translate k PatternHangingC5D5 {c5 및 d5에 검은색 전화}
translate k PatternMaroczy {Maroczy Center(c4 및 e4에 폰 포함)}
translate k PatternRookSacC3 {c3의 루크 파워}
translate k PatternKc1Kg8 {O-O-O 대 O-O(Kc1 대 Kg8)}
translate k PatternKg1Kc8 {OO 대 O-O-O(Kg1 대 Kc8)}
translate k PatternLightFian {밝은 광장 피안체토(Bishop-g2 대 Bishop-b7)}
translate k PatternDarkFian {다크스퀘어 피안체토(Bishop-b2 vs. Bishop-g7)}
translate k PatternFourFian {네 명의 피안체토(b2,g2,b7,g7의 주교)}

# Game saving:
translate k Today {오늘}
translate k ClassifyGame {게임을 구분하다}

# Setup position:
translate k EmptyBoard {빈 보드}
translate k InitialBoard {초기 보드}
translate k SideToMove {이동면책}
translate k MoveNumber {번호 이동}
translate k Castling {캐슬링}
translate k EnPassantFile {엔파상 파일}
translate k ClearFen {펜 지우기}
translate k PasteFen {펜 코팅 배치기}

translate k SaveAndContinue {저장하고 계속하세요}
translate k DiscardChangesAndContinue {변경사항을 취소하고 계속하세요.}
translate k GoBack {돌아가기}

# Replace move dialog:
translate k ReplaceMove {이동 교체}
translate k AddNewVar {새로운 변형}
translate k NewMainLine {새로운 본선}
translate k ReplaceMoveMessage {여기 이미 이동 중입니다.

이를 교체하거나 그 이후의 모든 동작을 삭제하거나 새로운 변형으로 동작을 추가할 수 있습니다.

(옵션: 이동 메뉴에서 "이동 교체 전 확인" 옵션을 잠시 쉬고 나중에 이 메시지를 표시할 수 있습니다.)}

# Make database read-only dialog:
translate k ReadOnlyDialog {이 데이터베이스를 변경하면 변경되지 않습니다.
게임을 저장하거나 교체할 수 있으며 삭제된 플래그를 붙일 수 없습니다.
모든 것을 분류하거나 ECO를 분류하는 명령은 귀하입니다.

데이터베이스를 닫고 다시 열어서 쉽게 데이터베이스를 다시 만들 수 있을 것 같습니다.

정말로 이 데이터베이스를 읽으면서 작성할까요?}

# Clear game dialog:
translate k ClearGameDialog {이 게임이 변경되었습니다.

계속 진행하고 변경사항을 취소하시겠습니까?}

# Exit dialog:
translate k ExitDialog {정말 Scid를 종료할 수 있나요?}
translate k ExitUnsaved {다음 데이터베이스에는 저장되지 않은 작업 변경 사항이 있습니다. 지금 종료하면 이러한 변경 사항이 삭제되었습니다.}

# Import window:
translate k PasteCurrentGame {현재 게임 플레이스토어}
translate k ImportHelp1 {위 프레임에 PGN 형식의 게임을 입력하거나 공격을 입력하세요.}
translate k ImportHelp2 {게임을 가져오는 중 오류가 발생하면 여기에 표시됩니다.}
translate k OverwriteExistingMoves {생산 업무를 담당할 의향이 있나요?}

# ECO Browser:
translate k ECOAllSections {모든 ECO 섹션}
translate k ECOSection {ECO 섹션}
translate k ECOSummary {요약}
translate k ECOFrequency {다음으로 하위 그룹}

# Opening Report:
translate k OprepReportFor {보고대상}
translate k OprepTitle {가격}
translate k OprepReport {반대}
translate k OprepGenerated {창작자}
translate k OprepStatsHist {통계 및 역사}
translate k OprepStats {측정}
translate k OprepStatAll {모든 것을 다루는 게임}
translate k OprepStatBoth {두 다 평가됨}
translate k OprepStatSince {에서}
translate k OprepOldest {가장 오래된 게임}
translate k OprepNewest {최신 게임}
translate k OprepPopular {현재 인기}
translate k OprepFreqAll {모든 연도의 경우:}
translate k OprepFreq1   {오늘부터 1년동안:}
translate k OprepFreq5   {현재까지 5년동안:}
translate k OprepFreq10  {현재까지 10년 동안:}
translate k OprepEvery {%u 게임마다 한 쪽}
translate k OprepUp {모든 연도보다 %u%s 증가}
translate k OprepDown {모든 연도에서 %u%s 설명}
translate k OprepSame {몇 년 동안 없어졌어}
translate k OprepMostFrequent {가장 빈번한 플레이어}
translate k OprepMostFrequentOpponents {가장 자주 반대하는 상대}
translate k OprepRatingsPerf {평가 및 성과}
translate k OprepAvgPerf {양해해 주시기 바랍니다.}
translate k OprepWRating {하얀색}
translate k OprepBRating {블랙 등급}
translate k OprepWPerf {화이트 퍼포먼스}
translate k OprepBPerf {블랙 퍼포먼스}
translate k OprepHighRating {평균이 가장 높은 게임}
translate k OprepTrends {결과 동향}
translate k OprepResults {결과 길이 및}
translate k OprepLength {게임 길이}
translate k OprepFrequency {그들}
translate k OprepWWins {백의 승리:}
translate k OprepBWins {흑의 승리:}
translate k OprepDraws {무승부:}
translate k OprepWholeDB {전체 데이터베이스}
translate k OprepShortest {최단 승리}
translate k OprepMovesThemes {동작 및 테마}
translate k OprepMoveOrders {보고 위치에 도달한 이동버튼}
translate k OprepMoveOrdersOne \
  {이 위치에 도달한 이동 숫자는 단 하나뿐이었습니다.}
translate k OprepMoveOrdersAll \
  {이 위치에 도달한 %u개의 이동 주문이 확인되었습니다:}
translate k OprepMoveOrdersMany \
  {이 위치에 도달하는 이동 주문이 %u개 확인되었습니다. 상위 %u는 다음과 같습니다.}
translate k OprepMovesFrom {보고 위치에서 이동합니다.}
translate k OprepMostFrequentEcoCodes {가장 자주 사용되는 ECO 코드}
translate k OprepThemes {위치 테마}
translate k OprepThemeDescription {각 게임의 첫 번째 %u 동작의 테마}
translate k OprepThemeSameCastling {같은 쪽 캐슬링}
translate k OprepThemeOppCastling {형식}
translate k OprepThemeNoCastling {두 왕 모두 캐슬링되지 않음}
translate k OprepThemeKPawnStorm {킹사이드폰 스톰}
translate k OprepThemeQueenswap {퀸즈 교환}
translate k OprepThemeWIQP {흰색으로 확인되지 않은 여왕의 전화번호}
translate k OprepThemeBIQP {블랙색이 꺼진 여왕 전화}
translate k OprepThemeWP567 {5/6/7위 화이트폰}
translate k OprepThemeBP234 {2/3/4위 블랙폰}
translate k OprepThemeOpenCDE {c/d/e 파일 배송}
translate k OprepTheme1BishopPair {오직 비숍만 비교 가능합니다.}
translate k OprepEndgames {엔드게임}
translate k OprepReportGames {게임 처리}
translate k OprepAllGames    {모든 게임}
translate k OprepEndClass {각 게임 종료 시 자료}
translate k OprepTheoryTable {운동표}
translate k OprepTableComment {%u개의 최고 게임을 제작했습니다.}
translate k OprepExtraMoves {추가 메모가 테이블에서 이동합니다.}
translate k OprepMaxGames {이론 테이블의 최대 게임}
translate k OprepMergeMoves {긴장된 게임의 이동 제한}
translate k OprepMergeUnique {독립형 밸브}
translate k OprepViewHTML {HTML 보기}

# Player Report:
translate k PReportTitle {플레이어 관리}
translate k PReportColorWhite {흰색 조각으로}
translate k PReportColorBlack {검은색 조각으로}
translate k PReportMoves {%s 이후}
translate k PReportOpenings {재개}
translate k PReportClipbase {Clips베이스를 비우고 일치하는 게임을 여기에서 복사하세요.}

# Piece Tracker window:
translate k TrackerSelectSingle {마우스 왼쪽 버튼을 이 부분으로 설정합니다.}
translate k TrackerSelectPair {마우스가 왼쪽 버튼으로 표시됩니다. 오른쪽 버튼은 형제와 동일합니다.}
translate k TrackerSelectPawn {왼쪽 버튼은 이 전화기로 로그인됩니다. 오른쪽 버튼은 8개의 전화기를 모두 선택합니다.}
translate k TrackerStat {통계량}
translate k TrackerGames {반대로 이동하는 % 게임}
translate k TrackerTime {각 코너의 % 시간}
translate k TrackerMoves {이동}
translate k TrackerMovesStart {추적을 시작하려면 이동번호를 입력하세요.}
translate k TrackerMovesStop {추적을 종료해야 이동번호를 입력하세요.}

# Game selection dialogs:
translate k SelectAllGames {데이터베이스의 모든 게임}
translate k SelectFilterGames {채굴에 게임만 있음}
translate k SelectTournamentGames {현재 대결의 게임만}
translate k SelectOlderGames {오래된 게임만 가능}

# Delete Twins window:
translate k TwinsNote {좋아하는 사람이 되려면 두 개의 게임에 흥미를 갖는 두 명의 플레이어가 있어야 하며 기준에서 접근할 수 있습니다. 한쌍의 쌍이 발견되면 더 짧은 게임이 삭제됩니다. 힌트: 끌어오기를 도와주면서 삭제하기 전에 데이터베이스의 맞춤법을 검사하는 것이 좋습니다.}
translate k TwinsCriteria {기준: 트윈 게임에는 다음이 있어야 합니다.}
translate k TwinsWhich {어떤 활동인지 참여자}
translate k TwinsColors {같은 플레이어 색상}
translate k TwinsEvent {같은 이벤트}
translate k TwinsSite {같은 사이트}
translate k TwinsRound {같은 라운드}
translate k TwinsYear {같은 해}
translate k TwinsMonth {같은 달}
translate k TwinsDay {같은 날}
translate k TwinsResult {같은 결과}
translate k TwinsECO {같은 ECO 코드}
translate k TwinsMoves {같은 동작}
translate k TwinsPlayers {플레이어 이름 비교}
translate k TwinsPlayersExact {정확히 일치}
translate k TwinsPlayersPrefix {처음 4글자만}
translate k TwinsWhen {트윈삭제게임시}
translate k TwinsSkipShort {5 동작하는 모든 게임을 무시합니다.}
translate k TwinsUndelete {먼저 모든 게임 삭제 취소}
translate k TwinsSetFilter {삭제된 모든 트윈 게임에 대한 설정}
translate k TwinsComments {협력 댓글로 게임을 유지하세요}
translate k TwinsVars {변화 변형된 운영 유지}
translate k TwinsDeleteWhich {게임 삭제}
translate k TwinsDeleteShorter {게임 지하철}
translate k TwinsDeleteOlder {더 작은 게임 수}
translate k TwinsDeleteNewer {더 큰 게임 번호}
translate k TwinsDelete {게임 삭제}

# Name editor window:
translate k NameEditType {편집할 이름의 종류}
translate k NameEditSelect {편집할 게임}
translate k NameEditReplace {분리다}
translate k NameEditWith {~와 함께}
translate k NameEditMatches {찾기 항목: Ctrl+1~Ctrl+9를 입력 선택}

# Check games window:
translate k CheckGames {게임 확인}
translate k CheckGamesWhich {게임 확인}
translate k CheckAll {모든 게임}
translate k CheckSelectFilterGames {금융에는 게임만 있음}

# Classify window:
translate k Classify {하다}
translate k ClassifyWhich {ECO가 어떤 게임을 할 것인지}
translate k ClassifyAll {모든 게임(이전 ECO 코드 쓰기)}
translate k ClassifyYear {축하합니다 모든 게임}
translate k ClassifyMonth {달에 일어난 모든 게임}
translate k ClassifyNew {아직 ECO 코드가 없는 게임만 가능}
translate k ClassifyCodes {ECO 코드}
translate k ClassifyBasic {기본 코드만("B12", ...)}
translate k ClassifyExtended {Scid 확장자("B12j", ...)}
translate k ClassifyResult {ECO는 꼭: $result 게임이 업데이트되었습니다.}

# Compaction:
translate k NameFile {이름 파일}
translate k GameFile {게임 파일}
translate k Names {이름}
translate k Unused {미사용}
translate k SizeKb {크기(kb)}
translate k CurrentState {현재 상태}
translate k AfterCompaction {압축 후}
translate k CompactNames {압축 이름 파일}
translate k CompactGames {한정된 게임파일}
translate k NoUnusedNames "사용되지 않은 이름의 이름 파일은 이미 완전히 압축되었습니다."
translate k NoUnusedGames "파일은 이미 완전히 압축되었습니다."
translate k GameFileCompacted {데이터베이스용 파일이 압축되었습니다.}

# Sorting:
translate k SortCriteria {기준}
translate k AddCriteria {기준 추가}
translate k CommonSorts {일반적인 반대}
translate k Sort {종류}

# Exporting:
translate k AddToExistingFile {기존 파일에 추가}
translate k ExportComments {댓글로}
translate k ExportVariations {변형 가능}
translate k IndentComments {프레스 인쇄}
translate k IndentVariations {성형 변형}
translate k ExportColumnStyle {열 스타일(한 라인에 한 쪽으로 이동)}
translate k ExportSymbolStyle {스타일 설명:}
translate k ExportStripMarks {댓글에서 코너/화살표\n코드 제거}

# Goto game/move dialogs:
translate k LoadGameNumber {게임번호를 입력하세요:}
translate k GotoMoveNumber {이동번호로 이동:}

# Copy games dialog:
translate k CopyAllGames {모든 게임을 다음으로 복사합니다.}
translate k CopyGames {게임 복사}
translate k CopyConfirm {정말로 입력하세요?
 [::utils::thousands $nGamesToCopy] 부근의 게임입니다
 데이터베이스 "$fromName"에서
 데이터베이스 "$targetName"에?}
translate k CopyErr {게임을 복사할 수 없습니다}
translate k CopyErrSource {소스 데이터베이스}
translate k CopyErrTarget {대상 데이터베이스}
translate k CopyErrNoGames {채굴에는 게임이 없습니다}
translate k CopyErrReadOnly {알고있습니다}
translate k CopyErrNotOpen {이기적이지 않아요}

# Colors:
translate k LightSquares {의자}
translate k DarkSquares {어두운 의자}
translate k SelectedSquares {선택 코너}
translate k SuggestedSquares {제안된 이동 코너}
translate k WhitePieces {조각}
translate k BlackPieces {검은 조각}
translate k WhiteBorder {흰색}
translate k BlackBorder {검은색}

# Novelty window:
translate k FindNovelty {참신함 찾기}
translate k Novelty {징기함}
translate k NoveltyInterrupt {참신한 검색이 중단되었습니다.}
translate k NoveltyNone {이 게임에 대한 참신함을 찾을 수 없습니다.}
translate k NoveltyHelp {Scid는 제외나 ECO 회수 원본에서 찾을 수 없는 위치에 도달하는 현재 게임의 첫 번째 이동을 데이터베이스를 찾고 있습니다.}

# Sounds configuration:
translate k SoundsFolder {문자열 파일 폴더}
translate k SoundsFolderHelp {폴더에는 King.wav, a.wav, 1.wav 등의 파일이 포함되어야 합니다.}
translate k SoundsAnnounceOptions {공지사항 옵션 이동}
translate k SoundsAnnounceNew {새로운 움직임이 만들어 발표하세요.}
translate k SoundsMoveSoundOnly {소리만 이동(공지사항 문의)}
translate k SoundsAnnounceForward {앞으로 나아갈 수 있음을 알립니다.}
translate k SoundsAnnounceBack {후퇴하거나 한 곳으로 이동할 때 알림}
translate k SoundsSoundDisabled {Scid가 시작되었습니다. Snack 오디오 패키지를 찾을 수 있는 부품이 없습니다.\n사운드가 문의해 보세요.}

# Upgrading databases:
translate k Upgrading {업그레이드 중}
translate k ConfirmOpenNew {Scid 4에서 열 수 없는 이전 형식(Scid 3) 데이터베이스이지만 새 형식(Scid 4) 버전이 이미 생성되었습니다.

새로운 형식의 데이터베이스 버전을 제출하려고 합니까?}
translate k ConfirmUpgrade {이전 형식(Scid 3) 데이터베이스입니다. Scid 4에서 사용하려면 먼저 새로운 형식의 데이터베이스 버전을 생성해야 합니다.

업그레이드하면 새 버전의 데이터베이스가 생성되고 나면 원본 파일이 제거됩니다.

이 작업은 작업 시간이 할당될 수 있지만 한 번만 수행하면 됩니다. 너무 오래 걸리면 취소할 수 있습니다.

지금 이 데이터베이스를 추가하시겠습니까?}

# Recent files options:
translate k RecentFilesMenu {파일 메뉴의 최근 파일 수}
translate k RecentFilesExtra {추가 하위 메뉴의 최신 파일 수}

# My Player Names options:
translate k MyPlayerNamesDescription {아래에 선호하는 플레이어 이름 목록을 한 줄에 입력하세요. 애니메이션 캐릭터(예: 단일 경우의 문자 "?", 소속의 문자의 "*")가 해당됩니다.

목록에 플레이어가 있는 게임이 로드될 때마다 해당 플레이어의 관점에서 게임을 표시하기 위해 필요한 경우 기본 창 체스판이 회전합니다.}

#Coach
translate k showblunderexists {함께가 존재함을 보여라}
translate k showblundervalue {전투의 꼴을 보여줘}
translate k showscore {점수 표시}
translate k coachgame {코치게임}
translate k configurecoachgame {게임 전술 구성}
translate k configuregame {게임 구성}
translate k Phalanxengine {팔랑크스 엔진}
translate k Coachengine {코치 엔진}
translate k difficulty {어려움}
translate k hard {한}
translate k easy {쉬움}
translate k Playwith {함께 놀다}
translate k white {하얀색}
translate k black {검은색}
translate k both {둘 다}
translate k Play {놀다}
translate k Noblunder {ㅇ 없음}
translate k blunder {빅데이터}
translate k Noinfo {-- 정보 없음 --}
translate k PhalanxOrTogaMissing {Phalanx 또는 Toga를 찾을 수 없습니다.}
translate k moveblunderthreshold {손실이 다음보다 크면 이동은 선택입니다.}
translate k limitanalysis {엔진 분석 시간 제한}
translate k seconds {초}
translate k Abort {중단}
translate k Resume {재개하다}
translate k OutOfOpening {종료 종료}
translate k NotFollowedLine {당신은 선을 반대했습니다.}
translate k DoYouWantContinue {계속해서 입력하시겠습니까?}
translate k CoachIsWatching {코코가 지켜주고 있다}
translate k Ponder {군데없는 사고}
translate k LimitELO {ELO 강제 제한}
translate k DubiousMovePlayedTakeBack {의심스러운 움직임이 실행되었습니다. 다시 가져오시겠습니까?}
translate k WeakMovePlayedTakeBack {당신을 사용할 수 있었습니다. 뒤돌리시?}
translate k BadMovePlayedTakeBack {승인되지 않은 사용이 가능했습니다. 취소하시겠습니까?}
translate k Iresign {나는 사임한다}
translate k yourmoveisnotgood {네 말이 맞지 않아}
translate k EndOfVar {변형 끝}
translate k Openingtrainer {부활 트레이너}
translate k DisplayCM {대신할 수 있는 표시}
translate k DisplayCMValue {대신 이동 값 표시}
translate k DisplayOpeningStats {측정 표시}
translate k ShowReport {반대표시}
translate k NumberOfGoodMovesPlayed {좋은 움직임을 보여주어}
translate k NumberOfDubiousMovesPlayed {모호한 움직임이 재생되었습니다.}
translate k NumberOfMovesPlayedNotInRepertoire {레퍼토리에 없는 동작}
translate k NumberOfTimesPositionEncountered {시간 위치가 발생했습니다.}
translate k PlayerBestMove  {최고의 행동만 허용}
translate k OpponentBestMove {상대가 가장 좋을 것 같다}
translate k OnlyFlaggedLines {심판이 지정되었습니다}
translate k resetStats {통계 구성}
translate k Repertoiretrainingconfiguration {레퍼토리 훈련 구성}
translate k Loadingrepertoire {레퍼토리 로드 중}
translate k Movesloaded {로드된 동작}
translate k Repertoirenotfound {레퍼토리를 찾을 수 없습니다.}
translate k Openfirstrepertoirewithtype {먼저 오른쪽에 아이콘/유형이 있도록 레퍼토리 데이터베이스를 테스트합니다.}
translate k Movenotinrepertoire {레퍼토리에 포함되지 않은 동작}
translate k PositionsInRepertoire {레퍼토리 위치}
translate k PositionsNotPlayed {플레이하지 않은 곳}
translate k PositionsPlayed {플레이한}
translate k Success {성공}
translate k DubiousMoves {모호한 움직임}
translate k OutOfRepertoire {레퍼토리 외}
translate k ConfigureTactics {구성 전술}
translate k ResetScores {점수}
translate k LoadingBase {로드로드}
translate k Tactics {전술}
translate k ShowSolution {솔루션 표시}
translate k NextExercise {다음 운동}
translate k PrevExercise {이전 운동}
translate k StopTraining {훈련 중단}
translate k Next {다음}
translate k ResettingScore {점수}
translate k LoadingGame {게임 로드 중}
translate k MateFound {친구를 찾았습니다}
translate k BestSolutionNotFound {최고의 솔루션을 찾을 수 없습니다!}
translate k MateNotFound {메이트를 찾을 수 없습니다.}
translate k ShorterMateExists {더 짧은 메이트가 존재합니다.}
translate k ScorePlayed {플레이한 점수}
translate k Expected {예상되는}
translate k ChooseTrainingBase {리프 훈련 선택}
translate k Thinking {생각해요}
translate k AnalyzeDone {분석하기}
translate k WinWonGame {승리한게임}
translate k Lines {부분}
translate k ConfigureUCIengine {UCI 엔진 구성}
translate k SpecificOpening {특정개시}
translate k StartNewGame {새로운 게임 시작}
translate k FixedLevel {안정적인 레벨}
translate k Opening {당신에게}
translate k RandomLevel {레벨}
translate k StartFromCurrentPosition {현재 위치에서 시작}
translate k FixedDepth {고정된 크기}
translate k Nodes {구분}
translate k Depth {규모}
translate k Time {시간}
translate k SecondsPerMove {이동당 초}
translate k Engine {엔진}
translate k TimeMode {시간 모드}
translate k TimeBonus {시간 + 비싸}
translate k TimeMin {분}
translate k TimeSec {비서}
translate k AllExercisesDone {모든 운동을 다해}
translate k MoveOutOfBook {책외이동}
translate k LastBookMove {마지막 책 이동}
translate k AnnotateSeveralGames {실제 게임에서 게임으로:}
translate k FindOpeningErrors {찾을 수 없는 사람}
translate k MarkTacticalExercises {훈련 전술}
translate k UseBook {도서 이용}
translate k MultiPV {다양한 변형}
translate k Hash {임시 메모리}
translate k OwnBook {엔진북 사용}
translate k BookFile {복구북}
translate k AnnotateVariations {변형에 달기}
translate k ShortAnnotations {지하철}
translate k addAnnotatorTag {자 태그 표시}
translate k AddScoreToShortAnnotations {추가 점수를 찾았습니다}
translate k Export {다}
translate k BookPartiallyLoaded {책이 부분적으로 읽혔어요}
translate k Calvar {변형작업}
translate k ConfigureCalvar {구성}
# Opening names used in tacgame.tcl
translate k Reti {레티}
translate k English {한국어}
translate k d4Nf6Miscellaneous {1.d4 Nf6 기타}
translate k Trompowsky {트롬포스키}
translate k Budapest {찾아}
translate k OldIndian {인도}
translate k BenkoGambit {벤코 갬빗}
translate k ModernBenoni {요즘 베노니}
translate k DutchDefence {버려진 국방 국방}
translate k Scandinavian {스칸디나비아 사람}
translate k AlekhineDefence {알레킨 디펜스}
translate k Pirc {피르크}
translate k CaroKann {카로칸}
translate k CaroKannAdvance {카로칸 어드벤스}
translate k Sicilian {시칠리아 사람}
translate k SicilianAlapin {시칠리아 알라핀}
translate k SicilianClosed {시칠리아 공식}
translate k SicilianRauzer {시칠리아 아우저}
translate k SicilianDragon {시칠리아 드래곤}
translate k SicilianScheveningen {시칠리아 스헤베닝겐}
translate k SicilianNajdorf {시칠리아 나이도르프}
translate k OpenGame {오픈 게임}
translate k Vienna {처리}
translate k KingsGambit {왕의 계략}
translate k RussianGame {러시아 게임}
translate k ItalianTwoKnights {이탈리아/두 명의 기사}
translate k Spanish {스페인 사람}
translate k SpanishExchange {교환하다}
translate k SpanishOpen {스페인 오픈}
translate k SpanishClosed {지금 휴무}
translate k FrenchDefence {프랑스 국방}
translate k FrenchAdvance {프렌치 어드밴스}
translate k FrenchTarrasch {프렌치 타라쉬}
translate k FrenchWinawer {프렌치 위나워}
translate k FrenchExchange {포르투갈어 교환}
translate k QueensPawn {여왕의 전화}
translate k Slav {슬라브 사람}
translate k QGA {QGA}
translate k QGD {QGD}
translate k QGDExchange {QGD 거래소}
translate k SemiSlav {반슬라브어}
translate k QGDwithBg5 {Bg5를 사용하여 QGD}
translate k QGDOrthodox {QGD 정교회}
translate k Grunfeld {그륀펠트}
translate k GrunfeldExchange {그륀펠트 거래소}
translate k GrunfeldRussian {그륀펠트 런}
translate k Catalan {카탈로니아 사람}
translate k CatalanOpen {카탈로니아 오픈}
translate k CatalanClosed {카탈로니아어 기록}
translate k QueensIndian {여왕의 퀸}
translate k NimzoIndian {님조-인디언}
translate k NimzoIndianClassical {Nico-인영화}
translate k NimzoIndianRubinstein {Nim 조인시아 루빈스타인}
translate k KingsIndian {킹스 킹}
translate k KingsIndianSamisch {킹스 킹 새미쉬}
translate k KingsIndianMainLine {킹스 킹 본선}

# FICS
translate k ConfigureFics {FICS 구성}
translate k FICSGuest {게스트로 로그인}
translate k FICSServerPort {서버용}
translate k FICSServerAddress {IP 주소}
translate k FICSRefresh {새로 고치다}
translate k FICSTimesealPort {타임씰 포트}
translate k FICSSilence {콘솔 핀}
translate k FICSOffers {제안}
translate k FICSConsole {콘솔}
translate k FICSGames {계략}
translate k FICSUnobserve {감시 경기중지}
translate k FICSProfile {기록 및 프로필 표시}
translate k FICSRelayedGames {중계된 게임}
translate k FICSFindOpponent {상대 찾기}
translate k FICSTakeback {회수}
translate k FICSTakeback2 {회수 2}
translate k FICSInitTime {초기 시간(분)}
translate k FICSIncrement {증분(초)}
translate k FICSRatedGame {게임에 대한}
translate k FICSAutoColour {오토매틱}
translate k FICSManualConfirm {수동으로 확인}
translate k FICSFilterFormula {수식으로}
translate k FICSIssueSeek {이슈 탐색 중}
translate k FICSChallenge {반대하다}
translate k FICSAccept {당신은 동의합니까?}
translate k FICSDecline {설명}
translate k FICSColour {색상}
translate k FICSSend {보내다}
translate k FICSConnect {연결하다}
translate k FICSdefaultuservars {효과적으로 활용하기}
translate k FICSObserveconfirm {이벤트를 종료하시겠습니까?}
translate k FICSpremove {사전 이동 활성화}
translate k FICSObserve {관찰하다}
translate k FICSRatedGames {평가된 게임}
translate k FICSUnratedGames {등급이 없는 게임}
translate k FICSRated {등급}
translate k FICSUnrated {등급 없음}
translate k FICSRegisteredPlayer {등록된 플레이어만}
translate k FICSFreePlayer {무료 플레이어만 해당}
translate k FICSNetError {시스템 오류\연결은 불가능합니다.}
translate k OptionsFICS {FICS}
translate k FICSTerminalColor {단자 색상}
translate k FICSTextColor {텍스트 색상}

# Game review
translate k GameReview {게임평론}
translate k GameReviewTimeExtended {시간 연장}
translate k GameReviewMargin {범위범위}
translate k GameReviewAutoContinue {이동이 하면 자동으로 진행됩니다}
translate k GameReviewReCalculate {연장된 시간을 활용하라}
translate k GameReviewAnalyzingMovePlayedDuringTheGame {동작 중 동작에 대한 분석}
translate k GameReviewAnalyzingThePosition {위치 분석}
translate k GameReviewEnterYourMove {당신을 입력하세요}
translate k GameReviewCheckingYourMove {이동 확인 중}
translate k GameReviewYourMoveWasAnalyzed {당신의 움직임이 분석되었습니다}
translate k GameReviewYouPlayedSameMove {이와 동일한 동작을 수행했습니다.}
translate k GameReviewScoreOfYourMove {당신의 움직임의 점수}
translate k GameReviewGameMoveScore {게임이동점수}
translate k GameReviewEngineScore {엔진 점수}
translate k GameReviewYouPlayedLikeTheEngine {당신은 엔진만큼 잘 놀았어요}
translate k GameReviewNotEngineMoveButGoodMove {엔진 작동은 좋은 움직임입니다.}
translate k GameReviewMoveNotGood {이번 조치는 좋지 않아 점수가}
translate k GameReviewMovesPlayedLike {다음과 같은 동작}
translate k GameReviewMovesPlayedEngine {엔진처럼 움직이는 움직임}

# Correspondence Chess Dialogs:
translate k CCDlgCGeneraloptions {일반 옵션}
translate k CCDlgLoginName  {로그인 이름:}
translate k CCDlgPassword   {포스틱:}
translate k CCDlgShowPassword {포스틱 표시}

# Connect Hardware dialogs
translate k ExtHWConfigConnection {외부기기 구성}
translate k ExtHWPort {포트}
translate k ExtHWEngineCmd {엔진컴퓨터}
translate k ExtHWEngineParam {엔진별로 다양}
translate k ExtHWShowButton {버튼표시}
translate k ExtHWHardware {하드웨어}
translate k ExtHWNovag {노바그 시트린}
translate k ExtHWInputEngine {입력 엔진}
translate k ExtHWNoBoard {보드 없음}
translate k NovagReferee {심판하다}

# Input Engine dialogs
translate k IEConsole {입력 엔진 콘솔}
translate k IESending {이동 전송 대상}
translate k IESynchronise {키}
translate k IERotate  {회전}
translate k IEUnableToStart {엔진을 입력할 수 없습니다.}

# Calculation of Variations
translate k DoneWithPosition {위치 확인하기}

translate k Board {판자}
translate k showGameInfo {게임 정보 표시}
translate k autoResizeBoard {보드 자동 크기 조정}
translate k DockTop {맨 위로 이동}
translate k DockBottom {맨 아래로 이동}
translate k DockLeft {왼쪽으로 이동}
translate k DockRight {오른쪽으로 이동}
translate k Undock {도킹하다}

# Switcher window
translate k AboutDatabase {이 데이터베이스 정보}
translate k ChangeIcon {데이터베이스 아이콘을 선택하세요...}
translate k NewGameListWindow {새 게임 목록 창}
translate k LoadatStartup {시작 시 로드}

# Gamelist window
translate k ShowHideDB {데이터베이스 표시/숨기기}
translate k ChangeFilter {필터 변경}
translate k ChangeLayout {대신 기준 및 열 보기 로드/저장/변경}
translate k ShowHideStatistic {통계/숨기기}
translate k BoardFilter {현재 보드 위치와 일치하는 게임만 표시}
translate k CopyGameTo {게임을 다음으로 복사하기}
translate k FindBar {바 찾기}
translate k FindCurrentGame {현재 게임 찾기}
translate k DeleteGame {게임 삭제}
translate k UndeleteGame {게임 삭제 취소}
translate k ResetSort {대신에}
translate k LayoutExists {'%s'이(가) 이미 존재합니다.}
translate k ConfirmDeleteLayout {정말 '%s' 입력을 삭제하시겠습니까?}

translate k ConvertNullMove {null 이동을 댓글로 변환}
translate k SetupBoard {설정 보드}
translate k Rotate {회전}
translate k SwitchColors {색상 전환}
translate k FlipBoard {플립보드}
translate k ImportPGN {PGN 게임 가져오기}
translate k ImportingFiles {PGN 파일 가져오기}
translate k ImportingFrom {다음에서 가져오기}
translate k ImportingIn {게임 가져오기}
translate k UseLastTag {이름\n게임의 태그 사용}
translate k Random {종류의}
translate k BackToMainline {메인라인으로 복귀기}
translate k LeaveVariant {변형하기}
translate k Autoplay {자동재생}
translate k ShowHideCoords {사냥꾼표시/숨기기.}
translate k ShowHideEvalBar {평가표시줄표시/숨기기}
translate k ShowHideMaterial {재료표시/숨기기}
translate k SelectMarker {마커 선택}
translate k FullScreen {전체 화면}
translate k FilterStatistic {측정항목}
translate k MakeCorrections {수정하기}
translate k Surnames {성}
translate k Ambiguous {모호한}

#Preferences Dialog
translate k OptionsToolbar "도구바"
translate k OptionsBoard "체스판"
translate k OptionsBoardSize "보드 크기"
translate k OptionsBoardPieces "조각 스타일"
translate k OptionsInternationalization "국제화"
translate k OptionsTablebaseDir "최대 4개의 테이블 기본 폴더를 선택하세요."

# Evaluation bar
translate k BestMoveArrow "최고의 이동방향"
translate k NewLocalEngine "+ 새로운 엔진 ..."

# Batch Annotate
translate k BatchAnnotate {알아요 달기}
translate k BatchEngineSelection {엔진 선택}
translate k BatchChessEngine {체스 엔진:}
translate k BatchNumberOfInstances {대응할 수 있음:}
translate k BatchGameReview {게임평론}
translate k BatchTimePerMove {이동당 시간(초):}
translate k BatchAnnotateBlunders {길만으로 달기}
translate k BatchBlunderThreshold {적용 기준:}
translate k BatchVariationLength {변형길이(이동):}
translate k BatchOpeningBook {개막북}
translate k BatchUseBook {도서 이용}
translate k BatchAnnotateVariations {변형에 달기}
translate k BatchShortAnnotations {지하철}
translate k BatchAddScoreToShort {단기간에 점수 추가 확인}
translate k BatchClearOld {이전 댓글과 같은 콘텐츠 삭제}
translate k BatchInitializingEngines {엔진 기어 중...}
translate k BatchAnalyzingGames {경기 분석 중...}
translate k BatchProgress {치료를 진행하지 못함}
translate k BatchComplete {꼭꼭!}
translate k BatchCancelled {취소가 되었습니다.}
translate k BatchStart {시작}
translate k BatchCancel {취소}
translate k BatchCompleted {완전한}
translate k BatchGames {계략}
translate k BatchProcessed {처리됨}
}
# end of english.tcl
