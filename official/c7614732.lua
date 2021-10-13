--大融合
--Greater Polymerization
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	Fusion.RegisterSummonEff{handler=c,mincount=3,stage2=s.stage2}
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Piercing
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(3208)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Cannot be destroyed by card effects
		local e2=e1:Clone()
		e2:SetDescription(3001)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		tc:RegisterEffect(e2,true)
	end
end
