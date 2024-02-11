// ver: 24021100

// ----------------------------------------------------
// game system variables
// ----------------------------------------------------
final int TotalCredits = 50;
int appearedCredits = 0;
float gainedWeights = 0;
int gainedItems = 0;
float GPA = 0;
enum GameState{
    PLAYING,
    PAUSING,
    FINISHED
};
GameState modeState = GameState.PLAYING;

// ----------------------------------------------------
// environment variables
// ----------------------------------------------------
// PlayArea
final int MaxX = 50;
final int MaxZ = 50;
final int AreaWallY = 10000000;
// CreditSphere
final int HandleCreditCount = 5;
final int MinPutY = 200;
final int MaxPutY = 1000;
final float RelocateYThres = -2500;
boolean EnableRelocation = true;

// ----------------------------------------------------
// object definitions
// ----------------------------------------------------
// PlayArea
PlayArea area = new PlayArea(MaxX * 2, AreaWallY, MaxZ * 2);
PVector playAreaCenter = new PVector(0,0,0);
// CreditSpheres
CreditSphere[] credits = new CreditSphere[HandleCreditCount];
// CatchPlate
PVector plateInit = new PVector(0,0,0);
PVector plateSize = new PVector(20, 2, 20);
CatchPlate plate = new CatchPlate(plateSize);
// camera
PVector cameraEye = new PVector(0, 0, 0);
PVector cameraPlace = new PVector(0, (float)MaxX * 1, -(float)MaxZ * 0.95);
// UI
GameUI UI = new GameUI();

// ----------------------------------------------------
// keyPress handller
// ----------------------------------------------------
KeyState keyState = new KeyState();
void keyPressed(){
    keyState.set(keyCode, true);
}
void keyReleased() {
    keyState.set(keyCode, false);
}

// ----------------------------------------------------
// rendering
// ----------------------------------------------------
void setup() {
    // global settings
    size(800, 800, P3D);
    background(32);
    noStroke();
    frameRate(30);
    // font file must have been created by "Tool/CreateFont".
    // bigger size, clearer edge.
    UI.setFont("Consolas-100.vlw");
    // game score init
    appearedCredits = HandleCreditCount;
    // smooth();
    sphereDetail(5);
    hint(ENABLE_DEPTH_SORT); // for correct transparency rendering
    // objects config
    area.fogRendering(true);
    plate.moveAreaSetting(new PVector(MaxX * 2, 100, MaxZ * 2));
    // put objects
    for (int i = 0; i < HandleCreditCount; ++i) {
        // define credits
        float r = map(i, 0, HandleCreditCount, 5, 30); // radius ranged [5, 30]
        float m = map(i, 0, HandleCreditCount -1, 1, 5); // mass ranged [1, 5]
        colorMode(HSB, HandleCreditCount);
        color c = color(i, 3, 3, 2);
        colorMode(RGB, 255); // reset colorMode
        credits[i] = new CreditSphere(r, m, c);

        // put
        PVector place = new PVector(
            random(-MaxX + r, MaxX - r),
            random(MinPutY, MaxPutY),
            random(-MaxZ + r, MaxZ - r)
        );
        credits[i].put(place);
    }
    plate.put(plateInit);
}
void draw() {
    background(0);
    // ------------------------
    // camera settings
    // ------------------------
    // cameraEye.z = plate.getCoordinate().z;
    camera(
        cameraPlace.x, cameraPlace.y, cameraPlace.z,
        cameraEye.x, cameraEye.y, cameraEye.z, // later: this may be center of movingPlate
        0, -1, 0
    );
    perspective(PI/1.5, float(width)/float(height), 1, AreaWallY);

    // ------------------------
    // UI rendering
    // ------------------------
    UI.drawTextWindow(
        modeState,
        TotalCredits - appearedCredits,
        gainedItems,
        keyState
    );
    if(modeState == GameState.FINISHED){
        UI.drawFinishUI(GPA);
    }
    
    // ------------------------
    // watch game system
    // ------------------------
    // game end detection
    if(appearedCredits >= TotalCredits && modeState == GameState.PLAYING){
        EnableRelocation = false;
        boolean allCreditPassed = true;
        for (int i = 0; i < HandleCreditCount; ++i) {
            allCreditPassed = allCreditPassed && (credits[i].getY() <= -plate.getSize().y);
        }
        // all Credits appeared AND all existing credits are passed
        // -> GAME END
        if(allCreditPassed){
            modeState = GameState.FINISHED;
            GPA = (float)gainedWeights / TotalCredits;
        }
    }
    // restart
    if(keyState.get('R') || modeState == GameState.PAUSING){
        UI.restartSelect();
        if(keyState.get('Y'))
        {
            modeState = GameState.PLAYING;
            // init variables
            appearedCredits = 0;
            plate.resetMass();
            gainedWeights = 0;
            gainedItems = 0;
            GPA = 0;
            // item will relocate.
            for (int i = 0; i < HandleCreditCount; ++i) {
                PVector yInf = new PVector(0, RelocateYThres * 2, 0);
                credits[i].relocate(yInf);
                EnableRelocation = true;
            }
        }
        else if(keyState.get('N'))
        {
            modeState = GameState.PLAYING;
        }
        else{
            modeState = GameState.PAUSING;
        }
    }
    
    

    // ------------------------
    // update object states
    // ------------------------
    // play area
    area.put(playAreaCenter);
    if(modeState == GameState.PLAYING){
        // plate
        plate.addForce(keyState);
        plate.update();
        // credits
        for (int i = 0; i < HandleCreditCount; ++i) {
            float r = credits[i].getR();
            // relocate place
            PVector place = new PVector(
                random(-MaxX + r, MaxX - r),
                random(MinPutY, MaxPutY),
                random(-MaxZ + r, MaxZ - r)
            );
            // relocation
            if(EnableRelocation && (credits[i].getPlace().y < RelocateYThres)){
                credits[i].relocate(place);
                appearedCredits += 1;
            }
            // update state
            credits[i].update();
            // collision handle
            if(collided(credits[i], plate)){
                // when collided, put credit far away
                // item will relocate on next frame.
                PVector yInf = new PVector(
                    credits[i].getPlace().x,
                    RelocateYThres * 2,
                    credits[i].getPlace().z
                );
                credits[i].relocate(yInf);
                plate.addMass(credits[i].getMass());
                gainedWeights += credits[i].getMass();
                gainedItems += 1;
            }
        }
    }

}

// ----------------------------------------------------
// collision handler
// ----------------------------------------------------
boolean collided(CreditSphere credit, CatchPlate plate){
    // return collided with CatchPlate.
    // when this._coordinate is in CatchPlatre's body, return true;
    PVector plateCoord = plate.getCoordinate();
    PVector plateSize = plate.getSize();
    PVector creditCoord = credit.getPlace();
    float creditR = credit.getR();
    boolean xCond, yCond, zCond;
    // y-axis collision condition
    yCond = abs(plateCoord.y - creditCoord.y) <= plateSize.y + creditR;
    // center of credit must be in plate's x-z area
    xCond = (
        ((plateCoord.x - plateSize.x / 2) <= creditCoord.x)
        &&
        (creditCoord.x <= (plateCoord.x + plateSize.x / 2))
    );
    zCond = (
        ((plateCoord.z - plateSize.z / 2) <= creditCoord.z)
        &&
        (creditCoord.z <= (plateCoord.z + plateSize.z / 2))
    );
    return xCond && yCond && zCond;
}

// ----------------------------------------------------
// catch plate
// ----------------------------------------------------
class CatchPlate{
    // plate own var
    private final PVector _size;
    private PVector _coordinate;
    private final color _fillColor = color(58, 201, 176, 120);
    private final color _strokeColor = color(58, 201, 176);
    // phisics var
    private final float _initMass = 300;
    private float _mass = _initMass;
    private PVector _velocity = new PVector(0, 0, 0);
    private PVector _force = new PVector(0, 0, 0);
    private final float _forceSize = 60000;
    // area limitation var
    public boolean moveAreaLimitation = false;
    private PVector _moveArea = new PVector(0, 0, 0);

    public CatchPlate(PVector size){
        _size = size;
    }
    public void put(PVector coordinate){
        _coordinate = coordinate;
        fill(_fillColor);
        stroke(_strokeColor);
        pushMatrix();
            translate(_coordinate.x, _coordinate.y, _coordinate.z);
            box(_size.x, _size.y, _size.z);
        popMatrix();
    }
    public void moveAreaSetting(PVector movableAreaSize){
        // movable area is the 3D area centered (0,0,0)
        this.moveAreaLimitation = true;
        _moveArea = movableAreaSize;
    }
    private void _coordinateLimitation(){
        // x-Plus limit, x-miNus limit, ...
        float xplim, xnlim, yplim, ynlim, zplim, znlim;
        xplim = _moveArea.x / 2 - _size.x / 2;
        xnlim = -xplim;
        yplim = _moveArea.y / 2 - _size.y / 2;
        ynlim = -yplim;
        zplim = _moveArea.z / 2 - _size.z / 2;
        znlim = -zplim;
        // x
        if(_coordinate.x > xplim){
            _coordinate.x = xplim;
            _velocity.x = 0;
        }
        if(_coordinate.x < xnlim){
            _coordinate.x = xnlim;
            _velocity.x = 0;
        }
        // y
        if(_coordinate.y > yplim){
            _coordinate.y = yplim;
            _velocity.y = 0;
        }
        if(_coordinate.y < ynlim){
            _coordinate.y = ynlim;
            _velocity.y = 0;
        }
        // z
        if(_coordinate.z > zplim){
            _coordinate.z = zplim;
            _velocity.z = 0;
        }
        if(_coordinate.z < znlim){
            _coordinate.z = znlim;
            _velocity.z = 0;
        }  
    }
    public void addForce(KeyState keyState){
        _force = new PVector(0, 0, 0);
        // wasd
        if(keyState.get('w')){
            _force.z += _forceSize;
        }
        if(keyState.get('a')){
            _force.x -= _forceSize;
        }
        if(keyState.get('s')){
            _force.z -= _forceSize;
        }
        if(keyState.get('d')){
            _force.x += _forceSize;
        }
        // direction keys
        // if(keyState.get(UP)){
        //     _force.z += _forceSize;
        // }
        // if(keyState.get(LEFT)){
        //     _force.x -= _forceSize;
        // }
        // if(keyState.get(DOWN)){
        //     _force.z -= _forceSize;
        // }
        // if(keyState.get(RIGHT)){
        //     _force.x += _forceSize;
        // }
    }
    public void update(){
        // add force to plate object
        PVector a, dCoord;
        // delta time = 1frame
        float dt = 1.0 / frameRate;
        // a = F/m
        a = PVector.div(_force, _mass);
        // dx = v0*dt + 1/2*a*(dt^2)
        dCoord = PVector.add(
            PVector.mult(_velocity, dt),
            PVector.mult(a, 0.5*dt*dt)
        );
        _coordinate = PVector.add(_coordinate, dCoord);
        // v = v0+a*dt
        _velocity = PVector.add(_velocity, PVector.mult(a, dt));

        // move area limitation
        if(moveAreaLimitation)
            _coordinateLimitation();
        // reput
        put(_coordinate);
    }
    public PVector getCoordinate(){
        return _coordinate;
    }
    public PVector getSize(){
        return _size;
    }
    public void addMass(float increace){
        _mass += increace;
    }
    public float getMass(){
        return _mass;
    }
    public void resetMass(){
        _mass = _initMass;
    }
}

// ----------------------------------------------------
// credit sphere
// ----------------------------------------------------
class CreditSphere{
    // phisics environment var
    private final float GravityAcc = -0.1;
    private final float AirResistanceCoef = 0.001;
    // sphere var
    private final float _r, _mass;
    private float _v;
    private PVector _coordinate;
    private color _bodyColor = color(255, 255, 255, 255);
    // prediction circle var
    private final float _predictionStartY = 500;
    private final float _predCircleR = 15, _predCircleDetail = 10;
    private color _predColor = color(255, 0, 0, 20);

    public CreditSphere(float r, float mass, color fillColor){
        _r = r;
        _mass = mass;
        _v = 0;
        _bodyColor = fillColor;
    }
    public void put(PVector initPlace){
        // place the sphere
        _coordinate = initPlace;
        pushMatrix();
            translate(_coordinate.x, _coordinate.y, _coordinate.z);
            noStroke();
            fill(_bodyColor);
            sphere(_r);
        popMatrix();
        _drawPredCircle();
    }
    private void _drawPredCircle(){
        // Prediction circle, with dynamic radius (far:big -> close: small)
        if(_coordinate.y <= 0){
            return;
        }
        // prediction appears _coordinate.y in (0,_predictionStartY]
        if(_coordinate.y <= _predictionStartY){
            float alpha = map(_coordinate.y, 0, _predictionStartY, 255, 0);
            float radius = map(_coordinate.y, 0, _predictionStartY, 0, _predCircleR);
            // draw circle
            noFill();
            stroke(
                red(_predColor),
                green(_predColor),
                blue(_predColor),
                alpha
            );
            strokeWeight(1.5);
            pushMatrix();
                translate(_coordinate.x, 0, _coordinate.z);
                beginShape();
                    for (int i = 0; i <= _predCircleDetail; ++i) {
                        vertex(
                            radius * cos(TWO_PI / _predCircleDetail * i),
                            0,
                            radius * sin(TWO_PI / _predCircleDetail * i)
                        );
                    }
                endShape(CLOSE);
            popMatrix();
            strokeWeight(1); // reset stroke width
        }
    }
    public PVector getPlace(){
        return _coordinate;
    }
    public float getY(){
        return _coordinate.y;
    }
    public float getR(){
        return _r;
    }
    public void update(){
        // update coordinate (next frame condition) and reput sphere.
        // reflect realistic phisics: free fall, air resistance
        // calc _v & _coordinate.y @ next frame
        // gravity force: _m * GravityAcc (- direction on y-axis)
        // air resistance force: -K * _v (+ direction on y-axis)
        // total force: airResist - gravity
        double gravity, airResist, totalForce, accel, k = AirResistanceCoef;
        gravity = _mass * GravityAcc;
        airResist = -k * _v;
        totalForce = airResist + gravity;
        accel = totalForce / _mass;
        // time delta: 1frame
        _coordinate.y += _v * 1.0 + 1/2 * (accel * (1.0 * 1.0));
        _v += accel * 1.0;
        // reput
        put(_coordinate);
    }
    public void relocate(PVector place){
        _v = 0;
        put(place);
    }
    public float getMass(){
        return _mass;
    }
}

// ----------------------------------------------------
// UI
// ----------------------------------------------------
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
    private final PVector _textWindowTL = new PVector(-MaxX * 1.5, -55, MaxZ * 0.8);
    private final PVector _textWindowSize = new PVector(MaxX * 2 - 10, 40);

    // restart window variables
    private final PVector _restartWindowSize = new PVector(MaxX * 2 - 10, 40);
    private final PVector _restartWindowTL = new PVector(-_restartWindowSize.x / 2, -40, -MaxZ * 0.3);

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
                String endMsg = "\nGAME\nFINISHED!";
                String scoreMsg = "SCORE: " + score;
                textAlign(CENTER);
                fill(_textWhite);
                textSize(12);
                text(endMsg, 0, -10, 0.001);
                textSize(12);
                text(scoreMsg, 0, 35, 0.001);
                textSize(4);
                text("Press 'R' to restart.", 0, 45, 0.001);
            popMatrix();
    }
    public void drawTextWindow(GameState stateEnum, int itemLeft, int gainedItems, KeyState keyState){
        // show instructions, leftItems, etc as window like Ubuntu console
        textAlign(LEFT, CENTER);
        textSize(_textSize);
        textFont(_font, _textSize);
        pushMatrix();
            scale(1, -1, 1);
            translate(_textWindowTL.x, _textWindowTL.y, _textWindowTL.z);
            rotateY(-PI / 18);
            rotateX(-PI / 6);
            // window
            _textWindow(_textWindowSize);
            noStroke();
            // command
            translate(_textShift, _textShift, 0);
            _textCommand();
            // description
            translate(0, _textShift * 2, 0);
            _textDescription();
            // key pressed state
            translate(_textShift * 8, _textShift * 2, 0);
            _textKeyStatus(keyState);
            // statusMsg
            translate(-_textShift * 8, _textShift * 4, 0);
            _textGameStatus(stateEnum, itemLeft, gainedItems);
            // GitHub link
            // translate(0, _textShift * 8, 0);
            // _textGithub();
        popMatrix();
    }
    private void _textWindow(PVector size){
        pushMatrix();
            fill(_textWindowFill);
            stroke(_textWindowStroke);
            strokeWeight(3);
            rectMode(CORNER);
            rect(
                0, 0, 
                size.x, size.y
            );
            strokeWeight(1); // reset weight
        popMatrix();
    }
    private void _textCommand(){
        fill(_textGreen);
        text(
            "21140036@TMU", 
           0, 0, _textFloatZ
        );
        fill(_textWhite);
        text(
            ":", 
            _textShift * 13, 0, _textFloatZ
        );
        fill(_textBlue);
        text(
            "CG/hw/final",
            _textShift * 14, 0, _textFloatZ
        );
        fill(_textWhite);
        text(
            "$ game info",
            _textShift * 26, 0, _textFloatZ
        );
    }
    private void _textDescription(){
        // description (about this game) and key operation
        fill(_textWhite);
        text(
            " * Description:",
            0, 0, _textFloatZ
        );
        text(
            "   Use ",
            0, _textShift * 2, _textFloatZ
        );
        // W A S D
        text(
            "to move plate,",
            _textShift * 16, _textShift * 2, _textFloatZ
        );
        text(
            "   and get falling item AMAP!",
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
    private void _textGameStatus(GameState stateEnum, int itemLeft, int gainedItems){
        final String re;
        switch (stateEnum) {
            case FINISHED :
                re = "Finished";
            break;	
            case PAUSING :
                re = "Pausing";
            break;	
            case PLAYING :
                re = "Playing";
            break;	
            default :
                re = "Undefined";
            break;	
        }
        // draw status text
        fill(_textWhite);
        text(
            " * Game status:",
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
    private void _textGithub(){
        // put link to GitHub repo
        fill(_textWhite);
        text(
            " * See more details:",
            0, 0, _textFloatZ
        );
        text(
            "   https://github.com/tenk-9/Dropout",
            0, _textShift * 2, _textFloatZ
        );
    }
    public void restartSelect(){
        textAlign(LEFT, CENTER);
        textSize(_textSize);
        textFont(_font, _textSize);
        pushMatrix();
            // put window
            scale(1, -1, 1);
            translate(_restartWindowTL.x, _restartWindowTL.y, _restartWindowTL.z);
            rotateX(-PI/3.9);
            _textWindow(_restartWindowSize);
            // message
            translate(_textShift / 2, _textShift, 0);
            fill(_textWhite);
            text(
                "KeyboardInterrupt:",
                0, 0, _textFloatZ
            );
            text(
                " 'R' key was pressed.",
                0, _textShift * 2, _textFloatZ
            );
            text(
                " Do you want to restart?",
                0, _textShift * 6, _textFloatZ
            );
            textAlign(CENTER, CENTER);
            text(
                "Yes (Y)       No (N)",
                _restartWindowSize.x / 2, _textShift * 10, _textFloatZ
            );
        popMatrix();
    }
}

// ----------------------------------------------------
// keyState
// ----------------------------------------------------
class KeyState{
    // class to check which key is pressed
    private HashMap<Integer, Boolean> states;
    public KeyState(){
        states = new HashMap<Integer, Boolean>();
        // init keyPressed variable of target keys
        // states.put(UP, false);
        // states.put(LEFT, false);
        // states.put(DOWN, false);
        // states.put(RIGHT, false);
        states.put((int)'W', false);
        states.put((int)'A', false);
        states.put((int)'S', false);
        states.put((int)'D', false);
        states.put((int)'R', false);
        states.put((int)'Y', false);
        states.put((int)'N', false);
    }
    public boolean get(int keycode){
        // get state with keyCode integer
        return states.get(keyCode);
    }
    public boolean get(char keyChar){
        // get state with char of key
        if(keyChar >= 'a')
            keyChar -= 0x20;
        return states.get((int)keyChar);
    }
    public void set(int keycode, boolean state){
        states.put(keycode, state);
    }
}

// ----------------------------------------------------
// playArea
// ----------------------------------------------------
class PlayArea{
    float _xSize, _zSize;
    float _wallHeight;
    float _wallPeakY = 20;
    color _wallColor = color(31, 31, 31, 180);
    color _edgeColor = color(97, 118, 116, 180);
    color _fogColor = color(5, 5, 5, 10);
    color _Y0Color = color(220, 220, 170);
    private boolean _activateFog = true;

    PVector _center;
    PlayArea(int xSize, int ySize, int zSize) {
        this._xSize = xSize;
        this._zSize = zSize;
        this._wallHeight = ySize;
    }
    void put(PVector center) {
        // put playArea @center
        float x, y, z;
        x = center.x;
        y = center.y;
        z = center.z;
        // put walls
        pushMatrix();
            translate(x, y, z);
            stroke(180);
            fill(this._wallColor);
            beginShape(QUAD_STRIP);
                vertex(this._xSize/2, this._wallPeakY, this._zSize/2);
                vertex(this._xSize/2, -this._wallHeight, this._zSize/2);
                vertex(-this._xSize/2, this._wallPeakY, this._zSize/2);
                vertex(-this._xSize/2, -this._wallHeight, this._zSize/2);
                vertex(-this._xSize/2, this._wallPeakY, -this._zSize/2);
                vertex(-this._xSize/2, -this._wallHeight, -this._zSize/2);
                vertex(this._xSize/2, this._wallPeakY, -this._zSize/2);
                vertex(this._xSize/2, -this._wallHeight, -this._zSize/2);
                vertex(this._xSize/2, this._wallPeakY, this._zSize/2);
                vertex(this._xSize/2, -this._wallHeight, this._zSize/2);
            endShape(CLOSE);
        popMatrix();
        // draw Y=0 line
        pushMatrix();
            translate(x, y, z);
            stroke(this._Y0Color);
            noFill();
            beginShape(QUAD);
                vertex(this._xSize/2, 0, this._zSize/2);
                vertex(-this._xSize/2, 0, this._zSize/2);
                vertex(-this._xSize/2, 0, -this._zSize/2);
                vertex(this._xSize/2, 0, -this._zSize/2);
            endShape(CLOSE);
        popMatrix();
        // far fog
        if(_activateFog){
            pushMatrix();
                noStroke();
                translate(x, -200, z);
                fill(this._fogColor);
                float tp = (float)alpha(this._fogColor) / 255; // transparency, 透明度
                float stopTp = 0.0001; // この透明度を達成するまでfogを重ねる
                int dup = (int)(Math.log(stopTp)/Math.log(1 - tp)); // fogを重ねる回数
                for (int i = 0; i < dup; ++i) {
                    translate(0, -50, 0);
                    beginShape(QUAD);
                        vertex(this._xSize/2, 0, this._zSize/2);
                        vertex(-this._xSize/2, 0, this._zSize/2);
                        vertex(-this._xSize/2, 0, -this._zSize/2);
                        vertex(this._xSize/2, 0, -this._zSize/2);
                    endShape(CLOSE);
                }
            popMatrix();
        }
        
    }
    public void fogRendering(boolean mode){
        _activateFog = mode;
    }
}
