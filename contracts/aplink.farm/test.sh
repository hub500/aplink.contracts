
# amnod

docker run --volume=/Users/zhuxh/AmaxHub/amaxdevnet/eosio:/root/eosio --volume=/Users/zhuxh/AmaxHub/amaxdevnet/amax-wallet:/root/amax-wallet --volume=/Users/zhuxh/AmaxHub/amaxdevnet/workspace:/root/workspace -p 8888:8888 -p 9876:9876 -d amaxdevnet:0.0.1

# default
amcli wallet create --to-console | tail -n 1 | sed 's/"//g' >/password
amcli wallet import --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

# amax
amcli wallet create -n amax --to-console | tail -n 1 | sed 's/"//g' >/password
amcli wallet import -n amax --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3


# aplink.contracts
git clone https://github.com/hub500/aplink.contracts
cd aplink.contracts
git checkout -b dev
git pull origin dev


# aplink.token
amcli create account amax aplinknewbie AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active
amcli create account amax aplink.token AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active
amcli create account amax aplink AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active

cd /root/workspace/aplink.contracts/contracts/aplink.token
mkdir build
cd build
mkdir aplink.token
amax-cpp -abigen ../src/aplink.token.cpp -o ./aplink.token/aplink.token.wasm -I ../include/

amcli set contract aplink.token ./aplink.token -p aplink.token@active

amcli push action aplink.token create '["aplink","1000000000.0000 APL"]' -p aplink.token@active
amcli push action aplink.token issue '["aplink","1000000000.0000 APL","APL issue"]' -p aplink@active

amcli push action aplink.token setacctperms '["aplink","aplink","4,APL",true,true]' -p aplink@active
amcli push action aplink.token transfer '["aplink","amax","10.0000 APL",""]' -p aplink@active


# aplink.farm
amcli create account amax aplink.farm AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active

amcli create account amax aplink.land AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active
amcli create account amax aplink.jam AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active

cd /root/workspace/aplink.contracts
bash ./build.sh
cd /root/workspace/aplink.contracts/build/contracts
amcli set contract aplink.farm ./aplink.farm -p aplink.farm


# farm test
amcli get table aplink.farm aplink.farm global

amcli push action aplink.farm init '["aplink.land","aplink.jam",10,10]' -p aplink.farm

amcli get table aplink.farm aplink.farm global

amcli push action aplink.farm lease '["aplink.land","this is one","imager","banner"]' -p aplink.land
amcli push action aplink.farm lease '["aplink.land","this is two","imager22","banner22"]' -p aplink.land
amcli push action aplink.farm lease '["aplink.land","this is three","imager33","banner33"]' -p aplink.land

amcli push action aplink.farm leaselist '["aplink.land","list is one","imager11","banner11","desc cn","desc en"]' -p aplink.land
amcli push action aplink.farm leaselist '["aplink.land","list is two","imager22","banner22","desc cn","desc en"]' -p aplink.land

amcli push action aplink.farm setleaselist '[5,"aplink.land","title55-5","imager22-55-5","banner22-55-5","desc cn-55-5","desc en-55-5"]' -p aplink.land

amcli push action aplink.farm clearleases '[]' -p aplink.land



amcli get table aplink.farm aplink.farm leases

amcli push action aplink.farm setlease '[2,"imager2","banner2"]' -p aplink.land

amcli get table aplink.farm aplink.farm leases


# farm test upgrade

amcli push action aplink.farm setinit '[20,600,3600]' -p aplink.farm

amcli get table aplink.farm aplink.farm globalext

amcli push action aplink.farm setleaselang '[2,"desc_cn111","desc_en222"]' -p aplink.land

amcli get table aplink.farm aplink.farm leaselang

# allot test
amcli get table aplink.farm aplink.farm allots

# ontransfer(const name& from, const name& to, const asset& quantity, const string& memo)
amcli push action aplink.token transfer '["aplink","aplink.land","100.0000 APL",""]' -p aplink@active

amcli push action aplink.token setacctperms '["aplink","aplink.land","4,APL",true,true]' -p aplink



# allot(const uint64_t& lease_id, const name& farmer, const asset& quantity, const string& memo)
amcli push action aplink.farm allot '[2,"picku1","1.0000 APL","first"]' -p aplink.land


amcli set account permission aplink.farm active --add-code aplink.farm -p aplink.farm@owner
amcli push action aplink.token setacctperms '["aplink","aplink.farm","4,APL",true,true]' -p aplink

# pick(const name& farmer, const vector<uint64_t>& allot_ids);
amcli push action aplink.farm pick '["picku1",[4]]' -p amax

# amcli push action $ptoken transfer '["user1","'$seller'",[[200,[1999,0]]],"add:1"]' -p user1


amcli create account amax amaxu1 AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax@active
amcli push action aplink.token transfer '["aplink","amaxu1","1.0000 APL",""]' -p aplink@active


amcli push action aplink.farm pick '["amaxu1",[3]]' -p amaxu1
amcli push action aplink.token setacctperms '["aplink","amaxu1","4,APL",true,true]' -p aplink
amcli push action aplink.token setacctperms '["aplink","amaxu1u12","4,APL",true,true]' -p aplink


amcli create account amaxu1 amaxu1u12 AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amaxu1@active
amcli push action aplink.token transfer '["aplink","amaxu1u12","1.0000 APL",""]' -p aplink@active
amcli push action aplink.token setacctperms '["aplink","amaxu1","4,APL",true,true]' -p aplink

amcli push action aplink.farm pick '["amaxu1u12",[6]]' -p amaxu1u12

amcli push action aplink.farm pick '["amaxu1",[6]]' -p amaxu1

amcli push action aplink.farm pick '["amax",[8]]' -p amax



amcli create account amax picku1 AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p amax
amcli push action aplink.token transfer '["aplink","picku1","1.0000 APL",""]' -p aplink
amcli push action aplink.token setacctperms '["aplink","picku1","4,APL",true,true]' -p aplink

amcli create account picku1 picku1u1 AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p picku1
amcli push action aplink.token transfer '["aplink","picku1u1","1.0000 APL",""]' -p aplink
amcli push action aplink.token setacctperms '["aplink","picku1u1","4,APL",true,true]' -p aplink

amcli create account picku1u1 picku1u1u1 AM6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p picku1u1
amcli push action aplink.token transfer '["aplink","picku1u1u1","1.0000 APL",""]' -p aplink
amcli push action aplink.token setacctperms '["aplink","picku1u1u1","4,APL",true,true]' -p aplink


amcli push action aplink.farm pick '["amax",[9]]' -p amax
amcli push action aplink.farm pick '["picku1",[4]]' -p picku1

amcli push action aplink.farm pick '["picku1u1u1",[9]]' -p picku1u1u1
amcli push action aplink.farm pick '["picku1u1",[8]]' -p picku1u1

