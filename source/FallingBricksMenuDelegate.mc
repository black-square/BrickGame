import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FallingBricksMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :about) {
            WatchUi.pushView(new AboutView(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_UP);
        } else if (item == :exit) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (item == :start_new_game) {
            var view = new FallingBricksView();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.switchToView(view, new FallingBricksDelegate(view), WatchUi.SLIDE_LEFT); 
        }
    }

}