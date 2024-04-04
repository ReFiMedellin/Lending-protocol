// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Utils {
    function calculateInterest(uint256 time, uint120 interestAccrualRate, uint256 currentAmount)
        public
        pure
        returns (uint256)
    {
        if (time == 0) {
            return 0;
        }
        uint256 compoundFrequency = 12;
        uint256 base = 10 ** 6;
        uint256 ratePerPeriod = (interestAccrualRate * base) / compoundFrequency / 100;

        uint256 total = currentAmount * (base + ratePerPeriod) ** time / base ** time;

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
