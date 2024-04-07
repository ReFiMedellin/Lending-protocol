// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ReFiMedLend.sol";
import "../src/Resolver.sol";
import "./MockERC20.sol";
import "@/library/LendManagerUtils.sol";

contract ReFiMedLendTest is Test {
    event UserQuotaIncreaseRequest(address indexed caller, address indexed recipent, uint256 amount, address[] signers);
    event UserQuotaSigned(address indexed signer, address indexed recipent, uint256 amount);
    event UserQuotaIncreased(address indexed caller, address indexed recipent, uint256 amount);
    event Lending(address indexed lender, uint256 amount, address indexed token, uint8 decimals);
    event lendRepaid(address indexed lender, uint256 amount, address indexed token, uint8 decimals);
    event Debt(address indexed debtor, uint256 amount, uint256 interests, address indexed token, uint8 decimals);
    event Withdraw(
        address indexed withdrawer, uint256 amount, uint256 interests, address indexed token, uint8 decimals
    );

    using stdStorage for StdStorage;

    uint256 private immutable _SCALAR = 1e3;

    LendResolver public resolver;
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

    function testFund() public {
        token.approve(address(refiMedLend), 1000 * 1e18);
        refiMedLend.fund(1000, address(token));
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        (uint256 totalFunds, uint256 interests, uint256 totalInterestShares, uint256 interestPerShare) =
            refiMedLend.funds();
        assertEq(totalFunds, 1000 * _SCALAR);
        assertEq(totalInterestShares, 1000 * _SCALAR);

        console.log("refiMedLend ERC20 balance: ", token.balanceOf(address(refiMedLend)));
        console.log("totalFunds: ", totalFunds);
        console.log("interests: ", interests);
        console.log("totalInterestShares: ", totalInterestShares);
        console.log("interestPerShare: ", interestPerShare);
    }

    function testRequestIncreaseQuota() public {
        address[] memory signers = new address[](3);
        token.approve(address(refiMedLend), 1000 * 1e18);
        refiMedLend.fund(1000, address(token));
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        vm.expectEmit(true, true, false, true);
        emit UserQuotaIncreaseRequest(owner, currentUser, 500, signers);
        refiMedLend.requestIncreaseQuota(currentUser, 500, signers);
    }

    function testSignIncreaseQuota() public {
        address[] memory signers = new address[](3);
        token.approve(address(refiMedLend), 1000 * 1e18);
        refiMedLend.fund(1000, address(token));
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        refiMedLend.requestIncreaseQuota(currentUser, 500, signers);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer1, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer1);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer2, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer2);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaIncreased(signer3, currentUser, 500);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer3, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer3);
    }

    function testMakeLend() public {
        address[] memory signers = new address[](3);
        token.approve(address(refiMedLend), 1000 * 1e18);
        refiMedLend.fund(1000, address(token));
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        refiMedLend.requestIncreaseQuota(currentUser, 500, signers);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer1, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer1);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer2, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer2);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaIncreased(signer3, currentUser, 500);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer3, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer3);
        vm.prank(currentUser);
        vm.expectEmit(true, true, false, true);
        emit Lending(currentUser, 500, address(token), 18);
        refiMedLend.requestLend(500, address(token), block.timestamp + 1000);
        assert(token.balanceOf(address(refiMedLend)) == 500 * 1e18);
    }

    function testPayFullLend() public {
        address[] memory signers = new address[](3);
        token.approve(address(refiMedLend), 1000 * 1e18);
        refiMedLend.fund(1000, address(token));
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        refiMedLend.requestIncreaseQuota(currentUser, 500, signers);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer1, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer1);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer2, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer2);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaIncreased(signer3, currentUser, 500);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer3, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer3);
        vm.prank(currentUser);
        refiMedLend.requestLend(500, address(token), block.timestamp + 1000);
        assert(token.balanceOf(address(refiMedLend)) == 500 * 1e18);
        uint256 time = Utils.timestampsToDays(block.timestamp, block.timestamp + 31556926);
        (uint256 _interest, uint256 _totalDebt) =
            Utils.calculateInterest(time, refiMedLend.INTEREST_RATE_PER_DAY(), 500 * _SCALAR);
        console.log("timesTamp: ", block.timestamp);
        vm.warp(31556927);
        vm.prank(currentUser);
        token.approve(address(refiMedLend), _totalDebt * 1e15);
        token.mint(address(currentUser), _totalDebt * 1e15);
        vm.prank(currentUser);
        vm.expectEmit(true, true, false, true);
        emit lendRepaid(currentUser, _totalDebt, address(token), 18);
        refiMedLend.payDebt(_totalDebt, address(token), 0);
        (uint256 totalFunds, uint256 interests, uint256 totalInterestShares, uint256 interestPerShare) =
            refiMedLend.funds();
        assert(interests == _interest);
        console.log("_interest: ", _interest);
        console.log("interests: ", interests);
        console.log("Days: ", time);
        console.log("timesTamp: ", block.timestamp);
        console.log("interest per share", interestPerShare);
        console.log("Total shares", totalInterestShares);
    }

    function testPartialyPayLend() public {
        address[] memory signers = new address[](3);
        token.approve(address(refiMedLend), 1000 * 1e18);
        refiMedLend.fund(1000, address(token));
        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        refiMedLend.requestIncreaseQuota(currentUser, 500, signers);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer1, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer1);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer2, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer2);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaIncreased(signer3, currentUser, 500);
        vm.expectEmit(true, true, false, true);
        emit UserQuotaSigned(signer3, currentUser, 500);
        refiMedLend._increaseQuota(currentUser, 0, signer3);
        vm.prank(currentUser);
        refiMedLend.requestLend(500, address(token), block.timestamp + 1000);
        assert(token.balanceOf(address(refiMedLend)) == 500 * 1e18);
        uint256 time = Utils.timestampsToDays(block.timestamp, block.timestamp + 31556926);
        (uint256 _interest, uint256 _totalDebt) =
            Utils.calculateInterest(time, refiMedLend.INTEREST_RATE_PER_DAY(), 500 * _SCALAR);
        console.log("timesTamp: ", block.timestamp);
        vm.warp(31556927);
        vm.prank(currentUser);
        token.approve(address(refiMedLend), _totalDebt * 1e15);
        token.mint(address(currentUser), _totalDebt * 1e15);
        vm.prank(currentUser);
        vm.expectEmit(true, true, false, true);
        emit Debt(currentUser, 200 * 1e3, _interest, address(token), 18);
        refiMedLend.payDebt(200 * 1e3, address(token), 0);
        (uint256 totalFunds, uint256 interests, uint256 totalInterestShares, uint256 interestPerShare) =
            refiMedLend.funds();
        assert(interests == _interest);
        console.log("_interest: ", _interest);
        console.log("interests: ", interests);
        console.log("Days: ", time);
        console.log("timesTamp: ", block.timestamp);
        console.log("interest per share", interestPerShare);
        console.log("Total shares", totalInterestShares);
    }

    function testCorrectWithdraw() public {
        address[] memory signers = new address[](3);

        token.approve(address(refiMedLend), 1000 * 1e18);
        refiMedLend.fund(1000, address(token));

        assertEq(token.balanceOf(address(refiMedLend)), 1000 * 1e18);

        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        refiMedLend.requestIncreaseQuota(currentUser, 500, signers);
        refiMedLend._increaseQuota(currentUser, 0, signer1);
        refiMedLend._increaseQuota(currentUser, 0, signer2);
        refiMedLend._increaseQuota(currentUser, 0, signer3);
        vm.prank(currentUser);
        refiMedLend.requestLend(500, address(token), block.timestamp + 1000);

        uint256 time = Utils.timestampsToDays(block.timestamp, block.timestamp + 31556926);
        (uint256 _interest, uint256 _totalDebt) =
            Utils.calculateInterest(time, refiMedLend.INTEREST_RATE_PER_DAY(), 500 * _SCALAR);
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
        console.log("refiMedLend ERC20 balance: ", token.balanceOf(address(refiMedLend)));
        console.log("totalFunds: ", totalFunds);
        console.log("interests: ", interests);
        console.log("totalInterestShares: ", totalInterestShares);
        console.log("interestPerShare: ", interestPerShare);
        assertEq(totalFunds, 0);
        assertEq(interests, 0);
        assertEq(totalInterestShares, 0);
    }

    function testCorrectMultipleWithdraw() public {
        address[] memory signers = new address[](3);
        token.approve(address(refiMedLend), 1000 * 1e18);
        refiMedLend.fund(1000, address(token));
        vm.prank(funder);
        token.approve(address(refiMedLend), 1000 * 1e18);
        vm.prank(funder);
        refiMedLend.fund(1000, address(token));
        assertEq(token.balanceOf(address(refiMedLend)), 2000 * 1e18);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;
        refiMedLend.requestIncreaseQuota(currentUser, 1300, signers);
        refiMedLend._increaseQuota(currentUser, 0, signer1);
        refiMedLend._increaseQuota(currentUser, 0, signer2);
        refiMedLend._increaseQuota(currentUser, 0, signer3);
        vm.prank(currentUser);
        refiMedLend.requestLend(1300, address(token), block.timestamp + 1000);
        uint256 time = Utils.timestampsToDays(block.timestamp, block.timestamp + 31556926);
        (uint256 _interest, uint256 _totalDebt) =
            Utils.calculateInterest(time, refiMedLend.INTEREST_RATE_PER_DAY(), 1300 * _SCALAR);
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
