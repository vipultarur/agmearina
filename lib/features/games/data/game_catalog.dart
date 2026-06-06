import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/game_config.dart';

const GameTheme mathTheme = GameTheme(
  id: 'math',
  title: 'Math Puzzle',
  primary: AppColors.yellow,
  soft: AppColors.yellowSoft,
  panel: AppColors.yellowPanel,
  categoryIcon: AssetConstants.categoryMath,
  assetFolder: 'imgYellow',
  darkAssetFolder: 'imgYellowDark',
);

const GameTheme memoryTheme = GameTheme(
  id: 'memory',
  title: 'Memory Puzzle',
  primary: AppColors.green,
  soft: AppColors.greenSoft,
  panel: AppColors.greenPanel,
  categoryIcon: AssetConstants.categoryMemory,
  assetFolder: 'imgGreen',
  darkAssetFolder: 'imgGreenDark',
);

const GameTheme trainTheme = GameTheme(
  id: 'train',
  title: 'Train Your Brain',
  primary: AppColors.purple,
  soft: AppColors.purpleSoft,
  panel: AppColors.purplePanel,
  categoryIcon: AssetConstants.categoryTrain,
  assetFolder: 'imgBlue',
  darkAssetFolder: 'imgBlueDark',
);

const GameConfig calculatorGame = GameConfig(
  id: 'calculator',
  title: 'Calculator',
  icon: AssetConstants.calculator,
  theme: mathTheme,
  mode: PlayMode.keypad,
  maxSeconds: 10,
);

const GameConfig guessSignGame = GameConfig(
  id: 'guess_sign',
  title: 'Guess The Sign',
  icon: AssetConstants.guessSign,
  theme: mathTheme,
  mode: PlayMode.answers,
  maxSeconds: 10,
);

const GameConfig correctAnswerGame = GameConfig(
  id: 'correct_answer',
  title: 'Correct Answer',
  icon: AssetConstants.correctAnswer,
  theme: mathTheme,
  mode: PlayMode.answers,
  maxSeconds: 10,
);

const GameConfig quickCalculationGame = GameConfig(
  id: 'quick_calculation',
  title: 'Quick Calculation',
  icon: AssetConstants.quickCalculation,
  theme: mathTheme,
  mode: PlayMode.keypad,
  maxSeconds: 20,
);

const GameConfig findMissingGame = GameConfig(
  id: 'find_missing',
  title: 'Find Missing',
  icon: AssetConstants.findMissing,
  theme: mathTheme,
  mode: PlayMode.answers,
  maxSeconds: 20,
);

const GameConfig trueFalseGame = GameConfig(
  id: 'true_false',
  title: 'True False',
  icon: AssetConstants.trueFalse,
  theme: mathTheme,
  mode: PlayMode.trueFalse,
  maxSeconds: 20,
);

const GameConfig complexCalculationGame = GameConfig(
  id: 'complex_calculation',
  title: 'Complex Calculation',
  icon: AssetConstants.complexCalculation,
  theme: mathTheme,
  mode: PlayMode.answers,
  maxSeconds: 20,
);

const GameConfig dualGame = GameConfig(
  id: 'dual_game',
  title: 'Dual Game',
  icon: AssetConstants.dualGame,
  theme: mathTheme,
  mode: PlayMode.dualGame,
  maxSeconds: 20,
);

const GameConfig squareRootGame = GameConfig(
  id: 'square_root',
  title: 'Square Root',
  icon: AssetConstants.squareRoot,
  theme: mathTheme,
  mode: PlayMode.keypad,
  maxSeconds: 20,
);

const GameConfig cubeRootGame = GameConfig(
  id: 'cube_root',
  title: 'Cube Root',
  icon: AssetConstants.cubeRoot,
  theme: mathTheme,
  mode: PlayMode.keypad,
  maxSeconds: 20,
);

const GameConfig rootGame = GameConfig(
  id: 'root',
  title: 'Root',
  icon: AssetConstants.root,
  theme: mathTheme,
  mode: PlayMode.keypad,
  maxSeconds: 20,
);

const GameConfig mathGridGame = GameConfig(
  id: 'math_grid',
  title: 'Math Grid',
  icon: AssetConstants.mathGrid,
  theme: mathTheme,
  mode: PlayMode.mathGrid,
  maxSeconds: 60,
);

const GameConfig numberPyramidGame = GameConfig(
  id: 'number_pyramid',
  title: 'Number Pyramid',
  icon: AssetConstants.numberPyramid,
  theme: mathTheme,
  mode: PlayMode.numberPyramid,
  maxSeconds: 60,
  totalLevels: 165,
);

const GameConfig mentalArithmeticGame = GameConfig(
  id: 'mental_arithmetic',
  title: 'Mental Arithmetic',
  icon: AssetConstants.mentalArithmetic,
  theme: memoryTheme,
  mode: PlayMode.keypad,
  maxSeconds: 60,
);

const GameConfig mathPairsGame = GameConfig(
  id: 'math_pairs',
  title: 'Math Pairs',
  icon: AssetConstants.mathPairs,
  theme: memoryTheme,
  mode: PlayMode.mathPairs,
  maxSeconds: 60,
);

const GameConfig numericMemoryGame = GameConfig(
  id: 'numeric_memory',
  title: 'Numeric Memory',
  icon: AssetConstants.numericMemory,
  theme: trainTheme,
  mode: PlayMode.numericMemory,
  maxSeconds: 60,
);

const GameConfig concentrationGame = GameConfig(
  id: 'concentration',
  title: 'Concentration',
  icon: AssetConstants.concentration,
  theme: memoryTheme,
  mode: PlayMode.concentration,
  maxSeconds: 60,
);

const GameConfig magicTriangleGame = GameConfig(
  id: 'magic_triangle',
  title: 'Magic Triangle',
  icon: AssetConstants.magicTriangle,
  theme: trainTheme,
  mode: PlayMode.magicTriangle,
  maxSeconds: 60,
);

const GameConfig picturePuzzleGame = GameConfig(
  id: 'picture_puzzle',
  title: 'Picture Puzzle',
  icon: AssetConstants.picturePuzzle,
  theme: trainTheme,
  mode: PlayMode.picturePuzzle,
  maxSeconds: 90,
);

const List<GameConfig> mathGames = <GameConfig>[
  calculatorGame,
  guessSignGame,
  correctAnswerGame,
  quickCalculationGame,
  findMissingGame,
  trueFalseGame,
  complexCalculationGame,
  dualGame,
  squareRootGame,
  cubeRootGame,
  rootGame,
  mathGridGame,
  numberPyramidGame,
];

const List<GameConfig> memoryGames = <GameConfig>[
  mentalArithmeticGame,
  mathPairsGame,
  concentrationGame,
];

const List<GameConfig> trainGames = <GameConfig>[
  magicTriangleGame,
  picturePuzzleGame,
  numericMemoryGame,
];

const List<GameConfig> allGames = <GameConfig>[
  ...mathGames,
  ...memoryGames,
  ...trainGames,
];
