--二量合成
--Dimer Synthesis
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Change ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CHEMICRITTER}
s.listed_names={65959844,25669282}
s.listed_card_types={TYPE_GEMINI}
function s.codefilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function s.chemfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CHEMICRITTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local f1=Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_DECK,0,1,nil,65959844)
	local f2=Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_DECK,0,1,nil,25669282)
		and Duel.IsExistingMatchingCard(s.chemfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return f1 or f2 end
	local op=Duel.SelectEffect(tp,
		{f1,aux.Stringid(id,2)},
		{f2,aux.Stringid(id,3)})
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,op+1,tp,LOCATION_DECK)
end
function s.threscon(sg)
	return #sg==2 and sg:FilterCount(s.chemfilter,nil)==1
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,s.codefilter,tp,LOCATION_DECK,0,1,1,nil,65959844)
		if #g1>0 then
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g1)
		end
	elseif op==2 then
		local g1=Duel.GetMatchingGroup(s.codefilter,tp,LOCATION_DECK,0,nil,25669282)
		local g2=Duel.GetMatchingGroup(s.chemfilter,tp,LOCATION_DECK,0,nil)
		if #g1==0 or #g2==0 then return end
		local sg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.threscon,1,tp,HINTMSG_ATOHAND)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function s.atkrescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsGeminiStatus,1,nil) and sg:IsExists(Card.IsAttackAbove,1,nil,1)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeEffectTarget,e),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.atkrescon,0,tp) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.atkrescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e)
	if #sg~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	local tc1=sg:FilterSelect(tp,Card.IsAttackAbove,1,1,nil,1):GetFirst()
	if not tc1 or tc1:IsImmuneToEffect(e) then return end
	local c=e:GetHandler()
	--Change ATK to 0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(0)
	tc1:RegisterEffect(e1)
	if not tc1:IsAttack(0) then return end
	local tc2=(sg-tc1):GetFirst()
	if not tc2 or tc2:IsImmuneToEffect(e) then return end
	--Increase ATK
	tc2:UpdateAttack(tc1:GetBaseAttack(),RESETS_STANDARD_PHASE_END,c)
end