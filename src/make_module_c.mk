
OBJ_PREFIX := .o
TEST := test
MKDIR := mkdir -p

TEMP_DIR := ../temp

# Default target is all.
.PHONY: all
all:

# $(call source-dir-to-binary-dir, directory-list)
source-dir-to-binary-dir = $(addprefix $(TEMP_DIR)/,$1)

# $(call source-to-object, source-file-list)
source-to-object = $(call source-dir-to-binary-dir, \
$(subst .c,$(OBJ_PREFIX),$(filter %.c,$1)))

# $(call one-compile-rule, object-file, source-file)
define one-compile-rule_c
$1: $2
	@echo "compile $$<"
	@$(CC) $(CFLAGS) -M $$< -MF $(subst $(OBJ_PREFIX),.d,$$@) -MP -MT $$@
	@$(CC) $(CFLAGS) -c $$< -o $$@

endef

# $(compile-rules)
define compile-rules
$(foreach f, $(filter %.c, $(sources)), \
$(call one-compile-rule_c,$(call source-to-object,$f),$f))

ifneq ($(MAKECMDGOALS),clean)
-include $(subst $(OBJ_PREFIX),.d,$(call source-to-object,$(sources)))
endif

endef

create-temp-directories :=                                                   \
	$(shell for f in $(call source-dir-to-binary-dir,$(source_directories)); \
		do                                                                   \
			$(TEST) -d $$f || $(MKDIR) $$f;                                  \
		done)                                                                \

# $(one-exe-rule)
define one-exe-rule
all: $(target)

$(target): $(call source-to-object, $(sources))
	@echo "link to $$@"
	@$(CC) $(LIBFLAGS) $$^ -o $$@

$(eval $(compile-rules))

endef

.PHONY: clean
clean:
	@echo "remove targets and temp directory"
	@$(RM) -r $(TEMP_DIR)
	@$(RM) $(target)
