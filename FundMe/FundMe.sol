//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    uint256 public minUSD = 5*1e18; //can also be writte as 5e18 (1e18)

    address[] public listOfSenders;
    mapping(address funder => uint256 amtFunded) public addressToAmount;

    function fund() public payable{
        require(getConversionRate(msg.value) > minUSD, "Not enough funds");
        listOfSenders.push(msg.sender);
        addressToAmount[msg.sender] = addressToAmount[msg.sender] + msg.value;
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        //Price of ETH in terms of USD
        return uint256(price * 1e10); // We do this because msg.value has 18 decimal places and this `price` var has 8, so we multiply by 1e10 to make them equal
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; //multiply first because solidity doesn't support decimals, and returns whole numbers so calculations can go wrong
        return ethAmountInUsd;
    }

    function getVersion() public view returns (uint256) {
        return (AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)).version();
    }
}
