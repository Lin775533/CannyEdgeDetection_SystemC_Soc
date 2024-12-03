# Edited for F24 by VG
# Clean Makefile for ECPS203

SYSTEMC = /users/ugrad/2017/summer/ecps203/public/SystemC_F24

INCLUDE = -I. -I$(SYSTEMC)/include
LIBRARY = $(SYSTEMC)/lib-linux64
SYSC_CFLAG = $(INCLUDE) -L$(LIBRARY) -Xlinker -R -Xlinker $(LIBRARY) -lsystemc

CC = g++
RM = rm -f

VIDEO   = Engineering
FRAMES  = $(VIDEO)[0-9][0-9][0-9]_edges.pgm

EXE =   canny

all: $(EXE)

clean:
	$(RM) $(EXE)
	$(RM) *.bak *~
	$(RM) *.o *.ti gmon.out
	$(RM) $(IMG_OUT)
	$(RM) $(FRAMES)

cleanall: clean
	$(RM) *.log

# Assignment 5
# Test bench model in SystemC

canny: canny.cpp
	$(CC) $(SYSC_CFLAG) $< -o $@

test: canny video/$(FRAMES)
	ulimit -s 128000; ./$<
	set -e; \
	for f in video/$(FRAMES); do \
		diff `basename $$f` $$f; \
	done

# Basic optimization with O2
canny_O2_opt: canny.cpp
	$(CC) $(SYSC_CFLAG) -O2 $< -o $@

# More aggressive optimization with O3
canny_O3_opt: canny.cpp
	$(CC) $(SYSC_CFLAG) -O3 $< -o $@

# Maximum optimization with additional flags
canny_O3_full_opt: canny.cpp
	$(CC) $(SYSC_CFLAG) -O3 -ffast-math -funroll-loops -ftree-vectorize $< -o $@

# ARM-specific optimizations
canny_O3_arm: canny.cpp
	$(CC) $(SYSC_CFLAG) -O3 -march=native -mtune=native -ffast-math $< -o $@

# Test all optimization levels (x86)
test_all_opt: canny_O2_opt canny_O3_opt canny_O3_full_opt
	@echo "Running tests with different optimization levels..."
	@echo "\nTesting -O2 version:"
	./canny_O2_opt
	@echo "\nTesting -O3 version:"
	./canny_O3_opt
	@echo "\nTesting fully optimized version:"
	./canny_O3_full_opt

# Test ARM optimizations
test_arm: canny_O3_arm
	@echo "Running ARM-optimized version..."
	./canny_O3_arm

clean_opt:
	$(RM) canny_O2_opt canny_O3_opt canny_O3_full_opt canny_O3_arm *.o

# EOF
