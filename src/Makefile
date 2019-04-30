
CFLAGS := -Wall

include make_module_c.mk

sources := main1.c test/test.c
target := main1
$(eval $(call one-exe-rule, $(target), $(sources)))

sources := main2.c test/test.c
target := main2
$(eval $(call one-exe-rule, $(target), $(sources)))

