import processing.opengl.*;

int dimw =3100 ;//1280*2+50;
int dimh =780;
int num = 200; //64

int time = 0;

boolean clear = true;
boolean input = true;

Friend[] friends;

int maxpal = 1024;//512
int numpal = 200;
color[] goodcolor = new color[maxpal];

void setup() {
  size(dimw,dimh,P3D);//P3D
  takecolor("longStickhorse.gif");
  background(0);
  frameRate(60);
  
  friends = new Friend[num];
  resetAll();
   
  
   //midicontrol
   midiIO = MidiIO.getInstance(this);
   //midiIO.plug(this,"noteOn",0,0);
   //midiIO.plug(this,"noteOff",0,0);
   midiIO.plug(this,"controllerIn",0,0);
   //midiIO.plug(this,"programChange",0,0);
   
/*   //soundinput
   
   Sonia.start(this);
     LiveInput.start(spectrumLength);
//  LiveInput.useEnvelope(true,1f);
  LiveInput.useEqualizer(true);  
  
   ffthelper=new SoniaHelper(spectrumLength,32,false);
  ffthelper.setMaxLimits(200,2000);
  damperval=0.1f;
  ffthelper.setDamper(damperval);  
  
  pt=new float[spectrumLength*2];
  for(int i=0; i<spectrumLength; i++) {
    pt[i*2]=random(width-50)+25;
    pt[i*2+1]=random(height-50)+25;
  }
  
  bandsteps=spectrumLength/ffthelper.band.length;
  maxdist=ffthelper.maxMaximum-ffthelper.maxMinimum;
  
  */
}

void draw() {
  
   drawState();
   num=numNode;
   
   //translate(mx+rad,my+rad);
    if (!input){
   doSoundInput();
   }
   
   /*
   for(int i=0; i<spectrumLength; i++) {
     fill(255,0,128, 255*ffthelper.spectrum[i]); 
     rad=2+20*(ffthelper.spectrum[i]*ffthelper.spectrum[i]);   
     //ellipse(pt[i*2],pt[i*2+1], rad,rad);  
      translate(mx,my+rad);
    // friends[i].move();
    //   println("ff "+ ffthelper.spectrum[i]);  
  }
    */


      //println("damperval "+damperval);  

   
  // move friends to happy places
  
    //num = int(random(100)); //64
   

  for (int c=0;c<num;c++) {
    friends[c].move();
  }
  
  for (int c=0;c<num;c++) {
    friends[c].expose();
    friends[c].exposeConnections();
  }
  if (time%2==0) for (int c=0;c<num;c++) {
    friends[c].findHappyPlace();
  }
  time++;
}

void drawState(){
  if (clear){
     background(0);
  } else {
  }
}

void keyReleased () {
  if (key == ' ' ) {
    clear = !clear;
  }else if(key =='i'){
    input = !input;
  }
}

void mousePressed () {
  resetAll();
  //num = int(random(100)); //64
 // background(0);
}


void resetAll() {
  // make some friend entities
  for (int x=0;x<num;x++) {
    float fx = dimw/2 + random(1.5)*dimw*cos(TWO_PI*x/num);//    float fx = dim/2 + 0.4*dim*cos(TWO_PI*x/num);
    float fy = dimh/2 + random(0.4)*dimh*sin(TWO_PI*x/num);
    friends[x] = new Friend(fx,fy,x);
  }

  // make some random friend connections
  for (int k=0;k<num*2.2;k++) {
    int a = int(floor(random(num)));
    int b = int(floor(a+random(22))%num);
    if (b>=num) {
      b=0;
      print("+");
    } else if (b<0) {
      b=0;
      print("+");
    }
    if (a!=b) {
      friends[a].connectTo(b);
      friends[b].connectTo(a);
      //      println(a+" made friends with "+b);
    }
  }

}



// OBJECTS ---------------------------------------------------------------

class Friend {
  float x, y;
  float dx, dy;
  float vx, vy;
  int id;

  int numcon;
  int maxcon = 10;
  int lencon = 10+int(random(50));
  int[] connections = new int[maxcon];

  // sand painters
  int numsands = 3;
  SandPainter[] sands = new SandPainter[numsands];

  color myc = somecolor();

  Friend(float X, float Y ,int Id) {
    // position
    dx = x = X;
    dy = y = Y;
    id = Id;
    
    numcon = 0;

    for (int n=0;n<numsands;n++) {
      sands[n] = new SandPainter();
    }
  }

  void expose() {
    for (int dx=-2;dx<3;dx++) {
      float a = 0.5-abs(dx)/5.0;
      stroke(0,256*a);
      point(x+dx,y);
      stroke(255,256*a);
      point(x+dx-1,y-1);
    }
    for (int dy=-2;dy<3;dy++) {
      float a = 0.5-abs(dy)/5.0;
      stroke(0,256*a);
      point(x,y+dy);
      stroke(255,256*a);
      point(x-1,y+dy-1);
    }
  }

  void exposeConnections() {
    // draw connection lines to all friends
    for (int n=0;n<numcon;n++) {
      // find axis distances
      float ox = friends[connections[n]].x;
      float oy = friends[connections[n]].y;

      for (int s=0;s<numsands;s++) {
        sands[s].render(x,y,ox,oy);
      }
    }
  }

  void render() {
    for(int xx=int(x-numcon);xx<int(x+numcon);xx++) {
      for(int yy=int(y-numcon);yy<int(y+numcon);yy++) {
        stroke(myc);
        point(xx,yy);
      }
    }
  }
  
  void renderConnections() {
    for (int n=0;n<numcon;n++) {
      float ddx = friends[connections[n]].x-x;
      float ddy = friends[connections[n]].y-y;
      int m = int(1 + sqrt(ddx*ddx+ddy*ddy)/6);
      for (int k=0;k<m;k++) {
        float t = (1 + cos(k*PI/m))/2;
        int px = int(x + t*ddx);
        int py = int(y + t*ddy);
        stroke(#333333);
        point(px,py);
      }
    }  
  }


  void move() {
    // add velocity to position
    x+=vx;
    y+=vy;
    
    //friction
    vx*=1.5*vxNode;//0.92
    vy*=1.5*vyNode;
    
   // println("x="+x+" y="+y);
  }

  void connectTo(int f) {
    // connect to friend f

    // is there room for more friends?
    if (numcon<maxcon) {
      // already connected to friend?
      if (!friendOf(f)) {
        connections[numcon] = f;
        numcon++;
      }
    }
  }

  boolean friendOf(int x) {
    boolean isFriend = false;
    for (int n=0;n<numcon;n++) {
      if (connections[n]==x) isFriend=true;
    }
    return isFriend;
  }

  void findHappyPlace() {
    // set destination to a happier place
    // (closer to friends, further from others)
    float ax = 0.0;
    float ay = 0.0;

    // find mean average of all friends and non-friends
    for (int n=0;n<num;n++) {
      if (friends[n]!=this) {
        // find distance
        float ddx = friends[n].x-x;
        float ddy = friends[n].y-y;
        float d = sqrt(ddx*ddx + ddy*ddy);
        float t = atan2(ddy,ddx);

        boolean friend = false;
        for (int j=0;j<numcon;j++) if (connections[j]==n) friend=true;
        if (friend) {
          // attract
          if (d>lencon) {
            ax += 4.0*cos(t);
            ay += 4.0*sin(t);
          }
        } else {
          // repulse
          if (d<lencon) {
            ax += (lencon-d)*cos(t+PI);
            ay += (lencon-d)*sin(t+PI);
          }
        }
      }
    }

    vx+=ax/42.22;//42.22
    vy+=ay/42.22;
    //println("x="+vx+" y="+vy);
  }
}

class SandPainter {

  float p;
  color c;
  float g;

  SandPainter() {

    p = random(1.0);
    c = somecolor();
    g = random(0.01,0.1);
  }

  void render(float x, float y, float ox, float oy) {
    // draw painting sweeps
    stroke(red(c),green(c),blue(c),28);
    point(ox+(x-ox)*sin(p),oy+(y-oy)*sin(p));

    g+=random(-0.050,0.050);
    float maxg = 1.00*maxgNode;//0.22
    if (g<-maxg) g=-maxg;
    if (g>maxg) g=maxg;

    float w = g/10.0;
    for (int i=0;i<11;i++) {
      float a = 0.1-i/110;
      stroke(red(c),green(c),blue(c),256*a);
      point(ox+(x-ox)*sin(p+sin(i*w)),oy+(y-oy)*sin(p + sin(i*w)));
      point(ox+(x-ox)*sin(p-sin(i*w)),oy+(y-oy)*sin(p - sin(i*w)));
    }
  }
}

// color routines ----------------------------------------------------------------

color somecolor() {
  // pick some random good color
  return goodcolor[int(random(numpal))];
}

void takecolor(String fn) {
  PImage b;
  b = loadImage(fn);
  image(b,0,0);

  for (int x=0;x<b.width;x++){
    for (int y=0;y<b.height;y++) {
      color c = get(x,y);
      boolean exists = false;
      for (int n=0;n<numpal;n++) {
        if (c==goodcolor[n]) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        // add color to pal
        if (numpal<maxpal) {
          goodcolor[numpal] = c;
          numpal++;
        }
      }
    }
  }
  // pump black and white in
  for (int x=0;x<22;x++) {
    goodcolor[numpal]=color(#000000);
    numpal++;
    goodcolor[numpal]=color(#FFFFFF);
    numpal++;
  }
}

// j.tarbell  March, 2004
// Albuquerque, New Mexico
// complexification.net

