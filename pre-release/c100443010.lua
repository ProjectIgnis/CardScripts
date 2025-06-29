--魂の結束－ソウル・ユニオン
--Soul Union
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ELEMENTAL_HERO}
function s.atkfilter(c)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:HasNonZeroAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	e:SetLabelObject(tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusconfilter(c)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsType(TYPE_NORMAL) and c:IsFaceup()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg~=2 then return end
	local fc=e:GetLabelObject()
	local gc=(tg-fc):GetFirst()
	if fc:IsFaceup() and not fc:IsImmuneToEffect(e) then
		--That monster on the field gains ATK equal to the ATK of that other monster in the GY until the end of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(gc:GetAttack())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		fc:RegisterEffect(e1)
		if not Duel.IsExistingMatchingCard(s.fusconfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) then return end
		local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_ELEMENTAL_HERO),matfilter=function(c) return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove() end,extrafil=s.fextra,extraop=Fusion.BanishMaterial}
		if Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end