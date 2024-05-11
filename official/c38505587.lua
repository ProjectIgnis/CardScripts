--マシマシュマロン
--Moremarshmallon
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.goldsarccon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Your opponent's monsters cannot target other monsters for attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.goldsarccon)
	e2:SetValue(function(e,_c) return _c~=e:GetHandler() end)
	c:RegisterEffect(e2)
	--Special Summon this card from your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and s.goldsarccon(e) end)
	e3:SetTarget(s.selfsptg)
	e3:SetOperation(s.selfspop)
	c:RegisterEffect(e3)
	--Special Summon 1 other "Moremarshmallon" and inflict 1000 damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e4:SetTarget(s.marshsptg)
	e4:SetOperation(s.marshspop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_SHINING_SARCOPHAGUS,id}
local LOCATIONS_REMOVED_HAND_DECK_GRAVE=LOCATION_REMOVED|LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE
function s.goldsarccon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SHINING_SARCOPHAGUS),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.marshspfilter(c,e,tp)
	return c:IsCode(id) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.marshsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.marshspfilter,tp,LOCATIONS_REMOVED_HAND_DECK_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATIONS_REMOVED_HAND_DECK_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.marshspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.marshspfilter),tp,LOCATIONS_REMOVED_HAND_DECK_GRAVE,0,1,1,exc,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end