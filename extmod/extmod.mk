# This makefile fragment provides rules to build 3rd-party components for extmod modules

# this sets the config file for FatFs
CFLAGS_MOD += -DFFCONF_H=\"lib/oofatfs/ffconf.h\"

################################################################################
# ussl

ifeq ($(MICROPY_PY_USSL),1)
CFLAGS_MOD += -DMICROPY_PY_USSL=1
ifeq ($(MICROPY_SSL_AXTLS),1)
CFLAGS_MOD += -DMICROPY_SSL_AXTLS=1 -I$(TOP)/lib/axtls/ssl -I$(TOP)/lib/axtls/crypto -I$(TOP)/extmod/axtls-include
AXTLS_DIR = lib/axtls
$(BUILD)/$(AXTLS_DIR)/%.o: CFLAGS += -Wno-all -Wno-unused-parameter -Wno-uninitialized -Wno-sign-compare -Wno-old-style-definition $(AXTLS_DEFS_EXTRA)
SRC_MOD += $(addprefix $(AXTLS_DIR)/,\
	ssl/asn1.c \
	ssl/loader.c \
	ssl/tls1.c \
	ssl/tls1_svr.c \
	ssl/tls1_clnt.c \
	ssl/x509.c \
	crypto/aes.c \
	crypto/bigint.c \
	crypto/crypto_misc.c \
	crypto/hmac.c \
	crypto/md5.c \
	crypto/rsa.c \
	crypto/sha1.c \
	)
else ifeq ($(MICROPY_SSL_MBEDTLS),1)
# Can be overridden by ports which have "builtin" mbedTLS
MICROPY_SSL_MBEDTLS_INCLUDE ?= $(TOP)/lib/mbedtls/include
CFLAGS_MOD += -DMICROPY_SSL_MBEDTLS=1 -I$(MICROPY_SSL_MBEDTLS_INCLUDE)
LDFLAGS_MOD += -L$(TOP)/lib/mbedtls/library -lmbedx509 -lmbedtls -lmbedcrypto
endif
endif

################################################################################
# lwip

ifeq ($(MICROPY_PY_LWIP),1)
# A port should add an include path where lwipopts.h can be found (eg extmod/lwip-include)
LWIP_DIR = lib/lwip/src
INC += -I$(TOP)/$(LWIP_DIR)/include
CFLAGS_MOD += -DMICROPY_PY_LWIP=1
$(BUILD)/$(LWIP_DIR)/core/ipv4/dhcp.o: CFLAGS_MOD += -Wno-address
SRC_MOD += extmod/modlwip.c lib/netutils/netutils.c
SRC_MOD += $(addprefix $(LWIP_DIR)/,\
	core/def.c \
	core/dns.c \
	core/inet_chksum.c \
	core/init.c \
	core/ip.c \
	core/mem.c \
	core/memp.c \
	core/netif.c \
	core/pbuf.c \
	core/raw.c \
	core/stats.c \
	core/sys.c \
	core/tcp.c \
	core/tcp_in.c \
	core/tcp_out.c \
	core/timeouts.c \
	core/udp.c \
	core/ipv4/autoip.c \
	core/ipv4/dhcp.c \
	core/ipv4/etharp.c \
	core/ipv4/icmp.c \
	core/ipv4/igmp.c \
	core/ipv4/ip4_addr.c \
	core/ipv4/ip4.c \
	core/ipv4/ip4_frag.c \
	core/ipv6/dhcp6.c \
	core/ipv6/ethip6.c \
	core/ipv6/icmp6.c \
	core/ipv6/inet6.c \
	core/ipv6/ip6_addr.c \
	core/ipv6/ip6.c \
	core/ipv6/ip6_frag.c \
	core/ipv6/mld6.c \
	core/ipv6/nd6.c \
	netif/ethernet.c \
	)
ifeq ($(MICROPY_PY_LWIP_SLIP),1)
CFLAGS_MOD += -DMICROPY_PY_LWIP_SLIP=1
SRC_MOD += $(LWIP_DIR)/netif/slipif.c
endif
endif

################################################################################
# btree

ifeq ($(MICROPY_PY_BTREE),1)
BTREE_DIR = lib/berkeley-db-1.xx
BTREE_DEFS = -D__DBINTERFACE_PRIVATE=1 -Dmpool_error=printf -Dabort=abort_ "-Dvirt_fd_t=void*" $(BTREE_DEFS_EXTRA)
INC += -I$(TOP)/$(BTREE_DIR)/PORT/include
SRC_MOD += extmod/modbtree.c
SRC_MOD += $(addprefix $(BTREE_DIR)/,\
	btree/bt_close.c \
	btree/bt_conv.c \
	btree/bt_debug.c \
	btree/bt_delete.c \
	btree/bt_get.c \
	btree/bt_open.c \
	btree/bt_overflow.c \
	btree/bt_page.c \
	btree/bt_put.c \
	btree/bt_search.c \
	btree/bt_seq.c \
	btree/bt_split.c \
	btree/bt_utils.c \
	mpool/mpool.c \
	)
CFLAGS_MOD += -DMICROPY_PY_BTREE=1
# we need to suppress certain warnings to get berkeley-db to compile cleanly
# and we have separate BTREE_DEFS so the definitions don't interfere with other source code
$(BUILD)/$(BTREE_DIR)/%.o: CFLAGS += -Wno-old-style-definition -Wno-sign-compare -Wno-unused-parameter $(BTREE_DEFS)
$(BUILD)/extmod/modbtree.o: CFLAGS += $(BTREE_DEFS)
endif
