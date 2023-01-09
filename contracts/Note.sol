// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;
import "./Verifier.sol";

contract Note is Verifier {
    constructor() {}

    enum State {
        Invalid,
        Created,
        Spent
    }
    struct NoteInfo {
        State state;
        bytes32 encryptedNote;
        string encryptedNoteString;
    }
    // mapping(bytes32 => State) public notes;
    mapping(address => mapping(uint256 => NoteInfo)) private userNotes;
    mapping(address => uint256[]) public userTxs;

    // string[] public allNotes;
    // bytes32[] public allHashedNotes;

    event ClaimNote(address to, uint256 amount);
    event NoteCreated(bytes32 indexed noteId, uint256 indexed timestamp);

    function createNote(string memory encryptedNote) external payable {
        bytes32 note = sha256(
            abi.encodePacked(
                bytes32(abi.encodePacked(msg.sender)),
                bytes32(msg.value)
            )
        );
        _createNote(note, encryptedNote);
    }

    function _createNote(bytes32 note, string memory encryptedNote) internal {
        userNotes[msg.sender][block.timestamp] = NoteInfo({
            state: State.Created,
            encryptedNote: note,
            encryptedNoteString: encryptedNote
        });
        userTxs[msg.sender].push(block.timestamp);
        emit NoteCreated(note, block.timestamp);
    }

    function getNotesByUser() external view returns (NoteInfo[] memory) {
        uint256[] memory txs = userTxs[msg.sender];
        NoteInfo[] memory notes = new NoteInfo[](txs.length);
        for (uint256 i = 0; i < txs.length; i++) {
            NoteInfo memory n = userNotes[msg.sender][txs[i]];
            notes[i] = n;
        }
        return notes;
    }

    function claimNote(
        uint256 amountToClaim,
        uint256 totalAmount,
        string memory encryptedNote,
        uint256 timestamp
    ) external {
        require(amountToClaim <= totalAmount, "Trying to claim too much");
        // bytes32 note = sha256(
        //     abi.encodePacked(
        //         bytes32(abi.encodePacked(msg.sender)),
        //         bytes32(totalAmount)
        //     )
        // );
        NoteInfo memory n = userNotes[msg.sender][timestamp];
        require(n.state == State.Created, "note doesnt exist");
        userNotes[msg.sender][timestamp].state = State.Spent;
        (
            bool sent, /*bytes memory data*/

        ) = payable(msg.sender).call{value: amountToClaim}("");
        require(sent, "Failed to send Ether");
        emit ClaimNote(msg.sender, amountToClaim);
        if (amountToClaim != totalAmount) {
            bytes32 newNote = sha256(
                abi.encodePacked(
                    bytes32(abi.encodePacked(msg.sender)),
                    bytes32(totalAmount - amountToClaim)
                )
            );
            _createNote(newNote, encryptedNote);
        }
    }

    function transferNote(
        Proof memory proof,
        uint256[7] memory input,
        string memory encryptedNote1,
        string memory encryptedNote2,
        uint256 timestamp
    ) external {
        require(verifyTx(proof, input), "Invalid zk proof");
        NoteInfo memory spendingNote = userNotes[msg.sender][timestamp];
        require(
            spendingNote.state == State.Created,
            "spendingNote doesnt exist"
        );

        userNotes[msg.sender][timestamp].state = State.Spent;
        bytes32 newNote1 = calcNoteHash(input[2], input[3]);
        _createNote(newNote1, encryptedNote1);
        bytes32 newNote2 = calcNoteHash(input[4], input[5]);
        _createNote(newNote2, encryptedNote2);
    }

    // function getNotesLength() external view returns (uint256) {
    //     return allNotes.length;
    // }

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
