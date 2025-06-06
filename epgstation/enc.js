const spawn = require('child_process').spawn;
const ffmpeg = process.env.FFMPEG;

const input = process.env.INPUT;
const output = process.env.OUTPUT;
const analyzedurationSize = '10M'; // Mirakurun の設定に応じて変更すること
const probesizeSize = '32M'; // Mirakurun の設定に応じて変更すること
const maxMuxingQueueSize = 1024;
const dualMonoMode = 'main';
const videoHeight = parseInt(process.env.VIDEORESOLUTION, 10);
const isDualMono = parseInt(process.env.AUDIOCOMPONENTTYPE, 10) == 2;
const audioBitrate = videoHeight > 720 ? '192k' : '128k';
const preset = 'veryfast';
const codec = 'h264_qsv';
const crf = 23;

const args = ['-y', '-analyzeduration', analyzedurationSize, '-probesize', probesizeSize];

// dual mono 設定
if (isDualMono) {
    Array.prototype.push.apply(args, ['-dual_mono_mode', dualMonoMode]);
}

// input 設定
Array.prototype.push.apply(args,['-hwaccel', 'qsv', '-c:v', 'mpeg2_qsv', '-i', input]);

// メタ情報を先頭に置く
Array.prototype.push.apply(args,['-movflags', 'faststart']);

// 字幕データを含めたストリームをすべてマップ
// Array.prototype.push.apply(args, ['-map', '0', '-ignore_unknown', '-max_muxing_queue_size', maxMuxingQueueSize, '-sn']);

// video filter 設定
let videoFilter = 'deinterlace_qsv';
if (videoHeight > 720) {
    videoFilter += ',scale_qsv=w=1920:h=1080,setsar=1'
}
Array.prototype.push.apply(args, ['-vf', videoFilter]);

// その他設定
Array.prototype.push.apply(args,[
    '-preset', preset,
    '-aspect', '16:9',
    '-b:v', '6000k',
    '-c:v', codec,
    '-crf', crf,
    '-f', 'mp4',
    '-c:a', 'libfdk_aac',
    '-ar', '48000',
    '-ab', audioBitrate,
    '-ac', '2',
    output
]);

let str = '';
for (let i of args) {
    str += ` ${ i }`
}
console.error(str);

const child = spawn(ffmpeg, args);

child.stderr.on('data', (data) => { console.error(String(data)); });

child.on('error', (err) => {
    console.error(err);
    throw new Error(err);
});

child.on('close', (code) => {
    process.exitCode = code;
});

process.on('SIGINT', () => {
    child.kill('SIGINT');
});
