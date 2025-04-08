# Manage Data

The Diamante network allows you to store and retrieve data on the ledger using the ManageData operation. This operation lets you create, update, or delete data entries associated with an account.

## About ManageData Operation

The ManageData operation is used to modify data entries on the Diamante network. Each account can store up to 64 data entries, each of which can hold up to 64 bytes of data. Data entries are identified by a unique key (up to 64 bytes) and can hold any value (also up to 64 bytes).

Every ManageData operation incurs a small fee. This fee deters spam and prevents people from overloading the system. The base fee is very small and it's charged for each operation in a transaction.

## Set Data

<!-- tabs:start -->

#### **Javascript**

```js
var server = new DiamSdk.Aurora.Server("https://diamtestnet.diamcircle.io");
var sourceKeys = DiamSdk.Keypair.fromSecret(
  "SCE3MU32ZI3IDCMSC4TKNUCNU4VKVD6HCLZZX2KYQJKG6XADZMRKM4VU"
);

var transaction;

server
  .loadAccount(sourceKeys.publicKey())
  .then(function (sourceAccount) {
    // Start building the transaction.
    transaction = new DiamSdk.TransactionBuilder(sourceAccount, {
      fee: DiamSdk.BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(
        DiamSdk.Operation.manageData({
          name: "MyDataEntry", // The name of the data entry
          value: "Hello, Diamante!", // The value to store
        })
      )
      .setTimeout(0)
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
  });
```

#### **Go**

```go
package main

import (
	"fmt"

	"github.com/diamcircle/go/clients/auroraclient"
	"github.com/diamcircle/go/keypair"
	"github.com/diamcircle/go/network"
	"github.com/diamcircle/go/txnbuild"
)

func main() {
	source := "SCKY763IROKEGHYFEWNCO6MCVWJN7L6OOGKMNEFHRB7VTLVC36LWI7ML"
	client := auroraclient.DefaultTestNetClient

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
			Timebounds:           txnbuild.NewInfiniteTimeout(),
			Operations: []txnbuild.Operation{
				&txnbuild.ManageData{
					Name:  "MyDataEntry",
					Value: []byte("Hello, Diamante!"),
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

	// And finally, send it off to diamante!
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

## Delete Data

To delete a data entry, you can use the ManageData operation with a blank value:

<!-- tabs:start -->

#### **Javascript**

```js
var transaction;

server
  .loadAccount(sourceKeys.publicKey())
  .then(function (sourceAccount) {
    // Start building the transaction.
    transaction = new DiamSdk.TransactionBuilder(sourceAccount, {
      fee: DiamSdk.BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(
        DiamSdk.Operation.manageData({
          name: "MyDataEntry", // The name of the data entry
          value: "", // Set value to an empty string to delete the data entry
        })
      )
      .setTimeout(0)
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
  });
```

#### **Go**

```go
tx, err := txnbuild.NewTransaction(
  txnbuild.TransactionParams{
    SourceAccount:        &sourceAccount,
    IncrementSequenceNum: true,
    BaseFee:              txnbuild.MinBaseFee,
    Timebounds:           txnbuild.NewInfiniteTimeout(),
    Operations: []txnbuild.Operation{
      &txnbuild.ManageData{
        Name:  "MyDataEntry",
        Value: []byte{},
      },
    },
  },
)

if err != nil {
    panic(err)
}

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
##  Get Data Entries
Load the target account. Access the `data_attr` property to get all key-value pairs.
<!-- tabs:start -->

#### **Javascript**

```js
async function getDataEntries(sourcePublicKey) {
    const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

    try {
        // Load the account
        const account = await server.loadAccount(sourcePublicKey);

        // Log the data entries (key-value pairs)
        console.log("Data entries for account:", account.data_attr);
    } catch (error) {
        console.error("Error loading account:", error);
    }
}
await getDataEntries("GDC5ZMDJX6CREOCQORHUTGEMBJE6ZLG3YCBNYGBRCXV5NGQSDBO7EGC3");
```
<!-- tabs:end -->
The following table outlines the functions available for managing data entries:

| Function          | Purpose                                                  |
|-------------------|----------------------------------------------------------|
| `setDataEntry`    | Create or update a data entry (key-value pair).          |
| `deleteDataEntry` | Remove an existing data entry by setting it to null.    |
| `getDataEntries`  | Retrieve and view all data entries for an account.      |
