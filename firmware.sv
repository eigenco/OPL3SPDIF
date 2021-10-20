//`default_nettype none
module firmware (
      input              CLOCK2_50,
      input              CLOCK3_50,
      inout              CLOCK4_50,
      input              CLOCK_50,

      output      [12:0] DRAM_ADDR,
      output      [1:0]  DRAM_BA,
      output             DRAM_CAS_N,
      output             DRAM_CKE,
      output             DRAM_CLK,
      output             DRAM_CS_N,
      inout       [15:0] DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_RAS_N,
      output             DRAM_UDQM,
      output             DRAM_WE_N,

      inout       [35:0] GPIO_0,
      inout       [35:0] GPIO_1,

      output reg  [6:0]  HEX0,
      output reg  [6:0]  HEX1,
      output reg  [6:0]  HEX2,
      output reg  [6:0]  HEX3,
      output reg  [6:0]  HEX4,
      output reg  [6:0]  HEX5,

      input       [3:0]  KEY,

      output reg  [9:0]  LEDR,

      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,

      input              RESET_N,

      output             SD_CLK,
      inout              SD_CMD,
      inout       [3:0]  SD_DATA,

      input       [9:0]  SW,

      output      [3:0]  VGA_B,
      output      [3:0]  VGA_G,
      output             VGA_HS,
      output      [3:0]  VGA_R,
      output             VGA_VS
);

integer i, j;
initial
begin
	for(i=0; i<128*4; i=i+1)
	  slv8_reg[i] = 8'h00;
	  
	connection_sel = 0;
	is_new = 0;
	nts = 0;
	dvb = 0;
   dam = 0;
   ryt = 0;
   bd = 0;
   sd = 0;
   tom = 0;
   tc = 0;
   hh = 0;
	
   for(i=0; i<2; i=i+1)
	  for(j=0; j<9; j=j+1)
	  begin
	     fnum[i][j] = 0;
		 block[i][j] = 0;
		   kon[i][j] = 0;
         cha[i][j] = 0;
         chb[i][j] = 0;
         chc[i][j] = 0;
         chd[i][j] = 0;
          fb[i][j] = 0;
         cnt[i][j] = 0;
	 end
	
	for(i=0; i<2; i=i+1)
	  for(j=0; j<18; j=j+1)
	  begin
	     mult[i][j] = 0;
          ws[i][j] = 0;
         vib[i][j] = 0;
          ar[i][j] = 0;
          dr[i][j] = 0;
          sl[i][j] = 0;
          rr[i][j] = 0;
          tl[i][j] = 0;
         ksr[i][j] = 0;
         ksl[i][j] = 0;
         egt[i][j] = 0;
          am[i][j] = 0;
	  end
	  
	HEX0 = 127;
	HEX1 = 127;
	HEX2 = 127;
	HEX3 = 127;
	HEX4 = 127;
	HEX5 = 127;
end

reg        [31:0] count;

always @(posedge CLOCK_50)
begin
	count <= count + 1;
end

//assign LEDR[0] = count[22];
assign LEDR[0] = kon[0][0];
assign LEDR[1] = kon[0][1];
assign LEDR[2] = kon[0][2];
assign LEDR[3] = kon[0][3];
assign LEDR[4] = kon[0][4];
assign LEDR[5] = kon[0][5];
assign LEDR[6] = kon[0][6];
assign LEDR[7] = kon[0][7];
assign LEDR[8] = kon[0][8];

spdif_core spdif_core(
    .clk_i(spdif_clk),
    .rst_i(0),
	 .bit_out_en_i(1),
	 .spdif_o(GPIO_0[0]),
	 .sample_i({channel_a, channel_c, channel_b, channel_d})
	 //.sample_i({channel_a + channel_c, channel_b + channel_d})
);

SDCLK SDCLK(
	.refclk(CLOCK_50),
	.rst(0),
	.outclk_0(spdif_clk), // 315/88*1e6*4/288*32*2*2 (normally: 48000*32*2*2)
	.outclk_1(clk)        // 315/88*1e6*4
	);

/**** ****/

reg [7:0] OPL3reg;

always@(posedge GPIO_1[13])
begin
	if(GPIO_1[8]==0)
		OPL3reg <= GPIO_1[7:0];
	if(GPIO_1[8]==1)
		slv8_reg[OPL3reg] <= GPIO_1[7:0];
end

/**** ****/
	
/**** OPL3 ****/

wire [7:0] slv8_reg[128*4];
reg clk;
reg sample_clk_en;
reg [REG_CONNECTION_SEL_WIDTH-1:0] connection_sel;
reg is_new;
reg nts;
reg [REG_FNUM_WIDTH-1:0] fnum [2][9];
reg [REG_MULT_WIDTH-1:0] mult [2][18];
reg [REG_BLOCK_WIDTH-1:0] block [2][9];
reg [REG_WS_WIDTH-1:0] ws [2][18];
reg vib [2][18];
reg dvb;
reg kon [2][9];
reg [REG_ENV_WIDTH-1:0] ar [2][18];  // attack rate
reg [REG_ENV_WIDTH-1:0] dr [2][18];  // decay rate
reg [REG_ENV_WIDTH-1:0] sl [2][18];  // sustain level
reg [REG_ENV_WIDTH-1:0] rr [2][18];  // release rate
reg [REG_TL_WIDTH-1:0] tl [2][18];   // total level
reg ksr [2][18];                     // key scale rate
reg [REG_KSL_WIDTH-1:0] ksl [2][18]; // key scale level
reg egt [2][18];                     // envelope type
reg am [2][18];                      // amplitude modulation (tremolo)
reg dam;                             // depth of tremolo
reg ryt;
reg bd;
reg sd;
reg tom;
reg tc;
reg hh;
reg cha [2][9];
reg chb [2][9];
reg chc [2][9];
reg chd [2][9];
reg [REG_FB_WIDTH-1:0] fb [2][9];
reg cnt [2][9];
reg signed [SAMPLE_WIDTH-1:0] channel_a;
reg signed [SAMPLE_WIDTH-1:0] channel_b;
reg signed [SAMPLE_WIDTH-1:0] channel_c;
reg signed [SAMPLE_WIDTH-1:0] channel_d;

reg [7:0] timer1;
reg [7:0] timer2;
reg irq_rst;
reg mt1;
reg mt2;
reg st1;
reg st2;
reg irq;

clk_div sample_clk_gen (.clk_en(sample_clk_en), .clk(clk));

register_file_axi register_file_axi (.*);

channels channels (.*);

timers timers (.*);

/**** EOF OPL3 ****/

endmodule
//`default_nettype wire