const HelloWorld = artifacts.require('HelloWorld');

contract('Hello World', () => {
    it('Set the initial value', async () => {
        const helloWorld = await HelloWorld.new('Hello Dev!');
        const data = await helloWorld.value();
        assert.equal('Hello Dev!', data);
    });
    it('Update the value', async () => {
        const helloWorld = await HelloWorld.new('Hello Dev!');
        await helloWorld.changeValue('Bye Dev!');
        const data = await helloWorld.value();
        assert.equal('Bye Dev!', data);
    });
});