class KeyState{
    // class to check which key is pressed
    private HashMap<Integer, Boolean> states;
    public KeyState(){
        states = new HashMap<Integer, Boolean>();
        // init keyPressed variable of target keys
        // states.put(UP, false);
        // states.put(LEFT, false);
        // states.put(DOWN, false);
        // states.put(RIGHT, false);
        states.put((int)'W', false);
        states.put((int)'A', false);
        states.put((int)'S', false);
        states.put((int)'D', false);
    }
    public boolean get(int keycode){
        // get state with keyCode integer
        return states.get(keyCode);
    }
    public boolean get(char keyChar){
        // get state with char of key
        if(keyChar >= 'a')
            keyChar -= 0x20;
        return states.get((int)keyChar);
    }
    public void set(int keycode, boolean state){
        states.put(keycode, state);
    }
}
