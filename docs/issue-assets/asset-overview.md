# Assets Overview

Issuing assets is a core feature of Diamante: any asset can be tokenized (or minted) on the network and then tracked, held, and traded quickly and cheaply. Assets can represent many things: cryptocurrencies (such as bitcoin or ether), fiat currencies (such as dollars or pesos), other tokens of value (such as NFTs), pool shares, or even bonds and equity. Any Diamante account can issue an asset, and since anyone can set up an account, anyone can issue assets: banks, payment processors, money service businesses, for-profit enterprises, nonprofits, local communities, and individuals. It’s a self-serve process with no permission needed.

Issuing an asset on Diamante is easy and only takes a few operations. However, there are additional considerations you may need to think about depending on your use case, such as publishing asset information, compliance, and asset supply, which we’ll cover in this documentation. Assets on Diamante have two identifying characteristics: the asset code and the issuer. Since more than one organization can issue a credit representing the same asset, asset codes often overlap (for example, multiple companies offer a USD token on Diamante). Assets are uniquely identified by the combination of their asset code and issuer.

## Stablecoins

One major category of assets is the stablecoin. A stablecoin is a blockchain-based token whose value is tied to another asset, such as the US dollar, other fiat currencies, commodities like gold, or even cryptocurrencies. There are two types of stablecoin: 1) reserve-backed stablecoins that must have a mechanism for redeeming the asset backing them, and 2) algorithmic stablecoins that don’t have assets backing them and instead rely on an algorithm to control the stablecoin supply. When discussing stablecoins, our documentation will focus on reserve-backed stablecoins.

Reserve-backed stablecoins are pegged to a real-world asset at a 1:1 ratio. Because the underlying asset is maintained as collateral, users should be able to trade their stablecoin for the asset at any time. Asset reserves can be maintained by independent custodians and should be regularly audited.

## Treasury management

When issuing a reserve-backed stablecoin, you must set up its off-chain reserve, which securely stores the asset backing the stablecoin. When users wish to redeem their stablecoin, they can receive an equivalent amount of the underlying reserve asset from the issuer.

## Compliance

As an asset issuer, you may need to comply with regulatory requirements that vary based on jurisdiction. Diamante has built-in features that can help meet these requirements, such as:

- [Controlling access to an asset with flags](/issue-assets/asset-design?id=controlling-access-to-an-asset-with-flags)
- DEP-0008: Regulated Assets - regulated assets are assets that require an issuer’s approval (or a delegated third party’s approval) on a per-transaction basis. Check out this Diamante Ecosystem Proposal to learn how to implement regulated assets into your use case.
