--陰陽師 タオタオ
--Taotao the Chanter
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card battles a monster, neither can be destroyed by that battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indestg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Special Summon 1 Level 3 or higher Illusion monster from your hand or GY, or, if you took 2000 or more damage, you can Special Summon it from your Deck or Extra Deck instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp and r&(REASON_BATTLE|REASON_EFFECT)>0 end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
function s.spfilter(c,e,tp,mmz_chk)
	if not (c:IsLevelAbove(3) and c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	local is_in_extra_deck=c:IsLocation(LOCATION_EXTRA)
	return (not is_in_extra_deck and mmz_chk) or (is_in_extra_deck and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local extra_locations=ev>=2000 and LOCATION_DECK|LOCATION_EXTRA or 0
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|extra_locations,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|extra_locations)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local extra_locations=ev>=2000 and LOCATION_DECK|LOCATION_EXTRA or 0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|extra_locations,0,1,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end