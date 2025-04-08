# Create Passive Sell Offer

The `Create Passive Sell Offer` operation allows users to create an order to sell one asset for another. This type of sell offer does not immediately match and consume any existing offers of the same price in the market. Instead, it is designed to sit passively on the order book until matched by other incoming offers.

### Key Characteristics:

1. **Passive Behavior**:

- Unlike a normal sell offer, which may instantly execute against matching offers, the passive sell offer waits to be taken by other market participants.
- It allows the offer creator to avoid accidentally matching with their own buy offers at the same price.

2. **Threshold**:

- This operation requires a medium threshold, meaning it needs appropriate account authorization.

3. **Result**:

- The outcome of this operation is represented by ManageSellOfferResult, which provides details such as success or failure and the status of the offer after execution.

### Use Case

`Create Passive Sell Offer` is used to place a sell order for an asset on the blockchain that does not immediately match with existing offers of the same price. It is ideal for avoiding self-trading and providing liquidity by allowing other users to take the offer. This operation is commonly used in decentralized exchanges (DEX) to maintain order book stability.

### Key Components

1. `selling`: The asset the user is selling (DIAM [native]in this case).
2. `buying`: The asset the user is buying (CAT token).
3. `amount`: The quantity of the selling asset to offer (e.g., 1 DIAM).
4. `price`: The price at which 1 unit of the selling asset is exchanged for the buying asset (e.g., 1 DIAM = 1 CAT).

1 - We'll start, as always, with our SDK and helper utilities and Network configuration

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Asset,
  Aurora,
  BASE_FEE,
  Keypair,
  Operation,
  TransactionBuilder,
} = require("diamnet-sdk");
// Network configuration
const NETWORK_PASSPHRASE = "Diamante Testnet 2024";
const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");
```

<!-- tabs:end -->

2 - This function defines the process for creating the passive sell offer, which will be submitted to the Diamante testnet. And Converts the secret key into a Keypair object. And Loads the account on the Diamante blockchain using the public key derived from the secret key.Define the Selling and Buying Assets Asset.native(): This represents the native asset (e.g., `DIAM`, the main currency of Diamante blockchain).` Asset`("CAT", issuer): This defines a custom asset named "CAT" with the specified issuer public key.

<!-- tabs:start -->

#### **Javascript**

```js
const secret = "SBM63RUOUMKZRWBZER6WLV4UM2RYNTHAWCQZAZ42BBCWHFGJBHDVXL3T"; //Replace with your Secreate key
async function createPassiveSellOffer(secret) {
const sourceKeypair = Keypair.fromSecret(secret);
const account = await server.loadAccount(sourceKeypair.publicKey());
const sellingAsset = Asset.native();
const buyingAsset = new Asset("CAT", "GBHHU65KNWOSXH3HWPADXMONMIVDH4V4PRXSNBWFKVCEW27HEESJXZIH");//asset the user is buying
```

<!-- tabs:end -->

3 -**TransactionBuilder(account, options)**: Initializes the transaction builder using the loaded account and the specified fee for createPassiveSellOffer operation to the transaction. and tx.sign(sourceKeypair): Signs the transaction using the Keypair derived from the secret key. This ensures that the transaction is authorized by the account owner. server.submitTransaction(tx): Submits the signed transaction to the Diamante blockchain. If the transaction is successful, it logs the transaction hash.

<!-- tabs:start -->

#### **Javascript**

```js
const tx = new TransactionBuilder(account, {
  fee: BASE_FEE,
  networkPassphrase: NETWORK_PASSPHRASE,
})
  .addOperation(
    Operation.createPassiveSellOffer({
      selling: sellingAsset,
      buying: buyingAsset,
      amount: "1", // Amount of selling asset to sell
      price: "1", // Price of 1 unit of selling asset
    })
  )
  .setTimeout(30) //Sets the transaction timeout to 30 seconds.
  .build(); //Builds the transaction.
tx.sign(sourceKeypair); //Signs the transaction using the Keypair derived from the secret key
try {
  const response = await server.submitTransaction(tx);
  if (response.successful) {
    console.log("Passive sell offer created successfully", response.hash);
  }
} catch (error) {
  console.error("Error submitting transaction:", error);
}
(async () => {
  await createPassiveSellOffer(secret);
})();
```

<!-- tabs:end -->

This process creates a passive sell offer on the Diamante that awaits buyers who match the specified price.
Check offer in this endpoint: https://diamtestnet.diamcircle.io/offers?&limit=10&order=desc
