as yet unclassified
clientScript
	^ 'const gameEl = document.createElement("div");
gameEl.id = "game";
gameEl.className = "hidden";
gameEl.innerHTML = `
  <p id="instructions">Waiting for the round to begin...</p>
  <div class="harvester-tray hidden" id="tray"></div>
  <div class="grid" id="grid"></div>
  <button id="sendBtn" class="hidden">Move harvesters</button>
  <button id="protectBtn" class="hidden">Protect zones</button>
  <p class="status" id="statusLine"></p>
  <p class="status" id="countdownLine"></p>
`;
document.body.appendChild(gameEl);

const byId = id => document.getElementById(id);
const nameInput = byId("name");
const msg = byId("msg");
const log = byId("log");
const loginEl = byId("login");
const gridEl = byId("grid");
const trayEl = byId("tray");
const instructions = byId("instructions");
const sendBtn = byId("sendBtn");
const protectBtn = byId("protectBtn");
const statusLine = byId("statusLine");
const countdownLine = byId("countdownLine");

const COLUMNS = 5;
const ROWS = 4;
const TOTAL_CELLS = COLUMNS * ROWS;
const HOUSEHOLD_PALETTE = ["#1D9E75", "#D85A30", "#534AB7", "#378ADD", "#EF9F27", "#D4537E", "#639922", "#993C1D"];
const MAX_PROTECTED_ZONES = 3;
const RANGER_WINDOW_MS = 10000;
const HOUSEHOLD_WINDOW_MS = 120000;

let myRole = null;
let locked = false;
let currentRound = null;
let reconnectAttempts = 0;
let myName = null;
let countdownInterval = null;
let roundStartTime = null;
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
  log.hidden = false;
  log.textContent += x + "\n";
  log.scrollTop = log.scrollHeight;
}

function showGame() {
  loginEl.classList.add("hidden");
  gameEl.classList.remove("hidden");
}

function rangerWindowOpen() {
  return roundStartTime != null && (Date.now() - roundStartTime) < RANGER_WINDOW_MS;
}

function canMoveHarvesters() {
  return myRole === "Household" && roundStartTime != null && !rangerWindowOpen() && !locked;
}

function canProtectZones() {
  return myRole === "Ranger" && rangerWindowOpen() && !locked;
}

function resetRoundSelections() {
  harvesterPlacement.fill(null);
  document.querySelectorAll(".harvester-dot").forEach(d => d.remove());
  trayTokens.forEach(t => t.classList.remove("placed"));
  protectedZones.clear();
  Object.values(cellEls).forEach(c => c.classList.remove("protect-selected"));
}

function startCountdown() {
  if (countdownInterval) clearInterval(countdownInterval);
  roundStartTime = Date.now();
  updateCountdownDisplay();
  updateActionVisibility();
  countdownInterval = setInterval(() => {
    updateCountdownDisplay();
    updateActionVisibility();
  }, 1000);
}

function updateCountdownDisplay() {
  const elapsed = Date.now() - roundStartTime;
  const remainingMs = rangerWindowOpen()
    ? RANGER_WINDOW_MS - elapsed
    : (RANGER_WINDOW_MS + HOUSEHOLD_WINDOW_MS) - elapsed;
  const remaining = Math.max(0, Math.round(remainingMs / 1000));
  const mins = Math.floor(remaining / 60);
  const secs = remaining % 60;
  countdownLine.textContent = "Time left: " + mins + ":" + String(secs).padStart(2, "0");
}

function updateActionVisibility() {
  statusLine.textContent = currentRound != null
    ? "Round " + currentRound + (rangerWindowOpen() ? " - Ranger''s turn" : " - Household''s turn")
    : "";

  if (myRole === "Household") {
    const myTurn = !rangerWindowOpen();
    trayEl.classList.toggle("hidden", !myTurn || locked);
    sendBtn.classList.toggle("hidden", !myTurn || locked);
    protectBtn.classList.add("hidden");
    Object.values(cellEls).forEach(c => c.classList.remove("protectable"));

    if (!myTurn) instructions.textContent = "Waiting for the Ranger to protect zones...";
    else if (locked) instructions.textContent = "Waiting for the round to resolve...";
    else instructions.textContent = "Drag your harvesters onto the grid, then send.";

  } else if (myRole === "Ranger") {
    const myTurn = rangerWindowOpen();
    sendBtn.classList.add("hidden");
    trayEl.classList.add("hidden");
    protectBtn.classList.toggle("hidden", !myTurn || locked);
    Object.values(cellEls).forEach(c => c.classList.toggle("protectable", myTurn && !locked));

    if (!myTurn) instructions.textContent = "Waiting for Households to move their harvesters...";
    else if (locked) instructions.textContent = "Waiting for Households to take their turn...";
    else instructions.textContent = "Click up to " + MAX_PROTECTED_ZONES + " cells to protect, then send.";

  } else {
    sendBtn.classList.add("hidden");
    trayEl.classList.add("hidden");
    protectBtn.classList.add("hidden");
    instructions.textContent = "You can watch the grid, but you have no actions available.";
  }
}

function lockHarvesters() {
  locked = true;
  sendBtn.disabled = true;
  protectBtn.disabled = true;
  document.querySelectorAll(".harvester-dot").forEach(d => d.remove());
  trayTokens.forEach(t => { t.draggable = false; t.classList.add("locked"); });
  updateActionVisibility();
}

const trayTokens = [];
for (let h = 0; h < 4; h++) {
  const token = document.createElement("div");
  token.className = "harvester-token";
  token.style.background = "#999999";
  token.textContent = "H" + (h + 1);
  token.draggable = true;
  token.dataset.harvester = h;

  token.addEventListener("dragstart", (e) => {
    if (!canMoveHarvesters()) { e.preventDefault(); return; }
    e.dataTransfer.setData("text/plain", String(h));
  });

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

  cell.addEventListener("dragover", (e) => {
    if (!canMoveHarvesters()) return;
    e.preventDefault();
    cell.classList.add("dragover");
  });

  cell.addEventListener("dragleave", () => cell.classList.remove("dragover"));

  cell.addEventListener("drop", (e) => {
    e.preventDefault();
    cell.classList.remove("dragover");
    if (!canMoveHarvesters()) return;
    const h = Number(e.dataTransfer.getData("text/plain"));
    placeHarvester(h, id);
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
  dot.draggable = true;

  dot.addEventListener("dragstart", (e) => {
    if (!canMoveHarvesters()) { e.preventDefault(); return; }
    e.dataTransfer.setData("text/plain", String(h));
  });

  dot.addEventListener("click", (e) => {
    e.stopPropagation();
    if (!canMoveHarvesters()) return;
    removeHarvesterVisual(h);
    harvesterPlacement[h] = null;
    trayTokens[h].classList.remove("placed");
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

      if (m.type === "registered") {
        localStorage.setItem("cm.name", m.payload.name);
        myName = m.payload.name;
        updateTrayColors();
        show("ok", `Welcome, ${m.payload.name}! Waiting for the game to start...`);
        addLog("REGISTERED as " + m.payload.name);

      } else if (m.type === "gameStarted") {
        myRole = m.payload.role;
        show("ok", `Game started! Your role: ${m.payload.role}`);
        addLog("GAME STARTED, role = " + m.payload.role);
        showGame();
        updateActionVisibility();

      } else if (m.type === "round") {
        currentRound = m.round;
        resetRoundSelections();
        locked = false;
        sendBtn.disabled = false;
        protectBtn.disabled = false;
        trayTokens.forEach(t => { t.draggable = true; t.classList.remove("locked"); });
        document.querySelectorAll(".harvester-dot").forEach(d => d.classList.remove("locked"));
        startCountdown();

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
});
'