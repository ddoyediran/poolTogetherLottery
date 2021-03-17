//SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "./IERC20.sol";
import "./ILendingPool.sol";

contract Lottery {
	// the timestamp of the drawing event
	uint public drawing;
	// the price of the ticket in DAI (100 DAI)
	uint ticketPrice = 100e18;
	mapping(address => bool) hasATicket;
	address[] poolPurchers;

	ILendingPool pool = ILendingPool(/* ILendingPool Address goes here */);
	IERC20 aDai = IERC20(/* IERC20 Address for aDai goes here */); 
	IERC20 dai = IERC20(/* IERC20 dai Address goes here */);

	constructor() {
        drawing = block.timestamp + 7 days;
	}

	function purchase() external {
		require(!hasATicket[msg.sender]);
        dai.transferFrom(msg.sender, address(this), ticketPrice);

		dai.approve(address(pool), ticketPrice);
		pool.deposit(address(dai), ticketPrice, address(this), 0);
		hasATicket[msg.sender] = true;
		poolPurchers.push(msg.sender);
	}

	event Winner(address);

	function pickWinner() external {
        require(drawing <= block.timestamp);

		// to get the total pool purchased == total purchasers
		uint totalPool = poolPurchers.length; 
		// use block hash to pick a random winner
		uint winnerIdx = uint(blockhash(block.number - 1)) % totalPool;
		// get the address of the winner 
		address winner = poolPurchers[winnerIdx];

		// emit the winner
		emit Winner(winner);

		// get the balance in the aDai
		uint balance = aDai.balanceOf(address(this));

		// to approve pool to spend aDai lottery balance
		aDai.approve(address(pool), balance);

		// withdraw ticket purchaser initial purchase in Dai and transfer it to them
		for(uint i = 0; i < poolPurchers.length; i++) {
			pool.withdraw(address(dai), ticketPrice, poolPurchers[i]);
		}

		// to deposit the interest to the winner's account
		uint interest = aDai.balanceOf(address(this));
		pool.withdraw(address(dai) ,interest, winner);
		
	}
}
