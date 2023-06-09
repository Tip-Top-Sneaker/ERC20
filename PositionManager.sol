// SPDX-License-Identifier: GPL-2.0-or-later
// Lp_Manager.sol
// Provide full range liquidity for FUC/WETH 
pragma solidity ^0.7.6;
pragma abicoder v2;

//import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
//import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
//import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
//import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
 
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC20 {
   
    event Transfer(address indexed from, address indexed to, uint256 value);

  
    event Approval(address indexed owner, address indexed spender, uint256 value);

  
    function totalSupply() external view returns (uint256);

 
    function balanceOf(address account) external view returns (uint256);

  
    function transfer(address to, uint256 amount) external returns (bool);

  
    function allowance(address owner, address spender) external view returns (uint256);

 
    function approve(address spender, uint256 amount) external returns (bool);

 
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract PositionManager is IERC721Receiver {
    // 
    address public constant POOL_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;


    address public constant FUC = 0x1F52145666C862eD3E2f1Da213d479E61b2892af;
    address public constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    uint24 public constant poolFee = 10000;

    INonfungiblePositionManager public immutable nonfungiblePositionManager;


    event NewPositionMinted(address sender, uint256 tokenId, address userAddress, address token0Address, address token1Address, uint256 amount0, uint256 amount1);


    /// @notice Represents the deposit of an NFT
    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    /// @dev deposits[tokenId] => Deposit
    mapping(uint256 => Deposit) public deposits;

    constructor(
        INonfungiblePositionManager _nonfungiblePositionManager
    ) {
        nonfungiblePositionManager = _nonfungiblePositionManager;
    }
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

     function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }


    // Implementing `onERC721Received` so this contract can receive custody of erc721 tokens
    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // get position information

        _createDeposit(operator, tokenId);

        return this.onERC721Received.selector;
    }

    function _createDeposit(address owner, uint256 tokenId) internal {
        (, , address token0, address token1, , , , uint128 liquidity, , , , ) =
            nonfungiblePositionManager.positions(tokenId);

        // set the owner and data for position
        // operator is msg.sender
        deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
    }

    /// @notice Calls the mint function defined in periphery, mints the same amount of each token.
    /// For this example we are providing 1000 FUC and 1000 WETH in liquidity
    /// @return tokenId The id of the newly minted ERC721
    /// @return liquidity The amount of liquidity for the position
    /// @return amount0 The amount of token0
    /// @return amount1 The amount of token1
    function mintNewPosition(address to, uint256 amount0ToMint, uint256 amount1ToMint)
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        // Before minting, check if the user has enough FUC and WETH
    require(IERC20(FUC).balanceOf(msg.sender) >= amount0ToMint, "Not enough FUC in account");
    require(IERC20(WETH).balanceOf(msg.sender) >= amount1ToMint, "Not enough WETH in account");

        // transfer tokens to contract
        safeTransferFrom(FUC, msg.sender, address(this), amount0ToMint);
        safeTransferFrom(WETH, msg.sender, address(this), amount1ToMint);

        // Approve the position manager
        safeApprove(FUC, address(nonfungiblePositionManager), amount0ToMint);
        safeApprove(WETH, address(nonfungiblePositionManager), amount1ToMint);

        INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                token0: FUC,
                token1: WETH,
                fee: poolFee,
                tickLower: -887272,
                tickUpper: 887272,
                amount0Desired: amount0ToMint,
                amount1Desired: amount1ToMint,
                amount0Min: 0,
                amount1Min: 0,
                recipient: to,  // recipient is set to the provided address 'to'
                deadline: block.timestamp
            });

   

        // Note that the pool defined by FUC/WETH and fee tier 0.3% must already be created and initialized in order to mint
        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

        // Emit the new event
         emit NewPositionMinted(msg.sender, tokenId, to, FUC, WETH, amount0, amount1);
        
        // Create a deposit
        _createDeposit(to, tokenId);

        // Remove allowance and refund in both assets.
        if (amount0 < amount0ToMint) {
            safeApprove(FUC, address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToMint - amount0;
            safeTransfer(FUC, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            safeApprove(WETH, address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToMint - amount1;
            safeTransfer(WETH, msg.sender, refund1);
        }
    }

  

   

    

    /// @notice Transfers funds to owner of NFT
    /// @param tokenId The id of the erc721
    /// @param amount0 The amount of token0
    /// @param amount1 The amount of token1
    function _sendToOwner(
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1
    ) internal {
        // get owner of contract
        address owner = deposits[tokenId].owner;

        address token0 = deposits[tokenId].token0;
        address token1 = deposits[tokenId].token1;
        // send collected fees to owner
        safeTransfer(token0, owner, amount0);
        safeTransfer(token1, owner, amount1);
    }

    /// @notice Transfers the NFT to the owner
    /// @param tokenId The id of the erc721
    function retrieveNFT(uint256 tokenId) external {
        // must be the owner of the NFT
        require(msg.sender == deposits[tokenId].owner, 'Not the owner');
        // transfer ownership to original owner
        nonfungiblePositionManager.safeTransferFrom(address(this), msg.sender, tokenId);
        //remove information related to tokenId
        delete deposits[tokenId];
    }
}
