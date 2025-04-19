-- 火麺ドローっと濃厚返しの術
--The Noodle Art of Saucery
-- Scripted bu Hatter
local s,id=GetID()
function s.initial_effect(c)	
	-- Draw
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PYRO)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.filter2(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PYRO) and c:IsFaceup()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	local pg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,#pg,e:GetHandler())
	if #g<1 then return end
	local dr=Duel.SendtoGrave(g,REASON_COST)
	-- Effect
	if dr>0 and Duel.Draw(tp,dr,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end