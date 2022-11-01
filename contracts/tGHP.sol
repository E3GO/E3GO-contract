// contracts/tGHP.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title The Golden Head Project proxy contract
 */
contract tGHP is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ERC1155SupplyUpgradeable
{
    using Counters for Counters.Counter;

    /**
     * @dev Token ID counter
     */
    Counters.Counter internal _tokenIdCounter;

    /**
     * @dev Store the MATIC / USD price feed contract address
     */
    AggregatorV3Interface internal _MATICUSD;

    /**
     * @dev Store the EUR / USD price feed contract address
     */
    AggregatorV3Interface internal _EURUSD;

    /**
     * @dev Wallet where fund will be redirected
     */
    address internal _wallet;

    /**
     * @dev mapping token id to price. EUR is express in cent
     */
    mapping(uint256 => uint256) internal _tokenIdPrice;

    // -----------------------------------------
    // External interface
    // -----------------------------------------

    /**
     * @dev mintTo authorize the mint semi-fongible pass directly by a wallet and also thanks to paper.xyz on-ramp integration
     * @param to wallet where the token will be mint
     * @param tokenId is used to check wich pass will be mint
     * @param amount is the amount of token minted
     */
    function mintTo(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external payable {
        // revert if tokenId has not corresponding pass setup
        require(
            _tokenIdPrice[tokenId] == 0,
            "tGHP: This token isn't setup yet."
        );
        require(
            changeMATICEUR(msg.value) == _tokenIdPrice[tokenId],
            "tGHP: Not enough to buy."
        );

        _forwardFunds();
        _mint(to, tokenId, amount, "");
    }

    /**
     * @dev mintNftTo used to mint an unique token (NFT) for special avantages determined only by the owner
     * @param to wallet where the token will be minted
     */
    function mintNftTo(address to) external onlyOwner {
        _tokenIdCounter.increment();
        _mint(to, _tokenIdCounter.current(), 1, "");
    }

    /**
     * @dev createPass will allow owner to open minting from
     * @param priceEUR is the price that the new pass will be. UNIT : cent euros
     */
    function createPass(uint256 priceEUR) external onlyOwner {
        _tokenIdCounter.increment();
        _tokenIdPrice[_tokenIdCounter.current()] = priceEUR;
    }

    /**
     * @dev
     * @param tokenId_ is the tokenId that the user try to buy with Paper.xyz
     */
    function checkClaimEligibility(uint256 tokenId_)
        external
        view
        returns (string memory)
    {
        if (_tokenIdPrice[tokenId_] == 0)
            return "tGHP: This token isn't setup yet.";
        return "";
    }

    // -----------------------------------------
    // Public interface
    // -----------------------------------------

    /**
     * @dev Initialize proxy function
     *
     */
    function initialize(address priceFeed_MATIC_USD, address priceFeed_EUR_USD)
        public
        initializer
    {
        __ERC1155_init("");
        __ERC1155Supply_init();
        __Ownable_init();
        _MATICUSD = AggregatorV3Interface(priceFeed_MATIC_USD);
        _EURUSD = AggregatorV3Interface(priceFeed_EUR_USD);
    }

    /**
     * @dev Convert weiAmount MATIC into EUR thanks to chainlink oracles
     * @param _weiAmount Matic weiAmount to change into EUR
     */
    function changeMATICEUR(uint256 _weiAmount)
        public
        virtual
        returns (uint256)
    {
        (, int256 MATICUSD, , , ) = _MATICUSD.latestRoundData();
        (, int256 EURUSD, , , ) = _EURUSD.latestRoundData();
        uint8 decEURUSD = _EURUSD.decimals();
        uint8 decMATICUSD = _MATICUSD.decimals();

        // Return EUR with cent precision taking in account decimals variation if there is any
        if (decEURUSD == decMATICUSD)
            return
                (_weiAmount * uint256(MATICUSD) * 100) /
                (uint256(EURUSD) * 10**18);
        else if (decEURUSD < decMATICUSD)
            return ((_weiAmount * uint256(MATICUSD) * 100) /
                (uint256(EURUSD) * 10**(decMATICUSD - decEURUSD + 18)));
        else
            return ((_weiAmount *
                uint256(MATICUSD) *
                100 *
                10**(decEURUSD - decMATICUSD)) / (uint256(EURUSD) * 10**18));
    }

    // -----------------------------------------
    // Internal interface
    // -----------------------------------------

    /**
     * @dev requirement by [OpenZeppelin implementation](https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable-_authorizeUpgrade-address-)
     */
    function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        Address.sendValue(payable(_wallet), msg.value);
    }
}
