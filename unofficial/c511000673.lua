--ガガガ流－明鏡死斬
--Gagaga Mirror Slash
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e) return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GAGAGA}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsSetCard(SET_GAGAGA) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_GAGAGA),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_GAGAGA),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		--Target cannot be destroyed by battle
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Inflict damage if the target destroys a monster by battle
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(511000673,0))
		e2:SetCategory(CATEGORY_DAMAGE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.damcon)
		e2:SetTarget(s.damtg)
		e2:SetOperation(s.damop)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		--Target's ATK and name becomes the same ATK and name of the monster it battles
		local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_ATKCHANGE)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLE_START)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetOperation(s.atkop)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	return eg:IsContains(tc) and bc:IsLocation(LOCATION_GRAVE) and bc:IsMonster()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	Duel.SetTargetCard(bc)
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(tc:GetCode())
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		c:RegisterEffect(e2)
	end
end