CXX	 = c++
CXXFLAGS = -g -Wall -pedantic-errors -Iinclude/
LDLIBS   = -lncurses -lpthread
BINNAME  = steganos
VPATH	 = src/
BUILDDIR = obj/
OBJECTS	 = $(shell for cpp_file in `ls $(VPATH)`; do echo $(BUILDDIR)$$cpp_file | sed "s/cpp/o/g"; done)
HDEPENDS = ncurses.h

all: check_depenencies create_obj_dir $(BINNAME)
	@echo "Done!"

check_depenencies:
	@tmp_file=$$(mktemp); \
	h_file=$${tmp_file}.h; \
	mv $$tmp_file $$h_file; \
	for dependency in $(HDEPENDS); do echo "#include <$$dependency>" >> $$h_file; done; \
	g++ -c $$h_file 2> /dev/null; \
	dependencies_ret_val=$$?; \
	rm $${h_file}*; \
	if [ $$dependencies_ret_val != 0 ]; then \
		echo "This application requires ncurses to be installed"; \
		echo "Try running: sudo apt-get install libncurses5-dev"; \
		exit $$dependencies_ret_val; \
	fi; \

create_obj_dir:
	@mkdir -p $(BUILDDIR)

$(BINNAME): $(OBJECTS)
	$(CXX) -o $@ $^ $(LDLIBS)

$(BUILDDIR)%.o: %.cpp
	$(CXX) $(CXXFLAGS) $< -c -o $@

test: test-with-files test-with-locks

test-with-files: all
	./test_steganos -f

test-with-locks: all
	./test_steganos -l

clean:
	@rm -f $(OBJECTS) $(BINNAME) ;							# not using rm -rf on BUILDDIR inorder to keep the user safe
	@if [ -d $(BUILDDIR) ]; then rmdir $(BUILDDIR); fi ;	# rmoving the BUILDDIR if exists
#	@echo "Good as new!"
