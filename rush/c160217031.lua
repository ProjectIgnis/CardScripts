--究極完全態・グレート・モス
--Perfectly Ultimate Great Moth
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,14141448,40240595)
end