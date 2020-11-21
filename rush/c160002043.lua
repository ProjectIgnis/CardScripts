--属性変更弾
--Attribute Change Blast
--scripted by Naim
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
function s.rvfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.attfilter),tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function s.attfilter(c,att)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsAttribute(att)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp,s.rvfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if tg then
		Duel.ConfirmCards(1-tp,tg)
		Duel.ShuffleHand(tp)
		if Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.attfilter),tp,0,LOCATION_MZONE,nil,tg:GetAttribute())>0 then
			local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.attfilter),tp,0,LOCATION_MZONE,1,3,nil,tg:GetAttribute())
			if g and #g>0 then
				for tc in aux.Next(g) do
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
					e1:SetValue(tg:GetAttribute())
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffectRush(e1)
				end
			end
		end
	end
end
