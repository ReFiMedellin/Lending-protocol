// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ReFiMedLend.sol";
import "../src/ReFiMedLendResolver.sol";
import "./MockERC20.sol";
import "@/library/LendManagerUtils.sol";

contract ReFiMedLendTest is Test {
    event Funded(address indexed funder, uint256 amount, address indexed token, uint8 decimals);

    event Withdraw(
        address indexed withdrawer, uint256 amount, uint256 interests, address indexed token, uint8 decimals
    );

    event Debt(
        address indexed debtor, uint256 amount, uint256 interests, address indexed token, uint8 decimals, uint256 nonce
    );

    event LendRepaid(address indexed lender, uint256 amount, address indexed token, uint8 decimals, uint256 nonce);

    event Lending(
        address indexed lender, uint256 amount, address indexed token, uint8 decimals, uint256 paymentDue, uint256 nonce
    );

    event UserQuotaIncreaseRequest(
        address indexed caller, uint16 indexed index, address indexed recipent, uint256 amount, address[] signers
    );

    event UserQuotaChanged(address indexed caller, address indexed recipent, uint256 amount);

    event UserQuotaSigned(address indexed signer, uint16 indexed index, address indexed recipent, uint256 amount);

    event TokenAdded(address indexed tokenAddress, string symbol, string name);

    using stdStorage for StdStorage;

    uint256 private immutable _SCALAR = 1e3;

    ReFiMedLendResolver public resolver;
    ReFiMedLend public refiMedLend;

    MockERC20 public token;
    address public currentUser = address(1);
    address public owner = address(this);
    address public signer1 = address(2);
    address public signer2 = address(3);
    address public signer3 = address(4);
    address public funder = address(5);

    function setUp() public {
        refiMedLend = new ReFiMedLend(address(this));
        token = new MockERC20();
        refiMedLend.addToken(address(token));
        token.mint(address(owner), 10000 * 1e18);
        token.mint(address(funder), 10000 * 1e18);
    }

    function prepareFunding(uint256 amount) internal {
        token.approve(address(refiMedLend), amount * 1e18);
        refiMedLend.fund(amount, address(token));
    }

    function prepareQuotaIncrease(uint256 amount) internal {
        address[] memory signers = new address[](3);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        refiMedLend.requestIncreaseQuota(currentUser, amount, signers);
    }

    function prepareSignIncreaseQuota(uint256 amount) internal {
        address[] memory signers = new address[](3);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        refiMedLend.requestIncreaseQuota(currentUser, amount, signers);
        refiMedLend.increaseQuota(currentUser, 0, signer1, amount * 1e3);
        refiMedLend.increaseQuota(currentUser, 0, signer2, amount * 1e3);
        refiMedLend.increaseQuota(currentUser, 0, signer3, amount * 1e3);
    }

    function testFund() public {
        prepareFunding(1000);
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        (uint256 totalFunds, uint256 interests, uint256 totalInterestShares, uint256 interestPerShare) =
            refiMedLend.funds();
        assertEq(totalFunds, 1000 * _SCALAR);
        assertEq(totalInterestShares, 1000 * _SCALAR);
    }

    function testRequestIncreaseQuota() public {
        address[] memory signers = new address[](3);
        prepareFunding(1000);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        vm.expectEmit(true, true, false, true);
        emit UserQuotaIncreaseRequest(owner, 0, currentUser, 500, signers);
        prepareQuotaIncrease(500);
    }

    function testSignIncreaseQuota() public {
        address[] memory signers = new address[](3);
        prepareFunding(1000);
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        uint256 amount = 500;
        prepareQuotaIncrease(amount);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer1, 0, currentUser, 500 * 1e3);
        refiMedLend.increaseQuota(currentUser, 0, signer1, amount * 1e3);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer2, 0, currentUser, 500 * 1e3);
        refiMedLend.increaseQuota(currentUser, 0, signer2, amount * 1e3);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaChanged(signer3, currentUser, 500 * 1e3);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer3, 0, currentUser, 500 * 1e3);
        refiMedLend.increaseQuota(currentUser, 0, signer3, amount * 1e3);
    }

    function _generateLendingId() private returns (uint256) {
        uint256 _lendNonce = 0;
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _lendNonce)));
        _lendNonce++;
        return random;
    }

    function testMakeLend() public {
        address[] memory signers = new address[](3);
        prepareFunding(1000);
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        prepareSignIncreaseQuota(500);
        vm.prank(currentUser);
        vm.expectEmit(true, true, false, true);
        uint256 nonce = _generateLendingId();
        emit Lending(currentUser, 500000, address(token), 18, 1001, nonce);
        refiMedLend.requestLend(500, address(token), block.timestamp + 1000);
        assert(token.balanceOf(address(refiMedLend)) == 500 * 1e18);
    }

    function testPayFullLend() public {
        address[] memory signers = new address[](3);
        prepareFunding(1000);
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        prepareSignIncreaseQuota(500);
        vm.prank(currentUser);
        refiMedLend.requestLend(500, address(token), block.timestamp + 1000);
        assert(token.balanceOf(address(refiMedLend)) == 500 * 1e18);
        uint256 time = LendManagerUtils.timestampsToDays(block.timestamp, block.timestamp + 31556926);
        (uint256 _interest, uint256 _totalDebt) =
            LendManagerUtils.calculateInterest(time, refiMedLend.INTEREST_RATE_PER_DAY(), 500 * _SCALAR);
        vm.warp(31556927);
        vm.prank(currentUser);
        token.approve(address(refiMedLend), 530663 * 1e15);
        token.mint(address(currentUser), 530663 * 1e15);
        vm.prank(currentUser);
        refiMedLend.payDebt(_totalDebt, address(token), 0);
        (uint256 totalFunds, uint256 interests, uint256 totalInterestShares, uint256 interestPerShare) =
            refiMedLend.funds();
        console.log(interests);
        assert(interests == 30663);
    }

    function testPartialyPayLend() public {
        address[] memory signers = new address[](3);
        prepareFunding(1000);
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        prepareSignIncreaseQuota(500);
        vm.prank(currentUser);
        refiMedLend.requestLend(500, address(token), block.timestamp + 1000);
        assert(token.balanceOf(address(refiMedLend)) == 500 * 1e18);
        uint256 time = LendManagerUtils.timestampsToDays(block.timestamp, block.timestamp + 31556926);
        (uint256 _interest, uint256 _totalDebt) =
            LendManagerUtils.calculateInterest(time, refiMedLend.INTEREST_RATE_PER_DAY(), 500 * _SCALAR);
        console.log("timesTamp: ", block.timestamp);
        vm.warp(31556927);
        vm.prank(currentUser);
        token.approve(address(refiMedLend), _totalDebt * 1e15);
        token.mint(address(currentUser), _totalDebt * 1e15);
        vm.prank(currentUser);
        refiMedLend.payDebt(200 * 1e3, address(token), 0);
        (uint256 totalFunds, uint256 interests, uint256 totalInterestShares, uint256 interestPerShare) =
            refiMedLend.funds();
        assert(interests == _interest);
    }

    function testCorrectWithdraw() public {
        address[] memory signers = new address[](3);

        prepareFunding(1000);
        prepareSignIncreaseQuota(500);

        vm.prank(currentUser);
        refiMedLend.requestLend(500, address(token), block.timestamp + 1000);

        uint256 time = LendManagerUtils.timestampsToDays(block.timestamp, block.timestamp + 31556926);
        (uint256 _interest, uint256 _totalDebt) =
            LendManagerUtils.calculateInterest(time, refiMedLend.INTEREST_RATE_PER_DAY(), 500 * _SCALAR);
        console.log("timesTamp: ", block.timestamp);
        vm.warp(31556927);
        vm.prank(currentUser);
        token.approve(address(refiMedLend), _totalDebt * 1e15);
        token.mint(address(currentUser), _totalDebt * 1e15);
        vm.prank(currentUser);
        refiMedLend.payDebt(_totalDebt, address(token), 0);
        console.log("Balance", token.balanceOf(address(refiMedLend)) / 1e18);

        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(address(owner), 1000, 30663, address(token), 18);
        refiMedLend.withdraw(1000, address(token));
        assert(token.balanceOf(address(refiMedLend)) == 0);
        console.log("Balance", token.balanceOf(address(refiMedLend)));
        token.mint(address(refiMedLend), 1000 * 1e18);
        vm.expectRevert();
        refiMedLend.withdraw(1000, address(token));
        (uint256 totalFunds, uint256 interests, uint256 totalInterestShares, uint256 interestPerShare) =
            refiMedLend.funds();

        assertEq(totalFunds, 0);
        assertEq(interests, 0);
        assertEq(totalInterestShares, 0);
    }

    function testCorrectMultipleWithdraw() public {
        address[] memory signers = new address[](3);
        prepareFunding(1000);
        vm.startPrank(funder);
        prepareFunding(1000);
        vm.stopPrank();
        assertEq(token.balanceOf(address(refiMedLend)), 2000 * 1e18);
        prepareSignIncreaseQuota(1300);

        vm.prank(currentUser);
        refiMedLend.requestLend(1300, address(token), block.timestamp + 1000);
        uint256 time = LendManagerUtils.timestampsToDays(block.timestamp, block.timestamp + 31556926);
        (uint256 _interest, uint256 _totalDebt) =
            LendManagerUtils.calculateInterest(time, refiMedLend.INTEREST_RATE_PER_DAY(), 1300 * _SCALAR);
        vm.warp(31556927);
        vm.prank(currentUser);
        token.approve(address(refiMedLend), _totalDebt * 1e15);
        token.mint(address(currentUser), _totalDebt * 1e15);
        vm.prank(currentUser);
        refiMedLend.payDebt(_totalDebt, address(token), 0);
        vm.prank(owner);
        refiMedLend.withdraw(1000, address(token));
        vm.prank(funder);
        refiMedLend.withdraw(1000, address(token));
        console.log("Balance", token.balanceOf(address(refiMedLend)));
        assertEq(token.balanceOf(address(refiMedLend)), 0);
        (uint256 totalFunds, uint256 interests, uint256 totalInterestShares, uint256 interestPerShare) =
            refiMedLend.funds();
        console.log("totalFunds: ", totalFunds);
        console.log("interests: ", interests);
        console.log("totalInterestShares: ", totalInterestShares);
        console.log("interestPerShare: ", interestPerShare);
        assertEq(totalFunds, 0);
        assertEq(interests, 0);
        assertEq(totalInterestShares, 0);
    }
}
