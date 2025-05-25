--巳剣之勾玉
--Mitsurugi Magatama
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MITSURUGI}
s.ritparams={
	lvtype=RITPROC_GREATER,
	filter=aux.FilterBoolFunction(Card.IsSetCard,SET_MITSURUGI),
	matfilter=aux.FilterBoolFunction(Card.IsLocation,LOCATION_MZONE)
}
function s.rescon(sg,tp)
	return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,sg)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	local b1=Duel.CheckReleaseGroupCost(tp,Card.IsRace,1,false,s.rescon,nil,RACE_REPTILE)
	local b2=Ritual.Target(s.ritparams)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local rg=Duel.SelectReleaseGroupCost(tp,Card.IsRace,1,1,false,s.rescon,nil,RACE_REPTILE)
		Duel.Release(rg,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Destroy 1 card your opponent controls
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif op==2 then
		--Ritual Summon1 "Mitsurugi" Ritual Monster from your hand, by Tributing monsters you control
		Ritual.Operation(s.ritparams)(e,tp,eg,ep,ev,re,r,rp)
	end
end