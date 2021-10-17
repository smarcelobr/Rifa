// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/Rifa.sol";

contract RifaTest is Rifa(20, 14, "Caneta") {

    // contas diferentes para testar como participantes
    address acc0;
    address acc1;
    address acc2;
    address acc3;

    //Rifa rifaToTest;
    uint constant t_valorDaCota = 14; // 14 wei por cota
    uint8 constant t_qtdCotas = 20; // 20 cotas no total

    /**
     * Inicia a rifa
     */
    function beforeAll () public {

        //  rifaToTest = new Rifa(t_qtdCotas, t_valorDaCota, "Caneta");

        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
    }

    /// #sender: account-1
    /// #value: 14
    function checkAquisicaoCotas () public payable {
        Assert.ok(msg.sender == acc1, 'caller should be custom account i.e. acc1');
        uint8 cota = 1;
        //        (bool success, ) = address(rifaToTest).call{value: t_valorDaCota, gas: 5000}(
        //            abi.encodeWithSignature("adquirirCota(uint8)",cota)
        //        );
        //        Assert.ok(success, "chamada nao foi bem sucedida");
        this.adquirirCota{gas: 50000, value: t_valorDaCota}(cota);
        Assert.equal(this.getCotaOwner(cota), address(acc1), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-2
    /// #value: 14
    function checkAquisicaoCotaJaAdquirida () public payable {
        uint8 cota = 1;

        try this.adquirirCota{gas: 50000, value: t_valorDaCota}(cota) {
            Assert.ok(false, 'deveria ter falhado');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'A cota escolhida ja foi adquirida', 'falhou por um motivo inesperado');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-3
    /// #value: 10
    function checkAquisicaoCotaAbaixoDoValor () public payable {
        uint8 cota = 2;

        try this.adquirirCota{gas: 50000, value: 10}(cota) {
            Assert.ok(false, 'deveria ter falhado');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'O pagamento deve ser exatamento o valor da cota', 'falhou por um motivo inesperado');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-1
    /// #value: 84
    function checkAquisicaoDeCotasDoAccount1 () public payable {
        this.adquirirCota{gas: 50000, value: 14}(5);
        this.adquirirCota{gas: 50000, value: 14}(7);
        this.adquirirCota{gas: 50000, value: 14}(11);
        this.adquirirCota{gas: 50000, value: 14}(13);
        this.adquirirCota{gas: 50000, value: 14}(14);
        this.adquirirCota{gas: 50000, value: 14}(19);
        Assert.equal(this. getCotaOwner(5), address(acc1), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-2
    /// #value: 84
    function checkAquisicaoDeCotasDoAccount2 () public payable {
        this.adquirirCota{gas: 50000, value: 14}(2);
        this.adquirirCota{gas: 50000, value: 14}(4);
        this.adquirirCota{gas: 50000, value: 14}(6);
        this.adquirirCota{gas: 50000, value: 14}(8);
        this.adquirirCota{gas: 50000, value: 14}(10);
        this.adquirirCota{gas: 50000, value: 14}(12);
        Assert.equal(this.getCotaOwner(2), address(acc2), "A quota deve ser de quem executou a funcao.");
        Assert.equal(this.getCotaOwner(4), address(acc2), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-3
    /// #value: 84
    function checkAquisicaoDeCotasDoAccount3 () public payable {
        this.adquirirCota{gas: 50000, value: 14}(3);
        this.adquirirCota{gas: 50000, value: 14}(9);
        this.adquirirCota{gas: 50000, value: 14}(15);
        this.adquirirCota{gas: 50000, value: 14}(16);
        this.adquirirCota{gas: 50000, value: 14}(17);
        this.adquirirCota{gas: 50000, value: 14}(18);
        Assert.equal(this.getCotaOwner(18), address(acc3), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-1
    /// #value: 0
    function checkSorteioSemSerOwner () public {
        try this.sortear{gas: 50000}() {
            Assert.ok(false, 'deveria ter falhado');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'Caller is not owner', 'falhou por um motivo inesperado');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-0
    /// #value: 0
    function checkSorteio () public {
        this.sortear{gas: 50000}();
        Assert.greaterThan(uint(this.getCotaSorteada()), uint(0), 'Uma cota deveria ter sido sorteada');
    }

    /// #sender: account-0
    /// #value: 0
    function checkRepetirSorteio () public {
        try this.sortear{gas: 50000}() {
            Assert.ok(false, 'deveria ter falhado');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'Sorteio ja foi realizado', 'falhou por um motivo inesperado');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-0
    /// #value: 0
    function checkAccount0TentaConfirmarRecebimento () public {
        try this.confirmarRecebimento{gas: 50000}() {
            Assert.equal(this.getGanhador(), address(this), 'deveria ter falhado, pq acc-0 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(this.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-0 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-1
    /// #value: 0
    function checkAccount1TentaConfirmarRecebimento () public {
        try this.confirmarRecebimento{gas: 50000}() {
            Assert.equal(this.getGanhador(), address(this), 'deveria ter falhado, pq acc-1 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(this.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-1 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-2
    /// #value: 0
    function checkAccount2TentaConfirmarRecebimento () public {
        try this.confirmarRecebimento{gas: 50000}() {
            Assert.equal(this.getGanhador(), address(this), 'deveria ter falhado, pq acc-2 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(this.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-2 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }


    /// #sender: account-3
    /// #value: 0
    function checkAccount3TentaConfirmarRecebimento () public {
        try this.confirmarRecebimento{gas: 50000}() {
            Assert.equal(this.getGanhador(), address(this), 'deveria ter falhado, pq acc-3 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(this.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-3 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

}
