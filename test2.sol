// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenDistributor {
    IERC20 useToken;
    mapping(address => uint256) public distribution;
    uint256 public totalRewards;
    
    constructor(IERC20 _useToken) {
        useToken = _useToken;
    }

    event TransferSuccess(address indexed from, address indexed to, uint256 request, string errorMessage);
    event TransferError(address indexed from, address indexed to, uint256 request, string successMessage);


    // アドレスと報酬額の配列を受け取り、マッピングに入れる
    // すでにデポジットされている額と報酬の総額を比較して、差分を送金
    function depositToken(address[] memory members, uint256[] memory rewards) public {
        require(members.length == rewards.length, "Number of members and rewards must match.");
        for (uint256 i = 0; i < members.length; i++) {
            distribution[members[i]] = rewards[i];
            totalRewards += rewards[i];
        }
        
        uint256 transferAmount = totalRewards - useToken.balanceOf(depositAddr);
        // require(transferAmount >= 0); // ←これは無条件で保証されている？
        if (useToken.transferFrom(msg.sender, address(this), transferAmount)) {
            emit TransferSuccess(msg.sender, address(this), transferAmount, "Trasfer success!");
        } else {
            emit TransferError(msg.sender, members[i], requests[i], "Transfer failed");
        }
    }


    function withdraw(address[] memory members, uint256[] memory requests) public {
        for (uint256 i = 0; i < members.length; i++) {
            // requestsの合計値がデポジットの額よりも多い場合は終了する(未実装)
            // requestsの合計値は引数として与えた方がガス代が安い？
            // require(useToken.balanceOf(depositAddr) >= amount);
 
            if (distribution[members[i]] < requests[i]) {
                emit TransferError(msg.sender, members[i], requests[i], "Request exceeds reward.");
                continue;
            }
            
            if (members[i] == address(0)) {
                emit TransferError(msg.sender, members[i], requests[i], "0x0 is an invalid address.");
                continue;
            }

            if (useToken.transferfrom(msg.sender, members[i], requests[i])) {
                emit TransferSuccess(msg.sender, members[i], requests[i], "Transfer completed!");
                memberRewards[members[i]] -= requests[i];
                totalRewards -= requests[i];
            } else {
                emit TransferError(msg.sender, members[i], requests[i], "Transfer failed");
                continue;
            }
        }
    }
}