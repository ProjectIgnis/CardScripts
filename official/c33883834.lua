--紫炎の寄子
--Shien's Squire
local s,id=GetID()
function s.initial_effect(c)
	--Your battling "Six Samurai" monster cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SIX_SAMURAI}
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and ((a:IsControler(tp) and a:IsSetCard(SET_SIX_SAMURAI)) or (d:IsControler(tp) and d:IsSetCard(SET_SIX_SAMURAI)))
		and Duel.GetFlagEffect(tp,id)==0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_DAMAGE_CAL,0,1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(3000)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(1)
	if a:IsControler(tp) then
		a:RegisterEffect(e1)
	else
		d:RegisterEffect(e1)
	end
end