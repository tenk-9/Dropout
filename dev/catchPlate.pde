class CatchPlate{
    // plate own var
    private final PVector _size;
    private PVector _coordinate;
    private color _fillColor, _strokeColor;
    // phisics var
    private float _mass = 1;
    private PVector _velocity, _force;
    private final float _forceSize = 0.5;
    // area limitation var
    public boolean moveAreaLimitation = false;
    private PVector _moveArea = new PVector(0, 0, 0);

    public CatchPlate(PVector size, color stroke){
        _size = size;
        _strokeColor = stroke;
        _velocity = new PVector(0, 0, 0);
    }
    public void put(PVector coordinate){
        _coordinate = coordinate;
        noFill();
        stroke(_strokeColor);
        pushMatrix();
            translate(_coordinate.x, _coordinate.y, _coordinate.z);
            box(_size.x, _size.y, _size.z);
        popMatrix();
    }
    public void moveAreaSetting(PVector movableAreaSize){
        // movable area is the 3D area centered (0,0,0)
        this.moveAreaLimitation = true;
        _moveArea = movableAreaSize;
    }
    private void _coordinateLimitation(){
        // x-Plus limit, x-miNus limit, ...
        float xplim, xnlim, yplim, ynlim, zplim, znlim;
        xplim = _moveArea.x / 2 - _size.x / 2;
        xnlim = -xplim;
        yplim = _moveArea.y / 2 - _size.y / 2;
        ynlim = -yplim;
        zplim = _moveArea.z / 2 - _size.z / 2;
        znlim = -zplim;
        // x
        if(_coordinate.x > xplim){
            _coordinate.x = xplim;
            _velocity.x = 0;
        }
        if(_coordinate.x < xnlim){
            _coordinate.x = xnlim;
            _velocity.x = 0;
        }
        // y
        if(_coordinate.y > yplim){
            _coordinate.y = yplim;
            _velocity.y = 0;
        }
        if(_coordinate.y < ynlim){
            _coordinate.y = ynlim;
            _velocity.y = 0;
        }
        // z
        if(_coordinate.z > zplim){
            _coordinate.z = zplim;
            _velocity.z = 0;
        }
        if(_coordinate.z < znlim){
            _coordinate.z = znlim;
            _velocity.z = 0;
        }  
    }
    public void update(){
        // add force to plate object
        PVector a, dCoord;
        // delta time = 1frame
        float dt = 1.0;
        _force = new PVector(0, 0, 0);
        if(keyPressed){
            // add force by pressed keys
            switch(key){
                // wasd
                case 'w':
                    _force.x -= _forceSize;
                    break;
                case 'a':
                    _force.z -= _forceSize;
                    break;
                case 's':
                    _force.x += _forceSize;
                    break;
                case 'd':
                    _force.z += _forceSize;
                    break;
                // dir keys
                case UP:
                    _force.x -= _forceSize;
                    break;
                case LEFT:
                    _force.z -= _forceSize;
                    break;
                case DOWN:
                    _force.x += _forceSize;
                    break;
                case RIGHT:
                    _force.z += _forceSize;
                    break;
                default:
                    break;
            }
        }
        // a = F/m
        a = PVector.div(_force, _mass);
        // dx = v0*dt + 1/2*a*(dt^2)
        dCoord = PVector.add(
            PVector.mult(_velocity, dt),
            PVector.mult(a, 0.5*dt*dt)
        );
        _coordinate = PVector.add(_coordinate, dCoord);
        // v = v0+a*dt
        _velocity = PVector.add(_velocity, PVector.mult(a, dt));

        // move area limitation
        if(moveAreaLimitation)
            _coordinateLimitation();
        // reput
        put(_coordinate);
    }
    public PVector getCoordinate(){
        return _coordinate;
    }
    public PVector getSize(){
        return _size;
    }

}
