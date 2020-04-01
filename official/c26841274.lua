--D－フュージョン
--D-Fusion
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterEffect(Fusion.CreateSummonEff(c,nil,Fusion.OnFieldMat(aux.FilterBoolFunction(Card.IsSetCard,0xc008)),nil,nil,nil,s.stage2))
end
s.listed_series={0xc008}
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
