--魔導騎士ギルティア
--Giltia the D. Knight
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,89272878,10071456)
end