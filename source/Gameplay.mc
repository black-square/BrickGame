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

const SCORES = [0, 40, 100, 300, 1200];

class Primitive {
    var data as Lang.Array?;
    var left = 0;
    var top = 0;
    var right = 0;
    var bottom = 0;

    function calcBounds() as Void {    
        left = PRIM_SIZE;
        top = PRIM_SIZE;
        right = 0;
        bottom = 0;
        
        for (var x = 0; x < PRIM_SIZE; ++x) {
            for (var y = 0; y < PRIM_SIZE; ++y) {
                if( data[x + y * PRIM_SIZE] == 1 ) {
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
        calcBounds();
    }

    function pickNewPrim() as Lang.Number {
        data = PRIMITIVES[ Math.rand() % PRIMITIVES.size() ];
        var rotNum = Math.rand() % 4;

        for (var i = 0; i < rotNum; ++i) {
            rotateImp();
        }

        calcBounds();

        return (FIELD_W - (right - left)) / 2;
    }

    function placeCurPrim( posX as Lang.Number, posY as Lang.Number, field as Lang.Array ) as Void {
        posX -= left;
        posY -= top;
        
        for (var x = left; x < right; ++x) {
            for (var y = top; y < bottom; ++y) {
                if( data[x + y * PRIM_SIZE] == 1 ) {
                    field[posX + x + (posY + y) * FIELD_W] = 1;
                }
            }
        }
    }

    function detectCollision( posX as Lang.Number, posY as Lang.Number, field as Lang.Array ) as Boolean {
        if( posY + bottom - top > FIELD_H ) {
            return true;
        }

        posX -= left;
        posY -= top;
        
        for (var x = left; x < right; ++x) {
            for (var y = top; y < bottom; ++y) {
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
    
    var primPosX = 0;
    var primPosY = 0;
    var curPrim = new Primitive();
    var score = 0;

    function initialize() {
        primPosX = curPrim.pickNewPrim();  
    }

    function BuildFieldForDraw() as Lang.Array {
        var newField = new[FIELD_W * FIELD_H];

        for (var i = 0; i != newField.size(); ++i ) {
            newField[i] = field[i];   
        }

        curPrim.placeCurPrim(primPosX, primPosY, newField);

        return newField;
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
    }

    function DetectAndRemoveFilledRows() as Lang.Number {
        var matchedRowsIdx = new[PRIM_SIZE];
        var matchedRowsCount = 0;

        for( var y = primPosY; y < primPosY + curPrim.bottom - curPrim.top; ++y ) {
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

            primPosX = curPrim.pickNewPrim();
            primPosY = 0;
            score += SCORES[matchedRowsCount];      
        } else {
            primPosY += 1;
        } 
    }

    function shiftPrimitive( dir as Lang.Number ) as Void {
        var newPosX = primPosX + dir;
        
        if( newPosX >= 0 && newPosX + curPrim.right - curPrim.left <= FIELD_W && 
            !curPrim.detectCollision(newPosX, primPosY, field) ) 
        {
            primPosX = newPosX;
        }
    }

    function rotate() as Void {
        var newPosX = primPosX;

        curPrim.rotate();

        var primWidth = curPrim.right - curPrim.left;

        if( newPosX + primWidth > FIELD_W ) {
            newPosX = FIELD_W - primWidth;
        }      

        if( curPrim.detectCollision(newPosX, primPosY, field) ) {
            for (var i = 0; i < 3; ++i) {
                curPrim.rotate();
            }
        } else {
            primPosX = newPosX;    
        } 
    }

    function accelDown() as Void {
        do{
            Tick();            
        } while ( primPosY != 0 );
    }
}