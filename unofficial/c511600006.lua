--Magicians Unite (Anime)
--マジシャンズ・クロス
--edited by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:GetAttackedCount()==0 and c:CanAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,2,2,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE)
end
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.tgfilter,nil,e)
	if #tg==2 then
		local c=e:GetHandler()
		for tc in aux.Next(tg) do
			local g=tg
			g:RemoveCard(tc)
			tc:SetCardTarget(g:GetFirst())
			--Destroy
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetLabelObject(g:GetFirst())
			e1:SetOperation(s.desop)
			tc:RegisterEffect(e1)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
		local ag=tg:Select(tp,1,1,nil)
		tg:Sub(ag)
		local tc1=ag:GetFirst()
		local tc2=tg:GetFirst()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetLabelObject(tc2)
		e2:SetCondition(s.atkcon)
		e2:SetValue(3000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		tc2:RegisterEffect(e3)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCardTarget():IsContains(e:GetLabelObject())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local g=c:GetCardTarget()
	if c:IsReason(REASON_DESTROY) and g:IsContains(tc) and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,r&REASON_EFFECT|r&REASON_BATTLE|r&REASON_RULE)
	end
	e:Reset()
end
