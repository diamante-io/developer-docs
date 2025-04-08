# Publish Information About An Asset

Diamante assets are defined by who issued them, what they represent, and the terms and conditions for their use. These should all be defined and made public by the issuer in a Diamante info file. It’s crucial to provide clear information about what it represents. On Diamante, you do that by linking your issuing account to a home domain, publishing a Diamante info file on that domain, and making sure that file is complete and accurate.

The most successful asset issuers give exchanges, wallets, and potential buyers lots of information about themselves in order to establish trust.

Completing your Diamante info file is not a step you can skip.

## What is a Diamante info file?

A Diamante info file is a common place where the Internet can find information about your organization’s Diamante integration. You write it in TOML, a simple and widely used configuration file format designed to be readable by both humans and machines, and publish it at `https://YOUR_DOMAIN/.well-known/diamante.toml`.

That way, everyone knows where to find it, anyone can look it up, and it proves that the owner of the HTTPS domain hosting the diamante.toml claims responsibility for the accounts and assets listed in it.

Using a `set_options` operation, you can link your Diamante account to the domain that hosts your Diamante info file, thereby creating a definitive on-chain connection between this information and that account.

## Completing your diamante.toml

The first Diamante Ecosystem Proposal (DEP) is DEP-0001: Diamante Info File and specifies everything you would ever need to include in your Diamante info file. This section will walk through the sections of DEP-0001 that relate to asset issuers. Use this section in conjunction with the DEP to ensure you complete your diamante.toml correctly.

The four sections we’ll cover are:

1. General Information
2. Organization Documentation
3. Point of Contact Documentation
4. Currency Documentation

For each of those sections, we’ll let you know which fields are required, meaning all asset issuers must include them to be listed by exchanges and wallets, and which fields are suggested. Completing suggested fields is a good way to make your asset stand out.

> It's a good idea to keep the sections in the order presented in DEP-0001: Diamante Info File, which is also the order they're presented here. TOML requires arrays to be at the end, so if you scramble the order, you may cause errors for TOML parsers.

## 1. General Information

### Required field for all asset issuers:

**ACCOUNTS:** A list of public keys for all the Diamante accounts associated with your asset.
Listing your public keys lets users confirm that you own them. For example, when `https://google.com` hosts a diamante.toml file, users can be sure that only the accounts listed on it belong to Google. If someone then says, "You need to pay your Google bill this month, send payment to address `GIAMGOOGLEIPROMISE`," but that key is not listed on Google's diamante.toml, then users know not to trust it.

There are several fields where you list information about your Diamante integration to aid in discoverability. If you are an anchor service, and you have set up infrastructure to interoperate with wallets and allow for in-app deposit and withdrawal of assets, make sure to include the locations of your servers on your diamante.toml file so those wallets know where to find relevant endpoints to query. In particular, list these:

### Suggested fields for asset issuers:

- **`TRANSFER_SERVER`** if you support DEP-0006: Deposit and Withdrawal API
- **`TRANSFER_SERVER_DEP0024`** if you support DEP-0024: Interactive Deposit and Withdrawal
- **`KYC_SERVER`** if you support DEP-0012: KYC API
- **`WEB_AUTH_ENDPOINT`** if you support DEP-0010: Diamante Web Authentication
- **`DIRECT_PAYMENT_SERVER`** if you support DEP-0031: Cross-Border Payments API

If you support other Diamante Ecosystem Proposals — such as federation or delegated signing — or host a public aurora instance that other people can use to query the ledger, you should also add the location of those resources to General Information so they're discoverable.

## 2. Organization Documentation

Basic information about your organization goes into a TOML table called `[DOCUMENTATION]`. Organization Documentation is your chance to inform exchanges and buyers about your business and to demonstrate that your business is legitimate and trustworthy.

### Required field for all asset issuers:

- **`ORG_NAME`:** The legal name of your organization, and if your business has one, its official ORG_DBA.
- **`ORG_URL`:** The HTTPS URL of your organization's official website. In order to prove the website is yours, you must host your diamante.toml on the same domain you list here. That way, exchanges and buyers can view the SSL certificate on your website and feel reasonably confident that you are who you say you are.
- **`ORG_LOGO`:** A URL to a company logo, which will show up next to your organization on exchanges. This image should be a square aspect ratio transparent PNG, ideally of size 128x128. If you fail to provide a logo, the icon next to your organization will appear blank on many exchanges.
- **`ORG_PHYSICAL_ADDRESS`:** The physical address of your organization. We understand you might want to keep your work address private. At the very least, you should put the city and country in which you operate. A street address is ideal and provides a higher level of trust and transparency to your potential asset holders.
- **`ORG_OFFICIAL_EMAIL`:** The best business email address for your organization. This should be hosted at the same domain as your official website.
- **`ORG_SUPPORT_EMAIL`:** The best email for support requests.

### Suggested fields for asset issuers:

- **`ORG_GITHUB`:** Your organization's official Github account.
- **`ORG_KEYBASE`:** Your organization's official Keybase account. Your Keybase account should contain proof of ownership of any public online accounts you list here, including your organization's domain.
- **`ORG_TWITTER`:** Your organization's official Twitter handle.
- **`ORG_DESCRIPTION`:** A description of your organization. This is fairly open-ended, and you can write as much as you want. It's a great place to distinguish yourself by describing what it is that you do.

_Issuers that list verified information including phone/address attestations and Keybase verifications are prioritized by Diamante clients._

## 3. Point of Contact Documentation

Information about the primary point(s) of contact for your organization goes into a TOML array of tables called `[[PRINCIPALS]]`. You need to put contact information for at least one person in your organization. If you don't, exchanges can't verify your offering, and it is unlikely that buyers will be interested. Multiple principals can be added with additional `[[PRINCIPALS]]` entries.

### Required field for all asset issuers:

- **`name`:** The name of the primary contact.
- **`email`:** The primary contact's official email address. This should be hosted at the same domain as your organization's official website.

### Suggested fields for asset issuers:

- **`github`:** The personal Github account of the point of contact.
- **`twitter`:** The personal Twitter handle of the point of contact.
- **`keybase`:** The personal Keybase account for the point of contact. This account should contain proof of ownership of any public online accounts listed here and may contain proof of ownership of your organization's domain.

## 4. Currency Documentation

Information about the asset(s) you issue goes into a TOML array of tables called `[[CURRENCIES]]`. If you issue multiple assets, you can include them all in one diamante.toml. Each asset should have its own `[[CURRENCIES]]` entry.

(These entries are also used for assets you support but don’t issue, but as this section focuses on issuing assets, the language will reflect that.)

### Required field for all asset issuers:

- **`code`:** The asset code. This is one of two key pieces of information that identify your token. Without it, your token cannot be listed anywhere.
- **`issuer`:** The Diamante public key of the issuing account. This is the second key piece of information that identifies your token. Without it, your token cannot be listed anywhere.
- **`is_asset_anchored`:** An indication of whether your token is anchored or native: true if your token can be redeemed for an asset outside the Diamante network, false if it can’t. Exchanges use this information to sort tokens by type in listings. If you fail to provide it, your token is unlikely to show up in filtered market views.

If you're issuing anchored (tethered, stablecoin, asset-backed) tokens, there are several additional required fields:

- **`anchor_asset_type`:** The type of asset your token represents. The possible categories are fiat, crypto, stock, bond, commodity, realestate, and other.
- **`anchor_asset`:** The name of the asset that serves as the anchor for your token.
- **`redemption_instructions`:** Instructions to redeem your token for the underlying asset.
- **`attestation_of_reserve`:** A URL to attestation or other proof, evidence, or verification of reserves, such as third-party audits, which all issuers of stablecoins should offer to adhere to best practices.

### Suggested fields for asset issuers:

- **`desc`:** A description of your token and what it represents. This is a good place to clarify what your token does and why someone might want to own it.
- **`conditions`:** Any conditions you place on the redemption of your token.
- **`image`:** A URL to a PNG or GIF image with a transparent background representing your token. Without it, your token will appear blank on many exchanges.

## How to publish your Diamante info file

After you've followed the steps above to complete your Diamante info file, post it at the following location: `https://YOUR_DOMAIN/.well-known/diamante.toml`

Enable CORS so people can access this file from other sites, and set the following header for an HTTP response for a `/.well-known/diamante.toml` file request.

`Access-Control-Allow-Origin: *`

Set a `text/plain` content type so that browsers render the contents rather than prompting for a download.

`content-type: text/plain`

You should also use the `set_options` operation to set the home domain on your issuing account.

#### Example

```bash
server {

        server_name my.example.com;
        root /var/www/my.example.com;

        location = /.well-known/diamante.toml {
                types { } default_type "text/plain; charset=utf-8";
                allow all;
                if ($request_method = 'OPTIONS') {
                        add_header 'Access-Control-Allow-Origin' '*';
                        add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS';
                        add_header 'Content-Length' 0;
                        return 204;
                }
                if ($request_method = 'GET') {
                        add_header 'Access-Control-Allow-Origin' '*';
                        add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS';
                        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
                }
        }

    // CertBot SSL configuration
    // ...
}
```

## Sample code to set the home domain of your issuing account

<!-- tabs:start -->

#### **Javascript**

```js
var DiamSdk = require("diamnet-sdk");
var server = new DiamSdk.Aurora.Server("https://diamtestnet.diamcircle.io/");

// Keys for issuing account
var issuingKeys = DiamSdk.Keypair.fromSecret(
  "SCZANGBA5YHTNYVVV4C3U252E2B6P6F5T3U6MM63WBSBZATAQI3EBTQ4"
);

server
  .loadAccount(issuingKeys.publicKey())
  .then(function (issuer) {
    var transaction = new DiamSdk.TransactionBuilder(issuer, {
      fee: 100,
      networkPassphrase: DiamSdk.Networks.TESTNET,
    })
      .addOperation(
        DiamSdk.Operation.setOptions({
          homeDomain: "yourdomain.com",
        })
      )
      // setTimeout is required for a transaction
      .setTimeout(100)
      .build();
    transaction.sign(issuingKeys);
    return server.submitTransaction(transaction);
  })
  .then(console.log)
  .catch(function (error) {
    console.error("Error!", error);
  });
```

#### **Go**

```go
package main

import (
	"log"

	"github.com/diamante/go/clients/auroraclient"
	"github.com/diamante/go/keypair"
	"github.com/diamante/go/network"
	"github.com/diamante/go/txnbuild"
)

func main() {
	// Keys for issuing account
	issuingSeed := "SCZANGBA5YHTNYVVV4C3U252E2B6P6F5T3U6MM63WBSBZATAQI3EBTQ4"
	issuingKeyPair, err := keypair.Parse(issuingSeed)
	if err != nil {
		log.Fatal("Error parsing issuing seed:", err)
	}

	// Load issuing account
	server := auroraclient.DefaultTestNetClient
	issuerAccount, err := server.LoadAccount(issuingKeyPair.Address())
	if err != nil {
		log.Fatal("Error loading issuing account:", err)
	}

	// Build and submit the transaction to set the home domain
	setOptionsTx, err := txnbuild.NewTransaction(
		txnbuild.TransactionParams{
			SourceAccount: &issuerAccount,
			Operations: []txnbuild.Operation{
				&txnbuild.SetOptions{
					HomeDomain: "yourdomain.com",
				},
			},
			BaseFee:    txnbuild.MinBaseFee,
			Timebounds: txnbuild.NewInfiniteTimeout(),
			Network:    network.TestNetworkPassphrase,
		},
	)
	if err != nil {
		log.Fatal("Error creating SetOptions transaction:", err)
	}

	setOptionsTx, err = setOptionsTx.Sign(issuingKeyPair)
	if err != nil {
		log.Fatal("Error signing SetOptions transaction:", err)
	}

	resp, err := server.SubmitTransaction(setOptionsTx)
	if err != nil {
		log.Fatal("Error submitting SetOptions transaction:", err)
	}

	log.Printf("SetOptions transaction submitted successfully. Hash: %s\n", resp.Hash)
}

```

<!-- tabs:end -->

## Sample diamante.toml

```toml
NETWORK_PASSPHRASE="Public Global Diamante MainNet; DEP 2022 Network ; September 2015"
FEDERATION_SERVER="https://api.domain.com/federation"
AUTH_SERVER="https://api.domain.com/auth"
TRANSFER_SERVER="https://api.domain.com"
SIGNING_KEY="GBBHQ7H4V6RRORKYLHTCAWP6MOHNORRFJSDPXDFYDGJB2LPZUFPXUEW3"
aurora_URL="https://aurora.domain.com"
ACCOUNTS=[
"GD5DJQDDBKGAYNEAXU562HYGOOSYAEOO6AS53PZXBOZGCP5M2OPGMZV3",
"GAENZLGHJGJRCMX5VCHOLHQXU3EMCU5XWDNU4BGGJFNLI2EL354IVBK7",
"GAOO3LWBC4XF6VWRP5ESJ6IBHAISVJMSBTALHOQM2EZG7Q477UWA6L7U"
]
VERSION="2.0.0"

[DOCUMENTATION]
ORG_NAME="Organization Name"
ORG_DBA="Organization DBA"
ORG_URL="https://www.domain.com"
ORG_LOGO="https://www.domain.com/awesomelogo.png"
ORG_DESCRIPTION="Description of issuer"
ORG_PHYSICAL_ADDRESS="123 Sesame Street, New York, NY 12345, United States"
ORG_PHYSICAL_ADDRESS_ATTESTATION="https://www.domain.com/address_attestation.jpg"
ORG_PHONE_NUMBER="1 (123)-456-7890"
ORG_PHONE_NUMBER_ATTESTATION="https://www.domain.com/phone_attestation.jpg"
ORG_KEYBASE="accountname"
ORG_TWITTER="orgtweet"
ORG_GITHUB="orgcode"
ORG_OFFICIAL_EMAIL="support@domain.com"

[[PRINCIPALS]]
name="Jane Jedidiah Johnson"
email="jane@domain.com"
keybase="crypto_jane"
twitter="crypto_jane"
github="crypto_jane"
id_photo_hash="be688838ca8686e5c90689bf2ab585cef1137c999b48c70b92f67a5c34dc15697b5d11c982ed6d71be1e1e7f7b4e0733884aa97c3f7a339a8ed03577cf74be09"
verification_photo_hash="016ba8c4cfde65af99cb5fa8b8a37e2eb73f481b3ae34991666df2e04feb6c038666ebd1ec2b6f623967756033c702dde5f423f7d47ab6ed1827ff53783731f7"

[[CURRENCIES]]
code="USD"
issuer="GCZJM35NKGVK47BB4SPBDV25477PZYIYPVVG453LPYFNXLS3FGHDXOCM"
display_decimals=2

[[CURRENCIES]]
code="BTC"
issuer="GAOO3LWBC4XF6VWRP5ESJ6IBHAISVJMSBTALHOQM2EZG7Q477UWA6L7U"
display_decimals=7
anchor_asset_type="crypto"
anchor_asset="BTC"
redemption_instructions="Use DEP6 with our federation server"
collateral_addresses=["2C1mCx3ukix1KfegAY5zgQJV7sanAciZpv"]
collateral_address_signatures=["304502206e21798a42fae0e854281abd38bacd1aeed3ee3738d9e1446618c4571d10"]

# asset with meta info
[[CURRENCIES]]
code="GOAT"
issuer="GD5T6IPRNCKFOHQWT264YPKOZAWUMMZOLZBJ6BNQMUGPWGRLBK3U7ZNP"
display_decimals=2
name="goat share"
desc="1 GOAT token entitles you to a share of revenue from Elkins Goat Farm."
conditions="There will only ever be 10,000 GOAT tokens in existence. We will distribute the revenue share annually on Jan. 15th"
image="https://static.thenounproject.com/png/2292360-200.png"
fixed_number=10000

```
