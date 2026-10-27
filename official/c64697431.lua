--局所的ハリケーン
--Hey, Trunade!
local s,id=GetID()
function s.initial_effect(c)
	--Return all Set Spells and Traps on the field to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.rthfilter(c)
	return c:IsFacedown() and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local g=Duel.GetMatchingGroup(s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end