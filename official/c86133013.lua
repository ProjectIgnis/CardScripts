--レベル・レジストウォール
--Level Resist Wall
--Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,e,tp,ft)
	local lv=c:GetLevel()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,lv)
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsFaceup()
		and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
		and c:HasLevel() and not c:IsType(TYPE_TOKEN) and g:CheckWithSumEqual(Card.GetLevel,lv,1,ft)
end
function s.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) end
	local tg=eg:Filter(s.tgfilter,nil,e,tp,ft)
	if chk==0 then return ft>0 and #tg>0 end
	local tc=nil
	if #tg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=tg:Select(tp,1,1,nil):GetFirst()
	else
		tc=tg:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetLevel()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,lv)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,lv,1,ft)
	if #sg==0 then return end
	local c=e:GetHandler()
	for sc in sg:Iter() do
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			--Negate their effects
			sc:NegateEffects(c)
		end
	end
	Duel.SpecialSummonComplete()
end