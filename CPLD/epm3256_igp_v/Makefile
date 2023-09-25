# Для тестирования модуля неодходимо чтобы тест назывался test_%имя_модуля%

#TARGET = pent_gen
ICARUS = iverilog

#mv out.vcd $(TARGET).vcd
#all: 
#	$(ICARUS) -o $(TARGET)  $(TARGET).v test_$(TARGET).v
#	vvp $(TARGET)
log: 
	$(ICARUS) -o pent_log.tmp  pent_log.v test_pent_log.v
	vvp pent_log.tmp
gen: 
	$(ICARUS) -o pent_gen.tmp  pent_gen.v test_pent_gen.v
	vvp pent_gen.tmp
clean:
#   rm -f $(TARGET) $(TARGET).vcd
	rm -f *.tmp *.vcd

.PHONY: all clean
