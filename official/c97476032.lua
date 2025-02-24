--アイス・ドール
--Ice Doll
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.AND(s.wateronlycost,Cost.Discard(aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),true)))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 WATER Spellcaster Monster from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.wateronlycost)
	e2:SetTarget(s.thtg(s.waterthfilter))
	e2:SetOperation(s.thop(s.waterthfilter))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Add 1 "Ice Doll Mirror" from your Deck to your hand
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e4:SetTarget(s.thtg(s.mirrorthfilter))
	e4:SetOperation(s.thop(s.mirrorthfilter))
	c:RegisterEffect(e4)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return c:IsAttribute(ATTRIBUTE_WATER) end)
end
s.listed_names={65569724} --"Ice Doll Mirror"
function s.wateronlycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon the turn you activate this effect, except WATER monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsAttributeExcept(ATTRIBUTE_WATER) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.waterthfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
function s.mirrorthfilter(c)
	return c:IsCode(65569724) and c:IsAbleToHand()
end
function s.thtg(thfilter)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(thfilter,tp,LOCATION_DECK,0,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.thop(thfilter)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end