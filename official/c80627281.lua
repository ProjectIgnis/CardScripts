--海晶乙女雪花
--Marincess Snow
--Credit to Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x12b}
function s.filter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousSetCard(0x12b) and c:GetPreviousTypeOnField()&TYPE_LINK==TYPE_LINK
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsCanBeEffectTarget(e) and c:GetLink()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLink()) 
end
function s.spfilter(c,e,tp,lk)
	return c:IsSetCard(0x12b) and c:IsLinkMonster() and c:GetLink()<lk
		and Duel.GetLocationCountFromEx(tp,tp,nil,c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.filter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=eg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCountFromEx(tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetLink()):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetValue(s.efilter)
			e1:SetOwnerPlayer(tp)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1,true)
			sc:CompleteProcedure()
		end
	Duel.SpecialSummonComplete()
	end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end