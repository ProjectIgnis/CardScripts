--窮鼠の進撃
--Attack of the Cornered Rat
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(d)
	return a:IsFaceup() and a:IsLevelBelow(3) and a:IsType(TYPE_NORMAL) and a:IsRelateToBattle()
		and d:IsFaceup() and d:IsRelateToBattle()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		for _,eff in pairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_LPCOST_CHANGE)}) do
			local val=eff:GetValue()
			if (type(val)=='integer' and val==0)
				or (type(val)=='function' and (val(eff,e,tp,100)~=100)) then
				return false
			end
		end
		return e:GetHandler():GetFlagEffect(id)==0 and Duel.CheckLPCost(tp,100)
		and e:GetLabelObject():IsAttackAbove(100)
	end
	local lp=Duel.GetLP(tp)
	local atk=e:GetLabelObject():GetAttack()
	local t={}
	for i=1,math.floor(math.min(lp,atk)/100) do t[i]=i*100 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local pay=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,pay)
	e:SetLabel(-pay)
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE|PHASE_DAMAGE,0,1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tc)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetFirstTarget()
	if not e:GetHandler():IsRelateToEffect(e) or not bc or not bc:IsRelateToEffect(e) or not bc:IsControler(1-tp) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(e:GetLabel())
	bc:RegisterEffect(e1)
end