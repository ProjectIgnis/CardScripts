--ＥＭバラクーダ
--Performapal Barracuda
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Make an opponent's monster that battles your "Performapal" monster lose ATK equal to the difference between its original ATK and current ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.oppatkcon)
	e1:SetOperation(s.oppatkop)
	c:RegisterEffect(e1)
	--Make 1 "Performapal" monster whose current ATK is different from its original ATK gain ATK equal to the difference until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCondition(aux.StatChangeDamageStepCondition)
	e2:SetTarget(s.ppalatktg)
	e2:SetOperation(s.ppalatkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PERFORMAPAL}
function s.oppatkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc1,bc2=Duel.GetBattleMonster(tp)
	return bc1 and bc1:IsSetCard(SET_PERFORMAPAL) and bc2 and not bc2:IsAttack(bc2:GetBaseAttack())
end
function s.oppatkop(e,tp,eg,ep,ev,re,r,rp)
	local _,bc=Duel.GetBattleMonster(tp)
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		local diff=math.abs(bc:GetBaseAttack()-bc:GetAttack())
		--It loses ATK equal to the difference between its original ATK and current ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-diff)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		bc:RegisterEffect(e1)
	end
end
function s.ppalatkfilter(c)
	return c:IsSetCard(SET_PERFORMAPAL) and c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
function s.ppalatktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.ppalatkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ppalatkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,s.ppalatkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.ppalatkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local diff=math.abs(tc:GetBaseAttack()-tc:GetAttack())
		--It gains ATK equal to the difference until the end of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(diff)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
