#!/bin/bash

# Copyright 2023 VMware, Inc.  All rights reserved.

# Provided as-is, NO VMware official support.

# Maintainer:	    Vladimir Klyubin
# Org:            VMware EMEA - Telco PSO
# e-mail:         vklyubin@vmware.com

/usr/sbin/zebra -d -A 127.0.0.1 -f /etc/quagga/zebra.conf
/usr/sbin/bgpd -d -A 127.0.0.1 -f /etc/quagga/bgpd.conf
/usr/sbin/nginx -g "daemon off;"