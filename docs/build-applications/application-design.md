# Application Design Considerations

### Custody Models

When building an application, one of the first decisions is how users' secret keys will be secured and stored. Diamante applications provide users access to their accounts stored on the ledger, and their access is controlled by the account’s secret key, proving ownership.

There are four custody options to consider:

1. **Non-custodial service:**

   - Users store their own secret key.
   - Requires users to securely store their own account credentials and safely navigate transaction signing.
   - Potential usability issues, and loss of the secret key results in account access loss.
   - Non-custodial applications typically create or import a pre-existing Diamante account for each user.

2. **Custodial service:**

   - Service provider (application) stores users' secret keys and delegates usage rights.
   - Often uses a single pooled Diamante account for transactions on behalf of users.
   - Encourages the implementation of muxed accounts to distinguish individual users in a pooled account.
   - Learn how to set up an application as a custodial service in this tutorial.

3. **Mixture of non-custodial and custodial:**

   - [Encyclopedia -> Multi-signature](/encyclopedia/sig-multisig?id=multisig) capabilities allow non-custodial service with account recovery.
   - Users can sign transactions with other authorized signatures if they lose their secret key.

4. **Third-party key management services:**
   - Integrate third-party custodial services for added security.
   - Explore services like diamcircleAuth, diamcircle Authenticator, Ledger, Trezor, diamcircleGuard, LobstrVault.

### Application Security

Even though wallets can operate client-side, they deal with users' secret keys, providing direct access to their accounts and any value they hold. Ensure all web traffic flows over strong TLS methods. Diamante is a powerful money-moving software, so prioritize security. Refer to our guide on [Encyclopedia -> securing web-based products](/encyclopedia/securing-web-projects) for more information.

### Wallet Services

A wallet typically includes key storage, account creation, transaction signing, and queries to the Diamante database. Some services handle all these functions, allowing you to build around them. Check out wallet services like:

- [DIAM Wallet](https://play.google.com/store/apps/details?id=com.diamante.diamwallet&pcampaignid=web_share)

### Account Creation Strategies

This section explores the new user account creation flow between non-custodial wallets and anchors with DEP-24 and/or DEP-6 implementations. A Diamante account is created with a keypair and the minimum balance of DIAM.

#### Option 1: The anchor creates and funds the Diamante account

1. Wallet registers a new user and issues a keypair.
2. Wallet initiates the first deposit without requiring the user to add the asset/trustline.
3. Anchor provides deposit instructions.
4. User transfers money to the anchor's bank account.
5. Anchor creates and funds the Diamante account.
6. Wallet prompts the user to add the asset/create the trustline.
7. Anchor sends deposit funds to the user's Diamante account.

> Note: An anchor should always maintain a healthy amount of DIAM in its distribution account to support new account creations. If doing so becomes unsustainable, it’s recommended that the anchor collaborates with wallets to determine a strategy based on the number of account creation requests. The recommended amount is 2DIAM per user account creation (1DIAM to meet the minimum balance requirement, and 1DIAM for establishing trustlines and covering transaction fees).

#### Option 2: The wallet creates and funds the Diamante account upon user sign-up

1. Wallet issues a keypair and creates/funds the user's Diamante account with 2 DIAM.
2. Wallet creates a trustline and initiates the first deposit.
3. Anchor provides deposit instructions.
4. User transfers funds to the anchor's account.
5. Anchor receives funds and sends them to the user's Diamante account.
6. Wallet notifies the user upon fund transfer.

> Note: In both options, the anchor or wallet could use sponsored reserves for simplicity.
