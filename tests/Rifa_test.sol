// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/Rifa.sol";

contract RifaTest {

    // contas diferentes para testar como participantes
    address acc0;
    address acc1;
    address acc2;

    Rifa rifaToTest;
    uint constant valorDaCota = 14; // 14 wei por cota
    uint8 constant qtdCotas = 20; // 20 cotas no total

    /**
     * Inicia a rifa
     */
    function beforeAll () public {

        rifaToTest = new Rifa(qtdCotas, valorDaCota, "Caneta");

        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }

    /// #sender: account-1
    /// #value: 14
    function checkAquisicaoCotas () public payable {
        uint8 cota = 1;
        //        (bool success, ) = address(rifaToTest).call{value: valorDaCota, gas: 5000}(
        //            abi.encodeWithSignature("adquirirCota(uint8)",cota)
        //        );
        //        Assert.ok(success, "chamada nao foi bem sucedida");
        rifaToTest.adquirirCota{gas: 50000, value: valorDaCota}(cota);
        Assert.equal(rifaToTest.getCotaOwner(cota), address(this), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-2
    /// #value: 14
    function checkAquisicaoCotaJaAdquirida () public payable {
        uint8 cota = 1;

        try rifaToTest.adquirirCota{gas: 50000, value: valorDaCota}(cota) {
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

        try rifaToTest.adquirirCota{gas: 50000, value: 10}(cota) {
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
        rifaToTest.adquirirCota{gas: 50000, value: 14}(5);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(7);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(11);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(13);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(14);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(19);
        Assert.equal(rifaToTest.getCotaOwner(5), address(this), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-2
    /// #value: 84
    function checkAquisicaoDeCotasDoAccount2 () public payable {
        rifaToTest.adquirirCota{gas: 50000, value: 14}(2);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(4);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(6);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(8);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(10);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(12);
        Assert.equal(rifaToTest.getCotaOwner(2), address(this), "A quota deve ser de quem executou a funcao.");
        Assert.equal(rifaToTest.getCotaOwner(4), address(this), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-3
    /// #value: 84
    function checkAquisicaoDeCotasDoAccount3 () public payable {
        rifaToTest.adquirirCota{gas: 50000, value: 14}(3);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(9);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(15);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(16);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(17);
        rifaToTest.adquirirCota{gas: 50000, value: 14}(18);
        Assert.equal(rifaToTest.getCotaOwner(18), address(this), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-0
    function checkSorteio () public {
        rifaToTest.sortear{gas: 50000}();
        Assert.greaterThan(uint(rifaToTest.getCotaSorteada()), uint(0), 'Uma cota deveria ter sido sorteada');
    }

    /// #sender: account-0
    function checkRepetirSorteio () public {
        try rifaToTest.sortear{gas: 50000}() {
            Assert.ok(false, 'deveria ter falhado');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'Sorteio ja foi realizado', 'falhou por um motivo inesperado');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-0
    function checkAccount0TentaConfirmarRecebimento () public {
        try rifaToTest.confirmarRecebimento{gas: 50000}() {
            Assert.equal(rifaToTest.getGanhador(), address(this), 'deveria ter falhado, pq acc-0 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(rifaToTest.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-0 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-1
    function checkAccount1TentaConfirmarRecebimento () public {
        try rifaToTest.confirmarRecebimento{gas: 50000}() {
            Assert.equal(rifaToTest.getGanhador(), address(this), 'deveria ter falhado, pq acc-1 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(rifaToTest.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-1 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-2
    function checkAccount2TentaConfirmarRecebimento () public {
        try rifaToTest.confirmarRecebimento{gas: 50000}() {
            Assert.equal(rifaToTest.getGanhador(), address(this), 'deveria ter falhado, pq acc-2 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(rifaToTest.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-2 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }


    /// #sender: account-3
    function checkAccount3TentaConfirmarRecebimento () public {
        try rifaToTest.confirmarRecebimento{gas: 50000}() {
            Assert.equal(rifaToTest.getGanhador(), address(this), 'deveria ter falhado, pq acc-3 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(rifaToTest.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-3 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

}
