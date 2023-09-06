import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;

const BLOCK_SIZE = 7;
const BUFF_W = FIELD_W * BLOCK_SIZE + 3;
const BUFF_H = FIELD_H * BLOCK_SIZE + 3;

const FG_COLOR = Graphics.COLOR_BLACK;
const BG_COLOR = Graphics.COLOR_WHITE; 

class FallingBricksView extends WatchUi.View {
    var tickNum = 0;
    var offscreenBuffer as Graphics.BufferedBitmap?;
    var gameplay = new Gameplay();
    var refreshTimer = new Timer.Timer();
    var cachedField = new[FIELD_W * FIELD_H];
    var lastGameplayOpTime = 0;
   
    function initialize() {
        View.initialize();
    }

    function timerCallback() as Void {
        var startGameplayOp = System.getTimer();
        gameplay.Tick();
        lastGameplayOpTime = System.getTimer() - startGameplayOp;
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

        dc.setColor(FG_COLOR, BG_COLOR);
        dc.clear();

        //Draw guides to simplify hard drop
        for (var x = 1; x < FIELD_W - 1; x += 2) {
            for ( var y = 1; y < FIELD_H - 1; y += 4 ) {
                dc.drawPoint( BLOCK_SIZE * (x + 1) + 1, BLOCK_SIZE * (y + 1) + 1 );
            }
        } 

        dc.drawRectangle(0, 0, BUFF_W, BUFF_H);
    }

    function syncFieldAndCache(newField as Lang.Array, dirtyRect as Rect) as Void {
        var dc = offscreenBuffer.getDc();

        //We redraw only changed cells and only check those within the dirty rectangle
        for (var x = dirtyRect.left; x < dirtyRect.right; ++x ) {
            for ( var y = dirtyRect.top; y < dirtyRect.bottom; ++y ) {
                var pos = x + y * FIELD_W;
                var newVal = newField[pos];

                if( cachedField[pos] == newVal ) {
                    continue;
                }

                if( newVal == 1 ) {
                    dc.setColor(FG_COLOR, BG_COLOR);
                    dc.drawRectangle(2 + BLOCK_SIZE * x, 2 + BLOCK_SIZE * y, BLOCK_SIZE - 1, BLOCK_SIZE - 1);
                    dc.drawRectangle(BLOCK_SIZE * x + 4, BLOCK_SIZE * y + 4, BLOCK_SIZE - 5, BLOCK_SIZE - 5);
                } else {
                    dc.setColor(BG_COLOR, FG_COLOR);
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

        syncFieldAndCache(newField[0], newField[1]);

        var afterSyncCache = System.getTimer();

        dc.setColor(FG_COLOR, BG_COLOR);
        dc.clear();

        dc.drawBitmap(24, 16, offscreenBuffer);
        dc.drawText(169, 93, Graphics.FONT_LARGE, gameplay.score, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(145, 30, Graphics.FONT_LARGE, gameplay.level, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if( !gameplay.isActive ) {
            dc.drawText(87, 135, Graphics.FONT_LARGE, "Game Over", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        var endDraw = System.getTimer();
        
        //Performace stats HUD
        if( gameplay.isActive ) {
            dc.drawText(170, 120, Graphics.FONT_XTINY, (afterFieldBuild - beginDraw).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(136, 140, Graphics.FONT_XTINY, (afterSyncCache - afterFieldBuild).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(136, 160, Graphics.FONT_XTINY, (endDraw - afterSyncCache).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(136, 120, Graphics.FONT_XTINY, lastGameplayOpTime.format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            var shift = 45 * tickNum;
            dc.drawArc( 144, 31, 29, Graphics.ARC_CLOCKWISE, 90 - shift, 45 - shift );
            ++tickNum;
        }
    }

    function rotate() as Void {
        var startGameplayOp = System.getTimer();
        gameplay.rotate();
        lastGameplayOpTime = System.getTimer() - startGameplayOp;
        WatchUi.requestUpdate();
    }

    function shiftPrimitive( dir as Lang.Number ) as Void {
        var startGameplayOp = System.getTimer();
        gameplay.shiftPrimitive(dir);
        lastGameplayOpTime = System.getTimer() - startGameplayOp;
        WatchUi.requestUpdate(); 
    }

    function hardDrop() as Void {
        var startGameplayOp = System.getTimer();
        gameplay.hardDrop();
        lastGameplayOpTime = System.getTimer() - startGameplayOp;
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
