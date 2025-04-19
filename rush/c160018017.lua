--Ｎ・アクア・ドルフィン
--Neo-Spacian Aqua Dolphin (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_HAND)
end
function s.disfilter(c,atk)
	return c:IsMonster() and c:IsAttackBelow(atk) and c:IsAbleToGrave()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)<1 then return end
	--Effect
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	Duel.ConfirmCards(tp,g)
	local pg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local _,atk=pg:GetMaxGroup(Card.GetAttack)
	if Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_HAND,1,nil,atk) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local tg=g:FilterSelect(tp,s.disfilter,1,1,nil,atk)
		if Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
	Duel.ShuffleHand(1-tp)
end