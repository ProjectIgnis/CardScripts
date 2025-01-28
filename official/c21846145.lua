--アブダクション
--Abduction
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 monster from your Deck or Extra Deck and take control of opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.ctfilter(c,tp)
	if not (c:IsFaceup() and c:IsAbleToChangeControler()) then return false end
	local original_lvrklnk=(c:HasLevel() and c:GetOriginalLevel())
		or (c:HasRank() and c:GetOriginalRank())
		or (c:IsLinkMonster() and c:GetLink())
	return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,c:GetOriginalRace(),c:GetOriginalAttribute(),c,original_lvrklnk)
end
function s.rmfilter(c,race,attr,tc,lvrklnk)
	return c:IsAbleToRemove() and c:IsOriginalRace(race) and c:IsOriginalAttribute(attr)
		and ((tc:HasLevel() and c:IsOriginalLevel(lvrklnk))
		or (tc:HasRank() and c:IsOriginalRank(lvrklnk))
		or (tc:IsLinkMonster() and c:IsLink(lvrklnk)))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
		and Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local original_lvrklnk=(tc:HasLevel() and tc:GetOriginalLevel())
		or (tc:HasRank() and tc:GetOriginalRank())
		or (tc:IsLinkMonster() and tc:GetLink())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rc=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,tc:GetOriginalRace(),tc:GetOriginalAttribute(),tc,original_lvrklnk):GetFirst()
	if rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 and rc:IsLocation(LOCATION_REMOVED)
		and Duel.GetControl(tc,tp) and rc:IsOriginalCodeRule(tc:GetOriginalCodeRule()) then
		tc:NegateEffects(e:GetHandler(),RESET_CONTROL)
	end
end