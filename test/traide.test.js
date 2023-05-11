const { expect } = require("chai")
const { ethers } = require("hardhat")
const { BigNumber } = require("ethers");

describe("traide", function () {
  let traide;
  let mockToken
  let owner;
  let addr1;
  const DAI = "0x6b175474e89094c44da98b954eedeac495271d0f";
  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    const MockToken = await ethers.getContractFactory("MockToken", owner);
    mockToken = await MockToken.deploy();
    await mockToken.deployed();


    const Traide = await ethers.getContractFactory("traide", owner);
    traide = await Traide.deploy();
    await traide.deployed();
  });

  it("should add a token", async function () {
    const price = 10n ** 18n
    await traide.connect(owner).addToken(DAI, price);
    console.log(await traide.tokensAllowed());
  })
  it("user should mint NFT for Token that owner set", async function (){
    const price = 10n ** 18n

    await traide.connect(owner).addToken(mockToken.address, price);
    await mockToken.connect(addr1).mint(addr1.address,price)
    await mockToken.connect(addr1).approve(traide.address, price)
    await traide.connect(addr1).mintNFTforTokens(mockToken.address)
    expect(await mockToken.balanceOf(traide.address)).to.eq(price)
    expect(await traide.balanceOf(addr1.address)).to.eq(1)
  })
  it("User should burn NFT and receive 99.5% of tokens", async function(){
    const price = 1000

    await traide.connect(owner).addToken(mockToken.address, price);
    await mockToken.connect(addr1).mint(addr1.address,price)
    await mockToken.connect(addr1).approve(traide.address, price)
    await traide.connect(addr1).mintNFTforTokens(mockToken.address)
    await traide.connect(addr1).burnNFT(0)

    expect(await mockToken.balanceOf(traide.address)).to.eq(5)

  })
  it("Owner should withdraw fee", async function(){
    const price = 1000

    await traide.connect(owner).addToken(mockToken.address, price);
    await mockToken.connect(addr1).mint(addr1.address,price)
    await mockToken.connect(addr1).approve(traide.address, price)
    await traide.connect(addr1).mintNFTforTokens(mockToken.address)
    await traide.connect(addr1).burnNFT(0)

     await traide.connect(owner).withdrawFee(mockToken.address) 
     /* This step I cant check properly, 
    because my mockToken doesn`t have any value, so it cant be swapped to USDC*/
  })
})
