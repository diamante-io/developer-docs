# Create an Account

Before we get started with working with Diamante in code, consider going through the following examples using the Diamante Laboratory. The lab allows you to create accounts, fund accounts on the Diamante test network, build transactions, run any operation, and inspect responses from aurora via the Endpoint Explorer.

Accounts are a fundamental building block of Diamante: they hold all your balances, allow you to send and receive payments, and let you place offers to buy and sell assets. Since pretty much everything on Diamante is in some way tied to an account, the first thing you generally need to do when you start developing is to create one. This beginner-level tutorial will show you how to do that.

## Create a Keypair

Diamante uses public key cryptography to ensure that every transaction is secure: every Diamante account has a keypair consisting of a public key and a secret key. The public key is always safe to share — other people need it to identify your account and verify that you authorized a transaction. It's like an email address. The secret key, however, is private information that proves you own — and gives you access to — your account. It's like a password, and you should never share it with anyone.

Before creating an account, you need to generate your own keypair:

<!-- tabs:start -->

#### **Javascript**

```js
var DiamSdk = require("diamnet-sdk");

// create a completely new and unique pair of keys
const pair = DiamSdk.Keypair.random();

pair.secret();
// SAV76USXIJOBMEQXPANUOQM6F5LIOTLPDIDVRJBFFE2MDJXG24TAPUU7
pair.publicKey();
// GCFXHS4GXL6BVUCXBWXGTITROWLVYXQKQLF4YH5O5JT3YZXCYPAFBJZB
```

#### **Go**

```go
package main

import (
    "log"

    "github.com/diamcircle/go/keypair"
)

func main() {
    pair, err := keypair.Random()
    if err != nil {
        log.Fatal(err)
    }

    log.Println(pair.Seed())
    // SAV76USXIJOBMEQXPANUOQM6F5LIOTLPDIDVRJBFFE2MDJXG24TAPUU7
    log.Println(pair.Address())
    // GCFXHS4GXL6BVUCXBWXGTITROWLVYXQKQLF4YH5O5JT3YZXCYPAFBJZB
}
```

<!-- tabs:end -->

## Create a new account

A valid keypair, however, does not make an account: to prevent unused accounts from bloating the ledger, Diamante requires accounts to hold a minimum balance of 1 DIAM before they actually exist. Until it gets a bit of funding, your keypair doesn't warrant space on the ledger.

On the public network, where live users make live transactions, your next step would be to acquire DIAMs, which you can do by consulting our DIAM buying guide. Because this tutorial runs on the test network, you can get 500 test DIAMs from Friendbot, which is a friendly account funding tool.

To do that, send Friendbot the public key you created. It’ll create and fund a new account using that public key as the account ID.

<!-- tabs:start -->

#### **Javascript**

```js
// The SDK does not have tools for creating test accounts, so you'll have to
// make your own HTTP request.

// if you're trying this on Node, install the `node-fetch` library and
// uncomment the next line:
// const fetch = require('node-fetch');

(async function main() {
  try {
    const response = await fetch(
      `https://friendbot.diamcircle.io?addr=${encodeURIComponent(
        pair.publicKey()
      )}`
    );
    const responseJSON = await response.json();
    console.log("SUCCESS! You have a new account :)\n", responseJSON);
  } catch (e) {
    console.error("ERROR!", e);
  }
  // After you've got your test lumens from friendbot, we can also use that account to create a new account on the ledger.
  try {
    const server = new DiamSdk.Aurora.Server(
      "https://diamtestnet.diamcircle.io/"
    );
    var parentAccount = await server.loadAccount(pair.publicKey()); //make sure the parent account exists on ledger
    var childAccount = DiamSdk.Keypair.random(); //generate a random account to create
    //create a transacion object.
    var createAccountTx = new DiamSdk.TransactionBuilder(parentAccount, {
      fee: DiamSdk.BASE_FEE,
      networkPassphrase: DiamSdk.Networks.TESTNET,
    });
    //add the create account operation to the createAccountTx transaction.
    createAccountTx = await createAccountTx
      .addOperation(
        DiamSdk.Operation.createAccount({
          destination: childAccount.publicKey(),
          startingBalance: "5",
        })
      )
      .setTimeout(180)
      .build();
    //sign the transaction with the account that was created from friendbot.
    await createAccountTx.sign(pair);
    //submit the transaction
    let txResponse = await server
      .submitTransaction(createAccountTx)
      // some simple error handling
      .catch(function (error) {
        console.log("there was an error");
        console.log(error.response);
        console.log(error.status);
        console.log(error.extras);
        return error;
      });
    console.log(txResponse);
    console.log("Created the new account", childAccount.publicKey());
  } catch (e) {
    console.error("ERROR!", e);
  }
})();
```

#### **Go**

```go
package main

import (
    "net/http"
    "io/ioutil"
    "log"
    "fmt"
)

func main() {
    // pair is the pair that was generated from previous example, or create a pair based on
    // existing keys.
    address := pair.Address()
    resp, err := http.Get("https://friendbot.diamcircle.io/?addr=" + address)
    if err != nil {
        log.Fatal(err)
    }

    defer resp.Body.Close()
    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(string(body))
}
```

<!-- tabs:end -->

Now for the last step: getting the account’s details and checking its balance. Accounts can carry multiple balances — one for each type of currency they hold.

<!-- tabs:start -->

#### **Javascript**

```js
const server = new DiamSdk.Aurora.Server("https://diamtestnet.diamcircle.io/");

// the JS SDK uses promises for most actions, such as retrieving an account
const account = await server.loadAccount(pair.publicKey());
console.log("Balances for account: " + pair.publicKey());
account.balances.forEach(function (balance) {
  console.log("Type:", balance.asset_type, ", Balance:", balance.balance);
});
```

#### **Go**

```go
package main

import (
    "log"

    "github.com/diamcircle/go/clients/auroraclient"
)

func main() {
    // Replace this with the output from earlier, or use pair.Address()
    address := "GCFXHS4GXL6BVUCXBWXGTITROWLVYXQKQLF4YH5O5JT3YZXCYPAFBJZB"

    request := auroraclient.AccountRequest{AccountID: address}
    account, err := auroraclient.DefaultTestNetClient.AccountDetail(request)
    if err != nil {
        log.Fatal(err)
    }

    log.Println("Balances for account:", address)

    for _, balance := range account.Balances {
        log.Println(balance)
    }
}
```

<!-- tabs:end -->

Now that you’ve got an account, you can start sending and receiving payments, or, if you're ready to hunker down, you can skip ahead and build a wallet or issue a diamcircle-network asset.
