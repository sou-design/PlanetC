as yet unclassified
gmScript
	^ '/* Game master page.
   The game master connects on /ws like a player, then sends the secret key (gmLogin).
   With the right key the server gives it the GameMaster role, so it receives every game
   broadcast (grid, harvesters, birds, rounds) as they happen, with no polling.
   Tabs: Players and QR code, Grid, Results (gain of every family per round).
   Before each turn (park manager, then households) the game master sets its time and clicks Proceed.
   Only the player list is asked every 2 seconds, because roles are assigned in the
   Cormas presenter, which sends no event. That request also keeps the connection alive. */
window.gmScriptVersion = 7; /* checked by the page: must match gmPageHtml */
const byId = id => document.getElementById(id);
const loginEl = byId("gmLogin");
const dashboardEl = byId("gmDashboard");
const form = byId("gmForm");
const nameInput = byId("gmName");
const orgInput = byId("gmOrg");
const secretInput = byId("gmSecret");
const errorEl = byId("gmError");
const identityEl = byId("gmIdentity");
const connectionEl = byId("gmConnection");
const playerList = byId("playerList");
const playerEmpty = byId("playerEmpty");
const playerSummary = byId("playerSummary");
const joinQr = byId("joinQr");
const joinUrlText = byId("joinUrlText");
const joinUrlInput = byId("joinUrlInput");
const joinHint = byId("joinHint");
const joinAddressSelect = byId("joinAddressSelect");
const joinAddressLabel = byId("joinAddressLabel");
const startBtn = byId("startBtn");
const startHint = byId("startHint");

const PLAYERS_REFRESH_MS = 2000;
let gmName = "";
let gmOrg = "";
let gmSecret = "";
let signedIn = false;
let stopped = false;        /* wrong key, or replaced by another game master page */
let accepted = false;       /* the server confirmed the key */
let ws = null;
let heartbeat = null;
let reconnectTimer = null;
let reconnectAttempts = 0;
let gameState = "waiting";  /* waiting, starting or started */
let canStart = false;
let lastPlayers = null;
let startAskedAt = 0;       /* when Start was clicked, to detect a start that never happens */
let joinUrlEdited = false;  /* once the game master edits the address, keep it */

/* Browser storage can throw (private mode, blocked storage): never let it break the page.
   Name and organization are remembered; the key only for this tab (sessionStorage). */
function load(store, key) { try { return store.getItem(key) || ""; } catch (e) { return ""; } }
function save(store, key, value) { try { store.setItem(key, value); } catch (e) {} }
function forget(store, key) { try { store.removeItem(key); } catch (e) {} }

/* ---------- Screens ---------- */

function showDashboard() {
  signedIn = true;
  stopped = false;
  identityEl.textContent = gmName + " \u00b7 " + gmOrg;
  loginEl.classList.add("hidden");
  dashboardEl.classList.remove("hidden");
  document.title = "Game Master - " + gmName;
  renderPlayers([]);
  updateStartButton([]);
  if (!joinUrlEdited) showJoinUrl(guessJoinUrl(null, null));
  connect();
}

function showLogin(message) {
  signedIn = false;
  disconnect();
  dashboardEl.classList.add("hidden");
  loginEl.classList.remove("hidden");
  document.title = "Game Master";
  errorEl.textContent = message || "";
  (nameInput.value ? secretInput : nameInput).focus();
}

/* ---------- Player list ---------- */

function renderPlayers(players) {
  playerList.innerHTML = "";
  players.forEach(p => {
    const li = document.createElement("li");

    const dot = document.createElement("span");
    dot.className = "player-dot" + (p.connected ? " connected" : "");

    const name = document.createElement("span");
    name.className = "player-name";
    name.textContent = p.name;

    li.appendChild(dot);
    li.appendChild(name);

    if (p.role) {
      const role = document.createElement("span");
      role.className = "player-role";
      role.textContent = p.role;
      li.appendChild(role);
    }

    const status = document.createElement("span");
    status.className = "player-status";
    status.textContent = p.connected ? "online" : "offline";
    li.appendChild(status);

    playerList.appendChild(li);
  });

  const online = players.filter(p => p.connected).length;
  playerList.classList.toggle("hidden", players.length === 0);
  playerEmpty.classList.toggle("hidden", players.length > 0);
  playerSummary.textContent = players.length === 0
    ? ""
    : players.length + (players.length === 1 ? " player" : " players") + " joined, " + online + " online";
}

/* ---------- Join link and QR code ---------- */

function isLoopback(host) {
  return host === "localhost" || host === "::1" || host === "[::1]" || /^127\./.test(host);
}

/* Address players should open: the laptop address from ipconfig and the port chosen in Cormas.
   If this page was opened with one of those addresses, keep it. */
function buildJoinUrl(address, port) {
  return "http://" + address + (port ? ":" + port : "") + "/";
}

function guessJoinUrl(addresses, port) {
  port = port || location.port;
  if (addresses && addresses.length > 0) {
    const address = addresses.includes(location.hostname) ? location.hostname : addresses[0];
    return buildJoinUrl(address, port);
  }
  return location.protocol + "//" + location.host + "/";
}

/* When the laptop has several addresses (Wi-Fi, Ethernet, VPN...), let the game master pick */
let shownAddresses = "";
function showAddressChoices(addresses, port) {
  const key = JSON.stringify([addresses, port]);
  if (key === shownAddresses) return;
  shownAddresses = key;
  joinAddressSelect.innerHTML = "";
  (addresses || []).forEach(address => {
    const option = document.createElement("option");
    option.value = buildJoinUrl(address, port || location.port);
    option.textContent = address;
    joinAddressSelect.appendChild(option);
  });
  const several = (addresses || []).length > 1;
  joinAddressSelect.classList.toggle("hidden", !several);
  joinAddressLabel.classList.toggle("hidden", !several);
  joinAddressSelect.value = joinUrlText.textContent;
}

joinAddressSelect.addEventListener("change", () => {
  joinUrlEdited = true;
  showJoinUrl(joinAddressSelect.value);
});

function showJoinUrl(url) {
  joinUrlText.textContent = url;
  if (document.activeElement !== joinUrlInput) joinUrlInput.value = url;
  try {
    const qr = qrcode(0, "M");
    qr.addData(url);
    qr.make();
    joinQr.innerHTML = qr.createSvgTag({ cellSize: 6, margin: 2, scalable: true });
  } catch (e) {
    joinQr.textContent = "Could not draw the QR code.";
  }
  let host = "";
  try { host = new URL(url).hostname; } catch (e) {}
  const local = isLoopback(host);
  joinHint.className = local ? "warning" : "";
  joinHint.textContent = local
    ? "No network address found on this laptop. Connect it to the Wi-Fi of the players, or type its address here."
    : "Players scan the code or type the address, then enter their name and click Join. Their device must be on the same network.";
}

joinUrlInput.addEventListener("input", () => {
  const url = joinUrlInput.value.trim();
  if (!url) return;
  joinUrlEdited = true;
  showJoinUrl(url);
});

/* ---------- Start button ---------- */

function updateStartButton(players) {
  if (players) {
    lastPlayers = players;
    canStart = players.length > 0 && players.every(p => p.role);
  }
  const ready = accepted && ws && ws.readyState === WebSocket.OPEN;
  startBtn.disabled = !(canStart && ready && gameState === "waiting");
  startBtn.textContent =
    gameState === "started" ? "Game started" :
    gameState === "starting" ? "Starting..." : "Start the game";
  let hint = "";
  let warning = false;
  if (gameState === "started") hint = "The game is running.";
  else if (gameState === "starting") hint = "";
  else if (!lastPlayers || lastPlayers.length === 0) hint = "Waiting for players to join.";
  else if (!canStart) { hint = "Every player needs a role before the game can start. In Cormas, right-click a player and choose Role."; warning = true; }
  else hint = "All players have a role. You can start the game.";
  startHint.textContent = hint;
  startHint.className = warning ? "warning" : "";
}

function markGameRunning() {
  if (gameState === "started") return;
  gameState = "started";
  updateStartButton();
}

startBtn.addEventListener("click", () => {
  if (startBtn.disabled) return;
  if (!confirm("Start the game now? Players cannot join after the game has started.")) return;
  gameState = "starting";
  updateStartButton();
  startAskedAt = Date.now();
  send({ type: "gmStart" });
});

/* ---------- Tabs ---------- */

const tabs = { lobby: byId("tabLobby"), game: byId("tabGame"), results: byId("tabResults") };
const panels = { lobby: byId("panelLobby"), game: byId("panelGame"), results: byId("panelResults") };
let currentTab = "lobby";

function selectTab(name) {
  currentTab = name;
  Object.keys(tabs).forEach(key => {
    tabs[key].setAttribute("aria-selected", String(key === name));
    panels[key].classList.toggle("hidden", key !== name);
  });
  setTabAlert(name, false);
}

/* Small dot on a tab when something new arrived while the game master looks at another tab */
function setTabAlert(name, on) {
  let dot = tabs[name].querySelector(".dot");
  if (on && currentTab !== name && !dot) {
    dot = document.createElement("span");
    dot.className = "dot";
    tabs[name].appendChild(dot);
  } else if (!on && dot) dot.remove();
}

tabs.lobby.addEventListener("click", () => selectTab("lobby"));
tabs.game.addEventListener("click", () => selectTab("game"));
tabs.results.addEventListener("click", () => selectTab("results"));

/* ---------- Family results ---------- */

const resultsEmpty = byId("resultsEmpty");
const resultsWrap = byId("resultsWrap");
const resultsSummary = byId("resultsSummary");
const resultsTable = byId("resultsTable");

/* One row per family: rank, name, gain in each round, total. Best total first. */
function renderResults(families, rounds) {
  const played = Math.max(rounds || 0, ...families.map(f => (f.gains || []).length));
  if (!families.length || played === 0) {
    resultsEmpty.classList.remove("hidden");
    resultsWrap.classList.add("hidden");
    return;
  }
  resultsEmpty.classList.add("hidden");
  resultsWrap.classList.remove("hidden");
  const sorted = families.slice().sort((a, b) => b.total - a.total || a.name.localeCompare(b.name));
  const best = sorted[0].total;

  resultsTable.innerHTML = "";
  const head = resultsTable.createTHead().insertRow();
  ["#", "Family"].concat(Array.from({ length: played }, (_, i) => "Round " + (i + 1)), ["Total"])
    .forEach(label => {
      const th = document.createElement("th");
      th.textContent = label;
      head.appendChild(th);
    });
  const body = resultsTable.createTBody();
  sorted.forEach((family, index) => {
    const row = body.insertRow();
    if (family.total === best && best > 0) row.className = "leader";
    const cells = [index + 1, family.name]
      .concat(Array.from({ length: played }, (_, i) => (family.gains || [])[i] ?? "-"), [family.total]);
    cells.forEach((value, i) => {
      const td = row.insertCell();
      td.textContent = value;
      if (i === cells.length - 1) td.className = "total";
    });
  });
  const leaders = sorted.filter(f => f.total === best).map(f => f.name);
  resultsSummary.textContent = "After " + played + (played === 1 ? " round" : " rounds") + ": "
    + (best > 0 ? leaders.join(", ") + (leaders.length > 1 ? " lead with " : " leads with ") + best : "no harvest yet");
}

/* ---------- Rounds: before each turn, set its time and click Proceed ---------- */

const gameNotStarted = byId("gameNotStarted");
const roundPanel = byId("roundPanel");
const roundTitle = byId("roundTitle");
const roundPhase = byId("roundPhase");
const roundSetup = byId("roundSetup");
const turnFieldText = byId("turnFieldText");
const turnInput = byId("turnSeconds");
const proceedBtn = byId("proceedBtn");
const finishBtn = byId("finishBtn");

/* Game phase, kept in sync with the server:
   lobby (not started), ready (next round can start), rangerTurn, rangerDone (waiting for the
   households turn), householdsTurn, ended (planned rounds played, or game finished).
   Round 1 has no park manager turn. */
const TURNS = {
  ranger: { label: "Park manager turn", defaultSeconds: 10, min: 5, max: 600, key: "cm.gm.rangerSeconds" },
  households: { label: "Households turn", defaultSeconds: 120, min: 10, max: 3600, key: "cm.gm.householdSeconds" }
};
const game = { phase: "lobby", round: 1, maxRounds: null, over: false, waiting: false,
               startedAt: 0, durationMs: 0 };
let autoSwitched = false;
let shownTurn = null;

function nextTurn() {
  if (game.phase === "rangerDone") return "households";
  return game.round === 1 ? "households" : "ranger";
}

function formatTime(ms) {
  const total = Math.max(0, Math.ceil(ms / 1000));
  return Math.floor(total / 60) + ":" + String(total % 60).padStart(2, "0");
}

function setPhaseText(text, time) {
  roundPhase.textContent = text;
  if (time) {
    const t = document.createElement("span");
    t.className = "time";
    t.textContent = " " + time;
    roundPhase.appendChild(t);
  }
}

function roundLabel(n) {
  return "Round " + n + (game.maxRounds ? " of " + game.maxRounds : "");
}

/* The time field always shows the time of the next turn (last value used for that turn) */
function prepareTurnField(turn) {
  if (turn === shownTurn) return;
  shownTurn = turn;
  const t = TURNS[turn];
  turnFieldText.textContent = t.label + " (seconds)";
  turnInput.min = t.min;
  turnInput.max = t.max;
  turnInput.value = load(localStorage, t.key) || t.defaultSeconds;
}

function renderRound() {
  const started = game.phase !== "lobby";
  gameNotStarted.classList.toggle("hidden", started);
  roundPanel.classList.toggle("hidden", !started);
  if (!started) return;
  if (!autoSwitched) { autoSwitched = true; selectTab("game"); }

  const running = game.phase === "rangerTurn" || game.phase === "householdsTurn";
  roundSetup.classList.toggle("hidden", running);
  proceedBtn.disabled = game.waiting || !accepted;
  finishBtn.disabled = game.waiting || !accepted;

  if (running) {
    const label = game.phase === "rangerTurn" ? "Park manager turn" : "Households turn";
    roundTitle.textContent = roundLabel(game.round);
    if (!game.startedAt) return setPhaseText(label + " in progress.");
    const left = game.durationMs - (Date.now() - game.startedAt);
    if (left > 0) setPhaseText(label + ":", formatTime(left) + " left");
    else setPhaseText(game.phase === "rangerTurn" ? "Park manager turn: time is up." : "Households turn: time is up. Resolving the round...");
    return;
  }

  const turn = nextTurn();
  prepareTurnField(turn);
  const next = game.round;

  if (game.phase === "rangerDone") {
    roundTitle.textContent = roundLabel(next);
    setPhaseText("The park manager turn is over. Set the time of the households turn, then click Proceed.");
    proceedBtn.textContent = game.waiting ? "Starting..." : "Start the households turn";
    finishBtn.classList.add("hidden");
  } else if (game.phase === "ready") {
    roundTitle.textContent = next === 1 ? "Ready to play" : "Round " + (next - 1) + " is over";
    setPhaseText(next === 1
      ? "Round 1 has no park manager turn. Set the time of the households turn, then click Proceed."
      : "Round " + next + " starts with the park manager turn. Set its time, then click Proceed.");
    proceedBtn.textContent = game.waiting ? "Starting..."
      : (turn === "ranger" ? "Start round " + next + ": park manager turn" : "Start round " + next + ": households turn");
    finishBtn.classList.toggle("hidden", next === 1);
  } else {
    roundTitle.textContent = game.over
      ? "Game over after " + (next - 1) + (next - 1 === 1 ? " round" : " rounds")
      : "All planned rounds are played (" + (next - 1) + ")";
    setPhaseText(game.over
      ? "Players see the end of the game. You can still add a round: set the time of its park manager turn."
      : "Finish the game, or add an extra round: set the time of its park manager turn.");
    proceedBtn.textContent = game.waiting ? "Starting..." : "Play an extra round (round " + next + ")";
    finishBtn.classList.toggle("hidden", game.over);
  }
}

setInterval(() => {
  if (game.phase === "rangerTurn" || game.phase === "householdsTurn") renderRound();
}, 500);

proceedBtn.addEventListener("click", () => {
  if (proceedBtn.disabled) return;
  const t = TURNS[nextTurn()];
  const value = Math.round(Number(turnInput.value));
  const seconds = Number.isFinite(value) ? Math.min(t.max, Math.max(t.min, value)) : t.defaultSeconds;
  turnInput.value = seconds;
  save(localStorage, t.key, String(seconds));
  game.waiting = true;
  renderRound();
  send({ type: "gmProceed", seconds });
});

finishBtn.addEventListener("click", () => {
  if (finishBtn.disabled) return;
  if (!confirm("Finish the game now? Players will see that the game is over.")) return;
  game.waiting = true;
  renderRound();
  send({ type: "gmFinish" });
});

/* ---------- Game grid (same as the players grid) ---------- */

const gamePanel = byId("gamePanel");
const gmGrid = byId("gmGrid");
const gameStatus = byId("gameStatus");
const gameLegend = byId("gameLegend");
const birdsBtn = byId("birdsBtn");
const BIOMASS_COLORS = ["#f6f6f6", "#c8e6c9", "#81c784", "#388e3c"];
const HOUSEHOLD_PALETTE = ["#1D9E75", "#D85A30", "#534AB7", "#378ADD", "#EF9F27", "#D4537E", "#639922", "#993C1D"];
const cellEls = [];
let showBirds = false;   /* birds are hidden until the game master asks for them */
let lastBirds = null;
const householdsSeen = new Set();

/* Same colors as on the players pages */
function colorForHousehold(name) {
  let hash = 0;
  for (let i = 0; i < name.length; i++) hash = (hash * 31 + name.charCodeAt(i)) >>> 0;
  return HOUSEHOLD_PALETTE[hash % HOUSEHOLD_PALETTE.length];
}

/* Build the cells the first time grid data arrives (one value per cell) */
function ensureGrid(count) {
  if (cellEls.length === count) return;
  gmGrid.innerHTML = "";
  cellEls.length = 0;
  for (let i = 0; i < count; i++) {
    const cell = document.createElement("div");
    cell.className = "cell";
    const label = document.createElement("span");
    label.className = "cell-id";
    label.textContent = i + 1;
    cell.appendChild(label);
    gmGrid.appendChild(cell);
    cellEls.push(cell);
  }
  gamePanel.classList.remove("hidden");
}

function applyBiomass(values) {
  ensureGrid(values.length);
  values.forEach((v, i) => {
    const level = Math.max(0, Math.min(3, Math.round(v)));
    cellEls[i].style.background = BIOMASS_COLORS[level];
  });
}

function applyProtection(values) {
  ensureGrid(values.length);
  values.forEach((isProtected, i) => cellEls[i].classList.toggle("protected-shared", !!isProtected));
}

function applyHarvesters(values) {
  ensureGrid(values.length);
  values.forEach((entries, i) => {
    const cell = cellEls[i];
    let container = cell.querySelector(".harvester-chips");
    if (!entries || entries.length === 0) { if (container) container.remove(); return; }
    if (!container) {
      container = document.createElement("div");
      container.className = "harvester-chips";
      cell.appendChild(container);
    }
    container.innerHTML = "";
    entries.forEach(entry => {
      householdsSeen.add(entry.household);
      const chip = document.createElement("div");
      chip.className = "harvester-chip";
      chip.title = entry.household + ": " + entry.count;
      const swatch = document.createElement("span");
      swatch.className = "harvester-chip-swatch";
      swatch.style.background = colorForHousehold(entry.household);
      const count = document.createElement("span");
      count.textContent = entry.count;
      chip.appendChild(swatch);
      chip.appendChild(count);
      container.appendChild(chip);
    });
  });
  renderLegend();
}

/* Birds are always received, but only drawn when the game master turns them on */
function applyBirds(values) {
  if (values) lastBirds = values;
  if (!lastBirds) return;
  ensureGrid(lastBirds.length);
  lastBirds.forEach((entry, i) => {
    const cell = cellEls[i];
    const adults = showBirds && entry ? entry.adults : 0;
    const newborns = showBirds && entry ? entry.newborns : 0;
    let adultIcon = cell.querySelector(".bird-icon-plain");
    if (adults > 0 && !adultIcon) {
      adultIcon = document.createElement("span");
      adultIcon.className = "bird-icon-plain";
      cell.appendChild(adultIcon);
    } else if (adults === 0 && adultIcon) adultIcon.remove();
    if (adultIcon) adultIcon.title = adults + " adult bird(s)";
    let chip = cell.querySelector(".newborn-chip");
    if (newborns > 0) {
      if (!chip) {
        chip = document.createElement("div");
        chip.className = "newborn-chip";
        cell.appendChild(chip);
      }
      chip.innerHTML = "<span class=\"bird-chip-icon\"></span><span>" + Number(newborns) + "</span>";
    } else if (chip) chip.remove();
  });
}

function renderLegend() {
  gameLegend.innerHTML = "";
  Array.from(householdsSeen).sort().forEach(name => {
    const item = document.createElement("span");
    const swatch = document.createElement("i");
    swatch.style.background = colorForHousehold(name);
    const label = document.createElement("b");
    label.style.fontWeight = "normal";
    label.textContent = name;
    item.appendChild(swatch);
    item.appendChild(label);
    gameLegend.appendChild(item);
  });
}

birdsBtn.addEventListener("click", () => {
  showBirds = !showBirds;
  birdsBtn.setAttribute("aria-pressed", String(showBirds));
  birdsBtn.textContent = showBirds ? "Hide birds" : "Show birds";
  applyBirds();
});

/* ---------- Error banner ---------- */

const gmAlert = byId("gmAlert");
function showAlert(text) {
  gmAlert.textContent = text;
  gmAlert.classList.remove("hidden");
}
function hideAlert() {
  gmAlert.classList.add("hidden");
}

/* ---------- Connection to the game server ---------- */

function setConnection(state, text) {
  connectionEl.className = state;
  connectionEl.textContent = text;
}

/* The server sends JSON, sometimes wrapped once more as a JSON string */
function parseServerMessage(raw) {
  let m = JSON.parse(raw);
  if (typeof m === "string") m = JSON.parse(m);
  return m;
}

function send(message) {
  if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(message));
}

/* One handler per message type */
const handlers = {
  gmAccepted(m) {
    accepted = true;
    game.waiting = false;
    reconnectAttempts = 0;
    setConnection("online", "Connected");
    const url = guessJoinUrl(m.addresses, m.port);
    if (!joinUrlEdited) showJoinUrl(url);
    showAddressChoices(m.addresses, m.port);
    send({ type: "gmPlayers" });
    send({ type: "gmGrid" });   /* if a game is already running, get its current state */
    clearInterval(heartbeat);
    heartbeat = setInterval(() => send({ type: "gmPlayers" }), PLAYERS_REFRESH_MS);
    renderRound();
  },
  gmRejected() {
    stopped = true;
    forget(sessionStorage, "cm.gm.secret");
    secretInput.value = "";
    showLogin("Wrong game master key.");
  },
  gmReplaced() {
    stopped = true;
    accepted = false;
    setConnection("replaced", "Opened in another window. Reload to take over.");
    updateStartButton();
  },
  gmPlayers(m) {
    renderPlayers(m.players || []);
    updateStartButton(m.players || []);
    /* Keep the phase in sync (also after a reload); a running countdown is kept */
    const running = p => p === "rangerTurn" || p === "householdsTurn";
    /* Start was accepted but Cormas still has no game after a few seconds */
    if (m.phase === "lobby" && startAskedAt && Date.now() - startAskedAt > 6000) {
      startAskedAt = 0;
      gameState = "waiting";
      updateStartButton(m.players || []);
      showAlert("Cormas did not start the game. Look in Pharo for a debugger window or an error in the Transcript. You can also click Start Game in the Cormas window: this page will follow.");
    }
    if (m.phase && m.phase !== "lobby") startAskedAt = 0;
    if (m.phase && !(m.phase === game.phase && running(m.phase))) {
      if (m.phase !== game.phase) game.startedAt = 0;
      game.phase = m.phase;
      if (m.round != null) game.round = m.round;
      if (m.maxRounds != null) game.maxRounds = m.maxRounds;
      if (m.phase !== "lobby") markGameRunning();
      renderRound();
    }
  },
  gmStart(m) {
    if (m.result === "starting" || m.result === "started") {
      hideAlert();
      markGameRunning();
      selectTab("game");
      return send({ type: "gmPlayers" });
    }
    gameState = "waiting";
    updateStartButton();
    if (m.result === "alreadyStarted") {
      showAlert("Cormas says this game has already started. If that is a previous game, open a new game in Cormas (or restart the server), then log in again.");
    } else {
      startHint.textContent = "The game could not start: every player needs a role. In Cormas, right-click a player and choose Role.";
      startHint.className = "warning";
    }
  },
  gmError(m) {
    showAlert("Error in Cormas: " + (m.message || "unknown") + "\nSee the Pharo Transcript or debugger for details.");
    if (gameState === "starting") { gameState = "waiting"; updateStartButton(); }
    game.waiting = false;
    renderRound();
  },
  gameStarted() { markGameRunning(); },
  round(m) {
    Object.assign(game, { phase: "ready", round: m.round, over: false, startedAt: 0 });
    if (m.maxRounds != null) game.maxRounds = m.maxRounds;
    gameStatus.textContent = roundLabel(m.round);
    markGameRunning();
  },
  turn(m) {
    Object.assign(game, { phase: m.turn === "ranger" ? "rangerTurn" : "householdsTurn", round: m.round,
                          waiting: false, over: false, startedAt: Date.now(), durationMs: (m.seconds || 0) * 1000 });
    gameStatus.textContent = roundLabel(m.round) + (m.turn === "ranger" ? " - park manager turn" : " - households turn");
    markGameRunning();
    renderRound();
  },
  turnEnded(m) {
    Object.assign(game, { phase: "rangerDone", round: m.round, waiting: false, startedAt: 0 });
    gameStatus.textContent = roundLabel(m.round) + " - waiting for the households turn";
    renderRound();
  },
  roundEnded(m) {
    if (m.maxRounds != null) game.maxRounds = m.maxRounds;
    Object.assign(game, { round: m.round + 1, waiting: false, startedAt: 0 });
    game.phase = m.round >= game.maxRounds ? "ended" : "ready";
    gameStatus.textContent = "Round " + m.round + " is over";
    renderRound();
  },
  results(m) {
    renderResults(m.families || [], m.rounds);
    setTabAlert("results", true);
  },
  gameOver(m) {
    Object.assign(game, { phase: "ended", over: true, waiting: false });
    if (m.rounds != null) { game.round = m.rounds + 1; game.maxRounds = m.rounds; }
    gameStatus.textContent = "Game over";
    renderRound();
  },
  gmProceed(m) {
    if (m.result === "ok") return;
    game.waiting = false;
    renderRound();
    setPhaseText("A turn is already running, or the game has not started.");
  },
  gmFinish(m) {
    if (m.result === "ok") return;
    game.waiting = false;
    renderRound();
    setPhaseText("The game can only be finished between rounds, after at least one round.");
  },
  biomass(m) { applyBiomass(m.values); markGameRunning(); },
  protection(m) { applyProtection(m.values); },
  harvesters(m) { applyHarvesters(m.values); },
  birds(m) { applyBirds(m.values); },
  rejected() { stopped = true; showLogin("This name is already used on the server. Choose another name."); }
};

function connect() {
  if (!signedIn || stopped) return;
  clearTimeout(reconnectTimer);
  accepted = false;
  setConnection("connecting", "Connecting...");

  const proto = location.protocol === "https:" ? "wss" : "ws";
  const socket = new WebSocket(proto + "://" + location.host + "/ws");
  ws = socket;

  socket.addEventListener("open", () => {
    /* Registered like a player, under a name players are unlikely to use, then the key */
    socket.send(JSON.stringify({ type: "bonjour", name: "[GM] " + gmName }));
    socket.send(JSON.stringify({ type: "gmLogin", secret: gmSecret, organization: gmOrg }));
  });

  socket.addEventListener("message", (ev) => {
    let m;
    try { m = parseServerMessage(ev.data); } catch (e) { return; }
    const handler = m && handlers[m.type];
    if (handler) handler(m);
  });

  socket.addEventListener("close", () => {
    if (socket !== ws) return;   /* a socket we already replaced or closed on purpose */
    clearInterval(heartbeat);
    ws = null;
    accepted = false;
    updateStartButton();
    renderRound();
    if (!signedIn || stopped) return;
    if (gameState === "starting") gameState = "waiting";
    setConnection("offline", "Disconnected, retrying...");
    reconnectAttempts++;
    reconnectTimer = setTimeout(connect, Math.min(2000 * reconnectAttempts, 10000));
  });
}

function disconnect() {
  clearTimeout(reconnectTimer);
  clearInterval(heartbeat);
  const socket = ws;
  ws = null;
  accepted = false;
  if (socket) socket.close();
}

/* ---------- Events ---------- */

form.addEventListener("submit", (e) => {
  e.preventDefault();
  gmName = nameInput.value.trim();
  gmOrg = orgInput.value.trim();
  gmSecret = secretInput.value;
  if (!gmName || !gmOrg || !gmSecret) {
    errorEl.textContent = "Please enter your name, organization and game master key.";
    return;
  }
  save(localStorage, "cm.gm.name", gmName);
  save(localStorage, "cm.gm.org", gmOrg);
  save(sessionStorage, "cm.gm.secret", gmSecret);
  showDashboard();
});

byId("gmSignOut").addEventListener("click", () => {
  forget(localStorage, "cm.gm.name");
  forget(localStorage, "cm.gm.org");
  forget(sessionStorage, "cm.gm.secret");
  form.reset();
  showLogin();
});

/* On reload in the same tab, reconnect without asking again */
nameInput.value = load(localStorage, "cm.gm.name");
orgInput.value = load(localStorage, "cm.gm.org");
gmSecret = load(sessionStorage, "cm.gm.secret");
if (nameInput.value && orgInput.value && gmSecret) {
  gmName = nameInput.value;
  gmOrg = orgInput.value;
  showDashboard();
} else {
  showLogin();
}'