# Memos

Memos are an optional unstructured data field that can be used to embed any additional identifying information about the transaction relevant to the sender or receiver.

They were previously used to differentiate between individual accounts in a pooled account- something we used muxed accounts for now.

<!-- For more information on muxed accounts, see our [Pooled Accounts - Muxed Accounts & Memos Encyclopedia Entry](TODO) -->

Memos can be one of the following types:

1. **MEMO_TEXT**: A string encoded using either ASCII or UTF-8, up to 28-bytes long.

2. **MEMO_ID**: A 64-bit unsigned integer.

3. **MEMO_HASH**: A 32-byte hash.

4. **MEMO_RETURN**: A 32-byte hash intended to be interpreted as the hash of the transaction the sender is refunding.

## Memo content examples

- Notifying that the transaction is a refund or reimbursement
- Reference to an invoice the transaction is paying
- Any further internal routing information
- Links to relevant data
