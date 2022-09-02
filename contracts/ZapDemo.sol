// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


import {IERC20} from "@oz/token/ERC20/IERC20.sol";
import {ERC20} from "@oz/token/ERC20/ERC20.sol";
import {SafeERC20} from "@oz/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@oz/security/ReentrancyGuard.sol";

contract FakeToken {

  event Debug(string name, uint256 amount);

  uint256 public totalSupply;

  function mint(uint256 amount) external {
    totalSupply += amount;

    emit Debug("mint", amount);
  }
}


contract ZapDemo {
  struct FunctionSpecifier {
    // Bytes that are the string that we can `encodeWithFunctionSignature` so we can sim offChain and it only costs 32 bytes
    string funSignature; 
    address target;
  }

  struct ZapData {
    address tokenIn; // List of tokenIn -> tokenOuts, last is the one you get
    FunctionSpecifier zap; // Do the zap 
    FunctionSpecifier calcout; // Calculate the amount out
  }

  FakeToken immutable public fakeToken;

  constructor() {
    fakeToken = new FakeToken();
  }

  function getZap() public returns (FunctionSpecifier memory) {
    FunctionSpecifier memory specier = FunctionSpecifier(
      "mint(uint256)",
      address(fakeToken)
    );

    return specier;
  }

  function doZap(bytes memory params) external returns(bytes memory) {
    FunctionSpecifier memory zapData = getZap();

    (bool success,) = address(zapData.target).call(
      abi.encodeWithSignature(zapData.funSignature, params)
    );

    // https://ethereum.stackexchange.com/questions/112562/how-do-you-pass-abi-encoded-parameters-to-abi-encodewithsignature-abi-encodewi

    require(success);
    require(zapData.target.code.length > 0);

    return params;
  }



}