--蹴神－ＶＡＲｅｆａｒ
--VARefar, the Judge of Ball
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand, then you can reveal 1 card in your hand and apply an effect based on the type of card revealed
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e1a:SetType(EFFECT_TYPE_QUICK_O)
	e1a:SetRange(LOCATION_HAND)
	e1a:SetCode(EVENT_CHAINING)
	e1a:SetCountLimit(1,id)
	e1a:SetCondition(s.spcon1)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_BE_BATTLE_TARGET)
	e1b:SetCondition(s.spcon2)
	c:RegisterEffect(e1b)
end
function s.spcontgfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsMonsterEffect() and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return trig_loc==LOCATION_MZONE and tg and tg:IsExists(s.spcontgfilter,1,nil,tp)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local bt=Duel.GetAttackTarget()
	return at and bt and at:IsControler(1-tp) and bt:IsControler(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	local opp_mon=(Duel.CheckEvent(EVENT_BE_BATTLE_TARGET) and Duel.GetAttacker())
		or (re:GetHandler():IsRelateToEffect(re) and eg:GetFirst())
		or nil
	if opp_mon then
		e:SetLabelObject(opp_mon)
		if not opp_mon:IsLinkMonster() then
			Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,opp_mon,1,tp,POS_FACEUP_DEFENSE)
		end
		Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,opp_mon,1,tp,opp_mon:GetAttack())
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,opp_mon,1,tp,0)
	end
end
function s.revealfilter(c,types)
	return c:IsType(types) and not c:IsPublic()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local opp_mon=e:GetLabelObject()
		if not opp_mon then return end
		if Duel.CheckEvent(EVENT_BE_BATTLE_TARGET) then
			if not opp_mon:IsRelateToBattle() then return false end
		else
			if not opp_mon:IsRelateToEffect(re) then return false end
		end
		local types=TYPE_SPELL
		if opp_mon:IsCanChangePosition() and opp_mon:IsAttackPos() then types=types|TYPE_MONSTER end
		if opp_mon:IsAbleToRemove() then types=types|TYPE_TRAP end
		if Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND,0,1,nil,types) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local rc=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_HAND,0,1,1,nil,types):GetFirst()
			if not rc then return end
			Duel.BreakEffect()
			Duel.ConfirmCards(1-tp,rc)
			Duel.ShuffleHand(tp)
			local op=rc:GetMainCardType()
			Duel.BreakEffect()
			if op==TYPE_MONSTER then
				--Change it to Defense Position
				Duel.ChangePosition(opp_mon,POS_FACEUP_DEFENSE)
			elseif op==TYPE_SPELL then
				--Its ATK becomes doubled
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_SET_ATTACK)
				e1:SetValue(opp_mon:GetAttack()*2)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				opp_mon:RegisterEffect(e1)
			elseif op==TYPE_TRAP then
				--Banish it
				Duel.Remove(opp_mon,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end