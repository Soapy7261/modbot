import Database from '../bot/Database.js';

/**
 * @template T
 */
export default class Confirmation {

    /**
     * @param {T} data
     * @param {number} expires
     * @param {?number} id
     */
    constructor(data, expires, id = null) {
        this.data = data;
        this.expires = expires;
        this.id = id;
    }


    /**
     * @template T
     * @param {number} id
     * @return {Promise<Confirmation<T>|null>}
     */
    static async get(id) {
        const data = await Database.instance.query('SELECT id, data, expires FROM confirmations WHERE id = ?', id);
        if (!data) {
            return null;
        }

        return new this(JSON.parse(data.data), parseInt(data.expires), id);
    }

    /**
     * save this confirmation
     * @return {Promise<number>}
     */
    async save() {
        if (this.id) {
            await Database.instance.query('UPDATE confirmations SET data = ?, expires = ? WHERE id = ?',
                JSON.stringify(this.data), this.expires, this.id);
            return this.id;
        } else {
            const insert = await Database.instance.queryAll('INSERT INTO confirmations (data, expires) VALUES (?,?)',
                JSON.stringify(this.data), this.expires);
            return this.id = insert.insertId;
        }
    }
}