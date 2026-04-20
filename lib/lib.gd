class_name Lib

class Item:
	var name: String
	var effect: int
	var is_equipment: bool
	var is_equipped: bool
	var attack_area: Array[Vector2i]
	var attack_damage: int
	func _init(name: String, effect: int, is_equipment: bool = false, attack_area: Array[Vector2i] = [], attack_damage: int = 0):
		self.name = name
		self.effect = effect
		self.is_equipment = is_equipment
		self.is_equipped = false
		self.attack_area = attack_area
		self.attack_damage = attack_damage
		# ITEM EFFECTS:
		# 0: repair kit (restore hp)
		# 1: signal booster (temporary sight)
		# 2: map scanner (reveals map)
		# 3: mysterious totem (one time revive)
		# 4: plating kit (max hp boost)
		# 5: glass dust (damages enemy in front)
		# 7: C4 (hits every enemy in the room)
		# 8: charm bracelet (no effect)
		
