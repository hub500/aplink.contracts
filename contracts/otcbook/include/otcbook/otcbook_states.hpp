 #pragma once

#include <eosio/asset.hpp>
#include <eosio/privileged.hpp>
#include <eosio/singleton.hpp>
#include <eosio/system.hpp>
#include <eosio/time.hpp>

#include <deque>
#include <optional>
#include <string>
#include <map>
#include <set>
#include <type_traits>

namespace mgp {

using namespace std;
using namespace eosio;

#define SYMBOL(sym_code, precision) symbol(symbol_code(sym_code), precision)

static constexpr eosio::name active_perm{"active"_n};
static constexpr eosio::name SYS_BANK{"eosio.token"_n};

// crypto assets
static constexpr symbol   SYS_SYMBOL            = SYMBOL("MGP", 4);
static constexpr symbol   CNYD_SYMBOL           = SYMBOL("CNYD", 6);
static constexpr symbol   CNY                   = SYMBOL("CNY", 4);
static constexpr symbol   STAKE_SYMBOL          = CNYD_SYMBOL;

static constexpr uint64_t percent_boost     = 10000;
static constexpr uint64_t order_stake_pct   = 7000; // 70%
static constexpr uint64_t max_memo_size     = 1024;

// static constexpr uint64_t seconds_per_year      = 24 * 3600 * 7 * 52;
// static constexpr uint64_t seconds_per_month     = 24 * 3600 * 30;
// static constexpr uint64_t seconds_per_week      = 24 * 3600 * 7;
// static constexpr uint64_t seconds_per_day       = 24 * 3600;
// static constexpr uint64_t seconds_per_hour      = 3600;




#define OTCBOOK_TBL [[eosio::table, eosio::contract("otcbook")]]

struct [[eosio::table("global"), eosio::contract("otcbook")]] global_t {
    // asset min_buy_order_quantity;
    // asset min_sell_order_quantity;
    // asset min_pos_stake_quantity;
    uint64_t withhold_expire_sec = 600;   // the amount hold will be unfrozen upon expiry
    name transaction_fee_receiver;  // receiver account to transaction fees
    uint64_t transaction_fee_ratio = 0; // fee ratio boosted by 10000
    name admin;             // default is contract self
    name conf_contract      = "otcconf"_n;     
    name conf_table         = "global"_n;
    bool initialized        = false; 

    EOSLIB_SERIALIZE( global_t, /*(min_buy_order_quantity)(min_sell_order_quantity)*/
                                (withhold_expire_sec)(transaction_fee_receiver)
                                (transaction_fee_ratio)(admin)(conf_contract)(conf_table)
    )
};
typedef eosio::singleton< "global"_n, global_t > global_singleton;

enum class account_type_t: uint8_t {
    NONE           = 0,
    ADMIN          = 1,
    MERCHANT       = 2,    // merchant
    USER           = 3,    // user
    ARBITER        = 4
};

enum class deal_action_t: uint8_t {
    CREATE          = 1,
    MAKER_ACCEPT    = 2,
    TAKER_SEND      = 3,
    MAKER_RECEIVE   = 4,
    MAKER_SEND      = 5,
    TAKER_RECEIVE   = 6,
    CLOSE           = 7,
    ADD_MEMO        = 8,
    REVERSE         = 9
};


enum class deal_status_t: uint8_t {
    NONE = 0,
    CREATED = 1,
    MAKER_ACCEPTED,
    TAKER_SENT,
    MAKER_RECEIVED,
    MAKER_SENT,
    TAKER_RECEIVED,
    CLOSED
};

enum class order_side_t: uint8_t {
    BUY         = 1,
    SELL        = 2
};

enum  class merchant_status_t: uint8_t {
    NONE = 0,
    REGISTERED = 1,
    ENABLED = 2,
    DISABLED = 3
};

struct OTCBOOK_TBL merchant_t {
    name owner;
    asset stake_quantity = asset(0, STAKE_SYMBOL);
    set<name> accepted_payments; //accepted payments
    string email;
    string memo;
    uint8_t status;

    merchant_t() {}
    merchant_t(const name& o): owner(o) {}

    uint64_t primary_key()const { return owner.value; }
    uint64_t scope()const { return 0; }

    typedef eosio::multi_index<"merchants"_n, merchant_t> idx_t;

    EOSLIB_SERIALIZE(merchant_t,  (owner)(stake_quantity)(accepted_payments)
                                (email)(memo)(status))
};

/**
 * Generic order struct for maker(merchant)
 * when the owner decides to close it before complete fulfillment, it just get erased
 * if it is truly fulfilled, it also get deleted.
 */
struct OTCBOOK_TBL order_t {
    uint64_t id;                //PK: available_primary_key

    name owner;                 //order maker's account, merchant
    set<name> accepted_payments;
    uint8_t side;          // order side, buy or sell
    asset price;                // MGP price the buyer willing to buy, symbol CNY
    // asset price_usd;            // MGP price the buyer willing to buy, symbol USD
    asset quantity;
    asset min_accept_quantity;
    string memo;
    asset stake_quantity;
    asset frozen_quantity;
    asset fulfilled_quantity;    //support partial fulfillment
    bool closed;
    time_point_sec created_at;
    time_point_sec closed_at;

    order_t() {}
    order_t(const uint64_t& i): id(i) {}

    uint64_t primary_key() const { return id; }
    // uint64_t scope() const { return price.symbol.code().raw(); } //not in use actually

    //to sort orders by price: 1. buy order: higher first; 2. sell order: lower first
    uint128_t by_price() const {
        uint64_t option = (uint64_t)side << 56;
        uint64_t price_factor = price.amount;
        price_factor = ((order_side_t)side == order_side_t::BUY) ? std::numeric_limits<uint64_t>::max() - price_factor : price_factor;
        return (uint128_t)option << 64 | (uint128_t)price_factor; 
    } 

    //to sort by order makers account
    uint64_t by_maker() const { return owner.value; }
  
    EOSLIB_SERIALIZE(order_t,   (id)(owner)(accepted_payments)(side)(price)/*(price_usd)*/
                                (quantity)(min_accept_quantity)(memo)
                                (stake_quantity)(frozen_quantity)(fulfilled_quantity)
                                (closed)(created_at)(closed_at))
};

typedef eosio::multi_index
< "orders"_n,  order_t,
    indexed_by<"price"_n, const_mem_fun<order_t, uint128_t, &order_t::by_price> >,
    indexed_by<"maker"_n, const_mem_fun<order_t, uint64_t, &order_t::by_maker> >
> order_table_t;

struct deal_memo_t {
    name account;
    uint8_t status;
    uint8_t action;
    string memo;

    EOSLIB_SERIALIZE(deal_memo_t,    (account)(status)(action)(memo) )
};

/**
 * buy/sell deal
 *
 */
struct OTCBOOK_TBL deal_t {
    uint64_t id;                //PK: available_primary_key
    uint64_t order_id;
    asset order_price;
    asset deal_quantity;
    name order_maker; // merchant 
    name order_taker; // user

    uint8_t status;
    time_point_sec created_at;
    time_point_sec closed_at;

    uint64_t order_sn; // 订单号（前端生成）
    time_point_sec expired_at; // 订单到期时间
    time_point_sec maker_expired_at; // 卖家操作到期时间
    vector<deal_memo_t> memos;

    deal_t() {}
    deal_t(uint64_t i): id(i) {}

    uint64_t primary_key() const { return id; }
    uint64_t scope() const { return /*order_price.symbol.code().raw()*/ 0; }

    uint64_t by_order()     const { return order_id; }
    uint64_t by_maker()     const { return order_maker.value; }
    uint64_t by_taker()     const { return order_taker.value; }
    uint64_t by_ordersn()   const { return order_sn;}
    uint64_t by_expired_at() const    { return uint64_t(expired_at.sec_since_epoch()); }
    uint64_t by_maker_expired_at() const    { return uint64_t(maker_expired_at.sec_since_epoch()); }

    typedef eosio::multi_index
    <"deals"_n, deal_t,
        indexed_by<"order"_n,   const_mem_fun<deal_t, uint64_t, &deal_t::by_order> >,
        indexed_by<"maker"_n,   const_mem_fun<deal_t, uint64_t, &deal_t::by_maker> >,
        indexed_by<"taker"_n,   const_mem_fun<deal_t, uint64_t, &deal_t::by_taker> >,
        indexed_by<"ordersn"_n, const_mem_fun<deal_t, uint64_t, &deal_t::by_ordersn> >,
        indexed_by<"expiry"_n,  const_mem_fun<deal_t, uint64_t, &deal_t::by_expired_at> >
    > idx_t;

    EOSLIB_SERIALIZE(deal_t,    (id)(order_id)(order_price)(deal_quantity)
                                (order_maker)
                                (order_taker)
                                (status)(created_at)(closed_at)(order_sn)
                                (expired_at)(maker_expired_at)
                                (memos))
};

// /**
//  * 交易订单过期时间
//  *
//  */
// struct OTCBOOK_TBL deal_expiry_t{
//     uint64_t deal_id;
//     time_point_sec expired_at;

//     deal_expiry_t() {}
//     deal_expiry_t(uint64_t i): deal_id(i) {}

//     uint64_t primary_key()const { return deal_id; }
//     uint64_t scope()const { return 0; }

//     uint64_t by_expired_at() const    { return uint64_t(expired_at.sec_since_epoch()); }

//     EOSLIB_SERIALIZE(deal_expiry_t,  (deal_id)(expired_at) )
// };

// typedef eosio::multi_index
//     <"dealexpiries"_n, deal_expiry_t ,
//         indexed_by<"expiry"_n,    const_mem_fun<deal_expiry_t, uint64_t, &deal_expiry_t::by_expired_at>   >
//     > deal_expiry_tbl;

} // MGP
