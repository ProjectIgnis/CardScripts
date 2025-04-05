--バラに棲む悪霊
--Rose Spectre of Dunn
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,41392891,29802344)
end