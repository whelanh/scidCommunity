### francais.tcl:
#
# French language support for Scid.
# Translations contributed by:
# Gilles Maire, Vincent Serisier, Joel Rivat, Pascal Heisel,
# and Besoa Rabenasolo.

proc setLanguage_F {} {

# File menu:
menuText F File "Fichier" 0
menuText F FileNew "Nouvelle..." 0 {Créer une nouvelle base de données Scid}
menuText F FileOpen "Ouvrir..." 0 {Ouvrir une base de données Scid existante}
menuText F FileClose "Fermer" 0 {Fermer la base de données Scid active}
menuText F FileFinder "Explorer..." 0 {Ouvrir la fenêtre de recherche de fichier}
menuText F FileBookmarks "Signets" 0 {Menu des signets (raccourci: Ctrl+B)}
menuText F FileBookmarksAdd "Ajouter un signet" 0 \
  {Créer un signet pour la position et la partie actuelle}
menuText F FileBookmarksFile "Ajouter le signet dans un dossier..." 0 \
  {Créer un signet pour la position et la partie actuelle et le classer dans un menu}
menuText F FileBookmarksEdit "Modifier les signets..." 0 \
  {Ouvre la fenêtre de gestion des signets}
menuText F FileBookmarksList "Afficher les dossiers comme une simple liste" 0 \
  {Afficher les dossiers comme une simple liste et non comme des sous-menus}
menuText F FileBookmarksSub "Afficher les dossiers comme des sous-menus" 0 \
  {Afficher les dossiers comme des sous-menus et non comme une simple liste}
menuText F FileMaint "Maintenance" 0 {Maintenance de la base}
menuText F FileMaintWin "Fenêtre de maintenance" 0 \
  {Ouvrir/Fermer la fenêtre de maintenance}
menuText F FileMaintCompact "Compacter la base..." 0 \
  {Compacter la base: supprimer les parties effacées et les noms non utilisés}
menuText F FileMaintClass "Calculer le code ECO des parties" 1 \
  {Recalculer le code ECO de toutes les parties}
menuText F FileMaintSort "Trier la base..." 0 {Trier toutes les parties de la base}
menuText F FileMaintDelete "Supprimer les doublons" 0 \
  {Trouver les parties en doublons et les marquer pour l'effacement}
menuText F FileMaintTwin "Trouver les doublons" 0 \
  {Ouvrir/Actualiser la fenêtre de recherche de doublons}
menuText F FileMaintName "Orthographe des noms" 0 \
  {Correction orthographiques des noms et du classement Elo}
menuText F FileMaintNameEditor "Éditeur de noms" 1 {Ouvrir/Fermer l'éditeur de noms}
menuText F FileMaintNamePlayer "Corriger les noms de joueurs..." 21 \
  {Vérifier l'orthographe des noms de joueurs}
menuText F FileMaintNameEvent "Corriger les événements..." 14 \
  {Vérifier l'orthographe des noms d'événements}
menuText F FileMaintNameSite "Corriger les noms de lieux..." 21 \
  {Vérifier l'orthographe des noms de lieux}
menuText F FileMaintNameRound "Corriger les noms des rondes..." 22 \
  {Vérifier l'orthographe des noms de rondes}
menuText F FileReadOnly "Lecture seule..." 0 \
  {Traiter la base courante en lecture seule, en empêchant les changements}
menuText F FileSwitch "Changer de base" 0 \
  {Changer vers une base ouverte différente}
menuText F FileOpenLichessTournament "Ouvrir un tournoi Lichess" 0 {Télécharger et ouvrir les parties en direct d'un tournoi Lichess}
menuText F FileImportLichess "Importer mes parties Lichess" 0 {Importer des parties depuis votre compte Lichess}
menuText F FileImportChessCom "Importer mes parties Chess.com" 0 {Importer des parties depuis votre compte Chess.com}
menuText F FileExit "Quitter" 0 {Quitter Scid}
menuText F FileMaintFixBase "Réparer base" 0 {Essaie de réparer une base corrompue}

# Edit menu:
menuText F Edit "Édition" 1
menuText F EditAdd "Ajouter une variante" 0 {Ajouter une variante}
menuText F EditDelete "Effacer cette variante" 0 {Effacer cette variante}
menuText F EditFirst "Déplacer en tête" 0 \
  {Déplacer cette variante en tête de liste des variantes}
menuText F EditMain "Variante vers ligne principale" 13 \
   {Promouvoir une variante en ligne principale}
menuText F EditStrip "Supprimer" 1 {Supprimer les commentaires ou les variantes de cette partie}
menuText F EditUndo "Annuler" 0 {Annuler la dernière modification de cette partie}
menuText F EditRedo "Rétablir" 0 {Rétablir la dernière modification de cette partie}
menuText F EditStripComments "Commentaires" 0 \
  {Supprimer tous les commentaires et annotations de cette partie}
menuText F EditStripCommentsNotAnnos "Commentaires, sauf les annotations" 0 \
  {Supprimer tous les commentaires de cette partie, mais conserver les annotations (NAGs)}
menuText F EditStripVars "Variantes" 0 {Supprimer toutes les variantes de cette partie}
menuText F EditStripAll "Commentaires et variantes" 0 \
  {Supprimer tous les commentaires, annotations et variantes de cette partie}
menuText F EditStripBegin "Coups depuis le début" 1 \
  {Supprimer tous les coups de cette partie depuis le début}
menuText F EditStripEnd "Coups jusqu'à la fin" 0 \
  {Supprimer tous les coups de cette partie jusqu’à la fin}
menuText F EditReset "Vider la Clipbase" 0 {Vider la base de données Clipbase}
menuText F EditCopy "Copier dans la Clipbase" 19 \
  {Copier la partie en cours dans la base de données Clipbase}
menuText F EditPaste "Coller depuis la Clipbase" 19 \
  {Copier la partie contenue dans la base Clipbase à cet emplacement}
menuText F EditPastePGN "Coller le presse-papier comme partie PGN..." 1 \
  {Interpréter le texte du presse-papier comme de la notation PGN et le coller comme partie active}
menuText F EditNullMove "Déplacement nul" 0 {Insérer un coup nul (sauter un coup)}
menuText F EditSetup "Définir la position de départ" 0 \
  {Choisir une position de départ pour cette partie}
menuText F EditCopyBoard "Copier la position" 10 \
  {Copier la position en cours en notation FEN vers la sélection de texte (presse-papier)}
menuText F EditPasteBoard "Coller la position de départ" 12 \
  {Initialiser la position de départ à partir de la sélection de texte courante (presse-papier)}
menuText F ConfigureScid "Préférences..." 1 {Configurer toutes les options pour SCID}

# Game menu:
menuText F Game "Partie" 0
menuText F GameNew "Nouvelle partie" 2 \
  {Remettre à zéro la partie}
menuText F GameFirst "Charger la première partie" 4 {Charger la première partie du filtre}
menuText F GamePrev "Partie précédente" 7 \
  {Charger la partie précédente du filtre}
menuText F GameReload "Recharger la partie" 2 \
  {Recharger la partie (les modifications ne seront pas sauvegardées)}
menuText F GameNext "Partie suivante" 7 {Charger la partie suivante du filtre}
menuText F GameLast "Charger la dernière partie" 5 {Charger la dernière partie du filtre}
menuText F GameRandom "Charger une partie au hasard" 1 {Charger au hasard une partie du filtre}
menuText F GameNumber "Partie numéro..." 9 \
  {Charger une partie en donnant son numéro}
menuText F GameReplace "Enregistrer: remplacer la partie..." 13 \
  {Enregistrer cette partie, en écrasant l'ancienne version}
menuText F GameAdd "Enregistrer: ajouter nouvelle partie..." 13 \
  {Enregistrer cette partie en tant que nouvelle partie dans la base}
menuText F GameDelete "Supprimer la partie" 0 {Activer/désactiver le drapeau de suppression de la partie en cours}
menuText F GameDeepest "Identifier l'ouverture" 13 \
  {Trouver la position la plus profonde qui est dans la nomenclature ECO}
menuText F GameGotoMove "Aller au coup numéro..." 14 \
  {Aller au coup spécifié dans la partie en cours}
menuText F GameNovelty "Trouver la nouveauté..." 4 \
  {Trouver le premier coup de la partie qui n'a pas été joué auparavant}
menuText F PlayTournament "Jouer au tournoi..." 0 \
    {Lancer un tournoi de moteur}

# Search Menu:
menuText F Search "Rechercher" 0
menuText F SearchReset "Réinitialiser le filtre" 0 \
  {Remettre à zéro le filtre (inclure toutes les parties)}
menuText F SearchNegate "Inverser le filtre" 0 \
  {Inverser le filtre}
menuText F SearchCurrent "Position..." 0 \
  {Rechercher selon la position actuelle}
menuText F SearchHeader "En-tête..." 0 \
  {Rechercher par information dans l'en-tête (joueur, tournoi, etc.)}
menuText F SearchMaterial "Matériel ou motif..." 0 \
  {Rechercher un motif ou un matériel particulier sur l'échiquier}
menuText F SearchMoves "Coups" 0 {Rechercher une séquence de coups dans la ligne principale}
menuText F SearchCQL "CQL..." 0 {Rechercher avec une requête Chess Query Language}
menuText F SearchComments "Rechercher des commentaires..." 0 {Rechercher les commentaires des jeux dans le filtre actuel}
menuText F SearchUsing "En utilisant un fichier d'options..." 3 \
  {Rechercher dans les commentaires des parties dans le filtre actuel}

# Windows menu:
menuText F Windows "Fenêtres" 1
menuText F WindowsComment "Éditeur de commentaires" 1 \
  {Ouvrir/fermer l'éditeur de commentaires}
menuText F WindowsGList "Liste des parties" 0 \
  {Ouvrir/fermer la liste des parties}
menuText F WindowsPGN "Fenêtre PGN" 8 {Ouvrir/fermer la fenêtre PGN}
menuText F WindowsPList "Chercher un joueur" 12 {Ouvrir/fermer la fenêtre de recherche de joueurs}
menuText F WindowsTmt "Chercher un tournoi" 12 {Ouvrir/fermer la fenêtre de recherche de tournois}
menuText F WindowsSwitcher "Changer de base" 0 \
  {Ouvrir/fermer l'outil de changement de base}
menuText F WindowsMaint "Fenêtre de Maintenance" 0 \
  {Ouvrir/fermer la fenêtre de maintenance}
menuText F WindowsECO "Navigateur ECO" 0 {Ouvrir/fermer le navigateur ECO}
menuText F WindowsStats "Statistiques des parties filtrées" 0 \
  {Ouvrir/fermer la fenêtre des statistiques des parties filtrées}
menuText F WindowsTree "Fenêtre d'arbre" 10 \
  {Ouvrir/fermer la fenêtre d'arbre}
menuText F WindowsBook "Bibliothèque d'ouvertures" 0 {Ouvrir/Fermer la bibliothèque d'ouverture}
menuText F WindowsCorrChess "Jeu par correspondance" 0 {Ouvrir/Fermer la fenêtre de jeu par correspondance}
menuText F WindowsGraph "Graphique d'analyse" 0 {Ouvre la fenêtre Graphique avec les temps et évaluations des mouvements}
menuText F WindowsPresentationBoard "Tableau de présentation" 0 {Ouvrir/fermer une fenêtre contenant uniquement un échiquier qui suit l’échiquier principal, pour un projecteur ou un deuxième écran}
menuText F WindowsPresentationFreeze "Tableau de présentation gelé" 0 {Arrêtez/reprenez le tableau de présentation afin que le jeu puisse être parcouru sans que le public ne le voie}
translate F PresentationFrozen {Gelé - le tableau de présentation ne suit pas}

menuText F WindowsEPD "Fenêtre EPD..." 0 {Ouvrir une fenêtre d'éditeur EPD (fichier de position)}

# EPD window:
translate F EpdPasteAnal {Coller l’analyse}
translate F EpdSortOpcodes {Trier les codes d'opération}
translate F EpdAddPosition {Ajouter une position}
translate F EpdFindPos {Trouver une position dans le jeu}
translate F EpdAnalPosition {Analyser les positions...}
translate F EpdStripOpcodes {Supprimer les opcodes...}
translate F EpdAnnotateTime {Secondes par position}
translate F EpdCountBestMoves {Comptez les meilleurs coups}
translate F EpdSaveLog {Enregistrer les résultats dans un fichier}
# EPD headless analysis: status text and the reasons the session reports.
# The EpdEngine* strings are fragments shown after the "%s" above them.
translate F EpdAnalysisTitle {Analyse EPD}
translate F EpdAnalysisRunning {Une autre analyse EPD est déjà en cours.}
translate F EpdAnalysisMinTime {Le temps d'analyse doit être d'au moins 1 seconde.}
translate F EpdAnalysisStartFailed {Échec du démarrage du moteur d'analyse : %s}
translate F EpdAnalysisError {Erreur d'analyse EPD : %s}
translate F EpdAnalysisStopped {L'analyse s'est arrêtée.}
translate F EpdAnalysisStopping {Arrêt...}
translate F EpdEngineNotStarted {le moteur n'a pas lancé la recherche}
translate F EpdEngineNoResult {le moteur n'a donné aucun résultat}
translate F EpdSearchAlreadyRunning {une recherche est déjà en cours}
translate F EpdNoEngineConfigured {aucun moteur n'est configuré}
translate F EpdOnlyUci {Seuls les moteurs UCI pris en charge}
translate F EpdEngineDisconnected {le moteur s’est déconnecté}
translate F EpdEngineNoAnswer {le moteur n'a pas répondu}
translate F EpdDontSave {Ne pas sauvegarder}
translate F EpdReadOnly {en lecture seule}
translate F EpdAltered {modifié}
translate F EpdNoMoves {aucun mouvement}
translate F positions {positions}
translate F EpdDeleteRow {Supprimer la ligne}
translate F EpdCloseWarning {Ce fichier EPD a été modifié.\nVoulez-vous le sauvegarder ?}
translate F EpdDeletePosition {Supprimer la position}
translate F EpdCopyRecord {Copier l'enregistrement}
translate F EpdPasteRecord {Coller l'enregistrement}

# Tools menu:
menuText F Tools "Outils" 2
menuText F ToolsConfigureEngines "Configurer les moteurs" 10 {Gérer la configuration des moteurs}
menuText F ToolsEngineWindow "Fenêtre moteur...." 0 {Ouvrir une fenêtre de moteur d'échecs}
menuText F ToolsCross "Classement du tournoi" 9 \
  {Montrer le classement du tournoi}
menuText F ToolsFilterGraph "Graphique (pourcentage)" 6 {Ouvrir/Fermer la fenêtre du graphique de filtre (en valeur absolue)}
menuText F ToolsAbsFilterGraph "Graphique (valeur absolue)" 7 {Ouvrir/Fermer la fenêtre du graphique de filtre (en valeur absolue)}
menuText F ToolsOpReport "Rapport d'ouverture" 0 {Générer un rapport d'ouvertures à partir de la position courante}
menuText F ToolsOpenBaseAsTree "Ouvrir une base comme arbre" 11 {Ouvrir une base dans la fenêtre d'arbre}
menuText F ToolsOpenRecentBaseAsTree "Ouvrir une base récente comme arbre" 3 {Ouvrir une base récente dans la fenêtre d'arbre}
menuText F ToolsTracker "Suivi de pièce"  3 {Ouvrir la fenêtre de suivi de pièce}
menuText F ToolsTraining "Entraînement"  0 {Entraînement (tactique, ouvertures, ...) }
menuText F ToolsPlayVsEngine "Jouer contre un moteur"  0 {Jouez à une partie contre un moteur d'échecs}
menuText F ToolsTrainOpenings "Ouvertures"  0 {S’entraîner avec un répertoire d'ouvertures}
menuText F ToolsTrainTactics "Exercices tactiques"  0 {Résoudre des problèmes tactiques}
menuText F ToolsTrainFindBestMove "Trouver le meilleur coup"  0 {Trouver le meilleur coup}
menuText F ToolsTrainFics "Jouer sur internet"  10 {Jouer sur freechess.org}
menuText F ToolsEngineTournament "Tournoi de moteurs"  0 {Démarrer un tournoi entre moteurs d'échecs}
menuText F ToolsTimeAnalysis "Analyse du temps" 0 {Afficher le graphique de la pendule de la partie en cours}
menuText F ToolsBookTuning "Config. Livre" 0 {Configuration fine d'un livre}
menuText F ToolsCtgConvert "Convertir CTG en OBR..." 0 {Convertir un livre ChessBase CTG en un livre OpenBook Rich (.obr)}
menuText F ToolsRapidAnnotate "Annoter à partir du graphique de score" 0 {Écrivez les évaluations et les annotations du graphique de score du moteur dans la partie en cours (Ctrl+Maj+A)}
menuText F ToolsDownloadTWIC "Télécharger les parties TWIC" 0 {Télécharger les dernières parties The Week In Chess (TWIC)}
menuText F ToolsConnectHardware "Connecter du matériel" 2 {Connecter un échiquier externe}
menuText F ToolsConnectHardwareConfigure "Configurer..." 0 {Configurer la connexion avec un échiquier externe}
menuText F ToolsConnectHardwareNovagCitrineConnect "Connecter Novag Citrine" 2 {Connecter Novag Citrine}
menuText F ToolsConnectHardwareInputEngineConnect "Connecter via Input Engine" 1 {Connecter via le protocole Input Engine (par ex. un échiquier DGT)}

menuText F ToolsPInfo "Information sur les joueurs"  0 \
  {Ouvrir/Mettre à jour la fenêtre d'information sur les joueurs}
menuText F ToolsPlayerReport "Rapport sur le joueur..." 2 \
  {Générer un rapport pour le joueur}
menuText F ToolsRating "Graphique Elo" 10 \
  {Tracer un graphique du classement Elo des joueurs de cette partie}
menuText F ToolsExpCurrent "Exporter la partie en cours" 1 \
  {Exporter la partie en cours dans un fichier texte}
menuText F ToolsExpCurrentPGN "Dans un fichier PGN..." 16 \
  {Exporter la partie en cours dans un fichier PGN}
menuText F ToolsExpCurrentHTML "Dans un fichier HTML..." 16 \
  {Exporter la partie en cours dans un fichier HTML}
menuText F ToolsExpCurrentHTMLJS "Dans un fichier HTML et JavaScript..." 24 {Exporter la partie en cours dans un fichier HTML et JavaScript}
menuText F ToolsExpCurrentRTF "Exporter la partie vers un fichier RTF..." 0 \
  {Exporter la partie actuelle dans un fichier RTF en préservant le formatage des commentaires}
menuText F ToolsExpFilter "Exporter les parties filtrées" 0
menuText F ToolsExpFilterPGN "Dans un fichier PGN..." 16 \
  {Exporter les parties filtrées dans un fichier PGN}
menuText F ToolsExpFilterHTML "Dans un fichier HTML..." 16 \
  {Exporter les parties filtrées dans un fichier HTML}
menuText F ToolsExpFilterHTMLJS "Dans un fichier HTML et JavaScript..." 24 {Exporter les parties filtrées dans un fichier HTML et JavaScript}
menuText F ToolsExpFilterRTF "Dans un fichier RTF..." 13 \
  {Exporter les parties filtrées dans un fichier RTF en préservant le formatage des commentaires}
menuText F ToolsImportOne "Importer une partie en PGN..." 0 \
  {Importer une partie à partir d'un fichier PGN}
menuText F ToolsImportFile "Importer des fichiers PGN..." 0 \
  {Importer des parties à partir d'un ou plusieurs fichiers PGN}
menuText F FileImportRTF "Importer une partie en RTF..." 0 \
  {Importer une partie à partir d’un fichier RTF}
menuText F ToolsStartEngine1 "Démarrer moteur 1" 16  {Démarrer moteur 1}
menuText F ToolsStartEngine2 "Démarrer moteur 2" 16  {Démarrer moteur 2}
menuText F ToolsCaptureBoard "Capture d’écran" 0  {Faire une capture d’écran de la position actuelle de l’échiquier}

# Play menu
menuText F Play "Jouer" 0
menuText F LichessPuzzles "Tactiques de Lichess" 0 {Résoudre les puzzles tactiques de Lichess de manière interactive}
menuText F Woodpecker "Méthode Woodpecker" 0 {Entraînement à la résolution de tactiques par répétition : résoudre le même ensemble de plus en plus vite}

# --- Correspondence Chess
menuText F CCResign "Abandonner" 1 {Abandonner (par Xfcc)}
menuText F CCClaimDraw "Réclamer la partie nulle" 3 {Envoyer le coup et réclamer une partie nulle (par Xfcc)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText F Options "Options" 0
menuText F OptionsBoardGraphics "Cases" 0 {Sélectionner les textures des cases}
translate F OptionsBGW {Sélectionner les textures des cases}
translate F OptionsBoardGraphicsText {Sélection des images pour les cases blanches et noires:}
menuText F OptionsBoardNames "Mes noms de joueurs..." 0 {Éditer mes noms de joueurs}
menuText F OptionsExport "Exportation" 1 {Changer les options d'exportation}
menuText F OptionsExportPGNText "Texte du fichier PGN" 0
menuText F OptionsExportHTMLText "Texte du fichier HTML" 0
menuText F OptionsFonts "Polices" 0 {Changer les polices}
menuText F OptionsFontsRegular "Normales" 0 {Changer les polices normales}
menuText F OptionsFontsMenu "Menu" 0 {Changer la police des menus}
menuText F OptionsFontsSmall "Petites" 0 {Changer les petites polices}
menuText F OptionsFontsTiny "Minuscule" 1 {Changer les polices minuscules}
menuText F OptionsFontsFixed "Fixe" 0 {Changer les polices de chasse fixe}
menuText F OptionsGInfo "Informations de la partie" 7 {Options d'information de la partie}
menuText F OptionsLanguage "Langue" 0 {Sélectionner la langue utilisée}
menuText F OptionsMovesTranslatePieces "Traduction des notations de pièces" 0 {Convertir la première lettre des noms des pièces en français}
menuText F OptionsMovesHighlightLastMove "Surbrillance dernier coup" 2 {Mettre le dernier coup en surbrillance}
menuText F OptionsMovesHighlightLastMoveDisplay "Afficher Cases" 0 {Afficher en surbrillance les cases du dernier coup}
menuText F OptionsMovesHighlightLastMoveWidth "Epaisseur" 0 {Epaisseur de la ligne}
menuText F OptionsMovesHighlightLastMoveColor "Couleur" 0 {Couleur de la ligne}
menuText F OptionsMovesHighlightLastMoveArrow "Afficher Flèche" 0 {Afficher la flèche de déplacement du dernier coup}
menuText F OptionsMovesHighlightLastMoveNag "Afficher les symboles d'annotation" 0
menuText F OptionsMovesHighlightLastMoveEval "Afficher les symboles d'évaluation" 0
menuText F OptionsMoves "Coups" 2 {Gestion de l’entrée des coups}
menuText F OptionsGamelist "Liste des parties" 0 {Options de la liste des parties}
menuText F OptionsMovesAnimate "Temps d'animation" 1 \
  {Régler le temps utilisé pour l'animation des coups}
menuText F OptionsMovesDelay "Délai entre les coups" 3 \
  {Régler le délai entre deux coups en mode automatique}
menuText F OptionsMovesCoord "Saisie de coordonnées" 0 \
  {Accepter l'entrée des coups par coordonnées ("g1f3")}
menuText F OptionsMovesSuggest "Montrer les coups suggérés" 0 \
  {Activer/Désactiver le mode de suggestion de coup}
menuText F OptionsShowVarPopup "Montrer fenêtre des variantes" 1 {Affichage automatique le sélecteur de variantes}
menuText F OptionsRepetitionAlert "Alertes de répétition" 0 {Comment annoncer une répétition de position}
menuText F OptionsRepetitionOff "Désactivé" 0 {N'annoncez pas les répétitions}
menuText F OptionsRepetitionBanner "Bannière" 0 {Afficher une bannière non bloquante qui s'efface d'elle-même}
menuText F OptionsRepetitionDialog "Boîte de dialogue" 0 {Afficher une boîte de dialogue qui doit être fermée}
translate F RepetitionTwice {Répétition 2 fois}
translate F RepetitionThreefold {Nulle - Répétition 3 fois}
menuText F OptionsMovesSpace "Ajouter un espace après le n° du coup" 1 {Ajouter un espace après le numéro du coup}
menuText F OptionsMovesLichess "Format Lichess/ChessBase pour les annotations" 0 {Utiliser le format Lichess/ChessBase pour les marqueurs et flèches}
menuText F OptionsMovesKey "Auto-complétion clavier" 1 \
  {Activer/Désactiver le mode d'auto-complétion du clavier}
menuText F OptionsMovesShowVarArrows "Montrer flèches pour les variantes" 2 {Montrer des flèches pour les prochains coups des variantes existantes}
menuText F OptionsMovesShowEngineVariationArrows "Afficher les flèches pour les variantes du moteur" 0 {Activer/désactiver les flèches montrant les lignes de variation du moteur en mode multiPV}
menuText F OptionsMovesGlossOfDanger "Coloration des cases attaquées" 0 {Afficher/Cacher la coloration des cases attaquées}
translate F OptionsGlistWheelRows {Rangées par encoche de roue}
translate F OptionsMovesTreeDepth {Profondeur de coup de la fenêtre d'arborescence par défaut}
translate F OptionsMovesEnginePvLength {Longueur d'affichage PV du moteur}
translate F OptionsMovesEngineHistory {Afficher l'historique de recherche du moteur}
menuText F OptionsNumbers "Format numérique" 7 {Sélectionner le format des nombres}
menuText F OptionsTheme "Apparence" 0 {Change l'apparence de l'interface}
menuText F OptionsWindows "Fenêtres" 0 {Options des fenêtres}
menuText F OptionsSounds "Sons" 2 {Configurer l'annonce des sonore des coups}
menuText F OptionsResources "Ressources..." 0 {Choisir les fichiers et dossiers de ressources}
menuText F OptionsWindowsDock "Fenêtres groupées" 0 {Fenêtres groupées (nécessite un redémarrage)}
menuText F OptionsWindowsSaveLayout "Enregistrer disposition" 0 {Enregistrer disposition}
menuText F OptionsWindowsRestoreLayout "Restaurer disposition" 0 {Restaurer disposition}
menuText F OptionsLayoutDefault "1 (par défaut)" 0
menuText F OptionsWindowsShowGameInfo "Montrer le panneau d'info" 0 {Montrer le panneau d'information}
menuText F OptionsWindowsAutoLoadLayout "Chargement auto 1ère disposition" 0 {Chargement auto de la première disposition au démarrage}
menuText F OptionsECO "Charger un fichier ECO" 19 \
  {Charger un fichier au format ECO}
menuText F OptionsSpell "Charger un fichier d'orthographe" 21 \
  {Charger un fichier de correction orthographique scid}
menuText F OptionsTable "Répertoire des tables de finales" 5 \
  {Sélectionner un répertoire de fichiers, tous les fichiers de ce répertoire seront utilisés}
menuText F OptionsRecent "Fichiers récents..." 1 \
  {Changer le nombre de fichiers récents affichés dans le menu Fichier}
menuText F OptionsBooksDir "Répertoire des bibliothèques" 15 {Répertoire des bibliothèques d'ouverture}
menuText F OptionsTacticsBasesDir "Répertoire des bases d'entraînement" 11 {Répertoire des bases pour l'entraînement tactique}
menuText F OptionsPhotosDir "Répertoire des images" 16 {Répertoire des bases pour les images}
menuText F OptionsThemeDir "Charger thème(s)"  0 { Charger un fichier de thèmes pour l'interface graphique }
translate F OptionsThemeOmarchy {Suivre le thème Omarchie}
menuText F OptionsSave "Enregistrer les options" 0 "Enregistrer les options dans le fichier $::optionsFile"
menuText F OptionsAutoSave "Sauvegarde automatique des options" 0 \
  {Sauvegarder automatiquement toutes les options en quittant Scid}

# Help menu:
menuText F Help "Aide" 0
menuText F HelpContents "Contenu" 0 {Montrer la page du contenu de l'aide}
menuText F HelpIndex "Index" 0 {Afficher la table des matières}
menuText F HelpGuide "Aide Rapide" 5 {Montrer la page d'aide rapide}
menuText F HelpHints "Astuces" 0 {Afficher les trucs et astuces}
menuText F HelpContact "Contact" 1 {Afficher les noms des contacts}
menuText F HelpTip "Astuce du jour" 1 {Afficher une astuce Scid}
menuText F HelpStartup "Fenêtre de démarrage" 0 {Afficher la fenêtre de démarrage}
menuText F HelpAbout "À propos de scidCommunity" 2 {Informations au sujet de scidCommunity}
menuText F UpdateCheck "Vérifier les mises à jour" 0 {Rechercher une nouvelle version de scidCommunity}
translate F UpdateChecking "Vérification des mises à jour..."
translate F UpdateUpToDate "Vous utilisez la dernière version de scidCommunity (%s)."
translate F UpdateAvailable "Une nouvelle version de scidCommunity est disponible : %s\n\nVous utilisez actuellement %s."
translate F UpdateDownloadInstall "Télécharger et installer"
translate F UpdateViewRelease "Afficher les notes de version"
translate F UpdateNotNow "Pas maintenant"
translate F UpdateCheckFailed "scidCommunity n'a pas pu vérifier les mises à jour. Veuillez vérifier votre connexion Internet et réessayer."
translate F UpdateInstallConfirm "scidCommunity %s sera téléchargé et installé.\n\nscidCommunity se fermera une fois le téléchargement terminé, puis exécutera le programme d'installation."
translate F UpdateDownloading "Téléchargement de scidCommunity %s..."
translate F UpdateDownloaded "Téléchargé %s"
translate F UpdateDownloadFailed "Le téléchargement de la mise à jour a échoué. Veuillez réessayer plus tard."

# Toolbar tooltips:
menuText F RotateBoard "Faire pivoter l’échiquier" 0 {Faire pivoter l’échiquier}

# Game info box popup menu:
menuText F GInfoHideNext "Cacher le coup suivant" 0
menuText F GInfoMaterial "Montrer les valeurs de matériel" 0
menuText F GInfoFEN "Montrer la notation FEN" 5
menuText F GInfoMarks "Montrer les cases colorées et les flèches" 5
menuText F GInfoWrap "Découper les longues lignes" 0
menuText F GInfoFullComment "Montrer tous les commentaires" 10
menuText F GInfoPhotos "Montrer les photos" 5
menuText F GInfoTBNothing "Tables de finales: Rien" 12
menuText F GInfoTBResult "Tables de finales: Seulement le résultat" 12
menuText F GInfoTBAll "Tables de finales: Résultat et meilleurs coups" 38
menuText F GInfoDelete "Restaurer/Supprimer cette partie" 3
menuText F GInfoMark "(Dé)Marquer cette partie" 4
menuText F GInfoInformant "Configurer les valeurs de notation" 0

# General buttons:
translate F LichessOpenExplore {Lichess OpenExplore}
translate F LichessTitle {Explorateur d'ouverture de Lichess}
translate F LichessApiTokenReq {Jeton API Lichess (obligatoire) :}
translate F LichessDatabase {Base de données :}
translate F LichessMasters {Maîtres}
translate F LichessGames {Parties de Lichess}
translate F LichessPlayer {Joueur}
translate F LichessNumMoves {Nombre de coups :}
translate F LichessTopGames {Meilleurs jeux :}
translate F LichessRecentGames {Jeux récents :}
translate F LichessSinceYear {Depuis l'année :}
translate F LichessUntilYear {Jusqu'à l'année :}
translate F LichessSinceMonth {Depuis (AAAA-MM) :}
translate F LichessUntilMonth {Jusqu'au (AAAA-MM) :}
translate F LichessTimeControls {Contrôle de temps}
translate F LichessRatingGroups {Groupes de classement}
translate F LichessPlayerName {Nom d'utilisateur du joueur :}
translate F LichessPlayerColor {Couleur du joueur :}
translate F LichessWhite {Blanc}
translate F LichessBlack {Noir}
translate F LichessGameModes {Modes de jeu}
translate F LichessRated {Noté}
translate F LichessCasual {Occasionnel}
translate F LichessTokenRequired {Un jeton API Lichess est requis.\n\nDepuis mars 2026, Lichess nécessite un jeton API pour accéder à l'explorateur d'ouverture. Veuillez saisir votre jeton dans le champ "Jeton API Lichess" ci-dessus.\n\nVous pouvez créer un jeton sur : https://lichess.org/account/oauth/token}
translate F LichessPlayerRequired {Veuillez saisir un nom d'utilisateur Lichess pour la base de données Player.}
translate F LichessQuerying {Interrogation de l'explorateur d'ouverture de Lichess...}
translate F LichessFailedQuery {Échec de l'interrogation de l'explorateur d'ouverture Lichess :\n%s}
translate F LichessPositionNotFound {Position introuvable dans la base de données %s.\n\nL'API a renvoyé :\n%s}
translate F LichessResultsTitle {Explorateur d'ouverture de Lichess - Base de données %s}
translate F LichessSummaryInfo {Total : %s jeux |  Les blancs gagnent : %s (%s%%) |  Nulles : %s (%s%%) |  Les Noirs gagnent : %s (%s%%)}
translate F LichessNoGamesFound {Aucun jeu trouvé pour cette position.}
translate F LichessMoves {Coups :}
translate F LichessColMove {Coup}
translate F LichessColWhite {Blanc}
translate F LichessColDraws {Nulles}
translate F LichessColBlack {Noir}
translate F LichessColTotal {Total}
translate F LichessColWinPct {Gagner%}
translate F LichessColAvgRating {Classement moyen}
translate F LichessColECO {ECO}
translate F LichessColOpening {Ouverture}
translate F LichessTopGamesTitle {Meilleures parties}
translate F LichessRecentGamesTitle {Parties récentes}
translate F LichessColWinner {Gagnant}
translate F LichessColWhiteRating {Classement B.}
translate F LichessColBlackRating {Classement N.}
translate F LichessColDate {Date}
translate F LichessLoadGameConfirm {Charger la partie %s contre %s (ID : %s) dans la clipbase ?}
translate F LichessLoadGameTitle {Charger la partie}
translate F LichessFetchGameFailed {Échec de la récupération de la partie %s :\n%s}
translate F LichessGameNotFound {Partie %s introuvable sur Lichess.}
translate F LichessImportFailed {Échec de l'importation de la partie :\n%s}
translate F LichessGameLoaded {Partie chargée avec succès dans clipbase.}

# Lichess Puzzles
translate F LichessPuzzlesTitle {Tactiques de Lichess}
translate F LichessPuzzlesDailyTitle {Tactique du jour}
translate F LichessPuzzlesQuerying {Interrogation des tactiques de Lichess...}
translate F LichessPuzzlesFailed {Échec de l'interrogation des tactiques Lichess :\n%s}
translate F LichessPuzzlesParseError {Échec du chargement de la position de la tactique}
translate F LichessPuzzlesLoadError {Échec du chargement de la position du puzzle}
translate F LichessPuzzlesSolve {À votre tour ! Trouvez le meilleur coup.}
translate F LichessPuzzlesCorrect {Bon coup !}
translate F LichessPuzzlesWrong {Ce n'est pas la bonne solution : essayez autre chose.}
translate F LichessPuzzlesBestMove {Meilleur coup !  Continuez...}
translate F LichessPuzzlesSolved {Tactique résolue ! Félicitations!}
translate F LichessPuzzlesPlaying {Résoudre une tactique…}
translate F LichessPuzzlesStop {Arrêter}
translate F LichessPuzzlesNew {Nouvelle tactique}
translate F LichessPuzzlesHint {Obtenez un indice}
translate F LichessPuzzlesViewSolution {Voir la solution}
translate F LichessPuzzlesHintMsg {Regardez la pièce sur %s.}
translate F LichessPuzzlesSolutionMsg {Solution :\n%s}
translate F LichessPuzzlesDifficulty {Difficulté:}
translate F LichessPuzzlesDiffEasiest {Le plus facile}
translate F LichessPuzzlesDiffEasier {Plus facile}
translate F LichessPuzzlesDiffNormal {Normal}
translate F LichessPuzzlesDiffHarder {Plus difficile}
translate F LichessPuzzlesDiffHardest {Le plus difficile}
translate F LichessPuzzlesColor {Jouez les :}
translate F LichessPuzzlesNextColor {Couleur de la tactique suivante :}
translate F LichessPuzzlesSideToMove {Couleur à jouer :}
translate F LichessPuzzlesSolvedTitle {Énigme résolue !}
translate F LichessPuzzlesTheme {Thème:}
translate F LichessPuzzlesMix {Mélange}
translate F LichessPuzzlesId {Identifiant de la tactique}
translate F LichessPuzzlesPlays {Coups}
translate F LichessPuzzlesThemes {Thèmes}
translate F LichessPuzzlesPerf {Type}
translate F LichessPuzzlesClock {Pendule}
translate F LichessPuzzlesRated {Classé}
translate F LichessPuzzlesGame {Partie}
translate F LichessPuzzlesNoNew {Aucune nouvelle tactique trouvée pour ces paramètres.\n\nEssayez de modifier le thème, la difficulté ou la couleur de l'énigme.}
# Woodpecker Method trainer (tcl/tools/woodpecker_ui.tcl)
translate F WoodpeckerTitle {Méthode Woodpecker}
translate F WoodpeckerColName {Ensemble}
translate F WoodpeckerColExercises {Exercices}
translate F WoodpeckerColCycle {Cycle}
translate F WoodpeckerColProgress {Ce cycle}
translate F WoodpeckerColLast {Dernière séance}
translate F WoodpeckerColDays {Jours}
translate F WoodpeckerColTime {Temps de résolution}
translate F WoodpeckerColResults {résolu/échoué}
translate F WoodpeckerColPct {Score}
translate F WoodpeckerColDate {Date}
translate F WoodpeckerColDuration {Durée}
translate F WoodpeckerColPoints {Points}
translate F WoodpeckerNew {Nouvel ensemble...}
translate F WoodpeckerOpenDatabase {Ouvrir la base de données de puzzles}
translate F WoodpeckerTrain {S’entraîner}
translate F WoodpeckerEvaluate {Évaluer...}
translate F WoodpeckerStats {Statistiques}
translate F WoodpeckerDelete {Supprimer}
translate F WoodpeckerContinue {Continuer (Entrer)}
translate F WoodpeckerSessionOptions {Session}
translate F WoodpeckerAutoPause {Pause après chaque exercice}
translate F WoodpeckerNoIdlePause {Ne faites pas de pause lorsque vous êtes inactif (l'horloge continue de fonctionner)}
translate F WoodpeckerPausedAfter {Pause après l'exercice. Parcourez la solution, puis appuyez sur Continuer (Entrée).}
translate F WoodpeckerPause {Pause}
translate F WoodpeckerResume {Reprendre}
translate F WoodpeckerEnd {Fin de séance}
translate F WoodpeckerNoSets {Pas encore d’ensemble de tactiques : appuyez sur Nouveau jeu pour commencer avec les puzzles inclus avec Scid, pour en télécharger davantage depuis Lichess ou pour utiliser un livre PGN.}
translate F WoodpeckerUnrated {%d sur %d exercices n'ont pas ! / !! notes : évaluez l'ensemble pour gagner ces bonus (les sessions précédentes sont également notées).}
translate F WoodpeckerCycleOver {Le cycle %d est terminé. Reposez-vous jusqu'à %s, puis le cycle suivant commence, avec la moitié des jours.}
translate F WoodpeckerCycleLine {Cycle %d : %d/%d réalisé, %d jours prévus, date limite %s.}
translate F WoodpeckerQuotaLine {Aujourd'hui : %d sur %d exercices.}
translate F WoodpeckerQuotaRaised {Vous êtes un peu en retard : l'objectif du jour est %d au lieu de %d.}
translate F WoodpeckerDeadlineMoved {Après la pause, le délai a été déplacé de %d jours, à %s ; l'objectif quotidien est de %d.}
translate F WoodpeckerOverStretch {Le cycle a atteint le double de la durée prévue : la date limite reste à %s et l'objectif quotidien est de %d.}
translate F WoodpeckerDeleteAsk {Supprimer l'ensemble "%s" avec sa base de données et ses statistiques ?}
translate F WoodpeckerNewTitle {Nouvel ensemble Woodpecker}
translate F WoodpeckerName {Nom}
translate F WoodpeckerFromLichess {Tactiques de Lichess}
translate F WoodpeckerFromPuzzles {Tactiques incluses avec Scid (puzzles classés de Lichess)}
translate F WoodpeckerAdvanced {Avancé}
translate F WoodpeckerUseLichess {Obtenez des puzzles de Lichess au lieu des ensembles inclus}
translate F WoodpeckerPicking {Choisir les tactiques…}
translate F WoodpeckerShortAsk {Seuls %d des %d puzzles demandés restent à votre niveau parmi ceux inclus avec Scid.\n\nTélécharger l'autre %d depuis Lichess ?\n\nNon : l’ensemble est créé avec les tactiques trouvées.}
translate F WoodpeckerNoPuzzles {Aucune tactique ne reste pour ce niveau, ce thème et cette couleur.}
translate F WoodpeckerCount {Exercices}
translate F WoodpeckerDifficulty {Difficulté}
translate F WoodpeckerTheme {Thème}
translate F WoodpeckerThemeMix {Mixte (recommandé)}
translate F WoodpeckerColor {Côté}
translate F WoodpeckerColor_both {Les deux}
translate F WoodpeckerColor_white {Blanc}
translate F WoodpeckerColor_black {Noir}
translate F WoodpeckerToken {Jeton Lichess}
translate F WoodpeckerFromFile {Base de données PGN ou Scid (par exemple un livre)}
translate F WoodpeckerFileHelp {Chaque partie qui part d'une position établie devient un exercice : son fil conducteur est la solution, les variantes sont ignorées. Celui de l'auteur ! et !! sont conservés.}
translate F WoodpeckerDays1 {Premier cycle (jours)}
translate F WoodpeckerRestDays {Repos entre les cycles (jours)}
translate F WoodpeckerDaysHelp {Chaque cycle ultérieur reçoit la moitié des jours du précédent : l'objectif est de réduire de moitié le temps de résolution à chaque cycle.}
translate F WoodpeckerCreate {Créer}
translate F WoodpeckerBadNumber {Numéro non valide : %s}
translate F WoodpeckerNoDifficulty {Choisissez au moins une difficulté et un certain nombre d'exercices.}
translate F WoodpeckerDownloading {Téléchargement de tactiques depuis Lichess...}
translate F WoodpeckerBuilding {Construire la base de données de l'ensemble...}
translate F WoodpeckerCreateFailed {L'ensemble n'a pas pu être créé :
%s}
translate F WoodpeckerCreated {Ensemble créé : %d exercices.}
translate F WoodpeckerFewer {Lichess a donné %d des %d tactiques demandées.}
translate F WoodpeckerNoFile {Impossible de lire %s}
translate F WoodpeckerSkipped {%d parties ont été sautées (pas de position de préparation ou aucun mouvement).}
translate F WoodpeckerMarksIncluded {Les mouvements clés ! et !! sont déjà marqués, vous pouvez donc commencer. Vous pouvez toujours évaluer l'ensemble avec votre propre moteur depuis son menu.}
translate F WoodpeckerEvalRecommended {L'évaluer maintenant avec l'examen ? Fortement recommandé : il marque les mouvements clés ! et !!, qui rapportent des points bonus. Cela prend environ une seconde par exercice et peut également être effectué plus tard.}
translate F WoodpeckerLevel_easiest {Le plus simple}
translate F WoodpeckerLevel_easier {Plus facile}
translate F WoodpeckerLevel_normal {Normal}
translate F WoodpeckerLevel_harder {Plus dur}
translate F WoodpeckerLevel_hardest {Le plus dur}
translate F WoodpeckerEvalBusy {Une évaluation est déjà en cours.}
translate F WoodpeckerSomeAnnotated {Des annotations sont déjà présentes sur les %d des %d exercices. Compléter les autres avec l’analyse, ou tout écraser avec l’analyse ?}
translate F WoodpeckerComplete {Compléter avec l’analyse}
translate F WoodpeckerOverwrite {Écraser avec l’analyse}
translate F WoodpeckerAllAnnotated {Tous les exercices %d sont déjà annotés, la révision est donc facultative. Écraser les notes de l'auteur par celles de l’analyse ?}
translate F WoodpeckerKeep {Conservez les annotations}
translate F WoodpeckerEvaluating {Évaluation de l'ensemble...}
translate F WoodpeckerEvalPhase_deep {Analyse : chercher les solutions}
translate F WoodpeckerEvalPhase_shallow {Analyse : quels coups sont évidents}
translate F WoodpeckerEvalPhase_write {Écrire les marques}
translate F WoodpeckerEvalDone {Évaluation effectuée : exercices %d ; %d coups marqués ! et %d marqué !!, sur %d coups à trouver.}
translate F WoodpeckerNoEngine {Aucun moteur UCI n'est configuré (Outils > Moteurs).}
translate F WoodpeckerEvalAsk {Évaluez les exercices %d avec ce moteur :}
translate F WoodpeckerOtherMode {Un autre entraînement ou jeu utilise actuellement l’échiquier.}
translate F WoodpeckerDatabaseBusy {La base de données de l'ensemble ne peut pas être lue lorsqu'un autre jeu ou entraînement utilise le plateau. Terminez-le, puis réessayez.}
translate F WoodpeckerDatabaseUnsaved {La base de données de l'ensemble contient des modifications non enregistrées. Enregistrez-les ou jetez-les avant de continuer.}
translate F WoodpeckerNoSlot {Aucun emplacement de base de données libre pour la session : fermez une base de données et réessayez.
(%s)}
translate F WoodpeckerRestAsk {Les jours de repos se terminent le %s. Démarrer le cycle %d quand même ?}
translate F WoodpeckerUnratedShort {Les exercices %d ne sont pas évalués : là seule la ligne compte.}
translate F WoodpeckerRes1 {résolu}
translate F WoodpeckerRes2 {échoué}
translate F WoodpeckerPacePer {par exercice}
translate F WoodpeckerPaceTarget {cible %s s}
translate F WoodpeckerCardStreak {Série de succès}
translate F WoodpeckerCardPoints {Points}
translate F WoodpeckerCardDeadline {Date limite}
translate F WoodpeckerStreakSub {nettoyer d'affilée}
translate F WoodpeckerPointsSub {des possibles}
translate F WoodpeckerDaysLeft {jours restants}
translate F WoodpeckerExercise {Exercice %d de %d}
translate F WoodpeckerWhiteToMove {Trait aux blancs}
translate F WoodpeckerBlackToMove {Trait aux noirs}
translate F WoodpeckerYourMove {Votre coup}
translate F WoodpeckerSolved {Résolu !}
translate F WoodpeckerFailed {Échoué.}
translate F WoodpeckerPoints {+%s / %s}
translate F WoodpeckerNoMarks {(non évalué : non ! / !! bonus pour l'instant)}
translate F WoodpeckerQuotaDone {Objectif du jour atteint ! Continuez ou terminez la séance.}
translate F WoodpeckerSolutionShown {Regardez la solution sur l’échiquier, puis appuyez sur Entrée.}
translate F WoodpeckerPaused {En pause.}
translate F WoodpeckerAutoPaused {En pause : aucun mouvement pendant deux minutes. Le temps passé ne compte pas.}
translate F WoodpeckerSessionOver {Séance terminée}
translate F WoodpeckerCycleComplete {Cycle %d terminé !}
translate F WoodpeckerSumDate {Date}
translate F WoodpeckerSumDuration {Durée}
translate F WoodpeckerSumExercises {Exercices terminés}
translate F WoodpeckerSumPoints {%s sur %s points}
translate F WoodpeckerSumAvg {Moyenne par exercice}
translate F WoodpeckerSumQuota {L'objectif du jour}
translate F WoodpeckerSumCompare {Par rapport au cycle précédent : %d plus rapide, %d plus lent, %d erreurs corrigées, %d nouvelles erreurs.}
translate F WoodpeckerSumReview {À réviser : exercices %s}
translate F WoodpeckerCyclesTitle {Cycles}
translate F WoodpeckerSessionsTitle {Séances}
translate F WoodpeckerStatsNote {Les points utilisent les notes d'évaluation %d. Les sessions précédentes sont notées avec les mêmes notes, donc les cycles se comparent équitablement.}
translate F WoodpeckerNoData {Pas encore de cycle}
translate F WoodpeckerChartLegend {barres : temps de résolution en pointillés : objectif (cycle précédent réduit de moitié)}
translate F WoodpeckerTagline {Résolvez le même ensemble encore et encore, plus rapidement à chaque fois.}
translate F WoodpeckerExit {Quitter la séance}
translate F WoodpeckerMore {Plus d'exercices}
translate F WoodpeckerToday {Aujourd'hui}
translate F WoodpeckerCycleShort {Cycle %d}
translate F WoodpeckerDaysPlanned {%d jours prévus}
translate F WoodpeckerExercisesShort {exercices}
translate F WoodpeckerDeadline {date limite %s}
translate F WoodpeckerHidden {La solution apparaîtra ici.}
translate F WoodpeckerSumCycle {Cycle}
translate F WoodpeckerTokenSave {Enregistrez et vérifiez}
translate F WoodpeckerTokenCreate {Créer un jeton (puzzle de portée : lire)}
translate F WoodpeckerTokenOk {✓ Le jeton fonctionne : %s.}
translate F WoodpeckerTokenRating {Note de la tactique %s.}
translate F WoodpeckerTokenNoScope {Ce jeton n'a pas l'autorisation puzzle:read : créez-en un avec le lien ci-dessus.}
translate F WoodpeckerTokenInvalid {Lichess ne connaît pas ce jeton.}
translate F WoodpeckerTokenUnchecked {Le token n'a pas pu être vérifié (pas de connexion ?). Il sera utilisé tel quel.}
translate F WoodpeckerTokenChecking {Vérification du jeton...}
translate F WoodpeckerTokenMissing {Pas de jeton ? Cela fonctionne aussi, avec le classement en tactiques renseigné ci-dessus (profil Lichess, Problèmes). Le téléchargement est plus lent et des tactiques que vous avez déjà résolues sur Lichess peuvent apparaître ; avec un jeton, c'est plus rapide.}
translate F WoodpeckerPreset_automatic {Automatique (plus facile)}
translate F WoodpeckerPreset_standard {Standard (recommandé)}
translate F WoodpeckerPreset_challenge {Stimulant}
translate F WoodpeckerPreset_tough {Difficile (principalement au-dessus de votre niveau)}
translate F WoodpeckerPreset_custom {Personnalisé}
translate F WoodpeckerPresetHelp_automatic {Des tactiques simples pour la plupart, visible d'emblée : le premier objectif du livre.}
translate F WoodpeckerPresetHelp_standard {Un quart plus facile, la plupart autour de votre niveau, un peu plus difficile – la proportion des sections Facile et Intermédiaire du livre.}
translate F WoodpeckerPresetHelp_challenge {Autour et au-dessus de votre niveau, pour les joueurs forts (comme la section Avancé du livre).}
translate F WoodpeckerPresetHelp_tough {Généralement bien au-dessus de votre niveau, pour les joueurs forts qui souhaitent avoir du fil à retordre.}
translate F WoodpeckerPresetHelp_custom {Choisissez vous-même la part de chaque niveau Lichess.}
translate F WoodpeckerPresetRating {Les niveaux sont relatifs à votre classement en problèmes Lichess (%s).}
translate F WoodpeckerPresetNoRating {Les niveaux sont relatifs à votre classement en problèmes Lichess.}
translate F WoodpeckerRatingAsk {Votre classement en problèmes Lichess}
translate F WoodpeckerBadRating {Saisissez votre classement en problèmes Lichess (400-3200) : il se trouve sur votre profil Lichess, sous Problèmes.}
translate F WoodpeckerPresetStated {Les niveaux sont relatifs au classement que vous avez saisi (%s).}
translate F WoodpeckerDataDir {Dossier de données de la méthode Woodpecker (vide : celui de Scid)}
translate F WoodpeckerNoDataDir {Le dossier de données Woodpecker est introuvable :\n%s\n\nLe disque est-il connecté ? Le dossier est défini dans Options > Ressources.}
translate F WoodpeckerDataDirMove {%d Les ensembles Woodpecker se trouvent dans le dossier de données précédent :\n%s\n\nLes déplacer dans le nouveau ?\n%s\n\nNon : le nouveau dossier démarre vide et les ensembles restent là où ils se trouvent.}
translate F WoodpeckerDataDirHasSets {Le nouveau dossier de données contient déjà des ensembles %d (synchronisés depuis un autre ordinateur ?) :\n%s\n\nScid les utilise. Les ensembles du dossier précédent restent dans :\n%s}

# Board screenshot
menuText F ToolsScreenshot "Capture d'écran de l’échiquier" 0 \
  {Enregistrer la position actuelle de l’échiquier sous forme d'image PNG}
translate F ScreenshotTitle {Capture d'écran de l’échiquier}
translate F ScreenshotFileType {Image PNG}
translate F ScreenshotOverwrite {Un fichier portant ce nom existe déjà. L'écraser ?}
translate F ScreenshotError {La capture d'écran n'a pas pu être enregistrée.}
translate F ScreenshotSaved {Capture d'écran de l’échiquier enregistrée :}

# Lichess study publishing
# Publish database games as chapters of a Lichess study.
# Designed by TBergh98 (https://github.com/TBergh98).
menuText F ToolsPublishLichessStudy "Publier la partie actuelle comme étude sur Lichess..." 0 \
  {Publiez la partie actuelle comme nouveau chapitre d'une de vos études Lichess}
translate F LichessStudyTitle {Publier comme étude Lichess}
translate F LichessStudyToPublish {Pour publier : %s (un chapitre par jeu)}
translate F LichessStudyToken {Jeton Lichess :}
translate F LichessStudyCreateToken {Créer un jeton (portées étude : lecture et étude : écriture)}
translate F LichessStudySearch {Chercher une étude}
translate F LichessStudyChapterSettings {Paramètres du chapitre}
translate F LichessStudyOrientation {Orientation:}
translate F LichessStudyOrientationAuto {Automatique}
translate F LichessStudyAnalysisMode {Mode d'analyse :}
translate F LichessStudyModeNormal {Analyse normale}
translate F LichessStudyModeConceal {Masquer les prochains coups}
translate F LichessStudyModePractice {S'entraîner avec un ordinateur}
translate F LichessStudyModeGamebook {Leçon interactive}
translate F LichessStudyCreateNew {Ou créez une nouvelle étude}
translate F LichessStudyName {Nom:}
translate F LichessStudyVisibility {Visibilité:}
translate F LichessStudyVisPrivate {Privé}
translate F LichessStudyVisUnlisted {Non répertorié}
translate F LichessStudyVisPublic {Publique}
translate F LichessStudyCreateAndPublish {Créer et publier}
translate F LichessStudyAddByLink {Étude à laquelle vous contribuez (lien) :}
translate F LichessStudyUnnamed {Étude %s}
translate F LichessStudyAddButton {Ajouter}
translate F LichessStudyReload {Recharger la liste}
translate F LichessStudyPublishButton {Publier}
translate F LichessStudyPublishGames {Publier dans l'étude Lichess (%s)...}
translate F LichessStudyAddedByLink {ajouté par lien}

translate F LichessStudyNeedToken {Collez votre jeton Lichess et appuyez sur "Enregistrer".}
translate F LichessStudyLoading {Chargement de vos études...}
translate F LichessStudyAccountStatus {Compte %s : %s études. Choisissez-en un et appuyez sur "Publier".}
translate F LichessStudyTokenInvalid {Le token contient des caractères invalides : copiez-le à nouveau depuis Lichess.}
translate F LichessStudySaveTokenFirst {Enregistrez d’abord votre jeton Lichess.}
translate F LichessStudyChecking {Vérification de l'étude %s...}
translate F LichessStudyPickStudy {Choisissez d'abord une étude dans la liste.}
translate F LichessStudyAddLinkPrompt {Collez le lien d'une étude, par ex. https://lichess.org/study/AbCd1234}
translate F LichessStudyNameLength {Le nom de l’étude doit comporter entre 2 et 100 caractères.}
translate F LichessStudyCreating {Création de l'étude "%s"...}
translate F LichessStudyCreateFailed {Impossible de créer l'étude "%s" : %s\n\nRien n'a été publié.}
translate F LichessStudyDbClosed {La base de données n'est plus ouverte.}
translate F LichessStudyTooManyGames {Vous avez sélectionné des jeux %s, mais une étude Lichess contient au maximum %s chapitres.}
translate F LichessStudyNoGame {Il n'y a aucun jeu sur le plateau.\n\nPour publier des jeux à partir d'une base de données, sélectionnez-les dans la liste des jeux et utilisez le menu contextuel.}
translate F LichessStudyNoUsername {Impossible de lire le nom d'utilisateur dans la réponse Lichess.}
translate F LichessStudyCurlNotFound {curl introuvable : il faut en parler à Lichess.}
translate F LichessStudyGameNotFound {Jeu %s introuvable dans la base de données.}
translate F LichessStudyCannotRead {Impossible de lire le jeu %s : %s}

translate F LichessStudyFull {l'étude est trop longue : une étude Lichess contient au maximum %s chapitres.}
translate F LichessStudyNoAnswer {Pas de réponse de Lichess : vérifiez votre connexion internet.}
translate F LichessStudy401 {Jeton invalide ou expiré (401).}
translate F LichessStudy403 {Autorisation refusée (403) : le jeton n'a pas les autorisations study:read/study:write, ou vous ne pouvez pas écrire dans cette étude.}
translate F LichessStudy404 {Étude introuvable (404), ou elle est privée et vous n'êtes pas membre.}
translate F LichessStudy429 {Trop de requêtes à Lichess (429) : attendez une minute et réessayez.}
translate F LichessStudyHttpError {Lichess (HTTP %s) : %s}
translate F LichessStudyUnexpected {Réponse inattendue de Lichess (HTTP %s). %s}
translate F LichessStudyNetworkError {Erreur réseau : %s}

translate F LichessStudyOvfFree {"%s" ne contient que %s chapitres gratuits sur %s (la limite Lichess), mais vous souhaitez publier des jeux %s.}
translate F LichessStudyOvfFull {"%s" est complet : une étude Lichess contient au maximum %s chapitres.}
translate F LichessStudyOvfQuestion {%s\n\nQue veux-tu faire ?}
translate F LichessStudyOvfFirst {Publiez ici uniquement les premières parties %s (%s ne sera pas publié)}
translate F LichessStudyOvfSplit {Publier les premières parties %s ici et les autres %s dans une nouvelle étude}
translate F LichessStudyOvfAllNew {Publier toutes les parties %s dans une nouvelle étude}
translate F LichessStudyOvfName {Nouveau nom de l'étude :}

translate F LichessStudyCancelled {Publication annulée : rien n'a été publié.}
translate F LichessStudyCheckingFree {Vérification des chapitres gratuits dans "%s"...}
translate F LichessStudyPublishing {Publication de %s partie(s) sur "%s"...}
translate F LichessStudyGamesNotPublished {Parties non publiées car l'étude est complète : %s.}
translate F LichessStudyEmptyNew {La nouvelle étude "%s" a été créée mais ne contient aucune des parties (%s).}
translate F LichessStudyNothingPublished {Rien n'a été publié.%s}
translate F LichessStudyReport {Vous avez créé %s de %s chapitres (%s).%s\n\nOuvrir l'étude dans votre navigateur ?}
translate F LichessStudyReportItem {%s dans "%s"}
translate F LichessStudyNoChapters {Aucun chapitre n'a été créé.%s}
translate F LichessStudyReports {Rapports de lichess : %s}

translate F About {À propos}
translate F Back {Retour}
translate F Apply {Appliquer}
translate F Browse {Parcourir}
translate F Cancel {Annuler}
translate F Continue {Continuer}
translate F Clear {Effacer}
translate F Close {Fermer}
translate F Contents {Contenu}
translate F Defaults {Par défaut}
translate F InvertSearch {Inverser la recherche}
translate F Delete {Éliminer}
translate F Graph {Graphique}
translate F Help {Aide}
translate F Hide {Cacher}
translate F Import {Importer}
translate F Index {Index}
translate F LoadGame {Charger cette partie}
translate F PgnOpenInViewer {Ouvrir dans le visionneur PGN}
translate F MergeGame {Fusionner la partie comme variante}
translate F MergeGames {Fusionner les parties}
translate F Preview {Prévisualiser}
translate F Revert {Rétablir}
translate F Rename {Renommer}
translate F Save {Enregistrer}
translate F Presets {Préréglages}
translate F SavePreset {Enregistrer le préréglage de recherche}
translate F PresetName {Nom du préréglage :}
translate F Search {Rechercher}
translate F Stop {Arrêter}
translate F Store {Enregistrer}
translate F Update {Mettre à jour}
translate F ChangeOrient {Changer l'orientation de la fenêtre}
translate F ShowIcons {Montrer les icônes}
translate F None {Aucun}
translate F First {Premier}
translate F Current {En cours}
translate F Last {Dernier}

# General messages:
translate F game {partie}
translate F games {parties}
translate F move {coup}
translate F moves {coups}
translate F all {tout}
translate F Yes {Oui}
translate F No {Non}
translate F Both {Les deux}
translate F King {Roi}
translate F Queen {Dame}
translate F Rook {Tour}
translate F Bishop {Fou}
translate F Knight {Cavalier}
translate F Pawn {Pion}
translate F White {Blancs}
translate F Black {Noirs}
translate F Player {Joueur}
translate F Rating {Classement Elo}
translate F RatingDiff {Différence de classement Elo (Blancs - Noirs)}
translate F AverageRating {Classement moyen}
translate F Event {Événement}
translate F Site {Lieu}
translate F Country {Pays}
translate F IgnoreColors {Ignorer les couleurs}
translate F Date {Date}
translate F EventDate {Date de l'événement}
translate F Decade {Décennie}
translate F Year {Année}
translate F Month {Mois}
translate F Months {Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre}
translate F Days {Dim Lun Mar Mer Jeu Ven Sam}
translate F YearToToday {- 1 an}
translate F YearToTodayTooltip {Fixer la date de 1 an en arrière à aujourd'hui}
translate F Result {Résultat}
translate F Round {Ronde}
translate F Length {Longueur}
translate F ECOCode {Code ECO}
translate F ECO {ECO}
translate F Deleted {Supprimé}
translate F SearchResults {Résultats de la recherche}
translate F OpeningTheDatabase {Ouverture de la base}
translate F Database {Base}
translate F MenuDatabaseSlot {Base %d : %s}
translate F MenuImportIntoSlot {dans %d : %s}
translate F Filter {Filtre}
translate F noGames {pas de parties}
translate F allGames {toutes les parties}
translate F empty {vide}
translate F clipbase {Clipbase}
translate F score {score}
translate F StartPos {Position de départ}
translate F Total {Total}
translate F readonly {lecture seule}

# Import games (skip duplicates):
translate F ImportInto {Importer dans :}
translate F ImportStripComments {Supprimer les commentaires des parties importées}
translate F Clipbase {Clipbase}
translate F NoWritableDatabases {Aucune base de données accessible en écriture n'est ouverte. Veuillez d'abord ouvrir ou créer une base de données.}
translate F Imported {Importé}
translate F Updated {Mis à jour}
translate F Into {dans}
translate F Skipped {Sauté}
translate F DuplicateGame {jeu en double}
translate F DuplicateGames {jeux en double}
translate F PgnErrorsWarnings {Erreurs/avertissements PGN :}
translate F NoPgnErrorsWarnings {sans erreurs ni avertissements PGN.}

# Standard error messages:
translate F ErrNotOpen {Ceci n'est pas une base ouverte.}
translate F ErrReadOnly {Cette base est en lecture seule; elle ne peut pas être modifiée.}
translate F ErrSearchInterrupted {La recherche a été interrompue; les résultats sont incomplets.}
translate F ErrNoClockComments {Aucun commentaire de pendule [%clk] n'a été trouvé dans cette partie.  Ajoutez les temps de jeu via la fenêtre de commentaires (Ctrl+E) pour utiliser cette fonctionnalité.}
translate F ErrFileInUse {Erreur : le fichier est déjà utilisé. Veuillez fermer toute autre application utilisant cette base de données.}

# Drag and drop
translate F DndCannotOpenUri {Impossible d'ouvrir l'URL}
translate F DndInvalidUri {URL invalide}
translate F DndUriRejected {URL rejetée}
translate F DndUriRejectedDetail {Bases de données Scid (.si5, .si4, .si3) ou fichiers PGN/EPD.}
translate F DndEmptyUriList {Aucun fichier trouvé dans la liste des URL déposées}
translate F DndOwnerDidntRespond {Échec du dépôt : le propriétaire de la sélection n'a pas répondu}




# Game information:
translate F twin {doublon}
translate F deleted {éliminé}
translate F comment {commentaire}
translate F hidden {caché}
translate F LastMove {Dernier coup}
translate F NextMove {Coup suivant}
translate F GameStart {Début de partie}
translate F LineStart {Début de ligne}
translate F GameEnd {Fin de partie}
translate F LineEnd {Fin de ligne}

# Player information:
translate F PInfoAll {Résultats pour <b>toutes</b> les parties}
translate F PInfoFilter {Résultats pour les parties <b>filtrées</b>}
translate F PInfoAgainst {Résultats contre}
translate F PInfoMostWhite {Ouvertures les plus fréquentes avec les blancs}
translate F PInfoMostBlack {Ouvertures les plus fréquentes avec les noirs}
translate F PInfoRating {Historique du classement}
translate F PInfoBio {Biographie}
translate F PInfoEditRatings {Éditer les classements}
translate F PInfoEloFile {Fichier}

# Tablebase information:
translate F Draw {Nulle}
translate F with {avec}
translate F only {seulement}
translate F lose {perte}
translate F loses {pertes}

# Tip of the day:
translate F Tip {Astuce}
translate F TipAtStartup {Astuce au démarrage}
translate F TipConvertPGN {Vous pouvez obtenir de meilleures performances en convertissant les fichiers PGN}

# Tree window menus:
menuText F TreeFile "Fichier" 0
menuText F TreeFileFillWithBase "Remplir le cache avec la base" 0 {Remplir le cache avec toutes les parties de la base courante}
menuText F TreeFileFillWithGame "Remplir le cache avec la partie" 0 {Remplir le cache avec la partie en cours de la base courante}
menuText F TreeFileSetCacheSize "Taille du cache" 0 {Taille du cache}
menuText F TreeFileCacheInfo "Info cache" 0 {Afficher information sur l'utilisation du cache}
menuText F TreeFileSave "Enregistrer le cache" 0
menuText F TreeFileFill "Remplir le cache" 0
menuText F TreeFileBest "Liste des meilleures parties" 0 {Montrer la liste des meilleures parties}
menuText F TreeFileGraph "Graphique" 0 {Graphique de cette branche de l'arbre}
menuText F TreeFileCopy "Copier l'arbre dans le presse-papier" 0 {Copier les statistiques de l’arbre dans le presse-papier}
menuText F TreeFileClose "Fermer la fenêtre d'arbre" 0
menuText F TreeMask "Masque" 0
menuText F TreeMaskNew "Nouveau" 0 {Nouveau masque}
menuText F TreeMaskOpen "Ouvrir" 0 {Ouvrir un masque}
menuText F TreeMaskOpenRecent "Ouvrir récent" 0 {Ouvrir un masque récent}
menuText F TreeMaskSave "Enregistrer" 0 {Enregistrer le masque}
menuText F TreeMaskClose "Fermer" 0 {Fermer le masque}
menuText F TreeMaskFillWithGame "Remplir avec la partie" 0 {Remplir le masque avec la partie courante}
menuText F TreeMaskFillWithBase "Remplir avec la base" 0 {Remplir le masque avec les parties de la base}
menuText F TreeMaskInfo "Info" 0 {Statistiques du masque}
menuText F TreeMaskDisplay "Afficher l'arbre" 0 {Affichage des données du masque sous la forme d'un arbre}
menuText F TreeMaskSearch "Chercher" 0 {Chercher dans le masque courant}
menuText F TreeSort "Trier" 0
menuText F TreeSortAlpha "Alphabétique" 0
menuText F TreeSortECO "code ECO" 0
menuText F TreeSortFreq "Fréquence" 0
menuText F TreeSortScore "Score" 0
menuText F TreeOpt "Options" 0
menuText F TreeOptSlowmode "Mode lent" 0 {Mode lent pour rafraichissement (précis)}
menuText F TreeOptFastmode "Mode rapide" 0 {Mode rapide pour rafraichissement (pas de transpositions)}
menuText F TreeOptFastAndSlowmode "Mode rapide puis lent" 0 {Mode rapide puis lent pour rafraichissement}
menuText F TreeOptStartStop "Rafraîchissement auto" 0 {Rafraîchissement automatique de la fenêtre}
menuText F TreeOptLock "Verrouiller" 0 {Dé/verrouiller l'arbre à la base en cours}
menuText F TreeOptAutoLoadMask "Chargement automatique du dernier masque" 0 \
  {Ouvrir automatiquement le masque le plus récemment utilisé lorsqu'une fenêtre arborescente s'ouvre}
menuText F TreeOptTraining "Entraînement" 0 {Démarrer/Arrêter l'arbre du mode d'entraînement}
menuText F TreeOptDepth "Déplacer la profondeur" 0 {Nombre de demi-coups à afficher dans l'arbre (1-4)}
menuText F TreeOptAutosave "Enregistrer le cache automatiquement" 0
menuText F TreeHelp "Aide" 0
menuText F TreeHelpTree "Aide Arbre" 0
menuText F TreeHelpIndex "Index" 0
menuText F TreeFindGames "Trouver les parties avec annotation" 0 {Construire la liste des parties où ce coup a été joué avec une annotation}
translate F SaveCache {Enregistrer le cache}
translate F Training {Entraînement}
translate F PlayFromHere {Jouez à partir d'ici}
translate F PlayFromHereHelp {Le moteur répond en premier lorsque la limite de temps ou de profondeur est atteinte. Zéro signifie aucune limite pour ce champ.}
translate F PlayFromHereLimit {Définir la limite de temps et de profondeur}
translate F PlayFromHereBusy {Terminez l’analyse en cours ou terminez le jeu en premier.}
translate F TreeTrainingEndOfLine {Fin de ligne atteinte.}
translate F TreeTrainingMoveNotInBase {Ce mouvement n'est pas dans la base de données.}
translate F LockTree {Verrouiller}
translate F TreeDepth {Profondeur de l'arbre (demi-mouvements) :}
translate F TreeLocked {verrouillé}
translate F TreeTimingSearch {recherche}
translate F TreeTimingStats {statistiques}
translate F TreeBest {Meilleur}
translate F TreeBestGames {Arbre des meilleures parties}
translate F TreeFindAnyAnn {toute annotation}
translate F TreeFindStalePos {La position actuelle ne correspond plus à la position annotée de l\x27arbre.\nRevenez-y et réessayez.}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate F TreeTitleRow \
{Coup                          ECO        Fréquence   Score EloMoy Perf avLen AnnéeMoy %Nulle   %Victoires}
translate F TreeTotal {TOTAL}
translate F DoYouWantToSaveFirst {Voulez-vous d'abord sauvegarder}
translate F AddToMask {Ajouter au masque}
translate F RemoveFromMask {Enlever du masque}
translate F AddThisMoveToMask {Ajouter ce coup au masque}
translate F SearchMask {Recherche dans masque}
translate F DisplayMask {Affichage du masque}
translate F Nag {Code Nag}
translate F Marker {Marqueur}
translate F Include {Inclure}
translate F Exclude {Exclure}
translate F MainLine {Ligne principale}
translate F Bookmark {Signet}
translate F NewLine {Nouvelle ligne}
translate F ToBeVerified {À vérifier}
translate F ToTrain {S’entraîner}
translate F Dubious {Douteux}
translate F ToRemove {À supprimer}
translate F NoMarker {Aucun marqueur}
translate F ColorMarker {Couleur}
translate F WhiteMark {Blanc}
translate F GreenMark {Vert}
translate F YellowMark {Jaune}
translate F BlueMark {Bleu}
translate F RedMark {Rouge}
translate F CommentMove {Annoter coup}
translate F CommentPosition {Annoter position}
translate F AddMoveToMaskFirst {Ajoutez d'abord le coup au masque}
translate F OpenAMaskFileFirst {Ouvrez d'abord un masque}
translate F Positions {Positions}
translate F Moves {Coups}

# Finder window:
menuText F FinderFile "Fichier" 0
menuText F FinderFileSubdirs "Rechercher dans les sous-répertoires" 0
menuText F FinderFileClose "Fermer l'explorateur de fichiers" 0
menuText F FinderSort "Trier" 0
menuText F FinderSortType "Type" 0
menuText F FinderSortSize "Taille" 0
menuText F FinderSortMod "Modifié" 0
menuText F FinderSortName "Nom" 0
menuText F FinderSortPath "Chemin" 0
menuText F FinderTypes "Types" 0
menuText F FinderTypesScid "Bases Scid" 0
menuText F FinderTypesOld "Bases Scid à l'ancien format" 0
menuText F FinderTypesPGN "fichiers PGN" 0
menuText F FinderTypesEPD "fichiers EPD (théorie)" 0
menuText F FinderTypesRep "fichiers des répertoires" 0
menuText F FinderHelp "Aide" 0
menuText F FinderHelpFinder "Aide de l'explorateur de fichiers" 0
menuText F FinderHelpIndex "Index de l’aide" 0
translate F FileFinder {Explorateur de fichiers}
translate F FinderDir {Répertoire}
translate F FinderDirs {Répertoires}
translate F FinderFiles {Fichiers}
translate F FinderUpDir {répertoire précédent}
translate F FinderCtxOpen {Ouvrir}
translate F FinderCtxBackup {Faire une sauvegarde}
translate F FinderCtxCopy {Copier}
translate F FinderCtxMove {Déplacer}
translate F FinderCtxDelete {Supprimer}

# Player finder:
menuText F PListFile "Fichier" 0
menuText F PListFileUpdate "Mettre à jour" 0
menuText F PListFileClose "Fermer la recherche de joueur" 0
menuText F PListSort "Trier" 0
menuText F PListSortName "Nom" 0
menuText F PListSortElo "Elo" 0
menuText F PListSortGames "Parties" 0
menuText F PListSortOldest "Les plus vieux" 0
menuText F PListSortNewest "Les plus récents" 0

# Tournament finder:
menuText F TmtFile "Fichier" 0
menuText F TmtFileUpdate "Mettre à jour" 0
menuText F TmtFileClose "Fermer l'explorateur de tournois" 0
menuText F TmtSort "Trier" 0
menuText F TmtSortDate "Date" 0
menuText F TmtSortPlayers "Joueurs" 0
menuText F TmtSortGames "Parties" 0
menuText F TmtSortElo "Elo" 0
menuText F TmtSortSite "Lieu" 0
menuText F TmtSortEvent "Événement" 1
menuText F TmtSortWinner "Vainqueur" 0
translate F TmtLimit "Limite de liste"
translate F TmtMeanElo {Moyenne Elo}
translate F TmtNone "Aucun tournoi correspondant n'a été trouvé."

# Graph windows:
menuText F GraphFile "Fichier" 0
menuText F GraphFileColor "Enregistrer comme Postscript en couleurs..." 27
menuText F GraphFileGrey "Enregistrer comme Postscript en niveaux de gris..." 27
menuText F GraphFileClose "Fermer la fenêtre" 0
menuText F GraphOptions "Options" 0
menuText F GraphOptionsWhite "Blancs" 0
menuText F GraphOptionsBlack "Noirs" 0
menuText F GraphOptionsBoth "Les deux" 4
menuText F GraphOptionsPInfo "Informations joueurs" 0
menuText F GraphOptionsEloFile "Classement Elo du fichier" 0
menuText F GraphOptionsEloDB "Classement Elo dans la base" 0
translate F GraphFilterTitle "Graphique de filtre : pourcentage de jeux atteignant la position"
translate F GraphAbsFilterTitle "Graphique de filtre: fréquence des parties"
translate F GraphWinPctTitle "Graphique de filtre : % de victoire (1-0 et 0-1) à la position actuelle par année"
translate F ConfigureFilter {Configurer l'axe des X par année, classement et coups}
translate F FilterEstimate "Estimer"
translate F TitleFilterGraph "scidCommunity: Graphe de filtre"
translate F WinPct "Gagner %"
translate F GraphLine "Graphique linéaire"
translate F GraphBar "Graphique à barres"
translate F GraphPopup "Tableau contextuel"
translate F PgnVarClose {Fermer toutes les variantes}
translate F PgnVarOpen {Ouvrir toutes les variantes}
translate F PgnEvaluate {Évaluer}
translate F PgnSaveEval {Enregistrer l'évaluation}
translate F PgnOptShort "En-tête court (3 lignes)"
translate F PgnOptSymbols "Annotations symboliques"
translate F PgnOptIndentC {Indenter les commentaires}
translate F PgnOptIndentV {Indenter les variantes}
translate F PgnOptColumn "Style de colonne (un mouvement par ligne)"
translate F PgnOptSpace {Espace après le numéro des coups}
translate F PgnOptStripMarks "Supprimez les codes de carrés/flèches colorés"
translate F PgnOptBoldMainLine {Utiliser du texte en gras pour les coups de la ligne principale}
translate F PgnOptCenter {Centrer le coup actuel}

# Analysis window:
translate F AddAllVariations {Ajouter toutes les variantes}
translate F AddMove {Ajouter le coup}
translate F RemoveMove {Supprimer le coup}
translate F Annotate {Annoter}
translate F FinishGame {Continuer la partie}
translate F StartEngine {Démarrer le moteur}
translate F LockEngine {Verrouiller le moteur à la position actuelle}
translate F AnalysisCommand {Commande d'analyse}
translate F PreviousChoices {Choix précédents}
translate F AnnotateTime {Temps en secondes par coup}
translate F AnnotateAll {Pour les coups des deux côtés}
translate F AnnotateWhite {Pour les coups des blancs seulement}
translate F AnnotateBlack {Pour les coups des noirs seulement}
translate F AnnotateBlundersOnlyScoreChange {L’analyse montre une gaffe, l’évaluation passe de/à: }
translate F LowPriority {Priorité processeur basse}
translate F ConfigureInformant {Valeurs des annotations}
translate F Informant!? {Coup intéressant}
translate F Informant? {Coup faible}
translate F Informant?? {Gaffe}
translate F Informant?! {Coup douteux}
translate F Informant+= {Les blancs ont un léger avantage}
translate F Informant+/- {Les blancs ont l'avantage}
translate F Informant+- {Les blancs ont un avantage décisif}
translate F Informant+-- {La partie est gagnée}
translate F AnalysisAutoCommentTooltip {Générez des commentaires IA pour l'ensemble du jeu}
translate F MoveLabelBest {Meilleur}
translate F MoveLabelExcellent {Excellent}
translate F MoveLabelGood {Bon}
translate F MoveLabelInaccuracy {Imprécision}
translate F MoveLabelMistake {Erreur}
translate F MoveLabelBlunder {Gaffe}
translate F MoveLabelBrilliant {Brillant}
translate F MoveLabelGreat {Très bon}
translate F MoveLabelMiss {Occasion manquée}
translate F MoveLabelForced {Forcé}
translate F MoveLabelBook {Théorie}
translate F GameComment {Commentaire du jeu}
translate F GameCommentTooltip {Analysez le jeu pour rechercher des mouvements annotés et générer un résumé de l'IA}
translate F ReviewGameButton {Analyse de la partie}
translate F ReviewGameButtonTooltip {Analyser tous les coups de la ligne courante et les annoter}
translate F ReviewMoveButton {Commentaire du coup}
translate F ReviewMoveButtonTooltip {Annoter le coup surligné ici et l'insérer}
translate F ReviewSettings {Réglages de l'analyse}
translate F ReviewSettingsTooltip {Configurer les réglages de l’analyse}
translate F ToolsWhatThreat {Quelle est la menace ?}
translate F ToolsWhatThreatTooltip {Demande au moteur ce que menace le joueur qui a le trait}
translate F WhatThreatRunning {Une analyse des menaces est déjà en cours.}
translate F WhatThreatNoEngine {Aucun moteur n'est configuré. Choisissez-en un dans Outils -> Configurer les moteurs, ou ouvrez d'abord une fenêtre de moteur.}
translate F WhatThreatNoPosition {Il n'y a aucune position à examiner.}
translate F WhatThreatNoMove {Il n'y a aucun coup à commenter ici. Allez d'abord sur un coup de la partie.}
translate F WhatThreatFailed {L'analyse des menaces n'a pas pu s'exécuter : %s}
translate F WhatThreatNothingForcing {%s n'a rien de forcé ici : aucun coup ne gagne de matériel ni ne donne échec.}
translate F ReviewVerifier {Moteur de vérification}
translate F ReviewVerifierOff {Désactivé (aucune vérification)}
translate F ReviewVarLines {Variantes à écrire}
translate F ReviewVarCp {Écart des variantes (cp)}
translate F ReviewMoveWait {Attendre la profondeur d'analyse}
translate F ReviewMovetime {Plafond de temps (ms)}
translate F ReviewCloudEval {Pré-évaluation dans le cloud}
translate F ReviewEstimatedRating {performance (de cette partie)}
translate F ReviewOpeningMoves {Coups de l’ouverture}
translate F ReviewFromPreset {%s (profil du moteur)}
translate F ReviewProgress {Analyse de la position %s sur %s}
translate F ReviewWaitForDepth {En attente de la profondeur %s}
translate F ReviewFailed {Échec de l'analyse : %s}
translate F ReviewCoach {Texte du coach}
translate F ReviewCoachProgress {annotation %s sur %s · texte %s sur %s}
translate F ReviewWriting {Rédaction de l'analyse...}
translate F ReviewCoachSettings {Réglages du coach...}
translate F ReviewCoachNoModel {Le texte du coach est activé, mais aucun modèle n'est configuré. Ouvrez les réglages de l'analyse et appuyez sur Réglages du coach... pour choisir un fournisseur et un modèle.}
translate F ReviewCoachKept {Analyse annulée : %s notes du coach sur %s ont été conservées.}
translate F ReviewCoachDiscarded {L'analyse est terminée, mais le texte du coach a été abandonné : une autre partie a été ouverte pendant que le modèle écrivait.}
translate F ReviewCoachSummaryLabel {Résumé}
translate F ReviewCoachLevelLabel {Niveau}
translate F ReviewCoachOpeningLabel {Ouverture}
translate F ReviewCoachPhase {mouvements %d-%d - précision W %.1f%% B %.1f%%, ACPL W %d B %d.}
translate F ReviewReportMarker {Analyse de la partie}
translate F ReviewReportSide {%s : précision %s%%, ACPL %d}
translate F ReviewReportLabels {%s étiquettes : %s}
translate F ReviewReportKeyMoments {Moments clés : %s}
translate F ReviewReportPhases {Phases : %s}
translate F ReviewReportPhase {%s se déplace de %d à %d (%s %.1f / %s %.1f)}
translate F ReviewReportOpening {ouverture}
translate F ReviewReportMiddlegame {milieu de jeu}
translate F ReviewReportEndgame {finale}
translate F TimeMs {Temps (ms)}


# Book window
translate F Book {Bibliothèque}
translate F OtherBookMoves {Bibliothèque de l'adversaire}
translate F OtherBookMovesTooltip {Coups pour lesquels l'adversaire a une réponse}
translate F Alphabetical {Alphabétique}
translate F BookCount {Livres}

# OpenBook Rich (.obr) book columns, shown in the Book window for a .obr book.
translate F ObrBookMove {Se déplacer}
translate F ObrBookGames {Parties }
translate F ObrBookFrequency {Fréquence}
translate F ObrBookScore {Score}
translate F ObrBookWDB {Blancs/Nulle/Noirs%}
translate F ObrBookElo {Elo}
translate F ObrBookPerf {Performance}
translate F ObrBookNoStats {(pas de statistiques)}
translate F ObrBookDetail {%s %d parties (fréquence %.1f%%) : +%d =%d -%d (Blancs/Nulle/Noirs) score %.1f%% Elo %s Perf %s couleur %s indicateurs 0x%02X}
translate F ObrColourRed {rouge}
translate F ObrColourBlue {bleu}
translate F ObrColourGreen {vert}
# Tools > Convert CTG book: ChessBase CTG book to OpenBook Rich (.obr)
translate F CtgChooseSource {Choisissez le livre CTG (.ctg) : ses fichiers .cto et .ctb doivent être dans le même dossier}
translate F CtgChooseDest {Choisissez où enregistrer le livre OBR (.obr)}
translate F CtgConverting {Conversion}
translate F CtgConvertDone {Livre enregistré :}

# Configure Engines dialog:
translate F EngineList {Configurer les moteurs}
translate F EngineName {Nom}
translate F EngineCmd {Commande}
translate F EngineArgs {Paramètres}
translate F EngineDir {Dossier}
translate F EngineElo {Elo}
translate F EngineTime {Date}
translate F EngineNew {Nouveau}
translate F EngineEdit {Éditer}
translate F EngineRequired {Les champs en gras sont requis; les autres sont optionnels}
translate F EngineNameInUse {Un moteur nommé %s existe déjà. Enregistrer celui-ci sous %s ?}
translate F EngineProtocol {Protocole de communication}
translate F EngineNotation {Notation des coups}
translate F EngineFlipEvaluation {Perspective d'évaluation inversée}
translate F EngineShowLog {Afficher le journal des communications}
translate F EngineNetworkd {Accepter les connexions à distance}
translate F EngineSelect {Sélectionnez le moteur actuel}
translate F EngineAddLocal {Ajouter un moteur local}
translate F EngineAddRemote {Ajouter un moteur distant}
translate F EngineReload {Recharger le moteur actuel}
translate F EngineClone {Créer une copie du moteur actuel}
translate F EngineDuplicate {Dupliquer}
translate F EngineDelete {Supprimer le moteur actuel}
translate F EngineOpenWindow {Ouvrir la fenêtre du moteur}
translate F EngineShortcut {Raccourci}
translate F EngineShortcutNone {Aucun}
translate F EngineShortcutWindow {Fenêtre %s (%s)}
translate F EngineShortcutKeys {Touches de raccourci}
translate F EngineShortcutKeysHelp {Choisissez la touche qui démarre chaque fenêtre du moteur. Appuyez sur Modifier..., puis sur la combinaison de touches souhaitée. Une touche déjà utilisée par une autre commande est refusée.}
translate F EngineShortcutChange {Changer…}
translate F EngineShortcutReset {Réinitialiser à F2 et F3}
translate F EngineShortcutPress {Appuyez sur la nouvelle combinaison de touches pour la fenêtre moteur %s.\nEchap annule l’action.}
translate F EngineShortcutInUse {La touche %s est déjà utilisée par une autre commande. Choisissez-en une autre.}
translate F EngineShortcutUnsafe {Choisissez une touche de fonction ou une combinaison de touches comprenant Ctrl, Alt ou Commande.}
translate F EngineShortcutReserved {Cette touche est réservée par le système d'exploitation ou par l'édition de texte. Choisissez-en une autre.}

# PGN window menus:
menuText F PgnFile "Fichier" 0
menuText F PgnFileCopy "Copier la partie dans le presse-papier" 0
menuText F PgnFilePrint "Enregistrer sous..." 0
menuText F PgnFileClose "Fermer la fenêtre PGN" 0
menuText F PgnOpt "Affichage" 0
menuText F PgnOptColor "Couleur d'affichage" 0
menuText F PgnOptShort "En-tête court (trois lignes)" 0
menuText F PgnOptSymbols "Annotations symboliques" 0
menuText F PgnOptIndentC "Indenter les commentaires" 0
menuText F PgnOptIndentV "Indenter les variantes" 13
menuText F PgnOptColumn "Style en colonne (un coup par ligne)" 1
menuText F PgnOptSpace "Espace après numéro des coups" 0
menuText F PgnOptStripMarks "Enlever les codes de flèches et de coloration de cases" 1
menuText F PgnOptBoldMainLine "Mettre en gras les coups de la ligne principale" 4
menuText F PgnOptCenter "Centrer le mouvement actuel" 7
menuText F PgnColor "Couleur" 0
menuText F PgnColorHeader "En-tête..." 0
menuText F PgnColorAnno "Annotations..." 0
menuText F PgnColorComments "Commentaires..." 0
menuText F PgnColorVars "Variantes..." 0
menuText F PgnColorBackground "Couleur du fond..." 11
menuText F PgnColorMain "Ligne principale…" 0
menuText F PgnColorCurrent "Dernier coup..." 1
menuText F PgnHelp "Aide" 0
menuText F PgnHelpPgn "Aide PGN" 0
menuText F PgnHelpIndex "Index" 0
translate F PgnWindowTitle {Notation - partie %u}

# Notation pane (PGN window) button tooltips:
translate F TBLookupTooltip {Consulter les tables de finales sur Lichess}
translate F LichessEvalTooltip {Évaluation du nuage Lichess pour la position actuelle}
translate F LichessUploadTooltip {Télécharger la partie sur Lichess.org}
translate F ChessComTooltip {Ouvrir la partie dans l’échiquier d'analyse Chess.com}
translate F ChessDBTooltip {Ouvrir la position actuelle dans ChessDB.cn}
translate F LichessOpenExTooltip {Explorateur d'ouverture Lichess pour la position actuelle}
translate F LichessMonitorTooltip {Pause/Reprise des mises à jour en direct}
translate F LucasChessNoMacOS {Les moteurs Lucas Chess ne sont pas disponibles pour macOS}

# Crosstable window menus:
menuText F CrosstabFile "Fichier" 0
menuText F CrosstabFileText "Écrire dans un fichier texte..." 23
menuText F CrosstabFileHtml "Écrire dans un fichier HTML..." 23
menuText F CrosstabFileClose "Fermer la fenêtre de classement du tournoi" 0
menuText F CrosstabEdit "Éditer" 0
menuText F CrosstabEditEvent "Événement" 0
menuText F CrosstabEditSite "Lieu" 0
menuText F CrosstabEditDate "Date" 0
menuText F CrosstabOpt "Afficher" 0
menuText F CrosstabOptAll "Toutes rondes" 0
menuText F CrosstabOptSwiss "Suisse" 0
menuText F CrosstabOptKnockout "Élimination directe" 0
menuText F CrosstabOptAuto "Auto" 0
menuText F CrosstabOptAges "Ages en années" 8
menuText F CrosstabOptNats "Nationalités" 0
menuText F CrosstabOptRatings "Classements" 0
menuText F CrosstabOptTitles "Titres" 0
menuText F CrosstabOptBreaks "Scores du départage" 4
menuText F CrosstabOptDeleted "Inclure les parties effacées" 8
menuText F CrosstabOptColors "Couleurs (système suisse uniquement)" 1
menuText F CrosstabOptColumnNumbers "Colonnes numérotées (Toutes rondes seulement)" 2
menuText F CrosstabOptGroup "Scores du groupe" 0
menuText F CrosstabSort "Trier" 0
menuText F CrosstabSortName "Nom" 0
menuText F CrosstabSortRating "Elo" 0
menuText F CrosstabSortScore "Score" 0
menuText F CrosstabColor "Couleur" 0
menuText F CrosstabColorPlain "Texte normal" 0
menuText F CrosstabColorHyper "Hypertexte" 0
menuText F CrosstabHelp "Aide" 0
menuText F CrosstabHelpCross "Aide résultat tournoi" 0
menuText F CrosstabHelpIndex "Index de l’aide" 0
translate F SetFilter {Activer le filtre}
translate F AddToFilter {Ajouter au filtre}
translate F Swiss {Suisse}
translate F Category {Catégorie}

# Opening report window menus:
menuText F OprepFile "Fichier" 0
menuText F OprepFileText "Écrire dans un fichier texte..." 23
menuText F OprepFileHtml "Écrire dans un fichier HTML..." 23
menuText F OprepFileOptions "Options..." 0
menuText F OprepFileClose "Fermer la fenêtre du rapport" 0
menuText F OprepFavorites "Favoris" 1
menuText F OprepFavoritesAdd "Ajouter un rapport..." 0
menuText F OprepFavoritesEdit "Modifier les favoris du rapport..." 0
menuText F OprepFavoritesGenerate "Générer le rapport…" 0
menuText F OprepHelp "Aide" 0
menuText F OprepHelpReport "Aide du rapport d’ouverture" 0
menuText F OprepHelpIndex "Index" 0

# Header search:
translate F HeaderSearch {Rechercher dans l'en-tête}
translate F EndSideToMove {Couleur au trait à la fin de la partie}
translate F GamesWithNoECO {Parties sans code ECO ?}
translate F GameLength {Longueur de la partie}
translate F FindGamesWith {Trouver les parties avec drapeau}
translate F StdStart {Pos. départ non standard}
translate F Promotions {Promotions}
translate F Variations {Variantes}
translate F Annotations {Annotations}
translate F DeleteFlag {Supprimer drapeau}
translate F WhiteOpFlag {Ouverture des blancs}
translate F BlackOpFlag {Ouverture des noirs}
translate F MiddlegameFlag {Milieu de partie}
translate F EndgameFlag {Finale}
translate F NoveltyFlag {Nouveauté}
translate F PawnFlag {Structure de pions}
translate F TacticsFlag {Tactiques}
translate F QsideFlag {Jeu à l'aile dame}
translate F KsideFlag {Jeu à l'aile roi}
translate F BrilliancyFlag {Spectaculaire}
translate F BlunderFlag {Gaffe}
translate F UserFlag {Utilisateur}
translate F PgnContains {PGN contient le texte}
translate F PgnTag {Étiquette}
translate F TagContains {contient}
translate F Variant {Variante}
translate F Annotator {Annotateur}
translate F Cmnts {parties annotées uniquement}

# Game list window:
translate F GlistNumber {Numéro}
translate F GlistWhite {Blancs}
translate F GlistBlack {Noirs}
translate F GlistWElo {B-Elo}
translate F GlistBElo {N-Elo}
translate F GlistEvent {Événement}
translate F GlistSite {Lieu}
translate F GlistRound {Ronde}
translate F GlistDate {Date}
translate F GlistYear {Année}
translate F GlistEDate {Date d'événement}
translate F GlistResult {Résultat}
translate F GlistLength {Longueur}
translate F GlistCountry {Pays}
translate F GlistECO {ECO}
translate F GlistOpening {Ouverture}
translate F GlistEndMaterial {Matériel final}
translate F GlistDeleted {Supprimé}
translate F GlistFlags {Drapeaux}
translate F GlistVars {Variantes}
translate F GlistComments {Commentaires}
translate F GlistAnnos {Annotations}
translate F GlistStart {Départ}
translate F GlistGameNumber {Partie numéro}
translate F GlistAverageElo {Moyenne Elo}
translate F GlistRating {Classement}
translate F GlistFindText {Rechercher texte}
translate F GlistMoveField {Coup}
translate F GlistEditField {Configurer}
translate F GlistAddField {Ajouter}
translate F GlistDeleteField {Enlever}
translate F GlistWidth {Largeur}
translate F GlistAlign {Aligner}
translate F GlistAlignL {Aligner: à gauche}
translate F GlistAlignR {Aligner: à droite}
translate F GlistAlignC {Aligner: au centre}
translate F GlistColor {Couleur}
translate F GlistSep {Séparateur}
translate F GlistCurrentSep {-- Actuel --}
translate F GlistNewSort {Nouveau}
translate F GlistAddToSort {Ajouter}

# base sorting
translate F GsortSort {Trier...}
translate F GsortDate {Date}
translate F GsortYear {Année}
translate F GsortEvent {Événement}
translate F GsortSite {Site}
translate F GsortRound {Ronde}
translate F GsortWhiteName {Nom blanc}
translate F GsortBlackName {Nom noir}
translate F GsortECO {ECO}
translate F GsortResult {Résultat}
translate F GsortMoveCount {Nombre de coups}
translate F GsortAverageElo {ELO Moyen}
translate F GsortCountry {Pays}
translate F GsortDeleted {Supprimé}
translate F GsortEventDate {Date de l'événement}
translate F GsortWhiteElo {ELO Blanc}
translate F GsortBlackElo {ELO Noir}
translate F GsortComments {Commentaires}
translate F GsortVariations {Variantes}
translate F GsortNAGs {NAG}
translate F GsortAscending {Ascendant}
translate F GsortDescending {Descendant}
translate F GsortAdd {Ajouter}
translate F GsortStore {Conserver}
translate F GsortLoad {Charger}

# menu shown with right mouse button down on game list.
translate F GlistRemoveSelectedFromFilter {Supprimer les parties sélectionnées du filtre}
translate F GlistExportSelected {Exporter les parties sélectionnées...}
translate F GlistRemoveThisGameFromFilter  {Enlever cette partie du filtre}
translate F GlistRemoveGameAndAboveFromFilter  {Enlever cette partie (et celles au-dessus) du filtre}
translate F GlistRemoveGameAndBelowFromFilter  {Enlever cette partie (et celles en-dessous) du filtre}
translate F GlistDeleteGame {(Dés-)effacer cette partie} 
translate F GlistDeleteAllGames {Effacer toutes les parties du filtre} 
translate F GlistUndeleteAllGames {Dés-effacer toutes les parties du filtre} 
translate F GlistMergeGameInBase {Fusionner la partie dans une autre base} 

# Maintenance window:
translate F DatabaseName {Nom de base:}
translate F TypeIcon {Type icône:}
translate F NumOfGames {Parties:}
translate F NumDeletedGames {Parties supprimées:}
translate F NumFilterGames {Parties dans le filtre:}
translate F YearRange {Années:}
translate F RatingRange {Classements:}
translate F Description {Description}
translate F Flag {Drapeau}
translate F CustomFlags {Drapeaux personnalisés}
translate F DeleteCurrent {Effacer la partie courante}
translate F DeleteFilter {Effacer le filtre de parties}
translate F DeleteAll {Effacer toutes les parties}
translate F UndeleteCurrent {Récupérer la partie en cours}
translate F UndeleteFilter {Récupérer les parties filtrées}
translate F UndeleteAll {Récupérer toutes les parties}
translate F DeleteTwins {Effacer les parties en doublon}
translate F MarkCurrent {Marquer la partie en cours}
translate F MarkFilter {Marquer les parties filtrées}
translate F MarkAll {Marquer toutes les parties}
translate F UnmarkCurrent {Démarquer la partie en cours}
translate F UnmarkFilter {Démarquer les parties filtrées}
translate F UnmarkAll {Démarquer toutes les parties}
translate F Spellchecking {Vérification orthographique}
translate F Players {Joueurs}
translate F Events {Événements}
translate F Sites {Lieux}
translate F Rounds {Rondes}
translate F DatabaseOps {Opérations sur la base}
translate F ReclassifyGames {ECO-Classifier les parties...}
translate F CompactDatabase {Compacter la base}
translate F SortDatabase {Trier la base}
translate F AddEloRatings {Ajouter les classements Elo}
translate F AutoloadGame {Chargement automatique du numéro de partie}
translate F StripTags {Enlever les marqueurs PGN}
translate F StripTag {Enlever les marqueurs}
translate F Cleaner {Nettoyer}
translate F CleanerHelp {\nLe Nettoyeur Scid va réaliser pour la base en cours toutes les actions de maintenance que vous avez sélectionnées à partir de la liste ci-dessous.\n\nLes réglages en cours de la classification ECO et les dialogues d'effacement des doublons vont s'appliquer si vous avez sélectionné ces fonctions.\n}
translate F CleanerConfirm {\nUne fois que le nettoyage est commencé, il ne peut être interrompu!\n\nCela peut prendre beaucoup de temps sur une grande base, suivant les fonctions que vous avez sélectionnées et leurs réglages en cours.\n\nÊtes-vous sûr que vous voulez commencer les fonctions de maintenance que vous avez sélectionnées ?\n}
# Twinchecker
translate F TwinCheckUndelete {pour permuter; "u" pour annuler l'effacement des deux}
translate F TwinCheckprevPair {Paire précédente}
translate F TwinChecknextPair {Paire suivante}
translate F TwinChecker {scidCommunity: vérificateur de doublon}
translate F TwinCheckTournament {Parties dans le tournoi:}
translate F TwinCheckNoTwin {Pas de doublon  }
translate F TwinCheckNoTwinfound {Aucun doublon n'a été détecté pour ce jeu.\nPour afficher les doublons dans cette fenêtre, vous devez d'abord utiliser la fonction "Purger les doublon...". }
translate F TwinCheckTag {Partager tags...}
translate F TwinCheckFound1 {Scid a trouvé $result doublons}
translate F TwinCheckFound2 { et positionné le marqueur de suppression}
translate F TwinCheckNoDelete {Il n'y a pas de parties dans cette base à effacer.}
translate F TwinCriteria1 { Les paramètres pour trouver des doublons risquent de\nfaire que des parties différentes avec des coups similaires soient marquées comme des doublons.}
translate F TwinCriteria2 {Il est recommandé de sélectionner "Non" pour "mêmes coups", vous devriez sélectionner "Oui" pour les couleurs, événement, site, ronde, année et mois.\nVoulez-vous continuer et effacer les doublons quand même ? }
translate F TwinCriteria3 {Il est recommandé de sélectionner "Oui" pour au moins deux des paramètres "même site", "même ronde" et "même année".\nVoulez-vous continuer et effacer les doublons quand même ?}
translate F TwinCriteriaConfirm {scidCommunity: Confirmer les paramètres de doublons}
translate F TwinChangeTag "Changer les tags de partie suivants:\n\n"
translate F AllocRatingDescription "Cette commande va utiliser les fichiers de vérification de noms et de classement Elo pour les parties de cette base. Chaque fois qu'un joueur n'a pas de classement mais que son classement est listé dans le fichier de vérification de noms à la date de la partie, ce classement est pris en compte."
translate F RatingOverride "Remplacer le classement non nul existant"
translate F AddRatings "ajouter classement à:"
translate F AddedRatings {Scid a ajouté $r classements Elo dans $g parties.}

#Bookmark editor
translate F NewSubmenu "Nouveau sous-menu"

# Comment editor:
translate F AnnotationSymbols {Symboles d'annotation:}
translate F Comment {Commentaire:}
translate F Format {Format}
translate F Bold {Gras}
translate F Italic {Italique}
translate F Underline {Souligner}
translate F TextColor {Couleur du texte...}
translate F CommentDefaultColor {Couleur du commentaire par défaut...}
translate F CommentFont {Police…}
translate F RemoveFormatting {Supprimer le formatage}
translate F Family {Famille}
translate F Size {Taille}
translate F FontSizeWarning {La taille de la police doit être un entier positif.}
translate F Green {Vert}
translate F Blue {Bleu}
translate F Red {Rouge}
translate F Brown {Marron}
translate F CustomColor {Couleur personnalisée...}
translate F InsertMark {Insère une marque}
translate F InsertMarkHelp {
Insérer/enlever marque: Sélectionner la couleur, le type et la case.
Insérer/enlever flèche: Clic droit sur deux cases.
}

# Nag buttons in comment editor:
translate F GoodMove {Bon coup}
translate F PoorMove {Coup faible}
translate F ExcellentMove {Excellent coup}
translate F Blunder {Gaffe}
translate F InterestingMove {Coup intéressant}
translate F DubiousMove {Coup douteux}
translate F WhiteDecisiveAdvantage {Les blancs ont un avantage décisif}
translate F BlackDecisiveAdvantage {Les noirs ont un avantage décisif}
translate F WhiteClearAdvantage {Les blancs ont l'avantage}
translate F BlackClearAdvantage {Les noirs ont l'avantage}
translate F WhiteSlightAdvantage {Les blancs ont un léger avantage}
translate F BlackSlightAdvantage {Les noirs ont un léger avantage}
translate F WhiteCrushing {Les blancs ont un avantage écrasant}
translate F BlackCrushing {Les noirs ont un avantage écrasant}
translate F Equality {Égalité}
translate F Unclear {Peu clair}
translate F Diagram {Diagramme}

# Board search:
translate F BoardSearch {Rechercher la position actuelle}
translate F FilterOperation {Opération sur le filtre en cours :}
translate F FilterAnd {ET (Restreint le filtre)}
translate F FilterOr {OU (Ajoute au filtre)}
translate F FilterIgnore {IGNORER (Restaure le filtre initial)}
translate F SearchType {Type de recherche :}
translate F SearchBoardExact {Position exacte, mêmes pièces sur les mêmes cases.}
translate F SearchBoardPawns {Pions, même matériel avec tous les pions sur les mêmes cases.}
translate F SearchBoardFiles {Colonnes, même matériel avec tous les pions sur mêmes colonnes.}
translate F SearchBoardAny {Même matériel, les pions et pièces n'importe où.}
translate F SearchInRefDatabase { Dans la base de référence }
translate F LookInVars {Chercher dans les variantes}

# Moves search:
translate F MovesSearchHint {Coups SAN dans l'ordre, par ex. e4 e5 Cf3. "?" correspond à n’importe quel mouvement.}
translate F LastMoveIsMate {Le dernier coup mate}

# Material search:
translate F MaterialSearch {Rechercher un matériel ou motif}
translate F Material {Matériel}
translate F Patterns {Motifs}
translate F Zero {Zéro}
translate F Any {Tout}
translate F CurrentBoard {Position en cours}
translate F CommonEndings {Finales courantes}
translate F CommonPatterns {Motifs courants}
translate F MaterialDiff {Différence en matériel}
translate F squares {cases}
translate F SameColor {Mêmes couleur}
translate F OppColor {Couleurs opposées}
translate F Either {Les deux}
translate F MoveNumberRange {Intervalle du numéro de coup}
translate F MatchForAtLeast {Correspond pour au moins}
translate F HalfMoves {demi-coups}

# Common endings in material search:
translate F EndingPawns {Finales de pions}
translate F EndingRookVsPawns {Tour contre pion(s)}
translate F EndingRookPawnVsRook {Tour et 1 pion contre Tour}
translate F EndingRookPawnsVsRook {Tour et pion(s) contre Tour}
translate F EndingRooks {Finales Tour contre Tour}
translate F EndingRooksPassedA {Finales de Tour contre Tour avec un pion passé a}
translate F EndingRooksDouble {Finales 2 tours}
translate F EndingBishops {Finales Fou contre Fou}
translate F EndingBishopVsKnight {Finales Fou contre Cavalier}
translate F EndingKnights {Finales Cavalier contre Cavalier}
translate F EndingQueens {Finales Dame contre Dame}
translate F EndingQueenPawnVsQueen {Dame et 1 pion contre Dame}
translate F BishopPairVsKnightPair {Milieu de jeu 2 Fous contre 2 Cavaliers}

# Common patterns in material search:
translate F PatternWhiteIQP {Pion Dame Isolé Blanc} ;# ***
translate F PatternWhiteIQPBreakE6 {Pion Dame Isolé Blanc: percée d4-d5 contre e6} ;# ***
translate F PatternWhiteIQPBreakC6 {Pion Dame Isolé Blanc: percée d4-d5 contre c6} ;# ***
translate F PatternBlackIQP {Pion Dame Isolé Noir} ;# ***
translate F PatternWhiteBlackIQP {Pion Dame Isolé Blanc contre Pion Dame Isolé Noir} ;# ***
translate F PatternCoupleC3D4 {Couple de pions isolés blancs en c3 et d4} ;# ***
translate F PatternHangingC5D5 {Pions noirs pendants en c5 et d5} ;# ***
translate F PatternMaroczy {Centre de Maroczy (avec les pions en c4 et e4)} ;# ***
translate F PatternRookSacC3 {Sacrifice de tour en c3} ;# ***
translate F PatternKc1Kg8 {O-O-O contre O-O (Rc1 vs. Rg8)} ;# ***
translate F PatternKg1Kc8 {O-O contre O-O-O (Rg1 vs. Rc8)} ;# ***
translate F PatternLightFian {Fianchettos de cases blanches (Fou-g2 contre Fou-b7)} ;# ***
translate F PatternDarkFian {Fianchettos de cases noires (Fou-b2 contre Fou-g7)} ;# ***
translate F PatternFourFian {Quatre Fianchettos (Fous en b2, g2, b7, g7)} ;# ***

# Game saving:
translate F SaveExtraTagsHint {Tags supplémentaires : (exemple de format : Annotateur "Anand, V")}
translate F Today {Aujourd'hui}
translate F ClassifyGame {Classer la partie}

# Setup position:
translate F EmptyBoard {Vider l'échiquier}
translate F InitialBoard {Réinitialiser l'échiquier}
translate F SideToMove {Côté qui a le trait}
translate F MoveNumber {Numéro du coup}
translate F Castling {Roque}
translate F EnPassantFile {Prise en passant}
translate F ClearFen {Effacer FEN}
translate F PasteFen {Coller FEN}

translate F SaveAndContinue {Enregistrer et continuer}
translate F DiscardChangesAndContinue {Ignorer changements\net continuer}
translate F GoBack {Retour}

# Replace move dialog:
translate F ReplaceMove {Remplacer le coup}
translate F AddNewVar {Ajouter variante}
translate F NewMainLine {Ligne principale}
translate F ReplaceMoveMessage {Un coup existe déjà.\n\nVous pouvez le remplacer, supprimer tous les coups après ce coup ou ajouter une nouvelle variante.\n\n(Vous pouvez demander à ne plus voir ce message à l'avenir, en désélectionnant l'option "Demander avant de remplacer le coup" dans le menu des options)}

# Make database read-only dialog:
translate F ReadOnlyDialog {Si vous mettez cette base en lecture seule, aucun changement ne sera permis.\nAucune partie ne peut être sauvegardée ou remplacée, et aucun drapeau d'effacement ne peut être altéré.\nTous les tris ou les résultats de classification ECO seront temporaires.\n\nVous pouvez facilement rendre la base à nouveau accessible en écriture, en la fermant et en l'ouvrant à nouveau.\n\nVoulez vous vraiment passer cette base en lecture seule?}

# Clear game dialog:
translate F ClearGameDialog {Cette partie a été modifiée.

Voulez vous vraiment continuer et ignorer les changements effectués?
}

# Exit dialog:
translate F ExitDialog {Voulez vous réellement quitter Scid?}
translate F ExitUnsaved {Les bases de données suivantes ont des parties modifiées non sauvegardées. Si vous quittez maintenant, ces modifications seront perdues.}

# Import window:
translate F PasteCurrentGame {Coller la partie en cours}
translate F ImportHelp1 {Entrer ou coller une partie au format PGN dans le cadre ci-dessus.}
translate F ImportHelp2 {Toutes les erreurs durant l'import de la partie seront affichées ici.}
translate F OverwriteExistingMoves {Effacer les coups existants ?}

# ECO Browser:
translate F ECOAllSections {toutes les sections ECO}
translate F ECOSection {section ECO}
translate F ECOSummary {Résumé pour}
translate F ECOFrequency {Fréquence des sous-codes pour}

# Opening Report:
translate F OprepReportFor {Rapport pour}
translate F OprepTitle {Rapport sur l'ouverture}
translate F OprepReport {Rapport}
translate F OprepGenerated {Généré par}
translate F OprepStatsHist {Statistiques et Historique}
translate F OprepStats {Statistiques}
translate F OprepStatAll {Toutes les parties du rapport}
translate F OprepStatBoth {Les deux joueurs classés}
translate F OprepStatSince {Depuis}
translate F OprepOldest {Les parties les plus anciennes}
translate F OprepNewest {Les parties les plus récentes}
translate F OprepPopular {Popularité actuelle}
translate F OprepFreqAll {Fréquence pour toutes les années: }
translate F OprepFreq1   {Depuis 1 an jusqu'à ce jour:      }
translate F OprepFreq5   {Depuis 5 ans jusqu'à ce jour:     }
translate F OprepFreq10  {Depuis 10 ans jusqu'à ce jour:    }
translate F OprepEvery {une partie sur %u}
translate F OprepUp {%u%s de plus que sur l'ensemble des années}
translate F OprepDown {%u%s de moins que sur l'ensemble des années}
translate F OprepSame {sans changement par rapport à l'ensemble des années}
translate F OprepMostFrequent {Joueurs les plus fréquents}
translate F OprepMostFrequentOpponents {Adversaires les plus fréquents}
translate F OprepRatingsPerf {Classements et performance}
translate F OprepAvgPerf {Classements moyens et performance}
translate F OprepWRating {Classement des blancs}
translate F OprepBRating {Classement des noirs}
translate F OprepWPerf {Performance des blancs}
translate F OprepBPerf {Performance des noirs}
translate F OprepHighRating {Parties avec le classement moyen le plus élevé}
translate F OprepTrends {Tendances de résultat}
translate F OprepResults {Résultats, longueurs et fréquences}
translate F OprepLength {Longueur de partie}
translate F OprepFrequency {Fréquence}
translate F OprepWWins {Gains blancs: }
translate F OprepBWins {Gains noirs:  }
translate F OprepDraws {Nulles:       }
translate F OprepWholeDB {base complète}
translate F OprepShortest {Gains les plus rapides}
translate F OprepMovesThemes {Coups et Thèmes}
translate F OprepMoveOrders {Ordres de coups atteignant la position du rapport}
translate F OprepMoveOrdersOne \
  {Il n'y a qu'un seul ordre de coups pour atteindre cette position:}
translate F OprepMoveOrdersAll \
  {Il y a %u ordres de coups pour atteindre cette position:}
translate F OprepMoveOrdersMany \
  {Il y a %u ordres de coups pour atteindre cette position. Les %u premiers sont:}
translate F OprepMovesFrom {Coups depuis la position du rapport}
translate F OprepMostFrequentEcoCodes {Codes ECO les plus fréquents}
translate F OprepThemes {Thèmes positionnels}
translate F OprepThemeDescription {Fréquence des thèmes dans les premiers %u coups de chaque partie}
translate F OprepThemeSameCastling {Roques du même côté}
translate F OprepThemeOppCastling {Roques du côté opposé}
translate F OprepThemeNoCastling {Aucun roque}
translate F OprepThemeKPawnStorm {Avalanche de pions à l'aile roi}
translate F OprepThemeQueenswap {Dames échangées}
translate F OprepThemeWIQP {Pion Dame blanc isolé}
translate F OprepThemeBIQP {Pion Dame noir isolé}
translate F OprepThemeWP567 {Pion blanc sur la 5/6/7e rangée}
translate F OprepThemeBP234 {Pion noir sur la 2/3/4e rangée}
translate F OprepThemeOpenCDE {Colonne c/d/e ouverte}
translate F OprepTheme1BishopPair {Paire de fous}
translate F OprepEndgames {Finales}
translate F OprepReportGames {Les parties du rapport}
translate F OprepAllGames {Toutes les parties}
translate F OprepEndClass {Classification du matériel des positions finales}
translate F OprepTheoryTable {Table de Théorie}
translate F OprepTableComment {Généré à partir des %u parties au classement le plus élevé.}
translate F OprepExtraMoves {Nombre de coups additionnels dans la table de théorie}
translate F OprepMaxGames {Nombre maximum de parties dans la table de théorie}
translate F OprepMergeMoves {Limite de coups pour les jeux fusionnés}
translate F OprepMergeUnique {Fusionner uniquement les jeux uniques}
translate F OprepViewHTML {Voir en HTML}

# Player Report:
translate F PReportTitle {Rapport sur le joueur}
translate F PReportColorWhite {avec les Blancs pièces}
translate F PReportColorBlack {avec les Noirs pièces}
translate F PReportMoves {après %s}
translate F PReportOpenings {Ouvertures}
translate F PReportClipbase {Vider la Clipbase et copier dedans toutes les parties qui correspondent}

# Piece Tracker window:
translate F TrackerSelectSingle {Le bouton gauche de la souris sélectionne cette pièce.}
translate F TrackerSelectPair {Le bouton gauche de la souris sélectionne cette pièce; le bouton droit sélectionne aussi son double.}
translate F TrackerSelectPawn {Le bouton gauche de la souris sélectionne ce pion ; le bouton droit sélectionne les 8 pions.}
translate F TrackerStat {Statistiques}
translate F TrackerGames {% parties avec déplacement sur la case}
translate F TrackerTime {% fois sur chaque case}
translate F TrackerMoves {Coups}
translate F TrackerMovesStart {Entrer le numéro du coups à partir duquel la recherche doit commencer.}
translate F TrackerMovesStop {Entrer le numéro du coups auquel la recherche doit s'arrêter.}

# Game selection dialogs:
translate F SelectAllGames {Toutes les parties de la base}
translate F SelectFilterGames {Seulement les parties du filtre}
translate F SelectTournamentGames {Seulement les parties du tournoi courant}
translate F SelectOlderGames {Seulement les parties plus anciennes}

# Delete Twins window:
translate F TwinsNote {Pour être considérées comme doublons, deux parties doivent au moins avoir les deux mêmes joueurs, et avoir les critères que vous pouvez fixer ci-dessous satisfaits. Quand une paire de doublons est trouvée, la partie la plus courte est effacée. Conseil: il est préférable de vérifier l'orthographe dans la base avant d'effacer les doublons, car cela améliore la détection des doublons. }
translate F TwinsCriteria {Critère: Les doublons doivent avoir...}
translate F TwinsWhich {Parties à examiner}
translate F TwinsColors {Même couleurs de joueurs}
translate F TwinsEvent {Même événement}
translate F TwinsSite {Même lieu}
translate F TwinsRound {Même ronde}
translate F TwinsYear {Même année}
translate F TwinsMonth {Même mois}
translate F TwinsDay {Même jour}
translate F TwinsResult {Même résultat}
translate F TwinsECO {Même code ECO}
translate F TwinsMoves {Mêmes coups}
translate F TwinsPlayers {Comparaison des noms des joueurs}
translate F TwinsPlayersExact {Correspondance exacte}
translate F TwinsPlayersPrefix {Les 4 premières lettres seules}
translate F TwinsWhen {En effaçant les doublons}
translate F TwinsSkipShort {Ignorer toutes les parties de moins de cinq coups}
translate F TwinsUndelete {Récupérer toutes les parties d'abord}
translate F TwinsSetFilter {Appliquer le filtre à tous les doublons éliminés}
translate F TwinsComments {Toujours garder les parties qui comportent des commentaires}
translate F TwinsVars {Toujours garder les parties qui comportent des variantes}
translate F TwinsDeleteWhich {Partie à effacer}
translate F TwinsDeleteShorter {La partie la plus courte}
translate F TwinsDeleteOlder {La partie avec le plus petit numéro}
translate F TwinsDeleteNewer {La partie avec le plus grand numéro}
translate F TwinsDelete {Effacer les doublons}

# Name editor window:
translate F NameEditType {Taper le nom à éditer}
translate F NameEditSelect {Parties à éditer}
translate F NameEditReplace {Remplacer}
translate F NameEditWith {avec}
translate F NameEditMatches {Correspondances: Presser Ctrl+1 à Ctrl+9 pour sélectionner}
translate F NameEditWildcard {Caractère joker pour les noms : * = n'importe quel caractère (1* = commence par 1, *Whelan = se termine par Whelan)}

# Check games window:
translate F CheckGames {Vérifier les parties}
translate F CheckGamesWhich {Vérifier les parties}
translate F CheckAll {Toutes les parties}
translate F CheckSelectFilterGames {Uniquement les parties filtrées}

# Classify window:
translate F Classify {Classer}
translate F ClassifyWhich {Choix des parties à classer suivant ECO}
translate F ClassifyAll {Toutes les parties (écrase les anciens codes ECO)}
translate F ClassifyYear {Toutes les parties jouées la dernière année}
translate F ClassifyMonth {Toutes les parties jouées le dernier mois}
translate F ClassifyNew {Seulement les parties qui ne possèdent pas encore de code ECO}
translate F ClassifyCodes {Codes ECO à utiliser}
translate F ClassifyBasic {Codes ECO de base seulement ("B12", ...)}
translate F ClassifyExtended {Extensions ECO de Scid ("B12j", ...)}
translate F ClassifyResult {Classement ECO terminé : $jeu(s) résultat(s) mis à jour.}

# Compaction:
translate F NameFile {Fichier de noms}
translate F GameFile {Fichier de parties}
translate F Names {Noms}
translate F Unused {Non utilisé}
translate F SizeKb {Taille (kb)}
translate F CurrentState {État courant}
translate F AfterCompaction {Après compactage}
translate F CompactNames {Compacter le fichier de noms}
translate F CompactGames {Compacter le fichier de parties}
translate F NoUnusedNames "Il n'y a pas de noms inutilisés, le fichier de noms est donc déjà compacté."
translate F NoUnusedGames "Le fichier des parties est déjà compacté."
translate F GameFileCompacted {Le fichier de parties de la base a été compacté.}

# Sorting:
translate F SortCriteria {Critère}
translate F AddCriteria {Ajouter un critère}
translate F CommonSorts {Tris courants}
translate F Sort {Tri}

# Exporting:
translate F AddToExistingFile {Ajouter les parties à un fichier existant}
translate F ExportComments {Exporter les commentaires}
translate F ExportVariations {Exporter les variantes}
translate F IndentComments {Indenter les commentaires}
translate F IndentVariations {Indenter les variantes}
translate F ExportColumnStyle {Style en colonne (un coup par ligne)}
translate F ExportSymbolStyle {Style d'annotation symbolique:}
translate F ExportStripMarks {Enlever les codes de marquages de flèches et de coloration de cases des commentaires}
translate F OptionsExportEol {Fins de lignes :}
translate F OptionsExportEolNative {Native}
translate F OptionsPGNExport {Exportation PGN}
translate F OptionsTagOrderIntro {Ordre des balises PGN restantes lors de l’écriture d’un jeu. La liste des sept balises est toujours écrite en premier, conformément à la norme PGN.}
translate F OptionsTagOrderStr {Liste de sept tags (fixe) : événement, site, date, tour, blanc, noir, résultat}
translate F OptionsTagOrderWhite {Classement Blancs}
translate F OptionsTagOrderBlack {Classement Noirs}
translate F OptionsTagOrderOthers {Autres balises}
translate F OptionsTagOrderSort {Trier les autres balises par ordre alphabétique (sinon dans l'ordre d'origine)}
translate F Up {Monter}
translate F Down {Descendre}

# Goto game/move dialogs:
translate F LoadGameNumber {Entrer le numéro de la partie à charger:}
translate F GotoMoveNumber {Aller au coup numéro:}

# Copy games dialog:
translate F CopyAllGames {Copiez tous les jeux dans}
translate F CopyGames {Copier les parties}
translate F CopyConfirm {
 Voulez vous vraiment copier
 les [::utils::thousands $nGamesToCopy] parties filtrées
 depuis la base "$fromName"
 vers la base "$targetName"?
}
translate F CopyErr {Ne peut pas copier les parties}
translate F CopyErrSource {la base source}
translate F CopyErrTarget {la base destination}
translate F CopyErrNoGames {n'a pas de parties dans son filtre}
translate F CopyErrReadOnly {est en lecture seule}
translate F CopyErrNotOpen {n'est pas ouverte}

# Colors:
translate F LightSquares {Cases blanches}
translate F DarkSquares {Cases noires}
translate F PickColorFromScreen {Choisir la couleur sur l'écran}
translate F SaveCurrentColors {Enregistrer les couleurs actuelles}
translate F SaveCurrentColorsHint {Ajouter les couleurs actuelles du tableau à la liste prédéfinie}
translate F RemoveSavedColor {Supprimer ce préréglage de couleurs enregistré}
translate F ColorPresetExists {Ces couleurs sont déjà enregistrées en tant que préréglage %d}
translate F SelectedSquares {Cases sélectionnées}
translate F SuggestedSquares {Cases des coups suggérés}
translate F WhitePieces {Pièces blanches}
translate F BlackPieces {Pièces noires}
translate F WhiteBorder {Bordure des pièces blanches}
translate F BlackBorder {Bordure des pièces noires}

# Novelty window:
translate F FindNovelty {Trouver la nouveauté}
translate F Novelty {Nouveauté}
translate F NoveltyInterrupt {Recherche de nouveauté interrompue}
translate F NoveltyNone {Aucune nouveauté n'a été trouvée pour cette partie}
translate F NoveltyHelp {Scid va trouver le premier coup de la partie en cours qui atteint une position qui ne figure ni dans la base sélectionnée ni dans le répertoire d'ouvertures ECO.}

# Sounds configuration:
translate F SoundsFolder {Répertoire des fichiers sonores}
translate F SoundsFolderHelp {Le répertoire devrait contenir les fichiers King.wav, a.wav, 1.wav, etc}
translate F SoundsTheme {Thème sonore}
translate F SoundsThemeDefault {Par défaut (Scid)}
translate F SoundsThemeHelp {Les sons de mouvement/événement proviennent du thème sélectionné. Pour ajouter un thème personnalisé, copiez un dossier de vos propres sons dans le répertoire des thèmes.}
translate F SoundsAnnounceOptions {Options d'annonce des coups}
translate F SoundsAnnounceNew {Annoncer les coups joués}
translate F SoundsMoveSoundOnly {Déplacer le son uniquement (désactiver les annonces)}
translate F SoundsAnnounceForward {Annoncer les coups quand on avance d’un coup}
translate F SoundsAnnounceBack {Annoncer les coups quand on recule d’un coup}
translate F SoundsSoundDisabled {Scid n'a pas pu trouver le paquet audio de Snack au démarrage;\nle son est désactivé.}

# Upgrading databases:
translate F Upgrading {Mise à jour}
translate F ConfirmOpenNew {
Ceci est une base de données à l'ancien format (Scid 3) qui ne peut être ouverte dans Scid 4, mais une version au nouveau format (Scid 4) a déjà été crée.

Voulez vous ouvrir le nouveau format de la base de données?
}
translate F ConfirmUpgrade {
Ceci est une base de données à l'ancien format (Scid 3). Une version de la base de données au nouveau format doit être créée avant de pouvoir être utilisée dans Scid 4.

Mettre à jour va créer une nouvelle version de la base de données; les fichiers originaux seront effacés.

Cela peut prendre un peu de temps, mais il n'est nécessaire de le faire qu'une fois. Vous pouvez abandonner si cela dure trop longtemps.

Voulez vous mettre à jour cette base de données maintenant?
}

# Recent files options:
translate F RecentFilesMenu {Nombre de fichiers récents dans le menu Fichier}
translate F RecentFilesExtra {Nombre de fichiers récents dans le sous-menu complémentaire}

# My Player Names options:
translate F MyPlayerNamesDescription {Entrer ci-dessous une liste des noms des joueurs préférés, un nom par ligne. Les caractères jokers (i.e. "?" pour un seul caractère, "*" pour n'importe quelle suite de caractères) sont autorisés.\nChaque fois qu'une partie avec un joueur de la liste est chargée, l'échiquier de la fenêtre principale sera tourné si nécessaire de façon à montrer la partie selon le point de vue du joueur.\n}

# Computer Tournament:
translate F configComp {Configurer le tournoi}
translate F Tournament {Tournoi}
translate F Available {Disponible}
translate F Selected {Choisi}
translate F RoundRobin {Tournoi toutes rondes}
translate F Gauntlet {Tournoi par défi}
translate F CompGameNext {Prochaine partie :}
translate F TimeperGame {Temps par\nPartie}
translate F TimeperMove {Temps par\nCoup}
translate F compStoreTime {Enregistrer les temps}
translate F Clock {Pendule}
translate F compConcurrent {Parties simultanées}
translate F compShowBoards {Afficher les échiquiers}
translate F compCarousel {Système de carrousel}
translate F compSaveEval {Enregistrer l'évaluation}
translate F compCanceledGames {Parties annulées ou expirées :}
translate F Replay {Rejouer}
translate F compStart {Commencer}
translate F compSave {Sauvegardez après chaque partie}
translate F compStop {Arrêter après la fin de la partie active.}
translate F compRunning {Tournoi en cours}
translate F Restart {Redémarrage}
translate F compFinished {Tournoi terminé}
translate F compStopped {Tournoi arrêté}
translate F compForceDraw {Forcer la nulle}
translate F compForceResign {Forcer l'abandon}
translate F compAfterMove {Après le coup :}
translate F compNumMoves {Nombre de coups :}
translate F compScoreLess {Score < :}
translate F compScoreGreater {Score > :}
translate F compRepeatReverse {Répéter en sens inverse}

#Coach
translate F showblunderexists {Montrer s’il y a une gaffe}
translate F showblundervalue {Montrer la valeur de la gaffe}
translate F showscore {Montrer score}
translate F coachgame {Entraînement}
translate F white {blancs}
translate F black {noirs}
translate F both {les deux}
translate F configurePlayEngine {Jouer contre le moteur}
translate F UseChessClock {Utiliser une pendule}
translate F Play {Jouer}
translate F Noblunder {Pas de gaffe}
translate F blunder {gaffe}
translate F Noinfo {-- Pas d'info --}
translate F moveblunderthreshold {le coup est une gaffe si les pertes sont supérieures à }
translate F limitanalysis {limiter le temps d'analyse}
translate F seconds {secondes}
translate F Abort {Arrêter}
translate F Resume {Reprendre}
translate F OutOfOpening {Hors de l'ouverture}
translate F NotFollowedLine {Vous n'avez pas suivi la ligne}
translate F DoYouWantContinue {Voulez-vous continuer ?}
translate F CoachIsWatching {L'entraîneur regarde}
translate F Ponder {Réflexion permanente}
translate F LimitELO {Limiter la force Elo}
translate F DubiousMovePlayedTakeBack {Coup douteux joué, voulez-vous reprendre le coup ?}
translate F WeakMovePlayedTakeBack {Coup faible joué, voulez-vous reprendre le coup ?}
translate F BadMovePlayedTakeBack {Mauvais coup joué, voulez-vous reprendre le coup ?}
translate F Iresign {J'abandonne}
translate F ResultSaved {Résultat enregistré}
translate F yourmoveisnotgood {Votre coup n'est pas bon}
translate F EndOfVar {Fin de variante}
translate F Openingtrainer {Entraînement aux ouvertures}
translate F DisplayCM {Afficher les coups candidats}
translate F DisplayCMValue {Afficher la valeur des coups candidats}
translate F DisplayOpeningStats {Montrer statistiques}
translate F ShowReport {Montrer rapport}
translate F NumberOfGoodMovesPlayed {bons coups joués}
translate F NumberOfDubiousMovesPlayed {coups douteux joués}
translate F NumberOfMovesPlayedNotInRepertoire {coups joués absents du répertoire}
translate F NumberOfTimesPositionEncountered {nombre de fois où la position a été rencontrée}
translate F PlayerBestMove  {N'autoriser que les meilleurs coups}
translate F OpponentBestMove {L'adversaire ne joue que les meilleurs coups}
translate F OnlyFlaggedLines {Seulement les lignes marquées}
translate F resetStats {Remettre à zéro les statistiques}
translate F Repertoiretrainingconfiguration {Configuration entraînement répertoire}
translate F Loadingrepertoire {Chargement du répertoire}
translate F Movesloaded {Coups lus}
translate F Repertoirenotfound {Répertoire introuvable}
translate F Openfirstrepertoirewithtype {Ouvrez d'abord une base avec le bon type/icône sur le côté droit}
translate F Movenotinrepertoire {Coup absent du répertoire}
translate F PositionsInRepertoire {Positions dans le répertoire}
translate F PositionsNotPlayed {Positions non jouées}
translate F PositionsPlayed {Positions jouées}
translate F Success {Succès}
translate F DubiousMoves {Coups douteux}
translate F OutOfRepertoire {Hors du répertoire}
translate F ConfigureTactics {Configurer les exercices tactiques}
translate F ResetScores {Remise à zéro des scores}
translate F LoadingBase {Chargement de la base}
translate F Tactics {Tactiques }
translate F ShowSolution {Montrer la solution}
translate F NextExercise {Exercice suivant}
translate F PrevExercise {Exercice précédent}
translate F StopTraining {Arrêter l'entraînement}
translate F Next {Suivant}
translate F ResettingScore {Remise à zéro des scores}
translate F LoadingGame {Chargement partie}
translate F MateFound {Mat trouvé}
translate F BestSolutionNotFound {Meilleur coup non trouvé !}
translate F MateNotFound {Mat non trouvé}
translate F ShorterMateExists {Un mat plus rapide existe}
translate F ScorePlayed {score coup joué}
translate F Expected {attendu}
translate F ChooseTrainingBase {Choisir la base d’entraînement}
translate F Thinking {Calcul en cours}
translate F AnalyzeDone {Analyse terminée}
translate F WinWonGame {Terminer partie gagnée}
translate F TacticsEngineStartFail {Impossible de démarrer le moteur de tactiques : %s}
translate F TacticsEngineGone {Le moteur de tactiques s'est arrêté : %s}
translate F TacticsNoAssessment {Le moteur n'a fourni aucune évaluation pour cette position}
translate F Lines {Lignes}
translate F ConfigureUCIengine {Configurer le moteur UCI}
translate F SpecificOpening {Ouverture spécifique}
translate F StartNewGame {Nouvelle partie}
translate F Opening {Ouverture}
translate F StartFromCurrentPosition {Jouer depuis la position actuelle}
translate F ShowDigitalClock {Montrer la pendule digitale}
translate F ClockFromGame {Commencer depuis le temps indiqué dans la partie}
translate F ClocksContinued {Continuer avec les pendules de la partie}
translate F ClocksRestarted {Pendule remise à zéro}
translate F FixedDepth {Profondeur fixe}
translate F Nodes {Nœuds} 
translate F Depth {Profondeur}
translate F Time {Temps} 
translate F SecondsPerMove {Secondes par coup}
translate F Engine {Moteur}
translate F TimeMode {Mode de réflexion}
translate F TimeBonus {Temps + bonus}
translate F TimeMin {min}
translate F TimeSec {sec}
translate F AllExercisesDone {Tous les exercices sont faits}
translate F FindOpeningErrors {Chercher les erreurs d'ouverture}
translate F MarkTacticalExercises {Marquer les exercices tactiques}
translate F UseBook {Utiliser une bibliothèque d'ouverture}
translate F MultiPV {Variante multiple}
translate F Hash {Mémoire}
translate F OwnBook {Utiliser bibliothèque propre}
translate F BookFile {Bibliothèque d'ouverture}
translate F AddScoreToShortAnnotations {Ajouter le score aux annotations}
translate F AddScoreToAllMoves {Ajouter le score à tous les coups}
translate F Export {Exporter}
translate F BookPartiallyLoaded {Bibliothèque chargée partiellement}
# Opening names used in tacgame.tcl
translate F Reti {Reti}
translate F English {Anglaise}
translate F d4Nf6Miscellaneous {1.d4 Cf6 divers}
translate F Trompowsky {Trompowsky}
translate F Budapest {Budapest}
translate F OldIndian {Vieille Indienne}
translate F BenkoGambit {Gambit Benko}
translate F ModernBenoni {Benoni Moderne}
translate F DutchDefence {Défense hollandaise}
translate F Scandinavian {Scandinave}
translate F AlekhineDefence {Défense Alekhine}
translate F Pirc {Pirc}
translate F CaroKann {Caro-Kann}
translate F CaroKannAdvance {Caro-Kann, variante d’avance}
translate F Sicilian {Sicilienne}
translate F SicilianAlapin {Sicilienne Alapin}
translate F SicilianClosed {Sicilienne fermée}
translate F SicilianRauzer {Sicilienne Rauzer}
translate F SicilianDragon {Sicilienne Dragon}
translate F SicilianScheveningen {Sicilienne Scheveningen}
translate F SicilianNajdorf {Sicilienne Najdorf}
translate F OpenGame {Partie ouverte}
translate F Vienna {Viennoise}
translate F KingsGambit {Gambit Roi}
translate F RussianGame {Petroff}
translate F ItalianTwoKnights {Italienne/Deux cavaliers}
translate F Spanish {Espagnole}
translate F SpanishExchange {Espagnole d’échange}
translate F SpanishOpen {Espagnole ouverte}
translate F SpanishClosed {Espagnole fermée}
translate F FrenchDefence {Défense française}
translate F FrenchAdvance {Défense française d’avance}
translate F FrenchTarrasch {Défense française Tarrasch}
translate F FrenchWinawer {Défense française Winawer}
translate F FrenchExchange {Défense française d’échange}
translate F QueensPawn {Pion Dame}
translate F Slav {Slave}
translate F QGA {GD Accepté}
translate F QGD {GD Décliné}
translate F QGDExchange {GD Échange}
translate F SemiSlav {Semi-Slave}
translate F QGDwithBg5 {GD décliné avec Fg5}
translate F QGDOrthodox {GD décliné Orthodoxe}
translate F Grunfeld {Grünfeld}
translate F GrunfeldExchange {Grünfeld d’échange}
translate F GrunfeldRussian {Grünfeld Russe}
translate F Catalan {Catalane}
translate F CatalanOpen {Catalane Ouverte}
translate F CatalanClosed {Catalane Fermée}
translate F QueensIndian {Ouest indienne}
translate F NimzoIndian {Nimzo-Indienne}
translate F NimzoIndianClassical {Nimzo-Indienne Classique}
translate F NimzoIndianRubinstein {Nimzo-Indienne Rubinstein}
translate F KingsIndian {Est-indienne}
translate F KingsIndianSamisch {Est-indienne Sämisch}
translate F KingsIndianMainLine {Est-indienne ligne principale}

# FICS
translate F ConfigureFics {Configurer FICS}
translate F FICSGuest {Se connecter comme invité}
translate F FICSServerPort {Port du serveur}
translate F FICSServerAddress {Adresse IP}
translate F FICSRefresh {Rafraîchir}
translate F FICSTimesealPort {Port Timeseal}
translate F FICSSilence {Filtrer la console}
translate F FICSOffers {Offres}
translate F FICSConsole {Console}
translate F FICSGames {Parties}
translate F FICSUnobserve {Arrêter de suivre la partie}
translate F FICSProfile {Afficher mon historique et mes données}
translate F FICSRelayedGames {Parties retransmises}
translate F FICSFindOpponent {Trouver adversaire}
translate F FICSTakeback {Reprendre un coup}
translate F FICSTakeback2 {Rependre deux coups}
translate F FICSInitTime {Temps initial (min)}
translate F FICSIncrement {Incrément (sec)}
translate F FICSRatedGame {Partie classée}
translate F FICSAutoColour {automatique}
translate F FICSManualConfirm {accepter manuellement}
translate F FICSFilterFormula {Filtrer avec formule}
translate F FICSIssueSeek {Envoyer seek}
translate F FICSChallenge {Challenge}
translate F FICSAccept {Accepter ?}
translate F FICSDecline {refuser}
translate F FICSColour {Couleur}
translate F FICSSend {envoyer}
translate F FICSConnect {Connecter}
translate F FICSdefaultuservars {Variables par défaut}
translate F FICSObserveconfirm {Voulez-vous suivre la partie}
translate F FICSpremove {Autoriser les pre-coups}
translate F FICSObserve {Observer}
translate F FICSRatedGames {Parties classée}
translate F FICSUnratedGames {Partie non classée}
translate F FICSRated {classée}
translate F FICSUnrated {non classée}
translate F FICSRegisteredPlayer {Joueur enregistré seulement}
translate F FICSFreePlayer {Joueur libre seulement}
translate F FICSNetError {Erreur de réseau\nPas de connexion à }
translate F OptionsFICS {FICS}
translate F FICSTerminalColor {Couleur du terminal}
translate F FICSTextColor {Couleur du texte}

# Game review

# Correspondence Chess Dialogs:
translate F CCDlgCGeneraloptions {Options générales}
translate F CCDlgLoginName  {Login:}
translate F CCDlgPassword   {Mot de passe:}
translate F CCDlgShowPassword {Montrer le mot de passe}

# Connect Hardware dialogs
translate F ExtHWConfigConnection {Configurer un matériel externe}
translate F ExtHWPort {Port}
translate F ExtHWEngineCmd {Commande moteur}
translate F ExtHWEngineParam {Paramètre moteur}
translate F ExtHWShowButton {Montrer bouton}
translate F ExtHWHardware {Matériel}
translate F ExtHWNovag {Novag Citrine}
translate F ExtHWInputEngine {Protocole Input Engine}
translate F ExtHWNoBoard {Pas d'échiquier}
translate F NovagReferee {Arbitre}

# Input Engine dialogs
translate F IEConsole {Console Input Engine}
translate F IESending {Coups envoyés pour}
translate F IESynchronise {Synchroniser}
translate F IERotate  {Tourner}
translate F IEUnableToStart {Impossible de démarrer le protocole Input Engine :}

translate F Board {Échiquier}
translate F showGameInfo {Montrer le panneau d'info}
translate F autoResizeBoard {Redimensionnement automatique}
translate F DockTop {Déplacer en haut}
translate F DockBottom {Déplacer en bas}
translate F DockLeft {Déplacer à gauche}
translate F DockRight {Déplacer à droite}
translate F Undock {Détacher}
translate F Dock {Ancrer}

# Switcher window
translate F AboutDatabase {À propos de cette base de données}
translate F ChangeIcon {Changer l'icône...}
translate F NewGameListWindow {Nouvelle fenêtre de liste de parties}
translate F LoadatStartup {Charger au démarrage}

# Gamelist window
translate F ShowHideDB {Afficher/Masquer les bases de données}
translate F ChangeFilter {Remplacer le filtre}
translate F ChangeLayout {Charger/Enregistrer/Modifier les critères de tri et la disposition des colonnes.}
translate F ShowHideStatistic {Afficher/Masquer les statistiques}
translate F BoardFilter {Afficher uniquement les parties qui correspondent à la position actuelle de l’échiquier}
translate F CopyGameTo {Copier la partie dans}
translate F FindBar {Barre de recherche}
translate F FindCurrentGame {Trouver la partie actuelle}
translate F DeleteGame {Supprimer la partie}
translate F UndeleteGame {Restaurer la partie}
translate F ResetSort {Réinitialiser le tri}
translate F LayoutExists {La mise en page '%s' existe déjà.}
translate F ConfirmDeleteLayout {Êtes-vous sûr de vouloir supprimer la mise en page '%s' ?}
translate F ConfirmStripGames {Supprimer les annotations de %d partie(s) sélectionnée(s) ?}

translate F ConvertNullMove {Convertir les coups nuls en commentaires}
translate F SetupBoard {Définir la position de départ}
translate F Rotate {Rotation}
translate F SwitchColors {Changer de couleur}
translate F FlipBoard {Retourner l'échiquier}
translate F Board3D {Échiquier 3D}
translate F Board3DReset {Réinitialiser}
translate F Board3DResetTip {Réinitialiser la caméra à la vue par défaut}
translate F Board3DZoomIn {Zoomer}
translate F Board3DZoomOut {Zoom arrière}
translate F Board3DDragToRotate {Faites glisser pour faire pivoter}
translate F Board3DScrollToZoom {Faites défiler pour zoomer}
translate F ImportPGN {Importer une partie PGN}
translate F ImportingFiles {Importer des fichiers PGN dans}
translate F ImportingFrom {Importation de}
translate F ImportingIn {Importer des parties dans}
translate F UseLastTag {Utilisez les tags de la dernière partie}
translate F Random {Aléatoire}
translate F BackToMainline {Revenir à la ligne principale}
translate F LeaveVariant {Quitter la variante}
translate F Autoplay {Jeu automatique}
translate F ShowHideCoords {Afficher/Masquer Coord.}
translate F ShowHideEvalBar {Afficher/Masquer la barre d'évaluation}
translate F ShowHideMaterial {Afficher/Masquer matériel}
translate F SelectMarker {Sélectionner un marqueur}
translate F FullScreen {Plein écran}
translate F FilterStatistic {Filtrer les statistiques}
translate F MakeCorrections {Corriger}
translate F Surnames {Noms de famille}
translate F Ambiguous {Ambigus}

#Preferences Dialog
translate F OptionsToolbar "Barre d'outils de la fenêtre principale"
translate F OptionsBoard "Échiquier"
translate F OptionsBoardSize "Taille d'échiquier"
translate F OptionsBoardPieces "Style des pièces"
translate F OptionsInternationalization "Internationalisation"
translate F OptionsTablebaseDir "Sélectionnez jusqu'à 4 dossiers de tables de finales:"

# Evaluation bar
translate F BestMoveArrow "Flèche du meilleur coup"
translate F NewLocalEngine "+ Nouveau moteur..."

# Batch Annotate
translate F BatchAnnotate {Annoter par lots}
translate F BatchEngineSelection {Sélection du moteur}
translate F BatchChessEngine {Moteur d'échecs :}
translate F BatchNumberOfInstances {Nombre d'instances :}
translate F BatchTimePerMove {Temps par mouvement (sec) :}
translate F BatchAnnotateBlunders {Annoter uniquement les erreurs}
translate F BatchBlunderThreshold {Seuil d'erreur :}
translate F BatchVariationLength {Longueur de variation (coups) :}
translate F BatchOpeningBook {Livre d'ouverture}
translate F BatchUseBook {Utiliser le livre}
translate F BatchAnnotateVariations {Annoter les variantes}
translate F BatchShortAnnotations {Annotations courtes}
translate F BatchAddScoreToShort {Ajouter une partition aux annotations courtes}
translate F BatchClearOld {Effacer les anciens commentaires et variantes}
translate F BatchInitializingEngines {Initialisation des moteurs...}
translate F BatchAnalyzingGames {Analyse des parties…}
translate F BatchProgress {Progression d'annotation par lots}
translate F BatchComplete {Annotation par lots terminée !}
translate F BatchCancelled {Annotation par lots annulée}
translate F BatchStart {Commencer}
translate F BatchCancel {Annuler}
translate F BatchCompleted {complété}
translate F BatchGames {Parties }
translate F BatchProcessed {traité}
translate F BatchUnscoredPlies {demi-coups sans verdict: %s}
translate F TablebaseWindow {Fenêtre de table de finales}
translate F TBWinMoves {--- Coups gagnants ---}
translate F TBDrawMoves {--- Coups nuls --- }
translate F TBLossMoves {--- Coups perdants --- }
translate F TBNoMoves {Aucun coup légal trouvé.}
translate F TBTooMany {Trop de pièces. La base de finale Lichess prend en charge jusqu'à 7 pièces.}
translate F TBQuerying {Interrogation de l'API Lichess...}
translate F TBError {Erreur lors du lancement de curl pour interroger Lichess.}
translate F TBQueryError {Réponse non valide de l'API tablebase.}
translate F TBNotFound {Position introuvable dans la base de finale ou erreur API.}
translate F TBCategory {Catégorie de position :}
translate F TBTrainingHidden {(Mode Entraînement ; les résultats sont masqués)}

# ICCF (International Correspondence Chess Federation)
menuText F ToolsTrainICCF "Jouer sur ICCF" 0 {Jouer sur ICCF}
translate F ICCFTitle {Jouer sur ICCF}
translate F ICCFLogin {Nom d'utilisateur}
translate F ICCFPassword {Mot de passe}
translate F ICCFConnect {Connecter}
translate F ICCFClose {Fermer}
translate F ICCFUpdateGames {Mettre à jour les parties}
translate F ICCFSendMoves {Envoyer des coups}
translate F ICCFYourMessage {Votre message}
translate F ICCFGameID {Partie}
translate F ICCFOpponent {Adversaire}
translate F ICCFEvent {Événement}
translate F ICCFLastMove {Dernier coup}
translate F ICCFSent {Envoyé}
translate F ICCFYourMove {Votre coup}
translate F ICCFOfferDraw {Proposer nulle}
translate F ICCFResign {Abandonner}
translate F ICCFWaiting {En attente}
translate F ICCFYourTurn {À votre tour}
translate F ICCFCredentialsNeeded {Veuillez saisir votre nom d'utilisateur et votre mot de passe ICCF.}
translate F ICCFUpdating {Récupération des parties depuis le serveur ICCF...}
translate F ICCFGamesUpdated {Parties : %s ajoutées, %s coups mis à jour, %s à jour}
translate F ICCFSendingMoves {Envoi des coups au serveur ICCF...}
translate F ICCFMovesSent {Coups envoyés : %s réussis, %s échoués}
translate F ICCFNoGamesFound {Aucune partie trouvée.}
translate F ICCFFilterError {Erreur de filtre.}
translate F ICCFConnectionFailed {Échec de la connexion au serveur ICCF. Vérifiez votre réseau.}
translate F ICCFAuthFailed {L'authentification a échoué. Vérifiez votre nom d'utilisateur et votre mot de passe.}
translate F ICCFNeedUpdate {Veuillez d'abord appuyer sur « Mettre à jour les parties » pour récupérer les données des parties actuelles sur le serveur.}
translate F ICCFNoDatabase {Aucune base de données n'est actuellement ouverte. Veuillez d'abord ouvrir une base de données.}
translate F ICCFMyTime {Ma pendule}
translate F ICCFOppTime {Pendule adverse}
translate F ICCFDrawOffered {Nulle offerte}
# LSS (Lechenicher SchachServer)
menuText F ToolsTrainLSS "Jouer sur LSS" 0 {Jouez sur Lechenicher SchachServer}
translate F LSSTitle {Jouer sur LSS - Lechenicher SchachServer}
translate F LSSConfigure {Configurer LSS}
translate F LSSServer {Serveur LSS}
translate F LSSLogin {Nom d'utilisateur}
translate F LSSPassword {Mot de passe}
translate F LSSConnect {Connecter}
translate F LSSClose {Fermer}
translate F LSSUpdateGames {Mettre à jour les parties}
translate F LSSSendMoves {Envoyer des coups}
translate F LSSGamesList {Liste des parties}
translate F LSSOpponentMessage {Message de l'adversaire}
translate F LSSYourMessage {Votre message}
translate F LSSGameID {Partie}
translate F LSSOpponent {Adversaire}
translate F LSSTime {Temps}
translate F LSSWhiteElo {ELO Blancs}
translate F LSSBlackElo {ELO Noirs}
translate F LSSEvent {Événement}
translate F LSSLastMove {Dernier coup}
translate F LSSSent {Envoyé}
translate F LSSYourMove {Votre coup}
translate F LSSOfferDraw {Proposer nulle}
translate F LSSResign {Abandonner}
translate F LSSWaiting {En attente}
translate F LSSYourTurn {À votre tour}
translate F LSSCredentialsNeeded {Veuillez saisir votre nom d'utilisateur et votre mot de passe LSS.}
translate F LSSUpdating {Récupération des parties depuis le serveur LSS...}
translate F LSSGamesUpdated {Parties : %s ajoutées, %s coups mis à jour, %s à jour}
translate F LSSSendingMoves {Envoi des coups au serveur LSS...}
translate F LSSMovesSent {Coups envoyés : %s réussis, %s échoués}
translate F LSSNoGamesFound {Aucune partie trouvée.}
translate F LSSFilterError {Erreur de filtre.}
translate F LSSConnectionFailed {Échec de la connexion au serveur LSS. Vérifiez votre réseau.}
translate F LSSAuthFailed {L'authentification a échoué. Vérifiez votre nom d'utilisateur et votre mot de passe.}
translate F LSSNeedUpdate {Veuillez d'abord appuyer sur « Mettre à jour les parties » pour récupérer les données des parties actuelles sur le serveur.}
translate F LSSNoDatabase {Aucune base de données n'est actuellement ouverte. Veuillez d'abord ouvrir une base de données.}
translate F LSSGameNumber {LSS}
translate F LSSMyTime {Mon temps}
translate F LSSOppTime {Temps adversaire}
translate F LSSDrawOffered {Nulle proposée}

# RTF Export and Import
translate F RtfExportTitle {Exporter vers un fichier RTF}
translate F RtfExportError {Erreur lors de l'exportation au format RTF}
translate F RtfImportTitle {Importer un fichier RTF}
translate F RtfImportError {Erreur lors de l'importation du fichier RTF}
translate F RtfNotScidFile {Ce fichier n'a pas été exporté par scidCommunity avec le formatage des commentaires, ou est corrompu.}
translate F RtfImportSuccess {Partie importée avec succès dans la base de données du presse-papiers.}
translate F RtfImportSuccessMulti {%d parties importées avec succès dans la base de données du presse-papiers.}

# Review progress pane (#422 item 3).
# Keep this block before the CQL entries: the language files carry it there,
# and tcl/lang/propagatelang.tcl compares entry positions.
translate F ReviewProgressTitle {Examiner les progrès}
translate F ReviewProgressIdle {Aucune analyse n’est en cours}
translate F ReviewProgressGameOf {partie %s de %s}
translate F ReviewProgressEngineWindow {Fenêtres moteur %s}
translate F ReviewProgressRapid {Annotation rapide}
translate F FinishGameGameChanged {la partie a changé pendant l'exécution de Finir Partie ; rien n'a été écrit}
translate F FinishGameAtEnd {Finir Partie commence à la fin de la ligne principale ; aller d'abord à la fin de la partie}
# CQL search:
translate F CQLQuery {Requête CQL}
translate F CQLQueryHint {Requête CQL, par ex. cql() mate ou cql(:gamenumber 1 10) K. Ctrl+Entrée lance la recherche.}
translate F CQLQueryEmpty {Saisissez une requête CQL avant de lancer la recherche.}
translate F CQLSearchFailed {La recherche CQL a échoué :}
translate F CQLUnreadableGames {%d partie(s) n'ont pas pu être lues}
}
# end of english.tcl


############################################################
#
# French tip of the day
# Machine-translated scaffold - please review and correct.

set tips(F) {
  {
    scidCommunity en compte plus de 40 <a Index>pages d'aide</a>, et dans la plupart des fenêtres de scidCommunity, en appuyant sur la touche <b>F1</b> vous obtiendrez la page d'aide de cette fenêtre.
  }
  {
    Certaines fenêtres de scidCommunity (par exemple la zone d'informations sur le jeu, la base de données <a Switcher>switcher</a>) ont un menu avec le bouton droit de la souris. Essayez d'appuyer sur le bouton droit de la souris dans chaque fenêtre pour voir si elle en a une et quelles fonctions sont disponibles.
  }
  {
    scidCommunity vous propose plusieurs façons de saisir des mouvements d'échecs, vous permettant de choisir celui qui vous convient le mieux. Vous pouvez utiliser la souris (avec ou sans suggestion de déplacement) ou le clavier (avec ou sans réalisation de déplacement). Lisez la page d'aide <a Moves> sur la saisie des mouvements d'échecs </a> pour plus de détails.
  }
  {
    Si vous avez quelques bases de données que vous ouvrez souvent, ajoutez un <a Bookmarks>signet</a> pour chacun, et vous pourrez alors les ouvrir plus rapidement en utilisant le menu des favoris.
  }
  {
    Vous pouvez suivre les principaux tournois d'échecs en temps réel à l'aide de la fonction <b>Open Lichess Tournament</b> dans le menu <b>Fichier</b>. scidCommunity surveillera et mettra automatiquement à jour les jeux en direct pour vous.
  }
  {
    Vous pouvez voir tous les mouvements du jeu en cours (avec toutes les variantes et commentaires) en utilisant la fenêtre <a PGN>PGN </a>. Dans la fenêtre PGN, vous pouvez accéder à n'importe quel mouvement en cliquant dessus avec le bouton gauche de la souris, ou utiliser le bouton central ou droit de la souris pour voir un aperçu de cette position.
  }
  {
    Vous pouvez copier des jeux d'une base de données à une autre par glisser-déposer avec le bouton gauche de la souris dans la <a Switcher>commutateur de base de données</a> fenêtre.
  }
  {
    scidCommunity peut ouvrir les fichiers PGN, même s'ils sont compressés avec Gzip (avec un suffixe de nom de fichier .gz). Les fichiers PGN sont ouverts en lecture seule, donc si vous souhaitez modifier un fichier PGN dans scidCommunity, créez une nouvelle base de données scidCommunity et copiez-y les jeux de fichiers PGN en utilisant le <a Switcher>commutateur de base de données</a>.
  }
  {
    Si vous utilisez souvent une grande base de données avec la fenêtre <a Tree>tree</a>, il vaut la peine de sélectionner <b>Fill cache file</b> dans le menu Fichier de la fenêtre arborescente. Cela mémorisera les statistiques des arbres pour de nombreuses positions d'ouverture courantes, ce qui rendra l'accès aux arbres plus rapide pour la base de données.
  }
  {
    Le <a Tree>arbre</a> La fenêtre peut vous montrer tous les coups joués à partir de la position actuelle, mais si vous souhaitez également voir tous les ordres de coups qui ont atteint cette position, vous pouvez les retrouver en générant un <a OpReport>rapport d'ouverture</a>.
  }
  {
    Pour importer rapidement vos propres parties à partir de sites en ligne, utilisez <b> Importer mon Lichess </b> ou <b> Importer mon chess.com </b> dans le menu <b> Fichier </b>. Entrez simplement votre nom d'utilisateur et une date de début pour télécharger vos jeux avec des métadonnées complètes.
  }
  {
    Dans la fenêtre <a GameList>game list</a>, appuyez sur le bouton gauche ou droit de la souris sur l'en-tête de chaque colonne pour ajuster sa largeur.
  }
  {
    Avec le <a PInfo>informations sur le joueur</a> fenêtre (cliquez simplement sur le nom de l'un des joueurs dans la zone d'informations du jeu sous l'échiquier de la fenêtre principale pour l'ouvrir), vous pouvez facilement définir le <a Searches Filter>filtre</a> pour contenir tous les jeux d'un certain joueur avec un certain résultat en cliquant sur n'importe quelle valeur affichée <red>en texte rouge</red>.
  }
  {
    Lors de l'étude d'une ouverture, il peut être très utile de faire une recherche <a Searches Board>board </a> avec l'option <b>Pions</b> ou <b>Fichiers</b> sur une position d'ouverture importante, car cela peut révéler d'autres ouvertures qui atteignent la même structure de pions.
  }
  {
    Dans la zone d'informations du jeu (sous l'échiquier), vous pouvez appuyer sur le bouton droit de la souris pour produire un menu permettant de le personnaliser. Par exemple, vous pouvez faire en sorte que scidCommunity masque le prochain mouvement, ce qui est utile pour l'entraînement, en jouant à un jeu devinant les mouvements.
  }
  {
    Si vous faites souvent beaucoup de base de données <a Maintenance>entretien</a> sur une grande base de données, vous pouvez effectuer plusieurs tâches de maintenance à la fois en utilisant le <a Maintenance Cleaner>nettoyeur</a>.
  }
  {
    La fenêtre <a PGN>PGN </a> comporte des boutons d'accès rapide pour télécharger votre partie en cours sur <b>Lichess.org</b> ou <b>Chess.com</b>. Cela vous permet d'utiliser instantanément leurs puissantes fonctionnalités d'analyse et de partage de moteur basées sur le cloud.
  }
  {
    Si vous disposez d'une grande base de données dans laquelle la plupart des jeux ont une date d'événement et que vous souhaitez que les jeux soient classés par date, envisagez de <a Sorting>trier </a> par Date d'événement puis Événement au lieu de Date puis Événement, car cela aidera à conserver les jeux dans le même tournoi avec des dates différentes ensemble (en supposant qu'ils ont tous la même Date d'événement, bien sûr).
  }
  {
    Avant <a Maintenance Twins> de supprimer des jeux jumeaux </a>, c'est une bonne idée de <a Maintenance Spellcheck> vérifier l'orthographe </a> de votre base de données car cela permettra à scidCommunity de trouver plus de jumeaux et de les marquer pour suppression.
  }
  {
    <a Flags>Drapeaux</a> sont utiles pour marquer les jeux de base de données avec des caractéristiques que vous souhaiterez peut-être rechercher ultérieurement, telles que la structure des pions, les tactiques, etc. Vous pouvez effectuer une recherche par drapeaux avec un <a Searches Header>recherche d'en-tête</a>.
  }
  {
    Pour trouver les jeux les plus importants (avec des adversaires de haut niveau) atteignant une position particulière, ouvrez la fenêtre <a Tree>tree </a> et à partir de là, ouvrez la liste des meilleurs jeux. Vous pouvez même restreindre la liste des meilleurs jeux pour afficher uniquement les jeux avec un résultat particulier.
  }
  {
    Utilisez le bouton <b>chessdb Engine Tree</b> dans la fenêtre <a PGN>PGN </a> pour consulter la base de données cloud <b>ChessDB.cn</b>. Il contient des milliards de postes pré-analysés et d'évaluations informatiques pour presque toutes les ouvertures.
  }
  {
    Un excellent moyen d'étudier une ouverture à l'aide d'une grande base de données de jeux consiste à activer le mode entraînement dans la fenêtre <a Tree>tree </a>, puis à jouer contre la base de données pour voir quelles lignes apparaissent souvent.
  }
  {
    Si vous avez deux bases de données ouvertes et que vous souhaitez voir <a Tree>arbre</a> statistiques de la première base de données tout en examinant un jeu de la deuxième base de données, appuyez simplement sur la touche <b>Verrouillage</b> dans la fenêtre arborescente pour le verrouiller sur la première base de données, puis passer à la deuxième base.
  }
  {
    Le <a Tmt>chercheur de tournoi</a> n'est pas seulement utile pour trouver un tournoi particulier, mais peut également être utilisé pour voir à quels tournois un certain joueur a participé récemment ou parcourir les meilleurs tournois joués dans un pays particulier.
  }
  {
    Il existe un certain nombre de modèles courants définis dans la fenêtre de recherche <a Searches Material>Matériau/Motif</a> que vous pourriez trouver utiles pour les ouvertures ou l'étude du milieu de jeu.
  }
  {
    Lors de la recherche d'une situation matérielle particulière dans la fenêtre de recherche <a Searches Material>Matériau/Motif</a>, il est souvent utile de limiter la recherche aux jeux qui correspondent à au moins quelques demi-coups afin d'éliminer les jeux où la situation recherchée ne s'est produite que brièvement.
  }
  {
    Si vous atteignez une fin de partie avec 7 pièces ou moins, cliquez sur le bouton <b> Table Base </b> dans la fenêtre <a PGN> PGN </a> pour obtenir une analyse parfaite des bases de table de fin de partie Lichess.
  }
  {
    Si vous disposez d'une base de données importante que vous ne souhaitez pas modifier accidentellement, sélectionnez <b>Lecture seule...</b> dans le menu <b>Fichier</b> après l'avoir ouverte, ou modifiez ses autorisations de fichier pour qu'elles soient en lecture seule.
  }
  {
    Si vous utilisez XBoard ou WinBoard (ou un autre programme d'échecs capable de copier une position d'échecs en notation FEN standard dans le presse-papiers) et que vous souhaitez copier sa position d'échecs actuelle dans scidCommunity, le moyen le plus rapide et le plus simple est de sélectionner <b> Copier la position </b> dans le menu Fichier de XBoard/WinBoard, puis <b> Coller la planche de démarrage </b> dans le menu Édition de communauté scid.
  }
  {
    Dans un <a Searches Header>recherche d'en-tête</a>, les noms de joueur/événement/site/tour ne sont pas sensibles à la casse et correspondent n'importe où dans un nom. Vous pouvez choisir d'effectuer une recherche générique sensible à la casse (où "?" = n'importe quel caractère et "*" = zéro ou plusieurs caractères) en saisissant le texte de recherche "entre guillemets". Par exemple, tapez "*BEL" (avec les guillemets) dans le champ du site pour trouver tous les jeux joués en Belgique mais pas à Belgrade.
  }
  {
    Si vous souhaitez corriger un coup dans une partie sans perdre tous les coups joués après, ouvrez la fenêtre <a Import> Importer </a>, appuyez sur le bouton <b> Coller la partie en cours </b>, modifiez le coup incorrect puis appuyez sur <b> Importer </b>.
  }
  {
    Si vous avez chargé un fichier de classification ECO, vous pouvez accéder à la position classée la plus profonde du jeu en cours avec <b>Identifier l'ouverture</b> dans le menu <b>Jeu</b> (raccourci : Ctrl+Shift+D).
  }
  {
    Restez à jour avec les derniers jeux du monde entier en utilisant <b> Téléchargez TWIC Games </b> dans le menu <b> Outils </b>. Il télécharge et ouvre automatiquement le dernier PGN hebdomadaire de <b> The Week In Chess </b>.
  }
  {
    Si vous souhaitez vérifier la taille d'un fichier ou sa date de dernière modification avant de l'ouvrir, utilisez l'option <a Finder>chercheur de fichiers</a> pour l'ouvrir.
  }
  {
    Un <a OpReport>rapport d'ouverture</a> est idéal pour en savoir plus sur un poste particulier. Vous pouvez voir à quel point il obtient de bons résultats, s'il conduit à des tirages courts fréquents et à des thèmes de position courants.
  }
  {
    Vous pouvez ajouter les symboles d'annotation les plus courants (!, !?, +=, etc.) au déplacement ou à la position actuelle avec des raccourcis clavier sans avoir besoin d'utiliser l'<a Comment>éditeur de commentaires</a> -- par exemple, tapez "!" puis la touche Retour pour ajouter un "!" symbole d'annotation. Consultez la page d'aide <a Moves> Saisie des mouvements d'échecs </a> pour plus de détails.
  }
  {
    Si vous parcourez les ouvertures dans une base de données avec le <a Tree>arbre</a>, vous pouvez avoir un aperçu utile des scores récents de l'ouverture en cours et des joueurs les mieux notés en ouvrant la fenêtre Statistiques (raccourci : Ctrl+I).
  }
  {
    Après un <a Searches>recherche</a>, vous pouvez facilement parcourir tous les jeux correspondants en maintenant enfoncé <b>Ctrl</b> et en appuyant sur le <b>En haut</b> ou <b>Vers le bas</b> touche pour charger le précédent ou le suivant <a Searches Filter>filtre</a> jeu.
  }
  {
    Les fenêtres peuvent être ancrées en cochant l'entrée correspondante dans le menu Options. Les onglets peuvent être glissés et déposés d'un bloc-notes à un autre et disposés en cliquant avec le bouton droit sur le widget d'onglets.
  }
}
