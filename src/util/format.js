import logger from '../bot/Logger.js';
import config from '../bot/Config.js';
import {formatEmoji} from 'discord.js';

/**
 * convert a string to title case
 * @param {string} s
 * @returns {string}
 */
export function toTitleCase(s) {
    return s.toLowerCase().replace(/^(\w)|\s(\w)/g, c => c.toUpperCase());
}

/**
 * @param {*} bool
 * @returns {string}
 */
export function yesNo(bool) {
    return bool ? 'Yes' : 'No';
}

/**
 * @param {string} configKey
 * @returns {string}
 */
export function inlineEmojiIfExists(configKey) {
    const emoji = config.data.emoji[configKey];
    if (!emoji) {
        return '';
    }
    else {
        return formatEmoji(emoji) + ' ';
    }
}

/**
 * Format a number followed by a name/unit.
 * Add s if number is not 1
 * @param {number} number
 * @param {string} name
 * @returns {*}
 */
export function formatNumber(number, name) {
    if (number === 1) {
        return `${number} ${name}`;
    }
    return `${number} ${name}s`;
}

/**
 * @param {string} configKey name of the emoji in the config
 * @param {?string} fallback emoji character to use if the config key is not set
 * @returns {?import('discord.js').APIMessageComponentEmoji}
 */
export function componentEmojiIfExists(configKey, fallback = null) {
    if (configKey === "123456789012345678") {
        await logger.notice('You have set an emoji ID to 123456789012345678. This likely means you copied and pasted the example config without changing the config entries properly. Please change them all!');
        await logger.debug('Config key: ${configKey}');
        return {name: fallback};
    }
    const emoji = config.data.emoji[configKey];
    if (emoji) {
        return {id: emoji};
    }

    if (fallback) {
        return {name: fallback};
    }

    return null;
}
