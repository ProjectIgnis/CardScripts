--フュージョニスト
--Fusionist
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,38142739,83464209)
end
