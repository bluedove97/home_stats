<%@ page language='java' contentType='text/html; charset=UTF-8' pageEncoding='UTF-8' isELIgnored="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Server Dashboard</title>
  <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
  <link rel="stylesheet" href="style/tailwind.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <style>
    * { font-family: 'Consolas', 'Monaco', 'Courier New', monospace; }
    .bar { transition: width 0.6s ease; }
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: #111827; }
    ::-webkit-scrollbar-thumb { background: #374151; border-radius: 3px; }
  </style>
</head>
<body class="bg-gray-900 text-gray-100 min-h-screen">
<div class="max-w-screen-xl mx-auto px-4 py-5 md:px-6">

  <!-- Header -->
  <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-3">
    <div>
      <h1 class="text-xl font-bold text-white tracking-wide">Server Dashboard</h1>
      <p class="text-xs text-gray-500 mt-0.5">10분 자동 갱신</p>
    </div>
    <div class="text-xs text-gray-400 bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 space-y-0.5">
      <div>마지막 업데이트: <span id="lastUpdate" class="text-gray-200 font-mono">-</span></div>
      <div>다음 갱신: <span id="countdown" class="text-green-400 font-mono">-</span></div>
    </div>
  </div>

  <!-- System Stats Cards -->
  <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3 mb-5">
    <div class="bg-gray-800 border border-gray-700 rounded-xl p-4 text-center">
      <div class="text-xs text-gray-500 mb-2 uppercase tracking-wider">CPU</div>
      <div id="cpuVal" class="text-2xl font-bold text-green-400">-</div>
      <div class="w-full bg-gray-700 rounded-full h-1 mt-2">
        <div id="cpuBar" class="bg-green-500 h-1 rounded-full bar" style="width:0%"></div>
      </div>
    </div>
    <div class="bg-gray-800 border border-gray-700 rounded-xl p-4 text-center">
      <div class="text-xs text-gray-500 mb-2 uppercase tracking-wider">Temp</div>
      <div id="tempVal" class="text-2xl font-bold text-green-400">-</div>
      <div class="text-xs text-gray-600 mt-2">celsius</div>
    </div>
    <div class="bg-gray-800 border border-gray-700 rounded-xl p-4 text-center">
      <div class="text-xs text-gray-500 mb-2 uppercase tracking-wider">Memory</div>
      <div id="memVal" class="text-2xl font-bold text-yellow-400">-</div>
      <div id="memDetail" class="text-xs text-gray-600 mt-1">-</div>
      <div class="w-full bg-gray-700 rounded-full h-1 mt-1">
        <div id="memBar" class="bg-yellow-500 h-1 rounded-full bar" style="width:0%"></div>
      </div>
    </div>
    <div class="bg-gray-800 border border-gray-700 rounded-xl p-4 text-center">
      <div class="text-xs text-gray-500 mb-2 uppercase tracking-wider">Disk</div>
      <div id="diskVal" class="text-2xl font-bold text-green-400">-</div>
      <div id="diskDetail" class="text-xs text-gray-600 mt-1">-</div>
      <div class="w-full bg-gray-700 rounded-full h-1 mt-1">
        <div id="diskBar" class="bg-green-500 h-1 rounded-full bar" style="width:0%"></div>
      </div>
    </div>
    <div class="bg-gray-800 border border-gray-700 rounded-xl p-4 text-center">
      <div class="text-xs text-gray-500 mb-2 uppercase tracking-wider">SSD</div>
      <div id="ssdVal" class="text-2xl font-bold text-green-400">-</div>
      <div id="ssdDetail" class="text-xs text-gray-600 mt-1">-</div>
      <div class="w-full bg-gray-700 rounded-full h-1 mt-1">
        <div id="ssdBar" class="bg-green-500 h-1 rounded-full bar" style="width:0%"></div>
      </div>
    </div>
    <div class="bg-gray-800 border border-gray-700 rounded-xl p-4 text-center">
      <div class="text-xs text-gray-500 mb-2 uppercase tracking-wider">Uptime</div>
      <div id="uptimeVal" class="text-base font-bold text-blue-400 leading-snug">-</div>
      <div class="text-xs text-gray-600 mt-1">online</div>
    </div>
  </div>

  <!-- Charts -->
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-5">
    <div class="bg-gray-800 border border-gray-700 rounded-xl p-4">
      <div class="flex justify-between items-center mb-3">
        <h2 class="text-xs text-gray-400 uppercase tracking-wider">CPU Usage History</h2>
        <span class="text-xs text-amber-400 bg-amber-900 bg-opacity-40 px-2 py-0.5 rounded">24h</span>
      </div>
      <div style="position:relative; height:140px;">
        <canvas id="cpuChart"></canvas>
      </div>
    </div>
    <div class="bg-gray-800 border border-gray-700 rounded-xl p-4">
      <div class="flex justify-between items-center mb-3">
        <h2 class="text-xs text-gray-400 uppercase tracking-wider">Memory Usage History</h2>
        <span class="text-xs text-blue-400 bg-blue-900 bg-opacity-40 px-2 py-0.5 rounded">24h</span>
      </div>
      <div style="position:relative; height:140px;">
        <canvas id="memChart"></canvas>
      </div>
    </div>
  </div>

  <!-- Docker Containers -->
  <div class="mb-5">
    <h2 class="text-xs text-gray-400 uppercase tracking-wider mb-3">Docker Containers</h2>
    <div id="dockerGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-3">
      <div class="bg-gray-800 border border-gray-700 rounded-xl p-4 text-center text-gray-600 text-sm col-span-full">
        loading...
      </div>
    </div>
  </div>

  <!-- System Log -->
  <div class="bg-gray-800 border border-gray-700 rounded-xl">
    <div class="flex justify-between items-center px-4 py-3 cursor-pointer select-none" onclick="toggleLog()">
      <h2 class="text-xs text-gray-400 uppercase tracking-wider">System Log</h2>
      <span id="logToggle" class="text-gray-500 text-sm">▼</span>
    </div>
    <div id="logSection" class="border-t border-gray-700">
      <div class="overflow-x-auto px-4 pb-4 pt-3">
        <table class="w-full text-xs">
          <thead>
            <tr class="text-gray-500 border-b border-gray-700">
              <th class="text-left pb-2 pr-4 font-normal whitespace-nowrap">Date</th>
              <th class="text-right pb-2 pr-4 font-normal">CPU</th>
              <th class="text-right pb-2 pr-4 font-normal">Temp</th>
              <th class="text-right pb-2 pr-4 font-normal">Memory</th>
              <th class="text-right pb-2 pr-4 font-normal">Disk</th>
              <th class="text-right pb-2 font-normal">SSD</th>
            </tr>
          </thead>
          <tbody id="logBody">
            <tr><td colspan="6" class="text-center text-gray-600 py-4">loading...</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

</div>

<script>
  let cpuChart = null;
  let memChart = null;
  let countdownSec = 600;
  let countdownInterval = null;

  // ── Parsing ──────────────────────────────────────────────────────────────

  function parseDataHtml(text) {
    return text.split('<hr/>')
      .map(function(s) { return s.trim(); })
      .filter(function(s) { return s.length > 0; })
      .map(function(entry) {
        var dateM = entry.match(/Check Date:\s*([\d\-]+ [\d:]+)/);
        if (!dateM) return null;
        var cpuM    = entry.match(/CPU Usage:\s*([\d.]+)%/);
        var tempM   = entry.match(/CPU Temperature:\s*([\d.]+)/);
        var memM    = entry.match(/Memory Usage:\s*(\d+)\/(\d+)MB\s*\(([\d.]+)%\)/);
        var diskM   = entry.match(/Disk Usage:\s*([\d.A-Za-z]+)\/([\d.A-Za-z]+)\s*\((\d+)%\)/);
        var ssdM    = entry.match(/SSD Usage:\s*([\d.A-Za-z]+)\/([\d.A-Za-z]+)\s*\((\d+)%\)/);
        var upM     = entry.match(/Up-Time:\s*(.+?)<\/div>/);
        return {
          date:      dateM[1],
          cpu:       cpuM   ? parseFloat(cpuM[1])   : 0,
          temp:      tempM  ? parseFloat(tempM[1])  : 0,
          memUsed:   memM   ? parseInt(memM[1])     : 0,
          memTotal:  memM   ? parseInt(memM[2])     : 0,
          memPct:    memM   ? parseFloat(memM[3])   : 0,
          diskUsed:  diskM  ? diskM[1]              : '-',
          diskTotal: diskM  ? diskM[2]              : '-',
          diskPct:   diskM  ? parseInt(diskM[3])    : 0,
          ssdUsed:   ssdM   ? ssdM[1]              : '-',
          ssdTotal:  ssdM   ? ssdM[2]              : '-',
          ssdPct:    ssdM   ? parseInt(ssdM[3])     : 0,
          uptime:    upM    ? upM[1].replace(/<[^>]+>/g, '').trim() : '-'
        };
      })
      .filter(Boolean);
  }

  function parseDockerHtml(text) {
    var parser = new DOMParser();
    var doc = parser.parseFromString(text, 'text/html');
    return Array.from(doc.querySelectorAll('table')).map(function(table) {
      var data = {};
      table.querySelectorAll('tr').forEach(function(row) {
        var cells = row.querySelectorAll('td');
        if (cells.length === 2) {
          data[cells[0].textContent.trim()] = cells[1].textContent.trim();
        }
      });
      return data;
    }).filter(function(c) { return c['NAME']; });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  function statusColor(pct, isTemp) {
    if (isTemp) {
      if (pct < 50) return '#4ade80';
      if (pct < 70) return '#facc15';
      return '#f87171';
    }
    if (pct < 50) return '#4ade80';
    if (pct < 80) return '#facc15';
    return '#f87171';
  }

  function statusTextClass(pct, isTemp) {
    if (isTemp) {
      if (pct < 50) return 'text-green-400';
      if (pct < 70) return 'text-yellow-400';
      return 'text-red-400';
    }
    if (pct < 50) return 'text-green-400';
    if (pct < 80) return 'text-yellow-400';
    return 'text-red-400';
  }

  function barColorClass(pct) {
    if (pct < 50) return 'bg-green-500';
    if (pct < 80) return 'bg-yellow-500';
    return 'bg-red-500';
  }

  function fmtStartup(raw) {
    var months = { Jan:'01', Feb:'02', Mar:'03', Apr:'04', May:'05', Jun:'06',
                   Jul:'07', Aug:'08', Sep:'09', Oct:'10', Nov:'11', Dec:'12' };
    var m = raw.match(/(\w{3})\s+(\d{1,2})\s+(\d{2}:\d{2}:\d{2})\s+\S+\s+(\d{4})/);
    if (!m) return raw;
    return m[4] + '-' + (months[m[1]] || '??') + '-' + m[2].padStart(2, '0') + ' ' + m[3];
  }

  function fmtUptime(raw) {
    var wM = raw.match(/(\d+)\s*weeks?/);
    var dM = raw.match(/(\d+)\s*days?/);
    var hM = raw.match(/(\d+)\s*hours?/);
    var mM = raw.match(/(\d+)\s*minutes?/);
    var parts = [];
    if (wM) parts.push(wM[1] + 'w');
    if (dM) parts.push(dM[1] + 'd');
    if (hM) parts.push(hM[1] + 'h');
    if (!wM && !dM && mM) parts.push(mM[1] + 'm');
    return parts.length ? parts.join(' ') : raw;
  }

  function setCard(id, html, pct, isTemp) {
    var el = document.getElementById(id);
    if (!el) return;
    el.innerHTML = html;
    var cls = statusTextClass(pct, isTemp);
    el.className = 'text-2xl font-bold ' + cls;
  }

  function setBar(id, pct) {
    var el = document.getElementById(id);
    if (!el) return;
    el.style.width = Math.min(pct, 100) + '%';
    el.className = 'h-1 rounded-full bar ' + barColorClass(pct);
  }

  // ── Render Stats ─────────────────────────────────────────────────────────

  function renderStats(cur) {
    var upEl = document.getElementById('lastUpdate');
    if (upEl) upEl.textContent = cur.date;

    setCard('cpuVal',  cur.cpu + '%',                  cur.cpu, false);
    setCard('tempVal', cur.temp.toFixed(1) + '°C',      cur.temp, true);
    setCard('memVal',  cur.memPct.toFixed(1) + '%',     cur.memPct, false);
    setCard('diskVal', cur.diskPct + '%',               cur.diskPct, false);
    setCard('ssdVal',  cur.ssdPct + '%',                cur.ssdPct, false);

    var memDetail = document.getElementById('memDetail');
    if (memDetail) memDetail.textContent = cur.memUsed + '/' + cur.memTotal + 'MB';
    var diskDetail = document.getElementById('diskDetail');
    if (diskDetail) diskDetail.textContent = cur.diskUsed + '/' + cur.diskTotal;
    var ssdDetail = document.getElementById('ssdDetail');
    if (ssdDetail) ssdDetail.textContent = cur.ssdUsed + '/' + cur.ssdTotal;
    var uptimeEl = document.getElementById('uptimeVal');
    if (uptimeEl) uptimeEl.textContent = fmtUptime(cur.uptime);

    setBar('cpuBar',  cur.cpu);
    setBar('memBar',  cur.memPct);
    setBar('diskBar', cur.diskPct);
    setBar('ssdBar',  cur.ssdPct);
  }

  // ── Render Docker ─────────────────────────────────────────────────────────

  function renderDocker(containers) {
    var grid = document.getElementById('dockerGrid');
    if (!containers.length) {
      grid.innerHTML = '<div class="col-span-full text-center text-gray-600 py-4 text-sm">No containers found</div>';
      return;
    }
    grid.innerHTML = containers.map(function(c) {
      var name    = c['NAME'] || '-';
      var cpuPct  = parseFloat(c['CPU%'])  || 0;
      var memPct  = parseFloat(c['MEM%'])  || 0;
      var memStr  = c['MEM USAGE / LIMIT'] || '-';
      var netStr  = c['NET I/O']           || '-';
      var blkStr  = c['BLOCK I/O']         || '-';
      var startStr = fmtStartup(c['STARTUP'] || '');
      var cpuCls  = statusTextClass(cpuPct);
      var memCls  = statusTextClass(memPct);
      var cpuBar  = barColorClass(cpuPct);
      var memBar  = barColorClass(memPct);
      var cpuW    = Math.min(cpuPct, 100).toFixed(1);
      var memW    = Math.min(memPct, 100).toFixed(1);

      return '<div class="bg-gray-900 border border-gray-700 rounded-xl p-4">'
        + '<div class="text-sm font-bold text-white mb-3 truncate" title="' + name + '">' + name + '</div>'
        + '<div class="space-y-2.5">'
        + '<div>'
        + '<div class="flex justify-between text-xs mb-1">'
        + '<span class="text-gray-500">CPU</span>'
        + '<span class="' + cpuCls + ' font-mono">' + (c['CPU%'] || '-') + '</span>'
        + '</div>'
        + '<div class="h-1 bg-gray-700 rounded-full overflow-hidden">'
        + '<div class="h-full ' + cpuBar + ' rounded-full bar" style="width:' + cpuW + '%"></div>'
        + '</div>'
        + '</div>'
        + '<div>'
        + '<div class="flex justify-between text-xs mb-1">'
        + '<span class="text-gray-500">MEM</span>'
        + '<span class="' + memCls + ' font-mono">' + (c['MEM%'] || '-') + '</span>'
        + '</div>'
        + '<div class="h-1 bg-gray-700 rounded-full overflow-hidden">'
        + '<div class="h-full ' + memBar + ' rounded-full bar" style="width:' + memW + '%"></div>'
        + '</div>'
        + '</div>'
        + '<div class="pt-1 space-y-1">'
        + '<div class="text-xs text-gray-600 truncate" title="' + memStr + '">'
        + '<span class="text-gray-500">Mem </span>' + memStr
        + '</div>'
        + '<div class="text-xs text-gray-600 truncate" title="' + netStr + '">'
        + '<span class="text-gray-500">Net </span>' + netStr
        + '</div>'
        + '<div class="text-xs text-gray-700 truncate" title="' + blkStr + '">'
        + '<span class="text-gray-600">Blk </span>' + blkStr
        + '</div>'
        + '<div class="text-xs text-gray-600 truncate border-t border-gray-800 pt-1 mt-1" title="' + startStr + '">'
        + '<span class="text-gray-500">Start </span>' + startStr
        + '</div>'
        + '</div>'
        + '</div>'
        + '</div>';
    }).join('');
  }

  // ── Render Log ────────────────────────────────────────────────────────────

  function renderLog(history) {
    var body = document.getElementById('logBody');
    if (!history.length) {
      body.innerHTML = '<tr><td colspan="6" class="text-center text-gray-600 py-4">No data</td></tr>';
      return;
    }
    body.innerHTML = history.map(function(e, i) {
      var rowCls = i === 0 ? 'bg-gray-700 bg-opacity-30' : '';
      var cpuCls  = statusTextClass(e.cpu);
      var tempCls = statusTextClass(e.temp, true);
      var memCls  = statusTextClass(e.memPct);
      return '<tr class="border-t border-gray-700 ' + rowCls + ' hover:bg-gray-700 hover:bg-opacity-20">'
        + '<td class="py-1.5 pr-4 whitespace-nowrap text-gray-400 font-mono">' + e.date + '</td>'
        + '<td class="py-1.5 pr-4 text-right ' + cpuCls + ' font-mono">' + e.cpu + '%</td>'
        + '<td class="py-1.5 pr-4 text-right ' + tempCls + ' font-mono">' + e.temp.toFixed(1) + '°C</td>'
        + '<td class="py-1.5 pr-4 text-right ' + memCls + ' font-mono">' + e.memPct.toFixed(1) + '%</td>'
        + '<td class="py-1.5 pr-4 text-right text-gray-400 font-mono">' + e.diskPct + '%</td>'
        + '<td class="py-1.5 text-right text-gray-400 font-mono">' + e.ssdPct + '%</td>'
        + '</tr>';
    }).join('');
  }

  // ── Charts ────────────────────────────────────────────────────────────────

  var chartBaseOptions = {
    responsive: true,
    maintainAspectRatio: false,
    animation: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        mode: 'index',
        intersect: false,
        backgroundColor: 'rgba(17,24,39,0.95)',
        titleColor: '#9ca3af',
        bodyColor: '#e5e7eb',
        borderColor: '#374151',
        borderWidth: 1,
        padding: 8
      }
    },
    scales: {
      x: {
        grid: { color: 'rgba(255,255,255,0.04)', drawBorder: false },
        ticks: { color: '#6b7280', maxTicksLimit: 8, font: { size: 10 }, maxRotation: 0 }
      },
      y: {
        min: 0, max: 100,
        grid: { color: 'rgba(255,255,255,0.04)', drawBorder: false },
        ticks: { color: '#6b7280', font: { size: 10 }, callback: function(v) { return v + '%'; } }
      }
    },
    interaction: { mode: 'nearest', axis: 'x', intersect: false }
  };

  function initCharts(history) {
    var chron = history.slice().reverse();
    var data144 = chron.slice(-144);
    var labels   = data144.map(function(e) { return e.date.slice(5, 16); });
    var cpuData  = data144.map(function(e) { return e.cpu; });
    var memData  = data144.map(function(e) { return e.memPct; });

    if (cpuChart) {
      cpuChart.data.labels = labels;
      cpuChart.data.datasets[0].data = cpuData;
      cpuChart.update('none');
    } else {
      cpuChart = new Chart(document.getElementById('cpuChart'), {
        type: 'line',
        data: {
          labels: labels,
          datasets: [{
            label: 'CPU %',
            data: cpuData,
            borderColor: '#f59e0b',
            backgroundColor: 'rgba(245,158,11,0.07)',
            borderWidth: 1.5,
            pointRadius: 1.5,
            pointHoverRadius: 4,
            tension: 0.3,
            fill: true
          }]
        },
        options: chartBaseOptions
      });
    }

    if (memChart) {
      memChart.data.labels = labels;
      memChart.data.datasets[0].data = memData;
      memChart.update('none');
    } else {
      memChart = new Chart(document.getElementById('memChart'), {
        type: 'line',
        data: {
          labels: labels,
          datasets: [{
            label: 'MEM %',
            data: memData,
            borderColor: '#60a5fa',
            backgroundColor: 'rgba(96,165,250,0.07)',
            borderWidth: 1.5,
            pointRadius: 1.5,
            pointHoverRadius: 4,
            tension: 0.3,
            fill: true
          }]
        },
        options: chartBaseOptions
      });
    }
  }

  // ── Countdown ─────────────────────────────────────────────────────────────

  function startCountdown() {
    countdownSec = 600;
    if (countdownInterval) clearInterval(countdownInterval);
    countdownInterval = setInterval(function() {
      countdownSec--;
      var m = Math.floor(countdownSec / 60);
      var s = countdownSec % 60;
      var el = document.getElementById('countdown');
      if (el) el.textContent = m + '분 ' + (s < 10 ? '0' : '') + s + '초';
      if (countdownSec <= 0) refresh();
    }, 1000);
  }

  // ── Log Toggle ────────────────────────────────────────────────────────────

  function toggleLog() {
    var section = document.getElementById('logSection');
    var toggle  = document.getElementById('logToggle');
    if (section.style.display === 'none') {
      section.style.display = '';
      toggle.textContent = '▼';
    } else {
      section.style.display = 'none';
      toggle.textContent = '▶';
    }
  }

  // ── Main Refresh ──────────────────────────────────────────────────────────

  function refresh() {
    var t = '?t=' + Date.now();
    Promise.all([
      fetch('data.html' + t).then(function(r) { return r.text(); }),
      fetch('dockerstats.html' + t).then(function(r) { return r.text(); })
    ]).then(function(results) {
      var history    = parseDataHtml(results[0]);
      var containers = parseDockerHtml(results[1]);
      if (history.length) {
        renderStats(history[0]);
        renderLog(history);
        initCharts(history);
      }
      renderDocker(containers);
      startCountdown();
    }).catch(function(err) {
      console.error('Refresh error:', err);
      var el = document.getElementById('lastUpdate');
      if (el) el.textContent = 'Error - ' + new Date().toLocaleTimeString();
    });
  }

  refresh();
</script>
</body>
</html>
