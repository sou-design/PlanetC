window.PlanetCharts = (() => {
  const SVG_NS = "http://www.w3.org/2000/svg";
  const COLOR_HARVEST = "#2a78d6";
  const COLOR_BIRDS = "#008300";
  const COLOR_OTHER = "#c4c3be";
  const COLOR_BIOMASS = "#4c7a1f";
  const COLOR_HARVESTED = "#d9a441";
  const FAMILY_COLORS = ["#2a78d6", "#d6552a", "#8a3ffc", "#d12771", "#009d9a", "#b28600", "#5a6872", "#ee538b"];
  const ALL = "__all__";
  const SURFACE = "#fcfcfb";

  const CSS = `
.pc-bar { display: flex; flex-wrap: wrap; align-items: center; gap: .75rem; margin: .75rem 0 }
.pc-mode { display: inline-flex; border: 1px solid #bbb; border-radius: 6px; overflow: hidden }
.pc-mode button { border: 0; background: #fff; padding: .4rem .8rem; cursor: pointer; font-size: .9rem; color: #222 }
.pc-mode button + button { border-left: 1px solid #bbb }
.pc-mode button[aria-pressed="true"] { background: #333; color: #fff }
.pc-bar label { font-size: .9rem; color: #444; display: inline-flex; align-items: center; gap: .4rem }
.pc-bar select { padding: .3rem .4rem; font-size: .9rem }
.pc-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: .75rem; margin-bottom: 1rem }
.pc-card { margin: 0; background: ${SURFACE}; border: 1px solid #e2e2e2; border-radius: 8px; padding: .6rem .7rem .5rem }
.pc-card figcaption { font-weight: 600; font-size: .95rem; color: #0b0b0b; margin-bottom: .25rem }
.pc-card svg { display: block; width: 100%; height: auto; overflow: visible }
.pc-card .pc-gridlines line { stroke: #e6e6e3; stroke-width: 1 }
.pc-card .pc-axis text { fill: #52514e; font-size: 11px; font-variant-numeric: tabular-nums }
.pc-card .pc-end { fill: #0b0b0b; font-size: 11px; font-weight: 600 }
.pc-card .pc-hit { fill: transparent }
.pc-card .pc-cross { stroke: #9b9a95; stroke-width: 1 }
.pc-legend { display: flex; align-items: center; gap: .35rem; margin: .3rem 0 0; font-size: .8rem; color: #52514e }
.pc-legend i { display: inline-block; width: 14px; height: 2px; border-radius: 1px; margin-left: .5rem }
.pc-legend i:first-child { margin-left: 0 }
.pc-tip { position: fixed; z-index: 50; pointer-events: none; background: #fff; border: 1px solid #ddd; border-radius: 6px;
          box-shadow: 0 4px 12px rgba(0,0,0,.15); padding: .4rem .55rem; font-size: .8rem; color: #0b0b0b;
          font-variant-numeric: tabular-nums; max-width: 240px }
.pc-tip b { display: block; margin-bottom: .15rem }
.pc-tip .pc-row { display: flex; justify-content: space-between; gap: .8rem; color: #52514e }
.pc-tip .pc-row.pc-focus { color: #0b0b0b; font-weight: 600 }
.pc-hidden { display: none }
`;

  let tip = null;

  function setup() {
    if (tip) return;
    const style = document.createElement("style");
    style.textContent = CSS;
    document.head.appendChild(style);
    tip = document.createElement("div");
    tip.className = "pc-tip pc-hidden";
    tip.setAttribute("role", "tooltip");
    document.body.appendChild(tip);
  }

  function el(tag, attrs, parent) {
    const node = document.createElementNS(SVG_NS, tag);
    Object.entries(attrs || {}).forEach(([k, v]) => node.setAttribute(k, v));
    if (parent) parent.appendChild(node);
    return node;
  }

  function escapeHtml(text) {
    return String(text).replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;" }[c]));
  }

  function showTip(event, html) {
    tip.innerHTML = html;
    tip.classList.remove("pc-hidden");
    const pad = 12, w = tip.offsetWidth, h = tip.offsetHeight;
    let x = event.clientX + pad, y = event.clientY + pad;
    if (x + w > window.innerWidth - 4) x = event.clientX - w - pad;
    if (y + h > window.innerHeight - 4) y = event.clientY - h - pad;
    tip.style.left = x + "px";
    tip.style.top = y + "px";
  }

  function hideTip() { tip.classList.add("pc-hidden"); }

  function cumulate(values) {
    let sum = 0;
    return values.map(v => (sum += v || 0));
  }

  function niceScale(value) {
    const raw = Math.max(value, 1) / 4;
    const power = Math.pow(10, Math.floor(Math.log10(raw)));
    const n = raw / power;
    const step = Math.max(1, (n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10) * power);
    return { max: step * Math.max(1, Math.ceil(value / step)), step };
  }

  function drawLines(holder, rounds, series, focus) {
    holder.innerHTML = "";
    const scale = niceScale(Math.max(0, ...series.flatMap(s => s.values)));
    const W = 360, H = 190, m = { top: 10, right: 40, bottom: 22, left: 34 };
    const svg = el("svg", { viewBox: "0 0 " + W + " " + H, role: "img" }, holder);
    const plot = { x: m.left, y: m.top, w: W - m.left - m.right, h: H - m.top - m.bottom };
    const yOf = v => plot.y + plot.h - (v / scale.max) * plot.h;
    const band = plot.w / Math.max(rounds, 1);
    const xOf = i => plot.x + band * (i + 0.5);
    const grid = el("g", { class: "pc-gridlines" }, svg);
    const axis = el("g", { class: "pc-axis" }, svg);
    for (let v = 0; v <= scale.max; v += scale.step) {
      el("line", { x1: plot.x, x2: plot.x + plot.w, y1: yOf(v), y2: yOf(v) }, grid);
      el("text", { x: plot.x - 6, y: yOf(v) + 4, "text-anchor": "end" }, axis).textContent = v;
    }
    const every = Math.ceil(rounds / 10);
    for (let i = 0; i < rounds; i++) {
      if (i % every && i !== rounds - 1) continue;
      el("text", { x: xOf(i), y: plot.y + plot.h + 15, "text-anchor": "middle" }, axis).textContent = "R" + (i + 1);
    }
    // Missing values (null) leave a gap in the line
    const path = values => values.map((v, i) => v == null ? "" : ((i && values[i - 1] != null) ? "L" : "M") + xOf(i) + "," + yOf(v)).join("");
    const isStrong = s => focus === ALL || s.name === focus;
    const ordered = series.filter(s => !isStrong(s)).concat(series.filter(isStrong));
    ordered.forEach(s => {
      const strong = isStrong(s);
      const color = strong ? s.color : COLOR_OTHER;
      if (s.values.filter(v => v != null).length > 1) {
        el("path", { d: path(s.values), fill: "none", stroke: SURFACE, "stroke-width": 5, "stroke-linejoin": "round", "stroke-linecap": "round" }, svg);
        el("path", { d: path(s.values), fill: "none", stroke: color, "stroke-width": 2, "stroke-linejoin": "round", "stroke-linecap": "round" }, svg);
      }
      if (strong) {
        s.values.forEach((v, i) => { if (v != null) el("circle", { cx: xOf(i), cy: yOf(v), r: 4, fill: color, stroke: SURFACE, "stroke-width": 2 }, svg); });
        const lastIndex = s.values.map(v => v != null).lastIndexOf(true);
        if (lastIndex >= 0 && focus !== ALL)
          el("text", { class: "pc-end", x: xOf(lastIndex) + 8, y: yOf(s.values[lastIndex]) + 4 }, svg).textContent = s.values[lastIndex];
      }
    });
    const cross = el("line", { class: "pc-cross", y1: plot.y, y2: plot.y + plot.h, visibility: "hidden" }, svg);
    for (let i = 0; i < rounds; i++) {
      const hit = el("rect", { class: "pc-hit", x: xOf(i) - band / 2, y: plot.y, width: band, height: plot.h }, svg);
      hit.addEventListener("mousemove", e => {
        cross.setAttribute("x1", xOf(i));
        cross.setAttribute("x2", xOf(i));
        cross.setAttribute("visibility", "visible");
        const rows = series.map(s => ({ name: s.name, v: s.values[i] ?? "-" })).sort((a, b) => (Number(b.v) || 0) - (Number(a.v) || 0));
        showTip(e, "<b>Round " + (i + 1) + "</b>" + rows.map(r =>
          "<div class=\"pc-row" + (r.name === focus || focus === ALL ? " pc-focus" : "") + "\"><span>" + escapeHtml(r.name) +
          "</span><span>" + r.v + "</span></div>").join(""));
      });
      hit.addEventListener("mouseleave", () => { cross.setAttribute("visibility", "hidden"); hideTip(); });
    }
  }

  function mount(container, options) {
    setup();
    const state = { mode: "round", focus: (options && options.focus) || ALL, data: null };
    container.innerHTML = `
      <div class="pc-bar">
        <div class="pc-mode" role="group" aria-label="Values">
          <button type="button" data-mode="round" aria-pressed="true">Per round</button>
          <button type="button" data-mode="total" aria-pressed="false">Cumulative</button>
        </div>
        <label>Family <select></select></label>
      </div>
      <div class="pc-grid">
        <figure class="pc-card"><figcaption></figcaption><div></div><p class="pc-legend"></p></figure>
        <figure class="pc-card"><figcaption></figcaption><div></div></figure>
        <figure class="pc-card"><figcaption></figcaption><div></div></figure>
      </div>`;
    const select = container.querySelector("select");
    const cards = container.querySelectorAll(".pc-card");
    const familyLegend = container.querySelector(".pc-legend");

    function render() {
      const data = state.data;
      if (!data || !data.families || !data.families.length || !data.rounds) return;
      const rounds = data.rounds;
      const pick = values => state.mode === "total" ? cumulate(values) : values;
      const gainsOf = f => Array.from({ length: rounds }, (_, i) => (f.gains || [])[i] || 0);
      const rangerOf = i => (data.ranger || []).find(r => r.round === i + 1) || {};
      const births = Array.from({ length: rounds }, (_, i) => rangerOf(i).newborns || 0);
      const afterRegen = Array.from({ length: rounds }, (_, i) => rangerOf(i).biomass ?? null);
      const names = data.families.map(f => f.name).sort((a, b) => a.localeCompare(b));
      const colorOf = name => names.length > 1 ? FAMILY_COLORS[names.indexOf(name) % FAMILY_COLORS.length] : COLOR_HARVEST;
      if (state.focus !== ALL && !names.includes(state.focus)) state.focus = ALL;
      const options = [ALL].concat(names);
      if (select.options.length !== options.length || Array.from(select.options).some((o, i) => o.value !== options[i])) {
        select.innerHTML = "";
        options.forEach(n => select.add(new Option(n === ALL ? "All" : n, n)));
      }
      select.value = state.focus;
      familyLegend.innerHTML = state.focus === ALL
        ? names.map(n => "<i style=\"background:" + colorOf(n) + "\"></i>" + escapeHtml(n)).join("")
        : "<i style=\"background:" + colorOf(state.focus) + "\"></i>" + escapeHtml(state.focus) +
          "<i style=\"background:" + COLOR_OTHER + "\"></i>Other families";
      const suffix = state.mode === "total" ? " (cumulative)" : " per round";
      cards[0].querySelector("figcaption").textContent = "Harvest per family" + suffix;
      cards[1].querySelector("figcaption").textContent = "Newborn birds" + suffix;
      cards[2].querySelector("figcaption").textContent = "Biomass on the grid";
      drawLines(cards[0].querySelector("div"), rounds,
        data.families.map(f => ({ name: f.name, color: colorOf(f.name), values: pick(gainsOf(f)) })), state.focus);
      drawLines(cards[1].querySelector("div"), rounds, [{ name: "Newborn birds", color: COLOR_BIRDS, values: pick(births) }], "Newborn birds");
      
      drawLines(cards[2].querySelector("div"), rounds, [
        { name: "Biomass", color: COLOR_BIOMASS, values: afterRegen }], "Biomass");
    }

    container.querySelector(".pc-mode").addEventListener("click", e => {
      const button = e.target.closest("button[data-mode]");
      if (!button) return;
      state.mode = button.dataset.mode;
      container.querySelectorAll(".pc-mode button").forEach(b => b.setAttribute("aria-pressed", String(b === button)));
      render();
    });
    select.addEventListener("change", () => { state.focus = select.value; render(); });

    return {
      update(data) { state.data = data; render(); },
      setFocus(name) { state.focus = name || ALL; render(); },
      hasData() { return !!(state.data && state.data.rounds && state.data.families && state.data.families.length); }
    };
  }

  return { mount };
})();