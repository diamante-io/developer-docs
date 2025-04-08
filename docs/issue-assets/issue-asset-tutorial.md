# Issue an Asset Tutorial

In this tutorial, we will walk through the steps to issue an asset on the Diamante test network.

## Prerequisites

You must ensure you have the required amount of DIAM to create your issuing and distribution accounts and cover the minimum balance and transaction fees. If you’re issuing an asset on the testnet, you can fund your account by getting test DIAM from friendbot. If you’re issuing an asset in production, you will need to acquire DIAM from another wallet or exchange.

If you’d like to avoid your users having to deal with transaction fees, consider using fee-bump transactions. Read more in our[Encyclopedia -> Fee-Bump Transaction Encyclopedia Entry](/encyclopedia/fee-bump-transactions).

Learn about the testnet and mainnet in our [Networks section](/fundamentals/networks).

Learn more about fees in our [Fees, Surge Pricing, and Fee Strategies section](/encyclopedia/fee-surge-pricing-strategies).

## 1. Create Issuing Account and an Object to Represent the New Asset

<!-- tabs:start -->

#### **Javascript**

```js
const issuerKeypair = DiamSdk.Keypair.random()
const astroDollar = new DiamSdk.Asset(‘AstroDollar’, issuerKeypair.publicKey())
```

#### **Go**

```go
	// Create issuing account
	issuerKeyPair, err := keypair.Random()
	if err != nil {
		log.Fatal("Error generating issuing account key pair:", err)
	}

	// Create an object to represent the new asset
	astroDollar := txnbuild.CreditAsset{
		Code:   "AstroDollar",
		Issuer: issuerKeyPair.Address(),
	}

	log.Printf("Issuing Account Public Key: %s\n", issuerKeyPair.Address())
	log.Printf("AstroDollar Asset Code: %s\n", astroDollar.Code)
	log.Printf("AstroDollar Asset Issuer: %s\n", astroDollar.Issuer)
```

<!-- tabs:end -->

## 2. Create distribution account

Although it is not required to create a distribution account, it is best practice, so we will do so in this example. Read more in our [Issuing and Distribution Accounts section](/issue-assets/asset-design).

<!-- tabs:start -->

#### **Javascript**

```js
// This generates a random keypair
const distributorKeypair = DiamSdk.Keypair.random()

// This loads a keypair from a secret key you already have
const distributorKeypair = DiamSdk.Keypair.fromSecret(‘SCZANGBA5YHTNYVVV4C3U252E2B6P6F5T3U6MM63WBSBZATAQI3EBTQ4’)
```

#### **Go**

```go
// This generates a random keypair
// Create distribution account
distributorKeyPair, err := keypair.Random()
if err != nil {
	log.Fatal("Error generating distribution account key pair:", err)
}

log.Printf("Distribution Account Public Key: %s\n", distributorKeyPair.Address())
```

<!-- tabs:end -->

## 3. Establish trustline between the two

An account must establish a trustline with the issuing account to hold that account’s asset. This is true for all assets except for Diamante's native token, DIAM.

Read more about trustlines in the [Trustlines section](/fundamentals/datastructures?id=trustlines).

If you’d like to avoid your users having to deal with trustlines or DIAM, consider using sponsored reserves. Read more in our [Encyclopedia -> Sponsored Reserves Encyclopedia Entry](/encyclopedia/sponsored-reserves).

<!-- tabs:start -->

#### **Javascript**

```js
const server = new DiamSdk.Aurora.Server("https://diamtestnet.diamcircle.io/");
const account = await server.loadAccount(distributorKeypair.publicKey());

const transaction = new DiamSdk.TransactionBuilder(account, {
  fee: DiamSdk.BASE_FEE,
  networkPassphrase: DiamSdk.Networks.TESTNET,
})
  // The `changeTrust` operation creates (or alters) a trustline
  // The `limit` parameter below is optional
  .addOperation(
    DiamSdk.Operation.changeTrust({
      asset: astroDollar,
      limit: "1000",
      source: distributorKeypair.publicKey(),
    })
  );
```

#### **Go**

```go
// First, the receiving (distribution) account must trust the asset from the issuer.
tx, err := txnbuild.NewTransaction(
	txnbuild.TransactionParams{
		SourceAccount:        distributorAccount.AccountID,
		IncrementSequenceNum: true,
		BaseFee:              txnbuild.MinBaseFee,
		Timebounds:           txnbuild.NewInfiniteTimeout(),
		Operations: []txnbuild.Operation{
			&txnbuild.ChangeTrust{
				Line:  astroDollar,
				Limit: "5000",
			},
		},
	},
)
signedTx, err := tx.Sign(network.TestNetworkPassphrase, distributor)
resp, err := client.SubmitTransaction(signedTx)
if err != nil {
	log.Fatal(err)
} else {
	log.Printf("Trust: %s\n", resp.Hash)
}
```

<!-- tabs:end -->

## 4. Make a payment from issuing to distribution account, issuing the asset

The payment operation is what actually issues (or mints) the asset.

<!-- tabs:start -->

#### **Javascript**

```js
const transaction = new DiamSdk.TransactionBuilder(...)
  // The `payment` operation sends the `amount` of the specified
  // `asset` to our distributor account
  .addOperation(DiamSdk.Operation.payment({
    destination: distributorKeypair.publicKey(),
    asset: astroDollar,
    amount: '1000',
    source: issuerKeypair.publicKey()
  }))
```

#### **Go**

```go
// Second, the issuing account actually sends a payment using the asset
tx, err := txnbuild.NewTransaction(
	txnbuild.TransactionParams{
		SourceAccount:        issuerAccount.AccountID,
		IncrementSequenceNum: true,
		BaseFee:              txnbuild.MinBaseFee,
		Timebounds:           txnbuild.NewInfiniteTimeout(),
		Operations: []txnbuild.Operation{
			&txnbuild.Payment{
				Destination: distributor.Address(),
				Asset:       astroDollar,
				Amount:      "10",
			},
		},
	},
)
signedTx, err := tx.Sign(network.TestNetworkPassphrase, issuer)
resp, err := client.SubmitTransaction(signedTx)
if err != nil {
	log.Fatal(err)
} else {
	log.Printf("Pay: %s\n", resp.Hash)
}
```

<!-- tabs:end -->

<!-- ## 5. _Optionally_ , lock the issuing account down so the asset’s supply is permanently fixed

Warning! This section details how to lock your account with the purpose of limiting the supply of your issued asset. However, locking your account means you’ll never be able to do anything with it ever again- whether that’s adjusting signers, changing the home domain, claiming any held DIAM, or any other operation. Your account will be completely frozen.

Learn more about asset supply in our section on Limiting the Supply of an Asset

```go
const transaction = new diamcircleSdk.TransactionBuilder(...)
  // This (optional) `setOptions` operation locks the issuer account
  // so there can never be any more of the asset minted
  .addOperation(diamcircleSdk.Operation.setOptions({
    masterWeight: 0,
    source: issuerKeypair.publicKey()
  }))

``` -->

## Full Code Sample

<!-- tabs:start -->

#### **Javascript**

```js
var DiamSdk = require("diamnet-sdk");
var server = new DiamSdk.Aurora.Server("https://diamtestnet.diamcircle.io/");

// Keys for accounts to issue and receive the new asset
var issuingKeys = DiamSdk.Keypair.fromSecret(
  "SCZANGBA5YHTNYVVV4C3U252E2B6P6F5T3U6MM63WBSBZATAQI3EBTQ4"
);
var receivingKeys = DiamSdk.Keypair.fromSecret(
  "SDSAVCRE5JRAI7UFAVLE5IMIZRD6N6WOJUWKY4GFN34LOBEEUS4W2T2D"
);

// Create an object to represent the new asset
var astroDollar = new DiamSdk.Asset("AstroDollar", issuingKeys.publicKey());

// First, the receiving account must trust the asset
server
  .loadAccount(receivingKeys.publicKey())
  .then(function (receiver) {
    var transaction = new DiamSdk.TransactionBuilder(receiver, {
      fee: 100,
      networkPassphrase: DiamSdk.Networks.TESTNET,
    })
      // The `changeTrust` operation creates (or alters) a trustline
      // The `limit` parameter below is optional
      .addOperation(
        DiamSdk.Operation.changeTrust({
          asset: astroDollar,
          limit: "1000",
        })
      )
      // setTimeout is required for a transaction
      .setTimeout(100)
      .build();
    transaction.sign(receivingKeys);
    return server.submitTransaction(transaction);
  })
  .then(console.log)

  // Second, the issuing account actually sends a payment using the asset
  .then(function () {
    return server.loadAccount(issuingKeys.publicKey());
  })
  .then(function (issuer) {
    var transaction = new DiamSdk.TransactionBuilder(issuer, {
      fee: 100,
      networkPassphrase: DiamSdk.Networks.TESTNET,
    })
      .addOperation(
        DiamSdk.Operation.payment({
          destination: receivingKeys.publicKey(),
          asset: astroDollar,
          amount: "10",
        })
      )
      // setTimeout is required for a transaction
      .setTimeout(100)
      .build();
    transaction.sign(issuingKeys);
    return server.submitTransaction(transaction);
  })
  .then(console.log)
  .catch(function (error) {
    console.error("Error!", error);
  });
```

#### **Go**

```go
package main

import (
  "github.com/diamcircle/go/clients/auroraclient"
  "github.com/diamcircle/go/keypair"
  "github.com/diamcircle/go/network"
  "github.com/diamcircle/go/txnbuild"
  "log"
)

func main() {
  client := auroraclient.DefaultTestNetClient

  // Remember, these are just examples, so replace them with your own seeds.
  issuerSeed := "SDR4C2CKNCVK4DWMTNI2IXFJ6BE3A6J3WVNCGR6Q3SCMJDTSVHMJGC6U"
  distributorSeed := "SBUW3DVYLKLY5ZUJD5PL2ZHOFWJSVWGJA47F6FLO66UUFZLUUA2JVU5U"

  /*
   * We omit error checks here for brevity, but you should always check your
   * return values.
   */

  // Keys for accounts to issue and distribute the new asset.
  issuer, err := keypair.ParseFull(issuerSeed)
  distributor, err := keypair.ParseFull(distributorSeed)

  request := auroraclient.AccountRequest{AccountID: issuer.Address()}
  issuerAccount, err := client.AccountDetail(request)

  request = auroraclient.AccountRequest{AccountID: distributor.Address()}
  distributorAccount, err := client.AccountDetail(request)

  // Create an object to represent the new asset
  astroDollar := txnbuild.CreditAsset{Code: "AstroDollar", Issuer: issuer.Address()}

  // First, the receiving (distribution) account must trust the asset from the
  // issuer.
  tx, err := txnbuild.NewTransaction(
    txnbuild.TransactionParams{
      SourceAccount:        distributorAccount.AccountID,
      IncrementSequenceNum: true,
      BaseFee:              txnbuild.MinBaseFee,
      Timebounds:           txnbuild.NewInfiniteTimeout(),
      Operations: []txnbuild.Operation{
        &txnbuild.ChangeTrust{
          Line:  astroDollar,
          Limit: "5000",
        },
      },
    },
  )

  signedTx, err := tx.Sign(network.TestNetworkPassphrase, distributor)
  resp, err := client.SubmitTransaction(signedTx)
  if err != nil {
    log.Fatal(err)
  } else {
    log.Printf("Trust: %s\n", resp.Hash)
  }

  // Second, the issuing account actually sends a payment using the asset
  tx, err = txnbuild.NewTransaction(
    txnbuild.TransactionParams{
      SourceAccount:        issuerAccount.AccountID,
      IncrementSequenceNum: true,
      BaseFee:              txnbuild.MinBaseFee,
      Timebounds:           txnbuild.NewInfiniteTimeout(),
      Operations: []txnbuild.Operation{
        &txnbuild.Payment{
          Destination: distributor.Address(),
          Asset:       astroDollar,
          Amount:      "10",
        },
      },
    },
  )

  signedTx, err = tx.Sign(network.TestNetworkPassphrase, issuer)
  resp, err = client.SubmitTransaction(signedTx)

  if err != nil {
    log.Fatal(err)
  } else {
    log.Printf("Pay: %s\n", resp.Hash)
  }
}
```

<!-- tabs:end -->
