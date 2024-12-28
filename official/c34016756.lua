--フォース
--Riryoku
local s,id=GetID()
function s.initial_effect(c)
	--Halve the ATK of a monster and increase the ATK of another by the same amount
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local hc=g:GetFirst()
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		hc=g:Select(tp,1,1,nil):GetFirst()
	end
	g:RemoveCard(hc)
	local c=e:GetHandler()
	local atk=hc:GetAttack()
	--Halve the ATK of one monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(atk/2)
	hc:RegisterEffect(e1)
	if not hc:IsImmuneToEffect(e1) and #g>0 then
		--Add that lost ATK to the other monster
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		e2:SetValue(atk/2)
		g:GetFirst():RegisterEffect(e2)
	end
end