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

class PlayArea{
    float _xSize, _zSize;
    float _wallHeight;
    float _wallPeakY = 20;
    color _wallColor = color(31, 31, 31, 180);
    color _edgeColor = color(97, 118, 116, 180);
    color _fogColor = color(5, 5, 5, 10);
    color _Y0Color = color(220, 220, 170);
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