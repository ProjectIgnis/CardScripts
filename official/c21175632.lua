--聖女ジャンヌ
--St. Joan
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,84080938,57579381)
end
s.material_setcode=SET_DARKLORD