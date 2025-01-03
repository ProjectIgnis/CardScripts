--ファイナル・クロス
--Final Cross
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Grant to a Synchro Monster the ability to attack twice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Check for Synchro Monsters sent to the GY
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_WARRIOR,SET_SYNCHRON,SET_STARDUST}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsType(TYPE_SYNCHRO) then
			Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0 and Duel.IsTurnPlayer(tp) and (Duel.IsAbleToEnterBP() or Duel.IsBattlePhase())
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:CanAttack() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,tg,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		--Can make a second attack
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3201)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		if not s.archetypetest(tc) then return end
		if Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			local atkc=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
			Duel.HintSelection(atkc,true)
			--Gain ATK equal to the ATK of the Synchro monster
			Duel.BreakEffect()
			tc:UpdateAttack(atkc:GetAttack(),RESET_EVENT|RESETS_STANDARD,c)
		end
	end
end
function s.archetypetest(c)
	return c:IsOriginalSetCard(SET_WARRIOR) or c:IsOriginalSetCard(SET_SYNCHRON) or c:IsOriginalSetCard(SET_STARDUST)
end
function s.atkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:GetAttack()>0
end