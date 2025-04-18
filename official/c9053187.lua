--覚醒の勇士 ガガギゴ
--Gagagigo the Risen
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,3)
	c:EnableReviveLimit()
end