--手札活殺
--Card Devastation
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Send to GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,LOCATION_HAND,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)<1
		or #g:Match(Card.IsLocation,nil,LOCATION_GRAVE)<1
		or not Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,1,nil)
		or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		Duel.BreakEffect()
		-- Update ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(#g*300)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
