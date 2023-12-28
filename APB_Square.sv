module APB_Square
#(parameter storona_a_ADDR = 4'h0,  // адрес регистра со стороной a
  parameter storona_b_ADDR = 4'h4,  // адрес регистра со стороной b
  parameter output_reg_ADDR = 4'h8) // адрес регистра, где хранится значение площади
(
    input wire PWRITE,            // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
    input wire PCLK,              // сигнал синхронизации
    input wire PSEL,              // сигнал выбора переферии 
    input wire [31:0] PADDR,      // Адрес регистра
    input wire [31:0] PWDATA,     // Данные для записи в регистр
    output reg [31:0] PRDATA = 0, // Данные, прочитанные из регистра
    input wire PENABLE,           // сигнал разрешения
    output reg PREADY = 0,        // сигнал готовности (флаг того, что всё сделано успешно)
	  input PRESET                  // сигнал сброса
);


reg  [31:0] storona_a  = 0;   // регистр для хранения стороны a
reg  [31:0] storona_b  = 0;   // регистр для хранения стороны b
reg  [31:0] output_reg = 0;   // регистр для хранения площади

always @(posedge PCLK) 
begin
    if(PRESET) // если обнаружен сигнал сброса, то обнуление сторон прямоугольника
	  begin
	    storona_a <= 0;
      storona_b <= 0;
	  end
	  
    else if (PSEL && !PWRITE && PENABLE) // Чтение из регистров 
     begin
        case(PADDR)
         storona_a_ADDR  : PRDATA <= storona_a;  // чтение по адресу регистра со стороной a
         storona_b_ADDR  : PRDATA <= storona_b;  // чтение по адресу регистра со стороной b
         output_reg_ADDR : PRDATA <= output_reg; // чтение по адресу выходного регистра
        endcase
        PREADY <= 1'd1; // поднимаем флаг заверешения операции
     end

     else if(PSEL && PWRITE && PENABLE) // запись производится только в регистры сторон прямоугольника
     begin
      case(PADDR)
         storona_a_ADDR : storona_a <= PWDATA;  // запись по адресу регистра со стороной a
         storona_b_ADDR : storona_b <= PWDATA;  // запись по адресу регистра со стороной b
      endcase
        PREADY <= 1'd1; // поднимаем флаг заверешения операции
     end
   
   if (PREADY) // сбрасываем PREADY после выполнения записи или чтения
    begin
      PREADY <= !PREADY;
    end
  end

always @(storona_a or storona_b) begin // блок реагирующий на изменение регистров со сторонами a и b

    if(PRESET)  // сброс значения output_reg по сигналу PRESET
	  begin
	    output_reg <= 0;
	  end
	  
    else begin
      output_reg <= storona_a * storona_b; // вычисление значения площади прямоугольника
    end
    
  
end

//iverilog -g2012 -o APB_Square.vvp APB_Square_tb.sv
//vvp APB_Square.vvp
endmodule