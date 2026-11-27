--The Legendary Gambler
--scripted by: UnknownGuest
--Fixed by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--dice
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_DICE_NEGATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.roll_dice=true
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainDisablable(ev) then return false end
	local ex=Duel.GetOperationInfo(ev,CATEGORY_DICE)
	return ex and re:GetHandler():GetControler(1-tp) and re:GetHandler()~=e:GetHandler()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,Group.FromCards(re:GetHandler()),1,1-tp,re:GetHandler():GetLocation())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_CARD,0,id)
		local cd=Duel.GetDiceResult()
		if cd~=0 then
			local dc=Duel.TossDice(tp,1)
			if dc>=cd then
				Duel.NegateEffect(ev)
			end
		end
	end
end
