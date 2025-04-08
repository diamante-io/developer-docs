# Error Handling

It’s important to anticipate errors your users may encounter as you develop on diamcircle. In many tutorials throughout our developer documentation, we leave out error handling code to focus on the example. In this section, we will do the opposite and talk specifically about the errors.

By the end of this section, you should be able to categorize errors and understand the best way to handle them in your application.

There are two main parts to this section:

1. **Resolution strategies:** recommended resolution strategies that apply to most error scenarios you may encounter
2. **Managing specific errors:** a deeper dive into the errors themselves. Refer to this section if you have encountered a specific error and want a better understanding of its cause.

For a full list of errors, see the [Encyclopedia -> Error section in our API documentation]("/encyclopedia/error-handling?id=error-handling).

## Part 1: Resolution Strategies

Many actions interact with the diamcircle network through the aurora API, and these possible actions fall into two main categories:

1. **Queries (any GET request, like to /accounts)**
2. **Transaction submissions (a POST /transactions)**

There are many possible error codes when executing these actions, and you can typically handle these error codes using the following strategies:

- **Request Adjustments**

  Adjusting the request to resolve structural errors with queries or transaction submissions.Suppose you’ve included a bad parameter, malformed your XDR, or otherwise didn’t follow the endpoint’s specification, resolve the error by referencing the details or result codes of the error response.

- **Retrying Until Success**

  Recommended way to work around latency or congestion issues encountered along the pipeline between your computer and the Diamante network. This can sometimes happen due to the nature of the distributed system.

- **Adjusting the Transaction**

  Can resolve issues but must be done with extreme care. If one of the above scenarios is in effect, it can trigger destructive duplicate actions (like sending a payment twice).

Let’s get into these strategies in more detail. We will mainly focus on the transaction submission category for each strategy since queries only return a read-only request.

### Request adjustments strategy

#### Queries

Many `GET` requests have specific parameter requirements, and while the SDKs can help enforce them, you can still pass invalid arguments (for example, an asset string that isn’t DEP-11 compatible) that error out every time. In this scenario, there’s nothing you can do aside from following the API specification. The `extras` field of the error response will often clue you in on where to look and what to look for.

```bash
curl -s https://diamtestnet.diamcircle.io/claimable_balances/0000 | jq '.extras'
{
  "invalid_field": "id",
  "reason": "Invalid claimable balance ID"
}
```

Note that the SDKs make it a point to distinguish an invalid request (as above) versus a missing resource (a `404 Not Found`).

#### Transaction submissions

Certain transaction submission failures also need adjustments to succeed. If the XDR is malformed, or the transaction is otherwise invalid, you’ll encounter a `400 Bad Request` (for example, see excluding a source account). Both transactions and their operations can be easily malformed: look at the `extras.result_codes` field for details and cross-reference them with the appropriate result codes documentation to determine specifics.

Transaction fees are also a safe adjustment. If you get a `tx_insufficient_fee` error, refer to the Insufficient Fees and Surge Pricing section later in this document.

### Retrying until success strategy

#### Transaction submissions

There are many possible scenarios (`504 Timeouts`, transient outages, congestion on the network) in which retrying your transaction submission is the only reasonable solution. However, only use this method after trying to make safe modifications to the transaction.

There is no way to cancel a transaction after submitting it. So, successfully resubmitting your transaction has two considerations. 1. Time bounds. Time bounds are optional but recommended, as they put a time limit on the transaction- so either the transaction makes it onto the ledger or it times out depending on your time parameters. 2. If the transaction has already successfully made it to the ledger, Aurora will return any attempted resubmission. Only in cases where a transaction’s status is unknown (and thus will have a chance to make it on the ledger) will a resubmission to the network occur.

If a transaction successfully makes it into the ledger, any attempted resubmitted transactions will be returned to you.

Example scenario:

You submit a transaction, and it enters the queue of the Diamante network, but Aurora crashes while giving you a response. Uncertain about the transaction status, you resubmit the transaction (with no changes!) until either a. Aurora comes back up to give you a reply or b. your time bounds are exceeded.

There are only two possible results to this scenario: either the transaction makes it into the ledger (exactly once) and Aurora gives you the response, or the transaction never makes it out of the queue, and you receive the corresponding `tx_too_late` response.

Despite the solution’s simplicity, things can go wrong fast if you don’t understand why the error occurred.

Suppose you submit transactions from multiple places in your application simultaneously, and your user spammed the Send Payment button a few times in their impatience. If you send the exact same payment transaction for each tap, naturally, only one will succeed. The others will fail with an invalid sequence number (`tx_bad_seq`), and if you resubmit blindly with an updated sequence number (as we do above), these payments will also succeed, resulting in more than one payment being made when only one was intended. So, be very careful when resubmitting transactions that have been modified to work around an error.

## Part 2: Managing specific errors

Here, we will cover specific errors commonly encountered during transaction submission and direct you to the appropriate resolution. We’ll start with a table of common errors and their codes and descriptions, then dive deeper into some specific ones.

| Result                | Code | Description                                                                                  |
| --------------------- | ---- | -------------------------------------------------------------------------------------------- |
| FAILED                | -1   | One of the operations failed (see [List of Operations](/fundamentals/operations) for errors) |
| TOO_EARLY             | -2   | Ledger closeTime before minTime value in the transaction                                     |
| TOO_LATE              | -3   | Ledger closeTime after maxTime value in the transaction                                      |
| MISSING_OPERATION     | -4   | No operation was specified                                                                   |
| BAD_SEQ               | -5   | Sequence number does not match source account                                                |
| BAD_AUTH              | -6   | Too few valid signatures / wrong network                                                     |
| INSUFFICIENT_BALANCE  | -7   | Fee would bring account below minimum balance; see our section on Diams for more info        |
| NO_ACCOUNT            | -8   | Source account not found                                                                     |
| INSUFFICIENT_FEE      | -9   | Fee is too small; see our section on Fees for more info                                      |
| BAD_AUTH_EXTRA        | -10  | Unused signatures attached to the transaction                                                |
| INTERNAL_ERROR        | -11  | An unknown error occurred                                                                    |
| NOT_SUPPORTED         | -12  | The transaction type is not supported                                                        |
| FEE_BUMP_INNER_FAILED | -13  | The fee bump inner transaction failed                                                        |
| BAD_SPONSORSHIP       | -14  | The sponsorship is not confirmed                                                             |

Now, let's dive deeper into the resolution for each of these specific errors.

- Timeouts: `504 Timeout`
- Insufficient fees and surge pricing: `INSUFFICIENT_FEE`
- Rate limiting: `429 Too Many Requests`
- Insufficient DIAM balance: `INSUFFICIENT_BALANCE`

#### Timeouts

Aurora may send a `504 Timeout` after transaction submission. Timeouts are not errors but warnings that your request hasn’t been fulfilled yet. This can happen because of the relationship between Aurora and Diamante Core- the network may take some time (5-10 mins during congestion) to accept the transaction. At the same time, Aurora needs to provide developers with a response within 30 seconds.

Receiving a 504 for your transaction submission does not mean the transaction didn’t make it to the network. Continue with retries until you get a definitive response. If you continue to face timeouts on retries, consider using a fee-bump transaction to get into the ledger (after the time bounds expire) or increasing the maximum fee you’re willing to pay. Read up on [Encyclopedia -> Surge Pricing](/encyclopedia/fee-surge-pricing-strategies) and Fee Strategies for more details.

#### Insufficient fees and surge pricing

See the [Encyclopedia -> Surge Pricing and Fee Strategies Encyclopedia Entry](/encyclopedia/fee-surge-pricing-strategies)

#### Rate limiting

If you’re using DDF’s public Aurora instance, you may get a `429 Too Many Requests` error when exceeding the rate limits. If you’re encountering this frequently, it may be time to deploy your own Aurora instance!

#### Insufficient DIAM balance

Any transaction that would reduce an account’s balance to less than the minimum will be rejected with an `INSUFFICIENT_BALANCE` error. Likewise, DIAM selling liabilities that would reduce an account’s balance to less than the minimum plus DIAM selling liabilities will be rejected with an `INSUFFICIENT_BALANCE` error.

For more on minimum balances, see our [Diams section](/fundamentals/diams).
