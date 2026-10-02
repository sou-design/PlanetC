as yet unclassified
stylesheet
	^ 'body { font-family: system-ui, sans-serif; max-width: 420px; margin: 4rem auto; padding: 0 1rem }
h1 { font-size: 1.2rem }
form { display: flex; gap: .5rem; margin-bottom: 1rem }
input[type=text] { flex: 1; padding: .6rem .8rem; font-size: 1rem }
button { padding: .6rem 1rem; font-size: 1rem; cursor: pointer }
button:disabled { opacity: .5; cursor: not-allowed }
.grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 0;
  margin: 1rem 0;
  border: 1px solid #999;
  border-radius: 6px;
  overflow: hidden;
}
.cell {
  aspect-ratio: 1;
  border: 1px solid #999;
  cursor: default; user-select: none; background: #f6f6f6;
  position: relative;
  display: flex; align-items: center; justify-content: center;
}
.cell.protect-selected { outline: 3px solid #b00020; outline-offset: -3px }
.cell.protected-shared { outline: 3px solid #b00020; outline-offset: -3px }
.cell.protectable, .cell.pickable { cursor: pointer }
.cell.pickable:hover { outline: 2px solid #333; outline-offset: -2px }
.harvester-tray {
  display: flex; gap: 10px; margin: .75rem 0;
  min-height: 40px; align-items: center;
}
.harvester-token {
  width: 28px; height: 28px; border-radius: 50%;
  border: 2px solid rgba(0,0,0,.3);
  display: flex; align-items: center; justify-content: center;
  font-size: .7rem; color: #fff; font-weight: bold;
}
.harvester-token.placed { opacity: .35 }
.harvester-token.locked { opacity: .35 }
.harvester-dot {
  width: 22px; height: 22px; border-radius: 50%;
  border: 2px solid rgba(0,0,0,.3);
  display: flex; align-items: center; justify-content: center;
  font-size: .65rem; color: #fff; font-weight: bold;
}
.hidden { display: none }
.error { color: #b00020; margin-top: .75rem }
.ok { color: #006400; margin-top: .75rem }
.status { font-size: .85rem; color: #555; margin-top: .5rem }
#sendBtn, #protectBtn { width: 100%; padding: .8rem; font-size: 1rem; margin-top: .5rem }
pre { background: #f6f6f6; padding: .75rem; overflow: auto; max-height: 160px }
.harvester-chips {
  position: absolute;
  bottom: 4px;
  left: 4px;
  right: 4px;
  display: flex;
  flex-wrap: wrap;
  gap: 3px;
}

.harvester-chip {
  display: flex;
  align-items: center;
  gap: 3px;
  background: rgba(255,255,255,0.85);
  border-radius: 4px;
  padding: 1px 4px;
  font-size: 11px;
  line-height: 1.2;
}

.harvester-chip-swatch {
  width: 8px;
  height: 8px;
  border-radius: 2px;
  display: inline-block;
}
.icon-bird { background-image: url(''/icons/bird.png''); }
.icon-poussin { background-image: url(''/icons/poussin.png''); }
.bird-icon-plain {
  position: absolute;
  top: 4px;
  left: 4px;
  width: 16px;
  height: 16px;
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
  display: inline-block;
}

.newborn-chip {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  align-items: center;
  gap: 3px;
  background: rgba(255,255,255,0.9);
  border-radius: 10px;
  padding: 2px 6px 2px 3px;
  font-size: 11px;
  line-height: 1.2;
}

.bird-chip-icon {
  width: 14px;
  height: 14px;
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
  display: inline-block;
}
.picker-backdrop {
  position: fixed; inset: 0; z-index: 10;
  background: rgba(0,0,0,.35);
  display: flex; align-items: center; justify-content: center;
  padding: 1rem;
}
.picker-backdrop.hidden { display: none }
.picker {
  background: #fff; border-radius: 10px; padding: 1rem;
  width: 100%; max-width: 320px;
  box-shadow: 0 8px 24px rgba(0,0,0,.25);
}
.picker-title { font-weight: bold; margin: 0 0 .75rem }
.picker-list { display: flex; flex-direction: column; gap: .5rem; margin-bottom: 1rem }
.picker-row {
  display: flex; align-items: center; gap: .6rem;
  padding: .5rem; border: 1px solid #ddd; border-radius: 6px; cursor: pointer;
}
.picker-row input { width: 20px; height: 20px; margin: 0 }
.picker-swatch {
  width: 28px; height: 28px; border-radius: 50%;
  border: 2px solid rgba(0,0,0,.3);
  display: flex; align-items: center; justify-content: center;
  font-size: .7rem; color: #fff; font-weight: bold;
}
.picker-where { font-size: .85rem; color: #555 }
#pickerDone { width: 100% }
#resultCard { margin: 1rem 0; padding: .8rem 1rem; border-radius: 8px; background: #eef7ef;
              border: 1px solid #b7dcbc; color: #1d4d27 }
#resultGain { margin: 0 0 .25rem; font-size: 1.15rem; font-weight: 600 }
#resultTotal { margin: 0 }'