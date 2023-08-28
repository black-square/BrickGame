import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;

const FIELD_W = 10;
const FIELD_H = 34;
const BLOCK_SIZE = 5;


class FallingBricksView extends WatchUi.View {

    var posY = 0;
    var posX = 0;

    var moveLeft = false;
    var moveRight = false;
    var prevUpdateTime = System.getTimer(); 
    //var offscreenBuffer as Graphics.BufferedBitmap;
    
    function initialize() {
        View.initialize();

        // if (Toybox.Graphics has :BufferedBitmap) { 
        //     offscreenBuffer = new Toybox.Graphics.BufferedBitmap(
        //         {:width=>1,
        //          :height=>1,
        //          :palette=>[Graphic.COLOR_DK_GRAY,
        //                     Graphics.COLOR_LT_GRAY,
        //                     Graphics.COLOR_BLACK,
        //                     Graphics.COLOR_WHITE]} );
        // }

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
        dc.drawRectangle(42 + 2 + BLOCK_SIZE * x, 1 + 2 + BLOCK_SIZE * y, 4, 4);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var curUpdateTime = System.getTimer();
        var duration = curUpdateTime - prevUpdateTime;
        prevUpdateTime = curUpdateTime;
        //System.println( "onUpdate " + duration );

        if( moveLeft ) {
            posX -= 1;
        } else if( moveRight ) {
            posX += 1;
        }
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY);
        dc.fillCircle( posX, posY, 10 );
        var fps = (duration > 0 ? (1000 + duration >> 2) / duration: 0).format("%d");
        dc.drawText(144, 32, Graphics.FONT_XTINY, fps,  Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawRectangle(42, 1, FIELD_W * BLOCK_SIZE + 3, FIELD_H * BLOCK_SIZE + 3);

        for (var x = 0; x != FIELD_W; ++x ) {
            for ( var y = 0; y != FIELD_H; ++y ) {
                drawBlock( x, y, dc );    
            }     
        }



        posY += 1;

        if( posY > dc.getHeight() )
        {
            posY = 0;
        }
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
