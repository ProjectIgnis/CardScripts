--－Ａｉ－ＳＨＯＷ
--A.I.'s Show
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x135}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.GetAttacker():IsControler(tp)
end
function s.spfilter(c,e,tp,zones)
	return c:IsRace(RACE_CYBERSE) and not c:IsType(TYPE_LINK) and c:GetAttack()==2300
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zones)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetSum(Card.GetAttack)<=e:GetLabel()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc==Duel.GetAttacker() end
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) and tg:IsAttackAbove(2300)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Duel.GetLinkedZone(tp)) end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsAttackAbove(2300) then
		local zones=Duel.GetLinkedZone(tp)
		local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,zones)
		if #tg<=0 then return end
		e:SetLabel(tc:GetAttack())
		local sg=aux.SelectUnselectGroup(tg,e,tp,1,Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zones),s.rescon,1,tp,HINTMSG_SPSUMMON)
		e:SetLabel(0)
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP,zones)>0 then
			Duel.BreakEffect()
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
		end
	end
end
