module flow::derivative {

	public struct Option has key, store {
		id: UID,
		seller: address,
		buyer: address,
		//underlying: UID, // TODO define
		quantity: u64,
		unit_price: u64,
		expiration_date: u64,
		premium: u64
	}

	public fun init_call(ctx: &mut TxContext, receiver: address, quantity: u64,	unit_price: u64, expiration_date: u64, premium: u64): Option {
		Option {
			id: object::new(ctx),
			seller: ctx.sender(),
			buyer: receiver,
			quantity: quantity,
			unit_price: unit_price,
			expiration_date: expiration_date,
			premium: premium
		}
	}

}
