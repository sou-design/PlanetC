as yet unclassified
clientScript
	^ '/* Player page. Each round has two turns started by the game master: the Ranger (park manager)
   protects zones, then the Households move their harvesters. Round 1 has only the households turn.
   The server sends: round (a round begins), turn (a turn starts, with its time in seconds),
   turnEnded, roundEnded, roundResult (my own family gain) and gameOver. */
const gameEl = document.createElement("div");
gameEl.id = "game";
gameEl.className = "hidden";
gameEl.innerHTML = `
  <p id="instructions">Waiting for the round to begin...</p>
  <div class="harvester-tray hidden" id="tray"></div>
  <div class="grid" id="grid"></div>
  <div class="picker-backdrop hidden" id="pickerBackdrop">
    <div class="picker" id="picker" role="dialog" aria-modal="true">
      <p class="picker-title" id="pickerTitle"></p>
      <div class="picker-list" id="pickerList"></div>
      <button type="button" id="pickerDone">Done</button>
    </div>
  </div>
  <button id="sendBtn" class="hidden">Move harvesters</button>
  <button id="protectBtn" class="hidden">Protect zones</button>
  <p class="status" id="statusLine"></p>
  <p class="status" id="countdownLine"></p>
  <div id="resultCard" class="hidden" style="margin:1rem 0;padding:.8rem 1rem;border-radius:8px;background:#eef7ef;border:1px solid #b7dcbc;color:#1d4d27">
    <p id="resultGain" style="margin:0 0 .25rem;font-size:1.15rem;font-weight:600"></p>
    <p id="resultTotal" style="margin:0"></p>
  </div>
`;
document.body.appendChild(gameEl);

const byId = id => document.getElementById(id);
const nameInput = byId("name");
const msg = byId("msg");
const loginEl = byId("login");
const gridEl = byId("grid");
const trayEl = byId("tray");
const instructions = byId("instructions");
const sendBtn = byId("sendBtn");
const protectBtn = byId("protectBtn");
const statusLine = byId("statusLine");
const countdownLine = byId("countdownLine");
const pickerBackdrop = byId("pickerBackdrop");
const pickerTitle = byId("pickerTitle");
const pickerList = byId("pickerList");
const pickerDone = byId("pickerDone");
const resultCard = byId("resultCard");
const resultGain = byId("resultGain");
const resultTotal = byId("resultTotal");
let pickerCellId = null;

const COLUMNS = 5;
const ROWS = 4;
const TOTAL_CELLS = COLUMNS * ROWS;
const HOUSEHOLD_PALETTE = ["#1D9E75", "#D85A30", "#534AB7", "#378ADD", "#EF9F27", "#D4537E", "#639922", "#993C1D"];
const MAX_PROTECTED_ZONES = 3;

let myRole = null;
let locked = false;
let currentRound = null;
let currentTurn = null;   /* "ranger", "households", or null between turns */
let turnEndsAt = null;    /* time (ms) when the current turn ends */
let reconnectAttempts = 0;
let myName = null;
let countdownInterval = null;
let myTotal = null;       /* my family total harvest, from the last roundResult */
const harvesterPlacement = [null, null, null, null];
const protectedZones = new Set();
const householdColorCache = new Map();

nameInput.value = localStorage.getItem("cm.name") || "";

function colorForHousehold(name) {
  if (householdColorCache.has(name)) return householdColorCache.get(name);
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = (hash * 31 + name.charCodeAt(i)) >>> 0;
  }
  const color = HOUSEHOLD_PALETTE[hash % HOUSEHOLD_PALETTE.length];
  householdColorCache.set(name, color);
  return color;
}

function myColor() {
  return colorForHousehold(myName || "");
}

function updateTrayColors() {
  const color = myColor();
  trayTokens.forEach(t => t.style.background = color);
  document.querySelectorAll(".harvester-dot").forEach(d => d.style.background = color);
}

function show(kind, text) {
  msg.className = kind;
  msg.textContent = text;
}

function addLog(x) {
  console.log(x);
}

function showGame() {
  loginEl.classList.add("hidden");
  gameEl.classList.remove("hidden");
}

function canMoveHarvesters() {
  return myRole === "Household" && currentTurn === "households" && !locked;
}

function canProtectZones() {
  return myRole === "Ranger" && currentTurn === "ranger" && !locked;
}

function resetRoundSelections() {
  harvesterPlacement.fill(null);
  document.querySelectorAll(".harvester-dot").forEach(d => d.remove());
  trayTokens.forEach(t => t.classList.remove("placed"));
  protectedZones.clear();
  Object.values(cellEls).forEach(c => c.classList.remove("protect-selected"));
}

/* Countdown of the current turn, with the time chosen by the game master */
function startCountdown(seconds) {
  stopCountdown();
  turnEndsAt = Date.now() + seconds * 1000;
  updateCountdownDisplay();
  updateActionVisibility();
  countdownInterval = setInterval(() => {
    updateCountdownDisplay();
    updateActionVisibility();
  }, 1000);
}

function stopCountdown() {
  if (countdownInterval) clearInterval(countdownInterval);
  countdownInterval = null;
  turnEndsAt = null;
  countdownLine.textContent = "";
}

function updateCountdownDisplay() {
  if (turnEndsAt == null) {
    countdownLine.textContent = "";
    return;
  }
  const remaining = Math.max(0, Math.round((turnEndsAt - Date.now()) / 1000));
  const mins = Math.floor(remaining / 60);
  const secs = remaining % 60;
  countdownLine.textContent = "Time left: " + mins + ":" + String(secs).padStart(2, "0");
}

function updateActionVisibility() {
  statusLine.textContent = currentRound != null
    ? "Round " + currentRound + (currentTurn === "ranger" ? " - Ranger''s turn" : currentTurn === "households" ? " - Household''s turn" : "")
    : "";
  if (myRole === "Household") {
    const myTurn = currentTurn === "households";
    trayEl.classList.toggle("hidden", !myTurn || locked);
    sendBtn.classList.toggle("hidden", !myTurn || locked);
    protectBtn.classList.add("hidden");
    Object.values(cellEls).forEach(c => {
      c.classList.remove("protectable");
      c.classList.toggle("pickable", myTurn && !locked);
    });
    if (!myTurn || locked) closePicker();
    if (currentTurn === "ranger") instructions.textContent = "Waiting for the Ranger to protect zones...";
    else if (!myTurn) instructions.textContent = "Waiting for the game master to start the next turn...";
    else if (locked) instructions.textContent = "Waiting for the round to resolve...";
    else instructions.textContent = "Tap a cell to choose which harvesters go there, then send.";
  } else if (myRole === "Ranger") {
    const myTurn = currentTurn === "ranger";
    sendBtn.classList.add("hidden");
    trayEl.classList.add("hidden");
    protectBtn.classList.toggle("hidden", !myTurn || locked);
    Object.values(cellEls).forEach(c => c.classList.toggle("protectable", myTurn && !locked));
    if (currentTurn === "households") instructions.textContent = "Waiting for Households to move their harvesters...";
    else if (!myTurn) instructions.textContent = "Waiting for the game master to start the next turn...";
    else if (locked) instructions.textContent = "Waiting for Households to take their turn...";
    else instructions.textContent = "Click up to " + MAX_PROTECTED_ZONES + " cells to protect, then send.";
  } else {
    sendBtn.classList.add("hidden");
    trayEl.classList.add("hidden");
    protectBtn.classList.add("hidden");
    instructions.textContent = myRole === "GameMaster"
      ? "This name has the GameMaster role. In Cormas, give it the Household or Ranger role, then reload this page."
      : "You have no role in this game. Ask the game master to give you a role in Cormas, then reload this page.";
  }
}

function lockHarvesters() {
  locked = true;
  sendBtn.disabled = true;
  protectBtn.disabled = true;
  document.querySelectorAll(".harvester-dot").forEach(d => d.remove());
  trayTokens.forEach(t => t.classList.add("locked"));
  closePicker();
  updateActionVisibility();
}

const trayTokens = [];
for (let h = 0; h < 4; h++) {
  const token = document.createElement("div");
  token.className = "harvester-token";
  token.style.background = "#999999";
  token.textContent = "H" + (h + 1);
  token.dataset.harvester = h;
  trayEl.appendChild(token);
  trayTokens.push(token);
}

const BIOMASS_COLORS = ["#f6f6f6", "#c8e6c9", "#81c784", "#388e3c"];
const cellEls = {};
for (let id = 1; id <= TOTAL_CELLS; id++) {
  const cell = document.createElement("div");
  cell.className = "cell";
  cell.dataset.id = id;
  cell.style.background = BIOMASS_COLORS[0];
  cell.addEventListener("click", () => {
    if (canMoveHarvesters()) { openPicker(id); return; }
    if (!canProtectZones()) return;
    if (protectedZones.has(id)) {
      protectedZones.delete(id);
      cell.classList.remove("protect-selected");
    } else {
      if (protectedZones.size >= MAX_PROTECTED_ZONES) {
        show("error", "You can only protect " + MAX_PROTECTED_ZONES + " zones");
        return;
      }
      protectedZones.add(id);
      cell.classList.add("protect-selected");
    }
  });
  gridEl.appendChild(cell);
  cellEls[id] = cell;
}

function placeHarvester(h, cellId) {
  removeHarvesterVisual(h);
  harvesterPlacement[h] = cellId;
  trayTokens[h].classList.add("placed");
  const dot = document.createElement("div");
  dot.className = "harvester-dot";
  dot.style.background = myColor();
  dot.textContent = "H" + (h + 1);
  dot.dataset.harvester = h;
  cellEls[cellId].appendChild(dot);
}

function unplaceHarvester(h) {
  removeHarvesterVisual(h);
  harvesterPlacement[h] = null;
  trayTokens[h].classList.remove("placed");
}

function openPicker(cellId) {
  pickerCellId = cellId;
  renderPicker();
  pickerBackdrop.classList.remove("hidden");
}

function closePicker() {
  pickerCellId = null;
  pickerBackdrop.classList.add("hidden");
}

function renderPicker() {
  if (pickerCellId == null) return;
  pickerTitle.textContent = "Harvesters on cell " + pickerCellId;
  pickerList.innerHTML = "";
  harvesterPlacement.forEach((placedOn, h) => {
    const row = document.createElement("label");
    row.className = "picker-row";
    const box = document.createElement("input");
    box.type = "checkbox";
    box.checked = placedOn === pickerCellId;
    box.addEventListener("change", () => {
      if (!canMoveHarvesters()) { closePicker(); return; }
      if (box.checked) placeHarvester(h, pickerCellId);
      else unplaceHarvester(h);
      renderPicker();
    });
    const swatch = document.createElement("span");
    swatch.className = "picker-swatch";
    swatch.style.background = myColor();
    swatch.textContent = "H" + (h + 1);
    const where = document.createElement("span");
    where.className = "picker-where";
    where.textContent = placedOn == null ? "not placed"
      : placedOn === pickerCellId ? "here"
      : "on cell " + placedOn + " (will move)";
    row.appendChild(box);
    row.appendChild(swatch);
    row.appendChild(where);
    pickerList.appendChild(row);
  });
}

pickerDone.addEventListener("click", closePicker);
pickerBackdrop.addEventListener("click", (e) => {
  if (e.target === pickerBackdrop) closePicker();
});
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") closePicker();
});

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

function applyProtection(values) {
  values.forEach((isProtected, i) => {
    const id = i + 1;
    const cell = cellEls[id];
    if (!cell) return;
    cell.classList.toggle("protected-shared", isProtected);
  });
}

function applyHarvesters(values) {
  values.forEach((entries, i) => {
    const id = i + 1;
    const cell = cellEls[id];
    if (!cell) return;
    let container = cell.querySelector(".harvester-chips");
    if (entries && entries.length > 0) {
      if (!container) {
        container = document.createElement("div");
        container.className = "harvester-chips";
        cell.appendChild(container);
      }
      container.innerHTML = "";
      entries.forEach(entry => {
        const chip = document.createElement("div");
        chip.className = "harvester-chip";
        const swatch = document.createElement("span");
        swatch.className = "harvester-chip-swatch";
        swatch.style.background = colorForHousehold(entry.household);
        const countText = document.createElement("span");
        countText.className = "harvester-chip-count";
        countText.textContent = entry.count;
        chip.appendChild(swatch);
        chip.appendChild(countText);
        chip.title = entry.household + ": " + entry.count;
        container.appendChild(chip);
      });
    } else if (container) {
      container.remove();
    }
  });
}

function applyBirds(values) {
  values.forEach((entry, i) => {
    const id = i + 1;
    const cell = cellEls[id];
    if (!cell) return;
    let adultIcon = cell.querySelector(".bird-icon-plain");
    if (entry.adults > 0) {
      if (!adultIcon) {
        adultIcon = document.createElement("span");
        adultIcon.className = "bird-icon-plain icon-bird";
        cell.appendChild(adultIcon);
      }
    } else if (adultIcon) {
      adultIcon.remove();
    }
    let newbornChip = cell.querySelector(".newborn-chip");
    if (entry.newborns > 0) {
      if (!newbornChip) {
        newbornChip = document.createElement("div");
        newbornChip.className = "newborn-chip";
        cell.appendChild(newbornChip);
      }
      newbornChip.innerHTML = "<span class=\"bird-chip-icon icon-poussin\"></span><span>" + entry.newborns + "</span>";
    } else if (newbornChip) {
      newbornChip.remove();
    }
  });
}

function parseServerMessage(raw) {
  let m = JSON.parse(raw);
  if (typeof m === "string") m = JSON.parse(m);
  return m;
}

function reasonOf(m) {
  return (m.payload && m.payload.reason) || m.reason || "unknown";
}

/* Between turns, or when the round or the game is over: nobody can act */
function pauseTurns(status, text) {
  stopCountdown();
  currentTurn = null;
  closePicker();
  updateActionVisibility();
  if (status != null) statusLine.textContent = status;
  if (text != null) instructions.textContent = text;
}

let ws = null;
function connect(name) {
  myName = name;
  updateTrayColors();
  const proto = location.protocol === "https:" ? "wss" : "ws";
  ws = new WebSocket(`${proto}://${location.host}/ws`);
  ws.addEventListener("open", () => {
    reconnectAttempts = 0;
    ws.send(JSON.stringify({ type: "bonjour", name: name }));
    const heartbeat = setInterval(() => {
      if (ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ type: "ping" }));
      else clearInterval(heartbeat);
    }, 5000);
  });
  ws.addEventListener("message", (ev) => {
    try {
      const m = parseServerMessage(ev.data);
      if (m.type === "pong") {
        return;
      } else if (m.type === "registered") {
        localStorage.setItem("cm.name", m.payload.name);
        myName = m.payload.name;
        updateTrayColors();
        show("ok", `Welcome, ${m.payload.name}! Waiting for the game to start...`);
        addLog("REGISTERED as " + m.payload.name);
        /* A fresh page (reloaded during the game): ask the server to show the game again */
        if (myRole == null) ws.send(JSON.stringify({ type: "rejoin" }));
      } else if (m.type === "gameStarted") {
        myRole = m.payload.role;
        show("ok", `Game started! Your role: ${m.payload.role}`);
        addLog("GAME STARTED, role = " + m.payload.role);
        showGame();
        updateActionVisibility();
      } else if (m.type === "round") {
        /* A new round: clear last round, then wait for the game master to start the first turn */
        currentRound = m.round;
        resetRoundSelections();
        locked = false;
        sendBtn.disabled = false;
        protectBtn.disabled = false;
        trayTokens.forEach(t => t.classList.remove("locked"));
        document.querySelectorAll(".harvester-dot").forEach(d => d.classList.remove("locked"));
        pauseTurns();
      } else if (m.type === "turn") {
        /* A turn starts, with the time chosen by the game master */
        currentRound = m.round;
        currentTurn = m.turn;
        locked = false;
        sendBtn.disabled = false;
        protectBtn.disabled = false;
        trayTokens.forEach(t => t.classList.remove("locked"));
        startCountdown(m.seconds);
      } else if (m.type === "turnEnded") {
        pauseTurns();
      } else if (m.type === "roundEnded") {
        locked = true;
        pauseTurns("Round " + m.round + " is over", "Waiting for the game master to start the next round...");
      } else if (m.type === "roundResult") {
        /* Only my own family result: what my harvesters collected this round, and my total */
        myTotal = m.total;
        resultGain.textContent = "Round " + m.round + ": your family harvested " + m.gain;
        resultTotal.textContent = "Total since the start: " + m.total;
        resultCard.classList.remove("hidden");
      } else if (m.type === "gameOver") {
        locked = true;
        pauseTurns("Game over", myTotal != null
          ? "The game is over. Your family harvested " + myTotal + " in total. Thank you for playing!"
          : "The game is over. Thank you for playing!");
      } else if (m.type === "biomass") {
        applyBiomass(m.values);
      } else if (m.type === "birds") {
        applyBirds(m.values);
      } else if (m.type === "protection") {
        applyProtection(m.values);
      } else if (m.type === "harvesters") {
        applyHarvesters(m.values);
      } else if (m.type === "rejected" && reasonOf(m) === "name-taken") {
        show("error", "This name is already taken. Choose another.");
        ws.close();
      } else if (m.type === "error") {
        show("error", "Error: " + reasonOf(m));
      } else {
        addLog("<< " + ev.data);
      }
    } catch (err) {
      addLog("<< " + ev.data);
    }
  });
  ws.addEventListener("close", (e) => {
    addLog("DISCONNECTED code=" + e.code + " reason=" + e.reason);
    if (myName) {
      reconnectAttempts++;
      setTimeout(() => connect(myName), Math.min(2000 * reconnectAttempts, 10000));
    }
  });
  ws.addEventListener("error", () => show("error", "Connection error"));
}

byId("login").addEventListener("submit", (e) => {
  e.preventDefault();
  const name = nameInput.value.trim();
  if (!name) {
    show("error", "Please enter a name");
    return;
  }
  connect(name);
});

sendBtn.addEventListener("click", () => {
  if (!canMoveHarvesters()) {
    show("error", "You can only move harvesters during the Household turn");
    return;
  }
  if (!ws || ws.readyState !== WebSocket.OPEN) {
    show("error", "Not connected");
    return;
  }
  const payload = { type: "move", harvesterCells: harvesterPlacement.slice() };
  ws.send(JSON.stringify(payload));
  addLog(">> " + JSON.stringify(payload));
  lockHarvesters();
});

protectBtn.addEventListener("click", () => {
  if (!canProtectZones()) {
    show("error", "You can only protect zones during the Ranger turn");
    return;
  }
  if (!ws || ws.readyState !== WebSocket.OPEN) {
    show("error", "Not connected");
    return;
  }
  const payload = { type: "protect", cells: Array.from(protectedZones) };
  ws.send(JSON.stringify(payload));
  addLog(">> " + JSON.stringify(payload));
  lockHarvesters();
});'