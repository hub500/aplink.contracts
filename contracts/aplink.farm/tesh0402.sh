
# farm test
amcli get table aplink.farm aplink.farm global

amcli push action aplink.farm init '["aplink.land","aplink.jam",11,11]' -p aplink.farm

amcli get table aplink.farm aplink.farm globalext

amcli push action aplink.farm setinit '[15,600,3600]' -p aplink.farm


amcli get table aplink.farm aplink.farm leases

amcli push action aplink.farm lease '["aplink.land","this is #4","imager#4","banner#4"]' -p aplink.land

amcli push action aplink.farm setlease '[12,"imager#4-1","banner#4-1"]' -p aplink.land

amcli push action aplink.farm settenant '[12,"aplink.land"]' -p aplink.land


amcli push action aplink.token transfer '["aplink","aplink.land","100.0000 APL",""]' -p aplink@active
amcli push action aplink.token transfer '["aplink.land","aplink.farm","100.0000 APL","14"]' -p aplink.land@active

amcli push action aplink.farm setstatus '[12,"inactive"]' -p aplink.land
amcli push action aplink.farm setstatus '[12,"active"]' -p aplink.land


amcli push action aplink.farm allot '[14,"picku1","1.0000 APL","first"]' -p aplink.land
amcli push action aplink.farm allot '[14,"picku1","1.0000 APL","first"]' -p aplink.land
amcli push action aplink.farm allot '[12,"picku1","1.0000 APL","first"]' -p aplink.land

amcli push action aplink.farm pick '["picku1",[15]]' -p picku1
amcli push action aplink.farm pick '["amax",[13]]' -p amax
amcli push action aplink.farm pick '["picku1u1u1",[14]]' -p picku1u1u1
amcli push action aplink.farm pick '["picku1u1",[14]]' -p picku1u1

amcli push action aplink.token setacctperms '["aplink","aplink.land","4,APL",true,true]' -p aplink
amcli push action aplink.token setacctperms '["aplink","aplink.jam","4,APL",true,true]' -p aplink
amcli push action aplink.farm reclaimlease '["aplink.land",12,"reclaim"]' -p aplink.land




# leaselist

amcli push action aplink.farm leaselist '["aplink.land","leaselist is #6","imager#6","banner#6","desc#6 cn","desc#6 en"]' -p aplink.land

amcli push action aplink.token transfer '["aplink","aplink.land","100.0000 APL",""]' -p aplink@active
amcli push action aplink.token transfer '["aplink.land","aplink.farm","100.0000 APL","13"]' -p aplink.land@active

amcli push action aplink.farm setleaselist '[13,"aplink.land","leaselist is #66","imager#66","banner#66","desc#66 cn","desc#66 en"]' -p aplink.land



amcli push action aplink.farm setstatus '[13,"inactive"]' -p aplink.land
amcli push action aplink.farm setstatus '[13,"active"]' -p aplink.land


amcli push action aplink.farm allot '[13,"picku1","1.0000 APL","first"]' -p aplink.land
amcli push action aplink.farm allot '[13,"picku1","1.0000 APL","first"]' -p aplink.land
amcli push action aplink.farm allot '[13,"picku1","1.0000 APL","first"]' -p aplink.land

amcli push action aplink.farm pick '["picku1",[20]]' -p picku1
amcli push action aplink.farm pick '["amax",[18]]' -p amax
amcli push action aplink.farm pick '["picku1u1u1",[21]]' -p picku1u1u1
amcli push action aplink.farm pick '["picku1u1",[21]]' -p picku1u1


amcli push action aplink.farm reclaimlist '["aplink.land",13,"reclaim"]' -p aplink.land

amcli push action aplink.farm reclaimallot '["aplink.land",23,"reclaim"]' -p aplink.land
amcli push action aplink.farm reclaimallot '["aplink.land",27,"reclaim"]' -p aplink.land



amcli push action aplink.farm clearleases '[]' -p aplink.land


