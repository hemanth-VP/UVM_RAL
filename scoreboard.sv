 `uvm_analysis_imp_decl(_active)
 `uvm_analysis_imp_decl(_passive)

//scoreboard class
class scoreboard extends uvm_scoreboard;

  //factory registration
  `uvm_component_utils(scoreboard)
  
  //2 analysis implementation ports are declared one is to collect the data from active monito and other is to collect the data from passive monitor
  uvm_analysis_imp_active #(seq_item,scoreboard) wr_mon_port;
  uvm_analysis_imp_passive #(seq_item,scoreboard) rd_mon_port;
  
  seq_item req;  //sequence item handle
 
  bit[63:0] expected_pkt;  //64 bit packet to store the expected data
  bit[63:0] actual_pkt;   //64 bit packet to store the actual data
  bit s;                //one bit variable used while concatenating the expected data
  bit r;               //one bit variable used while concatenating the actual data
 
  
  //class constructor new
    function new(string name="scoreboard", uvm_component parent =null);
      super.new(name,parent);
      
      //memory for 2 analysis implementation ports
      wr_mon_port=new(" wr_mon_port",this);
      rd_mon_port=new(" rd_mon_port",this);
    endfunction
 
    virtual function void build_phase(uvm_phase phase);
      req = seq_item::type_id::create("req", this);   //sequence item creation
      super.build_phase(phase);
    endfunction
 
  //write method for active monitor
  virtual function void write_active(seq_item req);   //2 separate write methods for 2 monitors
    while(req.data_in_q.size() > 'd0)begin  //if the data_in_q has some data then
      s=req.data_in_q.pop_front();          //pop it and store it in the variable "s"
      expected_pkt=expected_pkt<<1;         //shift the expected packet by 1 bit so that the data is not lost
      expected_pkt+=s;                      //add the expected packet bits to the popped data and store it in the expected                                                packet to get the next bit till the end of packet.

    end
     `uvm_info(get_type_name(),$sformatf("expected packet=%b",expected_pkt),UVM_NONE)
   
    endfunction

 //write method for passive monitor 
  virtual function void write_passive(seq_item req); 
    while(req.data_out_q.size() > 'd0)begin     //if the data_out_q has some data then
      r=req.data_out_q.pop_front();             //pop it and store it in the variable "r"
      actual_pkt=actual_pkt<<1;                 //shift the expected packet by 1 bit so that the data is not lost
      actual_pkt+=r;                            //add the expected packet bits to the popped data and store it in the                                                         expected packet to get the next bit till the end of packet.
      
    end
    `uvm_info(get_type_name(),$sformatf("actual packet=%b",actual_pkt),UVM_NONE)
    

//comparision logic for source and destination packets.
    if(expected_pkt[63:48]==actual_pkt[47:32]  && expected_pkt[47:32]==actual_pkt[63:48]  && expected_pkt[31:0]==actual_pkt[31:0])
        begin
          `uvm_info(get_type_name(),"DATA IS MATCHING",UVM_NONE)   //if packets are matched then give a display message as data is matching
     
        //--------------------------------
        `uvm_info(get_type_name(),$sformatf("sr_e =%b sr_a=%b ds_e =%b ds_a=%b data_e=%b data_a=%b id_e=%b id_a=%b",expected_pkt[63:48],actual_pkt[47:32],expected_pkt[47:32],actual_pkt[63:48],expected_pkt[15:0],actual_pkt[15:0],expected_pkt[31:16],actual_pkt[31:16]),UVM_NONE)
        //---------
        end
      else
        begin
        
        `uvm_info(get_type_name(),$sformatf("sr_e =%b sr_a=%b ds_e =%b ds_a=%b data_e=%b data_a=%b id_e=%b id_a=%b",expected_pkt[63:48],actual_pkt[47:32],expected_pkt[47:32],actual_pkt[63:48],expected_pkt[15:0],actual_pkt[15:0],expected_pkt[31:16],actual_pkt[31:16]),UVM_NONE)
          
          `uvm_info(get_type_name(),"DATA IS NOT MATCHING",UVM_NONE)   //if packets are not matching then give a display message as data is not matching
        
        end
         endfunction
  


//   if(expected_pkt[63:48]==actual_pkt[47:32]  && expected_pkt[47:32]==actual_pkt[63:48]  && expected_pkt[31:0]==actual_pkt[31:0])
//     `uvm_info(get_type_name(),"DATA IS MATCHING",UVM_NONE)
 
//       else
//         `uvm_info(get_type_name(),"DATA IS NOT MATCHING",UVM_NONE)
     

 
 
 endclass