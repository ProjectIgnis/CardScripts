--炎の騎士 キラー
--Charubin the Fire Knight
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,36121917,96851799)
end