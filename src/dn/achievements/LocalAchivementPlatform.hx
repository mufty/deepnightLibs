package dn.achievements;

import hxd.Save;
import haxe.ds.StringMap;
import dn.data.AchievementDb;

/**
 * Local Achivement platform
 * Save in Array
 */
class LocalAchivementPlatform extends AbstractAchievementPlatform {
    final LOCAL_ACHIEVEMENT_STORAGE = "localAchievements";
	var dones : Array<String>;

	public function new() {
		super();
		isLocal = true;
	}

	public function updateDones(originalStatus:Array<String> = null) {
		if(originalStatus == null) originalStatus = [];
		dones = originalStatus;
	}
	public function init() {
        var def = null;
        var saved = Save.load(def, LOCAL_ACHIEVEMENT_STORAGE);
        if(saved != null) {
            dones = saved;
        } else {
            dones = [];
        }
    }

	function internalClear(ach:Achievements) {
        var ok = dones.remove(ach.Id.toString());
		trace(ach.Id+": "+(ok?"Ok":"FAILED!"));
    }

	public function getUnlocked(?achs:cdb.Types.ArrayRead<Achievements>):Array<String>{
        return dones;
    }

	public function unlock(ach:Achievements):Bool {
		if(!dones.contains(ach.Id.toString())) {
            dones.push(ach.Id.toString());
            Save.save(this.dones, LOCAL_ACHIEVEMENT_STORAGE);
            return true;
        }
		return false;
	}
}