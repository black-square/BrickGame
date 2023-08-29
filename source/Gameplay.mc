import Toybox.Lang;

const FIELD_W = 10;
const FIELD_H = 34;
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

class Primitive {
    var data as Lang.Array?;
    var left = 0;
    var top = 0;
    var right = 0;
    var bottom = 0;

    function initialize() {
        pickNewPrim();  
    }

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

    function pickNewPrim() as Void {
        data = PRIMITIVES[ Math.rand() % PRIMITIVES.size() ];
        var rotNum = Math.rand() % 4;

        for (var i = 0; i < rotNum; ++i) {
            rotateImp();
        }

        calcBounds();
    }

    function placeCurPrim( posX as Lang.Number, posY as Lang.Number, field as Lang.Array ) as Void {
        posX -= left;
        posY -= top;
        
        for (var x = left; x < right; ++x) {
            for (var y = top; y < bottom; ++y) {
                if( data[x + y * PRIM_SIZE] == 1 ) {
                    field[x + posX + (y + posY) * FIELD_W] = 1;
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
                if ( field[x + posX + (y + posY) * FIELD_W] == 1 && data[x + y * PRIM_SIZE] == 1 ) {
                    return true;
                }
            }
        }

        return false;
    }
}

class Gameplay  {
    var field = new[FIELD_W * FIELD_H];
    
    var primPosX = FIELD_W / 2;
    var primPosY = 0;
    var curPrim = new Primitive();


    function BuildFieldForDraw() as Lang.Array {
        var newField = new[FIELD_W * FIELD_H];

        for (var i = 0; i != newField.size(); ++i ) {
            newField[i] = field[i];   
        }

        curPrim.placeCurPrim(primPosX, primPosY, newField);

        return newField;
    }

    function Tick() as Void {
        if( curPrim.detectCollision(primPosX, primPosY + 1, field) ) {
            curPrim.placeCurPrim(primPosX, primPosY, field);
            curPrim.pickNewPrim();
            primPosY = 0;
        } else {
            primPosY += 1;
        } 
    }

    function rotate() as Void {
        curPrim.rotate();
    }



}