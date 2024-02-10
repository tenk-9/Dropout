class GameUI{
    // this class handles: infomation window, finish message
    // text variables
    private final int _textSize = 4;
    private final int _textShift = _textSize / 2;
    private PFont _font;
    private final color _textGreen = color(39, 148, 98);
    private final color _textBlue = color(17, 56, 119);
    private final color _textWhite = color(255, 255, 255);
    private final color _textCyan = color(44, 148, 166);
    
    // finishUI variables
    private final color _endUiFill = color(220, 220, 139, 20);

    // textWindow variables
    private final color _textWindowFill = color(48, 10, 36, 200);
    private final color _textWindowStroke = color(35, 35, 35);
    private final int _textWindowStrokeWeight = 2;
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
                String endMsg = "GAME\n\nFINISHED!";
                String scoreMsg = "SCORE: " + score;
                textAlign(CENTER);
                fill(_textWhite);
                textSize(12);
                text(endMsg, 0, -10, 0.001);
                textSize(9);
                text(scoreMsg, 0, 40, 0.001);
            popMatrix();
    }
    public void drawTextWindow(boolean finished, int itemLeft, int gainedItems, KeyState keyState){
        // show instructions, leftItems, etc as window like Ubuntu console
        textAlign(LEFT, CENTER);
        textSize(_textSize);
        textFont(_font, _textSize);
        pushMatrix();
            scale(1, -1, 1);
            rotateX(-PI / 6);
            // window
            translate(_textWindowTL.x, _textWindowTL.y, _textWindowTL.z);
            _textWindow();
            noStroke();
            // command
            translate(_textShift, 0, 0);
            _textCommand();
            // description
            translate(0, _textShift * 3, 0);
            _textDescription();
            // key pressed state
            translate(_textShift * 7, _textShift * 2, 0);
            _textKeyStatus(keyState);
            // statusMsg
            translate(-_textShift * 7, _textShift * 4, 0);
            // _textGameStatus(finished, itemLeft, gainedItems);
            _textGameStatus(finished, itemLeft, gainedItems);
        popMatrix();
        
    }
    private void _textWindow(){
        pushMatrix();
            fill(_textWindowFill);
            stroke(_textWindowStroke);
            strokeWeight(3);
            rectMode(CORNER);
            rect(
                0, 0, 
                _textWindowSize.x, _textWindowSize.y
            );
            strokeWeight(1); // reset weight
        popMatrix();
    }
    private void _textCommand(){
        fill(_textGreen);
        text(
            "21140036@TMU", 
           0, _textShift, _textFloatZ
        );
        fill(_textWhite);
        text(
            ":", 
            _textShift * 13, _textShift, _textFloatZ
        );
        fill(_textBlue);
        text(
            "CG/hw/final",
            _textShift * 14, _textShift, _textFloatZ
        );
        fill(_textWhite);
        text(
            "$ game info",
            _textShift * 26, _textShift, _textFloatZ
        );
    }
    private void _textDescription(){
        // description (about this game) and key operation
        fill(_textWhite);
        text(
            " * Description",
            0, 0, _textFloatZ
        );
        text(
            "  Use ",
            0, _textShift * 2, _textFloatZ
        );
        // W A S D
        text(
            "to move plate,",
            _textShift * 15, _textShift * 2, _textFloatZ
        );
        text(
            "  and get falling item AMAP!",
            0, _textShift * 4, _textFloatZ
        );
    }
    private void _textKeyStatus(KeyState keyState){
        // draw W A S D, filled Cyan which is pressed
        // w
        if(keyState.get('W'))
            fill(_textCyan);
        else
            fill(_textWhite);
        text("W", 0, 0, _textFloatZ);
        // a
        if(keyState.get('A'))
            fill(_textCyan);
        else
            fill(_textWhite);
        text("A", _textShift * 2, 0, _textFloatZ);
        // s
        if(keyState.get('S'))
            fill(_textCyan);
        else
            fill(_textWhite);
        text("S", _textShift * 4, 0, _textFloatZ);
        // d
        if(keyState.get('D'))
            fill(_textCyan);
        else
            fill(_textWhite);
        text("D", _textShift * 6, 0, _textFloatZ);
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
            0, 0, _textFloatZ
        );
        text(
            "  - Status:      " + re,
            0, _textShift * 2, _textFloatZ
        );
        text(
            "  - Item left:   " + itemLeft,
            0, _textShift * 4, _textFloatZ
        );
        text(
            "  - Item gained: " + gainedItems, 
            0, _textShift * 6, _textFloatZ
        );
    }
    
}