// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract traid is SwapToken, ERC721, Ownable {
    using SafeCast for uint256;
    struct tokenInfo {
        address tokenAddress;
        uint256 amountOfToken;
        uint256 price;
        uint256 ownerFee;
    }
    IERC20 private exactToken;
    struct NFTData {
        uint256 tokenId;
        // string baseURI;
        address owner;
        address usedToken;
    }
    mapping(uint256 => NFTData) nftData;
    mapping(address => tokenInfo) InfoOfToken;
    address[] internal addresses;

    constructor() ERC721("Monkey", "MNK") {}

    function mintNFTforTokens(address _tokenAddress) public {
        require(
            _tokenAddress != address(0) &&
                _tokenAddress.isAddressExists == true,
            "Invalid address"
        );
        exactToken = IERC20(_tokenAddress);

        exactToken.safeTransferFrom(
            msg.sender,
            address(this),
            InfoOfToken[_tokenAddress].price
        );
        InfoOfToken[_tokenAddress].amountOfToken += price;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        nftData[_tokenId].owner = msg.sender;
        nftData[_tokenId].tokenId = tokenId;
        nftData[_tokenId].usedToken = _tokenAddress;
    }

    function addToken(address _tokenAddress, uint256 _price) public onlyOwner {
        InfoOfToken[_tokenAddress].tokenAddress = _tokenAddress;
        InfoOfToken[_tokenAddress].price = _price;
        addresses.push(_tokenAddress);
    }

    function removeToken(address _tokenAddress) public onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == _tokenAddress) {
                removeElement(addresses, i);
                return ();
            } else {
                revert("No such address");
            }
        }
    }

    function burnNFT(uint _tokenId) public {
        require(nftData[_tokenId].owner == msg.sender, "You are not an owner");
        address _address = nftData[_tokenId].usedToken;
        exactToken = IERC20(_address);
        uint amountToReturn = (995 * (InfoOfToken[_tokenAddress].price)) / 1000;
        InfoOfToken[_address].amountOfToken -= amountToReturn;
        InfoOfToken[_address].ownerFee += InfoOfToken[_address].amountOfToken;

        exactToken.safeTransfer(msg.sender, amountToReturn);
        _burn(tokenId);
    }

    function withdrawFee(address _addressOfToken) onlyOwner {
        require(
            _addressOfToken != address(0) &&
                _addressOfToken.isAddressExists == true,
            "Invalid address"
        );
        swapExactInputSingle(InfoOfToken[_address].ownerFee, _addressOfToken);
    }

    function tokensAllowed() public view returns (address[] memory) {
        return addresses;
    }

    ISwapRouter public constant swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint24 public constant poolFee = 3000;

    function swapExactInputSingle(
        uint256 amountIn, address _addressOfToken
    ) private returns (uint256 amountOut) {
        TransferHelper.safeApprove(_addressOfToken, address(swapRouter), amountIn);

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

    function removeElement(address[] storage addresses, uint index) internal {
        require(index < addresses.length, "Invalid index");
        for (uint i = index; i < addresses.length - 1; i++) {
            addresses[i] = addresses[i + 1];
        }
        addresses.pop();
    }

    function isAddressExists(address _address) public view returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }
}
