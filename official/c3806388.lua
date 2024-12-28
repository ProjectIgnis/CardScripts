--混沌核
--Core of Chaos
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--Must be Special Summoned by a card effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(_,se) return se:IsHasType(EFFECT_TYPE_ACTIONS) end)
	c:RegisterEffect(e1)
	--Banish this card if it would leave the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	--Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.hspcost)
	e3:SetTarget(s.hsptg)
	e3:SetOperation(s.hspop)
	c:RegisterEffect(e3)
	--Special Summon 1 banished "Core of Chaos"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={77312273}
function s.hspcostfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
		and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true))
end
function s.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE
	if chk==0 then return Duel.IsExistingMatchingCard(s.hspcostfilter,tp,loc,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.hspcostfilter,tp,loc,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--Cannot Special Summon monsters from the Extra Deck, except LIGHT or DARK Synchro monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK))
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_SYNCHRO) or not c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(77312273) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end