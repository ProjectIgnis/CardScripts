--レベル・アワード
--Level Award
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.HasLevel),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.HasLevel),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		local ac=Duel.AnnounceLevel(tp,0,8,tc:GetLevel())
		if ac==0 then
			local e0=Effect.CreateEffect(e:GetHandler())
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_ALLOW_NEGATIVE)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(ac)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end