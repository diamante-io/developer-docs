# Sponsored Reserves

Sponsored reserves allow an account (sponsoring account) to pay the base reserves for another account (sponsored account). While this relationship exists, base reserve requirements that would normally accumulate on the sponsored account now accumulate on the sponsoring account.

Both the Begin Sponsoring Future Reserves and the End Sponsoring Future Reserves operations must appear in the sponsorship transaction, guaranteeing that both accounts agree to the sponsorship.

Anything that increases the minimum balance can be sponsored (account creation, offers, trustlines, data entries, signers, claimable balances).

To learn about base reserves, see our section on [DIAM](/fundamentals/diams).

## Sponsored reserves operations

<br/>

### Begin and end sponsorships

To create a sponsored reserve, you have to use a sandwich transaction that includes three operations.

1. **Begin Sponsoring Future Reserves:** Initiates the sponsorship and requires the sponsoring account's signature.
2. **Specifies what is being sponsored.**
3. **End Sponsoring Future Reserves:** Allows the sponsored account to accept the sponsorship and requires the sponsored account’s signature.

Begin Sponsoring Future Reserves establishes the `is-sponsoring-future-reserves-for` relationship where the sponsoring account is the source account of the operation. The account specified in the operation is the sponsored account.

End Sponsoring Future Reserves ends the current `is-sponsoring-future-reserves-for` relationship for the source account of the operation.

At the end of any transaction, there must be no ongoing `is-sponsoring-future-reserves-for` relationships, which is why these two operations must be used together in a single transaction.

View operation details in our List of [Operations section.](/fundamentals/operations)

### Revoke sponsorship

Allows the sponsoring account to remove or transfer sponsorships of existing ledgerEntries and signers. If the ledgerEntry or signer is not sponsored, the owner of the ledgerEntry or signer can establish a sponsorship if it is the beneficiary of an `is-sponsoring-future-reserves-for` relationship.

**Operation logic:**

- **Entry/signer is sponsored**
  - Source account is currently the beneficiary of an `is-sponsoring-future-reserves-for` relationship
    - Transfer sponsorship of entry/signer from source account to the account that is-sponsoring-future-reserves-for source account
  - Source account is not the beneficiary of an `is-sponsoring-future-reserves-for` relationship
    - Remove the sponsorship from the entry/signer
- **Entry/signer is not sponsored**
  - Source account is currently the beneficiary of an `is-sponsoring-future-reserves-for` relationship
    - Establish sponsorship between entry/signer and the account that is-sponsoring-future-reserves-for source account
  - Source account is not the beneficiary of an `is-sponsoring-future-reserves-for` relationship
    - No-Op

View operation details in our List of [Operations section.](/fundamentals/operations)

## Effect on minimum balance

Once sponsorships are introduced, the minimum balance calculation is: `(2 base reserves + numSubEntries + numSponsoring - numSponsored) * baseReserve + liabilities.selling`.

When account A is sponsoring future reserves for account B, any reserve requirements that would normally accumulate on B will instead accumulate on A, shown in `numSponsoring`. The fact that these reserves are being provided by another account will be reflected on B in `numSponsored`, which cancels out the increase in `numSubEntries`, keeping the minimum balance unchanged for B.

When a sponsored entry or subentry is removed, `numSponsoring` is decreased on the sponsoring account and `numSponsored` is decreased on the sponsored account.

To learn more about minimum balance requirements, see our section on Diams.

## Effect on claimable balances

All claimable balances are sponsored through built-in logic in the claimable balance operations. The account that creates the claimable balance pays the base reserve to get the claimable balance on the ledger. When the claimable balance is claimed by the claimant(s), the claimable balance is removed from the ledger, and the account that created it gets the base reserve back.

Read more about claimable balances in our [Encyclopedia -> Claimable Balances Encyclopedia Entry](/encyclopedia/claimable-balances).

## Examples

Each of the following examples builds on itself, referencing variables from previous snippets. The following examples will demonstrate:

1. Sponsor creation of a trustline for another account
2. Sponsor two trustlines for an account via two different sponsors
3. Transfer the sponsorship responsibility from one account to another
4. Revoke the sponsorship by an account entirely

For brevity in the Golang examples, we’ll assume the existence of a `SignAndSend`(...) method (defined below) which creates and submits a transaction with the proper parameters and basic error-checking.

### Preamble

We’ll start by including the boilerplate of account and asset creation.

<!-- tabs:start -->

#### **Javascript**

```js
const sdk = require("diamnet-sdk");
const http = require("got");

let server = new sdk.Server("https://diamtestnet.diamcircle.io/");

async function main() {
  // Create & fund the new accounts.
  let keypairs = [
    sdk.Keypair.random(),
    sdk.Keypair.random(),
    sdk.Keypair.random(),
  ];

  for (const keypair of keypairs) {
    const base = "https://friendbot.diamcircle.io/?";
    const path = base + "addr=" + encodeURIComponent(keypair.publicKey());

    console.log(`Funding:\n ${keypair.secret()}\n ${keypair.publicKey()}`);

    // We use the "got" library here to do the HTTP request synchronously, but
    // you can obviously use any method you'd like for this.
    const response = await http(path).catch(function (error) {
      console.error("  failed:", error.response.body);
    });
  }

  // Arbitrary assets to sponsor trustlines for. Let's assume they make sense.
  let S1 = keypairs[0], A = keypairs[1], S2 = keypairs[2];
  let assets = [
    new sdk.Asset("ABCD", S1.publicKey()),
    new sdk.Asset("EFGH", S1.publicKey()),
    new sdk.Asset("IJKL", S2.publicKey()),
  ];

  // ...
```

#### **Go**

```go
package main

import (
    "fmt"
    "net/http"

    sdk "github.com/diamcircle/go/clients/auroraclient"
    "github.com/diamcircle/go/keypair"
    "github.com/diamcircle/go/network"
    protocol "github.com/diamcircle/go/protocols/aurora"
    "github.com/diamcircle/go/txnbuild"
)

func main() {
    client := sdk.DefaultTestNetClient

    // Both S1 and S2 will be sponsors for A at various points in time.
    S1, A, S2 := keypair.MustRandom(), keypair.MustRandom(), keypair.MustRandom()
    addressA := A.Address()

    for _, pair := range []*keypair.Full{S1, A, S2} {
        resp, err := http.Get("https://friendbot.diamcircle.org/?addr=" + pair.Address())
        check(err)
        resp.Body.Close()
        fmt.Println("Funded", pair.Address())
    }

    // Load the corresponding account for both A and C.
    s1Account, err := client.AccountDetail(sdk.AccountRequest{AccountID: S1.Address()})
    check(err)
    aAccount, err := client.AccountDetail(sdk.AccountRequest{AccountID: addressA})
    check(err)
    s2Account, err := client.AccountDetail(sdk.AccountRequest{AccountID: S2.Address()})
    check(err)

    // Arbitrary assets to sponsor trustlines for. Let's assume they make sense.
    assets := []txnbuild.CreditAsset{
        txnbuild.CreditAsset{Code: "ABCD", Issuer: S1.Address()},
        txnbuild.CreditAsset{Code: "EFGH", Issuer: S1.Address()},
        txnbuild.CreditAsset{Code: "IJKL", Issuer: S2.Address()},
    }

    // ...
```

<!-- tabs:end -->

### 1. Sponsoring trustlines

Now, let’s sponsor trustlines for Account A. Notice how the `CHANGE_TRUST` operation is sandwiched between the begin and end sponsoring operations and that all relevant accounts need to sign the transaction.

<!-- tabs:start -->

#### **Javascript**

```js
//
// 1. S1 will sponsor a trustline for Account A.
//
let s1Account = await server.loadAccount(S1.publicKey()).catch(accountFail);
let tx = new sdk.TransactionBuilder(s1Account, { fee: sdk.BASE_FEE })
  .addOperation(
    sdk.Operation.beginSponsoringFutureReserves({
      sponsoredId: A.publicKey(),
    })
  )
  .addOperation(
    sdk.Operation.changeTrust({
      source: A.publicKey(),
      asset: assets[0],
      limit: "1000", // This limit can vary according with your application;
      // if left empty, it defaults to the max limit.
    })
  )
  .addOperation(
    sdk.Operation.endSponsoringFutureReserves({
      source: A.publicKey(),
    })
  )
  .setNetworkPassphrase(sdk.Networks.TESTNET)
  .setTimeout(180)
  .build();

// Note that while either can submit this transaction, both must sign it.
tx.sign(S1, A);
let txResponse = await server.submitTransaction(tx).catch(txCheck);
if (!txResponse) {
  return;
}

console.log("Sponsored a trustline of", A.publicKey());

//
// 2. Both S1 and S2 sponsor trustlines for Account A for different assets.
//
let aAccount = await server.loadAccount(A.publicKey()).catch(accountFail);
let tx = new sdk.TransactionBuilder(aAccount, { fee: sdk.BASE_FEE })
  .addOperation(
    sdk.Operation.beginSponsoringFutureReserves({
      source: S1.publicKey(),
      sponsoredId: A.publicKey(),
    })
  )
  .addOperation(
    sdk.Operation.changeTrust({
      asset: assets[1],
      limit: "5000",
    })
  )
  .addOperation(sdk.Operation.endSponsoringFutureReserves())

  .addOperation(
    sdk.Operation.beginSponsoringFutureReserves({
      source: S2.publicKey(),
      sponsoredId: A.publicKey(),
    })
  )
  .addOperation(
    sdk.Operation.changeTrust({
      asset: assets[2],
      limit: "2500",
    })
  )
  .addOperation(sdk.Operation.endSponsoringFutureReserves())
  .setNetworkPassphrase(sdk.Networks.TESTNET)
  .setTimeout(180)
  .build();

// Note that all 3 accounts must approve/sign this transaction.
tx.sign(S1, S2, A);
let txResponse = await server.submitTransaction(tx).catch(txCheck);
if (!txResponse) {
  return;
}

console.log("Sponsored two trustlines of", A.publicKey());
```

#### **Go**

```go
    //
    // 1. S1 will sponsor a trustline for Account A.
    //
    sponsorTrustline := []txnbuild.Operation{
        &txnbuild.BeginSponsoringFutureReserves{
            SourceAccount: s1Account.AccountID,
            SponsoredID:   addressA,
        },
        &txnbuild.ChangeTrust{
            Line:  &assets[0],
            Limit: txnbuild.MaxTrustlineLimit,
        },
        &txnbuild.EndSponsoringFutureReserves{},
    }

    // Note that while A can submit this transaction, both sign it.
    SignAndSend(client, aAccount.AccountID, []*keypair.Full{S1, A}, sponsorTrustline...)
    fmt.Println("Sponsored a trustline of", A.Address())

    //
    // 2. Both S1 and S2 sponsor trustlines for Account A for different assets.
    //
    sponsorTrustline = []txnbuild.Operation{
        &txnbuild.BeginSponsoringFutureReserves{
            SourceAccount: s1Account.AccountID,
            SponsoredID:   addressA,
        },
        &txnbuild.ChangeTrust{
            Line:          &assets[1],
            Limit:         txnbuild.MaxTrustlineLimit,
        },
        &txnbuild.EndSponsoringFutureReserves{},

        &txnbuild.BeginSponsoringFutureReserves{
            SourceAccount: s2Account.AccountID,
            SponsoredID:   addressA,
        },
        &txnbuild.ChangeTrust{
            Line:          &assets[2],
            Limit:         txnbuild.MaxTrustlineLimit,
        },
        &txnbuild.EndSponsoringFutureReserves{},
    }

    // Note that all 3 accounts must approve/sign this transaction.
    SignAndSend(client, aAccount.AccountID, []*keypair.Full{S1, S2, A}, sponsorTrustline...)
    fmt.Println("Sponsored two trustlines of", A.Address())
```

<!-- tabs:end -->

### 2. Transferring sponsorship

Suppose that now Signer 1 wants to transfer the responsibility of sponsoring reserves for the trustline to Sponsor 2. This is accomplished by sandwiching the transfer between the `BEGIN/END_SPONSORING_FUTURE_RESERVES` operations. Both of the participants must sign the transaction, though either can submit it.

An intuitive way to think of a sponsorship transfer is that the very act of sponsorship is being sponsored by a new account. That is, the new sponsor takes over the responsibilities of the old sponsor by sponsoring a revocation.

<!-- tabs:start -->

#### **Javascript**

```js
//
// 3. Transfer sponsorship of B's second trustline from S1 to S2.
//
let tx = new sdk.TransactionBuilder(s1Account, { fee: sdk.BASE_FEE })
  .addOperation(
    sdk.Operation.beginSponsoringFutureReserves({
      source: S2.publicKey(),
      sponsoredId: S1.publicKey(),
    })
  )
  .addOperation(
    sdk.Operation.revokeTrustlineSponsorship({
      account: A.publicKey(),
      asset: assets[1],
    })
  )
  .addOperation(sdk.Operation.endSponsoringFutureReserves())
  .setNetworkPassphrase(sdk.Networks.TESTNET)
  .setTimeout(180)
  .build();

// Notice that while the old sponsor *sends* the transaction, both sponsors
// must *approve* the transfer.
tx.sign(S1, S2);
let txResponse = await server.submitTransaction(tx).catch(txCheck);
if (!txResponse) {
  return;
}

console.log("Transferred sponsorship for", A.publicKey());
```

#### **Go**

```go
    //
    // 3. Transfer sponsorship of B's second trustline from S1 to S2.
    //
    transferOps := []txnbuild.Operation{
        &txnbuild.BeginSponsoringFutureReserves{
            SourceAccount: s2Account.AccountID,
            SponsoredID:   S1.Address(),
        },
        &txnbuild.RevokeSponsorship{
            SponsorshipType: txnbuild.RevokeSponsorshipTypeTrustLine,
            Account:         &addressA,
            TrustLine: &txnbuild.TrustLineID{
                Account: addressA,
                Asset:   assets[1],
            },
        },
        &txnbuild.EndSponsoringFutureReserves{},
    }

    // Notice that while the old sponsor *sends* the transaction (in this case),
    // both sponsors must *approve* the transfer.
    SignAndSend(client, s1Account.AccountID, []*keypair.Full{S1, S2}, transferOps...)
    fmt.Println("Transferred sponsorship for", A.Address())
```

<!-- tabs:end -->

At this point, Signer 1 is only sponsoring the first asset (arbitrarily coded as ABCD), while Signer 2 is sponsoring the other two assets. (Recall that initially Signer 1 was also sponsoring EFGH.)

### 3. Sponsorship revocation

Finally, we can demonstrate complete revocation of sponsorships. Below, Signer 2 removes themselves from all responsibility over the two asset trustlines. Notice that Account A is not involved at all, since revocation should be performable purely at the sponsor’s discretion.

<!-- tabs:start -->

#### **Javascript**

```js
  //
  // 4. S2 revokes sponsorship of B's trustlines entirely.
  //
  let s2Account = await server.loadAccount(S2.publicKey()).catch(accountFail);
  let tx = new sdk.TransactionBuilder(s2Account, {fee: sdk.BASE_FEE})
    .addOperation(sdk.Operation.revokeTrustlineSponsorship({
      account: A.publicKey(),
      asset: assets[1],
    }))
    .addOperation(sdk.Operation.revokeTrustlineSponsorship({
      account: A.publicKey(),
      asset: assets[2],
    }))
    .setNetworkPassphrase(sdk.Networks.TESTNET)
    .setTimeout(180)
    .build();

  tx.sign(S2);
  let txResponse = await server.submitTransaction(tx).catch(txCheck);
  if (!txResponse) { return; }

  console.log("Revoked sponsorship for", A.publicKey());
} // ends main()
```

#### **Go**

```go
    //
    // 4. S2 revokes sponsorship of B's trustlines entirely.
    //
    revokeOps := []txnbuild.Operation{
        &txnbuild.RevokeSponsorship{
            SponsorshipType: txnbuild.RevokeSponsorshipTypeTrustLine,
            Account:         &addressA,
            TrustLine: &txnbuild.TrustLineID{
                Account: addressA,
                Asset:   assets[1],
            },
        },
        &txnbuild.RevokeSponsorship{
            SponsorshipType: txnbuild.RevokeSponsorshipTypeTrustLine,
            Account:         &addressA,
            TrustLine: &txnbuild.TrustLineID{
                Account: addressA,
                Asset:   assets[2],
            },
        },
    }

    SignAndSend(client, s2Account.AccountID, []*keypair.Full{S2}, revokeOps...)
    fmt.Println("Revoked sponsorship for", A.Address())
} // ends main()
```

<!-- tabs:end -->

### Sponsorship Source Accounts

> This relation is initiated by `BeginSponsoringFutureReservesOp`, where the sponsoring account is the source account, and is terminated by `EndSponsoringFutureReserveOp`, where the sponsored account is the source account.

Since the source account defaults to the transaction submitter when omitted, this field needs always needs to be set for either the `Begin` or the `End`.

For example, the following is an identical expression of the earlier Golang example of sponsoring a trustline, just submitted by the sponsor (Sponsor 1) rather than the sponsored account (Account A). Notice the differences in where `SourceAccount` is set:

<!-- tabs:start -->

#### **Go**

```go
    sponsorTrustline := []txnbuild.Operation{
        &txnbuild.BeginSponsoringFutureReserves{
            SponsoredID: addressA,
        },
        &txnbuild.ChangeTrust{
            SourceAccount: aAccount.AccountID,
            Line:          &assets[0],
            Limit:         txnbuild.MaxTrustlineLimit,
        },
        &txnbuild.EndSponsoringFutureReserves{
            SourceAccount: aAccount.AccountID,
        },
    }

    // Again, both participants must still sign the transaction: the sponsored
    // account must consent to the sponsorship.
    SignAndSend(client, s1Account.AccountID, []*keypair.Full{S1, A}, sponsorTrustline...)
```

<!-- tabs:end -->

### Footnote

For the above examples, an implementation of SignAndSend (Golang) and some (very) rudimentary error checking code (all languages) might look something like this:

<!-- tabs:start -->

#### **Javascript**

```js
function txCheck(err) {
  console.error("Transaction submission failed:", err);
  if (err.response != null && err.response.data != null) {
    console.error("More details:", err.response.data.extras);
  } else {
    console.error("Unknown reason:", err);
  }
}

function accountFail(err) {
  console.error(" Failed to load account:", err.response.body);
}
```

#### **Go**

```go
// Builds a transaction containing `operations...`, signed (by `signers`), and
// submitted using the given `client` on behalf of `account`.
func SignAndSend(
    client *sdk.Client,
    account txnbuild.Account,
    signers []*keypair.Full,
    operations ...txnbuild.Operation,
) protocol.Transaction {
    // Build, sign, and submit the transaction
    tx, err := txnbuild.NewTransaction(
        txnbuild.TransactionParams{
            SourceAccount:        account,
            IncrementSequenceNum: true,
            BaseFee:              txnbuild.MinBaseFee,
            Timebounds:           txnbuild.NewInfiniteTimeout(),
            Operations:           operations,
        },
    )
    check(err)

    for _, signer := range signers {
        tx, err = tx.Sign(network.TestNetworkPassphrase, signer)
        check(err)
    }

    txResp, err := client.SubmitTransaction(tx)
    if err != nil {
        if prob := sdk.GetError(err); prob != nil {
            fmt.Printf("  problem: %s\n", prob.Problem.Detail)
            fmt.Printf("  extras: %s\n", prob.Problem.Extras["result_codes"])
        }
        check(err)
    }

    return txResp
}

func check(err error) {
    if err != nil {
        panic(err)
    }
}
```

<!-- tabs:end -->
