--方界輪廻
--Cubic Rebirth
local s,id=GetID()
local COUNTER_CUBIC=0x1038
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CUBIC}
s.counter_place_list={COUNTER_CUBIC}
function s.cubicspfilter(c,e,tp)
	return c:IsSetCard(SET_CUBIC) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local bc=Duel.GetAttacker()
	if chkc then return chkc==bc end
	if chk==0 then return bc:IsOnField() and bc:IsCanBeEffectTarget(e) and bc:IsCanAddCounter(COUNTER_CUBIC,1)
		and Duel.IsExistingMatchingCard(s.cubicspfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.oppspfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local opp=1-tp
	local tg=Group.FromCards(tc)
	local ft=Duel.GetLocationCount(opp,LOCATION_MZONE,opp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.oppspfilter),opp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,opp,tc:GetCode())
	if ft>0 and #g>0 then
		if Duel.IsPlayerAffectedByEffect(opp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_SPSUMMON)
		local sg=g:Select(opp,ft,ft,nil)
		for sc in sg:Iter() do
			Duel.SpecialSummonStep(sc,0,opp,opp,false,false,POS_FACEUP_ATTACK)
		end
		Duel.SpecialSummonComplete()
		local og=Duel.GetOperatedGroup()
		tg:Merge(og)
	end
	local c=e:GetHandler()
	local counter_chk=false
	for tc in tg:Iter() do
		--The ATK of the targeted monster and those Special Summoned monster(s) become 0 and place 1 Cubic Counter on each
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if tc:AddCounter(COUNTER_CUBIC,1) then counter_chk=true end
		--Monsters with a Cubic Counter cannot attack, also negate their effects
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetCondition(function(e) return e:GetHandler():GetCounter(COUNTER_CUBIC)>0 end)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e3)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local cubicg=Duel.SelectMatchingCard(tp,s.cubicspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #cubicg>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(cubicg,0,tp,tp,true,false,POS_FACEUP)
	end
end