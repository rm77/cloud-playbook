ovn-nbctl ls-add sw0
ovn-nbctl lsp-add sw0 sw0-port1
ovn-nbctl lsp-set-addresses sw0-port1 "00:00:01:00:00:03 192.168.199.3"

ovn-nbctl ls-add sw1
ovn-nbctl lsp-add sw1 sw1-port1
ovn-nbctl lsp-set-addresses sw1-port1 "00:00:02:00:00:03 192.168.198.3"

ovn-nbctl lr-add lr0
# Connect sw0 to lr0
ovn-nbctl lrp-add lr0 lr0-sw0 00:00:00:00:ff:01 192.168.199.1/24
ovn-nbctl lsp-add sw0 sw0-lr0
ovn-nbctl lsp-set-type sw0-lr0 router
ovn-nbctl lsp-set-addresses sw0-lr0 router
ovn-nbctl lsp-set-options sw0-lr0 router-port=lr0-sw0

# Connect sw1 to lr0
ovn-nbctl lrp-add lr0 lr0-sw1 00:00:00:00:ff:02 192.168.198.1/24
ovn-nbctl lsp-add sw1 sw1-lr0
ovn-nbctl lsp-set-type sw1-lr0 router
ovn-nbctl lsp-set-addresses sw1-lr0 router
ovn-nbctl lsp-set-options sw1-lr0 router-port=lr0-sw1
