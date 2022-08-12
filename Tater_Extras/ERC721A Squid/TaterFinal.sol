// SPDX-License-Identifier: MIT
/*
* ERC721A Gas Optimized Minting
*  created by https://twitter.com/SQUIDzillaz0e
*  Feel free to use and Modify to your needs.
*  
*/

pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "./Ownable.sol";
import "./SafeMath.sol"; 

contract TATERTOWN is ERC721A, Ownable {
    using SafeMath for uint256;

    uint256 MAX_MINTS = 100;
    uint256 MAX_ELEMENTS = 5555;
    uint256 public mintRate = 0.07 ether;
    uint256 public privateMintPrice = 0.055 ether;
    uint256 public MAX_MINT_WHITELIST = 50;
    /*
    * @Dev Booleans for sale states. 
    * salesIsActive must be true in any case to mint
    * privateSaleIsActive must be true in the case of Whitelist mints
    */
    bool public saleIsActive = false;
    bool public privateSaleIsActive = true;
    /*
    * @Dev Whitelist Struct and Mappings
    * the address and amount minted to keep track of how many you may mint
    */
    struct Whitelist {
        address addr;
        uint256 claimAmount;
        uint256 hasMinted;
    }

    mapping(address => Whitelist) public whitelist;

    address[] whitelistAddr;


    string public baseURI = "ipfs://QmctVWhKnYK5FDkQAVZf9My2FAhNHmJV6tH6zyB1eGKYHy/";

    constructor() ERC721A("TaterTown", "TATER") {}

    /*
     *  @dev
     * Set presell price to mint
     */
    function setPrivateMintPrice(uint256 _price) external onlyOwner {
        privateMintPrice = _price;
    }

    /*
     *@dev
     * Set publicsell price to mint
     */
    function setPublicMintPrice(uint256 _price) external onlyOwner {
        mintRate = _price;
    }

    /*
    * @dev mint funtion with _to address. no cost mint
    *  by contract owner/deployer
    */
    function Devmint(uint256 quantity, address _to) external payable onlyOwner {
        require(saleIsActive, "Sale must be active to mint");
        require(totalSupply() + quantity <= MAX_ELEMENTS, "Not enough tokens left");
        _safeMint(_to, quantity);
    }

    /*
    * @dev mint function adn checks for saleState and mint quantity
    *
    */    
    function mint(uint256 quantity) external payable {
        require(saleIsActive, "Sale must be active to mint");
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        require(quantity + _numberMinted(msg.sender) <= MAX_MINTS, "Exceeds Max Allowed Mint Count");
        require(totalSupply() + quantity <= MAX_ELEMENTS, "Not enough tokens left to Mint");

        if(privateSaleIsActive) {
           require(msg.value >= (privateMintPrice * quantity), "Not enough ETH sent");
           require(quantity <= MAX_MINT_WHITELIST, "Above max Mint Whitelist count");
           require(isWhitelisted(msg.sender), "Is not whitelisted");
           require(
                whitelist[msg.sender].hasMinted.add(quantity) <=
                    MAX_MINT_WHITELIST,
                "Exceeds Max Mint During Whitelist Period"
            );
            whitelist[msg.sender].hasMinted = whitelist[msg.sender]
                .hasMinted
                .add(quantity);
        } else {
        if (isWhitelisted(msg.sender)) {
            require((balanceOf(msg.sender) - whitelist[msg.sender].hasMinted + quantity) <= MAX_MINTS, "Cant Mint any More Tokens");
        } else {
            require((balanceOf(msg.sender) + quantity) <= MAX_MINTS, "Cant Mint any More Tokens");
        }
            require(
                (mintRate * quantity) <= msg.value,
                "Value below price"
            );
        }


        if (totalSupply() < MAX_ELEMENTS){
        _safeMint(msg.sender, quantity);
        }
    }

    function setMaxMints(uint256 _max) external onlyOwner {
        MAX_MINTS = _max;
    }

    function setMaxMintsWhiteList(uint256 _wlMax) external onlyOwner {
        MAX_MINT_WHITELIST = _wlMax;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function maxSupply() external view returns (uint256) {
        return MAX_ELEMENTS;
    }

    function maxAllowedMints() external view returns (uint256) {
        return MAX_MINTS;
    }

    function publicmintPrice() external view returns (uint256) {
    return mintRate;
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setPublicRate(uint256 _mintRate) public onlyOwner {
        mintRate = _mintRate;
    }

     /*
     * Pause sale if active, make active if paused
     */

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }
    
    /*
    * @dev flip sale state form whitelist to public
    *
    */
    function flipPrivateSaleState() public onlyOwner {
        privateSaleIsActive = !privateSaleIsActive;
    }

    function setWhitelistAddr(address[] memory addrs) public onlyOwner {
        whitelistAddr = addrs;
        for (uint256 i = 0; i < whitelistAddr.length; i++) {
            addAddressToWhitelist(whitelistAddr[i]);
        }
    }

    function toWithdraw(uint256 _amount, address payable _to)
        external
        onlyOwner
    {
        require(_amount > 0, "Withdraw must be greater than 0");
        require(_amount <= address(this).balance, "Amount too high");
        (bool success, ) = _to.call{value: _amount}("");
        require(success);
    }

    function addAddressToWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        require(!isWhitelisted(addr), "Already whitelisted");
        whitelist[addr].addr = addr;
        success = true;
    }
    
    /*
    * @dev return a boolean true or false if
    * an address is whitelisted on etherscan
    * or frontend
    */
    function isWhitelisted(address addr)
        public
        view
        returns (bool isWhiteListed)
    {
        return whitelist[addr].addr == addr;
    }

}