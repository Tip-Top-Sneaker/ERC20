## Contract: PositionManager

The `PositionManager` contract is designed to manage liquidity positions on Uniswap V3. It interacts with the `INonfungiblePositionManager` interface from Uniswap V3 to mint, collect, and burn liquidity positions. It also implements the `IERC721Receiver` interface to handle the receipt of ERC721 tokens.

### State Variables:

- `POOL_ADDRESS`: The address of the Uniswap V3 pool.
- `FUC`: The address of the FUC token.
- `WETH`: The address of the WETH token.
- `poolFee`: The fee tier of the pool.
- `nonfungiblePositionManager`: The instance of the `INonfungiblePositionManager` contract.
- `deposits`: A mapping that stores the `Deposit` struct against each tokenId.

### Structs:

- `Deposit`: Represents the deposit of an NFT. It includes the owner of the deposit, the liquidity of the deposit, and the addresses of token0 and token1.

### Events:

- `NewPositionMinted`: Emitted when a new position is minted. It includes the sender of the transaction, the tokenId of the minted position, the recipient of the position, the addresses of token0 and token1, and the amounts of token0 and token1.

### Constructor:

- Takes an instance of `INonfungiblePositionManager` as a parameter and initializes the `nonfungiblePositionManager` state variable.

### Functions:

- `safeTransfer`: An internal function that safely transfers a given amount of a token to a specified address.
- `safeApprove`: An internal function that safely approves a specified address to spend a given amount of a token.
- `safeTransferFrom`: An internal function that safely transfers a given amount of a token from a specified address to another.
- `onERC721Received`: An override function that is called when an ERC721 token is transferred to this contract. It creates a deposit for the received token and returns the selector of this function.
- `_createDeposit`: An internal function that creates a deposit for a given tokenId.
- `mintNewPosition`: A public function that mints a new position. It transfers the required tokens to the contract, approves the `nonfungiblePositionManager` to spend the tokens, mints the position, creates a deposit for the minted position, and refunds any leftover tokens to the sender.
- `_sendToOwner`: An internal function that transfers funds to the owner of a given tokenId.
- `retrieveNFT`: A public function that transfers an NFT to its owner and deletes the deposit of the NFT. It requires that the caller is the owner of the NFT.

### Interfaces:

- `IERC721Receiver`: An interface that includes the `onERC721Received` function. This function is called whenever an ERC721 token is transferred to this contract.
- `IERC20`: An interface that includes the standard functions of an ERC20 token. These functions are used to interact with the FUC and WETH tokens.
- `INonfungiblePositionManager`: An interface from Uniswap V3 that includes functions to mint, collect, and burn liquidity positions.

This contract provides a way to manage liquidity positions on Uniswap V3. It handles the minting of positions, the collection of fees, and the retrieval of NFTs. It also ensures that only the owner of an NFT can retrieve it.
