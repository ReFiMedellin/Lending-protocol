import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract LiquidityManager is Ownable {
    event TokenAdded(address indexed tokenAddress);

    mapping(address => bool) internal _tokens;

    function addToken(address tokenAddress) external onlyOwner {
        _tokens[tokenAddress] = true;
        emit TokenAdded(tokenAddress);
    }
}
