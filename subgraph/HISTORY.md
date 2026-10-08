# Loading history from the block explorer

This subgraph does not read its history from the chain through The Graph. The
past events are embedded in `src/history.ts` and replayed once when the
subgraph starts. Events from block 79502412 on are indexed live.

## Why

On 2026-10-07 a normal deployment to Subgraph Studio, indexing from the
contract's deployment block, finished with no errors but with most historical
events missing (for Celo USD: 4 of 11 loans, 9 of 24 debts, 0 of 2 tokens). The
Celo block explorer has every event. The same happened to an unrelated
subgraph on Celo the same day, so the gap is in Studio's historical backfill.

The earlier deployments of this subgraph no longer exist, so there was nothing
to graft from.

## How it works

- `scripts/fetch-logs.py` downloads every log of the contract from Blockscout.
- `scripts/gen-history.js` decodes them with the ABI and writes
  `src/history.ts`: one call to the normal handler per event, in chain order.
- `subgraph.yaml` starts at the snapshot block and has a block handler with
  `filter: kind: once` that runs the replay.

Deployed as `refi-colombia-lending-celo-usd` for contract `0x505E65f7D854d4a564b5486d59c91E1DfE627579`.
After deploying, the entity counts were checked against the explorer's event
counts and match for every event type.

## Regenerating

```bash
SNAP=<recent block>
python3 scripts/fetch-logs.py <contract> logs.json $((SNAP-1))
npm install ethers
node scripts/gen-history.js abis/ReFiMedLend.json logs.json src/history.ts $SNAP <contract>
# set startBlock to $SNAP in subgraph.yaml, then: graph codegen && graph build && graph deploy <slug>
```

The COPm contract (`0x563456095a3a16f86885ED0CB22fE8Af14e700B7`) emits a newer
`UserQuotaIncreaseRequest` event, so its subgraph is built from the branch
`fix/signing-and-token-handling` (see `subgraph/celo-copm-history`).
`config/*.json` now use the real deployment blocks of each contract.
