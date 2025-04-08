# Claimable Balances

Claimable balances are used to split a payment into two parts.

**Part 1:** The sending account creates a payment, or ClaimableBalanceEntry, using the Create Claimable Balance operation.

**Part 2:** The destination account(s), or claimant(s), accepts the ClaimableBalanceEntry using the Claim Claimable Balance operation.

Claimable balances allow an account to send a payment to another account that is not necessarily prepared to receive the payment. They can be used when you send a non-native asset to an account that has not yet established a trustline, which can be useful for anchors onboarding new users. A trustline must be established by the claimant to the asset before it can claim the claimable balance, otherwise, the claim will result in an `op_no_trust` error.

It is important to note that if a claimable balance isn’t claimed, it sits on the ledger forever, taking up space and ultimately making the network less efficient. **For this reason, it is a good idea to put one of your own accounts as a claimant for a claimable balance.** Then you can accept your own claimable balance if needed, freeing up space on the network.

Each ClaimableBalanceEntry is a ledger entry, and each claimant in that entry increases the source account’s minimum balance by one base reserve.

Once a ClaimableBalanceEntry has been claimed, it is deleted.

## Operations

### Create Claimable Balance

For basic parameters, see the Create Claimable Balance entry in our List of [Operations section](/fundamentals/operations).

**Additional parameters:**

- `Claim_Predicate_` Claimant: An object that holds both the destination account that can claim the ClaimableBalanceEntry and a ClaimPredicate that must evaluate to true for the claim to succeed.

A ClaimPredicate is a recursive data structure that can be used to construct complex conditionals using different ClaimPredicateTypes. Below are some examples with the `Claim_Predicate_` prefix removed for readability. Note that the SDKs expect the Unix timestamps to be expressed in seconds.

- Can claim at any time - `UNCONDITIONAL`
- Can claim if the close time of the ledger, including the claim is before X seconds + the ledger close time in which the ClaimableBalanceEntry was created - `BEFORE_RELATIVE_TIME(X)`
- Can claim if the close time of the ledger including the claim is before X (Unix timestamp) - BEFORE_ABSOLUTE_TIME(X)
- Can claim if the close time of the ledger, including the claim is at or after X seconds + the ledger close time in which the ClaimableBalanceEntry was created - `NOT(BEFORE_RELATIVE_TIME(X))`
- Can claim if the close time of the ledger, including the claim is at or after X (Unix timestamp) - `NOT(BEFORE_ABSOLUTE_TIME(X))`
- Can claim between X and Y Unix timestamps (given X < Y) - `AND(NOT(BEFORE_ABSOLUTE_TIME(X))`,` BEFORE_ABSOLUTE_TIME(Y))`
- Can claim outside X and Y Unix timestamps (given X < Y) - `OR(BEFORE_ABSOLUTE_TIME(X)`, `NOT(BEFORE_ABSOLUTE_TIME(Y))`

- `ClaimableBalanceID`: ClaimableBalanceID is a union with one possible type (`CLAIMABLE_BALANCE_ID_TYPE_V0`). It contains an SHA-256 hash of the OperationID for Claimable Balances.

A successful Create Claimable Balance operation will return a Balance ID, which is required when claiming the ClaimableBalanceEntry with the Claim Claimable Balance operation.

### Claim Claimable Balance

For basic parameters, see the Claim Claimable Balance entry in our List of Operations section.

This operation will load the ClaimableBalanceEntry that corresponds to the Balance ID and then search for the source account of this operation in the list of claimants on the entry. If a match on the claimant is found, and the ClaimPredicate evaluates to true, then the ClaimableBalanceEntry can be claimed. The balance on the entry will be moved to the source account if there are no limit or trustline issues (for non-native assets), meaning the claimant must establish a trustline to the asset before claiming it.

### Clawback Claimable Balance

For basic parameters, see the Claim Claimable Balance entry in our List of [Operations section](/fundamentals/operations).

This operation claws back a claimable balance, returning the asset to the issuer account, burning it. You must claw back the entire claimable balance, not just part of it. Once a claimable balance has been claimed, use the regular clawback operation to claw it back.

Clawback claimable balances require the claimable balance ID.

Learn more about clawbacks in our [Clawback Encyclopedia Entry](clawback-encyclopedia-link).

## Example

The below code demonstrates via both the go and Go SDKs how an account (Account A) creates a ClaimableBalanceEntry with two claimants: Account A (itself) and Account B (another recipient).

Each of these accounts can only claim the balance under unique conditions. Account B has a full minute to claim the balance before Account A can reclaim the balance back for itself.

Note: there is no recovery mechanism for a claimable balance in general — if none of the predicates can be fulfilled, the balance cannot be recovered. The reclaim example below acts as a safety net for this situation.

<!-- tabs:start -->

#### **Javascript**

```js
const sdk = require("diamnet-sdk");

async function main() {
  let server = new sdk.Server("https://diamtestnet.diamcircle.io/");

  let A = sdk.Keypair.fromSecret(
    "SAQLZCQA6AYUXK6JSKVPJ2MZ5K5IIABJOEQIG4RVBHX4PG2KMRKWXCHJ"
  );
  let B = sdk.Keypair.fromPublicKey(
    "GAS4V4O2B7DW5T7IQRPEEVCRXMDZESKISR7DVIGKZQYYV3OSQ5SH5LVP"
  );

  // NOTE: Proper error checks are omitted for brevity; always validate things!

  let aAccount = await server.loadAccount(A.publicKey()).catch(function (err) {
    console.error(`Failed to load ${A.publicKey()}: ${err}`);
  });
  if (!aAccount) {
    return;
  }

  // Create a claimable balance with our two above-described conditions.
  let soon = Math.ceil(Date.now() / 1000 + 60); // .now() is in ms
  let bCanClaim = sdk.Claimant.predicateBeforeRelativeTime("60");
  let aCanReclaim = sdk.Claimant.predicateNot(
    sdk.Claimant.predicateBeforeAbsoluteTime(soon.toString())
  );

  // Create the operation and submit it in a transaction.
  let claimableBalanceEntry = sdk.Operation.createClaimableBalance({
    claimants: [
      new sdk.Claimant(B.publicKey(), bCanClaim),
      new sdk.Claimant(A.publicKey(), aCanReclaim),
    ],
    asset: sdk.Asset.native(),
    amount: "420",
  });

  let tx = new sdk.TransactionBuilder(aAccount, { fee: sdk.BASE_FEE })
    .addOperation(claimableBalanceEntry)
    .setNetworkPassphrase(sdk.Networks.TESTNET)
    .setTimeout(180)
    .build();

  tx.sign(A);
  let txResponse = await server
    .submitTransaction(tx)
    .then(function () {
      console.log("Claimable balance created!");
    })
    .catch(function (err) {
      console.error(`Tx submission failed: ${err}`);
    });
}
```

#### **Go**

```go
package main

import (
    "fmt"
    "time"

    sdk "github.com/diamcircle/go/clients/auroraclient"
    "github.com/diamcircle/go/keypair"
    "github.com/diamcircle/go/network"
    "github.com/diamcircle/go/txnbuild"
)


func main() {
    client := sdk.DefaultTestNetClient

    // Suppose that these accounts exist and are funded accordingly:
    A := "SCZANGBA5YHTNYVVV4C3U252E2B6P6F5T3U6MM63WBSBZATAQI3EBTQ4"
    B := "GA2C5RFPE6GCKMY3US5PAB6UZLKIGSPIUKSLRB6Q723BM2OARMDUYEJ5"

    // Load the corresponding account for A.
    aKeys := keypair.MustParseFull(A)
    aAccount, err := client.AccountDetail(sdk.AccountRequest{
        AccountID: aKeys.Address(),
    })
    check(err)

    // Create a claimable balance with our two above-described conditions.
    soon := time.Now().Add(time.Second * 60)
    bCanClaim := txnbuild.BeforeRelativeTimePredicate(60)
    aCanReclaim := txnbuild.NotPredicate(
        txnbuild.BeforeAbsoluteTimePredicate(soon.Unix()),
    )

    claimants := []txnbuild.Claimant{
        txnbuild.NewClaimant(B, &bCanClaim),
        txnbuild.NewClaimant(aKeys.Address(), &aCanReclaim),
    }

    // Create the operation and submit it in a transaction.
    claimableBalanceEntry := txnbuild.CreateClaimableBalance{
        Destinations: claimants,
        Asset:        txnbuild.NativeAsset{},
        Amount:       "420",
    }

    // Build, sign, and submit the transaction
    tx, err := txnbuild.NewTransaction(
        txnbuild.TransactionParams{
            SourceAccount:        aAccount.AccountID,
            IncrementSequenceNum: true,
            BaseFee:              txnbuild.MinBaseFee,
            // Use a real timeout in production!
            Timebounds: txnbuild.NewInfiniteTimeout(),
            Operations: []txnbuild.Operation{&claimableBalanceEntry},
        },
    )
    check(err)
    tx, err = tx.Sign(network.TestNetworkPassphrase, aKeys)
    check(err)
    txResp, err := client.SubmitTransaction(tx)
    check(err)

    fmt.Println(txResp)
    fmt.Println("Claimable balance created!")
}
```

<!-- tabs:end -->

At this point, the `ClaimableBalanceEntry` exists in the ledger, but we’ll need its Balance ID to claim it, which can be done in several ways:

- The submitter of the entry (Account A in this case) can retrieve the Balance ID before submitting the transaction;
- The submitter parses the XDR of the transaction result’s operations; or
- Someone queries the list of claimable balances.

Either party could also check the /effects of the transaction, query /claimable_balances with different filters, etc. Note that while (1) may be unavailable in some SDKs as it's just a helper, the other methods are universal.

<!-- tabs:start -->

#### **Javascript**

```js
// Method 1: Not available in the JavaScript SDK yet.

// Method 2: Suppose `txResponse` comes from the transaction submission
// above.
let txResult = sdk.xdr.TransactionResult.fromXDR(
  txResponse.result_xdr,
  "base64"
);
let results = txResult.result().results();

// We look at the first result since our first (and only) operation
// in the transaction was the CreateClaimableBalanceOp.
let operationResult = results[0].value().createClaimableBalanceResult();
let balanceId = operationResult.balanceId().toXDR("hex");
console.log("Balance ID (2):", balanceId);

// Method 3: Account B could alternatively do something like:
let balances = await server
  .claimableBalances()
  .claimant(B.publicKey())
  .limit(1) // there may be many in general
  .order("desc") // so always get the latest one
  .call()
  .catch(function (err) {
    console.error(`Claimable balance retrieval failed: ${err}`);
  });
if (!balances) {
  return;
}

balanceId = balances.records[0].id;
console.log("Balance ID (3):", balanceId);
```

#### **Go**

```go
// Method 1: Suppose `tx` comes from the transaction built above.
//           Notice that this can be done *before* submission.
balanceId, err := tx.ClaimableBalanceID(0)
check(err)

// Method 2: Suppose `txResp` comes from the transaction submission above.
var txResult xdr.TransactionResult
err = xdr.SafeUnmarshalBase64(txResp.ResultXdr, &txResult)
check(err)

if results, ok := txResult.OperationResults(); ok {
    // We look at the first result since our first (and only) operation in the
    // transaction was the CreateClaimableBalanceOp.
    operationResult := results[0].MustTr().CreateClaimableBalanceResult
    balanceId, err := xdr.MarshalHex(operationResult.BalanceId)
    check(err)
    fmt.Println("Balance ID:", balanceId)
}

// Method 3: Account B could alternatively do something like:
balances, err := client.ClaimableBalances(sdk.ClaimableBalanceRequest{Claimant: B})
check(err)
balanceId := balances.Embedded.Records[0].BalanceID
```

With the Claimable Balance ID acquired, either Account B or A can actually submit a claim, depending on which predicate is fulfilled. We’ll assume here that a minute has passed, so Account A just reclaims the balance entry.

```go
claimBalance := txnbuild.ClaimClaimableBalance{BalanceID: balanceId}
tx, err = txnbuild.NewTransaction(
    txnbuild.TransactionParams{
        SourceAccount:        aAccount.AccountID, // or Account B, depending on the condition!
        IncrementSequenceNum: true,
        BaseFee:              txnbuild.MinBaseFee,
        Timebounds:           txnbuild.NewInfiniteTimeout(),
        Operations:           []txnbuild.Operation{&claimBalance},
    },
)
check(err)
tx, err = tx.Sign(network.TestNetworkPassphrase, aKeys)
check(err)
txResp, err = client.SubmitTransaction(tx)
check(err)
```

<!-- tabs:end -->

And that’s it! Since we opted for the reclaim path, Account A should have the same balance as what it started with (minus fees), and Account B should be unchanged.
