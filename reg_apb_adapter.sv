//adapter class

class reg_apb_adapter extends uvm_reg_adapter;
  `uvm_object_utils(reg_apb_adapter)
  
  function new(string name = "reg_apb_adapter");
    super.new(name);
  endfunction

  //reg2bus function which will convert register level transactions into bus level transactions
  virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
    seq_item pkt = seq_item::type_id::create("pkt");
    pkt.rd_or_wr = (rw.kind == UVM_WRITE) ? 1: 0;
   
   pkt.addr = rw.addr;
    pkt.data = rw.data;
   
    `uvm_info(get_type_name, $sformatf("reg2bus: addr = %0h, data = %0h, rd_or_wr = %0h",  pkt.addr,  pkt.data,  pkt.rd_or_wr), UVM_LOW);
    $info("-----------");
    return  pkt;
  endfunction
 
  //bus2reg function which will convert bus level transactions into register level transactions 
  
  virtual function void bus2reg (uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    seq_item bus_pkt;
    if(!$cast(bus_pkt, bus_item))
      `uvm_fatal(get_type_name(), "Failed to cast bus_item transaction")

    rw.addr = bus_pkt.addr;
    rw.data = bus_pkt.data;
    rw.kind = (bus_pkt.rd_or_wr) ? UVM_READ: UVM_WRITE;
    
    `uvm_info(get_type_name, $sformatf("bus2reg: addr = %0h, data = %0h, rd_or_wr = %0h", rw.addr, rw.data, bus_pkt.rd_or_wr), UVM_LOW);
    $info("-----------");
  endfunction
endclass
