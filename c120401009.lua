--ラスト・ギャンブル
--Final Confrontation
--Scripted by Eerie Code
function c120401009.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,120401009+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c120401009.sptg)
	e1:SetOperation(c120401009.spop)
	c:RegisterEffect(e1)
	--redo
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c120401009.target)
	e2:SetOperation(c120401009.operation)
	c:RegisterEffect(e2)
end
function c120401009.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c120401009.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c120401009.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c120401009.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c120401009.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c120401009.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,120401009)==0 end
end
function c120401009.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,120401009,RESET_PHASE+PHASE_END,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetCondition(c120401009.coincon)
	e1:SetOperation(c120401009.coinop)
	Duel.RegisterEffect(e1,tp)
end
function c120401009.coincon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetFlagEffect(tp,120401009+100)==0
end
function c120401009.coinop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,120401009+100)~=0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(120401009,0)) then
		Duel.Hint(HINT_CARD,0,120401009)
		Duel.RegisterFlagEffect(tp,120401009+100,RESET_PHASE+PHASE_END,0,1)
		Duel.TossCoin(tp,ev)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+19162135,re,r,rp,tp,1)
	end
end
