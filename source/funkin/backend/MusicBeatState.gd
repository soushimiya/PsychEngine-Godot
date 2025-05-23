extends Node2D
class_name MusicBeatState

var curSection:int = 0
var stepsToDo:int = 0

var curStep:int = 0
var curBeat:int = 0

var curDecStep:float = 0
var curDecBeat:float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var oldStep:int = curStep
	updateCurStep()
	updateBeat()
	
	if (oldStep != curStep):
		if (curStep > 0):
			stepHit()
		if (PlayState.SONG != null):
			if (oldStep < curStep):
				updateSection()
			else:
				rollbackSection()

func updateSection():
	if (stepsToDo < 1):
		stepsToDo = round(getBeatsOnSection() * 4)
	while (curStep >= stepsToDo):
		curSection += 1
		var beats:float = getBeatsOnSection()
		stepsToDo += round(beats * 4)
		sectionHit()
		
func rollbackSection():
	if (curStep < 0):
		return
	var lastSection:int = curSection
	curSection = 0
	stepsToDo = 0
	for i in range(PlayState.SONG.notes.size()):
		if (PlayState.SONG.notes[i] != null):
			stepsToDo += round(getBeatsOnSection() * 4)
			if (stepsToDo > curStep): break

			curSection+= 1

		if (curSection > lastSection):
			sectionHit()
		
func updateCurStep():
	var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition)

	var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrotchet
	curDecStep = lastChange.stepTime + shit
	curStep = lastChange.stepTime + floorf(shit)

func updateBeat():
	curBeat = floor(curStep / 4)
	curDecBeat = curDecStep / 4
	
func getBeatsOnSection():
	var val = 4
	if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null && PlayState.SONG.notes[curSection].has("sectionBeats")):
		val = PlayState.SONG.notes[curSection].sectionBeats
	return val

func stepHit():
	if (curStep % 4 == 0):
		beatHit()
		
func beatHit():
	pass

func sectionHit():
	if (PlayState.SONG.notes[curSection] != null):
		if (PlayState.SONG.notes[curSection].has("changeBPM") && PlayState.SONG.notes[curSection].changeBPM):
			Conductor.bpm = PlayState.SONG.notes[curSection].bpm

func switchState(state):
	
	$/root/Main/transition/player.play("defaultIn")
	$/root/Main/transition/player.animation_finished.connect(func(name):
		if name.ends_with("In"):
			$/root/Main/transition/player.play("defaultOut")
			$/root/Main/game.add_child(state.instantiate())
			$/root/Main/game.remove_child(self)
			self.queue_free()
	)
