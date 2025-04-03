--ネクロ・ディフェンダー
--Necro Defender
local s,id=GetID()
function s.initial_effect(c)
	--Targeted monster cannot be destroyed by battle, also take no battle damage involving it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,2)
		--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3000)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END,2)
		tc:RegisterEffect(e1)
		--You take no battle damage from battles involving it
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetTargetRange(1,0)
		e2:SetTarget(function(e,c) return c:HasFlagEffect(id) end)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,0,2)
		Duel.RegisterEffect(e2,tp)
	end
end