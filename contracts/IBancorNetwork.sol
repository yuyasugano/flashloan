pragma solidity ^0.5.0;

interface IBancorNetwork {
    function getReturnByPath(address[] calldata _path, uint256 _amount) external view returns (uint256, uint256);
    function convert2(address[] calldata _path, uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) external payable returns (uint256);

    function claimAndConvert2(
        address[] calldata _path,
        uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) external returns (uint256);
}

interface IBancorNetworkPathFinder {
    function generatePath(address _sourceToken, address _targetToken) external view returns (address[] memory);
}
