import Toybox.Lang;

const FIELD_W = 10;
const FIELD_H = 20;
const PRIM_SIZE = 4;

const PRIMITIVES = [ 
    [   0, 0, 0, 0,
        0, 1, 1, 0,
        0, 1, 1, 0, 
        0, 0, 0, 0, ],

    [   0, 0, 1, 0,
        0, 0, 1, 0,
        0, 0, 1, 0, 
        0, 0, 1, 0, ],

    [   0, 0, 0, 0,
        0, 1, 1, 0,
        1, 1, 0, 0, 
        0, 0, 0, 0, ],

    [   0, 0, 0, 0,
        1, 1, 0, 0,
        0, 1, 1, 0, 
        0, 0, 0, 0, ],

    [   0, 1, 0, 0,
        0, 1, 0, 0,
        0, 1, 1, 0, 
        0, 0, 0, 0, ],

    [   0, 0, 1, 0,
        0, 0, 1, 0,
        0, 1, 1, 0, 
        0, 0, 0, 0, ],

    [   0, 0, 0, 0,
        1, 1, 1, 0,
        0, 1, 0, 0, 
        0, 0, 0, 0, ],
];

const SCORES = [0, 4, 10, 30, 120];

class Rect {
    var left = 0;
    var top = 0;
    var right = 0;
    var bottom = 0;


    function initialize() {
        reset();
    }

    function reset() as Void {
        left = FIELD_W;
        top = FIELD_H;
        right = 0;
        bottom = 0;
    }

    function expand (l as Lang.Number, t as Lang.Number, r as Lang.Number, b as Lang.Number) as Void {
        if( l < left ) {
            left = l;
        }

        if( t < top ) {
            top = t;
        }

        if( r > right ) {
            right = r;
        }

        if( b > bottom ) {
            bottom = b;
        }
    }

    function expandRect ( x as Lang.Number, y as Lang.Number, r as Rect ) as Void {
        expand( x, y, x + r.right - r.left, y + r.bottom - r.top );
    }


    function calcMatixBounds( data as Lang.Array, width as Lang.Number, height as Lang.Number ) as Void {    
        reset();
        
        for (var x = 0; x < width; ++x) {
            for (var y = 0; y < height; ++y) {
                if( data[x + y * width] == 1 ) {
                    if( x < left ){
                        left = x;
                    }

                    if( y < top ) {
                        top = y;
                    }

                    if( x > right ) {
                        right = x;
                    }

                    if( y > bottom ) {
                        bottom = y;
                    }
                }
            }
        }

        right += 1;
        bottom += 1;
    }
}

class Primitive {
    var data as Lang.Array?;
    var bounds as Rect = new Rect();    

    function rotateImp() as Void {
        var res = new [PRIM_SIZE * PRIM_SIZE];

        for (var x = 0; x < PRIM_SIZE; ++x) {
            for (var y = 0; y < PRIM_SIZE; ++y) {
                res[x + y * PRIM_SIZE] = data[y + (PRIM_SIZE - x - 1) * PRIM_SIZE];
            }
        }

        data = res;  
    }

    function rotate() as Void {
        rotateImp();
        bounds.calcMatixBounds( data, PRIM_SIZE, PRIM_SIZE );
    }

    function pickNewPrim() as Lang.Number {
        data = PRIMITIVES[ Math.rand() % PRIMITIVES.size() ];
        var rotNum = Math.rand() % 4;

        for (var i = 0; i < rotNum; ++i) {
            rotateImp();
        }

        bounds.calcMatixBounds( data, PRIM_SIZE, PRIM_SIZE );

        return (FIELD_W - (bounds.right - bounds.left)) / 2;
    }

    function placeCurPrim( posX as Lang.Number, posY as Lang.Number, field as Lang.Array ) as Void {
        posX -= bounds.left;
        posY -= bounds.top;
        
        for (var x = bounds.left; x < bounds.right; ++x) {
            for (var y = bounds.top; y < bounds.bottom; ++y) {
                if( data[x + y * PRIM_SIZE] == 1 ) {
                    field[posX + x + (posY + y) * FIELD_W] = 1;
                }
            }
        }
    }

    function detectCollision( posX as Lang.Number, posY as Lang.Number, field as Lang.Array ) as Boolean {
        if( posY + bounds.bottom - bounds.top > FIELD_H ) {
            return true;
        }

        posX -= bounds.left;
        posY -= bounds.top;
        
        for (var x = bounds.left; x < bounds.right; ++x) {
            for (var y = bounds.top; y < bounds.bottom; ++y) {
                if ( field[posX + x + (posY + y) * FIELD_W] == 1 && data[x + y * PRIM_SIZE] == 1 ) {
                    return true;
                }
            }
        }

        return false;
    }
}

class Gameplay  {
    var field = new[FIELD_W * FIELD_H];
    var dirtyRect as Rect = new Rect();
    
    var primPosX = 0;
    var primPosY = 0;
    var curPrim = new Primitive();
    var score = 0;
    var tickDuration = 1000;

    function initialize() {
        primPosX = curPrim.pickNewPrim();  
        dirtyRect.expandRect( primPosX, primPosY, curPrim.bounds );
    }

    function BuildFieldForDraw() as Lang.Array {
        var newField = field.slice(null, null);

        curPrim.placeCurPrim(primPosX, primPosY, newField);
        var resRect = dirtyRect;
        dirtyRect = new Rect();

        return [newField, resRect];
    }

    function RemoveRow( posY as Lang.Number ) as Void {
        for( var y = posY; y > 0; --y ) {

            var nextY = y - 1;

            for( var x = 0; x < FIELD_W ; ++x )  {
                field[x + y * FIELD_W] = field[x + nextY * FIELD_W];  
            }
        }

        for( var x = 0; x < FIELD_W ; ++x )  {
            field[x + 0 * FIELD_W] = 0;  
        }

        dirtyRect.expand( 0, 0, FIELD_W, posY + 1 );  
    }

    function DetectAndRemoveFilledRows() as Lang.Number {
        var matchedRowsIdx = new[PRIM_SIZE];
        var matchedRowsCount = 0;

        for( var y = primPosY; y < primPosY + curPrim.bounds.bottom - curPrim.bounds.top; ++y ) {
            for( var x = 0;; ++x )  {
                if( x == FIELD_W ) {
                    matchedRowsIdx[y - primPosY] = 1;
                    ++matchedRowsCount;
                    break; 
                }

                if( field[x + y * FIELD_W] != 1 ) {
                    break;
                }         
            }
        }

        for( var y = 0; y < PRIM_SIZE; ++y ) {
            if( matchedRowsIdx[y] == 1 ) {
                RemoveRow( y + primPosY );    
            }
        }
            
        return matchedRowsCount;
    }

    function Tick() as Void {
        if( curPrim.detectCollision(primPosX, primPosY + 1, field) ) {
            curPrim.placeCurPrim(primPosX, primPosY, field);

            var matchedRowsCount = DetectAndRemoveFilledRows();

            score += SCORES[matchedRowsCount];
            primPosX = curPrim.pickNewPrim();
            primPosY = 0;
        } else {
            dirtyRect.expandRect( primPosX, primPosY, curPrim.bounds );
            primPosY += 1;
        }

        dirtyRect.expandRect( primPosX, primPosY, curPrim.bounds );  
    }

    function shiftPrimitive( dir as Lang.Number ) as Void {
        var newPosX = primPosX + dir;
        
        if( newPosX >= 0 && newPosX + curPrim.bounds.right - curPrim.bounds.left <= FIELD_W && 
            !curPrim.detectCollision(newPosX, primPosY, field) ) 
        {
            dirtyRect.expandRect( primPosX, primPosY, curPrim.bounds ); 
            primPosX = newPosX;
            dirtyRect.expandRect( primPosX, primPosY, curPrim.bounds ); 
        }
    }

    function rotate() as Void {
        var newPosX = primPosX;

        dirtyRect.expandRect( primPosX, primPosY, curPrim.bounds );
        curPrim.rotate();

        var primWidth = curPrim.bounds.right - curPrim.bounds.left;

        if( newPosX + primWidth > FIELD_W ) {
            newPosX = FIELD_W - primWidth;
        }      

        if( curPrim.detectCollision(newPosX, primPosY, field) ) {
            for (var i = 0; i < 3; ++i) {
                curPrim.rotate();
            }
        } else { 
            primPosX = newPosX;
            dirtyRect.expandRect( primPosX, primPosY, curPrim.bounds );     
        } 
    }

    function accelDown() as Void {
        do{
            Tick();            
        } while ( primPosY != 0 );
    }
}