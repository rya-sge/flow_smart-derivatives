module flow::example {
	use sui::coin::{Self, Coin};
	use sui::sui::SUI;
	use sui::pay;
	use sui::clock::Clock;
	use sui::balance::Balance;

	const EMismatchedSenderRecipient: u64 = 0;

	public struct TradeInfo<phantom T> has key, store{
		id: UID,
		seller: address,
		buyer: address,
		underlying: Balance<T>,
		optionsPrice: u64,
		contractType: u8,
		premiumSui: u64,
		endDate: u64,
		startDate: u64,
		accepted: bool
	}

	public fun changeOwnership<OFFERED_TOKEN>(tradeInfo: &mut TradeInfo<OFFERED_TOKEN>, newBuyer: address, clock: &Clock, ctx: &mut TxContext){
		assert!(ctx.sender() == tradeInfo.buyer, EMismatchedSenderRecipient);
		assert!(tradeInfo.buyer != newBuyer, 0);
		assert!(tradeInfo.seller != newBuyer, 0);
		assert!(tradeInfo.endDate > clock.timestamp_ms(), 0);
		assert! (tradeInfo.startDate < clock.timestamp_ms(), 0);
		tradeInfo.buyer = newBuyer;
	}

	public fun createTrade<OFFERED_TOKEN:key+store>(buyer: address, 
	startDate:u64, endDate: u64, premiumSui:u64, contractType: u8, underlying: Coin<OFFERED_TOKEN>, totalPrice: u64, ctx: &mut TxContext) {
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
			contractType: contractType,
			optionsPrice: totalPrice,
			accepted: false
		};
		
		transfer::share_object(tradeInfo);
	}

	public fun acceptTrade<OFFERED_TOKEN:key+store>(tradeInfo: &mut TradeInfo<OFFERED_TOKEN>, sui: &mut Coin<SUI>, ctx: &mut TxContext){
		let sender = ctx.sender();
		assert!(tradeInfo.buyer == sender, EMismatchedSenderRecipient);

		tradeInfo.accepted = true;
		pay::split_and_transfer(sui, tradeInfo.premiumSui, tradeInfo.seller, ctx);
	}

	public fun retrieve_underlying_2<OFFERED_TOKEN:key+store>(contract: &mut TradeInfo<OFFERED_TOKEN>, coin: &mut Coin<OFFERED_TOKEN>, clock: &Clock, ctx: &mut TxContext): Coin<OFFERED_TOKEN> {
		let timestamp = clock.timestamp_ms();
		let contract_expired: bool = timestamp >= contract.startDate && timestamp <= contract.endDate;

		if (ctx.sender() == contract.seller) {
			assert!(!contract.accepted);
			assert!(contract_expired);
		} else {
			assert!(contract.accepted);
			assert!(!contract_expired);

			pay::split_and_transfer(coin, contract.optionsPrice, contract.seller, ctx);
		};

		let value = contract.underlying.value();
		let balance = contract.underlying.split(value);

		return coin::from_balance(balance, ctx)
	}
}
