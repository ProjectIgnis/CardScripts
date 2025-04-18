--ヒューマノイド・ドレイク
--Humanoid Worm Drake
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,73216412,46821314)
end