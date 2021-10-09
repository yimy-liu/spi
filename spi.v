{\rtf1\ansi\ansicpg936\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fnil\fcharset134 PingFangSC-Regular;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 //clk:100MHz\
//sclk:10MHz\
module spi #(\
parameter CMD_RW_FLAG =1,\
parameter CMD_ADDR_WIDTH=3,\
parameter CMD_DATA_WIDTH=8,\
parameter CMD_WIDTH=CMD_RW_FLAG+CMD_ADDR_WIDTH+CMD_DATA_WIDTH\
)(\
input clk,\
input rst_n,\
input cmd_valid,\
input  [CMD_WIDTH-1:0] cmd_in,\
\
output cmd_ready,\
output read_valid,\
output [DATA_WIDTH-1:0] read_data,\
output reg sclk,\
output  cs,\
input   miso,\
output  mosi,\
\
)
\f1 \'a3\'bb
\f0 \
\
//read\
reg[CMD_WIDTH-1:0] mosi_buf;\
reg[3:0] spi_clk_cnt;\
reg[3:0] spi_bit_num;\
\
reg[6:0] delay_clk_cnt;\
wire work_en;\
\
reg[CMD_DATA_WIDTH-1:0] miso_buf;\
\
reg[2:0] fsm_cs;\
reg[2:0] fsm_ns;\
\
//fsm state define\
local parameter IDLE =3'd0,\
                W_DATA=3'd1,\
                R_DATA=4'd2,\
                R_DELAY=4'd3,\
                R_SEND_DATA=4'd4,//R send data\
                READ_DATA=4'd5;\
\
reg[2:0] fsm_cs;\
reg[2:0] fsm_ns;\
\
always @ (posedge clk or negedge rst_n)\
begin\
    if(!rst_n)\
        fsm_cs <= IDLE;\
    else\
        fsm_cs <= fsm_ns;\
end\
\
always@(*)\
begin\
     case(fsm_cs)\
         IDLE:\
             if(cmd_valid)\
                 fsm_ns = cmd_in[11]?W_DATA:R_DATA;             \
             else\
                 fsm_ns = IDLE;\
        W_DATA:\
            if(spi_clk_cnt == 4'd9&& spi_bit_num==4'd11)\
                fsm_ns = IDLE;\
            else\
                fsm_ns = W_DATA;  \
        R_DATA:\
            if(spi_clk_cnt == 4'd9 && spi_bit_num == 4'd11 )\
                fsm_ns = R_DELAY;\
            else\
                fsm_ns = R_DATA;\
        R_DELAY:\
            if(delay_clk_cnt==6'd49)         \
                fsm_ns = R_SEND_DATA;\
            else\
                fsm_ns = R_DELAY;\
        R_SEND_DATA:\
            if(spi_clk_cnt == 4'd9 && spi_bit_num == 4'd7 )\
                fsm_ns = READ_DATA;\
            else\
                fsm_ns = R_SEND_DATA;\
        READ_DATA:\
                fsm_ns = IDLE;\
        default:\
                fsm_ns = IDLE;\
        endcase\
   end\
\
assign cmd_ready=fsm_cs==IDLE;\
assign cs= ~(fsm_cs==W_DATA||fsm_cs==R_DATA||fsm_cs==R_SEND_DATA);\
//assign sclk = (spi_clk_cnt >= 4'd5);\
\
always@
\f1 \'a3\'a8posedge clk or negedge rst_n\'a3\'a9\
begin\
    if(!rst_n)\
         sclk<=1\'a1\'afb0;\
    else if(spi_clk_cnt<=4\'a1\'afd4)\
         sclk<=1\'a1\'afb0;\
   else\
         sclk<=1\'a1\'afb1;\
end \

\f0 \
//mosi_buf\
always@(posedge clk or negedge rst_n)\
begin\
    if(!rst_n)\
        mosi_buf <= \{CMD_WIDTH(1'd0)\};\
    else if ((fsm_cs==IDLE && cmd_valid)\
        mosi_buf <= cmd_in;\
end\
\
assign work_en=fsm_cs==W_DATA|| fsm_cs==R_DATA || fsm_cs==R_SEND_DATA; \
\
//spi_clk_cnt\
always@(posedge clk or negedge rst_n)\
begin\
    if(!rst_n)\
        spi_clk_cnt <= 4'd0;\
    else if (work_en)\
        begin\
            if(spi_clk_cnt==4'd9)\
                spi_clk_cnt <= 4'd0;\
            else\
                spi_clk_cnt <= spi_clk_cnt+1'b1;\
         end\
end     \
 \
\
//spi_bit_num\
always@(posedge clk or negedge rst_n)\
begin\
    if(!rst_n)\
        spi_bit_num <= 4'd0;\
    else if(work_en)\
        begin\
           if(spi_clk_cnt==4'd9)\
               spi_bit_num<= spi_bit_num+1'b1;\
        end\
    else \
        spi_bit_num <= 4'd0;\
end     \
 \
assign mosi = (fsm_cs == W_DATA || fsm_cs == R_DATA)?mosi_buf[spi_bit_num]:1'b0;\
\
always @ (posedge clk or negedge rst_n)\
begin\
    if(!rst_n)\
        delay_clk_cnt <= 7'b0;\
    else if(delay_clk_cnt==99)\
        delay_clk_cnt <= 7'b0;\
    else if(fsm_cs==R_DELAY)\
        delay_clk_cnt <= delay_clk_cnt + 1'b1;\
end\
\
always @ (posedge clk or negedge rst_n)\
begin\
    if(!rst_n)\
        miso_buf <= \{CMD_DATA_WIDTH
\f1 \{1
\f0 \'92b0\}\};\
    else if(fsm_cs==R_SEND_DATA&&spi_clk_cnt==4)\
        miso_buf <= \{miso,miso_buf[R_SEND_DATA-1:1]\};\
end\
\
assign read_valid = fsm_cs == R_SEND_DATA;\
assign read_data = miso_buf;\
endmodule}