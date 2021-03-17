const { assert } = require("chai");

describe('Lottery', function () {
    before(async () => {
        const Lottery = await ethers.getContractFactory("Lottery");
        lottery = await Lottery.deploy();
        await lottery.deployed();
    });

    it('should set the lottery drawing', async () => {
        const drawing = await lottery.drawing();
        assert(drawing, "expected the drawing uint to be set!");
    });

    it('should set the lottery drawing for a week away', async () => {
        const drawing = await lottery.drawing();
        const unixSeconds = Math.floor(Date.now() / 1000);

        const oneWeek = 7 * 24 * 60 * 60;
        const oneWeekFromNow = unixSeconds + oneWeek;
        assert(drawing.gte(oneWeekFromNow.toString()), "expected the lottery drawing to be a week from now");

        const eightDays = 8 * 24 * 60 * 60;
        const eightDaysFromNow = unixSeconds + eightDays;
        assert(drawing.lt(eightDaysFromNow.toString()), "expected the lottery drawing to less than 8 days away");
    });
});
