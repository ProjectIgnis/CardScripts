--オールド・マインド
--Old Mind
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,PLAYER_ALL,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.filter(c,ty)
	return c:IsType(ty&0x7) and c:IsDiscardable(REASON_EFFECT)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,nil)
	if #g==0 then return end
	local oc=g:RandomSelect(tp,1):GetFirst()
	Duel.ConfirmCards(tp,oc)
	local b=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,oc:GetType())
		and Duel.IsPlayerCanDraw(tp,1) and c:IsRelateToEffect(e)
	local op=1
	if b then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if op==0 then
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,oc:GetType())
		g:AddCard(oc)
		if Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)==2 then
			Duel.BreakEffect()
			c:CancelToGrave()
			Duel.SendtoHand(c,1-tp,REASON_EFFECT)
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	else
		Duel.SetLP(tp,math.max(Duel.GetLP(tp)-1000,0))
	end
end
