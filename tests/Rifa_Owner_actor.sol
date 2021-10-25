// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "../contracts/Rifa.sol";

contract RifaOwnerActor  {

    Rifa rifa;

    /**
 * @dev Set contract deployer as owner
     */
    constructor(uint8 _qtdCotas, uint _valorDaCota, string memory _nome) {
        rifa = new Rifa(_qtdCotas, _valorDaCota, _nome);
    }

    function getRifa() public view returns (Rifa) {
        return rifa;
    }

    function adquirirCota (uint8 numCota) external payable {
        rifa.adquirirCota{value: msg.value}(numCota);
    }

    function confirmarRecebimento() external {
        rifa.confirmarRecebimento{gas: 50000}();
    }

    function sortear() external {
        rifa.sortear();
    }

    // necessário para conseguir receber ether
    // ref.: https://solidity-by-example.org/sending-ether/
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    // ref.: https://solidity-by-example.org/sending-ether/
    fallback() external payable {}

    // ref.: https://solidity-by-example.org/sending-ether/
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}