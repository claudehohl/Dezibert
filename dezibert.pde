#include <Servo.h> 
#include <SPI.h>
#include <Ethernet.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1,64 };
byte subnet[] = { 255,255,255,0 };
byte gateway[] = { 192,168,1,1 };
byte server[] = { 192,168,1,3 };

Client client(server, 80);



// hardware
int mic = 0;
int servo_port = 9;

//setup
int treshold = 2; //5: ich und thommy allein im raum; laptopsound schlägt an, komplette stille senkt den finger. 8: lärmige Cs
int reduce_every_steps = 5;
int finger_angle = 90;

//internals
Servo myservo;
int noise_level = analogRead(mic);
int penalty_level = 0;
int analog_value = 0;
int silent_steps = 0;
int finger_pos = 0;
int finger_moving = 0;



void setup() {
  Serial.begin(9600);
  Ethernet.begin(mac, ip, gateway, subnet);
  myservo.attach(servo_port);
  myservo.write(0);
  
  //matrix
  for(int i = 22; i <= 49; i += 1){
    pinMode(i, OUTPUT);
  }
  
  finger_up();
  finger_down();
  
}



void loop() {
  
  //matrix
  
  /*
  for(int i = 0; i <= 8; i += 1){
    matrix_level(i);
    delay(100);
  }
  
  for(int i = 8; i >= 0; i -= 1){
    matrix_level(i);
    delay(100);
  }
  */
  
  analog_value = analogRead(mic);
  //l(analog_value);
  
  int diff = noise_level - analog_value;
  diff = abs(diff);
  //l(diff);
  
  //read taster
  int taster = digitalRead(13);
  if(taster){
    diff = 100;
  } 
  
  //decibel value on LED-matrix
  int matrix_scale = scale(penalty_level, 20, 8);
  matrix_level(matrix_scale);
  
  if(silent_steps == reduce_every_steps){
    penalty_decrease();
    silent_steps = 0;
  }
  
  if(diff > treshold){
    penalty_increase();
  }
  
  noise_level = analog_value;
  silent_steps++;
  delay(100);
  
}



//penalty management
void penalty_increase(){
  if(penalty_level < 23){
    penalty_level++;
    penalty_handler();
  }
}

void penalty_decrease(){
  if(penalty_level > 0){
    penalty_level--;
    penalty_handler();
  }
}



void penalty_handler(){
    l(penalty_level);
    if(penalty_level >= 0 && penalty_level < 9){
      finger_down();
    }
    if(penalty_level >= 21 && penalty_level < 23){
      finger_up();
    }
    if(penalty_level >= 23){
      tweet();
    }
}



//finger control
void finger_up(){
  if(!finger_moving && finger_pos == 0){
    finger_moving = 1;
    //move finger up
    for(int pos = 0; pos <= finger_angle; pos += 1){
      myservo.write(pos);
      delay(10);
    }
    finger_moving = 0;
    finger_pos = 1;
  }
}

void finger_down(){
  if(!finger_moving && finger_pos == 1){
    finger_moving = 1;
    //move finger down
    for(int pos = finger_angle; pos >= 1; pos -= 1){
      myservo.write(pos);
      delay(20);
    }
    finger_moving = 0;
    finger_pos = 0;
  }
}



//matrix control
void set_rows(int r0, int r1, int r2, int r3, int r4, int r5, int r6, int r7){
  
  if(r0){
    digitalWrite(32, LOW);
  }else{
    digitalWrite(32, HIGH);
  }
  
  if(r1){
    digitalWrite(33, LOW);
  }else{
    digitalWrite(33, HIGH);
  }
  
  if(r2){
    digitalWrite(34, LOW);
  }else{
    digitalWrite(34, HIGH);
  }
  
  if(r3){
    digitalWrite(35, LOW);
  }else{
    digitalWrite(35, HIGH);
  }
  
  if(r4){
    digitalWrite(36, LOW);
  }else{
    digitalWrite(36, HIGH);
  }
  
  if(r5){
    digitalWrite(37, LOW);
  }else{
    digitalWrite(37, HIGH);
  }
  
  if(r6){
    digitalWrite(38, LOW);
  }else{
    digitalWrite(38, HIGH);
  }
  
  if(r7){
    digitalWrite(39, LOW);
  }else{
    digitalWrite(39, HIGH);
  }
  
}



void matrix_level(int level){
  
  //set colors
  if(level > 0 && level <= 3){
    //green
    for(int i = 22; i <= 29; i += 1){
      digitalWrite(i, LOW);
    }
    for(int i = 40; i <= 49; i += 1){
      digitalWrite(i, HIGH);
    }
  }else
  if(level > 3 && level <= 6){
    //orange
    for(int i = 22; i <= 29; i += 1){
      digitalWrite(i, HIGH);
    }
    for(int i = 40; i <= 49; i += 1){
      digitalWrite(i, HIGH);
    }
  }else
  if(level > 6 && level <= 8){
    //red
    for(int i = 22; i <= 29; i += 1){
      digitalWrite(i, HIGH);
    }
    for(int i = 40; i <= 49; i += 1){
      digitalWrite(i, LOW);
    }
  }
  
  if(level == 0){
    set_rows(0, 0, 0, 0, 0, 0, 0, 0);
  }else
  if(level == 1){
    set_rows(1, 0, 0, 0, 0, 0, 0, 0);
  }else
  if(level == 2){
    set_rows(1, 1, 0, 0, 0, 0, 0, 0);
  }
  if(level == 3){
    set_rows(1, 1, 1, 0, 0, 0, 0, 0);
  }else
  if(level == 4){
    set_rows(1, 1, 1, 1, 0, 0, 0, 0);
  }else
  if(level == 5){
    set_rows(1, 1, 1, 1, 1, 0, 0, 0);
  }else
  if(level == 6){
    set_rows(1, 1, 1, 1, 1, 1, 0, 0);
  }else
  if(level == 7){
    set_rows(1, 1, 1, 1, 1, 1, 1, 0);
  }else
  if(level == 8){
    set_rows(1, 1, 1, 1, 1, 1, 1, 1);
  }
}



void tweet(){

  //twitter: dezibert/zY44.UMM.
  
  if(!client.connected()){
    client.connect();
  }
  
  // Make a HTTP request:
  client.println("GET: /tweet.php/?my=pass HTTP/1.0");
  client.println("Host: my.host.com");
  client.println();
  
  //disconnect
  client.stop();
  
}



int scale(float val, int in_max, int iwant_max){
  float res = (val / in_max * iwant_max);
  res = int(res);
  return res;
}



//log
void l(int i){
  Serial.println(i);
}
