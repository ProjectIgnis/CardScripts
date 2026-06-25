--JP name
--Fata Dragna
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2 monsters with the same Type and Attribute, but different Levels
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--Your opponent cannot target Fusion Monsters you control with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsFusionMonster() end)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--If this card is sent to the GY as material for a Fusion Summon: You can Special Summon 1 Fusion Monster from your Extra Deck in Defense Position (but negate its effects, also return it to the Extra Deck during the End Phase), also for the rest of this turn, you cannot Special Summon from the Extra Deck, except Fusion Monsters. You can only use this effect of "Fata Dragna" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsLocation(LOCATION_GRAVE) and (r&REASON_FUSION)==REASON_FUSION end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.matfilter(c,fc,sumtype,sump,sub,matg,sg)
	return c:HasLevel() and (not sg or sg:FilterCount(aux.TRUE,c)==0 or (sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(fc,sumtype,sump),fc,sumtype,sump)
		and sg:IsExists(Card.IsRace,1,c,c:GetRace(fc,sumtype,sump),fc,sumtype,sump)
		and not sg:IsExists(Card.IsLevel,1,c,c:GetLevel())))
end
function s.spfilter(c,e,tp)
	return c:IsFusionMonster() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		--Negate its effects
		sc:NegateEffects(c)
		--Return it to the Extra Deck during the End Phase
		aux.DelayedOperation(sc,PHASE_END,id,e,tp,function(ag) Duel.SendtoDeck(ag,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,1))
	end
	Duel.SpecialSummonComplete()
	--For the rest of this turn, you cannot Special Summon from the Extra Deck, except Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsFusionMonster() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end