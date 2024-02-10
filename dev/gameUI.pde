class GameUI{
    // this class handles: infomation window, finish message
    // text variables
    private final int _textSize = 4;
    private final int _textShift = _textSize / 2;
    private PFont _font;
    // finishUI variables
    private final color _endUiFill = color(220, 220, 139, 20);

    // textWindow variables
    private final color _textWindowFill = color(48, 10, 36, 200);
    private final color _textWindowStroke = color(35, 35, 35);
    private final int _textWindowStrokeWeight = 2;
    private final color _textGreen = color(39, 148, 98);
    private final color _textBlue = color(17, 56, 119);
    private final color _textWhite = color(255, 255, 255);
    private final float _textFloatZ = -0.001;
    private final PVector _textWindowTL = new PVector(-MaxX, -50, MaxZ / 2);
    private final PVector _textWindowSize = new PVector(MaxX * 2 - 10, 40);

    //functions
    public GameUI(){}
    public void setFont(String fontPath){
        // this should called at setup()
        _font = loadFont(fontPath);
    }
    public void drawFinishUI(float score){
        // render game finish UI
        pushMatrix();
                // draw end message on x-z, y=0
                rotateX(-HALF_PI);
                noStroke();
                fill(_endUiFill);
                rectMode(CENTER);
                rect(0, 0, MaxX * 2, MaxZ * 2);
                String endMsg = "GAME\nFINISHED!";
                String scoreMsg = "SCORE: " + score;
                textAlign(CENTER);
                fill(_textWhite);
                textSize(12);
                text(endMsg, 0, -10, 0.001);
                textSize(9);
                text(scoreMsg, 0, 40, 0.001);
            popMatrix();
    }
    public void drawTextWindow(boolean finished, int itemLeft, int gainedItems){
        // show instructions, leftItems, etc as window like Ubuntu console
        textAlign(LEFT, CENTER);
        textSize(_textSize);
        textFont(_font, _textSize);
        pushMatrix();
            scale(1, -1, 1);
            // window
            _textWindow();
            noStroke();
            // command
            _textCommand();
            // statusMsg
            _textGameStatus(finished, itemLeft, gainedItems);
        popMatrix();
        
    }
    private void _textWindow(){
        pushMatrix();
            translate(0, 0, _textWindowTL.z);
            fill(_textWindowFill);
            stroke(_textWindowStroke);
            strokeWeight(3);
            rectMode(CORNER);
            rect(
                _textWindowTL.x, _textWindowTL.y, 
                _textWindowSize.x, _textWindowSize.y
            );
            strokeWeight(1); // reset weight
        popMatrix();
    }
    private void _textCommand(){
        fill(_textGreen);
        text(
            "21140036@TMU", 
            _textWindowTL.x + _textShift * 1, 
            _textWindowTL.y + _textShift, 
            _textWindowTL.z + _textFloatZ
        );
        fill(_textWhite);
        text(
            ":", 
            _textWindowTL.x + _textShift * 14,
            _textWindowTL.y + _textShift, 
            _textWindowTL.z + _textFloatZ
        );
        fill(_textBlue);
        text(
            "CG/hw/final",
            _textWindowTL.x + _textShift * 15, 
            _textWindowTL.y + _textShift, 
            _textWindowTL.z + _textFloatZ
        );
        fill(_textWhite);
        text(
            "$ game info",
            _textWindowTL.x + _textShift * 27, 
            _textWindowTL.y + _textShift, 
            _textWindowTL.z + _textFloatZ
        );
    }
    private void _textDescription(){

    }
    private void _textKeyStatus(KeyState keyState){
        
    }
    private void _textGameStatus(boolean finished, int itemLeft, int gainedItems){
        final String re;
        if(finished)
            re = "Finished";
        else
            re = "Playing";
        // draw status text
        fill(_textWhite);
        text(
            " * Game status",
            _textWindowTL.x,
            _textWindowTL.y + _textShift * 3,
            _textWindowTL.z + _textFloatZ
        );
        text(
            "  - Status:      " + re,
            _textWindowTL.x,
            _textWindowTL.y + _textShift * 5,
            _textWindowTL.z + _textFloatZ
        );
        text(
            "  - Item left:   " + itemLeft,
            _textWindowTL.x,
            _textWindowTL.y + _textShift * 7,
            _textWindowTL.z + _textFloatZ
        );
        text(
            "  - Item gained: " + gainedItems, 
            _textWindowTL.x,
            _textWindowTL.y + _textShift * 9,
            _textWindowTL.z + _textFloatZ
        );
    }
    
}