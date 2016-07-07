GC=gcc
SOURCE=convolution.c
TARGET=convolution
PREFIX=-lm

all:
	$(GC) $(SOURCE) $(PREFIX) -o $(TARGET)
clean:
	rm -rf $(TARGET)