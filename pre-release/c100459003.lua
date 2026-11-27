--ハーピィ・レディ－華麗なる分身－
--Harpie Lady - Elegant Egotist
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--This card's name becomes "Harpie Lady" while on the field or in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(CARD_HARPIE_LADY)
	c:RegisterEffect(e1)
	--If this card is in your hand and you control a WIND or EARTH monster: You can Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WIND|ATTRIBUTE_EARTH),tp,LOCATION_MZONE,0,1,nil)
	end)
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
	--If this card is Special Summoned: You can Special Summon up to 2 Level 5 "Harpie" monsters from your hand, Deck, and/or GY, also you cannot Special Summon for the rest of this turn, except WIND or EARTH monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.lv5sptg)
	e3:SetOperation(s.lv5spop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_HARPIE_LADY}
s.listed_series={SET_HARPIE}
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.lv5spfilter(c,e,tp)
	return c:IsSetCard(SET_HARPIE) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lv5sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.lv5spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.lv5spop(e,tp,eg,ep,ev,re,r,rp)
	local max_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if max_count>0 then
		max_count=math.min(2,max_count)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max_count=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.lv5spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,max_count,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--You cannot Special Summon for the rest of this turn, except WIND or EARTH monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c)
		return c:IsAttributeExcept(ATTRIBUTE_WIND|ATTRIBUTE_EARTH)
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end