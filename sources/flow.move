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
		let sender = ctx.sender();

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
            let sender = ctx.sender();
            assert!(tradeInfo.buyer == sender, EMismatchedSenderRecipient);
			
            pay::split_and_transfer(sui, tradeInfo.premiumSui, tradeInfo.seller, ctx);
    }
    
	// TODO implement payment
	public fun exerciseOption<OFFERED_TOKEN:key+store>(tradeInfo: &mut TradeInfo<OFFERED_TOKEN>, coin: Coin<OFFERED_TOKEN>, clock: &Clock, ctx: &mut TxContext): Coin<OFFERED_TOKEN> {
			assert!(tradeInfo.buyer == ctx.sender(), EMismatchedSenderRecipient);

			let timestamp = clock.timestamp_ms();
			assert!(timestamp >= tradeInfo.startDate && timestamp <= tradeInfo.endDate, EMismatchedSenderRecipient);

			// Void the token inside the tradeInfo
			let delivery_balance = tradeInfo.underlying.split(tradeInfo.underlying.value());
			
			return coin::from_balance<OFFERED_TOKEN>(delivery_balance, ctx)
	}
}
