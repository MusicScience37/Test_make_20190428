# suffix
OBJ_SUFFIX ?= .o
EXE_SUFFIX ?=

# commands
TEST ?= test
MKDIR ?= mkdir -p

# output directories
TEMP_DIR ?= ../temp
BIN_DIR ?= ../bin

# if VERBOSE variable is set, show commands
ifndef VERBOSE
    QUIET := @
endif

# Default target is all
.PHONY: all
all:

# $(call source-dir-to-temp-dir, directory-list)
source-dir-to-temp-dir = $(addprefix $(TEMP_DIR)/,$1)

# $(call source-to-object, source-file-list)
source-to-object = $(call source-dir-to-temp-dir, \
    $(subst .c,$(OBJ_SUFFIX),$(filter %.c,$1)))

# $(call source-to-depend, source-file-list)
source-to-depend = $(call source-dir-to-temp-dir, \
    $(subst .c,.d,$(filter %.c,$1)))

# $(eval $(call prepare-directories, directory-list))
# prepare output directories (if not cleaning)
define prepare-directories
    ifneq ($(MAKECMDGOALS),clean)
        $(foreach f, $1, \
            $(eval TEMP_PREPARE_DIRECTORY := $(shell $(TEST) -d $f || $(MKDIR) $f)))
    endif
endef

# variable to store processed object files
PROC_OBJECTS=

# $(call one-compile-rule-c, object-file, source-file)
# make the compile rule for a source file written in C
define one-compile-rule-c
    # avoid duplication
    ifeq (,$(findstring $1,$(PROC_OBJECTS)))
        $(eval DEPEND := $(call source-to-depend, $2))

        $1: $2
	        @echo "- compile $$<"
	        $(QUIET) $(CC) $(CFLAGS) -M $$< -MP -MT $$@ -MF $(DEPEND)
	        $(QUIET) $(CC) $(CFLAGS) -c $$< -o $$@

        -include $(DEPEND)

        PROC_OBJECTS+=$1
    endif
endef

# $(call compile-rules, sources)
# make compile rules
define compile-rules
    $(foreach f, $(filter %.c, $1), \
        $(call one-compile-rule-c,$(call source-to-object,$f),$f))
endef

# variable to store all targets to clean all of them
PROC_TARGETS=

# $(call one-exe-rule, target, sources)
# make build rules for a executable
define one-exe-rule
    $(eval TARGET := $(addsuffix $(EXE_SUFFIX), $(addprefix $(BIN_DIR)/, $1)))

    all: $(TARGET)

    $(TARGET): $(call source-to-object, $2)
	    @echo "- link to build $(TARGET)"
	    $(QUIET) $(CC) $(LIBFLAGS) $$^ -o $$@

    $(eval $(call prepare-directories, $(call source-dir-to-temp-dir, $(dir $2))))
    $(eval $(call prepare-directories, $(addprefix $(BIN_DIR)/, $(dir $1))))

    $(eval $(call compile-rules, $2))

    PROC_TARGETS += $(TARGET)

endef

# clean target
.PHONY: clean
clean:
	@echo "- remove output directories"
	$(QUIET) $(RM) -r $(TEMP_DIR) $(BIN_DIR)

