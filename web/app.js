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
  <div id="resultCard" class="hidden">
    <p id="resultGain"></p>
    <p id="resultTotal"></p>
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
const HARVESTERS = 4;

let myRole = null;
let locked = false;
let currentRound = null;
let currentTurn = null;
let turnEndsAt = null;
let reconnectAttempts = 0;
let myName = null;
let countdownInterval = null;
let myTotal = null;
const harvesterPlacement = new Array(HARVESTERS).fill(null);
const protectedZones = new Set();

nameInput.value = localStorage.getItem("cm.name") || "";

function colorForHousehold(name) {
  let hash = 0;
  for (let i = 0; i < name.length; i++) hash = (hash * 31 + name.charCodeAt(i)) >>> 0;
  return HOUSEHOLD_PALETTE[hash % HOUSEHOLD_PALETTE.length];
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
    ? "Round " + currentRound + (currentTurn === "ranger" ? " - Ranger's turn" : currentTurn === "households" ? " - Household's turn" : "")
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
for (let h = 0; h < HARVESTERS; h++) {
  const token = document.createElement("div");
  token.className = "harvester-token";
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

function forEachCell(values, action) {
  values.forEach((value, i) => {
    const cell = cellEls[i + 1];
    if (cell) action(cell, value);
  });
}

function applyBiomass(values) {
  forEachCell(values, (cell, v) => {
    const level = Math.max(0, Math.min(3, Math.round(v)));
    cell.style.background = BIOMASS_COLORS[level];
  });
}

function applyProtection(values) {
  forEachCell(values, (cell, isProtected) => cell.classList.toggle("protected-shared", isProtected));
}

function applyHarvesters(values) {
  forEachCell(values, (cell, entries) => {
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
  forEachCell(values, (cell, entry) => {
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

function pauseTurns(status, text) {
  stopCountdown();
  currentTurn = null;
  closePicker();
  updateActionVisibility();
  if (status != null) statusLine.textContent = status;
  if (text != null) instructions.textContent = text;
}

const handlers = {
  registered(m) {
    localStorage.setItem("cm.name", m.payload.name);
    myName = m.payload.name;
    updateTrayColors();
    show("ok", `Welcome, ${m.payload.name}! Waiting for the game to start...`);
  },
  gameStarted(m) {
    myRole = m.payload.role;
    show("ok", `Game started! Your role: ${m.payload.role}`);
    showGame();
    updateActionVisibility();
  },
  round(m) {

    currentRound = m.round;
    resetRoundSelections();
    unlock();
    document.querySelectorAll(".harvester-dot").forEach(d => d.classList.remove("locked"));
    pauseTurns();
  },
  turn(m) {

    currentRound = m.round;
    currentTurn = m.turn;
    unlock();
    startCountdown(m.seconds);
  },
  turnEnded() {
    pauseTurns();
  },
  roundEnded(m) {
    locked = true;
    pauseTurns("Round " + m.round + " is over", "Waiting for the game master to start the next round...");
  },
  roundResult(m) {

    myTotal = m.total;
    resultGain.textContent = "Round " + m.round + ": your family harvested " + m.gain;
    resultTotal.textContent = "Total since the start: " + m.total;
    resultCard.classList.remove("hidden");
  },
  gameOver() {
    locked = true;
    pauseTurns("Game over", myTotal != null
      ? "The game is over. Your family harvested " + myTotal + " in total. Thank you for playing!"
      : "The game is over. Thank you for playing!");
  },
  biomass(m) { applyBiomass(m.values); },
  birds(m) { applyBirds(m.values); },
  protection(m) { applyProtection(m.values); },
  harvesters(m) { applyHarvesters(m.values); },
  rejected(m) {
    if (reasonOf(m) !== "name-taken") return;
    show("error", "This name is already taken. Choose another.");
    ws.close();
  },
  error(m) { show("error", "Error: " + reasonOf(m)); }
};

function unlock() {
  locked = false;
  sendBtn.disabled = false;
  protectBtn.disabled = false;
  trayTokens.forEach(t => t.classList.remove("locked"));
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
    let m;
    try { m = parseServerMessage(ev.data); } catch (e) { return; }
    const handler = m && handlers[m.type];
    if (handler) handler(m);
  });
  ws.addEventListener("close", () => {
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

function sendAction(allowed, notAllowedText, payload) {
  if (!allowed) return show("error", notAllowedText);
  if (!ws || ws.readyState !== WebSocket.OPEN) return show("error", "Not connected");
  ws.send(JSON.stringify(payload));
  lockHarvesters();
}

sendBtn.addEventListener("click", () => sendAction(canMoveHarvesters(),
  "You can only move harvesters during the Household turn",
  { type: "move", harvesterCells: harvesterPlacement.slice() }));

protectBtn.addEventListener("click", () => sendAction(canProtectZones(),
  "You can only protect zones during the Ranger turn",
  { type: "protect", cells: Array.from(protectedZones) }));
