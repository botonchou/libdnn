include config.mk

CFG_NVCC+= -arch=sm_21 -w #-Xcompiler "-Wall"
CFLAGS=

BOTON_UTIL_ROOT=tools/utility/
CUMATRIX_ROOT=tools/libcumatrix/

INCLUDE= -I ./ \
	 -I include/ \
	 -I $(BOTON_UTIL_ROOT)/include/ \
	 -I $(CUMATRIX_ROOT)/include \
 	 -I /usr/local/cuda/samples/common/inc/ \
	 -I /usr/local/cuda/include

CPPFLAGS= -std=c++0x $(CFLAGS) $(INCLUDE) #-Werror -Wall 

SOURCES=cnn-utility.cu\
	nnet.cpp\
	dnn-utility.cu\
	utility.cpp\
	rbm.cu\
	feature-transform.cu\
	data-io.cpp\
	dataset.cpp\
	batch.cpp\
	config.cpp

EXECUTABLES=nn-train\
	    nn-predict\
	    nn-init\
	    nn-info\
	    nn-print\
	    data-statistics

EXECUTABLES:=$(addprefix bin/, $(EXECUTABLES))

.PHONY: debug all o3 dump_nrv ctags clean

all: $(EXECUTABLES) ctags

o3: CFLAGS+=-O3
o3: all
debug: CFLAGS+=-g -DDEBUG
debug: all
dump_nrv: CFG_NVCC+=-Xcompiler "-fdump-tree-nrv" all
dump_nrv: all

vpath %.h include/
vpath %.cpp src/
vpath %.cu src/

OBJDIR:=obj/
OBJ:=$(addprefix $(OBJDIR)/, $(addsuffix .o,$(basename $(SOURCES))))

$(OBJDIR):
	@mkdir -p $(OBJDIR)

LIBRARY=-lpbar -lcumatrix
CUDA_LIBRARY=-lcuda -lcudart -lcublas
LIBRARY_PATH=-L$(BOTON_UTIL_ROOT)/lib/ -L$(CUMATRIX_ROOT)/lib -L/usr/local/cuda/lib64

$(EXECUTABLES): bin/% : $(OBJ) $(OBJDIR)/%.o
	$(CFG_CXX) -o $@ $(CFLAGS) -std=c++0x $(INCLUDE) $^ $(LIBRARY_PATH) $(LIBRARY) $(CUDA_LIBRARY)

# +==============================+
# +===== Other Phony Target =====+
# +==============================+
$(OBJDIR)/%.o: %.cpp
	$(CFG_CXX) $(CPPFLAGS) -std=c++0x -o $@ -c $<

$(OBJDIR)/%.o: %.cu include/%.h
	$(CFG_NVCC) $(CFLAGS) $(INCLUDE) -o $@ -c $<

$(OBJDIR)/%.d: %.cpp | $(OBJDIR)
	@$(CFG_CXX) -MM $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,$(OBJDIR)/\1.o $@ : ,g' < $@.$$$$ > $@;\
	rm -f $@.$$$$

-include $(addprefix $(OBJDIR)/,$(subst .cpp,.d,$(SOURCES)))

ctags:
	@if command -v ctags >/dev/null 2>&1; then ctags -R --langmap=C:+.cu *; fi
clean:
	$(MAKE) clean -C tools/libcumatrix/
	$(MAKE) clean -C tools/utility/
	rm -rf $(EXECUTABLES) $(OBJDIR)/*
