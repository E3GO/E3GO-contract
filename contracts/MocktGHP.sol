// contracts/MocktGHP.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

import "./tGHP.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title MocktGHP.sol
 * WARNING: use only for testing and debugging purpose
 */
 contract MocktGHP is tGHP {
    
    function coverage() external {
        super._authorizeUpgrade(address(this));
    }

 }

contract TestMaticUsd is AggregatorV3Interface{
    
    constructor(){
        
    }

    function decimals() external  pure returns (uint8){
        return 8;
    }

    function description() external  pure returns (string memory){
        return "test Matic Usd"; 
    }

    function version() external pure returns (uint256){
        return 1;
    }

    function getRoundData(uint80 _roundId)
        external
        pure
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        ){
            return (0,135800000,0,0,0);
        }

    function latestRoundData()
        external
        pure
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        ){
            return (0,135800000,0,0,0);
        }
}

contract TestEurUsd is AggregatorV3Interface{
    
    uint8 decimal = 8;

    function setDecimal(uint8 n) public {
        decimal = n;
    }

    function decimals() external view returns (uint8){
        return decimal;
    }

    function description() external  pure returns (string memory){
        return "test Eur Usd"; 
    }

    function version() external pure returns (uint256){
        return 1;
    }

    function getRoundData(uint80 _roundId)
        external
        pure
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        ){
            return (0,107800000,0,0,0);
        }

    function latestRoundData()
        external
        pure
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        ){
            return (0,107800000,0,0,0);
        }
}
