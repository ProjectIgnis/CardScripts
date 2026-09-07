--アビストローム
--Abyss-strom
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 face-up "Umi" you control to the GY; send all Spells/Traps on the field to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_SSET)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI}
function s.costfilter(c,hc)
	return c:IsCode(CARD_UMI) and c:IsFaceup() and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,hc))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local exc=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler() or nil
		return Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsRelateToEffect(e) and c or nil
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end