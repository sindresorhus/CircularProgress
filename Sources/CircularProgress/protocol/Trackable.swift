import Foundation

import Cocoa
/**
* Makes it possible to utilize mouseOver/mouseOut functionality on a view (Supports custom bezier path)
* - Abstract: In order for onOut / onOver to work, we need: a few methods and variables methods: Override: `move,entered,exited,hitTest`, variables: hasMouseEntered, createTrackingArea
* - Discussion: we use viewUnderMouse and hittest to make sure overlapping views also gets their say. Because otherwise the tracking area sort of becomes "see-through"
* - Discussion: We do not store trackingArea in a variable, because the supertype should have as few variables as possible, to keep state simple, for now, only HasMOuseEntered is require for this solution to work
* - Caution: Its a little bit tricky to setup onOver onOut with a non-rectangular shape, so the code is a bit complex. I'm sure there are areas were the code can be improved but its not too far from being optimal
* - Caution: a view can have many tracking areas, the current workflow does not account for that, and is out-of scope for this solution
*/
protocol Trackable:class{
	var path:CGPath? {get}
}
extension Trackable where Self:NSView{
	/**
	* Creates a new tracking area
	* - Note: the only way to update trackingArea is to remove it and add a new one
	*/
	internal func createTrackingArea(_ options:NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited, .mouseMoved]){
		trackingAreas.forEach{ trackingArea in
			self.removeTrackingArea(trackingArea)/*Remove old trackingArea if it exists*/
		}
		let trackingArea:NSTrackingArea = .init(rect: self.bounds, options: options, owner: self, userInfo: nil)
		self.addTrackingArea(trackingArea)
	}
	/**
	* Stores/generates the path to hitTest against
	* - Note: override this if the view has needs a non-rectangular onOut/Over threshold
	* - Note: can be overriden in class or extension of class
	*/
	var path:CGPath? {return nil}
}
