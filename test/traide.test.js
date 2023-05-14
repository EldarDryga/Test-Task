const chai = require("chai")
const expect = chai.expect;
const { ethers, upgrades } = require("hardhat")
const { smock } = require("@defi-wonderland/smock");
chai.use(smock.matchers);

describe("traide", function () {
  let traide;
  let mockToken
  let owner;
  let addr1;
  let UniswapRouter;
  let uniswapRouter;
  let usdc;
  const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    const MockToken = await ethers.getContractFactory("MockToken", owner);
    mockToken = await MockToken.deploy();
    await mockToken.deployed();

    UniswapRouter = await smock.mock('SwapRouter');
    uniswapRouter = await UniswapRouter.deploy(DAI, DAI);
    const USDC = await ethers.getContractFactory("USDC", owner);
    usdc = await USDC.deploy();
    await usdc.deployed();
    const Traide = await ethers.getContractFactory("traide");
    traide = await upgrades.deployProxy(Traide, [uniswapRouter.address, usdc.address], {
      initilizer: 'initialize',
    });
    await traide.deployed();
   
    
  });

  it("should add a token", async function () {
    let price = 10n ** 18n
    await traide.connect(owner).addToken(DAI, price);
    expect(await traide.addressesOfToken(0)).to.eq(DAI);
    await expect(traide.connect(owner).addToken("0x0000000000000000000000000000000000000000", price)).to.be.revertedWith("Invalid address");
    price = 0;
    await expect(traide.connect(owner).addToken(DAI, price)).to.be.revertedWith("Price is lower or equal zero");

  })
  it("should remove a token", async function () {
    let price = 10n ** 18n
    await traide.connect(owner).addToken(DAI, price);
    expect(await traide.addressesOfToken(0)).to.eq(DAI);

    await traide.connect(owner).addToken(usdc.address, price);
    await traide.connect(owner).removeToken(DAI);
    expect(await traide.addressesOfToken(0)).to.eq(usdc.address);
    await expect(traide.connect(owner).removeToken(DAI)).to.be.revertedWith("No such address");

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

    await mockToken.connect(addr1).mint(addr1.address,price)
    await mockToken.connect(addr1).approve(traide.address, price)
    await traide.connect(addr1).mintNFTforTokens(mockToken.address)
    await expect(traide.connect(owner).burnNFT(0)).to.be.revertedWith("You are not an owner")

  })

  it("Owner should withdraw fee", async function(){
    uniswapRouter.exactInputSingle.returns(30)

    const price = 1000

    await traide.connect(owner).addToken(mockToken.address, price);
    await mockToken.connect(addr1).mint(addr1.address,price)
    await mockToken.connect(addr1).approve(traide.address, price)
    await traide.connect(addr1).mintNFTforTokens(mockToken.address)
    await traide.connect(addr1).burnNFT(0)
    
    await traide.connect(owner).withdrawFee(mockToken.address) 
    await expect(traide.connect(owner).withdrawFee(DAI)).to.be.revertedWith("Invalid address")

    await traide.connect(owner).addToken(usdc.address, price);
    await expect(traide.connect(owner).withdrawFee(usdc.address)).to.be.revertedWith("No fee yet")

  })
})
