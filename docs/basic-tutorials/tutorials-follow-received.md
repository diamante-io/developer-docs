# Follow Received Payments

This tutorial shows how easy it is to use aurora to watch for incoming payments on an account using go and EventSource. We will eschew using js-diamnet-sdk, the high-level helper library, to show that it is possible for you to perform this task on your own with whatever programming language you would like to use.

This tutorial assumes that you:

- Have node.js installed locally on your machine.
- Have curl installed locally on your machine.
- Are running on Linux, macOS, or any other system that has access to a bash-like shell.
- Are familiar with launching and running commands in a terminal.

In this tutorial, we will learn:

1. How to create a new account.
2. How to fund your account using friendbot.
3. How to follow payments to your account using curl and EventSource.

## Project Skeleton

Let's get started by building our project skeleton:

```bash
$ mkdir follow_tutorial
$ cd follow_tutorial
$ npm install --save diamante-base
$ npm install --save eventsource
```

This should have created a package.json in the follow_tutorial directory. You can check that everything went well by running the following command:

```bash
$ node -e "require('diamante-base')"
```

Everything was successful if no output was generated from the above command. Now let's write a script to create a new account.

## Creating an account

Create a new file named make_account.js and paste the following text into it:

```js
var Keypair = require("diamante-base").Keypair;

var newAccount = Keypair.random();

console.log("New key pair created!");
console.log("  Account ID: " + newAccount.publicKey());
console.log("  Secret: " + newAccount.secret());
```

Save the file and run it:

```bash
$ node make_account.js
New key pair created!
  Account ID: GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3
  Secret: SCU36VV2OYTUMDSSU4EIVX4UUHY3XC7N44VL4IJ26IOG6HVNC7DY5UJO
$
```

Before our account can do anything it must be funded. Indeed, before an account is funded it does not truly exist!

## Funding your account

The diamcircle test network provides the Friendbot, a tool that developers can use to get testnet diams for testing purposes. To fund your account, simply execute the following curl command:

```bash
$ curl "https://friendbot.diamcircle.io/?addr=GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3"
```

Don't forget to replace the account id above with your own. If the request succeeds, you should see a response like:

```json5
{
  hash: "ed9e96e136915103f5d8978cbb2036628e811f2c59c4c3d88534444cf504e360",
  result: "received",
  submission_result: "000000000000000a0000000000000001000000000000000000000000",
}
```

After a few seconds, the diamcircle network will perform consensus, close the ledger, and your account will have been created. Next up we will write a command that watches for new payments to your account and outputs a message to the terminal.

## Following payments using curl

To follow new payments connected to your account you simply need to send the Accept: text/event-stream header to the /payments endpoint.

```bash
$ curl -H "Accept: text/event-stream" "https://diamtestnet.diamcircle.io/accounts/GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3/payments"
```

As a result you will see something like:

```bash
retry: 1000
event: open
data: "hello"

id: 713226564145153
data: {"_links":{"effects":{"href":"/operations/713226564145153/effects/{?cursor,limit,order}","templated":true},
       "precedes":{"href":"/operations?cursor=713226564145153\u0026order=asc"},
       "self":{"href":"/operations/713226564145153"},
       "succeeds":{"href":"/operations?cursor=713226564145153\u0026order=desc"},
       "transactions":{"href":"/transactions/713226564145152"}},
       "account":"GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3",
       "funder":"GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K",
       "id":713226564145153,
       "paging_token":"713226564145153",
       "starting_balance":"10000",
       "type_i":0,
       "type":"create_account"}
```

Every time you receive a new payment you will get a new row of data. Payments is not the only endpoint that supports streaming. You can also stream transactions /transactions and operations /operations.

## Following payments using EventStream

Another way to follow payments is writing a simple JS script that will stream payments and print them to console. Create stream_payments.js file and paste the following code into it:

```js
var EventSource = require("eventsource");
var es = new EventSource(
  "https://diamtestnet.diamcircle.io/accounts/GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3/payments"
);
es.onmessage = function (message) {
  var result = message.data ? JSON.parse(message.data) : message;
  console.log("New payment:");
  console.log(result);
};
es.onerror = function (error) {
  console.log("An error occurred!");
};
```

Now, run our script: node stream_payments.js. You should see following output:

```bash
New payment:
{ _links:
   { effects:
      { href: '/operations/713226564145153/effects/{?cursor,limit,order}',
        templated: true },
     precedes: { href: '/operations?cursor=713226564145153&order=asc' },
     self: { href: '/operations/713226564145153' },
     succeeds: { href: '/operations?cursor=713226564145153&order=desc' },
     transactions: { href: '/transactions/713226564145152' } },
  account: 'GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3',
  funder: 'GBS43BF24ENNS3KPACUZVKK2VYPOZVBQO2CISGZ777RYGOPYC2FT6S3K',
  id: 713226564145153,
  paging_token: '713226564145153',
  starting_balance: '10000',
  type_i: 0,
  type: 'create_account' }
```

## Testing it out

We now know how to get a stream of transactions to an account. Let's check if our solution actually works and if new payments appear. Let's watch as we send a payment (`create_account` operation) from our account to another account.

We use the `create_account` operation because we are sending payment to a new, unfunded account. If we were sending payment to an account that is already funded, we would use the `payment` operation.

First, let's check our account sequence number so we can create a payment transaction. To do this we send a request to aurora:

```bash
$ curl "https://diamtestnet.diamcircle.io/accounts/GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3"
```

Sequence number can be found under the sequence field. For our example, the current sequence number is `713226564141056`. Save your value somewhere.

Now, create `make_payment.js` file and paste the following code into it, replacing the sequence number accordingly:

```js
var DiamBase = require("diamante-base");
var DiamSdk = require("diamnet-sdk");

var keypair = DiamBase.Keypair.fromSecret(
  "SCU36VV2OYTUMDSSU4EIVX4UUHY3XC7N44VL4IJ26IOG6HVNC7DY5UJO"
);
var account = new DiamBase.Account(keypair.publicKey(), "713226564141056");

var amount = "100";
var transaction = new DiamSdk.TransactionBuilder(account, {
  networkPassphrase: DiamBase.Networks.TESTNET,
  fee: DiamSdk.BASE_FEE,
})
  .addOperation(
    DiamBase.Operation.createAccount({
      destination: DiamBase.Keypair.random().publicKey(),
      startingBalance: amount,
    })
  )
  .setTimeout(180)
  .build();

transaction.sign(keypair);

console.log(transaction.toEnvelope().toXDR().toString("base64"));
```

After running this script you should see a signed transaction blob. To submit this transaction we send it to aurora or diamcircle-Core. But before we do, let's open a new console and start our previous script by `node stream_payments.js`.

Now to send a transaction just use aurora:

```bash
curl -H "Content-Type: application/json" -X POST -d '{"tx":"AAAAAgAAAAB+kqu+heHB1TFrxhuALTbRVSL2slMUoEeNNaz2PXo90wAAAGQAAoitAAAAAQAAAAEAAAAAAAAAAAAAAABgJHaDAAAAAAAAAAEAAAAAAAAAAAAAAAByS4gefO1iu/ZfYlr+PMA2AZsHJmSK/4NActJ1Oa1BIgAAAAA7msoAAAAAAAAAAAE9ej3TAAAAQPo1YHJMpdWKatEQxj7DqP1rrR6pA+OjK9q3WcU/sBwvKk6GhpdwA3gkUDrkREU0cFQSNKwugNFkGkR0zFmROgw="}' "https://diamtestnet.diamcircle.io/transactions"
```

You should see a new payment in a window running `stream_payments.js` script.
