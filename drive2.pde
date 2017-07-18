import controlP5.*;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;
import hypermedia.net.*;

Slider slider_accelerator;
Slider slider_break;
Slider slider_wheel;
Toggle toggle_gear;
int accelerator;
int decelerator;
int wheel = 50;
int shiftgear = 1;  //(temp)-1:back,0:parking,1:drive,2-3:faster

int prev_accelerator;
int prev_decelerator;
int prev_wheel = 50;
int prev_shiftgear = 1;

UDP udp;

void setup() {
  size(500, 500); 
  udp=new UDP(this,5700);
  udp.listen(true);
  //TCP Connection
  connect();
  
  //Setting GUI
  slider_accelerator = new ControlP5(this).addSlider("accelerator");
  slider_accelerator
    .setRange(0, 100)//0~100の間
    .setValue(0)//初期値
    .setPosition(50, 40)//位置
    .setSize(200, 20);//大きさ

  slider_break = new ControlP5(this).addSlider("decelerator");
  slider_break
    .setRange(0, 100)//0~100の間
    .setValue(0)//初期値
    .setPosition(50, 80)//位置
    .setSize(200, 20);//大きさ

  slider_wheel = new ControlP5(this).addSlider("wheel");
  slider_wheel
    .setRange(0, 100)//0~100の間
    .setValue(50)//初期値
    .setPosition(50, 120)//位置
    .setSize(200, 20);//大きさ

  // create a toggle and change the default look to a (on/off) switch look
  toggle_gear = new ControlP5(this).addToggle("shiftgear");
  toggle_gear
     .setMode(ControlP5.SWITCH)
     .setValue(true)
     .setPosition(50,200)
     .setSize(100,50)
     ;
     
  //start game
  Button btn_start = new ControlP5(this).addButton("start");
  btn_start
     .setPosition(200,200)
     .setSize(50,50)
     ;   
  
  background(0);
}

DataOutputStream out;

void connect(){
    String ip = "localhost";

    int port = 5800;
    //int port = 50000;

    Socket sock = new Socket();
    
    try {
      sock.connect(new InetSocketAddress(ip, port));
      out = new DataOutputStream(sock.getOutputStream());
    } catch (IOException e) {
      e.printStackTrace();
    }

/*
    try {
      sock.connect(new InetSocketAddress(ip, port));
      out = new DataOutputStream(sock.getOutputStream());


    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      try {
        sock.close();
      } catch (IOException e) {
        e.printStackTrace();
      }

      try {
        out.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
    */
  }
void send(String string){
  try{
      byte[] w = string.getBytes("UTF-8");
      out.write(w);
      out.flush();
      
      print(string);
      //println(w);
  }
  catch (IOException e) {
      e.printStackTrace();
  } 
}

void shiftgear(boolean theFlag){
  if(theFlag) {
    shiftgear = 1;
  } else {
    shiftgear = -1;
  }
  //println("a toggle event.: " + theFlag);
}

public void start(int theValue){
  init();
  //send("start "+theValue+"\n");
  send("start\n");
}

void init(){
  slider_accelerator.setValue(0);
  slider_break.setValue(0);
  slider_wheel.setValue(50);
  toggle_gear.setValue(true);
}

void draw() {
  if (prev_accelerator != accelerator){
    prev_accelerator = accelerator;
    send("accelerator "+accelerator+"\n");
  }
  if (prev_decelerator != decelerator){
    prev_decelerator = decelerator;
    send("decelerator "+decelerator+"\n");
  }
  if (prev_wheel != wheel){
    prev_wheel = wheel;
    send("wheel "+wheel+"\n");
  }
  if (prev_shiftgear != shiftgear){
    prev_shiftgear = shiftgear;
    send("shiftgear "+shiftgear+"\n");
  }
  
  if (wheel > 45 && wheel < 55){
    slider_wheel.setValue(50);
  }
}

void receive(byte[] data,String ip,int port){
  for(int i=0;i<data.length;i++){
    if (data[i]==-1) return;
    if (data[i]==101){
      send("start\n");
      return;
    }else if (data[i]==102){
      send("shiftgear 1\n");
      return;
    }else if (data[i]==103){
      send("shiftgear -1\n");
      return;
    }else if (data[i]==104){
      send("accelerator "+data[i+1]+"\n");
      return;
    }else if (data[i]==105){
      send("decelerator "+data[i+1]+"\n");
      return;
    }else if (data[i]==106){
      send("wheel "+data[i+1]+"\n");
      return;
    }
  }
}