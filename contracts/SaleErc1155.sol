// contracts/SaleErc1155.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC1155/ERC1155.sol";

contract SaleErc1155 is ERC1155 {
    struct SaleDetails {
        address owner;
        address buyer;
        uint256 amount;
        uint price;
    }

    mapping (uint256 => SaleDetails) internal sales;

    /**
     * @dev constuct conruct with stub uri
     */
    constructor() ERC1155("https://token-cdn-domain/{id}.json") {
    }

    
    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Mint is not resticted
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        _mint(to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        _mintBatch(to, ids, amounts, data);
    }

    
    /**
     * @dev Creates new sale of `amount` tokens of token type `id` with `price`.
     */
    function sell(
        uint256 id,
        uint256 amount,
        uint price
    ) public virtual {
        uint256 fromBalance = balanceOf(_msgSender(), id);
        require(fromBalance >= amount, "Insufficient balance for sale");
        require(sales[id].amount == 0, "Sale already exist");

        sales[id].owner = _msgSender();
        sales[id].amount = amount;
        sales[id].price = price;
        sales[id].buyer = address(0);
    }
    
    /**
     * @dev Closes existing sale if eth price provided
     */
    function buy(
        uint256 id
    ) public payable virtual {
        SaleDetails memory saleDetails = sales[id];
        require(saleDetails.amount > 0, "Sale not exist");
        require(saleDetails.price >= msg.value, "Insufficient eth");

        sales[id].buyer = _msgSender();

        _safeTransferFrom(saleDetails.owner, _msgSender(), id, saleDetails.amount, "0x0");

        sales[id] = SaleDetails(address(0), address(0), 0, 0);

        (bool sent, bytes memory data) = saleDetails.owner.call{value: saleDetails.price}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        for (uint256 i = 0; i < ids.length; i++) {
            SaleDetails memory saleDetails = sales[ids[i]];
            require(
                saleDetails.owner == address(0) ||
                saleDetails.owner != from ||
                saleDetails.buyer == to,
                "Tokens are under the sale"
             );
        }
    }
}
