// SPDX-License-Identifier: Unlicense
pragma solidity =0.8.13;

import "forge-std/Test.sol";

import {IERC20, WUSDC} from "src/WUSDC.sol";

contract TestWUSDC is Test {

    WUSDC wusdc;
    address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    IERC20 public constant usdcToken = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function setUp() public {
        wusdc = new WUSDC();
    }

    function testSetup() public {
        assertEq(address(wusdc.USDC()), usdc);
        assertEq(usdcToken.balanceOf(address(this)), 0);
        assertEq(wusdc.name(), "Wrapped USDC");
        assertEq(wusdc.symbol(), "WUSDC");
        assertEq(wusdc.totalSupply(), 0);
    }

    function testMintFailsNoUsdc(uint256 amount) public {
        vm.assume(amount != 0);

        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        wusdc.mint(amount);

        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        wusdc.mint(amount, address(this));
    }

    function testRedeemFailsNoWusdc(uint256 amount) public {
        vm.assume(amount != 0);

        vm.expectRevert("ERC20: burn amount exceeds balance");
        wusdc.redeem(amount);

        vm.expectRevert("ERC20: burn amount exceeds balance");
        wusdc.redeem(amount, address(this));
    }

    function mintSucceedsOneToOne(uint256 amount) public {
        assertEq(wusdc.totalSupply(), 0);
        assertEq(wusdc.balanceOf(address(this)), 0);

        deal(usdc, address(this), amount);
        usdcToken.approve(address(wusdc), amount);
        wusdc.mint(amount);

        assertEq(wusdc.totalSupply(), amount);
        assertEq(wusdc.balanceOf(address(this)), amount);
        assertEq(usdcToken.balanceOf(address(this)), 0);
    }

    function mintToSucceedsOneToOne(uint256 amount, address to) public {
        vm.assume(to != address(0));

        assertEq(wusdc.totalSupply(), 0);
        assertEq(wusdc.balanceOf(address(this)), 0);

        deal(usdc, address(this), amount);
        usdcToken.approve(address(wusdc), amount);
        wusdc.mint(amount, to);

        assertEq(wusdc.totalSupply(), amount);
        assertEq(wusdc.balanceOf(to), amount);
        assertEq(usdcToken.balanceOf(address(this)), 0);
    }

    function testRedeemSucceedsOneToOne(uint256 amount) public {
        mintSucceedsOneToOne(amount);

        wusdc.redeem(amount);

        assertEq(wusdc.totalSupply(), 0);
        assertEq(wusdc.balanceOf(address(this)), 0);
        assertEq(usdcToken.balanceOf(address(this)), amount);
    }

    function testRedeemToSucceedsOneToOne(uint256 amount, address to) public {
        vm.assume(to != address(0));

        mintToSucceedsOneToOne(amount, to);

        vm.prank(to);
        wusdc.redeem(amount, to);

        assertEq(wusdc.totalSupply(), 0);
        assertEq(wusdc.balanceOf(to), 0);
        assertEq(usdcToken.balanceOf(to), amount);
    }
}
