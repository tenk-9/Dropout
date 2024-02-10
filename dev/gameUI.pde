class GameUI{
    // this class handles: infomation window, finish message
    // text variables
    private final int _textSize = 4;
    private final int _textShift = _textSize / 2;
    private PFont _font;
    // finishUI variables
    private final color _endUiFill = color(220, 220, 139, 20);

    // textWindow variables
    private final color _textWindowFill = color(48, 10, 36);
    private final color _textWindowStroke = color(35, 35, 35);
    private final int _textWindowStrokeWeight = 3;
    private final color _textGreen = color(39, 148, 98);
    private final color _textBlue = color(17, 56, 119);
    private final color _textWhite = color(255, 255, 255);
    private final float _textFloatZ = -0.001;
    private final PVector _statusWindowTL = new PVector(-MaxX, -50, MaxZ);
    private final PVector _statusWindowSize = new PVector(MaxX * 2 - 10, 20);

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
            translate(0, 0, MaxZ);
            fill(_textWindowFill);
            stroke(_textWindowStroke);
            strokeWeight(3);
            rectMode(CORNER);
            rect(
                _statusWindowTL.x, _statusWindowTL.y, 
                _statusWindowSize.x, _statusWindowSize.y
            );
            strokeWeight(1); // reset weight
        popMatrix();
    }
    private void _textCommand(){
        fill(_textGreen);
        text(
            "21140036@TMU", 
            _statusWindowTL.x + _textShift * 1, 
            _statusWindowTL.y + _textShift, 
            _statusWindowTL.z + _textFloatZ
        );
        fill(_textWhite);
        text(
            ":", 
            _statusWindowTL.x + _textShift * 14,
            _statusWindowTL.y + _textShift, 
            _statusWindowTL.z + _textFloatZ
        );
        fill(_textBlue);
        text(
            "~/hw/final",
            _statusWindowTL.x + _textShift * 15, 
            _statusWindowTL.y + _textShift, 
            _statusWindowTL.z + _textFloatZ
        );
        fill(_textWhite);
        text(
            "$ game info",
            _statusWindowTL.x + _textShift * 26, 
            _statusWindowTL.y + _textShift, 
            _statusWindowTL.z + _textFloatZ
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
            _statusWindowTL.x,
            _statusWindowTL.y + _textShift * 3,
            _statusWindowTL.z + _textFloatZ
        );
        text(
            "  - Status:      " + re,
            _statusWindowTL.x,
            _statusWindowTL.y + _textShift * 5,
            _statusWindowTL.z + _textFloatZ
        );
        text(
            "  - Item left:   " + itemLeft,
            _statusWindowTL.x,
            _statusWindowTL.y + _textShift * 7,
            _statusWindowTL.z + _textFloatZ
        );
        text(
            "  - Item gained: " + gainedItems, 
            _statusWindowTL.x,
            _statusWindowTL.y + _textShift * 9,
            _statusWindowTL.z + _textFloatZ
        );
    }
    
}