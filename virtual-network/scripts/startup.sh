ovsdir=/var/run/openvswitch
ovsschema=/usr/share/openvswitch/vswitch.ovsschema
ovsdbsock=$ovsdir/db.sock
ovsconfdb=$ovsdir/conf.db
ovspid=$ovsdir/ovs.pid
ovslog=$ovsdir/ovs.log


OVS_RUNDIR=$ovsdir; export OVS_RUNDIR
OVS_LOGDIR=$ovsdir; export OVS_LOGDIR
OVS_DBDIR=$ovsdir; export OVS_DBDIR
OVS_SYSCONFDIR=$ovsdir; export OVS_SYSCONFDIR

#touch "$ovsdir"/.conf.db.~lock~
ovsdb-tool create $ovsconfdb $ovsschema
ovsdb-server --detach --no-chdir --pidfile=$ovspid --overwrite-pidfile -vconsole:off --log-file=$ovslog -vsyslog:off \
	--remote=punix:$ovsdbsock \
	--remote=db:Open_vSwitch,Open_vSwitch,manager_options 

ovs-vsctl --db=unix:$ovsdbsock --no-wait -- init
ovs-vswitchd --detach --no-chdir --pidfile -vconsole:off --log-file -vsyslog:off 


ovndir=/var/run/ovn
ovnnbdb=$ovndir/ovnnb_db.db
ovnnbsock=$ovndir/ovnnb_db.sock
ovnnbschema=/usr/share/ovn/ovn-nb.ovsschema
ovnnblog=$ovndir/ovn_nb.log
ovnnbpid=$ovndir/ovn_nb.pid
OVN_NB_DB=unix:$ovnnbdb
export OVN_NB_DB
ovsdb-tool create $ovnnbdb $ovnnbschema
ovsdb-server $ovnnbdb --detach --no-chdir --pidfile=$ovnnbpid --overwrite-pidfile -vconsole:off --log-file=$ovnnblog \
	--remote=punix:$ovnnbsock \
	--remote=db:OVN_Northbound,NB_Global,connections

ovnsbdb=$ovndir/ovnsb_db.db
ovnsbsock=$ovndir/ovnsb_db.sock
ovnsbschema=/usr/share/ovn/ovn-sb.ovsschema
ovnsblog=$ovndir/ovn_sb.log
ovnsbpid=$ovndir/ovn_sb.pid
OVN_SB_DB=unix:$ovnsbdb
export OVN_SB_DB
ovsdb-tool create $ovnsbdb $ovnsbschema
ovsdb-server $ovnsbdb --detach --no-chdir --pidfile=$ovnsbpid --overwrite-pidfile -vconsole:off --log-file=$ovnsblog \
	--remote=punix:$ovnsbsock \
	--remote=db:OVN_Southbound,SB_Global,connections


ovn-nbctl init
ovn-sbctl init





ovnnorthpid=$ovndir/north.pid
ovnnorthlog=$ovndir/north.log
ovn-northd --detach --no-chdir --pidfile=$ovnnorthpid --overwrite-pidfile \
	--log-file=$ovnnorthlog \
	--ovnnb-db=$OVN_NB_DB  \
	--ovnsb-db=$OVN_SB_DB

#ovn-controller --detach  --no-chdir --pidfile unix:$dbsock


