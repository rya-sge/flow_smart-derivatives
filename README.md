# SUI BSA Hackaton

> Project made during the 2024 SUI hackaton orginsed by the [BSA](https://bsaepfl.ch)

When you want to perform an OTC trade, there is always a counterparty risk. 

What happen if one of the party does not fulfill its obligations ? 

As a result,  OTC trade uses most often central counterparty clearing house or collateral  to guarantee the transaction. 

These requirements increases the cost of transaction for OTC buyers and sellers.

A blockchain-based application improves the OTC derivatives market by removing  the need to trust counterparties. 

Smart contracts automate settlements, ensuring timely execution and reducing settlement risk. This application is focused on OTC for derivate product.

Main advantage:

![solution](./image/solution.png)

The solution implements the following American options:

- Call

A call option gives the buyer the right (not the obligation) to buy an asset represented by a coin at a set price on or before a set date.

- Put

A put option gives you the right, but not the obligation, to sell an asset represented by a coin at a specific price (known as the strike price) by a specific time

## Schema

![schema](./image/schema.png)



![SmartContractDerivative-ShareObject.drawio](./image/SmartContractDerivative-ShareObject.drawio.webp)

## Transaction

![transaction](./image/transaction.png)

## Reference

- [docs.sui.io - shared-owned](https://docs.sui.io/guides/developer/sui-101/shared-owned)
- [docs.sui.io - client-tssdk](https://docs.sui.io/guides/developer/first-app/client-tssdk)

### Understanding OTC options

- [volckeralliance.org - Clearinghouses for Over-the-Counter Derivatives](https://www.volckeralliance.org/resources/clearinghouses-over-counter-derivatives)
- [YouTube - Understanding OTC Derivatives: A Beginner's Guide](https://www.youtube.com/watch?v=iSZEtvsbCcI)
- [YouTube - Derivatives Trading Explained](https://www.youtube.com/watch?v=LQrBzl0DMBA)

### Other projects

Made with the help of:

- [github.com/bsaepfl - SUIxBSA-Hackathon-Template-2024](https://github.com/bsaepfl/SUIxBSA-Hackathon-Template-2024)
- [github.com/Krut007 - Tricount](https://github.com/Krut007/tricount/blob/master/sources/tricount.move)
- [github.com/0xresil - Escrow-Move](https://github.com/0xresil/Escrow-Move/blob/main/escrow_sui/sources/escrow.move)
- [MystenLabs/sui - escrow/sources](https://github.com/MystenLabs/sui/tree/main/examples/trading/contracts/escrow/sources)