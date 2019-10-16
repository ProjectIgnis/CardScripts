--妖仙獣の風祀り
--Yosenju Wind Ritual
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xb3}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3) and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_PENDULUM))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3) and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_PENDULUM)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.rtfilter(c,p)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(p)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil) --group to return
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then --returns the group
		local ct=Duel.GetOperatedGroup():FilterCount(s.rtfilter,nil,tp) --gets the returned group
		if ct==#g then --checks if returned the whole group
			local ct=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0) --gets what I could draw
			if ct>0 and Duel.IsPlayerCanDraw(tp,ct) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then --if I can AND want to draw
				Duel.Draw(tp,ct,REASON_EFFECT) 
			end
		end
	end
end
