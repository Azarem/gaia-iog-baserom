/**
 * US ROM names, split by ROM bank.
 *
 * Each `db-us/names/bankNN.json` maps decimal ROM addresses to label names,
 * where NN is the two-digit hex bank (bank = floor(address / 65536)).
 *
 * Unlike `notes/`, names are required to extract and rebuild the ROM, so they
 * must be bundled into the published package. That rules out filesystem
 * discovery: every bank file is imported explicitly here and merged into the
 * flat address -> name dictionary the engine expects.
 *
 * To add a bank: create `db-us/names/bankNN.json` and add one import + one
 * array entry below.
 */
import bank00 from '../db-us/names/bank00.json' with { type: 'json' };
import bank01 from '../db-us/names/bank01.json' with { type: 'json' };
import bank02 from '../db-us/names/bank02.json' with { type: 'json' };
import bank03 from '../db-us/names/bank03.json' with { type: 'json' };
import bank04 from '../db-us/names/bank04.json' with { type: 'json' };
import bank05 from '../db-us/names/bank05.json' with { type: 'json' };
import bank06 from '../db-us/names/bank06.json' with { type: 'json' };
import bank07 from '../db-us/names/bank07.json' with { type: 'json' };
import bank08 from '../db-us/names/bank08.json' with { type: 'json' };
import bank09 from '../db-us/names/bank09.json' with { type: 'json' };
import bank0A from '../db-us/names/bank0A.json' with { type: 'json' };
import bank0B from '../db-us/names/bank0B.json' with { type: 'json' };
import bank0C from '../db-us/names/bank0C.json' with { type: 'json' };
import bank16 from '../db-us/names/bank16.json' with { type: 'json' };
import bank14 from '../db-us/names/bank14.json' with { type: 'json' };
import bank0E from '../db-us/names/bank0E.json' with { type: 'json' };
import bank15 from '../db-us/names/bank15.json' with { type: 'json' };
import bank17 from '../db-us/names/bank17.json' with { type: 'json' };
import bank0F from '../db-us/names/bank0F.json' with { type: 'json' };

const bankNames: Record<string, string>[] = [
    bank00, bank01, bank02, bank03, bank04, bank05, bank06,
    bank07, bank08, bank09, bank0A, bank0B, bank0C, bank16,
    bank14,
    bank0E,
    bank15,
    bank17,
    bank0F,
];

export const names: Record<string, string> = Object.assign({}, ...bankNames);
