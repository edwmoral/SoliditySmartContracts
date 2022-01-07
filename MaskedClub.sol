// SPDX-License-Identifier: MIT
// http://remix.ethereum.org/ 

// Payable NFT minting Smart contract

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MaskedClub is ERC721, Ownable {
    
    using Counters for Counters.Counter;
    using Strings for uint256;    
    Counters.Counter _tokenIds; 
    uint256 public MaskedPrice = 700000000;
    uint256 public MaxMaskedPurchased = 20;
    uint256 public MaxMasked;
    uint256 public MintedMasked=0;

    bool public saleIsActive = false;

    mapping(uint256 => string) _tokenURIs;
    
    struct RenderToken {
        uint256 id;
        string uri;
    }

    //initializes the smart contract  with a maximum ammount of NFTs  
    constructor(uint256 totalSupply) ERC721("MaskedClub", "AC"){
        MaxMasked = totalSupply;
    }
    
    //adds the URI for a new token to the _tokenURIs variable 
    function _setTokenUri(uint256 tokenId, string memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    //used to find URI based on a Token ID
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(_exists(tokenId));
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }
    
    //returns a list with all tokens created
    function getAllTokens() public view returns(RenderToken[] memory){
        uint256 latestId = _tokenIds.current(); 
        uint256 counter =0 ;
        RenderToken[] memory res = new RenderToken[](latestId);
        
        for(uint256  i = 0; i < latestId; i ++ ){
            if(_exists(counter)){
                string memory uri = tokenURI(counter);
                res[counter] = RenderToken(counter, uri);
            }
            counter ++;
            
        }
        return res;
        
    }
    
    //checks how many NFTS have been minted
    function getMintedMasked() public view returns(uint256){       

        return MintedMasked;
        
    }

    //checks maximum number of NFTS that can be minted
    function getMaxMasked() public view returns(uint256){       

        return MaxMasked;
        
    }
    
    // toggles sale on/off
    function flipSaleState() public onlyOwner  returns(bool){
        saleIsActive = !saleIsActive;
        return saleIsActive;
    }
    
    //Internal function. This mints the NFT
    function mint(address recipient, string memory uri) private returns(uint256) { 
        uint256 newId = _tokenIds.current();
        MintedMasked ++;
        _mint(recipient, newId);
        _setTokenUri(newId, uri);
        _tokenIds.increment();
        return newId;
    }

    //Mint multiple Masked
   
    function mintMasked(string[] memory URIs) public payable {
        require(saleIsActive, "Sale must be active to mint Masked");
        require(msg.value == MaskedPrice * URIs.length, "dasdorrect");
        require(URIs.length <= MaxMaskedPurchased, "Can only mint 25 masked at a time");       
        require(URIs.length + MintedMasked <= MaxMasked, "Purchase would exceed max supply of Masked");

        //uint256[] memory newIds;
        for(uint i = 0; i < URIs.length; i++) {            
               mint(msg.sender, URIs[i]);
            } 
  
    }

    //Mint 1 masked
    function mintMasked(string memory URI) public payable returns(uint256){
        require(saleIsActive, "Sale must be active to mint Masked");
        require(msg.value == MaskedPrice, "Ether value sent is not correct");
        require( MintedMasked +1 <= MaxMasked, "Purchase would exceed max supply of Masked");
                          
        return mint(msg.sender, URI);
             
    }

    //Set some Masked  aside
    // these are intended for giveaways
   function reserveMasked(string[] memory URIs) public onlyOwner {        
        require(URIs.length + MintedMasked <= MaxMasked, "Purchase would exceed max supply of Masked");
        require(URIs.length  <= 30, "Cannot generate more than 30 NFTS per at once");      
              
        for (uint256  i = 0; i < URIs.length; i++) {          
            mint(msg.sender, URIs[i]);            
        }


    }

}
