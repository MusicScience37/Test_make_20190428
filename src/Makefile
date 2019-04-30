
CFLAGS := -Wall

include make_module_c.mk

$(eval $(call one-exe-rule, \
    main1, \
        main1.c \
        test/test.c))

$(eval $(call one-exe-rule, \
    main2, \
        main2.c \
        test/test.c))

