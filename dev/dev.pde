// plate moves X-Z, Credit drops Y+ -> Y-

// ----------------------------------------------------
// game system variables
// ----------------------------------------------------
final int TotalCredits = 50;
int appearedCredits = 0;
int gainedWeights = 0;
float GPA = 0;
PFont font;

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
// rendering
// ----------------------------------------------------
void setup() {
    // global settings
    size(800, 800, P3D);
    background(32);
    noStroke();
    frameRate(30);
    font = createFont("YuGothicUI-Bold-30", 20);
    textFont(font);
    // game score init
    appearedCredits = HandleCreditCount;
    // smooth();
    sphereDetail(10);
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
    
    
    // // camera settings
    // cameraEye.z = plate.getCoordinate().z;
    camera(
        cameraPlace.x, cameraPlace.y, cameraPlace.z,
        cameraEye.x, cameraEye.y, cameraEye.z, // later: this may be center of movingPlate
        0, -1, 0
    );
    // UI rendering
    if(appearedCredits >= TotalCredits){
        EnableRelocation = false;
        pushMatrix();
            // draw end message on x-z, y=0
            rotateX(-HALF_PI);
            fill(220, 220, 139, 128);
            rectMode(CENTER);
            rect(0, 0, MaxX * 2, MaxZ * 2);
            GPA = (float)gainedWeights / TotalCredits;
            String endMsg = "GAME\nFINISHED!";
            String scoreMsg = "SCORE: " + GPA;
            textAlign(CENTER);
            fill(24, 24, 24);
            textSize(12);
            text(endMsg, 0, -10, 0.001);
            textSize(10);
            text(scoreMsg, 0, 40, 0.001);
        popMatrix();
    }
    perspective(PI/1.5, float(width)/float(height), 1, AreaWallY);
    
    area.put(playAreaCenter);
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
        }
    }
    // // update score
    print(gainedWeights, '/', TotalCredits, ',', appearedCredits, '\n');
    // // print(credit1.getY(), '\n');
    
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