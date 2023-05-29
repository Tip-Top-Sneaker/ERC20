// SPDX-License-Identifier: GPL-2.0-or-later
// LiquidityPositionRetriever.sol
pragma solidity =0.7.6;
pragma abicoder v2;

import './LiquidityPositionBase.sol';

contract LiquidityPositionRetrieve is LiquidityPositionBase {
    constructor(INonfungiblePositionManager _nonfungiblePositionManager)
        LiquidityPositionBase(_nonfungiblePositionManager)
    {}

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
