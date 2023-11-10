module checkpoint1;
  string fname;
  string line;
  logic open_file;
  integer file;


  initial begin

fname = "input_file.txt";

    // Verify whether a file name entered by the user is supplied as a command-line argument.
    if ($value$plusargs("FILENAME=%s", fname) == 0) begin
      $display("No file name is given by user. Using default file: %s", fname);
    end else begin
      $display("Using file given by user file: %s", fname);
    end

 // opening file and perform reading
    file = $fopen(fname, "r");
    if (file == 0) begin
      $display("Error: Could not open the file: %s", fname);
      $finish;
    end else begin
      open_file = 1;
    end
  
  

`ifdef DEBUG_ON 
begin
    // Read and parse the file line by line
    while (open_file) begin
    
       $fgets(line, file);
    $display(" %s", line);


    if (line == "") begin
        $display("file end");
        break;
      end

      
      
    end
end
`else
$display("DEBUG MODE is OFF.");
`endif
$fclose(file);  // file closing
     
    if (open_file) begin
      $fclose(file);
      $display("File closed.");
    end

    $finish;
  end
endmodule
        
