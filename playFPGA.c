// FPGA pins D00 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13
// RPi pins:   2   3   4  17  27  22  10   9  11   5   6  13  19  26
#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <unistd.h>

#define D0 2
#define D1 4
#define D2 3
#define D3 17
#define D4 27
#define D5 22
#define D6 10
#define D7 9

/*
#define D7 2
#define D6 3
#define D5 4
#define D4 17
#define D3 27
#define D2 22
#define D1 10
#define D0 9
*/

#define A0 11
#define CLK 26

void setdata(unsigned char data) {
  digitalWrite(D0, data & 1); data >>= 1;
  digitalWrite(D1, data & 1); data >>= 1;
  digitalWrite(D2, data & 1); data >>= 1;
  digitalWrite(D3, data & 1); data >>= 1;
  digitalWrite(D4, data & 1); data >>= 1;
  digitalWrite(D5, data & 1); data >>= 1;
  digitalWrite(D6, data & 1); data >>= 1;
  digitalWrite(D7, data & 1);
}

void setinput() {
  pinMode(D0, INPUT);
  pinMode(D1, INPUT);
  pinMode(D2, INPUT);
  pinMode(D3, INPUT);
  pinMode(D4, INPUT);
  pinMode(D5, INPUT);
  pinMode(D6, INPUT);
  pinMode(D7, INPUT);
}

void setoutput() {
  pinMode(D0, OUTPUT);
  pinMode(D1, OUTPUT);
  pinMode(D2, OUTPUT);
  pinMode(D3, OUTPUT);
  pinMode(D4, OUTPUT);
  pinMode(D5, OUTPUT);
  pinMode(D6, OUTPUT);
  pinMode(D7, OUTPUT);
}

void wr_adlib(unsigned char reg, unsigned char value) {
  setdata(reg);
  digitalWrite(A0, 0);
  digitalWrite(CLK, 0);
  digitalWrite(CLK, 1);
  setdata(value);
  digitalWrite(A0, 1);
  digitalWrite(CLK, 0);
  digitalWrite(CLK, 1);
}

int main() {
  unsigned char buffer[57306];
  int song_register, song_data, song_offset = 0, song_wait;
  FILE *f;
  int i;

  f = fopen("le.adl", "rb");
  fread(buffer, 1, 57306, f);
  fclose(f);

  wiringPiSetupGpio();
  setoutput();
  pinMode(A0, OUTPUT);
  pinMode(CLK, OUTPUT);

  for(i=0; i<256; i++)
    wr_adlib(i, 0);

  for(;;)
  {
    song_register = buffer[song_offset];
    song_offset++;
    if(song_register==0)
    {
      song_wait  = (buffer[song_offset+1] << 8) | buffer[song_offset+0];
      song_offset += 2;
      usleep(1786*song_wait);
    }
    else
    {
      song_data = buffer[song_offset]; song_offset++;
      song_wait = buffer[song_offset]; song_offset++;
      wr_adlib(song_register, song_data);
      usleep(1786*song_wait);
    }
    if(song_offset>57300)
    {
      for(i=0; i<256; i++)
        wr_adlib(i, 0);
      exit(0);
    }
  }

  return 0;
}
