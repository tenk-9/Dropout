// plate moves X-Z, Credit drops Y+ -> Y-

// ----------------------------------------------------
// game system variables
// ----------------------------------------------------
final int TotalCredits = 50;
int appearedCredits = 0;
float gainedWeights = 0;
int gainedItems = 0;
float GPA = 0;
class GameState{
  static final int PLAYING = 0;
  static final int PAUSING = 1;
  static final int FINISHED = 2;
};
int modeState = GameState.PLAYING;

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
    ambientLight(100, 100, 100);
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