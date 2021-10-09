{\rtf1\ansi\ansicpg936\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fnil\fcharset134 PingFangSC-Regular;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 `timescale 1ns/1ps\
module spi_tb();\
    parameter CMD_RW_FLAG =1,\
    parameter CMD_ADDR_WIDTH=3,\
    parameter CMD_DATA_WIDTH=8,\
    parameter CMD_WIDTH=CMD_RW_FLAG+CMD_ADDR_WIDTH+CMD_DATA_WIDTH;\
\
    reg clk;\
    reg rst_n;\
    reg cmd_valid;\
    reg [CMD_WIDTH-1:0] cmd_in;\
    wire sclk;\
    wire cs;\
    wire cmd_ready;\
 \
    wire read_valid;\
    wire [CMD_DATA_WIDTH-1:0] read_data;\
    wire mosi;\
    reg miso;\
\
spi #(\
    .CMD_RW_FLAG (CMD_RW_FLAG),\
    .CMD_ADDR_WIDTH (CMD_ADDR_WIDTH),\
    .CMD_DATA_WIDTH (CMD_DATA_WIDTH),\
    .CMD_WIDTH (CMD_WIDTH)\
)\
inst_spi(\
.clk (clk),\
.rst_n (rst_n),\
.cmd_valid (cmd_valid),\
.cmd_in (cmd_in),\
.sclk (sclk),\
.cs (cs),\
.cmd_ready (cmd_ready),\
.read_valid (read_valid),\
.read_data (read_data),\
.mosi (mosi),\
.miso (miso)\
)\
\
initial begin\
     #0;\
     clk=0;\
     rst_n =0;\
     cmd_valid=0;\
     cmd_in =0;\
     miso=0;\
     #100;\
     rst_n=1;\
 end\
\
always #10 clk=~clk;\
\
initial begin\
    #200;\
    //send_write;\
    send_read(8\'92ha5);\
    #1000;\
    $finish;\
end\
\
integer II;\
\
task send_write;\
begin: WR\
    @(posedge clk)begin\
        cmd_valid <= 1'b1;\
        cmd_in<= \{1'b1,3'd5,8'ha5\};\
    end\
    @(posedge clk)begin\
        cmd_valid <= 1'b0;\
        cmd_in <= 12'd0;\
    end\
end\
endtask\
\
task send_read;\
input[7:0]read_data;\
begin:RD\
    fork\
        begin\
             @(posedge clk)begin\
                 cmd_valid <= 1'b1;\
                 cmd_in<= \{1'b0,3'd5,8'h0\};\
        end\
            @(posedge clk)begin\
            cmd_valid <= 1'b0;\
            cmd_in<= 12'd0;\
            end\
        end\
        begin\
           repeat(220) @(posedge clk);\
           for(II=0;II<8;II=II+1)begin\
               @(posedge clk)begin\
                   miso<= read_data[II];\
                   end\
                   repeat(10) @(posedge clk);\
             end\
        end\
    jion\
end\
endtask\
\
initial begin\
     $fsdbDumpfil
\f1 e(\'a1\'b0soc.fsdb\'a1\'b1);\
    $fsdbDumpvars;\
end\
endmodule}