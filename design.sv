module switch( clk,rst,data_in,valid_in, paddr,psel,pen,p_write,p_wdata, 
out_port1,out_port2,out_port3, out_port4,valid_out,prdata);

input clk,rst,data_in,valid_in;
input [31:0]paddr;
input [31:0]p_wdata; 
input psel,pen,p_write;
output out_port1,out_port2,out_port3, out_port4,valid_out;
output reg  [31:0]prdata;
//reg bank
reg chip_en;
reg [7:0]chip_id;
reg [3:0]out_port_en;

//internal reg
reg [63:0]in_pkt;
reg [63:0]out_pkt;
reg [7:0]cnt;
reg out_start,pkt_rec;
reg [7:0]cnt_out;

wire pwrite,pread;

assign pwrite=p_write && psel && pen;
assign pread= (p_write==0) && psel && pen;

always@(posedge clk) begin
	if(!rst) begin
          chip_en<=0;
	  chip_id<='hAA;
	  out_port_en<=4'b0001;
	end
	else if(paddr==0 && pwrite) begin
		chip_en<=p_wdata[0];
	end
	else if(paddr=='h8 && pwrite) begin
		out_port_en<=p_wdata[3:0];
	end
	else if(paddr==0 && pread) begin
		prdata<=chip_en;
	end
	else if(paddr=='h4 && pread) begin
		prdata<=chip_id;
	end
	else if(paddr=='h8 && pread) begin
		prdata<=out_port_en;
	end

end

always@(posedge clk) begin
	if(!rst) begin
          in_pkt<=0;
	  cnt<=0;
	  pkt_rec<=0;
	end
	else if(valid_in && cnt!=64) begin
		cnt<=cnt+1;
                in_pkt<= {in_pkt[62:0], data_in};
		pkt_rec<=0;
	end
	else if (cnt==64) begin
           cnt<=0;
	   pkt_rec<=1;
	end
end

always@(posedge clk) begin
	if(!rst) begin
          out_pkt<=0;
	end
	else if(pkt_rec) begin
		out_pkt<=in_pkt;
      
      out_pkt[63:48]<=in_pkt[47:32];
      out_pkt[47:32]<=in_pkt[63:48];
      out_pkt[31:0]<=in_pkt[31:0];
     
     pkt_rec<=0;
	end
	else if(out_start) begin
		out_pkt<=out_pkt<<1;
	end
end
always@(posedge clk) begin
	if(!rst) begin
          out_start<=0;
	  cnt_out<=0;
	end
	else if(cnt_out==64) begin
		out_start<=0;
      cnt_out<=0;
	end
	else if(out_start | pkt_rec) begin
		cnt_out<=cnt_out+1;
		out_start<=1;
	end
end

assign valid_out=out_start;

assign out_port1= chip_en &  (out_port_en==4'b0001) & out_pkt[63];
assign out_port2= chip_en &  (out_port_en==4'b0010) & out_pkt[63];
assign out_port3= chip_en &  (out_port_en==4'b0100) & out_pkt[63];
assign out_port4= chip_en &  (out_port_en==4'b1000) & out_pkt[63];

endmodule

