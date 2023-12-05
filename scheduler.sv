 module scheduler;

typedef struct packed{
    int time_1;
    int core;
    int operation;   
    bit [33:0] address;
 }TraceData;
 
  
typedef struct packed {
    int time_1;
    int core;
    int operation;
    bit [33:18] row;
    bit [17:12] high_col;
    bit [11:10] bank;
    bit [9:7] bank_grp;
    bit [6] channel;
    bit [5:2] low_col;
    bit [1:0] byte_sel;
	bit [9:0]column;
	
} Memory;
   
    

    // Define the structs
    TraceData trace;
    Memory memory;

    // Define the queue
    int queue_count=0;
    int queue_front=0;
    int queue_back =0;
    TraceData trace_queue[16];
	int in,out;
	string output_filename;
    string trace_file = "default_trace_file.txt";
	
	
	 
	
	parameter  tRCD = 78;  
	parameter  tCL = 80;   
	parameter  tRP = 78;   
	parameter  tRFC = 590; 
	parameter  tWR = 60;   
	parameter  tBURST = 16;
	parameter  tCWD = 76;
	parameter  QUEUE_SIZE = 16;
	
	 
	 int final_time = 0;
	 int current_time =0;
	 int time_2;
	 
	
	
	
	task processDramCommand(Memory memory);
	    
		automatic int initial_time;
	    if(memory.time_1 % 2 == 0) begin
		    initial_time = memory.time_1 +2;
		end
		else begin
       		initial_time = memory.time_1 +1;
		end
	 
	   // timing logic
	 //  automatic int initial_time = time_2;
	
	    if(initial_time > final_time) begin
		
		        current_time = initial_time;
		end else begin
		        
				current_time = final_time;
				
		end
                 		
		
    


        // display of ACT0,ACT1 command 
        $fwrite(out,"%d %d ACT0 %d %d %h\n", current_time, memory.channel,memory.bank_grp, memory.bank, memory.row);
	    $fwrite(out,"%d %d ACT1 %d %d %h\n", current_time+2,memory.channel, memory.bank_grp, memory.bank, memory.row);
        current_time += tRCD+2; // Wait for tRCD

        // if operation is 0 and 2 - read and if 1 write
       unique case(memory.operation)
        0, 2: begin
               $fwrite(out,"%d %d  RD0 %d %d %h\n", current_time,memory.channel, memory.bank_grp, memory.bank, memory.column);
               $fwrite(out,"%d %d  RD1 %d %d %h\n", current_time+2,memory.channel, memory.bank_grp, memory.bank, memory.column);
               current_time += tCL + tBURST + 2; 
			   end
        1:    begin
               $fwrite(out,"%d %d  WR0 %d %d %h\n", current_time, memory.channel, memory.bank_grp, memory.bank, memory.column);
               $fwrite(out,"%d %d  WR1 %d %d %h\n", current_time+2,memory.channel, memory.bank_grp, memory.bank, memory.column);
               current_time += tCWD + tBURST + 2; 
			  end
        
         endcase
        // display of PRE command and wait for tRP 
        $fwrite(out,"%d %d  PRE %d %d\n", current_time,memory.channel, memory.bank_grp, memory.bank);
        final_time = current_time + tRP; 

    endtask
	
	
	
 initial begin 
  

  if ($value$plusargs("input=%s", trace_file) == 0) begin
    $display("User has not specified any file. Using default file: %s", trace_file);
  end else begin
    $display("Opening user file: %s", trace_file);
  end
  if (!$value$plusargs("output=%s", output_filename)) begin
            output_filename = "dram.txt"; // Default output filename
        end
		

     `ifdef DEBUG_ON 
	   begin
	    $display("DEBUG MODE is enabled");
        in = $fopen(trace_file, "r");

        if (in == 0) begin
            $display("Error opening trace file");
            $finish;
        end
		
		out= $fopen(output_filename, "w");
        if (out == 0) begin
            $display("Failed to open output file: %s", output_filename);
            $finish;
        end
   
    
        // Process each line in the trace file
        while (!$feof(in)) begin
            // Read data from the trace file
            $fscanf(in, "%0d %0d %0d %0h", trace.time_1, trace.core, trace.operation, trace.address);
			
            if (queue_count < QUEUE_SIZE) begin
                // Assign data to trace_queue and push it into the queue
                trace_queue[queue_back] = trace;
                queue_back = (queue_back + 1) % QUEUE_SIZE;
                queue_count = queue_count + 1;

                // Display the pushed data
               // $display("Pushed data: time=%0d core=%0d operation=%0d address=%0h", trace.time_1, trace.core, trace.operation, trace.address);
            end else begin
                $display("Queue full. Waiting for space...");
                  
            end

            // Process data from the queue
             if (queue_count > 0) begin
                trace = trace_queue[queue_front];
                queue_front = (queue_front + 1) % QUEUE_SIZE;
                queue_count = queue_count - 1;
                  
                // Decode the address and store in Memory
                memory.time_1 = trace.time_1;
                memory.core = trace.core;
                memory.operation = trace.operation;
                memory.row = trace.address[33:18];
                memory.high_col = trace.address[17:12];
                memory.bank = trace.address[11:10];
                memory.bank_grp = trace.address[9:7];
                memory.channel = trace.address[6];
                memory.low_col = trace.address[5:2];
                memory.byte_sel = trace.address[1:0];
				memory.column = {trace.address[17:12],trace.address[5:2]};
				memory.channel=0;
				
			   processDramCommand(memory);
                        
            end else begin
                $display("Queue is empty. Waiting for data...");
                
            end
			
			
     end 
end	 
    `else
       begin
         $display("DEBUG MODE is NOT enabled.");
       end
	 `endif

        // Close the trace file
        if (in) begin
           $fclose(in);
           $display("File closed.");
        end
		
		
	end
endmodule

	
