import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;

const BLOCK_SIZE = 7;
const BUFF_W = FIELD_W * BLOCK_SIZE + 3;
const BUFF_H = FIELD_H * BLOCK_SIZE + 3;


class FallingBricksView extends WatchUi.View {
    var tickNum = 0;
    var prevUpdateTime = System.getTimer(); 
    var offscreenBuffer as Graphics.BufferedBitmap?;
    var gameplay = new Gameplay();
    var refreshTimer = new Timer.Timer();
    var cachedField = new[FIELD_W * FIELD_H];
   
    function initialize() {
        View.initialize();
    }

    function timerCallback() as Void {
        gameplay.Tick();
        refreshTimer.start(method(:timerCallback), gameplay.tickDuration, false);
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        offscreenBuffer = new Graphics.BufferedBitmap(
            {:width=>BUFF_W,
            :height=>BUFF_H,
            :palette=>[Graphics.COLOR_BLACK,
                    Graphics.COLOR_WHITE]} );

        dc = offscreenBuffer.getDc();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawRectangle(0, 0, BUFF_W, BUFF_H);
    }

    function syncFieldAndCache(newField as Lang.Array) as Void {
        var dc = offscreenBuffer.getDc();

        for (var x = 0; x != FIELD_W; ++x ) {
            for ( var y = 0; y != FIELD_H; ++y ) {
                var pos = x + y * FIELD_W;
                var newVal = newField[pos];

                if( cachedField[pos] == newVal ) {
                    continue;
                }

                if( newVal == 1 ) {
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                    dc.drawRectangle(2 + BLOCK_SIZE * x, 2 + BLOCK_SIZE * y, BLOCK_SIZE - 1, BLOCK_SIZE - 1);
                } else {
                    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                    dc.fillRectangle(2 + BLOCK_SIZE * x, 2 + BLOCK_SIZE * y, BLOCK_SIZE - 1, BLOCK_SIZE - 1); 
                }

                cachedField[pos] = newVal;         
            }     
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        refreshTimer.start(method(:timerCallback), gameplay.tickDuration, false);
        WatchUi.requestUpdate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var beginDraw = System.getTimer();
        var newField = gameplay.BuildFieldForDraw();

        var afterFieldBuild = System.getTimer();

        syncFieldAndCache(newField);

        var afterSyncCache = System.getTimer();

        dc.drawBitmap(24, 16, offscreenBuffer);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(169, 90, Graphics.FONT_LARGE, gameplay.score, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        var endDraw = System.getTimer();

        dc.drawText(143, 120, Graphics.FONT_XTINY, (afterFieldBuild - beginDraw).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(143, 140, Graphics.FONT_XTINY, (afterSyncCache - afterFieldBuild).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(143, 160, Graphics.FONT_XTINY, (endDraw - afterSyncCache).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var shift = 45 * tickNum;
        dc.drawArc( 144, 31, 29, Graphics.ARC_CLOCKWISE, 90 - shift, 45 - shift );
        
        tickNum += 1;
    }

    function rotate() as Void {
        gameplay.rotate();
        WatchUi.requestUpdate();
    }

    function shiftPrimitive( dir as Lang.Number ) as Void {
        gameplay.shiftPrimitive(dir);
        WatchUi.requestUpdate(); 
    }

    function accelDown() as Void {
        gameplay.accelDown();
        refreshTimer.start(method(:timerCallback), gameplay.tickDuration, false);
        WatchUi.requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        refreshTimer.stop();
    }
}
