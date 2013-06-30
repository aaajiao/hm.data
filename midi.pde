import promidi.*;

int numNode =200;
float maxgNode;
float vxNode,vyNode;
float mx,my;


MidiIO midiIO;

void controllerIn(Controller controller){
  int num = controller.getNumber();
  float val = controller.getValue();
  

  if(num == 24){
    my=val/127*5f;
  }
  if(num == 27){
    my=-val/127*5f;
  }
/*
  if(num == 34){
    yTrans =val*30;
  }*/
  
 if(num == 31){
   numNode = floor(val/127*200);
   println("num = " +numNode);

  }

  if(num == 35){
   vxNode =val/127f;
   println("vxNode = " +vxNode);

  }
  if(num == 32){
   vyNode =val/127f;
   println("vyNode = " +vyNode);

  }
  if(num == 36){
  maxgNode =1-val/127;
   println("maxgNode = " +maxgNode);
  }
  if(num == 33){
 // girthm= val;
  } 
}

