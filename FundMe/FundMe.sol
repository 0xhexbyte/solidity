//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5*1e18; //can also be writte as 5e18 (1e18)
    address[] public listOfSenders;
    address public immutable i_owner;
    mapping(address funder => uint256 amtFunded) public addressToAmount;

    constructor() {
        i_owner = msg.sender; 
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Not enough funds");
        listOfSenders.push(msg.sender);
        addressToAmount[msg.sender] = addressToAmount[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {
        //for loop
        // 
        for(uint256 funderIndex=0; funderIndex<listOfSenders.length; funderIndex++) {
            address funder = listOfSenders[funderIndex];
            addressToAmount[funder]=0;
        }
        //reset the array
        listOfSenders = new address[](0);
        //withdraw the funds
      
        //msg.address = address
        //payable(msg.sender) = payable address
        // transfer - errors out
        payable(msg.sender).transfer(address(this).balance);
        // send - reverts with a boolean
        bool success = payable(msg.sender).send(address(this).balance);
        require(success, "Send failed");
        // call - allows us to make a call and send msg.value, and returns 2 params
        // bool points if the call was successful or not, returned bytes saves any data returned by that function
        // since bytes objest is an array, it needs to be stored in memory
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        // we can leave the second var blank, saying that we know it returns this data but we don't need it
        require(callSuccess, "Call failed");
    }
    modifier onlyOwner(){
        //require(msg.sender == i_owner, "Must be owner");
        if (msg.sender != i_owner) { revert NotOwner(); }
        _;
    }
}
