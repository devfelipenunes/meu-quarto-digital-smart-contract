// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MeuQuartoDigital is ERC1155Supply, Ownable {
    using Strings for uint256;

    struct Creator {
        bool isRegistered;
        uint256 subscriptionPrice;
    }

    struct Subscriber {
        uint256 expiration;
        bool hasReceivedReward;
    }

    uint256 public rewardPeriod = 180 days;
    uint256 public rewardNFTId = 1;

    mapping(address => Creator) public creators;
    mapping(address => mapping(address => Subscriber)) public subscribers;
    mapping(address => uint256[]) public creatorNFTs;

    event CreatorRegistered(address indexed creator, uint256 subscriptionPrice);
    event Subscription(address indexed subscriber, address indexed creator, uint256 expiration);
    event NFTCreated(address indexed creator, uint256 id, uint256 amount, uint256 price);
    event RewardClaimed(address indexed subscriber, address indexed creator);

    // Construtor com a URI base e endereço do proprietário inicial
    constructor(string memory uri, address initialOwner) ERC1155(uri) Ownable(initialOwner) {}

    function registerCreator(uint256 subscriptionPrice) external {
        require(!creators[msg.sender].isRegistered, "Creator already registered");

        creators[msg.sender] = Creator({
            isRegistered: true,
            subscriptionPrice: subscriptionPrice
        });

        emit CreatorRegistered(msg.sender, subscriptionPrice);
    }

    function subscribe(address creator) external payable {
        require(creators[creator].isRegistered, "Creator not registered");
        require(msg.value == creators[creator].subscriptionPrice, "Incorrect value sent");

        subscribers[creator][msg.sender] = Subscriber({
            expiration: block.timestamp + 30 days,
            hasReceivedReward: false
        });

        payable(creator).transfer(msg.value);

        emit Subscription(msg.sender, creator, block.timestamp + 30 days);
    }

    function claimReward(address creator) external {
        Subscriber storage subscriber = subscribers[creator][msg.sender];
        require(block.timestamp > subscriber.expiration + rewardPeriod, "Reward period not reached");
        require(!subscriber.hasReceivedReward, "Reward already claimed");

        _mint(msg.sender, rewardNFTId, 1, "");

        subscriber.hasReceivedReward = true;

        emit RewardClaimed(msg.sender, creator);
    }

    function createNFT(uint256 amount, uint256 price) external {
        require(creators[msg.sender].isRegistered, "Only registered creators can create NFTs");

        uint256 newItemId = totalSupply(rewardNFTId) + 1; // Simple NFT ID generation
        _mint(msg.sender, newItemId, amount, "");

        creatorNFTs[msg.sender].push(newItemId);

        emit NFTCreated(msg.sender, newItemId, amount, price);
    }

    function buyNFT(address creator, uint256 nftId, uint256 amount) external payable {
        require(creators[creator].isRegistered, "Creator not registered");
        require(balanceOf(creator, nftId) >= amount, "Not enough NFT supply");
        
        uint256 price = 0.1 ether; // Placeholder price, replace with actual logic
        require(msg.value == price * amount, "Incorrect value sent");

        safeTransferFrom(creator, msg.sender, nftId, amount, "");

        payable(creator).transfer(msg.value);
    }

    function uri(uint256 _tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(_tokenId), _tokenId.toString()));
    }
}
