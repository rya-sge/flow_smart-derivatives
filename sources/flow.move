// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// docs::#first
  
module flow::example {
    // use
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
     use sui::pay;
    use sui::clock::{Self, Clock};
    use std::string::{Self, String};
    use sui::balance::{Self, Balance};

    const EMismatchedSenderRecipient: u64 = 0;

//
  // Trade Status
  //
  
  const TRADE_STATUS_INITED: u64 = 0;
  const TRADE_STATUS_CREATED: u64 = 1;

// Part 1: These imports are provided by default
// use sui::object::{Self, UID};
// use sui::transfer;
// use sui::tx_context::{Self, TxContext};


// Part 3: Module initializer to be executed when this module is published


public struct CoinPayment{
    coinPaymentId: u64,
    premium: u64
}
// Part 2: struct definitions
// What is key and store ?
//
// Key which indicates that these structs are Sui objects that you can transfer between addresses. 
// The `store` ability on the structs provides the ability to appear in other struct fields and be transferred freely.
//#[allow(lint(coin_field))]
public struct TradeInfo<T> has key, store{
    id: UID,
    seller: address,
    buyer: address,
    underlying: Balance<T>,//   coinPayment: CoinPayment, 
    premiumSui:u64,
    endDate: u64,
    startDate: u64
}

    public fun createTrade<OFFERED_TOKEN:key+store>(buyer: address, 
    startDate:u64, endDate: u64, premiumSui:u64,underlying: &mut Coin<OFFERED_TOKEN>,  offered_amount: u64,ctx: &mut TxContext) {
            let sender = tx_context::sender(ctx);
            // Create a trade
            let id = object::new(ctx);
            // SPlit
            let offered_token = coin::split<OFFERED_TOKEN>(underlying, offered_amount, ctx);
            let tradeInfo = TradeInfo<OFFERED_TOKEN> {
                id: id,
                seller: sender,
                buyer: buyer,
                endDate: endDate,
                startDate:  startDate,
                premiumSui:premiumSui,
                //SOus jacent
                underlying:coin::into_balance<OFFERED_TOKEN>(offered_token)
            };
            // DTOkenTransfer?
            transfer::share_object(
                tradeInfo
            );
            //return tradeInfo;
    }

    public fun acceptTrade<OFFERED_TOKEN:key+store>(tradeInfo: &mut TradeInfo<OFFERED_TOKEN>, sui: &mut Coin<SUI>, ctx: &mut TxContext){
            let sender = tx_context::sender(ctx);
            assert!(tradeInfo.buyer == sender, EMismatchedSenderRecipient);
            // Buyer => Seller premium
            //let sui_balance = coin::into_balance(sui);
            //8let seller_balance = tradeInfo.seller.balance;
            //balance::join(seller_balance, sui_balance);
            //transfer::public_transfer(tradeInfo.buyer, tradeInfo.seller);
            pay::split_and_transfer(sui, tradeInfo.premiumSui, tradeInfo.seller, ctx);
    }
    
    public fun settleTrade<OFFERED_TOKEN:key+store>(tradeInfo: &mut TradeInfo<OFFERED_TOKEN>, coin: &mut Coin<OFFERED_TOKEN>, ctx: &mut TxContext) {
            let sender = tx_context::sender(ctx);
            // Create a trade
           // transfer::public_transfer(tradeInfo, sender);
            //pay::split_and_transfer(sui, tradeInfo.premiumSui, tradeInfo.seller, ctx);
            let offered_token_value = balance::value<OFFERED_TOKEN>(&tradeInfo.underlying);
            let offered_token = balance::split<OFFERED_TOKEN>(&mut tradeInfo.underlying, offered_token_value);
            transfer::public_transfer(coin::from_balance<OFFERED_TOKEN>(offered_token, ctx), sender);
        }
            // return tradeInfo;
    }


    


    
// docs::/#first
//coin:Coin<SUI>,