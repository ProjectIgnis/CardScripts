--双頭の雷龍
--Twin-Headed Thunder Dragon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,31786629,2)
end