module flow::flow {
	use sui::coin::{Self, Coin};
	use sui::sui::SUI;
	use sui::pay;
	use sui::clock::Clock;
	use sui::balance::Balance;

	const EMismatchedSenderRecipient: u64 = 0;

	const DAY_MS: u64 = 86_400_000;

	public struct TradeInfo<phantom T> has key, store{
		id: UID,
		seller: address,
		buyer: address,
		underlying: Balance<T>,
		price: u64,
		is_forward: bool,
		premium: u64,
		end_date: u64,
		start_date: u64,
		accepted: bool
	}

	public fun changeOwnership<OFFERED_TOKEN>(
			contract: &mut TradeInfo<OFFERED_TOKEN>, 
			newBuyer: address, 
			clock: &Clock, 
			ctx: &mut TxContext) {

		assert!(ctx.sender() == contract.buyer, EMismatchedSenderRecipient);
		assert!(contract.buyer != newBuyer, 0);
		assert!(contract.seller != newBuyer, 0);
		assert!(contract.end_date > clock.timestamp_ms(), 0);
		assert! (contract.start_date < clock.timestamp_ms(), 0);
		contract.buyer = newBuyer;
	}

	public fun create_trade<OFFERED_TOKEN:key+store>(
			buyer: address, 
			start_date:u64, 
			end_date: u64, 
			premium:u64, 
			underlying: Coin<OFFERED_TOKEN>, 
			price: u64, 
			is_forward: bool, 
			ctx: &mut TxContext) {

		let id = object::new(ctx);
		let sender = ctx.sender();
		
		transfer::share_object(TradeInfo<OFFERED_TOKEN> {
			id: id,
			seller: sender,
			buyer: buyer,
			end_date: end_date,
			start_date:  start_date,
			premium: premium,
			is_forward: is_forward,
			underlying: underlying.into_balance(),
			price: price,
			accepted: false
		});
	}

	public fun accept_trade<OFFERED_TOKEN:key+store>(
			contract: &mut TradeInfo<OFFERED_TOKEN>, 
			sui: &mut Coin<SUI>, 
			ctx: &mut TxContext) {

		let sender = ctx.sender();
		assert!(contract.buyer == sender, EMismatchedSenderRecipient);

		contract.accepted = true;
		pay::split_and_transfer(sui, contract.premium, contract.seller, ctx);
	}

	public fun retrieve_underlying<OFFERED_TOKEN:key+store>(
			contract: &mut TradeInfo<OFFERED_TOKEN>, 
			coin: &mut Coin<OFFERED_TOKEN>, 
			clock: &Clock, 
			ctx: &mut TxContext): Coin<OFFERED_TOKEN> {
				
		let timestamp = clock.timestamp_ms();
		let contract_expired: bool = timestamp >= contract.start_date && timestamp <= contract.end_date;

		if (ctx.sender() == contract.seller) {
			assert!(!contract.accepted);
			assert!(contract_expired);
		} else {
			assert!(contract.accepted);
			assert!(!contract_expired);
			if (contract.is_forward) {
				assert!(timestamp >= contract.end_date - DAY_MS);
			};

			pay::split_and_transfer(coin, contract.price, contract.seller, ctx);
		};

		let value = contract.underlying.value();
		let balance = contract.underlying.split(value);

		return coin::from_balance(balance, ctx)
	}
}
