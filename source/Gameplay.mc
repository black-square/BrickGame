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

class Gameplay  {
    var field = new[FIELD_W * FIELD_H];
    var curPrim as Lang.Array?;
    var primPosX = 0;
    var primPosY = 0;

    function rotate() as Void {
        var res = new [PRIM_SIZE * PRIM_SIZE];

        for (var i = 0; i < PRIM_SIZE; ++i) {
            for (var j = 0; j < PRIM_SIZE; ++j) {
                res[i + j * PRIM_SIZE] = curPrim[j + (PRIM_SIZE - i - 1) * PRIM_SIZE];
            }
        }

        curPrim = res;
    }

    function pickNewPrim() as Void {
        curPrim = PRIMITIVES[ Math.rand() % PRIMITIVES.size() ];
        var rotNum = Math.rand() % 4;

        for (var i = 0; i < rotNum; ++i) {
            rotate();
        }
    }

    function initialize() {
        pickNewPrim();  
    }

    function placeCurPrim( resField as Lang.Array ) as Void {
        for (var i = 0; i < PRIM_SIZE; ++i) {
            for (var j = 0; j < PRIM_SIZE; ++j) {
                resField[i + primPosX + (j + primPosY) * FIELD_W] = curPrim[i + j * PRIM_SIZE];
            }
        }
    }

    function BuildFieldForDraw() as Lang.Array {
        var newField = new[FIELD_W * FIELD_H];

        for (var i = 0; i != newField.size(); ++i ) {
            newField[i] = field;   
        }

        placeCurPrim(newField);

        return newField;
    }

    function Tick() as Void {
        primPosY += 1;   
    }



}