--キューピッド・キス
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(s.ctcon)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local d=Duel.GetAttackTarget()
	local a=Duel.GetAttacker()
	return tc==d and d and a:IsRelateToBattle() and a:IsFaceup() and a==e:GetHandler():GetEquipTarget() 
		and d:IsFaceup() and d:GetCounter(0x1090)>0
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=Duel.GetAttackTarget()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
