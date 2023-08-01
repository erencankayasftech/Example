// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTExample is ERC721Enumerable, Ownable {
    uint256 private nextTokenId = 1;
    address private liquidAccount;
    address private treasuryAccount;
    uint256 private royaltyFeeRate = 1;

    struct NFTMetadataAccount {
        string Name;
        string TokenUrl;
    }

    mapping(uint256 => NFTMetadataAccount) private nftMetadataAccount;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function setNFTValuables(string memory _name, string memory _tokenUrl, uint256 price) external {
    
    if(price > 0){
        uint256 tokenId = nextTokenId;
        _mint(msg.sender, tokenId);
        nftMetadataAccount[tokenId] = NFTMetadataAccount(_name, _tokenUrl);
        nextTokenId++;

        uint256 royaltyFee = (price * royaltyFeeRate) / 10;
        uint256 treasuryAmount = royaltyFee * 3 / 5;
        uint256 liquidityAmount = royaltyFee * 2 / 5;
        payable(treasuryAccount).transfer(treasuryAmount);
        payable(liquidAccount).transfer(liquidityAmount);
    }
    else{
        revert("Fiyat O'dan buyuk olmalidir.");
    }

     
    }

    function setRoyaltyFeeRate(uint256 rate) external onlyOwner {
        require(rate <= 100, "Oran 100'den dusuk olmalidir.");
        royaltyFeeRate = rate;
    }

    function setWallesAccounts(address _liquidAccount, address _treasuryAccount) external onlyOwner {
        require(_liquidAccount.balance > 0 , "Likidite hesabinin bakiyesi 0'dan buyuk olmalidir.");
        
        liquidAccount = _liquidAccount;
        treasuryAccount = _treasuryAccount;
    }

    function getNFTMetadataAccount(uint256 tokenId) external view returns (NFTMetadataAccount memory) {
        return nftMetadataAccount[tokenId];
    }
}
