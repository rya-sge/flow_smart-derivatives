module flow::flow_tests;
use sui::coin::{Self, Coin};
use sui::test_scenario;
use sui::balance::{Self, Balance};
use sui::sui::SUI;
use sui::clock::{Self, Clock};
const ENotImplemented: u64 = 0;
#[test]
fun test_my_first_package() {
    // pass
}
public struct TradeInfo<phantom T> has key, store{
		id: UID,
		seller: address,
		buyer: address,
		underlying: Balance<T>,
		optionsPrice: u64,
		contractType: u8,
		premiumSui: u64,
		endDate: u64,
		startDate: u64
	}

#[test, expected_failure(abort_code = ::flow::flow_tests::ENotImplemented)]
fun test_my_first_package_fail() {
    abort ENotImplemented
}
#[test_only] const ALICE: address = @0xA;
#[test_only] const BOB: address = @0xB;
#[test_only]
public struct CANDY has drop {}
#[test]
fun test_infoTrade() {
    let admin = @0xBABE;
    let mut scenario_val = test_scenario::begin(admin);
    let scenario = &mut scenario_val;

     let minted_candy_coin = coin::mint_for_testing<CANDY>(1000, test_scenario::ctx(scenario));
    //transfer::public_transfer(minted_candy_coin, offeror);
    // Create a dummy TxContext for testing
    let mut ctx = tx_context::dummy();
    let bal = minted_candy_coin.into_balance();
    let tradeInfo = TradeInfo<CANDY> {
        id: object::new(&mut ctx),
        seller: ALICE,
		buyer: BOB,
		underlying: bal,
        contractType:1,
		optionsPrice: 10,
		premiumSui: 15,
		endDate: 2290546408, //2042
		startDate: 0
    };
    transfer::public_transfer(tradeInfo, admin);
    scenario_val.end();
}
#[test]
fun test_valid_trade_creation() {
        let admin = @0xBABE;
        
        let mut scenario = test_scenario::begin(admin);

        {
            let mut clock = clock::create_for_testing(scenario.ctx());
            clock.set_for_testing(2290546408);
            clock::share_for_testing(clock);
        };

        scenario.next_tx(admin);
        {
            let clock = scenario.take_shared<Clock>();
            //   let minted_candy_coin = coin::mint_for_testing<CANDY>(1000, test_scenario::ctx(scenario));
            // Create test coin
            let minted_candy_coin = coin::mint_for_testing<CANDY>(1000, scenario.ctx());

            let startDate: u64 = 10;  // Start date of the trade
            let endDate: u64 = 20;    // End date of the trade
            let premiumSui: u64 = 1000;  // Premium to be paid in Sui
            let totalPrice: u64 = 5000;  // Total price of the trade

            flow::flow::create_trade<CANDY>(
                BOB,
                minted_candy_coin,
                premiumSui,
                totalPrice,
                false,
                startDate,
                endDate,
                &clock,
                scenario.ctx());
            test_scenario::return_shared(clock);
        };
        
        
        // Call the function
        

        // Expected results: tradeInfo should be created and transferred as a shared object.
        // Verifying shared object behavior would depend on the specific test framework.
        scenario.end();
    }


/*fun test_acceptTrade() {#[test]
        let admin = @0xBABE;
        let mut scenario_val = test_scenario::begin(admin);
        let mut ts = ts::begin(@0x0);
        let scenario = &mut scenario_val;
        let mut ctx = tx_context::dummy();
        //   let minted_candy_coin = coin::mint_for_testing<CANDY>(1000, test_scenario::ctx(scenario));
        // Create test coin
        let minted_candy_coin = coin::mint_for_testing<CANDY>(1000, test_scenario::ctx(scenario));

        let startDate: u64 = 10;  // Start date of the trade
        let endDate: u64 = 20;    // End date of the trade
        let premiumSui: u64 = 1000;  // Premium to be paid in Sui
        let totalPrice: u64 = 5000;  // Total price of the trade
        // Call the function
        ts.next_tx(ALICE);
        let tradeInfo = flow::example::createTrade<CANDY>(BOB,startDate, endDate , 
        premiumSui, minted_candy_coin, totalPrice, false, &mut ctx);
        ts.next_tx(BOB);
        flow::example::acceptTrade<CANDY>(minted_candy_coin, Coin<SUI>, &mut ctx);
        // Expected results: tradeInfo should be created and transferred as a shared object.
        // Verifying shared object behavior would depend on the specific test framework.
        scenario_val.end();
    } */


