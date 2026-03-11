const spawn = require('child_process').spawn;
const ffmpeg = process.env.FFMPEG;

const input = process.env.INPUT;
const output = process.env.OUTPUT;
const analyzedurationSize = '10M';
const probesizeSize = '32M';
const maxMuxingQueueSize = 1024;
const dualMonoMode = 'FL';
const videoHeight = parseInt(process.env.VIDEORESOLUTION, 10);
const isDualMono = parseInt(process.env.AUDIOCOMPONENTTYPE, 10) == 2;
const audioBitrate = videoHeight > 720 ? '192' : '128';
const profile = 'high';
const codec = 'h264';
const crf = 23;

const args = ['--input-analyze', analyzedurationSize, '--input-probesize', probesizeSize];

if (isDualMono) {
    Array.prototype.push.apply(args, ['--audio-stream', dualMonoMode]);
}

Array.prototype.push.apply(args,['--avhw', '--input-format', 'mpegts', '-i', input]);

Array.prototype.push.apply(args, [
    '--vpp-deinterlace', 'bob',
    '--output-res', '1280x720'
]);

Array.prototype.push.apply(args,[
    '--profile', profile,
    '--dar', '16:9',
    '--codec', codec,
    '--la-icq', crf,
    '--output-format', 'mp4',
    '--audio-codec', 'aac:aac_coder=twoloop',
    '--audio-samplerate', '48000',
    '--audio-bitrate', audioBitrate,
    '--audio-stream', ':stereo',
    '--output', output
]);

let str = '';
for (let i of args) {
    str += ` ${ i }`
}
console.error(str);

const child = spawn(ffmpeg, args);

/**
 * プログレスバー表示のための修正箇所
 */
let remainder = '';
child.stderr.on('data', (data) => {
    // 溜まっている文字列と新しいデータを結合して、改行またはキャリッジリターンで分割
    const lines = (remainder + data.toString()).split(/\r|\n/);
    remainder = lines.pop();

    for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed) {
            // 通常のログとして出力（ログビュー用）
            console.error(trimmed);

            // QSVEncCの進捗形式 "[ 2.5%]" を解析
            const match = trimmed.match(/\[\s*(\d+\.\d+)\s*%\]/);
            if (match) {
                const percent = parseFloat(match[1]) / 100;
                // EPGStationのプログレスバーを更新するためのJSON出力
                console.log(JSON.stringify({
                    type: 'progress',
                    percent: percent,
                    log: trimmed
                }));
            }
        }
    }
});

child.on('error', (err) => {
    console.error(err);
    throw new Error(err);
});

child.on('close', (code) => {
    // 残っている文字列があれば出力
    if (remainder.trim()) {
        console.error(remainder.trim());
    }
    process.exitCode = code;
});

process.on('SIGINT', () => {
    child.kill('SIGINT');
});