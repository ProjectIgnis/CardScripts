-- キノの蟲惑魔
-- Traptrix Arachnocampa
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Unaffected by the effects of "Hole" Normal Traps
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immfilter)
	c:RegisterEffect(e2)
	-- Set cards destruction protection
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(function(_,c) return c:IsFacedown() and c:GetSequence()<5 end)
	e3:SetValue(function(_,_,r) return (r&REASON_EFFECT==REASON_EFFECT) and 1 or 0 end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_TRAPTRIX,SET_HOLE}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_TRAPTRIX),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- Cannot Special Summon monsters from the Extra Deck, except Insect or Plant monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_INSECT|RACE_PLANT) end)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	-- Lizard check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalRace(RACE_INSECT|RACE_PLANT) end)
end
function s.immfilter(e,te)
	local c=te:GetOwner()
	return c:GetType()==TYPE_TRAP and (c:IsSetCard(SET_HOLE) or c:IsSetCard(SET_TRAP_HOLE))
end