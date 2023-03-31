--髑髏の司祭ヤスシ
--Yasushi the Skull Knight
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,80604091,78010363)
end
s.listed_names={80604091,78010363}
s.illegal=true
