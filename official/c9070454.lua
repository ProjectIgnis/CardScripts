--龍皇の波動
--Draco-Utopian Aura
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return Duel.IsChainNegatable(ev) and re:IsMonsterEffect() and (loc&LOCATION_MZONE)~=0 and ep==1-tp
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,rc,1,tp,LOCATION_GRAVE)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToRemove()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		local oc=Duel.GetOperatedGroup():GetFirst()
		local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
		if oc:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and #cg>0 and oc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=cg:Select(tp,1,1,nil)
			if #rg==0 then return end
			Duel.BreakEffect()
			if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 and Duel.SpecialSummonStep(oc,0,tp,tp,false,false,POS_FACEUP) then
				local c=e:GetHandler()
				--Negate its effects
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				oc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				oc:RegisterEffect(e2)
			end
			Duel.SpecialSummonComplete()
		end
	end
end