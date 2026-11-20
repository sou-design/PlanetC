const gameEl = document.createElement("div");
gameEl.id = "game";
gameEl.className = "hidden";
gameEl.innerHTML = `
  <p id="roleLine"></p>
  <p id="instructions">Waiting for the round to begin...</p>
  <div class="board">
    <span></span>
    <div class="board-cols"><span>A</span><span>B</span><span>C</span><span>D</span><span>E</span></div>
    <div class="board-rows"><span>1</span><span>2</span><span>3</span><span>4</span></div>
    <div class="grid" id="grid"></div>
  </div>
  <div class="picker-backdrop hidden" id="pickerBackdrop">
    <div class="picker" id="picker" role="dialog" aria-modal="true">
      <p class="picker-title" id="pickerTitle"></p>
      <p class="picker-help" id="pickerHelp"></p>
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
    <div id="memberScroll" class="hidden"><table id="memberTable"></table></div>
  </div>
  <div id="finalResults" class="hidden"></div>
  <div id="playerCharts" class="hidden"></div>
`;
document.body.appendChild(gameEl);

const byId = id => document.getElementById(id);
const nameInput = byId("name");
const msg = byId("msg");
const joinTitle = byId("joinTitle");
const roleLine = byId("roleLine");
const loginEl = byId("login");
const gridEl = byId("grid");
const instructions = byId("instructions");
const sendBtn = byId("sendBtn");
const protectBtn = byId("protectBtn");
const statusLine = byId("statusLine");
const countdownLine = byId("countdownLine");
const pickerBackdrop = byId("pickerBackdrop");
const pickerTitle = byId("pickerTitle");
const pickerHelp = byId("pickerHelp");
const pickerList = byId("pickerList");
const pickerDone = byId("pickerDone");
const resultCard = byId("resultCard");
const resultGain = byId("resultGain");
const resultTotal = byId("resultTotal");
const memberScroll = byId("memberScroll");
const memberTable = byId("memberTable");
const finalResults = byId("finalResults");
const playerChartsEl = byId("playerCharts");
let playerCharts = null;
let pickerCellId = null;

function cellName(id) {
  return "ABCDE"[(id - 1) % 5] + (Math.floor((id - 1) / 5) + 1);
}

const COLUMNS = 5;
const ROWS = 4;
const TOTAL_CELLS = COLUMNS * ROWS;
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
const harvesterPlacement = new Array(HARVESTERS).fill(null);
const protectedZones = new Set();


function colorForHousehold(name) {
  return name === myName ? "#2a78d6" : "#000000";
}

function myColor() {
  return colorForHousehold(myName || "");
}

function updateTrayColors() {
  document.querySelectorAll(".harvester-dot").forEach(d => d.style.background = myColor());
}

let msgTimer = null;
function show(kind, text) {
  clearTimeout(msgTimer);
  msg.className = kind;
  msg.textContent = text;
  if (myRole) msgTimer = setTimeout(() => { msg.textContent = ""; }, 4000);
}

function showGame() {
  joinTitle.classList.add("hidden");
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
    protectBtn.classList.toggle("hidden", !myTurn || locked);
    Object.values(cellEls).forEach(c => c.classList.toggle("protectable", myTurn && !locked));
    if (currentTurn === "households") instructions.textContent = "Waiting for Households to move their harvesters...";
    else if (!myTurn) instructions.textContent = "Waiting for the game master to start the next turn...";
    else if (locked) instructions.textContent = "Waiting for Households to take their turn...";
    else instructions.textContent = "Click up to " + MAX_PROTECTED_ZONES + " cells to protect, then send.";
  } else {
    sendBtn.classList.add("hidden");
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
  closePicker();
  updateActionVisibility();
}

function setHarvesterCount(count) {
  if (!count || count === harvesterPlacement.length) return;
  document.querySelectorAll(".harvester-dot").forEach(d => d.remove());
  harvesterPlacement.length = count;
  harvesterPlacement.fill(null);
}

const BIOMASS_COLORS = ["#f6f6f6", "#c8e6c9", "#81c784", "#388e3c"];
const cellEls = {};
for (let id = 1; id <= TOTAL_CELLS; id++) {
  const cell = document.createElement("div");
  cell.className = "cell";
  cell.dataset.id = id;
  cell.style.background = BIOMASS_COLORS[0];
  cell.title = cellName(id);
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

function dotsBox(cell) {
  let box = cell.querySelector(".harvester-dots");
  if (!box) {
    box = document.createElement("div");
    box.className = "harvester-dots";
    cell.appendChild(box);
  }
  return box;
}

function placeHarvester(h, cellId) {
  removeHarvesterVisual(h);
  harvesterPlacement[h] = cellId;
  const dot = document.createElement("span");
  dot.className = "harvester-small-dot harvester-dot mine";
  dot.style.background = myColor();
  dot.title = "H" + (h + 1);
  dot.dataset.harvester = h;
  dotsBox(cellEls[cellId]).appendChild(dot);
}

function unplaceHarvester(h) {
  removeHarvesterVisual(h);
  harvesterPlacement[h] = null;
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
  const here = harvesterPlacement.filter(c => c === pickerCellId).length;
  const home = harvesterPlacement.filter(c => c == null).length;
  pickerTitle.textContent = "Cell " + cellName(pickerCellId) + ": " + here + " harvester" + (here === 1 ? "" : "s");
  pickerHelp.textContent = "Tap a harvester to put it here or take it back. " + home + " at home.";
  pickerList.innerHTML = "";
  harvesterPlacement.forEach((placedOn, h) => {
    const chip = document.createElement("button");
    chip.type = "button";
    chip.className = "picker-chip" + (placedOn === pickerCellId ? " here" : placedOn == null ? "" : " elsewhere");
    chip.setAttribute("aria-pressed", String(placedOn === pickerCellId));
    chip.innerHTML = "<b>H" + (h + 1) + "</b><small>" +
      (placedOn === pickerCellId ? "here" : placedOn == null ? "home" : cellName(placedOn)) + "</small>";
    chip.addEventListener("click", () => {
      if (!canMoveHarvesters()) { closePicker(); return; }
      if (placedOn === pickerCellId) unplaceHarvester(h);
      else placeHarvester(h, pickerCellId);
      renderPicker();
    });
    pickerList.appendChild(chip);
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
    const box = dotsBox(cell);
    box.querySelectorAll(".harvester-small-dot:not(.harvester-dot)").forEach(d => d.remove());
    const placing = box.firstChild;
    const mine = (entries || []).filter(e => e.household === myName).reduce((sum, e) => sum + e.count, 0);
    const others = (entries || []).filter(e => e.household !== myName).reduce((sum, e) => sum + e.count, 0);
    [[mine, myName, "Your family"], [others, "", "Other families"]].forEach(([count, owner, label]) => {
      for (let i = 0; i < count; i++) {
        const dot = document.createElement("span");
        dot.className = "harvester-small-dot" + (owner === myName ? " mine" : "");
        dot.style.background = colorForHousehold(owner);
        dot.title = label;
        box.insertBefore(dot, placing);
      }
    });
    if (!box.firstChild) box.remove();
  });
}

let birdsVisible = false;
let lastBirds = [];
function drawNewborns(cell, count) {
  let box = cell.querySelector(".newborns");
  if (!count) { if (box) box.remove(); return; }
  if (!box) {
    box = document.createElement("div");
    box.className = "newborns";
    cell.appendChild(box);
  }
  box.innerHTML = "";
  for (let i = 0; i < count; i++) {
    const chick = document.createElement("span");
    chick.className = "poussin icon-poussin";
    box.appendChild(chick);
  }
  box.title = count + " newborn bird(s)";
}

function applyBirds(values) {
  lastBirds = values;
  forEachCell(values, (cell, entry) => {
    if (myRole === "Household" && !birdsVisible) entry = { adults: 0, newborns: 0 };
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
    drawNewborns(cell, entry.newborns);
  });
}

function renderMemberTable(members, round) {
  memberTable.innerHTML = "";
  if (!members.length) {
    memberScroll.classList.add("hidden");
    return;
  }
  const addCell = (row, tag, text, className) => {
    const cell = document.createElement(tag);
    cell.textContent = text;
    if (className) cell.className = className;
    row.appendChild(cell);
    return cell;
  };

  const head = memberTable.createTHead().insertRow();
  addCell(head, "th", "Member");
  addCell(head, "th", "Round " + round, "current");

  const body = memberTable.createTBody();
  members.forEach(h => {
    const row = body.insertRow();
    const nameCell = addCell(row, "td", "");
    const token = document.createElement("span");
    token.className = "member-token";
    token.style.background = myColor();
    token.textContent = h.name;
    nameCell.appendChild(token);
    addCell(row, "td", h.gain ?? 0, "current");
  });

  const foot = memberTable.createTFoot().insertRow();
  addCell(foot, "td", "Family");
  addCell(foot, "td", members.reduce((sum, h) => sum + (h.gain ?? 0), 0), "current");

  memberScroll.classList.remove("hidden");
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

function makeTable(headers, rows) {
  const table = document.createElement("table");
  const head = table.createTHead().insertRow();
  headers.forEach(text => { head.appendChild(document.createElement("th")).textContent = text; });
  const body = table.createTBody();
  rows.forEach(r => {
    const row = body.insertRow();
    if (r.className) row.className = r.className;
    (Array.isArray(r) ? r : r.cells).forEach(value => { row.insertCell().textContent = value; });
  });
  return table;
}

function heading(text) {
  const h3 = document.createElement("h3");
  h3.textContent = text;
  return h3;
}

const handlers = {
  registered(m) {
    myName = m.payload.name;
    saveName(myName);
    setConnected(true);
    updateTrayColors();
    joinTitle.classList.add("hidden");
    loginEl.classList.add("hidden");
    if (!myRole) {
      show("ok", `Welcome, ${m.payload.name}! Waiting for the game to start...`);
      changeNameBtn.classList.remove("hidden");
    }
  },
  gameStarted(m) {
    const rejoined = myRole === m.payload.role;
    myRole = m.payload.role;
    changeNameBtn.classList.add("hidden");
    if (!rejoined) show("ok", "");
    roleLine.textContent = myName + " - " + m.payload.role;
    showGame();
    updateActionVisibility();
  },
  round(m) {
    const newRound = m.round !== currentRound;
    currentRound = m.round;
    finalResults.classList.add("hidden");
    gridEl.parentElement.classList.remove("hidden");
    if (!newRound) return;
    lastAction = null;
    resetRoundSelections();
    unlock();
    document.querySelectorAll(".harvester-dot").forEach(d => d.classList.remove("locked"));
    if (m.round > 1) pauseTurns("Round " + m.round, "The game master will start the round.");
    else pauseTurns();
  },
  turn(m) {
    resultCard.classList.add("hidden");

    currentRound = m.round;
    currentTurn = m.turn;
    const sentThisTurn = lastAction && lastAction.round === m.round && lastAction.turn === m.turn;
    if (sentThisTurn) {
      sendNow(lastAction.payload);
      lockHarvesters();
    } else {
      unlock();
    }
    startCountdown(m.seconds - (m.age || 0));
  },
  turnEnded() {
    pauseTurns();
  },
  roundEnded(m) {
    locked = true;
    pauseTurns("Round " + m.round + " is over", "Look at your harvest and the newborn birds. Waiting for the game master...");
  },
  regenerated(m) {
    locked = true;
    pauseTurns("Round " + m.round + ": biomass regeneration", "Look at the new biomass on the grid. Waiting for the game master...");
  },
  roundResult(m) {

    resultGain.textContent = "Round " + m.round + ": your family harvested " + m.gain;
    resultTotal.textContent = "Total since the start: " + m.total;
    renderMemberTable(m.harvesters || [], m.round);
    resultCard.classList.remove("hidden");
  },
  state(m) {
    handlers.gameStarted({ payload: { role: m.role } });
    setHarvesterCount(m.harvesterCount);
    applyBiomass(m.biomass);
    applyBirds(m.birds);
    applyProtection(m.protection);
    applyHarvesters(m.harvesters.map(h => [
      { household: myName, count: h.mine },
      { household: "", count: h.others }].filter(e => e.count > 0)));
    if (m.finalResults) handlers.gameOver(m.finalResults);
    else if (m.roundResult) handlers.roundResult(m.roundResult);
    if (!m.finalResults) {
      if (m.turn) {
        const sent = lastAction && lastAction.round === m.round && lastAction.turn === m.turn ? lastAction : null;
        lastAction = null;
        handlers.round({ round: m.round });
        handlers.turn({ round: m.round, turn: m.turn, seconds: m.secondsLeft });
        lastAction = sent;
        if (m.submitted) lockHarvesters();
        else if (sent) { sendNow(sent.payload); lockHarvesters(); }
      } else if (m.phase === "rangerDone" || m.phase === "householdsDone") {
        handlers.round({ round: m.round });
        handlers.turnEnded();
      } else if (m.phase === "newBiomass") {
        handlers.round({ round: m.round });
      } else if (m.phase === "regenerated") {
        handlers.regenerated({ round: m.round });
      } else if (m.round > 0) {
        handlers.roundEnded({ round: m.round });
      }
    }
    if (playerChartsEl.classList.contains("hidden")) {
      let saved = null;
      try { saved = JSON.parse(sessionStorage.getItem("cm.charts")); } catch (e) { }
      if (saved) {
        const resultShown = !resultCard.classList.contains("hidden");
        handlers.charts(saved);
        if (resultShown && m.roundResult && m.roundResult.round > (saved.rounds || 0)) resultCard.classList.remove("hidden");
      }
    }
  },
  charts(m) {
    try { sessionStorage.setItem("cm.charts", JSON.stringify(m)); } catch (e) { }
    if (!window.PlanetCharts) return;
    finalResults.classList.add("hidden");
    resultCard.classList.add("hidden");
    playerChartsEl.classList.remove("hidden");
    if (!playerCharts) playerCharts = PlanetCharts.mount(playerChartsEl, { focus: myName });
    playerCharts.update(m);
  },
  sessionStarted(m) {
    try { sessionStorage.removeItem("cm.charts"); } catch (e) { }
    playerChartsEl.classList.add("hidden");
    currentRound = null;
    lastAction = null;
    resetRoundSelections();
    unlock();
    finalResults.classList.add("hidden");
    resultCard.classList.add("hidden");
    gridEl.parentElement.classList.remove("hidden");
    pauseTurns("Session " + m.session, "Same role and family, new board. Waiting for the game master to start round 1...");
  },
  gameOver(m) {
    locked = true;
    if (m.session === 1) pauseTurns("Session 1 is over", "Here are your results. Session 2 will start soon.");
    else pauseTurns("Game over", "The game is over. Thank you for playing!");
    const families = m.families || [];
    const roundLabels = Array.from({ length: m.rounds }, (_, i) => "R" + (i + 1));
    gridEl.parentElement.classList.add("hidden");
    resultCard.classList.add("hidden");

    finalResults.replaceChildren(
      heading("Households"),
      makeTable(["Family", ...roundLabels, "Total"],
        families.flatMap(f => [
          { className: "family-row", cells: [f.name, ...f.gains, f.total] },
          ...(f.harvesters || []).map(h => ({ className: "member-row", cells: [h.name, ...h.gains, h.total] }))
        ])),
      heading("Ranger"),
      makeTable(["Round", "Protected zones", "Newborn birds"],
        (m.ranger || []).map(r => [r.round, r.protected.map(cellName).join(", ") || "-", r.newborns])));
    finalResults.classList.remove("hidden");
  },
  biomass(m) { applyBiomass(m.values); },
  birds(m) { applyBirds(m.values); },
  showBirds(m) { birdsVisible = m.show; applyBirds(lastBirds); },
  protection(m) { applyProtection(m.values); },
  harvesters(m) { applyHarvesters(m.values); },
  rejected(m) {
    if (reasonOf(m) !== "name-taken") return;
    leaveGame();
    show("error", "This name is already used by a connected player. Choose another name.");
  },
  replaced() {
    leaveGame(true);
    show("error", "This name was opened in another tab or window. Reload this page to play here.");
  },
  error(m) { show("error", "Error: " + reasonOf(m)); }
};

function unlock() {
  locked = false;
  sendBtn.disabled = false;
  protectBtn.disabled = false;
}


const SAVED_NAME_KEY = "cm.name";
const SAVED_AT_KEY = "cm.nameSavedAt";

let playerToken = "";
try { playerToken = localStorage.getItem("cm.playerToken") || ""; } catch (e) { }
if (!playerToken) {
  playerToken = Array.from(crypto.getRandomValues(new Uint32Array(4)), n => n.toString(16)).join("");
  try { localStorage.setItem("cm.playerToken", playerToken); } catch (e) { }
}
const REJOIN_WINDOW_MS = 6 * 60 * 60 * 1000;
const HEARTBEAT_MS = 5000;
const DEAD_AFTER_MS = 15000;
const WAKE_CHECK_MS = 3000;
const BANNER_DELAY_MS = 1500;

let ws = null;
let heartbeatTimer = null;
let reconnectTimer = null;
let bannerTimer = null;
let lastMessageAt = 0;
let lastAction = null;

const connBanner = document.createElement("div");
connBanner.id = "connBanner";
connBanner.className = "hidden";
connBanner.setAttribute("role", "status");
document.body.prepend(connBanner);

const changeNameBtn = document.createElement("button");
changeNameBtn.type = "button";
changeNameBtn.id = "changeNameBtn";
changeNameBtn.className = "link-button hidden";
changeNameBtn.textContent = "Not you? Change name";
msg.after(changeNameBtn);
changeNameBtn.addEventListener("click", () => {
  leaveGame();
  show("", "");
});

function readStorage(key) {
  try {
    const own = sessionStorage.getItem(key);
    if (own != null) return own;
  } catch (e) { }
  try { return localStorage.getItem(key); } catch (e) { return null; }
}

function writeStorage(key, value) {
  [sessionStorage, localStorage].forEach(store => {
    try {
      if (value == null) store.removeItem(key);
      else store.setItem(key, value);
    } catch (e) { }
  });
}

function saveName(name) {
  writeStorage(SAVED_NAME_KEY, name);
  writeStorage(SAVED_AT_KEY, String(Date.now()));
  try { localStorage.setItem("cm.alive." + name, String(Date.now())); } catch (e) { }
}

function setConnected(connected) {
  clearTimeout(bannerTimer);
  if (connected) {
    connBanner.classList.add("hidden");
    return;
  }
  bannerTimer = setTimeout(() => {
    connBanner.textContent = "Connection lost. Reconnecting...";
    connBanner.classList.remove("hidden");
  }, BANNER_DELAY_MS);
}

function stopHeartbeat() {
  clearInterval(heartbeatTimer);
  heartbeatTimer = null;
}

function startHeartbeat() {
  stopHeartbeat();
  heartbeatTimer = setInterval(() => {
    if (!ws || ws.readyState !== WebSocket.OPEN) return;
    if (Date.now() - lastMessageAt > DEAD_AFTER_MS) return reconnectNow();
    ws.send(JSON.stringify({ type: "ping" }));
    writeStorage(SAVED_AT_KEY, String(Date.now()));
  }, HEARTBEAT_MS);
}

function dropSocket() {
  const old = ws;
  ws = null;
  stopHeartbeat();
  if (old) {
    try { old.close(); } catch (e) { }
  }
}

function connect(name) {
  myName = name;
  updateTrayColors();
  clearTimeout(reconnectTimer);
  dropSocket();

  const proto = location.protocol === "https:" ? "wss" : "ws";
  const socket = new WebSocket(`${proto}://${location.host}/ws`);
  ws = socket;

  socket.addEventListener("open", () => {
    if (socket !== ws) return;
    reconnectAttempts = 0;
    lastMessageAt = Date.now();
    socket.send(JSON.stringify({ type: "bonjour", name: name, token: playerToken }));
    startHeartbeat();
  });
  socket.addEventListener("message", (ev) => {
    if (socket !== ws) return;
    lastMessageAt = Date.now();
    let m;
    try { m = parseServerMessage(ev.data); } catch (e) { return; }
    const handler = m && handlers[m.type];
    if (handler) handler(m);
  });
  socket.addEventListener("close", () => {
    if (socket !== ws) return;
    ws = null;
    stopHeartbeat();
    scheduleReconnect();
  });
}

function scheduleReconnect() {
  if (!myName) return;
  setConnected(false);
  clearTimeout(reconnectTimer);
  const delay = reconnectAttempts === 0 ? 300 : Math.min(1000 * reconnectAttempts, 5000);
  reconnectAttempts++;
  reconnectTimer = setTimeout(() => connect(myName), delay);
}

function reconnectNow() {
  if (!myName) return;
  setConnected(false);
  reconnectAttempts = 0;
  connect(myName);
}

function checkConnection() {
  if (!myName) return;
  if (!ws || ws.readyState === WebSocket.CLOSING || ws.readyState === WebSocket.CLOSED) return reconnectNow();
  if (ws.readyState !== WebSocket.OPEN) return;
  const askedAt = Date.now();
  ws.send(JSON.stringify({ type: "ping" }));
  setTimeout(() => {
    if (myName && lastMessageAt < askedAt) reconnectNow();
  }, WAKE_CHECK_MS);
}

document.addEventListener("visibilitychange", () => {
  if (document.visibilityState === "visible") checkConnection();
});
window.addEventListener("pageshow", (e) => { if (e.persisted) checkConnection(); });
window.addEventListener("online", checkConnection);
window.addEventListener("focus", checkConnection);

function leaveGame(keepSavedName) {
  myName = null;
  lastAction = null;
  clearTimeout(reconnectTimer);
  dropSocket();
  setConnected(true);
  if (!keepSavedName) { writeStorage(SAVED_AT_KEY, null); try { sessionStorage.removeItem("cm.charts"); } catch (e) { } }
  changeNameBtn.classList.add("hidden");
  joinTitle.classList.remove("hidden");
  loginEl.classList.remove("hidden");
  nameInput.focus();
}

byId("login").addEventListener("submit", (e) => {
  e.preventDefault();
  const name = nameInput.value.trim();
  if (name.length < 3) {
    show("error", "Your name must have at least 3 letters");
    return;
  }
  reconnectAttempts = 0;
  connect(name);
});

function sendNow(payload) {
  if (!ws || ws.readyState !== WebSocket.OPEN) return false;
  ws.send(JSON.stringify(payload));
  return true;
}

function sendAction(allowed, notAllowedText, payload) {
  if (!allowed) return show("error", notAllowedText);
  lastAction = { round: currentRound, turn: currentTurn, payload: payload };
  lockHarvesters();
  if (!sendNow(payload)) {
    show("error", "Connection lost. Your choice will be sent when the phone reconnects.");
    checkConnection();
  }
}

sendBtn.addEventListener("click", () => sendAction(canMoveHarvesters(),
  "You can only move harvesters during the Household turn",
  { type: "move", harvesterCells: harvesterPlacement.slice() }));

protectBtn.addEventListener("click", () => sendAction(canProtectZones(),
  "You can only protect zones during the Ranger turn",
  { type: "protect", cells: Array.from(protectedZones) }));

const ALIVE_PREFIX = "cm.alive.";
const ALIVE_MS = 10000;
setInterval(() => {
  if (myName && ws && ws.readyState === WebSocket.OPEN) {
    try { localStorage.setItem(ALIVE_PREFIX + myName, String(Date.now())); } catch (e) { }
  }
}, 3000);
window.addEventListener("pagehide", () => {
  if (myName) try { localStorage.removeItem(ALIVE_PREFIX + myName); } catch (e) { }
});

function playedInAnotherTab(name) {
  try { return Date.now() - (Number(localStorage.getItem(ALIVE_PREFIX + name)) || 0) < ALIVE_MS; }
  catch (e) { return false; }
}

(function rejoinAfterReload() {
  let ownName = null;
  try { ownName = sessionStorage.getItem(SAVED_NAME_KEY); } catch (e) { }
  const savedName = readStorage(SAVED_NAME_KEY) || "";
  const savedAt = Number(readStorage(SAVED_AT_KEY)) || 0;
  nameInput.value = savedName;
  if (!savedName || Date.now() - savedAt > REJOIN_WINDOW_MS) return;
  if (!ownName && playedInAnotherTab(savedName)) { nameInput.value = ""; return; }
  joinTitle.classList.add("hidden");
  loginEl.classList.add("hidden");
  show("ok", "Joining as " + savedName + "...");
  changeNameBtn.classList.remove("hidden");
  connect(savedName);
})();