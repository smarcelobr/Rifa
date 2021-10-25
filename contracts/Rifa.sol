// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Rifa
 * @dev Contrato para gerir uma rifa. Nessa primeira versão, o contrato está fixo para 32 cotas.
 * Isso pode ser parametrizado no futuro.
 * @author Sergio M. C. Figueiredo
 */
contract Rifa {

    string public nome;   // nome da rifa
    uint8 immutable public qtdCotas; // número de cotas dessa Rifa. (pode ser immutable numa nova versão)
    uint immutable public valorDaCota; // valor unitário da cota em wei

    address payable private owner; // é o responsável pela Rifa. Ele recebe os ethers após confirmação da entrega do prêmio.

    address[] private cotas; // array de endereços das cotas adquiridas
    uint8 private cotaSorteada = 0; // cota sorteada. Quando é zero, não houve sorteio. (entre 1 e qtdCotas)

    /**
     * @dev Set contract deployer as owner
     */
    constructor(uint8 _qtdCotas, uint _valorDaCota, string memory _nome) {
        require(_qtdCotas > 1, "A qtdCotas deve ser maior que 1");
        require(_valorDaCota > 0, "O valor da cota deve ser especificado");

        qtdCotas = _qtdCotas;
        valorDaCota = _valorDaCota;
        nome = _nome;
        owner = payable(msg.sender);
        // 'msg.sender' is sender of current call, contract deployer for a constructor
        cotas = new address[](_qtdCotas);
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }

    /**
     * @dev Retorna quem adquiriu a cota
     * @return endereço do dono da cota
     */
    function getCotaOwner(uint8 cota) external view returns (address) {
        require(cota > 0 && cota <= qtdCotas, "Escolha uma cota entre 1 e qtdCotas");

        return cotas[cota - 1];
    }

    /**
     * @dev Adquire uma cota da Rifa. A cota é atribuída ao endereço do pagador
     */
    function adquirirCota(uint8 cota) external payable {
        require(cotaSorteada == 0, "Essa rifa nao aceita mais compra de cotas");
        require(msg.value == valorDaCota, "O pagamento deve ser exatamente o valor da cota");
        require(cota > 0 && cota <= qtdCotas, "Escolha uma cota entre 1 e qtdCotas");
        require(cotas[cota - 1] == address(0), "A cota escolhida ja foi adquirida");

        cotas[cota - 1] = msg.sender;
        // atribui o endereço do pagador a cota.
    }

    // serve para checar se é o owner que está executando a função
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * Realiza o sorteio e armazena o vencedor.
     */
    function sortear() external isOwner {
        require(cotaSorteada == 0, "Sorteio ja foi realizado");

        cotaSorteada = uint8((randomNumber() % qtdCotas) + 1);

        // valida se a cota sorteada pertence a alguém
        if (cotas[cotaSorteada - 1] == address(0)) {
            // ninguém adquiriu essa cota? o owner é o vencedor então.
            cotas[cotaSorteada - 1] = owner;
        }
    }

    /**
     * Obtem a cota que foi sorteada
     */
    function getCotaSorteada() external view returns (uint8) {
        require(cotaSorteada != 0, "Sorteio nao foi realizado");
        return cotaSorteada;
    }

    /**
     * Obtem o address do sorteado.
     */
    function getGanhador() external view returns (address) {
        require(cotaSorteada != 0, "Sorteio nao foi realizado");
        return cotas[cotaSorteada - 1];
    }

    /**
     * @dev O ganhador da rifa confirma que recebeu o produto e os
     * ethers do contrato são transferidos para o owner.
     */
    function confirmarRecebimento() external {
        require(cotaSorteada > 0, "Nao houve sorteio.");
        require(cotas[cotaSorteada - 1] == msg.sender, "apenas o sorteado pode confirmar o recebimento.");

        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success,) = owner.call{value : amount}("");
        require(success, "O envio de Ether falhou");
    }

    // Randomness provided by this is predicatable. Use with care!
    // see https://fravoll.github.io/solidity-patterns/randomness.html
    function randomNumber() internal view returns (uint) {
        return block.number;
    }
}