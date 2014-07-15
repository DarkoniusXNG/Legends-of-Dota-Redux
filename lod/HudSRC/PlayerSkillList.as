﻿package  {
	import flash.display.MovieClip;

	public class PlayerSkillList extends MovieClip {
		// Our skills
		public var skill0:MovieClip;
		public var skill1:MovieClip;
		public var skill2:MovieClip;
		public var skill3:MovieClip;
		public var skill4:MovieClip;
		public var skill5:MovieClip;

		// Stores our color picker
		public var color:MovieClip;

		// When our skill list is created
		public function PlayerSkillList(totalSkills:Number) {
			if(totalSkills <= 4) {
				this.gotoAndStop(1);
			} else if(totalSkills == 5) {
				this.gotoAndStop(2);
			} else {
				this.gotoAndStop(3);
			}
		}

		// Sets the color of this skill list
		public function setColor(num:Number) {
			this.color.gotoAndStop(num+1);
		}
	}

}
