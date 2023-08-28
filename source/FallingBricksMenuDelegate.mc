import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FallingBricksMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :item_1) {
            System.println("item 1");
        } else if (item == :exit) {
            System.println("EXIT!");
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

}