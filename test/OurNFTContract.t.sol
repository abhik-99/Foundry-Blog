// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "ds-test/test.sol";
import "forge-std/Test.sol";
import "../src/OurNFTContract.sol";
import "../src/mocks/VRFCoordinatorV2Mock.sol";

contract OurNFTContractTest is Test {
    OurNFTContract nftContract;
    VRFCoordinatorV2Mock vrfContract;

    event SubscriptionCreated(uint64 indexed subId, address owner);
    event SubscriptionFunded(
        uint64 indexed subId,
        uint256 oldBalance,
        uint256 newBalance
    );
    event ConsumerAdded(uint64 indexed subId, address consumer);
    event RandomWordsRequested(
        bytes32 indexed keyHash,
        uint256 requestId,
        uint256 preSeed,
        uint64 indexed subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords,
        address indexed sender
    );
    event RandomWordsFulfilled(
        uint256 indexed requestId,
        uint256 outputSeed,
        uint96 payment,
        bool success
    );

    event ReceivedRandomness(uint256 reqId, uint256 n1, uint256 n2);
    event RequestedRandomness(uint256 reqId, address invoker, string name);

    function setUp() public {
        vrfContract = new VRFCoordinatorV2Mock(0, 0);
        vrfContract.createSubscription();
        nftContract = new OurNFTContract(
            1,
            address(vrfContract),
            bytes32(
                0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f
            )
        );
    }

    function testSubscriptionCreate() public {
        vm.expectEmit(true, true, false, false);
        emit SubscriptionCreated(2, address(this));
        vrfContract.createSubscription();

        (uint96 balance, uint64 reqCount, address owner, ) = vrfContract
            .getSubscription(2);

        // emit log_uint(balance);
        // emit log_uint(reqCount);
        // emit log_address(owner);

        assertEq(balance, 0);
        assertEq(reqCount, 0);
        assertEq(owner, address(this));
    }

    function testSubscriptionFund() public {
        vm.expectEmit(true, true, true, false);
        emit SubscriptionFunded(1, 0, 2 ether);
        vrfContract.fundSubscription(1, 2 ether);
    }

    function testAddConsumer() public {
        vm.expectEmit(true, false, false, true);
        emit ConsumerAdded(1, address(nftContract));
        vrfContract.addConsumer(1, address(nftContract));
    }

    function testRequestIsSent() public {
        vrfContract.fundSubscription(1, 2 ether);
        vrfContract.addConsumer(1, address(nftContract));

        // vm.prank(address(1));
        vm.expectEmit(false, false, false, true);
        emit RequestedRandomness(1, address(this), "Halley");
        nftContract.safeMint("Halley");
    }

    function testRequestIsReceived() public {
        vrfContract.fundSubscription(1, 2 ether);
        vrfContract.addConsumer(1, address(nftContract));

        // vm.prank(address(1));
        vm.expectEmit(true, true, true, false);
        emit RandomWordsRequested(
            bytes32(
                0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f
            ),
            1,
            100,
            1,
            0,
            0,
            0,
            address(nftContract)
        );
        nftContract.safeMint("Halley");
    }

    function testRequestIsProcessed() public {
        vrfContract.fundSubscription(1, 2 ether);
        vrfContract.addConsumer(1, address(nftContract));

        // IMPORTANT: Test Will fail with "ERC721: transfer to non ERC721Receiver implementer" otherwise
        vm.prank(address(1));
        nftContract.safeMint("Halley");

        vm.expectEmit(true, false, false, true);
        emit RandomWordsFulfilled(1, 1, 0, true);
        vrfContract.fulfillRandomWords(1, address(nftContract));
    }

    function testResponseIsReceived() public {
        vrfContract.fundSubscription(1, 2 ether);
        vrfContract.addConsumer(1, address(nftContract));

        // IMPORTANT: Test Will fail with "ERC721: transfer to non ERC721Receiver implementer" otherwise
        vm.prank(address(1));
        nftContract.safeMint("Halley");

        vm.expectEmit(false, false, false, true);
        emit ReceivedRandomness(
            1,
            uint256(keccak256(abi.encode(1, 0))),
            uint256(keccak256(abi.encode(1, 1)))
        );
        vrfContract.fulfillRandomWords(1, address(nftContract));

				(address currentOwner, , string memory name, , ,) = nftContract.getCharacter(0);
				assertEq(currentOwner, address(1));
				assertEq(name, "Halley");
    }
}
