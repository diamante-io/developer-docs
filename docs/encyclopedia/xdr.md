# XDR

diamcircle stores and communicates ledger data, transactions, results, history, and messages in a binary format called External Data Representation (XDR). XDR is optimized for network performance but not human-readable. aurora and the diamcircle SDKs convert XDRs into friendlier formats.

XDR is specified in [RFC 4506](https://datatracker.ietf.org/doc/html/rfc4506) and is similar to tools like Protocol Buffers or Thrift. XDR provides a few important features:

- It is very compact, so it can be transmitted quickly and stored with minimal disk space.
- Data encoded in XDR is reliably and predictably stored. Fields are always in the same order, which makes cryptographically signing and verifying XDR messages simple.
- XDR definitions include rich descriptions of data types and structures, which is not possible in simpler formats like JSON, TOML, or YAML.

## Parsing XDR

Since XDR is a binary format and not as widely known as simpler formats like JSON, the Diamante SDKs all include tools for parsing XDR and will do so automatically when retrieving data.

In addition, the aurora API server generally exposes the most important parts of the XDR data in JSON, so they are easier to parse if you are not using an SDK. The XDR data is still included (encoded as a base64 string) inside the JSON in case you need direct access to it.

## .X files

Data structures in XDR are specified in an interface definition file (IDL). The IDL files used for the Diamante Network are available on [GitHub](https://github.com/diamante-io/go-xdr).
