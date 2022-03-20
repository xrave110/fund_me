// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getSender() public view returns (address) {
        return msg.sender;
    }

    function fund() public payable {
        uint256 minUsd = 50 * (10**18);
        require(
            _getConversionRate(msg.value) >= minUsd,
            "You need to spend more ETH (more than 50 USD)"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function _getPrice() private view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10**10);
    }

    function _getConversionRate(uint256 ethAmount)
        private
        view
        returns (uint256)
    {
        uint256 ethPrice = _getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 10**10;
        return ethAmountInUsd;
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        return _getConversionRate(ethAmount) / 10**18;
    }

    function getPrice() public view returns (uint256) {
        return _getPrice() / 10**18;
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); //new blank array
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = _getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }
}
