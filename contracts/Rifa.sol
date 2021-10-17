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
    uint immutable public valorDaCota; // valor unitário da cota

    address payable private owner; // é o responsável pela Rifa. Ele recebe os ethers após confirmação da entrega do prêmio.
    uint8 constant public qtdCotas = 32; // número de cotas dessa Rifa. (pode ser immutable no futuro)

    address[qtdCotas] private cotas; // array de endereços das cotas adquiridas
    uint8 public cotaSorteada = 0; // cota sorteada. Quando é zero, não houve sorteio. (entre 1 e qtdCotas)

    /**
     * @dev Set contract deployer as owner
     */
    constructor(uint _valorDaCota, string memory _nome) {
        valorDaCota = _valorDaCota;
        nome = _nome;
        owner = payable(msg.sender); // 'msg.sender' is sender of current call, contract deployer for a constructor
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
        require(cota>0 && cota<=qtdCotas, "Escolha uma cota entre 1 e qtdCotas");

        return cotas[cota-1];
    }

    /**
     * @dev Adquire uma cota da Rifa. A cota é atribuída ao endereço do pagador
     */
    function adquirirCota(uint8 cota) public payable {
        require(cotaSorteada==0, "Essa rifa nao aceita mais compra de cotas");
        require(msg.value==valorDaCota, "O pagamento deve ser exatamento o valor da cota");
        require(cota>0 && cota<=qtdCotas, "Escolha uma cota entre 1 e qtdCotas");
        require(cotas[cota-1]==address(0), "A cota escolhida ja foi adquirida");

        cotas[cota-1] = msg.sender; // atribui o endereço do pagador a cota.
    }

    // serve para checar se é o owner que está executando a função
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * Realiza o sorteio e armazena o vencedor.
     */
    function sortear() public isOwner {
        require(cotaSorteada==0, "Sorteio ja foi realizado");

        cotaSorteada = uint8((randomNumber() % 32)+1);

        // valida se a cota sorteada pertence a alguém
        if (cotas[cotaSorteada-1]==address(0)) {
            // ninguém adquiriu essa cota? o owner é o vencedor então.
            cotas[cotaSorteada-1] = owner;
        }
    }

    /**
     * @dev O ganhador da rifa confirma que recebeu o produto e os
     * ethers do contrato são transferidos para o owner.
     */
    function confirmarRecebimento() public {
        require(cotaSorteada>0, "Nao houve sorteio.");
        require(cotas[cotaSorteada]==msg.sender, "apenas o sorteado pode confirmar o recebimento.");

        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner.call{value: amount}("");
        require(success, "O envio de Ether falhou");
    }

    // Randomness provided by this is predicatable. Use with care!
    // see https://fravoll.github.io/solidity-patterns/randomness.html
    function randomNumber() public /*internal*/ view returns (uint) {
        return block.number;
    }
}