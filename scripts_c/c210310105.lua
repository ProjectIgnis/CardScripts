--Ultimato Mistake - Fallen Waste
--AlphaKretin
function c210310105.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMixN(c,true,true,c210310105.matfilter,2)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--reduce atk
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c210310105.atkcon)
	e2:SetOperation(c210310105.atkop)
	c:RegisterEffect(e2)
	--disable field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCost(c210310105.discost)
	e3:SetTarget(c210310105.distg)
	e3:SetOperation(c210310105.disop)
	c:RegisterEffect(e3)
end
function c210310105.matfilter(c)
	return c:IsSetCard(0xf32) or c:IsSetCard(0xf34)
end
function c210310105.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c210310105.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk/2)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function c210310105.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local seq=bit.lshift(0x1,e:GetHandler():GetPreviousSequence())
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(seq)
	e1:SetOperation(c210310105.discostop)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
end
function c210310105.discostop(e,tp)
	return e:GetLabel()
end
function c210310105.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if c==0 then return end
	local dis1=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
	if c>1 and Duel.SelectYesNo(tp,aux.Stringid(40391316,0)) then
		local dis2=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,dis1)
		dis1=bit.bor(dis1,dis2)
	end
	e:SetLabel(dis1)
end
function c210310105.disop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(c210310105.disopop)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,2)
	Duel.RegisterEffect(e1,tp)
end
function c210310105.disopop(e,tp)
	return e:GetLabel()
end