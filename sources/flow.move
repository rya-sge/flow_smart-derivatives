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
		premium: u64,
		is_forward: bool,
		begin_date: u64,
		end_date: u64,
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
		assert!(!time_expired(contract.begin_date, contract.end_date, clock));
		
		contract.buyer = newBuyer;
	}

	public fun create_trade<OFFERED_TOKEN>(
			buyer: address, 
			underlying: Coin<OFFERED_TOKEN>, 
			price: u64, 
			premium: u64, 
			is_forward: bool,
			begin_date:u64, 
			end_date: u64, 
			clock: &Clock,
			ctx: &mut TxContext) {

		assert!(!time_expired(begin_date, end_date, clock));

		
		let contract = TradeInfo<OFFERED_TOKEN> {
			id: object::new(ctx),
			seller: ctx.sender(),
			buyer: buyer,
			underlying: underlying.into_balance(),
			price: price,
			premium: premium,
			is_forward: is_forward,
			begin_date:  begin_date,
			end_date: end_date,
			accepted: false
		};

		transfer::share_object(contract);
	}

	public fun accept_trade<OFFERED_TOKEN>(
			contract: &mut TradeInfo<OFFERED_TOKEN>, 
			sui: &mut Coin<SUI>,
			clock: &Clock,
			ctx: &mut TxContext) {

		assert!(contract.buyer == ctx.sender(), EMismatchedSenderRecipient);
		assert!(!time_expired(contract.begin_date,contract.end_date, clock));

		contract.accepted = true;
		pay::split_and_transfer(sui, contract.premium, contract.seller, ctx);
	}

	public fun retrieve_underlying<OFFERED_TOKEN>(
			contract: &mut TradeInfo<OFFERED_TOKEN>, 
			coin: &mut Coin<OFFERED_TOKEN>, 
			clock: &Clock, 
			ctx: &mut TxContext): Coin<OFFERED_TOKEN> {

		let contract_expired: bool = time_expired(contract.begin_date, contract.end_date, clock);

		if (ctx.sender() == contract.seller) {
			assert!(!contract.accepted);
			assert!(contract_expired);
		} else {
			assert!(contract.accepted);
			assert!(!contract_expired);
			if (contract.is_forward) {
				assert!(!time_expired(contract.end_date - DAY_MS, contract.end_date, clock));
			};

			pay::split_and_transfer(coin, contract.price, contract.seller, ctx);
		};

		let value = contract.underlying.value();
		let balance = contract.underlying.split(value);

		return coin::from_balance(balance, ctx)
	}

	fun time_expired(begin_date: u64, end_date: u64, clock: &Clock): bool {
		let timestamp = clock.timestamp_ms();

		return timestamp >= begin_date && timestamp <= end_date
	}
}
