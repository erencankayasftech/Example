// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    uint256 private nextTokenId = 1;
    address private liquidityWallet;
    address private treasuryWallet;
    uint256 private royaltyFeePercentage = 10;

    struct NFTMetadata {
        string name;
        string tokenURI;
    }

    mapping(uint256 => NFTMetadata) private nftMetadata;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mintNFT(string memory name, string memory tokenURI, uint256 price) external {
        require(price > 0, "Price must be greater than 0");
        uint256 tokenId = nextTokenId;
        _mint(msg.sender, tokenId);
        nftMetadata[tokenId] = NFTMetadata(name, tokenURI);
        nextTokenId++;

        uint256 royaltyFee = (price * royaltyFeePercentage) / 100;
        uint256 treasuryAmount = royaltyFee * 6 / 10;
        uint256 liquidityAmount = royaltyFee * 4 / 10;
        payable(treasuryWallet).transfer(treasuryAmount);
        payable(liquidityWallet).transfer(liquidityAmount);
    }

    function setRoyaltyFeePercentage(uint256 percentage) external onlyOwner {
        require(percentage <= 100, "Percentage must be less than or equal to 100");
        royaltyFeePercentage = percentage;
    }

    function setWallets(address _liquidityWallet, address _treasuryWallet) external onlyOwner {
        liquidityWallet = _liquidityWallet;
        treasuryWallet = _treasuryWallet;
    }

    function getNFTMetadata(uint256 tokenId) external view returns (NFTMetadata memory) {
        return nftMetadata[tokenId];
    }
}