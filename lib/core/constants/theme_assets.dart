import '../../features/games/domain/entities/game_config.dart';
import 'asset_constants.dart';

const Set<String> _darkThemeFiles = <String>{
  'back_icon.svg',
  'Home.svg',
  'home_cell_bg.svg',
  'ic_close.svg',
  'ic_pause.svg',
  'info.svg',
  'restart.svg',
  'sub_cell_bg.svg',
};

String themedAsset(GameTheme theme, String file, {required bool darkMode}) {
  final folder = darkMode && _darkThemeFiles.contains(file)
      ? theme.darkAssetFolder
      : theme.assetFolder;
  return AssetConstants.themed(folder, file);
}
