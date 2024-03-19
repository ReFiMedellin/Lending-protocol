// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Utils {
    function calculateInterest(uint8 time, uint120 interestAccrualRate, uint256 currentAmount)
        public
        pure
        returns (uint256)
    {
        uint256 rateAnnual = 6;
        uint256 compoundFrequency = 12;
        uint256 base = 10 ** 6;
        uint256 ratePerPeriod = (rateAnnual * base) / compoundFrequency / 100;

        uint256 timeInMonths = time / 30;

        uint256 total = currentAmount * (base + ratePerPeriod) ** timeInMonths / base ** timeInMonths;

        uint256 interestEarned = total - currentAmount;

        return interestEarned;
    }

    function timestampsToDays(uint256 startTimestamp, uint256 finishTimestamp) internal pure returns (uint256) {
        require(finishTimestamp >= startTimestamp, "Finish timestamp must be greater than start timestamp");
        uint256 timeInSeconds = (finishTimestamp - startTimestamp);
        uint256 time = (timeInSeconds / 86400);
        return time;
    }
}
