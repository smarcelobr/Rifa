// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "../contracts/Rifa.sol";

contract RifaActor  {

    Rifa rifa;

    /**
 * @dev Set contract deployer as owner
     */
    constructor(Rifa _rifa) {
        rifa = _rifa;
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
}


