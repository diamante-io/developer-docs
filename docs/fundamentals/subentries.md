# Subentries in the Diamante

<br>

### What are Subentries?

In the Diamante network, subentries are secondary records associated with a Diamante account that store additional data. Each account can hold up to 256 subentries, which can include various types of information, such as:

**Trust Lines**: Agreements to trust certain assets issued by other accounts within the Diamante network.<br/>
**Liquidity Pools**: Accounts that hold assets in liquidity pools specific to the Diamante network.<br/>
**Offers**: Active offers for buying or selling assets, including the native asset DIAM.<br/>

Subentries allow accounts to maintain multiple relationships and transactions without creating separate accounts for each, optimizing efficiency within the Diamante network.

### How Do Subentries Increase?

Subentries increase when:

**New Trust Lines**: When an account establishes a trust line with the native asset DIAM or other assets in the Diamante network.<br/>
**Creating Offers**: When an account places buy/sell offers for DIAM or other assets.<br/>
**Participating in Liquidity Pools**: When an account participates in liquidity pools by adding or removing DIAM or other assets.<br/>

Each activity generates a new subentry, facilitating diverse interactions within the network.

### Maintaining DIAM with Increased Subentries

**DIAM Base Reserve**: Each account in the Diamante network is required to maintain a certain amount of DIAM as a base reserve. This base reserve is essential for preventing spam and ensuring that accounts have sufficient value.

**Base Reserve Calculation**: The base reserve is a fixed amount of DIAM (e.g., 0.0000001 DIAM) multiplied by the number of subentries an account holds.
For example, if the base reserve is 0.0000001 DIAM and an account has 3 subentries, the total reserve requirement would be 0000001 DIAM \* (3 + 0.0000002). The "+0.0000002" accounts for the base account.

**Maintaining Reserve**: If an account’s subentries increase, the required base reserve also increases. If the account does not have enough DIAM to meet the new reserve requirement, it may need to either remove subentries or acquire more DIAM.
Base Reserve of an Account

### What is Base Reserve?

The base reserve in the Diamante network is the minimum amount of DIAM that must be maintained in an account to keep it active. This reserve helps deter the creation of accounts for spam or malicious purposes and ensures that only purposeful accounts maintain a presence on the network.

### How is it Maintained?

The base reserve is dynamically maintained through the network's consensus mechanism.
Whenever the total number of subentries in an account changes, the reserve requirement automatically adjusts.
If an account's balance falls below the required reserve, it may face limitations, such as being unable to create new subentries or even being flagged for potential removal.
