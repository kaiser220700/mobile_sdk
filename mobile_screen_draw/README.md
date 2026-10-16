# mobile_screen_draw

Experimental 0.1.0, independent opt-in screen annotation for non-production
builds. No DevTool, Fuzz or production SDK dependency.

```dart
import 'package:mobile_screen_draw/mobile_screen_draw.dart' as draw;

final controller = draw.Controller();
controller.showOverlay();
// Mount draw.DrawingOverlay(tool: controller) while controller.overlayActive.
// Dispose the controller with its owner.
```

The host owns overlay mounting and signals. Forward route identity through
updateRoute and scroll deltas through addScrollDelta while open, if needed.
The package owns drawing state and toolbar/canvas interaction. See
`../example/lib/developer_tools.dart` for working composition.
