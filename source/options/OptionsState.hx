package options;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Debug Mode', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
		  	#if mobile
		  	removeVirtualPad();
		  	#end
				openSubState(new options.NotesSubState());
			case 'Controls':
		  	#if mobile
		  	removeVirtualPad();
		  	#end
				openSubState(new options.ControlsSubState());
			case 'Graphics':
		  	#if mobile
		  	removeVirtualPad();
		  	#end
				openSubState(new options.GraphicsSettingsSubState());
			case 'Debug Mode':
		  	#if mobile
		  	removeVirtualPad();
		  	#end
				openSubState(new UnlocksDebug());
			case 'Visuals and UI':
		  	#if mobile
		  	removeVirtualPad();
		  	#end
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
		  	#if mobile
		  	removeVirtualPad();
		  	#end
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				if (TitleState.introMusic != null && TitleState.introMusic.playing)
					TitleState.introMusic.stop();
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		if(Unlocks.newMenuItem.contains("options")) {
			Unlocks.newMenuItem.remove("options");
			Unlocks.saveUnlocks();
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuOptions'));
		//bg.color = 0xFF09F25E;
		bg.setGraphicSize(Std.int(bg.width * 0.6));
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		add(selectorRight);

		#if mobile
		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press BACK of your phone to go back to MainMenu', 16);
		tipText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2.4;
		tipText.scrollFactor.set();
		add(tipText);
		#end

		changeSelection();
		ClientPrefs.saveSettings();

    #if mobile
    addVirtualPad(UP_DOWN, A_B_C);
    #end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK #if mobile || FlxG.android.justReleased.BACK #end) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
	
		#if mobile
		if (virtualPad.buttonC.justPressed) {
		  #if mobile 
		  removeVirtualPad();
		  #end
		  openSubState(new mobile.MobileControlsSubState());
		}
		#end
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}