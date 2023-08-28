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
        System.println("onKey " + keyEvent.getKey() );

        return true;
    }

    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        System.println("onKeyPressed " + keyEvent.getKey() );

        if( keyEvent.getKey() == KEY_ESC ) {
            _view.moveRight = true;       
        }
        else if( keyEvent.getKey() == KEY_DOWN ) {
            _view.moveLeft = true;     
        }

        return true;
    }


    function onKeyReleased(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        System.println("onKeyReleased " + keyEvent.getKey() );

        if( keyEvent.getKey() == KEY_ESC ) {
            _view.moveRight = false;       
        }
        else if( keyEvent.getKey() == KEY_DOWN ) {
            _view.moveLeft = false;     
        }

        return true;
    }

}