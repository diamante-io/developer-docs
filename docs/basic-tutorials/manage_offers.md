# Manage Offers

Manage offers operations allow you to offer to buy or sell a specific amount of an asset at a specific exchange rate for a different asset. For example, sell 14 of asset A for 64 of asset B.

Diamante has three operations that manage these exchange offers:

- Manage buy offer
- Manage sell offer
- Create passive sell offer

In this section, we are going to open a buy or sell offer using a ManageBuyOffer, ManageSellOffer, or CreatePassiveSellOffer operation.

Let's walk through the three manage offer operations as we build our transaction

1. We'll start, as always, with our SDK and helper utilities.

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Keypair,
  Aurora,
  TransactionBuilder,
  Networks,
  Operation,
  Asset,
  BASE_FEE,
} = require("diamnet-sdk");
```

#### **Go**

```go
import (
	"fmt"

	"github.com/diamcircle/go/clients/auroraclient"
	"github.com/diamcircle/go/keypair"
	"github.com/diamcircle/go/network"
	"github.com/diamcircle/go/txnbuild"
)
```

<!-- tabs:end -->

2. We only need the keypair for our account for this, and it will need to be funded. We'll also need our server and account to build and submit the transaction later on.

<!-- tabs:start -->

#### **Javascript**

```js
const keypair = Keypair.fromSecret(
  "SCKY763IROKEGHYFEWNCO6MCVWJN7L6OOGKMNEFHRB7VTLVC36LWI7ML"
);

const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");
const questAccount = await server.loadAccount(keypair.publicKey());
```

#### **Go**

```go
keypair, err := keypair.ParseFull("SCKY763IROKEGHYFEWNCO6MCVWJN7L6OOGKMNEFHRB7VTLVC36LWI7ML")
if err != nil {
    log.Fatalf("Failed to parse keypair: %v", err)
}

client := auroraclient.DefaultTestNetClient
questAccountRequest := auroraclient.AccountRequest{AccountID: keypair.Address()}
questAccount, err := client.AccountDetail(questAccountRequest)
if err != nil {
    log.Fatalf("Failed to load account: %v", err)
}
```

<!-- tabs:end -->

3. We'll need an asset to use as our counter-asset when we make our offers. Below, I'm setting up the asset for USDC, but you can use any other asset on the testnet (or even create your own!)

<!-- tabs:start -->

#### **Javascript**

```js
const usdcAsset = new Asset(
  "USDC",
  "GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5"
);
```

#### **Go**

```go
usdcAsset, _ := txnbuild.CreditAsset{
	Code:   "USDC",
	Issuer: "GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5",
}.ToChangeTrustAsset()
```

<!-- tabs:end -->

4. We'll begin setting up our transaction, which looks pretty typical. We will also need to create a trustline to our non-native asset before we can create any exchange offers.

<!-- tabs:start -->

#### **Javascript**

```js
const transaction = new TransactionBuilder(questAccount, {
  fee: BASE_FEE,
  networkPassphrase: "Diamante Testnet 2024",
}).addOperation(
  Operation.changeTrust({
    asset: usdcAsset,
  })
);
```

#### **Go**

```go
tx, err := txnbuild.NewTransaction(
	txnbuild.TransactionParams{
		SourceAccount:        &questAccount,
		BaseFee:              txnbuild.MinBaseFee,
		IncrementSequenceNum: true,
		Operations: []txnbuild.Operation{
			&txnbuild.ChangeTrust{
				Line:  usdcAsset.MustToChangeTrustAsset(),
				Limit: "1000000",
			},
		},
		Timebounds: txnbuild.NewInfiniteTimeout(),
	},
)
if err != nil {
	log.Fatalf("Failed to build transaction: %v", err)
}

```

<!-- tabs:end -->

## Manage Buy Offer

5. Now, we are ready to add our buy and/or sell operations. Here's where we can go a bit more in-depth. Every offer is technically both a buy and sell offer. Selling 100 DIAM for 10 USD is identical to buying 10 USD for 100 DIAM. The difference is primarily syntactical to make it easier to reason about the creation of offers.

We'll begin with a manageBuyOffer operation. The available options for this operation are:

- **selling**: The asset you're offering to give in the exchange (native DIAM in the example below)
- **buying**: The asset you're seeking to receive in the exchange (USDC in the example below)
- **buyAmount**: The amount of the Buying asset you must receive for this offer to be taken
- **price**: This one's a little more complicated. Divide the amount you're selling by the amount you're buying. For example, if you want to buy 100 USD for 1,000 DIAM, your price would be 1000/100=10. The reason this can be tricky is that the result (10) isn't necessarily the amount of either the selling or buying asset, it's the price point for the counter asset of the offer.
- **offerId**: (optional) Set to 0 to create a new offer. To update or delete an existing offer, use the offer ID here. Defaults to '0'.
- **source**: (optional) The account that gives the selling asset and receives the buying asset in this offer. Defaults to transaction source.

<!-- tabs:start -->

#### **Javascript**

```js
const transaction = new TransactionBuilder(...)
  .addOperation(Operation.manageBuyOffer({
    selling: Asset.native(),
    buying: usdcAsset,
    buyAmount: '100',
    price: '10',
    offerId: '0',
    source: keypair.publicKey()
  }))
```

#### **Go**

```go
tx, err = txnbuild.NewTransaction(
    txnbuild.TransactionParams{
        SourceAccount:        &questAccount,
        BaseFee:              txnbuild.MinBaseFee,
        IncrementSequenceNum: true,
        Operations: []txnbuild.Operation{
            &txnbuild.ManageBuyOffer{
                Selling:   txnbuild.NativeAsset{},
                Buying:    usdcAsset,
                BuyAmount: "100",
                Price:     "10",
                OfferID:   0,
                SourceAccount: keypair.Address(),
            },
        },
        Timebounds: txnbuild.NewInfiniteTimeout(),
    },
)
if err != nil {
    log.Fatalf("Failed to build transaction: %v", err)
}
```

<!-- tabs:end -->

## Manage Sell Offer

6. Now, let's look at how we would create the same offer but use the manageSellOffer operation instead. This operation is nearly identical to manageBuyOffer, with the primary and counter assets swapped. The available options for this operation are:

- **selling**: The asset you're offering to give in the exchange (native DIAM in the example below)
- **buying**: The asset you're seeking to receive in the exchange (USDC in the example below)
- **amount**: The amount of the Selling asset you must give for this offer to be taken
- **price**: Like in the above example, if you create an identical offer of receiving 100 USD in exchange for 1,000 DIAM, flip the denominator and numerator (100/1000). Rather than the price of 10, the price would be 0.1.
- **offerId**: (optional) Set to 0 to create a new offer. To update or delete an existing offer, use the offer ID here. Defaults to '0'.
- **source**: (optional) The account that gives the selling asset and receives the buying asset in this offer. Defaults to transaction source.

<!-- tabs:start -->

#### **Javascript**

```js
const transaction = new TransactionBuilder(...)
  .addOperation(Operation.manageSellOffer({
    selling: Asset.native(),
    buying: usdcAsset,
    amount: '1000',
    price: '0.1',
    offerId: '0',
    source: keypair.publicKey()
  }))
```

#### **Go**

```go
tx, err = txnbuild.NewTransaction(
    txnbuild.TransactionParams{
        SourceAccount:        &questAccount,
        BaseFee:              txnbuild.MinBaseFee,
        IncrementSequenceNum: true,
        Operations: []txnbuild.Operation{
            &txnbuild.ManageSellOffer{
                Selling:   txnbuild.NativeAsset{},
                Buying:    usdcAsset,
                Amount:    "1000",
                Price:     "0.1",
                OfferID:   0,
                SourceAccount: keypair.Address(),
            },
        },
        Timebounds: txnbuild.NewInfiniteTimeout(),
    },
)
if err != nil {
    log.Fatalf("Failed to build transaction: %v", err)
}
```

<!-- tabs:end -->

## Create Passive Sell Offer

7. This last operation, createPassiveSellOffer, creates an offer to sell one asset for another without taking an already-existing reverse offer of equal price. This allows you to maintain an order book that both buys and sells an asset equally without the offers actually executing. The available options for this operation are:

- **selling**: The asset you're offering to give in the exchange (native DIAM in the example below)
- **buying**: The asset you're seeking to receive in the exchange (USDC in the example below)
- **amount**: The amount of the Selling asset you must give for this offer to be taken
- **price**: This calculation is reached in the same way as for the manageSellOffer operation.
- **source**: (optional) The account that gives the selling asset and receives the buying asset in this offer. Defaults to transaction source.

> Note that there is no offer ID for this operation because it behaves exactly like a regular buy or sell offer once it's been created. You can manage it via the regular manage buy or sell offer operations.

<!-- tabs:start -->

#### **Javascript**

```js
const transaction = new TransactionBuilder(...)
  .addOperation(Operation.createPassiveSellOffer({
    selling: Asset.native(),
    buying: usdcAsset,
    amount: '1000',
    price: '0.1',
    source: keypair.publicKey()
  }))
```

#### **Go**

```go
tx, err = txnbuild.NewTransaction(
    txnbuild.TransactionParams{
        SourceAccount:        &questAccount,
        BaseFee:              txnbuild.MinBaseFee,
        IncrementSequenceNum: true,
        Operations: []txnbuild.Operation{
            &txnbuild.CreatePassiveSellOffer{
                Selling:   txnbuild.NativeAsset{},
                Buying:    usdcAsset,
                Amount:    "1000",
                Price:     "0.1",
                SourceAccount: keypair.Address(),
            },
        },
        Timebounds: txnbuild.NewInfiniteTimeout(),
    },
)
if err != nil {
    log.Fatalf("Failed to build transaction: %v", err)
}

```

<!-- tabs:end -->

8. Now, we are ready to build, sign, and submit our transaction to the network.

<!-- tabs:start -->

#### **Javascript**

```js
const transaction = new TransactionBuilder(...)
  .setTimeout(30)
  .build()

transaction.sign(keypair)

try {
  let res = await server.submitTransaction(transaction)
  console.log(`Transaction Successful! Hash: ${res.hash}`)
} catch (error) {
  console.log(`${error}. More details:\n${JSON.stringify(error.response.data.extras, null, 2)}`)
}
```

#### **Go**

```go
tx, err = tx.Sign(network.TestNetworkPassphrase, sourceKP)
if err != nil {
    panic(err)
}

resp, err := auroraclient.DefaultTestNetClient.SubmitTransaction(tx)
if err != nil {
    panic(err)
}
```

<!-- tabs:end -->

> Important note: offers may or may not be taken immediately upon submission to the network. If a relevant counteroffer is already “on the books,” the offer will execute immediately. Otherwise, the offer will sit idle on the network until you either remove the offer, or a counterparty takes it. This will become important when building atomic transactions and should be considered when building more complex logic chains.
