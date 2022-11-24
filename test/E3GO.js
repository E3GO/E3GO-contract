const { expect } = require("chai");
const { ethers, upgrades} = require("hardhat");

describe("E3GO Contract", function () {

    let MocktGHP, MATICUSD, EURUSD
    let tGHP
    let owner, addr1, addr2, addr3
    let priceFeed_EURUSD
    let priceFeed_MATICUSD

    before(async () => {
        MocktGHP = await ethers.getContractFactory("MockE3GO")
        MATICUSD = await ethers.getContractFactory("TestMaticUsd")
        EURUSD = await ethers.getContractFactory("TestEurUsd")
        
        priceFeed_MATICUSD = await MATICUSD.deploy()
        await priceFeed_MATICUSD.deployed()

        priceFeed_EURUSD = await EURUSD.deploy()
        await priceFeed_EURUSD.deployed()
    })
    beforeEach(async () => {
        [owner, addr1, addr2, addr3, funds] = await ethers.getSigners()
        
        tGHP = await upgrades.deployProxy(MocktGHP, [priceFeed_MATICUSD.address, priceFeed_EURUSD.address, funds.address]);
    
        await tGHP.deployed();
    })
    
    describe("Deployment", () => {
        
        it("Should set the right Admin", async () => {

            expect(await tGHP.hasRole(tGHP.DEFAULT_ADMIN_ROLE(), owner.address)).to.equal(true);
        })

        it("Should set the moderator role too", async () => {

            expect(await tGHP.hasRole(tGHP.MODERATOR_ROLE(), owner.address)).to.equal(true);
        })

        it("Should initialze correctly", async () => {
            
            expect(await tGHP.wallet()).to.equal(funds.address)
        })
    })

    describe("Core contract", () => {
        
        it("Should create PASS with the right amount", async () => {
            
            await tGHP.createPass(1000)
            expect(await tGHP.tokenIdPrice(1)).to.equal(1000)
        })
        
        it("Should revert because pass doesn't exist", async () => {
            await expect(tGHP.mintTo(addr1.address, 1, 1, {value: ethers.utils.parseEther("10")})).to.be.revertedWith("tGHP: This token isn't setup yet.")
        })
        
        it("Should change matic to eur correctly", async () => {
            expect((await tGHP.changeMATICEUR(ethers.utils.parseEther("8"))).toString()).to.equal("1007") // In ths mock config 8 MATIC = 10.07 EUR
        })
        
        it("Should revert because not enough funds", async () => {
            await tGHP.createPass(1000)
            await expect(tGHP.mintTo(addr1.address, 1, 1, {value: ethers.utils.parseEther("1")})).to.be.revertedWith("tGHP: Not enough to buy.")
        })

        it("Should mintTo addr1", async () => {
            await tGHP.createPass(1000)
            
            await tGHP.mintTo(addr1.address, 1, 1, {value: ethers.utils.parseEther("8")}) // With the chainlink simulation 8 MATIC = ~10 EUR
            expect(await tGHP.balanceOf(addr1.address, 1)).to.equal(1)
        })
        
        it("Should mintTo addr1 multiple pass and one NFT", async () => {
            await tGHP.createPass(500)
            expect(await tGHP.connect(owner).mintNftTo(addr1.address)).to.emit(tGHP, "TransferSingle").withArgs(tGHP.address, ethers.constants.AddressZero, addr1.address, 2, 1)
            expect(await tGHP.mintTo(addr1.address, 1, 2, {value: ethers.utils.parseEther("8")})).to.emit(tGHP, "TransferSingle").withArgs(tGHP.address, ethers.constants.AddressZero, addr1.address, 1, 1)
        })

        it("Test checkClaimEligibility", async () => {
            await tGHP.createPass(500)
            expect(await tGHP.checkClaimEligibility(1)).to.equal("")
            expect(await tGHP.checkClaimEligibility(0)).to.equal("tGHP: This token isn't setup yet.")
        })

    })
    
    describe("Full coverage", () => {
        it("_authorizeUpgrade test", async () => {
            expect(tGHP.coverage()).to.be.reverted;
        })

        it("decEURUSD < decMATICUSD and the else path (useless because price feed have same decimals but 100%", async () => {
            await priceFeed_EURUSD.setDecimal(7)
            await tGHP.changeMATICEUR(ethers.utils.parseEther("8"))
            await priceFeed_EURUSD.setDecimal(9)
            await tGHP.changeMATICEUR(ethers.utils.parseEther("8"))
        })

        it("test the rest AggregatorV3Interface", async () => {
            await priceFeed_EURUSD.description()
            await priceFeed_EURUSD.version()
            await priceFeed_EURUSD.getRoundData(5)
            await priceFeed_MATICUSD.description()
            await priceFeed_MATICUSD.version()
            await priceFeed_MATICUSD.getRoundData(5)
        })
        
        it("test interface Id", async () => {
            await tGHP.supportsInterface('0x01ffc9a7')
        })
    })
    
})