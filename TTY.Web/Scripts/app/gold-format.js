// 主框架与独立内容页共用；IsRMB/ExchangeRate 由各自视图从同一配置注入。
function goldFormat(score) {
    if ((typeof score == "number" || /\d+\.\d+/g.test(score)) && window.isRMB == true)
        return formatMoney(score / window.ExchangeRate, '');
    else
        return typeof score == "number" ? Number(score.toFixed(8)) : score;
}

function formatMoney(s, dot) {
    s = parseFloat((s + "").replace(/[^\d\.-]/g, "")).toFixed(2) + "";
    var l = s.split(".")[0].split("").reverse(),
        r = s.split(".")[1],
        t = "";
    for (var i = 0; i < l.length; i++) {
        t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? dot : "");
    }
    return t.split("").reverse().join("") + "." + r;
}
