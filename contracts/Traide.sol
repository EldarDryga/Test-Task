// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Implementation ERC721 NFT with ERC20 tokens wrapping functionality
 */
contract traide is ERC721, Ownable {
    //Data for swap from ERC20 to USDC
    ISwapRouter public constant swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint24 public constant poolFee = 3000;
    // Counter for id of NFT
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    IERC20 private tokenToExchange;
    //NFT data structure
    struct NFTData {
        uint256 tokenId;
        address owner;
        address usedToken;
    }
    //ERC20 data sctucture
    struct tokenInfo {
        address tokenAddress;
        uint256 amountOfToken;
        uint256 price;
        uint256 ownerFee;
    }
    //mapping for NFT data structure
    mapping(uint256 => NFTData) nftData;
    //mapping for ERC20 data structure
    mapping(address => tokenInfo) InfoOfToken;
    //array of addresses of ERC20 tokens
    address[] internal addressesOfToken;

    constructor() ERC721("Monkey", "MNK") {}

    /**
@dev exchanges ERC20 tokens for NFTs
@param _addressOfTokenToExchange address of the ERC20 token that is intended to be deposited for NFT
 */
    function mintNFTforTokens(address _addressOfTokenToExchange) public {
        require(
            _addressOfTokenToExchange != address(0) &&
                isAddressExists(_addressOfTokenToExchange) == true,
            "Invalid address"
        );

        tokenToExchange = IERC20(_addressOfTokenToExchange);
        InfoOfToken[_addressOfTokenToExchange].amountOfToken += InfoOfToken[
            _addrOfTokenToExchange
        ].price;

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        nftData[tokenId].owner = msg.sender;
        nftData[tokenId].tokenId = tokenId;
        nftData[tokenId].usedToken = _addrOfTokenToExchange;

        tokenToExchange.transferFrom(
            msg.sender,
            address(this),
            InfoOfToken[_tokenAddress].price
        );
        _safeMint(msg.sender, tokenId);
    }
/**
@dev allows to add ERC20 tokens to allowed tokens registry
@param _addressOfTokenToExchange address of the ERC20 token that is intended to be added in allowed registry
@param _price sets the price for 1 NFT of this ERC20 token
 */  
    function addToken(
        address _addrOfTokenToExchange,
        uint256 _price
    ) public onlyOwner {
        InfoOfToken[_addrOfTokenToExchange]
            .tokenAddress = _addrOfTokenToExchange;
        InfoOfToken[_addrOfTokenToExchange].price = _price;
        addressesOfToken.push(_addrOfTokenToExchange);
    }
/**
@dev allows to remove ERC20 tokens from allowed tokens registry
@param _addressOfTokenToExchange address of the ERC20 token to remove from allowed registry
 */  
    function removeToken(address _addrOfTokenToExchange) public onlyOwner {
        for (uint i = 0; i < addressesOfToken.length; i++) {
            if (addressesOfToken[i] == _addrOfTokenToExchange) {
                removeElement(i);
                return ();
            }
            if (i == addressesOfToken.length - 1) {
                revert("No such address");
            }
        }
    }
/**
@dev Burns NFT and and returns 99.5% ERC20 tokens
@param _tokenId Id of token to burn
 */  
    function burnNFT(uint _tokenId) public {
        require(nftData[_tokenId].owner == msg.sender, "You are not an owner");
        address _addrOfTokenToExchange = nftData[_tokenId].usedToken;
        tokenToExchange = IERC20(_address);
        uint amountToReturn = (995 *
            (InfoOfToken[_addrOfTokenToExchange].price)) / 1000;
        InfoOfToken[_addrOfTokenToExchange].amountOfToken -= amountToReturn;
        InfoOfToken[_addrOfTokenToExchange].ownerFee += InfoOfToken[
            _addrOfTokenToExchange
        ].amountOfToken;

        tokenToExchange.transfer(msg.sender, amountToReturn);
        _burn(_tokenId);
    }
/**
@dev Allows to withdraw fees from an exact ERC20 token
@param _addressOfTokenToExchange address of the ERC20 token that is intended to be deposited for NFT
 */  
    function withdrawFee(address _addressOfToken) public onlyOwner {
        require(
            _addressOfToken != address(0) &&
                isAddressExists(_addressOfToken) == true,
            "Invalid address"
        );
        require((InfoOfToken[_addressOfToken].ownerFee) > 0, "No fee yet");

        uint amountOfFee = InfoOfToken[_addressOfToken].ownerFee;

        swapExactInputSingle(amountOfFee, _addressOfToken);
    }
/**
@return addressesOfToken Array of ERC20 token addresses that can be payment
 */  
    function tokensAllowed() public view returns (address[] memory) {
        return addressesOfToken;
    }
/**
@dev Swap from ERC20 token to USDC
@param amountIn amount of fee to swap to USDC
@param _addressOfToken address of the ERC20 token that is intended to be swapped to USDC
 */  
    function swapExactInputSingle(
        uint256 amountIn,
        address _addressOfToken
    ) private returns (uint256 amountOut) {
        TransferHelper.safeApprove(
            _addressOfToken,
            address(swapRouter),
            amountIn
        );

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _addressOfToken,
                tokenOut: USDC,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }
/**
@dev removes element from array
@param index index of element to remove
 */  
    function removeElement(uint index) internal {
        require(index < addressesOfToken.length, "Invalid index");
        for (uint i = index; i < addressesOfToken.length - 1; i++) {
            addressesOfToken[i] = addressesOfToken[i + 1];
        }
        addressesOfToken.pop();
    }
/**
@dev checks if the address exists in array of ERC20 tokens addresses
@param _address address that has to be checked
 */ 
    function isAddressExists(address _address) public view returns (bool) {
        for (uint i = 0; i < addressesOfToken.length; i++) {
            if (addressesOfToken[i] == _address) {
                return true;
            }
        }
        return false;
    }
}
