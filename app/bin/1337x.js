#!/usr/bin/env node

const request = require('https')
const spawn = require('child_process').spawn
const rofi =
    (data, callback) => {
        let stdout
        let stderr
        let menu = spawn("rofi", ["-dmenu", "-fuzy", "-i"])
        for (let d of data)
            menu.stdin.write(d + '\n')
        menu.stdin.end()
        menu.stdout.on('data', function(data) {
            stdout = data.toString().trim()
        })
        menu.stderr.on('data', function(data) {
            stderr = data
            console.error('error: ' + data.toString())
        })
        menu.on('exit', function(code) {
            if (code !== 0 && code !== 10 && (stdout || stderr)) {
                console.error('returned with code ' + code)
                return callback(code)
            }
            return callback(undefined, stdout, code)
        })
    }

const get_from_regex =
    (regex, data) => {
        let result = new Map()
        while ((m = regex.exec(data)) !== null) {
            if (m.index === regex.lastIndex) {
                regex.lastIndex++
            }
            let key = ""
            let matches = m.reduce((acc, el, index, arr) => {
                if (index == 2)
                    key = el
                return [...acc, el]
            }, [])
            result.set(key, matches)
        }
        return result
    }

const content_list =
    (url, regex) => {
        return new Promise((resolve, reject) => {
            request.get(url,
                    res => {
                        res.setEncoding('utf8')
                        let rawData = ""
                        res.on('data', chunk => rawData += chunk)
                        res.on('end', () => resolve(get_from_regex(regex, rawData)))
                    })
                .on('error', err => reject(err))
        })
    }

const print_magnet = (magnet) =>
    `${magnet[2]} | seeds ${magnet[3]} | leeches ${magnet[4]}`

const print_results = (results,prev) => {
  let res = [...results].map(r => r[1][5] == "last" ? "next" : print_magnet(r[1]))
  return prev?res.concat("prev"):res 
}

const paginator =
    (url, regex, page) => {
        content_list(url + "/" + page + "/", regex)
        .then(res => rofi(print_results(res,page>1), (err, selection, code) => {
                if (selection){
                    if (selection == "next")
                        paginator(url, regex, page + 1)
                    else if (selection == "prev")
                        paginator(url, regex, page - 1)
                    else 
                      content_list(
                            URL + (res.get(selection.split(" |")[0]))[1],
                            /href="(magnet.*?)"/gm)
                        .then(magnet => console.log(magnet.get("")[1]))
                }
            }))
    }

const URL = "https://www.1377x.to"
rofi([], (err, selection, code) => {
    if (selection)
        paginator(
            URL + "/search/" + encodeURI(selection),
            /(?:<a href="(\/torrent\/.*?)">(.*?)<.*\n.*?<td class="coll-2 seeds">(.*?)<.*\n<td class="coll-3 leeches">(.*?)<)|<li class="(last)">/gm,
            1)
})
