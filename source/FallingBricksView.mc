import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;

const BLOCK_SIZE = 7;
const BUFF_W = FIELD_W * BLOCK_SIZE + 3;
const BUFF_H = FIELD_H * BLOCK_SIZE + 3;


class FallingBricksView extends WatchUi.View {

    var posY = 0;
    var posX = 0;

    var moveLeft = false;
    var moveRight = false;
    var prevUpdateTime = System.getTimer(); 
    var offscreenBuffer as Graphics.BufferedBitmap?;
    var gameplay = new Gameplay();
    var tickDuration = 1000;
    var prevTick = System.getTimer();
    
    function initialize() {
        View.initialize();

        offscreenBuffer = new Graphics.BufferedBitmap(
            {:width=>BUFF_W,
            :height=>BUFF_H,
            :palette=>[Graphics.COLOR_BLACK,
                    Graphics.COLOR_WHITE]} );

        var dc = offscreenBuffer.getDc();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.clear();

        dc.drawRectangle(0, 0, BUFF_W, BUFF_H);

        for (var x = 0; x != FIELD_W; ++x ) {
            for ( var y = 0; y != FIELD_H; ++y ) {
                drawBlock( x, y, dc );    
            }     
        }
    }

    function timerCallback() as Void {
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        var myTimer = new Timer.Timer();
        myTimer.start(method(:timerCallback), 50, true);
        posX = dc.getWidth() / 2;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function drawBlock( x as Lang.Number, y as Lang.Number, dc as Dc ) as Void {
        dc.drawRectangle(2 + BLOCK_SIZE * x, 2 + BLOCK_SIZE * y, BLOCK_SIZE - 1, BLOCK_SIZE - 1);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var curUpdateTime = System.getTimer();
        var duration = curUpdateTime - prevUpdateTime;
        prevUpdateTime = curUpdateTime;

        if( prevTick + tickDuration <= curUpdateTime ) {
            gameplay.Tick();
            prevTick = curUpdateTime;
        }     

        if( moveLeft ) {
            posX -= 1;
        } else if( moveRight ) {
            posX += 1;
        }
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        TestDraw();

        dc.drawBitmap(24, 16, offscreenBuffer);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY);
        dc.fillCircle( posX, posY, 10 );
        dc.drawText(169, 90, Graphics.FONT_LARGE, gameplay.score, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        var endUpdateTime = System.getTimer();
        dc.drawText(144, 32, Graphics.FONT_XTINY, (endUpdateTime - curUpdateTime).format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        posY += 1;

        if( posY > dc.getHeight() )
        {
            posY = 0;
        }
    }

    function rotate() as Void {
        gameplay.rotate();
    }

    function shiftPrimitive( dir as Lang.Number ) as Void {
        gameplay.shiftPrimitive(dir); 
    }

    function accelDown() as Void {
        gameplay.accelDown();
    }

    function TestDraw() as Void {
        var tstField = gameplay.BuildFieldForDraw();

        var dc = offscreenBuffer.getDc();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.clear();
        dc.drawRectangle(0, 0, BUFF_W, BUFF_H);

        for (var x = 0; x != FIELD_W; ++x ) {
            for ( var y = 0; y != FIELD_H; ++y ) {

                if( tstField[ x + y * FIELD_W] == 1 ) {
                    drawBlock( x, y, dc );
                }                 
            }     
        }

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
