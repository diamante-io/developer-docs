# Prerequisites

You can install Diamante Core in a [number of different ways](/run-node/installing), and once you do, you can [configure](/run-node/configuring) it to participate in the network on several [different levels](/run-node/overview?id=types-of-nodes): it can be either a Basic Validator or a Full Validator. No matter how you install Diamante Core or what kind of node you run, however, you need to set up to connect to the peer-to-peer network and store the state of the ledger in a SQL [database](/run-node/configuring?id=database).

### Compute Requirements

We recently asked Diamante Core operators about their setups, and should have some updated information soon based on their responses. So stay tuned. In early 2018, Diamante Core with PostgreSQL running on the same machine worked well on a [m5.large](https://aws.amazon.com/ec2/instance-types/m5/) in AWS (dual-core 2.5 GHz Intel Xeon, 8 GB RAM). Storage-wise, 20 GB was enough in 2018, but the ledger has grown a lot since then, and most people seem to have at least 1TB on hand.

Diamante Core is designed to run on relatively modest hardware so that a whole range of individuals and organizations can participate in the network, and basic nodes should be able to function pretty well without tremendous overhead. That said, the more you ask of your node, the greater the requirements.

### Network Access

Diamante Core interacts with the peer-to-peer network to keep a distributed ledger in sync, which means that your node needs to make certain [TCP ports](https://en.wikipedia.org/wiki/Transmission_Control_Protocol#TCP_ports) available for inbound and outbound communication.

- **Inbound:** A Diamante Core node needs to allow all IPs to connect to its `PEER_PORT` over TCP. You can specify a port when you [configure Diamante Core](/run-node/configuring), but most people use the default, which is **11625**.
- **Outbound:** A Diamante Core needs to connect to other nodes via their `PEER_PORTs` TCP.

### Internal System Access

Diamante Core also needs to connect to certain internal systems, though exactly how varies based on your setup.

- **Outbound:** Diamante Core requires access to a PostgreSQL database. If that database resides on a different machine on your network, you'll need to allow that connection. You specify the database when you configure Diamante Core.
  You can block all other connections.
- **Inbound:** Diamante Core exposes an unauthenticated HTTP endpoint on its `HTTP_PORT`. You can specify a port when you [configure Diamante Core](/run-node/configuring), but most people use the default, which is **11626**.
  - The `HTTP_PORT` is used by Aurora to submit transactions, so may have to be exposed to the rest of your internal IPs.
  - It's also used to query Diamante Core [info](/run-node/commands) and provide [metrics](/run-node/monitoring).
  - And to perform administrative commands such as [scheduling upgrades](/run-node/upgrading) and changing log levels.
  - For more on that, see [commands](/run-node/commands).

**Note:** If you need to expose your HTTP endpoint to other hosts in your local network, we recommended using an intermediate reverse proxy server to implement authentication. Don't expose the HTTP endpoint to the raw and cruel open internet.
