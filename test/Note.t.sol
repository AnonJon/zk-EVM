// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Note.sol";
import "forge-std/console2.sol";

contract NoteTest is Test {
    Note public note;
    address public owner;
    address public address1;

    event NoteCreated(bytes32 indexed noteId, uint256 indexed index);

    function setUp() public {
        note = new Note();
        owner = address(this);
        address1 = vm.addr(1);
    }

    function test_createNote() public {
        vm.expectEmit(true, true, false, false);
        emit NoteCreated(
            sha256(
                abi.encodePacked(
                    bytes32(abi.encodePacked(owner)),
                    bytes32(uint256(1 ether))
                )
            ),
            block.timestamp
        );
        note.createNote{value: uint256(1 ether)}("test");
    }

    function test_claimNote() public {
        vm.startPrank(address1);
        vm.deal(address1, 1 ether);
        note.createNote{value: 1 ether}("test");
        note.claimNote(1 ether, 1 ether, "test", block.timestamp);
        assertTrue(address(note).balance == 0);
    }

    function test_claimNote_claimSome() public {
        vm.startPrank(address1);
        vm.deal(address1, 1 ether);
        note.createNote{value: 1 ether}("test");
        vm.warp(2);
        note.claimNote(0.5 ether, 1 ether, "test", 1);
        console2.log(note.getNotesByUser().length);
    }

    function test_claimNote_fail() public {
        vm.startPrank(address1);
        vm.deal(address1, 1 ether);
        note.createNote{value: 1 ether}("test");
        vm.expectRevert(bytes("Trying to claim too much"));
        note.claimNote(2 ether, 1 ether, "test", block.timestamp);
    }
}
