--Grapple Chain
--Scripted by Snrk and Edo
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.tgcon)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--pos
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(s.poscon)
	e3:SetTarget(s.postg)
	e3:SetValue(s.posval)
	c:RegisterEffect(e3)
	--cannot attack
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e4)
end
function s.poscon(e)
	local g=e:GetHandler():GetCardTarget()
	return g:Filter(Card.IsControler,nil,e:GetHandlerPlayer()):GetFirst()
end
function s.postg(e,c)
	return e:GetHandler():IsHasCardTarget(c) and c:IsControler(1-e:GetHandlerPlayer())
end
function s.posval(e)
	local g=e:GetHandler():GetCardTarget()
	local tc1=g:Filter(Card.IsControler,nil,e:GetHandlerPlayer()):GetFirst()
	return tc1:GetPosition()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	if g2:GetFirst():GetPosition()==g1:GetFirst():GetPosition() then
		g1:Merge(g2)
	end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,#g1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if not c:IsRelateToEffect(e) or #g~=2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsControler(1-tp) then tc1,tc2=tc2,tc1 end
	if tc1:IsControler(1-tp) or tc2:IsControler(tp) then return end
	Duel.ChangePosition(tc1,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if c:IsRelateToEffect(re) and g:FilterCount(Card.IsRelateToEffect,nil,re)==2 then
		local tc=g:GetFirst()
		while tc do
			c:SetCardTarget(tc)
			tc=g:GetNext()
		end
	end
end
