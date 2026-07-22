as yet unclassified
loginPageHtml
	^ '<!doctype html><html lang="en"><meta charset="utf-8" /><meta name="viewport" content="width=device-width,initial-scale=1" /><title>PlanetC Player</title><style>
  body { font-family: system-ui, sans-serif; max-width: 420px; margin: 4rem auto; padding: 0 1rem }
  h1 { font-size: 1.2rem }
  form { display: flex; gap: .5rem; margin-bottom: 1rem }
  input[type=text] { flex: 1; padding: .6rem .8rem; font-size: 1rem }
  button { padding: .6rem 1rem; font-size: 1rem; cursor: pointer }
  button:disabled { opacity: .5; cursor: not-allowed }
  .grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 6px; margin: 1rem 0 }
  .cell {
    aspect-ratio: 1; border: 1px solid #999; border-radius: 6px;
    cursor: default; user-select: none; background: #f6f6f6;
    position: relative;
    display: flex; align-items: center; justify-content: center;
  }
  .cell.dragover { outline: 3px dashed #333; outline-offset: -3px }
  .cell.protect-selected { outline: 3px solid #b00020; outline-offset: -3px }
  .cell.protectable { cursor: pointer }
  .bird-badge, .newborn-badge {
    position: absolute;
    width: 16px; height: 16px; border-radius: 50%;
    font-size: 9px; color: #fff; font-weight: bold;
    display: flex; align-items: center; justify-content: center;
  }
  .bird-badge { top: 2px; right: 2px; background: #333; }
  .newborn-badge { top: 2px; left: 2px; background: #f4a261; }
  .harvester-tray {
    display: flex; gap: 10px; margin: .75rem 0;
    min-height: 40px; align-items: center;
  }
  .harvester-token {
    width: 28px; height: 28px; border-radius: 50%;
    cursor: grab; border: 2px solid rgba(0,0,0,.3);
    display: flex; align-items: center; justify-content: center;
    font-size: .7rem; color: #fff; font-weight: bold;
  }
  .harvester-token:active { cursor: grabbing }
  .harvester-token.placed { opacity: .35 }
  .harvester-token.locked { cursor: not-allowed; opacity: .35 }
  .harvester-dot {
    width: 22px; height: 22px; border-radius: 50%;
    border: 2px solid rgba(0,0,0,.3);
    display: flex; align-items: center; justify-content: center;
    font-size: .65rem; color: #fff; font-weight: bold;
    cursor: grab;
  }
  .harvester-dot:active { cursor: grabbing }
  .harvester-dot.locked { cursor: not-allowed }
  .hidden { display: none }
  .error { color: #b00020; margin-top: .75rem }
  .ok { color: #006400; margin-top: .75rem }
  .status { font-size: .85rem; color: #555; margin-top: .5rem }
  #sendBtn, #protectBtn { width: 100%; padding: .8rem; font-size: 1rem; margin-top: .5rem }
  pre { background: #f6f6f6; padding: .75rem; overflow: auto; max-height: 160px }
</style>

<div id="login">
  <h1>Choose your name to join</h1>
  <form id="loginForm">
    <input id="name" type="text" placeholder="e.g. alice" required minlength="2" maxlength="24" />
    <button type="submit">Join</button>
  </form>
  <div id="msg"></div>
</div>

<div id="game" class="hidden">
  <p id="instructions">Waiting for the round to begin...</p>
  <div class="harvester-tray hidden" id="tray"></div>
  <div class="grid" id="grid"></div>
  <button id="sendBtn" class="hidden">Move harvesters</button>
  <button id="protectBtn" class="hidden">Protect zones</button>
  <p class="status" id="statusLine"></p>
  <p class="status" id="countdownLine"></p>
</div>

<pre id="log" hidden></pre>

<script>
  const byId = id => document.getElementById(id);
  const nameInput = byId(''name'');
  const msg = byId(''msg'');
  const log = byId(''log'');
  const loginEl = byId(''login'');
  const gameEl = byId(''game'');
  const gridEl = byId(''grid'');
  const trayEl = byId(''tray'');
  const instructions = byId(''instructions'');
  const sendBtn = byId(''sendBtn'');
  const protectBtn = byId(''protectBtn'');
  const statusLine = byId(''statusLine'');
  const countdownLine = byId(''countdownLine'');
  const COLUMNS = 5;
  const ROWS = 4;
  const TOTAL_CELLS = COLUMNS * ROWS;
  const HARVESTER_COLORS = [''#e63946'', ''#1d3557'', ''#2a9d8f'', ''#f4a261''];
  const MAX_PROTECTED_ZONES = 3;
  const PHASE_DURATION_MS = 120000;

  let myRole = null;
  let locked = false;
  let currentPhase = null;
  let currentRound = null;
  let reconnectAttempts = 0;
  let myName = null;
  let countdownInterval = null;
  let phaseDeadline = null;
  const harvesterPlacement = [null, null, null, null];
  const protectedZones = new Set();

  nameInput.value = localStorage.getItem(''cm.name'') || '''';

  function show(kind, text) {
    msg.className = kind;
    msg.textContent = text;
  }

  function addLog(x) {
    log.hidden = false;
    log.textContent += x + "\n";
    log.scrollTop = log.scrollHeight;
  }

  function showGame() {
    loginEl.classList.add(''hidden'');
    gameEl.classList.remove(''hidden'');
  }

  function canMoveHarvesters() {
    return myRole === ''Household'' && currentPhase === 3 && !locked;
  }

  function canProtectZones() {
    return myRole === ''Ranger'' && currentPhase === 2 && !locked;
  }

  function resetRoundSelections() {
    harvesterPlacement.fill(null);
    document.querySelectorAll(''.harvester-dot'').forEach(d => d.remove());
    trayTokens.forEach(t => t.classList.remove(''placed''));

    protectedZones.clear();
    Object.values(cellEls).forEach(c => c.classList.remove(''protect-selected''));
  }

  function startCountdown() {
    if (countdownInterval) clearInterval(countdownInterval);
    phaseDeadline = Date.now() + PHASE_DURATION_MS;
    updateCountdownDisplay();
    countdownInterval = setInterval(updateCountdownDisplay, 1000);
  }

  function updateCountdownDisplay() {
    const remaining = Math.max(0, Math.round((phaseDeadline - Date.now()) / 1000));
    const mins = Math.floor(remaining / 60);
    const secs = remaining % 60;
    countdownLine.textContent = ''Time left: '' + mins + '':'' + String(secs).padStart(2, ''0'');
    if (remaining <= 0) clearInterval(countdownInterval);
  }

  function updateActionVisibility() {
    statusLine.textContent = currentRound != null
      ? ''Round '' + currentRound + '' - Phase '' + currentPhase
      : '''';

    if (myRole === ''Household'') {
      trayEl.classList.toggle(''hidden'', currentPhase !== 3);
      sendBtn.classList.toggle(''hidden'', currentPhase !== 3);
      protectBtn.classList.add(''hidden'');
      Object.values(cellEls).forEach(c => c.classList.remove(''protectable''));
      if (currentPhase === 3) {
        instructions.textContent = ''Drag your harvesters onto the grid, then send.'';
      } else if (currentPhase === 2) {
        instructions.textContent = ''Waiting for the Ranger to protect zones...'';
      } else {
        instructions.textContent = ''Waiting for the round to begin...'';
      }
    } else if (myRole === ''Ranger'') {
      sendBtn.classList.add(''hidden'');
      trayEl.classList.add(''hidden'');
      protectBtn.classList.toggle(''hidden'', currentPhase !== 2);
      Object.values(cellEls).forEach(c => c.classList.toggle(''protectable'', currentPhase === 2));
      if (currentPhase === 2) {
        instructions.textContent = ''Click up to '' + MAX_PROTECTED_ZONES + '' cells to protect, then send.'';
      } else if (currentPhase === 3) {
        instructions.textContent = ''Waiting for Households to move their harvesters...'';
      } else {
        instructions.textContent = ''Waiting for the round to begin...'';
      }
    } else {
      sendBtn.classList.add(''hidden'');
      trayEl.classList.add(''hidden'');
      protectBtn.classList.add(''hidden'');
      instructions.textContent = ''You can watch the grid, but you have no actions available.'';
    }
  }

  function lockHarvesters() {
    locked = true;
    sendBtn.disabled = true;
    protectBtn.disabled = true;
    trayTokens.forEach(t => { t.draggable = false; t.classList.add(''locked''); });
    document.querySelectorAll(''.harvester-dot'').forEach(d => d.classList.add(''locked''));
  }

  const trayTokens = [];
  for (let h = 0; h < 4; h++) {
    const token = document.createElement(''div'');
    token.className = ''harvester-token'';
    token.style.background = HARVESTER_COLORS[h];
    token.textContent = ''H'' + (h + 1);
    token.draggable = true;
    token.dataset.harvester = h;
    token.addEventListener(''dragstart'', (e) => {
      if (!canMoveHarvesters()) { e.preventDefault(); return; }
      e.dataTransfer.setData(''text/plain'', String(h));
    });
    trayEl.appendChild(token);
    trayTokens.push(token);
  }

  const BIOMASS_COLORS = [''#f6f6f6'', ''#c8e6c9'', ''#81c784'', ''#388e3c''];
  const cellEls = {};

  for (let id = 1; id <= TOTAL_CELLS; id++) {
    const cell = document.createElement(''div'');
    cell.className = ''cell'';
    cell.dataset.id = id;
    cell.style.background = BIOMASS_COLORS[0];

    cell.addEventListener(''click'', () => {
      if (!canProtectZones()) return;
      if (protectedZones.has(id)) {
        protectedZones.delete(id);
        cell.classList.remove(''protect-selected'');
      } else {
        if (protectedZones.size >= MAX_PROTECTED_ZONES) {
          show(''error'', ''You can only protect '' + MAX_PROTECTED_ZONES + '' zones'');
          return;
        }
        protectedZones.add(id);
        cell.classList.add(''protect-selected'');
      }
    });

    cell.addEventListener(''dragover'', (e) => {
      if (!canMoveHarvesters()) return;
      e.preventDefault();
      cell.classList.add(''dragover'');
    });
    cell.addEventListener(''dragleave'', () => cell.classList.remove(''dragover''));
    cell.addEventListener(''drop'', (e) => {
      e.preventDefault();
      cell.classList.remove(''dragover'');
      if (!canMoveHarvesters()) return;
      const h = Number(e.dataTransfer.getData(''text/plain''));
      placeHarvester(h, id);
    });

    gridEl.appendChild(cell);
    cellEls[id] = cell;
  }

  function placeHarvester(h, cellId) {
    removeHarvesterVisual(h);
    harvesterPlacement[h] = cellId;
    trayTokens[h].classList.add(''placed'');

    const dot = document.createElement(''div'');
    dot.className = ''harvester-dot'';
    dot.style.background = HARVESTER_COLORS[h];
    dot.textContent = ''H'' + (h + 1);
    dot.dataset.harvester = h;
    dot.draggable = true;
    dot.addEventListener(''dragstart'', (e) => {
      if (!canMoveHarvesters()) { e.preventDefault(); return; }
      e.dataTransfer.setData(''text/plain'', String(h));
    });
    dot.addEventListener(''click'', (e) => {
      e.stopPropagation();
      if (!canMoveHarvesters()) return;
      removeHarvesterVisual(h);
      harvesterPlacement[h] = null;
      trayTokens[h].classList.remove(''placed'');
    });
    cellEls[cellId].appendChild(dot);
  }

  function removeHarvesterVisual(h) {
    const previousCellId = harvesterPlacement[h];
    if (previousCellId != null) {
      const oldDot = cellEls[previousCellId].querySelector(`.harvester-dot[data-harvester="${h}"]`);
      if (oldDot) oldDot.remove();
    }
  }

  function applyBiomass(values) {
    values.forEach((v, i) => {
      const id = i + 1;
      const cell = cellEls[id];
      if (!cell) return;
      const level = Math.max(0, Math.min(3, Math.round(v)));
      cell.style.background = BIOMASS_COLORS[level];
    });
  }

  function applyBirds(values) {
    values.forEach((entry, i) => {
      const id = i + 1;
      const cell = cellEls[id];
      if (!cell) return;

      let adultBadge = cell.querySelector(''.bird-badge'');
      if (entry.adults > 0) {
        if (!adultBadge) {
          adultBadge = document.createElement(''div'');
          adultBadge.className = ''bird-badge'';
          cell.appendChild(adultBadge);
        }
        adultBadge.textContent = entry.adults;
      } else if (adultBadge) {
        adultBadge.remove();
      }

      let newbornBadge = cell.querySelector(''.newborn-badge'');
      if (entry.newborns > 0) {
        if (!newbornBadge) {
          newbornBadge = document.createElement(''div'');
          newbornBadge.className = ''newborn-badge'';
          cell.appendChild(newbornBadge);
        }
        newbornBadge.textContent = entry.newborns;
      } else if (newbornBadge) {
        newbornBadge.remove();
      }
    });
  }

  function parseServerMessage(raw) {
    let m = JSON.parse(raw);
    if (typeof m === ''string'') m = JSON.parse(m);
    return m;
  }

  function reasonOf(m) {
    return (m.payload && m.payload.reason) || m.reason || ''unknown'';
  }

  let ws = null;

  function connect(name) {
    myName = name;
    const proto = location.protocol === ''https:'' ? ''wss'' : ''ws'';
    ws = new WebSocket(`${proto}://${location.host}/ws`);

    ws.addEventListener(''open'', () => {
      reconnectAttempts = 0;
      ws.send(JSON.stringify({ type: ''bonjour'', name: name }));

      const heartbeat = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ type: ''ping'' }));
        } else {
          clearInterval(heartbeat);
        }
      }, 5000);
    });

    ws.addEventListener(''message'', (ev) => {
      try {
        const m = parseServerMessage(ev.data);

        if (m.type === ''registered'') {
          localStorage.setItem(''cm.name'', m.payload.name);
          show(''ok'', `Welcome, ${m.payload.name}! Waiting for the game to start...`);
          addLog(''REGISTERED as '' + m.payload.name);
        } else if (m.type === ''gameStarted'') {
          myRole = m.payload.role;
          show(''ok'', `Game started! Your role: ${m.payload.role}`);
          addLog(''GAME STARTED, role = '' + m.payload.role);
          showGame();
          updateActionVisibility();
        } else if (m.type === ''phase'') {
          currentRound = m.round;
          currentPhase = m.phase;
          if (currentPhase === 1) resetRoundSelections();
          locked = false;
          sendBtn.disabled = false;
          protectBtn.disabled = false;
          trayTokens.forEach(t => { t.draggable = true; t.classList.remove(''locked''); });
          document.querySelectorAll(''.harvester-dot'').forEach(d => d.classList.remove(''locked''));
          updateActionVisibility();
          startCountdown();
        } else if (m.type === ''biomass'') {
          applyBiomass(m.values);
        } else if (m.type === ''birds'') {
          applyBirds(m.values);
        } else if (m.type === ''rejected'' && reasonOf(m) === ''name-taken'') {
          show(''error'', ''This name is already taken. Choose another.'');
          ws.close();
        } else if (m.type === ''error'') {
          show(''error'', ''Error: '' + reasonOf(m));
        } else {
          addLog(''<< '' + ev.data);
        }
      } catch (err) {
        addLog(''<< '' + ev.data);
      }
    });

    ws.addEventListener(''close'', (e) => {
      addLog(''DISCONNECTED code='' + e.code + '' reason='' + e.reason);
      if (myName) {
        reconnectAttempts++;
        setTimeout(() => connect(myName), Math.min(2000 * reconnectAttempts, 10000));
      }
    });

    ws.addEventListener(''error'', () => show(''error'', ''Connection error''));
  }

  byId(''loginForm'').addEventListener(''submit'', (e) => {
    e.preventDefault();
    const name = nameInput.value.trim();
    if (!name) { show(''error'', ''Please enter a name''); return; }
    connect(name);
  });

  sendBtn.addEventListener(''click'', () => {
    if (!canMoveHarvesters()) {
      show(''error'', ''You can only move harvesters during your phase'');
      return;
    }
    if (!ws || ws.readyState !== WebSocket.OPEN) {
      show(''error'', ''Not connected'');
      return;
    }
    const payload = { type: ''move'', harvesterCells: harvesterPlacement.slice() };
    ws.send(JSON.stringify(payload));
    addLog(''>> '' + JSON.stringify(payload));
    lockHarvesters();
  });

  protectBtn.addEventListener(''click'', () => {
    if (!canProtectZones()) {
      show(''error'', ''You can only protect zones during your phase'');
      return;
    }
    if (!ws || ws.readyState !== WebSocket.OPEN) {
      show(''error'', ''Not connected'');
      return;
    }
    const payload = { type: ''protect'', cells: Array.from(protectedZones) };
    ws.send(JSON.stringify(payload));
    addLog(''>> '' + JSON.stringify(payload));
    lockHarvesters();
  });
</script>
</html>'