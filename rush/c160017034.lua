--ウォーターミラー・サーペント
--Watermirror Serpent
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local params = {nil,s.matfilter,function(e,tp,mg) return nil,s.fcheck end}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(s.operation(Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsRace(RACE_DRAGON) and c:IsAbleToGrave()
end
function s.fusfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_WATER)
end
function s.fcheck(tp,sg,fc)
	local mg=sg:Filter(s.fusfilter,nil)
	return #sg>2 and #mg>0
end
function s.cfilter(c)
	return c:IsMonster() and not c:IsRace(RACE_DRAGON|RACE_HIGHDRAGON)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.tdfilter(c)
	return c:IsMonster() and not c:IsType(TYPE_FUSION) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.operation(fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
		Duel.HintSelection(td)
		if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
		fusop(e,tp,eg,ep,ev,re,r,rp)
	end
end