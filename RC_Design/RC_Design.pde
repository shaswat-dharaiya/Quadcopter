/*
21/05/2019
Author: Shaswat Dharaiya
Contact: shaswat.dharaiya@gmail.com
Code is plugged to Quadcopter Remote Controller.
It is the first pluggable version of code.
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Index:
1) Global Variables
2) Constructor for ControlButtons Class
3) Variables & Constructors:
  3.1) ControlButtons Class
  3.2) Thrust Class
  3.3) Battery Class
  3.4) MPU Class
4) setup() & draw() 
5) serialEvent() & movement()
6) BaseShape class
7) ControlButtons Class
8) Thrust Class
9) Battery Class
10) MPU Class
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////Global Variables/////////////////////////////////////////////////
import processing.serial.*;
Serial myPort;  // Create object from Serial class
boolean firstContact = false;
boolean initialization = true;

int fontSize = 15;
int rectSize = 80;     // Diameter of rect
int power = 100;
int thrst_pow = 50;
String incommingString = "0.00:0.00:0.00:0.00:0.00:0.00:V0.00:0.00:T1000:1000:1000:1000:;";
String outgoingString = "",val = "",prev_val = "";
String buttonClickVal = "";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////Constructor for ControlButtons Class////////////////////////////////////////

ControlButtons thrst = new ControlButtons("Lift", 'w');
ControlButtons lnd = new ControlButtons("Drop", 's');
ControlButtons role_l = new ControlButtons("Role Left", '4');
ControlButtons role_r = new ControlButtons("Role Right", '6');
ControlButtons ptch_fwd = new ControlButtons("Forward", '8');
ControlButtons ptch_bkd = new ControlButtons( "Backward", '5');
ControlButtons yaw_cw = new ControlButtons("Yaw +", 'a');
ControlButtons yaw_ccw = new ControlButtons("Yaw -", 'd');
ControlButtons reset = new ControlButtons("Reset", 'r');
//ControlButtons hld = new ControlButtons(("Hold",' ');

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////Variables for Thrust Class////////////////////////////////////////////////////

int rectCol = 200;
int thrst_val_1=1000, thrst_val_2=1000, thrst_val_3=1000, thrst_val_4=1000, thrst_val=1000;

/////////////////////////////////////////////////Constructor for Thrust Class/////////////////////////////////////////////////

Thrust rot0 = new Thrust("Thrust", thrst_val,0);
Thrust rot1 = new Thrust("Rotor 1", thrst_val_1,0);    //  ccw rotors
Thrust rot2 = new Thrust("Rotor 2", thrst_val_2,1);    //  cw rotors
Thrust rot3 = new Thrust("Rotor 3", thrst_val_3,2);    //  cw rotors
Thrust rot4 = new Thrust("Rotor 4", thrst_val_4,3);    //  ccw rotors

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////Variables for Battery Class///////////////////////////////////////////////////

float vlt1,vlt2;
int bat1_pos_x, bat1_pos_y,bat2_pos_x,bat2_pos_y;
int batLen = 100,batWid = 25; 

/////////////////////////////////////////////////Constructor for Battery Class////////////////////////////////////////////////

Battery bt1 = new Battery(vlt1,bat1_pos_x,bat1_pos_y,"Main",12.1,0);
Battery bt2 = new Battery(vlt2,bat2_pos_x,bat2_pos_y,"2nd",9,1);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////Variables for MPU Class////////////////////////////////////////////////////

int mpuBox = 500;

///////////////////////////////////////////////////Constructor for MPU Class//////////////////////////////////////////////////

MPU mpu = new MPU();//incommingString);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////This is the Setup Method()////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  size(1300, 850);
  try {               
    smooth();
    thrst.posRect(rectSize+10, 0);
    lnd.posRect(rectSize+10, 2*(rectSize+10));
    yaw_cw.posRect(0, rectSize+10);
    yaw_ccw.posRect(2*(rectSize+10), rectSize+10);
    ptch_fwd.posRect(5*rectSize+10, 0);
    ptch_bkd.posRect(5*rectSize+10, 2*(rectSize+10));
    role_l.posRect(4*rectSize, rectSize+10);
    role_r.posRect(6*rectSize+20, rectSize+10); 
    //hld.posRect(300, 200);
    int i = 13;
    reset.posRect(((i+4)*width/20+10),2*(rectCol+rectSize));
    rot0.posRect(((i+4)*width/20), rectCol);
    rot1.posRect((i*width/20), 0);
    rot2.posRect(((i+2)*width/20), 0);
    rot4.posRect((i*width/20), 2*rectCol);
    rot3.posRect(((i+2)*width/20), 2*rectCol);
    
    bt1.posRect((17*width/20)+batWid,(-batWid/2));
    bt2.posRect((17*width/20)+batWid,int(1.5*batWid));
    
    mpu.posRect(2*height/20,7*height/20);
    delay(300);
  }catch(Exception e){
    
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////This is the Draw Method()/////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void draw() {
try{
 background(102); 
 textSize(fontSize);
 if(initialization)
 {     
       textSize(30);
       fill(0);
       //textAlign(CENTER,CENTER);     
      text("Please select your port",width/2,100);
      textSize(15);
      ControlButtons[] x = new ControlButtons[Serial.list().length];
      for(int i=0;i<Serial.list().length;i++){        
        x[i] = new ControlButtons(Serial.list()[i]);
        x[i].drawShape(width/2,height/2+(50*i),100,20);           
      }
      for(int i=0;i<Serial.list().length;i++){        
        if(x[i].btnClicked()){
          println(x[i].name+":"+x[i].btnClicked());
          initialization  = !x[i].btnClicked();
          buttonClickVal = x[i].name;
          myPort = new Serial(this, buttonClickVal, 19200);
          myPort.bufferUntil('\n');
          delay(100);
          break;
        }         
      }          
 }
 else{
   if(firstContact)
   {
    textSize(fontSize);
    thrst.drawShape(rectSize, rectSize);
    //hld.drawShape(rectSize);
    lnd.drawShape(rectSize, rectSize);
    role_l.drawShape(rectSize, rectSize);
    role_r.drawShape(rectSize, rectSize);
    ptch_fwd.drawShape(rectSize, rectSize);
    ptch_bkd.drawShape(rectSize, rectSize);
    yaw_cw.drawShape(rectSize, rectSize);
    yaw_ccw.drawShape(rectSize, rectSize);
    reset.drawShape(rectSize,rectSize);
    rot0.setReadString("T"+rot0.getThrust()+":");
    rot1.setReadString(incommingString);
    rot2.setReadString(incommingString);
    rot3.setReadString(incommingString);
    rot4.setReadString(incommingString);  
    
    rot0.drawShape(rectSize, rectCol, rot0.out_thrstValue,rot0.name);
    rot1.drawShape(rectSize, rectCol, rot1.in_thrstValue,rot1.name);
    rot2.drawShape(rectSize, rectCol, rot2.in_thrstValue,rot2.name);
    rot3.drawShape(rectSize, rectCol, rot3.in_thrstValue,rot3.name);
    rot4.drawShape(rectSize, rectCol, rot4.in_thrstValue,rot4.name);
  
    bt1.setReadString(incommingString);
    bt2.setReadString(incommingString);
    bt1.drawBat(batLen,batWid,bt1.name);
    bt2.drawBat(batLen,batWid,bt2.name);
    
    fill(0);
    mpu.drawRect(mpuBox,mpuBox);
    mpu.setReadString(incommingString);
    mpu.dispReadString();
    
    if(keyPressed || mousePressed)
    {
      if(thrst.btnClicked())
      {
        rot0.setThrust(thrst_pow);
        movement(rot1,rot2,rot3,rot4,rot0.getThrust());
      }
      if(lnd.btnClicked())
      {
        rot0.setThrust(-thrst_pow);
        movement(rot1,rot2,rot3,rot4,rot0.getThrust());
      }
      if(ptch_fwd.btnClicked())
        movement(rot1,rot2);
      if(ptch_bkd.btnClicked())
        movement(rot3,rot4);
      if(role_r.btnClicked())
        movement(rot2,rot3);
      if(role_l.btnClicked())
        movement(rot1,rot4);
      if(yaw_cw.btnClicked())
        movement(rot1,rot3);
      if(yaw_ccw.btnClicked())
        movement(rot2,rot4);
      if(reset.btnClicked())
      {
        rot1.thrst_dir = 0;
        rot2.thrst_dir = 0;
        rot3.thrst_dir = 0;
        rot4.thrst_dir = 0;
      }
    }    
    else
      movement(rot1,rot2,rot3,rot4,rot0.getThrust());  
    outgoingString = renderOutputString();
   }
   else
   {
     initialization = false;     
     textSize(30);
     fill(255);
     //textAlign(CENTER,CENTER);     
     text("Establishing connection, please wait..\nCommunicating with "+buttonClickVal,width/2,100);     
     ControlButtons x = new ControlButtons("Ports");
     textSize(15);
     x.drawShape(width/2,height/2,100,30);     
     delay(50);
     if(x.btnClicked()){
       buttonClickVal = "";
       initialization = true;
     }
       
   }
 }
}catch(Exception e){
    
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////This is the SerialEvent Method///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void serialEvent( Serial myPort) {
//put the incoming data into a String - 
//the '\n' is our end delimiter indicating the end of a complete packet
val = myPort.readStringUntil('\n');
//make sure our data isn't empty before continuing
if (val != null) {
  //trim whitespace and formatting characters (like carriage return)
  val = trim(val);
  println(val);

  //look for our 'A' string to start the handshake
  //if it's there, clear the buffer, and send a request for data
  if (firstContact == false) {
    if (val.equals("A")) {
      myPort.clear();
      firstContact = true;
      myPort.write("A");
      println("contact");
      delay(200);
      val = "";
    }
  }
  else
  {
    myPort.write(outgoingString);
    //int index = val.indexOf('T');
    //String sub = "";
    //sub = val.substring(index);
    //text(sub,900,100);
    if(val.length() > 60)
    {
      for(int i=0;i<incommingString.length();i++)
      {
        if(incommingString.charAt(i)>'z')
        {
          incommingString = prev_val;
          break;
        }
        else
        {
          incommingString = val;
          prev_val = val;
        }
      }
    }
  }
 }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
void movement(Thrust t1, Thrust t2)
{
  int flank = rot0.getThrust()-power;
  t1.stThrst(flank);
  t2.stThrst(flank);
}
void movement(Thrust t1, Thrust t2,Thrust t3,Thrust t4,int th)
{
  t1.stThrst(th);
  t2.stThrst(th);
  t3.stThrst(th);
  t4.stThrst(th);
}
String renderOutputString()
{
  String outputString;
  outputString = rot1.getThrust()+":"+rot2.getThrust()+":"+rot3.getThrust()+":"+rot4.getThrust()+":;";
  return outputString;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////This is the Base Shape Class/////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Shape
{
  int pos_x, pos_y;
  int i, j;
  void posRect(int i, int j)
  {
    pos_x = (width/20)+i;
    pos_y = (height/20)+j;
  }
  void drawRect(int len, int br, int curve, int thrst_val, String name)
  {
    stroke(0);
    rect(pos_x, pos_y, len, br, curve);
    textAlign(CENTER, CENTER);
    fill(255);
    text(name, pos_x+(rectSize/2), pos_y-fontSize);
    text(thrst_val, pos_x+(rectSize/2), pos_y+rectCol+(rectSize/1.5));
  }
  void drawRect(int len, int br)
  {
    stroke(0);
    rect(pos_x, pos_y, len, br, 7);
  }
  void drawRect(int posx, int posy, int len, int br)
  {
    stroke(0);
    rect(posx, posy, len, br, 7);
  }
  void btnClick(int x_cord, int y_cord, int x_range,int y_range,Thrust t,int inr)
  {
    fill(0);
    if (mouseX >= x_cord && mouseX <= x_cord+x_range && mouseY >= y_cord && mouseY <= y_cord+y_range)
      fill(50);
    if ((mouseX >= x_cord && mouseX <= x_cord+x_range && mouseY >= y_cord && mouseY <= y_cord+y_range && mousePressed == true))
    {
      fill(100);
      t.setThrust(inr);
    }
  }
  boolean btnClick(int x_cord, int y_cord, int range,char dir)
  {
    boolean clicked = false;
    fill(0);
    if (mouseX >= x_cord && mouseX <= x_cord+range && mouseY >= y_cord && mouseY <= y_cord+range)
      fill(50);
    if ((mouseX >= x_cord && mouseX <= x_cord+range && mouseY >= y_cord && mouseY <= y_cord+range && mousePressed == true) || ( keyPressed == true && key == dir))
    {
      clicked = true;
      fill(100);
    }
    return clicked;
  }
  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void btnClick(String name, int x_cord, int y_cord, int range_x, int range_y)
  {
    //boolean clicked = false;    
      fill(0);
      if (mouseX >= x_cord && mouseX <= x_cord+range_x && mouseY >= y_cord && mouseY <= y_cord+range_y)
        fill(50);      
  }
  boolean mousePressed(String name, int x_cord, int y_cord, int range_x, int range_y){
    boolean clicked = false;
    if ((mouseX >= x_cord && mouseX <= x_cord+range_x && mouseY >= y_cord && mouseY <= y_cord+range_y && mousePressed))
      {      
        if(!name.equals(buttonClickVal)){
          initialization = false;
          clicked = true;        
          println(name+" is Selected");
        }
        fill(100);
        delay(10);
      }
    return clicked;
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////This is the Control Button Class/////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ControlButtons extends Shape
{
  int pos_x, pos_y;
  String name;
  char dir;
  int i, j, len, br;
  boolean clicked;
  ControlButtons(String name, char dir)  /////////Only Constructor of the ControlButton Class///////////
  {
    this.name = name;
    this.dir = dir;
  }
  ControlButtons(String name)  /////////Only Constructor of the ControlButton Class///////////
  {
    this.name = name;
  }
  char getDir(){return dir;}                                  ////////Returns the char assigned to the Button/////////////////  
  void drawShape(int len, int br)                //////////Draws the Button from the Base Class Shape////////////
  {   
    clicked = super.btnClick(super.pos_x,super.pos_y,rectSize,dir);     //////////Calls the btnClick() method of base class///////////// 
    super.drawRect(len, br);                            //////////Calls the drawRect() method of base class/////////////
    textAlign(CENTER, CENTER);
    fill(255);
    text(name, super.pos_x, super.pos_y-(rectSize/16), rectSize, rectSize);
  }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void drawShape(int posx, int posy, int len, int br)                //////////Draws the Button from the Base Class Shape////////////
  {   
    super.btnClick(name,posx,posy,len,br);     //////////Calls the btnClick() method of base class///////////// 
    clicked = super.mousePressed(name,posx,posy,len,br);
    super.drawRect(posx,posy,len, br);                            //////////Calls the drawRect() method of base class/////////////
    textAlign(CENTER, CENTER);
    fill(255);
    text(name, posx, posy, len, br);    
  }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  boolean btnClicked()
  {
    if(clicked)
      return true;
    else
      return false;
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////This is the Thrust Class////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
  All the out_thrstValue will be serialized 
  and appended to the outgoing string and will 
  be transmitted over.
  
  The incomming string will be deserialized
  and the data will be to an array of float
  in renderReadBuffer() method and the rotIndex
  will provide index of each rotor.
*/
class Thrust extends Shape
{
  int pos_x, pos_y;
  String name, readBuffer;
  int thrst_dir, thrst1, rotIndex, prev_index;   
  int in_thrstValue,prev_thrst;                 //////////in_thrstValue is the thrust value which is  received from the drone////////////
  int out_thrstValue;                //////////out_thrstValue is the thrust value which is to be sent to the drone////////////
  boolean clickp = false, clickm = false;
  
  Thrust(String name, int out_thrstValue,int rotIndex)
  {
    this.name = name;
    this.out_thrstValue = out_thrstValue;
    this.rotIndex = rotIndex;
  }
  String getReadString(){return readBuffer;}
  void setReadString(String readBuffer){this.readBuffer = readBuffer;}
  int getThrust(){return out_thrstValue;}
  void setThrust(int out_thrstValue)
  {
    if(this.out_thrstValue>=1000 && this.out_thrstValue<=2000)
      this.out_thrstValue += out_thrstValue/10;
    if(this.out_thrstValue>=2000)
      this.out_thrstValue = 2000;
    if(this.out_thrstValue<=1000)
      this.out_thrstValue = 1000;
  }
  void stThrst(int out_thrstValue)  
  {
    if(this.out_thrstValue>=1000 && this.out_thrstValue<=2000)
      this.out_thrstValue = out_thrstValue + thrst_dir;
    if(this.out_thrstValue>=2000)
      this.out_thrstValue = 2000;
    if(this.out_thrstValue<=1000)
      this.out_thrstValue = 1000;
  }
  void drawShape(int len, int br, int in_thrstValue,String name)
  {  
    fill(0);
    circle(super.pos_x+(rectSize/2), super.pos_y+rectCol+(rectSize/1.5), rectSize);  //Thrust display circle
    super.drawRect(len, br, 7, in_thrstValue, name);
    dispThrust(in_thrstValue);
    dispThrustControl();
    prev_thrst = out_thrstValue;
  }
  void dispThrust(int in_thrstValue)
  {
    fill(0,0,255);
    noStroke();
    float i;
    for(i=100; i<(in_thrstValue/5)-105;i+=5)
      rect(super.pos_x+2,super.pos_y+(1.5*rectCol)-i-7,.96*rectSize,(rectCol/20)-5.75,1);
    stroke(50);
  }
  void dispThrustControl()
  {
    textAlign(CENTER,CENTER);
    int inr_pow = 10;
    int[] rotValues = renderReadBuffer(readBuffer);
    in_thrstValue = rotValues[rotIndex];
    thrst1 = out_thrstValue;
    int inr_size = rectSize/3;
    int inr_x = super.pos_x+(rectSize)+inr_size/2;
    int inr_y = super.pos_y+rectCol+(rectSize/4);
    super.btnClick(inr_x,inr_y,inr_size,inr_size,this,inr_pow);
    rect(inr_x,inr_y , inr_size,inr_size);  //Thrust display circle
    fill(255);
    text("+",inr_x,inr_y,inr_size,inr_size-5);  //Thrust display circle
    super.btnClick(inr_x,int(inr_y+(1.25*inr_size)),inr_size,inr_size,this,-inr_pow);
    rect(inr_x, inr_y+1.25*inr_size, inr_size,inr_size);  //Thrust display circle
    fill(255);
    text("-",inr_x,inr_y+1.25*inr_size,inr_size,inr_size-5);  //Thrust display circle
    thrst_dir += out_thrstValue - thrst1;
  }
  int[] renderReadBuffer(String readBufferString)
  {
    String readString = "",bufferString= "";
    int index = readBufferString.indexOf('T');
    if(index<0)
      index = 0;
    readString = readBufferString.substring(index);
    index = readString.indexOf('T');
    int len = (readString.length()-1)/5;
    int[] rotValues = new int[len];
    for(int i=0;i<len;i++)
    {
      prev_index = index+1;
      index = readString.indexOf(':',prev_index);
      bufferString = readString.substring(prev_index,index);
      rotValues[i] = int(bufferString);
      if(rotValues[i]<1000)
        rotValues[i]=1000;
      //if(rotValues[i]!=thrst_val+thrst_dir || rotValues[i]!=thrst_val+thrst_dir-thrst_pow)
      // rotValues[i] = prev_thrst;
    }
    return rotValues;
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////This is the Battery Class///////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Battery extends Shape
{
  float volt,max;
  int pos_x, pos_y,batIndex,prev_index;
  String name,readBuffer;
  Battery(float volt,int pos_x,int pos_y,String name,float max,int batIndex)
  {
    this.volt = volt;
    this.pos_x = pos_x;
    this.pos_y = pos_y;
    this.name = name;
    this.max = max;
    this.batIndex = batIndex;
  }
  String getReadString(){return readBuffer;}
  void setReadString(String readBuffer){this.readBuffer = readBuffer;}
  void drawBat(int len, int br, String name)                //////////Draws the Button from the Base Class Shape////////////
  {    
    fill(0);
    super.drawRect(len, br);                                //////////Calls the drawRect() method of base class/////////////
    fill(255);
    textAlign(LEFT,CENTER);
    text(name, super.pos_x-1.75*batWid, super.pos_y,batWid*2,batWid);
    dispVolt();
  }
  void dispVolt()
  {
    float[] batValues = renderReadBuffer(readBuffer);
    volt = batValues[batIndex];
    fill(0);
    rect(super.pos_x, super.pos_y, batLen+1, batWid,3);
    fill(0,175,0);
    float j = 0.5;
    float per = (volt/max)*100;
    noStroke();
    for(float i = 0; i<per; i+=0.8)
      rect(super.pos_x+i+1, super.pos_y+1, 1, batWid-1,3);
    fill(255);
    textAlign(LEFT,BOTTOM);
    text("Volts="+volt+"v",super.pos_x,super.pos_y);
    textAlign(CENTER,CENTER);
    text(nf(per,0,1)+"%",super.pos_x,super.pos_y,batLen,batWid);
  }
  float[] renderReadBuffer(String readBufferString)
  {
    String readString = "";
    float[] batValues = new float[2];
    int index = readBufferString.indexOf('V');
    for(int i=0;i<batValues.length;i++)
    {
      prev_index = index+1;
      index = readBufferString.indexOf(':',index+1);
      readString = readBufferString.substring(prev_index,index);
      batValues[i] = float(readString);
      batValues[i] = float(nf(batValues[i],0,1));
    }
    return batValues;
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////This is the MPU Class///////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class MPU extends Shape
{
  int pos_x,pos_y;
  float X,Y,Z; 
  String readBuffer;
  MPU(){}
  void mpuSetX(float X){this.X = X;}
  void mpuSetY(float Y){this.Y = Y;}
  void mpuSetZ(float Z){this.Z = Z;}
  
  float mpuGetX(){return X;}
  float mpuGetY(){return Y;}
  float mpuGetZ(){return Z;}
  
  String getReadString(){return readBuffer;}
  void setReadString(String readBuffer){this.readBuffer = readBuffer;}
  void dispReadString()
  {
    fill(255);
    textAlign(CENTER,CENTER);
    text("MPU readings",super.pos_x,super.pos_y*0.5,mpuBox,mpuBox);
    float[] mpuVal = renderReadBuffer(readBuffer);
    for(int i =1; i<mpuVal.length+1;i++)
      text(str(mpuVal[i-1]),super.pos_x,super.pos_y+(i*30)-(mpuBox/4),mpuBox,mpuBox);
  }
  float[] renderReadBuffer(String readBufferString)
  {
    String readString;
    float[] mpuValues = new float[6];
    int index = -1,prev_index;
    for(int i = 0;i<mpuValues.length;i++)
    {
      prev_index = index+1;
      index = readBufferString.indexOf(':',index+1);
      readString = readBufferString.substring(prev_index,index);
      mpuValues[i] = float(readString);
    }
    return mpuValues;
  }
  float[] setGyro(float[] mpu)
  {
    float[] gyroValues = new float[3];
    for(int i=0;i<mpu.length;i++)
      if(i<3) gyroValues[i] = mpu[i];
    return gyroValues;
  }
  float[] setAccel(float[] mpu)
  {
    float[] accelValues = new float[3];
    for(int i=0;i<mpu.length;i++)
      if(i>2) accelValues[i+3] = mpu[i];
    return accelValues;
  } 
}
class Gyroscope extends MPU
{
  float rX, rY, rZ;
  Gyroscope(float rX,float rY,float rZ)
  {
    this.rX = rX;
    this.rY = rY;
    this.rZ = rZ;
  }
  
}
class Accelerometer extends MPU
{
  float gFX, gFY, gFZ;
  Accelerometer(float gFX,float gFY,float gFZ)
  {
    this.gFX = gFX;
    this.gFY = gFY;
    this.gFZ = gFZ;
  }
}
