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
  event SubscriptionFunded(uint64 indexed subId, uint256 oldBalance, uint256 newBalance);

  function setUp() public {
    vrfContract = new VRFCoordinatorV2Mock(0,0);
    vrfContract.createSubscription();
    nftContract = new OurNFTContract(1, address(vrfContract), bytes32(0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f));

  }

  function testSubscriptionCreate() public {

    vm.expectEmit(true, true, false, false);
    emit SubscriptionCreated(2, address(this));
    vrfContract.createSubscription();

    
    (uint96 balance, uint64 reqCount, address owner, ) = vrfContract.getSubscription(2);
    
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

}