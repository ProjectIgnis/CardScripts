--合成魔術
--Synthesis Spell
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreaterCode(c,6,nil,84385264)
end