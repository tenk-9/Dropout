// plate moves X-Z, Credit drops Y+ -> Y-

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