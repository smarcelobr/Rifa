// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../contracts/Rifa.sol";
import "./Rifa_actor.sol";
import "./Rifa_Owner_actor.sol";

contract RifaTest {

    Rifa rifa;
    // contas diferentes para testar como participantes
    RifaOwnerActor dono;
    RifaActor participante1;
    RifaActor participante2;
    RifaActor participante3;

    uint constant t_valorDaCota = 14000000; // 14.000.000 wei por cota
    uint8 constant t_qtdCotas = 20; // 20 cotas no total

    /**
     * Inicia a rifa
     */
    function beforeAll () public {
        dono = new RifaOwnerActor(t_qtdCotas, t_valorDaCota, "Liquidificador");
        rifa = dono.getRifa();
        participante1 = new RifaActor(rifa);
        participante2 = new RifaActor(rifa);
        participante3 = new RifaActor(rifa);
    }

    /// #sender: account-1
    /// #value: 14000000
    function checkAquisicaoCotas () public payable {
        uint8 cota = 1;
        participante1.adquirirCota{gas: 50000, value: t_valorDaCota}(cota);

        Assert.equal(rifa.getCotaOwner(cota), address(participante1), "A quota deve ser de quem executou a funcao.");
    }

    /// #sender: account-2
    /// #value: 14000000
    function checkAquisicaoCotaJaAdquirida () public payable {
        uint8 cota = 1;

        try participante2.adquirirCota{gas: 50000, value: t_valorDaCota}(cota) {
            Assert.ok(false, 'falha esperada');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'A cota escolhida ja foi adquirida', 'falhou inesperadamente');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-3
    /// #value: 10000000
    function checkAquisicaoCotaAbaixoDoValor () public payable {
        uint8 cota = 2;

        try participante3.adquirirCota{gas: 50000, value: 10000000}(cota) {
            Assert.ok(false, 'deveria ter falhado');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'O pagamento deve ser exatamente o valor da cota', 'falhou inesperadamente');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-1
    /// #value: 84000000
    function checkAquisicaoDeCotasDoAccount1 () public payable {
        participante1.adquirirCota{gas: 50000, value: t_valorDaCota}(5);
        participante1.adquirirCota{gas: 50000, value: t_valorDaCota}(7);
        participante1.adquirirCota{gas: 50000, value: t_valorDaCota}(11);
        participante1.adquirirCota{gas: 50000, value: t_valorDaCota}(13);
        participante1.adquirirCota{gas: 50000, value: t_valorDaCota}(14);
        participante1.adquirirCota{gas: 50000, value: t_valorDaCota}(19);
        Assert.equal(rifa.getCotaOwner(5), address(participante1), "CotaOwner invalid");
    }

    /// #sender: account-2
    /// #value: 84000000
    function checkAquisicaoDeCotasDoAccount2 () public payable {
        participante2.adquirirCota{gas: 50000, value: t_valorDaCota}(2);
        participante2.adquirirCota{gas: 50000, value: t_valorDaCota}(4);
        participante2.adquirirCota{gas: 50000, value: t_valorDaCota}(6);
        participante2.adquirirCota{gas: 50000, value: t_valorDaCota}(8);
        participante2.adquirirCota{gas: 50000, value: t_valorDaCota}(10);
        participante2.adquirirCota{gas: 50000, value: t_valorDaCota}(12);
        Assert.equal(rifa.getCotaOwner(2), address(participante2), "CotaOwner invalid");
        Assert.equal(rifa.getCotaOwner(4), address(participante2), "CotaOwner invalid");
    }

    /// #sender: account-3
    /// #value: 84000000
    function checkAquisicaoDeCotasDoAccount3 () public payable {
        participante3.adquirirCota{gas: 50000, value: t_valorDaCota}(3);
        participante3.adquirirCota{gas: 50000, value: t_valorDaCota}(9);
        participante3.adquirirCota{gas: 50000, value: t_valorDaCota}(15);
        participante3.adquirirCota{gas: 50000, value: t_valorDaCota}(16);
        participante3.adquirirCota{gas: 50000, value: t_valorDaCota}(17);
        participante3.adquirirCota{gas: 50000, value: t_valorDaCota}(18);
        Assert.equal(rifa.getCotaOwner(18), address(participante3), "CotaOwner invalid");
    }

    /// #sender: account-1
    /// #value: 0
    function checkSorteioSemSerOwner () public {
        try participante1.sortear{gas: 50000}() {
            Assert.ok(false, 'deveria ter falhado');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'Caller is not owner', 'falhou inesperadamente');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-0
    /// #value: 0
    function checkSorteio () public {
        dono.sortear{gas: 50000}();
        Assert.greaterThan(uint(rifa.getCotaSorteada()), uint(0), 'Uma cota deveria ter sido sorteada');
    }

    /// #sender: account-0
    /// #value: 0
    function checkRepetirSorteio () public {
        try dono.sortear{gas: 50000}() {
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
        try dono.confirmarRecebimento{gas: 50000}() {
            Assert.equal(rifa.getGanhador(), address(this), 'deveria ter falhado, pq acc-0 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(rifa.getGanhador(), address(this), 'deveria ter conseguido receber pq acc-0 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-1
    /// #value: 0
    function checkAccount1TentaConfirmarRecebimento () public {
        try participante1.confirmarRecebimento{gas: 50000}() {
            Assert.equal(rifa.getGanhador(), address(participante1), 'deveria ter falhado, pq acc-1 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(rifa.getGanhador(), address(participante1), 'deveria ter conseguido receber pq acc-1 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-2
    /// #value: 0
    function checkAccount2TentaConfirmarRecebimento () public {
        try participante2.confirmarRecebimento{gas: 50000}() {
            Assert.equal(rifa.getGanhador(), address(participante2), 'deveria ter falhado, pq acc-2 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(rifa.getGanhador(), address(participante2), 'deveria ter conseguido receber pq acc-2 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    /// #sender: account-3
    /// #value: 0
    function checkAccount3TentaConfirmarRecebimento () public {
        try participante3.confirmarRecebimento{gas: 50000}() {
            Assert.equal(rifa.getGanhador(), address(participante3), 'deveria ter falhado, pq acc-3 nao e ganhador');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'apenas o sorteado pode confirmar o recebimento.', 'falhou por um motivo inesperado');
            Assert.notEqual(rifa.getGanhador(), address(participante3), 'deveria ter conseguido receber pq acc-3 e o ganhador');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'falhou de forma inesperada');
        }
    }

    // #value: 0
    function getBalance() public {
        Assert.equal(dono.getBalance(), t_valorDaCota*19, "O owner nao recebeu a quantia esperada.") ;
    }

}
