// plate moves X-Z, Credit drops Y+ -> Y-

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
    private final float _predCircleR = 15, _predCircleDetail = 10;
    private color _predColor = color(255, 0, 0, 20);
    // relocate var
    private float _relocateThresY = -3000;
    private PVector _relocatePlace = new PVector(0, 0, 0);
    public boolean activateRelocate = false;

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
        // prediction appears _coordinate.y in (0,100]
        float alpha = map(_coordinate.y, 0, 100, 255, 0);
        float radius = map(_coordinate.y, 0, 100, 0, _predCircleR);
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
        if(this.activateRelocate && _coordinate.y < _relocateThresY){
            relocate();
        }
    }
    public void relocate(){
        _v = 0;
        put(_relocatePlace);
    }
    public void relocateSetting(float thresY, PVector place){
        this.activateRelocate = true;
        _relocateThresY = thresY;
        _relocatePlace = place;
    }
    public void disableRelocate(){
        this.activateRelocate = false;
    }
}