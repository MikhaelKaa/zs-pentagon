ICARUS = iverilog

$(tb):
	@echo "test $(tb)"
	$(ICARUS) -o $(tb).tmp  $(tb).v $(tb)_tb.v
	vvp $(tb).tmp
	rm $(tb).tmp

#7400: 
#	$(ICARUS) -o 7400.tmp  7400.v 7400_tb.v
#	vvp 7400.tmp
#	rm 7400.tmp

default:
	@echo "use make tb=NAME_OF_TESTING_MODULE"
	@echo "use make clean to delete .vcd files"
	ls | grep .v
	
clean:
	rm -f *.tmp *.vcd
.PHONY: all clean
