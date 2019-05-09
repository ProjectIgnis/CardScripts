--スチームジャイロイド
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,18325492,44729197)
end
s.material_setcode=0x16
