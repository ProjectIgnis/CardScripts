--ゴーストリック・サキュバス
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(s.atkcon)
	e2:SetValue(aux.imval2)
	c:RegisterEffect(e2)
end
s.listed_series={0x8d}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
function s.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local atk=cg:GetSum(Card.GetAttack)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,atk) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local seq=tc:GetSequence()
	if tc:IsControler(1-tp) then seq=seq+16 end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local g=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_OVERLAY,0,1)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetLabel(seq)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetReset(0)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.cfilter2(c)
	return s.cfilter(c) and c:GetFlagEffect(id)~=0
end
function s.discon(e)
	local g=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	if g:IsExists(s.cfilter2,1,nil) then
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_OVERLAY,0,1)
			tc=g:GetNext()
		end
		return true
	end
	e:Reset()
	return false
end
function s.disop(e,tp)
	return (0x1<<e:GetLabel())
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
