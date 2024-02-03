// plate moves X-Z, Credit drops Y- -> Y+

int MAX_X = 30;
int MAX_Z = 30;
int AREA_WALL_Y = 100000;

PlayArea area;
PVector cameraEye;
PVector areaCenter = new PVector(0,0,0);
void setup() {
    size(1000, 1000, P3D);
    background(32);
    noStroke();
    area = new PlayArea(MAX_X, AREA_WALL_Y, MAX_Z);
}

void draw() {
    
    camera(0, -200, -50, 0, 0, 0, 1, 1, 1);
    area.put(areaCenter);
    fill(255);
    sphere(10);
}

class PlayArea{
    float _xSize, _zSize;
    float _wallHeight;
    color _wallColor = color(31, 31, 31, 180);
    PVector _center;
    PlayArea(int xSize, int ySize, int zSize){
        this._xSize = xSize;
        this._zSize = zSize;
        this._wallHeight = ySize;
    }
    void put(PVector center){
        // put playArea @center
        float x, y, z;
        x = center.x;
        y = center.y;
        z = center.z;
        pushMatrix();
            translate(x, -this._wallHeight / 2, z);
            // put walls
            stroke(180);
            fill(this._wallColor);
            beginShape(QUAD_STRIP);
                vertex(this._xSize / 2, 0, this._zSize);
                vertex(this._xSize / 2, this._wallHeight, this._zSize);
                vertex(-this._xSize / 2, 0, this._zSize);
                vertex(-this._xSize / 2, this._wallHeight, this._zSize);
                vertex(-this._xSize / 2, 0, -this._zSize);
                vertex(-this._xSize / 2, this._wallHeight, -this._zSize);
                vertex(this._xSize / 2, 0, -this._zSize);
                vertex(this._xSize / 2, this._wallHeight, -this._zSize);
            endShape(CLOSE);
        popMatrix();
    }
    // PVector bottom(){
    //     return new PVector(this._center.x, this._center.y + this._wallHeight / 2, this.center.z);
    // }
}