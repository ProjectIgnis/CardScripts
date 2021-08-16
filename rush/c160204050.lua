--フュージョン
--Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,Fusion.OnFieldMat)
	c:RegisterEffect(e1)
end