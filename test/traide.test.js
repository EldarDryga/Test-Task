const { expect } = require("chai")
const { ethers } = require("hardhat")
const { BigNumber } = require("ethers");

describe("traide", function () {
  let traide;

  let owner;
  let addr1;
  let addr2;
  const WETH9 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
  const DAI = "0x6b175474e89094c44da98b954eedeac495271d0f";
  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    const Traide = await ethers.getContractFactory("traide", owner);
    traide = await Traide.deploy();
    await traide.deployed();
  });

  it("should add a token", async function () {
    const tokenAddress = "0x1234567890123456789012345678901234567890";
    const price = ethers.utils.parseEther("1");

    await traide.addToken(DAI, price);

    const tokenInfo = await traide.InfoOfToken(tokenAddress);
    assert.equal(tokenInfo.tokenAddress, tokenAddress);
    assert.equal(tokenInfo.price.toString(), price.toString());
  })

})
