--砂の魔女
--Mystical Sand
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,13039848,93221206)
end