# SDK Library

Interact with the Diamante network using the SDK in Javascript and GO. All SDKs are open-source; file a GitHub issue or pull request in the specific SDK repository if you have questions or suggestions.

Each SDK has its own source code and documentation. Learn how to use a specific SDK by referring to the documentation- most docs offer practical examples that demonstrate how to construct and submit transactions and interact with Aurora endpoints.

## JavaScript SDK

[NPM](https://www.npmjs.com/package/diamnet-sdk)

`diamnet-sdk` is the JavaScript library for communicating with a Diamante server, communicating with the Aurora API, and building transactions on the Diamante network. It is used for building Diamante apps either on Node.js or in the browser.

It provides:

- A networking layer API for RPC methods and the Aurora API.
- Facilities for building and signing transactions, for communicating with an RPC instance, for communicating with a Aurora instance, and for submitting transactions or querying network state.

## GO

This SDK is split up into separate packages, all of which you can find in the [Go monorepo README](https://github.com/diamante-io/go/tree/main/docs/reference). The two key libraries for interacting with Aurora are txnbuild, which enables the construction, signing, and encoding of Diamante transactions, and auroraclient, which provides a web client for interfacing with Aurora server REST endpoints to retrieve ledger information and submit transactions built with txnbuild.

- txnbuild: [SDK](https://github.com/diamante-io/go/tree/main/txnbuild) | [Docs](https://pkg.go.dev/github.com/diamcircle/go)
- Auroraclient: [SDK](https://github.com/diamante-io/go/tree/main/clients/auroraclient) | [Docs](https://pkg.go.dev/github.com/diamcircle/go@v0.1.1/clients/auroraclient)
