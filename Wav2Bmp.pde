import java.io.*;
import controlP5.*;
import sojamo.drop.*;

// 白黒2階調bmpのヘッダ
final String HEADER_BMP = "424D40020000000000003E000000280000004000000040000000010001000000000002020000120B0000120B00000000000000000000FFFFFF0000000000";

ControlP5 cp5;
SDrop drop;
String outPath;
byte[] outHeader;
int outWidth = 64;
String description  = "";
String message  = "";
int processCount = 0;

void setup() {
  size(500, 500);
  noSmooth();
  stroke(100);
  // 出力先ディレクトリを作成
  outPath = sketchPath("out");
  File dir = new File(outPath);
  if (!dir.exists()) {
    if (dir.mkdir()){
      println("ディレクトリ("+outPath+")の作成に成功しました");
    }
  }
  description = "[Export Directory]\n\""+outPath+"/\"";
  
  // 出力するｂｍｐのヘッダ
  ByteArrayOutputStream baos = new ByteArrayOutputStream();
  for(int i = 0; i < HEADER_BMP.length(); i += 2){
    int b = Integer.parseInt(HEADER_BMP.substring(i, i + 2), 16);
    baos.write(b);
  }
  outHeader = baos.toByteArray();
  
  // ファイルドロップ用のインスタンス
  drop = new SDrop(this);
  
  // 幅入力用コントロール
  cp5 = new ControlP5(this);
  cp5.addNumberbox("out_width")
     .setPosition(30,100)
     .setSize(100,14)
     .setRange(16,320)
     .setDirection(Controller.HORIZONTAL)
     .setValue(64)
     ;
}

void draw() {
  background(0);
  
  noFill();
  rect(10, 10, width-20, height-20);
  line(10, 80, width-10, 80);
  line(10, 140, width-10, 140);
  fill(255);
  textAlign(CENTER, TOP);
  textSize(18);
  text("Drag & Drop wav files into this window.\nSet width with \"OUT_WIDTH\" slider.", width/2, 20);
  textAlign(LEFT);
  textSize(10);
  text(description, 30, 170);
  text(message, 30, 220);
  text("px", 135, 110);
}

void out_width(int num) {
  outWidth = num;
}

void dropEvent(DropEvent theDropEvent) {
  File file = theDropEvent.file();
  if(file.isDirectory()){
    String[] fileArray = file.list();
    if (fileArray != null) {
      for(int i = 0; i < fileArray.length; i++) {
        String absolutePath = file.getAbsolutePath()+"/"+fileArray[i];
        String fileName = fileArray[i];
        saveWavAsBmp(absolutePath,fileName);
      }
    }
  }else{
    String absolutePath = file.getAbsolutePath();
    String fileName = file.getName();
    saveWavAsBmp(absolutePath,fileName);
  }
  
}

void saveWavAsBmp(String absolutePath, String fileName) {
  String name = getPreffix(fileName);
  String ext = getSuffix(fileName);
  // wavなら変換
  if(ext.equals("wav")) {
    byte wavBytes[] = loadBytes(absolutePath); 
    
    // wavヘッダ(先頭40バイト)を削除して波形データのみの配列を作成
    byte[] originalBytes = new byte[wavBytes.length-40];
    for(int j = 0; j < wavBytes.length-40; j++) originalBytes[j] = wavBytes[j+40];
    // bit配列に変換
    boolean[] originalBits = byteArray2BitArray(originalBytes);
    
    // 幅にあわせて高さを計算
    int outHeight = originalBits.length/outWidth;
    if(originalBits.length%outWidth != 0) outHeight++;
    // bmpヘッダの幅と高さを上書き
    byte[] byteWidth = int2byteArray(outWidth,4);
    byte[] byteHeight = int2byteArray(outHeight,4);
    for(int j = 0; j < 4; j++) outHeader[18+j] = byteWidth[j];
    for(int j = 0; j < 4; j++) outHeader[22+j] = byteHeight[j];
    
    // bmpは4バイト単位でデータを持つため、行あたりのバイト数を合わせて端数を0で埋める
    boolean[] outBits = new boolean[(outWidth + (outWidth%32 == 0 ? 0 : 32-outWidth%32) )*outHeight];
    int offset = 0;
    for(int i = 0; i < originalBits.length; i++) {
      outBits[i+offset] = originalBits[i];
      if(i%outWidth == outWidth-1) {
        offset+= outWidth%32 == 0 ? 0 : 32-outWidth%32;
      }
    }
    // byte配列に変換
    byte[] outBytes = bitArray2ByteArray(outBits);

    // 出力データを作成
    byte[] saveBytes = new byte[outHeader.length+outBytes.length+2];
    for(int j = 0; j < saveBytes.length; j++) {
      if(j < outHeader.length) saveBytes[j] = outHeader[j];
      else if(j < outHeader.length+outBytes.length) {
        saveBytes[j] = outBytes[j-outHeader.length];
      }
    }
    
    // bmp出力
    saveBytes(outPath+"/"+name+".bmp", saveBytes);
    processCount++;
    message += processCount+":[OK] "+fileName+" -> "+name+".bmp\n";
  }else{
    // wav以外
    processCount++;
    message += processCount+":[NG] "+fileName+"\n";
  }
  
  String[] msgs = message.split("\n");
  if(msgs.length > 16) {
    int index = message.indexOf("\n", 0);
    message = message.substring(index+1, message.length());
  }
}

