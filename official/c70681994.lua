--魔装騎士ドラゴネス
--Dragoness the Wicked Knight
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,53153481,33064647)
end