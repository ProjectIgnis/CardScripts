--ライト・ロー・プロテクション
--Lightlow Protection
Duel.EnableUnofficialProc(PROC_STATS_CHANGED)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(id)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec or not eg:IsContains(ec) then return false end
	local val=0
	if ec:GetFlagEffect(284)>0 then val=ec:GetFlagEffectLabel(284) end
	return ec:GetAttack()~=val and rp~=tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetEquipTarget(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Destroy(c:GetEquipTarget(),REASON_EFFECT)
	end
end