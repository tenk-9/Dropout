// plate moves X-Z, Credit drops Y+ -> Y-

int MAX_X = 30;
int MAX_Z = 30;
int AREA_WALL_Y = 10000000;

PlayArea area;
PVector cameraEye, cameraPlace;
PVector playAreaCenter = new PVector(0,0,0);
void setup() {
    size(800, 800, P3D);
    background(32);
    noStroke();
    smooth();
    area = new PlayArea(MAX_X * 2, AREA_WALL_Y, MAX_Z * 2);
    cameraPlace = new PVector(
        (float)MAX_X * 0.85,
        25,
        0
    );
    hint(ENABLE_DEPTH_SORT); // 透過表現を正しく行わせるため
}

void draw() {
    background(0);
    camera(
        cameraPlace.x, cameraPlace.y, cameraPlace.z,
        0, -50, 0, // later: this may be center of movingPlate
        0, -1, 0
    );
    //rotate by mouse
    rotateY(map(mouseX, 0, width, TWO_PI, -TWO_PI));
    perspective(PI/1.5, float(width)/float(height), 1, AREA_WALL_Y);
    area.put(playAreaCenter);
}