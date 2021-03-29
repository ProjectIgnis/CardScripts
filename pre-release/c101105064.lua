-- 二量合成
-- Dimer Synthesis
-- scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Change ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={0xeb}
s.listed_names={65959844,25669282}
function s.codefilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function s.chemfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xeb) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local f1 = Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_DECK,0,1,nil,65959844)
	local f2 = Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_DECK,0,1,nil,25669282)
		and Duel.IsExistingMatchingCard(s.chemfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return f1 or f2 end
	if f1 and f2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
	elseif f1 and not f2 then
		e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0)))
	elseif f2 and not f1 then
		e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,1))+1)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel()+1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,s.codefilter,tp,LOCATION_DECK,0,1,1,nil,65959844)
		if #g1>0 then
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g1)
		end
	elseif op==1 then
		local g1=Duel.GetMatchingGroup(s.codefilter,tp,LOCATION_DECK,0,nil,25669282)
		local g2=Duel.GetMatchingGroup(s.chemfilter,tp,LOCATION_DECK,0,nil)
		if #g1>0 and #g2>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g1:Select(tp,1,1,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			sg=sg+g2:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsGeminiState,1,nil) and sg:IsExists(Card.IsAttackAbove,1,nil,1)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCanBeEffectTarget,e),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0,tp) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.FilterFaceupFunction(Card.IsRelateToEffect,e),nil)
	if #sg~=2 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g=sg:FilterSelect(tp,Card.IsAttackAbove,1,1,nil,1)
	if #g==0 then return end
	local tc1=g:GetFirst()
	local tc2=(sg-tc1):GetFirst()
	if tc1:IsImmuneToEffect(e) then return end
	--Change ATK to 0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(0)
	tc1:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(tc1:GetBaseAttack())
	tc2:RegisterEffect(e2)
end