--怨念の小太刀
--Saber of Malice
Duel.EnableUnofficialRace(RACE_YOKAI)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	-- destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local d=Duel.GetAttackTarget()
	return ec==Duel.GetAttacker() and d and d:IsDefensePos() and ec:IsRace(RACE_YOKAI)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	if tc and tc:IsRelateToBattle() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end