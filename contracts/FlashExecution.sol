pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

import "./aave/FlashLoanReceiverBase.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/ILendingPool.sol";
import "./IKyberNetworkProxy.sol";
import "./IUniswapExchange.sol";
import "./IUniswapFactory.sol";
import "./IBancorNetwork.sol";
import "./IWETH.sol";

interface OrFeedInterface {
    function getExchangeRate(string calldata fromSymbol, string calldata toSymbol, string calldata venue, uint256 amount) external view returns (uint256);
    function getTokenDecimalCount(address tokenAddress) external view returns (uint256);
    function getTokenAddress(string calldata symbol) external view returns (address);
    function getSynthBytes32(string calldata symbol) external view returns (bytes32);
    function getForexAddress(string calldata symbol) external view returns (address);
    function arb(address fundsReturnToAddress, address liquidityProviderContractAddress, string[] calldata tokens, uint256 amount, string[] calldata exchanges) external payable returns (bool);
}

contract FlashExecution is FlashLoanReceiverBase {

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    ) external {
        require(
            _amount <= getBalanceInternal(address(this), _reserve),
            "Invalid balance, was the flashload successful? Need a fee in the balance"
        );

        // arbitrage, refinance loan, swap collaterals
        // place the orfeed contract address to use arb
        // https://etherscan.io/address/0x8316b082621cfedab95bf4a44a1d4b64a6ffc336#code
        OrFeedInterface orfeedContract = OrFeedInterface(address(0x8316B082621CFedAB95bf4a44a1d4B64a6ffc336));

        // approve arbitrage token in advance for OrFeed, DAI must have been approved sufficiently
        // IERC20 _token = IERC20(_reserve);
        // _token.approve(address(0x8316B082621CFedAB95bf4a44a1d4B64a6ffc336), 10000000000000000000000000000);

        string[] memory tokenOrder = new string[](3);
        string[] memory exchangeOrder = new string[](3);

        tokenOrder[0] = "DAI";
        tokenOrder[1] = "WETH";
        tokenOrder[2] = "DAI";

        exchangeOrder[0] = "UNISWAP";
        exchangeOrder[1] = "UNISWAP";
        exchangeOrder[2] = "UNISWAP";

        // call OrFeed arb function to perform token swaps via multiple exchanges
        orfeedContract.arb(address(this), address(this), tokenOrder, _amount, exchangeOrder);

        // Time to transfer the funds back with the fee
        uint256 totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }
}
