--選律のヴァルモニカ
--Vaalmonica Chosen Melody
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VALMONICA}
function s.cfilter(c)
	return c:IsSetCard(SET_VALMONICA) and c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
end
function s.linkfilter(c)
	return c:IsSetCard(SET_VALMONICA) and c:IsFaceup() and c:IsLinkMonster()
end
function s.disfilter(c)
	return c:IsNegatableMonster() and c:IsType(TYPE_EFFECT)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,angle_or_delvin) --Additional parameter used by "Angelo Valmonica" and "Demone Valmonica"
	local op=nil
	if angle_or_delvin then
		op=angle_or_delvin
	else
		local both=Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil)
		op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,1)},
			{true,aux.Stringid(id,2)},
			{both,aux.Stringid(id,3)})
	end
	local break_chk=nil
	local c=e:GetHandler()
	if op==1 or op==3 then
		--Gain 500 LP and apply the targeting procetion effect
		if Duel.Recover(tp,500,REASON_EFFECT)>0 and not Duel.HasFlagEffect(tp,id) then
			break_chk=true
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,aux.Stringid(id,4))
			--Your opponent cannot target "Valmonica" Monster Cards you control with card effects
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e1:SetTargetRange(LOCATION_ONFIELD,0)
			e1:SetTarget(function(_e,_c) return s.cfilter(_c) end)
			e1:SetValue(aux.tgoval)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
	if op==2 or op==3 then
		--Take 500 damage and negate the effects of 1 opponent's Effect Monster
		local g=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_MZONE,nil)
		if break_chk then Duel.BreakEffect() end
		if Duel.Damage(tp,500,REASON_EFFECT)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
			local nc=g:Select(tp,1,1,nil):GetFirst()
			Duel.HintSelection(nc,true)
			Duel.BreakEffect()
			nc:NegateEffects(c,RESET_PHASE|PHASE_END)
		end
	end
end