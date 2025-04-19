--E・HERO マッドボールマン
--Elemental HERO Mudballman (Rush)
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:AddMustBeFusionSummoned()
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,79979666,84327329)
end
s.material_setcode={0x8,0x3008}