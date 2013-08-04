/**
 * intをbyte配列に変換
 * @param input 10進数
 * @param length 何バイトで整形するか
 * @return byte配列
 */
byte[] int2byteArray(int input, int length) {
  String hex = Integer.toHexString(input);
  int hexLength = hex.length();
  for(int i = 0; i < length*2-hexLength; i++) {
    hex = "0"+hex;
  }
  byte[] ret = new byte[length]; 
  for(int i = 0; i < length; i++) {
    ret[length-1-i] = (byte) Integer.parseInt( hex.substring(i*2,(i+1)*2), 16);
  }
  return ret;
}

/**
 * byte配列をbit配列に変換
 * @param bytes byte配列
 * @return bit配列(boolean)
 */
boolean[] byteArray2BitArray(byte[] bytes) {
  boolean[] bits = new boolean[bytes.length*8];
  for (int i = 0; i < bytes.length*8; i++) {
    if ((bytes[i/8] & (1 << (7 - (i%8)))) > 0)
    bits[i] = true;
  }
  return bits;
}

/**
 * bit配列をbyte配列に変換
 * @param bits bit配列(boolean)
 * @return byte配列
 */
byte[] bitArray2ByteArray(boolean[] bits) {
  int length = bits.length/8 + (bits.length%8==0?0:1);
  byte[] bytes = new byte[length];
  for (int i = 0; i < bits.length; i++) {
    if(bits[i]) bytes[i/8] |= (1 << (7 - (i%8)));
    else bytes[i/8] &= ~(1 << (7 - (i%8)));
  }
  return bytes;
}

/**
 * ファイル名から拡張子を返す
 * @param fileName ファイル名
 * @return 拡張子
 */
String getSuffix(String fileName) {
  if (fileName == null)
    return null;
  int point = fileName.lastIndexOf(".");
  if (point != -1) {
    return fileName.substring(point + 1);
  }
  return fileName;
}

/**
 * ファイル名から拡張子を取り除いた名前を返す
 * @param fileName ファイル名
 * @return 名前
 */
String getPreffix(String fileName) {
  if (fileName == null)
    return null;
  int point = fileName.lastIndexOf(".");
  if (point != -1) {
    return fileName.substring(0, point);
  } 
  return fileName;
}
