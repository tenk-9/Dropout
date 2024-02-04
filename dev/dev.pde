// plate moves X-Z, Credit drops Y+ -> Y-

final int MaxX = 100;
final int MaxZ = 100;
final int AreaWallY = 10000000;
final float CreditInitY = 100;
final float CreditRelocateY = -3000;

PlayArea area;
CreditSphere credit1, credit2;
CatchPlate plate;
PVector cameraEye, cameraPlace;
PVector playAreaCenter = new PVector(0,0,0);
PVector creditInit = new PVector(0,200,0);
PVector plateInit = new PVector(0,0,0);
PVector plateSize = new PVector(30, 2, 30);


boolean collided(CreditSphere credit, CatchPlate plate){
    // return collided with CatchPlate.
    // when this._coordinate is in CatchPlatre's body, return true;
    
    float xplim, xnlim, yplim, ynlim, zplim, znlim; // x-Plus limit, x-miNus limit, ...
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

void setup() {
    // global settings
    size(800, 800, P3D);
    background(32);
    noStroke();
    frameRate(30);
    // smooth();
    sphereDetail(10);
    hint(ENABLE_DEPTH_SORT); // for correct transparency rendering
    // object defenition
    area = new PlayArea(MaxX * 2, AreaWallY, MaxZ * 2);
    credit1 = new CreditSphere(10, 1, color(255, 0, 0, 64));
    credit1.put(creditInit);
    credit2 = new CreditSphere(5, 1000, color(0, 255, 0, 64));
    credit2.put(new PVector(50,200,0));
    plate = new CatchPlate(plateSize, color(158, 16, 6));
    cameraPlace = new PVector(
        (float)MaxX * 0.85,
        80,
        0
    );
    plate.put(plateInit);
    plate.moveAreaSetting(new PVector(MaxX * 2, 100, MaxZ * 2));
}

void draw() {
    background(0);
    // camera settings
    cameraEye = plate.getCoordinate();
    camera(
        cameraPlace.x, cameraPlace.y, cameraPlace.z,
        0, -50, 0, // later: this may be center of movingPlate
        0, -1, 0
    );
    perspective(PI/1.5, float(width)/float(height), 1, AreaWallY);

    // rendering
    area.put(playAreaCenter);
    plate.update();
    credit1.relocateSetting(
        CreditRelocateY,
        new PVector(
            random(credit1.getR(), MaxX - credit1.getR()),
            CreditInitY,
            random(credit1.getR(), MaxZ - credit1.getR())
        )
    );
    credit2.relocateSetting(
        CreditRelocateY,
        new PVector(
            random(credit2.getR(), MaxX - credit2.getR()),
            CreditInitY,
            random(credit2.getR(), MaxZ - credit2.getR())
        )
    );
    credit1.update();
    credit2.update();

    if(collided(credit1, plate)){
        credit1.relocate();
    }
    if(collided(credit2, plate)){
        credit2.relocate();
    }
    // print(credit1.getY(), '\n');
    
}