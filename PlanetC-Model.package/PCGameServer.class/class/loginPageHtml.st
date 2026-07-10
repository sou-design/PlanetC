as yet unclassified
loginPageHtml
	^ '<!doctype html><html lang="en"><meta charset="utf-8" /><meta name="viewport" content="width=device-width,initial-scale=1" /><title>PlanetC Player</title><style>
  body { font-family: system-ui, sans-serif; max-width: 420px; margin: 4rem auto; padding: 0 1rem }
  h1 { font-size: 1.2rem }
  form { display: flex; gap: .5rem; margin-bottom: 1rem }
  input[type=text] { flex: 1; padding: .6rem .8rem; font-size: 1rem }
  button { padding: .6rem 1rem; font-size: 1rem; cursor: pointer }
  .grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 6px; margin: 1rem 0 }
  .cell {
    aspect-ratio: 1; border: 1px solid #999; border-radius: 6px;
    cursor: default; user-select: none; background: #f6f6f6;
    position: relative;
    display: flex; align-items: center; justify-content: center;
  }
  .cell.dragover { outline: 3px dashed #333; outline-offset: -3px }
  .bird-dot {
    position: absolute; top: 4px; right: 4px;
    width: 8px; height: 8px; border-radius: 50%;
    background: #333;
  }
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
  .harvester-dot {
    width: 22px; height: 22px; border-radius: 50%;
    border: 2px solid rgba(0,0,0,.3);
    display: flex; align-items: center; justify-content: center;
    font-size: .65rem; color: #fff; font-weight: bold;
    cursor: pointer;
  }
  .hidden { display: none }
  .error { color: #b00020; margin-top: .75rem }
  .ok { color: #006400; margin-top: .75rem }
  #sendBtn { width: 100%; padding: .8rem; font-size: 1rem; margin-top: .5rem }
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
  <p id="instructions">Drag your harvesters onto the grid, then send.</p>
  <div class="harvester-tray" id="tray"></div>
  <div class="grid" id="grid"></div>
  <button id="sendBtn">Move harvesters</button>
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
  const COLUMNS = 5;
  const ROWS = 4;
  const TOTAL_CELLS = COLUMNS * ROWS;
  const HARVESTER_COLORS = [''#e63946'', ''#1d3557'', ''#2a9d8f'', ''#f4a261''];

  let myRole = null;
  const harvesterPlacement = [null, null, null, null];

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
    return myRole === ''Household'';
  }

  function applyRolePermissions() {
    if (!canMoveHarvesters()) {
      sendBtn.style.display = ''none'';
      trayEl.style.display = ''none'';
      instructions.textContent = ''You can watch the grid, but only Household players can move harvesters.'';
    } else {
      sendBtn.style.display = '''';
      trayEl.style.display = '''';
      instructions.textContent = ''Drag your harvesters onto the grid, then send.'';
    }
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
    dot.addEventListener(''click'', () => {
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
    values.forEach((count, i) => {
      const id = i + 1;
      const cell = cellEls[id];
      if (!cell) return;
      let dot = cell.querySelector(''.bird-dot'');
      if (count > 0) {
        if (!dot) {
          dot = document.createElement(''div'');
          dot.className = ''bird-dot'';
          cell.appendChild(dot);
        }
      } else if (dot) {
        dot.remove();
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

  byId(''loginForm'').addEventListener(''submit'', (e) => {
    e.preventDefault();
    const name = nameInput.value.trim();
    if (!name) { show(''error'', ''Please enter a name''); return; }

    const proto = location.protocol === ''https:'' ? ''wss'' : ''ws'';
    const url = `${proto}://${location.host}/ws`;
    ws = new WebSocket(url);

    ws.addEventListener(''open'', () => {
      ws.send(JSON.stringify({ type: ''bonjour'', name: name }));

      const heartbeat = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ type: ''ping'' }));
        } else {
          clearInterval(heartbeat);
        }
      }, 15000);
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
          applyRolePermissions();
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

    ws.addEventListener(''close'', () => addLog(''DISCONNECTED''));
    ws.addEventListener(''error'', () => show(''error'', ''Connection error''));
  });

  sendBtn.addEventListener(''click'', () => {
    if (!canMoveHarvesters()) {
      show(''error'', ''Only Household players can move harvesters'');
      return;
    }
    if (!ws || ws.readyState !== WebSocket.OPEN) {
      show(''error'', ''Not connected'');
      return;
    }
    const payload = { type: ''move'', harvesterCells: harvesterPlacement.slice() };
    ws.send(JSON.stringify(payload));
    addLog(''>> '' + JSON.stringify(payload));
  });
</script>
</html>'