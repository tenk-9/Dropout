// plate moves X-Z, Credit drops Y+ -> Y-

// ----------------------------------------------------
// game system variables
// ----------------------------------------------------
final int TotalCredits = 50;
int appearedCredits = 0;
int gainedWeights = 0;
int gainedItems = 0;
float GPA = 0;
boolean gameFinished = false;


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
    PFont consoals = loadFont("Consolas-20.vlw");
    textFont(consoals, 20);
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
    // camera settings
    // cameraEye.z = plate.getCoordinate().z;
    camera(
        cameraPlace.x, cameraPlace.y, cameraPlace.z,
        cameraEye.x, cameraEye.y, cameraEye.z, // later: this may be center of movingPlate
        0, -1, 0
    );
    perspective(PI/1.5, float(width)/float(height), 1, AreaWallY);
    // UI rendering
    if(appearedCredits >= TotalCredits){
        EnableRelocation = false;
        boolean allCreditPassed = true;
        for (int i = 0; i < HandleCreditCount; ++i) {
            allCreditPassed = allCreditPassed && (credits[i].getY() <= -plate.getSize().y);
        }
        // all Credits appeared AND all existing credits are passed
        // -> GAME END
        if(allCreditPassed){
            gameFinished = true;
            pushMatrix();
                // draw end message on x-z, y=0
                rotateX(-HALF_PI);
                noStroke();
                fill(220, 220, 139, 20);
                rectMode(CENTER);
                rect(0, 0, MaxX * 2, MaxZ * 2);
                GPA = (float)gainedWeights / TotalCredits;
                String endMsg = "GAME\nFINISHED!";
                String scoreMsg = "SCORE: " + GPA;
                textAlign(CENTER);
                fill(242, 242, 242);
                textSize(12);
                text(endMsg, 0, -10, 0.001);
                textSize(9);
                text(scoreMsg, 0, 40, 0.001);
            popMatrix();
        }
    }
    // game info
    final color textWindowFill = color(48, 10, 36);
    final color textWindowStroke = color(35, 35, 35);
    final int textWindowStrokeWeight = 3;
    final color textGreen = color(39, 148, 98);
    final color textBlue = color(17, 56, 119);
    final color textWhite = color(255, 255, 255);
    final int textSize = 4;
    final int textShift = textSize / 2;
    final float textFloatZ = -0.001;
    final PVector statusWindowTL = new PVector(-MaxX, -50, MaxZ);
    final PVector statusWindowSize = new PVector(MaxX * 2 - 10, 20);
    pushMatrix();
        scale(1, -1, 1);
        // draw window
        pushMatrix();
        translate(0, 0, MaxZ);
            fill(textWindowFill);
            stroke(textWindowStroke);
            strokeWeight(3);
            rectMode(CORNER);
            rect(
                statusWindowTL.x, statusWindowTL.y, 
                statusWindowSize.x, statusWindowSize.y
            );
            strokeWeight(1);
        popMatrix();
        // put text
        textAlign(LEFT, CENTER);
        textSize(textSize);
        noStroke();
        // text/command
        fill(textGreen);
        text(
            "21140036@TMU", 
            statusWindowTL.x + textShift * 1, 
            statusWindowTL.y + textShift, 
            statusWindowTL.z + textFloatZ
        );
        fill(textWhite);
        text(
            ":", 
            statusWindowTL.x + textShift * 14,
            statusWindowTL.y + textShift, 
            statusWindowTL.z + textFloatZ
        );
        fill(textBlue);
        text(
            "~/hw/final",
            statusWindowTL.x + textShift * 15, 
            statusWindowTL.y + textShift, 
            statusWindowTL.z + textFloatZ
        );
        fill(textWhite);
        text(
            "$ game info",
            statusWindowTL.x + textShift * 26, 
            statusWindowTL.y + textShift, 
            statusWindowTL.z + textFloatZ
        );
        // text/info
        fill(textWhite);
        text(
            " * Mode:   " + (TotalCredits - appearedCredits),
            statusWindowTL.x,
            statusWindowTL.y + textShift * 2,
            statusWindowTL.z + textFloatZ
        );
        text(
            " * Item left:   " + (TotalCredits - appearedCredits),
            statusWindowTL.x,
            statusWindowTL.y + textShift * 4,
            statusWindowTL.z + textFloatZ
        );
        text(
            " * Item gained: " + gainedItems, 
            statusWindowTL.x,
            statusWindowTL.y + textShift * 6,
            statusWindowTL.z + textFloatZ
        );
    popMatrix();
    // control description
    pushMatrix();
        scale(1, -1, 1);
        fill(242, 242, 242);
        rotateY(HALF_PI);
        String controlDescString = "Use: \nto move plate and get items AMAP!";
        textAlign(LEFT, BOTTOM);
        textSize(10);
        text(controlDescString, -MaxX, -30, MaxZ - 0.001);
    popMatrix();

    // play area
    area.put(playAreaCenter);
    //plate
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