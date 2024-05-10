import { BigInt, Bytes } from '@graphprotocol/graph-ts';
import {
  Debt as DebtEvent,
  Funded as FundedEvent,
  LendRepaid as LendRepaidEvent,
  Lending as LendingEvent,
  OwnershipTransferred as OwnershipTransferredEvent,
  Paused as PausedEvent,
  RoleAdminChanged as RoleAdminChangedEvent,
  RoleGranted as RoleGrantedEvent,
  RoleRevoked as RoleRevokedEvent,
  TokenAdded as TokenAddedEvent,
  Unpaused as UnpausedEvent,
  UserQuotaIncreaseRequest as UserQuotaIncreaseRequestEvent,
  UserQuotaChanged as UserQuotaChangedEvent,
  UserQuotaSigned as UserQuotaSignedEvent,
  Withdraw as WithdrawEvent,
} from '../generated/ReFiMedLend/ReFiMedLend';
import { log } from '@graphprotocol/graph-ts';

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
  UserQuotaChanged,
  UserQuotaSigned,
  Withdraw,
  User,
  Token,
  UserQuotaRequest,
} from '../generated/schema';

export function handleDebt(event: DebtEvent): void {
  let entity = new Debt(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.debtor = event.params.debtor;
  entity.amount = event.params.amount;
  entity.interests = event.params.interests;
  entity.token = event.params.token;
  entity.decimals = event.params.decimals;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.nonce = event.params.nonce;
  let lending = Lending.load(event.params.nonce.toHex());
  if (lending) {
    lending.currentAmount = lending.currentAmount.minus(event.params.amount);
    lending.currentAmount = lending.currentAmount.plus(event.params.interests);
    lending.lastDebt = event.block.timestamp;
    lending.interests = lending.interests.plus(event.params.interests);
    lending.save();
  }

  entity.save();
}

export function handleFunded(event: FundedEvent): void {
  let entity = new Funded(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.funder = event.params.funder;
  entity.amount = event.params.amount;
  entity.token = event.params.token;
  entity.decimals = event.params.decimals;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleLendRepaid(event: LendRepaidEvent): void {
  let entity = new LendRepaid(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.lender = event.params.lender;
  entity.amount = event.params.amount;
  entity.token = event.params.token;
  entity.decimals = event.params.decimals;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.nonce = event.params.nonce;
  let lending = Lending.load(event.params.nonce.toHex());
  if (lending) {
    lending.repaid = true;
    lending.save();
  }

  entity.save();
}

export function handleLending(event: LendingEvent): void {
  let entity = new Lending(event.params.nonce.toHex());
  entity.lender = event.params.lender;
  entity.amount = event.params.amount;
  entity.token = event.params.token;
  entity.decimals = event.params.decimals;
  entity.currentAmount = event.params.amount;
  entity.paymentDue = event.params.paymentDue;
  entity.lastDebt = event.block.timestamp;
  entity.repaid = false;
  entity.blockNumber = event.block.number;
  entity.interests = BigInt.fromI32(0);
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.previousOwner = event.params.previousOwner;
  entity.newOwner = event.params.newOwner;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handlePaused(event: PausedEvent): void {
  let entity = new Paused(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.account = event.params.account;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleRoleAdminChanged(event: RoleAdminChangedEvent): void {
  let entity = new RoleAdminChanged(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.role = event.params.role;
  entity.previousAdminRole = event.params.previousAdminRole;
  entity.newAdminRole = event.params.newAdminRole;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleRoleGranted(event: RoleGrantedEvent): void {
  let entity = new RoleGranted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.role = event.params.role;
  entity.account = event.params.account;
  entity.sender = event.params.sender;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleRoleRevoked(event: RoleRevokedEvent): void {
  let entity = new RoleRevoked(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.role = event.params.role;
  entity.account = event.params.account;
  entity.sender = event.params.sender;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleTokenAdded(event: TokenAddedEvent): void {
  let token = new Token(event.params.tokenAddress.toHex());
  token.tokenAddress = event.params.tokenAddress;
  token.addedAtTimestamp = event.block.timestamp;
  token.symbol = event.params.symbol;
  token.name = event.params.name;
  token.save();
  let entity = new TokenAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.tokenAddress = event.params.tokenAddress;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleUnpaused(event: UnpausedEvent): void {
  let entity = new Unpaused(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.account = event.params.account;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleUserQuotaIncreaseRequest(
  event: UserQuotaIncreaseRequestEvent
): void {
  let id = event.params.recipent.toHex() + '-' + event.params.index.toString();

  let userQuotaRequest = UserQuotaRequest.load(id);

  if (userQuotaRequest == null) {
    userQuotaRequest = new UserQuotaRequest(id);
    userQuotaRequest.user = event.params.recipent.toHex();
    userQuotaRequest.amount = event.params.amount;
    userQuotaRequest.successfulSigns = 0;
    userQuotaRequest.complete = false;
    userQuotaRequest.signedBy = [];
    userQuotaRequest.signers = event.params.signers.map<string>(
      (signer: Bytes) => signer.toHexString()
    );
  }
  userQuotaRequest.save();

  let user = User.load(event.params.recipent.toHex());
  if (user == null) {
    user = new User(event.params.recipent.toHex());
    user.quota = BigInt.fromI32(0);
  }
  user.save();
}

export function handleUserQuotaChanged(event: UserQuotaChangedEvent): void {
  let entity = new UserQuotaChanged(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.caller = event.params.caller;
  entity.recipent = event.params.recipent;
  entity.amount = event.params.amount;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let user = User.load(event.params.recipent.toHex());

  if (user == null) {
    user = new User(event.params.recipent.toHex());
    user.quota = BigInt.fromI32(0);
  }

  user.quota = event.params.amount;
  user.save();

  entity.save();
}

export function handleUserQuotaSigned(event: UserQuotaSignedEvent): void {
  let id = event.params.recipent.toHex() + '-' + event.params.index.toString();
  let userQuotaRequest = UserQuotaRequest.load(id);

  if (userQuotaRequest) {
    const signedBy = userQuotaRequest.signedBy;
    signedBy.push(event.params.signer.toHexString());
    userQuotaRequest.signedBy = signedBy;
    userQuotaRequest.successfulSigns += 1;
    userQuotaRequest.complete = userQuotaRequest.successfulSigns >= 3;
    userQuotaRequest.save();
  }
}

export function handleWithdraw(event: WithdrawEvent): void {
  let entity = new Withdraw(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.withdrawer = event.params.withdrawer;
  entity.amount = event.params.amount;
  entity.interests = event.params.interests;
  entity.token = event.params.token;
  entity.decimals = event.params.decimals;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}
