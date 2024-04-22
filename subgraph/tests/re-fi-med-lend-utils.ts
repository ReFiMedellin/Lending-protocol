import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt, Bytes } from "@graphprotocol/graph-ts"
import {
  Debt,
  Funded,
  LendRepaid,
  Lending,
  OwnershipTransferred,
  Paused,
  RoleAdminChanged,
  RoleGranted,
  RoleRevoked,
  TokenAdded,
  Unpaused,
  UserQuotaIncreaseRequest,
  UserQuotaIncreased,
  UserQuotaSigned,
  Withdraw
} from "../generated/ReFiMedLend/ReFiMedLend"

export function createDebtEvent(
  debtor: Address,
  amount: BigInt,
  interests: BigInt,
  token: Address,
  decimals: i32
): Debt {
  let debtEvent = changetype<Debt>(newMockEvent())

  debtEvent.parameters = new Array()

  debtEvent.parameters.push(
    new ethereum.EventParam("debtor", ethereum.Value.fromAddress(debtor))
  )
  debtEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  debtEvent.parameters.push(
    new ethereum.EventParam(
      "interests",
      ethereum.Value.fromUnsignedBigInt(interests)
    )
  )
  debtEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  debtEvent.parameters.push(
    new ethereum.EventParam(
      "decimals",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(decimals))
    )
  )

  return debtEvent
}

export function createFundedEvent(
  funder: Address,
  amount: BigInt,
  token: Address,
  decimals: i32
): Funded {
  let fundedEvent = changetype<Funded>(newMockEvent())

  fundedEvent.parameters = new Array()

  fundedEvent.parameters.push(
    new ethereum.EventParam("funder", ethereum.Value.fromAddress(funder))
  )
  fundedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  fundedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  fundedEvent.parameters.push(
    new ethereum.EventParam(
      "decimals",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(decimals))
    )
  )

  return fundedEvent
}

export function createLendRepaidEvent(
  lender: Address,
  amount: BigInt,
  token: Address,
  decimals: i32
): LendRepaid {
  let lendRepaidEvent = changetype<LendRepaid>(newMockEvent())

  lendRepaidEvent.parameters = new Array()

  lendRepaidEvent.parameters.push(
    new ethereum.EventParam("lender", ethereum.Value.fromAddress(lender))
  )
  lendRepaidEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  lendRepaidEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  lendRepaidEvent.parameters.push(
    new ethereum.EventParam(
      "decimals",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(decimals))
    )
  )

  return lendRepaidEvent
}

export function createLendingEvent(
  lender: Address,
  amount: BigInt,
  token: Address,
  decimals: i32
): Lending {
  let lendingEvent = changetype<Lending>(newMockEvent())

  lendingEvent.parameters = new Array()

  lendingEvent.parameters.push(
    new ethereum.EventParam("lender", ethereum.Value.fromAddress(lender))
  )
  lendingEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  lendingEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  lendingEvent.parameters.push(
    new ethereum.EventParam(
      "decimals",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(decimals))
    )
  )

  return lendingEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent = changetype<OwnershipTransferred>(
    newMockEvent()
  )

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}

export function createPausedEvent(account: Address): Paused {
  let pausedEvent = changetype<Paused>(newMockEvent())

  pausedEvent.parameters = new Array()

  pausedEvent.parameters.push(
    new ethereum.EventParam("account", ethereum.Value.fromAddress(account))
  )

  return pausedEvent
}

export function createRoleAdminChangedEvent(
  role: Bytes,
  previousAdminRole: Bytes,
  newAdminRole: Bytes
): RoleAdminChanged {
  let roleAdminChangedEvent = changetype<RoleAdminChanged>(newMockEvent())

  roleAdminChangedEvent.parameters = new Array()

  roleAdminChangedEvent.parameters.push(
    new ethereum.EventParam("role", ethereum.Value.fromFixedBytes(role))
  )
  roleAdminChangedEvent.parameters.push(
    new ethereum.EventParam(
      "previousAdminRole",
      ethereum.Value.fromFixedBytes(previousAdminRole)
    )
  )
  roleAdminChangedEvent.parameters.push(
    new ethereum.EventParam(
      "newAdminRole",
      ethereum.Value.fromFixedBytes(newAdminRole)
    )
  )

  return roleAdminChangedEvent
}

export function createRoleGrantedEvent(
  role: Bytes,
  account: Address,
  sender: Address
): RoleGranted {
  let roleGrantedEvent = changetype<RoleGranted>(newMockEvent())

  roleGrantedEvent.parameters = new Array()

  roleGrantedEvent.parameters.push(
    new ethereum.EventParam("role", ethereum.Value.fromFixedBytes(role))
  )
  roleGrantedEvent.parameters.push(
    new ethereum.EventParam("account", ethereum.Value.fromAddress(account))
  )
  roleGrantedEvent.parameters.push(
    new ethereum.EventParam("sender", ethereum.Value.fromAddress(sender))
  )

  return roleGrantedEvent
}

export function createRoleRevokedEvent(
  role: Bytes,
  account: Address,
  sender: Address
): RoleRevoked {
  let roleRevokedEvent = changetype<RoleRevoked>(newMockEvent())

  roleRevokedEvent.parameters = new Array()

  roleRevokedEvent.parameters.push(
    new ethereum.EventParam("role", ethereum.Value.fromFixedBytes(role))
  )
  roleRevokedEvent.parameters.push(
    new ethereum.EventParam("account", ethereum.Value.fromAddress(account))
  )
  roleRevokedEvent.parameters.push(
    new ethereum.EventParam("sender", ethereum.Value.fromAddress(sender))
  )

  return roleRevokedEvent
}

export function createTokenAddedEvent(tokenAddress: Address): TokenAdded {
  let tokenAddedEvent = changetype<TokenAdded>(newMockEvent())

  tokenAddedEvent.parameters = new Array()

  tokenAddedEvent.parameters.push(
    new ethereum.EventParam(
      "tokenAddress",
      ethereum.Value.fromAddress(tokenAddress)
    )
  )

  return tokenAddedEvent
}

export function createUnpausedEvent(account: Address): Unpaused {
  let unpausedEvent = changetype<Unpaused>(newMockEvent())

  unpausedEvent.parameters = new Array()

  unpausedEvent.parameters.push(
    new ethereum.EventParam("account", ethereum.Value.fromAddress(account))
  )

  return unpausedEvent
}

export function createUserQuotaIncreaseRequestEvent(
  caller: Address,
  recipent: Address,
  amount: BigInt,
  signers: Array<Address>
): UserQuotaIncreaseRequest {
  let userQuotaIncreaseRequestEvent = changetype<UserQuotaIncreaseRequest>(
    newMockEvent()
  )

  userQuotaIncreaseRequestEvent.parameters = new Array()

  userQuotaIncreaseRequestEvent.parameters.push(
    new ethereum.EventParam("caller", ethereum.Value.fromAddress(caller))
  )
  userQuotaIncreaseRequestEvent.parameters.push(
    new ethereum.EventParam("recipent", ethereum.Value.fromAddress(recipent))
  )
  userQuotaIncreaseRequestEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  userQuotaIncreaseRequestEvent.parameters.push(
    new ethereum.EventParam("signers", ethereum.Value.fromAddressArray(signers))
  )

  return userQuotaIncreaseRequestEvent
}

export function createUserQuotaIncreasedEvent(
  caller: Address,
  recipent: Address,
  amount: BigInt
): UserQuotaIncreased {
  let userQuotaIncreasedEvent = changetype<UserQuotaIncreased>(newMockEvent())

  userQuotaIncreasedEvent.parameters = new Array()

  userQuotaIncreasedEvent.parameters.push(
    new ethereum.EventParam("caller", ethereum.Value.fromAddress(caller))
  )
  userQuotaIncreasedEvent.parameters.push(
    new ethereum.EventParam("recipent", ethereum.Value.fromAddress(recipent))
  )
  userQuotaIncreasedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return userQuotaIncreasedEvent
}

export function createUserQuotaSignedEvent(
  signer: Address,
  recipent: Address,
  amount: BigInt
): UserQuotaSigned {
  let userQuotaSignedEvent = changetype<UserQuotaSigned>(newMockEvent())

  userQuotaSignedEvent.parameters = new Array()

  userQuotaSignedEvent.parameters.push(
    new ethereum.EventParam("signer", ethereum.Value.fromAddress(signer))
  )
  userQuotaSignedEvent.parameters.push(
    new ethereum.EventParam("recipent", ethereum.Value.fromAddress(recipent))
  )
  userQuotaSignedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return userQuotaSignedEvent
}

export function createWithdrawEvent(
  withdrawer: Address,
  amount: BigInt,
  interests: BigInt,
  token: Address,
  decimals: i32
): Withdraw {
  let withdrawEvent = changetype<Withdraw>(newMockEvent())

  withdrawEvent.parameters = new Array()

  withdrawEvent.parameters.push(
    new ethereum.EventParam(
      "withdrawer",
      ethereum.Value.fromAddress(withdrawer)
    )
  )
  withdrawEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  withdrawEvent.parameters.push(
    new ethereum.EventParam(
      "interests",
      ethereum.Value.fromUnsignedBigInt(interests)
    )
  )
  withdrawEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  withdrawEvent.parameters.push(
    new ethereum.EventParam(
      "decimals",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(decimals))
    )
  )

  return withdrawEvent
}
