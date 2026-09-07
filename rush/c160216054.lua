--掻き混ぜコスモス姫
--Princess Cosmos Stirs
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Jest of the Cosmos Princess" in the hand or Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND)
	e0:SetValue(160017058)
	c:RegisterEffect(e0)
	--Change Position and Fusion Summon
	local params={fusfilter=aux.FilterBoolFunction(s.fusfilter),matfilter=s.mfilter,extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,maxcount=3}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(s.operation(Fusion.SummonEffOP(params)))
	c:RegisterEffect(e1)
end
s.listed_names={160017058}
function s.fusfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsDefense(1900,2600)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) and c:IsRace(RACE_GALAXY) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
end
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_GALAXY)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_GRAVE,0,nil)>=5
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.operation(fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Requirement
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local td=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)<1 then return end
		--Effect
		fusop(e,tp,eg,ep,ev,re,r,rp)
	end
end