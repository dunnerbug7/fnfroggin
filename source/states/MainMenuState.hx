package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.ui.FlxButton;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * The main menu state for the game.
 * Handles menu buttons, portrait displays, and transitions.
 */
class MainMenuState extends FlxState {
    // Version info
    public static var psychEngineVersion:String = '0.7.3';
    
    // UI Constants
    private static inline var FADE_DURATION:Float = 0.3;
    private static inline var PORTRAIT_SCALE:Float = 1.5;
    private static inline var MAIN_BUTTON_SCALE:Float = 1.7;
    private static inline var GALLERY_BUTTON_SCALE:Float = 0.5;
    private static inline var CHECKER_SIZE:Int = 64;
    private static inline var BUTTON_HOVER_RISE:Float = 10; // How many pixels the button rises when hovered
    private static inline var BUTTON_HOVER_DURATION:Float = 0.15; // Duration of hover animation
    private static inline var LOGO_SCALE:Float = 0.4; // Reduced scale for the menu logo
    private static inline var BG_FADE_DURATION:Float = 0.3; // Background color transition duration
    
    // Background
    private var defaultCheckerBg:FlxBackdrop;
    private var storyModeCheckerBg:FlxBackdrop;
    private var freePlayCheckerBg:FlxBackdrop;
    private var optionsCheckerBg:FlxBackdrop;
    private var currentBg:FlxBackdrop;
    
    // Logo
    private var menuLogo:FlxSprite;
    
    // Buttons
    private var storyModeButton:FlxButton;
    private var freePlayButton:FlxButton;
    private var optionsButton:FlxButton;
    private var galleryButton:FlxButton;
    
    // Portraits
    private var storyModePortrait:FlxSprite;
    private var freePlayPortrait:FlxSprite;
    private var optionsPortrait:FlxSprite;
    private var currentPortrait:FlxSprite;
    private var fadingOutPortrait:FlxSprite;
    
    // Store original Y positions for button hover animation
    private var buttonOriginalY:Map<FlxButton, Float>;

    /**
     * Initialize the state and create all UI elements
     */
    override function create() {
        // Enable mouse cursor
        FlxG.mouse.visible = true;
        
        // Initialize button Y position tracking
        buttonOriginalY = new Map<FlxButton, Float>();
        
        // Create background
        createBackgrounds();
        
        // Create portraits
        createPortraits();
        
		createLogo();

        // Create buttons
        createButtons();
        
        // Show default portrait (story mode)
        switchToPortrait(storyModePortrait);
        
        super.create();
    }
    
    /**
     * Update function called each frame
     * @param elapsed Time elapsed since last frame
     */
    override function update(elapsed:Float) {
        super.update(elapsed);
        // All button handling is handled by the FlxButton class
    }
    
    // ===== CREATION METHODS =====
    
    /**
     * Creates all background variations with different color palettes
     */
    private function createBackgrounds():Void {
        // Create default background (cream/yellow)
        var defaultGraphic = createCheckerBitmap(CHECKER_SIZE, 
            FlxColor.fromString("#eed97e"), FlxColor.fromString("#f4e9bb"));
        defaultCheckerBg = createCheckerBackdrop(defaultGraphic);
        defaultCheckerBg.alpha = 1; // Default is visible
        currentBg = defaultCheckerBg;
        
        // Create story mode background (green)
        var storyModeGraphic = createCheckerBitmap(CHECKER_SIZE, 
            FlxColor.fromString("#00e34f"), FlxColor.fromString("#0cf383"));
        storyModeCheckerBg = createCheckerBackdrop(storyModeGraphic);
        storyModeCheckerBg.alpha = 0; // Initially invisible
        
        // Create free play background (blue)
        var freePlayGraphic = createCheckerBitmap(CHECKER_SIZE, 
            FlxColor.fromString("#0e7dfe"), FlxColor.fromString("#004be3"));
        freePlayCheckerBg = createCheckerBackdrop(freePlayGraphic);
        freePlayCheckerBg.alpha = 0; // Initially invisible
        
        // Create options background (yellow/gold)
        var optionsGraphic = createCheckerBitmap(CHECKER_SIZE, 
            FlxColor.fromString("#e3a401"), FlxColor.fromString("#ffdb0c"));
        optionsCheckerBg = createCheckerBackdrop(optionsGraphic);
        optionsCheckerBg.alpha = 0; // Initially invisible
    }
    
    /**
     * Creates a checker backdrop with standard settings
     * @param graphic The graphic to use for the backdrop
     * @return The created backdrop
     */
    private function createCheckerBackdrop(graphic:flixel.graphics.FlxGraphic):FlxBackdrop {
        var backdrop = new FlxBackdrop(graphic);
        backdrop.scrollFactor.set(0, 0);
        backdrop.velocity.set(-50, -30);
        add(backdrop);
        return backdrop;
    }
    
    /**
     * Creates the menu logo at the top of the screen
     */
    private function createLogo():Void {
        menuLogo = new FlxSprite(0, 0);
        menuLogo.loadGraphic(Paths.image('mainmenu/menu_logo'));
        menuLogo.antialiasing = true;
        menuLogo.scale.set(LOGO_SCALE, LOGO_SCALE);
        menuLogo.updateHitbox();
        
        menuLogo.x = (FlxG.width - menuLogo.width) / 2;

        add(menuLogo);
    }
    
    /**
     * Creates all portrait sprites (initially invisible)
     */
    private function createPortraits():Void {
        // Story Mode Portrait
        storyModePortrait = createPortrait('mainmenu/story_mode_portrait');
        
        // Free Play Portrait
        freePlayPortrait = createPortrait('mainmenu/free_play_portrait');
        
        // Options Portrait
        optionsPortrait = createPortrait('mainmenu/options_portrait');
        
        // Initialize portrait tracking variables
        currentPortrait = null;
        fadingOutPortrait = null;
    }
    
    /**
     * Creates a single portrait with standard settings
     * @param imagePath The path to the portrait image
     * @return The created portrait sprite
     */
    private function createPortrait(imagePath:String):FlxSprite {
        var portrait = new FlxSprite(0, 0);
        portrait.loadGraphic(Paths.image(imagePath));
        portrait.antialiasing = true;
        portrait.scale.set(PORTRAIT_SCALE, PORTRAIT_SCALE);
        portrait.updateHitbox();
        positionPortrait(portrait);
        portrait.alpha = 0;
        add(portrait);
        return portrait;
    }
    
    /**
     * Creates all menu buttons
     */
    private function createButtons():Void {
        // Story Mode button (centered bottom)
        storyModeButton = createMainButton(
            'mainmenu/story_mode_idle', 
            'mainmenu/story_mode_hovered',
            onStoryModeClick,
            storyModePortrait
        );
        storyModeButton.x = (FlxG.width - storyModeButton.width) / 2;
        storyModeButton.y = FlxG.height - storyModeButton.height - 20;
        storeButtonYPosition(storyModeButton);
        
        // Free Play button (bottom left)
        freePlayButton = createMainButton(
            'mainmenu/free_play_idle', 
            'mainmenu/free_play_hovered',
            onFreePlayClick,
            freePlayPortrait
        );
        freePlayButton.x = 40;
        freePlayButton.y = FlxG.height - freePlayButton.height - 90;
        storeButtonYPosition(freePlayButton);
        
        // Options button (bottom right)
        optionsButton = createMainButton(
            'mainmenu/options_idle', 
            'mainmenu/options_hovered',
            onOptionsClick,
            optionsPortrait
        );
        optionsButton.x = FlxG.width - optionsButton.width - 40;
        optionsButton.y = FlxG.height - optionsButton.height - 90;
        storeButtonYPosition(optionsButton);
        
        // Gallery button (top right)
        galleryButton = createButton(
            'mainmenu/gallery_button_idle', 
            'mainmenu/gallery_button_hovered',
            onGalleryClick,
            GALLERY_BUTTON_SCALE,
            null
        );
        galleryButton.x = FlxG.width - galleryButton.width;
        galleryButton.y = 0;
        storeButtonYPosition(galleryButton);
    }
    
    /**
     * Creates a main menu button with standard scale
     * @param idleImagePath Path to idle state image
     * @param hoverImagePath Path to hover state image
     * @param callback Function to call when clicked
     * @param portrait Associated portrait to show on hover
     * @return The created button
     */
    private function createMainButton(
        idleImagePath:String, 
        hoverImagePath:String,
        callback:Void->Void,
        portrait:FlxSprite
    ):FlxButton {
        return createButton(
            idleImagePath, 
            hoverImagePath, 
            callback, 
            MAIN_BUTTON_SCALE, 
            portrait
        );
    }
    
    /**
     * Creates a button with custom scale and callbacks
     * @param idleImagePath Path to idle state image
     * @param hoverImagePath Path to hover state image
     * @param callback Function to call when clicked
     * @param scale Button scale
     * @param portrait Associated portrait to show on hover (can be null)
     * @return The created button
     */
    private function createButton(
        idleImagePath:String, 
        hoverImagePath:String,
        callback:Void->Void,
        scale:Float,
        portrait:FlxSprite
    ):FlxButton {
        var button = new FlxButton(0, 0, "", callback);
        button.loadGraphic(Paths.image(idleImagePath));
        button.antialiasing = true;
        button.scale.set(scale, scale);
        button.updateHitbox();
        setupButtonCallbacks(button, idleImagePath, hoverImagePath, scale, portrait);
        add(button);
        return button;
    }
    
    /**
     * Store a button's original Y position for hover animation
     * @param button The button to store position for
     */
    private function storeButtonYPosition(button:FlxButton):Void {
        buttonOriginalY.set(button, button.y);
    }
    
    // ===== UTILITY METHODS =====
    
    /**
     * Creates a checkered bitmap pattern with specified colors
     * @param size Size of each checker square
     * @param color1 First color for the checker pattern
     * @param color2 Second color for the checker pattern
     * @return The created bitmap as a FlxGraphic
     */
    private function createCheckerBitmap(size:Int, color1:FlxColor, color2:FlxColor):flixel.graphics.FlxGraphic {
        var bitmap = new openfl.display.BitmapData(size * 2, size * 2, true, 0);
        
        var rect1 = new openfl.geom.Rectangle(0, 0, size, size);
        var rect2 = new openfl.geom.Rectangle(size, 0, size, size);
        var rect3 = new openfl.geom.Rectangle(size, size, size, size);
        var rect4 = new openfl.geom.Rectangle(0, size, size, size);
    
        bitmap.fillRect(rect1, color1);
        bitmap.fillRect(rect2, color2);
        bitmap.fillRect(rect3, color1);
        bitmap.fillRect(rect4, color2);
    
        return flixel.graphics.FlxGraphic.fromBitmapData(bitmap);
    }
    
    /**
     * Position a portrait at the center of the screen
     * @param portrait The portrait to position
     */
    private function positionPortrait(portrait:FlxSprite):Void {
        // Center horizontally
        portrait.x = (FlxG.width - portrait.width) / 2;
        
        // Position slightly below the center of the Y axis
        portrait.y = (FlxG.height * 0.55) - (portrait.height / 2);
    }
    
	private function setupButtonCallbacks(
		button:FlxButton, 
		idleImagePath:String, 
		hoverImagePath:String, 
		scale:Float, 
		portrait:FlxSprite
	):Void {
		button.onOver.callback = function() {
			// Change button image
			button.loadGraphic(Paths.image(hoverImagePath));
			button.scale.set(scale, scale);
			button.updateHitbox();
			
			// Check at execution time, not definition time
			if (button != galleryButton) {
				FlxTween.cancelTweensOf(button, ["y"]);
				FlxTween.tween(button, {y: buttonOriginalY.get(button) - BUTTON_HOVER_RISE}, 
					BUTTON_HOVER_DURATION, {ease: FlxEase.quartOut});
                    
                // Switch background based on which button was hovered
                if (button == storyModeButton) {
                    switchToBackground(storyModeCheckerBg);
                } else if (button == freePlayButton) {
                    switchToBackground(freePlayCheckerBg);
                } else if (button == optionsButton) {
                    switchToBackground(optionsCheckerBg);
                }
			}
			
			// Switch to the corresponding portrait if provided
			if (portrait != null) {
				switchToPortrait(portrait);
			}
		};
	
		button.onOut.callback = function() {
			// Change button image
			button.loadGraphic(Paths.image(idleImagePath));
			button.scale.set(scale, scale);
			button.updateHitbox();
			
			// Check at execution time, not definition time
			if (button != galleryButton) {
				FlxTween.cancelTweensOf(button, ["y"]);
				FlxTween.tween(button, {y: buttonOriginalY.get(button)}, 
					BUTTON_HOVER_DURATION, {ease: FlxEase.quartOut});
                    
                // Switch back to default background
                switchToBackground(defaultCheckerBg);
			}
			
			// Switch back to the default portrait (story mode)
			switchToPortrait(storyModePortrait);
		};
	}
    
    /**
     * Switch to a new portrait with fade animation
     * @param newPortrait The portrait to switch to
     */
    private function switchToPortrait(newPortrait:FlxSprite):Void {
        // If it's the same portrait or null, do nothing
        if (newPortrait == currentPortrait || newPortrait == null)
            return;
            
        // If we have a current portrait, fade it out
        if (currentPortrait != null) {
            // Cancel any existing tweens on the current portrait
            FlxTween.cancelTweensOf(currentPortrait);
            
            // Store reference to the fading out portrait
            fadingOutPortrait = currentPortrait;
            
            // Fade out the current portrait
            FlxTween.tween(fadingOutPortrait, {alpha: 0}, FADE_DURATION, {
                ease: FlxEase.quartOut,
                onComplete: function(_) {
                    fadingOutPortrait = null;
                }
            });
        }
        
        // Update the current portrait reference
        currentPortrait = newPortrait;
        
        // Cancel any existing tweens on the new portrait
        FlxTween.cancelTweensOf(currentPortrait);
        
        // Fade in the new portrait
        currentPortrait.alpha = 0;
        FlxTween.tween(currentPortrait, {alpha: 1}, FADE_DURATION, {
            ease: FlxEase.quartIn
        });
    }
    
    /**
     * Switch to a new background with fade animation
     * @param newBg The background to switch to
     */
    private function switchToBackground(newBg:FlxBackdrop):Void {
        // If it's the same background, do nothing
        if (newBg == currentBg)
            return;
            
        // Fade out all backgrounds except the new one
        for (bg in [defaultCheckerBg, storyModeCheckerBg, freePlayCheckerBg, optionsCheckerBg]) {
            if (bg != newBg) {
                FlxTween.cancelTweensOf(bg);
                FlxTween.tween(bg, {alpha: 0}, BG_FADE_DURATION, {ease: FlxEase.quartOut});
            }
        }
        
        // Update the current background reference
        currentBg = newBg;
        
        // Cancel any existing tweens on the new background
        FlxTween.cancelTweensOf(currentBg);
        
        // Fade in the new background
        FlxTween.tween(currentBg, {alpha: 1}, BG_FADE_DURATION, {ease: FlxEase.quartIn});
    }
    
    // ===== BUTTON CALLBACKS =====
    
    private function onGalleryClick():Void {
        trace("Gallery button clicked!");
        // Add gallery action here
    }

    private function onStoryModeClick():Void {
        trace("Story Mode button clicked!");
        // Add story mode action here
    }

    private function onFreePlayClick():Void {
        trace("Free Play button clicked!");
        // Add free play action here
    }

    private function onOptionsClick():Void {
        trace("Options button clicked!");
        // Add options action here
    }
}