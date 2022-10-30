// contracts/tGHP.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";

/**
 * @title The Golden Head Project proxy contract
 */
contract tGHP is Initializable, UUPSUpgradeable, OwnableUpgradeable, ERC1155Upgradeable, ERC1155SupplyUpgradeable {
    
    struct Pass {
        uint256 startDate;
        uint256 endDate;
        uint256 priceEUR;
    }

    mapping(uint256 => Pass) tokenIdInfo;

    // -----------------------------------------
    // External interface
    // -----------------------------------------

    // -----------------------------------------
    // Public interface
    // -----------------------------------------

    /**
     * @dev Initialize proxy function 
     * 
     */
    function initialize() public initializer {
        __ERC1155_init("");
        __ERC1155Supply_init();
        __Ownable_init();
    }
    
    // -----------------------------------------
    // Internal interface
    // -----------------------------------------

    /**
     * @dev requirement by [OpenZeppelin implementation](https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable-_authorizeUpgrade-address-)
     */
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
    }
}