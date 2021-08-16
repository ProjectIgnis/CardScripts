--フュージョン
--Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,nil,Fusion.OnFieldMat(Card.IsFaceup))
end