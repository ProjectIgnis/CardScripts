--エレキック・ファイティング・ポーター
--Wattsychic Fighting Porter
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon up to 2 Level 3 or lower LIGHT monsters from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and #g==2 then
		local typ=g:GetClassCount(Card.GetOriginalRace)==1
		local lv=g:GetClassCount(Card.GetOriginalLevel)==1
		local c=e:GetHandler()
		for tc in g:Iter() do
			if typ then
				--Can attack directly this turn
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(3205)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_DIRECT_ATTACK)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e1)
			end
			if lv then
				--Cannot be destroyed by battle this turn
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(3000)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
				e2:SetValue(1)
				e2:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
end