const SaleErc1155 = artifacts.require("SaleErc1155");

contract("SaleErc1155", async accounts => {

    it("should mint, sell and buy", async () => {
        const seller = accounts[0];
        const buyer = accounts[1];
        const id = 1;

        const saleErc = await SaleErc1155.deployed();
        
        await saleErc.mint(seller, id, 1, "0x0", {from: seller});

        let balance = await saleErc.balanceOf.call(seller, id);
        assert.equal(balance.toNumber(), 1, "Token wasn't minted");

        await saleErc.sell(id, 1, 10, {from: seller});

        await saleErc.buy(id, {value: "10", from: buyer});

        balance = await saleErc.balanceOf.call(seller, id);
        assert.equal(balance.toNumber(), 0, "Token wasn't sold");

        balance = await saleErc.balanceOf.call(buyer, id);
        assert.equal(balance.toNumber(), 1, "Token wasn't bought");
    });
});
