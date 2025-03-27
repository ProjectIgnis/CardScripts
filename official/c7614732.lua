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
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Cannot be destroyed by card effects
		local e2=e1:Clone()
		e2:SetDescription(3001)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		tc:RegisterEffect(e2,true)
		if not tc:IsType(TYPE_EFFECT) then
			--Becomes an Effect Monster if it wasn't already one
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_ADD_TYPE)
			e3:SetValue(TYPE_EFFECT)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e3,true)
		end
	end
end