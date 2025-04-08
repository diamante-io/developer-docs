# Extension docs

<br>

### Getting started

Once DIAM wallet is installed and running, every new tab you open has a window.diam object available in the developer console. This is how your website will interact with DIAM wallet.

### Browser Detection

To verify if the browser is running DIAM wallet, run the following code in your developer console:

```js
if (window.diam) {
  console.log("DIAM extension is installed!");
}
```

### Connecting to DIAM Wallet Extension

You should only initiate a connection request in response to direct user action, such as clicking a button. You should always disable the "connect" button while the connection request is pending. You should never initiate a connection request on page load.

### Accessing Accounts

To interact with the user's account in DIAM wallet, you must first connect to it. For connecting to the user account, you must send a connection request to the user. If the user confirms, you will receive the user account public keys as an array; otherwise, you will receive an error.

```js
// Attempt to connect the wallet
window.diam
  .connect()
  .then((result) => {
    console.log("Connect result:", result);

    // Extract the public key from the result
    const publicKeyData = result.message?.data?.[0];
    if (publicKeyData && publicKeyData.diamPublicKey) {
      console.log(`public key: ${publicKeyData.diamPublicKey}`);
    } else {
      console.error("diam PublicKey not found.");
    }
  })
  .catch((error) => {
    console.error("Error connecting wallet:", error);
  });
```

### Signing Transactions

Transactions are a formal action on a blockchain. They can contain a simple sending of Diam (Payment Operation) or sending tokens creating data on the blockchain network and so on.

In DIAM wallet, use the diam.sign method to send a transaction.

This function accepts a transaction envelope XDR, a boolean value for submiting the transaction or just return the signed xdr and network Passphrase(Diamante MainNet; SEP 2022 or Diamante Testnet 2024), When you put an XDR string, boolean value and network Passphrase inside this method and call it, DIAM wallet decodes it and shows its details to the user, if the user confirms and the boolean value is false, signs it, you receive the signed XDR or if the boolean is true, it submits the transaction and send the trasnsaction response as response.

```js
window.diam
  .sign(
    "AAAAAgAAAADD9u0l8B7fMgvRITQuplXFfTskVrNgTgyBN1heDfkLEAAAAGQApCseAAAAAQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAQAAAADId5UakWjIgj3XsdYXl/8mJKTpUSUIu8F3IcB7cKoQ1wAAAAAAAAAAAExLQAAAAAAAAAAA",
    true,
    "Diamante Testnet 2024"
  )
  .then((res) => console.log(res));
```
