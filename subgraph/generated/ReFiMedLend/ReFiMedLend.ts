// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  ethereum,
  JSONValue,
  TypedMap,
  Entity,
  Bytes,
  Address,
  BigInt,
} from "@graphprotocol/graph-ts";

export class Debt extends ethereum.Event {
  get params(): Debt__Params {
    return new Debt__Params(this);
  }
}

export class Debt__Params {
  _event: Debt;

  constructor(event: Debt) {
    this._event = event;
  }

  get debtor(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get interests(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }

  get token(): Address {
    return this._event.parameters[3].value.toAddress();
  }

  get decimals(): i32 {
    return this._event.parameters[4].value.toI32();
  }

  get nonce(): BigInt {
    return this._event.parameters[5].value.toBigInt();
  }
}

export class Funded extends ethereum.Event {
  get params(): Funded__Params {
    return new Funded__Params(this);
  }
}

export class Funded__Params {
  _event: Funded;

  constructor(event: Funded) {
    this._event = event;
  }

  get funder(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get token(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get decimals(): i32 {
    return this._event.parameters[3].value.toI32();
  }
}

export class LendRepaid extends ethereum.Event {
  get params(): LendRepaid__Params {
    return new LendRepaid__Params(this);
  }
}

export class LendRepaid__Params {
  _event: LendRepaid;

  constructor(event: LendRepaid) {
    this._event = event;
  }

  get lender(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get token(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get decimals(): i32 {
    return this._event.parameters[3].value.toI32();
  }

  get nonce(): BigInt {
    return this._event.parameters[4].value.toBigInt();
  }
}

export class Lending extends ethereum.Event {
  get params(): Lending__Params {
    return new Lending__Params(this);
  }
}

export class Lending__Params {
  _event: Lending;

  constructor(event: Lending) {
    this._event = event;
  }

  get lender(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get token(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get decimals(): i32 {
    return this._event.parameters[3].value.toI32();
  }

  get paymentDue(): BigInt {
    return this._event.parameters[4].value.toBigInt();
  }

  get nonce(): BigInt {
    return this._event.parameters[5].value.toBigInt();
  }
}

export class OwnershipTransferred extends ethereum.Event {
  get params(): OwnershipTransferred__Params {
    return new OwnershipTransferred__Params(this);
  }
}

export class OwnershipTransferred__Params {
  _event: OwnershipTransferred;

  constructor(event: OwnershipTransferred) {
    this._event = event;
  }

  get previousOwner(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get newOwner(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class Paused extends ethereum.Event {
  get params(): Paused__Params {
    return new Paused__Params(this);
  }
}

export class Paused__Params {
  _event: Paused;

  constructor(event: Paused) {
    this._event = event;
  }

  get account(): Address {
    return this._event.parameters[0].value.toAddress();
  }
}

export class RoleAdminChanged extends ethereum.Event {
  get params(): RoleAdminChanged__Params {
    return new RoleAdminChanged__Params(this);
  }
}

export class RoleAdminChanged__Params {
  _event: RoleAdminChanged;

  constructor(event: RoleAdminChanged) {
    this._event = event;
  }

  get role(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get previousAdminRole(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get newAdminRole(): Bytes {
    return this._event.parameters[2].value.toBytes();
  }
}

export class RoleGranted extends ethereum.Event {
  get params(): RoleGranted__Params {
    return new RoleGranted__Params(this);
  }
}

export class RoleGranted__Params {
  _event: RoleGranted;

  constructor(event: RoleGranted) {
    this._event = event;
  }

  get role(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get account(): Address {
    return this._event.parameters[1].value.toAddress();
  }

  get sender(): Address {
    return this._event.parameters[2].value.toAddress();
  }
}

export class RoleRevoked extends ethereum.Event {
  get params(): RoleRevoked__Params {
    return new RoleRevoked__Params(this);
  }
}

export class RoleRevoked__Params {
  _event: RoleRevoked;

  constructor(event: RoleRevoked) {
    this._event = event;
  }

  get role(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get account(): Address {
    return this._event.parameters[1].value.toAddress();
  }

  get sender(): Address {
    return this._event.parameters[2].value.toAddress();
  }
}

export class TokenAdded extends ethereum.Event {
  get params(): TokenAdded__Params {
    return new TokenAdded__Params(this);
  }
}

export class TokenAdded__Params {
  _event: TokenAdded;

  constructor(event: TokenAdded) {
    this._event = event;
  }

  get tokenAddress(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get symbol(): string {
    return this._event.parameters[1].value.toString();
  }

  get name(): string {
    return this._event.parameters[2].value.toString();
  }
}

export class Unpaused extends ethereum.Event {
  get params(): Unpaused__Params {
    return new Unpaused__Params(this);
  }
}

export class Unpaused__Params {
  _event: Unpaused;

  constructor(event: Unpaused) {
    this._event = event;
  }

  get account(): Address {
    return this._event.parameters[0].value.toAddress();
  }
}

export class UserQuotaChanged extends ethereum.Event {
  get params(): UserQuotaChanged__Params {
    return new UserQuotaChanged__Params(this);
  }
}

export class UserQuotaChanged__Params {
  _event: UserQuotaChanged;

  constructor(event: UserQuotaChanged) {
    this._event = event;
  }

  get caller(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get recipent(): Address {
    return this._event.parameters[1].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }
}

export class UserQuotaIncreaseRequest extends ethereum.Event {
  get params(): UserQuotaIncreaseRequest__Params {
    return new UserQuotaIncreaseRequest__Params(this);
  }
}

export class UserQuotaIncreaseRequest__Params {
  _event: UserQuotaIncreaseRequest;

  constructor(event: UserQuotaIncreaseRequest) {
    this._event = event;
  }

  get caller(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get index(): i32 {
    return this._event.parameters[1].value.toI32();
  }

  get recipent(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }

  get signers(): Array<Address> {
    return this._event.parameters[4].value.toAddressArray();
  }
}

export class UserQuotaSigned extends ethereum.Event {
  get params(): UserQuotaSigned__Params {
    return new UserQuotaSigned__Params(this);
  }
}

export class UserQuotaSigned__Params {
  _event: UserQuotaSigned;

  constructor(event: UserQuotaSigned) {
    this._event = event;
  }

  get signer(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get index(): i32 {
    return this._event.parameters[1].value.toI32();
  }

  get recipent(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }
}

export class Withdraw extends ethereum.Event {
  get params(): Withdraw__Params {
    return new Withdraw__Params(this);
  }
}

export class Withdraw__Params {
  _event: Withdraw;

  constructor(event: Withdraw) {
    this._event = event;
  }

  get withdrawer(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get interests(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }

  get token(): Address {
    return this._event.parameters[3].value.toAddress();
  }

  get decimals(): i32 {
    return this._event.parameters[4].value.toI32();
  }
}

export class ReFiMedLend__fundsResult {
  value0: BigInt;
  value1: BigInt;
  value2: BigInt;
  value3: BigInt;

  constructor(value0: BigInt, value1: BigInt, value2: BigInt, value3: BigInt) {
    this.value0 = value0;
    this.value1 = value1;
    this.value2 = value2;
    this.value3 = value3;
  }

  toMap(): TypedMap<string, ethereum.Value> {
    let map = new TypedMap<string, ethereum.Value>();
    map.set("value0", ethereum.Value.fromUnsignedBigInt(this.value0));
    map.set("value1", ethereum.Value.fromUnsignedBigInt(this.value1));
    map.set("value2", ethereum.Value.fromUnsignedBigInt(this.value2));
    map.set("value3", ethereum.Value.fromUnsignedBigInt(this.value3));
    return map;
  }

  getTotalFunds(): BigInt {
    return this.value0;
  }

  getInterests(): BigInt {
    return this.value1;
  }

  getTotalInterestShares(): BigInt {
    return this.value2;
  }

  getInterestPerShare(): BigInt {
    return this.value3;
  }
}

export class ReFiMedLend__getUserLendsPaginatedResultValue0Struct extends ethereum.Tuple {
  get initialAmount(): BigInt {
    return this[0].toBigInt();
  }

  get currentAmount(): BigInt {
    return this[1].toBigInt();
  }

  get token(): Address {
    return this[2].toAddress();
  }

  get expectPaymentDue(): BigInt {
    return this[3].toBigInt();
  }

  get latestDebtTimestamp(): BigInt {
    return this[4].toBigInt();
  }

  get nonce(): BigInt {
    return this[5].toBigInt();
  }
}

export class ReFiMedLend__getUserQuotaRequestsResultValue0Struct extends ethereum.Tuple {
  get amount(): BigInt {
    return this[0].toBigInt();
  }

  get successfulSigns(): i32 {
    return this[1].toI32();
  }

  get signers(): Array<Address> {
    return this[2].toAddressArray();
  }

  get signedBy(): Array<Address> {
    return this[3].toAddressArray();
  }
}

export class ReFiMedLend__userResult {
  value0: BigInt;
  value1: BigInt;
  value2: BigInt;
  value3: BigInt;

  constructor(value0: BigInt, value1: BigInt, value2: BigInt, value3: BigInt) {
    this.value0 = value0;
    this.value1 = value1;
    this.value2 = value2;
    this.value3 = value3;
  }

  toMap(): TypedMap<string, ethereum.Value> {
    let map = new TypedMap<string, ethereum.Value>();
    map.set("value0", ethereum.Value.fromUnsignedBigInt(this.value0));
    map.set("value1", ethereum.Value.fromUnsignedBigInt(this.value1));
    map.set("value2", ethereum.Value.fromUnsignedBigInt(this.value2));
    map.set("value3", ethereum.Value.fromUnsignedBigInt(this.value3));
    return map;
  }

  getQuota(): BigInt {
    return this.value0;
  }

  getCurrentFund(): BigInt {
    return this.value1;
  }

  getInterestShares(): BigInt {
    return this.value2;
  }

  getLastFund(): BigInt {
    return this.value3;
  }
}

export class ReFiMedLend extends ethereum.SmartContract {
  static bind(address: Address): ReFiMedLend {
    return new ReFiMedLend("ReFiMedLend", address);
  }

  DEFAULT_ADMIN_ROLE(): Bytes {
    let result = super.call(
      "DEFAULT_ADMIN_ROLE",
      "DEFAULT_ADMIN_ROLE():(bytes32)",
      [],
    );

    return result[0].toBytes();
  }

  try_DEFAULT_ADMIN_ROLE(): ethereum.CallResult<Bytes> {
    let result = super.tryCall(
      "DEFAULT_ADMIN_ROLE",
      "DEFAULT_ADMIN_ROLE():(bytes32)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBytes());
  }

  INTEREST_RATE_PER_DAY(): BigInt {
    let result = super.call(
      "INTEREST_RATE_PER_DAY",
      "INTEREST_RATE_PER_DAY():(uint256)",
      [],
    );

    return result[0].toBigInt();
  }

  try_INTEREST_RATE_PER_DAY(): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "INTEREST_RATE_PER_DAY",
      "INTEREST_RATE_PER_DAY():(uint256)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  funds(): ReFiMedLend__fundsResult {
    let result = super.call(
      "funds",
      "funds():(uint256,uint256,uint256,uint256)",
      [],
    );

    return new ReFiMedLend__fundsResult(
      result[0].toBigInt(),
      result[1].toBigInt(),
      result[2].toBigInt(),
      result[3].toBigInt(),
    );
  }

  try_funds(): ethereum.CallResult<ReFiMedLend__fundsResult> {
    let result = super.tryCall(
      "funds",
      "funds():(uint256,uint256,uint256,uint256)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      new ReFiMedLend__fundsResult(
        value[0].toBigInt(),
        value[1].toBigInt(),
        value[2].toBigInt(),
        value[3].toBigInt(),
      ),
    );
  }

  getRoleAdmin(role: Bytes): Bytes {
    let result = super.call("getRoleAdmin", "getRoleAdmin(bytes32):(bytes32)", [
      ethereum.Value.fromFixedBytes(role),
    ]);

    return result[0].toBytes();
  }

  try_getRoleAdmin(role: Bytes): ethereum.CallResult<Bytes> {
    let result = super.tryCall(
      "getRoleAdmin",
      "getRoleAdmin(bytes32):(bytes32)",
      [ethereum.Value.fromFixedBytes(role)],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBytes());
  }

  getUserLendsPaginated(
    userAddress: Address,
    page: BigInt,
    pageSize: BigInt,
  ): Array<ReFiMedLend__getUserLendsPaginatedResultValue0Struct> {
    let result = super.call(
      "getUserLendsPaginated",
      "getUserLendsPaginated(address,uint256,uint256):((uint256,uint256,address,uint256,uint256,uint256)[])",
      [
        ethereum.Value.fromAddress(userAddress),
        ethereum.Value.fromUnsignedBigInt(page),
        ethereum.Value.fromUnsignedBigInt(pageSize),
      ],
    );

    return result[0].toTupleArray<ReFiMedLend__getUserLendsPaginatedResultValue0Struct>();
  }

  try_getUserLendsPaginated(
    userAddress: Address,
    page: BigInt,
    pageSize: BigInt,
  ): ethereum.CallResult<
    Array<ReFiMedLend__getUserLendsPaginatedResultValue0Struct>
  > {
    let result = super.tryCall(
      "getUserLendsPaginated",
      "getUserLendsPaginated(address,uint256,uint256):((uint256,uint256,address,uint256,uint256,uint256)[])",
      [
        ethereum.Value.fromAddress(userAddress),
        ethereum.Value.fromUnsignedBigInt(page),
        ethereum.Value.fromUnsignedBigInt(pageSize),
      ],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      value[0].toTupleArray<ReFiMedLend__getUserLendsPaginatedResultValue0Struct>(),
    );
  }

  getUserQuotaRequests(
    userAddress: Address,
    page: BigInt,
    pageSize: BigInt,
  ): Array<ReFiMedLend__getUserQuotaRequestsResultValue0Struct> {
    let result = super.call(
      "getUserQuotaRequests",
      "getUserQuotaRequests(address,uint256,uint256):((uint256,uint8,address[],address[])[])",
      [
        ethereum.Value.fromAddress(userAddress),
        ethereum.Value.fromUnsignedBigInt(page),
        ethereum.Value.fromUnsignedBigInt(pageSize),
      ],
    );

    return result[0].toTupleArray<ReFiMedLend__getUserQuotaRequestsResultValue0Struct>();
  }

  try_getUserQuotaRequests(
    userAddress: Address,
    page: BigInt,
    pageSize: BigInt,
  ): ethereum.CallResult<
    Array<ReFiMedLend__getUserQuotaRequestsResultValue0Struct>
  > {
    let result = super.tryCall(
      "getUserQuotaRequests",
      "getUserQuotaRequests(address,uint256,uint256):((uint256,uint8,address[],address[])[])",
      [
        ethereum.Value.fromAddress(userAddress),
        ethereum.Value.fromUnsignedBigInt(page),
        ethereum.Value.fromUnsignedBigInt(pageSize),
      ],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      value[0].toTupleArray<ReFiMedLend__getUserQuotaRequestsResultValue0Struct>(),
    );
  }

  hasRole(role: Bytes, account: Address): boolean {
    let result = super.call("hasRole", "hasRole(bytes32,address):(bool)", [
      ethereum.Value.fromFixedBytes(role),
      ethereum.Value.fromAddress(account),
    ]);

    return result[0].toBoolean();
  }

  try_hasRole(role: Bytes, account: Address): ethereum.CallResult<boolean> {
    let result = super.tryCall("hasRole", "hasRole(bytes32,address):(bool)", [
      ethereum.Value.fromFixedBytes(role),
      ethereum.Value.fromAddress(account),
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  increaseQuota(
    recipent: Address,
    index: i32,
    caller: Address,
    amount: BigInt,
  ): boolean {
    let result = super.call(
      "increaseQuota",
      "increaseQuota(address,uint16,address,uint256):(bool)",
      [
        ethereum.Value.fromAddress(recipent),
        ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(index)),
        ethereum.Value.fromAddress(caller),
        ethereum.Value.fromUnsignedBigInt(amount),
      ],
    );

    return result[0].toBoolean();
  }

  try_increaseQuota(
    recipent: Address,
    index: i32,
    caller: Address,
    amount: BigInt,
  ): ethereum.CallResult<boolean> {
    let result = super.tryCall(
      "increaseQuota",
      "increaseQuota(address,uint16,address,uint256):(bool)",
      [
        ethereum.Value.fromAddress(recipent),
        ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(index)),
        ethereum.Value.fromAddress(caller),
        ethereum.Value.fromUnsignedBigInt(amount),
      ],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  owner(): Address {
    let result = super.call("owner", "owner():(address)", []);

    return result[0].toAddress();
  }

  try_owner(): ethereum.CallResult<Address> {
    let result = super.tryCall("owner", "owner():(address)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  paused(): boolean {
    let result = super.call("paused", "paused():(bool)", []);

    return result[0].toBoolean();
  }

  try_paused(): ethereum.CallResult<boolean> {
    let result = super.tryCall("paused", "paused():(bool)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  supportsInterface(interfaceId: Bytes): boolean {
    let result = super.call(
      "supportsInterface",
      "supportsInterface(bytes4):(bool)",
      [ethereum.Value.fromFixedBytes(interfaceId)],
    );

    return result[0].toBoolean();
  }

  try_supportsInterface(interfaceId: Bytes): ethereum.CallResult<boolean> {
    let result = super.tryCall(
      "supportsInterface",
      "supportsInterface(bytes4):(bool)",
      [ethereum.Value.fromFixedBytes(interfaceId)],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  user(param0: Address): ReFiMedLend__userResult {
    let result = super.call(
      "user",
      "user(address):(uint256,uint256,uint256,uint256)",
      [ethereum.Value.fromAddress(param0)],
    );

    return new ReFiMedLend__userResult(
      result[0].toBigInt(),
      result[1].toBigInt(),
      result[2].toBigInt(),
      result[3].toBigInt(),
    );
  }

  try_user(param0: Address): ethereum.CallResult<ReFiMedLend__userResult> {
    let result = super.tryCall(
      "user",
      "user(address):(uint256,uint256,uint256,uint256)",
      [ethereum.Value.fromAddress(param0)],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      new ReFiMedLend__userResult(
        value[0].toBigInt(),
        value[1].toBigInt(),
        value[2].toBigInt(),
        value[3].toBigInt(),
      ),
    );
  }
}

export class ConstructorCall extends ethereum.Call {
  get inputs(): ConstructorCall__Inputs {
    return new ConstructorCall__Inputs(this);
  }

  get outputs(): ConstructorCall__Outputs {
    return new ConstructorCall__Outputs(this);
  }
}

export class ConstructorCall__Inputs {
  _call: ConstructorCall;

  constructor(call: ConstructorCall) {
    this._call = call;
  }

  get _attestationResolver(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class ConstructorCall__Outputs {
  _call: ConstructorCall;

  constructor(call: ConstructorCall) {
    this._call = call;
  }
}

export class AddTokenCall extends ethereum.Call {
  get inputs(): AddTokenCall__Inputs {
    return new AddTokenCall__Inputs(this);
  }

  get outputs(): AddTokenCall__Outputs {
    return new AddTokenCall__Outputs(this);
  }
}

export class AddTokenCall__Inputs {
  _call: AddTokenCall;

  constructor(call: AddTokenCall) {
    this._call = call;
  }

  get tokenAddress(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class AddTokenCall__Outputs {
  _call: AddTokenCall;

  constructor(call: AddTokenCall) {
    this._call = call;
  }
}

export class DecreaseQuotaCall extends ethereum.Call {
  get inputs(): DecreaseQuotaCall__Inputs {
    return new DecreaseQuotaCall__Inputs(this);
  }

  get outputs(): DecreaseQuotaCall__Outputs {
    return new DecreaseQuotaCall__Outputs(this);
  }
}

export class DecreaseQuotaCall__Inputs {
  _call: DecreaseQuotaCall;

  constructor(call: DecreaseQuotaCall) {
    this._call = call;
  }

  get recipent(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class DecreaseQuotaCall__Outputs {
  _call: DecreaseQuotaCall;

  constructor(call: DecreaseQuotaCall) {
    this._call = call;
  }
}

export class FundCall extends ethereum.Call {
  get inputs(): FundCall__Inputs {
    return new FundCall__Inputs(this);
  }

  get outputs(): FundCall__Outputs {
    return new FundCall__Outputs(this);
  }
}

export class FundCall__Inputs {
  _call: FundCall;

  constructor(call: FundCall) {
    this._call = call;
  }

  get amount(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }

  get token(): Address {
    return this._call.inputValues[1].value.toAddress();
  }
}

export class FundCall__Outputs {
  _call: FundCall;

  constructor(call: FundCall) {
    this._call = call;
  }
}

export class GetSpareFundsCall extends ethereum.Call {
  get inputs(): GetSpareFundsCall__Inputs {
    return new GetSpareFundsCall__Inputs(this);
  }

  get outputs(): GetSpareFundsCall__Outputs {
    return new GetSpareFundsCall__Outputs(this);
  }
}

export class GetSpareFundsCall__Inputs {
  _call: GetSpareFundsCall;

  constructor(call: GetSpareFundsCall) {
    this._call = call;
  }

  get token(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class GetSpareFundsCall__Outputs {
  _call: GetSpareFundsCall;

  constructor(call: GetSpareFundsCall) {
    this._call = call;
  }
}

export class GrantRoleCall extends ethereum.Call {
  get inputs(): GrantRoleCall__Inputs {
    return new GrantRoleCall__Inputs(this);
  }

  get outputs(): GrantRoleCall__Outputs {
    return new GrantRoleCall__Outputs(this);
  }
}

export class GrantRoleCall__Inputs {
  _call: GrantRoleCall;

  constructor(call: GrantRoleCall) {
    this._call = call;
  }

  get role(): Bytes {
    return this._call.inputValues[0].value.toBytes();
  }

  get account(): Address {
    return this._call.inputValues[1].value.toAddress();
  }
}

export class GrantRoleCall__Outputs {
  _call: GrantRoleCall;

  constructor(call: GrantRoleCall) {
    this._call = call;
  }
}

export class IncreaseQuotaCall extends ethereum.Call {
  get inputs(): IncreaseQuotaCall__Inputs {
    return new IncreaseQuotaCall__Inputs(this);
  }

  get outputs(): IncreaseQuotaCall__Outputs {
    return new IncreaseQuotaCall__Outputs(this);
  }
}

export class IncreaseQuotaCall__Inputs {
  _call: IncreaseQuotaCall;

  constructor(call: IncreaseQuotaCall) {
    this._call = call;
  }

  get recipent(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get index(): i32 {
    return this._call.inputValues[1].value.toI32();
  }

  get caller(): Address {
    return this._call.inputValues[2].value.toAddress();
  }

  get amount(): BigInt {
    return this._call.inputValues[3].value.toBigInt();
  }
}

export class IncreaseQuotaCall__Outputs {
  _call: IncreaseQuotaCall;

  constructor(call: IncreaseQuotaCall) {
    this._call = call;
  }

  get value0(): boolean {
    return this._call.outputValues[0].value.toBoolean();
  }
}

export class PayDebtCall extends ethereum.Call {
  get inputs(): PayDebtCall__Inputs {
    return new PayDebtCall__Inputs(this);
  }

  get outputs(): PayDebtCall__Outputs {
    return new PayDebtCall__Outputs(this);
  }
}

export class PayDebtCall__Inputs {
  _call: PayDebtCall;

  constructor(call: PayDebtCall) {
    this._call = call;
  }

  get amount(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }

  get token(): Address {
    return this._call.inputValues[1].value.toAddress();
  }

  get lendIndex(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }
}

export class PayDebtCall__Outputs {
  _call: PayDebtCall;

  constructor(call: PayDebtCall) {
    this._call = call;
  }
}

export class RenounceOwnershipCall extends ethereum.Call {
  get inputs(): RenounceOwnershipCall__Inputs {
    return new RenounceOwnershipCall__Inputs(this);
  }

  get outputs(): RenounceOwnershipCall__Outputs {
    return new RenounceOwnershipCall__Outputs(this);
  }
}

export class RenounceOwnershipCall__Inputs {
  _call: RenounceOwnershipCall;

  constructor(call: RenounceOwnershipCall) {
    this._call = call;
  }
}

export class RenounceOwnershipCall__Outputs {
  _call: RenounceOwnershipCall;

  constructor(call: RenounceOwnershipCall) {
    this._call = call;
  }
}

export class RenounceRoleCall extends ethereum.Call {
  get inputs(): RenounceRoleCall__Inputs {
    return new RenounceRoleCall__Inputs(this);
  }

  get outputs(): RenounceRoleCall__Outputs {
    return new RenounceRoleCall__Outputs(this);
  }
}

export class RenounceRoleCall__Inputs {
  _call: RenounceRoleCall;

  constructor(call: RenounceRoleCall) {
    this._call = call;
  }

  get role(): Bytes {
    return this._call.inputValues[0].value.toBytes();
  }

  get callerConfirmation(): Address {
    return this._call.inputValues[1].value.toAddress();
  }
}

export class RenounceRoleCall__Outputs {
  _call: RenounceRoleCall;

  constructor(call: RenounceRoleCall) {
    this._call = call;
  }
}

export class RequestIncreaseQuotaCall extends ethereum.Call {
  get inputs(): RequestIncreaseQuotaCall__Inputs {
    return new RequestIncreaseQuotaCall__Inputs(this);
  }

  get outputs(): RequestIncreaseQuotaCall__Outputs {
    return new RequestIncreaseQuotaCall__Outputs(this);
  }
}

export class RequestIncreaseQuotaCall__Inputs {
  _call: RequestIncreaseQuotaCall;

  constructor(call: RequestIncreaseQuotaCall) {
    this._call = call;
  }

  get recipent(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }

  get signers(): Array<Address> {
    return this._call.inputValues[2].value.toAddressArray();
  }
}

export class RequestIncreaseQuotaCall__Outputs {
  _call: RequestIncreaseQuotaCall;

  constructor(call: RequestIncreaseQuotaCall) {
    this._call = call;
  }
}

export class RequestLendCall extends ethereum.Call {
  get inputs(): RequestLendCall__Inputs {
    return new RequestLendCall__Inputs(this);
  }

  get outputs(): RequestLendCall__Outputs {
    return new RequestLendCall__Outputs(this);
  }
}

export class RequestLendCall__Inputs {
  _call: RequestLendCall;

  constructor(call: RequestLendCall) {
    this._call = call;
  }

  get amount(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }

  get token(): Address {
    return this._call.inputValues[1].value.toAddress();
  }

  get paymentDue(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }
}

export class RequestLendCall__Outputs {
  _call: RequestLendCall;

  constructor(call: RequestLendCall) {
    this._call = call;
  }
}

export class RevokeRoleCall extends ethereum.Call {
  get inputs(): RevokeRoleCall__Inputs {
    return new RevokeRoleCall__Inputs(this);
  }

  get outputs(): RevokeRoleCall__Outputs {
    return new RevokeRoleCall__Outputs(this);
  }
}

export class RevokeRoleCall__Inputs {
  _call: RevokeRoleCall;

  constructor(call: RevokeRoleCall) {
    this._call = call;
  }

  get role(): Bytes {
    return this._call.inputValues[0].value.toBytes();
  }

  get account(): Address {
    return this._call.inputValues[1].value.toAddress();
  }
}

export class RevokeRoleCall__Outputs {
  _call: RevokeRoleCall;

  constructor(call: RevokeRoleCall) {
    this._call = call;
  }
}

export class SetInterestPerDayCall extends ethereum.Call {
  get inputs(): SetInterestPerDayCall__Inputs {
    return new SetInterestPerDayCall__Inputs(this);
  }

  get outputs(): SetInterestPerDayCall__Outputs {
    return new SetInterestPerDayCall__Outputs(this);
  }
}

export class SetInterestPerDayCall__Inputs {
  _call: SetInterestPerDayCall;

  constructor(call: SetInterestPerDayCall) {
    this._call = call;
  }

  get interestRate(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }
}

export class SetInterestPerDayCall__Outputs {
  _call: SetInterestPerDayCall;

  constructor(call: SetInterestPerDayCall) {
    this._call = call;
  }
}

export class TransferOwnershipCall extends ethereum.Call {
  get inputs(): TransferOwnershipCall__Inputs {
    return new TransferOwnershipCall__Inputs(this);
  }

  get outputs(): TransferOwnershipCall__Outputs {
    return new TransferOwnershipCall__Outputs(this);
  }
}

export class TransferOwnershipCall__Inputs {
  _call: TransferOwnershipCall;

  constructor(call: TransferOwnershipCall) {
    this._call = call;
  }

  get newOwner(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class TransferOwnershipCall__Outputs {
  _call: TransferOwnershipCall;

  constructor(call: TransferOwnershipCall) {
    this._call = call;
  }
}

export class WithdrawCall extends ethereum.Call {
  get inputs(): WithdrawCall__Inputs {
    return new WithdrawCall__Inputs(this);
  }

  get outputs(): WithdrawCall__Outputs {
    return new WithdrawCall__Outputs(this);
  }
}

export class WithdrawCall__Inputs {
  _call: WithdrawCall;

  constructor(call: WithdrawCall) {
    this._call = call;
  }

  get amount(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }

  get token(): Address {
    return this._call.inputValues[1].value.toAddress();
  }
}

export class WithdrawCall__Outputs {
  _call: WithdrawCall;

  constructor(call: WithdrawCall) {
    this._call = call;
  }
}

export class WithdrawWithoutInterestsCall extends ethereum.Call {
  get inputs(): WithdrawWithoutInterestsCall__Inputs {
    return new WithdrawWithoutInterestsCall__Inputs(this);
  }

  get outputs(): WithdrawWithoutInterestsCall__Outputs {
    return new WithdrawWithoutInterestsCall__Outputs(this);
  }
}

export class WithdrawWithoutInterestsCall__Inputs {
  _call: WithdrawWithoutInterestsCall;

  constructor(call: WithdrawWithoutInterestsCall) {
    this._call = call;
  }

  get amount(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }

  get token(): Address {
    return this._call.inputValues[1].value.toAddress();
  }
}

export class WithdrawWithoutInterestsCall__Outputs {
  _call: WithdrawWithoutInterestsCall;

  constructor(call: WithdrawWithoutInterestsCall) {
    this._call = call;
  }
}
