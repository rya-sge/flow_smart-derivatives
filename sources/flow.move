module flow::example {
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::pay;
    use sui::clock::{Self, Clock};
    use std::string::{Self, String};
    use sui::balance::{Self, Balance};

    const EMismatchedSenderRecipient: u64 = 0;
  
	const TRADE_STATUS_INITIATRED: u64 = 0;
	const TRADE_STATUS_CREATED: u64 = 1;

	public struct CoinPayment{
		coinPaymentId: u64,
		premium: u64
	}

	public struct TradeInfo<phantom T> has key, store{
		id: UID,
		seller: address,
		buyer: address,
		underlying: Balance<T>,
		optionsPrice: u64,
		premiumSui: u64,
		endDate: u64,
		startDate: u64
	}

    public fun createTrade<OFFERED_TOKEN:key+store>(buyer: address, 
    startDate:u64, endDate: u64, premiumSui:u64, underlying: Coin<OFFERED_TOKEN>, totalPrice: u64, ctx: &mut TxContext) {
		let id = object::new(ctx);
		let sender = tx_context::sender(ctx);

		let tradeInfo = TradeInfo<OFFERED_TOKEN> {
			id: id,
			seller: sender,
			buyer: buyer,
			endDate: endDate,
			startDate:  startDate,
			premiumSui:premiumSui,
			underlying: underlying.into_balance(),
			optionsPrice: totalPrice
		};
		
		transfer::share_object(tradeInfo);
    }

    public fun acceptTrade<OFFERED_TOKEN:key+store>(tradeInfo: &mut TradeInfo<OFFERED_TOKEN>, sui: &mut Coin<SUI>, ctx: &mut TxContext){
            let sender = tx_context::sender(ctx);
            assert!(tradeInfo.buyer == sender, EMismatchedSenderRecipient);
			
            pay::split_and_transfer(sui, tradeInfo.premiumSui, tradeInfo.seller, ctx);
    }
    
	// TODO implement payment
	public fun exerciseOption<OFFERED_TOKEN:key+store>(tradeInfo: &mut TradeInfo<OFFERED_TOKEN>, coin: &mut Coin<OFFERED_TOKEN>, clock: &Clock, ctx: &mut TxContext) {
			assert!(tradeInfo.buyer == tx_context::sender(ctx), EMismatchedSenderRecipient);

			let timestamp = clock.timestamp_ms();
			assert!(timestamp >= tradeInfo.startDate && timestamp <= tradeInfo.endDate, EMismatchedSenderRecipient);

			let offered_token_value = balance::value<OFFERED_TOKEN>(&tradeInfo.underlying);
			let offered_token = balance::split<OFFERED_TOKEN>(&mut tradeInfo.underlying, offered_token_value);
			transfer::public_transfer(coin::from_balance<OFFERED_TOKEN>(offered_token, ctx), tradeInfo.buyer);
	}
}
