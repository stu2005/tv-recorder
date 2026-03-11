const spawn = require('child_process').spawn;
const execFile = require('child_process').execFile;
const ffmpeg = process.env.FFMPEG;
const ffprobe = process.env.FFPROBE;
const channelId = process.env.CHANNELID;
const serviceId = channelId % 100000;
const path = require('path');

const input = process.env.INPUT;
const output = process.env.OUTPUT;
const analyzedurationSize = '10M';
const probesizeSize = '32M';
const dualMonoMode = 'FL';
const videoHeight = parseInt(process.env.VIDEORESOLUTION, 10);
const isDualMono = parseInt(process.env.AUDIOCOMPONENTTYPE, 10) == 2;
const audioBitrate = videoHeight > 720 ? '192' : '128';
const profile = 'high';
const codec = 'h264';
const crf = 23;
const output_name = path.basename(output, path.extname(output));
const output_dir = path.dirname(output);

const args = ['--input-analyze', analyzedurationSize, '--input-probesize', probesizeSize];

if (isDualMono) {
    Array.prototype.push.apply(args, ['--audio-stream', dualMonoMode]);
}

Array.prototype.push.apply(args, [
    '--interlace', 'tff',
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
    '--output'
]);

// 変数名を argStr に変更して重複を回避
let argStr = '';
for (let i of args) {
    argStr += ` ${i}`;
}

const getDuration = filePath => {
    return new Promise((resolve, reject) => {
        execFile(ffprobe, ['-v', '0', '-show_format', '-of', 'json', filePath], (err, stdout) => {
            if (err) {
                reject(err);
                return;
            }
            try {
                const result = JSON.parse(stdout);
                resolve(parseFloat(result.format.duration));
            } catch (err) {
                reject(err);
            }
        });
    });
};

(async () => {
    const duration = await getDuration(input);

    let total_num = 0;
    let now_num = 0;
    let avisynth_flag = false;
    let percent = 0;
    let update_log_flag = false;
    let log = '';
    let remainder = ''; 

    // ここでも argStr を使用
    const jlse_args = ['-i', input, '-e', ffmpeg, '-c', serviceId, '-o', argStr, '-r', '-d', output_dir, '-n', output_name];
    
    var env = Object.create( process.env );
    env.HOME = '/root';
    const child = spawn('jlse', jlse_args, {env:env, detached: true});

    child.stderr.on('data', data => {
        // \r(キャリッジリターン)でも分割するように正規表現を使用
        let strbyline = (remainder + String(data)).split(/\r|\n/);
        remainder = strbyline.pop();

        for (let i = 0; i < strbyline.length; i++) {
            // ここで line を定義
            let line = strbyline[i].trim();
            if (!line) continue;

            switch(true) {
              case line.startsWith('AviSynth'): {
                const raw_avisynth_data = line.replace(/AviSynth\s/,'');
                if(raw_avisynth_data.startsWith('Creating')){
                  const avisynth_reg = /Creating\slwi\sindex\sfile\s(\d+)%/;
                  const match = raw_avisynth_data.match(avisynth_reg);
                  total_num = 200;
                  if (match) {
                    now_num = Number(match[1]);
                    now_num += avisynth_flag ? 100 : 0;
                    if (now_num == 100) avisynth_flag = true;
                  }
                }
                percent = now_num / total_num;
                log = `(1/4) AviSynth:Creating lwi index files`;
                update_log_flag = true;
                break;
              }

              case line.startsWith('chapter_exe'): {
                const raw_chapter_exe_data = line.replace(/chapter_exe\s/,'');
                if (raw_chapter_exe_data.startsWith('\tVideo Frames')) {
                    const movie_frame_reg = /\tVideo\sFrames:\s(\d+)\s\[\d+\.\d+fps\]/;
                    const match = raw_chapter_exe_data.match(movie_frame_reg);
                    if (match) total_num = Number(match[1]);
                } else if (raw_chapter_exe_data.startsWith('mute')) {
                    const chapter_reg = /mute\s?\d+:\s(\d+)\s\-\s\d+フレーム/;
                    const match = raw_chapter_exe_data.match(chapter_reg);
                    if (match) now_num = Number(match[1]);
                } else if (raw_chapter_exe_data.startsWith('end')) {
                    now_num = total_num;
                }
                percent = total_num > 0 ? now_num / total_num : 0;
                log = `(2/4) Chapter_exe: ${now_num}/${total_num}`;
                update_log_flag = true;
                break;
              }

              case line.startsWith('logoframe'): {
                const raw_logoframe_data = line.replace(/logoframe\s/,'');
                const logoframe_reg = /checking\s*(\d+)\/(\d+)\sended./;
                const logoframe = raw_logoframe_data.match(logoframe_reg);
                if (logoframe) {
                    now_num = Number(logoframe[1]);
                    total_num = Number(logoframe[2]);
                    percent = now_num / total_num;
                    log = `(3/4) logoframe: ${now_num}/${total_num}`;
                    update_log_flag = true;
                }
                break;
              }

              // QSVEncC 用の進捗解析
              case line.includes('%]'): {
                const qsvMatch = line.match(/\[\s*(\d+\.\d+)\s*%\]/);
                if (qsvMatch) {
                    percent = parseFloat(qsvMatch[1]) / 100;
                    log = `(4/4) QSVEnc: ${line}`;
                    update_log_flag = true;
                }
                break;
              }

              default: {
                console.log(line);
                break;
              }
            }

            if(update_log_flag) {
                console.log(JSON.stringify({ type: 'progress', percent: percent, log: log }));
                update_log_flag = false;
            }
        }
    });

    child.on('error', err => {
        console.error(err);
        throw new Error(err);
    });

    process.on('SIGINT', () => {
        process.kill(-child.pid, 'SIGINT');
    });

    child.on('close', code => {
        process.exitCode = code;
    });
})();