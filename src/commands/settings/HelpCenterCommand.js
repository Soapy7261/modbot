const Command = require('../../Command');
const Request = require('../../Request');

class HelpCenterCommand extends Command {

    static description = 'Configure the Zendesk help center';

    static usage = '<url|id>|off|show';

    static names = ['helpcenter', 'zendesk'];

    static userPerms = ['MANAGE_GUILD'];

    async execute() {
        if (this.args.length !== 1) {
            await this.sendUsage();
            return;
        }

        switch (this.args[0].toLowerCase()) {
            case "off":
                this.guildConfig.helpcenter = null;
                await this.guildConfig.save();
                await this.message.channel.send("Disabled Zendesk help center!")
                break;
            case "show":
                if (!this.guildConfig.helpcenter) {
                    await this.message.channel.send('There is no help center configured');
                }
                else {
                    await this.message.channel.send(`Active help center: https://${this.guildConfig.helpcenter}.zendesk.com`);
                }
                break;
            default:
                let subdomain = this.args.shift().replace(/^https?:\/\/|\.zendesk\.com(\/.*)?$/ig, '').replace(/[^\w]/g, '');

                if (!subdomain) {
                    await this.sendUsage();
                    return;
                }

                const request = new Request(`https://${subdomain}.zendesk.com/api/v2/help_center/articles.json`);
                try {
                    await request.getJSON();
                } catch (e) {
                    await this.message.channel.send('This is not a valid helpcenter subdomain!');
                    return;
                }
                this.guildConfig.helpcenter = subdomain;
                await this.guildConfig.save();
                await this.message.channel.send(`Set help center to https://${subdomain}.zendesk.com`);
        }
    }
}

module.exports = HelpCenterCommand;
