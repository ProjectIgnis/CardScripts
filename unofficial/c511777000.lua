--
local s,id=GetID()
function s.initial_effect(c)
	--Heal or Hurt?idk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.SelectYesNo(tp,aux.Stringid(4008,2)) then op1=1 else op1=0 end
	if Duel.SelectYesNo(1-tp,aux.Stringid(4008,3)) then op2=1 else op2=0 end
	if (op1==0 and op2==0) or (op1==1 and op2==1) then
		op3=0
	else
		op3=1
	end
	e:SetLabel(op3)
	if op3==0 then
		e:SetCategory(CATEGORY_RECOVER)
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(500)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,1,1-tp,500)
	else
		e:SetCategory(CATEGORY_DAMAGE)
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(500)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if e:GetLabel()==0 then
		Duel.Recover(p,d,REASON_EFFECT)
	else Duel.Damage(p,d,REASON_EFFECT) end
end
