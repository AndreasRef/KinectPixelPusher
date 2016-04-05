
void pushSide(int strip, int side, color c) {
  if (strip < stripNumbers && side < sidesPerStrip) {//Attempt to avoid ArrayIndexOutOfBoundsExceptions
    for (int i = 0; i<strips.size(); i++) {
      for (int stripx = side*pixelsPerSide; stripx < (side+1)*pixelsPerSide; stripx++) {
        strips.get(strip).setPixel(c, stripx);
      }
    }
  }
}

void fadeSide(int strip, int side, color c, boolean inOut, int fadeSpeed, int threshold) {
  pushStyle();
  colorMode(HSB, 360);
  for (int i = 0; i<strips.size(); i++) {
    for (int stripx = side*pixelsPerSide; stripx < (side+1)*pixelsPerSide; stripx++) {
      if (inOut == true) {
        brightness[stripx]+=fadeSpeed;
        if (brightness[stripx] >= 360) brightness[stripx] = 360;
      } else if (inOut ==false) {
        brightness[stripx]-=fadeSpeed;
        if (brightness[stripx] <= threshold) brightness[stripx] = threshold;
      }
      strips.get(strip).setPixel(color(hue(c), 360, brightness[stripx]), stripx);
    }
  }
  popStyle();
}

void fadePixel(int pixel, color c, boolean inOut, int fadeSpeed, int threshold) { 
  int strip = floor(pixel/(pixelsPerStrip));
  int pixelNum = pixel % (pixelsPerStrip);

  if (inOut == true) {
    brightness[pixel]+=fadeSpeed;
    if (brightness[pixel] >= 360) brightness[pixel] = 360;
  } else if (inOut ==false) {
    brightness[pixel]-=fadeSpeed;
    if (brightness[pixel] <= threshold) brightness[pixel] = threshold;
  }
    strips.get(strip).setPixel(color(hue(c), 360, brightness[pixel]), pixelNum);
}