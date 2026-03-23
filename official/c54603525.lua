--四天の龍 クリアウィング・シンクロ・ドラゴン
--Clear Wing Synchro Dragon of the Four Heavenly Dragons
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--If this card is Special Summoned: You can destroy 1 Effect Monster your opponent controls, and if you do, this card gains ATK equal to that monster's original ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--When your opponent activates a card or effect (Quick Effect): You can Special Summon 1 Level 4 or lower WIND Tuner from your hand or GY (but negate its effects), then immediately after this effect resolves, you can Synchro Summon 1 WIND Synchro Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SPEEDROID}
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsEffectMonster),tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsEffectMonster),tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsEffectMonster),tp,0,LOCATION_MZONE,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	local c=e:GetHandler()
	local atk=g:GetFirst():GetBaseAttack()
	if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() and atk>0 then
		--This card gains ATK equal to that monster's original ATK
		c:UpdateAttack(atk)
	end
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synchrofilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSynchroSummonable()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		--Negate its effects
		sc:NegateEffects(e:GetHandler())
	end
	if Duel.SpecialSummonComplete()>0 and Duel.IsExistingMatchingCard(s.synchrofilter,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local synchro=Duel.SelectMatchingCard(tp,s.synchrofilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		if synchro then
			Duel.SynchroSummon(tp,synchro)
		end
	end
end