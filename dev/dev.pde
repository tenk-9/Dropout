// plate moves X-Z, Credit drops Y+ -> Y-

final int MaxX = 100;
final int MaxZ = 100;
final int AreaWallY = 10000000;
final float CreditInitY = 100;
final float CreditRelocateY = -3000;

PlayArea area;
PVector cameraEye, cameraPlace;
PVector playAreaCenter = new PVector(0,0,0);
PVector creditInit = new PVector(0,200,0);
CreditSphere credit1, credit2;
void setup() {
    size(800, 800, P3D);
    background(32);
    noStroke();
    frameRate(30);
    // smooth();
    sphereDetail(10);
    hint(ENABLE_DEPTH_SORT); // for correct transparency rendering
    area = new PlayArea(MaxX * 2, AreaWallY, MaxZ * 2);
    cameraPlace = new PVector(
        (float)MaxX * 0.85,
        80,
        0
    );
    credit1 = new CreditSphere(10, 1, color(255, 0, 0));
    credit1.put(creditInit);
    credit2 = new CreditSphere(5, 1000, color(0, 255, 0));
    credit2.put(new PVector(50,200,0));
}

void draw() {
    background(0);
    camera(
        cameraPlace.x, cameraPlace.y, cameraPlace.z,
        0, -50, 0, // later: this may be center of movingPlate
        0, -1, 0
    );
    //rotate by mouse
    // rotateY(map(mouseX, 0, width, TWO_PI, -TWO_PI));
    perspective(PI/1.5, float(width)/float(height), 1, AreaWallY);


    area.put(playAreaCenter);
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
    // print(credit1.getY(), '\n');
    
}