// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;

import "../../lib/ERC20.sol";

import "./TransferModule.sol";


/// @title DappTransfers
contract DappTransfers is TransferModule
{

    constructor(ControllerImpl _controller)
        public
        TransferModule(_controller) {}

    modifier onlyWhitelistedDapp(address addr)
    {
        require(controller.dappAddressStore().isDapp(addr), "DISALLOWED");
        _;
    }

    function transferToken(
        address            wallet,
        address            token,
        address            to,
        uint               amount,
        bytes     calldata logdata
        )
        external
        nonReentrant
        onlyWhitelistedDapp(to)
        onlyWhenWalletUnlocked(wallet)
        onlyFromMetaTxOrWalletOwner(wallet)
    {
        transferInternal(wallet, token, to, amount, logdata);
    }

    function approveToken(
        address            wallet,
        address            token,
        address            to,
        uint               amount
        )
        external
        nonReentrant
        onlyWhitelistedDapp(to)
        onlyWhenWalletUnlocked(wallet)
        onlyFromMetaTxOrWalletOwner(wallet)
    {
        approveInternal(wallet, token, to, amount);
    }

    function callContract(
        address            wallet,
        address            to,
        uint               value,
        bytes     calldata data
        )
        external
        nonReentrant
        onlyWhitelistedDapp(to)
        onlyWhenWalletUnlocked(wallet)
        onlyFromMetaTxOrWalletOwner(wallet)
        returns (bytes memory returnData)
    {
        return callContractInternal(wallet, to, value, data);
    }

    function approveThenCallContract(
        address            wallet,
        address            token,
        address            to,
        uint               amount,
        uint               value,
        bytes     calldata data
        )
        external
        nonReentrant
        onlyWhitelistedDapp(to)
        onlyWhenWalletUnlocked(wallet)
        onlyFromMetaTxOrWalletOwner(wallet)
        returns (bytes memory returnData)
    {
        approveInternal(wallet, token, to, amount);
        return callContractInternal(wallet, to, value, data);
    }

    function verifySigners(
        address   wallet,
        bytes4    method,
        bytes     memory /*data*/,
        address[] memory signers
        )
        internal
        view
        override
        returns (bool)
    {
        require (
            method == this.transferToken.selector ||
            method == this.approveToken.selector ||
            method == this.callContract.selector ||
            method == this.approveThenCallContract.selector,
            "INVALID_METHOD"
        );
        return isOnlySigner(Wallet(wallet).owner(), signers);
    }
}
