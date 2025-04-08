# Send and Receive Payments

Most of the time, you’ll be sending money to someone else who has their own account. For this tutorial, however, you'll need a second account to transact with. So before proceeding, follow the steps outlined in [Create an Account](/basic-tutorials/tutorials-account?id=create-an-account) to make two accounts: one for sending and one for receiving.

## About Operations and Transactions

Actions that do things on Diamante — like sending payments or making buy or sell offers — are called [operations](/fundamentals/datastructures?id=operations). To submit an operation to the network, you bundle it into a [transaction](/fundamentals/datastructures?id=transactions), which is a group of anywhere from 1 to 100 operations accompanied by some extra information, like which account is making the transaction and a cryptographic signature to verify that the transaction is authentic.

Transactions are atomic, meaning that if any operation in a transaction fails, they all fail. Let’s say you have 100 DIAM and you make two payment operations of 60 DIAM each. If you make two transactions (each with one operation), the first will succeed and the second will fail because you don’t have enough DIAM. You’ll be left with 40 DIAM. However, if you group the two payments into a single transaction, they will both fail, and you’ll be left with the full 100 DIAM still in your account.

Every transaction also incurs a small fee. Like the minimum balance on accounts, this fee deters spam and prevents people from overloading the system. This base fee is very small — 100 jots per operation, where a jot equals 1 \* 10^-7 DIAM — and it's charged for each operation in a transaction. A transaction with two operations, for instance, would cost 200 jots.

> In the following code samples, proper error checking is omitted for brevity. However, you should always validate your results, as there are many ways that requests can fail. You should refer to the guide on Error Handling for tips on error management strategies.

## Send a Payment

Diamante stores and communicates transaction data in a binary format called XDR, which is optimized for network performance but unreadable to the human eye. Luckily, aurora, the Diamante API, and the Diamante SDKs convert XDRs into friendlier formats. Here’s how you might send 10 DIAM to an account:

<!-- tabs:start -->

#### **Javascript**

```js
var server = new DiamSdk.Aurora.Server("https://diamtestnet.diamcircle.io");
var sourceKeys = DiamSdk.Keypair.fromSecret(
  "SD75G4MIKTXGW4KHJCCJ2TVLNIRVN2W5PDIU6A6645XIBZ4EUHKVAQND"
);
var destinationId = "GC4ZJJRESNHECNST6HA5HUBYAUUGETMKGESJMEKYQLYBCQXTLYNVCUY7";
// Transaction will hold a built transaction we can resubmit if the result is unknown.
var transaction;

// First, check to make sure that the destination account exists.
// You could skip this, but if the account does not exist, you will be charged
// the transaction fee when the transaction fails.
server
  .loadAccount(destinationId)
  // If the account is not found, surface a nicer error message for logging.
  .catch(function (error) {
    if (error instanceof DiamSdk.NotFoundError) {
      throw new Error("The destination account does not exist!");
    } else return error;
  })
  // If there was no error, load up-to-date information on your account.
  .then(function () {
    return server.loadAccount(sourceKeys.publicKey());
  })
  .then(function (sourceAccount) {
    // Start building the transaction.
    transaction = new DiamSdk.TransactionBuilder(sourceAccount, {
      fee: DiamSdk.BASE_FEE,
      networkPassphrase: DiamSdk.Networks.TESTNET,
    })
      .addOperation(
        DiamSdk.Operation.payment({
          destination: destinationId,
          // Because Diamante allows transaction in many currencies, you must
          // specify the asset type. The special "native" asset represents Lumens.
          asset: DiamSdk.Asset.native(),
          amount: "10",
        })
      )
      // A memo allows you to add your own metadata to a transaction. It's
      // optional and does not affect how Diamante treats the transaction.
      .addMemo(DiamSdk.Memo.text("Test Transaction"))
      // Wait a maximum of three minutes for the transaction
      .setTimeout(180)
      .build();
    // Sign the transaction to prove you are actually the person sending it.
    transaction.sign(sourceKeys);
    // And finally, send it off to Diamante!
    return server.submitTransaction(transaction);
  })
  .then(function (result) {
    console.log("Success! Results:", result);
  })
  .catch(function (error) {
    console.error("Something went wrong!", error);
    // If the result is unknown (no response body, timeout etc.) we simply resubmit
    // already built transaction:
    // server.submitTransaction(transaction);
  });
```

#### **Go**

```go
package main

import (
    "github.com/diamcircle/go/keypair"
    "github.com/diamcircle/go/network"
    "github.com/diamcircle/go/txnbuild"
    "github.com/diamcircle/go/clients/auroraclient"
    "fmt"
)

func main () {
    source := "SCZANGBA5YHTNYVVV4C3U252E2B6P6F5T3U6MM63WBSBZATAQI3EBTQ4"
    destination := "GA2C5RFPE6GCKMY3US5PAB6UZLKIGSPIUKSLRB6Q723BM2OARMDUYEJ5"
    client := auroraclient.DefaultTestNetClient

    // Make sure destination account exists
    destAccountRequest := auroraclient.AccountRequest{AccountID: destination}
    destinationAccount, err := client.AccountDetail(destAccountRequest)
    if err != nil {
        panic(err)
    }

    fmt.Println("Destination Account", destinationAccount)

    // Load the source account
    sourceKP := keypair.MustParseFull(source)
    sourceAccountRequest := auroraclient.AccountRequest{AccountID: sourceKP.Address()}
    sourceAccount, err := client.AccountDetail(sourceAccountRequest)
    if err != nil {
        panic(err)
    }

    // Build transaction
    tx, err := txnbuild.NewTransaction(
      txnbuild.TransactionParams{
        SourceAccount:        &sourceAccount,
        IncrementSequenceNum: true,
        BaseFee:              txnbuild.MinBaseFee,
        Preconditions: txnbuild.Preconditions{
          TimeBounds: txnbuild.NewInfiniteTimeout(), // Use a real timeout in production!
        },
        Operations: []txnbuild.Operation{
          &txnbuild.Payment{
            Destination: destination,
            Amount:      "10",
            Asset:       txnbuild.NativeAsset{},
          },
        },
      },
    )

    if err != nil {
        panic(err)
    }

    // Sign the transaction to prove you are actually the person sending it.
    tx, err = tx.Sign(network.TestNetworkPassphrase, sourceKP)
    if err != nil {
        panic(err)
    }

    // And finally, send it off to diamcircle!
    resp, err := auroraclient.DefaultTestNetClient.SubmitTransaction(tx)
    if err != nil {
        panic(err)
    }

    fmt.Println("Successful Transaction:")
    fmt.Println("Ledger:", resp.Ledger)
    fmt.Println("Hash:", resp.Hash)
}
```

<!-- tabs:end -->

What exactly happened there? Let’s break it down.

1. Confirm that the account ID (aka the public key) you are sending to actually exists by loading the associated account data from the diamcircle network. It's okay to skip this step, but it gives you an opportunity to avoid making a transaction that will inevitably fail.

<!-- tabs:start -->

#### **Javascript**

```js
server.loadAccount(destinationId).then(function (account) {
  /* validate the account */
});
```

#### **Go**

```go
destAccountRequest := auroraclient.AccountRequest{AccountID: destination}
destinationAccount, err := client.AccountDetail(destAccountRequest)
if err != nil {
    panic(err)
}
fmt.Println("Destination Account", destinationAccount)
```

<!-- tabs:end -->

2. Load data for the account you are sending from. An account can only perform one transaction at a time and has something called a sequence number, which helps diamcircle verify the order of transactions. A transaction’s sequence number needs to match the account’s sequence number, so you need to get the account’s current sequence number from the network.

<!-- tabs:start -->

#### **Javascript**

```js
.then(function() {
return server.loadAccount(sourceKeys.publicKey());
})
```

#### **Go**

```go
sourceKP := keypair.MustParseFull(source)
sourceAccountRequest := auroraclient.AccountRequest{AccountID: sourceKP.Address()}
sourceAccount, err := client.AccountDetail(sourceAccountRequest)
if err != nil {
  panic(err)
}
```

<!-- tabs:end -->

3. Start building a transaction. This requires an account object, not just an account ID, because it will increment the account’s sequence number.

<!-- tabs:start -->

#### **Javascript**

```js
var transaction = new DiamSdk.TransactionBuilder(sourceAccount);
```

#### **Go**

```go
tx, err := txnbuild.NewTransaction(
  txnbuild.TransactionParams{
    SourceAccount:        &sourceAccount,
    IncrementSequenceNum: true,
    BaseFee:              MinBaseFee,
    Preconditions: txnbuild.Preconditions{
      TimeBounds: txnbuild.NewInfiniteTimeout(), // Use a real timeout in production!
    },
    ...
  },
)

if err != nil {
    panic(err)
}
```

<!-- tabs:end -->

4. Add the payment operation to the account. Note that you need to specify the type of asset you are sending: Diamante’s network currency is the diam, but you can send any asset issued on the network. We'll cover sending non-diam assets below. For now, though, we’ll stick to DIAM

<!-- tabs:start -->

#### **Javascript**

```js
.addOperation(DiamSdk.Operation.payment({
  destination: destinationId,
  asset: DiamSdk.Asset.native(),
  amount: "10"
}))
```

#### **Go**

```go
Operations: []txnbuild.Operation{
    &txnbuild.Payment{
      Destination: destination,
      Amount:      "10",
      Asset:       txnbuild.NativeAsset{},
    },
  },
```

<!-- tabs:end -->

You should also note that the amount is a string rather than a number. When working with extremely small fractions or large values, floating point math can introduce small inaccuracies. Since not all systems have a native way to accurately represent extremely small or large decimals, diamcircle uses strings as a reliable way to represent the exact amount across any system.

5. Optionally, you can add your own metadata, called a memo, to a transaction. diamcircle doesn’t do anything with this data, but you can use it for any purpose you’d like. Many exchanges require memos for incoming transactions because they use a single diamcircle account for all their users and rely on the memo to differentiate between internal user accounts.

<!-- tabs:start -->

#### **Javascript**

```js
.addMemo(DiamSdk.Memo.text('Test Transaction'))
```

#### **Go**

```go
Memo: txnbuild.MemoText("Test Transaction")
```

<!-- tabs:end -->

6. Now that the transaction has all the data it needs, you have to cryptographically sign it using your secret key. This proves that the data actually came from you and not someone impersonating you.

<!-- tabs:start -->

#### **Javascript**

```js
transaction.sign(sourceKeys);
```

#### **Go**

```go
tx, err = tx.Sign(network.TestNetworkPassphrase, sourceKP)
if err != nil {
    panic(err)
}
```

<!-- tabs:end -->

7. And finally, submit it to the Diamante network!

<!-- tabs:start -->

#### **Javascript**

```js
server.submitTransaction(transaction);
```

#### **Go**

```go
resp, err := auroraclient.DefaultTestNetClient.SubmitTransaction(tx)
if err != nil {
    panic(err)
}
```

<!-- tabs:end -->

## Receive a Payment

You don’t actually need to do anything to receive payments into a diamcircle account: if a payer makes a successful transaction to send assets to you, those assets will automatically be added to your account.

However, you may want to keep an eye out for incoming payments. A simple program that watches the network for payments and prints each one might look like:

<!-- tabs:start -->

#### **Javascript**

```js
var DiamSdk = require("diamnet-sdk");

var server = new DiamSdk.Aurora.Server("https://diamtestnet.diamcircle.io");
var accountId = "GC2BKLYOOYPDEFJKLKY6FNNRQMGFLVHJKQRGNSSRRGSMPGF32LHCQVGF";

// Create an API call to query payments involving the account.
var payments = server.payments().forAccount(accountId);

// If some payments have already been handled, start the results from the
// last seen payment. (See below in `handlePayment` where it gets saved.)
var lastToken = loadLastPagingToken();
if (lastToken) {
  payments.cursor(lastToken);
}

// `stream` will send each recorded payment, one by one, then keep the
// connection open and continue to send you new payments as they occur.
payments.stream({
  onmessage: function (payment) {
    // Record the paging token so we can start from here next time.
    savePagingToken(payment.paging_token);

    // The payments stream includes both sent and received payments. We only
    // want to process received payments here.
    if (payment.to !== accountId) {
      return;
    }

    // In Diamante’s API, Lumens are referred to as the “native” type. Other
    // asset types have more detailed information.
    var asset;
    if (payment.asset_type === "native") {
      asset = "diam";
    } else {
      asset = payment.asset_code + ":" + payment.asset_issuer;
    }

    console.log(payment.amount + " " + asset + " from " + payment.from);
  },

  onerror: function (error) {
    console.error("Error in payment stream");
  },
});

function savePagingToken(token) {
  // In most cases, you should save this to a local database or file so that
  // you can load it next time you stream new payments.
}

function loadLastPagingToken() {
  // Get the last paging token from a local database or file
}
```

#### **Go**

```go
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/diamcircle/go/clients/auroraclient"
    "github.com/diamcircle/go/protocols/aurora/operations"
)

func main() {
    client := auroraclient.DefaultTestNetClient
    opRequest := auroraclient.OperationRequest{ForAccount: "GC2BKLYOOYPDEFJKLKY6FNNRQMGFLVHJKQRGNSSRRGSMPGF32LHCQVGF", Cursor: "now"}

    ctx, cancel := context.WithCancel(context.Background())
    go func() {
        // Stop streaming after 60 seconds.
        time.Sleep(60 * time.Second)
        cancel()
    }()

    printHandler := func(op operations.Operation) {
        fmt.Println(op)
    }
    err := client.StreamPayments(ctx, opRequest, printHandler)
    if err != nil {
        fmt.Println(err)
    }

}
```

<!-- tabs:end -->

There are two main parts to this program. First, you create a query for payments involving a given account. Like most queries in diamcircle, this could return a huge number of items, so the API returns paging tokens, which you can use later to start your query from the same point where you previously left off. In the example above, the functions to save and load paging tokens are left blank, but in a real application, you’d want to save the paging tokens to a file or database so you can pick up where you left off in case the program crashes or the user closes it.

<!-- tabs:start -->

#### **Javascript**

```js
var payments = server.payments().forAccount(accountId);
var lastToken = loadLastPagingToken();
if (lastToken) {
  payments.cursor(lastToken);
}
```

#### **Go**

```go
client := auroraclient.DefaultTestNetClient
opRequest := auroraclient.OperationRequest{ForAccount: "GC2BKLYOOYPDEFJKLKY6FNNRQMGFLVHJKQRGNSSRRGSMPGF32LHCQVGF", Cursor: "now"}
```

<!-- tabs:end -->

Second, the results of the query are streamed. This is the easiest way to watch for payments or other transactions. Each existing payment is sent through the stream, one by one. Once all existing payments have been sent, the stream stays open and new payments are sent as they are made.

Try it out: Run this program, and then, in another window, create and submit a payment. You should see this program log the payment.

<!-- tabs:start -->

#### **Javascript**

```js
payments.stream({
  onmessage: function (payment) {
    // handle a payment
  },
});
```

#### **Go**

```go
ctx, cancel := context.WithCancel(context.Background())
go func() {
    // Stop streaming after 60 seconds.
    time.Sleep(60 * time.Second)
    cancel()
}()

printHandler := func(op operations.Operation) {
    fmt.Println(op)
}
err := client.StreamPayments(ctx, opRequest, printHandler)
if err != nil {
    fmt.Println(err)
}
```

<!-- tabs:end -->

You can also request payments in groups or pages. Once you’ve processed each page of payments, you’ll need to request the next one until there are none left.

<!-- tabs:start -->

#### **Javascript**

```js
payments.call().then(function handlePage(paymentsPage) {
  paymentsPage.records.forEach(function (payment) {
    // handle a payment
  });
  return paymentsPage.next().then(handlePage);
});
```

<!-- tabs:end -->
