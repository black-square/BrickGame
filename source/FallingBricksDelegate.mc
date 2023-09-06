import Toybox.Lang;
import Toybox.WatchUi;

class FallingBricksDelegate extends WatchUi.BehaviorDelegate {

    var _view as FallingBricksView? = null;

    function initialize(view as FallingBricksView) {
        _view = view;
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new FallingBricksMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        switch( keyEvent.getKey() ) {
            case KEY_UP:
                _view.rotate(); return true;

            case KEY_DOWN:
                _view.shiftPrimitive(-1); return true;

            case KEY_ESC:
                _view.shiftPrimitive(+1); return true;

            case KEY_ENTER:
                _view.hardDrop(); return true;
        }

        return false;
    }
}