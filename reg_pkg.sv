//chip enable register class

class Chip_enable_reg extends uvm_reg;
  `uvm_object_utils (Chip_enable_reg)
 
  //declare the field
   rand uvm_reg_field Chip_enable;
  
   function new( string name = "Chip_enable_reg" );
     super.new(  name, 1 , build_coverage( UVM_NO_COVERAGE ) );
   endfunction
 
   virtual function void build();
     this.Chip_enable = uvm_reg_field::type_id::create( "Chip_enable",,this.get_full_name() );
     
     //pass the configuration details such as access type, reset value etc
      this.Chip_enable.configure( this, 1, 0, "RW", 0, 1'h1, 1, 1, 0);
 
   endfunction
endclass


//chip id register class
class Chip_Id_reg extends uvm_reg;
   `uvm_object_utils( Chip_Id_reg)
  
//field declaration 
    uvm_reg_field Chip_Id;
  
   function new( string name = "Chip_Id_reg" );
     super.new( name ,  8 ,  build_coverage( UVM_NO_COVERAGE )   );
   endfunction: new
 
   virtual function void build();
      this.Chip_Id = uvm_reg_field::type_id::create( "Chip_Id",,this.get_full_name() );
     
     //configuration details
     this.Chip_Id.configure(this, 8, 0, "RO", 0, 8'hAA, 1, 1, 0 );
 
   endfunction
endclass


//output port enable register class
class Output_Port_enable_reg extends uvm_reg;
   `uvm_object_utils( Output_Port_enable_reg)
 
 //field declaration  
  rand uvm_reg_field Output_Port_enable;
  
   function new( string name = "Output_Port_enable_reg" );
     super.new(  name ,  4 ,   build_coverage( UVM_NO_COVERAGE )  );
   endfunction: new
 
   virtual function void build();
      this.Output_Port_enable = uvm_reg_field::type_id::create( "Output_Port_enable",,this.get_full_name() );
     
     //configuration details
     this.Output_Port_enable.configure( this, 4, 0, "RW", 0, 1'h1, 1, 1, 0 );
 
   endfunction
endclass



//..........................................................................................................................................

//reg block class which holds the registers
class ModuleReg extends uvm_reg_block;

  //declare the handles of all the 3 registers
   rand Chip_enable_reg enable_reg;
    Chip_Id_reg  Id_reg;  //not declared as rand since it is read only register
   rand Output_Port_enable_reg Port_enable_reg;
  
  
  `uvm_object_utils(ModuleReg)
  function new(string name = "module_reg");
    super.new(name,UVM_NO_COVERAGE);
  endfunction

  //cretare, configure and call the build function of each register
  virtual function void build();
    this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 1);  
    enable_reg = Chip_enable_reg::type_id::create( "enable_reg" );  //create the register
    enable_reg.configure(  this,null );  //register configuration
    enable_reg.build();   
 
      Id_reg = Chip_Id_reg::type_id::create( "Id_reg" );
      Id_reg.configure(this,null );
      Id_reg.build();
     
      Port_enable_reg = Output_Port_enable_reg::type_id::create( "Port_enable_reg" );
    Port_enable_reg.configure( this ,null );
      Port_enable_reg.build();
    
  //add all the registers to the register block    
    this.default_map.add_reg(enable_reg, 0, "RW");
        this.default_map.add_reg(Id_reg, 4, "RO");
        this.default_map.add_reg(Port_enable_reg, 8, "RW");
   endfunction: build
 
endclass
//----------------------------------------------------------------------
//----------------------------------------------------------------------

// Top Level register block class: SFR Reg Model 
class RegModel_SFR extends uvm_reg_block;
  rand ModuleReg mod_reg;  //call the handle of ModuleReg class
  
  `uvm_object_utils(RegModel_SFR)
  
  function new(string name = "RegModel_SFR");
    super.new(name);
  endfunction
  
  virtual function void build();
    this.default_map = create_map("axi_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
   
    this.mod_reg = ModuleReg::type_id::create("mod_reg");
    this.mod_reg.configure(this,"*");
    this.mod_reg.build();
    this.default_map.add_submap(this.mod_reg.default_map, 0);
  endfunction
endclass


