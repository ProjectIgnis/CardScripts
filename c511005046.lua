--Final Prophecy
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCondition(s.dm_cd)
	e1:SetTarget(s.dm_tg)
	e1:SetOperation(s.dm_op)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetCondition(s.cd)
	e2:SetCost(s.cs)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
function s.dm_cd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(id)==0
end

function s.dm_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,e:GetLabel())
end

function s.dm_op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if e:GetLabel()>0 then
		Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
		Duel.Damage(1-tp,e:GetLabel(),REASON_EFFECT)
	end
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

function s.cd(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and rp~=tp
end
function s.eq_fil(c)
	return c:IsType(TYPE_EQUIP) and c:IsFaceup()
end
function s.cs(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eq_fil,tp,LOCATION_SZONE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.eq_fil,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst():GetEquipTarget()
	local atk=tc:GetAttack()
	Duel.Destroy(g,REASON_COST)
	e:GetLabelObject():SetLabel(math.abs(atk-tc:GetAttack()))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.NegateEffect(ev)
		if re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
		if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
			e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
end