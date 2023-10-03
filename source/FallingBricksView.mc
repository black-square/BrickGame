import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;

(:instinct2) const BLOCK_SIZE = 7;
(:instinct2) const FIELD_POS_X = 24;
(:instinct2) const FIELD_POS_Y = 16;
(:instinct2) const SCORE_POS_X = 169;
(:instinct2) const SCORE_POS_Y = 93;
(:instinct2) const LEVEL_POS_X = 145;
(:instinct2) const LEVEL_POS_Y = 30;
(:instinct2) const ARC_POS_X = 144;
(:instinct2) const ARC_POS_Y = 31;
(:instinct2) const ARC_POS_R = 27;

(:instinct2s) const BLOCK_SIZE = 7;
(:instinct2s) const FIELD_POS_X = 20;
(:instinct2s) const FIELD_POS_Y = 7;
(:instinct2s) const SCORE_POS_X = 153;
(:instinct2s) const SCORE_POS_Y = 80;
(:instinct2s) const LEVEL_POS_X = 136;
(:instinct2s) const LEVEL_POS_Y = 25;
(:instinct2s) const ARC_POS_X = 136;
(:instinct2s) const ARC_POS_Y = 27;
(:instinct2s) const ARC_POS_R = 23;

(:round280) const BLOCK_SIZE = 11;
(:round280) const FIELD_POS_X = 57;
(:round280) const FIELD_POS_Y = 28;
(:round280) const SCORE_POS_X = 271;
(:round280) const SCORE_POS_Y = 129;
(:round280) const LEVEL_POS_X = 215;
(:round280) const LEVEL_POS_Y = 70;
(:round280) const ARC_POS_X = LEVEL_POS_X;
(:round280) const ARC_POS_Y = LEVEL_POS_Y;
(:round280) const ARC_POS_R = 27;

(:round260) const BLOCK_SIZE = 10;
(:round260) const FIELD_POS_X = 51;
(:round260) const FIELD_POS_Y = 29;
(:round260) const SCORE_POS_X = 255;
(:round260) const SCORE_POS_Y = 129;
(:round260) const LEVEL_POS_X = 195;
(:round260) const LEVEL_POS_Y = 57;
(:round260) const ARC_POS_X = LEVEL_POS_X;
(:round260) const ARC_POS_Y = LEVEL_POS_Y;
(:round260) const ARC_POS_R = 27;

(:round240) const BLOCK_SIZE = 9;
(:round240) const FIELD_POS_X = 45;
(:round240) const FIELD_POS_Y = 29;
(:round240) const SCORE_POS_X = 235;
(:round240) const SCORE_POS_Y = 120;
(:round240) const LEVEL_POS_X = 179;
(:round240) const LEVEL_POS_Y = 60;
(:round240) const ARC_POS_X = LEVEL_POS_X;
(:round240) const ARC_POS_Y = LEVEL_POS_Y;
(:round240) const ARC_POS_R = 27;

const BUFF_W = FIELD_W * BLOCK_SIZE + 3;
const BUFF_H = FIELD_H * BLOCK_SIZE + 3;

const FG_COLOR = Graphics.COLOR_BLACK;
const BG_COLOR = Graphics.COLOR_WHITE; 

class FallingBricksView extends WatchUi.View {
    var offscreenBuffer as Graphics.BufferedBitmap?;
    var offscreenBufferRef as Graphics.BufferedBitmapReference?;
    var gameplay = new Gameplay();
    var refreshTimer = new Timer.Timer();
    var cachedField = new[FIELD_W * FIELD_H];

    var tickNum = 0;

    (:perfTelemetry)
    var lastGameplayOpTime = 0;
   
    function initialize() {
        View.initialize();
    }

    function timerCallback() as Void {
        //var startGameplayOp = System.getTimer();
        gameplay.Tick();
        //lastGameplayOpTime = System.getTimer() - startGameplayOp;
        refreshTimer.start(method(:timerCallback), gameplay.tickDuration, false);
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        var bufferArgs = {
            :width=>BUFF_W,
            :height=>BUFF_H,
            :palette=>[Graphics.COLOR_BLACK,
                    Graphics.COLOR_WHITE]
        }; 
                    
        if ( Graphics has :createBufferedBitmap ){
            offscreenBufferRef = Graphics.createBufferedBitmap(bufferArgs);
            offscreenBuffer = offscreenBufferRef.get();
        } else {
            offscreenBuffer = new Graphics.BufferedBitmap(bufferArgs);    
        }  

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

        //var beginDraw = System.getTimer();
        var newField = gameplay.BuildFieldForDraw();

        //var afterFieldBuild = System.getTimer();

        syncFieldAndCache(newField[0], newField[1]);

        //var afterSyncCache = System.getTimer();

        dc.setColor(FG_COLOR, BG_COLOR);
        dc.clear();

        dc.drawBitmap(FIELD_POS_X, FIELD_POS_Y, offscreenBuffer);
        dc.drawText(SCORE_POS_X, SCORE_POS_Y, Graphics.FONT_LARGE, gameplay.score, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(LEVEL_POS_X, LEVEL_POS_Y, Graphics.FONT_LARGE, gameplay.level, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if( !gameplay.isActive ) {
            dc.drawText(dc.getWidth() / 2, dc.getHeight() * 76 / 100, Graphics.FONT_LARGE, "Game Over", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        //var endDraw = System.getTimer();
        
        //Performace stats HUD
        if( gameplay.isActive ) {
            //dc.drawText(170, 120, Graphics.FONT_XTINY, (afterFieldBuild - beginDraw).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            //dc.drawText(136, 140, Graphics.FONT_XTINY, (afterSyncCache - afterFieldBuild).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            //dc.drawText(136, 160, Graphics.FONT_XTINY, (endDraw - afterSyncCache).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            //dc.drawText(136, 120, Graphics.FONT_XTINY, lastGameplayOpTime.format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            var shift = 45 * tickNum;
            dc.drawArc( ARC_POS_X, ARC_POS_Y, ARC_POS_R, Graphics.ARC_CLOCKWISE, 90 - shift, 45 - shift );
            ++tickNum;
        }
    }

    function rotate() as Void {
        //var startGameplayOp = System.getTimer();
        gameplay.rotate();
        //lastGameplayOpTime = System.getTimer() - startGameplayOp;
        WatchUi.requestUpdate();
    }

    function shiftPrimitive( dir as Lang.Number ) as Void {
        //var startGameplayOp = System.getTimer();
        gameplay.shiftPrimitive(dir);
        //lastGameplayOpTime = System.getTimer() - startGameplayOp;
        WatchUi.requestUpdate(); 
    }

    function hardDrop() as Void {
        //var startGameplayOp = System.getTimer();
        gameplay.hardDrop();
        //lastGameplayOpTime = System.getTimer() - startGameplayOp;
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
