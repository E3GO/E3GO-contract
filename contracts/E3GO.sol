// contracts/E3GO.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title E³GO proxy contract
 */
contract E3GO is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ERC1155SupplyUpgradeable
{
    using Counters for Counters.Counter;

    /**
     * @dev Moderator role
     */ 
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    
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
    mapping(uint256 => uint256) internal _tokenIdPrices;

    // -----------------------------------------
    // External interface
    // -----------------------------------------

    /**
     * @dev view specific token price
     * @param tokenId token id
     */
    function tokenIdPrice(uint256 tokenId) external view returns(uint256){
        return _tokenIdPrices[tokenId];
    }
    
    /**
     * @dev see the wallet where funds are transfered 
     * @return wallet 
     */
    function wallet() external view returns(address){
        return _wallet;
    }
    
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
            _tokenIdPrices[tokenId] != 0,
            "tGHP: This token isn't setup yet."
        );
        require(
            changeMATICEUR(msg.value) >= _tokenIdPrices[tokenId],
            "tGHP: Not enough to buy."
        );

        _forwardFunds();
        _mint(to, tokenId, amount, "");
    }

    /**
     * @dev mintNftTo used to mint an unique token (NFT) for special avantages determined only by the owner
     * @param to wallet where the token will be minted
     */
    function mintNftTo(address to) external onlyRole(MODERATOR_ROLE) {
        _tokenIdCounter.increment();
        _mint(to, _tokenIdCounter.current(), 1, "");
    }

    /**
     * @dev createPass will allow owner to open minting from
     * @param priceEUR is the price that the new pass will be. UNIT : cent euros
     */
    function createPass(uint256 priceEUR) external onlyRole(MODERATOR_ROLE) {
        _tokenIdCounter.increment();
        _tokenIdPrices[_tokenIdCounter.current()] = priceEUR;
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
        if (_tokenIdPrices[tokenId_] == 0)
            return "tGHP: This token isn't setup yet.";
        return "";
    }

    // -----------------------------------------
    // Public interface
    // -----------------------------------------

    /**
     * @dev Getter super admin address
     */
    function superAdmin() public virtual view returns(address){
        return payable(0x684F6b7Fd58b27872Fe7ac07375a96630A111742);
    }

    /**
     * @dev Initialize proxy function
     * @param priceFeed_MATIC_USD address Chainlink price feed MATIC USD
     * @param priceFeed_EUR_USD address Chainlink price feed EUR USD
     * @param wallet_ address where funds will be transfered
     */
    function initialize(address priceFeed_MATIC_USD, address priceFeed_EUR_USD, address wallet_)
        public
        initializer
    {
        __ERC1155_init("");
        __ERC1155Supply_init();
        __AccessControl_init();
        _MATICUSD = AggregatorV3Interface(priceFeed_MATIC_USD);
        _EURUSD = AggregatorV3Interface(priceFeed_EUR_USD);
        _wallet = wallet_;
        _grantRole(DEFAULT_ADMIN_ROLE, superAdmin());
        _grantRole(MODERATOR_ROLE, superAdmin());
    }

    /**
     * @dev Convert weiAmount MATIC into EUR thanks to chainlink oracles
     * @param _weiAmount Matic weiAmount to change into EUR
     */
    function changeMATICEUR(uint256 _weiAmount)
        public
        virtual
        view 
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

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, ERC1155Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // -----------------------------------------
    // Internal interface
    // -----------------------------------------

    /**
     * @dev requirement by [OpenZeppelin implementation](https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable-_authorizeUpgrade-address-)
     */
    function _authorizeUpgrade(address) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        AddressUpgradeable.sendValue(payable(_wallet), msg.value);
    }
}
