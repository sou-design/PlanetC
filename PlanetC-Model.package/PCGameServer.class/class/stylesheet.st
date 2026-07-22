as yet unclassified
stylesheet
	^ 'body { font-family: system-ui, sans-serif; max-width: 420px; margin: 4rem auto; padding: 0 1rem }
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
pre { background: #f6f6f6; padding: .75rem; overflow: auto; max-height: 160px }'