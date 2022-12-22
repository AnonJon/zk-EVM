// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./verifier.sol";

contract Note is Verifier {
    constructor() {}

    enum State {
        Invalid,
        Created,
        Spent
    }
    mapping(bytes32 => State) public notes;
    string[] public allNotes;
    bytes32[] public allHashedNotes;

    event ClaimNote(address to, uint256 amount);
    event NoteCreated(bytes32 noteId, uint256 index);

    function createNote(
        address owner,
        uint256 amount,
        string memory encryptedNote
    ) public payable {
        require(msg.value >= amount * (10**18), "not enough ether");
        bytes32 note = sha256(
            abi.encodePacked(bytes32(abi.encodePacked(owner)), bytes32(amount))
        );
        _createNote(note, encryptedNote);
    }

    function claimNote(uint256 amount) public {
        bytes32 note = sha256(
            abi.encodePacked(
                bytes32(abi.encodePacked(msg.sender)),
                bytes32(amount)
            )
        );
        require(notes[note] == State.Created, "note doesnt exist");
        notes[note] = State.Spent;
        (
            bool sent, /*bytes memory data*/

        ) = payable(msg.sender).call{value: amount * (10**18)}("");
        require(sent, "Failed to send Ether");
        emit ClaimNote(msg.sender, amount * (10**18));
    }

    function transferNote(
        Proof memory proof,
        uint256[7] memory input,
        string memory encryptedNote1,
        string memory encryptedNote2
    ) public {
        require(verifyTx(proof, input), "Invalid zk proof");

        bytes32 spendingNote = calcNoteHash(input[0], input[1]);
        require(
            notes[spendingNote] == State.Created,
            "spendingNote doesnt exist"
        );

        notes[spendingNote] = State.Spent;
        bytes32 newNote1 = calcNoteHash(input[2], input[3]);
        _createNote(newNote1, encryptedNote1);
        bytes32 newNote2 = calcNoteHash(input[4], input[5]);
        _createNote(newNote2, encryptedNote2);
    }

    function getNotesLength() public view returns (uint256) {
        return allNotes.length;
    }

    function _createNote(bytes32 note, string memory encryptedNote) internal {
        notes[note] = State.Created;
        allNotes.push(encryptedNote);
        allHashedNotes.push(note);
        emit NoteCreated(note, allNotes.length - 1);
    }

    function calcNoteHash(uint256 _a, uint256 _b)
        internal
        pure
        returns (bytes32 note)
    {
        bytes16 a = bytes16(abi.encodePacked(_a));
        bytes16 b = bytes16(abi.encodePacked(_b));
        bytes memory _note = new bytes(32);

        for (uint256 i = 0; i < 16; i++) {
            _note[i] = a[i];
            _note[16 + i] = b[i];
        }
        note = bytesToBytes32(_note, 0);
    }

    function bytesToBytes32(bytes memory b, uint256 offset)
        internal
        pure
        returns (bytes32)
    {
        bytes32 out;
        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }
}
