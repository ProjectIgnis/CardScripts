--ヒーローズ・バックアップ
--Hero's Backup
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(function() return Duel.IsBattlePhase() and aux.StatChangeDamageStepCondition() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ELEMENTAL_HERO}
function s.targetfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.oppmonfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.oppmonfilter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk+1000)
end
function s.rmvfilter(c)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.targetfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.targetfilter,tp,LOCATION_MZONE,0,1,nil,tp) 
		and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.targetfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local g=Duel.GetMatchingGroup(s.rmvfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if rg and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
			tc:UpdateAttack(rg:GetBaseAttack(),RESET_EVENT|RESETS_STANDARD,c)
		end
	end
end
