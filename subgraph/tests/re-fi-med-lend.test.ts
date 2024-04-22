import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts"
import { Debt } from "../generated/schema"
import { Debt as DebtEvent } from "../generated/ReFiMedLend/ReFiMedLend"
import { handleDebt } from "../src/re-fi-med-lend"
import { createDebtEvent } from "./re-fi-med-lend-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let debtor = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let amount = BigInt.fromI32(234)
    let interests = BigInt.fromI32(234)
    let token = Address.fromString("0x0000000000000000000000000000000000000001")
    let decimals = 123
    let newDebtEvent = createDebtEvent(
      debtor,
      amount,
      interests,
      token,
      decimals
    )
    handleDebt(newDebtEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("Debt created and stored", () => {
    assert.entityCount("Debt", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "Debt",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "debtor",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "Debt",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "amount",
      "234"
    )
    assert.fieldEquals(
      "Debt",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "interests",
      "234"
    )
    assert.fieldEquals(
      "Debt",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "token",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "Debt",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "decimals",
      "123"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
