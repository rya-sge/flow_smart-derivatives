module flow::derivative {
	use sui::balance;
	use sui::balance::Balance;
	use sui::coin;
	use sui::coin::Coin;
	use sui::sui::SUI;

	public struct Option has key, store {
		id: UID,
		seller: address,
		buyer: address,
		//underlying: UID, // TODO define
		quantity: u64,
		unit_price: u64,
		expiration_date: u64,
		premium: u64,
		accepted: bool,
		payment: Balance<SUI>
	}

	public fun init_call(receiver: address, quantity: u64,	unit_price: u64, expiration_date: u64, premium: u64, ctx: &mut TxContext) {
		sui::transfer::share_object(Option {
			id: object::new(ctx),
			seller: ctx.sender(),
			buyer: receiver,
			quantity: quantity,
			unit_price: unit_price,
			expiration_date: expiration_date,
			premium: premium,
			accepted: false,
			payment: balance::zero()
		});
	}

	public fun accept_contract(contract: &mut Option, payment: &mut Coin<SUI>) {
		let mut balance = payment.balance_mut();
		assert!(balance.value() >= contract.premium, 0);

		contract.accepted = true;
		contract.payment.join(balance.split(contract.premium));
	}
}
