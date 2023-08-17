## run following commands on vyos vm.

configure

set nat source rule 1 description "allow nat outbound"
set nat source rule 1 outbound-interface eth0
set nat source rule 1 translation address masquerade

show nat

commit
save



