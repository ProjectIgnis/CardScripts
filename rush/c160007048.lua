-- 瓦バーン
-- Tile Burn
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Burn
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damconfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(s.damconfilter),tp,LOCATION_MZONE,0,1,nil)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=5
		and Duel.IsExistingMatchingCard(aux.AND(s.damconfilter,Card.IsAbleToGraveAsCost),tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SelectMatchingCard(tp,aux.AND(s.damconfilter,Card.IsAbleToGraveAsCost),tp,LOCATION_HAND,0,1,1,nil)
	if #cg<1 or Duel.SendtoGrave(cg,REASON_COST)<1 then return end
	-- Effect
	local g=Duel.GetMatchingGroup(function(c)return c:GetSequence()<5 end,tp,0,LOCATION_DECK,nil)
	if #g<5 then return end
	Duel.ConfirmCards(tp,g)
	local ct=g:FilterCount(Card.IsMonster,nil)
	if ct>0 then Duel.Damage(1-tp,ct*400,REASON_EFFECT) end
	Duel.MoveToDeckTop(g,1-tp)
	Duel.SortDecktop(1-tp,1-tp,5)
end