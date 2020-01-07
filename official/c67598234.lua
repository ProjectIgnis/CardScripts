--電影の騎士ガイアセイバー
--Gaiasaber, the Video Knight
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2)
	c:EnableReviveLimit()
end
