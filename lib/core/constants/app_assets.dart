/// A bundled picture together with its width / height ratio, so layouts can
/// size it immediately without waiting for the image to decode.
class Illustration {
  const Illustration(this.asset, this.aspect);

  final String asset;

  /// width / height
  final double aspect;
}

abstract final class AppAssets {
  /// App logo (rounded tile with transparent corners).
  static const logo = 'assets/images/logo_icon.png';

  static const couch = Illustration('assets/images/couch_ghost.png', 1.0);

  // Pip, the ghost, in different moods (cropped from the artwork sheet).
  static const wake = Illustration('assets/images/ghosts/ghost_wake.png', 0.836);
  static const checklist = Illustration('assets/images/ghosts/ghost_checklist.png', 0.808);
  static const celebrate = Illustration('assets/images/ghosts/ghost_celebrate.png', 0.811);
  static const meditate = Illustration('assets/images/ghosts/ghost_meditate.png', 0.840);
  static const sad = Illustration('assets/images/ghosts/ghost_sad.png', 0.952);
  static const trophy = Illustration('assets/images/ghosts/ghost_trophy.png', 1.018);
  static const clipboard = Illustration('assets/images/ghosts/ghost_clipboard.png', 0.994);
}
